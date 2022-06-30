.POSIX:

CFLAGS   =

# The following order is important, do not alphabetise
DEPS     = norayr/lists      \
	   norayr/opts       \
	   norayr/time       \
	   norayr/skprLogger \
	   norayr/skprJson

GITHUB   = https://github.com/

all: deps build_deps

deps:
	@for i in ${DEPS}; do                                     \
		if [ -d deps/$${i#*/} ]; then                     \
			printf "Updating %s: " $${i#*/};          \
			git -C deps/$${i#*/} pull                 \
				> /dev/null 2>&1                  \
				&& echo done                      \
				|| (echo failed && exit 1);       \
		else                                              \
			printf "Fetching %s: " $${i#*/};          \
			git clone ${GITHUB}$$i deps/$${i#*/}      \
				> /dev/null 2>&1                  \
				&& (echo done || echo failed);    \
		fi                                                \
	done

build_deps:
	@if [ ! -d build ]; then \
		mkdir build;     \
	fi
	@for i in ${DEPS:T}; do                    \
		ln -sf  ${.CURDIR}/build           \
			${.CURDIR}/deps/$$i/build; \
		make -C ${.CURDIR}/deps/$$i;       \
	done
	@cd build; voc -s  ${.CURDIR}/src/mnshList.Mod     \
			   ${.CURDIR}/src/mnshDefs.Mod     \
			   ${.CURDIR}/src/mnshStorage.Mod  \
			   ${.CURDIR}/src/mnshExtTools.Mod \
			   ${.CURDIR}/src/mnshInput.Mod \
			   ${.CURDIR}/src/mnshTerm.Mod \
			   ${.CURDIR}/src/vt100.Mod \
			   ${.CURDIR}/src/manush.Mod -M

clean:
	rm -rf build deps

.PHONY: deps
