from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl
from testsuite.Wroclaw.RRM.resources.preconditions_py import mrbts_id, nrbts_id


def get_pdu(pdu_id):
    return tl.pdus[int('{}'.format(pdu_id))]


AHBCB_PDU_ID = 1
UHFA_PDU_ID = 0
UHIE_PDU_ID = 3
NUM_OF_ITERATIONS = 1

RMODS = {
    'RMOD_1': {'pdu': get_pdu(AHBCB_PDU_ID), 'port': 7, 'att_ports': [1, 2, 3, 4]},
    'RMOD_2': {'pdu': get_pdu(UHFA_PDU_ID), 'port': 7, 'att_ports': [5, 6, 11, 12]},
    'RMOD_3': {'pdu': get_pdu(UHIE_PDU_ID), 'port': 4, 'att_ports': [7, 8, 9, 10]}
}


CELLS = {
    'CELL_1': {'rmod': 'RMOD_1', 'dist_name': "MRBTS-{}/NRBTS-{}/NRCELL-1".format(mrbts_id, nrbts_id)},
    'CELL_2': {'rmod': 'RMOD_2', 'dist_name': "MRBTS-{}/NRBTS-{}/NRCELL-2".format(mrbts_id, nrbts_id)},
    'CELL_3': {'rmod': 'RMOD_3', 'dist_name': "MRBTS-{}/NRBTS-{}/NRCELL-3".format(mrbts_id, nrbts_id)},
}


HR_SYSLOG_REGEX = ['CRNTI mismatch', 'context already exists', 'status Nok from Datamanager',
                   r'ERR\/*crnti*not match', 'hanging bearer', r'ERR\/*not found or*already in use',
                   'WRN*(UE*not*(found|in database)', 'No such*in UE DB',
                   'UE*already in database)', '(ERR/|WRN/)*nknown RNTI',
                   '(WRN|warning)*Cannot*(find ue', 'remove UE from any cell)',
                   'ERR*(unknownOrAlreadyAllocatedGnbCuUeF1apid)']

UES_LIST = ['UE_1', 'UE_2']
MAX_RESET_TIME = 288

CPLANE_CONTAINERS = {
    'CP_UE': ('master', '0x2730'),
    'CP_RT': ('slave', '0x2515'),
    'CP_NB': ('slave', '0x2513')
}
