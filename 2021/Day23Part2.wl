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

getMoves[state_] := Module[{hallway, rooms, moves = {}, room, amp, slot, hIdx, roomHPos, steps, newState, target, clearPath, destSlot},
  hallway = state[[1]];
  rooms = state[[2 ;; 5]];
  
  (* Moves from rooms to hallway *)
  Do[
    room = rooms[[r]];
    (* Find topmost amphipod *)
    slot = 0;
    Do[If[room[[s]] != ".", slot = s; Break[]], {s, roomDepth}];
    If[slot == 0, Continue[]];
    amp = room[[slot]];
    
    (* Skip if already in correct position *)
    If[targetRoom[amp] == r && AllTrue[Range[slot, roomDepth], rooms[[r, #]] == amp &], Continue[]];
    
    roomHPos = roomToHallway[r];
    Do[
      If[hallway[[hIdx]] != ".", Continue[]];
      clearPath = If[hIdx < roomHPos,
        AllTrue[Range[hIdx + 1, roomHPos], hallway[[#]] == "." &],
        AllTrue[Range[roomHPos, hIdx - 1], hallway[[#]] == "." &]
      ];
      If[clearPath,
        steps = Abs[hIdx - roomHPos] + slot;
        newState = ReplacePart[state, {{1, hIdx} -> amp, {r + 1, slot} -> "."}];
        AppendTo[moves, {newState, steps * cost[amp]}]
      ],
      {hIdx, validHallwayStops}
    ],
    {r, 4}
  ];
  
  (* Moves from hallway to rooms *)
  Do[
    If[hallway[[hIdx]] == ".", Continue[]];
    amp = hallway[[hIdx]];
    target = targetRoom[amp];
    room = rooms[[target]];
    roomHPos = roomToHallway[target];
    
    (* Check if room is ready (empty or has only correct amphipods at bottom) *)
    If[!AllTrue[room, # == "." || # == amp &], Continue[]];
    
    clearPath = If[hIdx < roomHPos,
      AllTrue[Range[hIdx + 1, roomHPos], hallway[[#]] == "." &],
      AllTrue[Range[roomHPos, hIdx - 1], hallway[[#]] == "." &]
    ];
    If[!clearPath, Continue[]];
    
    (* Find deepest empty slot *)
    destSlot = 0;
    Do[If[room[[s]] == ".", destSlot = s], {s, roomDepth}];
    If[destSlot == 0, Continue[]];
    
    steps = Abs[hIdx - roomHPos] + destSlot;
    newState = ReplacePart[state, {{1, hIdx} -> ".", {target + 1, destSlot} -> amp}];
    AppendTo[moves, {newState, steps * cost[amp]}],
    {hIdx, 11}
  ];
  
  moves
];

heuristic[state_] := Module[{h = 0, hallway, rooms, amp, target, r, slot},
  hallway = state[[1]];
  rooms = state[[2 ;; 5]];
  
  Do[
    If[hallway[[hIdx]] != ".",
      amp = hallway[[hIdx]];
      target = targetRoom[amp];
      h += cost[amp] * (Abs[hIdx - roomToHallway[target]] + 1)
    ],
    {hIdx, 11}
  ];
  
  Do[
    Do[
      amp = rooms[[r, slot]];
      If[amp != "." && (targetRoom[amp] != r || !AllTrue[Range[slot, roomDepth], rooms[[r, #]] == amp &]),
        target = targetRoom[amp];
        h += cost[amp] * (slot + 2 + Abs[roomToHallway[r] - roomToHallway[target]])
      ],
      {slot, roomDepth}
    ],
    {r, 4}
  ];
  h
];

data = ImportInputData["input-23.txt"];

(* Parse initial state with the two extra rows inserted *)
initRooms = {
  {StringTake[data[[3]], {4, 4}], "D", "D", StringTake[data[[4]], {4, 4}]},
  {StringTake[data[[3]], {6, 6}], "C", "B", StringTake[data[[4]], {6, 6}]},
  {StringTake[data[[3]], {8, 8}], "B", "A", StringTake[data[[4]], {8, 8}]},
  {StringTake[data[[3]], {10, 10}], "A", "C", StringTake[data[[4]], {10, 10}]}
};
initHallway = Table[".", {11}];
initState = {initHallway, initRooms[[1]], initRooms[[2]], initRooms[[3]], initRooms[[4]]};
goalState = {Table[".", {11}], {"A", "A", "A", "A"}, {"B", "B", "B", "B"}, {"C", "C", "C", "C"}, {"D", "D", "D", "D"}};

cost = <|"A" -> 1, "B" -> 10, "C" -> 100, "D" -> 1000|>;
targetRoom = <|"A" -> 1, "B" -> 2, "C" -> 3, "D" -> 4|>;
roomToHallway = <|1 -> 3, 2 -> 5, 3 -> 7, 4 -> 9|>;
validHallwayStops = {1, 2, 4, 6, 8, 10, 11};
roomDepth = 4;

toKey[state_] := StringJoin[Flatten[state]]
goalKey = toKey[goalState];

dist = <||>;
visited = <||>;
dist[toKey[initState]] = 0;
pq = {{heuristic[initState], 0, initState}};
result = -1;

While[pq != {},
  pq = Sort[pq];
  {f, d, current} = First[pq];
  pq = Rest[pq];
  
  currentKey = toKey[current];
  If[KeyExistsQ[visited, currentKey], Continue[]];
  visited[currentKey] = True;
  
  If[currentKey === goalKey, 
    result = d;
    Break[]
  ];
  
  moves = getMoves[current];
  Do[
    {nextState, moveCost} = move;
    nextKey = toKey[nextState];
    If[!KeyExistsQ[visited, nextKey],
      newDist = d + moveCost;
      If[newDist < Lookup[dist, nextKey, Infinity],
        dist[nextKey] = newDist;
        AppendTo[pq, {newDist + heuristic[nextState], newDist, nextState}]
      ]
    ],
    {move, moves}
  ]
];

result