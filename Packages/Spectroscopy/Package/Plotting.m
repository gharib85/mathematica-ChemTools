(* ::Package:: *)

(* Autogenerated Package *)

(* ::Subsubsection::Closed:: *)
(*View*)



ChemSpectrumPlot::usage="Plots a spectrum";
ChemSpectrumViewer::usage=
  "An interactive viewer to focus on pieces of a spectrum";


(* ::Subsubsection::Closed:: *)
(*Selector*)



ChemSpectrumLineStore::usage=
  "Represents a cache of lines. 
Has HoldFirst and can be used as an operator to add to the cache."; 


ChemSpectrumLineSelector::usage=
  "An interactive spectrum viewer and selector.
Has stacking, zooming, a cursor, and can apply an arbitrary function.
To be used with the operator form of ChemSpectrumLineStore";


Begin["`Private`"];


(* ::Subsection:: *)
(*Viewing*)



(* ::Subsubsubsection::Closed:: *)
(*Continuous*)



chemSpectrumPlotContinuous[spec_, ops:OptionsPattern[]]:=
  ListLinePlot[
    spec["Points"],
    FilterRules[
      {
        ops
        },
      Options@ListLinePlot
      ]
    ]


(* ::Subsubsubsection::Closed:: *)
(*Discrete*)



(* ::Subsubsubsubsection::Closed:: *)
(*Old*)



Options[chemSpectrumPlotDiscreteOld]=
  Options@ListLinePlot;
chemSpectrumPlotDiscreteOld[
  spec_,
  ops:OptionsPattern[]
  ]:=
  Module[
    {
      freqs,
      pts,
      ints,
      data,
      padding
      },
    freqs=spec["Frequencies"];
    ints=spec["Intensities"];
    pts=Transpose[{freqs, ints}];
    padding=
      Transpose[
        {
          freqs, 
          ConstantArray[Rescale[-10.^-6, {0, 1}, MinMax[ints]], Length@freqs]
          }
        ];
    data=
      Riffle[
        Riffle[padding, pts],
        padding,
        3
        ];
    ListLinePlot[
      data,
      FilterRules[
        {
          ops,
          PlotRange->{All, Threshold@MinMax@ints},
          PlotStyle->Red
          },
        Options@ListLinePlot
        ]
      ]
    ];


(* ::Subsubsubsubsection::Closed:: *)
(*New*)



Options[chemSpectrumPlotDiscrete]=
  Options@ListLinePlot;
chemSpectrumPlotDiscrete[
  spec_,
  ops:OptionsPattern[]
  ]:=
  Module[
    {
      freqs,
      pts,
      ints,
      data,
      padding
      },
    freqs=spec["Frequencies"];
    ints=spec["Intensities"];
    pts=Transpose[{freqs, ints}];
    ListPlot[
      pts,
      FilterRules[
        {
          ops,
          PlotRange->All,
          PlotStyle->Red,
          PlotMarkers->Style["", ShowStringCharacters->False],
          Filling->Axis,
          FillingStyle->Opacity[1]
          },
        Options@ListLinePlot
        ]
      ]
    ];


(* ::Subsubsubsection::Closed:: *)
(*Distribution*)



Options[chemSpectrumPlotDistribution]=
  Join[
    Options[Plot],
    {
      "DistributionFunction"->Automatic
      }
    ];
chemSpectrumPlotDistribution[
  spec_,
  ops:OptionsPattern[]
  ]:=
  Module[
    {
      dist=
        Replace[OptionValue["DistributionFunction"], 
          {
            Automatic->
              ChemSpectrumNormalDistribution
            }
          ]@spec,
      pdf,
      frange=spec["FrequencyRange"]
      },
    pdf=PDF[dist, $x];
    Plot[pdf,
      {$x, frange[[1]], frange[[2]]},
      Evaluate@FilterRules[{ops}, Options@Plot]
      ]
    ]


(* ::Subsubsubsection::Closed:: *)
(*Plot*)



$plotModeMap=
  <|
    "Continuous"->chemSpectrumPlotContinuous,
    "Discrete"->chemSpectrumPlotDiscrete,
    "Distribution"->chemSpectrumPlotDistribution
    |>


ChemSpectrumPlot[spec_, 
  mode:_?(KeyExistsQ[$plotModeMap, #]&)|Automatic:Automatic,
  ops:OptionsPattern[]
  ]:=
  Module[
    {
      fn=
        If[mode===Automatic,
          $plotModeMap[spec["Mode"]],
          $plotModeMap[mode]
          ]
      },
    fn[spec, ops]
    ]


(* ::Subsubsection::Closed:: *)
(*Viewer*)



(* ::Text:: *)
(*
	Needs an extension to better the new spectrum handling formats. Add in some stuff for Gaussian broadening.
*)



Options[ChemSpectrumViewer]=
  DeleteDuplicatesBy[Join[Options@ChemSpectrumPlot,Options@ChemSpectrumPlotDiscrete],First];
ChemSpectrumViewer[
  spectrum_ChemSpectrum,
rangeStart:{
    {_Scaled|_?NumericQ,_Scaled|_?NumericQ},
    {_Scaled|_?NumericQ,_Scaled|_?NumericQ}
    }:{
      {Scaled[.25],Scaled[.75]},
      {0.035,Scaled[1]}
      },
  plotFuntion:ChemSpectrumPlot|ChemSpectrumPlotDiscrete|Automatic:Automatic,
  ops:OptionsPattern[]]:=
  With[{plotF=
    Replace[plotFuntion,
      Automatic:>Switch[First@spectrum,_List,ChemSpectrumPlot,_,ChemSpectrumPlotDiscrete]
      ]},
      With[{
        d=Replace[OptionValue@ImageSize,{
          Large|Automatic->{600,600/3},
          Small->{250,250/3},
          e:{_,_}:>e,
          _->{150,150/3}
          }],
        R=Range@spectrum,
        M=MinMax@spectrum},
          With[{
            rMinS=
              Max@{
                  Replace[rangeStart[[1,1]],Scaled[s_]:>(First@R+s*((Last@R-First@R)))],
                  First@R
                  },
            rMaxS=
              Min@{
                  Replace[rangeStart[[1,2]],Scaled[s_]:>(First@R+s*((Last@R-First@R)))],
                  Last@R
                  },
            hMinS=
              Max@{
                  Replace[rangeStart[[2,1]],Scaled[s_]:>(First@M+s*((Last@M-First@M)))],
                  First@M
                  },
            hMaxS=
              Max@{
                  Replace[rangeStart[[2,2]],Scaled[s_]:>(First@M+s*((Last@M-First@M)))],
                  Last@M
                  }
            },
            DynamicModule[
              {rRange,hRange,applyUpdates},
              Panel@
                Grid[{
                  {
                    Panel[
                      Column[
                        {
                          EventHandler[
                            Dynamic[
                              applyUpdates;
                              plotF[spectrum[rRange,hRange],
                                ImageSize->d,
                                PlotRange->{rRange,hRange},
                                PlotRangePadding->0,
                                ops
                                ],
                              SynchronousUpdating->False,
                              TrackedSymbols:>{applyUpdates}
                              ],
                            "MouseClicked":>(applyUpdates=RandomReal[])
                            ],
                        EventHandler[
                          Grid[{
                            {"Scanning Range: ",
                              InputField[
                                Dynamic[
                                  Round[rRange[[1]],.001],
                                    rRange[[1]]=Max@{First@R,#};&],
                                  Number,
                                  Appearance->"Frameless"],
                              InputField[
                                Dynamic[
                                  Round[rRange[[2]],.001],
                                    rRange[[2]]=Min@{Last@R,#};&],
                                  Number,
                                  Appearance->"Frameless"]
                                },
                            {"Intensity Range: ",
                              InputField[
                                Dynamic[
                                  Round[hRange[[1]],.001],
                                    hRange[[1]]=Max@{First@M,#};&],
                                  Number,
                                  Appearance->"Frameless"],
                              InputField[
                                Dynamic[
                                  Round[hRange[[2]],.001],
                                    hRange[[2]]=Min@{Last@M,#};&],
                                  Number,
                                  Appearance->"Frameless"]}
                              },
                            Alignment->Left
                            ],
                          "ReturnKeyDown":>(applyUpdates=RandomReal[])
                          ]
                        },
                      Dividers->Center
                      ],
                    Background->White
                    ],
                    Control@{
                        {hRange,{hMinS,hMaxS},""},First@M,Last@M,
                          ImageSize->{25,Last@d},
                          ControlType->IntervalSlider,
                          ContinuousAction->False,
                          Appearance->"Vertical"
                        }~EventHandler~{
                          "MouseUp":>(applyUpdates=RandomReal[]),
                          PassEventsDown->True
                          }
                          
                    },
                  {
                    Control@{
                        {rRange,{rMinS,rMaxS},""},First@R,Last@R,
                          ImageSize->{First@d,25},
                          ControlType->IntervalSlider,
                          ContinuousAction->False
                        }~EventHandler~{
                          "MouseUp":>(applyUpdates=RandomReal[]),
                          PassEventsDown->True
                          }
                    }
                  },
                  Alignment->{Left,Top}
                  ],
              SynchronousInitialization->False,
              SaveDefinitions->False
              ]//Deploy
            ]
        ]
    ];


(* ::Subsubsection::Closed:: *)
(*LineStore*)



ChemSpectrumLineStore[sym_,pos_,scaling_,spectra_,
  selectFrom:_InterpolatingFunction|_Composition|_Integer:1
  ]:=(
    If[MatchQ[sym,_Symbol],sym={}];
    AppendTo[sym,
      Replace[selectFrom,{
        f:(First@*First@*_NearestFunction):>
          f@pos,
        e_:>
          ChemSpectrumNearestPeak[
            Replace[selectFrom,
              i_Integer:>spectra[[i]]
              ],
            pos]
        }]
      ]
    );
ChemSpectrumLineStore[sym_,
  selectFrom:_Composition|_InterpolatingFunction|_Integer:1][a___]:=
  ChemSpectrumLineStore[sym,a,selectFrom];
ChemSpectrumLineStore~SetAttributes~HoldFirst;


ChemSpectrumLineStore/:
  HoldPattern[Normal@ChemSpectrumLineStore[s_,___]]:=
    s;
ChemSpectrumLineStore/:
  HoldPattern[ChemSpectrum@ChemSpectrumLineStore[s_,___]]:=
    ChemSpectrum@s;
ChemSpectrumLineStore/:
  HoldPattern[ChemSpectrumPlot[ChemSpectrumLineStore[s_,___],ops___]]:=
    ChemSpectrumPlotDiscrete[
      AssociationThread[
        {"Frequencies","Weights","Transitions"},
        Append[Thread[s,List],ConstantArray[{1,0,0,0,0,0},Length@s]]
        ],ops];
  


(* ::Subsubsection::Closed:: *)
(*LineSelector*)



ChemSpectrumLineSelector[
  spectrumA_ChemSpectrum,others___ChemSpectrum,
  selectFunction:
    Except[_ChemSpectrum|_Rule|_RuleDelayed|_String]:
    (Print[#1]&),
  ops:(_Rule|_RuleDelayed)...]:=
With[{spectra=
  With[{pr=Last@First@FilterRules[{ops,PlotRange->All},PlotRange]},
  MapThread[
    Switch[#2,
      {_?NumericQ|-\[Infinity]|_Scaled,_?NumericQ|\[Infinity]|_Scaled},
        #[All,#2],
      _?NumericQ|_Scaled,
        #[All,{#2,\[Infinity]}],
      _,
        #
      ]&,
      {
        {spectrumA,others},
        Switch[pr,
            {_?NumericQ|-\[Infinity]|_Scaled,_?NumericQ|\[Infinity]|_Scaled}|Except[_List],
              ConstantArray[pr,Length@{spectrumA,others}],
            _,
              PadRight[
                Take[pr,UpTo[Length@{spectrumA,others}]],
                Length@{spectrumA,others},
                All]
            ]
        }]
    ]},  
With[{
  plots=
    With[{
      ps=Last@First@FilterRules[{ops,PlotStyle->Automatic},PlotStyle]
      },
      MapThread[
        ChemSpectrumPlot[
          #,
          Sequence@@Join[
            #2,
            FilterRules[{ops},
              DeleteCases[
                Keys@Merge[{
                  Options@ChemSpectrumPlot,
                  Options@ChemSpectrumPlotDiscrete
                  },
                  First
                  ],
                PlotStyle|PlotRange
                ]
              ]
            ]
          ]&,
        {
          spectra,
          With[{directives=(_Symbol|_Directive|_Opacity|_Thickness|_RGBColor|_Hue)},
            If[
              TrueQ[
                MatchQ[ps,{(directives|{directives..})..}]&&
                Length@ps==Length@spectra
                ],
              Replace[Flatten@{#},
                d:directives|{directives..}:>
                  (PlotStyle->d),
                1]&/@ps,
              ConstantArray[{PlotStyle->Flatten@{ps}},
                Length@spectra
                ]
              ]
            ]
          }]
      ],
  selF=
    Replace[selectFunction,{
      ChemSpectrumLineStore[s_]:>
        ChemSpectrumLineStore[s,Interpolation@Last@spectra]
      }],
  R=Range@spectrumA,
  S=Subtract@@Reverse@Range@spectrumA,
  M=MinMax/@spectra,
  makeDialog=TrueQ@Last@First@FilterRules[{ops,CreateDialog->True},CreateDialog],
  cachedPoints=
    Last@First@FilterRules[{ops,
      "CachedPoints"->
        Replace[selectFunction,{
          c:ChemSpectrumLineStore[s_,___]:>c,
          _->{}
          }]
        },"CachedPoints"],
  singlePlot=(
    Length@spectra==1||
    TrueQ@Last@First@FilterRules[{ops,Overlay->False},Overlay]
    ),
  WH=
    Replace[
      First@FilterRules[{ops,ImageSize->{500,250}},ImageSize],{
      (ImageSize->{w_,h_}):>
        {Replace[w,Except[_Integer]:>500],Replace[h,Except[_Integer]:>250]},
      (ImageSize->w_):>
        {
          Replace[w,Except[_Integer]:>500],
          .5*Replace[w,Except[_Integer]:>500]
          }
      }]},
  (*------------------Display Window--------------------*)
  DynamicModule[{
    raster,update,
    windowWidth=First@WH,
    windowHeight=(Last@WH)*If[singlePlot,1,Length@plots],
    r,m,rOld=0,v,vOld=0,doFast=False,failSize=0.01},
    Panel@
      Grid@{
        {
        DynamicWrapper[
          Dynamic[
            update;
            Overlay[{
              (*------------------Main Graphic--------------------*)
              Graphics[
                Inset[
                  raster
                  (*ReplaceAll[raster,
										g_Graphics\[RuleDelayed]
											Show[g,
												PlotRange\[Rule]
													ReplacePart[PlotRange@g,
														1->Rescale[{m-r/2,m+r/2},{0,1},R]
														]
												]
										]*),
                  Scaled@{.5,0},Scaled@{m,0}],
                PlotRange->
                  {
                    {0,windowWidth},
                    {0,windowHeight}
                    },
                ImagePadding->None,
                ImageSize->{windowWidth,windowHeight-25},
                AspectRatio->Full,
                PlotRangePadding->None,
                Background->White
                ],
              (*------------------Cursor + Labels--------------------*)
              Graphics[{Thin,Opacity[.5],
                Line@{{.5,(20/windowHeight)},{.5,1}},
                GrayLevel[.3],
                Inset[
                  Rescale[m,{0,1},R],
                    {.5,0},{Center,Bottom}],
                Inset[
                  Rescale[m-r/2,{0,1},R],
                  {0,0},{Left,Bottom}],
                Inset[
                  Rescale[m+r/2,{0,1},R],
                  {1,0},{Right,Bottom}],
                Green,
                Replace[
                  Map[
                    If[Between[#,Rescale[{m-r/2,m+r/2},{0,1},R]],
                      {#,(25/windowHeight)},
                      Nothing
                      ]&,
                    Replace[Normal@cachedPoints,{f_,_}:>f,1]
                    ],{
                    l:{__}:>Point@l,
                    _:>Nothing
                    }
                  ]
                },
                PlotRange->{{0,1},{0,1}},
                ImageSize->{windowWidth,windowHeight},
                AspectRatio->Full,
                ImagePadding->None,
                ImageMargins->None,
                PlotRangePadding->None
                ]
              },
              ImageSize->{windowWidth,windowHeight},
              Alignment->{Center,Top}
              ]//Framed[#,
                Background->White,
                FrameStyle->GrayLevel[.75],
                BaseStyle->"Panel"]&,
              TrackedSymbols:>{m,raster}
            ],
          (*-----------------Generate Graphic------------------------*)
          raster=
            With[{
              dims={
                windowWidth/r,
                (windowHeight/If[singlePlot,1,Length@plots])-10
                }
              },
              With[{
                baseOps={
                  ImageSize->{First@dims,Last@dims},
                  AspectRatio->Full,
                  ImagePadding->All,
                  Ticks->None,
                  Background->White,
                  Axes->{True,False},
                  ImageMargins->None
                  }
                },
              With[{graphic=
                If[singlePlot,
                  Show[plots,
                    Sequence@@baseOps,
                    PlotRange->{R,{Min@Append[M[[All,1]],0],Max@M[[All,2]]*v}}
                    ],
                Column@
                  Reverse@MapThread[
                    Show[#,
                      Sequence@@baseOps,
                      PlotRange->{R,{Min@Append[First@#2,0],Last@#2*v}}
                      ]&,
                    {plots,M}
                    ]
                  ]
                  },
                If[makeDialog,
                  SetOptions[EvaluationNotebook[],
                    WindowStatusArea->
                      TemplateApply["Horizontal Scaling: ``%| Vertical Scaling: ``%",
                        100*{r,v}
                        ]
                      ]
                    ];
                (*-----------------Try to rasterize------------------------*)
                If[r<failSize||TrueQ@doFast,
                  graphic,
                  Quiet[
                    With[{g=
                      Check[
                        Image[
                          Rasterize[graphic,"Image"],
                          ImageSize->{windowWidth/r,windowHeight}
                          ],
                        graphic
                        ]},
                      If[Length@$MessageList>0,
                        failSize=r
                        ];
                      g
                      ]
                    ]
                  ]
                ]
                ]
              ],
              TrackedSymbols:>{r,v,doFast}
            ]//
        (*-----------------Plot EventHandler------------------------*)
        EventHandler[#,
          "MouseClicked":>
            If[SelectionMove[EvaluationBox[],All,Expression];
              CurrentValue@"ShiftKey",
              doFast=True;
              If[CurrentValue@"MouseClickCount">1,
                CreateDialog[
                  raster/.g_Graphics:>
                    With[{pr=PlotRange@g},
                      Show[g,
                        ImageSize->
                          {windowWidth,windowHeight/If[singlePlot,1,Length@plots]},
                        PlotRange->{
                          Rescale[{m-r/2,m+r/2},{0,1},First@pr],
                          Last@pr
                          }]
                      ],
                  WindowMargins->
                    {{#,Automatic},{Automatic,#2}}&@@CurrentValue["MousePosition"],
                  Selectable->True,
                  WindowClickSelect->True,
                  ShowSelection->True,
                  Editable->False,
                  Deployed->False,
                  ShowCellBracket->True
                  ]
                ];
              ]
          ]&,
      EventHandler[
        Control@{
          {v,1},1,.0001,.01,
            ControlType->VerticalSlider,(*
						ImageSize\[Rule]windowHeight,*)
            ContinuousAction->True
            },
        {
          "MouseDown":>(doFast=True),
          "MouseUp":>(doFast=False),
          PassEventsDown->True
          }
        ]
        },
    {
      EventHandler[
        Control@{
          {r,1},1,.0001,.01,
          ControlType->Slider,
          ContinuousAction->True,
          ImageSize->windowWidth
          },
        {
          "MouseDown":>(doFast=True),
          "MouseUp":>(doFast=False),
          PassEventsDown->True
          }
        ]},
    {
      Control@{
        {m,Replace[m,Except[_?NumericQ]:>.5]},
        0,1,
        ControlType->Slider,
        ContinuousAction->True,
        ImageSize->windowWidth
        }
      }
    }//
    EventHandler[Deploy@#,
      With[{scalingFactor=
        (Which[
          CurrentValue@"CommandKey",
            10,
          CurrentValue@"OptionKey",
            1000,
          True,
            100])&},
      {
        "RightArrowKeyDown":>
          If[TrueQ@CurrentValue["ShiftKey"],
            doFast=True;
            (r=Max@{.001,r-1/scalingFactor[]}),
            (doFast=False);
            (m=Min@{1,m+r/scalingFactor[]})
            ],
        "LeftArrowKeyDown":>
          If[TrueQ@CurrentValue["ShiftKey"],
            doFast=True;
            (r=Min@{1,r+1/scalingFactor[]}),
            (doFast=False);
            (m=Max@{0,
              m-(r/scalingFactor[])})
            ],
        "UpArrowKeyDown":>
          If[TrueQ@CurrentValue["ShiftKey"],
            doFast=True;
            v=Max@{0.0001,v-(1/scalingFactor[])},
            (doFast=False);
            ],
        "DownArrowKeyDown":>
          If[TrueQ@CurrentValue["ShiftKey"],
            doFast=True;
            (v=Min@{1,v+(1/scalingFactor[])}),
            (doFast=False);
            ],
        "ReturnKeyDown":>(
          selF[Rescale[m,{0,1},R],m,{spectrumA,others}];
          update=RandomReal[]
          ),
        {"MenuCommand","HandleShiftReturn"}:>
          (doFast=True;)
        }
        ]
        ]&
    ]//If[makeDialog,
      CreateDialog[#,
        Sequence@@FilterRules[{ops},Options@CreateDialog],
        Selectable->True,
        Editable->False,
        Deployed->False,
        ShowSelection->False,
        WindowElements->{"StatusArea"},
        NotebookEventActions->{
          "UpArrowKeyDown":>Null,
          "DownArrowKeyDown":>Null,
          PassEventsUp->False
          }
        ],
      #
      ]&
  ]
  ]


End[];



