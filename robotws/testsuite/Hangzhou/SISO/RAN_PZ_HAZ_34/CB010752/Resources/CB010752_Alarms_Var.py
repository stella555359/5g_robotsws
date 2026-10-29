from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger

ALLOWED_ACTIVE_FAULTS = [
    61524,  # SSHenabled
    61652,  # R&DServicePortenabled
    61649,  # LMPaccessviaport$port
    4655,  # Serviceaccountrootaccessisenabled
    4654,  # Ethernetportsecurityisdisabled
    4592,  # BTSResetCause
]
ALLOWED_HISTORY_FAULTS = [
    61524,  # SSHenabled
    61652,  # R&DServicePortenabled
    61649,  # LMPaccessviaport$port
    61074,  # CRLUpdatefailure
    61618,  # Operator Certificate About to Expire or Expired
    4655,  # Serviceaccountrootaccessisenabled
    4592,  # BTSResetCause
    4340,  # Previouslydownloadedplan[planId]wasoverwrittenbyanewplan[planId]
    4420,  # GPSreceiveralarm:firmwareupgradeongoing
    7300,  # NoX2linkavailable
    7319,  # NoX2linkavailableforaspecificLTEENB
    9000,  # Temp Fault1
    1932,  # No module fan detected
]

CELL_BLOCK_ALLOWED_HISTORY_FAULTS = [
    49,  # Cell blocked
]

RU_POWER_RESET_ALLOWED_HISTORY_FAULTS = [
    4589,  # Unit power reset
    10,  # No connection to unit
]

RU_POWER_RESET_ALLOWED_HISTORY_FAULTS = RU_POWER_RESET_ALLOWED_HISTORY_FAULTS + ALLOWED_HISTORY_FAULTS
CELL_BLOCK_ALLOWED_HISTORY_FAULTS = CELL_BLOCK_ALLOWED_HISTORY_FAULTS + ALLOWED_HISTORY_FAULTS

tl = BuiltIn().get_variable_value("${tl}")
TESTLINE_IDENTITY = tl.gnbs[0].instance_id
cell_id_4 = '4'
cell_id_5 = '5'
cell_id_6 = '6'
cell_id_7 = '7'

# Call PCI And NrCellId info
CALL_PCI_AND_NRCELLID_INFO = {
    "KLT230800043": {
        "pci": "59",
        "nrcellid": "618070016",
    },
    "KLT23140002F": {
        "pci": "67",
        "nrcellid": "618070023",
    },
}

CALL_PCI_AND_NRCELLID_INFO_LET = {
    "KLT230800043": {
        "pci": "59",
        "nrcellid": "154517504",
    }
}


ALL_RU_INFO_LIST = []
for ru_index in range(len(tl.gnbs[0].dus[0].rus)):
    ru_details = {
        "ru_username": tl.gnbs[0].dus[0].rus[ru_index].default_ssh_connection_details.username,
        "ru_password": tl.gnbs[0].dus[0].rus[ru_index].default_ssh_connection_details.password,
        "ru_pdu_model": tl.gnbs[0].dus[0].rus[ru_index].pdu_port.pdu.vendor,
        "ru_pdu_ip": tl.gnbs[0].dus[0].rus[ru_index].pdu_port.pdu.addr,
        "ru_pdu_port": tl.gnbs[0].dus[0].rus[ru_index].pdu_port.port_no,
    }
    ALL_RU_INFO_LIST.append(ru_details)

ALL_UE_INFO_LIST = []
for ue_index in range(len(tl.ues)):
    ues_derails = {
        "ue_cpe_index": tl.ues[ue_index].phone_number,
        "ue_pc_address": tl.ues[ue_index].ue_pc_address,
        "ue_serial_number": tl.ues[ue_index].serial_number,
    }
    ALL_UE_INFO_LIST.append(ues_derails)

BWP_dict_20M = [{'actPdcchCceFragmentControl': 'false',
                 'actUpperThrAckNackFiltering': 'false',
                 'actUpperThrAckNackHrFiltering': 'false',
                 'bwpDN': 'MRBTS-'+TESTLINE_IDENTITY+'/NRBTS-'+TESTLINE_IDENTITY+'/BWP_PROFILE-5',
                 'cellBwpId': '0',
                 'pdcchResourcePreference': 'peakRate'},
                {'actPdcchCceFragmentControl': 'false',
                 'actUpperThrAckNackFiltering': 'false',
                 'actUpperThrAckNackHrFiltering': 'false',
                 'bwpDN': 'MRBTS-'+TESTLINE_IDENTITY+'/NRBTS-'+TESTLINE_IDENTITY+'/BWP_PROFILE-152',
                 'cellBwpId': '1',
                 'pdcchResourcePreference': 'peakRate'}, ]

BWP_dict_40M = [{'actPdcchCceFragmentControl': 'false',
                 'actUpperThrAckNackFiltering': 'false',
                 'actUpperThrAckNackHrFiltering': 'false',
                 'bwpDN': 'MRBTS-'+TESTLINE_IDENTITY+'/NRBTS-'+TESTLINE_IDENTITY+'/BWP_PROFILE-5',
                 'cellBwpId': '0',
                 'pdcchResourcePreference': 'peakRate'},
                {'actPdcchCceFragmentControl': 'false',
                 'actUpperThrAckNackFiltering': 'false',
                 'actUpperThrAckNackHrFiltering': 'false',
                 'bwpDN': 'MRBTS-'+TESTLINE_IDENTITY+'/NRBTS-'+TESTLINE_IDENTITY+'/BWP_PROFILE-154',
                 'cellBwpId': '1',
                 'pdcchResourcePreference': 'peakRate'}, ]

json_update = [
    dict(dist_name='MRBTS-'+TESTLINE_IDENTITY+'/NRBTS-'+TESTLINE_IDENTITY+'/NRCELL-'+cell_id_4,
         parameter='cellBwpList', value=BWP_dict_20M, operation='update'),
    dict(dist_name='MRBTS-'+TESTLINE_IDENTITY+'/NRBTS-'+TESTLINE_IDENTITY+'/NRCELL-'+cell_id_5,
         parameter='cellBwpList', value=BWP_dict_20M, operation='update'),
    dict(dist_name='MRBTS-'+TESTLINE_IDENTITY+'/NRBTS-'+TESTLINE_IDENTITY+'/NRCELL-'+cell_id_6,
         parameter='cellBwpList', value=BWP_dict_20M, operation='update'),
    dict(dist_name='MRBTS-'+TESTLINE_IDENTITY+'/NRBTS-'+TESTLINE_IDENTITY+'/NRCELL-'+cell_id_7,
         parameter='cellBwpList', value=BWP_dict_20M, operation='update'),
    dict(dist_name='MRBTS-'+TESTLINE_IDENTITY+'/NRBTS-'+TESTLINE_IDENTITY+'/NRCELL-'+cell_id_4+'/NRCELL_FDD-1',
         parameter='chBwUl', value='20MHz', operation='update'),
    dict(dist_name='MRBTS-'+TESTLINE_IDENTITY+'/NRBTS-'+TESTLINE_IDENTITY+'/NRCELL-'+cell_id_5+'/NRCELL_FDD-1',
         parameter='chBwUl', value='20MHz', operation='update'),
    dict(dist_name='MRBTS-'+TESTLINE_IDENTITY+'/NRBTS-'+TESTLINE_IDENTITY+'/NRCELL-'+cell_id_6+'/NRCELL_FDD-1',
         parameter='chBwUl', value='20MHz', operation='update'),
    dict(dist_name='MRBTS-'+TESTLINE_IDENTITY+'/NRBTS-'+TESTLINE_IDENTITY+'/NRCELL-'+cell_id_7+'/NRCELL_FDD-1',
         parameter='chBwUl', value='20MHz', operation='update'),
    dict(dist_name='MRBTS-'+TESTLINE_IDENTITY+'/NRBTS-'+TESTLINE_IDENTITY+'/NRCELL-'+cell_id_4+'/NRCELL_FDD-1',
         parameter='chBwDl', value='20MHz', operation='update'),
    dict(dist_name='MRBTS-'+TESTLINE_IDENTITY+'/NRBTS-'+TESTLINE_IDENTITY+'/NRCELL-'+cell_id_5+'/NRCELL_FDD-1',
         parameter='chBwDl', value='20MHz', operation='update'),
    dict(dist_name='MRBTS-'+TESTLINE_IDENTITY+'/NRBTS-'+TESTLINE_IDENTITY+'/NRCELL-'+cell_id_6+'/NRCELL_FDD-1',
         parameter='chBwDl', value='20MHz', operation='update'),
    dict(dist_name='MRBTS-'+TESTLINE_IDENTITY+'/NRBTS-'+TESTLINE_IDENTITY+'/NRCELL-'+cell_id_7+'/NRCELL_FDD-1',
         parameter='chBwDl', value='20MHz', operation='update'),
               ]

json_update_40M = [
    dict(dist_name='MRBTS-'+TESTLINE_IDENTITY+'/NRBTS-'+TESTLINE_IDENTITY+'/NRCELL-'+cell_id_4,
         parameter='cellBwpList', value=BWP_dict_40M, operation='update'),
    dict(dist_name='MRBTS-'+TESTLINE_IDENTITY+'/NRBTS-'+TESTLINE_IDENTITY+'/NRCELL-'+cell_id_5,
         parameter='cellBwpList', value=BWP_dict_40M, operation='update'),
    dict(dist_name='MRBTS-'+TESTLINE_IDENTITY+'/NRBTS-'+TESTLINE_IDENTITY+'/NRCELL-'+cell_id_6,
         parameter='cellBwpList', value=BWP_dict_40M, operation='update'),
    dict(dist_name='MRBTS-'+TESTLINE_IDENTITY+'/NRBTS-'+TESTLINE_IDENTITY+'/NRCELL-'+cell_id_7,
         parameter='cellBwpList', value=BWP_dict_40M, operation='update'),
    dict(dist_name='MRBTS-'+TESTLINE_IDENTITY+'/NRBTS-'+TESTLINE_IDENTITY+'/NRCELL-'+cell_id_4+'/NRCELL_FDD-1',
         parameter='chBwUl', value='40MHz', operation='update'),
    dict(dist_name='MRBTS-'+TESTLINE_IDENTITY+'/NRBTS-'+TESTLINE_IDENTITY+'/NRCELL-'+cell_id_5+'/NRCELL_FDD-1',
         parameter='chBwUl', value='40MHz', operation='update'),
    dict(dist_name='MRBTS-'+TESTLINE_IDENTITY+'/NRBTS-'+TESTLINE_IDENTITY+'/NRCELL-'+cell_id_6+'/NRCELL_FDD-1',
         parameter='chBwUl', value='40MHz', operation='update'),
    dict(dist_name='MRBTS-'+TESTLINE_IDENTITY+'/NRBTS-'+TESTLINE_IDENTITY+'/NRCELL-'+cell_id_7+'/NRCELL_FDD-1',
         parameter='chBwUl', value='40MHz', operation='update'),
    dict(dist_name='MRBTS-'+TESTLINE_IDENTITY+'/NRBTS-'+TESTLINE_IDENTITY+'/NRCELL-'+cell_id_4+'/NRCELL_FDD-1',
         parameter='chBwDl', value='40MHz', operation='update'),
    dict(dist_name='MRBTS-'+TESTLINE_IDENTITY+'/NRBTS-'+TESTLINE_IDENTITY+'/NRCELL-'+cell_id_5+'/NRCELL_FDD-1',
         parameter='chBwDl', value='40MHz', operation='update'),
    dict(dist_name='MRBTS-'+TESTLINE_IDENTITY+'/NRBTS-'+TESTLINE_IDENTITY+'/NRCELL-'+cell_id_6+'/NRCELL_FDD-1',
         parameter='chBwDl', value='40MHz', operation='update'),
    dict(dist_name='MRBTS-'+TESTLINE_IDENTITY+'/NRBTS-'+TESTLINE_IDENTITY+'/NRCELL-'+cell_id_7+'/NRCELL_FDD-1',
         parameter='chBwDl', value='40MHz', operation='update'),
               ]
