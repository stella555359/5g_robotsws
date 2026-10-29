SET_FIXED_FREQUENCY_COMMAND = ':freq:fix {}{}'
READ_FIXED_FREQUENCY_COMMAND = ':freq:fix?'
CHANGE_RF_OUTPUT_STATE_COMMAND = ':outp {}'
READ_RF_OUTPUT_STATE_COMMAND = ':outp?'
CHANGE_MODULATION_STATE_COMMAND = ':outp:mod {}'
READ_MODULATION_STATE_COMMAND = ':outp:mod?'
ENDING = '\r\n'


class ScpiCommands(object):

    @staticmethod
    def set_fixed_frequency(frequency, unit):
        return SET_FIXED_FREQUENCY_COMMAND.format(frequency, unit).encode() + ENDING.encode()

    @staticmethod
    def read_fixed_frequency():
        return READ_FIXED_FREQUENCY_COMMAND.encode() + ENDING.encode()

    @staticmethod
    def change_rf_output_state(on_or_off):
        return CHANGE_RF_OUTPUT_STATE_COMMAND.format(on_or_off).encode() + ENDING.encode()

    @staticmethod
    def read_rf_output_state():
        return READ_RF_OUTPUT_STATE_COMMAND.encode() + ENDING.encode()

    @staticmethod
    def change_modulation_output_state(on_or_off):
        return CHANGE_MODULATION_STATE_COMMAND.format(on_or_off).encode() + ENDING.encode()

    @staticmethod
    def read_modulation_output_state():
        return READ_MODULATION_STATE_COMMAND.encode() + ENDING.encode()
