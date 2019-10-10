# Mini-projet 1 : solveur DPLL récursif


Objectif du mini-projet
-----------------------

Le but du mini-projet est d'implémenter un solveur DPLL récursif en
OCaml. Vous devez compléter pour cela le code dans le fichier dpll.ml :

 - la fonction simplifie : int -> int list list -> int list list
 - la fonction unitaire : int list list -> int
 - la fonction pur : int list list -> int
 - la fonction solveur_dpll_rec : int list list -> int list -> int list option

Ces types et les commentaires dans dpll.ml sont indicatifs. D'autres
choix peuvent être pertinents ; par exemple, unitaire et pur
pourraient aussi être de type int list list -> int option.


Tester son mini-projet
----------------------

Outre les sept exemples de test inclus dans dpll.ml (exemple_3_13,
exemple_7_3, exemple_7_5, exemple_7_9, accessibilite, grammaire et
coloriage), vous pouvez utiliser le Makefile en appelant

  make

pour compiler un exécutable natif et le tester sur des fichiers au
format DIMACS. Vous trouverez des exemples de fichiers à l'adresse

  https://www.irif.fr/~schmitz/teach/2019_lo5/dimacs/

Parmi ces exemples, accessibilite.cnf, coloriage.cnf, exemple-5-8.cnf,
exemple-7-3.cnf, exemple-7-9.cnf, flat50-1000.cnf, peirce.cnf et
sudoku-4x4.cnf sont satisfiables, tandis que aim-50-1_6-no-1.cnf,
exemple-3-13.cnf, exemple-7-5.cnf, grammaire.cnf et hole6.cnf sont
insatisfiables. Par exemple :

./dpll chemin/vers/sudoku-4x4.cnf

devrait répondre

SAT
-111 -112 113 -114 -121 -122 -123 124 -131 132 -133 -134 141 -142 -143 -144 -211 212 -213 -214 221 -222 -223 -224 -231 -232 -233 234 -241 -242 243 -244 311 -312 -313 -314 -321 322 -323 -324 -331 -332 333 -334 -341 -342 -343 344 -411 -412 -413 414 -421 -422 423 -424 431 -432 -433 -434 -441 442 -443 -444 0


Rendre son mini-projet
----------------------

 - date limite : 25 octobre 2019
 - sur la page Moodle du cours
     https://moodlesupd.script.univ-paris-diderot.fr/course/view.php?id=12299
 - en binôme
 - sous la forme d'une archive nom1-nom2.zip contenant l'arborescence
   suivante :
     nom1-nom2/dpll.ml
     nom1-nom2/dimacs.ml
     nom1-nom2/Makefile

   Optionnellement, vous pouvez ajouter un fichier
     nom1-nom2/RENDU
   en format texte simple, avec vos remarques ou commentaires.
