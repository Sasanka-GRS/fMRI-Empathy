from setuptools import Extension
from setuptools import setup
import logging
import pathlib
import platform
import setuptools
import setuptools.command.build_ext
import setuptools.command.install
import shutil
import subprocess
import sys,os

class InstallationError(Exception): pass

major,minor,_,_,_ = sys.version_info
setupdir = pathlib.Path(__file__).resolve().parent

python_versions = [(3, 6), (3, 7), (3, 8), (3, 9), (3, 10)]
if (major,minor) not in python_versions: raise InstallationError("Unsupported python version")
if platform.system() != "Windows" or platform.architecture()[0] != "64bit" or platform.machine() not in ["AMD64","x86_64"]: raise InstallationError("Invalid system/platform/architecture")

class install(setuptools.command.install.install):
    """
    Extend the default install command, adding an additional operation
    that installs the dynamic MOSEK libraries.
    """
    libdir   = ['..\\..\\bin']
    instlibs = ['tbb12.dll', 'mosek64_10_0.dll', 'svml_dispmd.dll']
    
    def create_origin(self,sitedir):
        mskdir = os.path.join(sitedir,'mosek')
        with open(os.path.join(mskdir,'mosekorigin.py'),'wt',encoding='ascii') as f:
            f.write(f'__mosekinstpath__ = {repr(mskdir)}\n')
    
    def findlib(self,lib):
        for p in self.libdir:
            f = pathlib.Path(p).joinpath(lib)
            if f.exists():
                return f
        raise InstallationError(f"Library not found: {lib}")
    
    def install_libs(self):
        mskdir = pathlib.Path(self.install_lib).joinpath('mosek')
        for lib in [ self.findlib(lib) for lib in self.instlibs ]:
            logging.info(f"copying {lib} -> {mskdir}")
            shutil.copy(lib,mskdir)
    def run(self):
        super().run()
        self.execute(self.install_libs, (), msg="Installing native libraries")
        self.execute(self.create_origin,(self.install_lib,), msg="Creating origin file")

os.chdir(setupdir)
setup(name =             'Mosek',
      version =          "10.0.20",
      description =      'Python API for Mosek',
      long_description = 'Python API for Mosek optimiation tools and Fusion',
      author =           'Mosek ApS',
      author_email =     'support@mosek.com',
      license =          'See license.pdf in the MOSEK distribution',
      url =              'https://mosek.com',
      packages =         ['mosek', 'mosek.fusion', 'mosek.fusion.impl'],
      cmdclass =         { "install" : install })
