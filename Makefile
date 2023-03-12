DEMO:=SimpleTrees

run: $(DEMO).mfz
#	../../MFM/bin/mfzrun $(DEMO).mfz
	../../MFM/bin/mfzrun $(DEMO).mfz run {{1F1}}

$(DEMO).mfz: *.ulam
#	../../ULAM/bin/ulam --verbose --showcommands $^ $@
	../../ULAM/bin/ulam $^ $@

uc: *.ulam
	../../ULAM/bin/ulam --ulamcompile $^

clean:
	rm -f $(DEMO).mfz
