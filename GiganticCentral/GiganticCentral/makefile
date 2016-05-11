C=clang++
CC=clang++
FLEX=flex++
BISON=bison

CFILES:=$(shell ls *.c)
CPPFILES:=$(shell ls | grep .cpp)
COBJECTS=$(CFILES:.c=.o)
CPPOBJECTS+=$(CPPFILES:.cpp=.opp)
TARGET = NLP
UNAME_S := $(shell uname -s)
    CPPFLAGS += -lsqlite3 -ll 
    ifeq ($(UNAME_S),Linux)
        CPPFLAGS += -fblocks -ldispatch -lkqueue -lpthread_workqueue -lBlocksRuntime -all_load -lstdc++
    endif
    ifeq ($(UNAME_S),Darwin)
        CPPFLAGS += 
    endif

all: $(TARGET)

clean: 
	rm -rf lex.yy.* NLP.tab.* *.o NLP.output *.opp $(TARGET)

$(TARGET): $(COBJECTS) $(CPPOBJECTS) lex.yy.cc NLP.tab.c
	$(CC) -o $@ $^ -Xlinker -lstdc++ $(CPPFLAGS)
    
%.opp: %.cpp
	$(CC) -c -o $@ $< $(CPPFLAGS)
%.o: %.c
	$(C) -c -o $@ $< $(CFLAGS)
Grammar.lex.yy.cc: Grammar.lex
	$(FLEX) -+ NLP.lex
    
Grammar.tab.c: Grammar.y
	$(BISON) -d -v -t NLP.y
