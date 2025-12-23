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


dijkstra[] := Module[{dist, visited, queue, current, d, newDist},
  dist = <|{1, 1} -> 0|>;
  visited = <||>;
  queue = {{0, {1, 1}}};
  
  While[queue != {},
   {d, current} = First[queue];
   queue = Rest[queue];
   
   If[Lookup[visited, current, False], Continue[]];
   visited[current] = True;
   
   If[current == {h, w}, Return[d]];
   
   Do[
    If[! Lookup[visited, nb, False],
     newDist = d + grid[[nb[[1]], nb[[2]]]];
     If[newDist < Lookup[dist, nb, Infinity],
      dist[nb] = newDist;
      queue = Sort[Append[queue, {newDist, nb}]]
      ]
     ],
    {nb, neighbors[current]}
    ]
   ];
  dist[{h, w}]
  ]


data = ImportInputData["input-15.txt"];
smallGrid = ToExpression[Characters[#]] & /@ data;
{sh, sw} = Dimensions[smallGrid];

(*Build the 5x5 tiled grid*)
wrap[n_] := If[n > 9, n - 9, n]
bigGrid = Table[
   wrap[smallGrid[[Mod[r - 1, sh] + 1, Mod[c - 1, sw] + 1]] + 
     Quotient[r - 1, sh] + Quotient[c - 1, sw]],
   {r, 5 sh}, {c, 5 sw}
   ];
{h, w} = Dimensions[bigGrid];

neighbors[{r_, c_}] := 
 Select[{{r - 1, c}, {r + 1, c}, {r, c - 1}, {r, c + 1}}, 
  1 <= #[[1]] <= h && 1 <= #[[2]] <= w &]

dist = ConstantArray[Infinity, {h, w}];
dist[[1, 1]] = 0;
visited = ConstantArray[False, {h, w}];
queue = {{0, {1, 1}}};

While[queue != {},
  {d, current} = First[queue];
  queue = Rest[queue];
  {cr, cc} = current;
  
  If[visited[[cr, cc]], Continue[]];
  visited[[cr, cc]] = True;
  
  If[current == {h, w}, Break[]];
  
  Do[
   {nr, nc} = nb;
   If[! visited[[nr, nc]],
    newDist = d + bigGrid[[nr, nc]];
    If[newDist < dist[[nr, nc]],
     dist[[nr, nc]] = newDist;
     queue = Sort[Append[queue, {newDist, nb}]]
     ]
    ],
   {nb, neighbors[current]}
   ]
  ];

dist[[h, w]]