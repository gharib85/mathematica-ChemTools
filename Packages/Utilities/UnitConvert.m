(* ::Package:: *)

(* Autogenerated Package *)

ChemUnitConvert::usage=
  "Adds support to UnitConvert for non-standard unit conversions. Not fully developed.";


Begin["`Private`"];


(* ::Subsection:: *)
(*UnitConvert*)



(* ::Text:: *)
(*
	Attempts to find the best unit type for the given unit in terms of the possible unit conversions available
*)



(* ::Subsubsection::Closed:: *)
(*UnitManipulationUtilities*)



(*iChemUnitConversionTypeMap[]:=
	AssociationMap[
			iChemUnitDimMap/@StringSplit[#, "To"]&,
			StringTrim[
				Select[Keys@ChemDataLookup[All, "UnitConversions"], 
					StringMatchQ[__~~"To"~~__]
					],
				"Units"|"Magnitude"
				]
			]*)


(*iChemUnitDimMap[u_List]:=
	AssociationThread@@Thread[u]
iChemUnitDimMap[u_]:=
	iChemUnitDimMap@UnitDimensions[u]*)


(*iChemUnitReducedForms[unitMap_, forms_]:=
	Map[
		Join[unitMap, 
			AssociationThread[
				Keys[#],
				Lookup[unitMap, Keys[#], 0]+Values[#]
				]
			]&,
		forms
		]*)


(* ::Subsubsection::Closed:: *)
(*Custom UnitConvert*)



(* ::Subsubsubsection::Closed:: *)
(*addUnitConvertRule*)



addUnitConvertRule[key_->Quantity[val_, unit_]]:=
  With[
    {
      customKey=Symbol["CalculateUnits`UnitCommonSymbols`"<>key]
      },
    If[Not@KeyExistsQ[QuantityUnits`Private`$UnitReplacementRules, key],
      AppendTo[QuantityUnits`Private`$UnitReplacementRules, key->customKey]
      ];
    CalculateUnits`UnitCommonSymbols`KnownUnit0Q[customKey]=True;
    With[{uc=UnitConvert[unit]},
      With[{uval=
          val*QuantityMagnitude[uc]*QuantityUnit[uc]/.{
            s_String:>Lookup[QuantityUnits`Private`$UnitReplacementRules, s]
            }//.u_Symbol?CalculateUnits`UnitCommonSymbols`KnownUnit0Q:>
          Replace[
            CalculateUnits`UnitCommonSymbols`UnitLookup[u, "FundamentalUnitValue"],
            _CalculateUnits`UnitCommonSymbols`UnitLookup:>u
            ]
          },
        CalculateUnits`UnitCommonSymbols`UnitLookup[customKey, "FundamentalUnitValue"]=
        uval;
        CalculateUnits`UnitTable`CUF0[customKey]=
          Evaluate[#*uval/.s_Symbol?CalculateUnits`UnitCommonSymbols`KnownUnit0Q:>1]&;
        CalculateUnits`UnitTable`CUF1[customKey]=
          Evaluate[#/uval/.s_Symbol?CalculateUnits`UnitCommonSymbols`KnownUnit0Q:>1]*#&
        ]
      ];
    CalculateUnits`UnitCommonSymbols`UnitLookup[customKey, "UnitDimensions"]=
    With[{uc=UnitDimensions[unit]},
      Apply[Times, Power@@@uc]/.s_String:>Symbol["CalculateUnits`UnitCommonSymbols`"<>s]
      ];
    ]


(* ::Subsubsubsection::Closed:: *)
(*copyFromLink*)



copyFromLink[link_, expr_]:=
  ((*For fast copies of mutable expressions*)
    LinkWrite[link, expr];
    LinkRead[link]
    );
copyFromLink[link_][expr_]:=
  copyFromLink[link, expr];


(* ::Subsubsubsection::Closed:: *)
(*withCustomConvertRules*)



withCustomConvertRules[
  expr_,
  rules:{
    (_->_Quantity)..
    },
  useCache:True|False:False
  ]:=
  With[{ll=LinkCreate[LinkMode->Loopback]},
    Internal`WithLocalSettings[
      None,
      Block[
        {
          QuantityUnits`Private`$CompatibleUnitQCache=
          If[useCache,
            copyFromLink[ll]@ QuantityUnits`Private`$CompatibleUnitQCache,
            System`Utilities`HashTable[]
            ],
          QuantityUnits`Private`$KnownUnitQCache=
          If[useCache,
            copyFromLink[ll]@QuantityUnits`Private`$KnownUnitQCache,
            System`Utilities`HashTable[]
            ],
          QuantityUnits`Private`$UnitDimensionsCache=
          If[useCache,
            copyFromLink[ll]@QuantityUnits`Private`$UnitDimensionsCache,
            System`Utilities`HashTable[]
            ],
           QuantityUnits`Private`$UnitReplacementRules=
          QuantityUnits`Private`$UnitReplacementRules
          },
        Internal`InheritedBlock[
          {
            CalculateUnits`UnitCommonSymbols`UnitLookup,
            CalculateUnits`UnitCommonSymbols`KnownUnit0Q,
            CalculateUnits`UnitTable`CUF0,
            CalculateUnits`UnitTable`CUF1
            },
          addUnitConvertRule/@rules;
          expr
          ]
        ],
      LinkClose[ll];
      ]
    ];
withCustomConvertRules~SetAttributes~HoldFirst


(* ::Subsubsection::Closed:: *)
(*iChemUnitConversion*)



(*iChemUnitConversionMagnitude[a_String, b_String]:=
	Replace[
		ChemDataLookup[a<>"To"<>b<>"Magnitude", "UnitConversions"],
		$Failed\[RuleDelayed]
			Replace[ChemDataLookup[b<>"To"<>a<>"Magnitude", "UnitConversions"],
				n:Except[$Failed]\[RuleDelayed]1/n
				]
		];
iChemUnitConversionUnits[a_String, b_String]:=
	Replace[
		ChemDataLookup[a<>"To"<>b<>"Units", "UnitConversions"],
		$Failed\[RuleDelayed]
			Replace[ChemDataLookup[b<>"To"<>a<>"Units", "UnitConversions"],
				n:Except[$Failed]\[RuleDelayed]Quantity[1/QuantityMagnitude@n, 1/QuantityUnit[n]]
				]
		];*)


(*iChemUnitConversionFallback[a_, b_]:=
	Module[
		{
			unitType=iChemUnitDimMap[a],
			targetType=iChemUnitDimMap[b],
			knownConversionTypes=iChemUnitConversionTypeMap[],
			redBaseForms,
			redTargForms
			},(*
		redBaseForms=
			iChemUnitReducedForms[];*)
		PackageRaiseException[
			Automatic,
			"Conversions outside of the known types not supported"
			]
		]*)


(*iChemUnitConversion[a_, b_]:=
	Catch[
		Map[
			Replace[#[a, b], e:Except[$Failed]\[RuleDelayed]Throw[e, UnitConversion]]&,
			{
				iChemUnitConversionMagnitude,
				iChemUnitConversionUnits,
				iChemUnitConversionFallback
				}
			],
		UnitConversion
		]*)


(* ::Subsubsection::Closed:: *)
(*ChemUnitConvert*)



(* ::Text:: *)
(*Need to handle listed cases cleaner...*)



getChemUnitsMap[]:=
  DeleteDuplicatesBy[First]@
    KeyValueMap[
      If[StringMatchQ[#, __~~"To"~~__~~"Magnitude"],
        With[
          {
            bt=
              Flatten@
                StringCases[#, base__~~"To"~~targ__~~"Magnitude":>{base, targ}]
            },
          "Chem"<>bt[[2]]->Quantity[1/#2, bt[[1]]]
          ],
        Nothing
        ]&,
      ChemDataLookup[All, "UnitConversions"]
      ]


withChemUnits[expr_]:=
  With[{cm=getChemUnitsMap[]},
    withCustomConvertRules[
      ReleaseHold[
        Hold[expr]/.
          Thread[StringTrim[Keys[cm], "Chem"]->Keys[cm]]
        ],
      cm
      ]//ReplaceAll[
      #/.Thread[Keys[cm]->StringTrim[Keys[cm], "Chem"]],
      HoldPattern@StructuredArray[QuantityArray, dim_, data_]:>
        StructuredArray[QuantityArray, dim, 
          ReplacePart[data,
            3->(data[[3]]/.Thread[Keys[cm]->StringTrim[Keys[cm], "Chem"]])
            ]
          ]
      ]&
    ]
withChemUnits~SetAttributes~HoldFirst


ChemUnitConvert[a_, targ_]:=
  PackageExceptionBlock["UnitConvert"]@
    (*Quiet@*)
      Check[
        Quiet[
          Check[
            UnitConvert[a, targ], 
            withChemUnits@UnitConvert[a, targ](*ChemUnitConvertFallthrough[a, targ]*), 
            Quantity::compat
            ],
          Quantity::compat  
          ],
        PackageRaiseException[Automatic,
          "Unable to convert `` to unit \"``\"",
          a, targ
          ]
        ];
ChemUnitConvert[a_List, targ_]:=
  ChemUnitConvert[#, targ]&/@a;


(* ::Subsubsection::Closed:: *)
(*ChemUnitConvertFallthrough*)



(*ChemUnitConvertFallthrough[v_Quantity, targ_]:=
	Replace[
		iChemUnitConversion[QuantityUnit@v, targ],
		{
			n_?NumericQ:>
				Quantity[n*QuantityMagnitude@v, targ],
			
			}
		]*)


(* ::Subsection:: *)
(*Autocompletions*)



Quiet@
  PackageAddAutocompletions[
    ChemUnitConvert,
    {
      None, 
      First@
        FileNames["Unit_Names.trie", 
          PacletManager`PacletFind["AutoCompletionData"][[1]]["Location"], 
          \[Infinity]
          ]
      }
    ]


End[];



