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


countPaths[current_, visited_, usedDouble_] := 
 Module[{newVisited, count = 0},
  If[current == "end", Return[1]];
  newVisited = If[isSmall[current], Append[visited, current], visited];
  Do[
   If[next == "start", Continue[]];
   If[! MemberQ[newVisited, next],
    count += countPaths[next, newVisited, usedDouble],
    (*next is in newVisited,so it's a small cave*)
    If[! usedDouble,
     count += countPaths[next, newVisited, True]
     ]
    ],
   {next, adj[current]}
   ];
  count
  ]


data = ImportInputData["input-12.txt"];
edges = StringSplit[#, "-"] & /@ data;

adj = <||>;
Do[
  {a, b} = edge;
  adj[a] = Append[Lookup[adj, a, {}], b];
  adj[b] = Append[Lookup[adj, b, {}], a],
  {edge, edges}
  ];

isSmall[cave_] := LowerCaseQ[cave]

countPaths["start", {}, False]
