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


hitsTarget[vx0_, vy0_, x1_, x2_, y1_, y2_] := Module[{x = 0, y = 0, vx = vx0, vy = vy0},
  While[x <= x2 && y >= y1,
    x += vx;
    y += vy;
    vx = Max[vx - 1, 0];
    vy -= 1;
    If[x1 <= x <= x2 && y1 <= y <= y2, Return[True]];
  ];
  False
]

data = ImportInputData["input-17.txt"];
nums = ToExpression /@ 
   StringCases[First[data], RegularExpression["-?[0-9]+"]];
{xMin, xMax, yMin, yMax} = nums;

count = 0;
Do[If[hitsTarget[vx, vy, xMin, xMax, yMin, yMax], count++], {vx, 1, 
   xMax}, {vy, yMin, -yMin}];
count