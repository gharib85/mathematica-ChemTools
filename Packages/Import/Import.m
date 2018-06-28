(* ::Package:: *)



ChemImportXYZ::usage="Imports XYZ data";
ChemImportMolTable::usage="Imports MolTable data";
ChemImportZMatrix::usage="Imports ZMatrix data";
ChemImportGraphics::usage="Imports Graphics data";
ChemImportChemicalStructure::usage="Attempts to import a structure";


Begin["`Private`"];


(* ::Subsection:: *)
(*String Patterns*)



ZMatrixStringPattern1=
	((StartOfLine|Whitespace)~~LetterCharacter..~~(Whitespace|EndOfLine));
ZMatrixStringPattern2=
	((StartOfLine|Whitespace)~~LetterCharacter..~~Whitespace~~
		(DigitCharacter..)~~Whitespace~~NumberString~~(Whitespace|EndOfLine));
ZMatrixStringPattern3=
	((StartOfLine|Whitespace)~~LetterCharacter..~~Whitespace~~
		(DigitCharacter..)~~Whitespace~~NumberString~~Whitespace~~
		(DigitCharacter..)~~Whitespace~~NumberString~~(Whitespace|EndOfLine));
ZMatrixStringPattern4=
	((StartOfLine|Whitespace)~~LetterCharacter..~~Whitespace~~
		(DigitCharacter..)~~Whitespace~~NumberString~~Whitespace~~
		(DigitCharacter..)~~Whitespace~~NumberString~~Whitespace~~
		(DigitCharacter..)~~Whitespace~~NumberString~~(Whitespace|EndOfLine));


ChemDataZMatrixStringPattern=
	ZMatrixStringPattern1|
	(ZMatrixStringPattern1~~ZMatrixStringPattern2)|
	(ZMatrixStringPattern1~~ZMatrixStringPattern2~~ZMatrixStringPattern3)|
	(ZMatrixStringPattern1~~ZMatrixStringPattern2~~
		ZMatrixStringPattern3~~(ZMatrixStringPattern4..));


MolTableLineStringPattern1=
	(StartOfLine|Whitespace)~~LetterCharacter..~~
		Whitespace~~NumberString~~
		Whitespace~~NumberString~~
		Whitespace~~NumberString;
MolTableLineStringPattern2=
	(
		(StartOfLine|Whitespace)~~NumberString~~
		Whitespace?(Not@*StringContainsQ["\n"])~~NumberString~~
		Whitespace?(Not@*StringContainsQ["\n"])~~NumberString~~
		Whitespace?(Not@*StringContainsQ["\n"])~~LetterCharacter..~~
		Except["\n"]..
		);


ChemDataMolTableStringPattern=
	(
		((MolTableLineStringPattern1~~(Whitespace|"")~~EndOfLine)..)|
		((MolTableLineStringPattern2~~(Whitespace|"")~~EndOfLine)..)
		);


BondLineStringPattern=
	(
		(StartOfLine|Whitespace)~~DigitCharacter..~~
			Whitespace~~DigitCharacter..~~(Except["\n"]...)
		);


ChemDataBondBlockStringPattern=
	(BondLineStringPattern~~EndOfLine)..;


(* ::Subsection:: *)
(*XYZ*)



(* ::Subsubsection::Closed:: *)
(*chemProcessXYZData*)



chemProcessXYZData[{types_, coords_}]:=
	With[{s=ChemDataLookup[types, "Symbol"]},
		If[AllTrue[s, StringQ],
			{Prepend[Thread[{s, coords/100}], {Length@coords, 0}]},
			PackageRaiseException[
				"XYZImport", 
				"Bad XYZ atom labels ``",
				"MessageParameters"->{types}
				]
			]
		];


chemProcessXYZData[data_]:=
	PackageRaiseException[
		"XYZImport",
		"Malformatted XYZ import ``",
		"MessageParameters"->data
		]


(* ::Subsubsection::Closed:: *)
(*ChemImportXYZ*)



ChemImportXYZ[s:_String?FileExistsQ|_InputStream|_File|_URL, ops:OptionsPattern[]]:=
	PackageExceptionBlock["XYZImport"]@
	chemProcessXYZData@
		Import[
			s,
			{"XYZ", {"VertexTypes", "VertexCoordinates"}}
			];
ChemImportXYZ[s:_String, ops:OptionsPattern[]]:=
	ChemImportXYZ[StringToStream@s];


(* ::Subsection:: *)
(*ZMatrix*)



(* ::Subsubsection::Closed:: *)
(*iChemImportZMatrix*)



iChemImportZMatrix//Clear


iChemImportZMatrix[table:{__List}]:=
	Module[
		{
			chunks=
				Join@@@
					Partition[
						SplitBy[table, MatchQ@{_String}],
						2
						],
			lines,
			a,
			b,
			inDeg
			},
		Table[
			lines=
				Cases[t, {_String, ___}];
			inDeg=
				MemberQ[
					lines, 
					{_, _Integer, _, _Integer, _?(TrueQ[#>2\[Pi]||#<-\[Pi]]&), ___}
					]||
					MemberQ[
						lines, 
						{_, _Integer, _, _Integer, _, _Integer, _?(TrueQ[#>2\[Pi]||#<-\[Pi]]&), ___}
						];
			a=
				ChemFormatsZMatrixToMol@
					If[inDeg,
						Replace[
							lines,
							{
								{s_, i_Integer, r_, j_Integer, ang_?NumericQ}:>
									{s, i, r, j, ang*Degree},
								{s_, i_Integer, r_, j_Integer, ang_, k_Integer, d_, ___}:>
									{s, i, r, 
										j, ang*Degree, 
										k, d*Degree
										}
								},
							1
							],
						lines
						];
				b=Cases[t,{_Integer,_Integer,_Integer}|{_Integer,_Integer}];
				Join[
					{{Length@a,Length@b}},
					a,
					b
					],
			{t,chunks}
			]
		];


(* ::Subsubsection::Closed:: *)
(*ChemImportZMatrix*)



ChemImportZMatrix[s_String?(Not@*FileExistsQ), ops:OptionsPattern[]]:=
	With[{strings=If[Length[#]==1, #[[1]], #]&@ChemFormatsEnumerateZMatrixStrings@s},
		If[StringQ@strings, 
			iChemImportZMatrix@ImportString[strings, "Table"],
			Flatten[Map[iChemImportZMatrix@ImportString[#, "Table"]&, strings], 1]
			]
		];
ChemImportZMatrix[
	file:_String?FileExistsQ|_InputStream|_File|_URL,
	ops:OptionsPattern[]
	]:=
	ChemImportZMatrix@ReadString[file];


(* ::Subsection:: *)
(*MolTable*)



(* ::Subsubsection::Closed:: *)
(*ChemImportMolTable*)



ChemImportMolTable[string_String?(Not@*FileExistsQ), ops:OptionsPattern[]]:=
	ChemImportMolTableString/@
		Select[
			StringSplit[string,
				"$$$$"
				],
			StringContainsQ["V2000"|"V3000"]
			];
ChemImportMolTable[stream_InputStream, ops:OptionsPattern[]]:=
	ChemImportMolTable@ReadString[stream];
ChemImportMolTable[l_List]:=
	ChemImportMolTableList/@
		DeleteCases[{"$$$$"}]@
			Split[
				l,
				MatchQ[{"$$$$"}]
				];


(* ::Subsubsection::Closed:: *)
(*chemMolImportAtoms*)



chemMolImportAtoms[stringChunks:{__String}]:=
	With[{chunks=
		StringTake[stringChunks,{
			{1,10},(*Positions*)
			{11,20},
			{21,30},
			{31,34}(*Element*)(*
			{34,-1}(*Rest*)*)
			}]
		},
		{
			StringTrim@#[[4]],
			ToExpression@Take[#,3]
			(*,
			ImportString[#[[5]],"Table"]*)
			}&/@chunks
		];


(* ::Subsubsection::Closed:: *)
(*chemMolImportBonds*)



chemMolImportBonds[stringChunks:{__String}]:=
	With[{chunks=
		StringTake[stringChunks,{
			{1,3},
			{4,6},
			{7,9}(*,
			{10,-1}*)
			}]
		},
		ToExpression@chunks[[All,;;3]]
		];


(* ::Subsubsection::Closed:: *)
(*ChemImportMolTableString*)



ChemImportMolTableString//Clear


basicDigitPattern=
	(
		("  "~~DigitCharacter)|
		(" "~~DigitCharacter)|
		DigitCharacter
		);
ChemImportMolTableString[s_String?(StringContainsQ["\n"])]:=
	PackageExceptionBlock["ImportMolTable"]@
		With[{blockChunks=
			Join[
				StringCases[
					s,{
					StartOfString~~id:(Except["\n"]..):>
						{"Props","ID"->id},
					StartOfString~~(Except["\n"]..)~~"\n"~~
						"  "~~name:(Except["\n"]..):>
						{"Props","IDTag"->name},
					(StartOfLine~~nums:((basicDigitPattern)~~
						(Except["\n"]..))~~("V2000"|"V3000")):>
						{"Numbers",ToExpression@StringTake[nums,{{1,3},{4,6}}]},
					(
						"> <"~~prop:Except[">"]..~~">"~~val:Except["<"]..~~"\n\n":>	
							RuleCondition[
								{"Props",
									StringJoin@
										(
											(
												Switch[#,
													(*
											Replace isn't capturing the variable appropriately here for 
											who knows what reason
											*)
													"pubchem",
														Nothing,
													"id",
														"ID",
													"rmsd",
														"RMSD",
													"cid",
														"CID",
													"mmff94",
														"MMFF94",
													"sid",
														"SID",
													_,
														ToUpperCase[StringTake[#,1]]<>
															StringTake[#,{2,-1}]
													]
												)&/@ToLowerCase@StringSplit[prop,"_"]
											)->
											Replace[
												DeleteCases[{}]@ImportString[val,"Table"],{
												{{i_}}:>i,
												l:{{_}..}:>Flatten[l]
												}]
										},
								True
								]
						)
					}],
				StringCases[
					StringSplit[s,
						(StartOfLine~~((basicDigitPattern)~~
							(Except["\n"]..))~~("V2000"|"V3000"))|
						"M "
						][[2]],{
					l:(StartOfLine~~("  -"|"   ")~~Except["\n"]..~~"\n"):>
						If[StringLength@l>=30,
							{"Atoms",l},
							l
							],
					l:(
						StartOfLine~~(
							("  "~~DigitCharacter)|
							(" "~~DigitCharacter)|
							DigitCharacter
							)~~Except["\n"]..~~"\n"):>
							If[StringLength@l>=9,
								{"Bonds",l},
								l
								]
					}]
				]},
				With[{data=KeySort@GroupBy[blockChunks,First->Last]},
					If[Length@Lookup[data, "Atoms", {}]==0,
						PackageRaiseException["ImportMolTable",
							"MolTable requires at least one atom"
							];
						];
					{
						Join[
							data["Numbers"],
							chemMolImportAtoms[Lookup[data, "Atoms", {}]],
							Replace[Lookup[data, "Bonds", {}],
								l:{__}:>chemMolImportBonds[l]
								]
							],
						Lookup[data, "Props", {}]
						}
					]
			];(*
ChemImportMolTableString[s_String?(
		Not@FileExistsQ@#&&
		Not@StringContainsQ[#,"\n"|$PathnameSeparator]
		&)]:=
	Replace[ChemImportChemicalStructure[s, Identity],
		r_String:>ChemImportMolTableString[s]
		];*)


(* ::Subsubsection::Closed:: *)
(*ChemImportMolTableList*)



ChemImportMolTable::molst="Unable to find beginning of MolTable block";
ChemImportMolTableList[table_List]:=
	Block[{$atomBondCount={\[Infinity],\[Infinity]}},
		Replace[
			Reap[
				Replace[table,{
					{atomCount_,bondCount_,___,"V2000"|"V3000"}:>
						With[{ab=
							If[atomCount>999,
								FromDigits/@
									Partition[IntegerDigits@atomCount,UpTo[3]],
								{atomCount,bondCount}
								]
							},
							Sow@"START";
							Sow@ab
							],
					{crd1_Real,crd2_Real,crd3_Real,elm_String,massDifference_,
						charge_,hCount_,stereoFlag_,hCount2_,__,
						aMap_,invRet_,exactChg_}:>
						Sow@{elm,{crd1,crd2,crd3}},
					{atom1_Integer,atom2_Integer,bondType_Integer,otherShit___}:>
						Sow@
							If[atom1>999,
								Append[
									With[{try1=
										FromDigits/@
											Partition[IntegerDigits@atom1,UpTo[3]]
										},
										If[AnyTrue[try1,#>First@$atomBondCount&],
											FromDigits@*Reverse/@
												Partition[Reverse@IntegerDigits@atom1,
													UpTo[3]]
											]
										],
									atom2
									],
								{atom1,atom2,bondType}
								],
					{"M","END"}:>
						Sow@"END",
					{">",s_String?(StringMatchQ["<*>"])}:>
						Sow["PROP"->s],
					e_:>Sow@e
					},
					1]
				][[2]],
				{
					e:Except[{{___,"START",___}}]:>(
						Print@e;
						Message[ChemImportObject::molst];
						$Failed
						),
					e_:>(parseMolTable@First@e)
					}
				]
		];


(* ::Subsubsection::Closed:: *)
(*parseMolTable*)



parseMolTable[atomList:{___,"START",__}]:=
	SequenceCases[atomList,
		{
			id_:None,
			idTag_:None,
			___,
			"START",bits:Shortest@__,"END",p___}:>
			{
				{
					bits
					},
				Join[
					{
						"ID"->id,
						"IDTag"->idTag
						},
					Map[Last@First@#->Rest[#]]&/@
						Block[{flag=True},
							Split[{p},
								Function[
									If[MatchQ[#,"PROP"->_],
										flag=Not@flag
										];
									flag
									]
								]
							]
					]
				}	
		];


(* ::Subsection:: *)
(*Graphics3D*)



getElemColors[]:=
	Replace[
		$elemsByColor,
		Except[_Association]:>
			($elemsByColor=
				DeleteCases[
					AssociationMap[
						ElementData[#, "IconColor"]&,
						ChemTools`Private`$ChemElements//Keys
						],
					$Failed
					]
				)
		];
elemByColor[c_]:=
	With[{elems=getElemColors[]},
		SelectFirst[
			Keys@elems,
			Replace[elems[#],{
				ec_?ColorQ:>
					(ColorDistance[ec,c]<.1),
				_->False
				}]||
			Replace[ColorData["Atoms"][#],{
				ec_?ColorQ:>
					(ColorDistance[ec,c]<.1),
				_->False
				}]&,
			"X"
			]
		];


graphics3DGetAtoms[{color_,crds__}]:=
	With[{e=elemByColor@color},
		Map[{e,#}&,{crds}]
		];


graphics3DGetBonds[{origCrds_,atomCrds_}]:=
	With[{bondCrds=Replace[origCrds,(l_List->_):>l,1]},
		With[{pairs=
			DeleteDuplicatesBy[Sort]@*Join@@
				Replace[bondCrds,{
					{
						a_?(Norm[First@Nearest[atomCrds,#]-#<.1]&),
						b_?(Norm[First@Nearest[atomCrds,#]-#<.1]&)
						}:>
						With[{
							a1=First@Nearest[atomCrds,a,1],
							a2=First@Nearest[atomCrds,b,1]
							},
							If[a1==a2,
								Nothing,
								{{a1,a2}}
								]
							],
					{a_,b_}:>
						Join[
							Cases[bondCrds,
								{a,i:Except[b]}|{i:Except[b],a}:>{b,i}
								],
							Cases[bondCrds,
								{i:Except[a],b}|{b,i:Except[a]}:>{a,i}
								]
							]
						},
					1]
				},
			(*Append[#,1]&/@*)
				Select[
					pairs,
					AllTrue[#,MemberQ[atomCrds,#]&]&
					]
			]
		];


graphicsComplexImport[gc_]:=
	With[{
		coords=First@gc,
		objs=Cases[gc[[2]],_RGBColor|_Sphere|_Ball|_Cylinder,\[Infinity]]},
		With[{
			balls=
				SequenceCases[objs,
					{_RGBColor,(_Sphere|_Ball)..},
					\[Infinity]],
			sticks=
				SequenceCases[objs,
					{_RGBColor,(_Cylinder)..},
					\[Infinity]
					]
			},
			With[{
				atoms=
					Join@@Map[
							graphics3DGetAtoms@*
								ReplaceAll[ (Sphere|Ball)[p_,___]:>p ],
							balls
							]},
				{
					atoms,
					graphics3DGetBonds@{
						Cases[sticks,
							Cylinder[{i_Integer,j_Integer},___]:>
								{i,j}
							,\[Infinity]],
						Last/@atoms
						}
					}/.i_Integer:>coords[[i]]
				]
			]
		];


graphicsImportSpheresBallsAndCylinders[objs_]:=
	With[{objSet=
		Cases[objs,_RGBColor|_Sphere|_Ball|_Cylinder,\[Infinity]]
		},
		With[{
			balls=
				SequenceCases[objSet,
					{_RGBColor,(_Sphere|_Ball)..},
					\[Infinity]],
			sticks=
				Cases[
					ReplaceAll[objSet,
						l:{___,_Cylinder,___}:>
							SplitBy[l,
								MatchQ[_Cylinder]
								]
						],{
					Except[_Cylinder]...,
					c:__Cylinder|{__Cylinder},
					Except[_Cylinder]...
					}:>
						Flatten@{c},\[Infinity]]
			},
			With[{
					atoms=
						Join@@Map[
								graphics3DGetAtoms@*
									ReplaceAll[ (Sphere|Ball)[p_,___]:>p ],
								balls
								]},
					{
						atoms,
						graphics3DGetBonds@{
							Map[
								FirstCase[#,
									p:{{__?NumericQ},{__?NumericQ}}:>
										(p),
									Nothing,
									\[Infinity]
									]&,
								sticks
								],
							Last/@atoms
							}
						}
					]
				]
			];


chemImportGraphics3D[data_Graphics3D]:=
	With[{as=
		Replace[FirstCase[data,_GraphicsComplex,None,\[Infinity]],{
			None:>
				graphicsImportSpheresBallsAndCylinders@data,
			gc_:>
				graphicsComplexImport@gc
			}]
		},
		List@
			Join[
				With[{m=
					Replace[
						Replace[(Norm@*Subtract@@@Last@as),{
							{}->0,
							m:{__}:>Mean@m
							}],
						i_?(#>0&):>
							Floor@Log10@i
						]},
						If[m>0,
							Map[{First@#,Last@#/10^m}&,First@as],
							First@as
							]
					],
				With[{aps=Last/@First@as},
					Sort@
						Map[
							First@First@Position[aps,#]&,
							Last@as,
							{2}]
					]
				]
		];


ChemImportGraphics::nosup=
	"Import support for type `` is currently unavailable. \
Only Graphics3D is currently supported.";


ChemImportGraphics[data_Graphics3D]:=
	chemImportGraphics3D[data];
ChemImportGraphics[data_]/;(Message[ChemImportGraphics::nosup, Head[data]]):=
	Null;


(* ::Subsection:: *)
(*Graph*)



(*chemImportGraph[data_Graph]:=
	With[{
		nodes=VertexList@data,
		c=Options[data,VertexStyle],
		w=Normal@WeightedAdjacencyGraph@data},
		Vertex coordinates would have to be explicitly specified, though.
		
		];*)


(* ::Subsection:: *)
(*Gaussian*)



gaussianImportObjectData[file:_String?FileExistsQ|_InputStream, "GaussianJob"]:=
	List@ImportGaussianJob[file, "MolTable"];
gaussianImportObjectData[file:_String?FileExistsQ|_InputStream, "FormattedCheckpoint"]:=
	List@ImportFormattedCheckpointFile[file, "MolTable"];


(* ::Subsection:: *)
(*Structure*)



ChemImportChemicalStructure::no3D=
	"No 3D structure found for identifier ``. Attempting to use a 2D structure instead";
ChemImportChemicalStructure::nostr=
	"No structure found for identifier ``";
ChemImportChemicalStructure[
	structure:
		_PubChemCompound|
		_PubChemSubstance|
		_Integer|
		Entity["Chemical",_]|
		_String?(
			Not@FileExistsQ@#&&
			Not@StringContainsQ[#,"\n"|$PathnameSeparator]
			&),
	postProcessFunction_:ChemImportMolTableString
	]:=
	Replace[
		Replace[
			Quiet[ChemDataLookup[structure,"SDFFiles"],ServiceExecute::serrormsg],
			$Failed:>(
				PackageThrowMessage[
					"ImportStructure3D",
					"No 3D structure found for ``. Attempting to usage a 2D structure"
					"MessageParameters"->{structure}
					];
				ChemDataLookup[structure,"2DStructures",
					"Overwrite"->True]
				)
			],
		{
			mol_String:>
				postProcessFunction@mol,
			mols:{__String}:>
				Map[postProcessFunction, mols],
			_:>
				PackageRaiseException["ImportStructure", 
					"No structure found for identifier ``",
					"MessageParameters"->{structure}
					]
			}
		];
ChemImportChemicalStructure[
	structure:_InputStream|_String?(FileExistsQ),
	postProcess_:ChemImportMolTableString
	]:=
	ChemImportChemicalStructure[Import[structure, "Text"], postProcess];


End[];



