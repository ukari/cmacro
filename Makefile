LISP = sbcl
LISPOPTS = --no-sysinit --no-userinit

BUILD = build

NAME = cmacro
LEXER = grammar/cmc-lexer
BUILDAPP = $(BUILD)/buildapp

QLDIR = $(BUILD)/quicklisp
QLURL = http://beta.quicklisp.org/quicklisp.lisp
QLFILE = $(QLDIR)/quicklisp.lisp
QLSETUP = $(QLDIR)/setup.lisp

LISP_QL = $(LISP) $(LISPOPTS) --load $(QLSETUP)

default: all

$(QLDIR)/setup.lisp:
	@echo "Install Quicklisp"
	mkdir -p $(QLDIR)
	curl -o $(QLFILE) $(QLURL)
	$(LISP) $(LISPOPTS) --load $(QLFILE) \
	  --eval '(quicklisp-quickstart:install :path "$(QLDIR)")' \
          --quit
	rm $(QLFILE)

quicklisp: $(QLDIR)/setup.lisp ;

$(BUILD)/buildapp: quicklisp
	@echo "Install Buildapp"
	$(LISP_QL) --eval '(ql:quickload :buildapp)' \
		   --eval '(buildapp:build-buildapp "$(BUILDAPP)")' \
	 	   --quit

buildapp: $(BUILD)/buildapp ;

$(BUILD)/.reqs:
	@echo "Downloading requirements"
	$(LISP_QL) --eval '(ql:quickload :$(NAME))' --quit
	touch $@

libs: $(BUILD)/.reqs ;

cmc: buildapp libs
	@echo "Building $(NAME)"
	$(BUILDAPP) --output $@ \
		    --asdf-path . \
		    --asdf-tree $(QLDIR)/dists \
                    --load-system $(NAME) \
		    --entry cmacro:main

all: cmc

clean:
	rm -rf $(BUILD)
