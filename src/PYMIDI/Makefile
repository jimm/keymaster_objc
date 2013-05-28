# This simple Makefile is sufficient because this code doesn't change.

CC = gcc
CFLAGS = -isystem .. -fobjc-gc-only

all:	PYMIDIManager.o

PYMIDIManager.o: PYMIDIManager.m
	$(CC) $(CFLAGS) -c *.m

clean:
	rm -f *.o
