all: test main1

main1: child_sig.o
	gcc child_sig.o -o main1

test: test.o 
	gcc test.o -o test
clean:
	-@rm -f *~ *.o main1 test
	@echo "All clean"
