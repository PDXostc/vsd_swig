#
# Makefile to generate python interface code for DSTC
#

CFLAGS += -ggdb
VSD_DIR ?= /usr/local/include

VSPEC2C ?= /usr/local/bin/vspec2c.py

all: vsd_swig_wrap.o example.so
example: example.so

vsd_swig_wrap.o: vsd_swig_wrap.c
	python3 setup.py build_ext --inplace -I${VSD_DIR}

vsd_swig_wrap.c: vsd_swig.i
	swig -I${VSD_DIR} -python -includeall vsd_swig.i

# vspec2.py is available at
# https://github.com/GENIVI/vehicle_signal_specification
example.so:
	${VSPEC2C} -I. -i :example.id example.vss example_vss.c example_vss_macro.h
	gcc ${CFLAGS} -fpic -shared -o example.so example_vss.c

clean:
	rm -rf _vsd*.so build vsd_swig.py vsd_swig_wrap.* __pycache__ \
	dist jlr_vsd.egg-info  example_vss.c example_vss_macro.h *~ example.so
