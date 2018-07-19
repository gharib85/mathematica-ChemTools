(* ::Package:: *)

(* Autogenerated Package *)

$ChemDVRDefaultPotentialFunctions::usage=
  "The list of potential functions and options built in";
ChemDVRDefaultNamedPotential::usage="";
ChemDVRDefaultPotentialEnergy::usage="";
ChemDVRDefaultGridPotentialEnergy::usage="";
ChemDVRDefaultDirectProductPotentialEnergy::usage="";
ChemDVRDefaultPrunePotentialEnergy::usage="";


Begin["`Private`"];


(* ::Subsubsection::Closed:: *)
(*$ChemDVRDefaultPotentialFunctions*)



$ChemDVRDefaultPotentialFunctions=
  {
    {"HarmonicOscillator", "ForceConstant", "EquilibriumBondLength"},
    {"MorseOscillator", "DissociationEnergy", "WellWidth", "EquilibriumBondLength"},
    {"MultiWellPolynomial", "TurningPoints", "Depth", "Minimum"},
    {"HinderedRotor", "WellNumber", "WellDepth", "Phase", "Minimum"},
    {"HinderedHalfRotor", "WellNumber", "WellDepth", "Phase", "Minimum"}
    };


(* ::Subsection:: *)
(*NamedPotential*)



ChemDVRObject::nonpot="Named potential `` unknown";


ChemDVRDefaultNamedPotential//Clear


(* ::Subsubsection::Closed:: *)
(*HarmonicOscillator*)



ChemDVRDefaultNamedPotential["HarmonicOscillator", ops___?OptionQ]:=
  With[
    {
      k=Lookup[{ops}, "ForceConstant", 1/2],
      re=Lookup[{ops}, "EquilibriumBondLength", 0]
      },
    k*(#-re)^2&
    ];


(* ::Subsubsection::Closed:: *)
(*MorseOscillator*)



ChemDVRDefaultNamedPotential["MorseOscillator", ops___?OptionQ]:=
  With[
    {
      de=Lookup[{ops}, "DissociationEnergy", 10],
      a=Lookup[{ops}, "WellWidth", 1],
      re=Lookup[{ops}, "EquilibriumBondLength", 0]
      },
    de*(1-Exp[-(1/a)*(#-re)])^2&
    ];


(* ::Subsubsection::Closed:: *)
(*MultiWellPolynomial*)



ChemDVRDefaultNamedPotential["MultiWellPolynomial", ops___?OptionQ]:=
  Module[
    {
      pos=Lookup[{ops}, "TurningPoints", {-1, 1}],
      dep=Lookup[{ops}, "Depth", 5],
      min=Lookup[{ops}, "Minimum", 0],
      mainPol,
      minValPos,
      minPos,
      minVal,
      minDiff
      },
    If[EvenQ@Length@pos,
      pos=Riffle[pos, MovingAverage[pos, 2]]
      ];
    mainPol=Integrate[Product[\[FormalX]p-t, {t, pos}], \[FormalX]p];
    minValPos={\[FormalI]pol, mainPol}/.MapIndexed[{\[FormalX]p->#, \[FormalI]pol->#2[[1]]}&, pos];
    {minPos, minVal}=
      First@MinimalBy[minValPos[[Range[1, Length@pos, 2]]], Last];
    minDiff=
      Min@{
        If[minPos>1,
          minValPos[[minPos-1, 2]]-minVal,
          \[Infinity]
          ],
        If[minPos<Length@pos,
          minValPos[[minPos+1, 2]]-minVal,
          \[Infinity]
          ]
        };
    If[minDiff>0, 
      dep=dep/minDiff,
      dep=1
      ];
    Evaluate[dep(mainPol/.\[FormalX]p->#)-(dep*minVal-min)]&
    ];


(* ::Subsubsection::Closed:: *)
(*HinderedRotor*)



ChemDVRDefaultNamedPotential["HinderedRotor", ops___?OptionQ]:=
  With[
    {
      w=Lookup[{ops}, "WellNumber", 3],
      d=Lookup[{ops}, "WellDepth", 25.],
      p=Lookup[{ops}, "Phase", 0],
      s=Lookup[{ops}, "Minimum", 0]
      },
    d*Cos[w*#-p]+(d-s)&
    ];


(* ::Subsubsection::Closed:: *)
(*HinderedHalfRotor*)



ChemDVRDefaultNamedPotential["HinderedHalfRotor", ops___?OptionQ]:=
  With[
    {
      w=2*Lookup[{ops}, "WellNumber", 1],
      d=Lookup[{ops},   "WellDepth", 25.],
      p=Lookup[{ops},   "Phase", 0],
      s=Lookup[{ops},   "Minimum", 0]
      },
    d*Cos[w*#-p]+(d-s)&
    ];


(* ::Subsubsection::Closed:: *)
(*Fallback*)



ChemDVRDefaultNamedPotential[name_String, ops___?OptionQ]:=
  If[FileExistsQ[name]||MemberQ[ChemDVRPotentials[], name],
    name,
    With[
      {
        pe=PhysicalSystemData[name, "PotentialEnergy"],
        crds=PhysicalSystemData[name, "Coordinates"],
        vars=PhysicalSystemData[name, "Variables"]
        },
      If[MissingQ@pe||MissingQ@crds,
        PackageRaiseException[
          "DVRRun",
          "Named potential `` unknown",
          "MessageParameters"->{name}
          ],
        With[
          {
            potExpr=
              pe/.
                Join[
                  MapIndexed[
                    Sequence@@
                      {#->Apply[Slot, #2], #[___]->Apply[Slot, #2]}&,
                    crds
                    ], 
                  Flatten@
                    Join[
                      {ops}, 
                      Replace[
                        Flatten@{ops},
                        (s_String->v_):>
                          Sequence@@{
                            QuantityVariable[_, s]->v, 
                            QuantityVariable[s, _]->v
                            },
                        1
                        ]
                      ],
                  Thread[vars->1]
                  ]
              },
          Function[potExpr]
          ]
        ]
      ]
    ];
ChemDVRDefaultNamedPotential[e___]:=
  PackageRaiseException[
    "DVRRun",
    "Named potential `` unknown",
    "MessageParameters"->{e}
    ]


(* ::Subsection:: *)
(*GridBasedPotential*)



dvrImportPotential[obj_,grid:{_List,___}]:=
  With[{
    g=
      Select[Flatten[grid,Depth[grid]-3],AllTrue[NumericQ]]
      },
    Thread[{g[[All,;;-2]],g[[All,-1]]}]
    ];
dvrImportPotential[obj_,vals:{_?NumericQ,___}]:=
  With[{
    grid=If[Length[#]==2&&MatrixQ@#[[2]],#[[1]],#]&@ChemDVRGrid[obj]
    },
    Thread[{Flatten[grid,Depth[grid]-3],vals}]
    ]


dvrImportPotential[obj_,file_String?FileExistsQ]:=
  With[{
      res=
      dvrImportPotential[
        obj,
        Import[file]
        ]
      },
    res/;AllTrue[res,ListQ]
    ]


Options[dvrAlignPotential]=
  {
    Tolerance->.01,
    "GridPotentialPrepFunction"->Identity
    };
dvrAlignPotential[
  grid:Except[_?OptionQ],
  peInput:Except[_?OptionQ],
  ops:OptionsPattern[]
  ]:=
  With[{peGrid=
      Replace[OptionValue["GridPotentialPrepFunction"]@peInput,
        Except[_List]:>peInput
        ]},
    Dimensions[grid];
    With[{
      d1=Depth[grid],
      d2=Depth[peGrid],
      tol=OptionValue[Tolerance]
      },
      If[d1<d2, 
        PackageRaiseException[
          "DVRRun",
          "Can't align grid of depth `` to that of depth ``",
          "MessageParameters"->{d1, d2}
          ]
        ];
      With[{
          points1=
            Map[grid[[Sequence@@#]]->#&, 
              Position[grid,{__?NumericQ}]
              ],
          points2=
            If[Last@Dimensions[peGrid]===2,
              peGrid[[All,1]],
              Most/@peGrid
              ]
          },
        If[Length[points1]=!=Length[points2],
          With[{interpf=Interpolation[peGrid]},
            ReplacePart[
              grid,
              Thread@
                Rule[Last/@points1,
                  Quiet[
                    interpf@@@Map[First,points1],
                    InterpolatingFunction::dmval
                    ]
                  ]
              ]
            ],
          (*
					Find the nearest point to the points
						(issues with duplicates may arise, but only for ill-aligned data )
					Replace the grid points with the potential values
					
					*)
          Block[{
            nearestChoices=points1,
            nearestValues=points2,
            nearestFound={}
            },
            While[
              nearestFound=
                {
                  nearestFound,
                  DeleteDuplicates@
                    AssociationThread[
                      nearestValues->
                        Map[First, Nearest[nearestChoices, nearestValues]]
                      ]
                  };
              nearestChoices=
                DeleteCases[nearestChoices,
                  _->(Alternatives@@Values@Last[nearestFound])
                  ];
              nearestValues=
                DeleteCases[nearestValues,
                  Alternatives@@Keys@Last[nearestFound]
                  ];
              Length[nearestValues]>0
              ];
            nearestFound=Apply[Join, Map[Values, Flatten[nearestFound]]];
            ReplacePart[
              grid,
              Thread[
                nearestFound->
                peGrid[[All,2]]
                ]
              ]
            ]
          ]
        ]
      ]
    ]


Options[dvrImportAlignPotential]=Options[dvrAlignPotential];
dvrImportAlignPotential[obj_,grid_,pot:Except[_?OptionQ],
  ops:OptionsPattern[]
  ]:=
  With[{p=dvrImportPotential[obj,pot]},
    dvrAlignPotential[grid,p,ops]
    ]


(* ::Subsection:: *)
(*ChemDVRDefaultPotentialEnergy*)



ChemDVRObject::badpot=
  "Potential function `` didn't return a numerical vector over the gridpoints"; 


(* ::Subsubsection::Closed:: *)
(*iChemDVRDefaultPotentialFunction*)



(* ::Text:: *)
(*
	
	Need good symbolic representation for a direct product of potential functions, which can also work for the grid and for the kinetic energy too.

*)



iChemDVRDefaultPotentialFunction//Clear


iChemDVRDefaultPotentialFunction[s_String, ops___]:=
  ChemDVRDefaultNamedPotential[s, ops];
iChemDVRDefaultPotentialFunction[
  {s_String, op___?OptionQ},
  ___
  ]:=
  ChemDVRDefaultNamedPotential[s, op];
iChemDVRDefaultPotentialFunction[
  {s_, n_Integer}, 
  ops___
  ]:=
  iChemDVRDefaultPotentialFunction[
    NonCommutativeMultiply@@ConstantArray[s, n],
    ops
    ];
iChemDVRDefaultPotentialFunction[
  (NonCommutativeMultiply|List|Cross)[a:Repeated[Except[_?OptionQ].., {2, \[Infinity]}]], 
  ops___
  ]:=
  Function[
    Evaluate@
      MapIndexed[
        #[Slot@@#2]&, 
        iChemDVRDefaultPotentialFunction[#, ops]&/@{a}
        ]
    ]/.Slot[n_]:>#[[n]];
iChemDVRDefaultPotentialFunction[
  (NonCommutativeMultiply|List|Cross)[a:Except[_?OptionQ]], 
  ops___
  ]:=
  iChemDVRDefaultPotentialFunction[a, ops];
iChemDVRDefaultPotentialFunction[e_, ___]:=
  e


(* ::Subsubsection::Closed:: *)
(*ChemDVRDefaultPotentialEnergyElementFunction*)



Options[ChemDVRDefaultPotentialEnergyElementFunction]=
  {
    "PotentialFunction"->Automatic,
    Function->Automatic
    };
ChemDVRDefaultPotentialEnergyElementFunction[ops:OptionsPattern[]]:=
  Replace[
    iChemDVRDefaultPotentialFunction[
      Lookup[Flatten@{ops}, "PotentialFunction", 
        Lookup[
          Options[ChemDVRDefaultPotentialEnergyElementFunction], 
          "PotentialFunction"
          ]
        ]
      ],
    Except[
      _Function|_InterpolatingFunction|
      _CompiledFunction|_Symbol?(Length[DownValues[#]>0]&)
      ]:>
      iChemDVRDefaultPotentialFunction[
        Lookup[Flatten@{ops}, Function, 
          Lookup[
            Options[ChemDVRDefaultPotentialEnergyElementFunction], 
            Function
            ]
          ]
        ]
    ]


(* ::Subsubsection::Closed:: *)
(*iChemDVRPotentialEnergy*)



iChemDVRPotentialValidate[vec_, gpnum_]:=
  Length@vec==gpnum&&
    VectorQ[vec, Internal`RealValuedNumericQ]


iChemDVRPotentialEnergy[gridpoints_, function_]:=
  With[
    {
      gpVec=
        Replace[Quiet@function@gridpoints, 
          Except[_List?(iChemDVRPotentialValidate[#, Length[gridpoints]]&)]:>
            Map[function, gridpoints]
          ]
      },
    If[!iChemDVRPotentialValidate[gpVec, Length[gridpoints]],
      PackageRaiseException[
        "DVRRun",
        "Potential function `` didn't return a numerical vector over the gridpoints",
        "MessageParameters"->{function}
        ],
      SparseArray[Band[{1, 1}]->gpVec]
      ]
    ]


(* ::Subsubsection::Closed:: *)
(*ChemDVRDefaultPotentialEnergy*)



Options[ChemDVRDefaultPotentialEnergy]=
  Join[
    Options[ChemDVRDefaultPotentialEnergyElementFunction],
    Options@ChemDVRDefaultGridPointList
    ];
ChemDVRDefaultPotentialEnergy[grid_, ops___?OptionQ]:=
  With[
    {
      pf=
        Replace[Function[{e__}]:>Function[Plus[e]]]@
          ChemDVRDefaultPotentialEnergyElementFunction[ops],
      gp=
        ChemDVRDefaultGridPointList[grid, 
          FilterRules[{ops},
            Options@ChemDVRDefaultGridPointList
            ]
          ]
        },
    iChemDVRPotentialEnergy[gp, pf]
    ]


(* ::Subsection:: *)
(*ChemDVRDefaultGridPotentialEnergy*)



Options[ChemDVRDefaultGridPotentialEnergy]=
  Options[ChemDVRDefaultGridPointList];
ChemDVRDefaultGridPotentialEnergy[
  grid:_List, 
  pe:{Except[_List], ___},
  ops:OptionsPattern[]
  ]:=
  MapThread[
    Flatten@*List,
    {
      ChemDVRDefaultGridPointList[grid, ops],
      pe
      }
    ];
ChemDVRDefaultGridPotentialEnergy[
  grid:_List, 
  pe:_SparseArray|_List?(SquareMatrixQ),
  ops:OptionsPattern[]
  ]:=
  ChemDVRDefaultGridPotentialEnergy[
    grid,
    Normal@Diagonal@pe,
    ops
    ];
ChemDVRDefaultGridPotentialEnergy[
  grid:_List, 
  pe:_Hold,
  ops:OptionsPattern[]
  ]:=
  ChemDVRDefaultGridPotentialEnergy[
  grid, 
  ReleaseHold@pe,
  ops
  ]


(* ::Subsection:: *)
(*ChemDVRDirectProductPotentialEnergy*)



ChemDVRDefaultDirectProductPotentialEnergy[pemats:{__}]:=
    ChemDVRKroeneckerProductKineticEnergy@pemats;


(* ::Subsection:: *)
(*ChemDVRDefaultPrunePotentialEnergy*)



ChemDVRDefaultPrunePotentialEnergy[potMx_, pruningEnergy_]:=
  Module[{V=ReleaseHold@potMx, vDiag, prune=pruningEnergy, prunePos},
    If[NumericQ@prune||MatchQ[prune, Scaled[_?NumericQ]],
      vDiag=Normal@Diagonal[ReleaseHold@V];
      prune=
        Replace[prune, 
          {
            i_?NumericQ:>Rescale[i, MinMax@vDiag],
            Scaled[s_]:>s
            }
          ];
      vDiag=Rescale[vDiag];
      prunePos=Flatten@Position[vDiag, _?(#>prune&), 1];
      V[[
          Complement[Range[Length@V], prunePos], 
          Complement[Range[Length@V], prunePos]
          ]],
      V
      ]
    ]


End[];



