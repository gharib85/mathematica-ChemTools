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


Cartesian2DDVRFormatGrid::usage=""
Cartesian2DDVRPoints::usage=""
Cartesian2DDVRKineticMatrix::usage=""
Cartesian2DDVRPotentialMatrix::usage=""
Cartesian2DDVRWavefunctions::usage=""
Cartesian2DDVRPlotFunction::usage=""


Begin["`Private`"];


Cartesian2DDVRPoints[
	points:{_Integer, _Integer},
	X:{{_?NumericQ,_?NumericQ}, {_?NumericQ,_?NumericQ}}:{{-10,10}, {-10,10}}
	]:=
	Table[
		{x, y},
		{x, Subdivide@@Flatten@{N@X[[1]],points[[1]]-1}},
		{y, Subdivide@@Flatten@{N@X[[2]],points[[2]]-1}}
		]


(* ::Text:: *)
(*We\[CloseCurlyQuote]ll be lazy and claim we can just do a summation of the 1D DVRs *)



Cartesian2DDVRKineticMatrix[grid_,OptionsPattern@{"M"->1,"\[HBar]"->1}]:=
	With[{
		xmin=Min@grid[[1]],xmax=Max@grid[[1]],xpoints=Length@grid[[1]],
		ymin=Min@grid[[2]],yxmax=Max@grid[[2]],ypoints=Length@grid[[2]]
		},
		With[{
			dx=(xmax-xmin)/xpoints,
			dy=(xmax-xmin)/ypoints,
			m=OptionValue@"M",
			\[HBar]=OptionValue@"\[HBar]"
			},
			If[xpoints*ypoints>100000,
				ParallelTable,
				Table
				][
				With[{
					ix=Floor[(i-1)/xpoints*ypoints], jx=Mod[i, xpoints, 1],
					iy=Floor[(j-1)/xpoints*ypoints], jy=Mod[j, ypoints, 1]
					},(*
					If[iy\[Equal]jy, 
						0.,*)
						If[ix==jx, \[Pi]^2/3., 2./(ix-jx)^2]*(\[HBar] (-1)^(ix-jx))/(2.m dx^2)+
						(*]*)(*+
					If[ix\[Equal]jx, 
						0.,*)
						If[iy==jy, \[Pi]^2/3., 2./(iy-jy)^2]*(\[HBar] (-1)^(iy-jy))/(2.m dy^2)(*
						]*)
					],
				{i,xpoints*ypoints},
				{j,xpoints*ypoints}
				]
			]
		]


Options[Cartesian2DDVRPotentialMatrix]={Function->(Norm[(#/2)^2]&)};
Cartesian2DDVRPotentialMatrix[grid_,ops:OptionsPattern[]]:=
	With[{func=OptionValue@Function},
		With[{A=func/@Flatten[grid,1]},
			DiagonalMatrix@A
			]
		]


Options[Cartesian2DDVRPlotFunction]=
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
		"CutOff"->10^-4,
		Manipulate->True,
		PlotRange->Automatic,
		"SquareWavefunction"->False,
		FilterRules[Options[ListLinePlot],
			Except[AxesOrigin|PlotRange|LabelingFunction]
			]
		};
Cartesian2DDVRPlotFunction[
	solutions_,
	grid2D_,
	potentialMatrix_,
	ops:OptionsPattern[]
	]:=
	Module[
		{\[CapitalLambda],X,\[Psi],
		scale=OptionValue[Scaled],
		num=
			Replace[OptionValue["WavefunctionSelection"],{
				Automatic:>If[TrueQ@OptionValue@Manipulate, All, 1]
				}],
		dataRange,
		potential=
			If[potentialMatrix//MatrixQ,
				Diagonal@potentialMatrix,
				potentialMatrix],
		squared=OptionValue@"SquareWavefunction",
		lf=Replace[OptionValue@LabelingFunction,{
				Automatic->(
					Row@{Subscript["\[Psi]",#1],": E=",
						1.Round[#2, 10^(-OptionValue["EnergyDigits"])]}&),
				None->False}],
		plotWave,
		waveSet,
		Ec=OptionValue["CutOff"],
		wavePlot,potentialPlot,
		\[Lambda]Plot,plotRange,len,
		grid=Flatten[grid2D, 1]
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
		\[Psi]=Function[MapThread[Append[#1, If[squared,#2^2,#2]]&,{grid, X[[#]]}]];
		waveSet=\[Psi]/@num;
		dataRange=
			CoordinateBounds@
				Select[Flatten[waveSet,1],Abs[#[[3]]]>=Ec&];
		plotWave[n_]:=
			If[OptionValue["ShowEnergy"]//TrueQ,
				With[{s={1, 1, scale},\[Lambda]={0,0,\[CapitalLambda][[n]]}},
					\[Lambda]+s*#&/@\[Psi][n]
					],
				With[{s={1, 1,scale},\[Lambda]={0,0,\[CapitalLambda][[n]]}},
					s*#&/@\[Psi][n]
					]
				];
		waveSet=
			Select[#,
				dataRange[[1,1]]<=#[[1]]<=dataRange[[1,2]]&&
					dataRange[[2,1]]<=#[[2]]<=dataRange[[2,2]]&
				]&/@(plotWave/@num);
		wavePlot[sel_,lFunc_:lf]:=
			ListPlot3D[
				waveSet[[sel]],
				FilterRules[{
					ops,
					PlotRange->
						dataRange,
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
					ListPlot3D[
						MapThread[Append, {grid,potential}],
						PlotRange->
							dataRange,
						PlotStyle->
							Replace[op,
								Automatic->
									Directive[Opacity[.1], Gray]
								]
						]
					]
				];
		\[Lambda]Plot[sel_]:=
			ListPlot3D[
				MapThread[Append, {grid, ConstantArray[#, Length[grid]]}],
				PlotStyle->Directive[Opacity[.1], Red],
				PlotRange->
					dataRange
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


$Cartesian2DDVR=
	<|
		"Name"->"Cartesian 2D",
		"Dimension"->2,
		"PointLabels"->{"x"|"y"|"z", "x"|"y"|"z"},
		"Range"->{{-10,10}, {-10, 10}},
		"Grid"->Cartesian2DDVRPoints,
		"KineticEnergy"->Cartesian2DDVRKineticMatrix,
		"PotentialEnergy"->Cartesian2DDVRPotentialMatrix,
		"View"->Cartesian2DDVRPlotFunction
		|>


ChemDVREnd[];


$Cartesian2DDVR


