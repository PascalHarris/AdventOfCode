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


parseInput[lines_] := Module[{scanners = {}, current = {}},
  Do[
    Which[
      StringMatchQ[line, "--- scanner *"],
        If[current != {}, AppendTo[scanners, current]];
        current = {},
      line == "", Null,
      True, AppendTo[current, ToExpression["{" <> line <> "}"]]
    ],
    {line, lines}
  ];
  AppendTo[scanners, current];
  scanners
]

findOverlap[fixed_, moving_] := Module[{fixedSet, rotated, diffs, tally, offset, cnt},
  fixedSet = Association[# -> True & /@ fixed];
  Do[
    rotated = (rot . #) & /@ moving;
    (* Compute all pairwise offsets and find most common *)
    diffs = Flatten[Outer[#1 - #2 &, fixed, rotated, 1], 1];
    tally = Tally[diffs];
    Do[
      {offset, cnt} = item;
      If[cnt >= 12,
        (* Verify *)
        If[Count[(KeyExistsQ[fixedSet, # + offset]) & /@ rotated, True] >= 12,
          Return[{rot, offset}, Module]
        ]
      ],
      {item, tally}
    ],
    {rot, rotations}
  ];
  None
]

data = ImportInputData["input-19.txt"];

scanners = parseInput[data];

rotations = {
  {{1,0,0},{0,1,0},{0,0,1}}, {{1,0,0},{0,0,-1},{0,1,0}}, {{1,0,0},{0,-1,0},{0,0,-1}}, {{1,0,0},{0,0,1},{0,-1,0}},
  {{0,-1,0},{1,0,0},{0,0,1}}, {{0,0,1},{1,0,0},{0,1,0}}, {{0,1,0},{1,0,0},{0,0,-1}}, {{0,0,-1},{1,0,0},{0,-1,0}},
  {{-1,0,0},{0,-1,0},{0,0,1}}, {{-1,0,0},{0,0,-1},{0,-1,0}}, {{-1,0,0},{0,1,0},{0,0,-1}}, {{-1,0,0},{0,0,1},{0,1,0}},
  {{0,1,0},{-1,0,0},{0,0,1}}, {{0,0,1},{-1,0,0},{0,-1,0}}, {{0,-1,0},{-1,0,0},{0,0,-1}}, {{0,0,-1},{-1,0,0},{0,1,0}},
  {{0,0,-1},{0,1,0},{1,0,0}}, {{0,1,0},{0,0,1},{1,0,0}}, {{0,0,1},{0,-1,0},{1,0,0}}, {{0,-1,0},{0,0,-1},{1,0,0}},
  {{0,0,-1},{0,-1,0},{-1,0,0}}, {{0,-1,0},{0,0,1},{-1,0,0}}, {{0,0,1},{0,1,0},{-1,0,0}}, {{0,1,0},{0,0,-1},{-1,0,0}}
};

known = <|1 -> {IdentityMatrix[3], {0, 0, 0}}|>;
queue = {1};
While[queue != {} && Length[known] < Length[scanners],
  current = First[queue];
  queue = Rest[queue];
  {currentRot, currentOffset} = known[current];
  currentBeacons = (currentRot . # + currentOffset) & /@ scanners[[current]];
  
  Do[
    If[!KeyExistsQ[known, i],
      result = findOverlap[currentBeacons, scanners[[i]]];
      If[result =!= None,
        {rot, offset} = result;
        known[i] = {rot, offset};
        AppendTo[queue, i]
      ]
    ],
    {i, Length[scanners]}
  ]
]

allBeacons = {};
Do[
  {rot, offset} = known[i];
  transformed = (rot . # + offset) & /@ scanners[[i]];
  allBeacons = Union[allBeacons, transformed],
  {i, Length[scanners]}
];

Length[allBeacons]

scannerPositions = Table[known[i][[2]], {i, Length[scanners]}];

Max[Table[
  Total[Abs[scannerPositions[[i]] - scannerPositions[[j]]]],
  {i, Length[scannerPositions]},
  {j, Length[scannerPositions]}
]]