#!/usr/bin/env python3
# Test python client to exercise DSTC.
import vsd
import dstc
import sys



exit_flag = False

def process_signal(signal, path, value):
    print("Sub {}:{} - {}".format(signal, path, value))
    global exit_flag
    exit_flag = True

def main():
    vsd.load_vss_shared_object("./example.so")
    dstc.activate()
    vsd.set_callback(process_signal)
    sig = vsd.signal("Modem");
    if not sig:
        print("Could not resolve signal Modem")
        sys.exit(255)

    vsd.subscribe(sig)
    global exit_flag

    while not exit_flag:
        dstc.process_events(-1)

if __name__ == "__main__":
    main()
