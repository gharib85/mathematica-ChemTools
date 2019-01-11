(* ::Package:: *)

(* Autogenerated Package *)

(* ::Subsubsection::Closed:: *)
(*Methods*)



ChemSpectrumSort::usage="";
ChemSpectrumPart::usage="";


ChemSpectrumPoints::usage="";
ChemSpectrumInterpolation::usage="";
ChemSpectrumFrequencyRange::usage="";
ChemSpectrumIntensityRange::usage="";


ChemSpectrumMode::usage="";
ChemSpectrumNorm::usage="";
ChemSpectrumRegularlySampledQ::usage="";


(* ::Subsubsection::Closed:: *)
(*Modifications*)



ChemSpectrumSelect::usage="Applies Select to a ChemSpectrum";
ChemSpectrumChop::usage="Applies Threshold to a ChemSpectrum";
ChemSpectrumWindow::usage="Akin to TimeSeriesWindow";
ChemSpectrumResample::usage="Akin to TimeSeriesResample";
ChemSpectrumScale::usage="Scales the frequency range of the spectrum";
ChemSpectrumShift::usage="Akin to TimeSeriesShift";


ChemSpectrumSmooth::usage=
  "Applies a smoother to the spectrum";
ChemSpectrumNormalize::usage=
  "Normalizes the data";
ChemSpectrumAdjust::usage=
  "Adjusts the spectrum to work better for plotting";


(* ::Subsubsection::Closed:: *)
(*Distributions*)



ChemSpectrumDistribution::usage=
  "Creates a MixtureDistribution based on the peaks and intensities";
ChemSpectrumNormalDistribution::usage=
  "Creates a Gaussian-broadend distribution";
ChemSpectrumCauchyDistribution::usage=
  "Creates a Lorentzian-broadend distribution";


(* ::Subsubsection::Closed:: *)
(*Peaks*)



ChemSpectrumFindPeaks::usage=
  "Applies FindPeaks to a ChemSpectrum";
ChemSpectrumNearestPeak::usage=
  "Finds the peak nearest to a given wavelength";


Begin["`Private`"];


(* ::Subsection:: *)
(*Misc*)



(* ::Subsubsection::Closed:: *)
(*Slices*)



(* ::Subsubsubsection::Closed:: *)
(*Slice*)



ChemSpectrumPart[spec_, p_]:=
  With[{l={Part[spec["Frequencies"], p], Part[spec["Intensities"], p]}},
    If[ListQ@l[[1]],
      ChemSpectrumBuild@
        ReplacePart[
          Normal@spec,
          {
            "Frequencies"->l[[1]],
            "Intensities"->l[[2]]
            }
          ],
      l
      ]
    ]


(* ::Subsubsubsection::Closed:: *)
(*Sort*)



ChemSpectrumSort[spec_]:=
    Module[{o=Ordering[spec["Frequencies"]]},
      ChemSpectrumBuild@
        ReplacePart[
          Normal@spec,
          {
            "Frequencies"->spec["Frequencies"][[o]],
            "Intensities"->spec["Intensities"][[o]]
            }
          ]
      ]


(* ::Subsubsubsection::Closed:: *)
(*Points*)



ChemSpectrumPoints[spec_, p_:All]:=
  With[{l={Part[spec["Frequencies"], p], Part[spec["Intensities"], p]}},
    If[ListQ@l[[1]],
      Transpose@Developer`ToPackedArray@l,
      l
      ]
    ]


(* ::Subsubsection::Closed:: *)
(*Interpolations*)



(* ::Subsubsubsection::Closed:: *)
(*Interpolation*)



ChemSpectrumInterpolation[spec_, a___]:=
  Interpolation[spec["Points"], a];


(* ::Subsubsection::Closed:: *)
(*Ranges*)



(* ::Subsubsubsection::Closed:: *)
(*FrequencyRange*)



ChemSpectrumFrequencyRange[spec_]:=
  MinMax@spec["Frequencies"]


(* ::Subsubsubsection::Closed:: *)
(*IntensityRange*)



ChemSpectrumIntensityRange[spec_]:=
    MinMax@spec["Intensities"]


(* ::Subsubsubsection::Closed:: *)
(*ScaledFrequency*)



ChemSpectrumScaledFrequency[spec_, p_]:=
  Module[{mm=spec["FrequencyRange"]},
    Rescale[p, {0, 1}, mm]
    ]


(* ::Subsubsubsection::Closed:: *)
(*ScaledIntensity*)



ChemSpectrumScaledIntensity[spec_, p_]:=
  Module[{mm=spec["IntensityRange"]},
    Rescale[p, {0, 1}, mm]
    ]


(* ::Subsubsubsection::Closed:: *)
(*TrueFrequency*)



ChemSpectrumTrueFrequency[spec_, p_]:=
  Replace[p, 
    Scaled[s_]:>ChemSpectrumScaledFrequency[spec, p],
    {0, 2}
    ]


(* ::Subsubsubsection::Closed:: *)
(*TrueIntensity*)



ChemSpectrumTrueIntensity[spec_, p_]:=
  Replace[p, 
    Scaled[s_]:>ChemSpectrumScaledIntensity[spec, p],
    {0, 2}
    ]


(* ::Subsubsection::Closed:: *)
(*Sampling*)



(* ::Subsubsubsection::Closed:: *)
(*RegularlySampledQ*)



regSampQ[d_, window_:1000]:=
  If[Length@d>window,
    Module[{eq=True},
      Do[
        If[Length@DeleteDuplicates@Differences[d[[n-window;;n]]]>1, 
           eq=False;Break[]
          ], {n, window+1, Length@d, window}];
        eq
        ],
      Equal@@Differences[d]
      ];
regSampQ~SetAttributes~HoldFirst


ChemSpectrumRegularlySampledQ[spec_]:=
  regSampQ@spec["Frequencies"]


(* ::Subsubsubsection::Closed:: *)
(*Norm*)



ChemSpectrumNorm[spec_]:=
  Differences[spec["Frequencies"]].
    MovingAverage[spec["Intensities"], 2]


(* ::Subsubsubsection::Closed:: *)
(*Mode*)



ChemSpectrumMode[spec_]:=
  Module[
    {
      fdiffs=Differences[spec["Frequencies"]],
      stdev,
      mean,
      rat
      },
    stdev=StandardDeviation@fdiffs;
    mean=Mean@fdiffs;
    rat=stdev/mean;
    If[rat<.1,
      "Continuous",
      "Discrete"
      ]
    ]


(* ::Subsection:: *)
(*Selection*)



(* ::Subsubsection::Closed:: *)
(*Cases*)



ChemSpectrumCases[
  spec_,
  pat:{rangePat_,intensityPat_}
  ]:=
  ChemSpectrumModify[
    spec,
    Cases[ChemSpectrumPoints@spec, pat]
    ];(* This might be expensive... *)


(* ::Subsubsection::Closed:: *)
(*Select*)



ChemSpectrumSelect[
  spec_,
  test_
  ]:=
  ChemSpectrumModify[spec, 
    Select[ChemSpectrumPoints@spec, test]
    ];(* This might be expensive... *)


(* ::Subsubsection::Closed:: *)
(*Clip*)



ChemSpectrumClip[
  spec_,
  {minInt_, maxInt_},
  Optional[{minClip_?NumericQ, maxClip_?NumericQ}, {0., 1.}] 
  ]:=
  ChemSpectrumModify[spec, 
    {
      spec["Frequencies"],
      Clip[spec["Intensities"], {minInt, maxInt}, {minClip, maxClip}]
      }
    ];


(* ::Subsubsection::Closed:: *)
(*Chop*)



ChemSpectrumChop[
  spec_,
  thresh___
  ]:=
  ChemSpectrumModify[spec, 
    {
      spec["Frequencies"],
      Threshold[spec["Intensities"], thresh]
      }
    ];
ChemSpectrumChop[
  spec_,
  thresh___
  ]:=
  ChemSpectrumModify[spec, 
    {
      spec["Frequencies"],
      Threshold[spec["Intensities"], thresh]
      }
    ];


(* ::Subsubsection::Closed:: *)
(*Window*)



chemSpectrumWindow[
  {freq_, int_},
  {freqMin_, freqMax_}, 
  {intMin_, intMax_}
  ]:=
  Module[
    {
      sp,
      fr=freq,
      in=int,
      frMs={freqMin, freqMax},
      inm=intMin,  inM=intMax
      },
      sp=
        If[freqMin===-\[Infinity], 
          ConstantArray[1, Length@fr],
          UnitStep[fr, fr-freqMin]
          ]*
          If[freqMax===\[Infinity], 
            ConstantArray[1, Length@fr],
            UnitStep[fr, freqMax-fr]
            ];
      fr=Pick[fr, sp, 1];
      in=Pick[in, sp, 1];
      sp=
        If[intMin===-\[Infinity], 
          ConstantArray[1, Length@in],
          UnitStep[in, in-intMin]
          ]*
        If[intMax===\[Infinity], 
          ConstantArray[1, Length@in],
          UnitStep[in, intMax-in]
          ];
      fr=Pick[fr, sp, 1];
      in=Pick[in, sp, 1];
      {
        fr,
        in
        }
    ]


ChemSpectrumWindow[spec_, 
  f:{_, _}, 
  i:{_, _}:{-\[Infinity], \[Infinity]}
  ]:=
  ChemSpectrumTransform[
    spec, 
    chemSpectrumWindow[
      #, 
      ChemSpectrumTrueFrequency[spec, f], 
      ChemSpectrumTrueIntensity[spec, i]
      ]&
    ]


(* ::Subsubsection::Closed:: *)
(*Scale*)



chemSpectrumScale[
  {freq_, int_},
  {sc_, o_},
  {is_, oi_}
  ]:=
  {
    sc*(freq-o)+o, 
    is*(int-oi)+oi
    }


ChemSpectrumScale[spec_, 
  sc_?NumericQ, 
  o_?NumericQ:0
  ]:=
  ChemSpectrumTransform[spec, 
    chemSpectrumScale[#, 
      {sc, o},
      {1, 0}
      ]&
    ]


ChemSpectrumScale[spec_, 
  {sc_?NumericQ, o_?NumericQ},
  {is_?NumericQ, oi_?NumericQ}
  ]:=
  ChemSpectrumTransform[spec, 
    chemSpectrumScale[#, 
      {sc, o},
      {is, oi}
      ]&
    ]


(* ::Subsubsection::Closed:: *)
(*Shift*)



chemSpectrumShift[
  {freq_, int_},
  freqShift_,
  intShift_
  ]:=
  {freq+freqShift, int+intShift}


ChemSpectrumShift[
  spec_, 
  freqShift_,
  intShift_:0
  ]:=
  ChemSpectrumTransform[spec, 
    chemSpectrumShift[#,
      ChemSpectrumTrueFrequency[spec, freqShift], 
      ChemSpectrumTrueIntensity[spec, intShift]
      ]&
    ]


(* ::Subsection:: *)
(*Peak Stuff*)



(* ::Subsubsection::Closed:: *)
(*FindPeaks*)



Options@ChemSpectrumFindPeaks=
  Options@FindPeaks;
ChemSpectrumFindPeaks[spec_, params___]:=
  Module[
    {
      fr=spec["Frequencies"],
      in=spec["Intensities"],
      pk
      },
    pk=PeakDetect[in, params];
    fr=Pick[fr, pk, 1];
    If[Length@fr>0,
      Transpose@{fr, Pick[in, pk, 1]},
      {}
      ]
    ];


(* ::Subsubsection::Closed:: *)
(*NearestPeaks*)



Options[ChemSpectrumNearestPeaks]=
  {
    "FindPeakParameters"->{}
    };
ChemSpectrumNearestPeaks[spec_, 
  peak_?NumericQ, 
  n___?(Not@*OptionQ), 
  ops:OptionsPattern[]
  ]:=
  Module[{pk=ChemSpectrumFindPeaks[spec, OptionValue["FindPeakParameters"]]},
    pk[[Nearest[pk[[All, 1]]->"Index", peak, n]]]
    ]


(* ::Subsection:: *)
(*Normalization*)



(* ::Subsubsection::Closed:: *)
(*Normalize*)



ChemSpectrumNormalize[
  spec_
  ]:=
  ChemSpectrumTransform[
    spec,
    {
      #[[1]],
      #[[2]]/(Differences[#[[1]]].MovingAverage[#[[2]], 2])
      }&
    ]


(* ::Subsubsection::Closed:: *)
(*Smooth*)



ChemSpectrumSmooth[
  spec_,
  averagePoints_:10
  ]:=
  ChemSpectrumTransform[spec, MovingAverage[#, averagePoints]&]


(* ::Subsubsection::Closed:: *)
(*Adjust*)



Options[ChemSpectrumAdjust]=
  {
    "FrequencyRange"->Automatic,
    "SmoothingPoints"->Automatic,
    "FrequencyScaling"->Automatic,
    "FrequencyShift"->Automatic,
    "IntensityThreshold"->Automatic,
    "IntensityScaling"->Automatic
    };
chemSpectrumAdjust[
  spec_, 
  ops:OptionsPattern[]
  ]:=
  PackageExceptionBlock["Spectrum"]@
  Module[
    {
      sps,
      freqs,
      ints,
      pspec,
      rang=Replace[OptionValue["FrequencyRange"], Automatic->{-\[Infinity], \[Infinity]}],
      scale=Replace[OptionValue["IntensityScaling"], Automatic->{1, 0}],
      shif=Replace[OptionValue["FrequencyShift"], Automatic->0],
      spacescale=Replace[OptionValue["FrequencyScaling"], Automatic->1],
      thresh=Replace[OptionValue["IntensityThreshold"], Automatic->Scaled[.001]],
      spmin
      },
    If[!MatchQ[rang, {_, _}], 
      PackageRaiseException[Automatic, 
        "Frequency range `` is expected to be a min and max frequency",
        rang
        ]
      ];
    rang=ChemSpectrumTrueFrequency[spec, rang];
    thresh=ChemSpectrumTrueIntensity[spec, thresh];
    If[!NumericQ@thresh,
      PackageRaiseException[Automatic, 
        "Intensity threshold `` is expected to be a number or Scaled",
        thresh
        ]
      ];
    If[!MatchQ[rang, {_, _}], 
      PackageRaiseException[Automatic, 
        "Frequency range `` is expected to be a min and max frequency",
        rang
        ]
      ];
    shif=ChemSpectrumTrueFrequency[spec, shif];
    If[!NumericQ@shif,
      PackageRaiseException[Automatic, 
        "Frequency shift `` is expected to be a number or Scaled",
        shif
        ]
      ];
    scale=ChemSpectrumTrueIntensity[spec, scale];
    If[!MatchQ[scale, _?NumericQ|{_?NumericQ, _?NumericQ}],
      PackageRaiseException[Automatic, 
        "Intensity scaling `` is expected to be a number or list of scaling and offset",
        scale
        ]
      ];
    spacescale=ChemSpectrumTrueIntensity[spec, spacescale];
    If[!MatchQ[spacescale, _?NumericQ|{_?NumericQ, _?NumericQ}],
      PackageRaiseException[Automatic, 
        "Frequency scaling `` is expected to be a number or list of scaling and offset",
        spacescale
        ]
      ];
    {freqs, ints}=
      chemSpectrumWindow[
        chemSpectrumShift[
          chemSpectrumScale[
            {spec["Frequencies"], spec["Intensities"]},
            If[NumericQ@spacescale, {spacescale, 0}, spacescale],
            If[NumericQ@scale, {scale, 0}, scale]
            ],
          shif,
          0
          ],
        rang,
        {0, thresh}
        ]
    ]


ChemSpectrumAdjust[spec_, ops:OptionsPattern[]]:=
  ChemSpectrumModify[spec, 
    chemSpectrumAdjust[spec, ops]
    ]


(* ::Subsection:: *)
(*Broadening*)



(* ::Text:: *)
(*
	Introduces broadening to a discrete spectrum
*)



(* ::Subsubsection::Closed:: *)
(*General*)



ChemSpectrumDistribution[spec_, distribution_, weighting_]:=
  Module[
    {
      ints,
      pos,
      dists,
      weights
      },
    ints=spec["Intensities"];
    pos=spec["Frequencies"];
    dists=distribution/@pos;
    weights=MapThread[weighting, {ints, dists}];
    MixtureDistribution[
      Max[ints]*weights/Max[weights],
      dists
      ]
  ]


(* ::Subsubsection::Closed:: *)
(*Gaussian Broadening*)



ChemSpectrumNormalDistribution//Clear


ChemSpectrumNormalDistribution[spec_, broadening_:Automatic]:=
  With[{broadness=Replace[broadening, Automatic->5]}, (* placeholder until I'm smarter *)
    ChemSpectrumDistribution[spec, 
      NormalDistribution[#, broadness]&,
      #/(broadness*Sqrt[2\[Pi]])&
      ]
    ]


(* ::Subsubsection::Closed:: *)
(*Lorentzian Broadening*)



ChemSpectrumCauchyDistribution//Clear


ChemSpectrumCauchyDistribution[spec_, broadening_:Automatic]:=
  With[{broadness=Replace[broadening, Automatic->5]}, (* placeholder until I'm smarter *)
    ChemSpectrumDistribution[spec, 
      CauchyDistribution[#, broadness]&,
      #/(broadness*Sqrt[\[Pi]])&
      ]
    ]


End[];



