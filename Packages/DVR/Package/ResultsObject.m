(* ::Package:: *)

(* Autogenerated Package *)

(* ::Section:: *)
(*DVR Results Object*)



ChemDVRResultsObjectQ::usage="";
ChemDVRResultsModify::usage="";
NewDVRResultsObject::usage="";


Begin["`Private`"];


(* ::Subsection:: *)
(*Registration*)



(* ::Subsubsection::Closed:: *)
(*keyTypeMap*)



sparseArrayQ=
  MatchQ[_SparseArray?System`Private`NoEntryQ]


packedSquareMatrixQ=
  TrueQ@If[!(Developer`PackedArrayQ[#]||sparseArrayQ[#]),
    PackageRaiseException[Automatic,
      "Matrix `` isn't packed",
      #
      ],
    True
    ]&&
    TrueQ@If[!(SquareMatrixQ[#]),
      PackageRaiseException[Automatic,
        "Matrix isn't square"
        ],
      True
      ]&&
    TrueQ@If[!(MatrixQ[#, Internal`RealValuedNumericQ]),
      PackageRaiseException[Automatic,
        "Matrix is non-real"
        ],
      True
      ]&;
softSQMQ=
  Block[{PackageRaiseException}, packedSquareMatrixQ[#]]&


$keyTypeMap=
  <|
    "Object"->_ChemDVRObject,
    "Grid"->_CoordinateGridObject?CoordinateGridObjectQ,
    "Transformation"->
      None|_List?softSQMQ|{(None|_List?packedSquareMatrixQ)..},
    "KineticEnergy"->_?packedSquareMatrixQ,
    "PotentialEnergy"->_?packedSquareMatrixQ,
    "Wavefunctions"->_WavefunctionsObject?WavefunctionsObjectQ,
    "Options"->_Association?AssociationQ
    |>;


(* ::Subsubsection::Closed:: *)
(*validateResults*)



validateDVRResults[a_Association]:=
  AllTrue[Keys@$keyTypeMap,
    If[!MatchQ[a[#], None|$keyTypeMap[#]],
      PackageRaiseException[Automatic,
        "DVR result `` for \"``\" is not None and doesn't match pattern ``",
        a[#],
        #,
        $keyTypeMap[#]
        ],
      True
      ]&
    ]


(* ::Subsubsection::Closed:: *)
(*NewDVRResultsObject*)



NewDVRResultsObject[a:_Association:<||>]:=
  ChemDVRResultsObject@Join[
    AssociationMap[None&, Keys@$keyTypeMap],
    a
    ];


(* ::Subsubsection::Closed:: *)
(*ConstructDVRResults*)



constructDVRResults[bleh_]:=
  Module[{mute=bleh, grid},
    If[ListQ@mute["Grid"],
     grid=CoordinateGridObject[Evaluate@mute["Grid"]];
     If[!CoordinateGridObjectQ@grid, Throw@grid];
     mute["Grid"]=grid
     ];
    mute
    ];


ConstructDVRResults[
  cache_Association
  ]:=
  Module[{new=constructDVRResults[cache]},
    If[validateDVRResults[new],
      new,
      <|$Failed->True|> (* requires Association return to throw the error *)
      ]
    ];
ConstructDVRResults[
  e_
  ]:=
  ConstructDVRResults[Association@e]


(* ::Subsubsection::Closed:: *)
(*ChemDVRResultsObject*)



RegisterInterface[
  ChemDVRResultsObject,
  Keys@$keyTypeMap,
  "Validator"->
    ChemDVRResultsObjectQ,
  "Constructor"->
    ConstructDVRResults,
  "AccessorFunctions"->Automatic,
  "MutationFunctions"->{"Keys", "Parts"}
  ]


End[];



