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


explode[s_] := Module[{depth = 0, i, leftNum, rightNum, pair, before, after},
  For[i = 1, i <= StringLength[s], i++,
    Switch[StringTake[s, {i, i}],
      "[", depth++,
      "]", depth--
    ];
    If[depth > 4 && StringMatchQ[StringTake[s, {i, Min[i + 10, StringLength[s]]}], RegularExpression["\\[\\d+,\\d+\\].*"]],
      {leftNum, rightNum} = ToExpression /@ StringCases[StringTake[s, {i, Min[i + 10, StringLength[s]]}], RegularExpression["^\\[(\\d+),(\\d+)\\]"] :> {"$1", "$2"}][[1]];
      pair = StringCases[StringTake[s, {i, Min[i + 10, StringLength[s]]}], RegularExpression["^\\[\\d+,\\d+\\]"]][[1]];
      before = StringTake[s, i - 1];
      after = StringDrop[s, i - 1 + StringLength[pair]];
      before = StringReplace[before, RegularExpression["(\\d+)([^0-9]*)$"] :> ToString[ToExpression["$1"] + leftNum] <> "$2", 1];
      after = StringReplace[after, RegularExpression["^([^0-9]*)(\\d+)"] :> "$1" <> ToString[ToExpression["$2"] + rightNum], 1];
      Return[before <> "0" <> after]
    ]
  ];
  s
]

reduce[s_] := Module[{current = s, next},
  While[True,
    next = explode[current];
    If[next =!= current, current = next; Continue[]];
    next = split[current];
    If[next =!= current, current = next; Continue[]];
    Break[]
  ];
  current
]

magnitude[s_] := Module[{expr},
  expr = ToExpression[StringReplace[s, {"[" -> "{", "]" -> "}"}]];
  mag[n_Integer] := n;
  mag[{a_, b_}] := 3 mag[a] + 2 mag[b];
  mag[expr]
]

data = ImportInputData["input-18.txt"];
split[s_] := StringReplace[s, RegularExpression["\\d{2,}"] :> 
  With[{n = ToExpression["$0"]}, "[" <> ToString[Floor[n/2]] <> "," <> ToString[Ceiling[n/2]] <> "]"], 1]
add[a_, b_] := reduce["[" <> a <> "," <> b <> "]"]
Max[Table[
  If[i != j, magnitude[add[data[[i]], data[[j]]]], 0],
  {i, Length[data]}, {j, Length[data]}
]]