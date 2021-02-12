Parser = parser.sam

all:build
	@echo "Everything builded !"
build:
	@ocamlopt samenhirAst.ml samenhir_utilities.mli samenhir_utilities.ml samenhirParserBuilder.ml -o samenhirParserBuilder
	@./samenhirParserBuilder
	@ocamllex -q samenhirLexer.mll
	@ocamlopt samenhirAst.ml samenhir_utilities.mli samenhir_utilities.ml samenhirParser.mli samenhirParser.ml samenhirLexer.ml samenhir.ml -o samenhir -O3
	@rm *.cmi *.cmx *.o samenhirLexer.ml
	@rm samenhirParser.ml samenhirParser.mli samenhirParserBuilder

exec:
	./samenhir $(PARSER)

time:
	time ./samenhir parser.sam
	time ocamlopt parser.mli parser.ml -o parser

clean:
	@rm -f parser parser.mli parser.ml
	@rm -f _build/*
	@rm -f *.cmi *.o *.cmx samenhirParserBuilder samenhirParser.ml samenhirParser.mli samenhirLexer.ml
	
cleanall: clean
	@rm -f samenhir

rust: build
	./samenhir -l rust -no-main parser.sam
	