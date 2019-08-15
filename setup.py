"""
setup.py file for VSD SWIG
"""
import setuptools
import os
from distutils.core import setup, Extension
if 'VERSION' in os.environ:
    ver = os.environ['VERSION']
else:
    ver = '0.0.0.dev0'

setup(name='python-vsd',
      version=ver,
      author="VSD Docs",
      author_email="ecoffey1@jaguarlandrover.com",
      url="https://github.com/PDXostc/vsd_swig",
      description="""SWIG wrapper for VSD.""",
      py_modules=['vsd', 'vsd_swig'],
      ext_modules=[
        Extension('_vsd_swig',
                  sources=['vsd_swig_wrap.c', ],
                  libraries=['vsd', 'dstc', 'rmc', 'vss'])
                  ],
      )
