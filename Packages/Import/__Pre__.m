(* ::Package:: *)

(* Autogenerated Package *)

(* ::Text:: *)
(*
	A preloaded file before any of the other files are imported.
	Get is run on it rather than the standard declaration scraping procedure.
*)



(* ::Subsubsection::Closed:: *)
(*MolTable*)



If[!TrueQ[`Private`$ImportRegistered["MolTable"]],
  ImportExport`RegisterImport[
    "MolTable",
    {
      "Elements":>
          Function[
            {
              "Elements"->
                {
                  "Atoms", "Bonds", "AtomsBonds",
                  "Properties", "Graphics", "Graphics3D"
                  }
              }
            ],
      ChemImportMolTable
      },
    {
      "Atoms" :> ChemImportPostProcessElementPositions,
      "Bonds" :> ChemImportPostProcessBondLists,
      "AtomsBonds" :> ChemImportPostProcessElementsBonds,
      "Properties" :> ChemImportPostProcessSupplementaryInfo,
      "Graphics" :> ChemImportPostProcessGraphics,
      "Graphics3D" :> ChemImportPostProcessGraphics3D
      },
    "FunctionChannels"->{"Streams"}
    ];
  `Private`$ImportRegistered["MolTable"]=True
  ]


(* ::Subsubsection::Closed:: *)
(*Entity*)



If[!TrueQ[`Private`$ImportRegistered["ChemEntity"]],
  ImportExport`RegisterImport[
    "ChemEntity",
    {
      "Elements":>
          Function[
            {
              "Elements"->
                {
                  "Atoms", "Bonds", "AtomsBonds",
                  "Properties", "Graphics", "Graphics3D"
                  }
              }
            ],
      ChemImportEntity
      },
    {
      "Atoms" :> ChemImportPostProcessElementPositions,
      "Bonds" :> ChemImportPostProcessBondLists,
      "AtomsBonds" :> ChemImportPostProcessElementsBonds,
      "Properties" :> ChemImportPostProcessSupplementaryInfo,
      "Graphics" :> ChemImportPostProcessGraphics,
      "Graphics3D" :> ChemImportPostProcessGraphics3D
      }
    ];
  `Private`$ImportRegistered["ChemEntity"]=True
  ]


(* ::Subsubsection::Closed:: *)
(*Format*)



If[!TrueQ[`Private`$ImportRegistered["ChemFormat"]],
  ImportExport`RegisterImport[
    "ChemFormat",
    {
      "Elements":>
          Function[
            {
              "Elements"->
                {
                  "Atoms", "Bonds", "AtomsBonds",
                  "Properties", "Graphics", "Graphics3D"
                  }
              }
            ],
      ChemImportFormat
      },
    {
      "Atoms" :> ChemImportPostProcessElementPositions,
      "Bonds" :> ChemImportPostProcessBondLists,
      "AtomsBonds" :> ChemImportPostProcessElementsBonds,
      "Properties" :> ChemImportPostProcessSupplementaryInfo,
      "Graphics" :> ChemImportPostProcessGraphics,
      "Graphics3D" :> ChemImportPostProcessGraphics3D
      },
    "FunctionChannels"->{"Streams"}
    ];
  `Private`$ImportRegistered["ChemFormat"]=True
  ]


(* ::Subsubsection::Closed:: *)
(*ZMatrix*)



If[!TrueQ[`Private`$ImportRegistered["ZMatrix"]],
  ImportExport`RegisterImport[
    "ZMatrix",
    {
      "Elements":>
          Function[
            {
              "Elements"->
                {
                  "Atoms", "Bonds", "AtomsBonds",
                  "Properties", "Graphics", "Graphics3D"
                  }
              }
            ],
      ChemImportZMatrix
      },
    {
      "Atoms" :> ChemImportPostProcessElementPositions,
      "Bonds" :> ChemImportPostProcessBondLists,
      "AtomsBonds" :> ChemImportPostProcessElementsBonds,
      "Properties" :> ChemImportPostProcessSupplementaryInfo,
      "Graphics" :> ChemImportPostProcessGraphics,
      "Graphics3D" :> ChemImportPostProcessGraphics3D
      },
    "FunctionChannels"->{"Streams"}
    ];
  `Private`$ImportRegistered["ZMatrix"]=True
  ]


(* ::Subsubsection::Closed:: *)
(*XYZTable*)



If[!TrueQ[`Private`$ImportRegistered["XYZTable"]],
  ImportExport`RegisterImport[
    "XYZTable",
    {
      "Elements":>
          Function[
            {
              "Elements"->
                {
                  "Atoms", "Bonds", "AtomsBonds",
                  "Properties", "Graphics", "Graphics3D"
                  }
              }
            ],
      ChemImportXYZ
      },
    {
      "Atoms" :> ChemImportPostProcessElementPositions,
      "Bonds" :> ChemImportPostProcessBondLists,
      "AtomsBonds" :> ChemImportPostProcessElementsBonds,
      "Properties" :> ChemImportPostProcessSupplementaryInfo,
      "Graphics" :> ChemImportPostProcessGraphics,
      "Graphics3D" :> ChemImportPostProcessGraphics3D
      },
    "FunctionChannels"->{"Streams"}
    ];
  `Private`$ImportRegistered["XYZTable"]=True
  ]


(* ::Subsubsection::Closed:: *)
(*CubeFile*)



If[!TrueQ[`Private`$ImportRegistered["CubeFile"]],
  Map[
    ImportExport`RegisterImport[
      "CubeFile",
      {
        "Association":>
          Function[
            {"Association"->CubeFileGrid@CubeFileRead[##]}
            ],
        "Grid":>
          Function[
            {"Grid"->CubeFileGrid@CubeFileRead[##]}
            ],
        "InterpolatingFunction":>
          Function[
            {"InterpolatingFunction"->CubeFileFunction@CubeFileRead[##]}
            ],
        "Elements":>
          Function[{"Elements"->{"Association", "Grid", "InterpolatingFunction"}}],
        CubeFileRead
        },
      "FunctionChannels"->{"Streams"}
      ]&,
    {"cube", "CubeFile"}
    ];
  `Private`$ImportRegistered["CubeFile"]=True
  ];


(* ::Subsubsection::Closed:: *)
(*GJF*)



If[!TrueQ[`Private`$ImportRegistered["GaussianJob"]],
  Map[
    ImportExport`RegisterImport[
      #,
      {
        "MolTable":>
          Function[{"MolTable"->ImportGaussianJob[#, "MolTable"]}],
        "Graphics3D":>
          Function[{"Graphics3D"->ImportGaussianJob[#, "Graphics3D", Rest@{##}]}],
        "Elements":>
          Function[{"Elements"->{"MolTable", "Graphics3D"}}],
        ImportGaussianJob
        }
      ]&,
    {"GJF", "GaussianJob"}
    ];
  `Private`$ImportRegistered["GaussianJob"]=True
  ];


(* ::Subsubsection::Closed:: *)
(*FChk*)



If[!TrueQ[`Private`$ImportRegistered["FormattedCheckpoint"]],
  Map[
    ImportExport`RegisterImport[
      #,
      {
        "MolTable":>
          Function[{"MolTable"->ImportFormattedCheckpointFile[#, "MolTable"]}],
        "Elements":>
          Function[{"Elements"->{"MolTable"}}],
        ImportFormattedCheckpointFile
        },
      "FunctionChannels"->{"Streams"}
      ]&,
    {"FCHK", "FormattedCheckpoint"}
    ];
  `Private`$ImportRegistered["FormattedCheckpoint"]=True
  ];


(* ::Subsubsection::Closed:: *)
(*GaussianLog*)



`Private`$GLKS=
  Join[
    {
      "StartDateTime",
      "AtomPositions",
      "CartesianCoordinates",
      "CartesianCoordinateVectors",
      "MullikenCharges",
      "MultipoleMoments",
      "DipoleMoments",
      "QuadrupoleMoments",
      "OctapoleMoments",
      "HexadecapoleMoments",
      "HartreeFockEnergies",
      "MP2Energies",
      "InputZMatrix",
      "InputZMatrixVariables",
      "ZMatrices",
      "ZMatrixCoordinates",
      "ZMatrixCoordinateVectors",
      "ScanTable",
      "OptimizationScan",
      "Blurb",
      "ComputerTimeElapsed",
      "EndDateTime"
      },
    {
      "ScanQuantityArray",
      "HartreeFockEnergyQuantityArray",
      "MP2EnergyQuantityArray",
      "ScanCoordinateQuantityArray",
      "CartesianCoordinateQuantityArray",
      "ZMatrixCoordinateQuantityArray",
      "MultipoleQuantityArray",
      "DipoleQuantityArray",
      "OptimizationScanQuantityArray",
      "OptimizationScanZMatrices"
      }
    ]


If[!TrueQ[`Private`$ImportRegistered["GaussianLog"]],
  Map[
    ImportExport`RegisterImport[
      #,
      Join[
        Map[
          Function[
            With[{`Private`elname=#},
              `Private`elname:>
                Function[{`Private`elname->ImportGaussianLog[#, `Private`elname]}]
              ]
            ],
            `Private`$GLKS
          ],
        {
          "Elements":>
            Function[
              {
                "Elements"->
                  `Private`$GLKS
                }
              ],
          ImportGaussianLog
          }
        ],
      "FunctionChannels"->{"Streams"}
      ]&,
    {"GaussianLog"}
    ];
  `Private`$ImportRegistered["GaussianLog"]=True
  ];



