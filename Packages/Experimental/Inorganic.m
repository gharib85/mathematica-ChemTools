(* ::Package:: *)

(************************************************************************)
(* This file was generated automatically by the Mathematica front end.  *)
(* It contains Initialization cells from a Notebook file, which         *)
(* typically will have the same name as this file except ending in      *)
(* ".nb" instead of ".m".                                               *)
(*                                                                      *)
(* This file is intended to be loaded into the Mathematica kernel using *)
(* the package loading commands Get or Needs.  Doing so is equivalent   *)
(* to using the Evaluate Initialization Cells menu command in the front *)
(* end.                                                                 *)
(*                                                                      *)
(* DO NOT EDIT THIS FILE.  This entire file is regenerated              *)
(* automatically each time the parent Notebook file is saved in the     *)
(* Mathematica front end.  Any changes you make to this file will be    *)
(* overwritten.                                                         *)
(************************************************************************)



CharacterTable::usage="Storage class for character table data";
CharacterTableData::usage="Looks up char table data";
CharacterTableSymmetryFunctions::usage=
	"Determines the functions that describe the symmetry classes";
CharacterTableRepresentationsList::usage=
	"";
CharacterTableRepresentationsGrid::usage=
	"Formats a grid for the reducible reps";
CharacterTableTotalRepresentation::usage=
	"Computes the total of a representation list";
CharacterTableReduceRepresentation::usage=
	"Reduces a reducible representation in a character table's irreps";
CharacterTableModeRepresentations::usage=
	"Represents the translational, vibrational, and rotational irreps";


Begin["`Private`"];


(*normalizeCTName[ct_]:=
	Replace[
		Capitalize@ToLowerCase@
			StringDelete[
				StringJoin@ReplaceAll[ct,Subscript|SubscriptBox\[Rule]List],
				Whitespace
				],
		HoldPattern[Capitalize[s_]]:>
			ToUpperCase[StringTake[s,1]]<>StringDrop[s,1]
		]*)


(*CharacterTableURL[ct_]:=
	Switch[ct,
		"T",
			"http://symmetry.jacobs-university.de/cgi-bin/group.cgi?group=900&option=4",
		"Th",
			"http://symmetry.jacobs-university.de/cgi-bin/group.cgi?group=901&option=4",
		"O",
			"http://symmetry.jacobs-university.de/cgi-bin/group.cgi?group=903&option=4",
		_,
			TemplateApply[
				"http://www.webqc.org/printable-symmetrypointgroup-ct-``.html",
				ToLowerCase@ct
				]
		]*)


(*CharacterTableRawData[ct_String?(StringContainsQ["/"])]:=
	If[StringStartsQ[ct, "http://www.webqc.org/"(*|"http://symmetry.jacobs-university.de"*)], 
		CharacterTableCleanRawData, 
		Identity
		]@
		Map[
			If[StringStartsQ[ct, "http://www.webqc.org/"|"http://symmetry.jacobs-university.de"],
				Map[
					StringDelete[
						StringJoin@
							System`Convert`HTMLImportDump`SymbolicXML2Text@#,
						Except["\n", Whitespace]
						]&,
					ReplaceAll[#[[3]],
						{
							XMLElement["img",{"src"\[Rule]"/pics/epsilon.gif"},{}]\[Rule]"\[CurlyEpsilon]",
							XMLElement["img",{"src"\[Rule]"/pics/sigma.gif"},{}]\[Rule]"\[Sigma]"
							}
						]
					]&,
				Identity
				],
			Cases[
						Import[ct,{"HTML","XMLObject"}],
						XMLElement["table", __],
						\[Infinity]
						][[
				Which[
					StringStartsQ[ct, "http://www.webqc.org/"],
						Sequence@@{2, 3},
					StringStartsQ[ct, "http://symmetry.jacobs-university.de"],
						Sequence@@{2, 3},
					True,
						All
					]
				]]
			];
CharacterTableRawData[ct_]:=
		CharacterTableRawData@CharacterTableURL@ct*)


(*CharacterTableCleanRawData[tdata_]:=
	Module[{
		trueTab=
			ConstantArray[None,
				Length@tdata+
					Length@Select[Rest@tdata, StringContainsQ["\n"][#[[2]]]&]
				],
		rowFillCounter=2,
		splitRow,
		boxLen=Length@tdata[[1]]
		},
		trueTab[[1]]=tdata[[1]];
		Map[
			If[StringContainsQ["\n"][#[[2]]],
				splitRow=StringSplit[#,"\n"]&/@#;
				With[{maxLen=Max@Append[Map[Length,splitRow],0]},
					Do[
						(* populate the final row *)
						trueTab[[rowFillCounter++]]=
							Map[
								(* check how many elements it has *)
								Switch[Length[#],
									maxLen,
										#[[i]],
									1,
										#[[1]]<>ToString[i],
									_,
										Null
									]&,
							Take[PadRight[splitRow, boxLen, ""], boxLen]
							],
						{i, maxLen}
						]
					],
				trueTab[[rowFillCounter++]]=
					PadRight[#, boxLen, ""]
				]&,
			Rest@tdata
			];
		trueTab
		]*)


(*If[!AssociationQ@$CharacterTables, $CharacterTables=<||>];
CharacterTableImport[ct_]:=
	With[{nm=normalizeCTName@ct},
		Lookup[$CharacterTables,nm,
			$CharacterTables[nm]=
				<|
					"PointGroup"\[Rule]nm,
					"SymmetryClasses"\[Rule]#[[1, 2;;Length[#] ]],
					"IrreducibleRepresentations"\[Rule]
						#[[2;;, 1 ]],
					"CharacterTable"->
						Map[Quiet[Check[ToExpression[#],#]]&, #[[2;;, 2;;Length[#] ]]],
					"Others"->
						AssociationThread[
							#[[1, 1+Length[#];; ]],
							Transpose@#[[2;;, 1+Length[#];; ]]
							]
					|>&@CharacterTableRawData@nm
			]
		]*)


CharacterTablePointGroupEnt[ct_]:=
	Entity["FiniteGroup",
		{
			"CrystallographicPointGroup", 
			$pointGroupMap@
				normalizeCTName@ct
			}
		]


$CharacterTableKeys=
	{
		"PointGroup",
		"SymmetryClasses",
		"IrreducibleRepresentations",
		"CharacterTable",
		"LinearFunctions",
		"NonLinearFunctions"
		};


$pointGroupEntityMap=
	<|
		"C1"->1,"Ci"->2,"C2"->3,"Cs"->4,"C2h"->5,"D2"->6,"C2v"->7,
		"D2h"->8,"C4"->9,"S4"->10,"C4h"->11,"D4"->12,"C4v"->13,
		"D2d"->14,"D4h"->15,"C3"->16,"S6"->17,"D3"->18,"C3v"->19,
	 "D3d"->20,"C6"->21,"C3h"->22,"C6h"->23,"D6"->24,"C6v"->25,
		"D3h"->26,"D6h"->27,"T"->28,"Th"->29,"O"->30,
		"Td"->31,"Oh"->32,"Ih"->"Icosahedral"
		|>;


$charTables=
	{
		"Cs","Ci","C1","C2","C3","C4","C5","C6","C7","C8",
		"D2","D3","D4","D5","D6",
		"C2h","C3h","C4h","C5h","C6h",
		"C2v","C3v","C4v","C5v","C6v","Civ",
		"D2d","D3d","D4d","D5d","D6d",
		"D2h","D3h","D4h","D5h","D6h","D8h","Dih",
		"S4","S6","S8",
		"T","Th","Td",
		"O","Oh",
		"I","Ih",
		"K","Kh"
		};


CharacterTableGrid[data_]:=
	Grid[
		Prepend[
			Prepend[
				data["SymmetryClasses"][[All, "Formatted"]],
				data["PointGroup", "Formatted"]
				]
			]@
		MapThread[
			Prepend,
			{
				data["CharacterTable"],
				data["IrreducibleRepresentations"][[All, "Formatted"]]
				}
			],
		Alignment->Right,
		Dividers->{{2->Black},{2->Black}}
		];


CharacterTable[data_Association][k__]:=
	data[k]
CharacterTable[pg_String]:=
	CharacterTable@$ChemCharacterTables[pg];
CharacterTable/:Normal[CharacterTable[data_Association]]:=
	data;
CharacterTable/:Part[CharacterTable[data_Association], i__]:=
	Replace[{i},{
		{s_String}:>
			CharacterTableData[CharacterTable@data,
				{"IrreducibleRepresentation", s},
				"Vector"
				],
		{s_String, e__}:>
			CharacterTableData[CharacterTable@data,
				{"IrreducibleRepresentation", s},
				"Vector"
				][[e]],
		_:>
			data["CharacterTable"][[i]]
		}];
CharacterTable/:Dataset[CharacterTable[data_Association]]:=
	Dataset@data;


Format[CharacterTable[data_Association]]:=
	RawBoxes@TemplateBox[
		ToBoxes/@{data, CharacterTableGrid[data]},
		"CharacterTable",
		InterpretationFunction:>
			Function[
				RowBox@{"CharacterTable","[",#,"]"}
				],
		DisplayFunction:>
			Function[
				StyleBox[
					RowBox@{
						"CharacterTable",
						"[",
						PanelBox[
							#2,
							Appearance->{
								"Default"->
									FrontEnd`FileName[{"Typeset", "SummaryBox"}, "Panel.9.png"]
								}
							],
						"]"
						},
					ShowStringCharacters->False
					]
				],
		Editable->False,
		Selectable->False
		];


charTabImportExcel[f_]:=
MapThread[
#->
Check[
DeleteCases[{"","",__,__Real?(FractionalPart[#]>0&),___}]@
Rest@SplitBy[#2,MatchQ[{""..}]][[3]],
$Failed
]&,
Rest/@
Import[f,
{"XLS",{"Sheets","Data"}}
]
]//Association;


(*Global`map=charTabImportExcel["~/Downloads/ed300281d_si_001.xls"];*)


charTabParsePG[pg_]:=
	With[{
		pgMain=
			First@
				StringReplace[StringReplace[pg,"i"->"\[Infinity]"],
					t:LetterCharacter~~
					n:(DigitCharacter...|"\[Infinity]")~~
					modifiers___:>
					<|
						"ID"->pg,
						"Type"->t,
						"Order"->
							If[StringLength[n]>0,
								ToExpression[n],
								None
								],
						"Modifier"->modifiers
						|>
					]
			},
		Append[pgMain,
			"Formatted"->
			Style[
				With[{
						t=pgMain["Type"],
						o=pgMain["Order"],
						m=pgMain["Modifier"]
						},
					If[o=!=None||StringLength[m]>0,
						Subscript[t,
							Row@{Replace[o,None:>Sequence@@{}],m}
							],
						t
						]
					],
				ShowStringCharacters->False
				]
			]
		]


charTabParseCl[cl_]:=
	Map[
		With[{
				coreData=
					First@
						StringReplace[#,
							{
								StartOfString~~(counts:DigitCharacter...)~~t:Except[DigitCharacter]~~
									n:(DigitCharacter...|"\[Infinity]")~~
										modifiers___~~EndOfString:>
								<|
								"Type"->t,
								"ID"->#,
								"Order"->
									If[StringLength@n>0,
										ToExpression@
											If[StringLength@n>1&&StringTake[n, {-1}]=!="0",
												StringTake[n,{1, -2}],
												n
												],
										1
										],
								"Degree"->
									If[StringLength@n>1&&StringTake[n, {-1}]=!="0",
										ToExpression@StringTake[n,{-1}],
										1
										],
								"Count"->
									If[StringLength@counts>0,
										ToExpression[counts],
										1
										],
								"Orientation"->
									If[StringStartsQ[modifiers, ("h"|"v"|"d")],
										StringTake[modifiers, {1}],
										""
										],
								"Modifier"->
									If[StringMatchQ[modifiers,"(=*"],
										"",
										If[StringStartsQ[modifiers, ("h"|"v"|"d")],
											StringTake[modifiers, {2,-1}],
											modifiers
											]
										]
								|>
								}
							]
				},
			Append[coreData,
				"Formatted"->
					Style[
						Row@{
							coreData["Count"]*
							Replace[
								{
									Replace[coreData["Orientation"],
										""->coreData["Order"]
										],
									coreData["Degree"]
									},
								{
									{1,1}:>coreData["Type"],
									{1,n_}:>Superscript[coreData["Type"],n],
									{n_,1}:>Subscript[coreData["Type"],n],
									{n_,m_}:>Superscript[Subscript[coreData["Type"],n],m]
									}
								],
							coreData["Modifier"]
							},
						ShowStringCharacters->False
						]
				]
			]&,
		cl
		]


charTabParseIR[ir_]:=
	Map[
		With[{
				coreData=
					First@
						StringReplace[#,
							{
								t:Except[DigitCharacter]~~
								index:(DigitCharacter...|"\[Infinity]")~~
								parity:"g"|"u"|""~~
								modifiers___:>
								<|
									"ID"->#,
									"Type"->t,
									"Index"->
									If[StringLength@index>0,
										ToExpression@index,
										0
										],
									"Parity"->parity,
									"Modifier"->modifiers
									|>
								}
							]
				},
			Append[coreData,
				"Formatted"->
					Style[
						Row@{
							Replace[
								{
									coreData["Index"],
									coreData["Parity"]
									},
								{
									{0,""}:>coreData["Type"],
									{0,n_}:>Subscript[coreData["Type"],n],
									{n_,0}:>Subscript[coreData["Type"],n],
									{n_,m_}:>Subscript[coreData["Type"],Row@{n,m}]
									}
								],
							coreData["Modifier"]
							},
						ShowStringCharacters->False
						]
				]
			]&,
		ir
		]


charTabParseCT[pgData_, ct_, cl_]:=
	Quiet@
		Map[
			Map[
				If[StringQ@#,
					Replace[
						With[{clean=
							FixedPoint[
								StringReplace[{
										"\.bd"->"(1/2)",
										"\[CurlyEpsilon]":>TemplateApply["Exp[2*Pi*I/``]",pgData["Order"]],
										"*"->"\[Conjugate]",
										"cos"~~arg:Except["+"]..:>
											"Cos["<>arg<>"]",
										"\[CapitalPhi]"->"\[FormalCapitalPhi]"
										}],
								#
								]
							},
							Check[
								ToExpression@clean,
								Echo[clean]
								]
							],
						r_?NumberQ:>IntegerPart[r]
						],
					If[NumberQ[#],
						IntegerPart@#,
						#
						]
					]&
				],
			 ct[[2;;, 4;;UpTo[3+Length@ cl]]]
			]


charTabParseLFs[ct_, cl_]:=
	Map[
		DeleteCases[Null]@
		Map[
			Replace[{
				l:{__String}:>
					Quiet[Check[ToExpression[If[Length@l>1,l,l[[1]]]],Print[l]]]
				}]
			]@
		StringSplit[
			StringTrim[
				StringReplace[
					StringReplace[#,{
						"Rx"->"\[FormalCapitalR][\[FormalX]]",
						"Ry"->"\[FormalCapitalR][\[FormalY]]",
						"Rz"->"\[FormalCapitalR][\[FormalZ]]",
						"x"->" \[FormalX]",
						"y"->" \[FormalY]",
						"z"->" \[FormalZ]"
						}],{
					e:Except[WhitespaceCharacter|"+"|"("]~~"2":>e<>"^2"
					}],
				((Whitespace|"")~~("("|")")~~(Whitespace|""))
				],
			","
			]&
		]@
	StringCases[
		Map[
			If[Length[#]>3+Length@ cl,
				#[[3+Length@ cl+1]],
				""
				]&,
			Rest@ct
			],
		s:Shortest[("("~~__~~")")|(__~~(","|EndOfString))]:>
			StringTrim[s,","]
		]


charTabParseNLFs[ct_, cl_]:=
	Map[
		DeleteCases[Null]@
		Map[
			Replace[{
				l:{__}:>
					Quiet[Check[ToExpression[If[Length@l>1,l,l[[1]]]],Print[l]]]
				}]
			]@
		StringSplit[
			StringTrim[
				StringReplace[
					StringReplace[#,{
						"Rx"->"\[FormalCapitalR][\[FormalX]]",
						"Ry"->"\[FormalCapitalR][\[FormalY]]",
						"Rz"->"\[FormalCapitalR][\[FormalZ]]",
						"x"->" \[FormalX]",
						"y"->" \[FormalY]",
						"z"->" \[FormalZ]"
						}],{
					e:Except[WhitespaceCharacter|"+"|"("]~~"2":>e<>"^2"
					}],
				((Whitespace|"")~~("("|")")~~(Whitespace|""))
				],
			","
			]&
		]@
	StringCases[
		Map[
			If[Length[#]>3+Length@cl+1,
				#[[3+Length@cl+2]],
				""
				]&,
			Rest@ct
			],
		s:Shortest[("("~~__~~")")|(__~~(","|EndOfString))]:>
			StringTrim[s,","]
		]


charTabExcelClean[ds_]:=
	Map[
		Check[
			With[{
				ct=#,
				pg=#[[1,3]],
				pgData=charTabParsePG[#[[1,3]]],
				cl=
					TakeWhile[#[[1,4;;]],
						#=!=""&
						],
				ir=
					With[{i=#[[2;;, 3 ]]},
						ReplacePart[i,
							Map[
								#[[1]]->i[[#[[1]]-1]]&,
								Position[i,""]
								]
							]
						]
				},
				<|
				"PointGroup"->
					pgData,
				"SymmetryClasses"->
					charTabParseCl[cl],
				"IrreducibleRepresentations"->
					charTabParseIR[ir],
				"CharacterTable"->
					charTabParseCT[pgData, ct, cl],
				"LinearFunctions"->
					charTabParseLFs[ct, cl],
				"NonLinearFunctions"->
					charTabParseNLFs[ct, cl]
					|>
				],
			<||>
			]&,
		ds
		];


(*Global`ctabs=charTabExcelClean[Global`map];*)


CharacterTableData[ct_String]:=
	CharacterTable[ct];
CharacterTableData[ct_CharacterTable]:=
	ct;
CharacterTableData[ct:_String|_CharacterTable,
	prop:Alternatives@@$CharacterTableKeys
	]:=
	CharacterTableData[ct][prop];
CharacterTableData[ct:_String|_CharacterTable,
	{"IrreducibleRepresentation"|"IR", irrep:_String|_Integer}
	]:=
	With[{coredata=CharacterTableData[ct]},
		With[{irpos=
			Switch[irrep,
				_Integer,
					irrep,
				_String,
					FirstPosition[
						coredata["IrreducibleRepresentations"][[All, "ID"]], 
						irrep,
						$Failed
						][[1]],
				_,
					$Failed
				]
			},
			<|
				"PointGroup"->coredata["PointGroup"],
				"Data"->
					coredata["IrreducibleRepresentations"][[irpos]],
				"Vector"->
					coredata["CharacterTable"][[irpos]],
				"LinearFunctions"->
					coredata["LinearFunctions"][[irpos]],
				"NonLinearFunctions"->
					coredata["NonLinearFunctions"][[irpos]]
				|>/;Length[coredata["IrreducibleRepresentations"]]>=irpos
			]
		];
CharacterTableData[ct:_String|_CharacterTable,
	{"SymmetryClass"|"SC", sc:_String|_Integer}
	]:=
	With[{coredata=CharacterTableData[ct]},
		With[{scpos=
			Switch[sc,
				_Integer,
					sc,
				_String,
					FirstPosition[
						coredata["SymmetryClasses"][[All, "ID"]], 
						sc,
						$Failed
						][[1]],
				_,
					$Failed
				]
			},
			<|
				"PointGroup"->
					coredata["PointGroup"],
				"Data"->
					coredata["SymmetryClasses"][[scpos]],
				"Vector"->
					coredata["CharacterTable"][[scpos]]
				|>/;Length[coredata["SymmetryClasses"]]>=scpos
			]
		];


$CharacterTableThingProps=
	{
		"PointGroup",
		"Vector",
		"SymmetryClass",
		"IrreducibleRepresentation",
		"Data",
		"LinearFunctions",
		"NonLinearFunctions"
		};
CharacterTableData[ct:_String|_CharacterTable,
	{p:"IrreducibleRepresentation"|"IR"|"SymmetryClass"|"SC", thing:_String|_Integer},
	prop:Alternatives@@$CharacterTableThingProps|
		{Alternatives@@$CharacterTableThingProps,__String}
	]:=
	With[{base=CharacterTableData[ct, {p, thing}]},
		base@@Flatten[{prop}]/;AssociationQ@base
		]


PackageAddAutocompletions["CharacterTableData",
	{
		$charTables, 
		Join[$CharacterTableKeys, 
			{"SymmetryClass", "IrreducibleRepresentation"}
			],
		$CharacterTableThingProps
		}
	]


CharacterTableSymmetryFunctions[ct_, sops_]:=
	Module[{
		rots=sops["RotationAxes"],
		planes=sops["SymmetryPlanes"],
		screws=sops["ScrewAxes"],
		center=sops["Center"],
		primaryAxis,
		ind,
		cur
		},
		primaryAxis=
			MaximalBy[
				MaximalBy[rots, First][[All, 2]],
				#[[3]]&
				][[1]];
		AssociationMap[
			Switch[#["Type"],
				"E",
					Identity,
				"i",
					Minus,
				"C",
						ind=
							FirstPosition[rots, 
								{
									#["Order"]*#["Degree"], 
									Which[
										StringContainsQ[#["Modifier"],"x"],
											{_?(Abs[#]>.001&), __?(Abs[#]<.001&)},
										StringContainsQ[#["Modifier"],"y"],
											{_?(Abs[#]<.001&),_?(Abs[#]>.001&),_?(Abs[#]<.001&)},
										StringContainsQ[#["Modifier"],"z"],
											{__?(Abs[#]<.001&),_?(Abs[#]>.001&)},
										True,
											_
										]
									}, 
								$Failed
								][[1]];
						cur=rots[[ind]];
						rots=Delete[rots,ind];
						RotationTransform[2.\[Pi]/cur[[1]], cur[[2]], center],
				"\[Sigma]",
						Switch[{#["Orientation"], #["Modifier"]},
							{_, _?(StringContainsQ["xy"])},
								ind=
									FirstPosition[planes,	
										{Repeated[{_,_,_?(Abs[#]<.0001&)}, {2}]},
										{1}
										][[1]],
							{_, _?(StringContainsQ["xz"])},
								ind=
									FirstPosition[planes,	
										{Repeated[{_,_?(Abs[#]<.0001&),_}, {2}]},
										{1}
										][[1]],
							{_, _?(StringContainsQ["yz"])},
								ind=
									FirstPosition[planes,	
										{Repeated[{_?(Abs[#]<.0001&),_,_}, {2}]},
										{1}
										][[1]],
							{"h"|"d", _},
								ind=
									FirstPosition[planes,	
										{pt1:{_,_,_}, pt2_}/;\[Pi]/1.8>VectorAngle[
											primaryAxis, 
											Cross[pt1-center, pt2-center]
											]>\[Pi]/2.2,
										{1}
										][[1]],
							_,
								ind=
									FirstPosition[planes,	
										{pt1:{_,_,_}, pt2_}/;.1\[Pi]>VectorAngle[
											primaryAxis, 
											Cross[pt1-center, pt2-center]
											],
										{1}
										][[1]]
							];
						cur=planes[[ind]];
						planes=Delete[planes,ind];
						ReflectionTransform[
							Cross[cur[[1]]-center, cur[[2]]-center],
							center
							],
				"S",
					ind=
							FirstPosition[screws, 
								{
									#["Order"]*#["Degree"], 
									Which[
										StringContainsQ[#["Modifier"],"x"],
											{_?(Abs[#]>.001&), __?(Abs[#]<.001&)},
										StringContainsQ[#["Modifier"],"y"],
											{_?(Abs[#]<.001&),_?(Abs[#]>.001&),_?(Abs[#]<.001&)},
										StringContainsQ[#["Modifier"],"z"],
											{__?(Abs[#]<.001&),_?(Abs[#]>.001&)},
										True,
											_
										]
									}, 
								$Failed
								][[1]];
						cur=screws[[ind]];
						screws=Delete[rots,ind];
						Composition[
							RotationTransform[2.\[Pi]/cur[[1]], cur[[2]], center],
							ReflectionTransform[cur[[2]], center]
							]//Simplify
				]&,
			ct["SymmetryClasses"]
			]
		]


charTableTransfCloseEnough[transfed_, v_]:=
	TrueQ[
		transfed==v||
			Apply[And,
				MapThread[
					#-.001<=#2<=#+.001&,
					{
						transfed,
						v
						}
					]
				]
		];


CharacterTableRepresentationsList//Clear


CharacterTableRepresentationsList[
	mapping_Association?(Not@*KeyMemberQ["Center"]),
	coordsAndVecs:{({_,_,_}->{{_,_,_}..})..}
	]:=
	GroupBy[First->Last]@
	Flatten@
	Table[
		Table[
			v[[1]]->
				Table[
					With[{newpt=m[v[[1]]], newdir=m[i]},
						Which[
							!charTableTransfCloseEnough[v[[1]],newpt],
								0,
							charTableTransfCloseEnough[i, newdir],
								1,
							charTableTransfCloseEnough[i, -newdir],
							 -1, 
							True, 
								0
							]
						],
					{m, mapping}
					],
			{i, v[[2]]}
			],
		{v, coordsAndVecs}
		];
CharacterTableRepresentationsList[
	mapping_Association?(Not@*KeyMemberQ["Center"]),
	coords:{{_,_,_}..},
	vecs:{{_,_,_}..}:IdentityMatrix[3]
	]:=
	CharacterTableRepresentationsList[mapping,
		Map[#->vecs&, coords]
		];
CharacterTableRepresentationsList[
	ct_, 
	sops_Association?(KeyMemberQ["Center"]),
	coords:{{_,_,_}..},
	coordinateVectors:{{_,_,_}..}:IdentityMatrix[3]
	]:=
	CharacterTableRepresentationsList[
		CharacterTableSymmetryFunctions[ct, sops],
		coords,
		coordinateVectors
		];
CharacterTableRepresentationsList[
	ct_, 
	sops_Association?(KeyMemberQ["Center"]),
	coordsAndVecs:{({_,_,_}->{{_,_,_}..})..}
	]:=
	CharacterTableRepresentationsList[
		CharacterTableSymmetryFunctions[ct, sops],
		coordsAndVecs
		];


CharacterTableReducibleRepresentationsGrid//Clear


CharacterTableReducibleRepresentationsGrid[
	ct_,
	gamma_Association?(AllTrue[ListQ]@*Keys),
	labels:{__String}:{"x","y","z"}
	]:=
	With[{grid=
		Panel@
			With[{
				core=
					MapIndexed[
						With[{l=#, num=ToString@First@#2},
							MapThread[
								Prepend[#,
									Subscript[#2,num]
									]&,
								{
									l,
									Take[
										Join@@ConstantArray[labels, Length@l],
										Length@l
										]
									}]
							]&,
						Values@KeyDrop[gamma, Key@{"Grid"}]
						]
				},
				Style[
					Grid[
						Prepend[
							Flatten[core,1],
							Prepend[ct["SymmetryClasses"][[All,"Formatted"]], ""]
							]
						],
					ShowStringCharacters->False
					]
				]
		},
	Interpretation[
		grid,
		Append[gamma, {"Grid"}->grid]
		]
	];
CharacterTableReducibleRepresentationsGrid[
	ct_,
	fmapping_Association?(Not@*KeyMemberQ["Center"]),
	coordAndVecs:{({_,_,_}->{{_,_,_}..})..},
	labels:{__String}:{"x","y","z"}
	]:=
	CharacterTableReducibleRepresentationsGrid[
		ct,
		CharacterTableRepresentationsList[
			fmapping,
			coordAndVecs
			],
		labels
		];
CharacterTableReducibleRepresentationsGrid[
	ct_,
	fmapping_Association?(Not@*KeyMemberQ["Center"]),
	coords:{{___?NumericQ}..},
	coordVecs:{{_,_,_}..}:IdentityMatrix[3],
	labels:{__String}:{"x","y","z"}
	]:=
	CharacterTableReducibleRepresentationsGrid[
		ct,
		CharacterTableRepresentationsList[
			fmapping,
			coords, 
			coordVecs
			],
		labels
		];
CharacterTableReducibleRepresentationsGrid[
	ct_,
	symOps_Association?(KeyMemberQ["Center"]),
	coordAndVecs:{({_,_,_}->{{_,_,_}..})..},
	labels:{__String}:{"x","y","z"}
	]:=
	CharacterTableReducibleRepresentationsGrid[
		ct,
		CharacterTableRepresentationsList[
			CharacterTableSymmetryFunctions[ct, symOps],
			coordAndVecs
			],
		labels
		];
CharacterTableReducibleRepresentationsGrid[
	ct_,
	symOps_Association?(KeyMemberQ["Center"]),
	coords:{{___?NumericQ}..},
	coordVecs:{{_,_,_}..}:IdentityMatrix[3],
	labels:{__String}:{"x","y","z"}
	]:=
	CharacterTableReducibleRepresentationsGrid[
		ct,
		CharacterTableRepresentationsList[
			CharacterTableSymmetryFunctions[ct, symOps],
			coords,
			coordVecs
			],
		labels
		];


CharacterTableTotalRepresentation//Clear


CharacterTableTotalRepresentation[
	gamma_Association
	]:=
	Transpose[Join@@Values[gamma]]//Map[Total];
CharacterTableTotalRepresentation[
	fmapping_Association?(Not@*KeyMemberQ["Center"]),
	coordVecs:{({_,_,_}->{{_,_,_}..})..}
	]:=
	CharacterTableTotalRepresentation@
		CharacterTableRepresentationsList[fmapping, coordVecs];
CharacterTableTotalRepresentation[
	fmapping_Association?(Not@*KeyMemberQ["Center"]),
	coords_List,
	coordVecs:{{_,_,_}..}:IdentityMatrix[3]
	]:=
	CharacterTableTotalRepresentation@
		CharacterTableRepresentationsList[fmapping, coords, coordVecs];
CharacterTableTotalRepresentation[
	ct_,
	symOps_Association?(KeyMemberQ["Center"]),
	coordVecs:{({_,_,_}->{{_,_,_}..})..}
	]:=
	CharacterTableTotalRepresentation[ct,
		CharacterTableSymmetryFunctions[ct, symOps],
		coordVecs
		];
CharacterTableTotalRepresentation[
	ct_,
	symOps_Association?(KeyMemberQ["Center"]),
	coords_List,
	coordVecs:{{_,_,_}..}:IdentityMatrix[3]
	]:=
	CharacterTableTotalRepresentation[ct,
		CharacterTableSymmetryFunctions[ct, symOps],
		coords,
		coordVecs
		];


CharacterTableReduceRepresentationCoefficients[
	ctRows_List,
	symmClassCounts_,
	red_
	]:=
	(1/Total[symmClassCounts])*
		Map[
			Total@
				MapThread[
					Times,
					{
						symmClassCounts,
						red,
						#
						}
					]&,
			ctRows
			];
CharacterTableReduceRepresentation[ct_CharacterTable, rep_]:=
	With[
		{
			characterRows=
				CharacterTableData[ct, "CharacterTable"],
			symmClassCounts=
				Lookup[CharacterTableData[ct, "SymmetryClasses"], "Count"],
			irreps=
				CharacterTableData[ct,"IrreducibleRepresentations"]
			},
		AssociationThread[
			irreps,
			CharacterTableReduceRepresentationCoefficients[
				characterRows,
				symmClassCounts,
				rep
				]
			]
		];


CharacterTableModeRepresentations[
	ct_,
	totalNuclearRep_Association
	]:=
	Module[
		{
			translations,
			rotations,
			vibrations
			},
		translations=
			Pick[
				Keys@totalNuclearRep, 
				MemberQ[\[FormalX]|\[FormalY]|\[FormalZ]]/@CharacterTableData[ct,"LinearFunctions"]
				];
		rotations=
			Pick[
				Keys@totalNuclearRep, 
				MemberQ[\[FormalCapitalR][\[FormalX]]|\[FormalCapitalR][\[FormalY]]|\[FormalCapitalR][\[FormalZ]]]/@CharacterTableData[ct,"LinearFunctions"]
				];
		vibrations=
			Association@
				KeyValueMap[
					#->
						If[MemberQ[Join[translations,rotations],#],
							#2-1,
							#2
							]&,
					totalNuclearRep
					];
		<|
			"Translations"->	
				AssociationMap[1&, translations],
			"Rotations"->
				AssociationMap[1&, rotations],
			"Vibrations"->
				vibrations
			|>
		];
CharacterTableModeRepresentations[
	ct_,
	redRep:{__Integer}
	]:=
	CharacterTableModeRepresentations[ct,
		CharacterTableReduceRepresentation[
			ct,
			redRep
			]
		];
CharacterTableModeRepresentations[
	ct_,
	fmapping_Association?(Not@*KeyMemberQ["Center"]),
	coords_List,
	coordVecs:{{_, _, _}...}:IdentityMatrix[3]
	]:=
	CharacterTableModeRepresentations[ct,
		CharacterTableReduceRepresentation[
			ct,
			CharacterTableTotalNuclearRepresentation[ct,
				fmapping,
				coords,
				coordVecs
				]
			]
		];


End[];



