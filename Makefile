CD = cd
MKDIR = mkdir -p
MV = mv
RM = rm -f
RMDIR = rmdir
SED = sed
GIT = git
FASMG = fasmg
TOUCH = touch
NOP = :
ZIP = zip

INCLUDES = $(addprefix include/,$(addprefix fasmg-ez80/,ez80.inc commands.alm ez80.alm) ti84pceg.inc)

all: ASMHOOK.8xp

unprot: FASMG_FLAGS = -i "protected equ"
unprot: all

release:
	$(MAKE) clean
	$(MAKE) unprot
	$(MV) ASMHOOK.8xp ASMHOOK_unprot.8xp
	$(MAKE)
	$(ZIP) ASMHOOK.zip ASMHOOK.8xp ASMHOOK_unprot.8xp

%.8xp: %.asm $(INCLUDES) Makefile
	INCLUDE="include;include/fasmg-ez80" $(FASMG) $(FASMG_FLAGS) $< $@

include/ti84pceg.inc: include/ti84pce.inc Makefile
	include/fasmg-ez80/ti84pce.sed $< > $@
	$(SED) --expression='3s/^/element anovaf_vars\n/' --in-place $@

include/ti84pce.inc: include/fasmg-ez80/bin/fetch_ti84pce Makefile
	$(MKDIR) include
	$(CD) include && fasmg-ez80/bin/fetch_ti84pce

include/fasmg-ez80/%: .gitmodules Makefile
	$(GIT) submodule update --init include/fasmg-ez80
	$(TOUCH) $@

distclean: clean
	$(RM) include/*.inc
	$(GIT) submodule deinit --all
	$(RMDIR) include/fasmg-ez80 include || $(NOP)

clean:
	$(RM) *.8xp *.zip

.SECONDARY: $(INCLUDES)

.PHONY: all unprot release distclean clean
