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

enhance[img_, alg_, default_] := Module[{h, w, padded, newImg, idx, r, c},
  h = Length[img];
  w = Length[img[[1]]];
  (* Pad image with 2 layers of default *)
  padded = ArrayPad[img, 2, default];
  {h, w} = Dimensions[padded];
  newImg = Table[
    idx = FromDigits[
      Flatten[Table[toVal[padded[[r + dr, c + dc]]], {dr, -1, 1}, {dc, -1, 1}]], 
      2
    ];
    alg[[idx + 1]],
    {r, 2, h - 1}, {c, 2, w - 1}
  ];
  newImg
]

(* Handle infinite background flipping *)
(* If alg[[1]] is "#", then all dark pixels become light, and vice versa *)
step[{img_, default_}, alg_] := Module[{newDefault},
  newDefault = If[default == ".", alg[[1]], alg[[512]]];
  {enhance[img, alg, default], newDefault}
]

data = ImportInputData["input-20.txt"];

algorithm = Characters[data[[1]]];
split = Position[data, ""][[1, 1]];
imageLines = Drop[data, split];
image = Characters /@ imageLines;

toVal["."] := 0;
toVal["#"] := 1;

{result, _} = Nest[step[#, algorithm] &, {image, "."}, 2];
Count[Flatten[result], "#"]