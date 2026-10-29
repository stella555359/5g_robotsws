"""
:copyright: Nokia Networks
:author: Marek Piotrowski
:contact: marek.piotrowski@nokia.com
--------------------------------------------------------------------


[Documentation] LIBRARY:NE3S Packet Parser

Metadata:
| Version | Status | Date | Author | Change Notification |
| 0.1 | DRAFT | 25.06.2018 | Sebastian Zarebski | Initial Version |
| 0.2 | DRAFT | 25.06.2018 | Marek Piotrowski | Initial Version |
 End of Metadata

::Example of usage with robotframework::

Lets assume we have python library:
    |Library resources.FZM.lib.ta_sc_ne3s_parser
    |
    |parse_wireshark_with_ne3s_messages
    |Validate NE3S operation  filename.json  successful_registration
"""

from NE3SPacketReader import Ne3SPacketReader
from robot.api import logger
import NE3SPacketValidator


class NE3SParserInterface(object):
    @staticmethod
    def parse_wireshark_with_ne3s_messages(file_path_to_wireshark, output_files_directory):
        """
        [Documentation] KEYWORD:parse_wireshark_with_ne3s_messages

        Metadata:
        | Version | Status | Date | Author | Change Notification |
        | 0.1 | DRAFT | 25.06.2018 | Anna Banys | Initial Version |
        | 0.2 | DRAFT | 06.07.2018 | Marek Piotrowski | modified calling |
        End of Metadata

        Change History:
        Delete file_path_to_wireshark = file_path_to_wireshark.encode('utf-8') before
        ne3s_packet_parser = Ne3SPacketReader(file_path_to_wireshark, output_files_directory)
        when do python2->3 migration


        :param file_path_to_wireshark:
        :param output_files_directory:
        :return:
        """
        logger.debug("[parse_wireshark_with_ne3s_messages] start...\n\n")
        ne3s_packet_parser = Ne3SPacketReader(file_path_to_wireshark, output_files_directory)
        logger.debug("[parse_wireshark_with_ne3s_messages] initialization finished")
        path_tmp = ne3s_packet_parser.get_path_to_json_file_with_results()
        logger.debug("[parse_wireshark_with_ne3s_messages] parsing finished")
        logger.debug("[parse_wireshark_with_ne3s_messages] path to json file with results: {}".format(path_tmp))
        return path_tmp

    @staticmethod
    def test_function():
        logger.debug("[parse_wireshark_with_ne3s_messages] parsing finished")

    @staticmethod
    def validate_ne3s_operation(json_filepath, operation_name, *args, **kwargs):
        return NE3SPacketValidator.validate_operation(json_filepath, operation_name, *args, **kwargs)

    @staticmethod
    def validate_ne3s_operation_with_netact(json_filepath, clab, operation_name, *args, **kwargs):
        return NE3SPacketValidator.validate_operation_with_netact(json_filepath, clab, operation_name, *args, **kwargs)

    @staticmethod
    def count_ne3s_msg(json_filepath, msg, *args, **kwargs):
        return NE3SPacketValidator.count_msg(json_filepath, msg, *args, **kwargs)


if __name__ == '__main__':
    obj = NE3SParserInterface()
    file_path = obj.parse_wireshark_with_ne3s_messages('/home/ute/log/gnb-tcpdump/gnb-tcpdump_1647433263.pcap',
                                                       '/home/ute/logs/')
    print("hello {}".format(file_path))

    obj.validate_ne3s_operation(json_filepath=file_path, operation_name='reregister', level='basic')
    obj.validate_ne3s_operation(json_filepath=file_path, operation_name='cm_upload')
    obj.validate_ne3s_operation(json_filepath=file_path, operation_name='asc_notification', level='basic',
                                asc_status='Identification finished')
    obj.validate_ne3s_operation(json_filepath=file_path, operation_name='asc_notification', level='basic',
                                asc_status='Autoconfiguration completed')
