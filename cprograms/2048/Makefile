BD = ../../libmikeos

CC = bcc
CFLAGS = -c -Md -ansi -O -I

LD = ld86
LDFLAGS = -y -d -T100 -0 -C0 -lmikeos

# ----------------------------------------------------------------------------
SRC = 2048.c

TARGET = $(addsuffix .app, $(basename $(SRC)))
OBJ = $(addsuffix .o, $(basename $(SRC)))

HEADER = $(BD)/include
LIBDIR = $(BD)/lib

# ----------------------------------------------------------------------------
.PHONY: all clean

all: $(TARGET)

$(TARGET): $(OBJ)
	$(LD) -L$(LIBDIR) $(LDFLAGS)  -o $(TARGET) $(OBJ)

%.o: %.c
	$(CC) $(CFLAGS) -I$(HEADER) -o $@ $<

clean:
	rm -rf $(TARGET) $(OBJ)
