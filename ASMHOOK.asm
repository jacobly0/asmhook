include 'ez80.inc'
include 'tiformat.inc'
include 'ti84pceg.inc'
name := 'ASMHOOK'
format ti archived executable protected program name

macro trampoline? reg: hl
	local base
	element base
	virtual at base

	macro end?.trampoline?!
			local code
			load code: $ - $$ from $$
		end virtual

		repeat (lengthof code + long - 1) / long
			ld	reg, code shr ((%% - %) * long shl 3) and ((1 shl (long shl 3)) - 1)
			push	reg
		end repeat
		purge end?.trampoline?
	end macro
end macro

launch:	call	ti.ChkFindSym
	ret	c
	ld	hl, launch.endoff
	add	hl, de
	jp	(hl)
.endoff := 10 + lengthof name + 2 + 2 + $ - .

	element	base
	org	base
inst:	push	af, bc, de, hl
	call	ti._frameset0
.loc:	ex	de, hl
	call	ti.ChkInRam
	jr	nz, .arc
	jr	.cont
	assert	$ = 10 + lengthof name + $$
	jr	inst
.cont:	ld	hl, .name - .loc
	add	hl, de
	call	ti.Mov9ToOP1
trampoline
	ld	ix, (ti.arcInfo)
	lea	hl, ix + launch.endoff + .ret - .
	jp	(hl)
	.count := ($ - $$ + long - 1) / long
end trampoline
	pea	ix - .count * long
	call	ti.ChkFindSym
	jp	ti.ArchiveVar
.ret:
repeat .count
	pop	de
end repeat
	ld	de, .loc - .ret
	add	hl, de
	ex	de, hl
.arc:	ld	hl, menu - 1 - .loc
	add	hl, de
	ld	(ti.menuHookPtr), hl
	ld	hl, parser - 1 - .loc
	add	hl, de
	ld	(ti.parserHookPtr), hl
	ld	hl, ti.flags + ti.hookflags4
	ld	a, (hl)
	or	a, 1 shl ti.menuHookActive or 1 shl ti.parserHookActive
	ld	(hl), a
	pop	ix, hl, de, bc, af
	ret
match any, protected
.name	db	ti.ProtProgObj, name, 0
else
.name	db	ti.ProgObj, name, 0
end match
	db	$83
menu:	cp	a, 3
	jr	nz, .retz
	ld	a, b
	cp	a, ti.kYes
	jr	nz, .retz
	ld	a, (ti.menuCurrent)
	cp	a, $40
	jr	nz, .retz
	lea	hl, inst.name + ix - menu
	call	ti.Mov9ToOP1
	call	ti.ChkFindSym
	sbc	a, a
	or	a, b
	rlca
	jr	c, .yes
	call	ti.PushRealO1
	sbc	hl, hl
	add	hl, sp
	ex	de, hl
	ld	hl, -.inserted * long
	add	hl, sp
	ld	sp, hl
	ld	bc, 7 * long
	ex	de, hl
	ldir
	ex	de, hl
virtual
	pop	hl
	add	hl, de
	pop	de
	load	.trampoline1: $ - $$ from $$
end virtual
virtual
	di
	pop	de
	jp	(hl)
	load	.trampoline2: $ - $$ from $$
end virtual
iterate value, ti.PopRealO1, ti.ChkFindSym, relative 6, launch.endoff, .trampoline1, .trampoline2
 match =relative? offset, value
	ex	de, hl
	ld	hl, offset
	add	hl, de
	ex	de, hl
 else
	ld	de, value
 end match
	ld	(hl), de
 if % <> %%
  repeat long
	inc	hl
  end repeat
 else
	.inserted := %
 end if
end iterate
.yes:	ld	b, ti.kYes
.retz:	cp	a, a
	ret
clean:	assert	~ti.LoadHLInd_s xor ti.JErrorNo and not $FF
	ex	(sp), hl
	ld	(hl), ti.JErrorNo and $FF
.good:	pop	hl, hl
	res	ti.numOP1, (hl)
	pop	bc, hl
	ld	de, (hl)
	ld	(hl), bc
	pop	hl
	di
	ld	sp, hl
	pop	hl
	ret
	.count := ($ - . + long - 1) / long
asm:	call	ti.ParsePrgmName
	call	ti.CkEndLin
	jr	z, .legal
	ld	(ti.curPC), bc
	cp	a, ti.tRParen
	call	z, ti.CkEndLin
	jp	nz, ti.ErrSyntax
.legal:	call	ti.ChkFindSym
	jp	c, ti.ErrUndefined
	ex	de, hl
	ld	a, b
	ld	b, 1
	cp	a, $D0
	jr	nc, parser.ram
	ld	a, 10
	add	a, c
	ld	c, a
	dec	b
	add	hl, bc
	jr	parser.ram
	db	$83
parser:	or	a, a
	jr	z, begin
	cp	a, 2
	jr	nz, .retz
	ld	a, b
	cp	a, $5D
	jr	z, asm
.retz:	cp	a, a
	ret
.ram:	call	ti.LoadDEInd_s
	ld	a, (hl)
	cp	a, ti.tExtTok
.invld:	jp	nz, ti.ErrInvalid
	inc	hl
	ld	a, (hl)
	cp	a, ti.tAsm84CeCmp
	jr	nz, .invld
.valid:	inc	hl
	dec	de
	dec	de
	djnz	.arc
	add	hl, de
.arc:	ld	bc, ti.LoadHLInd_s
	push	bc
	ld	bc, ti.DelMem
	push	bc, hl, de
	ex	de, hl
	call	ti.ErrNotEnoughMem
	ex	de, hl
	ld	de, ti.userMem
	call	ti.InsertMem
	pop	bc, hl
	push	de
	ld	(ti.asm_prgm_size), bc
	ldir
	ld	hl, -clean.count * long
	add	hl, sp
	ld	sp, hl
	push	hl
	ex	de, hl
	lea	hl, clean + ix - parser
	ld	c, clean.count * long
	ldir
	ex	de, hl
	ex	(sp), hl
	ld	de, ti.asm_prgm_size
	push	de, bc, iy + ti.ParsFlag2
	ex	de, hl
	ld	hl, (clean.count + 2) * long
	add	hl, de
	push	hl
	ex	de, hl
	call	ti.PushErrorHandler
	ld	hl, 11 * long + clean.good - clean
	add	hl, sp
	push	hl
	ld	hl, ti.PopErrorHandler
	push	hl
	jp	ti.userMem
begin:	call	ti.CurFetch
	ld	e, a
	ld	a, (ti.basic_prog + 1)
	cp	a, '#'
	ld	a, e
	jr	z, .eol
	cp	a, ti.tExtTok
	jr	nz, .retz
	dec	hl
	dec	hl
	call	ti.LoadDEInd_s
	inc	hl
	ld	a, (hl)
	cp	a, ti.tAsm84CeCmp
	jr	z, parser.valid
.rew:	ld	hl, (ti.begPC)
	ld	(ti.curPC), hl
.retz:	cp	a, a
	ret
.scan:	call	ti.Isa2ByteTok
	call	z, ti.IncFetch
.next:	call	ti.IncFetch
.cont:	cp	a, ti.tString
	call	z, ti.BufToNextBASICSeparator
	call	ti.CkEndExp
	jr	nz, .scan
	call	ti.IncFetch
	jr	c, .rew
.eol:	cp	a, ti.tProg
	jr	nz, .cont
	push	hl
	dec	hl
	ld	(ti.curPC), hl
	call	ti.ParsePrgmName
	call	ti.ChkFindSym
	pop	hl
.cnext:	jr	c, .next
	ex	de, hl
	ld	a, b
	cp	a, $D0
	jr	nc, .ram
	ld	a, 10
	add	a, c
	ld	c, a
	ld	b, 0
	add	hl, bc
.ram:	ld	a, (hl)
	inc	hl
	add	a, -3
	sbc	a, a
	or	a, (hl)
	jr	z, .next
	inc	hl
	ld	hl, (hl)
	ld	bc, ti.tExtTok or ti.tAsm84CeCmp shl 8
	sbc.s	hl, bc
	jr	nz, .next
	push	de
	ld	l, 2
	call	ti.ErrNotEnoughMem
	ld	hl, (ti.begPC)
	dec	hl
	dec	hl
	ld	bc, (hl)
	inc	bc
	inc	bc
	ld	a, c
	rra
	or	a, b
	jp	z, ti.ErrMemory
	ex	(sp), hl
	push	bc
	inc	hl
	ex	de, hl
	call	ti.InsertMem
	pop	bc, hl
	ld	(hl), bc
	ex	de, hl
	ld	bc, ti.t2ByteTok or ti.tasm shl 8 or ti.tProg shl 16
	dec	hl
	ld	(hl), bc
	ld	hl, (ti.endPC)
	inc	hl
	inc	hl
	ld	(ti.endPC), hl
	scf
	jr	.cnext
