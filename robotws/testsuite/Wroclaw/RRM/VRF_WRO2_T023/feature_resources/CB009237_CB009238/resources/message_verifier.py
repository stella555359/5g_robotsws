import subprocess
import operator


from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn


class PcapVerificationError(Exception):
    def __init__(self, message):
        super().__init__(message)
        self.message = message


class PcapVerifier:
    condition_operators = {
        '==': operator.eq,
        '!=': operator.ne,
        '<': operator.lt,
        '>': operator.gt,
        '<=': operator.le,
        '>=': operator.ge
    }

    def verify_percentage_of_messages_with_expected_value(self, msg_type_1_filter, msg_type_2_filter,
                                                          condition='==', expected_percentage=1, file_path=None):
        """
        Verifies the percentage of specific messages in filtered messages in the pcap file.

        :param msg_type_1_filter: Wireshark display filter of all searched messages to count.
        :param msg_type_2_filter: Wireshark display filter of messages with expected value.
        :param condition: Comparison operator as a string (e.g., '==', '!=', '<', '>', '<=', '>=').
        :param expected_percentage: Expected percentage of msg_type_2 in msg_type_1 messages.
        :param file_path: Path to the pcap file to parse.
        :return: True if the condition is met, False otherwise.
        """

        self._check_data(condition, file_path)
        try:
            msg_type_1_result = self._parse_pcap_file(msg_type_1_filter, file_path)

            if msg_type_1_result.returncode != 0:
                message = f"Error running tshark command: {msg_type_1_result.stderr}"
                logger.error(message)
                raise PcapVerificationError(message)

            msg_type_2_result = self._parse_pcap_file(msg_type_2_filter, file_path)

            if msg_type_2_result.returncode != 0:
                message = f"Error running tshark command: {msg_type_2_result.stderr}"
                logger.error(message)
                raise PcapVerificationError(message)

            all_messages_count = self._count_messages(msg_type_1_filter, msg_type_1_result)
            expected_messages_count = self._count_messages(msg_type_2_filter, msg_type_2_result)

            percentage = self._check_percentage(expected_messages_count, all_messages_count)
            comparison_result = self.condition_operators[condition](percentage, expected_percentage)

            self._evaluate_percentage_result(comparison_result, condition, expected_percentage, percentage)

        except PcapVerificationError as e:
            BuiltIn().fail(f"Error processing pcap file: {e}")

        except ZeroDivisionError:
            BuiltIn().fail(f"No messages were found in file")

    def _evaluate_percentage_result(self, comparison_result, condition, expected_percentage, percentage):
        if comparison_result:
            logger.info(
                f"Verification successful: Condition '{percentage} {condition} {expected_percentage}' is met.",
                also_console=True
            )
        else:
            message = f"Verification failed: Condition '{percentage} {condition} {expected_percentage}' is not met."
            BuiltIn().fail(message)

    def _check_percentage(self, expected_messages_count, all_messages_count):
        return (expected_messages_count * 100) / all_messages_count

    def verify_amount_of_messages_in_file(self, display_filter, condition='==', number_of_messages=1, file_path=None):
        """
        Verifies the number of messages in the pcap file that match the given display filter.

        :param display_filter: Wireshark display filter string.
        :param number_of_messages: Expected number of matching messages.
        :param condition: Comparison operator as a string (e.g., '==', '!=', '<', '>', '<=', '>=').
        :param file_path: Path to the pcap file to parse.
        :return: True if the condition is met, False otherwise.
        """

        self._check_data(condition, file_path)
        try:
            result = self._parse_pcap_file(display_filter, file_path)

            if result.returncode != 0:
                message = f"Error running tshark command: {result.stderr}"
                logger.error(message)
                raise PcapVerificationError(message)

            count = self._count_messages(display_filter, result)
            comparison_result = self.condition_operators[condition](count, number_of_messages)

            self._evaluate_result(comparison_result, condition, count, number_of_messages)

        except PcapVerificationError as e:
            BuiltIn().fail(f"Error processing pcap file: {e}")

    def _evaluate_result(self, comparison_result, condition, count, number_of_messages):

        if comparison_result:
            logger.info(
                f"Verification successful: Condition '{count} {condition} {number_of_messages}' is met.",
                also_console=True
            )
        else:
            message = f"Verification failed: Condition '{count} {condition} {number_of_messages}' is not met."
            BuiltIn().fail(message)

    def _check_data(self, condition, file_path):
        """
        Verifies that given condition is in specified conditions, and if given file exists

        :param condition: One of the conditions (e.g., '==', '!=', '<', '>', '<=', '>=').
        :param file_path: Path to the pcap file to parse.
        :return: True if the condition is met, False otherwise.
        """

        if file_path is None:
            raise FileNotFoundError("Path to pcap file must be provided")

        if condition not in self.condition_operators:
            raise KeyError(f"Invalid condition: {condition}. "
                           f"Must be one of the conditions (e.g., '==', '!=', '<', '>', '<=', '>=')")

    def _parse_pcap_file(self, display_filter, file_path):
        logger.info(f"Running tshark on pcap file: {file_path}", also_console=True)
        command = f'tshark -r {file_path} -Y "{display_filter}" | wc -l'
        return subprocess.run(command, shell=True, capture_output=True, text=True)

    def _count_messages(self, display_filter, raw_data):
        output_lines = raw_data.stdout.splitlines()
        filtered_lines = [line for line in output_lines if "Failed to find match" not in line]
        count = int(filtered_lines[-1]) if filtered_lines else 0

        logger.info(f"Number of messages matching filter '{display_filter}': {count}", also_console=True)
        return count


verifier = PcapVerifier()


def verify_amount_of_messages_in_file(filter_string, condition="==", number_of_messages=1, file_path=None):
    """
    Verifies the number of messages in the pcap file that match the given display filter.

    :param filter_string: Wireshark display filter string.
    :param condition: Comparison operator as a string (e.g., '==', '!=', '<', '>', '<=', '>=').
    :param number_of_messages: Expected number of matching messages.
    :param file_path: Path to the pcap file to parse.
    :return: True if the condition is met, False otherwise.
    """

    verifier.verify_amount_of_messages_in_file(
            filter_string,
            condition=condition,
            number_of_messages=number_of_messages,
            file_path=file_path
    )


def verify_percentage_of_messages_with_expected_value(msg_type_1_filter, msg_type_2_filter, condition="==",
                                                      expected_percentage=0, file_path=None):
    """
    Verifies the percentage of specific messages in filtered messages in the pcap file.

    :param msg_type_1_filter: Wireshark display filter of all searched messages to count.
    :param msg_type_2_filter: Wireshark display filter of messages with expected value.
    :param condition: Comparison operator as a string (e.g., '==', '!=', '<', '>', '<=', '>=').
    :param expected_percentage: Expected percentage of msg_type_2 in msg_type_1 messages.
    :param file_path: Path to the pcap file to parse.
    :return: True if the condition is met, False otherwise.
    """

    verifier.verify_percentage_of_messages_with_expected_value(
            msg_type_1_filter,
            msg_type_2_filter,
            condition=condition,
            expected_percentage=expected_percentage,
            file_path=file_path
    )
