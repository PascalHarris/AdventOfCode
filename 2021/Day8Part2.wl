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


decode[{patterns_, output_}] := 
 Module[{p, one, four, seven, eight, len5, len6, digits}, 
  p = Sort /@ Characters /@ patterns;
  one = First[Select[p, Length[#] == 2 &]];
  four = First[Select[p, Length[#] == 4 &]];
  seven = First[Select[p, Length[#] == 3 &]];
  eight = First[Select[p, Length[#] == 7 &]];
  len5 = Select[p, Length[#] == 5 &];
  len6 = Select[p, Length[#] == 6 &];
  three = First[Select[len5, Length[Intersection[#, one]] == 2 &]];
  five = 
   First[Select[len5, 
     Length[Intersection[#, four]] == 3 && # != three &]];
  two = First[Select[len5, # != three && # != five &]];
  nine = First[Select[len6, Length[Intersection[#, four]] == 4 &]];
  zero = 
   First[Select[len6, # != nine && Length[Intersection[#, one]] == 2 &]];
  six = First[Select[len6, # != nine && # != zero &]];
  digits = {zero -> 0, one -> 1, two -> 2, three -> 3, four -> 4, 
    five -> 5, six -> 6, seven -> 7, eight -> 8, nine -> 9};
  FromDigits[(Sort /@ Characters /@ output) /. digits]
  ]



data = ImportInputData["input-8.txt"];
entries = {StringSplit[#[[1]]], 
     StringSplit[#[[2]]]} & /@ (StringSplit[#, " | "] & /@ data);

Total[decode /@ entries]