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


parsePacket[pos_] := 
 Module[{p = pos, version, typeId, lenTypeId, subLen, subCount, 
   versionSum, chunk, endPos, subVer},
  version = toInt[bits[[p ;; p + 2]]]; p += 3;
  typeId = toInt[bits[[p ;; p + 2]]]; p += 3;
  versionSum = version;
  
  If[typeId == 4,
   (*Literal value*)
   While[True,
    chunk = bits[[p ;; p + 4]];
    p += 5;
    If[chunk[[1]] == 0, Break[]]
    ];
   {p, versionSum},
   
   (*Operator*)
   lenTypeId = bits[[p]]; p += 1;
   
   If[lenTypeId == 0,
    subLen = toInt[bits[[p ;; p + 14]]]; p += 15;
    endPos = p + subLen;
    While[p < endPos,
     {p, subVer} = parsePacket[p];
     versionSum += subVer
     ],
    subCount = toInt[bits[[p ;; p + 10]]]; p += 11;
    Do[
     {p, subVer} = parsePacket[p];
     versionSum += subVer,
     {subCount}
     ]
    ];
   {p, versionSum}
   ]
  ]


data = ImportInputData["input-16.txt"];
hex = First[data];

hexToBin = <|"0" -> {0, 0, 0, 0}, "1" -> {0, 0, 0, 1}, 
   "2" -> {0, 0, 1, 0}, "3" -> {0, 0, 1, 1}, "4" -> {0, 1, 0, 0}, 
   "5" -> {0, 1, 0, 1}, "6" -> {0, 1, 1, 0}, "7" -> {0, 1, 1, 1}, 
   "8" -> {1, 0, 0, 0}, "9" -> {1, 0, 0, 1}, "A" -> {1, 0, 1, 0}, 
   "B" -> {1, 0, 1, 1}, "C" -> {1, 1, 0, 0}, "D" -> {1, 1, 0, 1}, 
   "E" -> {1, 1, 1, 0}, "F" -> {1, 1, 1, 1}|>;

bits = Flatten[hexToBin /@ Characters[hex]];

toInt[list_] := FromDigits[list, 2]

parsePacket[1][[2]]
