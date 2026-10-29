"""
:author: Mateusz Potoniec
:contact: mateusz.potoniec@nokia.com
:maintainer: mateusz.potoniec@nokia.com

Example:

    emil_verifier = EmilVerifier()

    awaited_messages = [
        AwaitedMessage(name="SgNBAdditionRequest"),
        AwaitedMessage(name="SgNBAdditionRequestAcknowledge", fields={
            "/spCellConfigCommon/physCellId": ['51'],
            "/physCellId": ['51', '52', '53', '54']
        }),
        AwaitedMessage(name="SgNBReconfigurationComplete"),
        AwaitedMessage(name="SNStatusTransfer")
    ]

    emil_verifier.expect_flow(file_path, awaited_messages, display_filter='x2ap')
    packets = emil_verifier.get_packets(file_path, awaited_messages, display_filter='x2ap')

    for packet in packets:
        print(packet)
        print(packet.message)
        print(packet.message.keys())
        print(packet.message.findall())
        for path in packet.message.paths():
            print(f"Path: {path}, | Value: {packet.message.xpath(path)}")

"""

from dataclasses import dataclass, field
from typing import List, Dict, Generator, Any
from collections import Counter

from robot.api import logger

from taf.analyzer.emil import EmilReader
from taf.analyzer.emil.emil_log_entry import EmilLogEntry


class AwaitedMessageNotFoundError(Exception):
    pass


class AwaitedMessageFieldHasDifferentValueError(Exception):
    pass


@dataclass
class AwaitedMessage:
    name: str
    fields: Dict[str, List[Any]] = field(default_factory=dict)

    def __str__(self):
        return self.name


class EmilVerifier():

    def expect_flow(self, file_path: str, awaited_messages: List[AwaitedMessage], display_filter: str,
                    json_format: str = "ndjson") -> None:
        """
        Check if the awaited messages are present in the flow.

        :param file_path: The path to the file.
        :param awaited_messages: The awaited messages.
        :param display_filter: The filter to apply. Supported display filter x2ap, rrc, f1ap, e1ap.
        :param json_format: The format of the JSON file.

        :return: None

        :raises AwaitedMessageNotFoundError: If an awaited message is not found.
        :raises AwaitedMessageFieldHasDifferentValueError: If a field has different value.
        """

        packets = self._get_all_packets_by_filter(file_path, display_filter, json_format=json_format)
        packet_index = 0

        for awaited_message in awaited_messages:
            found = False
            while packet_index < len(packets):
                packet = packets[packet_index]
                packet_index += 1
                if awaited_message.name in packet.message.keys():
                    found = True
                    logger.info(f"Awaited message: {awaited_message} found")
                    for field, expected_values in awaited_message.fields.items():
                        packet_field_values = self._get_packet_filed_values_by_xpath(packet, field)
                        if not self._compare_values(expected_values, packet_field_values):
                            raise AwaitedMessageFieldHasDifferentValueError(
                                f"Awaited message: {awaited_message} field: {field} expected not in got values. "
                                f"Expected: {expected_values}, Actual: {packet_field_values}"
                            )
                        logger.info(
                            f"Awaited message: {awaited_message} field: {field} checked correctly. "
                            f"Expected: {expected_values}, Actual: {packet_field_values}"
                        )
                    break
            if not found:
                raise AwaitedMessageNotFoundError(f"Awaited message: {awaited_message} not found")

    def get_packets(self, file_path: str, awaited_messages: List[AwaitedMessage], display_filter: str,
                    json_format: str = "ndjson") -> List[EmilLogEntry]:
        """
        Get the packets with the awaited messages.

        :param file_path: The path to the file.
        :param awaited_messages: The awaited messages.
        :param display_filter: The filter to apply. Supported display filter x2ap, rrc, f1ap, e1ap.
        :param json_format: The format of the JSON file.

        :return: The packets with the awaited messages.

        :raises AwaitedMessageFieldHasDifferentValueError: If a field has different value.
        """

        packets = self._get_all_packets_by_filter(file_path, display_filter, json_format=json_format)
        if not awaited_messages:
            logger.info(f"No awaited messages provided. Returning all of {display_filter.upper()} packets")
            return packets

        packets_to_return = []
        for packet in packets:
            for awaited_message in awaited_messages:
                if awaited_message.name in packet.message.keys():
                    logger.info(f"Awaited message: {awaited_message} found")
                    for field, expected_values in awaited_message.fields.items():
                        packet_field_values = self._get_packet_filed_values_by_xpath(packet, field)
                        if not self._compare_values(expected_values, packet_field_values):
                            raise AwaitedMessageFieldHasDifferentValueError(
                                f"Awaited message: {awaited_message} field: {field} expected not in got values. "
                                f"Expected: {expected_values}, Actual: {packet_field_values}"
                            )
                        logger.info(
                            f"Awaited message: {awaited_message} field: {field} checked correctly. "
                            f"Expected: {expected_values}, Actual: {packet_field_values}"
                        )
                    packets_to_return.append(packet)
                    break

        logger.info(f"Got {len(packets_to_return)} of {display_filter.upper()} packets filtered by awaited messages")
        return packets_to_return

    def log_packet_xpaths(self, packet: EmilLogEntry) -> None:
        """
        Log all packet XPaths with its value in format Path: <path/to/value> | Value: <[value]>

        :param packet: The packet.

        :return: None
        """

        for path in packet.message.paths():
            try:
                logger.info(f"Path: {path} | Value: {packet.message.xpath(path)}")
            except (KeyError, LookupError) as e:
                logger.warrning(f"Error while logging packet XPaths: {e}")
                continue

    def _get_packet_filed_values_by_xpath(self, packet: EmilLogEntry, field: str) -> List[str]:
        """
        Get the field values by the XPath.

        :param packet: The packet.
        :param field: The field.

        :return: The field values.
        """

        packet_field_values = []
        for path in packet.message.paths():
            if path.endswith(field):
                packet_field_values.extend(packet.message.xpath(path))
        return packet_field_values

    def _get_all_packets_by_filter(self, file_path: str, display_filter: str,
                                   json_format: str = "ndjson") -> List[EmilLogEntry]:
        """
        Get all packets by the display_filter.

        :param file_path: The path to the file.
        :param display_filter: The filter to apply.
        :param json_format: The format of the JSON file.

        :return: The packets.
        """

        if display_filter.lower() == 'x2ap':
            packets = self._get_all_x2_packets(file_path, json_format=json_format)
            logger.info(f"Found {len(packets)} of all X2AP packets")
        elif display_filter.lower() == 'rrc':
            packets = self._get_all_rrc_packets(file_path, json_format=json_format)
            logger.info(f"Found {len(packets)} of all RRC packets")
        elif display_filter.lower() == 'f1ap':
            packets = self._get_all_f1ap_or_e1ap_packets(file_path, json_format=json_format, user_data_filter="F1AP: ")
            logger.info(f"Found {len(packets)} of all F1AP packets")
        elif display_filter.lower() == 'e1ap':
            packets = self._get_all_f1ap_or_e1ap_packets(file_path, json_format=json_format, user_data_filter="E1AP: ")
            logger.info(f"Found {len(packets)} of all E1AP packets")
        else:
            raise ValueError(f"Invalid display_filter: {display_filter}")
        return packets

    def _get_all_x2_packets(self, file_path: str, json_format: str = "ndjson") -> List[EmilLogEntry]:
        """
        Get all X2 packets.

        :param file_path: The path to the file.
        :param json_format: The format of the JSON file.

        :return: The X2 packets.
        """

        packets = []
        for emil_log_entry in self._read_from_json_file(file_path, json_format=json_format):
            if emil_log_entry.message["Protocol"] == "SCTP":
                if "X2AP: " in emil_log_entry.message["ZMQ_SCTP_name"]:
                    packets.append(emil_log_entry)
        return packets

    def _get_all_f1ap_or_e1ap_packets(self, file_path: str, json_format: str = "ndjson",
                                      user_data_filter: str = "F1AP: ") -> List[EmilLogEntry]:
        """
        Get all F1AP or E1AP packets.

        :param file_path: The path to the file.
        :param json_format: The format of the JSON file.
        :param user_data_filter: The user data filter.

        :return: The F1AP or E1AP packets.
        """

        packets = []
        for emil_log_entry in self._read_from_json_file(file_path, json_format=json_format):
            if emil_log_entry.message["Protocol"] == "SysCom":
                try:
                    if user_data_filter in emil_log_entry.message["User_data"]:
                        packets.append(emil_log_entry)
                except KeyError:
                    continue
        return packets

    def _get_all_rrc_packets(self, file_path: str, json_format: str = "ndjson") -> List[EmilLogEntry]:
        """
        Get all RRC packets.

        :param file_path: The path to the file.
        :param json_format: The format of the JSON file.

        :return: The RRC packets.
        """

        packets = []
        for emil_log_entry in self._read_from_json_file(file_path, json_format=json_format):
            if emil_log_entry.message["Protocol"] == "ZMQ":
                try:
                    packet_type = emil_log_entry.message["ZMQ_SCTP_name"]
                    if "UlSduReceiveInd" in packet_type or "SrbSendReq" in packet_type:
                        packets.append(emil_log_entry)
                except KeyError:
                    continue
        return packets

    def _read_from_json_file(self, file_path: str, json_format: str = "ndjson") -> Generator[EmilLogEntry, None, None]:
        """
        Generator to read JSON file.

        :param file_path: The path to the file.
        :param json_format: The format of the JSON file.

        :return: The EmilLogEntry.
        """

        with open(file_path, 'rb') as file_obj:
            for emil_log_entry in EmilReader(file_obj=file_obj, json_format=json_format):
                yield emil_log_entry

    def _compare_values(self, expected_values: List[str], given_values: List[str]) -> bool:
        """
        Compare the given and expected values.

        :param given_value: The given value.
        :param expected_value: The expected value.

        :return: True if the given and expected values are equal, otherwise False.
        """

        counter_expected = Counter(expected_values)
        counter_given = Counter(given_values)

        for element, count in counter_expected.items():
            if counter_given[element] < count:
                return False
        return True
