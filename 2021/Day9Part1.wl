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




data = ImportInputData["input-9.txt"];
grid = ToExpression[Characters[#]] & /@ data;
{h, w} = Dimensions[grid];

neighbors[{r_, c_}] := 
 Select[{{r - 1, c}, {r + 1, c}, {r, c - 1}, {r, c + 1}}, 
  1 <= #[[1]] <= h && 1 <= #[[2]] <= w &]

isLowPoint[{r_, c_}] := 
 AllTrue[neighbors[{r, c}], grid[[r, c]] < grid[[#[[1]], #[[2]]]] &]

lowPoints = Select[Tuples[{Range[h], Range[w]}], isLowPoint];
Total[grid[[#[[1]], #[[2]]]] + 1 & /@ lowPoints]