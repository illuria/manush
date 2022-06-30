.POSIX:

CFLAGS   =

# The following order is important, do not alphabetise
DEPS     = norayr/lists      \
	   norayr/opts       \
	   norayr/time       \
	   norayr/skprLogger \
	   norayr/skprJson

GITHUB   = https://github.com/

ROOTDIR  = $$PWD

all: ${DEPS}
	@if [ ! -d build ]; then \
		mkdir build;     \
	fi
	@for i in $?; do                                \
		ln -sf  ${ROOTDIR}/build                \
			${ROOTDIR}/deps/$${i#*/}/build; \
		make -C ${ROOTDIR}/deps/$${i#*/};       \
	done
	@cd build; voc -s  ${ROOTDIR}/../src/mnshList.Mod     \
			   ${ROOTDIR}/../src/mnshDefs.Mod     \
			   ${ROOTDIR}/../src/mnshStorage.Mod  \
			   ${ROOTDIR}/../src/mnshExtTools.Mod \
			   ${ROOTDIR}/../src/manush.Mod -M


${DEPS}:
	@for i in $@; do                                          \
		if [ -d deps/$${i#*/} ]; then                     \
			printf "Updating %s: " $${i#*/};          \
			git -C deps/$${i#*/} pull --ff-only       \
				${GITHUB}$$i > /dev/null 2>&1     \
				&& echo done                      \
				|| (echo failed && exit 1);       \
		else                                              \
			printf "Fetching %s: " $${i#*/};          \
			git clone ${GITHUB}$$i deps/$${i#*/}      \
				> /dev/null 2>&1                  \
				&& echo done                      \
				|| (echo failed && exit 1);       \
		fi                                                \
	done

clean:
	rm -rf build deps

.PHONY: deps
