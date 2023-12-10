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


AGENT1="PacmOz055Basic.oz"
AGENT2="GhOzt055Basic.oz"
AGENT3 = "./extension/PacmOz055Advanced.oz"
AGENT4 = "./extension/GhOzt055Advanced.oz"

all:
	$(OZC) -c Input.oz -o "Input.ozf"
	$(OZC) -c AgentManager.oz
	$(OZC) -c ${AGENT3} -o "./extension/PacmOz055Advanced.ozf"
	$(OZC) -c ${AGENT4} -o "./extension/GhOzt055Advanced.ozf"
	$(OZC) -c "./extension/GraphStyles.oz" -o "./extension/GraphStyles.ozf"
	$(OZC) -c Graphics.oz
	$(OZC) -c Main.oz
run:
	$(OZENGINE) Main.ozf
clean:
	rm *.ozf

	rm ./extension/*.ozf
