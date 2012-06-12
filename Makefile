CC = gcc
CFLAGS = -Os -Wall
LDFLAGS = -lbz2
SOFLAGS = -fpic -shared

# FIXME: Assumes you have GCC 4.4 installed for building on OS X
ifeq ($(shell uname),Darwin)
CC = gcc-mp-4.4
endif

ifeq ($(shell pkg-config --exists lua5.1; echo $$?),0)
PFLAGS = $(shell pkg-config --cflags lua5.1)
else
PFLAGS = $(shell pkg-config --cflags lua)
endif

SOURCES = lbz.c lbz2_file_reader.c lbz2_file_writer.c lbz2_stream.c lbz2_common.c

bz2.so: $(SOURCES)
	$(CC) $(SOFLAGS) $(PFLAGS) $(CFLAGS) $(SOURCES) $(LDFLAGS) -o bz2.so

clean:
	-rm -f bz2.so

test: bz2.so
	lua test.lua
