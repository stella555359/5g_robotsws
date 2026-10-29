from testsuite.Oulu.TrunkEng.ALD.Python.Resources.AldEmulator import AldEmulator


class AldEmulatorInterface:

    def __init__(self):
        self.ald = AldEmulator()

    def get_available_antennalines(self):
        """
        Shows available emulator lines

        :returns list: Available emulator lines
        """
        command = "available_antennalines"
        return self.ald.execute_command(command, r"EmulatorLine\d+", return_list=True)

    def raise_alarm(self, lna, alarm_type, emulator_line, environment=None):
        """
        Raises alarm to LNA via ALD emulator

        :param str lna: Used LNA (lna1 / lna2)
        :param str alarm_type:
                              Possible alarms:
                                              - HardwareError
                                              - MinorTmaFault
                                              - MajorTmaFault
                                              - BypassMode
        :param str emulator_line: e.g. EmulatorLine1
        :param str environment: e.g. 2_11_CLOUDx
        """
        command = "{} {} raise_alarm {}".format(emulator_line, lna, alarm_type)
        output = self.ald.execute_command(command, r"OK", environment=environment)
        self.ald.check_output_correctness(output, r"OK")

    def clear_alarm(self, lna, alarm_type, emulator_line, environment=None):
        """
        Clears alarm from LNA via ALD emulator

        :param str lna: Used LNA (lna1 / lna2)
        :param str alarm_type:
                              Possible alarms:
                                              - HardwareError
                                              - MinorTmaFault
                                              - MajorTmaFault
                                              - BypassMode
        :param str emulator_line: e.g. EmulatorLine1
        :param str environment: e.g. 2_11_CLOUDx
        """
        command = "{} {} clear_alarm {}".format(emulator_line, lna, alarm_type)
        output = self.ald.execute_command(command, r"OK", environment=environment)
        self.ald.check_output_correctness(output, r"OK")

    def return_code(self, lna, return_code_type, emulator_line, environment=None):
        """
        Set return code to LNA via ALD emulator

        :param str lna: Used LNA (lna1 / lna2)
        :param str return_code_type:
                                    Possible return codes:
                                                          - Ok
                                                          - Busy
                                                          - HardwareError
                                                          - MinorTmaFault
                                                          - MajorTmaFault
                                                          - UnsupportedValue
                                                          - WorkingSoftwareMissing
                                                          - FormatError
                                                          - UnsupportedProcedure
        :param str emulator_line: e.g. EmulatorLine1
        :param str environment: e.g. 2_11_CLOUDx
        """
        command = "{} {} set_gain_return_code_{} {}".format(emulator_line, lna, lna, return_code_type)
        output = self.ald.execute_command(command, r"OK", environment=environment)
        self.ald.check_output_correctness(output, r"OK")

    def get_return_code(self, lna, return_code_type, emulator_line, environment=None):
        """
        Set return code to LNA via ALD emulator

        :param str lna: Used LNA (lna1 / lna2)
        :param str return_code_type:
                                    Possible return codes:
                                                          - Ok
                                                          - Busy
                                                          - MinorTmaFault
                                                          - MajorTmaFault
                                                          - WorkingSoftwareMissing
                                                          - FormatError
        :param str emulator_line: e.g. EmulatorLine1
        :param str environment: e.g. 2_11_CLOUDx
        """
        command = "{} {} get_gain_return_code_{} {}".format(emulator_line, lna, lna, return_code_type)
        output = self.ald.execute_command(command, r"OK", environment=environment)
        self.ald.check_output_correctness(output, r"OK")
