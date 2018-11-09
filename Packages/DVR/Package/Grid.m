(* ::Package:: *)



$ChemDVRDefaultGridTypes::usage="The set of built-in grids";
ChemDVRDefaultFormatGrid::usage="";
ChemDVRBasisSetGrid::usage="Computes a grid from a specified basis set";
ChemDVRDefaultGrid::usage=
  "Default DVR grid function";
ChemDVRDefaultNamedGrid::usage="";
ChemDVRDirectProductGrid::usage=
  "Creates a direct product grid from two grid functions";
ChemDVRDefaultGridPointList::usage="";
ChemDVRDefaultPruneGridPoints::usage="";


Begin["`Private`"];


(* ::Subsection:: *)
(*FormatGrid*)



ChemDVRDefaultFormatGrid[grid_,points_,___]:=
  grid;


(* ::Subsection:: *)
(*BasisSetGrid*)



(* ::Subsubsection::Closed:: *)
(*iChemDVRBasisSetGrid*)



(* ::Text:: *)
(*
	For now only supports 1D grids... might be expanded later?
*)



(* ::Subsubsubsection::Closed:: *)
(*iChemDVRRecGridRep*)



(* ::Text:: *)
(*
	Make a grid representation for the recurrence relation given by the provided rules.
	The integer key is which j the i couples to (relative to i)
	The value is a function that returns the value at that node based on i
*)



iChemDVRRecGridRep//Clear


Options[iChemDVRRecGridRep]=
  {
    "KeepExact"->Automatic,
    "EchoRepresentation"->False
    };
iChemDVRRecGridRep[
  recRules:{(_Integer->_)..},
  pts_,
  {min_, max_},
  ___?(Not@*OptionQ),
  ops:OptionsPattern[]
  ]:=
  If[OptionValue@"EchoRepresentation"//TrueQ, Echo, Identity]@
    With[{ex=TrueQ@OptionValue["KeepExact"]},
      SparseArray[
        Map[
          With[{fn=#[[2]], shift=#[[1]]},
            Band[
              If[Positive@shift, 
                {1, 1+shift},
                {1-shift, 1}
                ]
              ]->
                Array[
                  If[!ex, N, Identity]@fn[#, #+shift]&,
                  pts-Abs@#[[1]], 
                  Max@{1-#[[1]], 1}
                  ]
            ]&,
          recRules
          ],
        {pts, pts}
        ]
      ]


(* ::Subsubsubsection::Closed:: *)
(*iChemDVRBSGridRep*)



iChemDVRBSGridRep//Clear


Options[iChemDVRBSGridRep]=
  {
    "KeepExact"->False,
    "EchoRepresentation"->False,
    "NumericalIntegration"->Automatic,
    "IntegrationBounds"->Automatic
    };
iChemDVRBSGridRep[
  {basisFunction_, coordinate_, coordinateFunction_},
  pts_,
  {min_, max_},
  ops:OptionsPattern[]
  ]:=
  If[OptionValue@"EchoRepresentation"//TrueQ, Echo, Identity]@
  With[
    {
      cr=coordinateFunction@coordinate,
      ex=TrueQ@OptionValue["KeepExact"],
      numint=
        Replace[OptionValue["NumericalIntegration"],
          Except[True|False]:>NoneTrue[{min, max}, MatchQ[_Real]]
          ],
      bounds=
        Replace[OptionValue["IntegrationBounds"],
          Except[{_, _}]:>{min, max}
          ]
      },
    Table[
      If[!ex, N, Identity]@
      If[numint,
        Integrate,
        Function[Null, 
          Quiet[NIntegrate[##], 
            {
              NIntegrate::ncvb,
              NIntegrate::slwcon
              }
            ], 
          HoldAll
          ]
        ][
        basisFunction[i, cr]*
          cr*
        basisFunction[j, cr],
        {coordinate, bounds[[1]], bounds[[2]]}
        ],
      {i, pts},
      {j, pts}
      ]
    ]


(* ::Subsubsubsection::Closed:: *)
(*iChemDVRBasisSetGrid*)



iChemDVRBasisSetGrid//Clear


chopTransform[trans_, tol_:10^-$MachinePrecision]:=
  With[{r=N@tol},
    Map[
      If[Abs[#]<r, 0., #]&,
      trans,
      {2}
      ]
    ]


iChemDVRBasisSetGrid[
  basis_,
  pts_,
  {min_, max_}
  ]:=
  Module[
    {
      rep,
      eig,
      spec,
      ops,
      scaling,
      targ
      },
    ops=Select[basis, OptionQ];
    spec=Select[basis, Not@*OptionQ];
    targ=
      Replace[Lookup[ops, "GridRange", Automatic],
        Except[{_, _}]->{min, max}
        ];
    rep=
      Switch[spec,
        {_String},
          iChemDVRRecGridRep[
            iChemDVRNamedBasisSetGrid[spec[[1]], pts], 
            pts, 
            {min, max},
            FilterRules[{ops},
             Options@iChemDVRRecGridRep
             ]
            ],
        {(_Integer->_)..},
          iChemDVRRecGridRep[spec, 
            pts, 
            {min, max}, 
            FilterRules[{ops},
             Options@iChemDVRRecGridRep
             ]
            ],
        {_},
          iChemDVRBSGridRep[
            Join[spec, {\[FormalX], Identity}],
            pts,
            {min, max},
            FilterRules[{ops},
             Options@iChemDVRRecGridRep
             ]
            ],
        {_, _Symbol},
          iChemDVRBSGridRep[Append[spec, Identity],
            pts,
            {min, max},
            FilterRules[{ops},
             Options@iChemDVRRecGridRep
             ]
            ],
        {_, _Symbol, _},
          iChemDVRBSGridRep[spec,
            pts,
            {min, max},
            FilterRules[{ops},
             Options@iChemDVRRecGridRep
             ]
            ],
        _,
          PackageRaiseException[Automatic,
            "Couldn't process basis specification ``",
            spec
            ]
        ];
    eig=Quiet[Eigensystem[rep], Eigensystem::arh];
    eig=eig[[All, Ordering[First@eig]]];
    If[AllTrue[targ, NumericQ],
      eig[[1]]=
        Rescale[eig[[1]], 
          MinMax@eig[[1]],
          targ
          ]
      ];
    eig
    ]


(* ::Subsubsection::Closed:: *)
(*iChemDVRNamedBasisSetGrid*)



(* ::Subsubsubsection::Closed:: *)
(*Legendre*)



iChemDVRNamedBasisSetGrid["Legendre"|LegendreP, pts_]:=
  {
    1  -> (Sqrt[#2^2/((2#2-1)(2#2+1))]&), 
    -1 -> (Sqrt[#^2/((2#-1)(2#+1))]&)
    };


(* ::Subsubsubsection::Closed:: *)
(*Hermite*)



iChemDVRNamedBasisSetGrid["Hermite"|HermiteH, pts_]:=
  {
    1 ->(Sqrt[#/2]&),
    -1->(Sqrt[#2/2]&)
    };


(* ::Subsubsubsection::Closed:: *)
(*Chebyshev*)



iChemDVRNamedBasisSetGrid["Chebyshev"|ChebyshevT, pts_]:=
  {
    1  -> (-If[#==1, 1/Sqrt[2], 1/2]&),
    -1 -> (-If[#2==1, 1/Sqrt[2], 1/2]&)
    };


(* ::Subsubsubsection::Closed:: *)
(*Laguerre*)



iChemDVRNamedBasisSetGrid["Laguerre"|LaguerreL, pts_]:=
  {
    0 ->((3+2*#)&), 
    1 ->(-(#+1)&), 
    -1->(-#&)
    };


(* ::Subsection:: *)
(*DefaultGridPointList*)



Options[ChemDVRDefaultGridPointList]=
  {
    "GridPrepFunction"->Identity
    };
ChemDVRDefaultGridPointList[grid_, o:OptionsPattern[]]:=
  With[{dims=Dimensions[grid]},
    If[Depth@grid<=3,
      OptionValue["GridPrepFunction"]@grid,
      Flatten[
        OptionValue["GridPrepFunction"]@grid,
        Depth[grid]-3
        ]
      ]
    ];


(* ::Subsection:: *)
(*ChemDVRPruneGrid*)



ChemDVRDefaultPruneGridPoints[gridpoints_, V_, pruningEnergy_]:=
  Module[{vDiag, prune=pruningEnergy},
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
      Pick[gridpoints, #<=prune&/@vDiag],
      gridpoints
      ]
    ];


(* ::Subsection:: *)
(*ChemDVRDirectProductGrid*)



(* ::Text:: *)
(*Alas this is best implemented procedurally owing to lack of FoldTuple*)



chemDVRComputeGrid[fn_, pt_, reg_, opts:OptionsPattern[]]:=
  fn[pt, reg, FilterRules[{opts}, Options[fn]]]


ChemDVRDirectProductGrid[{grids__}]:=
    Outer[List, grids];
ChemDVRDirectProductGrid[
  fns_,
  pts_,
  regions_,
  opts:OptionsPattern[]
  ]:=
  ChemDVRDirectProductGrid@
    MapThread[
      #[#2, #3, FilterRules[{opts}, Options[#]]]&,
      {
        fns,
        pts,
        regions
        }
      ]


(* ::Subsection:: *)
(*ChemDVRDefaultGrid*)



$ChemDVRDefaultGridTypes=
  {
    "RegularSubdivision",
    "InteriorSubdivision",
    "AzimuthalSubdivision",
    "PolarSubdivision",
    {"BasisSet", "Legendre"},
    {"BasisSet", "Hermite"},
    {"BasisSet", "Chebyshev"},
    {"BasisSet", ___}
    };


(* ::Subsubsection::Closed:: *)
(*ChemDVRDefaultNamedGrid*)



(* ::Subsubsubsection::Closed:: *)
(*RegularSubdivision*)



ChemDVRDefaultNamedGrid[
  "RegularSubdivision", 
  pt_Integer, {min_, max_}
  ]:=
  Subdivide@@Flatten@{min, max, pt-1};


(* ::Subsubsubsection::Closed:: *)
(*InteriorSubdivision*)



ChemDVRDefaultNamedGrid[
  "InteriorSubdivision", 
  pt_Integer, {min_, max_}
  ]:=
  ((max-min)/(pt+1)*Range[pt])+min;


(* ::Subsubsubsection::Closed:: *)
(*AzimuthalSubdivision*)



ChemDVRDefaultNamedGrid[
  "AzimuthalSubdivision", 
  pt_Integer, {min_, max_}
  ]:=
  DeleteDuplicatesBy[Mod[#, 2\[Pi]]&]@
    ChemDVRDefaultNamedGrid[
      "InteriorSubdivision", 
      pt, 
      {min, max}
      ]


(* ::Subsubsubsection::Closed:: *)
(*PolarSubdivision*)



ChemDVRDefaultNamedGrid[
  "PolarSubdivision", 
  pt_Integer, {min_, max_}
  ]:=
  DeleteDuplicatesBy[Mod[#, \[Pi]]&]@
    ChemDVRDefaultNamedGrid[
      "InteriorSubdivision", 
      pt, 
      {min, max}
      ]


(* ::Subsubsubsection::Closed:: *)
(*SibertChebyshev*)



ChemDVRDefaultNamedGrid[
  "SibertChebyshev", 
  pt_Integer, {min_, max_}
  ]:=
  Range[pt]/pt-1/(2*pt)


(* ::Subsubsection::Closed:: *)
(*ChemDVRDefaultGrid*)



(* ::Text:: *)
(*

	TODO: 
		include default grids; 
		allow for easy specification in DVR template files;
		handle NonCommutativeMultiply for direct product grids;
		handle arbitrary op matrix el func for determining change of basis;

*)



ChemDVRRun::grdimfn=
  "Dimensions of grid (``) and number of grid types (``) don't match";
ChemDVRRun::ungrid=
  "\"GridType\" `` not known";


Options[ChemDVRDefaultGrid]=
  {
    "GridType"->"RegularSubdivision"
    };
ChemDVRDefaultGrid[
  pts_,
  regions_,
  ops:OptionsPattern[]
  ]:=
  Module[
    {
      gfs=
        Replace[OptionValue["GridType"],
          {
            k:_Cross|_NonCommutativeMultiply|_(Inactive[CircleTimes]):>List@@k,
            {s_, n_Integer}:>ConstantArray[s, n],
            s_?AtomQ:>ConstantArray[s, Length@pts]
            }
          ],
      grids,
      transforms,
      gfdim
      },
    gfs=
      Replace[
        Flatten[{gfs}, 1],
        b:{"BasisSet", ___}:>{b}
        ];
    gfdim=
      Length@gfs;
    If[gfdim=!=Length@pts, 
      PackageRaiseException[
        Automatic,
        "Dimensions of grid (``) and number of grid types (``) don't match",
        Length@pts, 
        gfdim
        ]
      ];
    grids=
      MapThread[
        Switch[#,
          _String,
            Replace[ChemDVRDefaultNamedGrid[#, #2, #3],
              ChemDVRDefaultNamedGrid[s_, __]:>
                PackageRaiseException[
                  Automatic,
                  "\"GridType\" `` not known",
                  s
                  ]
              ],
          {"BasisSet", __},
            Replace[
              iChemDVRBasisSetGrid[Rest@#, #2, #3],
              Except[{{__?NumericQ}, _?SquareMatrixQ}]:>
                PackageRaiseException[
                  Automatic,
                  "\"BasisSet\" `` did not return proper grid",
                  Rest@#
                  ]
              ],
          _,
            #[#2, #3]
          ]&,
        {
          gfs,
          pts,
          regions
          }
        ];
    grids=
      Replace[grids,
        {
          g:Except[{{__?NumericQ}, _?SquareMatrixQ}]:>
            {g, None}
          },
        1
        ];
    transforms=grids[[All, 2]];
    grids=grids[[All, 1]];
    {
      Replace[
        grids,
        {
          {l_}:>l,
          l:{__}:>ChemDVRDirectProductGrid[l]
          }
        ],
      Replace[transforms, {l_}:>l]
      }
    ]


End[];



