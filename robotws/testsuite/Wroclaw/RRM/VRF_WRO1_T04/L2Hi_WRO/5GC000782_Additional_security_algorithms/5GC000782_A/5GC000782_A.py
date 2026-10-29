import os
from ta5g_interface_tools import ta5g_interface_tools
from taf.transport.ssh.ssh_keywords import SSHManager

filename_path = ta5g_interface_tools().get_robot_output_dir()


def start_capturing_pcap_on_e1_and_f1_interfaces(filename):
    ssh = SSHManager()
    ssh.connect_to(hostname='192.168.255.129', username='toor4nsn', password='oZPS0POrRieRtu', alias='check')
    ssh.send_command(command='cd /tmp&&tcpdump -i any -w ' + filename + ' -vv', connection='check')


def common_assert(output_dirpath, filtr, message):
    os.system('tshark -Y "' + filtr + '" -r ' + filename_path + '/e1_f1_interfaces.pcap' + ' -w ' + output_dirpath)
    size_info = os.stat(output_dirpath)
    print(size_info.st_size)
    assert size_info.st_size > 250, message


def assert_that_nRencryptionAlgorithms_are_supported(output_dirpath):
    common_assert(output_dirpath, filtr='x2ap.nRencryptionAlgorithms == e0:00',
                  message='nRencryptionAlgorithms seems to be empty or not supported, please check')


def assert_that_reponseInformationSgNBReconfComp_exists(output_dirpath):
    common_assert(output_dirpath, filtr='x2ap.id == 214',
                  message='reponseInformationSgNBReconfComp seems to be empty, please check')


def assert_that_e1ap_ciphering_algorithm_equals_nea3(output_dirpath):
    common_assert(output_dirpath, filtr='e1ap.cipheringAlgorithm == 3',
                  message='E1ap ciphering algorithm seems not to be nea3, please check')


def assert_that_bearer_context_setup_response_exists(output_dirpath):
    common_assert(output_dirpath, filtr='e1ap.id == 16',
                  message='bearer context setup response seem to not exist, please check')


def assert_that_CUtoDURRCInformation_exists_in_setup_request(output_dirpath):
    common_assert(output_dirpath, filtr='f1ap.id == 9',
                  message='CUtoDURRCInformation seem to not exist in setup request, please check')


def assert_that_CUtoDURRCInformation_exists_in_setup_response(output_dirpath):
    common_assert(output_dirpath, filtr='f1ap.id == 39',
                  message='CUtoDURRCInformation seem to not exist in setup reponse, please check')


def assert_that_nrrrc_ciphering_algorithm_equals_nea3(output_dirpath):
    common_assert(output_dirpath, filtr='nr-rrc.cipheringAlgorithm == 3',
                  message='Nrrrc ciphering algorithm seems not to be nea3, please check')


def assert_that_e1ap_ciphering_algorithm_are_not_supported(output_dirpath):
    common_assert(output_dirpath, filtr='e1ap.cipheringAlgorithm == 0',
                  message='E1ap ciphering algorithm seems to support something, but shot not, please check')


def assert_that_nrrrc_ciphering_algorithm_are_not_supported(output_dirpath):
    common_assert(output_dirpath, filtr='nr-rrc.cipheringAlgorithm == 0',
                  message='Nrrrc ciphering algorithm seems to support something, but shot not, please check')


def assert_that_e1ap_ciphering_algorithm_equals_nea1(output_dirpath):
    common_assert(output_dirpath, filtr='e1ap.cipheringAlgorithm == 1',
                  message='E1ap ciphering algorithm seems not to be nea1, please check')


def assert_that_nrrrc_ciphering_algorithm_equals_nea1(output_dirpath):
    common_assert(output_dirpath, filtr='nr-rrc.cipheringAlgorithm == 1',
                  message='Nrrrc ciphering algorithm seems not to be nea1, please check')


def assert_that_e1ap_ciphering_algorithm_equals_nea2(output_dirpath):
    common_assert(output_dirpath, filtr='e1ap.cipheringAlgorithm == 2',
                  message='E1ap ciphering algorithm seems not to be nea2, please check')


def assert_that_nrrrc_ciphering_algorithm_equals_nea2(output_dirpath):
    common_assert(output_dirpath, filtr='nr-rrc.cipheringAlgorithm == 2',
                  message='Nrrrc ciphering algorithm seems not to be nea2, please check')
