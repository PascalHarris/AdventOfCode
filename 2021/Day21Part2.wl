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

countWins[pos1_, pos2_, score1_, score2_, turn_] := Module[
  {key, wins1 = 0, wins2 = 0, newPos, newScore, subWins, roll, count},
  key = {pos1, pos2, score1, score2, turn};
  If[KeyExistsQ[memo, key], Return[memo[key]]];
  
  Do[
    roll = rc[[1]];
    count = rc[[2]];
    If[turn == 1,
      newPos = Mod[pos1 + roll - 1, 10] + 1;
      newScore = score1 + newPos;
      If[newScore >= 21,
        wins1 += count,
        subWins = countWins[newPos, pos2, newScore, score2, 2];
        wins1 += count * subWins[[1]];
        wins2 += count * subWins[[2]]
      ],
      newPos = Mod[pos2 + roll - 1, 10] + 1;
      newScore = score2 + newPos;
      If[newScore >= 21,
        wins2 += count,
        subWins = countWins[pos1, newPos, score1, newScore, 1];
        wins1 += count * subWins[[1]];
        wins2 += count * subWins[[2]]
      ]
    ],
    {rc, rollCounts}
  ];
  memo[key] = {wins1, wins2};
  {wins1, wins2}
];

data = ImportInputData["input-21.txt"];
p1Start = ToExpression[StringCases[data[[1]], RegularExpression["\\d+$"]][[1]]];
p2Start = ToExpression[StringCases[data[[2]], RegularExpression["\\d+$"]][[1]]];

rollCounts = {{3, 1}, {4, 3}, {5, 6}, {6, 7}, {7, 6}, {8, 3}, {9, 1}};

memo = <||>;

result = countWins[p1Start, p2Start, 0, 0, 1];
Max[result]