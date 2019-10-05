#
# Copyright (C) 2018, Jaguar Land Rover
# This program is licensed under the terms and conditions of the
# Mozilla Public License, version 2.0.  The full text of the
# Mozilla Public License is at https:#www.mozilla.org/MPL/2.0/
#
# Author: Magnus Feuer (mfeuer1@jaguarlandrover.com)

#
# Simple library to integrate Python with DSTC
#
import dstc
import ctypes

_callback = None
vsd_swig = None
# Copied in from vehicle_signal_distribution.h
# Could not get exported enums to work.
class data_type_e:
    vsd_int8 = 0
    vsd_uint8 = 1
    vsd_int16 = 2
    vsd_uint16 = 3
    vsd_int32 = 4
    vsd_uint32 = 5
    vsd_double = 6
    vsd_float = 7
    vsd_boolean = 8
    vsd_string = 9
    vsd_stream = 10
    vsd_na = 11


def load_vss_shared_object(so_file):
    global vsd_swig
    res = ctypes.CDLL("librmc.so", mode=ctypes.RTLD_GLOBAL)
    res = ctypes.CDLL("libdstc.so", mode=ctypes.RTLD_GLOBAL)
    res = ctypes.CDLL(so_file, mode=ctypes.RTLD_GLOBAL)
    vsd_swig = __import__("vsd_swig")

def publish(sig):
    vsd_swig.log_debug("VSD Publish")
    return vsd_swig.vsd_publish(sig)

def subscribe(sig):
    vsd_swig.log_debug("VSD Subscribe")
    return vsd_swig.swig_vsd_subscribe(sig)

def signal_by_id(sig_id):
    return vsd_swig.swig_vss_get_signal_by_index(sig_id)

def signal(path):
    return vsd_swig.swig_vss_find_signal_by_path(path)

def path(sig):
    return vsd_swigt.vsd_desc_to_path_static(sig)

def get(sig):
    dt = vsd_swig.swig_vsd_data_type(sig)

    if dt == data_type_e.vsd_int8:
        return vsd_swig.swig_vsd_value_i8(sig)

    if dt == data_type_e.vsd_uint8:
        return vsd_swig.swig_vsd_value_u8(sig)

    if dt == data_type_e.vsd_int16:
        return vsd_swig.swig_vsd_value_i16(sig)

    if dt == data_type_e.vsd_uint16:
        return vsd_swig.swig_vsd_value_u16(sig)

    if dt == data_type_e.vsd_int32:
        return vsd_swig.swig_vsd_value_i32(sig)

    if dt == data_type_e.vsd_uint32:
        return vsd_swig.swig_vsd_value_u32(sig)

    if dt == data_type_e.vsd_double:
        return vsd_swig.swig_vsd_value_d(sig)

    if dt == data_type_e.vsd_float:
        return vsd_swig.swig_vsd_value_f(sig)

    if dt == data_type_e.vsd_boolean:
        return vsd_swig.swig_vsd_value_b(csig)

    if dt == data_type_e.vsd_string:
        return vsd_swig.swig_vsd_value_s(sig)

    if dt == data_type_e.vsd_stream:
        return None

    if dt == data_type_e.vsd_na:
        return None

    return None


def set(sig, val):
    dt = vsd_swig.swig_vsd_data_type(sig)

    if dt == data_type_e.vsd_int8:
        return vsd_swig.swig_vsd_set_i8(sig, val)

    if dt == data_type_e.vsd_uint8:
        return vsd_swig.swig_vsd_set_u8(sig, val)

    if dt == data_type_e.vsd_int16:
        return vsd_swig.swig_vsd_set_i16(sig, val)

    if dt == data_type_e.vsd_uint16:
        return vsd_swig.swig_vsd_set_u16(sig, val)

    if dt == data_type_e.vsd_int32:
        return vsd_swig.swig_vsd_set_i32(sig, val)

    if dt == data_type_e.vsd_uint32:
        return vsd_swig.swig_vsd_set_u32(sig, val)

    if dt == data_type_e.vsd_double:
        return vsd_swig.swig_vsd_set_d(sig, val)

    if dt == data_type_e.vsd_float:
        return vsd_swig.swig_vsd_set_f(sig, val)

    if dt == data_type_e.vsd_boolean:
        return vsd_swig.swig_vsd_set_b(sig, val)

    if dt == data_type_e.vsd_string:
        return vsd_swig.swig_vsd_set_s(sig, val)

    if dt == data_type_e.vsd_stream:
        return None

    if dt == data_type_e.vsd_na:
        return None

    return None

def _intermediate_callback(*arg):
    # Invoke the real callback with unpacked tuples provided
    # as native arguments.

    (signal_id, path, value) = arg
    vsd_swig.log_debug("Intermediate callback called for path: " + str(path))
    _callback(signal_id, path, value)

def set_callback(cb):
    global _callback
    _callback = cb
    return vsd_swig.swig_vsd_set_python_callback(_intermediate_callback)

def process_events(timeout_msec):
    return dstc.process_events(timeout_msec);

def process_pending_events(timeout_msec):
    return dstc.process_pending_events(timeout_msec);

def activate():
    dstc.activate()
