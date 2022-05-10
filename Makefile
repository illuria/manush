mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
mkfile_dir_path := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
build_dir_path := $(mkfile_dir_path)/build
current_dir := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))
DPS = dps

CFLAGS=

PACKAGES=github.com/norayr/lists github.com/norayr/time github.com/norayr/skprLogger github.com/norayr/skprJson

all: get_deps build_deps

get_deps:
	mkdir -p $(mkfile_dir_path)/$(DPS)
	if [ -d $(DPS)/lists ]; then cd $(DPS)/lists; git pull; cd -; else cd $(DPS); git clone https://github.com/norayr/lists; cd -; fi
	if [ -d $(DPS)/time ]; then cd $(DPS)/time; git pull; cd -; else cd $(DPS); git clone https://github.com/norayr/time; cd -; fi
	if [ -d $(DPS)/skprLogger ]; then cd $(DPS)/skprLogger; git pull; cd -; else cd $(DPS); git clone https://github.com/norayr/skprLogger; cd -; fi
	if [ -d $(DPS)/skprJson ]; then cd $(DPS)/skprJson; git pull; cd -; else cd $(DPS); git clone https://github.com/norayr/skprJson; cd -; fi
	#$(foreach PKG,$(PACKAGES),$(call download_dep,$(PKG), $(strip $(notdir $(PKG)))))

build_deps:
	gmake -f $(mkfile_dir_path)/dps/lists/makefile BUILD=$(build_dir_path)
	gmake -f $(mkfile_dir_path)/dps/time/makefile BUILD=$(build_dir_path)
	gmake -f $(mkfile_dir_path)/dps/skprLogger/makefile BUILD=$(build_dir_path)
	gmake -f $(mkfile_dir_path)/dps/skprJson/makefile BUILD=$(build_dir_path)
	cd $(build_dir_path) && \
	voc -s ../src/mnshList.Mod ../src/mnshDefs.Mod ../src/mnshStorage.Mod ../src/mnshExtTools.Mod ../src/manush.Mod -M

clean:
	rm -rf build/*
