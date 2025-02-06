# OpenImageIO with OpenColorIO Build System

This repository contains scripts and configuration files for building OpenImageIO with OpenColorIO v2.3.1 support and Python 3.9 integration.

## Repository Structure

- `build_all.sh` - Main script that orchestrates the entire build process
- `build_ocio.sh` - Script for building OpenColorIO
- `build_oiio.sh` - Script for building OpenImageIO
- `setup_env.sh` - Environment setup script
- `flatten_install.sh` - Installation flattening utility
- `test_libraries.py` - Test script to verify library functionality

### Rez Package
The `oiio_install` directory contains a Rez package configuration for OpenImageIO, managing dependencies and environment setup.

## Requirements

- Python 3.9
- Boost
- OpenEXR
- CMake

## Tools Included

The build includes the following OpenImageIO command-line tools:
- iconvert
- idiff
- igrep
- iinfo
- maketx
- oiiotool 