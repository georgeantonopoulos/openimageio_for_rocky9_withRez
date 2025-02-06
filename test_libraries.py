#!/usr/bin/env python3

import sys
print("Python version:", sys.version)

# Test OpenColorIO
print("\nTesting OpenColorIO...")
try:
    import PyOpenColorIO as OCIO
    print("OCIO version:", OCIO.__version__)
    
    # Create a simple color transform
    config = OCIO.Config.CreateRaw()
    processor = config.getProcessor(OCIO.ColorSpace.Rec709, OCIO.ColorSpace.sRGB)
    print("Successfully created OCIO processor")
except Exception as e:
    print("OCIO test failed:", e)

# Test OpenImageIO
print("\nTesting OpenImageIO...")
try:
    import OpenImageIO as oiio
    print("OIIO version:", oiio.VERSION_STRING)
    
    # Create a simple image
    spec = oiio.ImageSpec(64, 64, 3, oiio.FLOAT)
    buf = oiio.ImageBuf(spec)
    oiio.ImageBufAlgo.fill(buf, (1, 0, 0))  # Fill with red
    
    # Test writing and reading
    buf.write("/tmp/test.exr")
    read_buf = oiio.ImageBuf("/tmp/test.exr")
    print("Successfully wrote and read an EXR file")
    
    # Test color conversion using OCIO
    if oiio.has_feature("OCIO"):
        print("OIIO was built with OCIO support")
except Exception as e:
    print("OIIO test failed:", e) 