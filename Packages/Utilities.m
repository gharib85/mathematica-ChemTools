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



ChemDataAtomQ::usage="Returns true for atom or isotope strings";
ChemDataIsotopeQ::usage="Returns true for isotope strings";


ChemHQuantumNumbers::usage=
	"Gives quantum numbers for an orbital configuration";
ChemHAngularWavefunction::usage=
	"Returns the angular part of the orbital wavefunction";
ChemHRadialWavefunction::usage=
	"Computes the radial part of the orbital wavefunction";
ChemHOrbital::usage=
	"Computes the input orbital";
ChemHOrbitalPlot::usage="Plots the orbital";


ChemHOrbitalSurface::usage="Computes the surface of a H orbital";
ChemHOrbitalVolume::usage="Computes the volume of an H orbital";


ChemUtilsDetectMolFormat::usage=
	"Detects a molecule format";
ChemUtilsGenerateZMatrix::usage=
	"Turns a list of atom-coordiante pairs into a ZMatrix";
ChemUtilsGenerateMolTable::usage=
	"Turns a ZMatrix into a list of atoms-coordinate pairs";
ChemUtilsGenerateMolRules::usage="Generates rules for a MOL file";
ChemUtilsGenerateMolString::usage="Converts atom list into MOL or SDF string";


ChemUtilsBondMatrix::usage=
	"Converts a bond list into a bond matrix";
ChemUtilsBondList::usage=
	"Converts a bond matrix into a bond list";
ChemUtilsGuessBonds::usage=
	"Attempts to resolve the bonding structure of a collection of atoms";


ChemUtilsInertialEigensystem::usage=
	"Returns the inertial eigensystem for a collection of masses and positions";
ChemUtilsInertialSystem::usage=
	"Returns the A, B, and C constants and axes";
ChemUtilsRotorType::usage=
	"Returns the type of molecular rotor that best resembles the collection of atoms";


ChemUtilsCoordinateBounds::usage=
	"The bounding box of a collection of atoms";
ChemUtilsCenter::usage="Center of a set of atoms";
ChemUtilsCenterOfMass::usage="COM of a set of atoms";


ChemUtilsIsotopologues::usage=
	"Figures out all possible isotopologues and abundances of a given atomset";


ChemUtilsSymmetryElements::usage=
	"Finds all the symmetry elements of a collection of atoms";
ChemUtilsSymmetryGraphics::usage=
	"Plots a collection of symmetry elements";
ChemUtilsInertialSymmetry::usage=
	"Finds symmetry elements relative to the ABC axes";
ChemUtilsPointGroup::usage=
	"Guesses the point group of the collection of atoms";


ChemUtilsAxisAlignmentTransform::usage=
	"Alignment transform mapping points";


Begin["`Private`"];


ChemDataIsotopeQ[s_String]:=
	ChemDataSource[s]===IsotopeData;
ChemDataAtomQ[s_String]:=
	MatchQ[ChemDataSource[s],ElementData|IsotopeData];
ChemDataIsotopeQ[__]:=False


ChemHQuantumNumbers[primary_String,sub_String:""]:=
	Replace[
		{ToLowerCase@primary,ToLowerCase@sub},{
			{"s",""}->{0,0},
			{"p","x"}->{1,-1},
			{"p","z"|""}->{1,0},
			{"p","y"}->{1,1},
			{"d","xy"}->{2,-2},
			{"d","xz"}->{2,-1},
			{"d","z"|""}->{2,0},
			{"d","yz"}->{2,1},
			{"d","x-y"}->{2,2},
			{"f","z"|""}->{3,0},
			_->$Failed
			}
		]


sphericalHarmonic[{l_Integer,m_Integer:0}]:=
	If[l>=0,
		With[{s=SphericalHarmonicY[l,m,#,#2]},
			(s&)
			],
		With[{s=SphericalHarmonicY[-l,-m,#,#2]},
			(-s&)
			]
		];


harmonicCombination[k:_Real|_Complex:1,harmonics__List]:=
	With[{f=k*(
		Total@(
			Table[sphericalHarmonic[h][#,#2],{h,{harmonics}}])/Sqrt@Length@{harmonics})
			},
		f&
		];


angularWavefunction[l_,m_]:=
	Which[
		m>0,
			harmonicCombination[{l,-m},-{l,m}],
		m==0,
			sphericalHarmonic[{l,m}],
		m<0,
			harmonicCombination[{l,-m},{l,m}]
		];


ChemHAngularWavefunction[l_Integer,m_Integer]:=
	angularWavefunction[l,m];
ChemHAngularWavefunction[l_String,m_String:""]:=
	angularWavefunction@@ChemHQuantumNumbers[l,m];


bohrRadius=
	QuantityMagnitude@UnitConvert[Quantity["BohrRadius"],"Angstroms"];


radialWavefunction[n_,l_,Z_Integer:1]:=
	Evaluate[
		(Sqrt[(n-l-1)!/(2*n*((n+l)!)^3)])*
		((2Z/(n*bohrRadius))^(l+3/2))*
		(#^l)Exp[-Z#/(n*bohrRadius)]*
		LaguerreL[n+l-1,2l+1,2Z #/(n*bohrRadius)]
		]&


ChemHRadialWavefunction[n_Integer,l_Integer,Z_Integer:1]:=
	radialWavefunction[n,l,Z];
ChemHRadialWavefunction[l_String,m_String:"",Z_Integer:1]:=
	radialWavefunction@@
		Replace[ChemHQuantumNumbers[l,m],{a_,b_}:>{a+1,a,Z}];


ChemHOrbital[n:_Integer|Automatic:Automatic,l_Integer,m_Integer]:=
	With[{qn=Replace[n,Automatic->l+1]},
		With[{
			f=radialWavefunction[qn,l][#],
			f2=angularWavefunction[l,m][#2,#3]},
			f*f2&
			]
		];
ChemHOrbital[n_:Automatic,l_String,m_String:""]:=
	ChemHOrbital[n,Sequence@@ChemHQuantumNumbers[l,m]];


ChemHOrbitalPlot[
	{n_,m_,l_},
	densityCutoff:_Real|Automatic:Automatic,
	DensityPlot3D,
	radial:{_?NumericQ,_?NumericQ}|Automatic:Automatic,
	azimuthal:{_?NumericQ,_?NumericQ}|Automatic:Automatic,
	polar:{_?NumericQ,_?NumericQ}|Automatic:Automatic,
	o:OptionsPattern[Options@DensityPlot3D]]:=
	With[{c2s=
		CoordinateTransform["Cartesian"->"Spherical",{#,#2,#3}],
		rRange=Replace[radial,Automatic:>{0,n+1.25}],
		qRange=Replace[azimuthal,Automatic->{0,2\[Pi]}],
		jRange=Replace[polar,Automatic->{0,\[Pi]}]},
	With[{
		f=ChemHOrbital[n,m,l]@@(c2s&[\[Rho],\[Theta],\[CurlyPhi]]),
		rf=With[{r=Last@rRange},(#\[Element]Ball[{0,0,0},r]&)],
		opf=
			If[densityCutoff=!=Automatic,
				(If[#>densityCutoff,1,0]&),
				(If[#<.5,#/2,Mean@{#,1},Mean@{#,0}]&)
				]},
		DensityPlot3D[
			Abs[f]^2,
			Evaluate@
				If[rRange[[1]]==0&&qRange=={0,2\[Pi]}&&jRange=={0,\[Pi]},
					With[{r=Last@rRange},
						{\[Rho],\[Theta],\[CurlyPhi]}\[Element]Ball[{0,0,0},r]],
					Sequence@@
						{
							{\[Rho],-Last@rRange,Last@rRange},
							{\[Theta],-Last@qRange,Last@qRange},
							{\[CurlyPhi],-Last@jRange,Last@jRange}
							}
				],
			o,
			PlotRange->All,
			Boxed->False,
			(*RegionFunction\[Rule]rf,*)
			OpacityFunction->opf,
			Axes->False,
			AxesOrigin->{0,0,0}
			MeshFunctions->(Function/@c2s)
			]
		]
		];


ChemHOrbitalPlot[
		{n_,m_,l_},
		contourValue:_Real|Automatic:Automatic,
		ContourPlot3D,
		radial:{_?NumericQ,_?NumericQ}|Automatic:Automatic,
		azimuthal:{_?NumericQ,_?NumericQ}|Automatic:Automatic,
		polar:{_?NumericQ,_?NumericQ}|Automatic:Automatic,
		o:OptionsPattern[Options@ContourPlot3D]
		]:=
	With[{c2s=
		CoordinateTransform["Cartesian"->"Spherical",{#,#2,#3}],
		rRange=Replace[radial,Automatic:>{0,n+1.25}],
		qRange=Replace[azimuthal,Automatic->{0,2\[Pi]}],
		jRange=Replace[polar,Automatic->{0,\[Pi]}]},
	With[{
		rf=With[{r=Last@rRange},(#\[Element]Ball[{0,0,0},r]&)],
		f=ChemHOrbital[n,m,l]@@(c2s&[\[Rho],\[Theta],\[CurlyPhi]])
		},
		Quiet@ContourPlot3D[
			Evaluate@
				If[contourValue===Automatic,
					Abs[f]^2,
					Abs[f]^2==contourValue
					],
			{\[Rho],-Last@rRange,Last@rRange},
			{\[Theta],-Last@qRange,Last@qRange},
			{\[CurlyPhi],-Last@jRange,Last@jRange},
			o,
			Contours->1,
			Lighting->"Neutral",
			ContourStyle->Directive[Hue[.5,.4,.3],Specularity[White,500]],
			PlotPoints->20,
			PlotRange->All,
			Boxed->False,
			Axes->False,
			AxesOrigin->{0,0,0},
			MeshFunctions->(Function/@c2s),
			MeshStyle->None
			]
		]
		];


ChemHOrbitalPlot[
		{n_,m_,l_},
		cutoff:_Real:.0005,
		Optional[RegionPlot3D,RegionPlot3D],
		radial:{_?NumericQ,_?NumericQ}|Automatic:Automatic,
		azimuthal:{_?NumericQ,_?NumericQ}|Automatic:Automatic,
		polar:{_?NumericQ,_?NumericQ}|Automatic:Automatic,
		o:OptionsPattern[Options@ContourPlot3D]
		]:=
	With[{c2s=
		CoordinateTransform["Cartesian"->"Spherical",{#,#2,#3}],
		rRange=Replace[radial,Automatic:>{0,n+1.25}],
		qRange=Replace[azimuthal,Automatic->{0,2\[Pi]}],
		jRange=Replace[polar,Automatic->{0,\[Pi]}]},
	With[{
		rf=With[{r=Last@rRange},(#\[Element]Ball[{0,0,0},r]&)],
		f=ChemHOrbital[n,m,l]@@(c2s&[\[Rho],\[Theta],\[CurlyPhi]])
		},
		Quiet@RegionPlot3D[
			Abs[f]^2>cutoff,
			{\[Rho],-Last@rRange,Last@rRange},
			{\[Theta],-Last@qRange,Last@qRange},
			{\[CurlyPhi],-Last@jRange,Last@jRange},
			o,
			Lighting->"Neutral",
			PlotStyle->Directive[Hue[.5,.4,.3],Specularity[White,500]],
			PlotPoints->20,
			PlotRange->All,
			Boxed->False,
			Axes->False,
			AxesOrigin->{0,0,0},
			MeshFunctions->(Function/@c2s),
			MeshStyle->None
			]
		]
		];


ChemHOrbitalPlot[s__String,a:Except[_String]...]:=
	ChemHOrbitalPlot[
		Replace[ChemHQuantumNumbers[s],
			{l_,m_}:>{l+1,l,m}],
		a
		];


ChemHOrbitalSurface[{n_,l_,m_},cutoff_Real:.001]:=
	ChemSurface@ChemHOrbitalPlot[{n,l,m},cutoff,RegionPlot3D];
ChemHOrbitalSurface[l_String,m_String:"",cutoff_Real:.001]:=
	ChemSurface@ChemHOrbitalPlot[l,m,cutoff,RegionPlot3D];


ChemHOrbitalVolume[s_?RegionQ]:=
	Quantity[
		With[
			{coords = MeshCoordinates[s]},
			With[{
				compiledDotCross=
					Compile[{{abc,_Integer,1}},
						coords[[ abc[[1]] ]].
								Cross[coords[[ abc[[2]] ]], coords[[ abc[[3]] ]]]
						]
					},
				(MeshCells[s, 2]/.Polygon[g_List] :> compiledDotCross@g)
					//Total
				]/6
			],
		"Angstroms"^3
		];


ChemHOrbitalVolume[s__]:=
	ChemHOrbitalVolume@
		ChemHOrbitalSurface[s];	


ChemUtilsDetectMolFormat[s_String]:=
	Which[
		StringStartsQ[s,"InChI"],
			"InChI",
		Length@StringCases[s,"\n"]===0,
			"SMILES",
		Length@StringCases[s,"M  END"]===1,
			"MOL",
		Length@StringCases[s,"M  END"]>1,
			"SDF",
		StringStartsQ[StringTrim[s], LetterQ..~~"\n"],
			"ZMatrix",
		True,
			$Failed
		];
ChemUtilsDetectMolFormat[l_List]:=
	Switch[l,
		{
			Optional[{_Integer,_Integer},{0,0}],
			{_String,_List,___}..,
			{_Integer,_Integer,___}...
			},
			"MOL",
		{
			{_String},
			{_String, _Integer, __?NumericQ}...
			},
			"ZMatrix",
		{
			Repeated[{
				Optional[{_Integer,_Integer},{0,0}],
				{_String,_List,___}..,
				{_Integer,_Integer,___}...
				}]
			},
			"SDF",
		{
			Repeated[_->{__List}]
			},
			"SDFRules",
		{
			Repeated[_->_List]
			},
			"MOLRules",
		_,
			$Failed
		]


zmNorm=
	Function[{crd1,crd2},
		Norm[crd2-crd1]
		];
zmVAngle=
	Function[{crd1,crd2,crd3},
		VectorAngle[
			crd2-crd3,
			crd2-crd1
			]*180/\[Pi]
		];
zmDAngle=
	Function[{crd1,crd2,crd3,crd4},
		With[{caxis=crd3-crd2},
			VectorAngle[
				Cross[crd4-crd3,caxis],
				Cross[crd2-crd1,-caxis]
				]*180/\[Pi]
			]
		];


zmatrixEntry[atom_,previousAtoms_]:=
	Switch[Length@previousAtoms,
		0,
			{First@atom},
		1,
			{First@atom,
				1,zmNorm[
						Last@atom,
						Last@previousAtoms[[-1]]
						]
				},
		2,
			{First@atom,
				2,zmNorm[
						Last@atom,
						Last@previousAtoms[[-1]]
						],
				1,zmVAngle[
						Last@atom,
						Last@previousAtoms[[-1]],
						Last@previousAtoms[[-2]]
						]
				},
		_,
			{First@atom,
				Length@previousAtoms,
					zmNorm[
						Last@atom,
						Last@previousAtoms[[-1]]
						],
				Length@previousAtoms-1,
					zmVAngle[
						Last@atom,
						Last@previousAtoms[[-1]],
						Last@previousAtoms[[-2]]
						],
				Length@previousAtoms-2,
					zmDAngle[
						Last@atom,
						Last@previousAtoms[[-1]],
						Last@previousAtoms[[-2]],
						Last@previousAtoms[[-3]]
						]
				}
		];


ChemUtilsGenerateZMatrix[atoms_List]:=
	MapIndexed[zmatrixEntry[#,Take[atoms,First@#2-1]]&,atoms]


molTableNormed=
	Function[{crd1,crd2,norm},
		crd1+norm*Normalize[crd2-crd1]
		];
molTableVAngled=
	Function[{crd1,crd2,rv,angle},
		crd1+RotationMatrix[angle,rv].(crd2-crd1)
		];
molTableDAngled=
	Function[{crd1,crd2,crd3,angle},
		With[{caxis=crd2-crd1},
			crd1+RotationMatrix[angle,Cross[caxis,(crd3-crd1)]].(caxis)
			]
		];


molTableEntry[line_,previousAtoms_]:=
	Switch[Length@previousAtoms,
		0,
			{line[[1]],
				{0.,0.,0.}
				},
		1,
			{line[[1]],
				With[{crd1=previousAtoms[[line[[2]],2]],n=line[[3]]},
					crd1+{0,0,n}
					]
				},
		2,
			{line[[1]],
				With[{
					crd1=previousAtoms[[line[[2]],2]],n=line[[3]],
					crd2=previousAtoms[[line[[4]],2]],a=line[[5]]},
					crd1+n*Normalize[RotationMatrix[a,{1,0,0}].(crd2-crd1)]
					]
				},
		_,
			{line[[1]],
				With[{
					crd1=previousAtoms[[line[[2]],2]],n=line[[3]],
					crd2=previousAtoms[[line[[4]],2]],a=line[[5]],
					crd3=previousAtoms[[line[[6]],2]],d=line[[7]]},
						crd1+
							n*Normalize[
									RotationMatrix[d,(crd2-crd1)].
										RotationMatrix[a,Cross[(crd2-crd1),(crd3-crd1)]].
											(crd2-crd1)
									]
					]
					
				}
		];


ChemUtilsGenerateMolTable[zmMatrix:{{_String},___List}]:=
	Fold[Append[#,molTableEntry[#2,#]]&,{},zmMatrix]


ChemUtilsGenerateMolRules[
	molTable:{
		Optional[{_Integer,_Integer},{0,0}],
		atoms:{_String,_List,___}..,
		bonds:{_Integer,_Integer,___}...
		}
	]:=
	{
		"VertexTypes"->{atoms}[[All,1]],
		"VertexCoordinates"->{atoms}[[All,2]],
		"EdgeRules"->
			Rule@@@{bonds}[[All,;;2]],
		"EdgeTypes"->
			Replace[{bonds}[[All,-1]],
				{
					1->"Single",
					2->"Double",
					3->"Triple",
					_->"Single"
					},
				1
				],
		"FormalCharges"->
			Replace[{atoms},{{_,_,_,c_}:>c,_->0},1]
		}


ChemUtilsGenerateMolRules[
	molTables:{
		Repeated@
			{
				Optional[{_Integer,_Integer},{0,0}],
				{_String,_List,___}..,
				{_Integer,_Integer,___}...
				}
		}
	]:=
	Thread[
		{"VertexTypes","VertexCoordinates",
			"EdgeTypes","EdgeRules","FormalCharges"}->
		Lookup[
			ChemUtilsGenerateMolRules/@molTables,
			{"VertexTypes","VertexCoordinates",
				"EdgeTypes","EdgeRules","FormalCharges"}
			]
		]


ChemUtilsGenerateMolRules[
	zm_List?(ChemUtilsDetectMolFormat[#]==="ZMatrix"&)
	]:=
	ChemUtilsGenerateMolRules@
		ChemUtilsGenerateMolTable[zm]


ChemUtilsGenerateMolString[
	molTable:
		{
			Optional[{_Integer,_Integer},{0,0}],
			{_String,_List,___}..,
			{_Integer,_Integer,___}...
			}
	]:=
	StringDelete[
		StartOfLine~~
			"Created with the Wolfram Language : www.wolfram.com"
			~~EndOfLine
		]@
		ExportString[
			ChemUtilsGenerateMolRules[molTable],
			{"MOL","Rules"}
			];
ChemUtilsGenerateMolString[
	molTables:{
		Repeated@
			{
				Optional[{_Integer,_Integer},{0,0}],
				{_String,_List,___}..,
				{_Integer,_Integer,___}...
				}
		}
	]:=
	StringDelete[
		StartOfLine~~
			"Created with the Wolfram Language : www.wolfram.com"
			~~EndOfLine
		]@
		ExportString[
			ChemUtilsGenerateMolRules[molTables],
			{"SDF","Rules"}
			]
ChemUtilsGenerateMolString[
	zm_List?(ChemUtilsDetectMolFormat[#]==="ZMatrix"&)
	]:=
	StringDelete[
		StartOfLine~~
			"Created with the Wolfram Language : www.wolfram.com"
			~~EndOfLine
		]@
		ExportString[
			ChemUtilsGenerateMolRules@zm,
			{"MOL","Rules"}
			];
ChemUtilsGenerateMolString[
	mol_List?(OptionQ[#]&&ChemUtilsDetectMolFormat[#]==="MOLRules"&)
	]:=
	StringDelete[
		StartOfLine~~
			"Created with the Wolfram Language : www.wolfram.com"
			~~EndOfLine
		]@
		ExportString[mol,{"MOL","Rules"}];
ChemUtilsGenerateMolString[
	mol_List?(OptionQ[#]&&ChemUtilsDetectMolFormat[#]==="SDFRules"&)
	]:=
	StringDelete[
		StartOfLine~~
			"Created with the Wolfram Language : www.wolfram.com"
			~~EndOfLine
		]@
		ExportString[mol,{"SDF","Rules"}];


ChemUtilsInertialTensor[masses_List,positions_List]:=
	Total@MapThread[
		With[{m=#1,x=#2[[1]],y=#2[[2]],z=#2[[3]]},
			m*{ 
				{y^2+z^2,-x*y,-x*z},
				{-x*y,x^2+z^2,-y*z},
				{-x*z,-y*z,x^2+y^2}
			}]&,{masses,positions}
		];
ChemUtilsInertialTensor[massPositions:{{_Real,_List},___}]:=
	ChemUtilsInertialTensor[massPositions[[All,1]],massPositions[[All,2]]];
ChemUtilsInertialTensor[massPositions:{{_String,_List},___}]:=
	ChemUtilsInertialTensor@
		Map[{QuantityMagnitude@ChemDataLookup[First@#,"AtomicMass"],Last@#}&,massPositions];


ChemUtilsInertialEigensystem[args__]:=
	Replace[ChemUtilsInertialTensor[args],
		tensor:{_List,_List,_List}:>
			With[{eig=Eigensystem@tensor},
				With[{ord=Ordering@First@eig},
					{eig[[1,ord]],eig[[2,ord]]}
					]
				]
		];


inertConversion=
	Block[{$ChemDataSourcesDontCacheFlag=True},
		QuantityMagnitude@
			ChemDataLookup[
				"InertialConstant",
				"UnitConversions"
				]
		];
ChemDataLookup["InertialConstant","UnitConversions"]=.


ChemUtilsInertialSystem[{{ia_,ib_,ic_},{ax_,bx_,cx_}}]:=
	<|
		"A"->Replace[ia,{0|0.->\[Infinity],e_:>inertConversion/e}],
		"B"->Replace[ib,{0|0.->\[Infinity],e_:>inertConversion/e}],
		"C"->Replace[ic,{0|0.->\[Infinity],e_:>inertConversion/e}],
		"AAxis"->ax,
		"BAxis"->bx,
		"CAxis"->cx,
		"Units"->Quantity[1,"Megahertz"]
		|>;
ChemUtilsInertialSystem[e__]:=
	ChemUtilsInertialSystem@ChemUtilsInertialEigensystem[e]


ChemUtilsCenter[atoms_]:=
	Mean@Map[Last,atoms];


ChemUtilsCenterOfMass[masses_,positions_]:=
	Mean@WeightedData[positions,masses];
ChemUtilsCenterOfMass[atoms:{{_Real,_},___}]:=
	ChemUtilsCenterOfMass[First/@atoms,Last/@atoms];
ChemUtilsCenterOfMass[atoms:{{_String,_},___}]:=
	ChemUtilsCenterOfMass@
		Map[{QuantityMagnitude@ChemDataLookup[First@#,"AtomicMass"],Last@#}&,
			atoms];


ChemUtilsRotorType[Ic_?NumericQ,Ib_?NumericQ,Ia_?NumericQ]:=
	If[Ia<10^-5,
		"Linear",
		With[{ac=Ic/Ia,ab=Ib/Ia,bc=Ic/Ib},
			Which[
				Max@{ac,ab,bc}<2,
					"Spherical",
				ab<2,
					"Oblate",
				bc<2,
					"Prolate",
				True,
					None
				]
			]
		];
ChemUtilsRotorType[{{Ia_?NumericQ,Ib_?NumericQ,Ic_?NumericQ},_}]:=
	ChemUtilsRotorType[Ia,Ib,Ic];
ChemUtilsRotorType[a:{{_Real,_List},___}]:=
	ChemUtilsRotorType@ChemUtilsInertialEigensystem[a];
ChemUtilsRotorType[a:{{_String,_List},___}]:=
	ChemUtilsRotorType@
		Map[{
			QuantityMagnitude@ChemDataLookup[First@#,"AtomicMass"],
			Last@#}&,a];


ChemUtilsCoordinateBounds[
	atoms:{
		{_String,{_?NumericQ,_?NumericQ,_?NumericQ}}..
		},
	padding:_?NumericQ:0
	]:=
	Module[{
		rads=
			QuantityMagnitude/@
				UnitConvert[ChemDataLookup[First/@atoms,"Radius"],"Angstroms"],
		pos=Last/@atoms,
		moves=Tuples[{1,-1},3]
		},
		pos=
			Flatten[
				MapThread[
					With[{
						base=#*moves,
						p=#2
						},
						p+#&/@base
						]&,{
					rads+padding,
					pos
					}],
				1
				];
		CoordinateBounds@pos
		];


ChemUtilsAxisAlignmentTransform//Clear


axisPattern=
	"X"|"Y"|"Z"|{_?NumericQ,_?NumericQ,_?NumericQ};


ChemUtilsAxisAlignmentTransform[
	a:(axisPattern->axisPattern),
	b:(axisPattern->axisPattern)|None:None,
	point:axisPattern:{0,0,0}
	]:=
	With[{
		rotation1=
			Replace[a,
				(ax1_->ax2_):>
					Replace[{ax1,ax2},{
						"X"->{1,0,0},
						"Y"->{0,1,0},
						"Z"->{0,0,1}
						},
						1]
				],
		center=
			Replace[point,
				{
					"X"->{1,0,0},
					"Y"->{0,1,0},
					"Z"->{0,0,1}
					}
				]
		},
		Replace[b,{
			(ax1_->ax2_):>
				With[{
					t1=
						If[MatchQ[rotation1,{_List,_List}],
							If[MatrixRank@rotation1==2,
								RotationTransform[rotation1,center],
								Identity
								],
							Identity
							]
					},
					With[{
						t2=
							RotationTransform[
								{t1@First@#,Last@#}&@
									Replace[{ax1,ax2},
										{
											"X"->{1,0,0},
											"Y"->{0,1,0},
											"Z"->{0,0,1}
											},
										1],
								center
								]
						},
						If[t1===Identity,
							t2,
							Simplify@Composition[t2,t1]
							]
						]
					],
			_->
				Replace[rotation1,
					{u_,v_}:>
						Which[
							MatrixRank@{u,v}==2,
								RotationTransform[{u,v},center],
							u==-v,
								(*
							Need a better way to handle this. 
							Should maybe be some form of inversion? 
							*)
								RotationTransform[{u,v},center],
							True,
								None
							]
					]
			}]
	]


ChemUtilsAlignmentTransform//Clear


pt="X"|"Y"|"Z"|{_?NumericQ,_?NumericQ,_?NumericQ};


ChemUtilsAlignmentTransform[
	a:{Repeated[pt,3]}->
		b:{Repeated[pt,3]}
	]:=
	With[{
		pos=Replace[Join[a,b],{"X"->{1,0,0},"Y"->{0,1,0},"Z"->{0,0,1}},1]
		},
		Simplify@
			Composition[
				ChemUtilsAxisAlignmentTransform[
					pos[[1]]-pos[[2]]->pos[[4]]-pos[[5]],
					pos[[1]]-pos[[3]]->pos[[4]]-pos[[6]],
					pos[[4]]
					],
				TranslationTransform[pos[[4]]-pos[[1]]]
				]
		];
ChemUtilsAlignmentTransform[
	a:{{_?StringQ|_?NumericQ,{_?NumericQ,_?NumericQ,_?NumericQ}},___}->
		b:{{_?StringQ|_?NumericQ,{_?NumericQ,_?NumericQ,_?NumericQ}},___}
	]:=
	With[{
		sys1=
			ChemUtilsInertialSystem[a],
		com1=
			ChemUtilsCenterOfMass[a],
		sys2=
			ChemUtilsInertialSystem[b],
		com2=
			ChemUtilsCenterOfMass[b]
		},
		ChemUtilsAlignmentTransform[
			{com1,com1+sys1["AAxis"],com2+sys1["BAxis"]}->
				{com2,com2+sys2["AAxis"],com2+sys2["BAxis"]}
			]
		];


ChemUtilsIsotopologues[atoms_List,
	abundanceMin_:.0000000001
	]:=
	With[{
		reps=
			Replace[atoms,
				{
					{el_?(Not@*ChemDataIsotopeQ),p_}:>
						Map[{el,p}->{Last@#,p}&,
							Pick[#,
								#>=abundanceMin&/@
									ChemDataLookup[#,"IsotopeAbundance",IsotopeData]
								]&@ChemDataLookup[el,None,IsotopeData]
							],
					_->Nothing
					},
				1]
		},
		Reverse@Sort@Select[
			AssociationMap[
				Times@@Map[ChemDataLookup[First@#,"IsotopeAbundance",IsotopeData]&,#]&,
				Map[atoms/.#&,Tuples@reps]
				],
			#>abundanceMin&
			]
		];


ChemUtilsBondMatrix[list_]:=
	With[{atoms=#[[;;2]]&/@list},
		Table[
			If[i==j,
				0,
				FirstCase[list,{i_,j_,v_}:>v,0]
				],
			{i,Max@atoms},{j,Max@atoms}
			]
		];


ChemUtilsBondList[mx_]:=
	Replace[
		Select[
			Position[mx,_?(#>0&)],
				First@#<Last@#&
				],
		{i_,j_}:>{i,j,mx[[i,j]]},
		1];


guessBondsAdjustRowUp[i_,mx_,inRange_,valences_]:=
Block[{
		bondingMatrix=mx,
		valenceTotals=Total/@mx
		},
		Do[
			If[inRange[[i,j]],
				If[
					AnyTrue[
						Replace[valences[[i]],v_Integer:>{v}],
						valenceTotals[[i]]<#&]
						&&
					AnyTrue[
						Replace[valences[[j]],v_Integer:>{v}],
						valenceTotals[[j]]<#&],
					If[mx[[i,j]]<3,
						bondingMatrix[[i,j]]=bondingMatrix[[j,i]]=
							mx[[i,j]]+1;
						valenceTotals[[j]]++;
						valenceTotals[[i]]++;
						]
					]
				],
			{j,
				Reverse@
					SortBy[
						Range[Length@mx],
						Replace[valences[[i]],{v_,_}:>v,1]
						]}
			];
		bondingMatrix
		];


guessBondsAdjustRowDown[i_,mx_,inRange_,valences_]:=
	Block[{
		bondingMatrix=mx,
		valenceTotal=Total@mx[[i]],
		valence=valences[[i]]
		},
		Do[
			If[
				mx[[i,j]]>0&&
				AnyTrue[
					Replace[valences[[j]],v_Integer:>{v}],
					valenceTotal+mx[[i,j]]>#&],
				With[{diff=valenceTotal+mx[[i,j]]-valence},
					valenceTotal-=diff;
					bondingMatrix[[i,j]]=bondingMatrix[[j,i]]=
						mx[[i,j]]-diff
					]
				],
			{j,
				SortBy[
					Range[Length@mx],
					Replace[valences[[i]],{v_,_}:>v,1]
					]}
			];
		bondingMatrix
		];


guessBondsAdjustBondingMatrix[mx_,inRange_,valences_,order_]:=
	Block[{bondingMatrix=mx},
		Do[
			With[{
				vt=Total@mx[[i]],
				vals=Replace[valences[[i]],v_Integer:>{v}]},
				Which[
					AnyTrue[vals,vt==#&],
						Null,
					vt>First@Nearest[vals,vt],
						bondingMatrix=
							guessBondsAdjustRowDown[i,bondingMatrix,inRange,valences],
					vt<First@Nearest[vals,vt],
						bondingMatrix=
							guessBondsAdjustRowUp[i,bondingMatrix,inRange,valences]
					]
				],
			{i,
				Replace[order,{
					True->
						Range[Length@mx,1,-1],
					False->
						Length@mx
					}]}
			];
		bondingMatrix
		];


guessBondsCheckBondingMatrix[mx_,inRange_,valences_,goal_]:=
	MapThread[
		If[MatchQ[#2,_Integer],
			Total@#==#2,
			MemberQ[#2,Total@#]
			]&,
		{mx,valences}];


guessBondsDetermineBondsStep[mx_,
	inRange_,valences_,goal_,order_]:=
	With[{bm=guessBondsAdjustBondingMatrix[mx,inRange,valences,order]},
		If[Not@*And@@guessBondsCheckBondingMatrix[bm,inRange,valences,goal],
			Block[{
				bondingMatrix=bm,
				vs=
					guessBondsCheckBondingMatrix[bm,inRange,valences,goal]
				},
				If[mx==bm,
					Do[
						If[!vs[[i]],
							Replace[Flatten@Position[inRange[[i]],True],
								c:{__}:>
								Replace[
									DeleteDuplicates@
										Map[Sort]@
											Apply[Join]@
												Map[
													Thread[{#,
														DeleteCases[
															Flatten@Position[inRange[[#]],True],
															i]
														}]&,
													c
													],
									p:{__}:>
										With[{pair=RandomChoice@p},
											bondingMatrix[[Sequence@@pair]]=
												bondingMatrix[[Sequence@@Reverse@pair]]=0
											]
										]
								]
							],
						{i,Length@vs}
						];
					];
				"Continue"->{
					bondingMatrix,
					vs
					}
				],
			"Final"->bm
			]
		];


guessBonds[atoms_,tol_,iters_,multiValent_,goal_,log_]:=
	With[{
		inRange=
			Table[
				i!=j&&
				Norm[Subtract@@(Last@atoms[[#]]&/@{i,j})]<=
					With[{d=
						ChemDataLookup[
							{First@atoms[[i]],First@atoms[[j]],1},
							"BondDistances"]},
						d+Replace[tol,Scaled[p_]:>d*p]
						],
				{i,Length@atoms},
				{j,Length@atoms}
				],
		valences=
			With[{v=First@ChemDataLookup[First@#,"ElementValences"]},
				Replace[multiValent,{
					r:{(_Rule|_RuleDelayed)..}|_Association:>
						Prepend[
							Lookup[multiValent,First@#,{}],
							v],
					_->v
					}]
				]&/@atoms
		},
		If[log,
			Map[
				Replace[{
					("Continue"->{m_,___}):>m,
					("Final"->m_):>m
					}]
				]@*
				Map[
					Replace[{f___,l:("Final"->_),___}:>{f,l}]
					],
			Replace[{
				("Continue"->{m_,___}):>m,
				("Final"->m_):>m
				}]
			]@
			If[log,NestList,Nest][
				Replace[{
					("Continue"->{m1_,vs_}):>
						guessBondsDetermineBondsStep[
							m1,inRange,valences,goal,
							SortBy[Range[Length@m1],
								Switch[vs[[#]],True,1,False,0]&
								]
							],
					("Final"->m_):>
						("Final"->m),
					m_:>
						guessBondsDetermineBondsStep[m,inRange,valences,goal,False]
					}],
				ReplaceAll[inRange,{True->1,False->0}],
				iters
				]	
		];


Options[ChemUtilsGuessBonds]={
	MaxIterations->10,
	Tolerance->.075,
	"Charge"->0,
	"PriorityFunction"->(Switch[First@#,"H",0,"C",1,_,2]&),
	"LogSteps"->False,
	"MultiValences"->None,
	"MakeBondLists"->True
	};
ChemUtilsGuessBonds[
	sourceAtoms:{{_String,{__?NumericQ}}..},
	ops:OptionsPattern[]]:=
	With[{
		atoms=SortBy[sourceAtoms,OptionValue@"PriorityFunction"],
		tol=OptionValue@Tolerance,
		iters=OptionValue@MaxIterations,
		goal=
			Replace[OptionValue@"Charge",{
				r_Real:>Ceiling@r,
				Except[_Integer]->1
				}],
		log=TrueQ@OptionValue@"LogSteps",
		multi=
			Replace[OptionValue@"MultiValences",{
				Automatic:>
					Map[ChemDataLookup[First@#,"ElementValences"]&,
						sourceAtoms
						]
				}],
		makeLists=OptionValue@"MakeBondLists"
		},
		If[log,
			<|
				"Atoms"->atoms,
				"Bonds"->
					If[makeLists===False,
						#,
						ChemUtilsBondList@#
						]
				|>&/@
					guessBonds[atoms,tol,iters,multi,goal,log],
			<|
				"Atoms"->atoms,
				"Bonds"->
					If[makeLists===False,
						guessBonds[atoms,tol,iters,multi,goal,log],
						ChemUtilsBondList@
							guessBonds[atoms,tol,iters,multi,goal,log]
						]
				|>
			]
		]


symmetricPointQ[p_,{el_,opos_},atoms_,tol_]:=
	AnyTrue[Cases[atoms,{el,_}],
		Between[#[[2,1]],p[[1]]+{-tol,tol}]&&
		Between[#[[2,2]],p[[2]]+{-tol,tol}]&&
		Between[#[[2,3]],p[[3]]+{-tol,tol}]
		&]


symmetryOperationQ[transform_,atoms_,tol_]:=
	AllTrue[atoms,
		Replace[transform@Last@#,
			{
				p_List:>symmetricPointQ[p,#,atoms,tol],
				_->False
				}]&
		]


inversionTransform[point_]:=
	AffineTransform@{ScalingMatrix[{-1,-1,-1}],2*point}


ChemUtilsInversionCenterQ[point_,
	atoms_,tol:_?NumericQ:0]:=
	symmetryOperationQ[(2*point-#)&,atoms,tol];


$uniquenessTolerance=.005;


uniqueAxesQ[center_,p_,q_]:=
	With[{n1=Normalize[p-center],n2=Normalize[q-center]},
		Norm[n1-n2]>$uniquenessTolerance&&
			Norm[n1+n2]>$uniquenessTolerance
		];
uniqeAxesQ[center_][p_,q_]:=
	uniqueAxesQ[center,p,q];


rotationTransform[order_,{point1_,point2_}]:=
	RotationTransform[2.\[Pi]/order,point2-point1,point1];
rotationTransform[{point1_,point2_}][order_]:=
	rotationTransform[order,{point1,point2}];


ChemUtilsRotationAxisOrder[{point1_,point2_},
	atoms_,tol:_?NumericQ:0]:=
	If[ChemUtilsRotorType@atoms==="Linear",
		If[
			uniqueAxesQ[point1,atoms[[1,2]],point2]||
				uniqueAxesQ[point1,atoms[[-1,2]],point2],
			1,
			\[Infinity]
			],
		With[{
			es=Last@Sort@Counts@Map[First,atoms]
			},
			FirstCase[Range[es,2,-1],
				_?(symmetryOperationQ[rotationTransform[#,{point1,point2}],atoms,tol]&),
				1]
			]
		];


reflectionTransform[{point1_,point2_,point3_}]:=
	With[{norm=Normalize@Cross[point2-point1,point3-point1]},
		ReflectionTransform[norm,point1]
		];


ChemUtilsPlaneOfSymmetryQ[{point1_,point2_,point3_},
	atoms_,tol:_?NumericQ:0]:=
	symmetryOperationQ[reflectionTransform@{point1,point2,point3},atoms,tol]


upQ=
	Compile[{
		{center,_Real,1},
		{p,_Real,2},
		{q,_Real,2}
		},
		With[{
			n1=Normalize@Cross[p[[1]]-center,p[[2]]-center],
			n2=Normalize@Cross[q[[1]]-center,q[[2]]-center]
			},
			Norm[n1-n2]>$uniquenessTolerance&&
			Norm[n1+n2]>$uniquenessTolerance
			]
		];


uniquePlanesQ[center_,p:{_,_},q:{_,_}]:=
	upQ[center,p,q]
uniquePlanesQ[center_][p_,q_]:=
	uniquePlanesQ[center,p,q]


perpendicularAxisQ[center_,p_,{q1_,q2_}]:=
	Not@uniqueAxesQ[center,p,Cross[q1-center,q2-center]];
perpendicularAxisQ[center_,p_][q_]:=
	perpendicularAxisQ[center,p,q];


rotOrderCount[order_,axes_]:=
	Length@Select[axes,Mod[First@#,order]==0&];
rotOrderCount[order_][axes_]:=
	rotOrderCount[order,axes];


anyPerpPlane[center_,axes_,planes_]:=
	AnyTrue[planes,
		With[{plane=#},
			AnyTrue[axes,perpendicularAxisQ[center,#,plane]&]
			]&
		];
anyPerpPlane[center_,axes_][planes_]:=
	anyPerpPlane[center,axes,planes];


screwTransform[order_,{center_,axisPoint_}]:=
	Composition[
		rotationTransform[order,{center,axisPoint}],
		ReflectionTransform[axisPoint-center,center]
		]//Simplify;
screwTransform[{center_,axisPoint_}][order_]:=
	screwTransform[order,{center,axisPoint}]


ChemUtilsScrewAxisOrder[{center_,axisPoint_},
	atoms_,tol:_?NumericQ:0]:=
	With[{
			es=Last@Sort@Counts@Map[First,atoms]
			},
			FirstCase[Range[es,3,-1],
				_?(symmetryOperationQ[screwTransform[#,{center,axisPoint}],atoms,tol]&),
				0]
			]


ChemUtilsIdentifyPointGroup[
	center:{_?NumericQ,_?NumericQ,_?NumericQ},
	centerOfSymmetry:True|False:False,
	rotationAxesS:{{_Integer|\[Infinity],_List}...},
	symmetryPlanesS:{{_List,_List}...}:{},
	screwAxesS:{{_Integer|\[Infinity],_List}...}:{}]:=
	With[{
		rotationAxes=
			DeleteDuplicates[rotationAxesS,
				Not@uniqueAxesQ[center,Last@#,Last@#2]
				&],
		symmetryPlanes=
			DeleteDuplicates[symmetryPlanesS,
				Not@*uniquePlanesQ[center]
				],
		screwAxes=
			DeleteDuplicates[screwAxesS,
				Not@uniqueAxesQ[center,Last@#,Last@#2]
				&]
		},
	If[AnyTrue[First/@rotationAxes,#==\[Infinity]&],
		(*Linear*)
		If[centerOfSymmetry,
			(*Inversion center*)
			"D\[Infinity]h",
			(*No inversion center*)
			"C\[Infinity]v"
			],
		(*Non-linear*)
		If[rotOrderCount[3,rotationAxes]>1,
			(*2+ unique C3 axes*)
			If[rotOrderCount[5,rotationAxes]>1,
				(*2+ unique C5 axes*)
				If[centerOfSymmetry,
					(*Inversion center*)
					"Ih",
					(*No inversion center*)
					"I"],
				(* <2 unique C5 axes*)
				If[rotOrderCount[4,rotationAxes]>1,
					(*2+ unique C4 axes*)
					If[centerOfSymmetry,
						(*Inversion center*)
						"Oh",
						(*No inversion center*)
						"O"],
					(* <2 unique C4 axes*)
					If[Length@symmetryPlanes>0,
						(*Has symmetry planes*)
						If[centerOfSymmetry,
							(*Inversion center*)
							"Th",
							(*No inversion center*)
							"Td"],
						(*No symmetry planes*)
						"T"
						]
					]
				],
			(* <2 unique C3 axes*)
			If[Length@rotationAxes>0,
				(*Any rotation axes*)
				With[{mAxes=MaximalBy[rotationAxes,First]},
				With[{n=First@First@mAxes,axes=Last/@mAxes},
				If[Length@Cases[rotationAxes,{2,_}]>=n,
					(*N distinct C2 axes*)
					If[anyPerpPlane[center,axes,symmetryPlanes],
						(*Horizontal reflection plane*)
						"D"<>ToString@n<>"h",
						If[Length@symmetryPlanes>=n,
							(*N+ planes of symmetry*)
							"D"<>ToString@n<>"d",
							(* <N planes of symmetry *)
							"D"<>ToString@n
							]
						],
					(* <N distinct C2 axes*)
					If[anyPerpPlane[center,axes,symmetryPlanes],
						(*Horizontal reflection plane*)
						"C"<>ToString@n<>"h",
						If[Length@symmetryPlanes>=n,
							(*N+ planes of symmetry*)
							"C"<>ToString@n<>"v",
							If[Length@Cases[screwAxes,{2*n,_}]>0,
								(*2N screw axis*)
								"S"<>ToString[2*n],
								"C"<>ToString@n
								]
							]
						]
					]
					]
					],
				(*No rotation axes*)
				If[Length@symmetryPlanes>0,
					"Cs",
					If[centerOfSymmetry,
						"Ci",
						"C1"
						]
					]
				]
			]
		]
	]


ChemUtilsInertialSymmetry[c_,axes_,atoms_,tol:_?NumericQ:.05]:=
	<|
		"CenterSymmetric"->ChemUtilsInversionCenterQ[c,atoms,tol],
		"ARotationOrder"->ChemUtilsRotationAxisOrder[{c,c+axes[[1]]},atoms,tol],
		"BRotationOrder"->ChemUtilsRotationAxisOrder[{c,c+axes[[2]]},atoms,tol],
		"CRotationOrder"->ChemUtilsRotationAxisOrder[{c,c+axes[[3]]},atoms,tol],
		"ABSymmetric"->ChemUtilsPlaneOfSymmetryQ[{c,c+axes[[1]],c+axes[[2]]},atoms,tol],
		"ACSymmetric"->ChemUtilsPlaneOfSymmetryQ[{c,c+axes[[1]],c+axes[[3]]},atoms,tol],
		"BCSymmetric"->ChemUtilsPlaneOfSymmetryQ[{c,c+axes[[2]],c+axes[[3]]},atoms,tol],
		"AScrewOrder"->
			ChemUtilsScrewAxisOrder[{c,c+axes[[1]]},atoms,tol],
		"BScrewOrder"->
			ChemUtilsScrewAxisOrder[{c,c+axes[[2]]},atoms,tol],
		"CScrewOrder"->
			ChemUtilsScrewAxisOrder[{c,c+axes[[3]]},atoms,tol]
		|>;
ChemUtilsInertialSymmetry[atoms_,tol:_?NumericQ:.05]:=
	With[{
		c=ChemUtilsCenterOfMass@atoms,
		axes=Lookup[ChemUtilsInertialSystem@atoms,{"AAxis","BAxis","CAxis"}]
		},
		ChemUtilsInertialSymmetry[c,axes,atoms,tol]
		];


enumeratePositions[center_,positions_]:=
	DeleteDuplicates@DeleteCases[Join[positions,Mean/@Tuples[positions,2]],center]


enumeratePlanesSimple[center_,positions_]:=
	Select[
		DeleteDuplicates[Sort/@
			Tuples[positions,2]
			],
		Apply@uniqeAxesQ[center]
		]


enumerateAxes[center_,positions_]:=
	DeleteDuplicates@
		Join[enumeratePositions[center,positions],
			Map[center+Cross[#[[1]]-center,#[[2]]-center]&,
				enumeratePlanesSimple[center,positions]
				]
			]


enumeratePlanes[center_,positions_]:=
	enumeratePlanesSimple[center,enumerateAxes[center,positions]]


enumerateRotationAxes[center_,atoms_,tol_]:=
	With[{positions=Map[Last,atoms]},
		With[{possibleAxes=
			DeleteDuplicates[
				enumerateAxes[center,positions],
				Not@*uniqeAxesQ[center]
				]},
			DeleteCases[
				Map[
					{ChemUtilsRotationAxisOrder[{center,#},atoms,tol],#}&,
					possibleAxes
					],
				{1,_}
				]
			]
		];


enumerateSymmetryPlanes[center_,atoms_,tol_]:=
	With[{positions=Map[Last,atoms]},
		With[{possiblePlanes=
			DeleteDuplicates[
				enumeratePlanes[center,positions],
				Not@*uniquePlanesQ[center]
				]
				},
			Select[possiblePlanes,
				ChemUtilsPlaneOfSymmetryQ[Prepend[#,center],atoms,tol]&
				]
			]
		];


enumerateScrewAxes[center_,atoms_,tol_]:=
	With[{positions=Map[Last,atoms]},
		With[{possibleAxes=
			DeleteDuplicates[
				enumerateAxes[center,positions],
				Not@*uniqeAxesQ[center]
				]},
			DeleteCases[
				Map[
					{ChemUtilsScrewAxisOrder[{center,#},atoms,tol],#}&,
					possibleAxes
					],
				{0,_}
				]
			]
		];


ChemUtilsSymmetryElements[atoms_,tol:_?NumericQ:.05]:=
	With[{
		center=ChemUtilsCenter@atoms,
		axes=Last@ChemUtilsInertialEigensystem@atoms},
		<|
			"Center"->center,
			"CenterSymmetric"->ChemUtilsInversionCenterQ[center,atoms,tol],
			"RotationAxes"->
				DeleteDuplicates[
					Join[
						enumerateRotationAxes[center,atoms,tol],
						DeleteCases[
							{ChemUtilsRotationAxisOrder[{center,#},atoms,tol],#}&/@axes,
							{1,_}
							];{}
						],
					Not@*uniqueAxesQ[center][Last@#,Last@#2]&
					],
			"SymmetryPlanes"->
				DeleteDuplicates[
					Join[
						enumerateSymmetryPlanes[center,atoms,tol],
						Select[
							DeleteDuplicatesBy[Tuples[axes,2],Sort],
							Not@*Equal@@#&&
								ChemUtilsPlaneOfSymmetryQ[Prepend[#,center],atoms,tol]&
							]
						],
					Not@*uniquePlanesQ[center]
					],
			"ScrewAxes"->
				DeleteDuplicates[
					Join[
						enumerateScrewAxes[center,atoms,tol],
						DeleteCases[
							{ChemUtilsScrewAxisOrder[{center,#},atoms,tol],#}&/@axes,
							{0,_}
							]
						],
					Not@*uniqueAxesQ[center][Last@#,Last@#2]&
					]
			|>
		];


ChemUtilsPointGroup[atoms_,tol:_?NumericQ:.05]:=
	ChemUtilsIdentifyPointGroup@@ChemUtilsSymmetryElements[atoms,tol];


ChemUtilsSymmetryGraphicsObjects[
	symm_Association,
	boxSize_?NumericQ
	]:=
	With[{m=boxSize,M=boxSize+.15},
		<|
			"InversionCenter"->
				If[symm["CenterSymmetric"],
					{Red,AbsolutePointSize@10,Point@symm["Center"]},
					{}
					],
			"RotationAxes"->
				{
					AbsoluteThickness[1],
					Map[
						With[{v=Normalize[Last@#-symm["Center"]]},
							Line@{symm["Center"]+v*M,symm["Center"]-v*M}
							]&,
						symm["RotationAxes"]
						]
					},
			"SymmetryPlanes"->
				Map[
					With[{n=Cross[symm["Center"]-First@#,symm["Center"]-Last@#],N=48},
						{
							Opacity[.25],
							Polygon@
								NestList[
									RotationTransform[2.\[Pi]/N,n,symm["Center"]],
									symm["Center"]+m*Normalize[symm["Center"]-First@#],
									N]
							}
						]&,
					symm["SymmetryPlanes"]
					],
			"ScrewAxes"->
				{
					Red,
					AbsoluteThickness[2],
					Dashed,
					Map[
						With[{v=Normalize[Last@#-symm["Center"]]},
							Line@{symm["Center"]+v*M,symm["Center"]-v*M}
							]&,
						symm["ScrewAxes"]	
						]
					}
			|>
		]


ChemUtilsSymmetryGraphicsObjects[
	atoms_?(Length[#]>=3&)
	]:=
	With[{
		symm=ChemUtilsSymmetryElements@atoms,
		m=.5+Max@
				Map[Abs,
					Thread@CoordinateBoundingBox[Last/@atoms]
					]},
		ChemUtilsSymmetryGraphicsObjects[symm,m]
		]


Options[ChemUtilsSymmetryGraphics]=
	Options[Graphics3D];
ChemUtilsSymmetryGraphics[
	symm_Association,
	boxSize_?NumericQ,
	types:
		"InversionCenter"|"RotationAxes"|"SymmetryPlanes"|"ScrewAxes"|
			{("InversionCenter"|"RotationAxes"|"SymmetryPlanes"|"ScrewAxes")..}:
		{"InversionCenter","RotationAxes","SymmetryPlanes","ScrewAxes"},
	ops:OptionsPattern[]
	]:=
	Graphics3D[
		Lookup[
			ChemUtilsSymmetryGraphicsObjects[symm,boxSize],
			types
			],
		ops
		];
ChemUtilsSymmetryGraphics[atoms_?(Length[#]>=3&),
	ops:OptionsPattern[]
	]:=
	With[{
		symm=ChemUtilsSymmetryElements@atoms,
		m=.5+Max@
				Map[Abs,
					Thread@CoordinateBoundingBox[Last/@atoms]
					]},
		ChemUtilsSymmetryGraphics[symm,m,ops]
		]
	


ChemUtilsArrangeMoleculeLayout//Clear;
ChemUtilsArrangeMoleculeSanityCheck//Clear;


(*ChemUtilsArrangeMoleculeSanityCheck[
	atomEdges_,
	"Tetrahedral"
	]:=
	Length[VertexList[atomEdges]]\[Equal]5&&*)


(*ChemUtilsArrangeMoleculeLayout[
	atomEdges_,
	"Tetrahedral"
	]:=Null;*)


ChemUtilsArrangeMoleculeSanityCheck[_List,_]:=
	True;
ChemUtilsArrangeMoleculeSanityCheck[_,_]:=
	False


ChemUtilsArrangeMoleculeLayout[
	_,
	mode_
	]:=
	With[{r=Message[ChemUtilsArrangeMolecule::nomo,mode]},
		r/;False
		];


ChemUtilsArrangeMoleculePrepEdges[e_]:=
	e/.(TwoWayRule|DirectedEdge|Rule)->UndirectedEdge


ChemUtilsArrangeMolecule::invat=
	"Invalid atom bonding layout `` for mode ``";
ChemUtilsArrangeMolecule::nomo=
	"Unknown mode `` for mode ``";
ChemUtilsArrangeMolecule[
	atomEdgesRaw_,
	modeRaw_
	]:=
	With[{
		atomEdges=ChemUtilsArrangeMoleculePrepEdges[atomEdgesRaw],
		mode=ChemUtilsArrangeMoleculePrepMode[modeRaw]
		},
		If[ChemUtilsArrangeMoleculeSanityCheck[atomEdges,mode],
			ChemUtilsArrangeMoleculeLayout[atomEdges,mode],
			Message[ChemUtilsArrangeMolecule::invat,atomEdges,mode],
			$Failed
			]
		]


End[];



