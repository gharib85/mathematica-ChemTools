(* ::Package:: *)



ChemUtilsSymmetryElements::usage=
	"Finds all the symmetry elements of a collection of atoms";


ChemUtilsSymmetryGraphics::usage=
	"Plots a collection of symmetry elements";
ChemUtilsInertialSymmetry::usage=
	"Finds symmetry elements relative to the ABC axes";
ChemUtilsPointGroup::usage=
	"Guesses the point group of the collection of atoms";


Begin["`Private`"];


(* ::Subsubsection::Closed:: *)
(*symmetricPointQ*)



(* ::Text:: *)
(*Might be worth having a symmetry tester for each group*)



symmetricPointQ=
	Compile[
		{
			{p, _Real, 1},
			{opos, _Real, 1},
			{positions, _Real, 2},
			{tol, _Real}
			},
		Block[
			{
				flag=False,
				idx=1,
				len=Length@positions
				},
			While[
				idx<=len&&
					Not[
						flag=
							p[[1]]-tol<=positions[[idx, 1]]<=p[[1]]+tol&&
							p[[2]]-tol<=positions[[idx, 2]]<=p[[2]]+tol&&
							p[[3]]-tol<=positions[[idx, 3]]<=p[[3]]+tol
						],
				idx++
				];
			flag
			]
		];


(* ::Subsubsection::Closed:: *)
(*symmetryOperationQ*)



symmetryOperationQ[transform_, pts_List, tol_]:=
	AllTrue[pts,
		With[
			{
				tp=transform@#
				},
			ListQ@tp&&(symmetricPointQ[tp, #, pts, tol])
			]&
		];
symmetryOperationQ[transform_,grps_Association,tol_]:=
	AllTrue[grps,
		symmetryOperationQ[transform, #, tol]&
		]


(* ::Subsubsection::Closed:: *)
(*InversionCenterQ*)



inversionTransform[point_]:=
	AffineTransform@{ScalingMatrix[{-1,-1,-1}],2*point}


ChemUtilsInversionCenterQ[ 
	groups_, tol:(_?NumericQ|Automatic):Automatic]:=
		symmetryOperationQ[
			Minus,
			groups,
			Replace[tol, Automatic:>$ChemSymmetryTolerance]
			];


(* ::Subsubsection::Closed:: *)
(*uniqueAxesQ*)



uniqueAxesQComp=
	Compile[{{center, _Real, 1}, {p, _Real, 1}, {q, _Real, 1}, {tol, _Real}},
		With[{n1=#/Norm[#]&@p-center,n2=#/Norm[#]&@q-center},
			Norm[n1-n2]>tol&&
				Norm[n1+n2]>tol
			]
		];
uniqueAxesQ[center_, p_,q_]:=
	uniqueAxesQComp[center,p,q, $ChemSymmetryUniquenessThreshold];
uniqueAxesQ[center_][p_,q_]:=
	uniqueAxesQComp[center,p,q];


(* ::Subsubsection::Closed:: *)
(*RotationAxisOrderComp*)



(*ChemUtilsRotationAxisOrderComp:=
	With[
		{
			symmetricPointQ=symmetricPointQ,
			uniqueAxesQ=uniqueAxesQComp,
			rawRotationTransformationFunction=
				rawRotationTransformationFunction
			},
		Compile[
			{
				{point1, _Real, 1},
				{point2, _Real, 1},
				{positions, _Real, 2},
				{grps, _Integer, 1},
				{linFlag, _Integer},
				{tol, _Real}
				},
			If[linFlag===1,
				If[
					uniqueAxesQ[point1, positions[[1]], point2]||
						uniqueAxesQ[point1, positions[[-1]], point2],
					1,
					-1
					],
				Block[{
					groupOrdering = Ordering[grps],
					returnOrder=1
					},
						Do[
							Block[
								{
									flag=True,
									i=1,j=1,
									newpts,
									oldpts
									},
								While[i\[LessEqual]Length[grps]&&flag,
									With[{grp=Take[positions, {Total@grps[[;;i-1]], grps[[i]]}]},
										j=1;
										While[j\[LessEqual]grps[[i]]&&flag,
											flag=symmetricPointQ[
												rawRotationTransformationFunction[
													grp[[j]],
													2.\[Pi]/o,
													point2,
													point1
													],
												grp[[j]],
												grp,
												tol
												];
											j++
											]
										];
									i++
									];
								If[flag,
									returnOrder=o;
									Break[]
									]
								],
							{o, grps}
							];
					returnOrder
					]
				]
			]
		];*)


(* ::Subsubsection::Closed:: *)
(*RotationAxisOrder*)



rotationTransform[order_,  point_]:=
	RotationTransform[2.\[Pi]/order, point];
rotationTransform[point_][order_]:=
	rotationTransform[order,point];


ChemUtilsRotationAxisOrder//Clear


ChemUtilsRotationAxisOrder[
	point_,
	groups_,
	linearQ:True|False:False,
	tol:_?NumericQ|Automatic:Automatic
	]:=
	If[linearQ,
		If[
			uniqueAxesQComp[groups[[1,1]], point]||
				uniqueAxesQComp[groups[[1,-1]], point],
			1,
			\[Infinity]
			],
		With[{es=SortBy[groups, Length]},
			With[{
				ret=
					Do[
						If[
							symmetryOperationQ[
								rotationTransform[o, point],
								groups,
								Replace[tol, Automatic:>$ChemSymmetryTolerance]
								],
							Return[o]
							],
						{o, Length@es[[-1]], 2, -1}
						]
					},
				If[ret>1//TrueQ,
					ret,
					1
					]
				]
			]
		];


(* ::Subsubsection::Closed:: *)
(*perpendicularAxisQ*)



perpendicularAxisQ[center_,p_,{q1_,q2_}]:=
	Not@uniqueAxesQ[center,p,Cross[q1-center,q2-center]];
perpendicularAxisQ[center_,p_][q_]:=
	perpendicularAxisQ[center,p,q];


(* ::Subsubsection::Closed:: *)
(*anyPerpendicular*)



anyPerpPlane[center_,axes_,planes_]:=
	AnyTrue[planes,
		With[{plane=#},
			AnyTrue[axes,perpendicularAxisQ[center,#,plane]&]
			]&
		];
anyPerpPlane[center_,axes_][planes_]:=
	anyPerpPlane[center,axes,planes];


(* ::Subsubsection::Closed:: *)
(*ScrewAxisOrderComp*)



(*ChemUtilsScrewAxisOrderComp:=
	With[
		{
			symmetricPointQ=symmetricPointQ,
			uniqueAxesQ=uniqueAxesQComp,
			rawRotationReflectionTransformationFunction=
				rawRotationReflectionTransformationFunction
			},
		Compile[
			{
				{point1, _Real, 1},
				{point2, _Real, 1},
				{positions, _Real, 2},
				{grps, _Integer, 1},
				{tol, _Real}
				},
				Block[{
					groupOrdering = Ordering[grps],
					returnOrder=1
					},
						Do[
							Block[
								{
									flag=True,
									i=1,j=1,
									newpts,
									oldpts
									},
								While[i\[LessEqual]Length[grps]&&flag,
									With[{grp=Take[positions, {Total@grps[[;;i-1]], grps[[i]]}]},
										j=1;
										While[j\[LessEqual]grps[[i]]&&flag,
											flag=symmetricPointQ[
												rawRotationReflectionTransformationFunction[
													grp[[j]],
													2.\[Pi]/o,
													point2,
													point1
													],
												grp[[j]],
												grp,
												tol
												];
											j++
											]
										];
									i++
									];
								If[flag,
									returnOrder=o;
									Break[]
									]
								],
							{o, grps}
							];
					returnOrder
					]
				]
		];*)


(* ::Subsubsection::Closed:: *)
(*ScrewAxisOrder*)



screwTransform[order_, axisPoint_]:=
	Composition[
		rotationTransform[order, axisPoint],
		ReflectionTransform[axisPoint]
		]//Simplify;
screwTransform[axisPoint_][order_]:=
	screwTransform[order,axisPoint]


ChemUtilsScrewAxisOrder[
	point_,
	groups_,
	tol:_?NumericQ|Automatic:Automatic
	]:=
	With[{es=SortBy[groups, Length]},
		With[{
			ret=
				Do[
					If[
						symmetryOperationQ[
							screwTransform[o, point],
							groups,
							Replace[tol, Automatic:>$ChemSymmetryTolerance]
							],
						Return[o]
						],
					{o, Length@groups[[-1]], 3, -1}
					]
				},
			If[ret>0//TrueQ,
				ret,
				0
				]
			]
		];


(* ::Subsubsection::Closed:: *)
(*InertialSymmetry*)



ChemUtilsInertialSymmetry[c_,axes_,atoms_,toler:_?NumericQ|Automatic:Automatic]:=
	With[{tol=Replace[toler, Automatic:>$ChemSymmetryTolerance]},
		<|
			"CenterSymmetric"->ChemUtilsInversionCenterQ[c,atoms,tol],
			"ARotationOrder"->ChemUtilsRotationAxisOrder[{c,c+axes[[1]]},atoms,tol],
			"BRotationOrder"->ChemUtilsRotationAxisOrder[{c,c+axes[[2]]},atoms,tol],
			"CRotationOrder"->ChemUtilsRotationAxisOrder[{c,c+axes[[3]]},atoms,tol],
			"ABSymmetric"->ChemUtilsPlaneOfSymmetryQ[{c,c+axes[[1]],c+axes[[2]]},atoms,tol],
			"ACSymmetric"->ChemUtilsPlaneOfSymmetryQ[{c,c+axes[[1]],c+axes[[3]]},atoms,tol],
			"BCSymmetric"->ChemUtilsPlaneOfSymmetryQ[{c,c+axes[[2]],c+axes[[3]]},atoms,tol],
			"AScrewOrder"->
				ChemUtilsScrewAxisOrder[{c,c+axes[[1]]},atoms,tol],
			"BScrewOrder"->
				ChemUtilsScrewAxisOrder[{c,c+axes[[2]]},atoms,tol],
			"CScrewOrder"->
				ChemUtilsScrewAxisOrder[{c,c+axes[[3]]},atoms,tol]
			|>
		];
ChemUtilsInertialSymmetry[atoms_,tol:_?NumericQ|Automatic:Automatic]:=
	With[{
		c=ChemUtilsCenterOfMass@atoms,
		axes=Lookup[ChemUtilsInertialSystem@atoms,{"AAxis","BAxis","CAxis"}]
		},
		ChemUtilsInertialSymmetry[c,axes,atoms,
			Replace[tol, Automatic:>$ChemSymmetryTolerance]]
		];


(* ::Subsubsection::Closed:: *)
(*symmetryTestPosition*)



$chemSymmEscapeArray=
	RandomReal[{-.5,.5},3];


(*enumeratePositionsIter:=
	enumeratePositionsIter=With[{$chemSymmEscapeArray=$chemSymmEscapeArray},
	enumeratePositionsIter=
		Compile[{{positions, _Real, 2},{n, _Integer}, {plen, _Integer}},
			With[
				{
					i=1+Floor[(n-1)/plen],
					j=Mod[n, plen, 1]
					},
				If[i>j,
					$chemSymmEscapeArray,
					Mean[{
						positions[[i]],
						positions[[j]]
						}]
					]
				]
			]
	];
symmetryTestPosition[center_, positions_, n_]:=
	enumeratePositionsIter[positions, n, Length@positions];
symmetryTestPositionCount[center_, positions_]:=
	Length@positions^2;*)


uniquePointsQComp=
	Compile[{{pt1,_Real,1},{pt2,_Real,1}, {tol,_Real}},
		Norm[pt1-pt2]>tol
		]
uniquePointsQ[pt1_List, pt2_]:=
	uniquePointsQComp[pt1, pt2, $ChemSymmetryUniquenessThreshold];
uniquePointsQ[___]:=False


(*enumeratePlanesIter1:=enumeratePlanesIter1=With[{
	$chemSymmEscapeArray=$chemSymmEscapeArray,
	uniquePointsQComp=uniquePointsQComp,
	$ChemSymmetryUniquenessThreshold=$ChemSymmetryUniquenessThreshold,
	enumeratePositionsIter=enumeratePositionsIter
	},
		Compile[{
			{center, _Real, 1}, {positions, _Real, 2},
			{n, _Integer}, {plen, _Integer}
			},
			With[
				{
					i=1+Floor[(n-1)/(plen^2)],
					j=Mod[n, plen^2, 1]
					},
				If[i>=j,
					{$chemSymmEscapeArray, $chemSymmEscapeArray},
					With[{pt1=enumeratePositionsIter[positions, i, plen]},
						If[(
								pt1!=$chemSymmEscapeArray&&
								uniquePointsQComp[pt1, center,$ChemSymmetryUniquenessThreshold]
								)//TrueQ,
							With[{pt2=enumeratePositionsIter[positions, j, plen]},
								If[(
									pt2!=$chemSymmEscapeArray&&
									uniquePointsQComp[pt2, center, $ChemSymmetryUniquenessThreshold]
									)//TrueQ,
									{pt1, pt2},
									{$chemSymmEscapeArray, $chemSymmEscapeArray}
									]
								],
							{$chemSymmEscapeArray, $chemSymmEscapeArray}
							]
						]
					]
				]
			]
		];*)


(*enumerateAxesIter:=enumerateAxesIter=With[{
	$chemSymmEscapeArray=$chemSymmEscapeArray,
	uniquePointsQComp=uniquePointsQComp,
	$ChemSymmetryUniquenessThreshold=$ChemSymmetryUniquenessThreshold,
	enumeratePositionsIter=enumeratePositionsIter,
	enumeratePlanesIter=enumeratePlanesIter
	},
	Compile[{
		{center, _Real, 1}, {positions, _Real, 2},
		{n, _Integer}, {plen, _Integer}
		},
		With[{p=
			If[n<=plen^2,
				enumeratePositionsIter[positions, n, plen],
				With[{s=enumeratePlanesIter[center, positions, n - plen]},
					If[s=!=$chemSymmEscapeArray,
						center+Cross[s[[1]]-center, s[[2]]-center],
						$chemSymmEscapeArray
						]
					]
				]
				},
			If[uniquePointsQComp[p,center,$ChemSymmetryUniquenessThreshold],
				p, 
				$chemSymmEscapeArray
				]
			]
		]
	];
symmetryTestAxis[center_, positions_, n_]:=
	enumerateAxesIter[center, positions, n, Length@positions];
symmetryTestAxisCount[positions_]:=
	Length@positions^4+Length@positions*)


(*enumeratePlanesIter2:=
	enumeratePlanesIter2=With[
	{
		$chemSymmEscapeArray=$chemSymmEscapeArray,
		uniquePointsQComp=uniquePointsQComp,
		$ChemSymmetryUniquenessThreshold=$ChemSymmetryUniquenessThreshold,
		enumerateAxesIter=enumerateAxesIter
		},
		Compile[{
			{center, _Real, 1}, {positions, _Real, 2},
			{n, _Integer}, {plen, _Integer}
			},
			With[
				{
					i=1+Floor[(n-1)/(plen^2)],
					j=Mod[n, (plen^2), 1]
					},
					With[{pt1=enumerateAxesIter[center, positions, i + plen^2, plen]},
						If[
							(
								pt1!=$chemSymmEscapeArray&&
								uniquePointsQComp[pt1, center, $ChemSymmetryUniquenessThreshold]
								)//TrueQ,
							With[{pt2=enumerateAxesIter[center, positions, j, plen]},
								If[
									(
										pt2!=$chemSymmEscapeArray&&
										uniquePointsQComp[pt2, center, $ChemSymmetryUniquenessThreshold]
										)//TrueQ,
									{pt1, pt2},
									{$chemSymmEscapeArray, $chemSymmEscapeArray}
									]
								],
							{$chemSymmEscapeArray, $chemSymmEscapeArray}
							]
						]
					]
			]
		];
enumeratePlanesIter=
	With[{
		enumeratePlanesIter1=enumeratePlanesIter1,
		enumeratePlanesIter2=enumeratePlanesIter2
		},
		Compile[
			{
				{center, _Real, 1}, {positions, _Real, 2},
				{n, _Integer}, {plen, _Integer}
				},
			If[ n <= plen^4,
				enumeratePlanesIter1[center, positions, n, plen],
				enumeratePlanesIter2[center, positions, n, plen]
				]
			]
		];
symmetryTestPlane[center_, positions_, n_]:=
	With[{len=Length@positions},
		If[ n <= len^4,
			enumeratePlanesIter[center, positions, n, len],
			enumeratePlanesIter2[center, positions, n, len]
			]
		];
symmetryTestPlaneCount[positions_]:=
	Length@positions^4+Length@positions^4;*)


(*enumerateRotationAxesCompiled:=enumerateRotationAxesCompiled=With[
	{
		$chemSymmEscapeArray=$chemSymmEscapeArray,
		uniquePointsQComp=uniquePointsQComp,
		uniqueAxesQComp=uniqueAxesQComp,
		$ChemSymmetryUniquenessThreshold=$ChemSymmetryUniquenessThreshold,
		enumerateAxesIter=enumerateAxesIter,
		enumeratePlanesIter=enumeratePlanesIter,
		ChemUtilsRotationAxisOrderComp=ChemUtilsRotationAxisOrderComp
		},
		Compile[
			{
				{center, _Real, 1},
				{positions, _Real, 2},
				{groups, _Integer, 1},
				{totalCount, _Integer},
				{linearFlag, _Integer},
				{tol, _Real}
				},
		Block[
			{
				triedAxes=
					Table[$chemSymmEscapeArray,totalCount],
				successOrders=
					Table[-1,totalCount],
				linearQ=linearFlag===1,
				j,
				allTrueFlag
				},
			Do[
				triedAxes[[n]]=enumerateAxesIter[center, positions, n];
				If[triedAxes[[n]]=!=$chemSymmEscapeArray,
						allTrueFlag=True;
						If[j=1;
								While[j<n&&allTrueFlag,
									allTrueFlag=(
										triedAxes[[j]]===$chemSymmEscapeArray||
										uniqueAxesQComp[
											center,
											triedAxes[[j]], 
											triedAxes[[n]],
											$ChemSymmetryUniquenessThreshold
											]
										);
									j++
									];
								allTrueFlag,
							With[{
								o=
									ChemUtilsRotationAxisOrderComp[
										center,
										triedAxes[[n]],
										positions,
										groups,
										linearFlag,
										tol
										]
									},
								If[o>1,
									successOrders[[n]]=
										o
									]
								]
							];
						],
					{n, totalCount}
					];
			Thread[{
				Select[successOrders, #>1&],
				Pick[triedAxes, #>1&/@successOrders]
				}]
			]
		]
	];*)


(*enumerateSymmetryPlanesCompiled:=enumerateSymmetryPlanes=With[
	{
		$chemSymmEscapeArray=$chemSymmEscapeArray,
		uniquePointsQComp=uniquePointsQComp,
		uniqueAxesQComp=uniqueAxesQComp,
		$ChemSymmetryUniquenessThreshold=$ChemSymmetryUniquenessThreshold,
		enumerateAxesIter=enumerateAxesIter,
		enumeratePlanesIter=enumeratePlanesIter,
		ChemUtilsPlaneOfSymmetryQComp=ChemUtilsPlaneOfSymmetryQComp
		},
		Compile[
			{
				{center, _Real, 1},
				{positions, _Real, 2},
				{groups, _Integer, 1},
				{totalCount, _Integer},
				{tol, _Real}
				},
			Block[
				{
					triedPlanes=
						Table[{$chemSymmEscapeArray, $chemSymmEscapeArray}, totalCount],
					triedNorms=
						Table[$chemSymmEscapeArray, totalCount],
					testPlane,
					testNorm,
					plen=Length@positions,
					allTrueFlag,
					j=1
					},
				Do[
					testPlane=enumeratePlanesIter[center, positions, n, plen];
					If[testPlane=!={$chemSymmEscapeArray,$chemSymmEscapeArray},
						testNorm=
							triedNorms[[n]]=
									Cross[testPlane[[1]]-center, testPlane[[2]]-center];
						allTrueFlag=True;
						If[testPlane[[1]]!={0.,0.,0.}&&
							(
								j=1;
								While[j<n&&allTrueFlag,
									allTrueFlag=(
										triedNorms[[j]]===$chemSymmEscapeArray||
										uniqueAxesQComp[
											center,
											triedNorms[[j]], 
											testNorm,
											$ChemSymmetryUniquenessThreshold
											]
										);
									j++
									];
								allTrueFlag
								),
							If[
									ChemUtilsPlaneOfSymmetryQComp[
										center,
										testPlane[[1]],
										positions,
										groups,
										tol
										],
								triedPlanes[[n]]=
									testPlane
								]
							];
						],
					{n, totalCount}
					];
				Select[triedPlanes, 
					#=!={$chemSymmEscapeArray,$chemSymmEscapeArray}&
					]
				]
			]
	];*)


(*enumerateScrewAxes:=enumerateScrewAxes=With[
	{
		$chemSymmEscapeArray=$chemSymmEscapeArray,
		uniquePointsQComp=uniquePointsQComp,
		uniqueAxesQComp=uniqueAxesQComp,
		$ChemSymmetryUniquenessThreshold=$ChemSymmetryUniquenessThreshold,
		enumerateAxesIter=enumerateAxesIter,
		enumeratePlanesIter=enumeratePlanesIter,
		ChemUtilsScrewAxisOrderComp=ChemUtilsScrewAxisOrderComp
		},
		Compile[
			{
				{center, _Real, 1},
				{positions, _Real, 2},
				{groups, _Integer, 1},
				{totalCount, _Integer},
				{linearFlag, _Integer},
				{tol, _Real}
				},
		Block[
			{
				triedAxes=
					Table[$chemSymmEscapeArray,totalCount],
				successOrders=
					Table[-1,totalCount],
				linearQ=linearFlag===1,
				j,
				allTrueFlag
				},
			Do[
				triedAxes[[n]]=enumerateAxesIter[center, positions, n];
				If[triedAxes[[n]]=!=$chemSymmEscapeArray,
						allTrueFlag=True;
						If[j=1;
								While[j<n&&allTrueFlag,
									allTrueFlag=(
										triedAxes[[j]]===$chemSymmEscapeArray||
										uniqueAxesQComp[
											center,
											triedAxes[[j]], 
											triedAxes[[n]],
											$ChemSymmetryUniquenessThreshold
											]
										);
									j++
									];
								allTrueFlag,
							With[{
								o=
									ChemUtilsScrewAxisOrderComp[
										center,
										triedAxes[[n]],
										positions,
										groups,
										tol
										]
									},
								If[o>1,
									successOrders[[n]]=
										o
									]
								]
							];
						],
					{n, totalCount}
					];
			Thread[{
				Select[successOrders, #>1&],
				Pick[triedAxes, #>1&/@successOrders]
				}]
			]
		]
	];*)


(* ::Subsubsection::Closed:: *)
(*uniqueAxesQCompGen*)



uniqueAxesQCompGen[tolRough_]:=
	With[{tol=Mod[10*tolRough*Degree, \[Pi]]},
		Compile[{{p, _Real, 1}, {q, _Real, 1}},
			With[{arg=(p.q)/(Norm[p]*Norm[q])},
				Which[
					arg==-1,
						True,
					arg==1,
						True,
					True,
						With[{ang=ArcCos[arg]},
							tol<ang<\[Pi]-tol
							]
					]
				]
			]
		]


nonUniqueAxesQCompGen[tolRough_]:=
	With[{tol=Mod[10*tolRough*Degree, \[Pi]]},
		Compile[{{p, _Real, 1}, {q, _Real, 1}},
			With[{arg=(p.q)/(Norm[p]*Norm[q])},
				Which[
					arg==-1,
						True,
					arg==1,
						True,
					True,
						With[{ang=ArcCos[arg]},
							tol>ang||ang>\[Pi]-tol
							]
					]
				]
			]
		]


(* ::Subsubsection::Closed:: *)
(*uniquePlanesQCompGen*)



uniquePlanesQCompGen[center_, tolRough_]:=
	With[{tol=Mod[10*tolRough*Degree, \[Pi]]},
		Compile[{{src1, _Real, 2}, {src2, _Real, 2}},
			With[{
				p=Cross[src1[[1]], src1[[2]]],
				q=Cross[src2[[1]], src2[[2]]]
				},
				With[{arg=(p.q)/(Norm[p]*Norm[q])},
					Which[
						arg==-1,
							True,
						arg==1,
							True,
						True,
							With[{ang=ArcCos[arg]},
								tol<ang<\[Pi]-tol
								]
						]
					]
				]
			]
		]


nonUniquePlanesQCompGen[tolRough_]:=
	With[{tol=Mod[10*tolRough*Degree, \[Pi]]},
		Compile[{{src1, _Real, 2}, {src2, _Real, 2}},
			With[{
				p=Cross[src1[[1]], src1[[2]]],
				q=Cross[src2[[1]], src2[[2]]]
				},
				With[{arg=(p.q)/(Norm[p]*Norm[q])},
					Which[
						arg==-1,
							True,
						arg==1,
							True,
						True,
							With[{ang=ArcCos[arg]},
								tol>ang||ang>\[Pi]-tol
								]
						]
					]
				]
			]
		]


(* ::Subsubsection::Closed:: *)
(*enumeratePositions*)



$chemSymmIgnore=RandomReal[{-1,1}, 3];


enumeratePositionsCore=
	Compile[{{positions, _Real, 2}},
		Select[
			Table[
				With[
					{
						i=1+Floor[(n-1)/Length[positions]],
						j=Mod[n, Length[positions], 1]
						},
					If[i>j,
						$chemSymmEscapeArray,
						If[i==j,
							positions[[i]], 
							If[positions[[i]]=!=positions[[j]],
								Mean[{
									positions[[i]],
									positions[[j]]
									}],
								$chemSymmEscapeArray
								]
							]
						]
					],
				{n, Length@positions^2}
				],
			#=!=$chemSymmEscapeArray&
			]
		];
enumeratePositions[pts_]:=
	Replace[enumeratePositionsCached[{pts}],
		Except[_List]:>
			Set[
				enumeratePositionsCached[pts], 
				If[Length[pts]>0, enumeratePositionsCore[pts], {}]
				]
		]


(* ::Subsubsection::Closed:: *)
(*deleteDuplicatePlanes*)



deleteDuplicatePlanesPickSpec[tol_]:=
	Compile[
		{	{planes, _Real, 3} },
		Block[{
			vecs = Cross[#[[1]], #[[2]]]&/@planes,
			vecNorm,
			angs,
			order,
			angDiffs,
			angSel,
			tally=0.,
			normDiffs,
			flag=1,
			tolTrue=tol/100
			},
			Times@@
				Table[
					vecNorm=Norm@vecs[[i]];
					angs=
							Table[(vecs[[i]].vecs[[j]])/(vecNorm*Norm[vecs[[j]]]),
								{j, i+1, Length@vecs}
								];
					Join[
						Table[1, {doop,i}],
						If[1-tol<#, 0, 1]&/@Abs[angs]
						],
					{i, Length[vecs]}
					]
			]
		];
deleteDuplicatePlanes[planes_, tol_]:=
	If[Length[planes]>1,
		With[{spec=deleteDuplicatePlanesPickSpec[tol]@planes},
			If[Length[spec]===Length[planes],
				Pick[planes, spec, 1],
				planes
				]
			],
		planes
		]


(* ::Subsubsection::Closed:: *)
(*enumeratePlanesSimple*)



enumeratePlanesEnumerator//Clear


enumeratePlanesEnumeratorComp=
	With[{
			$failed=$chemSymmEscapeArray
			},
		Compile[{{positions, _Real, 2}},
			Select[
				Flatten[
					Table[
						With[
							{
								i=1+Floor[(n-1)/Length[positions]],
								j=Mod[n, Length[positions], 1],
								i2=1+Floor[(m-1)/Length[positions]],
								j2=1+Floor[(m-1)/Length[positions]]
								},
							If[n>m||i>j||i2>j2,
								{$failed, $failed},
								With[{
									samp=
										{
											If[i==j,
												positions[[i]], 
												If[positions[[i]]=!=positions[[j]],
													Mean[{
														positions[[i]],
														positions[[j]]
														}],
													$failed
													]
												],
											If[i2==j2,
												positions[[i2]], 
												If[positions[[i]]=!=positions[[j]],
													Mean[{
														positions[[i2]],
														positions[[j2]]
														}],
													$failed
													]
												]
											}
										},
										If[samp[[1]]=!=samp[[2]],	
											samp,
											{$failed, $failed}
											]
										]
								]
							],
						{n, Length@positions^2},
						{m, Length@positions^2}
						],
					1
					],
				#[[1]]=!=$failed&&#[[2]]=!=$failed&
				]
			]
		];


enumeratePlanesEnumerator[pts_]:=
	With[{real=Select[pts, Norm[#]>0&]},
		If[Length@real>1,
			enumeratePlanesEnumeratorComp[real],
			{}
			]
		]


enumeratePlanesSimple[pts_, tol_]:=
	Replace[enumeratePlanesSimpleCached[{pts, tol}],
		Except[_List]:>
			Set[
				enumeratePlanesSimpleCached[{pts, tol}],
					With[{base=DeleteDuplicates@enumeratePlanesEnumerator[pts]},
						deleteDuplicatePlanes[
							base,
							tol
							]
						]
				]
		]


(* ::Subsubsection::Closed:: *)
(*enumeratePlanes optimized, broken version*)



(*enumeratePlanesSimple=
	With[{uniqueAxesQComp=uniqueAxesQComp},
		Compile[{{center, _Real, 1}, {positions, _Real, 2}, {tol, _Real}},
			Block[{
				coplanarPts=
					Table[
						0, 
						{m, Length[positions]^2}, 
						{n, Length[positions]^2}, 
						{o, Length[positions]^2}
						],
				coplanarFlag=False,
				p,
				ptsBag=Internal`Bag[Most@{0}]
				},
				Do[
					With[{
						(* This just computes the indices for each planar pt *)
						i1=1+Floor[(n-1)/Length[positions]],
						j1=Mod[n, Length[positions], 1],
						i2=1+Floor[(m-1)/Length[positions]],
						j2=Mod[m, Length[positions], 1],
						i3=1+Floor[(m-1)/Length[positions]],
						j3=Mod[m, Length[positions], 1]
						},
						(* Reduce the combinations to check *)
						If[m>n||i1>j1||i2>j2||i3>j3||
							(
								coplanarFlag = False;
								p=1;
								While[(!coplanarFlag)&&p<n,
									(* Check if there's anything point such that these are all coplanar *)
									coplanarFlag=
										(coplanarPts[[p, n, o]]>0)&&
											(coplanarPts[[p, m, o]]>0);
									p++
									];
								!coplanarFlag
								),
							-1,
						With[{
							p1=If[i1\[Equal]j1, positions[[i1]], Mean[{positions[[i1]], positions[[j1]]}]],
							p2=If[i2\[Equal]j2, positions[[i2]], Mean[{positions[[i2]], positions[[j2]]}]],
							p3=If[i3\[Equal]j3, positions[[i3]], Mean[{positions[[i3]], positions[[j3]]}]]
							},
							If[
								coplanarPts[[m, n, o]]=
									If[
										uniqueAxesQComp[
											center,
											Cross[p1-center, p2-center],
											Cross[p3-center, p2-center],
											tol
											],
										1,
										0
										],
								Internal`StuffBag[
									ptsBag,
									Internal`Bag[{Internal`Bag[p1],Internal`Bag[p2]}]
									],
								Internal`StuffBag[
									ptsBag,
									Internal`Bag[{Internal`Bag[p1],Internal`Bag[p2]}]
									];
								Internal`StuffBag[
									ptsBag,
									Internal`Bag[{Internal`Bag[p1],Internal`Bag[p3]}]
									];
								Internal`StuffBag[
									ptsBag,
									Internal`Bag[{Internal`Bag[p2],Internal`Bag[p3]}]
									];
								]
							]
						]
					],
					{n, Length@positions^2},
					{m, Length@positions^2},
					{o, Length@positions^2}
					];
				Internal`BagPart[ptsBag, All]
				]
			]
		]*)


(* ::Subsubsection::Closed:: *)
(*deleteDuplicateAxes*)



deleteDuplicateAxesInds[tol_]:=
	Compile[
		{	{vecs, _Real, 2} },
		Block[{
			pickedVecs,
			tally=0.,
			vecNorm,
			angs,
			order,
			reorder,
			angDiffs,
			angSel,
			flag=1,
			tolTrue=tol/100
			},
			Times@@
				Table[
					vecNorm=Norm@vecs[[i]];
					angs=
							Table[(vecs[[i]].vecs[[j]])/(vecNorm*Norm[vecs[[j]]]),
								{j, i+1, Length@vecs}
								];
					Join[
						Table[1, {o, i}],
						If[1-tol<Abs[#], 0, 1]&/@angs
						],
					{i, Length@vecs}
					]
			]
		];
deleteDuplicateAxes[axes_, tol_]:=
	With[{real=Select[axes, Norm[#]>tol&]},
		If[Length[real]>1,
			Pick[real,
				deleteDuplicateAxesInds[tol]@real,
				1],
			real
			]
		]


(* ::Subsubsection::Closed:: *)
(*deleteDuplicateRotationAxes*)



deleteDuplicateRotationAxes[axes_, tol_]:=
	With[{
		a=GroupBy[axes, First->Last, DeleteDuplicates]},
		Join@@
			KeyValueMap[
				Thread[{#, Pick[a[#], #2, 1]}]&,
				deleteDuplicateAxesInds[tol]/@a
				]
		]


(* ::Subsubsection::Closed:: *)
(*enumerateAxes*)



enumerateAxesNormals=
	Compile[{{p,_Real,3}},
		Map[Cross[#[[1]], #[[2]]]&, p]
		]


enumerateAxes[positions_, tol_]:=
	Replace[enumerateAxesCached[{positions, tol}],
		Except[_List]:>
			Set[
				enumerateAxesCached[{positions, tol}],
				With[{
					posReal=
						deleteDuplicateAxes[
							positions, 
							tol
							]
					},
					deleteDuplicateAxes[
						Join[
							enumeratePositions[posReal],
							With[{r=enumeratePlanesSimple[posReal, tol]},
								If[Length[r]>0,
									enumerateAxesNormals@r,
									{}
									]
								]
							],
						tol
						]
					]
				]
		]


(* ::Subsubsection::Closed:: *)
(*enumerateRotationAxes*)



enumerateRotationAxes[axes_, groups_,linearQ_, tol_, tol2_]:=
	With[
		{
			ax=
				Union@@
					Join[
						Values@
							Map[
								Function[
									enumerateAxes[#, tol2]
									],
								groups
								],
						{axes}
						]
			},
		Map[
			With[
				{
					o=
						ChemUtilsRotationAxisOrder[#, groups, linearQ, tol]
					},
				If[o>1,
					{o, #},
					Nothing
					]
				]&,
			deleteDuplicateAxes[
				ax,
				tol2
				]
			]
		]


(* ::Subsubsection::Closed:: *)
(*enumerateSymmetryPlanes*)



enumeratePlanes[positions_, tol_]:=
	With[{axBase=enumerateAxes[positions, tol]},
		If[Length@axBase>1,
			enumeratePlanesSimple[
				enumerateAxes[positions, tol], 
				tol
				],
			{}
			]
		]


enumerateSymmetryPlanes[axes_, groups_,tol_,tol2_]:=
	With[{
		u=
			Union@@
				Join[
					Values@
						Map[
							enumeratePlanes[#, tol2]&,
							groups
							],
					{Subsets[axes, {2}]}
					]
		},
		If[Length@u>0,
			Select[
				deleteDuplicatePlanes[u, tol2],
				ChemUtilsPlaneOfSymmetryQ[
					#,
					groups,
					tol
					]&
				],
			{}
			]
		]


(* ::Subsubsection::Closed:: *)
(*PlaneOfSymmetryQComp*)



(*ChemUtilsPlaneOfSymmetryQComp:=
	With[
		{
			symmetricPointQ=symmetricPointQ,
			rawReflectionTransformationFunction=rawReflectionTransformationFunction
			},
		Compile[
			{
				{point1, _Real, 1},
				{norm, _Real, 1},
				{positions, _Real, 2},
				{grps, _Integer, 1},
				{tol, _Real}
				},
				Block[{
					flag=True,
					i=1,j=1,
					newpts,
					oldpts
					},
					While[i\[LessEqual]Length[grps]&&flag,
						With[{grp=Take[positions, {Total@grps[[;;i-1]], grps[[i]]}]},
							j=1;
							While[j\[LessEqual]grps[[i]]&&flag,
								flag=symmetricPointQ[
									rawReflectionTransformationFunction[
										grp[[j]],
										norm,
										point1
										],
									grp[[j]],
									grp,
									tol
									];
								j++
								]
							];
						i++
						];
					flag
					]
				]
		];*)


(* ::Subsubsection::Closed:: *)
(*PlaneOfSymmetryQ*)



ChemUtilsPlaneOfSymmetryQ[
	norm_:{_,_,_},
	grps_,
	tol:_?NumericQ:0.000001
	]:=
	symmetryOperationQ[
		ReflectionTransform[norm],
		grps,
		tol
		];
ChemUtilsPlaneOfSymmetryQ[
	{point1_,point2_},
	grps_,
	tol:_?NumericQ:0.000001
	]:=
	ChemUtilsPlaneOfSymmetryQ[
		Cross[point1, point2],
		grps,
		tol
		]


(* ::Subsubsection::Closed:: *)
(*enumerateScrewAxes*)



enumerateScrewAxes[axes_, groups_,tol_,tol2_]:=
	With[
		{
			ax=
				Union@@
					Join[
						Values@
							Map[
								Function[
									enumerateAxes[#, tol2]
									],
								groups
								],
						{axes}
						]
			},
	Map[
		With[{o=ChemUtilsScrewAxisOrder[#, groups,tol]},
			If[o>0,
				{o, #},
				Nothing
				]
			]&,
		deleteDuplicateAxes[
			ax,
			tol2
			]
		]
	]


(* ::Subsubsection::Closed:: *)
(*RawSymmetryElements*)



$ChemSymmetryTolerance=.01;
$ChemSymmetryUniquenessThreshold=.0001;


Options[ChemUtilsRawSymmetryElements]=
	{
		Tolerance->Automatic,
		"UniquenessThreshold"->Automatic
		};
ChemUtilsRawSymmetryElements[atoms_,
	ops:OptionsPattern[]
	]:=
	Block[{
		enumeratePositionsCached,
		enumeratePlanesSimpleCached,
		enumerateAxesCached,
		$ChemSymmetryTolerance=
			Replace[OptionValue[Tolerance],
				Except[_?NumericQ]->$ChemSymmetryTolerance],
		$ChemSymmetryUniquenessThreshold=
			Replace[OptionValue["UniquenessThreshold"],
				Except[_?NumericQ]->$ChemSymmetryUniquenessThreshold]
		},
		With[{
			center=
				Round[ChemUtilsCenter@atoms, $ChemSymmetryUniquenessThreshold],
			tol=
				$ChemSymmetryTolerance,
			tol2=
				$ChemSymmetryUniquenessThreshold
			},
			With[{
				axes=
					Last@ChemUtilsInertialEigensystem@atoms,
				groups=
					Map[#-center&]/@
						Round[
							GroupBy[atoms,First->Last],
							.0001
							],
				linear=
					ChemUtilsRotorType[atoms]==="Linear"
				},
				<|
					"Center"->
						center,
					"CenterSymmetric"->
						ChemUtilsInversionCenterQ[
							Select[
								Join@@Values@groups,
								Norm[#]>0&
								],
							tol
							],
					"RotationAxes"->
						Replace[
							enumerateRotationAxes[
								axes,
								groups,
								ChemUtilsRotorType[
									MapThread[
										Thread@*List,
										{Keys[groups],Values[groups]}
										]
									]==="Linear",
								tol,
								tol2
								],
							{o_, v_}:>
								{o, Normalize[v] + center},
							1
							],
					"SymmetryPlanes"->
						Replace[
							enumerateSymmetryPlanes[
								axes,
								groups,
								tol,
								tol2
								],
							{v1_, v2_}:>
								{Normalize[v1]+center, Normalize[v2]+center},
							1
							],
					"ScrewAxes"->
						Replace[
							enumerateScrewAxes[
								axes,
								groups,
								tol,
								tol2
								],
							{o_,v_}:>
								{o, Normalize[v]+center},
							1
							]
					|>
				]
			]
		];


(* ::Subsubsection::Closed:: *)
(*SymmetryElementFunctions*)



ChemUtilsSymmetryElementFunction[
	"InversionCenter",
	center_
	]:=
	ScalingTransform[{-1, -1, -1}, center];
ChemUtilsSymmetryElementFunction[
	"RotationAxes",
	center_,
	{order_, v_}
	]:=
	RotationTransform[2\[Pi]/order, v-center, center];
ChemUtilsSymmetryElementFunction[
	"SymmetryPlanes",
	center_,
	{v1_, v2_}
	]:=
	ReflectionTransform[
		Cross[v1-center, v2-center],
		center
		];
ChemUtilsSymmetryElementFunction[
	"ScrewAxes",
	center_,
	{order_, v_}
	]:=
	Composition[
		RotationTransform[2\[Pi]/order, v-center, center],
		ReflectionTransform[
			v,
			center
			]
		]//Simplify


ChemUtilsSymmetryElementFunctions[
	rawEls_Association?(KeyMemberQ["Center"])
	]:=
	Association@
	KeyValueMap[
		Switch[#,
			"CenterSymmetric",
				If[#2,
					"InversionCenter"->
						ChemUtilsSymmetryElementFunction["InversionCenter", rawEls["Center"]],
					Nothing
					],
			"RotationAxes",
				#->
					AssociationMap[
						ChemUtilsSymmetryElementFunction["RotationAxes",
							rawEls["Center"],
							#
							]&,
						#2
						],
			"SymmetryPlanes",
				#->
					AssociationMap[
						ChemUtilsSymmetryElementFunction["SymmetryPlanes",
							rawEls["Center"],
							#
							]&,
						#2
						],
			"ScrewAxes",
				#->
					AssociationMap[
						ChemUtilsSymmetryElementFunction["ScrewAxes",
							rawEls["Center"],
							#
							]&,
						#2
						],
			_,
				Nothing
			]&,
		rawEls
		];
ChemUtilsSymmetryElementFunctions[
	atoms_,tol:_?NumericQ|Automatic:Automatic
	]:=
	ChemUtilsSymmetryElementFunctions@
		ChemRawSymmetryElements[atoms, tol]


(* ::Subsubsection::Closed:: *)
(*SymmetryElementGrouping*)



ChemUtilsSymmetryTotalGroup//Clear


ChemUtilsSymmetryElementGroup//Clear


ChemUtilsSymmetryTotalGroup["RotationAxes"|"ScrewAxes",
	axes_,
	center_,
	fns_
	]:=
	FixedPoint[
		DeleteDuplicates[
			Flatten[
				Table[f[p],
					 {p, #},
				 {f, Flatten@Values@fns}
					],
				1
				],
			Norm[#-#2]<.1&
			]&, 
		{axes[[1, 2]]}, 
		Length[axes]
		];


ChemUtilsSymmetryElementGroup[
	"RotationAxes"|"ScrewAxes",
	axes_,
	center_,
	fns_
	]:=
	ConnectedComponents[
		Graph@
			Flatten@{
				(* Map things to themselves *)
				Map[#<->#&, axes],
				Table[
					With[{
						fpl=
							FixedPoint[
								DeleteDuplicates[
									DeleteDuplicates@Join[#, Map[f, #]],
									(Norm[#-#2]<.1&)
									]&,
								{a[[2]]},
								SameTest->(Round[#,.01]==Round[#2,.01]&)
								]
						},
						With[{
							order=a[[1]],
							newPt=#
							},
							Replace[
								(* Find the element corresponding to the point *)
								SelectFirst[DeleteCases[axes,a],
									order==#[[1]]&&!uniqueAxesQ[center, newPt, #[[2]]]&,
									Nothing
									],
								l_List:>
									(* An element was found so connect it to a *)
									a<->l
								]
							]&/@fpl
						],
					{a, axes},
					{f, Flatten@Values@fns}
					]
					}
				];


ChemUtilsSymmetryTotalGroup["SymmetryPlanes",
	planes_,
	center_,
	fns_
	]:=
	FixedPoint[
		DeleteDuplicates[
			Flatten[
				Table[
					Map[f, pl],
					{pl, #},
				 {f, Flatten@Values@fns}
					],
				1
				],
			Norm[
				Normalize@Cross[#[[1]]-center, #[[2]]-center]-
					Normalize@Cross[#2[[1]]-center, #2[[2]]-center]
				]<.1&
			]&, 
		{planes[[1]]}, 
		Length[planes]
		];
ChemUtilsSymmetryElementGroup["SymmetryPlanes",
	planes_,
	center_,
	fns_
	]:=
	ConnectedComponents[
		Graph@Flatten@
			Join[
				Map[#<->#&, planes],
				Table[
					With[{
						fpl=
							FixedPoint[
								DeleteDuplicates[
									DeleteDuplicates@Join[#, Map[f]/@#],
									With[{p1=#, p2=#2},
										Norm[
											Normalize@Cross[p1[[1]]-center, p1[[2]]-center]-
												Normalize@Cross[p2[[1]]-center, p2[[2]]-center]
											]<.1
										]&
									]&,
								{a},
								SameTest->(Round[#,.01]==Round[#2,.01]&)
								]
						},
						With[{
							normal=
								center+Cross[#[[1]]-center,#[[2]]-center]
							},
							Replace[
								SelectFirst[DeleteCases[planes,a],
									!uniqueAxesQ[
										center,
										normal,
										center+Cross[#[[2]]-center,#[[1]]-center]
										]&,
									Nothing
									],
								l_List:>
									a<->l
								]
							]&/@fpl
						],
					{a, planes},
					{f, Flatten@Values@fns}
					]
				]
			];
ChemUtilsSymmetryElementGroup[k1_,k_,r__]:=
	k;
ChemUtilsSymmetryElementGrouping[
	elems_,
	fns_,
	tol_:Automatic
	]:=
	Association@
		KeyValueMap[
			#->
				ChemUtilsSymmetryElementGroup[#, #2, elems["Center"], 
					Flatten@Values@KeyDrop[fns, "InversionCenter"]
					]&,
			KeyDrop[elems, {"Center","CenterSymmetric"}]
			]


(* ::Subsubsection::Closed:: *)
(*SymmetryElementExpandClass*)



axisCloseEnough[center_][{_, r1_}, {_, r2_}]:=
	With[{va=VectorAngle[r1-center, r2-center]},
		va > \[Pi]-(10.*Degree) || 10.*Degree > va
		]


ChemUtilsSymmetryApplyGroupElement[objAssoc_,
	k:"RotationAxes"|"ScrewAxes",
	data:{{_, _}, ___},
	fns_
	]:=
	Join@@
		KeyValueMap[
			Thread[
				{
					#,
					FixedPoint[
						deleteDuplicateAxes[
							Union[#, Join@@Map[Through[fns[#]]&, #]],
							$ChemSymmetryUniquenessThreshold
							]&,
						#2,
						Length@objAssoc[k]
						]
					}
				]&,
			GroupBy[data, First->Last]
			]


ChemUtilsSymmetryApplyGroupElement[objAssoc_,
	"SymmetryPlanes",
	data:{{_, _},___}, 
	fns_
	]:=
	FixedPoint[
		deleteDuplicatePlanes[
			Union[#,
				Join@@
					Map[
						Transpose@{
							Through[fns[#[[1]]]],
							Through[fns[#[[2]]]]
							}&,
						#
						]
					],
			$ChemSymmetryUniquenessThreshold
			]&,
		data,
		Length@objAssoc["SymmetryPlanes"]
		]


ChemUtilsSymmetryApplyGroupElement[_, _, d_, fn_]:=
	{d}


ChemUtilsSymmetryApplyGroup[objAssoc_, key_, data_, fns_]:=
	ChemUtilsSymmetryApplyGroupElement[objAssoc, key, data, 
		Flatten@Replace[Flatten@Values@fns, a_Association:>Values[a],1]
		]


ChemUtilsSymmetryElementExpandClass[objAssoc_, fns_]:=
	Association@
		KeyValueMap[
			#->
			Switch[#,
				"RotationAxes"|"ScrewAxes",
					If[Length[#2]>0,
						With[{
							a=
							GroupBy[
								ChemUtilsSymmetryApplyGroup[
									objAssoc,
									#,
									DeleteDuplicates@
										SortBy[
											Join@@
												Map[
													Prepend[#]@
													Table[
														{o, #[[2]]},
														{o, Power@@@FactorInteger[#[[1]]]}
														]&,
													#2
													],
											First
											],
									fns
									],
								First->Last,
								DeleteDuplicates
								]
							},
							Join@@
								With[{
									df=deleteDuplicateAxesInds[$ChemSymmetryUniquenessThreshold]
									},
									KeyValueMap[
										With[{
											real=
												Select[#2, Norm[#]>$ChemSymmetryUniquenessThreshold&]
											},
											Which[Length[real]>1,
												Thread[{#, Pick[real, df@real, 1]}],
												Length[real]===1,
													Thread[{#, real}],
												Length[#2]>0,
													{#, {0.,0.,0.}},
												True,
													{}
												]
											]&,
										a
										]
									]
							],
					#2
					],
				"SymmetryPlanes",
					With[{pl=
						Sort/@
							ChemUtilsSymmetryApplyGroup[objAssoc,
								#,
								#2,
								fns
								]
							},
						If[Length[pl]>1,
							deleteDuplicatePlanes[
								pl,
								$ChemSymmetryUniquenessThreshold
								],
							pl
							]
						],
				_,
					#2
				]&,
			objAssoc
			]


(* ::Subsubsection::Closed:: *)
(*SymmetryElements*)



Options[ChemUtilsSymmetryElements]=
	Join[
		Options[ChemUtilsRawSymmetryElements],
		{
			"ReturnFunctions"->True,
			"DetermineClasses"->True,
			"FullClasses"->True
			}
		];
ChemUtilsSymmetryElements[atoms_, ops:OptionsPattern[]]:=
	Module[
		{
			raw=
				ChemUtilsRawSymmetryElements[atoms,
					FilterRules[{ops}, Options@ChemUtilsRawSymmetryElements]
					],
			fns,
			fullClass,
			funcs=TrueQ@OptionValue["ReturnFunctions"],
			classes=TrueQ@OptionValue["DetermineClasses"],
			fullClasses=TrueQ@OptionValue["FullClasses"]
			},
		fns=ChemUtilsSymmetryElementFunctions@raw;
		fullClass=
			If[fullClasses,
				ChemUtilsSymmetryElementExpandClass[raw, fns],
				raw
				];
		If[funcs,
			fns=ChemUtilsSymmetryElementFunctions@fullClass
			];
		<|
			"Elements"->
				fullClass,
			"Classes"->
				If[classes,
					Association@
						KeyValueMap[
							#->
								ReplaceAll[#2,
									MapIndexed[#->#2[[1]]&, fullClass[#]]
									]&,
							ChemUtilsSymmetryElementGrouping[
								fullClass, 
								fns
								]
							],
					Missing["NotComputed"]
					],
			"Functions"->
				If[funcs,
					Association@
					KeyValueMap[
						#->
							If[#=!="InversionCenter",
								KeyMap[
									Replace[MapIndexed[#->#2[[1]]&, fullClass[#]]],
									#2
									],
								#2
								]&,
						fns
						],
					Missing["NotComputed"]
					]
			|>
		]


(* ::Subsubsection::Closed:: *)
(*orderCount*)



rotOrderCount[order_,axes_]:=
	Length@Select[axes, First@#==order&];
rotOrderCount[order_][axes_]:=
	rotOrderCount[order,axes];


(* ::Subsubsection::Closed:: *)
(*IdentifyPointGroup*)



ChemUtilsIdentifyPointGroup[
	center:{_?NumericQ,_?NumericQ,_?NumericQ},
	centerOfSymmetry:True|False:False,
	rotationAxesS:{{_Integer|\[Infinity],_List}...},
	symmetryPlanesS:{{_List,_List}...}:{},
	screwAxesS:{{_Integer|\[Infinity],_List}...}:{}
	]:=
	With[{
		rotationAxes=
			deleteDuplicateRotationAxes[
				Map[ReplacePart[#, 2->#[[2]]-center]&, rotationAxesS],
				$ChemSymmetryUniquenessThreshold
				],
		symmetryPlanes=
			deleteDuplicatePlanes[
				Map[Map[#-center&, #]&, symmetryPlanesS],
				$ChemSymmetryUniquenessThreshold
				],
		screwAxes=
			deleteDuplicateRotationAxes[
				Map[ReplacePart[#, 2->#[[2]]-center]&, screwAxesS], 
				$ChemSymmetryUniquenessThreshold
				]
		},
	If[AnyTrue[First/@rotationAxes,#==\[Infinity]&],
		(*Linear*)
		If[centerOfSymmetry,
			(*Inversion center*)
			"D\[Infinity]h",
			(*No inversion center*)
			"C\[Infinity]v"
			],
		(*Non-linear*)
		If[rotOrderCount[3, rotationAxes]>1,
			(*2+ unique C3 axes*)
			If[rotOrderCount[5,rotationAxes]>1,
				(*2+ unique C5 axes*)
				If[centerOfSymmetry,
					(*Inversion center*)
					"Ih",
					(*No inversion center*)
					"I"],
				(* <2 unique C5 axes*)
				If[rotOrderCount[4,rotationAxes]>1,
					(*2+ unique C4 axes*)
					If[centerOfSymmetry,
						(*Inversion center*)
						"Oh",
						(*No inversion center*)
						"O"],
					(* <2 unique C4 axes*)
					If[Length@symmetryPlanes>0,
						(*Has symmetry planes*)
						If[centerOfSymmetry,
							(*Inversion center*)
							"Th",
							(*No inversion center*)
							"Td"],
						(*No symmetry planes*)
						"T"
						]
					]
				],
			(* <2 unique C3 axes*)
			If[Length@rotationAxes>0,
				(*Any rotation axes*)
				With[{mAxes=MaximalBy[rotationAxes,First]},
				With[{n=First@First@mAxes,axes=Last/@mAxes},
				If[Length@Cases[rotationAxes,{2,_}]>=n,
					(*N distinct C2 axes*)
					If[anyPerpPlane[center, axes, symmetryPlanes],
						(*Horizontal reflection plane*)
						"D"<>ToString@n<>"h",
						If[Length@symmetryPlanes>=n,
							(*N+ planes of symmetry*)
							"D"<>ToString@n<>"d",
							(* <N planes of symmetry *)
							"D"<>ToString@n
							]
						],
					(* <N distinct C2 axes*)
					If[anyPerpPlane[center, axes, symmetryPlanes],
						(*Horizontal reflection plane*)
						"C"<>ToString@n<>"h",
						If[Length@symmetryPlanes>=n,
							(*N+ planes of symmetry*)
							"C"<>ToString@n<>"v",
							If[Length@Cases[screwAxes,{2*n,_}]>0,
								(*2N screw axis*)
								"S"<>ToString[2*n],
								"C"<>ToString@n
								]
							]
						]
					]
					]
					],
				(*No rotation axes*)
				If[Length@symmetryPlanes>0,
					"Cs",
					If[centerOfSymmetry,
						"Ci",
						"C1"
						]
					]
				]
			]
		]
	]


(* ::Subsubsection::Closed:: *)
(*PointGroup*)



ChemUtilsPointGroup[
	smels_Association
	]:=
	ChemUtilsIdentifyPointGroup@@
		Lookup[
			smels["Elements"],
			{
				"Center", 
				"CenterSymmetric",
				"RotationAxes",
				"SymmetryPlanes",
				"ScrewAxes"
				}
			];
Options[ChemUtilsPointGroup]=
	Options@ChemUtilsSymmetryElements;
ChemUtilsPointGroup[
	atoms:{{_String,__}..},
	ops:OptionsPattern[]
	]:=
	ChemUtilsPointGroup@
		ChemUtilsSymmetryElements[atoms, ops];


(* ::Subsubsection::Closed:: *)
(*Graphics*)



ChemUtilsSymmetryGraphicsObjects[
	symmEls_Association,
	boxSize_?NumericQ,
	OptionsPattern[]
	]:=
	With[{symm=symmEls["Elements"], m=boxSize, M=boxSize+.15},
		<|
			"InversionCenter"->
				If[symm["CenterSymmetric"],
					{Red,AbsolutePointSize@10,Point@symm["Center"]},
					{}
					],
			"RotationAxes"->
				{
					AbsoluteThickness[1],
					Map[
						With[{v=Normalize[Last@#-symm["Center"]]},
							Line@{symm["Center"]+v*M,symm["Center"]-v*M}
							]&,
						symm["RotationAxes"]
						]
					},
			"SymmetryPlanes"->
				Map[
					With[{n=Cross[symm["Center"]-First@#,symm["Center"]-Last@#],N=48},
						{
							Opacity[.25],
							Polygon@
								NestList[
									RotationTransform[2.\[Pi]/N,n,symm["Center"]],
									symm["Center"]+m*Normalize[symm["Center"]-First@#],
									N]
							}
						]&,
					symm["SymmetryPlanes"]
					],
			"ScrewAxes"->
				{
					Red,
					AbsoluteThickness[2],
					Dashed,
					Map[
						With[{v=Normalize[Last@#-symm["Center"]]},
							Line@{symm["Center"]+v*M,symm["Center"]-v*M}
							]&,
						symm["ScrewAxes"]	
						]
					}
			|>
		]


Options[ChemUtilsSymmetryGraphicsObjects]=
	Options[ChemUtilsSymmetryElements];
ChemUtilsSymmetryGraphicsObjects[
	atoms_?(Length[#]>=3&),
	ops:OptionsPattern[]
	]:=
	With[{
		symm=
			ChemUtilsSymmetryElements[atoms,
				"ReturnFunctions"->False,
				"DetermineClasses"->False,
				ops
				],
		m=.5+Max@
				Map[Abs,
					Thread@CoordinateBoundingBox[Last/@atoms]
					]},
		ChemUtilsSymmetryGraphicsObjects[symm,m]
		]


Options[ChemUtilsSymmetryGraphics]=
	Join[
		Options[Graphics3D],
		Options[ChemUtilsSymmetryGraphicsObjects]
		];
ChemUtilsSymmetryGraphics[
	symm_Association,
	boxSize_?NumericQ,
	types:
		"InversionCenter"|"RotationAxes"|"SymmetryPlanes"|"ScrewAxes"|
			{("InversionCenter"|"RotationAxes"|"SymmetryPlanes"|"ScrewAxes")..}:
		{"InversionCenter","RotationAxes","SymmetryPlanes","ScrewAxes"},
	ops:OptionsPattern[]
	]:=
	Graphics3D[
		Lookup[
			ChemUtilsSymmetryGraphicsObjects[symm,boxSize,
				Sequence@@FilterRules[{ops},Options@ChemUtilsSymmetryGraphicsObjects]
				],
			types
			],
		ops
		];
ChemUtilsSymmetryGraphics[
	atoms_List?(Length[#]>=3&),
	ops:OptionsPattern[]
	]:=
	With[{
		symm=ChemUtilsSymmetryElements@atoms,
		m=.5+Max@
				Map[Abs,
					Thread@CoordinateBoundingBox[Last/@atoms]
					]},
		ChemUtilsSymmetryGraphics[symm,m,ops]
		]
	


End[];



