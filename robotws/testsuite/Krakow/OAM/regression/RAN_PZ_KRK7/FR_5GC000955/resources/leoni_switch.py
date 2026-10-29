import datetime
import time
from taf.hw.optical_switch.devices.leoni import Leoni_mol_2x_3x8


def link_brake():

    out1 = OpticalSwitch.get_optical_switch_channels()
    print(out1)

    OpticalSwitch.set_optical_switch_channels({1: 2})

    out2 = OpticalSwitch.get_optical_switch_channels()
    print(out2)

    time.sleep(0.1)

    OpticalSwitch.set_optical_switch_channels({1: 4})
    out3 = OpticalSwitch.get_optical_switch_channels()
    print(out3)


def link_brake_while():
    OpticalSwitch = Leoni_mol_2x_3x8('10.255.40.105')
    start_time = datetime.datetime.now()
    end_time = start_time + datetime.timedelta(minutes=8)

    while datetime.datetime.now() < end_time:
        print('Break!: time: {}'.format(datetime.datetime.now()))
        link_brake()
        time.sleep(15)
