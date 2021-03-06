
val print_all : bool ref

val explain : bool ref

val include_main : bool ref

val trace_time: bool ref

val unrawGrammar : SamenhirAst.grammar_raw -> SamenhirAst.grammar

val buildTable : SamenhirAst.grammar -> SamenhirAst.priority -> SamenhirAst.parseTable

val pp_buildProg: Format.formatter -> SamenhirAst.program -> unit

val pp_main: Format.formatter -> SamenhirAst.program -> unit

val pp_mli : Format.formatter -> SamenhirAst.program -> unit

val pp_rust_main : Format.formatter -> SamenhirAst.program -> string -> unit

