DEMO:=SimpleTrees

run: $(DEMO).mfz
#	../../MFM/bin/mfzrun $(DEMO).mfz
#	../../MFM/bin/mfzrun $(DEMO).mfz run {{1F1}}
	mfzrun $(DEMO).mfz run {{1F1}}

$(DEMO).mfz: *.ulam
#	../../ULAM/bin/ulam --verbose --showcommands $^ $@
#	../../ULAM/bin/ulam $^ $@
	ulam $^ $@

uc: *.ulam
#	../../ULAM/bin/ulam --ulamcompile $^
	ulam --ulamcompile $^

clean:
	rm -f $(DEMO).mfz

cleanall: clean
	rm -rf .gen
