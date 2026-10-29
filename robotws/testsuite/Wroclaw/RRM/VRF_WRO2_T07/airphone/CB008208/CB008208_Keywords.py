from robot.api import logger
from robot.errors import ExecutionFailed


def get_qfi_value_from_asn_logs(path, value):
    """Init PcmdAsnVerifier class and call 'get value from logs' func"""
    pcmd_verifier = PcmdAsnVerifier()
    qfi_value = pcmd_verifier.get_value_from_logs(path=path, value=value)
    return qfi_value


class PcmdAsnVerifier:

    def __init__(self):
        self.file_name = "/asn_decoded_10.0.1.1_49151.log"

    def _open_asn_file(self, path):
        filepath = path + self.file_name

        try:
            with open(filepath) as f:
                f = f.readlines()
            return f
        except FileNotFoundError:
            logger.warn("Provided filepath is invalid - " + filepath)

        raise ExecutionFailed(message="Test failed while attempting to open ASN log file.")

    def _clean_qfi_value(self, qfi_value):
        """Trims found QFI value"""
        qfi_value = qfi_value.strip(" ")
        qfi_value = qfi_value.split()
        return qfi_value[1].replace(",", "")

    def get_value_from_logs(self, path, value):

        if type(value) is not str:
            raise ExecutionFailed(message="Provided value is not a string.")

        asn_file = self._open_asn_file(path=path)

        # Iterate over the log file in order to locate "qfi" record
        for i in asn_file:
            if value in i:
                return self._clean_qfi_value(i)

        print("Value '{}' not found in the log file".format(value))
        raise ExecutionFailed(message="Value '{}' not found in the log file".format(value))
