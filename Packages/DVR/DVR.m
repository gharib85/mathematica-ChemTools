(* ::Package:: *)

(* Autogenerated Package *)

(* ::Text:: *)
(*This is the top-level interface for lower-level DVR stuff*)



ChemDVRObject::usage=
  "General object wrapper for ChemDVR stuff";


ChemDVRResultsObject::usage=
  "An object-oriented interface to ChemDVR results";


Begin["`Private`"];


(* ::Text:: *)
(*
	All code lives in the implementation package. This just exposes the symbols in the DVR context instead of DVR`Package`
	
*)



PackageAddAutocompletions[
  ChemDVRObject,
  List@ChemDVRClasses[]
  ]


End[];



