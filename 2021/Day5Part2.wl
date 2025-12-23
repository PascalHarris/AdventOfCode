ImportInputData[defaultFile_String : ""] := Module[{file, data},
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
  
  (*Attempt import*)
  data = Quiet[Import[file, {"Text", "Lines"}]];
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


points[{x1_, y1_, x2_, y2_}] := Module[{dx, dy, n},
  dx = Sign[x2 - x1]; dy = Sign[y2 - y1];
  n = Max[Abs[x2 - x1], Abs[y2 - y1]];
  Table[{x1 + i*dx, y1 + i*dy}, {i, 0, n}]
  ]

data = ImportInputData["input-5.txt"];
lines = ToExpression /@ StringSplit[#, {",", " -> "}] & /@ data;

allPoints = Flatten[points /@ lines, 1];
Count[Tally[allPoints], {_, n_} /; n >= 2]