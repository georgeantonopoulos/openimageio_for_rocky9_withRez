#!/bin/bash
set -e

# Function to log messages with timestamps
log() {
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Function to check if a command exists
check_command() {
    if ! command -v $1 &> /dev/null; then
        log "ERROR: Required command '$1' not found. Please install it first."
        exit 1
    fi
}

# Function to check if previous step succeeded
check_step() {
    if [ $? -ne 0 ]; then
        log "ERROR: Step '$1' failed! Check the logs above for details."
        exit 1
    fi
}

# Function to check and cleanup previous builds
check_cleanup() {
    local space_to_clean=0
    
    # Check for previous build directories
    if [ -d "${BUILD_ROOT}" ]; then
        space_to_clean=$((space_to_clean + $(du -sk "${BUILD_ROOT}" | cut -f1)))
    fi
    if [ -d "${TMP_INSTALL}" ]; then
        space_to_clean=$((space_to_clean + $(du -sk "${TMP_INSTALL}" | cut -f1)))
    fi
    if [ -d "${INSTALL_PREFIX}" ]; then
        space_to_clean=$((space_to_clean + $(du -sk "${INSTALL_PREFIX}" | cut -f1)))
    fi
    
    if [ ${space_to_clean} -gt 0 ]; then
        log "Found previous build directories using $(( space_to_clean / 1024 ))MB"
        read -p "Would you like to clean them up? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            log "Cleaning up previous build directories..."
            rm -rf "${BUILD_ROOT}" "${TMP_INSTALL}" "${INSTALL_PREFIX}"
            log "Cleanup complete, freed $(( space_to_clean / 1024 ))MB"
        else
            log "Skipping cleanup, continuing with build..."
        fi
    fi
}

# Create log directory
LOG_DIR="$(pwd)/logs"
mkdir -p ${LOG_DIR}
log "Logs will be saved to: ${LOG_DIR}"

log "Starting OpenImageIO build process with OCIO support..."

# 1. Setup environment first (this will install needed packages)
log "[1/4] Setting up build environment..."
# Don't pipe the source command to maintain environment
source setup_env.sh > >(tee "${LOG_DIR}/setup.log") 2>&1

# Verify the environment is properly set
if [[ ! -d "${TMP_VENV}" ]]; then
    log "ERROR: Temporary virtual environment not found at ${TMP_VENV}!"
    exit 1
fi

if ! which cmake >/dev/null 2>&1; then
    log "ERROR: cmake not found in PATH after environment setup!"
    exit 1
fi

# NOW verify all required packages are installed
log "Verifying critical packages..."
for pkg in dnf-plugins-core git ninja-build rsync; do
    if ! rpm -q $pkg >/dev/null 2>&1; then
        log "ERROR: Required package '$pkg' is not installed!"
        exit 1
    fi
done

# NOW check for required commands after environment is sourced
log "Checking required commands..."
check_command git
check_command cmake
check_command ninja
check_command rsync
check_command python3

# Verify environment variables are set
for var in BUILD_ROOT SRC_ROOT TMP_INSTALL INSTALL_PREFIX; do
    if [ -z "${!var}" ]; then
        log "ERROR: Required environment variable $var is not set!"
        exit 1
    fi
done

# Check disk space and cleanup
SPACE_NEEDED=5000000  # ~5GB in KB
AVAILABLE_SPACE=$(df -k . | awk 'NR==2 {print $4}')
if [ ${AVAILABLE_SPACE} -lt ${SPACE_NEEDED} ]; then
    log "WARNING: Low disk space! You have $(( AVAILABLE_SPACE / 1024 ))MB available,"
    log "         but the build process might need up to $(( SPACE_NEEDED / 1024 ))MB"
    check_cleanup
    # Check space again after cleanup
    AVAILABLE_SPACE=$(df -k . | awk 'NR==2 {print $4}')
    if [ ${AVAILABLE_SPACE} -lt ${SPACE_NEEDED} ]; then
        log "ERROR: Still not enough disk space after cleanup!"
        log "Please free up at least $(( (SPACE_NEEDED - AVAILABLE_SPACE) / 1024 ))MB more space"
        exit 1
    fi
fi

# 2. Build OCIO
log "[2/4] Building OpenColorIO..."
./build_ocio.sh 2>&1 | tee "${LOG_DIR}/ocio_build.log"
check_step "OCIO build"

# Verify OCIO installation
if [ ! -f "${TMP_INSTALL}/bin/ociocheck" ]; then
    log "ERROR: OCIO installation verification failed! ociocheck not found."
    exit 1
fi

# 3. Build OIIO
log "[3/4] Building OpenImageIO..."
./build_oiio.sh 2>&1 | tee "${LOG_DIR}/oiio_build.log"
check_step "OIIO build"

# Verify OIIO installation
if [ ! -f "${TMP_INSTALL}/bin/oiiotool" ]; then
    log "ERROR: OIIO installation verification failed! oiiotool not found."
    exit 1
fi

# 4. Create final installation
log "[4/4] Creating final installation (flattening symlinks)..."
./flatten_install.sh 2>&1 | tee "${LOG_DIR}/flatten.log"
check_step "Installation flattening"

# Final verification
if [ ! -f "${INSTALL_PREFIX}/bin/oiiotool" ]; then
    log "ERROR: Final installation verification failed! oiiotool not found in final location."
    exit 1
fi

# Make scripts executable (in case they weren't)
chmod +x build_ocio.sh build_oiio.sh flatten_install.sh

log "Build process complete!"
log "Final installation is available at: ${INSTALL_PREFIX}"
log "Build logs are available in: ${LOG_DIR}"
log "You can now use this directory for your Rez package"

# Optional: Check disk space
SPACE_NEEDED=5000000  # ~5GB in KB
AVAILABLE_SPACE=$(df -k . | awk 'NR==2 {print $4}')
if [ ${AVAILABLE_SPACE} -lt ${SPACE_NEEDED} ]; then
    log "WARNING: Low disk space! You have $(( AVAILABLE_SPACE / 1024 ))MB available,"
    log "         but the build process might need up to $(( SPACE_NEEDED / 1024 ))MB"
fi 