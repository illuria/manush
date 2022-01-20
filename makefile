VIPACK = "~/tmp/vipack/build/vipack"

all:
			$(VIPACK) -p skprJson -P `pwd` -t `pwd`/depTree
