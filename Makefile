target = OXCON2016

paper_target = $(target)_paper
slides_target = $(target)_slides

documentation = README.md

paper_source = $(paper_target).tex
slides_source = $(slides_target).tex
latex_cmd = pdflatex
editor = vi

dvi_options = --output-format dvi

paper_counter_file = counters/paper_build_counter.txt
slides_counter_file = counters/slides_build_counter.txt

paper_pdf_file = $(paper_target).pdf
paper_dvi_file = $(paper_target).dvi
slides_pdf_file = $(slides_target).pdf

paper_sources = $(paper_source) $(bibtex_file)
slides_sources = $(slides_source)
graphics_dir = ./graphics

temporary_files = *.log *.aux *.out *.idx *.ilg *.bbl *.blg .pdf *.nav *.snm *.toc

all:: $(paper_pdf_file) 

graphics_for_paper = $(graphics_dir)/ox_brand_cmyk_pos.pdf

graphics_for_slides = $(graphics_dir)/ox_brand_cmyk_pos.pdf

$(paper_pdf_file): $(paper_sources) $(graphics_for_paper) Makefile
	@echo $$(($$(cat $(paper_counter_file)) + 1)) > $(paper_counter_file)
	$(latex_cmd) $(paper_source)
	bibtex $(paper_target)
	if (grep "Warning" $(paper_target).blg > /dev/null ) then false; fi
	while ( \
		$(latex_cmd) $(paper_target) ; \
		grep "Rerun to get" $(paper_target).log > /dev/null \
	) do true ; done
	chmod a-x,a+r $(paper_pdf_file)
	@echo "Build `cat $(paper_counter_file)`"

$(slides_pdf_file): $(slides_sources) $(graphics_for_slides) Makefile
	@echo $$(($$(cat $(slides_counter_file)) + 1)) > $(slides_counter_file)
	while ( \
		$(latex_cmd) $(slides_target) ; \
		grep "Rerun to get" $(slides_target).log > /dev/null \
	) do true ; done
	@echo "Build `cat $(slides_counter_file)`"
	chmod a-x,a+r $(slides_pdf_file)

vi: paper

commit:
	git add -A
	git commit
	git pull
	git push

paper:
	$(editor) $(paper_source)

slides:
	$(editor) $(slides_source)

spell::
	aspell --lang=en_GB check $(paper_source)
	aspell --lang=en_GB check $(slides_source)

clean::
	rm -vf $(temporary_files)

allclean: clean
	rm -vf $(paper_pdf_file) $(paper_dvi_file) $(slides_pdf_file)

