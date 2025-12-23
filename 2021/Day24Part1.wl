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

(* The program consists of 14 nearly identical blocks, one per input digit *)
(* Each block has 18 instructions starting with 'inp w' *)
(* The key varying parameters in each block are at lines 5, 6, and 16 *)
(* Line 5: div z {1 or 26} *)
(* Line 6: add x {some number} *)
(* Line 16: add y {some number} *)

blocks = Partition[data, 18];

params = Table[
  {
    ToExpression[StringSplit[blocks[[i, 5]]][[3]]],  (* div z param: 1 or 26 *)
    ToExpression[StringSplit[blocks[[i, 6]]][[3]]],  (* add x param *)
    ToExpression[StringSplit[blocks[[i, 16]]][[3]]]  (* add y param *)
  },
  {i, 14}
];

Print["Parameters (divZ, addX, addY):"];
Print[params];

(* 
The algorithm in each block essentially does:
  x = z mod 26
  z = z / divZ  (integer division)
  x = x + addX
  if x != w then z = 26*z + w + addY

When divZ=1, z grows (push operation)
When divZ=26, z can shrink (pop operation) if x == w

For z to end at 0, pushes and pops must balance.
When divZ=26, we need: (previous_z mod 26) + addX == current_input
This constrains pairs of digits.
*)

(* Find the constraints *)
stack = {};
constraints = {};

Do[
  {divZ, addX, addY} = params[[i]];
  If[divZ == 1,
    (* Push: this digit will be constrained later *)
    AppendTo[stack, {i, addY}],
    (* Pop: constrain with the matching push *)
    {j, addYj} = Last[stack];
    stack = Most[stack];
    (* Constraint: digit[i] = digit[j] + addYj + addX *)
    AppendTo[constraints, {i, j, addYj + addX}]
  ],
  {i, 14}
];

Print["Constraints (i, j, diff) meaning digit[i] = digit[j] + diff:"];
Print[constraints];

(* Find largest valid number *)
digits = Table[0, {14}];

Do[
  {i, j, diff} = c;
  (* digit[i] = digit[j] + diff *)
  (* Maximize: want largest digits possible *)
  (* digit[j] can be 1-9, digit[i] = digit[j] + diff must also be 1-9 *)
  If[diff >= 0,
    (* digit[j] can be at most 9-diff to keep digit[i] <= 9 *)
    digits[[j]] = 9 - diff;
    digits[[i]] = 9,
    (* diff < 0, digit[i] can be at most 9, so digit[j] = 9 - diff could exceed 9 *)
    (* digit[j] can be at most 9, digit[i] = digit[j] + diff *)
    digits[[j]] = 9;
    digits[[i]] = 9 + diff
  ],
  {c, constraints}
];

Print["Largest valid number:"];
StringJoin[ToString /@ digits]