(* ::Package:: *)

(* Autogenerated Package *)

(* ::Section:: *)
(*Grid Function Tools*)



(* ::Subsubsection::Closed:: *)
(*Constructors*)



ConstructGridFunction;
GridFunctionObjectQ;


(* ::Subsubsection::Closed:: *)
(*Parts*)



GFPart::usage=
  "Applies part to a grid function";
GFKeyPart::usage=
  "Applies key lookup to a grid function";
GFSlice::usage=
  "Slices at level n";


(* ::Subsubsection::Closed:: *)
(*Structural*)



GFPoints::usage=
  "Flattens down to the coordinate points";
GFArray::usage=
  "Creates the normal array";
GFMap::usage=
  "Applies a transformation to the coordinates points, maintaining ordering";
GFSort::usage=
  "";
GFTranspose::usage=
  "Takes a transpose of coordinates in the grid";
GFPermute::usage=
  "Permutes coordinates in the grid";


(* ::Subsubsection::Closed:: *)
(*Manipulation*)



GFScale::usage="";
GFShift::usage="";
GFRescale::usage="";
GFClip::usage="";
GFChop::usage="";


(* ::Subsubsection::Closed:: *)
(*Higher-Level*)



GFCombine::usage=
  "Combines GridFunctions by value";
GFAdd::usage=
  "Raw Plus over GridFunctions";
GFMultiply::usage=
  "Raw Times over GridFunctions";
GFSubtract::usage="";
GFDivide::usage="";


GFDerivative::usage=
  "Finite difference derivatives";
GFIntegrate::usage=
  "Dot-based integration";
(*GFInterpolate::usage=
	"Distinct from GFInterpolation in that it does the interpolation by hand";*)


GFKroneckerProduct::usage=
  "Kronecker product over grid functions";


GFCompile::usage=
  "Clever-ish compilation";


(* ::Subsubsection::Closed:: *)
(*Mindless*)



GFInterpolation::usage=
  "";
GFMinMax::usage=
  "";
GFDimension::usage=
  "";
GFLength::usage=
  "";


Begin["`Private`"];


(* ::Subsection:: *)
(*Constructor*)



(* ::Subsubsection::Closed:: *)
(*ConstructGridFunction*)



(* ::Subsubsubsection::Closed:: *)
(*validateGFData*)



validateGFData[{grid_, values_}]:=
  Module[
    {
      dn
      },
    If[!Developer`PackedArrayQ@values,
      PackageRaiseException[
        Automatic,
        "grid function values cannot be packed"
        ]
      ];
    Dimensions[values]===GridDimensions[grid]
    ]


(* ::Subsubsubsection::Closed:: *)
(*cleanGFData*)



cleanGFData[g_, vals_]:=
  Module[
    {
      base=N@Developer`ToPackedArray@vals,
      grid,
      gplen
      },
    If[!Developer`PackedArrayQ[base],
      PackageRaiseException[
        Automatic,
        "Function data cannot be packed"
        ]
      ];
    grid=If[!CoordinateGridObjectQ@g, CoordinateGridObject[g], g];
    If[!CoordinateGridObjectQ@grid,
      PackageRaiseException[
        Automatic,
        "grid function coordinate grid improperly defined"
        ]
      ];
    If[GridPointNumber[grid]=!=Times@@Dimensions[base],
      PackageRaiseException[
        Automatic,
        "number of grid points (``) and function values (``) disagaree",
        GridPointNumber[grid],
        GridPointNumber[base]
        ]
      ];
    If[GridDimensions[grid]=!=Dimensions[base],
      If[Depth@base==2,
        base=ArrayReshape[base, Dimensions[grid]],
        PackageRaiseException[
          Automatic,
          "Grid dimensions (``) and function dimensions (``) disagaree",
          Dimensions[grid],
          Dimensions[base]
          ]
        ]
      ];
    {
      grid,
      base(*Map[List, base, {Depth[base]-1}]*)
      }
    ]


(* ::Subsubsubsection::Closed:: *)
(*ConstructCoordinateGrid*)



ConstructGridFunction[grid_, vals_]:=
  With[{g=cleanGFData[grid, vals]},
    If[validateGFData[g],
      <|"Grid"->g[[1]], "Values"->g[[2]]|>,
      <|$Failed->True|> (* requires Association return to throw the error *)
      ]
    ];
ConstructGridFunction[a_Association]:=
  a; (* should probably just do a quick validation... *)


(* ::Subsection:: *)
(*Meh*)



GFModify[gf_, justOneFunc_]:=
  InterfaceModify[
    GridFunctionObject,
    gf,
    With[{newb=justOneFunc@Lookup[#, {"Grid", "Values"}]},
      ReplacePart[#,
        {
          "Grid"->#[[1]],
          "Values"->#[[2]]
          }
        ]
      ]&
    ];


GFModify[gf_, gridF_, valF_]:=
  InterfaceModify[
    GridFunctionObject,
    gf,
    MapAt[
      valF,
      MapAt[gridF, #, "Grid"],
      "Values"
      ]&
    ]


(* ::Subsection:: *)
(*GridFunction Parts*)



(* ::Subsubsection::Closed:: *)
(*GFPart*)



GFPart[c:GridFunctionObject[a_], p__]:=
  If[CoordinateGridObjectQ@#["Grid"],
    GridFunctionObject[#],
    Append@@Lookup[#, {"Grid", "Values"}]
    ]&@
    MapAt[
      Part[#, p]&,
      a,
      {{"Grid"}, {"Values"}}
      ];


(* ::Subsubsection::Closed:: *)
(*GFKeyPart*)



GFKeyPart[c:GridFunctionObject[a_], sel__]:=
  a[sel]


(* ::Subsection:: *)
(*Structural*)



(* ::Subsubsection::Closed:: *)
(*GFArray*)



GFArray[grid_List, vals_List]:=
  Module[{d1=Dimensions[grid], d2=Dimensions[vals], dp=Depth[vals]},
    If[d1[[;;-2]]=!=d2,
      PackageRaiseException["GridFunction",
        "Grid function grid and values have inconsistent dimensions (`` and ``)",
        d1,
        d2
        ]
      ];
    If[
      Length@d1>1,
        Join[grid, Map[List, vals, {dp-1}], dp],
        PackageRaiseException["Grid",
          "Grid `` has depth 1...?",
          grid
          ]
      ]
    ];
GFArray[grid_]:=
  GFArray[grid["Grid"]["Grid"], grid["Values"]]


(* ::Subsubsection::Closed:: *)
(*GFPoints*)



GFPoints[grid_List, vals_List]:=
  Flatten[GFArray[grid, vals], Depth[vals]-2];
GFPoints[grid_]:=
  GFPoints[grid["Grid"]["Grid"], grid["Values"]]


(* ::Subsubsection::Closed:: *)
(*GFMap*)



GFMap[tf_, {grid_List, vals_List}]:=
  Module[{d=Depth[vals], array=GFArray[grid, vals]},
    Developer`ToPackedArray@N@Map[tf, array, {Depth[vals]-1}]
    ];
GFTransform[tf_, f_]:=
  GFTransform[tf, {f["Grid"]["Grid"], f["Values"]}];


(* ::Subsubsection::Closed:: *)
(*GFPermute*)



GFPermute[g_GridFunctionObject, newIndices_]:=
  PackageExceptionBlock["GridPermute"]@
    GFModify[g, 
      GridPermute[#, newIndices]&,
      Transpose[#, Ordering@newIndices]&
      ]


(* ::Subsubsection::Closed:: *)
(*GFSlice*)



iGFSlice[vals_, n__Integer]:=
  Part[
    vals,
    n,
    Sequence@@
      ConstantArray[All, 
        Depth[vals]-(2+Length[{n}])
        ]
    ];
GFSlice[g_, n__Integer]:=
  GFModify[
    g, 
    GridSlice[#, n]&,
    iGFSlice[#, n]&
    ];


(* ::Subsection:: *)
(*Manipulation*)



(* ::Subsubsection::Closed:: *)
(*GFScale*)



GFScale//Clear
GFScale[{grid_, values_}, n_?NumericQ]:=
  {grid, values*n};
GFScale[{grid_, values_}, {n_?NumericQ, base_?NumericQ}]:=
  {grid, base+n*(values-base)};
GFScale[gf_GridFunctionObject, spec:_?NumericQ|{_?NumericQ, _?NumericQ}]:=
  GridFunctionObject@@
    GFScale[{gf["Grid"], gf["Values"]}, spec];


(* ::Subsubsection::Closed:: *)
(*GFShift*)



GFShift//Clear
GFShift[{grid_, values_}, n_?NumericQ]:=
  {grid, values+n};
GFShift[{grid_, values_}, Scaled[i_?NumericQ]]:=
  GFShift[{grid, values}, Subtract@@Reverse@MinMax[values]];
GFShift[gf_GridFunctionObject, spec:_?NumericQ|Scaled[_?NumericQ]]:=
  GridFunctionObject@@
    GFShift[{gf["Grid"], gf["Values"]}, spec];


(* ::Subsubsection::Closed:: *)
(*GFRescale*)



(* ::Text:: *)
(*
	This requires some thought to do appropriately and cleanly
*)



(* ::Subsubsubsection::Closed:: *)
(*getGFScalingRange*)



getGFScalingRange[values_, minmax_, {m_?NumericQ, n_?NumericQ}]:=
  {m, n};
getGFScalingRange[values_, minmax_, {Scaled[i_?NumericQ], n_}]:=
  getGFScalingRange[values, minmax, {i*minmax[[1]], n}];
getGFScalingRange[values_, minmax_, {m_, Scaled[i_?NumericQ]}]:=
  getGFScalingRange[values, minmax, {m, i*minmax[[2]]}];
getGFScalingRange[values_, minmax_, 
  Offset[spec_, x_?NumericQ]
  ]:=
  With[{s=getGFScalingRange[values, minmax, spec]},
    s-x(* ...this might not be right...? *)
    ];
getGFScalingRange[values_, minmax_, 
  Offset[spec_, Scaled[n_]]
  ]:=
  getGFScalingRange[
    values, minmax,
    Offset[spec, Rescale[n, {0, 1}, minmax]]
    ]


(* ::Subsubsubsection::Closed:: *)
(*iGFRescale*)



iGFRescale//Clear
iGFRescale[{grid_, values_}, minmax_, spec_]:=
  With[{gspec=getGFScalingRange[values, minmax, spec]},
    If[ListQ@gspec,
      {grid, Rescale[values, minmax, gspec]},
      PackageRaiseException[
        Automatic,
        "Spec `` is invalid for GFRescale",
        spec
        ]
      ]
    ];
iGFRescale[{grid_, values_}, spec_]:=
  iGFRescale[{grid, values}, MinMax@values, spec];


(* ::Subsubsubsection::Closed:: *)
(*GFRescale*)



GFRescale//Clear


GFRescale[
  gf_GridFunctionObject,
  minMax:({_?NumericQ, _?NumericQ}|Automatic):Automatic,
  spec_
  ]:=
  With[
    {
      res=
        PackageExceptionBlock["GFRescale"]@
          iGFRescale[{gf["Grid"], gf["Values"]}, spec]
      },
    GridFunctionObject@@res/;ListQ@res
    ];


(* ::Subsubsection::Closed:: *)
(*GFClip*)



GFClip[f_GridFunctionObject, s__]:=
  With[{vs=Clip[f["Values"], s]},
    GridFunctionObject[f["Grid"], vs]/;ListQ@vs
    ];


(* ::Subsubsection::Closed:: *)
(*GFChop*)



GFChop[f_GridFunctionObject, s__]:=
  With[{vs=Threshold[f["Values"], s]},
    GridFunctionObject[f["Grid"], vs]/;ListQ@vs
    ];


(* ::Subsection:: *)
(*Mindless*)



GFInterpolation[f_, a___]:=
  Interpolation[GFPoints[f], a];
GFMinMax[f_, a___]:=
  MinMax[f["Values"], a];
GFDimension[f_]:=
  GridDimension[f["Grid"]];
GFLength[f_]:=
  GridLength@f["Grid"]


(* ::Subsection:: *)
(*Higher Level*)



(* ::Subsubsection::Closed:: *)
(*GFKroneckerProduct*)



GFKroneckerProduct//Clear
GFKroneckerProduct[g_GridFunctionObject, g2__GridFunctionObject]:=
  Module[
    {dimensions, targetDimension, points, grid, vals, kp, op},
    dimensions=#["Dimensions"]&/@{g, g2};
    targetDimension=Join@@dimensions;
    points=GFPoints/@{g, g2};
    grid=points[[All, All, ;;-2]];
    vals=points[[All, All, -1]];
    kp=KroneckerProduct@@vals;
    op=Join@@@Tuples@grid;
    grid=ArrayReshape[op, Append[targetDimension, Length@targetDimension]];
    vals=ArrayReshape[kp, targetDimension];
    GridFunctionObject[grid, vals]
    ]


(* ::Subsubsection::Closed:: *)
(*GFCombine*)



GFCombine[combiner_, f_GridFunctionObject, s__GridFunctionObject]:=
  Module[{vals=#["Values"]&/@{f, s}},
    vals=combiner@vals;
    GFModify[f, Identity, vals&](* surely this is not the best way to do this... *)
    ]


(* ::Subsubsection::Closed:: *)
(*GFAdd*)



GFAdd[f_GridFunctionObject, s__GridFunctionObject]:=
  GFCombine[Apply[Plus], f, s];


(* ::Subsubsection::Closed:: *)
(*GFSubtract*)



GFSubtract[f_GridFunctionObject, s__GridFunctionObject]:=
  GFCombine[Apply[Subtract], f, s];


(* ::Subsubsection::Closed:: *)
(*GFDivide*)



GFMultiply[f_GridFunctionObject, s__GridFunctionObject]:=
  GFCombine[Apply[Divide], f, s];


(* ::Subsubsection::Closed:: *)
(*GFMultiply*)



GFMultiply[f_GridFunctionObject, s__GridFunctionObject]:=
  GFCombine[Apply[Times], f, s];


(* ::Subsubsection::Closed:: *)
(*GFCompile*)



(* ::Subsubsubsection::Closed:: *)
(*Pointwise*)



iGFPointwiseInterpCut[
  interp_,
  coords:{(Automatic|_?NumericQ)..},
  preProcessor_,
  def_, 
  min_
  ]:=
  Module[{potInterp=interp, dom=interp[[1]], preCoords, i=1, getPot},
    preCoords=preProcessor@coords;
    getPot[a_]:=Apply[potInterp, a];
    If[Length@preCoords=!=Length@dom,
      PackageRaiseException[
        Automatic,
        "Interpolation dimensions (``) and passed coordinate dimensions (``) don't match",
        Length@dom,
        Length@coords
        ]
      ];
    Block[{crds},
      Compile@@
        With[
          {
            test=
              With[{tests=MapThread[#[[1]]<=#2<=#[[2]]&, {dom, preCoords}]},
                If[MemberQ[tests, False&],
                  False,
                  And@@DeleteCases[tests, True]
                  ]
                ],
            crdSpec=
              Quiet@
                preProcessor@
                  Map[
                    If[#===Automatic, crds[[i++]], #]&,
                    crds
                    ]
            },
          Hold[
            {{crds, _Real}},
            Module[{default=def, mininmum=min},
              If[test,
                getPot[crdSpec]-mininmum,
                default
                ]
              ],
            {{getPot[_], _Real, 1}},
            RuntimeOptions->{
              "EvaluateSymbolically"->False,
              "WarningMessages"->False
              },
            RuntimeAttributes->{Listable}
            ]
          ]
        ]
      ];


(* ::Subsubsubsection::Closed:: *)
(*Vectorized*)



iGFVectorizedInterpCut[interp_, coords_, preProcessor_, def_, min_]:=
  Module[{potInterp=interp, dom=interp[[1]], j=1},
    Block[{crds, pt, gps},
        Module[
          {
            getPot,
            varBlock,
            varBlock2,
            preCoords
            },
          getPot[a_]:=Apply[potInterp, a];
          preCoords=
            Quiet@
              preProcessor@
                Map[
                  If[#===Automatic, 
                    Compile`GetElement[crds, j++], 
                    #
                    ]&,
                  coords
                  ];
          j=1;
          (* bounds checking for test *)
          With[
            {
              test=
                With[
                  {
                    tests=
                      MapThread[
                        #[[1]]<=
                          If[NumericQ[#2], 
                            j++;#2, 
                            Compile`GetElement[pt, j++]
                            ]<=#[[2]]&, 
                        {dom, preCoords}
                        ]
                    },
                  If[MemberQ[tests, False],
                    False,
                    And@@DeleteCases[tests, True]
                    ]
                  ],
              crdSpec=preCoords,
              means=Mean/@dom,
              fn=
                Compile[
                  {{crds, _Real, 1}},
                  Evaluate@preCoords,
                  RuntimeAttributes->{Listable}
                  ]
              },
            Compile@@
              Hold[(* True Compile body but with Hold for code injection *)
                {{gps, _Real, 2}},
                Module[
                  {
                    pts=fn@gps,
                    ongrid=Table[0, {i, Length@gps}],
                    intres,
                    midpt=means,
                    interpvals,
                    interpcounter,
                    interppts,
                    i=1,
                    barrier=def,
                    minimum=min
                    },
                  interppts=Table[midpt, {i, Length@pts}];
                  (* Find points in domain *)
                  interpcounter=0;
                  Do[
                    If[test,
                      ongrid[[i]]=1;
                      interppts[[++interpcounter]]=pt
                      ];
                    i++,
                    {pt, pts}
                    ];
                  (* Apply InterpolatingFunction only once (one MainEval call) *)
                  If[interpcounter>0,
                    intres=interppts[[;;interpcounter]];
                    interpvals=getPot[Transpose@intres]-minimum;
                    (* Pick points that are in domain *)
                    interpcounter=0;
                    Map[
                      If[#==1, interpvals[[++interpcounter]], barrier]&,
                      ongrid
                      ],
                    Table[barrier, {i, Length@gps}]
                    ]
                  ],
                {{getPot[_], _Real, 1}},
                RuntimeOptions->{
                  "EvaluateSymbolically"->False,
                  "WarningMessages"->False
                  },
                CompilationOptions->{"InlineExternalDefinitions" -> True},
                RuntimeAttributes->{Listable}
              ]
            ]
          ]
        ]
      ];


(* ::Subsubsubsection::Closed:: *)
(*GFCompile*)



Options[GFCompile]=
  {
    "CoordinateTransformation"->Identity,
    "Minimum"->0.,
    "Default"->0.,
    "Mode"->"Vector"
    };
GFCompile[
  gf_, 
  coordSpec:{(Automatic|_?NumericQ)..}|Automatic:Automatic,
  ops:OptionsPattern[]
  ]:=
  If[OptionValue["Mode"]==="Vector",
    iGFVectorizedInterpCut,
    iGFPointwiseInterpCut
    ][
      GFInterpolation[gf],
      Replace[
        coordSpec, 
        Automatic:>ConstantArray[Automatic, GFDimension[gf]]
        ],
      OptionValue["CoordinateTransformation"],
      OptionValue["Default"],
      OptionValue["Minimum"]
      ]


(* ::Subsubsection::Closed:: *)
(*GFAverage*)



(* ::Text:: *)
(*
	Should allow for averaging a function over some of the dimensions using an appropriate PDF.
	PDF must first be discretized if necessary, dimensions should be checked, and grid slicing performed as 
	needed.
*)



(* ::Subsubsubsection::Closed:: *)
(*iGFAverage*)



iGFAverage[{grid_, values_}, dist_, n_]:=
  values


(* ::Subsubsubsection::Closed:: *)
(*GFAverage*)



(*GFAverage[gf_, dist_]:=*)


(* ::Subsubsection::Closed:: *)
(*GFIntegrate*)



(* ::Text:: *)
(*
	One-dimensional integration via Trapezoid Rule...in n-dim unspecified. 
	Asked about here: https://mathematica.stackexchange.com/questions/189007/trapezoid-rule-esque-integration-with-unevenly-spaced-n-d-grid
*)



GFIntegrate[
  grid_List?(VectorQ[#, Internal`RealValuedNumericQ]&), 
  f_List?(VectorQ[#, Internal`RealValuedNumericQ]&)
  ]:=
  Module[
    {
      diffs=Differences[grid],
      means=MovingAverage[f, 2]
      },
    diffs.means
    ];
GFIntegrate[
  grid_List?(VectorQ[#, Internal`RealValuedNumericQ]&), 
  f_List?(VectorQ[#, Internal`RealValuedNumericQ]&),
  vec_List?(VectorQ[#, Internal`RealValuedNumericQ]&)
  ]:=
  GFIntegrate[grid, f*vec];


End[];



