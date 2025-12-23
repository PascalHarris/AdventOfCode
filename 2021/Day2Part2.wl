inpData = Import["day2input.txt",{"Text","Lines"}]
arraySize = Length[inpData]
depth = 0
hpos = 0
aim = 0
For[i = 1, i <= arraySize, i++, lArray = StringSplit[inpData[[i]]]; 
  If[lArray[[1]] === "forward", hpos = hpos + ToExpression[lArray[[2]]];
                                depth = depth + (ToExpression[lArray[[2]]] * aim), 
    If[lArray[[1]] === "down", aim = aim + ToExpression[lArray[[2]]], 
      If[lArray[[1]] === "up", aim = aim - ToExpression[lArray[[2]]], 0]
    ]
  ]
]

Print [depth * hpos]