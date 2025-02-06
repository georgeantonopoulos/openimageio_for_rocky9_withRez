name = "openimageio"
version = "2.4.15.0"

description = """
OpenImageIO with built-in OpenColorIO v2.3.1 support.
Built with Python 3.9 support.
"""

requires = [
    "python-3.9",
    "boost",
    "openexr"
]

variants = []  # Keep same as reference if it had none

tools = [
    "iconvert",
    "idiff",
    "igrep",
    "iinfo",
    "maketx",
    "oiiotool"
]

def commands():
    env.PATH.append("{root}/bin")
    env.LD_LIBRARY_PATH.append("{root}/lib64")
    env.LD_LIBRARY_PATH.append("{root}/lib")
    env.PYTHONPATH.append("{root}/lib64/python{python.version.major}.{python.version.minor}/site-packages")
    env.PYTHONPATH.append("{root}/lib/python{python.version.major}.{python.version.minor}/site-packages") 