#!/bin/sh
# SPDX-License-Identifier: BSD-3-Clause
# Copyright Contributors to the OpenColorIO Project.

# For OS X
export DYLD_LIBRARY_PATH="/tmp/oiio_tmp_install/lib64:${DYLD_LIBRARY_PATH}"

# For Linux
export LD_LIBRARY_PATH="/tmp/oiio_tmp_install/lib64:${LD_LIBRARY_PATH}"

export PATH="/tmp/oiio_tmp_install/bin:${PATH}"
export PYTHONPATH="/tmp/oiio_tmp_install/lib64/python3.9/site-packages:${PYTHONPATH}"
