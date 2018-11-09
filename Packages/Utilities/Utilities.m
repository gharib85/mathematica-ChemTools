(* ::Package:: *)

(* Autogenerated Package *)

(* ::Subsubsection::Closed:: *)
(*Atom Types*)



ChemDataAtomQ::usage="Returns true for atom or isotope strings";
ChemDataIsotopeQ::usage="Returns true for isotope strings";


(* ::Subsubsection::Closed:: *)
(*Bonds*)



ChemUtilsBondMatrix::usage=
  "Converts a bond list into a bond matrix";
ChemUtilsBondList::usage=
  "Converts a bond matrix into a bond list";
ChemUtilsGuessBonds::usage=
  "Attempts to resolve the bonding structure of a collection of atoms";


(* ::Subsubsection::Closed:: *)
(*Isotopologues*)



ChemUtilsIsotopologues::usage=
  "Figures out all possible isotopologues and abundances of a given atomset";


(* ::Subsubsection::Closed:: *)
(*Energies*)



ChemUtilsProductEnergies::usage=
  "Finds the lowest n direct product energies and indices";


Begin["`Private`"];


(* ::Subsection:: *)
(*Data Methods*)



(* ::Subsubsection::Closed:: *)
(*ChemDataIsotopeQ*)



ChemDataIsotopeQ[s_String]:=
  ChemDataSource[s]===IsotopeData;


(* ::Subsubsection::Closed:: *)
(*ChemDataAtomQ*)



ChemDataAtomQ[s_String]:=
  MatchQ[ChemDataSource[s],
    ElementData|IsotopeData|"CustomAtoms"
    ];
ChemDataIsotopeQ[__]:=False


(* ::Subsection:: *)
(*Misc Utils*)



(* ::Subsubsection::Closed:: *)
(*Isotopologues*)



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


(* ::Subsection:: *)
(*Bonding Utils*)



(* ::Subsubsection::Closed:: *)
(*BondMatrix*)



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


(* ::Subsubsection::Closed:: *)
(*BondList*)



ChemUtilsBondList[mx_]:=
  Replace[
    Select[
      Position[mx,_?(#>0&)],
        First@#<Last@#&
        ],
    {i_,j_}:>{i,j,mx[[i,j]]},
    1];


(* ::Subsubsection::Closed:: *)
(*GuessBonds*)



(* ::Subsubsubsection::Closed:: *)
(*Adjust matrix*)



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


(* ::Subsubsubsection::Closed:: *)
(*Iterate*)



guessBondsCheckBondingMatrix[mx_, inRange_, valences_, goal_]:=
  MapThread[
    If[MatchQ[#2,_Integer],
      Total@#==#2,
      MemberQ[#2,Total@#]
      ]&,
    {mx,valences}
    ];


guessBondsDetermineBondsStep[
  mx_,
  inRange_,
  valences_,
  goal_,
  order_
  ]:=
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


guessBonds[atoms_, tol_, iters_, multiValent_, goal_, log_, forbidden_]:=
  With[{
    inRange=
      Table[
        i!=j&&!MemberQ[forbidden, atoms[[{i, j}, 1]]]&&
        Norm[Subtract@@atoms[[{i, j}, 2]]]<=
          With[
            {
              d=
                ChemDataLookup[
                  Query[First@atoms[[i]], First@atoms[[j]], 1],
                  "BondDistances"
                  ]
              },
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


(* ::Subsubsubsection::Closed:: *)
(*Composite*)



Options[ChemUtilsGuessBonds]={
  MaxIterations->10,
  Tolerance->.075,
  "Charge"->0,
  "PriorityFunction"->(Switch[First@#,"H",0,"C",1,_,2]&),
  "LogSteps"->False,
  "MultiValences"->None,
  "MakeBondLists"->True,
  "ForbiddenBonds"->{}
  };
ChemUtilsGuessBonds[
  sourceAtoms:{{_String,{__?NumericQ}, ___}..},
  ops:OptionsPattern[]
  ]:=
  With[{
    atoms=SortBy[sourceAtoms, OptionValue@"PriorityFunction"],
    tol=OptionValue@Tolerance,
    iters=OptionValue@MaxIterations,
    goal=
      Replace[OptionValue@"Charge",
        {
          r_Real:>Ceiling@r,
          Except[_Integer]->1
          }
        ],
    log=TrueQ@OptionValue@"LogSteps",
    multi=
      Replace[OptionValue@"MultiValences",
        {
          Automatic:>
            Map[ChemDataLookup[First@#, "ElementValences"]&,
              sourceAtoms
              ]
          }
        ],
    makeLists=OptionValue@"MakeBondLists",
    forbidden=
      Sort/@
        Replace[
          OptionValue["ForbiddenBonds"], 
          Except[_List]:>{}
          ]
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
          guessBonds[atoms, tol, iters, multi, goal, log, forbidden],
      <|
        "Atoms"->atoms,
        "Bonds"->
          If[makeLists===False,
            guessBonds[
              atoms,
              tol,
              iters,
              multi,
              goal,
              log,
              forbidden
              ],
            ChemUtilsBondList@
              guessBonds[
                atoms,
                tol,
                iters,
                multi,
                goal,
                log,
                forbidden
                ]
            ]
        |>
      ]
    ]


(* ::Subsection:: *)
(*Energy Utils*)



(* ::Subsubsection::Closed:: *)
(*ChemUtilsProductEnergies*)



(* ::Subsubsubsection::Closed:: *)
(*iChemProdEigenSetsC*)



(* ::Text:: *)
(*
	Implementing this:
		https://cs.stackexchange.com/a/46945
*)



iChemProdEigenSetsC:=
  iChemProdEigenSetsC=
    Compile[
      {{vals, _Real, 2}, {n, _Integer}},
      Module[
        {
          dim,
          len,
          queue,
          costs,
          defel,
          tups,
          pop,
          push,
          cost,
          qels=0,
          solns=0,
          order
          },
        dim=Length@vals;
        len=Dimensions[vals][[2]];
        (* Initialize priority queue and cost vector *)
        defel=Table[-1, {$, dim}];
        queue=Table[defel, {$, n}];
        costs=Table[-1., {$, n}];
        (* Initialize solutions *)
        tups=Table[defel, {$, n}];
        (* Determine first element *)
        push=Table[1, {$, dim}];
        (* Compute cost *)
        cost=0.;
        Do[cost+=vals[[i, push[[i]]]], {i, dim}];
        (* Push onto queue *)
        ++qels;
        queue[[qels]]=push;
        costs[[qels]]=cost;
        (* Iterate *)
        pop=defel;
        Do[
          (* pop the first element, add it to the tups array *)
          pop=queue[[1]];
          tups[[++solns]]=pop;
          (* shift the queue elements back *)
          queue[[;;qels]]=queue[[2;;qels+1]];
          costs[[;;qels]]=costs[[2;;qels+1]];
          qels--;
          Do[
            (* Create new push element *)
            push=pop;
            push[[j]]+=1;
            (* Safety check that shows I've messed something up *)
            If[push[[j]]<=len,
              (* Compute cost *)
              cost=0.;
              Do[cost+=vals[[i, push[[i]]]], {i, dim}];
              (* determine where on queue would be added *)
              ++qels;
              (* allocate more queue if necessary *)
              If[qels>Length@queue,
                queue=
                Join[queue, 
                  Table[defel, {$$,2*Length@queue}]
                  ];
                costs=
                Join[costs, 
                  Table[-1., {$$,2*Length@queue}]
                  ]
                ];
              (* push onto queue *)
              queue[[qels]]=push;
              costs[[qels]]=cost;
              ];
            (* If next element would be added in later iteration, break *)
            If[pop[[j]]>1, Break[]],
            {j, dim}
            ];
          (* resort by priority *)
          order=Ordering[costs[[;;qels]]];
          queue[[;;qels]]=queue[[;;qels]][[order]];
          costs[[;;qels]]=costs[[;;qels]][[order]],
          {$, n-1}
          ];
        pop=queue[[1]];
        tups[[++solns]]=pop;
        tups
        ]
      ];


(* ::Subsubsubsection::Closed:: *)
(*ChemUtilsProductEnergies*)



ChemUtilsProductEnergies[eigenvals_, n_]:=
  Module[
    {
      pos,
      sets,
      eigs,
      eigmax=Length@eigenvals*Max@eigenvals+5,
      eiglen=Length/@eigenvals//Max,
      vals
      },
    eigs=PadRight[#, eiglen, eigmax]&/@eigenvals;
    pos=iChemProdEigenSetsC[eigs, n];
    sets=MapIndexed[eigenvals[[#2[[1]], #]]&, Transpose@pos]//Transpose;
    vals=Total/@sets;
    pos=Pick[pos, #<eigmax&/@vals];
    vals=Select[vals, #<eigmax&];
    {pos, vals}
    ]


End[];



