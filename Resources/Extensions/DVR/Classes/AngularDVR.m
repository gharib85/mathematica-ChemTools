(* ::Package:: *)

(************************************************************************)
(* This file was generated automatically by the Mathematica front end.  *)
(* It contains Initialization cells from a Notebook file, which         *)
(* typically will have the same name as this file except ending in      *)
(* ".nb" instead of ".m".                                               *)
(*                                                                      *)
(* This file is intended to be loaded into the Mathematica kernel using *)
(* the package loading commands Get or Needs.  Doing so is equivalent   *)
(* to using the Evaluate Initialization Cells menu command in the front *)
(* end.                                                                 *)
(*                                                                      *)
(* DO NOT EDIT THIS FILE.  This entire file is regenerated              *)
(* automatically each time the parent Notebook file is saved in the     *)
(* Mathematica front end.  Any changes you make to this file will be    *)
(* overwritten.                                                         *)
(************************************************************************)



ChemDVRBegin[];


AngularDVRPoints::usage="Generates the grid";
AngularDVRK::usage="";


Begin["`Private`"];


AngularDVRPoints[{points_Integer},
	X:{{_?NumericQ,_?NumericQ}}:{{0,2.\[Pi]}}
	]:=
	DeleteDuplicatesBy[Mod[#,2\[Pi]]&][
		Subdivide@@Append[X[[1]],points]
		]


Options[AngularDVRK]=
	{
		"Mass"->1,
		"HBar"->1,
		"ScalingFactor"->1,
		"UseExact"->False
		};
AngularDVRK[gridpoints_,ops:OptionsPattern[]]:=
	With[
		{
			X=gridpoints,
			p=Length@gridpoints,
			\[HBar]=OptionValue@"HBar",
			m=OptionValue["Mass"],
			ex=TrueQ@OptionValue["UseExact"],
			s=OptionValue["ScalingFactor"]
			},
		Table[
			If[!ex, N, Identity]@
			(s*\[HBar])*
			If[i==j,
				(p^2/2+1)*1/6,
				((-1)^(i-j))/
					(2*Sin[(\[Pi]*(i-j))/p]^2)
				],
			{i,p},
			{j,p}
			]
		];


End[];


$AngularDVR=
	<|
		"Name"->"Angular 1D",
		"Dimension"->1,
		"PointLabels"->{("\[CurlyPhi]"|"\[Phi]"|"phi"|"Phi"|"Angular"|"angular")},
		"Range"->{{0,2\[Pi]}},
		"Grid"->AngularDVRPoints,
		"KineticEnergy"->AngularDVRK,
		"Defaults"->
				{
					"PotentialFunction"->"HinderedRotor",
					"PlotMode"->"Angular3D"
					}
		|>;


ChemDVREnd[];


$AngularDVR



