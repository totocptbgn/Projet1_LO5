dpll: dpll.ml dimacs.ml
	ocamlfind ocamlopt -o dpll -package str -linkpkg dimacs.ml dpll.ml 

clean:
	rm -f *.cmi *.cmx *.o dpll

# Run 'eval $(opam config env)' if 'ocamlfind' is not found.