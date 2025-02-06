#!/bin/bash
set -e

# Base directories
export BUILD_ROOT="/tmp/oiio_tmp_build"
export SRC_ROOT="$(pwd)/tmp/oiio_src"
# Temporary locations with fixed paths
export TMP_VENV="/tmp/oiio_tmp_venv"  # Fixed venv location
export TMP_INSTALL="/tmp/oiio_tmp_install"
# Final installation prefix
export INSTALL_PREFIX="$(pwd)/tmp/oiio_install"

# Create necessary directories
mkdir -p $BUILD_ROOT
mkdir -p $INSTALL_PREFIX
mkdir -p $SRC_ROOT
mkdir -p $TMP_INSTALL

# Install critical packages first
sudo dnf install -y dnf-plugins-core
sudo dnf config-manager --set-enabled crb
sudo dnf install -y epel-release
sudo dnf install -y --allowerasing \
    python3-devel \
    git \
    ninja-build \
    rsync

# Verify that the venv module works before proceeding
echo "Verifying Python venv capability..."
if ! python3 -m venv /tmp/testvenv; then
    echo "ERROR: python3 venv module check failed!"
    exit 1
else
    echo "python3 venv module is available."
    rm -rf /tmp/testvenv
fi

# Now proceed with venv creation
echo "Creating virtual environment..."
if [ ! -d "${TMP_VENV}" ]; then
    echo "Creating temporary venv in ${TMP_VENV}"
    if ! python3 -m venv "${TMP_VENV}"; then
        echo "ERROR: Failed to create temporary virtual environment in ${TMP_VENV}"
        exit 1
    fi
    
    # Verify temporary venv was created
    if [ ! -f "${TMP_VENV}/bin/activate" ]; then
        echo "ERROR: Failed to create temporary virtual environment - activate script not found"
        exit 1
    fi
fi

# Verify venv exists before sourcing
if [ ! -f "${TMP_VENV}/bin/activate" ]; then
    echo "ERROR: Virtual environment not found at ${TMP_VENV}"
    exit 1
fi

echo "Activating virtual environment..."
source "${TMP_VENV}/bin/activate"

echo "Installing Python packages..."
pip install --upgrade pip
pip install numpy cmake pybind11

# Set up environment variables
export PATH="${TMP_INSTALL}/bin:${PATH}"
export LD_LIBRARY_PATH="${TMP_INSTALL}/lib64:${TMP_INSTALL}/lib:${LD_LIBRARY_PATH}"
export PKG_CONFIG_PATH="${TMP_INSTALL}/lib64/pkgconfig:${TMP_INSTALL}/lib/pkgconfig:${PKG_CONFIG_PATH}"
export CMAKE_PREFIX_PATH="${TMP_INSTALL}"
export PYTHONPATH="${TMP_INSTALL}/lib64/python$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')/site-packages:${TMP_INSTALL}/lib/python$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')/site-packages:${PYTHONPATH}"

# Add these OCIO-specific variables
export OCIO_INCLUDE_PATH="${TMP_INSTALL}/include"
export OCIO_LIBRARY_PATH="${TMP_INSTALL}/lib64:${TMP_INSTALL}/lib"
export OpenColorIO_DIR="${TMP_INSTALL}"

# Install remaining build dependencies
sudo dnf groupinstall -y "Development Tools"
sudo dnf install -y \
    boost-devel \
    openexr-devel \
    libtiff-devel \
    libpng-devel \
    libjpeg-turbo-devel \
    zlib-devel \
    pkgconfig \
    expat-devel \
    yaml-cpp-devel \
    pugixml-devel \
    lcms2-devel \
    ilmbase-devel \
    tinyxml-devel \
    libzstd-devel \
    openssl-devel \
    xz-devel

# After activating venv, add pybind11 to CMAKE_PREFIX_PATH
export CMAKE_PREFIX_PATH="${TMP_VENV}/lib/python$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')/site-packages/pybind11/share/cmake/pybind11:${CMAKE_PREFIX_PATH}" 