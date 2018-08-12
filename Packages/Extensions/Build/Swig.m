(* ::Package:: *)

(* Autogenerated Package *)

SwigBuild::usage="Gets and compiles the Swig system";
SwigCheck::usage="Checks that Swig is installed";
$SwigDirectory::usage="The directory Swig was built to";
SwigBinary::usage="Returns the binary for the Swig system"


Begin["`Private`"];


(* ::Subsubsection::Closed:: *)
(*FindSwig*)



$SwigPath=
	{
		$ChemExtensionsDev,
		$ChemExtensionsApp
		};


FindSwig[]:=
	Replace[
		StringTrim@
			RunProcess[			
				{If[$OperatingSystem=="Windows","where", "which"], "swig"},
				"StandardOutput"
				],
		{
			ob_String?(StringLength[#]>0&&FileExistsQ[#]&&
				swigDirQ[Nest[DirectoryName, #, 2]]&):>
				Nest[DirectoryName, ob, 2],
			_:>
				SelectFirst[
					FileNames["*swig*", $SwigPath],
					swigDirQ,
					ChemExtensionDir["swig"]
					]
			}
		]


(* ::Subsection:: *)
(*Swig*)



(* ::Subsubsection::Closed:: *)
(*$swigsrc*)



$swigsrc=
	"http://prdownloads.sourceforge.net/swig/swig-3.0.12.tar.gz";


(* ::Subsubsection::Closed:: *)
(*$swigpcresrc*)



$swigpcresrc="https://ftp.pcre.org/pub/pcre/pcre-8.41.tar.gz";


(* ::Subsubsection::Closed:: *)
(*swigDownload*)



swigDownload[dir_String?DirectoryQ]:=
	With[{
		tmpDir=
			CreateDirectory@
				FileNameJoin@{
					$TemporaryDirectory,
					StringJoin@RandomSample[Alphabet[],10]
					}
		},
		With[{
			f=URLDownload[$swigsrc,FileNameJoin@{tmpDir,"swig_tmp.tar.gz"}],
			out=FileNameJoin@{dir,"swig"}
			},
			ExtractArchive[f,tmpDir];
			DeleteFile[f];
			If[DirectoryQ@out,DeleteDirectory[out,DeleteContents->True]];
			CopyDirectory[First@FileNames["*",tmpDir],out];
			Quiet@DeleteDirectory[tmpDir,DeleteContents->True];
			swigpcreDownload[out];
			Replace[
				out,
				Except[_String?FileExistsQ]->$Failed
				]
		]
	];


swigpcreDownload[dir_]:=
	URLDownload[
		$swigpcresrc,
		FileNameJoin@{
			dir,
			FileNameTake[$swigpcresrc]
			}
		]


(* ::Subsubsection::Closed:: *)
(*swigBuild*)



swigBuild[dir_]:=
	With[{swigdir=ExpandFileName@FileNameJoin@{dir,"swig"}},
		RunInTerminal[{FileNameJoin@{"Tools","pcre-build.sh"}},
			ProcessDirectory->swigdir
			];
		RunInTerminal[
			{
				FileNameJoin@{swigdir, "configure"},
				"--prefix="<>
					FileNameJoin@
						Map[
							If[StringContainsQ[#,Whitespace],"\""<>#<>"\"",#]&,
							FileNameSplit[swigdir]
							]
				},
			ProcessDirectory->swigdir
			];
		RunInTerminal[{"make"},
			ProcessDirectory->swigdir
			];
		RunInTerminal[{"make","install"},
			ProcessDirectory->swigdir
			];
		If[FileExistsQ@FileNameJoin@{swigdir,"bin","swig"},
			FileNameJoin@{swigdir,"bin","swig"},
			PackageRaiseException[
				"SwigBuild",
				"Failed to build swig to ``",
				"MessageParameters"->{FileNameJoin@{swigdir,"bin","swig"}}
				]
			]
		]


(* ::Subsubsection::Closed:: *)
(*swigDirQ*)



swigDirQ[dir_]:=
	FileExistsQ@FileNameJoin@{dir, "bin", "swig"}


(* ::Subsubsection::Closed:: *)
(*swigCheck*)



swigCheck[dir_?DirectoryQ]:=
	FileExistsQ@FileNameJoin@{dir, "swig", "bin", "swig"};


(* ::Subsubsection::Closed:: *)
(*swigEnsureDownload*)



swigEnsureDownload[d_]:=
	If[!DirectoryQ@FileNameJoin@{d, "swig"}||
		Length[
			Select[DirectoryQ]@
				FileNames["*",FileNameJoin@{d, "swig"}]
			]===0,
		swigDownload[d]
		];


(* ::Subsubsection::Closed:: *)
(*$SwigDirectory*)



$SwigDirectory:=
	$SwigDirectory=FindSwig[];


(* ::Subsubsection::Closed:: *)
(*SwigBuild*)



SwigBuild[dir:_String?DirectoryQ|Automatic:Automatic]:=
	PackageExceptionBlock["SwigBuild"]@
		If[swigDirQ@Replace[dir, Automatic:>$SwigDirectory],
			Replace[dir, Automatic:>$SwigDirectory],
			With[{d=Replace[dir, Automatic:>DirectoryName@$SwigDirectory]},
				If[!swigCheck[d],
					swigEnsureDownload[d];
					swigBuild[d],
					Replace[dir, 
						{
							Automatic:>$SwigDirectory,
							e_:>FileNameJoin@{e, "swig"}
							}
						]
					]
				]
			]


(* ::Subsubsection::Closed:: *)
(*SwigBinary*)



SwigBinary[dir:_String?DirectoryQ|Automatic:Automatic]:=
	PackageExceptionBlock["SwigBuild"]@
		FileNameJoin@{SwigBuild[], "bin", "swig"}


End[];


