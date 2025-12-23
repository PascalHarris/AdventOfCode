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


step[pairCounts_] := Module[{newCounts = <||>, pair, cnt, ins},
  Do[
   pair = item[[1]];
   cnt = item[[2]];
   ins = Lookup[rules, pair, None];
   If[ins =!= None,
    newCounts[StringTake[pair, 1] <> ins] = 
     Lookup[newCounts, StringTake[pair, 1] <> ins, 0] + cnt;
    newCounts[ins <> StringTake[pair, -1]] = 
     Lookup[newCounts, ins <> StringTake[pair, -1], 0] + cnt, 
    newCounts[pair] = Lookup[newCounts, pair, 0] + cnt
    ],
   {item, Normal[pairCounts]}
   ];
  newCounts
  ]


data = ImportInputData["input-14.txt"];
template = Characters[data[[1]]];
rules = <|Rule @@ StringSplit[#, " -> "] & /@ Drop[data, 2]|>;

pairs = Counts[StringJoin /@ Partition[template, 2, 1]];

finalPairs = Nest[step, pairs, 40];

charCounts = <||>;
Do[
  pair = item[[1]];
  cnt = item[[2]];
  charCounts[StringTake[pair, 1]] = 
   Lookup[charCounts, StringTake[pair, 1], 0] + cnt; 
  charCounts[StringTake[pair, -1]] = 
   Lookup[charCounts, StringTake[pair, -1], 0] + cnt, {item, 
   Normal[finalPairs]}
  ];
(*Each char is double-counted except first and last*)
charCounts[template[[1]]] += 1;
charCounts[template[[-1]]] += 1;
charCounts = charCounts/2;

Max[charCounts] - Min[charCounts]