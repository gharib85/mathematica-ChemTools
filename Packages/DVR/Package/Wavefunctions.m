(* ::Package:: *)



ChemDVRDefaultPrepareHamiltonian::usage=
ChemDVRDefaultWavefunctions::usage="";
ChemDVRDefaultExtendWavefunctions::usage="";
ChemDVRDefaultGridWavefunctions::usage="";
ChemDVRDefaultInterpolatingWavefunctions::usage="";
ChemDVRDefaultExpectationValues::usage="";
ChemDVRDefaultOperatorMatrix::usage="";
ChemDVRDefaultOperatorMatrixElements::usage="";


Begin["`Private`"];


(* ::Subsection:: *)
(*WavefunctionSelection*)



chemDVRScaledWavefunctionSpan[s_, len_]:=
  Which[
    s>=1, 
      Sequence@@{},
    s==0,
      Sequence@@{},
    s<0,
      Ceiling[s*len];;,
    True,
      ;;Floor[s*len] 
    ]


Options[ChemDVRDefaultWavefunctionSelection]=
  {
    "WavefunctionSelection"->All
    };
ChemDVRDefaultWavefunctionSelection[wfs_, 
  sel:Except[_?OptionQ], ops:OptionsPattern[]]:=
  If[sel=!=All,
    wfs[[All, 
      Replace[sel,
        {
          i_Integer?Positive:>
            If[i>Length@wfs[[1]], All, ;;i],
          i_Integer?Negative:>
            If[-i>Length@wfs[[1]], All, i;;],
          Scaled[s_?NumericQ]:>
            chemDVRScaledWavefunctionSpan[s, Length@wfs[[1]]],
          Scaled[{min_?NumericQ, max_?NumericQ}]:>
            With[{minMax=Sort@{min, max}},
              Replace[
                {
                  chemDVRScaledWavefunctionSpan[minMax[[1]], Length@wfs[[1]]],
                  chemDVRScaledWavefunctionSpan[minMax[[2]], Length@wfs[[1]]]
                  },
                {
                  {}:>
                    Sequence@@{},
                  {M_;;, ;;m_}|
                    {m_;;, M_;;}|
                    {;;m_, ;;M_}:>m;;M,
                  {e_}:>e
                  }
                ]
              ],
          e:Except[_Span|All|{__Integer}]:>
            PackageRaiseException[
              Automatic,
              "Wavefunction selection spec `` couldn't be processed",
              e
              ]
          }
        ]
      ]],
    wfs
    ];
ChemDVRDefaultWavefunctionSelection[wfs_, ops:OptionsPattern[]]:=
  ChemDVRDefaultWavefunctionSelection[wfs,
    OptionValue["WavefunctionSelection"]
    ]


(* ::Subsection:: *)
(*ChemDVRDefaultPrepareHamiltonian*)



Options[ChemDVRDefaultPrepareHamiltonian]=
  {
    "ValidateHamiltonian"->True,
    "PruningEnergy"->None,
    "HamiltonianRounding"->None
    };
ChemDVRDefaultPrepareHamiltonian[T_, V_, ops:OptionsPattern[]]:=
  Module[
    {
      prune=OptionValue["PruningEnergy"],
      vDiag,
      prunePos,
      fullLen,
      round=OptionValue["HamiltonianRounding"],
      keMat=ReleaseHold@T,
      peMat=ReleaseHold@V,
      ham,
      validate=OptionValue["ValidateHamiltonian"]=!=False,
      hermCut
      },
    If[!SquareMatrixQ[keMat]||
      (validate&&!MatrixQ[keMat, Internal`RealValuedNumericQ]),
      PackageRaiseException[
        Automatic,
        "The kinetic energy is not a square numerical matrix"
        ]
      ];
    If[!SquareMatrixQ[peMat]||
      (validate&&!MatrixQ[peMat, Internal`RealValuedNumericQ]),
      PackageRaiseException[
        Automatic,
        "The potential energy is not a square numerical matrix"
        ]
      ];
    ham=keMat+peMat;
    fullLen=Length@ham;
    If[!SquareMatrixQ[ham]||
      (validate&&!MatrixQ[ham, Internal`RealValuedNumericQ]),
      PackageRaiseException[
        Automatic,
        "The Hamiltonian is not a square numerical matrix"
        ]
      ]; 
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
      ham=
        ham[[
          Complement[Range[Length@ham], prunePos], 
          Complement[Range[Length@ham], prunePos]
          ]];
      ];
    If[round>1, round=10^-round];
    If[NumericQ@round, ham=Round[ham, N@round]];
    If[validate&&!HermitianMatrixQ@ham, 
      If[HermitianMatrixQ[ham, Tolerance->10^-7],
        hermCut=
          SelectFirst[
            Range[
              Floor@$MachinePrecision,
              7,
              -1
              ],
            HermitianMatrixQ[ham, Tolerance->10^-#]&
            ];
        PackageRaiseException[
          Automatic,
          "Hamiltonian isn't Hermitian. \
Numerical instability may have introduced lack of hermiticity. \
Try passing \"HamiltonianRounding\"->``.",
          With[{c=hermCut}, HoldForm[10^-c]]
          ],
        PackageRaiseException@
          "Hamiltonian is neither Hermitian nor approximately Hermitian"
        ]
      ]; 
    {ham, {If[ListQ@prunePos, prunePos, {}], fullLen}}
    ]


(* ::Subsection:: *)
(*ChemDVRDefaultWavefunctions*)



(* ::Subsubsection::Closed:: *)
(*ChemDVRDefaultWavefunctions*)



Options[ChemDVRDefaultWavefunctions]=
  Join[
    Options@Eigensystem,
    {
      "NumberOfWavefunctions"->Automatic,
      "CorrectPhase"->True,
      "SortEnergies"->True,
      "WavefunctionEigensolver"->Eigensystem,
      "PreadjustHamiltonian"->True,
      "ArnoldiIterations"->Automatic,
      "ArnoldiBasisSize"->Automatic,
      "ArnoldiTolerance"->Automatic,
      "ArnoldiGuessWavefunction"->Automatic,
      "TargetEigenvalue"->Automatic
      },
    Options[ChemDVRDefaultPrepareHamiltonian]
    ];
ChemDVRDefaultWavefunctions[T_, V_, ops:OptionsPattern[]]:=
  Module[
    {
      useFlags,
      ham,
      wfnSel,
      hamAdj,
      shift,
      hamDiag,
      hamDiagMax,
      rowSums,
      rowBounds,
      rowMin,
      rowShift,
      hamEigMax,
      nwfs=OptionValue["NumberOfWavefunctions"],
      sort=OptionValue["SortEnergies"]=!=False,
      rephase=OptionValue["CorrectPhase"]=!=False,
      wfns,
      phase,
      solver=
        Replace[OptionValue["WavefunctionEigensolver"],
          Eigenvectors->Eigensystem
          ],
      origLen,
      prunePos,
      prunePosOrder,
      hamPruned,
      arnops
      },
    Internal`WithLocalSettings[
      useFlags=
        Quiet@
          Fold[
            Lookup,
            SystemOptions["LinearAlgebraOptions"->"UseMatrixPropertyFlags"],
            {"LinearAlgebraOptions", "UseMatrixPropertyFlags"}
            ];
      Quiet@SetSystemOptions["LinearAlgebraOptions"->"UseMatrixPropertyFlags"->True],
      {ham, {prunePos, origLen}}=
        ChemDVRDefaultPrepareHamiltonian[T, V, 
          FilterRules[{ops}, Options[ChemDVRDefaultPrepareHamiltonian]]
          ];
      shift=Replace[OptionValue["TargetEigenvalue"], Except[_?NumericQ]->Automatic];
      hamPruned=Length@prunePos>0;
      If[hamPruned,
        (*
				Will need to reconstruct the wavefunctions to resample the grid properly
				The first entries will be the pruned positions.
				The last entries will be fill.
				Need to resort so that the fill is in the right spot.
				*) 
        prunePosOrder=
          Ordering@Join[Complement[Range[origLen], prunePos], prunePos]
        ];
      wfnSel=
        Replace[nwfs,
          {
            Automatic:>
              If[Head@ham===SparseArray, 
                -Abs[Max@{Min@{Floor[Length@ham/10], 25}, 3}],
                If[solver===Eigenvalues,
                  -Abs[Max@{Min@{Floor[Length@ham/10], 25}, 3}],
                  Sequence@@{}
                  ]
                ],
            i_Integer:>
              -i,
            _:>Sequence@@{}
            }
          ];
      hamAdj=Length@{wfnSel}>0&&TrueQ@OptionValue["PreadjustHamiltonian"];
      If[hamAdj&&shift===Automatic, wfnSel=-wfnSel];
      If[hamAdj||hamPruned,
        (*
				If things are pruned I want the maximum possible eigenvalue to return by Gerschgorin--
					this is what I'll give for all the pruned positions
				*)
        hamDiag=Diagonal[ham];
        hamDiagMax=Max[hamDiag];
        rowSums=Total@*Abs/@ham;
        rowBounds=2*Abs[hamDiag]-rowSums;
        hamEigMax=Max@hamDiag+Max@Abs@rowBounds;
        ];
      If[hamAdj,
        (*
				If there is no shift, I force all eigenvalues to be negative then pick the largest ones. This is faster with the 
				Arnoldi algorithm.
				
				By Gerschgorin's theorm this means I need to push the diagonal large enough
					such that all of the eigenvalue disks are wholly negative
				
				If there is a shift, I shift so that the minimum abs. value eigenvalue may be expected to be around there 
				*)
        If[shift===Automatic,
          hamDiag-=hamDiagMax;
          (* row sums computed previously *)
          rowBounds=2*Abs[hamDiag]-rowSums; (* Compute diagonal - disk radius *)
          rowMin=Min@rowBounds; (* Pick largest displacement in negative sense *)
          rowShift=-(2*Abs[rowMin]+hamDiagMax); (* Shift by twice this to wholly avoid zero*),
          rowShift=-(shift+Min[hamDiag])
          ];
        ham=ham+SparseArray[Band[{1,1}]->rowShift, {Length@ham, Length@ham}]
        ];
      wfns=
        Re@
          solver[
            ham,
            wfnSel,
            Method->
              Replace[OptionValue[Method], 
                Automatic:>
                  If[Head@ham===SparseArray, 
                    arnops=
                      KeyValueMap[
                        Switch[#,
                          "MaxIterations",
                            If[IntegerQ@#2&&Positive[#2],
                              #->#2,
                              Nothing
                              ],
                          "BasisSize",
                            If[IntegerQ@#2&&Positive[#2],
                              #->#2,
                              Nothing
                              ],
                          "Tolerance",
                            If[NumericQ@#2&&Positive[#2],
                              #->#2,
                              Nothing
                              ],
                          "StartingVector",
                            If[VectorQ[#2, Internal`RealValuedNumericQ],
                              #->#2,
                              Nothing
                              ]
                          ]&, 
                        AssociationThread[
                          {
                            "MaxIterations",
                            "BasisSize",
                            "Tolerance",
                            "StartingVector"
                            },
                          OptionValue[
                            {
                              "ArnoldiIterations", 
                              "ArnoldiBasisSize", 
                              "ArnoldiTolerance",
                              "ArnoldiGuessWavefunction"
                              }
                            ]
                          ]
                        ];
                    Flatten@{"Arnoldi", arnops},
                    Automatic
                    ]
                ],
            FilterRules[
              FilterRules[{ops},Alternatives@@Keys@Options@Eigensystem],
              Except[Method]
              ]
            ];
      Which[
        NumericQ@wfns[[1]],
          (* just energies, so just return them *)
          If[sort, Sort, Identity]@
            If[hamPruned, 
              If[wfnSel===All,
                Join[
                  #, 
                  ConstantArray[hamEigMax, Echo@Length@prunePos]
                  ],
                #
                ]&,
              Identity
              ]@
            If[TrueQ[NumericQ@rowShift],
              wfns-rowShift,
              wfns
              ],
        Length@wfns==2,
          (* full eigensystem *)
          wfns=
            If[sort, #[[{1,2}, Ordering[First@#]]], #]&@
              If[hamPruned, 
                {
                  If[wfnSel===All,
                    Join[
                      #[[1]], 
                      ConstantArray[hamEigMax, Length@prunePos]
                      ],
                    #[[1]]
                    ],
                  Join[
                    #, 
                    ConstantArray[0., Length@prunePos]
                    ][[prunePosOrder]]&/@#[[2]]
                  }&, 
                Identity
                ]@
              If[TrueQ[NumericQ@rowShift],
                {
                    #[[1]]-rowShift, 
                    #[[2]]
                    },
                #
                ]&@wfns;
          If[rephase,
            phase=Sign@wfns[[2, Ordering[First@wfns][[1]]]];
            {First@wfns, phase*#&/@Last@wfns},
            wfns
            ],
        True,
          wfns
        ],
      Quiet@SetSystemOptions["LinearAlgebraOptions"->"UseMatrixPropertyFlags"->useFlags]
      ]
    ];


(* ::Subsection:: *)
(*ChemDVRDefaultExtendWavefunctions*)



(* ::Subsubsubsection::Closed:: *)
(*iChemDVRDefaultExtendWavefunctions*)



(* ::Text:: *)
(*
	Attempt to figure out where the new eigenvalues should be built from.
	
	A future version should try to apply some clever \[OpenCurlyQuote]chunking\[CloseCurlyQuote] or something.
		Basically if no new eigenvalues would be generated (or too few) apply the process iteratively.
*)



Options[iChemDVRDefaultExtendWavefunctions]=
  Options[ChemDVRDefaultWavefunctions];
iChemDVRDefaultExtendWavefunctions[
  T_,
  V_, 
  wfns_,
  n_,
  ops:OptionsPattern[]
  ]:=
  Module[
    {
      eigNum=n,
      engs=wfns[[1]],
      mengPos, meng,
      engLen, lastN, 
      targetEstimator,
      targetE=OptionValue["TargetEigenvalue"], guessWf,
      newEngs, newWfs,
      new, orderNew
      },
    mengPos=Ordering[engs, 1][[1]];
    meng=engs[[mengPos]];
    If[!NumericQ@targetE,
      engLen=Min@{Length[engs], Max@{n, 5}};
      lastN=engs[[-engLen;;]];
      Which[engLen>3,
        targetEstimator=
          Table[
            LinearModelFit[lastN, \[FormalN]^Range[m], \[FormalN]],
            {m, 3}
            ];
        targetEstimator=
          MaximalBy[targetEstimator, #["RSquared"]&][[1]]["Function"],
        engLen>1,
          targetEstimator=
            Evaluate[Fit[lastN, {1, #}, #]]&,
        True,
          eigNum++;
          targetEstimator=meng&;
        ];
      targetE=targetEstimator[engLen+1]
      ];
    guessWf=wfns[[2, mengPos]];
    new=
      ChemDVRDefaultWavefunctions[
        T, V, 
        "NumberOfWavefunctions"->n,
        "PreadjustHamiltonian"->True,
        "ArnoldiGuessWavefunction"->guessWf,
        "TargetEigenvalue"->targetE,
        ops
        ];
    If[MatchQ[new, 
          {_List?(VectorQ[#, Internal`RealValuedNumberQ]&), _List?MatrixQ}
          ],
      {newEngs, newWfs}=newWfs,
      PackageRaiseException[
        Automatic,
        "Failed to generate wavefunctions"
        ];
      ];
    new=Select[newEngs, Not@*MatchQ[Alternatives@@engs]];
    If[Length@new===0,
      PackageRaiseException[
        Automatic,
        "Failed to find any new wavefunctions with eigenvalue shift ``. \
Try supplying a different \"TargetEigenvalue\" directly",
        targetE
        ]
      ];
    new={new, Pick[newWfs, Not@*MatchQ[Alternatives@@engs]/@newEngs]};
    new=
      MapThread[
        Join,
        {
          new,
          wfns
          }
        ];
    orderNew=Ordering[new[[1]]];
    #[[orderNew]]&/@new
    ]


(* ::Subsubsubsection::Closed:: *)
(*ChemDVRDefaultExtendWavefunctions*)



ChemDVRDefaultExtendWavefunctions//Clear


Options[ChemDVRDefaultExtendWavefunctions]=
  Options[iChemDVRDefaultExtendWavefunctions];
ChemDVRDefaultExtendWavefunctions[
  T_,
  V_, 
  wfns_,
  ops:OptionsPattern[]
  ]:=
  iChemDVRDefaultExtendWavefunctions[
    T, V, ReleaseHold[wfns],
    Replace[
      OptionValue["NumberOfWavefunctions"],
      Except[_Integer?IntegerQ]->5
      ],
    ops
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
(*ChemDVRDefaultExpectationValues*)



(* ::Subsubsection::Closed:: *)
(*validateWfns*)



validateWfns[wfns_]:=
  If[!ListQ@wfns&&Length@wfns==2&&VectorQ[wfns[[1]], Internal`RealValuedNumericQ],
      PackageRaiseException[
        Automatic,
        "Supplied wavefunctions are invalid"
        ]
      ];


(* ::Subsubsection::Closed:: *)
(*chemDVRCalcExpectationValue*)



chemDVRCalcExpectationValueVec[func_, grid_]:=
  Replace[func@grid, 
    Except[_List?(Length[#]==Length@grid&)]:>Map[func, grid]
    ];
chemDVRCalcExpectationValueVec[func_, grid_, wf_]:=
  Replace[func[grid, wf],
    Except[_List?(Length[#]==Length@grid&)]:>
      MapThread[func, {grid, wf}]
    ];


multiplicativeOperator[func_Function]:=
  !(MemberQ[func, Slot[2], \[Infinity]]||
      MatchQ[func, Verbatim[Function][{_, _}, ___]]);
multiplicativeOperator[e_]:=
  False;


chemDVRCalcExpectationValue[
  func_Function, grid_, wfL_, wfR_,
  multiplicative_
  ]:=
  wfL.
    With[
      {
        mult=
          If[multiplicative===Automatic,
            multiplicativeOperator[func],
            TrueQ@multiplicative
            ]
        },
      If[!mult,
        chemDVRCalcExpectationValueVec[func, grid, wfR],
        Quiet[
          Check[
            wfR*chemDVRCalcExpectationValueVec[func, grid],
            PackageRaiseException[
              Automatic,
              "Dimension mismatch in matrix element calculation for function ``.\
 Wavefunction has dimension `` and the grid has dimension ``"(*, \
and the function applied to the grid has dimension ``*),
              func,
              Dimensions[wfR], 
              Dimensions@grid(*,
							Dimensions@chemDVRCalcExpectationValueVec[func, grid]*)
              ];
            ],
          Thread::tdlen
          ]
        ]
    ];
chemDVRCalcExpectationValue[func:Except[_Function], grid_, wfL_, wfR_,
  multiplicative_
  ]:=
  wfL.Replace[chemDVRCalcExpectationValueVec[func, grid, wfR],
    {
      {_func, __}:>
        Replace[chemDVRCalcExpectationValueVec[func, grid],
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
(*ChemDVRDefaultExpectationValues*)



Options[ChemDVRDefaultExpectationValues]=
  Join[
    Options@ChemDVRDefaultGridWavefunctions,
    {
      "MultiplicativeOperator"->Automatic
      }
    ];
ChemDVRDefaultExpectationValues[
  grid_,
  wfs_,
  evs_,
  V:_?SquareMatrixQ|Hold[_?SquareMatrixQ],
  ops:OptionsPattern[]
  ]:=
  With[
    {
      coreGridPoints=
        ChemDVRDefaultPruneGridPoints[
          ChemDVRDefaultGridPointList[grid, 
            FilterRules[{ops}, Options@ChemDVRDefaultGridPointList]
            ],
          V,
          OptionValue["PruningEnergy"]
          ],
      exfns=
        Flatten@List@evs,
      wfns=
        ChemDVRDefaultWavefunctionSelection[
          ReleaseHold@wfs,
          FilterRules[{ops}, Options[ChemDVRDefaultWavefunctionSelection]]
          ],
      retE=
        TrueQ@OptionValue["ReturnEnergies"],
      mul=OptionValue["MultiplicativeOperator"]
      },
    If[retE, 
      wfns[[1]]->#&,
      Identity
      ]@
        If[Not@ListQ@evs, Map[First], Identity]@
          Table[
            Map[
              chemDVRCalcExpectationValue[#, coreGridPoints, wf, wf, mul]&,
              exfns
              ],
            {wf, wfns[[2]]}
            ]
    ];


(* ::Subsection:: *)
(*ChemDVRDefaultOperatorMatrix*)



(* ::Subsubsection::Closed:: *)
(*ChemDVRDefaultOperatorMatrix*)



Options[ChemDVRDefaultOperatorMatrix]=
  Join[
    Options@ChemDVRDefaultExpectationValues,
    {
      "AssumeSymmetric"->True,
      "AssumeHermitian"->False
      }
    ];
ChemDVRDefaultOperatorMatrix[
  grid_,
  wfs_,
  evs_,
  V:_?SquareMatrixQ|Hold[_?SquareMatrixQ],
  ops:OptionsPattern[]
  ]:=
  Module[
    {
      coreGridPoints=
        ChemDVRDefaultPruneGridPoints[
          ChemDVRDefaultGridPointList[grid, 
            FilterRules[{ops}, Options@ChemDVRDefaultGridPointList]
            ],
          V,
          OptionValue["PruningEnergy"]
          ],
      exfns=
        Flatten@List@evs,
      els,
      sels,
      wfns=ReleaseHold@wfs,
      retE=
        TrueQ@OptionValue["ReturnEnergies"],
      mat,
      engs,
      wfnSel,
      exFs,
      asrs=TrueQ@OptionValue["AssumeSymmetric"],
      ash=TrueQ@OptionValue["AssumeHermitian"],
      mul=OptionValue["MultiplicativeOperator"]
      },
    {sels, exfns}=
      Transpose@
        Replace[exfns,
          {
            (sel_->fn_):>
              {sel, fn},
            fn_:>
              {OptionValue["WavefunctionSelection"], fn}
            },
          1
          ];
    wfns=
      Map[
        ChemDVRDefaultWavefunctionSelection[wfns, #]&, 
        sels
        ];
    If[Length@sels==1, First, Identity]@
      MapThread[
        Function[
          engs=#[[1]];
          wfnSel=#[[2]];
          exFs=#2;
          If[retE, 
            Array[
              {engs[[#]], engs[[#2]]}&,
              {Length@wfnSel, Length@wfnSel}
              ]->#&,
            Identity
            ]@
          Block[
            {
              rmat=
                ConstantArray[0., 
                  {
                    Length@wfnSel, Length@wfnSel, 
                    If[Not@ListQ@exFs, Nothing, Length@exFs]
                    }
                  ]
              },
            Do[
              rmat[[i, j]]=
                If[(asrs||ash)&&i>j,
                  If[ash, Conjugate, Identity]@rmat[[j, i]],
                  With[{gr=coreGridPoints, wfL=wfnSel[[i]], wfR=wfnSel[[j]]},
                    If[Not@ListQ@exFs,
                      chemDVRCalcExpectationValue[
                        exFs, 
                        gr, 
                        wfL, wfR,
                        mul
                        ],
                      Map[
                        chemDVRCalcExpectationValue[
                          #, 
                          gr, 
                          wfL, wfR,
                          mul
                          ]&,
                        exFs
                        ]
                      ]
                    ]
                  ],
              {i, Length@wfnSel},
              {j, Length@wfnSel}
              ];
            rmat
            ]
          ],
        {
          wfns,
          exfns
          }
        ]
    ];


(* ::Subsubsection::Closed:: *)
(*ChemDVRDefaultOperatorMatrixElements*)



ChemDVRDefaultOperatorMatrixElements//Clear


Options[ChemDVRDefaultOperatorMatrixElements]=
  Options@ChemDVRDefaultOperatorMatrix;
ChemDVRDefaultOperatorMatrixElements[
  grid_,
  wfs_,
  evs:
    (({_, _}->_)|
    ({{_, _}...}->_)|
    {(({{_, _}...}|{_, _})->_)..}),
  V:_?SquareMatrixQ|Hold[_?SquareMatrixQ],
  ops:OptionsPattern[]
  ]:=
  Module[
    {
      coreGridPoints=
        ChemDVRDefaultPruneGridPoints[
          ChemDVRDefaultGridPointList[grid, 
            FilterRules[{ops}, Options@ChemDVRDefaultGridPointList]
            ],
          V,
          OptionValue["PruningEnergy"]
          ],
      exfns=
        Flatten@List@evs,
      els,
      sels,
      wfns=ReleaseHold@wfs,
      retE=
        TrueQ@OptionValue["ReturnEnergies"],
      wfSelL,
      wfSelR,
      engsL,
      engsR,
      wfnsL,
      wfnsR,
      exFs,
      mul=OptionValue["MultiplicativeOperator"]
      },
    {sels, exfns}=
      Transpose[List@@@exfns];
    validateWfns[wfns];
    wfSelL=
      Map[
        Map[
          ChemDVRDefaultWavefunctionSelection[wfns, #]&,
          Replace[
            Replace[#, k:{Except[_List], _}:>{k}][[All, 1]], 
            i_Integer:>{i},
            1
            ]
          ]&,
        sels
        ];
    wfSelR=
      Map[
        Map[
          ChemDVRDefaultWavefunctionSelection[wfns, #]&,
          Replace[
            Replace[#, k:{Except[_List], _}:>{k}][[All, 2]], 
            i_Integer:>{i},
            1
            ]
          ]&,
        sels
        ];
    If[Length@sels==1, First, Identity]@
      MapThread[
        Function[
          exFs=#3;
          If[Length@#==1, First, Identity]@
          MapThread[
            Function[
              engsL=#[[1]];
              engsR=#2[[1]];
              wfnsL=#[[2]];
              wfnsR=#2[[2]];
              Which[
                Length@wfnsL==1&&Length@wfnsR==1,
                  First@First@#&,
                Length@wfnsL==1||Length@wfnsR==1, 
                  Flatten[#, 1]&, 
                True,
                  Identity
                ]@
              If[retE, 
                Array[
                  {engsL[[#]], engsR[[#2]]}&,
                  {Length@wfnsL, Length@wfnsR}
                  ]->#&,
                Identity
                ]@
              Table[
                With[{gr=coreGridPoints, wfL=wfL, wfR=wfR},
                  If[Not@ListQ@exFs,
                    chemDVRCalcExpectationValue[
                      exFs, 
                      gr, 
                      wfL, wfR,
                      mul
                      ],
                    Map[
                      chemDVRCalcExpectationValue[
                        #, 
                        gr, 
                        wfL, wfR,
                        mul
                        ]&,
                      exFs
                      ]
                    ]
                  ],
                {wfL, wfnsL},
                {wfR, wfnsR}
                ]
              ],
            {
              #,
              #2
              }
            ]
          ],
        {
          wfSelL,
          wfSelR,
          exfns
          }
        ]
    ];


End[];



