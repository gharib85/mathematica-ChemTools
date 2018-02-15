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


Options[Cartesian1DDVRPotentialMatrix]={Function->((#/2)^2&)};
Cartesian1DDVRPotentialMatrix[grid_,ops:OptionsPattern[]]:=
	With[{func=OptionValue@Function},
		With[{A=func/@grid},
			DiagonalMatrix@A
			]
		]


Options[Cartesian1DDVRPlotFunction]=
	DeleteDuplicatesBy[First]@
	Flatten@{
		"WavefunctionSelection"->Automatic,
		AxesOrigin->{0,0},
		Scaled->1,
		"ShowEnergy"->True,
		"PotentialStyle"->Automatic,
		"EnergyDigits"->3,
		"ZeroPointEnergy"->0,
		LabelingFunction->Automatic,
		"CutOff"->10^-5,
		Manipulate->True,
		PlotRange->Automatic,
		"SquareWavefunction"->False,
		FilterRules[Options[ListLinePlot],
			Except[AxesOrigin|PlotRange|LabelingFunction]
			]
		};
Cartesian1DDVRPlotFunction[solutions_,grid_,potentialMatrix_,ops:OptionsPattern[]]:=
	Module[
		{\[CapitalLambda],X,\[Psi],
		scale=OptionValue[Scaled],
		num=
			Replace[OptionValue["WavefunctionSelection"],{
				Automatic:>If[TrueQ@OptionValue@Manipulate,All,5]
				}],
		dataRange,
		potential=
			If[potentialMatrix//MatrixQ,
				Diagonal@potentialMatrix,
				potentialMatrix],
		squared=OptionValue@"SquareWavefunction",
		lf=Replace[OptionValue@LabelingFunction,{
				Automatic->(Row@{Subscript["\[Psi]",#1],": E=",
					NumberForm[#2,OptionValue["EnergyDigits"]]}&),
				None->False}],
		plotWave,waveSet,Ec=OptionValue["CutOff"],
		wavePlot,potentialPlot,
		\[Lambda]Plot,plotRange,len
		},
		{\[CapitalLambda],X}=solutions;
		len=Length@X;
		num=
			Replace[num,
				{
					All:>Range[1,len],
					_List:>num,
					_Integer:>Range[1,num],
					_->1
					}];
		\[Psi]=Function[MapThread[{#1,If[squared,#2^2,#2]}&,{grid,X[[#]]}]];
		waveSet=\[Psi]/@num;
		dataRange=
			With[{\[CurlyPhi]=Select[Flatten[waveSet,1],Abs[#[[2]]]>=Ec&]},
				{Min[\[CurlyPhi][[All,1]]],Max[\[CurlyPhi][[All,1]]]}
				];
		plotWave[n_]:=
			If[OptionValue["ShowEnergy"]//TrueQ,
				With[{s={1,scale},\[Lambda]={0,\[CapitalLambda][[n]]}},
					\[Lambda]+s*#&/@\[Psi][n]
					],
				With[{s={1,scale},\[Lambda]={0,\[CapitalLambda][[n]]}},
					s*#&/@\[Psi][n]
					]
				];
		waveSet=
			Select[#,Between[dataRange]@*First]&/@(plotWave/@num);
		wavePlot[sel_,lFunc_:lf]:=
			ListLinePlot[ 
				waveSet[[sel]],
				FilterRules[{
					ops,
					PlotRange->{
						Min@Append[waveSet[[sel,All,2]],0],
						Max@waveSet[[sel,All,2]]
						},
					PlotLegends->
						If[lFunc===False,
							None,
							(lFunc@@#)&/@
								Thread@{
									num[[ If[IntegerQ@sel,{sel},sel] ]],
									\[CapitalLambda][[ num[[ If[IntegerQ@sel===0,{sel},sel] ]] ]]
									}
							]
					},
					Options@ListLinePlot
					]
				];
		potentialPlot=
			With[{op=OptionValue["PotentialStyle"]},
				If[op===None,
					Nothing,
					ListLinePlot[
						Thread[{grid,potential}],
						PlotStyle->
							Replace[op,
								Automatic->{Gray,Dashing[{.01,.025,.02,.025}]}
								]
						]
					]
				];
		\[Lambda]Plot[sel_]:=
			ListLinePlot[
				Thread[{grid,#}],
				PlotStyle->{Red,Dotted}
				]&/@\[CapitalLambda][[ num[[sel]] ]];
		plotRange=Automatic;
		If[Length@num>1,
			If[OptionValue@Manipulate,
				With[{wp=wavePlot,N=num,
					lF=With[{f=lf[#1,#2]},f&],
					potPlot=potentialPlot,L=\[CapitalLambda],
					\[Lambda]P=\[Lambda]Plot,pR=plotRange},
				Manipulate[
					Show[
						wp[N[[i]],lF],
						{
							potPlot,
							If[OptionValue["ShowEnergy"]//TrueQ,\[Lambda]P[{i}],Sequence@@{}]
							},
						FilterRules[{ops,PlotRange->pR},Options[Plot]]
						],
					{{i,1,""},1,Length@N,1}
					]
				],
				Show[wavePlot[All],
					{potentialPlot,
						If[OptionValue["ShowEnergy"]//TrueQ,
							\[Lambda]Plot[All],
							Sequence@@{}
							]
							},
					FilterRules[{ops,PlotRange->plotRange},
						Options[Plot]
						]
					]
			],
			Show[wavePlot[All],
				{potentialPlot,\[Lambda]Plot[All]},
				FilterRules[{ops,PlotRange->plotRange},
					Options[Plot]
					]
				]
			]
	];


End[];


$Cartesian1DDVR=
	<|
		"Name"->"Cartesian 1D",
		"Dimension"->1,
		"PointLabels"->{"x"|"y"|"z"},
		"Range"->{{-10,10}},
		"Grid"->Cartesian1DDVRPoints,
		"KineticEnergy"->Cartesian1DDVRKineticMatrix,
		"PotentialEnergy"->Cartesian1DDVRPotentialMatrix,
		"View"->Cartesian1DDVRPlotFunction
		|>


ChemDVREnd[];


$Cartesian1DDVR



