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


data = ImportInputData["input-13.txt"];
split = Position[data, ""][[1, 1]];
dots = ToExpression["{" <> # <> "}"] & /@ Take[data, split - 1];
folds = StringCases[#, 
      RegularExpression["([xy])=(\\d+)"] :> {"$1", 
        ToExpression["$2"]}][[1]] & /@ Drop[data, split];

foldPaper[pts_, {"x", val_}] := 
 Union[{If[#[[1]] > val, 2 val - #[[1]], #[[1]]], #[[2]]} & /@ pts]
foldPaper[pts_, {"y", val_}] := 
 Union[{#[[1]], If[#[[2]] > val, 2 val - #[[2]], #[[2]]]} & /@ pts]

final = Fold[foldPaper, dots, folds];

{maxX, maxY} = {Max[final[[All, 1]]], Max[final[[All, 2]]]};
grid = Table[
   If[MemberQ[final, {x, y}], "#", "."], {y, 0, maxY}, {x, 0, maxX}];
StringJoin /@ grid // Column