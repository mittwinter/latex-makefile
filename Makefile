#
# *** latex-makefile ***
#
# Copyright (C) 2013-2014 Martin Wegner
# Released under the terms of the GNU General Public License, version 3 or newer.
# website: https://github.com/mittwinter/latex-makefile
#
MODES = draft final
MODE = draft

ifeq "" "$(MODE)"
	$(error MODE is not set)
endif

ifneq (, $(filter-out $(MODES), $(MODE)))
	$(error MODE is none of $(MODES))
endif

# Look for "main" latex file that is passed to pdflatex,
#  by looking for a *.latexmain filename, as e. g. also 
#  used by vim-latexsuite. Replace with plain filename,
#  if desired.
SOURCES := $(basename $(wildcard *.latexmain ))
TARGETS := $(shell echo ${SOURCES} | sed -e 's/.latex/.pdf/g')

# Look for additional latex files that the main latex file
#  should depend on for remaking. I like to use a three digit
#  prefix to order the input files (e. g. 100-introduction.latex,
#  200-main_chapter.latex, ...). Replace it with plain filenames
#  or other pattern to adapt to your personal preferences.
INPUTS := $(sort $(wildcard ???-*.latex))
TEXFILES := ${SOURCES} ${INPUTS}
BIBTEXFILE := $(wildcard *.bib)
# Set language used by hunspell when $ make spellcheck:
LANGUAGE = de_DE_frami
SUBDIRS =

VERSIONTAG := $(shell [ -d .git ] && git describe --all --tags --long || echo none)
PDFLATEXMACROS = \\newcommand{\\versiontag}{$(VERSIONTAG)}
ifeq "$(MODE)" "draft"
	PDFLATEXMACROS += \\def\\draft{}
endif

PDFLATEX = pdflatex
PDFLATEXFLAGS = -halt-on-error -file-line-error
BIBTEX = bibtex
BIBTEXFLAGS = 

.PHONY: all clean distclean todo spellcheck pre-version

all: ${TARGETS}
	#$(MAKE) clean
	for d in $(SUBDIRS); do \
		cd $$d && $(MAKE); \
	done

$(TARGETS): %.pdf: %.latex ${INPUTS} ${BIBTEXFILE}
	$(PDFLATEX) $(PDFLATEXFLAGS) $(PDFLATEXMACROS)\\input{$<} \
		&& ( [ ! -f "${BIBTEXFILE}" ] \
		     || ( $(BIBTEX) $(BIBTEXFLAGS) $* \
		          && $(PDFLATEX) $(PDFLATEXFLAGS) $(PDFLATEXMACROS)\\input{$<} >/dev/null \
		        ) \
		   ) \
		&& $(PDFLATEX) $(PDFLATEXFLAGS) -recorder $(PDFLATEXMACROS)\\input{$<} >/dev/null
		# clean latex temp files:
		grep '^OUTPUT' $*.fls \
			| cut -d' ' -f2 \
			| grep -vx $@ \
			| xargs rm -v
		rm -v $*.fls # clean -recorder file
		rm -vf $*.bbl $*.blg # clean bibtex temp files

clean:
	for f in $(SOURCES); do \
		rm -f `basename $$f`{aux,bbl,blg,brf,lof,lol,lot,log,nav,out,snm,toc,vrb}; \
	done
	for d in $(SUBDIRS); do \
		cd $$d && $(MAKE) clean; \
	done

distclean: clean
	rm -f ${TARGETS}
	for d in $(SUBDIRS); do \
		cd $$d && $(MAKE) distclean; \
	done

todo:
	grep -nT -C 1 'TODO\|FIXME' ${TEXFILES} ${BIBTEXFILE}

spellcheck:
	hunspell -d $(LANGUAGE) -t ${TEXFILES}

pre-version: all
	mkdir -p ./Pre-Versions
	for f in ${TARGETS}; do \
		cp -f $$f ./Pre-Versions/$(shell date +%Y%m%d)-$$f; \
	done

