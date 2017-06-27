NAME = keymaster
XCODE_FRAMEWORKS_DIR = /Applications/Xcode.app/Contents/Developer/Library/Frameworks
CC = gcc
CFLAGS = -Itest -isystem src -F $(XCODE_FRAMEWORKS_DIR)
LIBFLAGS = -lncurses
FRAMEWORKS = -framework AudioToolbox -framework CoreMIDI -framework Foundation
TEST_FRAMEWORKS = $(FRAMEWORKS) -framework XCTest
SRC = src/Chain.m src/Connection.m src/curses/Geometry.m src/curses/InfoWindow.m \
    src/curses/KMWindow.m src/curses/ListWindow.m src/curses/PatchWindow.m \
    src/curses/TriggerWindow.m src/Cursor.m src/InputInstrument.m src/Instrument.m \
    src/KeyMaster.m src/OutputInstrument.m src/PacketMessageIterator.m src/Patch.m \
    src/Reader.m src/Song.m src/Trigger.m src/curses/PromptWindow.m src/consts.m
OBJS = $(SRC:.m=.o)
MAIN = src/km.m
MAIN_OBJ = $(MAIN:.m=.o)
TESTNAME = test/kmtest
TEST_SRC = test/kmtest.m test/PatchTest.m test/ConnectionTest.m \
    test/MockInputInstrument.m test/MockOutputInstrument.m test/TriggerTest.m \
    test/PacketMessageIteratorTest.m test/ChainTest.m test/KeyMasterTest.m \
    test/OutputInstrumentTest.m test/ReaderTest.m test/ConstsTest.m
TEST_OBJS = $(TEST_SRC:.m=.o)

# ================================================================
# Building
# ================================================================

.PHONY: all
all:	PYMIDI $(NAME)

.PHONY: PYMIDI
PYMIDI:
	cd src/PYMIDI && make all

$(NAME):	$(OBJS) $(MAIN_OBJ) PYMIDI
	$(CC) $(LIBFLAGS) $(FRAMEWORKS) \
	    -o $(NAME) $(OBJS) $(MAIN_OBJ) src/PYMIDI/*.o

# ================================================================
# Testing
# ================================================================

.PHONY: test
test:	all $(TESTNAME)
	$(TESTNAME)

$(TESTNAME): $(OBJS) $(TEST_OBJS)
	$(CC) $(CFLAGS) $(LIBFLAGS) $(TEST_FRAMEWORKS) \
	    -o test/kmtest $(OBJS) $(TEST_OBJS) src/PYMIDI/*.o

# ================================================================
# Cleaning
# ================================================================

.PHONY: clean
clean:
	rm -f src/*.o src/curses/*.o test/*.o $(NAME) $(TESTNAME)

.PHONY: distclean
distclean:	clean
	rm -f src/PYMIDI/*.o

# ================================================================
# Dependencies
# ================================================================

src/Chain.o: src/Chain.m src/Chain.h src/Song.h

src/Connection.o: src/Connection.m src/Connection.h src/InputInstrument.h src/OutputInstrument.h src/PacketMessageIterator.h src/consts.h

src/curses/Geometry.o: src/curses/Geometry.m

src/curses/InfoWindow.h: src/curses/KMWindow.h

src/curses/InfoWindow.o: src/curses/InfoWindow.m src/curses/InfoWindow.h

src/curses/KMWindow.o: src/curses/KMWindow.m src/curses/KMWindow.h

src/curses/ListWindow.h: src/curses/KMWindow.h

src/curses/ListWindow.o: src/curses/ListWindow.m src/curses/ListWindow.h src/KeyMaster.h

src/curses/PatchWindow.h: src/curses/KMWindow.h

src/curses/PatchWindow.o: src/curses/PatchWindow.m src/curses/PatchWindow.h src/KeyMaster.h src/Patch.h src/Connection.h src/Instrument.h src/consts.h

src/curses/TriggerWindow.h: src/curses/KMWindow.h

src/curses/TriggerWindow.o: src/curses/TriggerWindow.m src/curses/TriggerWindow.h src/Trigger.h src/KeyMaster.h src/InputInstrument.h

src/Cursor.o: src/Cursor.m src/Cursor.h src/Chain.h src/Song.h src/Patch.h

src/InputInstrument.o: src/InputInstrument.m src/InputInstrument.h src/Instrument.h src/Trigger.h src/Connection.h

src/Instrument.o: src/Instrument.m src/Instrument.h src/PYMIDI/PYMIDI.h

src/KeyMaster.o: src/KeyMaster.m src/KeyMaster.h src/PYMIDI/PYMIDI.h src/Chain.h src/Song.h src/Patch.h src/Cursor.h src/InputInstrument.h src/OutputInstrument.h src/curses/Geometry.h src/curses/ListWindow.h src/curses/PatchWindow.h src/curses/TriggerWindow.h src/curses/InfoWindow.h src/curses/PromptWindow.h

src/OutputInstrument.o: src/OutputInstrument.m src/OutputInstrument.h src/Instrument.h src/consts.h

src/PacketMessageIterator.o: src/PacketMessageIterator.m src/PacketMessageIterator.h src/consts.h

src/Patch.o: src/Patch.m src/Patch.h src/Song.h src/Connection.h

src/Reader.o: src/Reader.m src/Reader.h src/PYMIDI/PYMIDI.h src/Reader.h src/KeyMaster.h src/Chain.h src/Song.h src/Patch.h src/Connection.h src/Trigger.h src/InputInstrument.h src/OutputInstrument.h src/consts.h

src/Song.o: src/Song.m src/Song.h src/Patch.h

src/Trigger.o: src/Trigger.m src/Trigger.h src/PacketMessageIterator.h src/KeyMaster.h

src/curses/PromptWindow.o: src/curses/PromptWindow.m src/curses/PromptWindow.h src/curses/Geometry.h

src/consts.o: src/consts.m src/consts.h

$(MAIN_OBJ): src/km.m src/KeyMaster.h src/Reader.h

# ================
# test dependencies
# ================

test/PatchTest.o: test/PatchTest.m src/KeyMaster.h test/MockInputInstrument.h test/MockOutputInstrument.h src/Patch.h src/Patch.m src/Connection.h

test/ConnectionTest.o: test/ConnectionTest.m src/KeyMaster.h test/MockInputInstrument.h test/MockOutputInstrument.h src/Connection.h src/Connection.m src/consts.h

test/MockInputInstrument.o: test/MockInputInstrument.m test/MockInputInstrument.h src/InputInstrument.h src/InputInstrument.m

test/MockOutputInstrument.o: test/MockOutputInstrument.m test/MockOutputInstrument.h src/OutputInstrument.h src/OutputInstrument.m

test/PacketMessageIteratorTest.o: test/PacketMessageIteratorTest.m src/PacketMessageIterator.h src/PacketMessageIterator.m src/consts.h

test/TriggerTest.o: test/TriggerTest.m src/Trigger.h src/Trigger.m src/consts.h src/KeyMaster.h

test/ChainTest.o: test/ChainTest.m src/Chain.h src/Chain.m src/Song.h

test/OutputInstrumentTest.o: test/OutputInstrumentTest.m test/MockOutputInstrument.o src/OutputInstrument.h src/OutputInstrument.m src/consts.h

test/KeyMasterTest.o: test/KeyMasterTest.m src/KeyMaster.h src/KeyMaster.m src/Chain.h src/Song.h test/MockOutputInstrument.o src/consts.h

test/ReaderTest.o: test/ReaderTest.m src/Reader.h src/Reader.m src/KeyMaster.h test/MockInputInstrument.h src/Trigger.h

test/ConstsTest.o: test/COnstsTest.m src/consts.h src/consts.m
