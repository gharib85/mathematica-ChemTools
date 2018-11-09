(* ::Package:: *)

(* Autogenerated Package *)

(* ::Section:: *)
(*Wavefunction Tools*)



(* ::Subsubsection::Closed:: *)
(*Parts*)



ChemWavefunctionsPart::usage=
  "Applies part to a wavefunction";
ChemWavefunctionsKeyPart::usage=
  "Applies key lookup to a wavefunction";


(* ::Subsubsection::Closed:: *)
(*Creation*)



ChemSeparableWavefunctions::usage=
  "Function for doing 1D SCF averaging of a potential with a DVR";


(* ::Subsubsection::Closed:: *)
(*Combination*)



ChemProductWavefunctions::usage=
  "Creates product wavefunctions out of 1D wavefunctions";


(* ::Subsubsection::Closed:: *)
(*ExpectationValues*)



ChemExpectationValues::usage=
  "Expectation values over a normalized, discretized set of wavefunctions";
ChemWavefunctionsOperatorMatrix::usage=
  "Operator matrix over a normalized, discretized set of wavefunctions";
ChemWavefunctionsOperatorMatrixElements::usage=
  "Operator matrix elements over a normalized, discretized set of wavefunctions";


Begin["`Private`"];


(* ::Subsection:: *)
(*Wavefunction Parts*)



(* ::Subsubsection::Closed:: *)
(*ChemWavefunctionsPart*)



ChemWavefunctionsPart[c_ChemWavefunctionsObject, sel_]:=
  ChemWavefunctionsObject@
    MapAt[
      Part[#, If[IntegerQ@sel, {sel}, sel]]&,
      Normal@c,
      {"Energies", "Wavefunctions"}
      ]
ChemWavefunctionsPart[c_ChemWavefunctionsObject, All, p__]:=
  ChemWavefunctionsObject@
    MapAt[
      Part[#, All, p]&,
      MapAt[
        Part[#, p]&, 
        Normal@c,
        "GridPoints"
        ],
      "Wavefunctions"
      ];
ChemWavefunctionsPart[c_ChemWavefunctionsObject, sel_, p__]:=
  ChemWavefunctionsObject@
    MapAt[
      Part[#, 
        If[IntegerQ@sel, {sel}, sel], 
        p
        ]&,
      MapAt[
        Part[#, p]&, 
        MapAt[
          Part[#, If[IntegerQ@sel, {sel}, sel]]&,
          Normal@c,
          "Energies"
          ],
        "GridPoints"
        ],
      "Wavefunctions"
      ];


(* ::Subsubsection::Closed:: *)
(*ChemWavefunctionsKeyPart*)



ChemWavefunctionsKeyPart[c:ChemWavefunctionsObject[a_], sel__]:=
  a[sel]


(* ::Subsection:: *)
(*WavefunctionNormalize*)



WavefunctionNormalize[wfs_]:=
  wfs/Map[Norm, wfs];
ChemWavefunctionsNormalize[c_ChemWavefunctionsObject]:=
  MapAt[WavefunctionNormalize, c, "Wavefunctions"];


(* ::Subsection:: *)
(*NormalizedQ*)



ChemWavefunctionsNormalizedQ[c_ChemWavefunctionsObject]:=
  AllTrue[Norm/@c["Wavefunctions"], #==1&];


(* ::Subsection:: *)
(*WavefunctionsProduct*)



ChemWavefunctionsProduct[
  wfns1_ChemWavefunctionsObject,
  wfnsother__ChemWavefunctionsObject,
  n:_Integer?Positive|All|Automatic:Automatic
  ]:=
  Module[
    {
      numCombo,
      normals=Normal/@{wfns1, wfnsother},
      grids,
      energies,
      wavefunctions,
      indices,
      grid
      },
    grids=normals[[All, "GridPoints"]];
    energies=normals[[All, "Energies"]];
    numCombo=
      Replace[
        OptionValue["NumberOfCombinations"], 
        {
          All:>
            Apply[Times, Length/@energies],
          i_Integer?Positive:>
            Min@{i, Apply[Times, Length/@energies]},
          Automatic:>
            Min@{50, Apply[Times, Length/@energies]}
          }
        ];
    {indices, energies}=ChemUtilsProductEnergies[energies, numCombo];
    wavefunctions=
      Map[
        Join@@
          KroneckerProduct[
            Sequence@@
              MapThread[#[["Wavefunctions", #2]]&,
                {normals, #}
                ]
            ]&, 
        indices
        ];
    grid=Flatten[Outer[Flatten@*List, Sequence@@grids], Length@grids-1];
    ChemWavefunctionsObject@
      Merge[
        {
          KeyDrop[#, {"Grid", "Energies", "Wavefunctions"}]&/@
            normals,
          "Grid"->grid,
          "Energies"->energies,
          "Wavefunctions"->wavefunctions
          },
        Last
        ]
    ]


(* ::Subsection:: *)
(*ChemDVRDefaultGridWavefunctions*)



(* ::Subsubsection::Closed:: *)
(*iChemDVRDefaultThreadGridWavefunctions*)



iChemDVRDefaultThreadGridWavefunctions[gps_, wfns_, retE_]:=
  Module[
    {
      grid=gps
      },
      If[!ListQ@First@grid,
        grid=List/@grid
        ];
    grid=Developer`ToPackedArray@grid;
    If[retE, 
      MapThread[
        #->Join[grid, List/@#2, 2]&,
        wfns
        ],
      Map[
        Join[grid, List/@#, 2]&, 
        wfns[[2]]
        ]
      ]
    ];


(* ::Subsubsection::Closed:: *)
(*ChemDVRDefaultGridWavefunctions*)



Options[ChemDVRDefaultGridWavefunctions]=
  Join[
    {
      "ReturnEnergies"->False,
      "PruningEnergy"->None
      },
    Options[ChemDVRDefaultWavefunctionSelection],
    Options[ChemDVRDefaultGridPointList]
    ];
ChemDVRDefaultGridWavefunctions[
  grid_, 
  wfs_,
  V_,
  o:OptionsPattern[]
  ]:=
  With[
    {
      coreGridPoints=
        ChemDVRDefaultPruneGridPoints[
          ChemDVRDefaultGridPointList[grid, 
            FilterRules[{o}, Options@ChemDVRDefaultGridPointList]
            ],
          V,
          OptionValue["PruningEnergy"]
          ],
      wfns=
        ChemDVRDefaultWavefunctionSelection[
          ReleaseHold@wfs,
          FilterRules[{o}, Options[ChemDVRDefaultWavefunctionSelection]]
          ],
      retE=TrueQ@OptionValue["ReturnEnergies"]
      },
    iChemDVRDefaultThreadGridWavefunctions[
      coreGridPoints,
      wfns,
      retE
      ]
    ];


(* ::Subsection:: *)
(*ChemDVRDefaultInterpolatingWavefunctions*)



Options[ChemDVRDefaultInterpolatingWavefunctions]=
  Options@ChemDVRDefaultGridWavefunctions;
ChemDVRDefaultInterpolatingWavefunctions[
  grid_,
  wfs_,
  V_,
  ops:OptionsPattern[]
  ]:=
  With[
    {wf=ChemDVRDefaultGridWavefunctions[grid, wfs, V, ops]},
    If[MatchQ[wf[[1]], _Rule],
      #[[1]]->Interpolation[#[[2]]]&,
      Interpolation
      ]/@wf
    ]


(* ::Subsection:: *)
(*ExpectationValues*)



(* ::Subsubsection::Closed:: *)
(*expectationValue*)



expectationValueVec[func_, grid_]:=
  Replace[func@grid, 
    Except[_List?(Length[#]==Length@grid&)]:>Map[func, grid]
    ];
expectationValueVec[func_, grid_, wf_]:=
  Replace[func[grid, wf],
    Except[_List?(Length[#]==Length@grid&)]:>
      MapThread[func, {grid, wf}]
    ];


multiplicativeOperatorQ[func_Function]:=
  !(MemberQ[func, Slot[2], \[Infinity]]||
      MatchQ[func, Verbatim[Function][{_, _}, ___]]);
multiplicativeOperatorQ[e_]:=
  False;


expectationValue[
  func_Function, grid_, wfL_, wfR_,
  multiplicative_
  ]:=
  wfL.
    With[
      {
        mult=
          If[multiplicative===Automatic,
            multiplicativeOperatorQ[func],
            TrueQ@multiplicative
            ]
        },
      If[!mult,
        expectationValue[func, grid, wfR],
        wfR*expectationValue[func, grid]
        ]
    ];
expectationValue[func:Except[_Function], grid_, wfL_, wfR_,
  multiplicative_
  ]:=
  wfL.Replace[expectationValueVec[func, grid, wfR],
    {
      {_func, __}:>
        Replace[expectationValueVec[func, grid],
          {
            {_func, __}:>
              PackageRaiseException[
                Automatic,
                "Operator `` in matrix element calculation didn't evaluate",
                func
                ],
            l_:>wfR*l
            }
          ]
      }
    ]


(* ::Subsubsection::Closed:: *)
(*operatorMatrix*)



operatorMatrix[exf_, grid_, wfnsL_, wfnsR_, assumeRealSym_, assumeHerm_, mult_]:=
  Block[
    {
      mat=ConstantArray[0., {Length@wfnsL, Length@wfnsR}],
      asrs=TrueQ@assumeRealSym,
      ash=TrueQ@assumeHerm,
      mo=mult
      },
  Which[
    asrs,
      Do[
        If[i>j, 
          mat[[i, j]]=mat[[j, i]],
          mat[[i, j]]=
            expectationValue[exf, grid, wfnsL[[i]], wfnsR[[j]], mo]
          ],
        {i, Length@wfnsL},
        {j, Length@wfnsR}
        ],
    ash,
      Do[
        If[i>j, 
          mat[[i, j]]=Conjugate@mat[[j, i]],
          mat[[i, j]]=
            expectationValue[exf, grid, wfnsL[[i]], wfnsR[[j]], mo]
          ],
        {i, Length@wfnsL},
        {j, Length@wfnsR}
        ],
    True,
      Do[
        mat[[i, j]]=
          expectationValue[exf, grid, wfnsL[[i]], wfnsR[[j]], mo],
        {i, Length@wfnsL},
        {j, Length@wfnsR}
        ]
    ]
  ]


(* ::Subsubsection::Closed:: *)
(*ExpectationValues*)



Options[ChemWavefunctionsExpectationValues]=
  {
    "MultiplicativeOperator"->Automatic
    };
ChemWavefunctionsExpectationValues[
  {grid_, wfns_},
  evs_,
  ops:OptionsPattern[]
  ]:=
  With[
    {
      exfns=Flatten@List@evs,
      mul=OptionValue["MultiplicativeOperator"]
      },
      If[Not@ListQ@evs, Map[First], Identity]@
        Table[
          Map[
            expectationValue[#, grid, wf, wf, mul]&,
            exfns
            ],
          {wf, wfns}
          ]
    ];
ChemWavefunctionsOperatorMatrix[
  c_ChemWavefunctionsObject,
  evs_,
  ops:OptionsPattern[]
  ]:=
  ChemWavefunctionsOperatorMatrix[
    {c["Grid"], c["Wavefunctions"]},
    evs,
    ops
    ];


(* ::Subsubsection::Closed:: *)
(*OperatorMatrix*)



Options[ChemWavefunctionsOperatorMatrix]=
  Join[
    Options@ChemWavefunctionsExpectationValues,
    {
      "AssumeSymmetric"->True,
      "AssumeHermitian"->False
      }
    ];
ChemWavefunctionsOperatorMatrix[
  {grid_, wfns_},
  evs_,
  ops:OptionsPattern[]
  ]:=
  Module[
    {
      exfns=Flatten@List@evs,
      els,
      sels,
      mat,
      asrs=TrueQ@OptionValue["AssumeSymmetric"],
      ash=TrueQ@OptionValue["AssumeHermitian"],
      mul=OptionValue["MultiplicativeOperator"],
      exf,
      mo
      },
      If[!ListQ@mul, mul=ConstantArray[mul, Length@exfns]];
      Table[
        exf=exfns[[n]];
        mo=mul[[n]];
        mat=ConstantArray[0., {Length@wfns, Length@wfns}];
        operatorMatrix[exf, grid, wfns, wfns, asrs, ash, mo],
        {n, Length@exfns}
        ]
    ];
ChemWavefunctionsOperatorMatrix[
  c_ChemWavefunctionsObject,
  evs_,
  ops:OptionsPattern[]
  ]:=
  ChemWavefunctionsOperatorMatrix[
    {c["Grid"], c["Wavefunctions"]},
    evs,
    ops
    ]


(* ::Subsubsection::Closed:: *)
(*ChemWavefunctionsOperatorMatrixElements*)



Options[ChemWavefunctionsOperatorMatrixElements]=
  Options@ChemWavefunctionsOperatorMatrix;
ChemWavefunctionsOperatorMatrixElements[
  {grid_, wfns_},
  evs:
    (({_, _}->_)|
    ({{_, _}...}->_)|
    {(({{_, _}...}|{_, _})->_)..}),
  ops:OptionsPattern[]
  ]:=
  Module[
    {
      exfns=Flatten@List@evs,
      els,
      sels,
      mat,
      asrs=TrueQ@OptionValue["AssumeSymmetric"],
      ash=TrueQ@OptionValue["AssumeHermitian"],
      mul=OptionValue["MultiplicativeOperator"],
      exf,
      mo,
      wfL,
      wfR,
      res
      },
    {sels, exfns}=Transpose[List@@@exfns];
    (* get a list of LHS wavefunctions and RHS wavefunctions for each set of expectation value functions *)
    wfL=
      Map[
        Map[
          Part[wfns, #]&,
          Replace[
            Replace[#, k:{Except[_List], _}:>{k}][[All, 1]], 
            i_Integer:>{i},
            1
            ]
          ]&,
        sels
        ];
    wfR=
      Map[
        Map[
          Part[wfns, #]&,
          Replace[
            Replace[#, k:{Except[_List], _}:>{k}][[All, 2]], 
            i_Integer:>{i},
            1
            ]
          ]&,
        sels
        ];
    If[!ListQ@mul, mul=ConstantArray[mul, Length@exfns]];
    (* Thread over the right and left wavefunctions, the operators, and the multiplicativity *)
    res=
      MapThread[
        With[{l=#, r=#2, m=If[ListQ@#3&&!ListQ@#4, ConstantArray[#4, Length@#3], #4]},
          (* Thread over the operators and multiplicativity *)
          If[Length@#3==1, First, Identity]@
            MapThread[
              If[Length@wfL>1||Length@wfR>1,
                operatorMatrix[exf, grid, wfL, wfR, asrs, ash, mo],
                expectationValue[exf, grid, wfL[[1]], wfR[[1]], mo]
                ],
              {
                #3,
                m
                }
              ]
          ]&,
        {
          wfL,
          wfR,
          exfns,
          mul
          }
        ];
    If[Length@wfL==1, res[[1]], res]
    ];


ChemWavefunctionsOperatorMatrixElements[
  c_ChemWavefunctionsObject,
  evs:
    (({_, _}->_)|
    ({{_, _}...}->_)|
    {(({{_, _}...}|{_, _})->_)..}),
  ops:OptionsPattern[]
  ]:=
  ChemWavefunctionsOperatorMatrixElements[
    {c["Grid"], c["Wavefunctions"]},
    evs,
    ops
    ]


End[];



