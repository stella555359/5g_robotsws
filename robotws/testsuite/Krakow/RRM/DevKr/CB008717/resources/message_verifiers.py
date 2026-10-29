from ta_messaging.message_verifiers import message_verifier
from ta_messaging.message_flows import get_flow
from ta_emss import ta_emss
from robot.libraries.BuiltIn import BuiltIn, RobotNotRunningError
from ta_messaging.message_verifiers import message_verifier as _message_verifier
import logging
import os


FORMAT = '%(asctime)s-[%(levelname)s] (%(threadName)-10s) %(message)s'
E1F1Reset_logger_name = 'E1F1Reset_view'

logging.basicConfig(level=logging.INFO,
                    format=FORMAT)
try:
    out_dir = BuiltIn().get_variable_value('${OUTPUT_DIR}')
except RobotNotRunningError:
    out_dir = os.getcwd()
log_filepath = os.path.sep.join([out_dir,  E1F1Reset_logger_name])
if os.path.exists(log_filepath):
    os.remove(log_filepath)
file_handler = logging.FileHandler(log_filepath)
file_handler.setFormatter(logging.Formatter(FORMAT))
logging.getLogger(E1F1Reset_logger_name).addHandler(file_handler)

saved_cu_and_du_ue_id_mn = set()
saved_cu_and_du_ue_id_sn = set()
saved_meas_id = None
E1_RESET_COUNTER = 0
F1_RESET_COUNTER = 0


@message_verifier
def ue_ctx_rel_cmd_contains_rrccontainer_save_cu_ue_id(msg):
    """Check if UEContextReleaseCommand contains cause:radioNetwork:'normal-release' and GNB-CU-UE-F1AP-ID
    and GNB-CU-UE-F1AP-ID are the same as in UEContextSetup for MN"""
    # Filter F1AP UEContextReleaseCommand by checking presence of RRContainer
    if 'RRCContainer' in msg:
        global saved_cu_ue_id_mn
        global saved_du_ue_id_mn
        cu_ue_id = int(msg.get_value_by_unique_key('GNB-CU-UE-F1AP-ID'))
        du_ue_id = int(msg.get_value_by_unique_key('GNB-DU-UE-F1AP-ID'))
        if (cu_ue_id, du_ue_id) not in saved_cu_and_du_ue_id_mn:
            return False
        # Check if cause:radioNetwork is normal-release
        cause_radio_network = msg.get_value_by_unique_key('radioNetwork')
        if cause_radio_network == 'normal-release':
            return True
    return False


@message_verifier
def ue_ctx_rel_cpl_contains_cu_ue_id_match_ctx_rel_with_rrccontainer(msg):
    """Check if in UEContextReleaseCommand GNB-CU-UE-F1AP-ID and GNB-CU-UE-F1AP-ID are the same
    as in UEContextSetup for MN"""
    cu_ue_id = int(msg.get_value_by_unique_key('GNB-CU-UE-F1AP-ID'))
    du_ue_id = int(msg.get_value_by_unique_key('GNB-DU-UE-F1AP-ID'))
    if saved_cu_and_du_ue_id_mn is not None and (cu_ue_id, du_ue_id) in saved_cu_and_du_ue_id_mn:
        return True
    return False


@message_verifier
def ue_ctx_rel_cmd_does_not_contain_rrccontainer_save_cu_ue_id(msg):
    """Check if UEContextReleaseCommand contains cause:radioNetwork:'normal-release' and GNB-CU-UE-F1AP-ID
    and GNB-CU-UE-F1AP-ID are the same as in UEContextSetup for SN"""
    # Filter F1AP UEContextReleaseCommand by checking presence of RRContainer
    if 'RRCContainer' not in msg:
        global saved_cu_ue_id_sn
        global saved_du_ue_id_sn
        cu_ue_id = int(msg.get_value_by_unique_key('GNB-CU-UE-F1AP-ID'))
        du_ue_id = int(msg.get_value_by_unique_key('GNB-DU-UE-F1AP-ID'))
        if (cu_ue_id, du_ue_id) not in saved_cu_and_du_ue_id_sn:
            return False
        # Check if cause:misc is unspecified
        cause_radio_network = msg.get_value_by_unique_key('radioNetwork')
        if cause_radio_network == 'normal-release':
            return True
    return False


@message_verifier
def ue_ctx_rel_cpl_contains_cu_ue_id_match_ctx_rel_without_rrccontain(msg):
    """Check if in UEContextReleaseCommand GNB-CU-UE-F1AP-ID and GNB-CU-UE-F1AP-ID are the same
    as in UEContextSetup for SN"""
    cu_ue_id = int(msg.get_value_by_unique_key('GNB-CU-UE-F1AP-ID'))
    du_ue_id = int(msg.get_value_by_unique_key('GNB-DU-UE-F1AP-ID'))
    if saved_cu_and_du_ue_id_sn is not None and (cu_ue_id, du_ue_id) in saved_cu_and_du_ue_id_sn:
        return True
    return False


@message_verifier
def verify_ue_ctx_reset_match_cu_ue_ctx_for_MN(msg):
    """Check if in F1AP: Reset gNB_CU_UE_F1AP_ID and gNB_DU_UE_F1AP_ID are the same
    as in UEContextSetup for MN"""
    logger = logging.getLogger(E1F1Reset_logger_name)
    cu_ue_id = int(msg.get_value_by_unique_key('gNB-CU-UE-F1AP-ID'))
    du_ue_id = int(msg.get_value_by_unique_key('gNB-DU-UE-F1AP-ID'))
    logger.info('cu_ue_id: {} and du_ue_id: {} received in F1AP Reset for MN'.format(cu_ue_id, du_ue_id))
    if (cu_ue_id, du_ue_id) in saved_cu_and_du_ue_id_mn:
        return True
    return False


@message_verifier
def verify_ue_ctx_reset_match_cu_ue_ctx_for_SN(msg):
    """Check if in F1AP: Reset gNB_CU_UE_F1AP_ID and gNB_DU_UE_F1AP_ID are the same
    as in UEContextSetup for SN"""
    logger = logging.getLogger(E1F1Reset_logger_name)
    cu_ue_id = int(msg.get_value_by_unique_key('gNB-CU-UE-F1AP-ID'))
    du_ue_id = int(msg.get_value_by_unique_key('gNB-DU-UE-F1AP-ID'))
    logger.info('cu_ue_id: {} and du_ue_id: {} received in F1AP Reset for SN'.format(cu_ue_id, du_ue_id))
    if (cu_ue_id, du_ue_id) in saved_cu_and_du_ue_id_sn:
        return True
    return False


def save_cu_du_ue_id_from_ue_ctx_setup_mn(message_alias, flow_alias):
    """Get values of GNB-CU-UE-F1AP-ID and GNB-DU-UE-F1AP-ID from UEContextSetup for MN
    and save them to global variables"""
    logger = logging.getLogger(E1F1Reset_logger_name)
    msg_content = get_flow(flow_alias).get_message(message_alias)
    cu_ue_id = int(msg_content.get_value_by_unique_key('GNB-CU-UE-F1AP-ID'))
    du_ue_id = int(msg_content.get_value_by_unique_key('GNB-DU-UE-F1AP-ID'))
    saved_cu_and_du_ue_id_mn.add((cu_ue_id, du_ue_id))
    logger.info('cu_ue_id: {} and du_ue_id: {} saved in saved_cu_and_du_ue_id_mn for MN'.format(cu_ue_id, du_ue_id))
    return True


def save_cu_du_ue_id_from_ue_ctx_setup_sn(message_alias, flow_alias):
    """Get values of GNB-CU-UE-F1AP-ID and GNB-DU-UE-F1AP-ID from UEContextSetup for SN
    and save them to global variables"""
    logger = logging.getLogger(E1F1Reset_logger_name)
    msg_content = get_flow(flow_alias).get_message(message_alias)
    cu_ue_id = int(msg_content.get_value_by_unique_key('GNB-CU-UE-F1AP-ID'))
    du_ue_id = int(msg_content.get_value_by_unique_key('GNB-DU-UE-F1AP-ID'))
    saved_cu_and_du_ue_id_sn.add((cu_ue_id, du_ue_id))
    logger.info('cu_ue_id: {} and du_ue_id: {} saved in saved_cu_and_du_ue_id_sn for SN'.format(cu_ue_id, du_ue_id))
    return True


@message_verifier
def increment_counter_for_e1_or_f1_reset_msgs(owner_alias, message):
    """Count number of F1AP Reset or E1AP Reset messages and save them to global variables"""
    global E1_RESET_COUNTER
    global F1_RESET_COUNTER
    logger = logging.getLogger(E1F1Reset_logger_name)
    message_payload = message.parse()

    if 'F1AP-PDU' in message_payload:
        F1_RESET_COUNTER += 1
    if 'E1AP-PDU' in message_payload:
        E1_RESET_COUNTER += 1
    logger.info('F1_RESET_COUNTER: {}'.format(F1_RESET_COUNTER))
    logger.info('E1_RESET_COUNTER: {}'.format(E1_RESET_COUNTER))
    logger.info('message_payload: {}'.format(message_payload))


@message_verifier
def decrement_counter_for_e1_or_f1_reset_msgs(owner_alias, message):
    """Count number of F1AP ResetAck or E1AP ResetAck messages and save them to global variables"""
    global E1_RESET_COUNTER
    global F1_RESET_COUNTER
    logger = logging.getLogger(E1F1Reset_logger_name)
    message_payload = message.parse()

    if 'F1AP-PDU' in message_payload:
        F1_RESET_COUNTER -= 1
    if 'E1AP-PDU' in message_payload:
        E1_RESET_COUNTER -= 1
    logger.info('F1_RESET_COUNTER: {}'.format(F1_RESET_COUNTER))
    logger.info('E1_RESET_COUNTER: {}'.format(E1_RESET_COUNTER))
    logger.info('message_payload: {}'.format(message_payload))


def verify_e1_and_f1_messages_for_MN_and_SN():
    """Verify that all pairs E1:Reset / E1:ResetAck and F1:Reset / F1:ResetAck were sent for MN and SN"""
    assert E1_RESET_COUNTER == 0 and F1_RESET_COUNTER == 0


def verify_cause_in_reset_msgs(message_alias, flow_alias, cause_group, cause):
    """Verify that message contains cause_group with given cause"""
    logger = logging.getLogger(E1F1Reset_logger_name)
    msg_content = get_flow(flow_alias).get_message(message_alias)
    cause_received = msg_content.get_value_by_unique_key(cause_group)
    logger.info('cause: {}'.format(cause))
    logger.info('cause_group: {}'.format(cause_group))
    assert cause == cause_received


def get_arfcnSsbPbch_value_from_cell(nrcell_id):
    """function to map specific NRCELL id to it's frequency"""
    cell_to_freq_mapper = get_nrcell_id_with_frequency(nrcell_id)
    ssb_freq = cell_to_freq_mapper['NRCELL-{}'.format(str(nrcell_id))]
    return ssb_freq['arfcnssbpbch']


def get_nrcell_id_with_frequency(nrcell_id):
    """Get values of arfcnSsbPbch param for each NRCELL MOC
    return example: {{'NRCELL-1': {'arfcnssbpbch': '2254267'}"""
    ta_emss_inst = ta_emss(host='10.0.1.1', port=4001)
    object_type = 'NRCELL'
    key_cell = 'NRCELL-' + str(nrcell_id)
    param_name = 'arfcnSsbPbch'
    cell_with_freq = dict()
    cell_with_freq[key_cell] = ta_emss_inst.get_object_attributes(object_type + '-' + str(nrcell_id), param_name)
    assert bool(cell_with_freq[key_cell]), "{} parametr for NRCELL-{} is not present".format(param_name, nrcell_id)
    return cell_with_freq
