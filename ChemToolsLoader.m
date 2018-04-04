(* ::Title:: *)
(*ChemTools`*)


(* ::Text::GrayLevel[0.5]:: *)
(* Autogenerated ChemTools loader file *)


Unprotect[ChemTools`PackageScope`Private`$TopLevelLoad];
ChemTools`PackageScope`Private`$TopLevelLoad=
	MemberQ[$ContextPath, "Global`"];


BeginPackage["ChemTools`"];


(* ::Subsubsection::Closed:: *)
(*$ContextPath*)


$ContextPath=
	Join[$ContextPath,
		"ChemTools`"<>
			StringReplace[
				FileNameDrop[#,FileNameDepth@DirectoryName@$InputFileName],
				$PathnameSeparator->"`"
				]&/@
			Select[
				DirectoryQ@#&&
					StringMatchQ[
						StringReplace[
							FileNameDrop[#,FileNameDepth@DirectoryName@$InputFileName],
							$PathnameSeparator->"`"
							],
						("$"|WordCharacter)..
						]
				&]@
			FileNames["*",
				FileNameJoin@{
					DirectoryName@$InputFileName,
					"Packages"
					},
				Infinity
				]
		]


(* ::Section:: *)
(* Package Functions *)


Unprotect["`PackageScope`Private`*"];
Begin["`PackageScope`Private`"];


(* ::Subsection:: *)
(*Constants*)


(* ::Subsubsection::Closed:: *)
(*Naming*)


$PackageDirectory=
	DirectoryName@$InputFileName;
$PackageName=
	"ChemTools";


(* ::Subsubsection::Closed:: *)
(*Loading*)


$PackageListing=<||>;
$PackageContexts={
		"ChemTools`",
		"ChemTools`PackageScope`Private`",
		"ChemTools`PackageScope`Package`"
		};
$PackageDeclared=
	TrueQ[$PackageDeclared];


(* ::Subsubsection:: *)
(*Scoping*)


$PackageFEHiddenSymbols={};
$PackageScopedSymbols={};
$PackageLoadSpecs=
	Merge[
		{
			With[
				{
					f=
						Append[
							FileNames[
								"LoadInfo."~~"m"|"wl",
								FileNameJoin@{$PackageDirectory, "Config"}
								],
							None
							][[1]]
					},
				Replace[
						Quiet[
							Import@f,
							{
								Import::nffil,
								Import::chtype
								}
							],
					Except[KeyValuePattern[{}]]:>
						{}
					]
				],
			With[
				{
					f=
						Append[
							FileNames[
								"LoadInfo."~~"m"|"wl",
								FileNameJoin@{$PackageDirectory, "Private", "Config"}
								],
							None
							][[1]]},
				Replace[
					Quiet[
						Import@f,
						{
							Import::nffil,
							Import::chtype
							}
						],
					Except[KeyValuePattern[{}]]:>
						{}
					]
				]
			},
		Last
		];
$AllowPackageRescoping=
	Replace[
		Lookup[$PackageLoadSpecs, "AllowRescoping"],
		Except[True|False]->$TopLevelLoad
		];
$AllowPackageRecoloring=
	Replace[
		Lookup[$PackageLoadSpecs, "AllowRecoloring"],
		Except[True|False]->
			$TopLevelLoad
		];
(* ::Subsection:: *)
(*Paths*)


(* ::Subsubsection::Closed:: *)
(*PackageFilePath*)


PackageFilePath[p__]:=
	FileNameJoin[Flatten@{
		$PackageDirectory,
		p
		}];


(* ::Subsubsection::Closed:: *)
(*PackageFEFile*)


PackageFEFile[p___,f_]:=
	FrontEnd`FileName[
		Evaluate@
		Flatten@{
			$PackageName,
			p
			},
		f
		];


(* ::Subsubsection::Closed:: *)
(*PackagePathSymbol*)


PackagePathSymbol[parts___String,sym_String]:=
	ToExpression[StringRiffle[{$PackageName,parts,sym},"`"],StandardForm,HoldPattern];
PackagePathSymbol[parts___String,sym_Symbol]:=
	PackagePathSymbol[parts,Evaluate@SymbolName@Unevaluated[sym]];
PackagePathSymbol~SetAttributes~HoldRest;
(* ::Subsection:: *)
(*Loading*)


(* ::Subsubsection::Closed:: *)
(*Constants*)


If[Not@AssociationQ@$PackageFileContexts,
	$PackageFileContexts=
		<||>
	];


If[Not@AssociationQ@$DeclaredPackages,
	$DeclaredPackages=
		<||>
	];


If[Not@ListQ@$LoadedPackages,
	$LoadedPackages={}
	];


(* ::Subsubsection::Closed:: *)
(*PackageFileContext*)


PackageFileContextPath[f_String?DirectoryQ]:=
	FileNameSplit[FileNameDrop[f,FileNameDepth[$PackageDirectory]+1]];
PackageFileContextPath[f_String?FileExistsQ]:=
	PackageFileContextPath[DirectoryName@f];


PackageFileContext[f_String?DirectoryQ]:=
	With[{s=PackageFileContextPath[f]},
		StringRiffle[Append[""]@Prepend[s,ChemTools],"`"]
		];
PackageFileContext[f_String?FileExistsQ]:=
	PackageFileContext[DirectoryName[f]];


(* ::Subsubsection::Closed:: *)
(*PackageExecute*)


PackageExecute[expr_]:=
	CompoundExpression[
		Block[{$ContextPath={"System`"}},
			BeginPackage["ChemTools`"];
			$ContextPath=
				DeleteDuplicates[
					Join[$ContextPath,$PackageContexts]
					];
			CheckAbort[
				With[{res=expr},
					EndPackage[];
					res
					],
				EndPackage[]
				]
			]
		];
PackageExecute~SetAttributes~HoldFirst


(* ::Subsubsection::Closed:: *)
(*PackagePullDeclarations*)


PackagePullDeclarationsAction//Clear
PackagePullDeclarationsAction[
	Hold[
		_Begin|_BeginPackage|
			CompoundExpression[_Begin|_BeginPackage,___]
		]
	]:=
	Throw[Begin];
PackagePullDeclarationsAction[
	p:
		Hold[
			_PackageFEHiddenBlock|_PackageScopeBlock|
			CompoundExpression[
				_PackageFEHiddenBlock|_PackageScopeBlock,
				___]
			]
	]/;TrueQ[$AllowPackageRecoloring]:=
	(
		ReleaseHold[p];
		Sow[p];
		);
PackagePullDeclarationsAction[e:Except[Hold[Expression]]]:=
	Sow@e;


PackagePullDeclarations[pkgFile_]:=
	pkgFile->
		Cases[
				Reap[
					With[{f=OpenRead[pkgFile]},
						Catch@
							Do[
								If[
									Length[
										ReadList[
											f,
											PackagePullDeclarationsAction@Hold[Expression],
											1
											]
										]===0,
										Throw[EndOfFile]
									],
								Infinity
								];
						Close[f]
						]
				][[2,1]],
			s_Symbol?(
				Function[Null,
					Quiet[Context[#]===$Context],
					HoldAllComplete
					]
					):>
					HoldPattern[s],
			Infinity
			]


(* ::Subsubsection::Closed:: *)
(*PackageLoadPackage*)


PackageLoadPackage[heldSym_,context_,pkgFile_->syms_]:=
	Block[{
		$loadingChain=
			If[ListQ@$loadingChain,$loadingChain,{}],
		$inLoad=TrueQ[$inLoad],
		$ContextPath=$ContextPath
		},
		If[!MemberQ[$loadingChain,pkgFile],
			With[{$$inLoad=$inLoad},
				$inLoad=True;
				If[$AllowPackageRecoloring,
					Internal`SymbolList[False]
					];
				Replace[Thread[syms,HoldPattern],
					Verbatim[HoldPattern][{s__}]:>Clear[s]
					];
				If[Not@MemberQ[$ContextPath,context],
					$ContextPath=Prepend[$ContextPath,context];
					];
				Block[{PackageFEHiddenBlock=Null},
					PackageAppGet[context,pkgFile];
					];
				Unprotect[$LoadedPackages];
				AppendTo[$LoadedPackages,pkgFile];
				Protect[$LoadedPackages];
				If[!$$inLoad&&$AllowPackageRecoloring,
					Internal`SymbolList[True]
					];
				ReleaseHold[heldSym]
				]
			]
		];


(* ::Subsubsection::Closed:: *)
(*PackageDeclarePackage*)


PackageDeclarePackage[pkgFile_->syms_]:=
	With[{c=$Context},
		$DeclaredPackages[pkgFile]=syms;
		$PackageFileContexts[pkgFile]=c;
		Map[
			If[True,
				#:=PackageLoadPackage[#,c,pkgFile->syms]
				]&,
			syms
			]
		];


(* ::Subsubsection::Closed:: *)
(*PackageLoadDeclare*)


PackageLoadDeclare[pkgFile_String]:=
	If[!MemberQ[$LoadedPackages,pkgFile],
		If[!KeyMemberQ[$DeclaredPackages,pkgFile],
			PackageDeclarePackage@
				PackagePullDeclarations[pkgFile]
			],
		PackageAppGet[pkgFile]
		];


(* ::Subsubsection::Closed:: *)
(*PackageAppLoad*)


packageAppLoad[dir_, listing_]:=
	With[
		{
			fileNames=
				Select[
					FileNames["*", dir],
					DirectoryQ@#||MatchQ[FileExtension[#], "m"|"wl"]&
					]
			},
		Replace[
			Select[fileNames, 
				StringMatchQ[
					ToLowerCase@FileNameTake[#],
					"__pre__."~~("m"|"wl")
					]&
				],
			{f_}:>Get[f]
			];
		PackageAppLoad[
			$PackageListing[listing]=
				Select[fileNames, StringFreeQ["__"]@*FileBaseName]
			];
		Replace[
			Select[fileNames, 
				StringMatchQ[
					ToLowerCase@FileNameTake[#], 
					"__Post__."~~("m"|"wl")
					]&
				],
			{f_}:>Get[f]
			];
		];


PackageAppLoad[dir_String?DirectoryQ]:=
	If[StringMatchQ[FileBaseName@dir,(WordCharacter|"$")..],
		Begin["`"<>FileBaseName[dir]<>"`"];
		AppendTo[$PackageContexts, $Context];
		packageAppLoad[dir, FileNameDrop[dir,FileNameDepth[$PackageDirectory]+1]];
		End[];
		];
PackageAppLoad[file_String?FileExistsQ]:=
	PackageLoadDeclare[file];
PackageAppLoad[]:=
	PackageExecute@
		packageAppLoad[FileNameJoin@{$PackageDirectory,"Packages"}, $PackageName];
PackageAppLoad~SetAttributes~Listable;


(* ::Subsubsection::Closed:: *)
(*PackageAppGet*)


PackageAppGet[f_]:=
	PackageExecute@
		With[{fBase = 
			If[FileExistsQ@f,
				f,
				PackageFilePath["Packages",f<>".m"]
				]
			},
			With[{cont = 
				Most@
					FileNameSplit[
						FileNameDrop[fBase, FileNameDepth[PackageFilePath["Packages"]]]
						]},
				If[Length[cont]>0,
					Begin[StringRiffle[Append[""]@Prepend[""]@cont, "`"]];
					(End[];#)&@Get[fBase],
					Get[fBase]
				]
			]
		];
PackageAppGet[c_,f_]:=
	PackageExecute[
		Begin[c];
		(End[];#)&@
			If[FileExistsQ@f,
				Get@f;,
				Get@PackageFilePath["Packages",f<>".m"]
				]
		];


(* ::Subsubsection::Closed:: *)
(*PackageAppNeeds*)


PackageAppNeeds[pkgFile_String?FileExistsQ]:=
	If[!MemberQ[$LoadedPackages,pkgFile],
		If[KeyMemberQ[$DeclaredPackages,pkgFile],
			PackageLoadDeclare[pkgFile],
			Do[PackageLoadDeclare[pkgFile],2]
			];
		];


PackageAppNeeds[pkg_String]:=
	If[FileExistsQ@PackageFilePath["Packages",pkg<>".m"],
		PackageAppNeeds[PackageFilePath["Packages",pkg<>".m"]],
		$Failed
		];


(* ::Subsubsection:: *)
(*PackageScopeBlock*)


$PackageScopeBlockEvalExpr=TrueQ[$PackageScopeBlockEvalExpr];
PackageScopeBlock[
	e_,
	scope:_String?(StringFreeQ["`"]):"Package",
	context:_String?(StringEndsQ["`"]):"`PackageScope`"
	]/;TrueQ[$AllowPackageRescoping]:=
	With[{
		newcont=
			If[StringStartsQ[context, "`"],
				"ChemTools"<>context<>scope<>"`",
				context<>scope<>"`"
				],
		res=If[$PackageScopeBlockEvalExpr,e]
		},
		If[!MemberQ[$PackageContexts, newcont],
			Unprotect[$PackageContexts];
			AppendTo[$PackageContexts,newcont];
			];
		Replace[
			Thread[
				Cases[
					HoldComplete[e],
					sym_Symbol?(
						Function[Null,
							MemberQ[$PackageContexts,Quiet[Context[#]]],
							HoldAllComplete
							]
						):>
						HoldComplete[sym],
					\[Infinity]
					],
				HoldComplete
				],
			HoldComplete[{s__}]:>
				If[!$PackageDeclared&&ListQ@$PackageScopedSymbols,
					$PackageScopedSymbols=
						{
							$PackageScopedSymbols,
							newcont->
								HoldComplete[s]
							},
					Block[{$AllowPackageRecoloring=True},
						PackageFERehideSymbols[s]
						];
					Map[
						Function[Null,
							Quiet[
								Check[
									Set[Context[#], newcont],
									Remove[#],
									Context::cxdup
									],
								Context::cxdup
								],
							HoldAllComplete
							],
						HoldComplete[s]
						]//ReleaseHold;
					]
			];
		res
		];
PackageScopeBlock[e_, scope_String:"Package"]/;Not@TrueQ[$AllowPackageRescoping]:=
	If[$PackageScopeBlockEvalExpr,e];
PackageScopeBlock~SetAttributes~HoldFirst;


(* ::Subsubsection::Closed:: *)
(*PackageDecontext*)


PackageDecontext[
	pkgFile_String?(KeyMemberQ[$DeclaredPackages,#]&),
	scope:_String?(StringFreeQ["`"]):"Package",
	context:_String?(StringEndsQ["`"]):"`PackageScope`"
	]/;TrueQ[$AllowPackageRescoping]:=
	With[{
		names=$DeclaredPackages[pkgFile],
		ctx=
		 If[StringStartsQ[context, "`"],
			"ChemTools"<>context<>scope<>"`",
			context<>scope<>"`"
			]
		},
		Replace[names,
			Verbatim[HoldPattern][s_]:>
				Set[Context[s], ctx],
			1
			]
		];


(* ::Subsubsection::Closed:: *)
(*PackageRecontext*)


PackageRecontext[
	pkgFile_String?(KeyMemberQ[$DeclaredPackages,#]&)
	]/;TrueQ[$AllowPackageRescoping]:=
	With[{
		names=$DeclaredPackages[pkgFile],
		ctx=PackageFileContext[pkgFile]
		},
		Replace[names,
			Verbatim[HoldPattern][s_]:>
				Set[Context[s],ctx],
			1
			]
		];
(* ::Subsection:: *)
(*Autocompletion*)


(* ::Subsubsection::Closed:: *)
(*Formats*)


$PackageAutoCompletionFormats=
	Alternatives@@Join@@{
		Range[0,9],
		{
			_String?(FileExtension[#]==="trie"&),
			{
				_String|(Alternatives@@Range[0,9])|{__String},
				(("URI"|"DependsOnArgument")->_)...
				},
			{
				_String|(Alternatives@@Range[0,9])|{__String},
				(("URI"|"DependsOnArgument")->_)...,
				(_String|(Alternatives@@Range[0,9])|{__String})
				},
			{
				__String
				}
			},
		{
			"codingNoteFontCom",
			"ConvertersPath",
			"ExternalDataCharacterEncoding",
			"MenuListCellTags",
			"MenuListConvertFormatTypes",
			"MenuListDisplayAsFormatTypes",
			"MenuListFonts",
			"MenuListGlobalEvaluators",
			"MenuListHelpWindows",
			"MenuListNotebookEvaluators",
			"MenuListNotebooksMenu",
			"MenuListPackageWindows",
			"MenuListPalettesMenu",
			"MenuListPaletteWindows",
			"MenuListPlayerWindows",
			"MenuListPrintingStyleEnvironments",
			"MenuListQuitEvaluators",
			"MenuListScreenStyleEnvironments",
			"MenuListStartEvaluators",
			"MenuListStyleDefinitions",
			"MenuListStyles",
			"MenuListStylesheetWindows",
			"MenuListTextWindows",
			"MenuListWindows",
			"PrintingStyleEnvironment",
			"ScreenStyleEnvironment",
			"Style"
			}
		};


(* ::Subsubsection::Closed:: *)
(*AddAutocompletions Base*)


PackageAddAutocompletions[pats:{(_String->{$PackageAutoCompletionFormats..})..}]:=
	If[$Notebooks&&
		Internal`CachedSystemInformation["FrontEnd","VersionNumber"]>10.0,
		FrontEndExecute@FrontEnd`Value@
			Map[
				FEPrivate`AddSpecialArgCompletion[#]&,
				pats
				],
		$Failed
		];
PackageAddAutocompletions[pat:(_String->{$PackageAutoCompletionFormats..})]:=
	PackageAddAutocompletions[{pat}];


(* ::Subsubsection::Closed:: *)
(*AddAutocompletions Helpers*)


$PackageAutocompletionAliases=
	{
		"None"|None|Normal->0,
		"AbsoluteFileName"|AbsoluteFileName->2,
		"FileName"|File|FileName->3,
		"Color"|RGBColor|Hue|XYZColor->4,
		"Package"|Package->7,
		"Directory"|Directory->8,
		"Interpreter"|Interpreter->9,
		"Notebook"|Notebook->"MenuListNotebooksMenu",
		"StyleSheet"->"MenuListStylesheetMenu",
		"Palette"->"MenuListPalettesMenu",
		"Evaluator"|Evaluator->"MenuListGlobalEvaluators",
		"FontFamily"|FontFamily->"MenuListFonts",
		"CellTag"|CellTags->"MenuListCellTags",
		"FormatType"|FormatType->"MenuListDisplayAsFormatTypes",
		"ConvertFormatType"->"MenuListConvertFormatTypes",
		"DisplayAsFormatType"->"MenuListDisplayAsFormatTypes",
		"GlobalEvaluator"->"MenuListGlobalEvaluators",
		"HelpWindow"->"MenuListHelpWindows",
		"NotebookEvaluator"->"MenuListNotebookEvaluators",
		"PrintingStyleEnvironment"|PrintingStyleEnvironment->
			"PrintingStyleEnvironment",
		"ScreenStyleEnvironment"|ScreenStyleEnvironment->
			ScreenStyleEnvironment,
		"QuitEvaluator"->"MenuListQuitEvaluators",
		"StartEvaluator"->"MenuListStartEvaluators",
		"StyleDefinitions"|StyleDefinitions->
			"MenuListStyleDefinitions",
		"CharacterEncoding"|CharacterEncoding|
			ExternalDataCharacterEncoding->
			"ExternalDataCharacterEncoding",
		"Style"|Style->"Style",
		"Window"->"MenuListWindows"
		};


(* ::Subsubsection::Closed:: *)
(*AddAutocompletions Convenience*)


$PackageAutocompletionTable={
	f:$PackageAutoCompletionFormats:>f,
	Sequence@@$PackageAutocompletionAliases,
	s_String:>{s}
	};


PackageAddAutocompletions[o:{__Rule}]/;(!TrueQ@$recursionProtect):=
	Block[{$recursionProtect=True},
		Replace[
			PackageAddAutocompletions@
				Replace[o,
					(s_->v_):>
						(Replace[s,_Symbol:>SymbolName[s]]->
							Replace[
								Flatten[{v},1],
								$PackageAutocompletionTable,
								1
								]),
					1
					],
			_PackageAddAutocompletions->$Failed
			]
		];
PackageAddAutocompletions[s:Except[_List],v_]:=
	PackageAddAutocompletions[{s->v}];
PackageAddAutocompletions[l_,v_]:=
	PackageAddAutocompletions@
		Flatten@{
			Quiet@
				Check[
					Thread[l->v],
					Map[l->#&,v]
					]
			};


(*PackageAddAutocompletions[PackageAddAutocompletions,
	{None,
		Join[
			Replace[Keys[$PackageAutocompletionAliases],
				Verbatim[Alternatives][s_,___]:>s,
				1
				],
			{FileName,AbsoluteFileName}/.$PackageAutocompletionAliases
			]
		}
	]*)


(* ::Subsubsection::Closed:: *)
(* PackageSetAutocompletionData *)


PackageSetAutocompletionData[]:=
	If[DirectoryQ@
			FileNameJoin@{
					$PackageDirectory,
					"Resources",
					"FunctionalFrequency"
					},
		CurrentValue[
		$FrontEndSession,
			{PrivatePaths,"AutoCompletionData"}
			]=
			DeleteDuplicates@
				Append[
					CurrentValue[
						$FrontEndSession,
						{PrivatePaths,"AutoCompletionData"}
						],
					FileNameJoin@{
						$PackageDirectory,
						"Resources",
						"FunctionalFrequency"
						}
					]
		];
(* ::Subsection:: *)
(*FrontEnd*)


(* ::Subsubsection::Closed:: *)
(*PackageFEInstallStylesheets *)


PackageFEInstallStylesheets[]:=
	With[{
		base=
			FileNameJoin@{
				$PackageDirectory,
				"FrontEnd",
				"StyleSheets",
				$PackageName
				},
		target=
			FileNameJoin@{
					$UserBaseDirectory,
					"SystemFiles",
					"FrontEnd",
					"StyleSheets",
					$PackageName}
		},
		If[DirectoryQ@base,
			Do[
				Quiet@
					CreateFile[
						FileNameJoin@{
							target,
							FileNameDrop[f,FileNameDepth[base]]
							},
						CreateIntermediateDirectories->True
						];
				CopyFile[f,
					FileNameJoin@{
						target,
						FileNameDrop[f,FileNameDepth[base]]
						},
					OverwriteTarget->True],
				{f,FileNames["*.nb",base,\[Infinity]]}
				]
			]
		];


(* ::Subsubsection::Closed:: *)
(*PackageFEInstallPalettes *)


PackageFEInstallPalettes[]:=
	With[{
		base=
			FileNameJoin@{
				$PackageDirectory,
				"FrontEnd",
				"Palettes",
				$PackageName
				},
		target=
			FileNameJoin@{
					$UserBaseDirectory,
					"SystemFiles",
					"FrontEnd",
					"Palettes",
					$PackageName}
		},
		If[DirectoryQ@base,
			Do[
				Quiet@
					CreateFile[
						FileNameJoin@{
							target,
							FileNameDrop[f,FileNameDepth[base]]
							},
						CreateIntermediateDirectories->True
						];
				CopyFile[f,
					FileNameJoin@{
						target,
						FileNameDrop[f,FileNameDepth[base]]
						},
					OverwriteTarget->True],
				{f,FileNames["*.nb",base,\[Infinity]]}
				]
			]
		];


(* ::Subsubsection::Closed:: *)
(*PackageFEHiddenBlock*)


$PackageFEHideExprSymbols=TrueQ[$PackageFEHideExprSymbols];
$PackageFEHideEvalExpr=TrueQ[$PackageFEHideEvalExpr];
PackageFEHiddenBlock[expr_,
	hide:True|False|Automatic:Automatic,
	eval:True|False|Automatic:Automatic
	]/;TrueQ[$AllowPackageRecoloring]:=
	If[!$PackageDeclared&&ListQ@$PackageFEHiddenSymbols,
		With[{
			s=
				Cases[
					HoldComplete[expr],
					sym_Symbol?(
						Function[Null,
							MemberQ[$PackageContexts,Quiet[Context[#]]],
							HoldAllComplete
							]
						):>
						HoldPattern[sym],
					\[Infinity]
					]
			},
			$PackageFEHiddenSymbols=
				{
					$PackageFEHiddenSymbols,
					s
					}
			],
		Block[{feBlockReturn},
			Internal`SymbolList[False];
			feBlockReturn=If[Replace[eval,Automatic:>$PackageFEHideEvalExpr],expr];
			If[Replace[hide,Automatic:>$PackageFEHideExprSymbols],
				With[{
					s=
						Cases[
							HoldComplete[expr],
							sym_Symbol?(
								Function[Null,
									MemberQ[$PackageContexts,Quiet[Context[#]]],
									HoldAllComplete
									]
								):>
								HoldPattern[sym],
							\[Infinity]
							]
					},
					Replace[Thread[s,HoldPattern],
						Verbatim[HoldPattern][{sym__}]:>
							PackageFERehideSymbols[sym]
						]
					]
				];
			Internal`SymbolList[True];
			feBlockReturn
			]
		];
PackageFEHiddenBlock[expr_,
	hide:True|False|Automatic:Automatic,
	eval:True|False|Automatic:Automatic
	]/;Not@TrueQ[$AllowPackageRecoloring]:=
	If[eval, expr];
PackageFEHiddenBlock~SetAttributes~HoldFirst


(* ::Subsubsection::Closed:: *)
(*PackageFEUnhideSymbols*)


PackageFEUnhideSymbols[syms__Symbol,
	cpath:{__String}|Automatic:Automatic,
	mode:"Update"|"Set":"Update"
	]/;TrueQ[$AllowPackageRecoloring]:=
	With[{stuff=
		Map[
			Function[Null,
				{Context@#,SymbolName@Unevaluated@#},
				HoldAllComplete],
			HoldComplete[syms]
			]//Apply[List]
		},
		KeyValueMap[
			FrontEndExecute@
			If[mode==="Update",
				FrontEnd`UpdateKernelSymbolContexts,
				FrontEnd`SetKernelSymbolContexts
				][
				#,
				Replace[cpath,Automatic->$ContextPath],
				{{#,{},{},#2,{}}}
				]&,
			GroupBy[stuff,First->Last]
			];
		];
PackageFEUnhideSymbols[names_String,
	mode:"Update"|"Set":"Update"]/;TrueQ[$AllowPackageRecoloring]:=
	Replace[
		Thread[ToExpression[Names@names,StandardForm,Hold],Hold],
		Hold[{s__}]:>PackageFEUnhideSymbols[s,mode]
		];
PackageFEUnhideSymbols~SetAttributes~HoldAllComplete;


(* ::Subsubsection::Closed:: *)
(*PackageFERehideSymbols*)


PackageFERehideSymbols[syms__Symbol,
	cpath:{__String}|Automatic:Automatic,
	mode:"Update"|"Set":"Update"]/;TrueQ[$AllowPackageRecoloring]:=
	With[{stuff=
		Map[
			Function[Null,
				{Context@#,SymbolName@Unevaluated@#},
				HoldAllComplete],
			HoldComplete[syms]
			]//Apply[List]
		},
		KeyValueMap[
			FrontEndExecute@
			If[mode==="Update",
				FrontEnd`UpdateKernelSymbolContexts,
				FrontEnd`SetKernelSymbolContexts
				][
				#,
				Replace[cpath,
					Automatic->$ContextPath
					],
				{{#,{},#2,{},{}}}
				]&,
			GroupBy[stuff,First->Last]
			];
		];
PackageFERehideSymbols[names_String,
	mode:"Update"|"Set":"Update"]/;TrueQ[$AllowPackageRecoloring]:=
	Replace[
		Thread[ToExpression[Names@names,StandardForm,Hold],Hold],
		Hold[{s__}]:>PackageFERehideSymbols[s,mode]
		];
PackageFERehideSymbols~SetAttributes~HoldAllComplete;


(* ::Subsubsection::Closed:: *)
(*PackageFEUnhidePackage*)


PackageFEUnhidePackage[
	package_String?FileExistsQ,
	a___
	]/;TrueQ[$AllowPackageRecoloring]:=
	Replace[Thread[Lookup[$DeclaredPackages,package,{}],HoldPattern],
		Verbatim[HoldPattern][{syms__}]:>
			PackageFEUnhideSymbols[syms,a]
		];
PackageFEUnhidePackage[spec:_String|_List,a___]/;TrueQ[$AllowPackageRecoloring]:=
	PackageFEUnhidePackage[PackageFilePath@Flatten@{"Packages",spec},a];


(* ::Subsubsection::Closed:: *)
(*PackageFERehidePackage*)


PackageFERehidePackage[
	package_String?FileExistsQ,
	a___
	]/;TrueQ[$AllowPackageRecoloring]:=
	Replace[Thread[Lookup[$DeclaredPackages,package,{}],HoldPattern],
		Verbatim[HoldPattern][{syms__}]:>
			PackageFERehideSymbols[syms,a]
		];
PackageFERehidePackage[spec:_String|_List,a___]/;TrueQ[$AllowPackageRecoloring]:=
	PackageFERehidePackage[PackageFilePath@Flatten@{"Packages",spec},a];


(* ::Subsection:: *)
(*Post-Processing*)


(* ::Subsubsection::Closed:: *)
(*PrepFileName*)


PackagePostProcessFileNamePrep[fn_]:=
		Replace[
			FileNameSplit@
				FileNameDrop[fn,
					FileNameDepth@
						PackageFilePath["Packages"]
					],{
			{f_}:>
				f|fn|StringTrim[f,".m"|".wl"],
			{p__,f_}:>
				FileNameJoin@{p,f}|fn|{p,StringTrim[f,".m"|".wl"]}
			}]


(* ::Subsubsection::Closed:: *)
(*PrepSpecs*)


PackagePostProcessPrepSpecs[]:=
	(
		Unprotect[
			$PackagePreloadedPackages,
			$PackageHiddenPackages,
			$PackageHiddenContexts,
			$PackageExposedContexts,
			$PackageDecontextedPackages
			];
		If[FileExistsQ@PackageFilePath["Config","LoadInfo.m"],
			Replace[
				$PackageLoadSpecs,
				specs:{__Rule}|_Association:>
					CompoundExpression[
						$PackagePreloadedPackages=
							Replace[
								Lookup[specs,"PreLoad"],
								Except[{__String}]->{}
								],
						$PackageHiddenPackages=
							Replace[
								Lookup[specs,"FEHidden"],
								Except[{__String}]->{}
								],
						$PackageDecontextedPackages=
							Replace[
								Lookup[specs,"PackageScope"],
								Except[{__String}]->{}
								],
						$PackageExposedContexts=
							Replace[
								Lookup[specs,"ExposedContexts"],
								Except[{__String}]->{}
								]
						]
				]
			]
		);


(* ::Subsubsection::Closed:: *)
(*ExposePackages*)


PackagePostProcessExposePackages[]/;TrueQ[$AllowPackageRecoloring]:=
	(
		PackageAppGet/@
			$PackagePreloadedPackages;
		With[{
			syms=
				If[
					!MemberQ[$PackageHiddenPackages,
						PackagePostProcessFileNamePrep[#]
						],
					$DeclaredPackages[#],
					{}
					]&/@Keys@$DeclaredPackages//Flatten
			},
			Replace[
				Thread[
					If[ListQ@$PackageFEHiddenSymbols,
						DeleteCases[syms,
							Alternatives@@
								(Verbatim[HoldPattern]/@Flatten@$PackageFEHiddenSymbols)
							],
						syms
						],
					HoldPattern],
				Verbatim[HoldPattern][{s__}]:>
					PackageFEUnhideSymbols[s]
				]
			]
		)




(* ::Subsubsection::Closed:: *)
(*Rehide Packages*)


PackagePostProcessRehidePackages[]/;TrueQ[$AllowPackageRecoloring]:=
	If[
		MemberQ[$PackageHiddenPackages,
			PackagePostProcessFileNamePrep[#]
			],
		PackageFERehidePackage@#
		]&/@Keys@$DeclaredPackages


(* ::Subsubsection::Closed:: *)
(*Decontext*)


PackagePostProcessDecontextPackages[]/;TrueQ[$AllowPackageRecoloring]:=
	(
		If[
			MemberQ[$PackageDecontextedPackages,
				PackagePostProcessFileNamePrep[#]
				],
			PackageFERehidePackage@#;
			PackageDecontext@#
			]&/@Keys@$DeclaredPackages;
		If[ListQ@$PackageScopedSymbols,
			KeyValueMap[
				With[{newcont=#},
					Replace[Join@@#2,
						HoldComplete[s__]:>
							(
								PackageFERehideSymbols[s];
								Map[
									Function[Null,
										Quiet[
											Check[
												Set[Context[#],newcont],
												Remove[#],
												Context::cxdup
												],
											Context::cxdup
											],
										HoldAllComplete
										],
									HoldComplete[s]
									]//ReleaseHold;
								)
						]
					]&,
				GroupBy[Flatten@$PackageScopedSymbols,First->Last]
				];
			]
		)




(* ::Subsubsection::Closed:: *)
(*ContextPathReassign*)


PackagePostProcessContextPathReassign[]:=
	With[{cp=$ContextPath},
		If[MemberQ[cp],
			"ChemTools`",
			$ContextPath=
				Join[
					Replace[
						Flatten@{$PackageExposedContexts},
						Except[_String?(StringEndsQ["`"])]->Nothing,
						1
						],
					$ContextPath
					];
			If[TrueQ[$AllowPackageRecoloring], 
				FrontEnd`Private`GetUpdatedSymbolContexts[]
				];
			]
		]


(* ::Subsection:: *)
(*End*)


End[];


(* ::Section:: *)
(* Load *)


If[`PackageScope`Private`$AllowPackageRecoloring,
	Internal`SymbolList[False]
	];


(* ::Subsubsection:: *)
(*Basic Load*)


`PackageScope`Private`$loadAbort=False;
CheckAbort[
	`PackageScope`Private`PackageAppLoad[];
	`PackageScope`Private`$PackageFEHideExprSymbols=True;
	`PackageScope`Private`$PackageFEHideEvalExpr=True;
	`PackageScope`Private`$PackageScopeBlockEvalExpr=True;
	`PackageScope`Private`$PackageDeclared=True;,
	`PackageScope`Private`$loadAbort=True;
	EndPackage[];
	];
Protect["`PackageScope`Private`*"];
Unprotect[`PackageScope`Private`$loadAbort];


(* ::Subsubsection:: *)
(*Post-Process*)


If[!`PackageScope`Private`$loadAbort,
	`PackageScope`Private`PackagePostProcessPrepSpecs[];
	`PackageScope`Private`PackagePostProcessExposePackages[];
	`PackageScope`Private`PackagePostProcessRehidePackages[];
	`PackageScope`Private`PackagePostProcessDecontextPackages[];
	]


Unprotect[`PackageScope`Private`$PackageFEHiddenSymbols];
Clear[`PackageScope`Private`$PackageFEHiddenSymbols];
Unprotect[`PackageScope`Private`$PackageScopedSymbols];
Clear[`PackageScope`Private`$PackageScopedSymbols];


(* ::Subsubsection:: *)
(*Preempt Shadowing*)


(* Hide `PackageScope`Private` shadowing *)


Replace[
	Hold[{`PackageScope`Private`m___}]:>
		Off[`PackageScope`Private`m]
		]@
Thread[
	ToExpression[
		Map[#<>"$"&, Names["`PackageScope`Private`*"]
		],
		StandardForm,
		Function[Null, 
			Hold[MessageName[#, "shdw"]],
			HoldAllComplete
			]
		],
	Hold
	]


(* ::Subsubsection:: *)
(*EndPackage / Reset $ContextPath*)


EndPackage[];


If[(Clear@ChemTools`PackageScope`Private`$loadAbort;!#)&@ChemTools`PackageScope`Private`$loadAbort,
	ChemTools`PackageScope`Private`PackagePostProcessContextPathReassign[]
	]