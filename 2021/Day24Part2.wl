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

data = ImportInputData["input-24.txt"];

blocks = Partition[data, 18];

params = Table[
  {
    ToExpression[StringSplit[blocks[[i, 5]]][[3]]],
    ToExpression[StringSplit[blocks[[i, 6]]][[3]]],
    ToExpression[StringSplit[blocks[[i, 16]]][[3]]]
  },
  {i, 14}
];

stack = {};
constraints = {};

Do[
  {divZ, addX, addY} = params[[i]];
  If[divZ == 1,
    AppendTo[stack, {i, addY}],
    {j, addYj} = Last[stack];
    stack = Most[stack];
    AppendTo[constraints, {i, j, addYj + addX}]
  ],
  {i, 14}
];

(* Find smallest valid number *)
digits = Table[0, {14}];

Do[
  {i, j, diff} = c;
  (* digit[i] = digit[j] + diff *)
  (* Minimize: want smallest digits possible *)
  (* digit[j] can be 1-9, digit[i] = digit[j] + diff must also be 1-9 *)
  If[diff >= 0,
    (* digit[j] must be at least 1, so digit[i] = 1 + diff *)
    digits[[j]] = 1;
    digits[[i]] = 1 + diff,
    (* diff < 0, digit[i] must be at least 1, so digit[j] = 1 - diff *)
    digits[[j]] = 1 - diff;
    digits[[i]] = 1
  ],
  {c, constraints}
];

Print["Smallest valid number:"];
StringJoin[ToString /@ digits]