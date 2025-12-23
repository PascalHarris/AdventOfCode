inpData = Import["day1input.txt",{"Text","Lines"}]
arraySize = Length[inpData]
counter = 0
previoussum = 0
For[i = 3, i <= arraySize, i++, 
  currentsum = ToExpression[inpData[[i]]] + ToExpression[inpData[[i-1]]] + ToExpression[inpData[[i-2]]];
  If[currentsum > previoussum, 
    counter++, 
    0
  ];
  previoussum = currentsum
]
Print [counter-1]