# ----------------------------
# group number 055
# 03132100 : ABDULLAHU Eduart
# 03142100 : Antúnez García Isaías
# ----------------------------
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
	OZC = /Applications/Mozart2.app/Contents/Resources/bin/ozc
	OZENGINE = /Applications/Mozart2.app/Contents/Resources/bin/ozengine
else
	OZC = ozc
	OZENGINE = ozengine
endif


AGENT1 = "PacmOz055Advanced.oz"
AGENT2 = "GhOzt055Advanced.oz"
all:
	$(OZC) -c Input.oz -o "Input.ozf"
	$(OZC) -c AgentManager.oz
	$(OZC) -c ${AGENT2} -o "GhOzt055Advanced.ozf"
	$(OZC) -c ${AGENT1} -o "PacmOz055Advanced.ozf"
	$(OZC) -c Graphics.oz
	$(OZC) -c Main.oz
	$(OZENGINE) Main.ozf
run:
	
clean:
	rm *.ozf
