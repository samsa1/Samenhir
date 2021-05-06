(*
###########################################################
#                                                         #
#             Fichier d'interface de Samenhir             #
#                                                         #
# Sert à appeler le parser, le lexer, le constructeur de  #
# table ainsi que la fonction de construction des fichier #
#             .ml et .mli du même nom que l'input         #
#                                                         #
###########################################################
*)

open SamenhirAst

let file = ref "";;
let v2 = ref false;;
let language = ref "ocaml";;

type lang =
	| OCaml
	| Rust

let convert_lang_name x = match String.lowercase_ascii x with 
	| "ocaml" | "ml" -> OCaml
	| "rust" | "rs" -> Rust
	| _ -> begin	
			print_string "This languga name is not autorised !\n";
			exit 1;
	end

let main () =
	let spectlist = ["-explain", Arg.Set Samenhir_utilities.explain, "build file of states";
	"-print", Arg.Set Samenhir_utilities.print_all, "show info to debug Samenhir";
	"-v2", Arg.Set v2, "use v2 version for OCaml only";
	"-l", Arg.Set_string language, "set language";
	"-include-main", Arg.Set Samenhir_utilities.include_main, "add main function for rust"]
	in
	Arg.parse spectlist (fun f -> file := f) "";
	if !file = "" then
		failwith "no file to compile"
	else if not (Filename.check_suffix !file ".sam")
		then failwith "not the good extension"
		else begin
			let f = open_in !file in
			let buf = Lexing.from_channel f in
			let parsed = try SamenhirParser.program SamenhirLexer.token buf
			with SamenhirParser.Samenhir_Parsing_Error _ -> (let e = Lexing.lexeme_end_p buf in
				print_string "Parsing error line ";
				print_int e.pos_lnum;
				print_newline ();
				exit 1)
 in
			let () = close_in f in
			let table = Samenhir_utilities.buildTable (Samenhir_utilities.unrawGrammar parsed.g) parsed.prio in
			let p = {gR = parsed.g; startLTable = table.startLine; gotoTab = table.goto; actionTab = table.action; tokenList = parsed.tokenList; head = parsed.header} in
			match convert_lang_name !language with 
				| OCaml -> begin
					if !Samenhir_utilities.include_main then print_string "WARNING : No main is not avialable for Ocaml\n";
					let outfile = (Filename.chop_suffix !file ".sam" ^ ".ml") in
					let out = open_out outfile in
					let _ = (if !v2 then Samenhir_utilities.pp_main else Samenhir_utilities.pp_buildProg) (Format.formatter_of_out_channel out) p in
					let () = close_out out in
					let out = open_out (outfile^"i") in
					let _ = Samenhir_utilities.pp_mli (Format.formatter_of_out_channel out) p in
					close_out out;
					end
				| Rust -> begin
					if !v2 then print_string "WARNING : V2 is directly implemented in rust, no need to call it\n";
					let debut_nom = Filename.chop_suffix !file ".sam" in
					let outfile = debut_nom ^ ".rs" in
					let out = open_out outfile in
					let _ = Samenhir_utilities.pp_rust_main (Format.formatter_of_out_channel out) p in
					close_out out
					end
		end
;;

let () = main ();;
