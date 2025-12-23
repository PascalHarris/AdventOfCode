ImportInputData[defaultFile_String : ""] := Module[
  {file, data},
  (*Try default file first,or open dialog if not specified/not found*)
  file = If[defaultFile =!= "" && FileExistsQ[defaultFile],
    defaultFile,
    SystemDialogInput["FileOpen",
     WindowTitle -> "Select Input Data File",
     FileNameFilter -> {"Text files" -> {"*.txt"}, "All files" -> {"*"}}
     ]
    ];
  
  (*User cancelled the dialog*)
  If[file === $Canceled, Message[ImportInputData::cancelled];
   Abort[]
   ];
  (*File doesn't exist*)
  If[! FileExistsQ[file], Message[ImportInputData::notfound, file];
   Abort[]
   ];
  (*Attempt import*)data = Quiet[Import[file, {"Text", "Lines"}]];
  If[data === $Failed || ! ListQ[data], 
   Message[ImportInputData::importfail, file];
   Abort[]
   ];
  data
  ]

(*Define error messages*)
ImportInputData::cancelled = "File selection was cancelled.";
ImportInputData::notfound = "File not found: `1`"; 
ImportInputData::importfail = "Failed to import file: `1`";

data = ImportInputData["input-21.txt"];
p1Start = ToExpression[StringCases[data[[1]], RegularExpression["\\d+$"]][[1]]];
p2Start = ToExpression[StringCases[data[[2]], RegularExpression["\\d+$"]][[1]]];

pos = {p1Start, p2Start};
scores = {0, 0};
die = 1;
rolls = 0;
player = 1;

While[Max[scores] < 1000,
  roll = Mod[die - 1, 100] + 1 + Mod[die, 100] + 1 + Mod[die + 1, 100] + 1;
  die = Mod[die + 2, 100] + 1;
  rolls += 3;
  pos[[player]] = Mod[pos[[player]] + roll - 1, 10] + 1;
  scores[[player]] += pos[[player]];
  player = 3 - player;
];

Min[scores] * rolls