
import os
import xmltodict
import xml.dom.minidom
import subprocess
from robot.api import logger
from taf.sbts.oam.coam.admin import admin
from taf.rfrl.utilities.robot.general import get_builtin_value
from taf.internal.sbts.admin.exceptions import AdminApiProcedureFailureException
from taf.rfrl.bts.devices.du.commissioning import GnbCommissioning
from taf.rfrl.ue.parsers.qxdm_parser import QxdmLogParser
from ute_common_abstract_core.message import Message


_tl = get_builtin_value(param_name="tl")


class MissingXlinkObject(Exception):
    """This exception is raised when there is no Xn link object in WebEM ."""
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
        logger.info("Present {} objects in SCF:".format(object_type))
        for obj in objects:
            logger.info("\t{}".format(obj))
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
    assert len(objects) == 0, "There is {} {} object but should be 0".format(len(objects), object_type)


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
    assert len(objects) != 0, 'No {} object.'.format(object_type)
    verified_objects = []
    for obj in objects:
        invalid_params = _verify_object_prams(obj, **kwargs)
        logger.info(invalid_params)
        if len(invalid_params) == 0:
            verified_objects.append(obj)
    assert len(verified_objects) != 0, '{} object exists but parameters don\'t match.'.format(object_type)


def get_nr_cell_id_in_hex(nr_cell_id):
    """
    The function dump nrcellid to hex format.
    :param nr_cell_id: cell's nrcellid in dec format
    :return: cell's nrcellid in hex format
    """
    return "{0:#0{1}x}".format(int(nr_cell_id), 11)


def assert_existence_of_xnlink_in_scf():
    """
    The function checks Xn object existence and raises exception when it's missing.
    :return: None
    """
    objects = get_objects_list('XNLINK')
    if len(objects) == 0:
        raise MissingXlinkObject("No XNLINK object.")


def perform_commissioning_for_gnbs(scf_gnb0=None, scf_gnb1=None):
    """
    The function perform commissioning for max 2 gNBs when SCF file path is provided.
    :param scf_gnb0: path to SCF for first gNB from __init__.py configuration file
    :param scf_gnb1: path to SCF for second gNB from __init__.py configuration file
    :return: None
    """
    if scf_gnb0 is not None:
        perform_commissioning_for_gnb(scf_gnb=scf_gnb0, bts_id=0)
    if scf_gnb1 is not None:
        perform_commissioning_for_gnb(scf_gnb=scf_gnb1, bts_id=1)


def perform_commissioning_for_gnb(scf_gnb, bts_id):
    """
    The function perform commissioning for gNB with SCF file.
    :param scf_gnb: path to SCF
    :param bts_id: gNB/BTS index from __init__.py configuration file
    :return: None
    """
    logger.info("Performing commissioning on gNB-{} with {} SCF".format(bts_id, scf_gnb))
    gnb_commissioning = GnbCommissioning()

    try:
        gnb_commissioning.connect(bts_id=bts_id, du_id=0)
        connection_name = gnb_commissioning.rest_alias.format(bts_id, 0)
        gnb_commissioning.admin.validate_scf_online(scf_file=scf_gnb,
                                                    skip_parameter_relation_errors=False,
                                                    detailed_output=True,
                                                    connection=connection_name)

    except AdminApiProcedureFailureException as e:
        logger.warn("Validation SCF Failed - Please consider adapt your SCF\n{}".format(repr(e)))

    gnb_commissioning.perform_bts_full_commissioning(scf_file=scf_gnb,
                                                     bts_id=bts_id,
                                                     skip_parameter_relation_errors=True,
                                                     should_activate=True,
                                                     validate_scf=False,
                                                     timeout=300,
                                                     du_id=0)


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
    logger.debug('[*] QxdmLogParser(...).ret:\n{}'.format(parser.ret))
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


def verify_cgi_request_with_drx_release_and_anr_drx_profile_configuration_occured_in_rrc_messages(file_path):
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

            mac_cell_group_config = rrc_reconfiguration.get('criticalExtensions', {}).get('rrcReconfiguration', {}).get(
                'nonCriticalExtension', {}).get('masterCellGroup', {}).get('CONTAINING', {}).get('mac-CellGroupConfig',
                                                                                                 {})
            logger.info(mac_cell_group_config)
            if 'drx-Config' in mac_cell_group_config:
                drx_config = mac_cell_group_config['drx-Config']
                if 'release' in drx_config:
                    drx_release = True
                if 'drx-LongCycleStartOffset' in drx_config.get('setup', {}):
                    if 'ms640' in drx_config.get('setup', {}).get('drx-LongCycleStartOffset', {}):
                        anr_drx_profile_configuration = True

            meas_config = rrc_reconfiguration.get('criticalExtensions', {}).get('rrcReconfiguration', {}).get(
                'measConfig', {})
            logger.info(meas_config)
            if 'reportCGI' in meas_config.get('reportConfigToAddModList', [{}])[0].get('reportConfig', {}).get(
                    'reportConfigNR', {}).get('reportType', {}):
                cgi_report_request = True

    logger.info("drx_release:" + str(drx_release))
    logger.info("anr_drx_profile_configuration:" + str(anr_drx_profile_configuration))
    logger.info("cgi_report_request:" + str(cgi_report_request))
    assert drx_release and anr_drx_profile_configuration and cgi_report_request, \
        "DRX not released or CGI report not requested, check RRC messages."


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

        meas_result_list_nr = measurement_report.get('criticalExtensions', {}).get('measurementReport', {}).get(
            'measResults', {}).get('measResultNeighCells', {}).get('measResultListNR', [{}])

        if len(meas_result_list_nr) > 0 and 'cgi-Info' in meas_result_list_nr[0]:
            if meas_result_list_nr[0].get('physCellId') == int(target_cell_pci):
                cgi_info = True

    for rrc_reconfiguration in rrc_reconfiguration_messages:
        logger.info("RRC Reconfiguration message: " + str(rrc_reconfiguration))

        non_critical_extension = rrc_reconfiguration.get('criticalExtensions', {}).get('rrcReconfiguration', {}).get(
            'nonCriticalExtension', {})
        master_cell_group = non_critical_extension.get('masterCellGroup', {}).get('CONTAINING', {})

        if 'spCellConfig' in master_cell_group:
            sp_cell_config = master_cell_group.get('spCellConfig', {})
            if 'reconfigurationWithSync' in sp_cell_config:
                reconfiguration_with_sync = sp_cell_config.get('reconfigurationWithSync', {})
                sp_cell_config_common = reconfiguration_with_sync.get('spCellConfigCommon', {})
                if sp_cell_config_common.get('physCellId') == int(target_cell_pci):
                    ho_reconfiguration = True

    for rrc_reconfiguration_complete in rrc_reconfiguration_complete_messages:
        rrc_reconfiguration_complete_pci = getattr(rrc_reconfiguration_complete, 'Radio Bearer ID', None)
        logger.info("PCI from metadata of RRC Reconfiguration Complete message: " +
                    str(rrc_reconfiguration_complete_pci))
        if rrc_reconfiguration_complete_pci and str(target_cell_pci) in rrc_reconfiguration_complete_pci:
            ho_reconfiguration_complete = True

    logger.info("cgi_info:" + str(cgi_info))
    logger.info("ho_reconfiguration:" + str(ho_reconfiguration))
    logger.info("ho_reconfiguration_complete:" + str(ho_reconfiguration_complete))
    assert cgi_info and ho_reconfiguration and ho_reconfiguration_complete, \
        "CGI Info not occurred or HO unsuccessful, check RRC messages."


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

        non_critical_extension = rrc_reconfiguration.get('criticalExtensions', {}).get('rrcReconfiguration', {}).get(
            'nonCriticalExtension', {})
        master_cell_group = non_critical_extension.get('masterCellGroup', {}).get('CONTAINING', {})

        sp_cell_config = master_cell_group.get('spCellConfig', {})
        reconfiguration_with_sync = sp_cell_config.get('reconfigurationWithSync', {})
        sp_cell_config_common = reconfiguration_with_sync.get('spCellConfigCommon', {})

        if sp_cell_config_common.get('physCellId') == int(target_cell_pci):
            ho_reconfiguration = True

    for rrc_reconfiguration_complete in rrc_reconfiguration_complete_messages:
        rrc_reconfiguration_complete_pci = getattr(rrc_reconfiguration_complete, 'Radio Bearer ID', None)
        logger.info(
            "PCI from metadata of RRC Reconfiguration Complete message: " + str(rrc_reconfiguration_complete_pci))

        if rrc_reconfiguration_complete_pci and str(target_cell_pci) in rrc_reconfiguration_complete_pci:
            ho_reconfiguration_complete = True

    logger.info("ho_reconfiguration:" + str(ho_reconfiguration))
    logger.info("ho_reconfiguration_complete:" + str(ho_reconfiguration_complete))

    assert ho_reconfiguration and ho_reconfiguration_complete, \
        "CGI Info not occurred or HO unsuccessful, check RRC messages."


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

    command = 'python {} -i {} -p {} -u {} -s {}'.format(script_path, ip, port, username, password)
    logger.info('Executed command: '.format(command))

    with subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE) as process:
        stdout, stderr = process.communicate()
        output = stdout.decode('utf-8') if process.returncode == 0 else stderr.decode('utf-8')
        logger.debug('Hanging script execution output:\n{}'.format(output))
        if 'There were hanging resources' in output:
            raise ValueError('Hanging resources were found on gNB')
        if 'No hanging resources' not in output:
            raise ValueError('Missing expected results in Hanging script execution output.')
        logger.info('No hanging resources as expected.')
