open List

(* fonctions utilitaires *********************************************)

(* filter_map : ('a -> 'b option) -> 'a list -> 'b list
   disponible depuis la version 4.08.0 de OCaml dans le module List :
   pour chaque élément de 'list', appliquer 'filter' :
   - si le résultat est 'Some e', ajouter 'e' au résultat ;
   - si le résultat est 'None', ne rien ajouter au résultat.
   Attention, cette implémentation inverse l'ordre de la liste *)

let filter_map filter list =
  let rec aux list ret =
    match list with
    | []   -> ret
    | h::t -> match (filter h) with
      | None   -> aux t ret
      | Some e -> aux t (e::ret)
  in aux list []

(* ou : 'a option -> 'a option -> 'a option
   prendre le « ou » de deux options *)
let ou a b =
  match a with
  | None -> b
  | _    -> a

(* print_modele : int list option -> unit
   affichage du résultat *)
let print_modele: int list option -> unit = function
  | None   -> print_string "UNSAT\n"
  | Some modele -> print_string "SAT\n";
     let modele2 = sort (fun i j -> (abs i) - (abs j)) modele in
     List.iter (fun i -> print_int i; print_string " ") modele2;
     print_string "0\n"

(* ensembles de clauses de test *)
let exemple_3_13 = [[1;2;-3];[2;3];[-1;-2;3];[-1;-3];[1;-2]]
let exemple_7_3 = [[1;-1;-3];[-2;3];[-2]]
let exemple_7_5 = [[1;2;3];[-1;2;3];[3];[1;-2;-3];[-1;-2;-3];[-3]]
let exemple_7_9 = [[1;-2;3];[1;-3];[2;3];[1;-2]]
let accessibilite = [[-1;2];[-1;7];[-2;1];[-2;3];[-3;2];[-3;4];[-4;5];[-4;15];[-5;2];[-5;4];[-6;5];[-7;1];[-7;8];[-7;6];[-8;7];[-8;9];[-8;10];[-9;8];[-10;8];[-10;11];[-10;12];[-11;9];[-11;10];[-12;6];[-12;10];[-12;13];[-12;15];[-13;11];[-14;13];[-14;15];[-15;12];[1];[-14]]
let grammaire = [[6];[1;-2;-3;-4];[1;-2;-5];[5;-3;-5];[2;-3];[3;-4];[4;-6];[-1]]
let coloriage = [[1;2;3];[4;5;6];[7;8;9];[10;11;12];[13;14;15];[16;17;18];[19;20;21];[-1;-2];[-1;-3];[-2;-3];[-4;-5];[-4;-6];[-5;-6];[-7;-8];[-7;-9];[-8;-9];[-10;-11];[-10;-12];[-11;-12];[-13;-14];[-13;-15];[-14;-15];[-16;-17];[-16;-18];[-17;-18];[-19;-20];[-19;-21];[-20;-21];[-1;-4];[-2;-5];[-3;-6];[-1;-7];[-2;-8];[-3;-9];[-4;-7];[-5;-8];[-6;-9];[-4;-10];[-5;-11];[-6;-12];[-7;-10];[-8;-11];[-9;-12];[-7;-13];[-8;-14];[-9;-15];[-7;-16];[-8;-17];[-9;-18];[-10;-13];[-11;-14];[-12;-15];[-13;-16];[-14;-17];[-15;-18]]

(********************************************************************)

(* simplifie : int -> int list list -> int list list
   applique la simplification de l'ensemble des clauses en mettant
   le littéral i à vrai *)

(*
Version ultérieure
let rec simplifiebis i clauses acc =
  match clauses with
    | [] -> acc
    | a :: b ->
      if exists (fun x -> i=x) a
      then simplifiebis i b acc
      else simplifiebis i b ((filter (fun x -> not (x = (-i))) a) :: acc)
;;

let simplifie i clauses =
  simplifiebis i clauses []
;;
*)

let simplifie i clauses =
  filter_map
    (fun x ->
      if exists (fun el -> i = el) x
      then None
      else Some (filter_map
        (fun x' -> if x' = (-i) then None else Some x')
      x)
    )
    clauses
;;

(* solveur_split : int list list -> int list -> int list option
   exemple d'utilisation de 'simplifie' *)

let rec solveur_split clauses interpretation =
  (* l'ensemble vide de clauses est satisfiable *)
  if clauses = [] then Some interpretation else
  (* un clause vide est insatisfiable *)
  if mem [] clauses then None else
  (* branchement *)
  let l = hd (hd clauses) in
  ou (solveur_split (simplifie l clauses) (l::interpretation))
     (solveur_split (simplifie (-l) clauses) ((-l)::interpretation))

(* tests *)
(* let () = print_modele (solveur_split accessibilite []) *)
(* let () = print_modele (solveur_split coloriage []) *)
(* let () = print_modele (solveur_split grammaire []) *)

(* solveur dpll récursif *)

(* unitaire : int list list -> int
    - si 'clauses' contient au moins une clause unitaire, retourne
      le littéral de cette clause unitaire ;
    - sinon, lève une exception 'Not_found' *)

(* Version ultérieure
let rec unitaire clauses =
  match clauses with
  | [] -> (* Failure "Not_found" *) 0
  | a :: tl ->
      match a with
        | [e] -> e
        | _ -> unitaire tl
;;
*)

let unitaire clauses =
  (hd
    (find
      (fun x -> length x = 1)
    clauses)
  )
;;

(* --- Fonctions auxiliaires à pur* --- *)

(* Fonction renvoyant le premier élément d'une liste de couples (int * bool)
où le bool est true ou 0 si la liste est vide *)

let rec first l =
  match l with
  | [] -> raise Not_found
  | (e, b) :: l -> if b then e else first l
;;


(* Prends en entrée une clause et une liste de couples (int * bool )
et pour chaque variable :
  - si elle est présente, on vérifie si elle est sous la forme v ou -v,
    et si elle est sous une forme différente, on passe à false le booléen
    correspondant
  - si elle ne l'est pas, on ajoute un couple (variable, true) où variable
    est ajoutée sous sa forme (soit v, soit -v) *)

let rec aux_aux_pur clause accu =
  match clause with
  | [] -> accu
  | a :: tl ->
    if exists (fun (n, b) -> a = n || a = (-n)) accu
    then aux_aux_pur tl (map (fun (n, b) -> if n = -a then (n, false) else (n, b)) accu)
    else aux_aux_pur tl ((a, true) :: accu)
;;

(* Appelle aux_aux_pur sur toutes les clauses, en transmettant l'accumulateur *)

let rec aux_pur clauses accu =
  match clauses with
    | [] -> (*first accu*)
      (match
        find (fun (el,b) -> b) accu
      with (el,b) -> el)
    | a :: b -> aux_pur b (aux_aux_pur a accu)
;;

(* pur : int list list -> int
    - si 'clauses' contient au moins un littéral pur, retourne
      ce littéral ;
    - sinon, lève une exception 'Failure "pas de littéral pur"'
*)


let pur clauses =
  aux_pur clauses []
;;

(* --- Fonction auxiliaires à solveur_dpll_rec* --- *)

(* Vérifie qu'aucune clauses ne soit vide *)

(* Inutile
let rec hasAnEmptyClause clauses =
  match clauses with
  | [] -> false
  | a :: tl ->
    if a = []
    then true
    else hasAnEmptyClause tl
;;
*)

(* solveur_dpll_rec : int list list -> int list -> int list option *)

(* Version ultérieure
let rec solveur_dpll_rec clauses interpretation =
  (* Recherche d'une clause vide *)
  if hasAnEmptyClause clauses
  then None
  else


  (* Vérification que clauses n'est pas vide *)
  if clauses = []
  then Some (interpretation)
  else

  (* Recherche des variables unitaires *)
  let unit = unitaire clauses in
  if unit != 0
  then solveur_dpll_rec (simplifie unit clauses) (unit :: interpretation)
  else

  (* Recherche des variables pures *)
  let pur = pur clauses in
  if pur != 0
  then solveur_dpll_rec (simplifie pur clauses) (pur :: interpretation)
  else

  (* Elimination des variables *)
  let l = hd (hd clauses) in
  ou (solveur_split (simplifie l clauses) (l::interpretation))
     (solveur_split (simplifie (-l) clauses) ((-l)::interpretation))
;;

*)

let rec solveur_dpll_rec clauses interpretation =
  (* Recherche d'une clause vide *)
  if exists (fun x -> x=[]) clauses
  then None
  else


  (* Vérification que clauses n'est pas vide *)
  if clauses = []
  then Some (interpretation)
  else

  (* Recherche des variables unitaires *)
  try
    let literal = unitaire clauses in
    solveur_dpll_rec (simplifie literal clauses) (literal :: interpretation)
  with
  | Not_found ->

  (* Recherche des variables pures *)
  try
    let pur = pur clauses in
    solveur_dpll_rec (simplifie pur clauses) (pur :: interpretation)
  with
  | Not_found ->

  (* Elimination des variables *)
  let l = hd (hd clauses) in
  ou (solveur_split (simplifie l clauses) (l::interpretation))
     (solveur_split (simplifie (-l) clauses) ((-l)::interpretation))
;;

(* tests *)
(* let () = print_modele (solveur_dpll_rec accessibilite []) *)
(* let () = print_modele (solveur_dpll_rec coloriage []) *)
(* let () = print_modele (solveur_dpll_rec grammaire []) *)

let () =
  let clauses = Dimacs.parse Sys.argv.(1) in
  print_modele (solveur_dpll_rec clauses [])
;;
