%module vsd_swig
%{
#include <reliable_multicast.h>
#include <rmc_log.h>
#include <dstc.h>
#include <vehicle_signal_distribution.h>
#include <stdint.h>
#include <errno.h>
#include <dlfcn.h>

    extern void* vsd_get_user_data(vsd_context_t* ctx);
    extern int vsd_set_user_data(vsd_context_t* ctx, void* user_data);

    static uint8_t do_callback(vsd_signal_node_t* node, void* v_ctx)
    {
        RMC_LOG_DEBUG("PYTHON: Callback called");
        vsd_context_t* ctx = (vsd_context_t*) v_ctx;
        PyObject *arglist = 0;
        PyObject *result = 0;
        PyObject *cb = (PyObject*) vsd_get_user_data(ctx);
        vss_signal_t* elem = node->data;
        char sig_name[1024];
        vss_get_signal_path(elem, sig_name, sizeof(sig_name));

        if (elem->element_type == VSS_BRANCH) {
            printf("FATAL: Tried to print branch: %u:%s", elem->index, elem->name);
            exit(255);
        }

        vsd_data_u res;
        vsd_get_value(elem, &res);

        switch(elem->data_type) {
        case VSS_INT8:
            arglist = Py_BuildValue("sIb", sig_name, elem->data_type, res.i8);
            break;
        case VSS_INT16:
            arglist = Py_BuildValue("sIh", sig_name, elem->data_type, res.i16);
            break;
        case VSS_INT32:
            arglist = Py_BuildValue("sIi", sig_name, elem->data_type, res.i32);
            break;
        case VSS_UINT8:
            arglist = Py_BuildValue("sIB", sig_name, elem->data_type, res.i8);
            break;
        case VSS_UINT16:
            arglist = Py_BuildValue("sIH", sig_name, elem->data_type, res.i16);
            break;
        case VSS_UINT32:
            arglist = Py_BuildValue("sII", sig_name, elem->data_type, res.i32);
            break;
        case VSS_DOUBLE:
            arglist = Py_BuildValue("sId", sig_name, elem->data_type, res.d);
            break;
        case VSS_FLOAT:
            arglist = Py_BuildValue("sIf", sig_name, elem->data_type, res.f);
            break;
        case VSS_BOOLEAN:
            arglist = Py_BuildValue("sIb", sig_name, elem->data_type, res.b);
            break;
        case VSS_STRING:
            arglist = Py_BuildValue("sIy#", sig_name, elem->data_type,
                                    res.s.data,
                                    res.s.len);
            break;
        case VSS_NA:
            break;
        default:
            break;
        }

        if (arglist) {
            result = PyObject_CallObject(cb, arglist);
            Py_DECREF(arglist);
            if (result)
                Py_DECREF(result);
        }
        return 1;
    }

    void swig_vsd_process(vsd_context_t* ctx, vsd_signal_list_t* lst)
    {
        RMC_LOG_DEBUG("PYHTON: processing vsd signals");
        vsd_signal_list_for_each(lst, do_callback, 0);
        return;
    }
%}

%include "typemaps.i"

%inline %{
    typedef unsigned int vsd_id_t;
    typedef long int usec_timestamp_t;

    extern int vsd_publish(vss_signal_t* sig);
    extern int vsd_set_value_by_path_int8(vsd_context_t* context,
                                          char* path,
                                          signed char val);
    extern int vsd_get_value(vss_signal_t* sig,
                         vsd_data_u *result);
    extern int vsd_subscribe(struct vsd_context* ctx,
                             vss_signal_t* sig,
                             vsd_subscriber_cb_t callback);


    void log_debug(char* msg)
    {
       RMC_LOG_DEBUG(msg);
    }

    vss_signal_t* swig_vss_find_signal_by_path(char* path)
    {
        vss_signal_t* sig = 0;
        vss_get_signal_by_path(path, &sig);

        return sig;
    }

    char* swig_vss_get_signal_path(vss_signal_t* sig)
    {
        static char path[1024];

        vss_get_signal_path(sig, path, sizeof(path));

        return path;
    }

    int  swig_vsd_subscribe(vss_signal_t* sig)
    {
        return vsd_subscribe(0, sig, swig_vsd_process);
    }

    int swig_vsd_data_type(vss_signal_t* sig)
    {
        return (int) sig->data_type;
    }

    void swig_vsd_set_python_callback(PyObject* cb)
    {
        PyObject *o_cb = (PyObject*) vsd_get_user_data(0);

        // Wipe old value, if set.
        if (o_cb)
            Py_DECREF(o_cb);

        Py_INCREF(cb);
        vsd_set_user_data(0, (void*) cb);

        RMC_LOG_DEBUG("vsd_set_python_callback()");
    }

    signed char swig_vsd_value_i8(vss_signal_t* sig) {

        vsd_data_u res;
        vsd_get_value(sig, &res);

        return res.i8;
    }

    unsigned char swig_vsd_value_u8(vss_signal_t* sig) {

        vsd_data_u res;
        vsd_get_value(sig, &res);

        return res.u8;
    }

    signed short swig_vsd_value_i16(vss_signal_t* sig) {

        vsd_data_u res;
        vsd_get_value(sig, &res);

        return res.i16;
    }

    unsigned short swig_vsd_value_u16(vss_signal_t* sig) {

        vsd_data_u res;
        vsd_get_value(sig, &res);

        return res.u16;
    }

    signed int swig_vsd_value_i32(vss_signal_t* sig) {

        vsd_data_u res;
        vsd_get_value(sig, &res);

        return res.i32;
    }

    unsigned int swig_vsd_value_u32(vss_signal_t* sig) {

        vsd_data_u res;
        vsd_get_value(sig, &res);

        return res.u32;
    }

    float swig_vsd_value_f(vss_signal_t* sig) {

        vsd_data_u res;
        vsd_get_value(sig, &res);

        return res.f;
    }

    double swig_vsd_value_d(vss_signal_t* sig) {

        vsd_data_u res;
        vsd_get_value(sig, &res);

        return res.d;
    }

    unsigned int swig_vsd_value_b(vss_signal_t* sig) {

        vsd_data_u res;
        vsd_get_value(sig, &res);

        return res.b;
    }

    //
    // SET VALUE
    //
    signed char swig_vsd_set_i8(vss_signal_t* sig, signed char val)
    {
        RMC_LOG_DEBUG("vsd_set_i8() value: %d on signal %s \n", val, sig->uuid);
        return vsd_set_value_by_signal_int8(0, sig, val);
    }

    unsigned char swig_vsd_set_u8(vss_signal_t* sig, unsigned char val)
    {
        RMC_LOG_DEBUG("vsd_set_u8() value: %c on signal %s \n", val, sig->uuid);
        return vsd_set_value_by_signal_uint8(0, sig, val);
    }

    signed short swig_vsd_set_i16(vss_signal_t* sig, signed short val)
    {
        RMC_LOG_DEBUG("vsd_set_i16() value: %d on signal %s \n", val, sig->uuid);
        return vsd_set_value_by_signal_int16(0, sig, val);
    }

    unsigned short swig_vsd_set_u16(vss_signal_t* sig, unsigned short val)
    {
        RMC_LOG_DEBUG("vsd_set_u16() value: %d on signal %s \n", val, sig->uuid);
        return vsd_set_value_by_signal_uint16(0, sig, val);
    }

    signed int swig_vsd_set_i32(vss_signal_t* sig, signed int val)
    {
        RMC_LOG_DEBUG("vsd_set_i32() value: %d on signal %s \n", val, sig->uuid);
        return vsd_set_value_by_signal_int32(0, sig, val);
    }

    unsigned int swig_vsd_set_u32(vss_signal_t* sig, unsigned int val)
    {
        RMC_LOG_DEBUG("vsd_set_u32() value: %d on signal %s \n", val, sig->uuid);
        return vsd_set_value_by_signal_uint32(0, sig, val);
    }

    float swig_vsd_set_f(vss_signal_t* sig, float val)
    {
        RMC_LOG_DEBUG("vsd_set_f() value: %.2f on signal %s \n", val, sig->uuid);
        return vsd_set_value_by_signal_float(0, sig, val);
    }

    double swig_vsd_set_d(vss_signal_t* sig, double val)
    {
        RMC_LOG_DEBUG("vsd_set_d() value: %.2f on signal %s \n", val, sig->uuid);
        return vsd_set_value_by_signal_double(0, sig, val);
    }

    unsigned int swig_vsd_set_b(vss_signal_t* sig, signed char val)
    {
        RMC_LOG_DEBUG("vsd_set_b() value: %c on signal %s \n", val, sig->uuid);
        return vsd_set_value_by_signal_boolean(0, sig, val);
    }

    unsigned int swig_vsd_set_s(vss_signal_t* sig, char* data)
    {
        RMC_LOG_DEBUG("vsd_set_s() value: %s on signal %s \n", data, sig->uuid);
        return vsd_set_value_by_signal_string(0, sig, data);
    }

    %}

%include "cstring.i"
%cstring_output_allocate_size(char** str, int *len, free(*$1));
%{
    int swig_vsd_value_s(vss_signal_t* sig, char** str, int *len) {

        vsd_data_u res;
        vsd_get_value(sig, &res);

        *str = (char*) malloc(res.s.len);
        *len = res.s.len;
        memcpy(*str, res.s.data, *len);
        return 0;
}
%}
