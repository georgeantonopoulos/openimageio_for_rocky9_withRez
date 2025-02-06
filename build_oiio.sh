#!/bin/bash
set -e

# Source our environment
source setup_env.sh

# OIIO version
OIIO_VERSION="v2.4.15.0"

# Enter source directory
cd $SRC_ROOT

# Clone OIIO if not already present
if [ ! -d "oiio" ]; then
    git clone --branch ${OIIO_VERSION} https://github.com/OpenImageIO/oiio.git
fi

# Create and enter build directory
mkdir -p ${BUILD_ROOT}/oiio
cd ${BUILD_ROOT}/oiio

# Only clean if CMakeCache.txt exists
if [ -f "CMakeCache.txt" ]; then
    echo "Cleaning previous build..."
    rm CMakeCache.txt
    rm -rf CMakeFiles
fi

# Configure OIIO
cmake ${SRC_ROOT}/oiio \
    -GNinja \
    -DCMAKE_INSTALL_PREFIX=${TMP_INSTALL} \
    -DCMAKE_BUILD_TYPE=Release \
    -DPYTHON_VERSION=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")') \
    -DPYTHON_EXECUTABLE=$(which python3) \
    -DOIIO_BUILD_TESTS=OFF \
    -DUSE_PYTHON=ON \
    -DUSE_OPENCOLORIO=ON \
    -DBUILD_DOCS=OFF \
    -DINSTALL_DOCS=OFF \
    -DUSE_EXTERNAL_PUGIXML=ON \
    -DSTOP_ON_WARNING=OFF \
    -DOIIO_BUILD_TOOLS=ON \
    -DUSE_NUKE=OFF

# Build and install
ninja -j$(nproc) install

# Verify installation
echo "Verifying OIIO installation..."
if [ -f "${TMP_INSTALL}/bin/oiiotool" ]; then
    echo "OIIO installation successful!"
    ${TMP_INSTALL}/bin/oiiotool --version
    echo "Checking OCIO support..."
    if ${TMP_INSTALL}/bin/oiiotool --help | grep -q "colorconvert"; then
        echo "OCIO support verified!"
    else
        echo "WARNING: OCIO support might not be enabled!"
        exit 1
    fi
else
    echo "OIIO installation failed!"
    exit 1
fi

# After build
echo "Checking for Python modules..."
find ${TMP_INSTALL} -name "OpenImageIO*" 