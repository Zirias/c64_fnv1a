CA65?=		ca65
LD65?=		ld65

CA65FLAGS+=	-t none -g
LD65FLAGS+=	-Ln $(TARGET).lbl -m $(TARGET).map -C $(TARGET).cfg

TARGET=		fnv1atest

MODULES=	fnv1a_fast test

OBJS=		$(addsuffix .o,$(MODULES))

all:		$(TARGET).prg

$(TARGET).prg:	$(OBJS) $(TARGET).cfg Makefile
	$(LD65) -o$@ $(LD65FLAGS) $(OBJS)

%.o:		%.s $(TARGET).cfg Makefile
	$(CA65) $(CA65FLAGS) -o$@ $<
