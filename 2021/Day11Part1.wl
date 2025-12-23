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


step[g_] := Module[{grid = g + 1, flashed = {}, toFlash},
  While[
   toFlash = Select[Tuples[{Range[h], Range[w]}],
     grid[[#[[1]], #[[2]]]] > 9 && ! MemberQ[flashed, #] &];
   toFlash != {},
   
   Do[
    AppendTo[flashed, pos];
    Do[grid[[n[[1]], n[[2]]]]++, {n, neighbors[pos]}],
    {pos, toFlash}
    ]
   ];
  
  Do[grid[[p[[1]], p[[2]]]] = 0, {p, flashed}];
  {grid, Length[flashed]}
  ]


data = ImportInputData["input-11.txt"];
initGrid = ToExpression[Characters[#]] & /@ data;
{h, w} = Dimensions[initGrid];

neighbors[{r_, c_}] := Select[
  Tuples[{r + Range[-1, 1], c + Range[-1, 1]}],
  # != {r, c} && 1 <= #[[1]] <= h && 1 <= #[[2]] <= w &
  ]

result = {initGrid, 0};
total = 0;
Do[result = step[result[[1]]];
  total += result[[2]], {100}];
total
