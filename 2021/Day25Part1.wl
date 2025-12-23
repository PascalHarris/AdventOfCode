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

step[g_] := Module[{g1, g2, moved = False, newR, newC},
  (* East-facing cucumbers move first *)
  g1 = g;
  Do[
    If[g[[r, c]] == ">",
      newC = Mod[c, w] + 1;
      If[g[[r, newC]] == ".",
        g1[[r, c]] = ".";
        g1[[r, newC]] = ">";
        moved = True
      ]
    ],
    {r, h}, {c, w}
  ];
  
  (* South-facing cucumbers move second *)
  g2 = g1;
  Do[
    If[g1[[r, c]] == "v",
      newR = Mod[r, h] + 1;
      If[g1[[newR, c]] == ".",
        g2[[r, c]] = ".";
        g2[[newR, c]] = "v";
        moved = True
      ]
    ],
    {r, h}, {c, w}
  ];
  
  {g2, moved}
]

data = ImportInputData["input-25.txt"];
grid = Characters /@ data;
{h, w} = Dimensions[grid];

count = 0;
current = grid;
moved = True;

While[moved,
  count++;
  {current, moved} = step[current]
];

count