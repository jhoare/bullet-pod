DL_LINK = https://github.com/bulletphysics/bullet3/archive/2.83.6.tar.gz
DL_NAME = 2.83.6.tar.gz
UNZIP_DIR = bullet3-2.83.6

BUILD_SYSTEM:=$(OS)
ifeq ($(BUILD_SYSTEM),Windows_NT)
BUILD_SYSTEM:=$(shell uname -o 2> uname.err || echo Windows_NT) # set to Cygwin if appropriate
else
BUILD_SYSTEM:=$(shell uname -s)
endif
BUILD_SYSTEM:=$(strip $(BUILD_SYSTEM))

# Figure out where to build the software.
#   Use BUILD_PREFIX if it was passed in.
#   If not, search up to four parent directories for a 'build' directory.
#   Otherwise, use ./build.
ifeq ($(BUILD_SYSTEM), Windows_NT)
ifeq "$(BUILD_PREFIX)" ""
BUILD_PREFIX:=$(shell (for %%x in (. .. ..\.. ..\..\.. ..\..\..\..) do ( if exist %cd%\%%x\build ( echo %cd%\%%x\build & exit ) )) & echo %cd%\build )
endif
# don't clean up and create build dir as I do in linux.  instead create it during configure.
else
ifeq "$(BUILD_PREFIX)" ""
BUILD_PREFIX:=$(shell for pfx in ./ .. ../.. ../../.. ../../../..; do d=`pwd`/$$pfx/build;\
               if [ -d $$d ]; then echo $$d; exit 0; fi; done; echo `pwd`/build)
endif
# create the build directory if needed, and normalize its path name
BUILD_PREFIX:=$(shell mkdir -p $(BUILD_PREFIX) && cd $(BUILD_PREFIX) && echo `pwd`)
endif

BULLET_OPTIONS:= -DINSTALL_LIBS=on \
		 -DBUILD_DEMOS=off \
		 -DUSE_DOUBLE_PRECISION=on \
		 -DUSE_DX11=off # easier to get it building on windows.  might want to re-enable

ifeq "$(BUILD_SYSTEM)" "Cygwin"
  BUILD_PREFIX:=$(shell cygpath -m $(BUILD_PREFIX))
else
BULLET_OPTIONS:=$(BULLET_OPTIONS) -DBUILD_SHARED_LIBS=on   # shared libs doesn't work with msvc (there aren't any dllexports defined) 
endif

# Default to a release build.  If you want to enable debugging flags, run
# "make BUILD_TYPE=Debug"
ifeq "$(BUILD_TYPE)" ""
BUILD_TYPE="Release"
endif

SED=sed
ifeq ($(shell uname), Darwin)
  SED=gsed
endif

BULLET_INSTALL_LIBS = libBullet3OpenCL_clew.2.83.dylib \
	libBullet2FileLoader.2.83.dylib \
	libBullet3Dynamics.2.83.dylib \
	libBullet3Collision.2.83.dylib \
	libBullet3Geometry.2.83.dylib \
	libBullet3Common.2.83.dylib \
	libBulletSoftBody.2.83.dylib \
	libBulletCollision.2.83.dylib \
	libBulletDynamics.2.83.dylib \
	libLinearMath.2.83.dylib 

all: pod-build/Makefile
	cmake --build pod-build --config $(BUILD_TYPE) --target install
ifeq ($(shell uname), Darwin)
	@for lib in $(BULLET_INSTALL_LIBS); do \
		install_name_tool -id $(BUILD_PREFIX)/lib/$$lib $(BUILD_PREFIX)/lib/$$lib; \
		for deplib in $(BULLET_INSTALL_LIBS); do \
			install_name_tool -change $$deplib $(BUILD_PREFIX)/lib/$$deplib $(BUILD_PREFIX)/lib/$$lib; \
		done; \
	done
endif

pod-build/Makefile:
	$(MAKE) configure

.PHONY: configure
configure: $(UNZIP_DIR)/CMakeLists.txt
	@echo "\nBUILD_PREFIX: $(BUILD_PREFIX)\n\n"

	# create the temporary build directory if needed
	@mkdir -p pod-build

	# run CMake to generate and configure the build scripts
	@cd pod-build && cmake $(CMAKE_FLAGS) -DCMAKE_INSTALL_PREFIX=$(BUILD_PREFIX) $(BULLET_OPTIONS) \
		-DCMAKE_BUILD_TYPE=$(BUILD_TYPE) ../$(UNZIP_DIR)

$(DL_NAME) : 
	wget --no-check-certificate $(DL_LINK) -O $(DL_NAME)


$(UNZIP_DIR)/CMakeLists.txt: bullet_gjk_accuracy_patch.diff $(DL_NAME)
	tar -xzf $(DL_NAME)	
	$(SED) -i -e 's@share/pkgconfig@lib/pkgconfig@g' $(UNZIP_DIR)/CMakeLists.txt
	patch -p0 -i bullet_gjk_accuracy_patch.diff
	mv $(UNZIP_DIR)/src/LinearMath/btScalar.h $(UNZIP_DIR)/src/LinearMath/btScalar.h.in
	patch -p0 -i bullet_double_precision_patch.diff
	patch -p0 -i bullet_windows_pkgconfig.diff

clean:
	-if [ -e pod-build/install_manifest.txt ]; then rm -f `cat pod-build/install_manifest.txt`; fi
	-if [ -d pod-build ]; then $(MAKE) -C pod-build clean; rm -rf pod-build; fi

# Default to a less-verbose build.  If you want all the gory compiler output,
# run "make VERBOSE=1"
$(VERBOSE).SILENT:

