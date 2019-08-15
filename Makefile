#
# Makefile to generate python interface code for VSD
#
CFLAGS += -ggdb
INC_DIRS ?= -I/usr/local/include

OBJ = vsd_swig_wrap.o
SRC = vsd_swig_wrap.c
SWIG = vsd_swig.i

$(OBJ): $(SRC)
	python3 setup.py build_ext --inplace $(INC_DIRS)

$(SRC): $(SWIG)
	swig $(INC_DIRS) -python -includeall $(SWIG)

clean:
	rm -rf _vsd*.so build vsd_swig.py vsd_swig_wrap.* __pycache__ \
	dist jlr_vsd.egg-info **~
