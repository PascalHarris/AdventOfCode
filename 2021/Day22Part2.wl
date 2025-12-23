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

parseStep[line_] := Module[{onOff, nums},
  onOff = If[StringStartsQ[line, "on"], 1, 0];
  nums = ToExpression /@ StringCases[line, RegularExpression["-?\\d+"]];
  {onOff, {nums[[1]], nums[[2]]}, {nums[[3]], nums[[4]]}, {nums[[5]], nums[[6]]}}
]

(* Intersection of two cuboids, returns None if no overlap *)
intersect[{x1a_, x1b_}, {y1a_, y1b_}, {z1a_, z1b_}, {x2a_, x2b_}, {y2a_, y2b_}, {z2a_, z2b_}] := 
  Module[{xa, xb, ya, yb, za, zb},
    xa = Max[x1a, x2a]; xb = Min[x1b, x2b];
    ya = Max[y1a, y2a]; yb = Min[y1b, y2b];
    za = Max[z1a, z2a]; zb = Min[z1b, z2b];
    If[xa <= xb && ya <= yb && za <= zb,
      {{xa, xb}, {ya, yb}, {za, zb}},
      None
    ]
  ]

data = ImportInputData["input-22.txt"];

steps = parseStep /@ data;

volume[{xa_, xb_}, {ya_, yb_}, {za_, zb_}] := (xb - xa + 1) (yb - ya + 1) (zb - za + 1)

(* Track cuboids with signs for inclusion-exclusion *)
cuboids = {}; (* Each entry: {sign, xRange, yRange, zRange} *)

Do[
  {onOff, xr, yr, zr} = step;
  newCuboids = {};
  
  (* For each existing cuboid, add its intersection with opposite sign *)
  Do[
    {sign, exr, eyr, ezr} = cub;
    inter = intersect[exr, eyr, ezr, xr, yr, zr];
    If[inter =!= None,
      AppendTo[newCuboids, {-sign, inter[[1]], inter[[2]], inter[[3]]}]
    ],
    {cub, cuboids}
  ];
  
  (* If turning on, add the new cuboid *)
  If[onOff == 1,
    AppendTo[newCuboids, {1, xr, yr, zr}]
  ];
  
  cuboids = Join[cuboids, newCuboids],
  {step, steps}
];

Total[#[[1]] * volume[#[[2]], #[[3]], #[[4]]] & /@ cuboids]