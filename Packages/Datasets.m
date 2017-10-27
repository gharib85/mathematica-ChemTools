(* ::Package:: *)


(* ::Title:: *)
(*AtomsetUtils Package*)

(* ::Text::GrayLevel[.5]:: *)
(*Autogenerated ChemTools package*)

PackageScopeBlock[
	$ChemAtomColors::usage="";
	$ChemElements::usage="";
	$ChemSpaceGroups::usage="";
	$ChemBondDistances::usage="";
	$ChemElementValences::usage="";
	]


Begin["`Private`"];


$ChemAtomColors:=
	$ChemAtomColors=
		Import@PackageFilePath["Resources","Datasets","ChemAtomColors.wl"];


$ChemElements:=
	$ChemElements=
		Import@PackageFilePath["Resources","Datasets","ChemElements.wl"];


$ChemSpaceGroups:=
	$ChemSpaceGroups=
		Import@PackageFilePath["Resources","Datasets","ChemSpaceGroups.wl"];


$ChemBondDistances:=
	$ChemBondDistances=
		Import@PackageFilePath["Resources","Datasets","ChemBondDistances.wl"];


$ChemElementValences:=
	$ChemElementValences=
		Import@PackageFilePath["Resources","Datasets","ChemElementValences.wl"];


End[];



