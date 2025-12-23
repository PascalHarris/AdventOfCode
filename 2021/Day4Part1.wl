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



wins[board_, called_] := Module[{marked},
  marked = Map[MemberQ[called, #] &, board, {2}];
  AnyTrue[marked, Apply[And]] || AnyTrue[Transpose[marked], Apply[And]]
  ]

play[] := Module[{called = {}},
  Do[
   AppendTo[called, draws[[i]]];
   Do[
    If[wins[boards[[j]], called],
     Return[
      draws[[i]]*
       Total[Select[Flatten[boards[[j]]], ! MemberQ[called, #] &]], 
      Module]
     ],
    {j, Length[boards]}
    ],
   {i, Length[draws]}
   ]
  ]

data = ImportInputData["input-4.txt"];
draws = ToExpression /@ StringSplit[First[data], ","];
boards = 
  Partition[ToExpression /@ StringSplit[StringJoin[Riffle[#, " "]]], 
     5] & /@ Partition[Select[Rest[data], # != "" &], 5];

play[]