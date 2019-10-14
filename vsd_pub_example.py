#!/usr/bin/env python3
import vsd
import dstc
import sys
import time
from dstc import current_milli_time

def main():
    #./ in the path name forces the current directory to be searched
    # instead of LD_LIBRARY_PATH (/lib, /usr/libm, etc)
    vsd.load_vss_shared_object("./example.so")

    sig = vsd.signal("Modem.DataLink.Status")
    if not sig:
        print("Could not resolve signal Modem.DataLink.Status")
        sys.exit(255)

    vsd.set(sig, "connecting")

    sig = vsd.signal("Modem.SignalStrength")
    if not sig:
        print("Could not resolve signal Modem.SignalStrength")
        sys.exit(255)


    vsd.set(sig, 12)

    pub = vsd.signal("Modem")

    dstc.activate()

    stop_ts = current_milli_time() + 400
    while (current_milli_time() < stop_ts):
            dstc.process_events(stop_ts - current_milli_time())

    vsd.publish(pub)

    dstc.process_pending_events()


if __name__ == "__main__":
    main()
