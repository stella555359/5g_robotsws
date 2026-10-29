import telnetlib
from testsuite.Wroclaw.SyVe.RRM.resources.ScpiCommands import ScpiCommands
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger

ON = 1
OFF = 0
DEFAULT_COMMAND_TIMEOUT = 2
ENDLINE = 'SCPI>'.encode()
UNWANTED_OUTPUT_SIGNS = '\r\nSCPI>'


def execute_command_via_telnet(address, port, command):
    with Telnet(address, port) as tn:
        tn.write(command)
        return prepared_output(tn.read_until(ENDLINE, DEFAULT_COMMAND_TIMEOUT))


def prepared_output(read_command):
    return read_command.decode().strip(UNWANTED_OUTPUT_SIGNS)


class Telnet(object):
    """
    According to telnetlib python docs:
    "Deprecated since version 3.11, will be removed in version 3.13:
    The telnetlib module is deprecated (see PEP 594 for details and alternatives)."
    If any error appears, first check if UTE did not update python version.
    telnetlib3 is planned as replacement.
    """
    def __init__(self, address, port):
        self.address = address
        self.port = port
        self.telnet_connection = None
        self.command = ScpiCommands()

    def __enter__(self):
        self.telnet_connection = telnetlib.Telnet(self.address, self.port)
        Telnet.set_telnet_cursor(self.telnet_connection)
        return self.telnet_connection

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.telnet_connection.close()

    def read_fixed_frequency(self):
        Logger.info('Reading fixed frequency value')
        return execute_command_via_telnet(self.address, self.port, self.command.read_fixed_frequency())

    def set_fixed_frequency(self, frequency, unit):
        Logger.info('Setting fixed frequency value to: {}'.format(frequency, unit))
        return execute_command_via_telnet(self.address, self.port, self.command.set_fixed_frequency(frequency, unit))

    def turn_on_rf_output(self):
        Logger.info('Turning on rf output')
        if Telnet(self.address, self.port).read_rf_output_state() == OFF:
            execute_command_via_telnet(self.address, self.port, self.command.change_rf_output_state('on'))
        else:
            Logger.warning('RF output already turned on')

    def turn_off_rf_output(self):
        Logger.info('Turning off rf output')
        if Telnet(self.address, self.port).read_rf_output_state() == ON:
            execute_command_via_telnet(self.address, self.port, self.command.change_rf_output_state('off'))
        else:
            Logger.warning('Modulation already turned off')

    def read_rf_output_state(self):
        Logger.info('Reading rf output state')
        return int(execute_command_via_telnet(self.address, self.port, self.command.read_rf_output_state()))

    def turn_on_modulation_output(self):
        Logger.info('Turning on modulation output')
        if Telnet(self.address, self.port).read_modulation_output_state() == OFF:
            execute_command_via_telnet(self.address, self.port, self.command.change_modulation_output_state('on'))
        else:
            Logger.warning('Modulation already turned on')

    def turn_off_modulation_output(self):
        Logger.info('Turning off modulation output')
        if Telnet(self.address, self.port).read_modulation_output_state() == ON:
            execute_command_via_telnet(self.address, self.port, self.command.change_modulation_output_state('off'))
        else:
            Logger.warning('Modulation already turned off')

    def read_modulation_output_state(self):
        Logger.info('Reading modulation output state')
        return int(execute_command_via_telnet(self.address, self.port, self.command.read_modulation_output_state()))

    @staticmethod
    def set_telnet_cursor(telnet_connection):
        while telnet_connection.read_until('SCPI>'.encode(), timeout=2) != ' '.encode():
            telnet_connection.read_until('SCPI>'.encode())
