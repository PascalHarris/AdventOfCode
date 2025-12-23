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
  {onOff, nums[[1]], nums[[2]], nums[[3]], nums[[4]], nums[[5]], nums[[6]]}
]

data = ImportInputData["input-22.txt"];

steps = parseStep /@ data;

(* Filter to initialization region -50..50 *)
initSteps = Select[steps, 
  #[[2]] >= -50 && #[[3]] <= 50 && 
  #[[4]] >= -50 && #[[5]] <= 50 && 
  #[[6]] >= -50 && #[[7]] <= 50 &];

(* Use a sparse set of on cubes *)
cubes = <||>;

Do[
  {onOff, x1, x2, y1, y2, z1, z2} = step;
  Do[
    If[onOff == 1,
      cubes[{x, y, z}] = True,
      cubes[{x, y, z}] = False
    ],
    {x, Max[x1, -50], Min[x2, 50]},
    {y, Max[y1, -50], Min[y2, 50]},
    {z, Max[z1, -50], Min[z2, 50]}
  ],
  {step, initSteps}
];

Count[Values[cubes], True]