(* ::Package:: *)

$packageHeader

CreateGeometricAtomset::usage=
	"Makes a new atomset with specified geometry";


Begin["`Private`"];


$CreateGeometricAtomsetGeometries=
	<|
		"Linear"->
			CreateLinearAtomset,
		"Bent"->
			CreateBentAtomset,
		"Square"->
			CreateSquareAtomset,
		"CisSquare"->
			CreateCisSquareAtomset,
		"TransSquare"->
			CreateTransSquareAtomset,
		"Diamond"->
			CreateDiamondAtomset,
		"CisDiamond"->
			CreateCisDiamondAtomset,
		"TransDiamond"->
			CreateTransDiamondAtomset,
		"Hexagonal"->
			CreateHexagonalAtomset,
		"TrigonalPlanar"->
			CreateTrigonalPlanarAtomset,
		"TrigonalPyrimidal"->
			CreateTrigonalPyrimidalAtomset,
		"Tetrahedral"->
			CreateTetrahedralAtomset,
		"CisTrigonalBipyramidal"->
			CreateCisTrigonalBipyramidalAtomset,
		"TransTrigonalBipyramidal"->
			CreateTransTrigonalBipyramidalAtomset,
		"TrigonalBipyramidal"->
			CreateTrigonalBipyramidalAtomset,
		"SquarePlanar"->
			CreateSquarePlanarAtomset,
		"CisSquarePlanar"->
			CreateCisSquarePlanarAtomset,
		"TransSquarePlanar"->
			CreateTransSquarePlanarAtomset,
		"SquarePyrimidal"->
			CreateSquarePyrimidalAtomset,
		"Octahedral"->
			CreateOctahedralAtomset,
		"FacialOctahedral"->
			CreateFacialOctahedralAtomset,
		"MeridionalOctahedral"->
			CreateMeridionalOctahedralAtomset,
		"Coordinates"->
			CreateCoordinatesAtomset
		|>;


CreateGeometricAtomset//Clear


CreateGeometricAtomset[
	geom_String,
	check:True|False:False,
	args___
	]:=
	With[{f=$CreateGeometricAtomsetGeometries[geom]},
		With[{res=
			If[MissingQ@f,
				With[{
					coords=
						Replace[PolyhedronData[geom, "Vertices"],
							f_Function:>f[1,1,1],
							1
							]},
					If[ListQ@coords,
						CreateCoordinatesAtomset[check,
							coords,
							args,
							PolyhedronData[geom, "Edges"]
							]
						]
					],
				$CreateGeometricAtomsetGeometries[geom][check,args]
				]
			},
		res/;ChemObjectQ@res
		]
	];


PackageAddAutocompletions[CreateGeometricAtomset,
	{Keys@$CreateGeometricAtomsetGeometries}
	]


CreateCoordinatesAtomset[
	check:True|False:True,
	coords:{{_,_,_}..},
	els:{Repeated[_String|{_String,___}|ChemSinglePattern]},
	bonds:{{_,_,___}...}:{}
	]/;Length[coords]===Length[els]:=
	Module[{
		ats=
			CreateAtom@
				MapThread[List,
					{
						els,
						coords
						}
					],
		atomset
		},
		Do[
			AtomCreateBond[
				ats[[b[[1]]]],
				ats[[b[[2]]]],
				b[[3]],
				check
				],
			{b, PadRight[#,3,1]&/@bonds}
			];
		atomset=CreateAtomset[ats];
		AtomsetNormalizeBonds[atomset];
		atomset
		]


CreateLinearAtomset[
	check:True|False:False,
	elements:{Repeated[_String|{_String,___}|ChemSinglePattern,{2,\[Infinity]}]}
	]:=
	Module[
		{
			atoms=
				CreateAtom@
					MapIndexed[
						{#,{#2[[1]]-1, 0, 0}}&, 
						elements
						],
			atomset
			},
		Do[
			AtomCreateBond[atoms[[n]], atoms[[n+1]], 1, check],
			{n, Length[atoms]-1}
			];
		atomset=CreateAtomset[atoms];
		AtomsetNormalizeBonds[atomset];
		atomset
		]


CreateSquareAtomset[
	check:True|False:False,
	els1:{Repeated[_String|{_String,___}|ChemSinglePattern,{4}]}
	]:=
	Module[
		{
			atoms=
				{
					CreateAtom@
						MapThread[List,
							{
								els1[[;;2]],
								{
									1/Sqrt[2.] { 1, 1, 0},
									1/Sqrt[2.] {-1, -1, 0}
									}
								}
							],
					CreateAtom@
						MapThread[List,
							{
								els1[[3;;]],
								{
									1/Sqrt[2.] {-1, 1, 0},
									1/Sqrt[2.] {1,-1, 0}
									}
								}
							]
					},
			oldBonds,
			atomset
			},
			Do[AtomCreateBond[a, b, 1, check], {a, atoms[[1]]}, {b, atoms[[2]]}];
			atomset=CreateAtomset[Join@@atoms];
			AtomsetNormalizeBonds[atomset];
			atomset
		]


CreateCisSquareAtomset[
	check:True|False:False,
	els1:
		{
		{Repeated[_String|{_String,___}|ChemSinglePattern,{2}]},
		{Repeated[_String|{_String,___}|ChemSinglePattern,{2}]}
		}
	]:=
	CreateSquareAtomset[
		check,
		RotateRight@Flatten[els1]
		]


CreateTransSquareAtomset[
	check:True|False:False,
	els1:
		{
		{Repeated[_String|{_String,___}|ChemSinglePattern,{2}]},
		{Repeated[_String|{_String,___}|ChemSinglePattern,{2}]}
		}
	]:=
	CreateSquareAtomset[
		check,
		Flatten[els1]
		]


CreateDiamondAtomset[
	check:True|False:False,
	els1:{Repeated[_String|{_String,___}|ChemSinglePattern,{4}]}
	]:=
	Module[
		{
			atoms=
				{
					CreateAtom@
						MapThread[List,
							{
								els1[[;;2]],
								{
									{ 1, 0, 0},
									{-1, 0, 0}
									}
								}
							],
					CreateAtom@
						MapThread[List,
							{
								els1[[3;;]],
								{
									{0, 1, 0},
									{0,-1, 0}
									}
								}
							]
					},
			oldBonds,
			atomset
			},
			Do[AtomCreateBond[a, b, 1, check], {a, atoms[[1]]}, {b, atoms[[2]]}];
			atomset=CreateAtomset[Join@@atoms];
			AtomsetNormalizeBonds[atomset];
			atomset
		]


CreateCisDiamondAtomset[
	check:True|False:False,
	els1:
		{
		{Repeated[_String|{_String,___}|ChemSinglePattern,{2}]},
		{Repeated[_String|{_String,___}|ChemSinglePattern,{2}]}
		}
	]:=
	CreateDiamondAtomset[
		check,
		RotateRight@Flatten[els1]
		]


CreateTransDiamondAtomset[
	check:True|False:False,
	els1:
		{
		{Repeated[_String|{_String,___}|ChemSinglePattern,{2}]},
		{Repeated[_String|{_String,___}|ChemSinglePattern,{2}]}
		}
	]:=
	CreateDiamondAtomset[
		check,
		Flatten[els1]
		]


CreateHexagonalAtomset[
	check:True|False:False,
	els1:{Repeated[_String|{_String,___}|ChemSinglePattern,{6}]}
	]:=
	Module[
		{
			atoms=
				CreateAtom@
					MapThread[List,
						{
							els1,
							Append[0]/@
								CirclePoints[6]//N
							}
						],
			oldBonds,
			atomset
			},
			Do[
				AtomCreateBond[
					atoms[[n]], 
					atoms[[Mod[n+1, Length@atoms, 1]]],
					1, 
					check
					], 
				{n, Length@atoms}
				];
			atomset=CreateAtomset[atoms];
			AtomsetNormalizeBonds[atomset];
			atomset
		]


CreateTrigonalPlanarAtomset[
	check:True|False:False,
	coreEl:_String|{_String,___}|ChemSinglePattern:"C",
	elements:{Repeated[{Repeated[_String|{_String,___}|ChemSinglePattern,{2}]}, 2]}
	]:=
	Module[
		{
			atoms=
				CreateAtom@
						MapThread[List,
							elements[[1]],
							CirclePoints[3]
							],
			core=CreateAtom[coreEl, {0, 0, 0}],
			atomset
			},
			Do[AtomCreateBond[core, b, 1, check], {b, atoms}];
			atomset=CreateAtomset[Join[{core},atoms]];
			AtomsetNormalizeBonds[atomset];
			atomset
		]


CreateTetrahedralAtomset[
	check:True|False:False,
	coreEl:_String|{_String,___}|ChemSinglePattern:"C",
	elements:{Repeated[_String|{_String,___}|ChemSinglePattern,{4}]}
	]:=
	Module[{
		core=CreateAtom[coreEl, {0,0,0}],
		others=
			CreateAtom@
				MapThread[List,
					{
						elements,
						{
							{0.`,0.`,0.6123724356957945`},
							{-0.2886751345948129`,-0.5`,-0.20412414523193154`},
							{-0.2886751345948129`,0.5`,-0.20412414523193154`},
							{0.5773502691896258`,0.`,-0.20412414523193154`}
							}
						}],
			atomset
			},
			Do[AtomCreateBond[core, a, 1, check], {a, others}];
			atomset=CreateAtomset[Join[{core},others]];
			AtomsetNormalizeBonds[atomset];
			atomset
		]


CreateTrigonalPyrimidalAtomset[
	check:True|False:False,
	coreEl:_String|{_String,___}|ChemSinglePattern:"C",
	elements:{Repeated[_String|{_String,___}|ChemSinglePattern,{4}]}
	]:=
	With[{core=ChemImport["methane"]},
		With[{
			cCore=First@AtomsetGetAtoms[core,"C"],
			hs=AtomsetGetAtoms[core,"H"],
			newCore=CreateAtom@coreEl,
			newOuter=CreateAtom/@elements,
			oldBonds=ChemGet[core["Atoms"],"Bonds"]
			},
			AtomsetSubstituteAtom[
				core,
				Prepend[cCore->newCore]@
					Thread[hs->newOuter],
				check
				];
			ChemRemove/@Flatten@{hs,cCore,oldBonds};
			AtomsetNormalizeBonds[core];
			core
			]
		]


(*CreateBentAtomset[
	check:True|False:False,
	coreEl:_String|{_String,___}|ChemSinglePattern:"C",
	elements:{Repeated[_String|{_String,___}|ChemSinglePattern,{4}]}
	]:=
	With[{core=ChemImport["methane"]},
		With[{
			cCore=First@AtomsetGetAtoms[core,"C"],
			hs=AtomsetGetAtoms[core,"H"],
			newCore=CreateAtom@coreEl,
			newOuter=CreateAtom/@elements,
			oldBonds=ChemGet[core["Atoms"],"Bonds"]
			},
			AtomsetSubstituteAtom[
				core,
				Prepend[cCore->newCore]@
					Thread[hs\[Rule]newOuter],
				check
				];
			ChemRemove/@Flatten@{hs,cCore,oldBonds};
			AtomsetNormalizeBonds[core];
			core
			]
		]*)


CreateTrigonalBipyramidalAtomset[
	check:True|False:False,
	coreEl:_String|{_String,___}|ChemSinglePattern:"C",
	elements:{Repeated[_String|{_String,___}|ChemSinglePattern,{5}]}
	]:=
	Module[{
		core=CreateAtom[coreEl, {0,0,0}],
		others=
			CreateAtom@
				MapThread[List,
					{
						elements,
						N@{
							{0,0,1},{0,0,-1},
							{Sqrt[3]/2,-(1/2),0},{0,1,0},{-(Sqrt[3]/2),-(1/2),0}
							}
						}],
			atomset
			},
			Do[AtomCreateBond[core, a, 1, check], {a, others}];
			atomset=CreateAtomset[Join[{core},others]];
			AtomsetNormalizeBonds[atomset];
			atomset
		]


CreateCisTrigonalBipyramidalAtomset[
	check:True|False:False,
	coreEl:_String|{_String,___}|ChemSinglePattern:"C",
	elements:{
		{Repeated[_String|{_String,___}|ChemSinglePattern,{2}]},
		{Repeated[_String|{_String,___}|ChemSinglePattern,{3}]}
		}
	]:=
CreateTrigonalBipyramidalAtomset[check,
	coreEl,
	RotateRight@Flatten[elements]
	]


CreateTransTrigonalBipyramidalAtomset[
	check:True|False:False,
	coreEl:_String|{_String,___}|ChemSinglePattern:"C",
	elements:{
		{Repeated[_String|{_String,___}|ChemSinglePattern,{2}]},
		{Repeated[_String|{_String,___}|ChemSinglePattern,{3}]}
		}
	]:=
CreateTrigonalBipyramidalAtomset[check,
	coreEl,
	Flatten[elements]
	]


CreateSquarePlanarAtomset[
	check:True|False:False,
	coreEl:_String|{_String,___}|ChemSinglePattern:"C",
	elements:{Repeated[_String|{_String,___}|ChemSinglePattern,{4}]}
	]:=
	Module[{
		core=CreateAtom[coreEl, {0,0,0}],
		others=
			CreateAtom@
				MapThread[List,
					{
						elements,
						{
							{1`,0.`,0},
							{-1,0,0},
							{0,1,0},
							{0,-1,0}
							}
						}],
			atomset
			},
			Do[AtomCreateBond[core, a, 1, check], {a, others}];
			atomset=CreateAtomset[Join[{core},others]];
			AtomsetNormalizeBonds[atomset];
			atomset
		]


CreateCisSquarePlanarAtomset[
	check:True|False:False,
	coreEl:_String|{_String,___}|ChemSinglePattern:"C",
	elements:{Repeated[{Repeated[_String|{_String,___}|ChemSinglePattern,{2}]}, {2}]}
	]:=
	CreateSquarePlanarAtomset[check, coreEl,
		RotateRight@Flatten[elements]
		]


CreateTransSquarePlanarAtomset[
	check:True|False:False,
	coreEl:_String|{_String,___}|ChemSinglePattern:"C",
	elements:{Repeated[{Repeated[_String|{_String,___}|ChemSinglePattern,{2}]}, {2}]}
	]:=
	CreateSquarePlanarAtomset[check, coreEl, Flatten[elements]];


CreateSquarePyramidalAtomset[
	check:True|False:False,
	coreEl:_String|{_String,___}|ChemSinglePattern:"S",
	elements:{Repeated[_String|{_String,___}|ChemSinglePattern,{5}]}
	]:=
	Module[{
		core=CreateAtom[coreEl, {0,0,0}],
		others=
			CreateAtom@
				MapThread[List,
					{
						elements,
						{
							{0.`,0.`,1.},
							{-1., 0.`,0.`},{0.`,1.,0.`},
							{0.`,-1., 0.`},{1.,0.`,0.`}
							}
						}],
			atomset
			},
			Do[AtomCreateBond[core, a, 1, check], {a, others}];
			atomset=CreateAtomset[Join[{core},others]];
			AtomsetNormalizeBonds[atomset];
			atomset
		]


CreateOctahedralAtomset[
	check:True|False:False,
	coreEl:_String|{_String,___}|ChemSinglePattern:"S",
	elements:{Repeated[_String|{_String,___}|ChemSinglePattern,{6}]}
	]:=
	Module[{
		core=CreateAtom[coreEl, {0,0,0}],
		others=
			CreateAtom@
				MapThread[List,
					{
						elements,
						{
							{0.`,0.`,-1.},{0.`,0.`,1.},
							{-1., 0.`,0.`},{0.`,1.,0.`},
							{0.`,-1., 0.`},{1.,0.`,0.`}
							}
						}],
			atomset
			},
			Do[AtomCreateBond[core, a, 1, check], {a, others}];
			atomset=CreateAtomset[Join[{core},others]];
			AtomsetNormalizeBonds[atomset];
			atomset
		]


CreateFacialOctahedralAtomset[
	check:True|False:False,
	coreEl:_String|{_String,___}|ChemSinglePattern:"S",
	faces:{
		{Repeated[_String|{_String,___}|ChemSinglePattern,{3}]},
		{Repeated[_String|{_String,___}|ChemSinglePattern,{3}]}
		}
	]:=
	CreateOctahedralAtomset[
		check,
		coreEl,
		RotateRight@Flatten[faces]
		]


CreateMeridionalOctahedralAtomset[
	check:True|False:False,
	coreEl:_String|{_String,___}|ChemSinglePattern:"S",
	faces:{
		{Repeated[_String|{_String,___}|ChemSinglePattern,{3}]},
		{Repeated[_String|{_String,___}|ChemSinglePattern,{3}]}
		}
	]:=
	CreateOctahedralAtomset[
		check,
		coreEl,
		Flatten[faces]
		]


End[];



