#!/bin/bash
set -e

# Source our environment
source setup_env.sh

# OCIO version
OCIO_VERSION="v2.3.1"

# Enter source directory
cd $SRC_ROOT

# Clone OCIO if not already present
if [ ! -d "OpenColorIO" ]; then
    git clone --branch ${OCIO_VERSION} --recursive https://github.com/AcademySoftwareFoundation/OpenColorIO.git
fi

# Create and enter build directory
mkdir -p ${BUILD_ROOT}/OpenColorIO
cd ${BUILD_ROOT}/OpenColorIO

# Build dependencies first
echo "Building pystring..."
cd ${SRC_ROOT}
if [ ! -d "pystring" ]; then
    git clone https://github.com/imageworks/pystring.git
fi
mkdir -p ${BUILD_ROOT}/pystring
cd ${BUILD_ROOT}/pystring
cmake ${SRC_ROOT}/pystring \
    -GNinja \
    -DCMAKE_INSTALL_PREFIX=${TMP_INSTALL} \
    -DCMAKE_BUILD_TYPE=Release
ninja -j$(nproc) install

echo "Building minizip-ng..."
cd ${SRC_ROOT}
if [ ! -d "minizip-ng" ]; then
    git clone --branch 3.0.7 https://github.com/zlib-ng/minizip-ng.git
fi
mkdir -p ${BUILD_ROOT}/minizip-ng
cd ${BUILD_ROOT}/minizip-ng
cmake ${SRC_ROOT}/minizip-ng \
    -GNinja \
    -DCMAKE_INSTALL_PREFIX=${TMP_INSTALL} \
    -DCMAKE_BUILD_TYPE=Release
ninja -j$(nproc) install

# Return to OCIO build directory
cd ${BUILD_ROOT}/OpenColorIO

# Only clean if CMakeCache.txt exists (indicating a previous failed build)
if [ -f "CMakeCache.txt" ]; then
    echo "Cleaning previous build..."
    rm CMakeCache.txt
    rm -rf CMakeFiles
fi

# Now build OCIO
echo "Building OpenColorIO..."
mkdir -p ${BUILD_ROOT}/OpenColorIO
cd ${BUILD_ROOT}/OpenColorIO

# Configure OCIO
cmake ${SRC_ROOT}/OpenColorIO \
    -GNinja \
    -DCMAKE_INSTALL_PREFIX=${TMP_INSTALL} \
    -DCMAKE_BUILD_TYPE=Release \
    -DOCIO_BUILD_PYTHON=ON \
    -DOCIO_BUILD_TESTS=OFF \
    -DOCIO_BUILD_GPU_TESTS=OFF \
    -DPYTHON_EXECUTABLE=$(which python3) \
    -DOCIO_BUILD_DOCS=OFF \
    -DOCIO_USE_HEADLESS=ON \
    -DBUILD_SHARED_LIBS=ON \
    -DOPENSSL_ROOT_DIR=/usr \
    -DZSTD_ROOT_DIR=/usr \
    -DLZMA_LIBRARY=/usr/lib64/liblzma.so \
    -DCMAKE_EXE_LINKER_FLAGS="-lcrypto -lssl -lzstd -llzma" \
    -DCMAKE_SHARED_LINKER_FLAGS="-lcrypto -lssl -lzstd -llzma"

# Build and install
ninja -j$(nproc) install

# Verify installation
echo "Verifying OCIO installation..."
if [ -f "${TMP_INSTALL}/bin/ociocheck" ]; then
    echo "OCIO installation successful!"
    ${TMP_INSTALL}/bin/ociocheck --version
else
    echo "OCIO installation failed!"
    exit 1
fi

# After build
echo "Checking for Python modules..."
find ${TMP_INSTALL} -name "PyOpenColorIO*" 