#!/usr/bin/env python3
import vsd
import dstc
import sys
import time

current_milli_time = lambda: int(round(time.time() * 1000))

def main():

    sig = vsd.signal("Vehicle.Drivetrain.InternalCombustionEngine.Engine.Power")
    vsd.set(sig, 230)

    sig = vsd.signal("Vehicle.Drivetrain.InternalCombustionEngine.FuelType")
    vsd.set(sig, "gasoline")

    pub = vsd.signal("Vehicle.Drivetrain.InternalCombustionEngine")

    dstc.activate()

    stop_ts = current_milli_time() + 400
    while (current_milli_time() < stop_ts):
            dstc.process_events(stop_ts - current_milli_time())

    vsd.publish(pub)

    dstc.process_pending_events()


if __name__ == "__main__":
    main()