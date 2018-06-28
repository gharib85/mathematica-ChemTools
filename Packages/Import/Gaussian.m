(* ::Package:: *)

(* Autogenerated Package *)

ImportGaussianJob::usage=
	"Imports data from a Gaussian job";
ImportFormattedCheckpointFile::usage=
	"Imports results from an FChk file";
ImportGaussianLog::usage=
	"Imports data from a log file";


Begin["`Private`"];


(* ::Subsection:: *)
(*GaussianJob*)



(* ::Subsubsection::Closed:: *)
(*iGaussianRead*)



(* ::Subsubsubsection::Closed:: *)
(*iGaussianReadLink0*)



iGaussianReadLink0[link0Block_]:=
	Map[
		If[StringContainsQ[#, "="],
			Rule@@StringSplit[#, "=", 2],
			#
			]&,
		Select[
			StringSplit[StringTrim@link0Block, "%"|Whitespace],
			Not@*StringMatchQ[""|Whitespace]
			]
		];


(* ::Subsubsubsection::Closed:: *)
(*iGaussianReadDirectives*)



iGaussianReadDirectives[directives_]:=
	Map[
		If[StringContainsQ[#, "="],
			Rule@@StringSplit[#, "=", 2],
			#
			]&,
		Select[
			StringSplit[StringTrim@directives, "#"|Whitespace],
			Not@*StringMatchQ[""|Whitespace]
			]
		];


(* ::Subsubsubsection::Closed:: *)
(*iGaussianJobReadChargeAndMultiplicity*)



iGaussianJobReadChargeAndMultiplicity[mult_]:=
	Map[
		Which[
			StringMatchQ[#, NumberString], 
				Floor@Internal`StringToDouble[#], 
			StringMatchQ[#, Whitespace|""],
				Nothing,
			True,
				#
			]&,
		StringTrim@StringSplit[mult, ","|" "]
		];


(* ::Subsubsubsection::Closed:: *)
(*iGaussianJobReadAtoms*)



iGaussianJobReadAtoms[atoms_]:=
	ImportString[atoms, "Table"];


(* ::Subsubsubsection::Closed:: *)
(*iGaussianJobReadVariables*)



iGaussianJobReadVariables[vars_]:=
	Map[
		Map[
			Which[
				StringMatchQ[#, NumberString], 
					Internal`StringToDouble[#], 
				StringMatchQ[#, Whitespace|""],
					Nothing,
				True,
					#
				]&,
			StringSplit[StringTrim@#]
			]&, 
		StringSplit[vars, "\n"]
		];


(* ::Subsubsubsection::Closed:: *)
(*iGaussianJobReadBonds*)



iGaussianJobReadBonds[bonds_]:=
	ImportString[bonds, "Table"];


(* ::Subsubsubsection::Closed:: *)
(*iGaussianJobPrecleanSpec*)



iGaussianJobPrecleanSpec[s_]:=
	Fold[
		#2[#]&,
		s,
		{
			StringTrim, 
			StringDelete[StartOfString~~"!"~~(Except["\n"]...)~~"\n"],
			StringDelete[Longest["!"~~(Except["\n"]...)]],
			StringDelete[StartOfLine~~(Except["\n", Whitespace])],
			StringDelete[(Except["\n", Whitespace])~~EndOfLine],
			StringReplace[Repeated["\n", {2, \[Infinity]}]->"\n\n"]
			}
		]


(* ::Subsubsubsection::Closed:: *)
(*iGaussianJobReadSystem*)



iGaussianJobReadSystem[systemSpec_]:=
	Module[
		{
			specText=iGaussianJobPrecleanSpec[systemSpec],
			mults,
			atoms,
			vars,
			consts,
			bonds
			},
		{mults, specText}=StringSplit[specText, "\n", 2];
		atoms=
			First@
				StringCases[specText,
					Repeated[
						(Whitespace|"")~~LetterCharacter~~Except["\n"|":"]...~~("\n"|EndOfString)
						]
					];
		specText=StringTrim[specText, atoms];
		vars=
			StringCases[specText,
				StartOfLine~~Except["\n"]..~~":"~~(Whitespace|"")~~"\n"~~
					varBlock:
						Repeated[
							(Whitespace|"")~~LetterCharacter~~Except["\n"|":"]..~~("\n"|EndOfString)
							]:>varBlock
				];
		Which[
			Length@vars>1, 
				consts=vars[[2]];
				vars=vars[[1]],
			Length@vars==1,
				vars=vars[[1]];
				consts="",
			True,
				vars="";
				consts="";
			];
		bonds=
			StringTrim@Replace[
				StringCases[
					StringDelete[specText, Alternatives@@vars],
					Repeated[
						(Whitespace|"")~~DigitCharacter~~Except["\n"|":"]..~~("\n"|EndOfString)
						]
					],
				{
					{}->"",
					{e_, ___}:>e
					}
				];
		<|
			"MultiplicityAndCharge"->
				iGaussianJobReadChargeAndMultiplicity@mults,
			"Atoms"->
				iGaussianJobReadAtoms@atoms,
			"Variables"->
				iGaussianJobReadVariables@vars,
			"Constants"->
				iGaussianJobReadVariables@consts,
			"Bonds"->
				iGaussianJobReadBonds@bonds
			|>
		]


(* ::Subsubsubsection::Closed:: *)
(*iGaussianJobRead*)



iGaussianJobRead[cleanText_]:=
	With[{baseSplit=StringTrim@StringSplit[cleanText, Repeated["\n", {2, \[Infinity]}], 4]},
		<|
			"Header"->
				<|
					"Link0"->iGaussianReadLink0@baseSplit[[1]],
					"Directives"->iGaussianReadDirectives@baseSplit[[2]],
					"Description"->StringTrim@baseSplit[[3]]
					|>,
			"System"->
				iGaussianJobReadSystem@baseSplit[[4]]
			|>
		];


(* ::Subsubsubsection::Closed:: *)
(*iGaussianJobRead1*)



iGaussianJobRead1[fullText_]:=
	iGaussianJobRead@
		StringTrim@
			StringReplace[Repeated["\n", {3, \[Infinity]}]->"\n\n"]@
				Fold[
					StringDelete,
					fullText,
					{
						(StartOfLine~~"!"~~Except["\n"]...~~"\n"),
						"!"~~Except["\n"]..
						}
					];


(* ::Subsubsection::Closed:: *)
(*ImportGaussianJob*)



ImportGaussianJob[file:_String?FileExistsQ|_InputStream, ops:OptionsPattern[]]:=
	ImportGaussianJob[ReadString@file];
ImportGaussianJob[str_String?(Not@*FileExistsQ)]:=
	iGaussianJobRead1[str];
ImportGaussianJob[file:_String|_InputStream, "MolTable", ops:OptionsPattern[]]:=
	With[{dats=ImportGaussianJob[file]["System"]},
		ImportString[#, "ZMatrix"]&@
			StringRiffle@
				Join[
					dats["Atoms"],
					{{"Variables:"}},
					dats["Variables"],
					{{""}},
					dats["Bonds"]
					]
		];
ImportGaussianJob[file:_String|_InputStream, "Graphics3D", ops:OptionsPattern[]]:=
	ChemGraphics3D[Rest[#], ops]&/@
		ImportGaussianJob[file, "MolTable"];


(* ::Subsection:: *)
(*GaussianLog*)



(* ::Subsubsection::Closed:: *)
(*iGaussianLogRead*)



$GaussianLogReadNumberOfRecords=All;


iGaussianLogRead[
	log_InputStream, recSeps_, postProcess_,
	mode:Read:Read
	]/;!TrueQ[$GaussianLogReadEOF]:=
	With[
		{
			sp=
				Quiet@StreamPosition@log,
			res=
				Read[log, Record, 
					RecordSeparators->recSeps
					]
			},
		If[res===EndOfFile,
			$GaussianLogReadEOF=
				Quiet@Check[SetStreamPosition[log, sp], True];
			Missing["NotFound"],
			postProcess@res
			]
		];
iGaussianLogRead[
	log_InputStream, recSeps_, postProcess_,
	mode:ReadList
	]/;!TrueQ[$GaussianLogReadEOF]:=
	With[
		{
			sp=
				Quiet@StreamPosition@log,
			res=
				ReadList[log, Record, 
					Replace[$GaussianLogReadListRecords,
						Except[_Integer?Positive]:>Sequence@@{}
						],
					RecordSeparators->recSeps
					]
			},
		$GaussianLogReadEOF=
			Quiet@Check[SetStreamPosition[log, sp], True];
		postProcess@
			If[IntegerQ@#&&#<0&@$GaussianLogReadListRecords,
				res[[$GaussianLogReadListRecords;;]],
				res
				]
		];
iGaussianLogRead[
	log_InputStream, recSeps_, postProcess_, 
	___
	]/;TrueQ[$GaussianLogReadEOF]=
	Missing["EndOfFile"]


(* ::Subsubsection::Closed:: *)
(*GaussianLogRead*)



(* ::Subsubsubsection::Closed:: *)
(*Main*)



GaussianLogRead[logFile:_String?FileExistsQ, key_]:=
	With[{or=OpenRead[logFile]},
		Replace[$Failed:>(Close[or];$Failed)]@
			CheckAbort[
				With[{res=GaussianLogRead[or, key]},
					Close[or];
					res
					],
				$Failed
				]
		];
GaussianLogRead[logString_String, key_]:=
	With[{or=StringToStream[logString]},
		Replace[$Failed:>(Close[or];$Failed)]@
			CheckAbort[
				With[{res=GaussianLogRead[or, key]},
					Close[or];
					res
					],
				$Failed
				]
		];


(* ::Subsubsubsection::Closed:: *)
(*InputZMatrix*)



gaussianLogReadZMatrixBlock[zmat_]:=
	With[{
		bits=
			StringSplit[
				StringSplit[StringTrim@zmat, "\n", 2][[2]],
				"Variables:"
				]
		},
		Prepend[
			#[[1]]->Rest[#]&/@
				ImportString[
					StringSplit[StringTrim@bits[[2]], "\n"~~(Whitespace|"")~~"\n"][[1]], 
					"Table"
					],
			Map[
				Which[
					Length@#>5,
						MapAt[
							Quantity[#, "Angstroms"]&, 
							MapAt[Quantity[#, "AngularDegrees"]&, #, {{5}, {7}}],
							{3}
							],
					Length@#>3,
						MapAt[
							Quantity[#, "Angstroms"]&, 
							MapAt[Quantity[#, "AngularDegrees"]&, #, {5}], 
							{3}
							],
					Length@#>1,
							MapAt[Quantity[#, "Angstroms"]&, #, {3}],
					True,
						#
					]&,
				ImportString[
					StringTrim@First@bits,
					"Table"
					]
				]
			]
		];


GaussianLogRead[log_InputStream, "InputZMatrix"]:=
	iGaussianLogRead[
		log,
		{{"Z-matrix:"}, {"NAtoms="}},
		gaussianLogReadZMatrixBlock
		]


(* ::Subsubsubsection::Closed:: *)
(*CartesianCoordinates*)



(* ::Subsubsubsubsection::Closed:: *)
(*Parse*)



gaussianLogReadParseCartesianCoordinates[s:{__String}]:=
	Map[
		StringCases[
			(
				Whitespace~~which:DigitCharacter..~~
				Whitespace~~what:DigitCharacter..~~
				Whitespace~~type:DigitCharacter..~~
				Whitespace~~x:NumberString~~
				Whitespace~~y:NumberString~~
				Whitespace~~z:NumberString
				):>
					{
						ChemDataLookup[Floor@Internal`StringToDouble@what, "Symbol"], 
						Internal`StringToDouble/@{x, y, z}
						}
				],
		s
		];
gaussianLogReadParseCartesianCoordinates[{}]:=
	{}


(* ::Subsubsubsubsection::Closed:: *)
(*Tags*)



$glrCartCoordStartTag=
"                         Standard orientation:                         
 ---------------------------------------------------------------------
 Center     Atomic      Atomic             Coordinates (Angstroms)
 Number     Number       Type             X           Y           Z
 ---------------------------------------------------------------------";
$glrCartCoordEndTag=
" ---------------------------------------------------------------------";


(* ::Subsubsubsubsection::Closed:: *)
(*Main*)



GaussianLogRead[log_InputStream, "CartesianCoordinates"]:=
	iGaussianLogRead[
		log,
		{
			{$glrCartCoordStartTag},
			{$glrCartCoordEndTag}
			},
		gaussianLogReadParseCartesianCoordinates,
		ReadList
		]


(* ::Subsubsubsection::Closed:: *)
(*ZMatrices*)



gaussianLogReadParseZMatrices[s:{__String}]:=
	Map[
		StringCases[
			{
				what:LetterCharacter..~~Whitespace~~EndOfLine:>
					{what},
				(* norm type *)
				what:LetterCharacter..~~
					Whitespace~~
				n1:DigitCharacter..~~Whitespace~~r:NumberString~~
					"("~~Repeated[_, {6}]~~")"~~EndOfLine:>
					{what, Floor@Internal`StringToDouble@n1, Internal`StringToDouble@r},
				(* norm angle *)
				what:LetterCharacter..~~Whitespace~~
					n1:DigitCharacter..~~Whitespace~~r:NumberString~~
						"("~~Repeated[_, {6}]~~")"~~Whitespace~~
					n2:DigitCharacter..~~Whitespace~~a:NumberString~~
						"("~~Repeated[_, {6}]~~")"~~EndOfLine:>
					{what, 
						Floor@Internal`StringToDouble@n1, Internal`StringToDouble@r,
						Floor@Internal`StringToDouble@n2, Internal`StringToDouble@a
						},
				(* norm angle dihedral *)
				what:LetterCharacter..~~Whitespace~~
					n1:DigitCharacter..~~Whitespace~~r:NumberString~~
						"("~~Repeated[_, {6}]~~")"~~Whitespace~~
					n2:DigitCharacter..~~Whitespace~~a:NumberString~~
						"("~~Repeated[_, {6}]~~")"~~Whitespace~~
					n3:DigitCharacter..~~Whitespace~~d:NumberString:>
					{what, 
						Floor@Internal`StringToDouble@n1, Internal`StringToDouble@r,
						Floor@Internal`StringToDouble@n2, Internal`StringToDouble@a,
						Floor@Internal`StringToDouble@n3, Internal`StringToDouble@d
						}
				}
			],
		s
		];
gaussianLogReadParseZMatrices[{}]:=
	{}


$glrZMatrixStartTag=
"---------------------------------------------------------------------------------------------------
                            Z-MATRIX (ANGSTROMS AND DEGREES)
   CD    Cent   Atom    N1       Length/X        N2       Alpha/Y        N3        Beta/Z          J
 ---------------------------------------------------------------------------------------------------
";


$glrZMatrixEndTag=
" ---------------------------------------------------------------------";


GaussianLogRead[log_InputStream, "ZMatrices"]:=
	iGaussianLogRead[
		log,
		{
			{$glrZMatrixStartTag}, 
			{$glrZMatrixEndTag}
			},
		gaussianLogReadParseZMatrices,
		ReadList
		]


(* ::Subsubsubsection::Closed:: *)
(*MullikenCharges*)



gaussianLogReadParseMullikenCharges[s:{__String}]:=
	Map[
		StringCases[
			(
				which:DigitCharacter..~~
				Whitespace~~what:LetterCharacter..~~
				Whitespace~~charge:NumberString..~~
				(Whitespace|"")~~(EndOfLine|EndOfString)
				):>
					{
						what, 
						Internal`StringToDouble@charge
						}
				],
		s
		];
gaussianLogReadParseMullikenCharges[{}]:=
	{}


GaussianLogRead[log_InputStream, "MullikenCharges"]:=
	iGaussianLogRead[
		log,
		{
			{"Mulliken charges:"}, 
			{"Sum of Mulliken charges"}
			},
		gaussianLogReadParseMullikenCharges,
		ReadList
		]


(* ::Subsubsubsection::Closed:: *)
(*MultipoleMoments*)



gaussianLogReadParseMultipoleMoments[s_String]:=
	Association@
		Map[
			#[[1]]->
				With[
					{
						vals=
							StringCases[#[[2]], 
								k:("X"|"Y"|"Z")..~~"="~~Whitespace~~val:NumberString:>
								Replace[Characters@k,
									{
										"X"->1,
										"Y"->2,
										"Z"->3
										},
									1
									]->Internal`StringToDouble@val
								]
						},
					With[
						{
							symms=
								SortBy[
									DeleteDuplicatesBy[
										Flatten[
											Thread[
												Tuples[#[[1]], Length[#[[1]]]]->
													#[[2]]
												]&/@vals
											], 
										First
										], 
									First
									]
							},
						If[Mod[Length[symms], 3]==0, 
							If[!NumericQ@#[[1]], RawArray["Real32", #], #]&@
							Nest[
								If[Mod[Length[#], 3]==0,
									Partition[#, 3],
									#
									]&, 
								Last/@symms,
								Length@vals[[1, 1]]-1
								]
							]
						]
					]&,
			Partition[
				StringSplit[
					"Dipole moment ("<>s,
					Longest[
						(StartOfLine|StartOfString)~~
							(type:(WordCharacter|" ")..)~~" moment "~~Except[":"]..~~":"
						]:>
						StringDelete[type, Whitespace]
					],
				2
				]
			];
gaussianLogReadParseMultipoleMoments[s:{__String}]:=
	gaussianLogReadParseMultipoleMoments/@s;
gaussianLogReadParseMultipoleMoments[_]:=
	{};


GaussianLogRead[log_InputStream, "MultipoleMoments"]:=
	iGaussianLogRead[
		log,
		{
		{"Dipole moment ("}, 
 {" N-N="}
 },
		gaussianLogReadParseMultipoleMoments,
		ReadList
		]


(* ::Subsubsubsection::Closed:: *)
(*HFEnergies*)



gaussianLogReadParseHFEnergies//Clear


gaussianLogReadParseHFEnergies[s_]:=
	Internal`StringToDouble/@StringTrim[s]


GaussianLogRead[log_InputStream, "HartreeFockEnergies"]:=
	iGaussianLogRead[
		log,
		{{"SCF Done:  E(RHF) ="}, {"A.U."}},
		gaussianLogReadParseHFEnergies,
		ReadList
		];


(* ::Subsubsubsection::Closed:: *)
(*MP2Energies*)



gaussianLogReadParseMP2Energies//Clear


gaussianLogReadParseMP2Energies[s_]:=
	Internal`StringToDouble@
		StringReplacePart[#, "E", {-4, -4}]&/@
		StringTrim[s]


GaussianLogRead[log_InputStream, "MP2Energies"]:=
	iGaussianLogRead[
		log,
		{{"EUMP2 ="}, {"\n"}},
		gaussianLogReadParseMP2Energies,
		ReadList
		];


(* ::Subsubsubsection::Closed:: *)
(*ScanTable*)



gaussianLogReadScanBlock[scan_]:=
	Module[
		{
			splits=
				StringTrim[
					StringSplit[scan, Repeated[Repeated["-"]|"  "]~~Repeated["-"], 2],
					Repeated[Repeated["-"]|"  "]~~Repeated["-"]
					],
			headers,
			vars,
			energyPos,
			tab
			},
		headers=StringSplit[splits[[1]]];
		energyPos=First@FirstPosition[headers, "SCF"];
		vars=Append[Take[headers, {2, energyPos-1}], "V"];
		tab=
			MapAt[
				#&,
				Partition[
					ReadList[StringToStream@splits[[2]], Number], 
					Length@headers
					][[All, Append[Range[2, energyPos-1], -1]]],
				{All, -1}
				];
		Map[Thread[vars->#]&, tab]
		];


GaussianLogRead[log_InputStream, "ScanTable"]:=
	iGaussianLogRead[
		log,
		{{"scan:"}, {"\n  \n"}},
		gaussianLogReadScanBlock
		];


(* ::Subsubsubsection::Closed:: *)
(*OptimizationScan*)



gaussianLogReadOptScanBlock[scan_]:=
	Transpose@
		KeyValueMap[Thread[Rule[Replace[#, "Eigenvalues"->"Energy"], #2]]&]@
			KeySortBy[Replace[{"Eigenvalues"->1, _->0}]]@
			GroupBy[
				DeleteCases[{}]@
				Flatten[
					ImportString[#, "Table"]&/@
						StringReplace[
							StringSplit[scan, "\n"~~Repeated[Whitespace~~DigitCharacter..]~~"\n"],
							{
								"--"->"  ",
								"-"->" -"
								}
							],
					1
					],
				First->Rest,
				Flatten
				]


GaussianLogRead[log_InputStream, "OptimizationScan"]:=
	iGaussianLogRead[
		log,
		{{"Summary of Optimized Potential Surface Scan"}, {"-----------------"}},
		gaussianLogReadOptScanBlock
		];


(* ::Subsubsubsection::Closed:: *)
(*ComputerTimeElapsed*)



gaussianLogReadTimeElapsedBlock[elapsed_]:=
	With[
		{
			times=Internal`StringToDouble@StringCases[elapsed, NumberString],
			units={"Days", "Hours", "Minutes", "Seconds"}
			},
		With[{mlen=Min[Length/@{times, units}]},
			Quantity[
				MixedMagnitude[Take[times, mlen]],
				MixedUnit[Take[units, mlen]]
				]
			]
		];


GaussianLogRead[log_InputStream, "ComputerTimeElapsed"]:=
	iGaussianLogRead[
		log,
		{{"cpu time:"}, {"\n"}},
		gaussianLogReadTimeElapsedBlock
		];


(* ::Subsubsubsection::Closed:: *)
(*Blurb*)



GaussianLogRead[log_InputStream, "Blurb"]:=
	iGaussianLogRead[
		log,
		{{"\n\n\n"}, {"\n Job "}},
		StringTrim
		]


(* ::Subsubsubsection::Closed:: *)
(*StartDateTime*)



gaussianLogReadParseStartDateTime[s_String]:=
	DateObject@
		First@
			StringSplit[
				Last@
					StringSplit[
						s,
						" at "
						],
				","
				]


GaussianLogRead[log_InputStream, "StartDateTime"]:=
	iGaussianLogRead[log,
		{{"Leave Link"}, {"\n (Enter"}},
		gaussianLogReadParseStartDateTime
		]


(* ::Subsubsubsection::Closed:: *)
(*EndDateTime*)



gaussianLogReadParseEndDateTime[s_String]:=
	DateObject@Last@
		StringSplit[s, " at "]


GaussianLogRead[log_InputStream, "EndDateTime"]:=
	iGaussianLogRead[
		log,
		{{"Normal termination of Gaussian"}, {"\n"}},
		gaussianLogReadParseEndDateTime
		]


(* ::Subsubsection::Closed:: *)
(*ImportGaussianLog*)



$GaussianLogKeywords=
	{
		"StartDateTime",
		"CartesianCoordinates",
		"MullikenCharges",
		"MultipoleMoments",
		"HartreeFockEnergies",
		"MP2Energies",
		"InputZMatrix",
		"InputZMatrixVariables",
		"ZMatrices",
		"ScanTable",
		"OptimizationScan",
		"Blurb",
		"ComputerTimeElapsed",
		"EndDateTime"
		};
$GaussianLogAllKeywords=
	{
		"StartDateTime",
		"InputZMatrix",
		"ScanTable",
		"Blurb",
		"ComputerTimeElapsed",
		"EndDateTime"
		};


(* ::Subsubsubsection::Closed:: *)
(*Main*)



ImportGaussianLog//Clear


Options[ImportGaussianLog]=
	{
		"ImportedElements"->All,
		"NumberOfRecords"->All
		};
ImportGaussianLog[
	file:_String?FileExistsQ|_InputStream,
	k_String,
	n_:All
	]:=
	Block[{$GaussianLogReadEOF, $GaussianLogReadNumberOfRecords=n},
		Replace[
			GaussianLogRead[file, k],
			_GaussianLogRead->Missing["UnknownKey", k]
			]
		];
ImportGaussianLog[
	file:_String?FileExistsQ|_InputStream,
	k:{__String},
	n_:All
	]:=
	Block[{$GaussianLogReadEOF, $GaussianLogReadNumberOfRecords=n},
		AssociationMap[
			Replace[
				GaussianLogRead[file, #],
				_GaussianLogRead->Missing["UnknownKey", #]
				]&,
			SortBy[
				k, 
				Position[$GaussianLogKeywords, #]&
				]
			]
		];
ImportGaussianLog[
	file:_String?FileExistsQ|_InputStream,
	ops:OptionsPattern[]
	]:=
	ImportGaussianLog[
		file, 
		Replace[
			OptionValue["ImportedElements"],
			All->$GaussianLogAllKeywords
			]
		]


(* ::Subsubsubsection::Closed:: *)
(*ScanQuantityArray*)



ImportGaussianLog[
	file:_String?FileExistsQ|_InputStream,
	"ScanQuantityArray"
	]:=
	With[{bits=ImportGaussianLog[file, {"InputZMatrix", "ScanTable"}]},
		If[MissingQ@bits[[2]],
			bits[[2]],
			With[{
				keys=Keys@First@bits[[2]], 
				vals=Values@bits[[2]], 
				zm=bits[[1, 1]],
				uc=
					QuantityMagnitude@
						UnitConvert[
							Quantity[1, "Hartrees"], 
							"Wavenumbers"*"PlanckConstant"*"SpeedOfLight"
							]
				},
				With[
					{
						types=
							Map[
								Switch[FirstPosition[zm, #], 
									{_, 3, ___}, "Angstroms",
									_, "AngularDegrees"
									]&,
								Most@keys
								]
						},
				Map[QuantityVariable, keys]->
					QuantityArray[
						MapAt[uc*#&, vals, {All, -1}], 
						Append[types, "Wavenumbers"]
						]
					]
				]
			]
		]


(* ::Subsubsubsection::Closed:: *)
(*OptimizationScanQuantityArray*)



ImportGaussianLog[
	file:_String?FileExistsQ|_InputStream,
	"OptimizationScanQuantityArray"
	]:=
	With[{bits=ImportGaussianLog[file, {"InputZMatrix", "OptimizationScan"}]},
		If[MissingQ@bits[[2]],
			bits[[2]],
			With[{
				keys=Keys@First@bits[[2]], 
				vals=Values@bits[[2]], 
				zm=bits[[1, 1]],
				uc=
					QuantityMagnitude@
						UnitConvert[
							Quantity[1, "Hartrees"], 
							"Wavenumbers"*"PlanckConstant"*"SpeedOfLight"
							]
				},
				With[
					{
						types=
							Map[
								Switch[FirstPosition[zm, #], 
									{_, 3, ___}, "Angstroms",
									_, "AngularDegrees"
									]&,
								Most@keys
								]
						},
				Map[QuantityVariable, keys]->
					QuantityArray[
						MapAt[uc*#&, vals, {All, -1}], 
						Append[types, "Wavenumbers"]
						]
					]
				]
			]
		]


(* ::Subsubsubsection::Closed:: *)
(*OptimizationScanZMatrices*)



ImportGaussianLog[
	file:_String?FileExistsQ|_InputStream,
	"OptimizationScanZMatrices"
	]:=
	With[{bits=ImportGaussianLog[file, {"InputZMatrix", "OptimizationScan"}]},
		If[MissingQ@bits[[2]],
			bits[[2]],
			With[{
				keys=Keys@First@bits[[2]], 
				vals=Values@bits[[2]], 
				zm=bits[[1, 1]],
				uc=
					QuantityMagnitude@
						UnitConvert[
							Quantity[1, "Hartrees"], 
							"Wavenumbers"*"PlanckConstant"*"SpeedOfLight"
							]
				},
				With[
					{
						types=
							Map[
								Switch[FirstPosition[zm, #], 
									{_, 3, ___}, "Angstroms",
									_, "AngularDegrees"
									]&,
								Most@keys
								]
						},
				ReplaceAll[zm/.q_Quantity:>QuantityMagnitude[q],
					Thread[keys->#]&/@
						QuantityMagnitude@
							QuantityArray[
								MapAt[uc*#&, vals, {All, -1}], 
								Append[types, "Wavenumbers"]
								]
						]
					]
				]
			]
		]


(* ::Subsection:: *)
(*FormattedCheckPoint Files*)



(* ::Subsubsection::Closed:: *)
(*iFormattedCheckpointRead*)



Clear[iFormattedCheckpointRead];
ImportFormattedCheckpointFile::misfmt=
	"Misformatted fchk file or failed to extract from block appropriately. \
`` isn't an appropriate line specification.";
iFormattedCheckpointRead[
	stream_InputStream, 
	keys:_?StringPattern`StringPatternQ|{__?StringPattern`StringPatternQ}|All
	]:=
	Module[
		{
			validKeys=
				Replace[keys, 
					{
						"*"|Verbatim[__]->All,
						{p__}:>Alternatives[p]
						}
					],
			header,
			line,
			lineParts,
			keyRaw,
			key,
			subspec,
			type,
			results=<||>
			},
			header=Internal`Bag[];
			Do[
				line=ReadList[stream, String, 1];
				(* If we've hit the end of the file we just return *)
				If[line==={}, Return[EndOfFile], line=line[[1]] ];
				(* test to see if we've read the header yet *)
				If[header=!=None,
					(* while in the header *)
					If[StringFreeQ[line, "Number of atoms"~~__~~" I "],
						(* stuff the bag *)
						Internal`StuffBag[header, line];
						Continue[],
						(* exit the header *)
						If[(validKeys===All||StringMatchQ["Header", validKeys]),
							results["Header"]=
								StringRiffle[Internal`BagPart[header, All], "\n"]
							];
						header=None;
						]
					];
				(* if the line is malformatted we fail out *)
				If[StringStartsQ[line, " "],
					Message[ImportFormattedCheckpointFile::misfmt, line];
					results=Return[$Failed]
					];
				(* All lines are whitespace separated by multiple spaces *)
				lineParts=StringSplit[line, Repeated[" ", {2, \[Infinity]}]];
				(* The key is the first element *)
				keyRaw=lineParts[[1]];
				(* We'll reformat it to be more Mathematica appropriate *)
				key=
					StringJoin@
						Map[
							With[{base=Last@StringSplit[StringTrim[#, "/"],"/"]},
								ToUpperCase@StringTake[base, 1]<>StringDrop[base, 1]
								]&,
							 StringSplit[lineParts[[1]], " "]
							];
				If[MatchQ[lineParts[[2]], "I"|"R"|"C"|"L"],
					subspec=None,
					(* subspec is the second *)
					subspec=
						StringJoin@
							Map[
								With[{base=Last@StringSplit[StringTrim[#, "/"],"/"]},
									ToUpperCase@StringTake[base, 1]<>StringDrop[base, 1]
									]&,
								 StringSplit[lineParts[[2]], " "]
								];
					(* Shift so that the type is the second *)
					lineParts=Delete[lineParts, 2]
					];
				(* The type is the second *)
				type=lineParts[[2]];
				(* If we've specified a subset of keys we make sure we're taking one of those *)
				If[validKeys===All||StringMatchQ[key, validKeys],
					(* Check if we're starting a block *)
					With[{res=
						If[lineParts[[3]]=="N=",
							With[{n=Floor@Internal`StringToDouble[lineParts[[4]]]},
								Switch[type,
									"R"|"I",
										If[n>50,
											RawArray[
												If[type=="R", "Real64", "Integer32"],
												ReadList[stream, Number, n]
												],
											ReadList[stream, Number, n]
											],
									"C",
										ReadList[stream, Word, n],
									"H",
										(* Gaussian encodes this without whitespace padding so it requires lower-level tricks *)
										Replace[
											With[{lines=Quotient[n, 72], extras=Mod[n, 72]},
												Flatten[{
													ReadList[stream,
														ConstantArray[Character, 75],
														Quotient[n, 72]
														][[All, 3;;74]],
													ReadList[stream, 
														ConstantArray[Character, 3+extras], 
														1][[All, 3;;2+extras]]
													}]
												],
											{
												"1"->True,
												"0"->False,
												" "->Nothing,
												_->Indeterminate
												},
											1
											]
									]
								],
							Which[
								type=="R"&&
									StringLength[lineParts[[3]]]>4&&
									StringTake[lineParts[[3]], {-4}]=="E",
									Internal`StringToDouble@lineParts[[3]],
								type=="I",
									Floor@Internal`StringToDouble[lineParts[[3]]],
								type=="R",
									Internal`StringToDouble[lineParts[[3]]],
								type=="L",
									Switch[lineParts[[3]], "0", False, "1", True, _, Indeterminate],
								type=="C",
									lineParts[[3]]
								]
							]
						},
						If[subspec===None,
							results[key]=res,
							If[!KeyExistsQ[results, key],
								results[key]=<|subspec->res|>,
								results[key, subspec]=res
								]
							]
						];,
					(* we place the break here so subspec keys aren't missed *)
					If[ListQ@keys&&Sort[keys]==Sort[Keys[results]],
						Break[]
						];
					(* skip if necessary *)
					If[lineParts[[3]]=="N=",
						Skip[stream, 
							Number, 
							Floor@Internal`StringToDouble[lineParts[[4]]]
							]
						]
					],
				{i, \[Infinity]}
				];
			results
			];
iFormattedCheckpointRead[
	file_String?FileExistsQ, 
	keys:_?StringPattern`StringPatternQ|All
	]:=
	With[
		{
			strm=OpenRead@file
			},
		With[
			{
				 res=
				CheckAbort[iFormattedCheckpointRead[strm, keys], $Aborted]
				},
			Close[strm];
			res
			]
		];


(* ::Subsubsection::Closed:: *)
(*iFormattedCheckpointCleanResults*)



Clear[iFormattedCheckpointCleanResults];
iFormattedCheckpointCleanResults[results_Association?AssociationQ]:=
	Association@
		KeyValueMap[
			#->
				If[AssociationQ@#2,
					iFormattedCheckpointCleanResults[#2],
					Which[
						StringEndsQ[#, "Density"],
							With[{sq=Sqrt[Length[#2]]},
								If[IntegerQ@sq&&Positive[sq], 
									RawArray[
										Developer`RawArrayType@#2,
										Partition[Normal@#2, sq]
										], 
									#2
									]
								],
						StringContainsQ[#, "Coordinates"],
							QuantityArray[
								Partition[Normal@#2, 3], 
								"BohrRadius"
								],
						StringEndsQ[#, "Energy"|"Energies"],
							If[NumericQ@#2,
								Quantity[#2, "Hartrees"],
								QuantityArray[Normal@#2, "Hartrees"]
								],
						True,
							#2
						]
					]&,
			results
			];
iFormattedCheckpointCleanResults[_]:=$Failed


(* ::Subsubsection::Closed:: *)
(*ImportFormattedCheckpointFile*)
 


ImportFormattedCheckpointFile//Clear


Options[ImportFormattedCheckpointFile]=
	{
		"KeyPattern"->All
		};
ImportFormattedCheckpointFile[
	file:_String?FileExistsQ|_InputStream, 
	ops:OptionsPattern[]
	]:=
	With[{res1=iFormattedCheckpointRead[file, OptionValue["KeyPattern"]]},
		If[AssociationQ@res1,
			iFormattedCheckpointCleanResults[res1],
			$Failed
			]
		];
ImportFormattedCheckpointFile[
	file:_String?FileExistsQ|_InputStream,
	"MolTable",
	ops:OptionsPattern[]
	]:=
	With[
		{
			dats=
				ImportFormattedCheckpointFile[file, 
					"KeyPattern"->
						{
							"CurrentCartesianCoordinates", 
							"AtomicNumbers", 
							"IBond"
							}, 
					ops
					]
			},
			With[
				{
					bonds=
						DeleteDuplicates@
							Flatten[
								MapIndexed[
									Map[Sort]@Thread[{#2[[1]],DeleteCases[#, 0]}]&,
									Partition[dats["IBond"], Length@dats["AtomicNumbers"]-1]
									],
								1
								]
					},
				Join[
					{{Length@dats["AtomicNumbers"], Length@bonds}},
					Thread[
						{
							ChemDataLookup[dats["AtomicNumbers"], "Symbol"],
							QuantityMagnitude@
								UnitConvert[dats["CurrentCartesianCoordinates"], "Angstroms"]
							}
						],
					bonds
					]
				]
		];
ImportFormattedCheckpointFile[
	file:_String?FileExistsQ|_InputStream, 
	s:_?StringPattern`StringPatternQ|{__?StringPattern`StringPatternQ},
	ops:OptionsPattern[]
	]:=
	ImportFormattedCheckpointFile[file, "KeyPattern"->s, ops];
ImportFormattedCheckpointFile[
	str:_String,
	keys___?StringPattern`StringPatternQ,
	ops:OptionsPattern[]
	]:=
	ImportFormattedCheckpointFile[StringToStream[str], keys, ops];


End[];



