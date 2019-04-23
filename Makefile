#
# Makefile to generate python interface code for DSTC
#

CFLAGS += -ggdb
VSD_DIR ?= /usr/local/include

vsd_swig_wrap.o: vsd_swig_wrap.c
	python3 setup.py build_ext --inplace -I${VSD_DIR}

vsd_swig_wrap.c: vsd_swig.i
	swig -I${VSD_DIR} -python -includeall vsd_swig.i

clean:
	rm -rf _vsd*.so build vsd_swig.py vsd_swig_wrap.* __pycache__ \
	dist jlr_vsd.egg-info **~
