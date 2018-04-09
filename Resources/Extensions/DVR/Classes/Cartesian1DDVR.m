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


Cartesian1DDVRFormatGrid::usage=""
Cartesian1DDVRPoints::usage=""
Cartesian1DDVRKineticMatrix::usage=""
Cartesian1DDVRPotentialMatrix::usage=""
Cartesian1DDVRWavefunctions::usage=""
Cartesian1DDVRPlotFunction::usage=""


Begin["`Private`"];


Cartesian1DDVRPoints[points:{_Integer},
	X:{{_?NumericQ,_?NumericQ}}:{{-10,10}}]:=
	Subdivide@@Flatten@{N@X,points-1}


Options[Cartesian1DDVRKineticMatrix]=
	{
		"Mass"->1,
		"HBar"->1,
		"ScalingFactor"->1,
		"UseExact"->False
		};
Cartesian1DDVRKineticMatrix[grid_,OptionsPattern[]]:=
	With[{xmin=Min@grid,xmax=Max@grid,points=Length@grid},
		With[
			{
				dx=(xmax-xmin)/(points-1),
				m=OptionValue@"Mass",
				\[HBar]=OptionValue@"HBar",
				scl=OptionValue@"ScalingFactor",
				ex=TrueQ@OptionValue@"UseExact"
				},
			With[
				{
					f=
						If[ex,
							scl*
								If[#==#2, 
									\[Pi]^2/3, 
									2/(#-#2)^2
									]*
									(\[HBar]^2(-1)^(#-#2))/(2m dx^2)&,
							scl*
								If[#==#2, 
									\[Pi]^2./3.,
									2./(#-#2)^2
									]*
									(\[HBar]^2.(-1)^(#-#2))/(2.m dx^2)&
							]
					},
				If[points>100000,
					ParallelTable[f[i,j],{i,points},{j,points}],
					Table[f[i,j],{i,points},{j,points}]
					]
				]
			]
		]


End[];


$Cartesian1DDVR=
	<|
		"Name"->"Cartesian 1D",
		"Dimension"->1,
		"PointLabels"->{"x"|"y"|"z"},
		"Range"->{{-10,10}},
		"Grid"->Cartesian1DDVRPoints,
		"KineticEnergy"->Cartesian1DDVRKineticMatrix,
		"Defaults"->
			{
				"PotentialFunction"->"HarmonicOscillator",
				"PlotMode"->{"Cartesian", 1}
				}
		|>


ChemDVREnd[];


$Cartesian1DDVR



