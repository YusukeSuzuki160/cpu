include ../tools/Makefile.inc

.DEFAULT: all


# --------
# ソースディレクトリのリスト
# 各ディレクトリには code.s が1つ存在している前提
#

SRC_DIRS = \
	ControlTransfer \
	IntRegImm \
	IntRegReg \
	LoadAndStore \
	ZeroRegister \
	Uart \

# 中間ファイルのリスト
ASM_SRCS  = $(SRC_DIRS:%=%/code.s)
ASM_OBJS  = $(SRC_DIRS:%=%/code.o)
ASM_ELFS  = $(SRC_DIRS:%=%/code.elf)
ASM_DUMPS = $(SRC_DIRS:%=%/code.dump)
ASM_BINS  = $(SRC_DIRS:%=%/code.bin)
ASM_DSTS  = $(SRC_DIRS:%=%/code.hex)


# ----
# 生成ルール
# $(ASM_DSTS) の全ファイルを生成 -> 
#   各ファイルごとに依存関係を逆辿りすることで全体が生成される
#
%.o: %.s
	$(CC) $(CFLAGS) -o $@ -c $<

# LD の引数の順にアドレス空間に配置されるため，
# CRTOBJ は必ず先頭に置く必要がある
# また，$(LIBGCC) $(LIBC) -T$(LDSCRIPT) $(LDFLAGS) は
# $(OBJS) が依存しているためその後ろに置く必要がある．
%.elf: $(CRTOBJ) %.o
	$(LD) -o $@ $^ $(LIBC) $(LIBGCC) $(LIBC) -T$(LDSCRIPT) $(LDFLAGS)

%.dump: %.elf
	$(OBJDUMP) -D $< > $@

%.bin: %.dump 
	$(OBJECT_FILE_CONVERTER) $< $@

%.hex: %.bin
	$(BIN_TO_HEX) $< $@ $(BIN_SIZE)


all: $(ASM_DSTS)


clean:
	rm $(ASM_DSTS) $(ASM_ELFS) $(ASM_DUMPS) $(ASM_BINS) $(ASM_OBJS) $(CRTOBJ) -f


# 中間ファイルが残るように
.PRECIOUS: $(ASM_DSTS) $(ASM_ELFS) $(ASM_DUMPS) $(ASM_BINS) $(ASM_OBJS) $(CRTOBJ)

