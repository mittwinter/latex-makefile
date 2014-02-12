Makefile for LaTeX
==================

This aims to be a generic Makefile to compile LaTex sources to PDF files.

For each PDF the Makefile assumes that there is one main LaTeX source file, by
default indicated by an existing empty file `<sourceFile>.latexmain`, as it is
for example also used by the *vim-latexsuite*. There is also a list of input
files which the main source files depend on. By default, the input files are
determined via a wildcard `???-*.latex`, so that e. g. the main file
`main.latex` may include files like `000-introduction.latex`,
`100-first_chapter.latex` via `\input{...}`.

The Makefile employs:

 * Two modes *draft* and *final*. In *draft* mode the Makefile will define the
   macro \draft which can be used to conditionally include parts of your
   document only in draft versions:

		\ifdefined\draft
			% draft-specific LaTeX code
		\fi

   You can use it for example in combination with the `todonotes` package:

		\ifx \draft \undefined
			\usepackage[disable]{todonotes}
		\else
			\usepackage{todonotes}
		\fi

 * If placed inside of a git repository, the Makefile will define the macro
   `\versiontag` which can be used to indicate the git revision from which the
   document was generated.

   The macro will contain the output of:

		$ git describe --all --tags --long

 * An optional list of subdirectories `SUBDIRS` to descend into and call `make`
   subsequently.

 * `clean` target which deletes all temporary files that are created by LaTeX
   during compilation.

 * `distclean` target which additionally to `clean` also deletes the compiled
   PDF files.

 * `todo` target which greps all LaTeX files for the strings `TODO` and `FIXME`.

 * `spellcheck` target which invokes `hunspell` for all LaTeX files with the
   language as specified in the variable `LANGUAGE`.
