#!/usr/bin/python3
# Test python client to exercise DSTC.
import vsd
import sys


if __name__ == "__main__":
    ctx = vsd.create_context()
    if vsd.load_from_file(ctx, "./vss_rel_2.0.0-alpha+005.csv") != 0:
        print("Could not load vss_rel_2.0.0-alpha+005.csv")
        sys.exit(255)

    vsd.process_events(300000)

    sig = vsd.signal(ctx, "Vehicle.Drivetrain.Transmission.Gear")
    vsd.set(ctx, sig, 4)

    pub = vsd.signal(ctx, "Vehicle.Drivetrain.Transmission")
    vsd.publish(pub);
    vsd.process_events(300000)
