(* ::Package:: *)

(* Autogenerated Package *)

$SpectrumPropertyCache::usage=
  "Expression store for cached spectrum computation";
ChemSpectrumQ::usage=
  "Tests whether an object is a ChemSpectrum";
ChemSpectrumBuild::usage=
  "Creates the true ChemSpectrum object";
ChemSpectrumCopy::usage=
  "Copies a ChemSpectrum object and preserves its metadata/cache data";


ChemSpectrumModify::usage=
  "Creates a copy of the spectrum with modified parameters";
ChemSpectrumTransform::usage=
  "Applies a transformation to the spectrum data and returns a modifed spectrum";


ChemSpectrumSetProperty::usage=
  "Sets a ChemSpectrum property value";
ChemSpectrumPropertyValue::usage=
  "Gets a ChemSpectrum property value";  
ChemSpectrumRemoveProperty::usage=
  "";
ChemSpectrumPropertyList::usage=
  "";


Begin["`Private`"];


ChemSpectrum//Clear


(* ::Subsection:: *)
(*Constructor*)



$spectrumObjectVersion=1;
(* I realized I should put a version tag in all of my object interfaces *)


(* ::Subsubsection::Closed:: *)
(*ChemSpectrumQ*)



ChemSpectrumQ[d_Association?AssociationQ]:=
  AllTrue[{"Version"}, KeyExistsQ[d, #]&]&&
    AllTrue[{"Frequencies", "Intensities"}, Developer`PackedArrayQ@d[#]&]&&
      Length@d["Frequencies"]==Length@d["Intensities"];
ChemSpectrumQ[ChemSpectrum[a_Association]]:=
  ChemSpectrumQ[a];
ChemSpectrumQ[___]:=False


(* ::Subsubsection::Closed:: *)
(*continuousSpectrumQ*)



continuousSpectrumQ[spec_]:=
  spec["Mode"]==="Continuous"


(* ::Subsubsection::Closed:: *)
(*spectrumListQ*)



spectrumListQ[{a_List, b_List}]:=
  Length[a]===Length[b];
spectrumListQ[d:{__List}]:=
  Dimensions[d]==2;
spectrumListQ[__]:=
  False


(* ::Subsubsection::Closed:: *)
(*getSpectrumList*)



getSpectrumList[d_List]:=
  Module[
    {
      m=d
      },
    If[Length@Dimensions@m!=2,
        specError@
          "Spectral data must be a list of frequencies and intensities"
        ];
      m=Developer`ToPackedArray@m;
      If[!Developer`PackedArrayQ@m, m=Developer`ToPackedArray@N@m];
      If[!Developer`PackedArrayQ@m,
        specError@
          "Spectral data must be real-valued numeric"
        ];
      If[Last@Dimensions[m]==2, m=Transpose@m];
      m
    ]


(* ::Subsubsection::Closed:: *)
(*ChemSpectrumBuild*)



ChemSpectrumBuild//Clear


ChemSpectrumBuild[a_Association?ChemSpectrumQ]:=
  System`Private`HoldSetNoEntry@
    ChemSpectrum[a]


ChemSpectrumBuild[
  {freq_, ints_}, 
  meta_:Automatic,
  version_:Automatic,
  units_:Automatic
  ]:=
  ChemSpectrumBuild@
    <|
      "Version"->Replace[version, Automatic->$spectrumObjectVersion],
      "Frequencies"->Developer`ToPackedArray@freq,
      "Intensities"->Developer`ToPackedArray@ints,
      "Units"->Replace[units, Automatic->None],
      "MetaInfomation"->Replace[meta, Automatic-><||>]
      |>;


(* ::Subsubsection::Closed:: *)
(*specError*)



specError[msg_, pars___]:=
  PackageRaiseException[Automatic,
    msg,
    pars
    ]


(* ::Subsubsection::Closed:: *)
(*ConstructChemSpectrumObject*)



ConstructChemSpectrumObject[d_List, meta_]:=
  PackageExceptionBlock["Spectrum"]@
    ChemSpectrumBuild[getSpectrumList[d], meta]


(* ::Subsubsection::Closed:: *)
(*reformatSpectrumObject*)



reformatSpectrumObject[a_Association]:=
  PackageExceptionBlock["Spectrum"]@
    Module[
      {
        freq,
        int
        },
      freq=Lookup[a, "Frequencies", specError@"No frequencies provides"];
      If[Length@Dimensions@freq!=1, 
        specError@"Frequency data not a list of real numbers"
        ];
      freq=Developer`ToPackedArray@freq;
      If[!Developer`PackedArrayQ@freq, 
        specError@
          "Frequency data must be real-valued numeric"
        ];
      int=Lookup[a, "Intensities", specError@"No intensities provides"];
      If[Length@Dimensions@freq!=1, 
        specError@"Intensity data not a list of real numbers"
        ];
      int=Developer`ToPackedArray@int;
      If[!Developer`PackedArrayQ@int, 
        specError@
          "Intensity data must be real-valued numeric"
        ];
      ChemSpectrumBuild[
        {freq, int},
        Lookup[a, "MetaInformation", Automatic],
        Lookup[a, "Version", Automatic]
        ]
      ]


(* ::Subsubsection::Closed:: *)
(*ChemSpectrum*)



ChemSpectrum[d_List, meta_:Automatic]:=
  ConstructChemSpectrumObject[d, meta];
ChemSpectrum[d_Association]?System`Private`HoldEntryQ:=
  reformatSpectrumObject@d;


(* ::Subsection:: *)
(*Formatting*)



$specIcon=
  Image[
    Import@PackageFilePath["Resources", "Icons", "ContinuousSpectrumIcon.png"],
    ImageSize->{32,32}
    ];


$discSpecIcon=
  Image[
    Import@PackageFilePath["Resources", "Icons", "DiscreteSpectrumIcon.png"],
    ImageSize->{32,32}
    ];


Format[spec_ChemSpectrum?ChemSpectrumQ]:=
  RawBoxes@BoxForm`ArrangeSummaryBox[
    "ChemSpectrum",
    spec,
    If[continuousSpectrumQ@spec, 
      $specIcon,
      $discSpecIcon
      ],
    {
      BoxForm`MakeSummaryItem[{"Points: ", spec["Length"]},StandardForm]
      },
    {
      BoxForm`MakeSummaryItem[
        {"Frequency Range: ", Round[spec["FrequencyRange"], .001]},
        StandardForm
        ],
      BoxForm`MakeSummaryItem[
        {"Intensity Range: ", Round[spec["IntensityRange"], .001]},
        StandardForm
        ],
      BoxForm`MakeSummaryItem[
        {"Units: ", spec["Units"]},
        StandardForm
        ]
      },
    StandardForm
    ];


(* ::Subsection:: *)
(*Properties*)



If[!ValueQ@$SpectrumPropertyCache,
  $SpectrumPropertyCache=Language`NewExpressionStore["<ChemSpectrumProperties>"]
  ];


(* ::Subsubsection::Closed:: *)
(*get*)



cacheGet[spec_, prop_]:=
  Replace[$SpectrumPropertyCache@"get"[spec, prop],
    {
      Null->Missing["KeyAbsent", prop],
      $$hold[x_]:>x
      }
    ];


(* ::Subsubsection::Closed:: *)
(*set*)



cacheSet[spec_, prop_, val_]:=
  (
    $SpectrumPropertyCache@"put"[spec, prop, val];
    val
    )


(* ::Subsubsection::Closed:: *)
(*set*)



$$hold~SetAttributes~HoldAllComplete


cacheSetDelayed~SetAttributes~HoldRest


cacheSetDelayed[spec_, prop_, val_]:=
  (
    $SpectrumPropertyCache@"put"[spec, prop, $$hold@val];
    )


(* ::Subsubsection::Closed:: *)
(*remove*)



cacheRemove[spec_, prop_]:=
  $SpectrumPropertyCache@"remove"[spec, prop];


(* ::Subsubsection::Closed:: *)
(*keys*)



cacheKeys[spec__]:=
  $SpectrumPropertyCache@"getKeys"[spec]


(* ::Subsubsection::Closed:: *)
(*cachedCompute*)



cachedCompute[spec_, prop_, func_, args___]:=
  Replace[cacheGet[spec, prop],
    Missing["KeyAbsent", prop]:>
      With[{v=func[args]},
        cacheSet[spec, prop, v];
        v
        ]
    ]
cachedCompute~SetAttributes~HoldAllComplete


(* ::Subsubsection::Closed:: *)
(*cacheCopy*)



cacheCopy[obj1_, obj2_, keyTest_:(True&)]:=
  Scan[If[keyTest[#], cacheSet[obj2, #, cacheGet[obj1, #]]]&, cacheKeys[obj1]]


(* ::Subsubsection::Closed:: *)
(*Properties*)



ChemSpectrumSetProperty[spec_, prop_->val_]:=
  cacheSet[spec, prop, val];
ChemSpectrumSetProperty[spec_, prop_:>val_]:=
  cacheSetDelayed[spec, prop, val];
ChemSpectrumPropertyValue[spec_, prop_]:=
  cacheGet[spec, prop];
ChemSpectrumRemoveProperty[spec_, prop_]:=
  cacheRemove[spec, prop];
ChemSpectrumPropertyList[spec_]:=
  cacheKeys[spec]


(* ::Subsection:: *)
(*Object Stuff*)



(* ::Text:: *)
(*
	Need to maintain a list of properties *not* to copy...
*)



(* ::Subsubsection::Closed:: *)
(*Copy*)



ChemSpectrumCopy[spec_, test:Except[_ChemSpectrum]:(True&)]:=
  With[{copy=ChemSpectrumBuild[Normal@spec]},
    ChemSpectrumCopy[spec, copy, test];
    copy
    ]
ChemSpectrumCopy[
  spec1_, 
  spec2_, 
  keyTest_:(True&)
  ]:=
  (
    cacheCopy[spec1, spec2, keyTest];
    spec2
    )


(* ::Subsubsection::Closed:: *)
(*Mutability*)



ChemSpectrum/:HoldPattern[
  Set[(s_ChemSpectrum?ChemSpectrumQ)[k_String], v_]
  ]:=
  ChemSpectrumSetProperty[s, k->v]
ChemSpectrum/:HoldPattern[
  SetDelayed[(s_ChemSpectrum?ChemSpectrumQ)[k_String], v_]
  ]:=
  ChemSpectrumSetProperty[s, k:>v]
ChemSpectrum/:HoldPattern[
  Unset[(s_ChemSpectrum?ChemSpectrumQ)[k_String]]
  ]:=
  ChemSpectrumRemoveProperty[s, k]


ChemSpectrumMutationHandler//ClearAll
ChemSpectrumMutationHandler~SetAttributes~HoldAllComplete;
ChemSpectrumMutationHandler[
  (Set|SetDelayed)[(s_Symbol?ChemSpectrumQ)[k_String], v_]
  ]:=
    With[{spec=s},
      spec[k]=v
      ];
ChemSpectrumMutationHandler[
  Unset[(s_Symbol?ChemSpectrumQ)[k_String]]
  ]:=
    With[{spec=s},
      spec[k]=.
      ];
ChemSpectrumMutationHandler[___]:=
  Language`MutationFallthrough
Language`SetMutationHandler[ChemSpectrum, ChemSpectrumMutationHandler]


(* ::Subsubsection::Closed:: *)
(*Methods*)



(* ::Subsubsubsection::Closed:: *)
(*Bind*)



$chemSpecMethods=<||>


chemSpecBind[fn_, name_]:=
  (
    $chemSpecMethods[name]=fn;
    ChemSpectrum/:(spec:_ChemSpectrum?ChemSpectrumQ)[name]:=
      Function[Null, fn[spec, ##], HoldAllComplete];
    ChemSpectrum/:(spec:_ChemSpectrum?ChemSpectrumQ)[name[args___]]:=
      fn[spec, args]
    )


chemSpecBindProp[fn_, name_]:=
  (
    $chemSpecMethods[name]=fn;
    ChemSpectrum/:(spec:_ChemSpectrum?ChemSpectrumQ)[name]:=
      fn[spec]
    )


(* ::Subsubsubsection::Closed:: *)
(*Methods*)



ChemSpectrum/:(spec:_ChemSpectrum?ChemSpectrumQ)["Methods"]:=
    Keys@$chemSpecMethods


(* ::Subsubsubsection::Closed:: *)
(*Properties*)



ChemSpectrum/:(spec:_ChemSpectrum?ChemSpectrumQ)["Properties"]:=
    ChemSpectrumPropertyList[spec]


(* ::Subsubsubsection::Closed:: *)
(*Sort*)



chemSpecSort[spec_]:=
  With[
    {
      s2=
        ChemSpectrumCopy[ChemSpectrumSort[spec], spec]
      },
    ChemSpectrumSetProperty[s2, "SortedQ"->True];
    s2
    ]


chemSpecBind[chemSpecSort, "Sort"]


(* ::Subsubsubsection::Closed:: *)
(*Sorted*)



chemSpecSorted[spec_]:=
  If[TrueQ@spec["SortedQ"], 
    spec, 
    chemSpecSort[spec]
    ]


chemSpecBindProp[chemSpecSorted, "Sorted"]


(* ::Subsubsubsection::Closed:: *)
(*Interpolation*)



chemSpecInterp[spec_]:=
  cachedCompute[
    spec,
    "Interpolation",
    ChemSpectrumInterpolation,
    spec
    ];
chemSpecBindProp[chemSpecInterp, "Interpolation"];
chemSpecBind[ChemSpectrumInterpolation, "Interpolation"];


(* ::Subsubsubsection::Closed:: *)
(*Length*)



chemSpecLength[spec_]:=
  Length@spec["Frequencies"]


chemSpecBindProp[chemSpecLength, "Length"]


(* ::Subsubsubsection::Closed:: *)
(*Points*)



chemSpecPoints[spec_, p_:All]:=
  ChemSpectrumPoints[spec, p]


chemSpecBindProp[chemSpecPoints, "Points"]


(* ::Subsubsubsection::Closed:: *)
(*Mode*)



chemSpecMode[spec_]:=
  cachedCompute[
    spec,
    "Mode",
    ChemSpectrumMode,
    spec
    ];
chemSpecBindProp[chemSpecMode, "Mode"]


(* ::Subsubsubsection::Closed:: *)
(*Norm*)



chemSpecNorm[spec_]:=
  cachedCompute[
    spec,
    "Norm",
    ChemSpectrumNorm,
    spec
    ];
chemSpecBindProp[chemSpecNorm, "Norm"]


(* ::Subsubsubsection::Closed:: *)
(*RegularlySampledQ*)



chemSpecRegularlySampledQ[spec_]:=
  cachedCompute[
    spec,
    "RegularlySampledQ",
    ChemSpectrumRegularlySampledQ,
    spec
    ];
chemSpecBindProp[chemSpecRegularlySampledQ, "RegularlySampledQ"]


(* ::Subsubsubsection::Closed:: *)
(*FrequencyRange*)



chemSpecFrequencyRange[spec_]:=
  cachedCompute[
    spec,
    "FrequencyRange",
    ChemSpectrumFrequencyRange,
    spec
    ];
chemSpecBindProp[chemSpecFrequencyRange, "FrequencyRange"]


(* ::Subsubsubsection::Closed:: *)
(*IntensityRange*)



chemSpecIntensityRange[spec_]:=
  cachedCompute[
    spec,
    "IntensityRange",
    ChemSpectrumIntensityRange,
    spec
    ];
chemSpecBindProp[chemSpecIntensityRange, "IntensityRange"]


(* ::Subsubsubsection::Closed:: *)
(*Select*)



chemSpecBind[ChemSpectrumSelect, "Select"];


(* ::Subsubsubsection::Closed:: *)
(*Clip*)



chemSpecBind[ChemSpectrumClip, "Clip"];


(* ::Subsubsubsection::Closed:: *)
(*Chop*)



chemSpecBind[ChemSpectrumChop, "Chop"];


(* ::Subsubsubsection::Closed:: *)
(*Window*)



chemSpecBind[ChemSpectrumWindow, "Window"];


(* ::Subsubsubsection::Closed:: *)
(*Scale*)



chemSpecBind[ChemSpectrumScale, "Scale"];


(* ::Subsubsubsection::Closed:: *)
(*Shift*)



chemSpecBind[ChemSpectrumShift, "Shift"];


(* ::Subsubsubsection::Closed:: *)
(*Smooth*)



chemSpecBind[ChemSpectrumSmooth, "Smooth"];


(* ::Subsubsubsection::Closed:: *)
(*Normalize*)



chemSpecBind[ChemSpectrumNormalize, "Normalize"];


(* ::Subsubsubsection::Closed:: *)
(*Adjust*)



chemSpecBind[ChemSpectrumAdjust, "Adjust"];


(* ::Subsubsubsection::Closed:: *)
(*Peaks*)



chemSpecBindProp[ChemSpectrumFindPeaks, "Peaks"];


(* ::Subsubsubsection::Closed:: *)
(*FindPeaks*)



chemSpecBind[ChemSpectrumFindPeaks, "FindPeaks"];


(* ::Subsubsubsection::Closed:: *)
(*NearestPeaks*)



chemSpecBind[ChemSpectrumNearestPeaks, "NearestPeaks"];


(* ::Subsubsubsection::Closed:: *)
(*Distribution*)



chemSpecBind[ChemSpectrumDistribution, "Distribution"];


(* ::Subsubsubsection::Closed:: *)
(*NormalDistribution*)



chemSpecGauss[spec_]:=
  cachedCompute[
    spec,
    "NormalDistribution",
    ChemSpectrumNormalDistribution,
    spec
    ]


chemSpecBind[ChemSpectrumNormalDistribution, "NormalDistribution"];


(* ::Subsubsubsection::Closed:: *)
(*CauchyDistribution*)



chemSpecBind[ChemSpectrumCauchyDistribution, "CauchyDistribution"];


(* ::Subsubsubsection::Closed:: *)
(*Plot*)



chemSpecBind[ChemSpectrumPlot, "Plot"];


(* ::Subsubsubsection::Closed:: *)
(*Modify*)



chemSpecBind[ChemSpectrumModify, "Modify"];


(* ::Subsubsubsection::Closed:: *)
(*Transform*)



chemSpecBind[ChemSpectrumTransform, "Transform"];


(* ::Subsubsection::Closed:: *)
(*Overloads*)



(* ::Subsubsubsection::Closed:: *)
(*Part*)



ChemSpectrum/:HoldPattern[Part[spec:_ChemSpectrum?ChemSpectrumQ, p_]]:=
  ChemSpectrumPart[spec, p];


(* ::Subsubsubsection::Closed:: *)
(*Key*)



ChemSpectrum/:HoldPattern[
  (s:ChemSpectrum[a_Association?ChemSpectrumQ])[
    k_String?(Not@KeyExistsQ[$chemSpecMethods, #]&)
    ]
  ]:=
  Replace[a[k],
    Missing["KeyAbsent", k]:>
      ChemSpectrumPropertyValue[s, k]
    ]


(* ::Subsubsubsection::Closed:: *)
(*Normal*)



ChemSpectrum/:HoldPattern[Normal@ChemSpectrum[a_Association?ChemSpectrumQ]]:=
  a;


(* ::Subsection:: *)
(*Modify*)



(* ::Subsubsection::Closed:: *)
(*Modify*)



(* ::Text:: *)
(*
	Modifies some part of a ChemSpectrum
*)



ChemSpectrumModify[spec_, 
  specL:_List?spectrumListQ|Automatic:Automatic, 
  attrs:_?OptionQ:<||>
  ]:=
  Module[
    {
      pl=specL,
      meta,
      sp2
      },
    If[specL===Automatic,
      specL={spec["Frequencies"], spec["Intensities"]}
      ];
    meta=Merge[
      {
        KeyDrop[Normal@spec, {"Frequencies", "Intensities"}],
        attrs
        },
      Last
      ];
    sp2=ConstructChemSpectrumObject[specL, meta];
    ChemSpectrumCopy[spec, sp2];
    If[specL=!=Automatic,
      ChemSpectrumRemoveProperty[sp2, "Interpolation"]
      ];
    sp2
    ]
  


(* ::Subsubsection::Closed:: *)
(*Transform*)



ChemSpectrumTransform[spec_, fn_]:=
  ChemSpectrumModify[spec, fn[{spec["Frequencies"], spec["Intensities"]}]]


End[];



