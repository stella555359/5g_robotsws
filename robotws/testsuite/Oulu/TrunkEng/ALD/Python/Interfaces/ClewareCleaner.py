from robot.libraries.BuiltIn import BuiltIn
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, error
from testsuite.Oulu.TrunkEng.ALD.Python.Resources.ALDExceptions import UnallowedState, DeviceNotInDictionaryError
from testsuite.Oulu.TrunkEng.ALD.Python.Resources.Cleware import Cleware


class ClewareCleaner:

    def __init__(self):
        self.logger = BuiltIn().get_library_instance("LOG")
        self.cw = Cleware()
        self.PIN_AMOUNT = 8
        self.pin_up = False

    def read_multiple_times(self, pin_status, serial_number, pin_id, env, retries=5):
        try_ctr = 0
        while pin_status == 1 and try_ctr < retries:
            BuiltIn().sleep("2s")
            error("{} pin {} was ON instead of OFF. Trying to read it again".format(serial_number, pin_id))
            pin_status = self.cw.get_switch(serial_number=serial_number, pin_id=pin_id, env=env)
            try_ctr += 1
        return pin_status

    def check_pins(self, env):
        """
        Switches all pins that are ON, to OFF

        :param env: e.g. 2_11_CLOUDx
        :raises DeviceNotInDictionaryError: If device is incorrect
        :raises UnallowedState: If pin is ON
        """
        info("Checking that all Cleware pins are off")
        devices = self.cw.get_serial_numbers(env=env)
        for i, serial_number in enumerate(devices):
            if serial_number not in devices:
                error("Incorrect serial number.")
                raise DeviceNotInDictionaryError
            self.cw.connect(serial_number, env=env)
            BuiltIn().sleep("2s")
            for j in range(self.PIN_AMOUNT):
                pin_status = self.cw.get_switch(serial_number=serial_number, pin_id=j, env=env)
                pin_status = self.read_multiple_times(pin_status, serial_number, j, env)
                if pin_status == 1:
                    error("{} pin {} was ON instead of OFF. Trying to switch it OFF".format(serial_number, j))
                    self.cw.set_switch("OFF", serial_number=serial_number, pin_id=j, env=env)
                pin_status = self.read_multiple_times(pin_status, serial_number, j, env)
                if pin_status == 1:
                    self.pin_up = True
                BuiltIn().sleep("2s")
        if self.pin_up:
            raise UnallowedState
