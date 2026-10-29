"""
:copyright: Nokia Networks
:author: Damian Piasecki
:contact: damian.piasecki@nokia.com
:team: MN_RAN_L2_SW_2_KRK_CntDlv_SG
"""
import re
import time
from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger
from lxml import etree
import taf.config.scf as scf


def start_data_traffic_in_egate(ue_id, direction):
    """
        Author: Damian Piasecki
        Contact: damian.piasecki@nokia.com
        Creation Date: 21.05.2021
        Modified Date: -

        The function used to start data traffic in egate

        Args:
            ue_id(int): UE id for which data traffic is started
            direction(str): Traffic direction (ul, dl or bi)

        Returns:
            None
    """
    BuiltIn().import_resource('resources/sites/Ulm/Common/wts_ue.robot')
    BuiltIn().run_keyword('Start data traffic in egate',
                          'ue_id={}'.format(ue_id), 'direction={}'.format(direction), 'pdu=1')


def stop_data_traffic_in_egate(ue_id, direction):
    """
        Author: Damian Piasecki
        Contact: damian.piasecki@nokia.com
        Creation Date: 21.05.2021
        Modified Date: -

        The function used to start data traffic in egate

        Args:
            ue_id(int): UE id for which data traffic is stopped
            direction(str): Traffic direction (ul, dl or bi)

        Returns:
            None
    """
    BuiltIn().import_resource('resources/sites/Ulm/Common/wts_ue.robot')
    BuiltIn().run_keyword('Stop data traffic in egate',
                          'ue_id={}'.format(ue_id), 'direction={}'.format(direction), 'pdu=1')


def start_ping_for_multiple_ues(number_of_ues, traffic_direction):
    """
        Author: Damian Piasecki
        Contact: damian.piasecki@nokia.com
        Creation Date: 21.05.2021
        Modified Date: -

        The function used to start data traffic for multiple UEs at the same time

        Args:
            number_of_ues(int): Number of UEs to which data traffic is started
            traffic_direction(str): Traffic direction (ul, dl or bi)

        Returns:
            None
    """
    for ue_id in range(1, number_of_ues + 1):
        if traffic_direction in ['bi', 'ul']:
            start_data_traffic_in_egate(ue_id=ue_id, direction='ul')
        if traffic_direction in ['bi', 'dl']:
            start_data_traffic_in_egate(ue_id=ue_id, direction='dl')


def stop_data_traffic_for_multiple_ues(number_of_ues, traffic_direction):
    """
        Author: Damian Piasecki
        Contact: damian.piasecki@nokia.com
        Creation Date: 21.05.2021
        Modified Date: -

        The function used to stop data traffic for multiple UEs at the same time

        Args:
            number_of_ues(int): Number of UEs to which data traffic is stopped
            traffic_direction(str): Traffic direction (ul, dl or bi)

        Returns:
            None
    """
    for ue_id in range(1, number_of_ues + 1):
        if traffic_direction in ['bi', 'ul']:
            stop_data_traffic_in_egate(ue_id=ue_id, direction='ul')
        if traffic_direction in ['bi', 'dl']:
            stop_data_traffic_in_egate(ue_id=ue_id, direction='dl')


def handle_ping_for_multiple_ues(number_of_ues, traffic_direction, traffic_duration=5):
    """
        Author: Damian Piasecki
        Contact: damian.piasecki@nokia.com
        Creation Date: 21.05.2021
        Modified Date: -

        The function used to handle ping for multiple UEs at the same time

        Args:
            number_of_ues(str): Number of UEs to which the ping is sent
            traffic_direction(str): Traffic direction (ul, dl or bi)
            traffic_duration(str): Traffic duration in seconds

        Returns:
            None
    """
    number_of_ues = int(number_of_ues)
    start_ping_for_multiple_ues(number_of_ues=number_of_ues, traffic_direction=traffic_direction)
    time.sleep(int(traffic_duration))
    stop_data_traffic_for_multiple_ues(number_of_ues=number_of_ues, traffic_direction=traffic_direction)


def validate_ues_assignment_to_beams(path_to_pdml_file, ue_beam_assignment, max_num_of_ue_per_cell=4):
    """
        Author: Anna Bien
        Contact: anna.bien@nokia.com
        Creation Date: 17.06.2021
        Modified Date: -

        The function validates if UEs are assigned to proper beam.

        Args:
            path_to_pdml_file(str): Path to .pdml file parsed with filter 'uldata_pucchreceivereq'.
            ue_beam_assignment(dict): Dictionary with attached UE ids and its corresponding pattern ids of beams.
                                      e.g. {1: 21, 2: 21, 3: 26, 4: 26, 6: 21, 7: 21, 8: 26, 9: 26}
            max_num_of_ue_per_cell(int): Max number of UEs attached to single cell

        Returns:
            None
    """
    expected_ue_beam_assignment = dict()
    rnti_dict = get_ues_rnti()
    for ue_id, rnti in rnti_dict.items():
        pattern_id = ue_beam_assignment[ue_id]
        expected_ue_beam_assignment.update({int(rnti, 16): pattern_id})
    tree = etree.parse(path_to_pdml_file)
    for packet in tree.iter('packet'):
        icom_5g = [item for item in packet if item.attrib['name'] == 'icom_5g'][0]
        rnti_dict = dict()
        pattern_id_dict = dict()
        fields = icom_5g.findall('proto/proto/proto/proto/proto/proto/proto/field')
        for field in fields:
            for index in range(0, max_num_of_ue_per_cell):
                rnti = field.attrib['show'] if field.attrib['name'] == 'UlData_PucchReceiveReq.pucchResources_' \
                                                                        'item_{}.rnti'.format(index) else None
                if rnti is not None:
                    rnti_dict.update({'rnti{}'.format(index): rnti})
        fields = icom_5g.findall('proto/proto/proto/proto/proto/proto/proto/proto/field')
        for field in fields:
            pattern_id = field.attrib['show'] if field.attrib['name'] == \
                                                 'UlData_PucchReceiveReq.patternId.patternId_item_0' else None
            if pattern_id is not None:
                pattern_id_dict.update({'pattern_id{}'.format(len(pattern_id_dict)): pattern_id})
        for index in range(0, len(rnti_dict)):
            try:
                assert (int(rnti_dict['rnti{}'.format(index)], 16) in expected_ue_beam_assignment.keys())
            except AssertionError:
                logger.info(rnti_dict['rnti{}'.format(index)], also_console=True)
                logger.info('Not expected RNTI {} found in BIP logs'.format(
                    int(rnti_dict['rnti{}'.format(index)], 16)
                ), also_console=True)
                raise AssertionError
            try:
                assert(int(pattern_id_dict['pattern_id{}'.format(index)], 16) ==
                       expected_ue_beam_assignment[int(rnti_dict['rnti{}'.format(index)], 16)])
            except AssertionError:
                logger.info('UE with RNTI {} assigned to wrong beam with patternID: {}'
                            .format(int(rnti_dict['rnti{}'.format(index)], 16)),
                            int(pattern_id_dict['pattern_id{}'.format(index)], 16), also_console=True)
                raise AssertionError
    logger.info('BIP logs validation finished successfully', also_console=True)


def get_ues_rnti(egate_console_log_path='/opt/iphy/latest/egate_console.log'):
    """
        Author: Anna Bien
        Contact: anna.bien@nokia.com
        Creation Date: 17.06.2021
        Modified Date: -

        Get UEs RNTI from egate_console.log

        Args:
            egate_console_log_path(str): Path to egate_console.log

        Returns:
            rnti_dict(dict): Dictionary with UEs RNTI
    """
    rnti_dict = dict()
    regexp_rnti = re.compile('UE(\\d+):.*\\(crnti: \\d+ = (0x.*)\\)')
    with open(egate_console_log_path, "r") as log_file:
        data = log_file.read()
    rnti_list = regexp_rnti.findall(data)
    for rnti in rnti_list:
        rnti_dict.update({int(rnti[0]): rnti[1]})
    logger.info('UE RNTI assignment: {}'.format(rnti_dict))
    return rnti_dict


def change_vlan_b_in_scf(path_to_scf, dist_name='MRBTS-1/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1'):
    """
        Author: Anna Bien
        Contact: anna.bien@nokia.com
        Creation Date: 22.06.2021
        Modified Date: -

        Offline change of vlan B in scfc file according to TL name.

        Args:
            path_to_scf(str): Path to scf xml file that will be overwritten
            dist_name(str): DistName of object with vlanId parameter to change.
        Returns:
            None
    """
    tl = BuiltIn().get_variable_value('${tl}', None)
    hostname = tl.test_pc.default_ssh_connection_details.addr.split('.')[0]
    regex_tl_id = re.compile('\\d-\\d-UTE5G\\D+(\\d{1,})')
    tl_id = int(regex_tl_id.findall(hostname)[0])
    vlan_b = 1500 + tl_id
    current_scf = scf.scf()
    try:
        current_scf.load_scf(path_to_scf)
        current_scf.modify_scf_element(value=str(vlan_b), dist_name=dist_name, p_name='vlanId')
        current_scf.save_scf(path_to_scf)
        logger.info('vlanId changed to {} in {}'.format(vlan_b, path_to_scf), also_console=True)
    except OSError:
        raise OSError('Could not change vlanId. File {} is not accessible'.format(path_to_scf))
    except KeyError:
        raise KeyError('Could not found vlanId in {}.'.format(dist_name))
