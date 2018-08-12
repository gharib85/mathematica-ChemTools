(* ::Package:: *)

(* Autogenerated Package *)

(* ::Subsubsection::Closed:: *)
(*Imports*)



ChemSpectrumImport::usage="Imports a spectrum";
ChemSpectrumImportString::usage="Imports a string as a spectrum";


Begin["`Private`"];


(* ::Subsection:: *)
(*Import*)



(* ::Subsubsection::Closed:: *)
(*OVR*)



chemImportOVR[file_]:=
  Replace[
    Cases[
      Import[file,"XML"],
      XMLElement["ExperimentalPlot", h_, {d_}]:>
        {h,ChemSpectrum@Partition[Join@@ImportString[d,"Table"],2]},
      \[Infinity]],
    {d_}:>d
    ];


(* ::Subsubsection::Closed:: *)
(*ChemSpectrumImport*)



ChemSpectrumImport[
  file:_String?FileExistsQ|_InputStream,
  dType_
  ]:=
  Switch[ToLowerCase@dType,
    "ovr",
      chemImportOVR@file,
    "lin",
      $SPCAT;
      ChemSpectrum@spimportLIN@file,
    "par"|"var",
      $SPCAT;
      spimportPAR@file,
    "int",
      $SPCAT;
      spimportINT@file,
    "cat",
      $SPCAT;
      ChemSpectrum@spimportCAT@file,
    "egy",
      $SPCAT;
      spimportEGY@file,
    _,
      Import[file,"Text"]
    ];


ChemSpectrumImport[file_String?FileExistsQ]:=
  ChemSpectrumImport[file,FileExtension@file];
ChemSpectrumImport[file_?(!StringMatchQ[#,"/*"|"~/*"]&&Length@URLParse[#]["Path"]>0&)]:=
  With[{tempf=
    First@URLDownload[file,
      FileNameJoin@{
        $TemporaryDirectory,
        FileNameTake[file]
        }
      ]},
    With[{d=ChemSpectrumImport@tempf},DeleteFile@tempf;d]
    ];


ChemSpectrumImportString[string_String,type_]:=
  If[StringLength@string==0,
    $Failed,
    With[{s=StringToStream@string},
      With[{c=ChemSpectrumImport[s,type]},
        Close@s;
        c
        ]
      ]
    ];


End[];


