inpData = Import["day1input.txt",{"Text","Lines"}]
arraySize = Length[inpData]
counter = 0
For[i = 2, i <= arraySize, i++, If[ToExpression[inpData[[i]]] > ToExpression[inpData[[i-1]]], counter++, 0]]
Print [counter]