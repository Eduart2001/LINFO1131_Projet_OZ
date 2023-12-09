# ----------------------------
# TODO: Fill your group number, your NOMAs and your names
# group number 055
# 03132100 : ABDULLAHU Eduart
# NOMA2 : NAME2
# ----------------------------
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
	OZC = /Applications/Mozart2.app/Contents/Resources/bin/ozc
	OZENGINE = /Applications/Mozart2.app/Contents/Resources/bin/ozengine
else
	OZC = ozc
	OZENGINE = ozengine
endif


AGENT1 = "PacmOz055Basic.oz"
AGENT2 = "GhOzt055Advanced.oz"
all:
	$(OZC) -c Input.oz -o "Input.ozf"
	$(OZC) -c AgentManager.oz
	$(OZC) -c ${AGENT2} -o "GhOzt055Advanced.ozf"
	$(OZC) -c ${AGENT1} -o "PacmOz055Basic.ozf"
	$(OZC) -c Graphics.oz
	$(OZC) -c Main.oz
	$(OZENGINE) Main.ozf
run:
	$(OZENGINE) Main.ozf
clean:
	rm Input.ozf
	rm Graphics.ozf
	rm AgentManager.ozf
	rm Main.ozf
	rm PacmOz055Basic.ozf
	rm GhOzt055Basic.ozf