#!/bin/sh%

if [ "$#" -lt 2 ]; then
	echo "Usage: create_project name path"
	exit 1
fi

PROJ_NAME=$1
PROJ_PATH=$2

PROJ_DIR="${PROJ_PATH}/${PROJ_NAME}"

echo "Generating $PROJ_DIR"

mkdir -p "$PROJ_DIR"
if [ "$?" -ne 0 ]; then
	echo "Failed to create project directory $PROJ_DIR" 1>&2
	exit 1
fi

mkdir -p "${PROJ_DIR}/include/${PROJ_NAME}"
if [ "$?" -ne 0 ]; then
	echo "Failed to create project include directory ${PROJ_DIR}/include/${PROJ_NAME}" 1>&2
	exit 1
fi

mkdir -p "${PROJ_DIR}/src"
if [ "$?" -ne 0 ]; then
	echo "Failed to create project source directory ${PROJ_DIR}/src" 1>&2
	exit 1
fi

#===============================================================================
# *PhysicsModel.h
#===============================================================================

PHYSICSMODEL_HEADER="${PROJ_DIR}/include/${PROJ_NAME}/${PROJ_NAME}PhysicsModel.h"

echo "#ifndef ${PROJ_NAME}_PHYSICSMODEL_H
#define ${PROJ_NAME}_PHYSICSMODEL_H

#include <deque>
#include <functional>
#include <tuple>
#include <vector>
#include <PhysTools/histogram.h>
#include <PhysTools/likelihood/likelihood.h>
#include <PhysTools/likelihood/physics_weighters.h>
#include <PhysTools/optimization/ParameterSet.h>

class ${PROJ_NAME}PhysicsModel{
public:
	//Change the constructor to take any additional arguments you want
	${PROJ_NAME}PhysicsModel();

	//!!! Change this to the number of parameters in your model
	static constexpr unsigned int NParameters = 0;

	struct Event{
		//!!! Put variables here for your observables and 
		//    anything you need to compute your weights
	};

	struct WeighterMaker{
		const phys_tools::ParameterSet& p;

		WeighterMaker(const phys_tools::ParameterSet& p): p(p) {}

		template<typename DataType>
		std::function<DataType(const Event&)> operator()(const std::vector<DataType>& params) const {
			//!!! Put the code to implement your weight calculation here
		}
	};

	struct UncertaintyWeighter{
		UncertaintyWeighter() {}
		
		template<typename DataType>
		DataType operator()(const Event& e, const DataType& w) const {
			return w*w;
		}
	};

	struct Prior{
		const phys_tools::ParameterSet& p;
		//Add any other members you need here

		Prior(const phys_tools::ParameterSet& p):p(p)
		//Initialize any members you added here
		{}

		template<typename DataType>
		DataType operator()(const std::vector<DataType>& parameters) const {
			//Compute and return any prior you want here.
			return 1.;
		}
	};

	template<unsigned int Dimension>
	using histogram=phys_tools::histograms::histogram<Dimension, phys_tools::likelihood::entryStoringBin<std::reference_wrapper<const Event>>>;

	using HistogramSet = std::tuple<
		//!!! Put the types of histograms you want to fit here
	>;

	HistogramSet MakeHistogramSet() const;

	void AddEventToHistogram(HistogramSet& h, const Event& e) const;
	
	phys_tools::ParameterSet MakeParameterSet() const;

	WeighterMaker MakeWeigherMaker(const phys_tools::ParameterSet& params) const;

	UncertaintyWeighter MakeUncertaintyWeighter() const;

	Prior MakePrior(const phys_tools::ParameterSet& params) const;

private:
	//Add any member variables here
};

#endif //${PROJ_NAME}_PHYSICSMODEL_H
" > $PHYSICSMODEL_HEADER
if [ "$?" -ne 0 ]; then
	echo "Failed to write template header file $PHYSICSMODEL_HEADER" 1>&2
	exit 1
fi

#===============================================================================
# *PhysicsModel.cpp
#===============================================================================
PHYSICSMODEL_IMPL="${PROJ_DIR}/src/${PROJ_NAME}PhysicsModel.cpp"
echo "#include <${PROJ_NAME}/${PROJ_NAME}PhysicsModel.h>

//Change the constructor to initialize any member variables that you add
${PROJ_NAME}PhysicsModel::${PROJ_NAME}PhysicsModel(){}

${PROJ_NAME}PhysicsModel::HistogramSet 
${PROJ_NAME}PhysicsModel::MakeHistogramSet() const{
	//!!! Construct your histograms here
	
	HistogramSet h = std::make_tuple( /* insert histograms */ );
	return h;
}

void ${PROJ_NAME}PhysicsModel::AddEventToHistogram(HistogramSet& h, const Event& e) const{
	//!!! Write code here to put e into h
}

phys_tools::ParameterSet ${PROJ_NAME}PhysicsModel::MakeParameterSet() const{
	phys_tools::ParameterSet parameters;

	//!!! Define your parameters here
	//The number of parameters you add should match NParameters

	return parameters;
}

${PROJ_NAME}PhysicsModel::WeighterMaker
${PROJ_NAME}PhysicsModel::MakeWeigherMaker(const phys_tools::ParameterSet& params) const{
	//Change this code if your WeighterMaker takes any other arguments
	return WeighterMaker(params);
}

${PROJ_NAME}PhysicsModel::UncertaintyWeighter 
${PROJ_NAME}PhysicsModel::MakeUncertaintyWeighter() const{
	return UncertaintyWeighter();
}

${PROJ_NAME}PhysicsModel::Prior 
${PROJ_NAME}PhysicsModel::MakePrior(const phys_tools::ParameterSet& params) const{
	//Change this code if your Prior takes any other arguments
	return Prior(params);
}
" > $PHYSICSMODEL_IMPL

#===============================================================================
# *DataLoader.h
#===============================================================================

DATALOADER_HEADER="${PROJ_DIR}/include/${PROJ_NAME}/${PROJ_NAME}DataLoader.h"

echo "#ifndef ${PROJ_NAME}_DATALOADER_H
#define ${PROJ_NAME}_DATALOADER_H

#include <deque>
#include <PhysTools/tableio.h>
#include <LeptonWeighter/ParticleType.h>

class ${PROJ_NAME}DataLoader{
public:
	struct Event{
		//Define the properties you want for each event you will read in
	};
	${PROJ_NAME}DataLoader();
protected:
	void readFile(const std::string& filePath,
                  std::function<void(phys_tools::tableio::RecordID,Event&)> action) const;
public:
	std::deque<Event> GetSimulationEvents() const;
	std::deque<Event> GetDataEvents() const;
};

#endif //${PROJ_NAME}_DATALOADER_H
" > $DATALOADER_HEADER

#===============================================================================
# *DataLoader.cpp
#===============================================================================

DATALOADER_IMPL="${PROJ_DIR}/src/${PROJ_NAME}DataLoader.cpp"

echo "#include <${PROJ_NAME}/${PROJ_NAME}DataLoader.h>

${PROJ_NAME}DataLoader::${PROJ_NAME}DataLoader(){}

void 
${PROJ_NAME}DataLoader::readFile(const std::string& filePath,
  std::function<void(phys_tools::tableio::RecordID,Event&)> action) const{
	using namespace phys_tools::cts;
	phys_tools::tableio::H5File h5file(filePath);
	if(!h5file)
		throw std::runtime_error(\"Unable to open \"+filePath);
	std::set<std::string> tables=phys_tools::tableio::getTables(h5file,\"/\");
	if(tables.empty())
		throw std::runtime_error(filePath+\" contains no tables\");
	std::map<phys_tools::tableio::RecordID,Event> intermediateData;

	//Put code here to read all tables of interest from the file

	for(std::map<phys_tools::tableio::RecordID,Event>::value_type& item : intermediateData)
		action(item.first,item.second);
}

std::deque<${PROJ_NAME}DataLoader::Event> ${PROJ_NAME}DataLoader::GetSimulationEvents() const{
	//Write code here to read whatever files contain the simulated data
}

std::deque<${PROJ_NAME}DataLoader::Event> ${PROJ_NAME}DataLoader::GetDataEvents() const{
	//Write code here to read whatever files contain the observed data
}

" > $DATALOADER_IMPL

#===============================================================================
# *configure
#===============================================================================

CONFIGURATION_SCRIPT="${PROJ_DIR}/configure"

echo "#!/bin/sh

check_pkgconfig(){
	if [ \"\$CHECKED_PKGCONFIG\" ]; then return; fi
	echo \"Looking for pkg-config...\"
	which pkg-config 2>&1 > /dev/null
	if [ \"\$?\" -ne 0 ]; then
		echo \"Error: pkg-config not found; you will need to specify library locations manually\" 1>&2
		exit 1
	fi
	CHECKED_PKGCONFIG=1
}

find_package(){
	PKG=\$1
	VAR_PREFIX=\`echo \$PKG | tr [:lower:] [:upper:]\`
	TMP_FOUND=\`eval echo \"\$\"\${VAR_PREFIX}_FOUND\`
	if [ \"\$TMP_FOUND\" ]; then return; fi
	check_pkgconfig
	echo \"Looking for \$PKG...\"

	pkg-config --exists \$PKG
	if [ \"\$?\" -ne 0 ]; then
		echo \" \$PKG not found with pkg-config\"
		return
	fi
	if [ \$# -ge 2 ]; then
		MIN_VERSION=\$2
		pkg-config --atleast-version \$MIN_VERSION \$PKG
		if [ \"\$?\" -ne 0 ]; then
			echo \"Error: installed \$PKG version (\"\`pkg-config --modversion \$PKG\`\") is too old; version >=\$MIN_VERSION is required\" 1>&2
			exit 1
		fi
	fi
	echo \" Found \$PKG version \`pkg-config --modversion \$PKG\`\"
	eval \${VAR_PREFIX}_FOUND=1
	eval \${VAR_PREFIX}_VERSION=\\\"\`pkg-config --modversion \$PKG\`\\\"
	eval \${VAR_PREFIX}_CFLAGS=\\\"\`pkg-config --cflags \$PKG\`\\\"
	eval \${VAR_PREFIX}_LDFLAGS=\\\"\`pkg-config --libs \$PKG\`\\\"
	eval \${VAR_PREFIX}_INCDIR=\\\"\`pkg-config --variable=includedir \$PKG\`\\\"
	eval \${VAR_PREFIX}_LIBDIR=\\\"\`pkg-config --variable=libdir \$PKG\`\\\"
}

find_hdf5(){
	PKG=hdf5
	echo \"Looking for \$PKG...\"
	VAR_PREFIX=\`echo \$PKG | tr [:lower:] [:upper:]\`
	TMP_FOUND=\`eval echo \"\$\"\${VAR_PREFIX}_FOUND\`
	if [ \"\$TMP_FOUND\" ]; then return; fi

	which h5cc 2>&1 > /dev/null
	if [ \"\$?\" -ne 0 ]; then return; fi

	which h5ls 2>&1 > /dev/null
	if [ \"\$?\" -eq 0 ]; then
		HDF5_VERSION=\`h5ls --version | sed 's/.* \\([0-9.]*\\)/\\1/'\`
		echo \" Found \$PKG version \$HDF5_VERSION via executables in \\\$PATH\"
		if [ \$# -ge 1 ]; then
			MIN_VERSION=\$1
			#TODO: actually check version
		fi
	else
		echo \" h5ls not found; cannot check \$PKG version\"
		echo \" Proceeding with unknown version and hoping for the best\"
	fi
	HDF5_COMPILE_COMMAND=\`h5cc -show\`
	for item in \$HDF5_COMPILE_COMMAND; do
		item=\`echo \"\$item\" | sed 's| | \\\\n|g' | sed -n 's/.*-L\\([^ ]*\\).*/\\1/p'\`
		if [ -n \"\$item\" ]; then
			POSSIBLE_HDF5_LIBDIRS=\"\$POSSIBLE_HDF5_LIBDIRS
				\$item\"
		fi
	done
	for HDF5_LIBDIR in \$POSSIBLE_HDF5_LIBDIRS; do
		if [ -d \$HDF5_LIBDIR -a \\( -e \$HDF5_LIBDIR/libhdf5.a -o -e \$HDF5_LIBDIR/libhdf5.so \\) ]; then
			break
		fi
	done
	if [ ! -d \$HDF5_LIBDIR -o ! \\( -e \$HDF5_LIBDIR/libhdf5.a -o -e \$HDF5_LIBDIR/libhdf5.so \\) ]; then
		echo \" Unable to guess \$PKG library directory\"
		return
	fi
	POSSIBLE_HDF5_INCDIRS=\`echo \"\$HDF5_COMPILE_COMMAND\" | sed 's| |\\\\n|g' | sed -n 's/.*-I\\([^ ]*\\).*/\\1/p'\`
	POSSIBLE_HDF5_INCDIRS=\"\$POSSIBLE_HDF5_INCDIRS \${HDF5_LIBDIR}/../include\"
	for HDF5_INCDIR in \$POSSIBLE_HDF5_INCDIRS; do
		if [ -d \$HDF5_INCDIR -a -e \$HDF5_INCDIR/H5version.h ]; then
			break
		fi
	done
	if [ ! -d \$HDF5_INCDIR -o ! \$HDF5_INCDIR/H5version.h ]; then
		echo \" Unable to guess \$PKG include directory\"
		return
	fi

	HDF5_CFLAGS=\"-I\${HDF5_INCDIR}\"
	HDF5_LDFLAGS=\`echo \"\$HDF5_COMPILE_COMMAND\" | \\
	sed 's/ /\\\\
	/g' | \\
	sed -n -E \\
	-e '/^[[:space:]]*-l/p' \\
	-e '/^[[:space:]]*-L/p' \\
	-e '/^[[:space:]]*-Wl,/p' \\
	-e 's/^[[:space:]]*.*lib([^.]*)\\.a/-l\\1/p' \\
	-e 's/^[[:space:]]*.*lib([^.]*)\\.so/-l\\1/p' \\
	-e 's/^[[:space:]]*.*lib([^.]*)\\.dylib/-l\\1/p' \`
	HDF5_LDFLAGS=\`echo \$HDF5_LDFLAGS\` # collapse to single line

	HDF5_FOUND=1
}

try_find_boost(){
	GUESS_DIR=\$1
	PKG=boost
	VAR_PREFIX=\`echo \$PKG | tr [:lower:] [:upper:]\`
	TMP_FOUND=\`eval echo \"\$\"\${VAR_PREFIX}_FOUND\`
	if [ \"\$TMP_FOUND\" ]; then return; fi
	echo \"Looking for \$PKG in \$GUESS_DIR...\"
	POSSIBLE_BOOST_LIBDIRS=\"\${GUESS_DIR}/lib \${GUESS_DIR}/lib64 \${GUESS_DIR}/lib/x86_64-linux-gnu\"
	POSSIBLE_BOOST_INCDIRS=\"\${GUESS_DIR}/include\"
	for BOOST_LIBDIR in \$POSSIBLE_BOOST_LIBDIRS; do
		if [ -d \$BOOST_LIBDIR -a \\( -e \$BOOST_LIBDIR/libboost_python.a -o -e \$BOOST_LIBDIR/libboost_python.so \\) ]; then
			break
		fi
	done
	if [ ! -d \$BOOST_LIBDIR -o ! \\( -e \$BOOST_LIBDIR/libboost_python.a -o -e \$BOOST_LIBDIR/libboost_python.so \\) ]; then
		echo \" Unable to locate the boost_python libray in \$GUESS_DIR\"
		return
	fi
	for BOOST_INCDIR in \$POSSIBLE_BOOST_INCDIRS; do
		if [ -d \$BOOST_INCDIR -a -e \$BOOST_INCDIR/boost/python.hpp ]; then
			break
		fi
	done
	if [ ! -d \$BOOST_INCDIR -o ! \$BOOST_INCDIR/boost/python.hpp ]; then
		echo \" Unable to locate boost/python.hpp in \$GUESS_DIR\"
		return
	fi
	BOOST_CFLAGS=\"-I\${BOOST_INCDIR}\"
	BOOST_LDFLAGS=\"-Wl,-rpath -Wl,\${BOOST_LIBDIR} -L\${BOOST_LIBDIR} -lboost_python\"
	BOOST_FOUND=1
	echo \" Found boost in \$GUESS_DIR\"
}

PHOTOSPLINE_CONFIG=\"photospline-config\"
try_find_photospline(){
  which \"\$PHOTOSPLINE_CONFIG\" 2>&1 > /dev/null
  if [ \"\$?\" -ne 0 ]; then return; fi

  PHOTOSPLINE_VERSION=\`\$PHOTOSPLINE_CONFIG --version\`
  PHOTOSPLINE_CFLAGS=\`\$PHOTOSPLINE_CONFIG --cflags\`
  PHOTOSPLINE_LDFLAGS=\`\$PHOTOSPLINE_CONFIG --libs\`
  PHOTOSPLINE_FOUND=1
}

ensure_found(){
	PKG=\$1
	VAR_PREFIX=\`echo \$PKG | tr [:lower:] [:upper:]\`
	TMP_FOUND=\`eval echo \"$\"\${VAR_PREFIX}_FOUND\`
	if [ \"\$TMP_FOUND\" ]; then return; fi
	#not found
	echo \"Error: \$PKG not installed or not registered with pkg-config\" 1>&2
	lowername=\`echo \$PKG | tr [A-Z] [a-z]\`
	echo \"Please specify location using the --with-\"\$lowername\" flag\" 1>&2
	exit 1
}

PREFIX=/usr/local

VERSION_NUM=100000
VERSION=\`echo \$VERSION_NUM | awk '{
	major = int(\$1/100000);
	minor = int(\$1/100)%1000;
	patch = \$1%100;
	print major\".\"minor\".\"patch;
}'\`

OS_NAME=\`uname -s\`

GUESS_CC=gcc
GUESS_CXX=g++
GUESS_AR=ar
GUESS_LD=ld
if [ \"\$OS_NAME\" = Linux ]; then
	DYN_SUFFIX=.so
	DYN_OPT='-shared -Wl,-soname,\$(shell basename \$(DYN_PRODUCT))'
fi
if [ \"\$OS_NAME\" = Darwin ]; then
	GUESS_CC=clang
	GUESS_CXX=clang++
	GUESS_LD=clang++
	DYN_SUFFIX=.dylib
  DYN_OPT='-dynamiclib -compatibility_version \$(VERSION) -current_version \$(VERSION)'
fi

CC=\${CC-\$GUESS_CC}
CXX=\${CXX-\$GUESS_CXX}
AR=\${AR-\$GUESS_AR}
LD=\${LD-\$GUESS_LD}

PYTHON_EXE=\"python\"

HELP=\"Usage: ./configure [OPTION]...

Installation directories:
  --prefix=PREFIX         install files in PREFIX
                          [\$PREFIX]

By default, \\\`make install' will install all the files in
\\\`\$PREFIX/bin', \\\`\$PREFIX/lib' etc.  You can specify
an installation prefix other than \\\`\$PREFIX' using \\\`--prefix',
for instance \\\`--prefix=\$HOME'.

The following options can be used to maunally specify the 
locations of dependencies:
  --with-gsl=DIR           use the copy of GSL in DIR
                           assuming headers are in DIR/include
                           and libraries in DIR/lib
  --with-gsl-incdir=DIR    use the copy of GSL in DIR
  --with-gsl-libdir=DIR    use the copy of GSL in DIR
  --with-hdf5=DIR          use the copy of HDF5 in DIR
                           assuming headers are in DIR/include
                           and libraries in DIR/lib
  --with-hdf5-incdir=DIR   use the copy of HDF5 in DIR
  --with-hdf5-libdir=DIR   use the copy of HDF5 in DIR
  --with-squids=DIR        use the copy of SQuIDS in DIR
                           assuming headers are in DIR/include
                           and libraries in DIR/lib
  --with-squids-incdir=DIR        use the copy of SQuIDS in DIR
  --with-squids-libdir=DIR        use the copy of SQuIDS in DIR
  --with-nusquids=DIR        use the copy of nuSQuIDS in DIR
                             assuming headers are in DIR/include
                             and libraries in DIR/lib
  --with-nusquids-incdir=DIR        use the copy of nuSQuIDS in DIR
  --with-nusquids-libdir=DIR        use the copy of nuSQuIDS in DIR
  --with-phystools=DIR        use the copy of PhysTools in DIR
                             assuming headers are in DIR/include
                             and libraries in DIR/lib
  --with-phystools-incdir=DIR        use the copy of PhysTools in DIR
  --with-phystools-libdir=DIR        use the copy of PhysTools in DIR

  --with-photospline-config=EXE  use this photospline-config
For the python bindings the following flags are used:
  --with-python-bindings         enable python binding compilation
  --without-python-bindings      disable python binding compilation
  --with-boost-incdir=DIR        use the copy of Boost in DIR
  --with-boost-libdir=DIR        use the copy of Boost in DIR
  --with-boost=DIR               use the copy of Boost in DIR
                                 assuming headers are in DIR/include
                                 and libraries in DIR/lib
  --python-bin=PYTHON_EXECUTABLE use this python executable
                                 (default is 'python')
  --python-install-user          Install the python module in the 
                                 user scheme 
                                 (like pip install --user)

Some influential environment variables:
CC          C compiler command
CXX         C++ compiler command
AR          Static linker command
LD          Dynamic linker command
\" #\`

for var in \"\$@\"
do
	if [ \"\$var\" = \"--help\" -o \"\$var\" = \"-h\" ]; then
		echo \"\$HELP\"
		exit 0
	fi

	TMP=\`echo \"\$var\" | sed -n 's/^--prefix=\(.*\)$/\1/p'\`
	if [ \"\$TMP\" ]; then PREFIX=\"\$TMP\"; continue; fi

	TMP=\`echo \"\$var\" | sed -n 's/^--with-gsl=\(.*\)$/\1/p'\`
	if [ \"\$TMP\" ]; then
		GSL_INCDIR=\"\${TMP}/include\";
		GSL_LIBDIR=\"\${TMP}/lib\";
	continue; fi

	TMP=\`echo \"\$var\" | sed -n 's/^--with-gsl-incdir=\(.*\)$/\1/p'\`
	if [ \"\$TMP\" ]; then GSL_INCDIR=\"\$TMP\"; continue; fi

	TMP=\`echo \"\$var\" | sed -n 's/^--with-gsl-libdir=\(.*\)$/\1/p'\`
	if [ \"\$TMP\" ]; then GSL_LIBDIR=\"\$TMP\"; continue; fi

	TMP=\`echo \"\$var\" | sed -n 's/^--with-hdf5=\(.*\)$/\1/p'\`
	if [ \"\$TMP\" ]; then
		HDF5_INCDIR=\"\${TMP}/include\";
		HDF5_LIBDIR=\"\${TMP}/lib\";
	continue; fi

	TMP=\`echo \"\$var\" | sed -n 's/^--with-hdf5-incdir=\(.*\)$/\1/p'\`
	if [ \"\$TMP\" ]; then HDF5_INCDIR=\"\$TMP\"; continue; fi

	TMP=\`echo \"\$var\" | sed -n 's/^--with-hdf5-libdir=\(.*\)$/\1/p'\`
	if [ \"\$TMP\" ]; then HDF5_LIBDIR=\"\$TMP\"; continue; fi

	TMP=\`echo \"\$var\" | sed -n 's/^--with-squids=\(.*\)$/\1/p'\`
	if [ \"\$TMP\" ]; then
		SQUIDS_INCDIR=\"\${TMP}/include\";
		SQUIDS_LIBDIR=\"\${TMP}/lib\";
	continue; fi

	TMP=\`echo \"\$var\" | sed -n 's/^--with-squids-incdir=\(.*\)$/\1/p'\`
	if [ \"\$TMP\" ]; then SQUIDS_INCDIR=\"\$TMP\"; continue; fi

	TMP=\`echo \"\$var\" | sed -n 's/^--with-squids-libdir=\(.*\)$/\1/p'\`
	if [ \"\$TMP\" ]; then SQUIDS_LIBDIR=\"\$TMP\"; continue; fi

	TMP=\`echo \"\$var\" | sed -n 's/^--with-nusquids=\(.*\)$/\1/p'\`
	if [ \"\$TMP\" ]; then
		NUSQUIDS_INCDIR=\"\${TMP}/include\";
		NUSQUIDS_LIBDIR=\"\${TMP}/lib\";
	continue; fi

	TMP=\`echo \"\$var\" | sed -n 's/^--with-nusquids-incdir=\(.*\)$/\1/p'\`
	if [ \"\$TMP\" ]; then NUSQUIDS_INCDIR=\"\$TMP\"; continue; fi

	TMP=\`echo \"\$var\" | sed -n 's/^--with-nusquids-libdir=\(.*\)$/\1/p'\`
	if [ \"\$TMP\" ]; then NUSQUIDS_LIBDIR=\"\$TMP\"; continue; fi

	TMP=\`echo \"\$var\" | sed -n 's/^--with-phystools=\(.*\)$/\1/p'\`
	if [ \"\$TMP\" ]; then
		PHYSTOOLS_INCDIR=\"\${TMP}/include\";
		PHYSTOOLS_LIBDIR=\"\${TMP}/lib\";
	continue; fi

	TMP=\`echo \"\$var\" | sed -n 's/^--with-phystools-incdir=\(.*\)$/\1/p'\`
	if [ \"\$TMP\" ]; then PHYSTOOLS_INCDIR=\"\$TMP\"; continue; fi

	TMP=\`echo \"\$var\" | sed -n 's/^--with-phystools-libdir=\(.*\)$/\1/p'\`
	if [ \"\$TMP\" ]; then PHYSTOOLS_LIBDIR=\"\$TMP\"; continue; fi

	TMP=\`echo \"\$var\" | sed -n 's/^--with-leptonweighter=\(.*\)$/\1/p'\`
	if [ \"\$TMP\" ]; then
		LEPTONWEIGHTER_INCDIR=\"\${TMP}/include\";
		LEPTONWEIGHTER_LIBDIR=\"\${TMP}/lib\";
	continue; fi

	TMP=\`echo \"\$var\" | sed -n 's/^--with-leptonweighter-incdir=\(.*\)$/\1/p'\`
	if [ \"\$TMP\" ]; then LEPTONWEIGHTER_INCDIR=\"\$TMP\"; continue; fi

	TMP=\`echo \"\$var\" | sed -n 's/^--with-leptonweighter-libdir=\(.*\)$/\1/p'\`
	if [ \"\$TMP\" ]; then LEPTONWEIGHTER_LIBDIR=\"\$TMP\"; continue; fi

	# PHOTOSPLINE #
	TMP=\`echo \"\$var\" | sed -n 's/^--with-photospline-config=\(.*\)$/\1/p'\`
	if [ \"\$TMP\" ]; then
		PHOTOSPLINE_CONFIG=\"\${TMP}\";
	continue; fi

	TMP=\`echo \"\$var\" | sed -n 's/^--with-nuflux=\(.*\)$/\1/p'\`
	if [ \"\$TMP\" ]; then
		NUFLUX_INCDIR=\"\${TMP}/include\";
		NUFLUX_LIBDIR=\"\${TMP}/lib\";
	continue; fi

	TMP=\`echo \"\$var\" | sed -n 's/^--with-nuflux-incdir=\(.*\)$/\1/p'\`
	if [ \"\$TMP\" ]; then NUFLUX_INCDIR=\"\$TMP\"; continue; fi

	TMP=\`echo \"\$var\" | sed -n 's/^--with-nuflux-libdir=\(.*\)$/\1/p'\`
	if [ \"\$TMP\" ]; then NUFLUX_LIBDIR=\"\$TMP\"; continue; fi

	TMP=\`echo \"\$var\" | sed -n 's/^--with-boost=\(.*\)$/\1/p'\`
	if [ \"\$TMP\" ]; then
		BOOST_INCDIR=\"\${TMP}/include\";
		BOOST_LIBDIR=\"\${TMP}/lib\";
	continue; fi

	TMP=\`echo \"\$var\" | sed -n 's/^--with-boost-libdir=\(.*\)$/\1/p'\`
	if [ \"\$TMP\" ]; then BOOST_LIBDIR=\"\$TMP\"; continue; fi
	TMP=\`echo \"\$var\" | sed -n 's/^--with-boost-incdir=\(.*\)$/\1/p'\`
	if [ \"\$TMP\" ]; then BOOST_INCDIR=\"\$TMP\"; continue; fi

	TMP=\`echo \"\$var\" | sed -n 's/^--python-bin=\(.*\)$/\1/p'\`
	if [ \"\$TMP\" ]; then PYTHON_EXE=\$TMP; continue; fi

	TMP=\`echo \"\$var\" | sed -n 's/^--with-python-bindings/true/p'\`
	if [ \"\$TMP\" ]; then PYTHON_BINDINGS=true; continue; fi

	TMP=\`echo \"\$var\" | sed -n 's/^--python-install-user/user/p'\`
	if [ \"\$TMP\" ]; then PYTHON_INSTALL_SCHEME=\"\$TMP\"; continue; fi

	echo \"config.sh: Unknown or malformed option '\$var'\" 1>&2
	exit 1
done

if [ \"\$GSL_INCDIR\" -a \"\$GSL_LIBDIR\" ]; then
	echo \"Checking manually specified GSL...\"
	if [ -d \"\$GSL_INCDIR/gsl\" \\
         -a -e \"\$GSL_INCDIR/gsl/gsl_version.h\" \\
         -a -d \"\$GSL_LIBDIR\" \\
         -a -e \"\$GSL_LIBDIR/libgsl.a\" ]; then
		GSL_FOUND=1
		GSL_CFLAGS=\"-I\$GSL_INCDIR\"
		GSL_LDFLAGS=\"-L\$GSL_LIBDIR -lgsl -lgslcblas -lm\"
	else
		echo \"Warning: manually specifed GSL not found; will attempt auto detection\"
	fi
fi

find_package gsl 1.15

if [ \"\$HDF5_INCDIR\" -a \"\$HDF5_LIBDIR\" ]; then
	echo \"Checking manually specified HDF5...\"
	if [ -d \"\$HDF5_INCDIR\" \\
         -a -e \"\$HDF5_INCDIR/H5version.h\" \\
         -a -d \"\$HDF5_LIBDIR\" \\
         -a -e \"\$HDF5_LIBDIR/libhdf5.a\" \\
         -a -e \"\$HDF5_LIBDIR/libhdf5_hl.a\" ]; then
		HDF5_FOUND=1
		HDF5_CFLAGS=\"-I\$HDF5_INCDIR\"
		HDF5_LDFLAGS=\"-L\$HDF5_LIBDIR -lhdf5 -lhdf5_hl\"
	else
		echo \"Warning: manually specifed HDF5 not found; will attempt auto detection\"
	fi
fi

#Do not use this due to broken Ubuntu package
#find_package hdf5 1.8
find_hdf5

if [ \"\$SQUIDS_INCDIR\" -a \"\$SQUIDS_LIBDIR\" ]; then
	echo \"Checking manually specified SQUIDS...\"
	if [ -d \"\$SQUIDS_INCDIR\" \\
         -a -d \"\$SQUIDS_LIBDIR\" \\
         -a -e \"\$SQUIDS_LIBDIR/libSQuIDS.a\" ]; then
		SQUIDS_FOUND=1
		SQUIDS_CFLAGS=\"-I\$SQUIDS_INCDIR\"
		SQUIDS_LDFLAGS=\"-L\$SQUIDS_LIBDIR -lSQuIDS\"
		if \$CXX --version | grep -q \"Free Software Foundation\"; then
			SQUIDS_CFLAGS=\"\$SQUIDS_CFLAGS -Wno-abi\"
		fi
	else
		echo \"Warning: manually specifed SQUIDS not found; will attempt auto detection\"
	fi
fi

find_package squids 1.2

if [ \"\$NUSQUIDS_INCDIR\" -a \"\$NUSQUIDS_LIBDIR\" ]; then
	echo \"Checking manually specified NUSQUIDS...\"
	if [ -d \"\$NUSQUIDS_INCDIR\" \\
         -a -d \"\$NUSQUIDS_LIBDIR\" \\
         -a -e \"\$NUSQUIDS_LIBDIR/libnuSQuIDS.a\" ]; then
		NUSQUIDS_FOUND=1
		NUSQUIDS_CFLAGS=\"-I\$NUSQUIDS_INCDIR\"
		NUSQUIDS_LDFLAGS=\"-L\$NUSQUIDS_LIBDIR -lnuSQuIDS\"
		if \$CXX --version | grep -q \"Free Software Foundation\"; then
			NUSQUIDS_CFLAGS=\"\$NUSQUIDS_CFLAGS -Wno-abi\"
		fi
	else
		echo \"Warning: manually specifed nuSQUIDS not found; will attempt auto detection\"
	fi
fi

find_package nusquids

if [ \"\$PHYSTOOLS_INCDIR\" -a \"\$PHYSTOOLS_LIBDIR\" ]; then
	echo \"Checking manually specified PhysTools ...\"
	if [ -d \"\$PHYSTOOLS_INCDIR\" \\
         -a -d \"\$PHYSTOOLS_LIBDIR\" \\
         -a -e \"\$PHYSTOOLS_LIBDIR/libPhysTools.a\" ]; then
		PHYSTOOLS_FOUND=100000
		PHYSTOOLS_CFLAGS=\"-I\$PHYSTOOLS_INCDIR\"
		PHYSTOOLS_LDFLAGS=\"-L\$PHYSTOOLS_LIBDIR -lPhysTools\"
	else
		echo \"Warning: manually specifed PhysTools not found; will attempt auto detection\"
	fi
fi

find_package phystools

if [ \"\$NUFLUX_INCDIR\" -a \"\$NUFLUX_LIBDIR\" ]; then
	echo \"Checking manually specified nuflux...\"
	if [ -d \"\$NUFLUX_INCDIR\" \\
         -a -d \"\$NUFLUX_LIBDIR\" \\
         -a -e \"\$NUFLUX_LIBDIR/libnuflux.a\" ]; then
		NUFLUX_FOUND=1
		NUFLUX_CFLAGS=\"-I\$NUFLUX_INCDIR\"
		NUFLUX_LDFLAGS=\"-L\$NUFLUX_LIBDIR -lnuflux\"
		if \$CXX --version | grep -q \"Free Software Foundation\"; then
			NUFLUX_CFLAGS=\"\$NUFLUX_CFLAGS -Wno-abi\"
		fi
	else
		echo \"Warning: manually specifed nuflux not found; will attempt auto detection\"
	fi
fi

find_package nuflux

try_find_photospline

ensure_found gsl
ensure_found hdf5
ensure_found squids
ensure_found nusquids
ensure_found photospline
ensure_found nuflux

if [ ! -d ./build/ ]; then
    mkdir build;
fi
if [ ! -d ./lib/ ]; then
    mkdir lib;
fi

echo \"Generating config file...\"

# Somewhat evil: HDF5 does not register with pkg-config, which causes the latter
# to error out because it cannot find nuSQuIDS dependencies.
# Solution: Since we found HDF5 (hopefully correctly), register it ourselves.
echo \"# WARNING: This configuration file was heutristically generated by nuSQuIDS
# and may not be complete or correct
libdir=\${HDF5_LIBDIR}
includedir=\${HDF5_INCDIR}\" > lib/hdf5.pc
echo '
Name: HDF5
Description: \"A data model, library, and file format for storing and managing data.\"
URL: https://www.hdfgroup.org/HDF5/' >> lib/hdf5.pc
echo \"Version: \${HDF5_VERSION}\" >> lib/hdf5.pc
echo \"Cflags: \${HDF5_CFLAGS}
Libs: \${HDF5_LDFLAGS}
\" >> lib/hdf5.pc

echo \"prefix=\$PREFIX\" > lib/${PROJ_NAME}.pc
echo '
libdir=\${prefix}/lib
includedir=\${prefix}/inc

Name: ${PROJ_NAME}
Description: golem MEOWS analysis
echo \"Version: \$VERSION\"' >> lib/${PROJ_NAME}.pc
echo 'Requires: gsl >= 1.15 hdf5 >= 1.8 squids >= 1.2.0 nusquids >= 1.0.0
Libs: -L\${libdir} -l${PROJ_NAME}
Cflags: -I\${includedir}
' >> lib/${PROJ_NAME}.pc

echo \"Generating makefile...\"
echo \"# Compiler
CC=\$CC
CXX=\$CXX
AR=\$AR
LD=\$LD

DYN_SUFFIX=\$DYN_SUFFIX
DYN_OPT=\$DYN_OPT

VERSION=\$VERSION
PREFIX=\$PREFIX
\" > ./Makefile

echo '
PATH_${PROJ_NAME}=\$(shell pwd)

SOURCES = \$(wildcard src/*.cpp)
OBJECTS = \$(patsubst src/%.cpp,build/%.o,\$(SOURCES))

CXXFLAGS= -std=c++11

# Directories
'  >> ./Makefile

echo \"GSL_CFLAGS=\$GSL_CFLAGS\" >> ./Makefile
echo \"GSL_LDFLAGS=\$GSL_LDFLAGS\" >> ./Makefile

echo \"HDF5_CFLAGS=\$HDF5_CFLAGS\" >> ./Makefile
echo \"HDF5_LDFLAGS=\$HDF5_LDFLAGS\" >> ./Makefile

echo \"SQUIDS_CFLAGS=\$SQUIDS_CFLAGS\" >> ./Makefile
echo \"SQUIDS_LDFLAGS=\$SQUIDS_LDFLAGS\" >> ./Makefile

echo \"NUSQUIDS_CFLAGS=\$NUSQUIDS_CFLAGS\" >> ./Makefile
echo \"NUSQUIDS_LDFLAGS=\$NUSQUIDS_LDFLAGS\" >> ./Makefile

echo \"NUFLUX_CFLAGS=\$NUFLUX_CFLAGS\" >> ./Makefile
echo \"NUFLUX_LDFLAGS=\$NUFLUX_LDFLAGS\" >> ./Makefile

echo \"PHOTOSPLINE_CFLAGS=\$PHOTOSPLINE_CFLAGS\" >> ./Makefile
echo \"PHOTOSPLINE_LDFLAGS=\$PHOTOSPLINE_LDFLAGS\" >> ./Makefile

echo \"PHYSTOOLS_CFLAGS=\$PHYSTOOLS_CFLAGS\" >> ./Makefile
echo \"PHYSTOOLS_LDFLAGS=\$PHYSTOOLS_LDFLAGS\" >> ./Makefile

echo '

INC${PROJ_NAME}=\$(PATH_${PROJ_NAME})/include
LIB${PROJ_NAME}=\$(PATH_${PROJ_NAME})/lib

# FLAGS
CFLAGS= -O3 -fPIC -I\$(INC${PROJ_NAME}) \$(SQUIDS_CFLAGS) \$(NUSQUIDS_CFLAGS) \$(GSL_CFLAGS) \$(HDF5_CFLAGS) \$(NUFLUX_CFLAGS) \$(PHOTOSPLINE_CFLAGS) \$(PHYSTOOLS_CFLAGS)
LDFLAGS= -Wl,-rpath -Wl,\$(LIB${PROJ_NAME}) -L\$(LIB${PROJ_NAME})
LDFLAGS+= \$(SQUIDS_LDFLAGS) \$(NUSQUIDS_LDFLAGS) \$(GSL_LDFLAGS) \$(HDF5_LDFLAGS) \$(NUFLUX_LDFLAGS) \$(PHOTOSPLINE_LDFLAGS) \$(PHYSTOOLS_LDFLAGS) -lpthread

# Project files
NAME=${PROJ_NAME}
STAT_PRODUCT=lib/lib\$(NAME).a
DYN_PRODUCT=lib/lib\$(NAME)\$(DYN_SUFFIX)

# Compilation rules
all: \$(STAT_PRODUCT) \$(DYN_PRODUCT)

\$(DYN_PRODUCT) : \$(OBJECTS)
	@echo Linking \$(DYN_PRODUCT)
	@\$(CXX) \$(DYN_OPT)  \$(LDFLAGS) -o \$(DYN_PRODUCT) \$(OBJECTS)

\$(STAT_PRODUCT) : \$(OBJECTS)
	@echo Linking \$(STAT_PRODUCT)
	@\$(AR) -rcs \$(STAT_PRODUCT) \$(OBJECTS)

build/%.o : src/%.cpp
	@echo Compiling $< to $@
	@\$(CXX) \$(CXXFLAGS) -c \$(CFLAGS) \$< -o \$@

.PHONY: install uninstall clean test docs
clean:
	@echo Erasing generated files
	@rm -f \$(PATH_${PROJ_NAME})/build/*.o
	@rm -f \$(PATH_${PROJ_NAME})/\$(STAT_PRODUCT) \$(PATH_${PROJ_NAME})/\$(DYN_PRODUCT)

doxygen:
	@mkdir -p ./docs
	@doxygen src/doxyfile
docs:
	@mkdir -p ./docs
	@doxygen src/doxyfile

test: \$(DYN_PRODUCT) \$(STAT_PRODUCT)
	@cd ./test ; ./run_tests

install: \$(DYN_PRODUCT) \$(STAT_PRODUCT)
	@echo Installing headers in \$(PREFIX)/include/${PROJ_NAME}
	@mkdir -p \$(PREFIX)/include/${PROJ_NAME}
	@cp \$(INC${PROJ_NAME})/${PROJ_NAME}/*.h \$(PREFIX)/include/${PROJ_NAME}
	@echo Installing libraries in \$(PREFIX)/lib
	@mkdir -p \$(PREFIX)/lib
	@cp \$(DYN_PRODUCT) \$(STAT_PRODUCT) \$(PREFIX)/lib
	@echo Installing config information in \$(PREFIX)/lib/pkgconfig
	@mkdir -p \$(PREFIX)/lib/pkgconfig
	@cp lib/${PROJ_NAME}.pc \$(PREFIX)/lib/pkgconfig' >> ./Makefile

" > $CONFIGURATION_SCRIPT
