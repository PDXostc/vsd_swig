#!/usr/bin/python3
# Test python client to exercise DSTC.
import vsd
import sys

ctx = None
def process_signal(signal, path, value):
    print("Sub {}:{} - {}".format(signal, path, value))

if __name__ == "__main__":
    ctx = vsd.create_context()
    vsd.set_callback(ctx, process_signal)
    if vsd.load_from_file(ctx, "./vss_rel_2.0.0-alpha+005.csv") != 0:
        print("Could not load vss_rel_2.0.0-alpha+005.csv")
        sys.exit(255)
    sig = vsd.signal(ctx, "Vehicle.Drivetrain.Transmission");
    vsd.subscribe(ctx, sig)
    vsd.process_events(-1)
