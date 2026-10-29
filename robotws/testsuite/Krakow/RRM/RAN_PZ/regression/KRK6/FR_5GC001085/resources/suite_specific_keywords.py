"""
This module is designed to interact with gNBs for tasks such as
retrieving and validating configuration data from SCF files,
performing gNB commissioning, and parsing/verifying RRC (Radio Resource Control) messages from QXDM logs.

:copyright:     Nokia Networks
:author:        Mikolaj Borkowski
:maintainer:    Mikolaj Borkowski
:contact:       mikolaj.borkowski@nokia.com
:team:          KRK6
"""
import os
import xmltodict
import xml.dom.minidom
import subprocess
from robot.api import logger
from taf.sbts.oam.coam.admin import admin
from taf.rfrl.utilities.robot.general import get_builtin_value
from taf.rfrl.ue.parsers.qxdm_parser import QxdmLogParser
from ute_common_abstract_core.message import Message

_tl = get_builtin_value(param_name="tl")


class MissingXlinkObject(Exception):
    """This exception is raised when there is no Xn link object in WebEM."""
    pass


class MissingMessagesError(Exception):
    """This exception is raised when there is no expected RRC message in parsed QXDM file."""
    pass


def handle_admin(func):
    """
    The decorator logs in the user for gNB Web Element Manager.
    :param func: function requiring authentication
    :return: function
    """
    def inner(*args, **kwargs):
        gnb_ip = _tl.gnbs[0].cu.oam_ssh_connection_details.addr
        webem_username = _tl.gnbs[0].cu.oam_http_connection_details.username
        webem_password = _tl.gnbs[0].cu.oam_http_connection_details.password
        admin_instance = admin()
        try:
            connection = admin_instance.connect_to(bts_host=gnb_ip, username=webem_username, password=webem_password)
            result = func(connection=connection, *args, **kwargs)
            return result
        finally:
            admin_instance.teardown_admin()
    return inner


@handle_admin
def get_objects_list(object_type, *args, **kwargs):
    """
    The function gets list of specified objects form scfc file.
    :param object_type: NRELL or NRADJNRCELL string
    :param args: arguments required for authentication
    :param kwargs: keyword arguments required for authentication
    :return: list of objects founded in dcf file
    """
    configuration = kwargs["connection"].get_scf(export_type="configuration")
    xmldom = xml.dom.minidom.parseString(configuration)
    itemlist = xmldom.getElementsByTagName('managedObject')
    objects = [xmltodict.parse(item.toxml()) for item in itemlist
               if item.attributes['class'].value.endswith(object_type)]
    if objects:
        logger.info(f"Present {object_type} objects in SCF:")
        for obj in objects:
            logger.info(f"\t{obj}")
    else:
        logger.info("No {} object present in SCF")
    return objects


def check_if_there_are_no_objects_in_scf(object_type):
    """
    The function checks if gNB's scfc file doesn't contain specified objects.
    :param object_type: NRELL or NRADJNRCELL string
    :return: None
    """
    objects = get_objects_list(object_type)
    assert len(objects) == 0, f"There is {len(objects)} {object_type} object but should be 0"


def get_number_of_objects_in_scf(object_type):
    """
    The function gets number of specified objects form scfc file.
    :param object_type: NRELL or NRADJNRCELL string
    :return: None
    """
    objects = get_objects_list(object_type)
    return len(objects)


def _verify_object_prams(obj, **params):
    """
    The function verify excepted parameters with real object parameters
    :param obj: object parameters scraped form scfc file
    :param params: excepted object parameter in key-value format
    :return: list of all invalid parameters
    """
    plist = {p['@name']: p['#text'] for p in obj['managedObject']['p']}
    invalid_object_params = []
    for key, value in params.items():
        if key not in plist or not plist[key] == str(value):
            invalid_object_params.append({key: value})
    return invalid_object_params


def check_if_any_object_contains_specified_parameters(object_type, **kwargs):
    """
    The function verifies existence of specified object in scfc file. It downloads all objects
    from the scfc file and checks if there is any object with configuration specified in keyword arguments.
    If no match was found, the function will raise an assertion error.
    :param object_type: one of the available object types (NRELL or NRADJNRCELL)
    :param kwargs: object parameters to verify as key and value pairs
    :return: None
    """
    objects = get_objects_list(object_type)
    assert len(objects) != 0, f'No {object_type} object.'
    verified_objects = []
    for obj in objects:
        invalid_params = _verify_object_prams(obj, **kwargs)
        logger.info(invalid_params)
        if len(invalid_params) == 0:
            verified_objects.append(obj)
    assert len(verified_objects) != 0, f'{object_type} object exists but parameters don\'t match.'


def get_nr_cell_id_in_hex(nr_cell_id):
    """
    The function dump nrcellid to hex format.
    :param nr_cell_id: cell's nrcellid in dec format
    :return: cell's nrcellid in hex format
    """
    return f"{int(nr_cell_id):#011x}"


def assert_existence_of_xnlink_in_scf():
    """
    The function checks Xn object existence and raises exception when it's missing.
    :return: None
    """
    objects = get_objects_list('XNLINK')
    if len(objects) == 0:
        raise MissingXlinkObject("No XNLINK object.")


def get_rrc_message(file_path, message_name, message_direction, rat):
    """
    Gets RRC message from QCAT output txt file.
    E.g:
        For message from QCAT output txt file:
            { ... 'DL-DCCH-Message': {'message': {'c1': {'rrcRelease': { ... }}}} }
        parameter message_name equals to 'rrcRelease'
        parameter message_direction equals to 'DL-DCCH-Message'

    :param rat: 4G or 5G
    :param file_path: path to file with messages
    :param message_name: name of message e.g: 'rrcRelease'
    :param message_direction: direction of message e.g: 'DL-DCCH-Message'
    :return: list of all matched messages
    """
    if rat == "5G":
        rrc_id = '0xB821'
    elif rat == "4G":
        rrc_id = '0xB0C0'
    else:
        raise NotImplementedError('Unknown message. Only 5g or 4g RRC messages can be parsed. ')
    parser = QxdmLogParser(file_path=file_path, message_ids=[rrc_id])
    parser.parse()
    messages = []
    logger.debug(f'[*] QxdmLogParser(...).ret:\n{parser.ret}')
    for msg in parser.ret[rrc_id]:
        try:
            message = msg[message_direction]['message']['c1'][message_name]
            metadata = get_message_metadata(msg, message_direction)
            messages.append(Message(message, metadata))
        except KeyError:
            continue
    return messages


def get_message_metadata(msg, message_direction):
    """
    Gets metadata of RRC message.
    :param msg: RRC message
    :param message_direction: direction of message e.g: 'DL-DCCH-Message'
    :return: dictionary containing RRC message metadata
    """
    metadata_keys = msg.keys()
    metadata_keys = [mtk for mtk in metadata_keys if mtk != message_direction]
    metadata = {}
    for mt in metadata_keys:
        metadata[mt] = msg[mt]
    return metadata


def verify_cgi_request_with_drx_release_and_anr_drx_profile_configuration_occured_in_rrc_messages(file_path,
                                                                                                  target_cell_pci):
    """
    Function verifies presence of CGI-Info request and dRX profile configuration release and addition
    in RRC Reconfiguration QXDM messages converted into text file.
    :param file_path: path to file with messages
    :return: None
    """
    rrc_reconfiguration_messages = get_rrc_message(file_path, message_name='rrcReconfiguration',
                                                   message_direction='DL-DCCH-Message', rat='5G')
    if len(rrc_reconfiguration_messages) == 0:
        raise MissingMessagesError('RRC Reconfiguration not exist in file')

    drx_release = False
    anr_drx_profile_configuration = False
    cgi_report_request = False

    for rrc_reconfiguration in rrc_reconfiguration_messages:
        if not drx_release or not anr_drx_profile_configuration or not cgi_report_request:
            logger.info("RRC Reconfiguration message: " + str(rrc_reconfiguration))
            if 'mac-CellGroupConfig' in (rrc_reconfiguration['criticalExtensions']['rrcReconfiguration']
                                                            ['nonCriticalExtension']['masterCellGroup']['CONTAINING']):
                if 'drx-Config' in (rrc_reconfiguration['criticalExtensions']['rrcReconfiguration']
                                                       ['nonCriticalExtension']['masterCellGroup']['CONTAINING']
                                                       ['mac-CellGroupConfig']):
                    if 'release' in (rrc_reconfiguration['criticalExtensions']['rrcReconfiguration']
                                                        ['nonCriticalExtension']['masterCellGroup']['CONTAINING']
                                                        ['mac-CellGroupConfig']['drx-Config']):
                        drx_release = True
                if 'drx-LongCycleStartOffset' in \
                        (rrc_reconfiguration['criticalExtensions']['rrcReconfiguration']['nonCriticalExtension']
                                            ['masterCellGroup']['CONTAINING']['mac-CellGroupConfig']['drx-Config']):
                    if 'ms640' in \
                            (rrc_reconfiguration['criticalExtensions']['rrcReconfiguration']['nonCriticalExtension']
                                                ['masterCellGroup']['CONTAINING']['mac-CellGroupConfig']['drx-Config']
                                                ['setup']['drx-LongCycleStartOffset']):
                        anr_drx_profile_configuration = True
            if 'measConfig' in (rrc_reconfiguration['criticalExtensions']['rrcReconfiguration']):
                report_type = (
                    rrc_reconfiguration['criticalExtensions']['rrcReconfiguration']['measConfig']
                    ['reportConfigToAddModList'][0]['reportConfig']['reportConfigNR']['reportType']
                )
                if 'reportCGI' in report_type:
                    cgi = report_type['reportCGI']
                    if (cgi.get('cellForWhichToReportCGI') is not None
                            and int(cgi['cellForWhichToReportCGI']) == int(target_cell_pci)):
                        cgi_report_request = True

    assert drx_release and anr_drx_profile_configuration and cgi_report_request


def verify_cgi_info_and_handover_succeeded_in_rrc_messages(file_path, target_cell_pci):
    """
    Function verifies presence of CGI-Info response and HO messages
    in RRC QXDM messages converted into text file.
    :param file_path: path to file with messages
    :param target_cell_pci: PCI of expected target cell
    :return: None
    """
    measurement_report_messages = get_rrc_message(file_path, message_name='measurementReport',
                                                  message_direction='UL-DCCH-Message', rat='5G')
    rrc_reconfiguration_messages = get_rrc_message(file_path, message_name='rrcReconfiguration',
                                                   message_direction='DL-DCCH-Message', rat='5G')
    rrc_reconfiguration_complete_messages = get_rrc_message(file_path, message_name='rrcReconfigurationComplete',
                                                            message_direction='UL-DCCH-Message', rat='5G')
    if len(measurement_report_messages) == 0:
        raise MissingMessagesError('Measurement Report not exist in file')
    if len(rrc_reconfiguration_messages) == 0:
        raise MissingMessagesError('RRC Reconfiguration not exist in file')
    if len(rrc_reconfiguration_complete_messages) == 0:
        raise MissingMessagesError('RRC Reconfiguration Complete not exist in file')

    cgi_info = False
    ho_reconfiguration = False
    ho_reconfiguration_complete = False

    for measurement_report in measurement_report_messages:
        logger.info("RRC Measurement Report message: " + str(measurement_report))
        if 'cgi-Info' in \
                (measurement_report['criticalExtensions']['measurementReport']['measResults']['measResultNeighCells']
                                   ['measResultListNR'][0]):
            if (measurement_report['criticalExtensions']['measurementReport']['measResults']['measResultNeighCells']
                                  ['measResultListNR'][0]['physCellId']) == int(target_cell_pci):
                cgi_info = True
    for rrc_reconfiguration in rrc_reconfiguration_messages:
        logger.info("RRC Reconfiguration message: " + str(rrc_reconfiguration))
        if 'nonCriticalExtension' in (rrc_reconfiguration['criticalExtensions']['rrcReconfiguration']):
            if 'spCellConfig' in \
                    (rrc_reconfiguration['criticalExtensions']['rrcReconfiguration']['nonCriticalExtension']
                                        ['masterCellGroup']['CONTAINING']):
                if 'reconfigurationWithSync' in (rrc_reconfiguration['criticalExtensions']['rrcReconfiguration']
                                                                    ['nonCriticalExtension']['masterCellGroup']
                                                                    ['CONTAINING']['spCellConfig']):
                    if (rrc_reconfiguration['criticalExtensions']['rrcReconfiguration']['nonCriticalExtension']
                                           ['masterCellGroup']['CONTAINING']['spCellConfig']['reconfigurationWithSync']
                                           ['spCellConfigCommon']['physCellId'] == int(target_cell_pci)):
                        ho_reconfiguration = True
    for rrc_reconfiguration_complete in rrc_reconfiguration_complete_messages:
        rrc_reconfiguration_complete_pci = getattr(rrc_reconfiguration_complete, 'Radio Bearer ID')
        logger.info("PCI from metadata of RRC Reconfiguration Complete message: " +
                    str(rrc_reconfiguration_complete_pci))
        if str(target_cell_pci) in rrc_reconfiguration_complete_pci:
            ho_reconfiguration_complete = True

    assert cgi_info and ho_reconfiguration and ho_reconfiguration_complete, \
        "CGI Info not occured or HO unsuccessful, check RRC messages. "


def verify_handover_succeeded_in_rrc_messages(file_path, target_cell_pci):
    """
    Function verifies HO messages in RRC QXDM messages converted into text file.
    :param file_path: path to file with messages
    :param target_cell_pci: PCI of expected target cell
    :return: None
    """
    rrc_reconfiguration_messages = get_rrc_message(file_path, message_name='rrcReconfiguration',
                                                   message_direction='DL-DCCH-Message', rat='5G')
    rrc_reconfiguration_complete_messages = get_rrc_message(file_path, message_name='rrcReconfigurationComplete',
                                                            message_direction='UL-DCCH-Message', rat='5G')
    if len(rrc_reconfiguration_messages) == 0:
        raise MissingMessagesError('RRC Reconfiguration not exist in file')
    if len(rrc_reconfiguration_complete_messages) == 0:
        raise MissingMessagesError('RRC Reconfiguration Complete not exist in file')

    ho_reconfiguration = False
    ho_reconfiguration_complete = False

    for rrc_reconfiguration in rrc_reconfiguration_messages:
        logger.info("RRC Reconfiguration message: " + str(rrc_reconfiguration))
        if 'nonCriticalExtension' in (rrc_reconfiguration['criticalExtensions']['rrcReconfiguration']):
            if 'spCellConfig' in \
                    (rrc_reconfiguration['criticalExtensions']['rrcReconfiguration']['nonCriticalExtension']
                                        ['masterCellGroup']['CONTAINING']):
                if 'reconfigurationWithSync' in (rrc_reconfiguration['criticalExtensions']['rrcReconfiguration']
                                                                    ['nonCriticalExtension']['masterCellGroup']
                                                                    ['CONTAINING']['spCellConfig']):
                    if (rrc_reconfiguration['criticalExtensions']['rrcReconfiguration']['nonCriticalExtension']
                                           ['masterCellGroup']['CONTAINING']['spCellConfig']['reconfigurationWithSync']
                                           ['spCellConfigCommon']['physCellId'] == int(target_cell_pci)):
                        ho_reconfiguration = True
    for rrc_reconfiguration_complete in rrc_reconfiguration_complete_messages:
        rrc_reconfiguration_complete_pci = getattr(rrc_reconfiguration_complete, 'Radio Bearer ID')
        logger.info("PCI from metadata of RRC Reconfiguration Complete message: " + rrc_reconfiguration_complete_pci)
        if str(target_cell_pci) in rrc_reconfiguration_complete_pci:
            ho_reconfiguration_complete = True

    assert ho_reconfiguration and ho_reconfiguration_complete, \
        "CGI Info not occured or HO unsuccessful, check RRC messages. "


def start_hanging_resource_file(ip, port, username, password, script_path=None):
    """
    Run hanging_check_4G_5G.py and check result if there is hanging resource or not.
    :param ip: ip of gNB
    :param port: port of gNB
    :param username: username to perform ssh
    :param password: password to perform ssh
    :param script_path: path to hanging_check_4G_5G.py script (default is directory of current file)
    :return: None
    """
    if script_path is None:
        parent = os.path.dirname(os.path.abspath(__file__))
        script_path = os.path.join(parent, 'hanging_check_4G_5G.py')

    command = f'python {script_path} -i {ip} -p {port} -u {username} -s {password}'
    logger.info(f'Executed command: {command}')

    with subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE) as process:
        stdout, stderr = process.communicate()
        output = stdout.decode('utf-8') if process.returncode == 0 else stderr.decode('utf-8')
        logger.debug(f'Hanging script execution output:\n{output}')
        if 'There were hanging resources' in output:
            raise ValueError('Hanging resources were found on gNB')
        if 'No hanging resources' not in output:
            raise ValueError('Missing expected results in Hanging script execution output.')
        logger.info('No hanging resources as expected.')


def verify_pci_in_measurement_reports(file_path, expected_pci):
    """
    Verifies the presence of a specific Physical Cell ID (PCI)
    as neighbour cell in UL-DCCH Measurement Report messages.

    :param file_path: Path to the file containing RRC messages.
    :param expected_pci: The Physical Cell ID (PCI) to search for.
    :return: None
    :raises MissingMessagesError: If no Measurement Report messages are found.
    :raises AssertionError: If the expected PCI is not found in any serving or neighbour cell.
    """
    pci_found_in_report = False
    expected_pci_int = int(expected_pci)

    measurement_report_messages = get_rrc_message(file_path, message_name='measurementReport',
                                                  message_direction='UL-DCCH-Message', rat='5G')
    if not measurement_report_messages:
        raise MissingMessagesError('Measurement Report messages not found in file.')

    for measurement_report_msg_obj in measurement_report_messages:
        logger.debug("Checking Measurement Report message: " + str(measurement_report_msg_obj))

        measurement_report_content = measurement_report_msg_obj.get('criticalExtensions', {}).get('measurementReport',
                                                                                                  {})
        meas_results = measurement_report_content.get('measResults', {})

        # Check neighbour cell PCIs
        meas_result_neigh_cells = meas_results.get('measResultNeighCells', {})
        meas_result_list_nr = meas_result_neigh_cells.get('measResultListNR', [])
        for neighbour_cell_info in meas_result_list_nr:
            neighbour_pci = neighbour_cell_info.get('physCellId')
            if neighbour_pci is not None and neighbour_pci == expected_pci_int:
                logger.info(f"Expected PCI {expected_pci_int} found as neighbour cell PCI.")
                pci_found_in_report = True
                break

        if pci_found_in_report:
            break

    assert pci_found_in_report, \
        f"Expected PCI {expected_pci_int} not found in any neighbour cell in Measurement Reports."
