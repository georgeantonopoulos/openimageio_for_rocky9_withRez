#!/bin/bash
set -e

# Source environment
source setup_env.sh

echo "Creating final installation in ${INSTALL_PREFIX}"

# Remove any existing install
rm -rf "${INSTALL_PREFIX}"

# Create final directory structure
mkdir -p ${INSTALL_PREFIX}/{bin,lib,lib64,include,share}

# Use rsync to copy files while dereferencing symlinks
rsync -aL "${TMP_INSTALL}/" "${INSTALL_PREFIX}/"

# Create a manifest of what's installed
echo "=== OIIO/OCIO Installation Manifest ===" > ${INSTALL_PREFIX}/manifest.txt
echo "Binaries:" >> ${INSTALL_PREFIX}/manifest.txt
ls -l ${INSTALL_PREFIX}/bin >> ${INSTALL_PREFIX}/manifest.txt
echo -e "\nLibraries:" >> ${INSTALL_PREFIX}/manifest.txt
ls -l ${INSTALL_PREFIX}/lib64 >> ${INSTALL_PREFIX}/manifest.txt
echo -e "\nPython Modules:" >> ${INSTALL_PREFIX}/manifest.txt
find ${INSTALL_PREFIX} -name "*.so" -type f >> ${INSTALL_PREFIX}/manifest.txt
echo -e "\nOCIO Support in OIIO:" >> ${INSTALL_PREFIX}/manifest.txt
${INSTALL_PREFIX}/bin/oiiotool --help | grep -A 2 "color" >> ${INSTALL_PREFIX}/manifest.txt

# Verify no symlinks remain
echo "Checking for remaining symlinks..."
SYMLINKS=$(find "${INSTALL_PREFIX}" -type l)
if [ -n "${SYMLINKS}" ]; then
    echo "WARNING: Found remaining symlinks:"
    echo "${SYMLINKS}"
    exit 1
else
    echo "No symlinks found - flattening successful!"
fi

# Print some stats about the installation
echo -e "\nInstallation Statistics:"
echo "Original size (with symlinks):"
du -sh "${TMP_INSTALL}"
echo "Final size (without symlinks):"
du -sh "${INSTALL_PREFIX}"

# Verify key executables still work
echo -e "\nVerifying executables in final install:"
if [ -f "${INSTALL_PREFIX}/bin/oiiotool" ]; then
    echo "Testing oiiotool..."
    "${INSTALL_PREFIX}/bin/oiiotool" --version
fi
if [ -f "${INSTALL_PREFIX}/bin/ociocheck" ]; then
    echo "Testing ociocheck..."
    "${INSTALL_PREFIX}/bin/ociocheck" --version
fi

echo -e "\nFinal installation is ready at: ${INSTALL_PREFIX}"
echo "You can now use this directory for your Rez package"

# Optionally cleanup tmp install
read -p "Clean up temporary installation? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf "${TMP_INSTALL}"
    echo "Temporary installation cleaned up"
fi 