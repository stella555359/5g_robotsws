# copyright: Nokia 5G RAN
# Contact: I_MN_5G_RAN_IV4_LINE_HZG_8_IV@internal.nsn.com
from testsuite.Hangzhou.OAM.RAN_PZ_HAZ_34.libraries.global_vars import *

DICT__PARAMS_TO_add_cell = {
    '32': [
        dict(value=False, dist_name='MRBTS-%s/NRBTS-%s/NRCELL-32' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='actPRBBlanking'),
        dict(value=32, dist_name='MRBTS-%s/NRBTS-%s/NRCELL-32' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='lcrId'),
        dict(value=4, dist_name='MRBTS-%s/NRBTS-%s/NRCELL-32' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='maxNumPagingRecords'),
        dict(value=16, dist_name='MRBTS-%s/NRBTS-%s/NRCELL-32' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='maxNumPuschAllocationPerSlot'),
        dict(value=7, dist_name='MRBTS-%s/NRBTS-%s/NRCELL-32' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='msg1FrequencyStart'),
        dict(value=625000, dist_name='MRBTS-%s/NRBTS-%s/NRCELL-32' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='nrarfcn'),
        dict(value=849, dist_name='MRBTS-%s/NRBTS-%s/NRCELL-32' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='physCellId'),
        dict(value='zeroDot25', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-32' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='pucchF3MaxCodeRate'),
        dict(value=['32'], dist_name='MRBTS-%s/NRBTS-%s/NRCELLGRP-32' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='nrCellList'),
    ],
    '33': [
        dict(value=False, dist_name='MRBTS-%s/NRBTS-%s/NRCELL-33' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='actPRBBlanking'),
        dict(value=33, dist_name='MRBTS-%s/NRBTS-%s/NRCELL-33' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='lcrId'),
        dict(value=4, dist_name='MRBTS-%s/NRBTS-%s/NRCELL-33' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='maxNumPagingRecords'),
        dict(value=16, dist_name='MRBTS-%s/NRBTS-%s/NRCELL-33' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='maxNumPuschAllocationPerSlot'),
        dict(value=7, dist_name='MRBTS-%s/NRBTS-%s/NRCELL-33' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='msg1FrequencyStart'),
        dict(value=628332, dist_name='MRBTS-%s/NRBTS-%s/NRCELL-33' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='nrarfcn'),
        dict(value=850, dist_name='MRBTS-%s/NRBTS-%s/NRCELL-33' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='physCellId'),
        dict(value='zeroDot25', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-33' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='pucchF3MaxCodeRate'),
        dict(value=['33'], dist_name='MRBTS-%s/NRBTS-%s/NRCELLGRP-33' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='nrCellList'),
    ],
    '34': [
        dict(value=False, dist_name='MRBTS-%s/NRBTS-%s/NRCELL-34' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='actPRBBlanking'),
        dict(value=34, dist_name='MRBTS-%s/NRBTS-%s/NRCELL-34' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='lcrId'),
        dict(value=4, dist_name='MRBTS-%s/NRBTS-%s/NRCELL-34' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='maxNumPagingRecords'),
        dict(value=16, dist_name='MRBTS-%s/NRBTS-%s/NRCELL-34' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='maxNumPuschAllocationPerSlot'),
        dict(value=7, dist_name='MRBTS-%s/NRBTS-%s/NRCELL-34' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='msg1FrequencyStart'),
        dict(value=631664, dist_name='MRBTS-%s/NRBTS-%s/NRCELL-34' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='nrarfcn'),
        dict(value=851, dist_name='MRBTS-%s/NRBTS-%s/NRCELL-34' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='physCellId'),
        dict(value='zeroDot25', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-34' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='pucchF3MaxCodeRate'),
        dict(value=['34'], dist_name='MRBTS-%s/NRBTS-%s/NRCELLGRP-34' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='nrCellList'),
    ]
}


DICT__nrcelltype_TO_recommison = {
    'update': [
        dict(value='8DL4UL', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-31' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='nrCellType'),
        dict(value='16DL2UL', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-32' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='nrCellType'),
        dict(value='4DL2UL', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-33' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='nrCellType'),
    ],
}

DICT__nrcelltype_TO_recommison_ori = {
    'update': [
        dict(value='16DL4UL', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-31' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='nrCellType'),
        dict(value='16DL4UL', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-32' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='nrCellType'),
        dict(value='16DL4UL', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-33' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='nrCellType'),
    ],
}

DICT__subband_TO_recommison_ori = {
    'update': [
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-31' % (GLOBAL_BTS_ID, MRBTS_ID),
             list_name='srsForSubbandBm',
             value=dict(bfSubbandSize='2 PRBs', numOfSrsSubbandInput='1')),
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-32' % (GLOBAL_BTS_ID, MRBTS_ID),
             list_name='srsForSubbandBm',
             value=dict(bfSubbandSize='2 PRBs', numOfSrsSubbandInput='1')),
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-33' % (GLOBAL_BTS_ID, MRBTS_ID),
             list_name='srsForSubbandBm',
             value=dict(bfSubbandSize='2 PRBs', numOfSrsSubbandInput='1')),
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-34' % (GLOBAL_BTS_ID, MRBTS_ID),
             list_name='srsForSubbandBm',
             value=dict(bfSubbandSize='2 PRBs', numOfSrsSubbandInput='1')),
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-31' % (GLOBAL_BTS_ID, MRBTS_ID),
             list_name='srsForBeamMgmt',
             value=dict(comb='comb2', srsUePeriodicity='slots80')),
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-32' % (GLOBAL_BTS_ID, MRBTS_ID),
             list_name='srsForBeamMgmt',
             value=dict(comb='comb2', srsUePeriodicity='slots80')),
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-33' % (GLOBAL_BTS_ID, MRBTS_ID),
             list_name='srsForBeamMgmt',
             value=dict(comb='comb2', srsUePeriodicity='slots80')),
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-34' % (GLOBAL_BTS_ID, MRBTS_ID),
             list_name='srsForBeamMgmt',
             value=dict(comb='comb2', srsUePeriodicity='slots80')),
    ],
}

DICT__subband_TO_recommison = {
    'update': [
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-31' % (GLOBAL_BTS_ID, MRBTS_ID),
             list_name='srsForSubbandBm',
             value=dict(bfSubbandSize='4 PRBs', numOfSrsSubbandInput='4')),
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-32' % (GLOBAL_BTS_ID, MRBTS_ID),
             list_name='srsForSubbandBm',
             value=dict(bfSubbandSize='4 PRBs', numOfSrsSubbandInput='4')),
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-33' % (GLOBAL_BTS_ID, MRBTS_ID),
             list_name='srsForSubbandBm',
             value=dict(bfSubbandSize='4 PRBs', numOfSrsSubbandInput='4')),
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-34' % (GLOBAL_BTS_ID, MRBTS_ID),
             list_name='srsForSubbandBm',
             value=dict(bfSubbandSize='4 PRBs', numOfSrsSubbandInput='4')),
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-31' % (GLOBAL_BTS_ID, MRBTS_ID),
             list_name='srsForBeamMgmt',
             value=dict(comb='comb4', srsUePeriodicity='slots10')),
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-32' % (GLOBAL_BTS_ID, MRBTS_ID),
             list_name='srsForBeamMgmt',
             value=dict(comb='comb4', srsUePeriodicity='slots10')),
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-33' % (GLOBAL_BTS_ID, MRBTS_ID),
             list_name='srsForBeamMgmt',
             value=dict(comb='comb4', srsUePeriodicity='slots10')),
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-34' % (GLOBAL_BTS_ID, MRBTS_ID),
             list_name='srsForBeamMgmt',
             value=dict(comb='comb4', srsUePeriodicity='slots10')),
    ],
}

DICT__72a_TO_recommison_ori = {
    'update': [
        dict(value='true', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-31' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='actEcpri72e'),
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-31' % (GLOBAL_BTS_ID, MRBTS_ID),
             list_name='srsForSubbandBm',
             value=dict(bfSubbandSize='2 PRBs')),
        dict(value='16Rx', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-31' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='numberOfRxBeamforming'),
        dict(value='true', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-32' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='actEcpri72e'),
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-32' % (GLOBAL_BTS_ID, MRBTS_ID),
             list_name='srsForSubbandBm',
             value=dict(bfSubbandSize='2 PRBs')),
        dict(value='16Rx', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-32' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='numberOfRxBeamforming'),
        dict(value='true', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-33' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='actEcpri72e'),
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-33' % (GLOBAL_BTS_ID, MRBTS_ID),
             list_name='srsForSubbandBm',
             value=dict(bfSubbandSize='2 PRBs')),
        dict(value='16Rx', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-33' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='numberOfRxBeamforming'),
        dict(value='true', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-34' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='actEcpri72e'),
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-34' % (GLOBAL_BTS_ID, MRBTS_ID),
             list_name='srsForSubbandBm',
             value=dict(bfSubbandSize='2 PRBs')),
        dict(value='16Rx', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-34' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='numberOfRxBeamforming'),
    ]
}

DICT__72a_TO_recommison = {
    'update': [
        dict(value='false', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-31' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='actEcpri72e'),
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-31' % (GLOBAL_BTS_ID, MRBTS_ID),
             list_name='srsForSubbandBm',
             value=dict(bfSubbandSize='4 PRBs')),
        dict(value='4Rx', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-31' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='numberOfRxBeamforming'),
        dict(value='false', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-32' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='actEcpri72e'),
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-32' % (GLOBAL_BTS_ID, MRBTS_ID),
             list_name='srsForSubbandBm',
             value=dict(bfSubbandSize='4 PRBs')),
        dict(value='4Rx', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-32' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='numberOfRxBeamforming'),
        dict(value='false', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-33' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='actEcpri72e'),
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-33' % (GLOBAL_BTS_ID, MRBTS_ID),
             list_name='srsForSubbandBm',
             value=dict(bfSubbandSize='4 PRBs')),
        dict(value='4Rx', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-33' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='numberOfRxBeamforming'),
        dict(value='false', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-34' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='actEcpri72e'),
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-34' % (GLOBAL_BTS_ID, MRBTS_ID),
             list_name='srsForSubbandBm',
             value=dict(bfSubbandSize='4 PRBs')),
        dict(value='4Rx', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-34' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='numberOfRxBeamforming'),
    ]
}


DICT__PA_Value = {
    'AEHC': {
        '5GC001208_10MHZ': [20, 20, 20, 20],
        '5GC001070_10MHZ': [20, 20, 20, 20],
        '5GC001116_0ms_10MHZ': [15, 15, 15, 15],
        '5GC001116_3ms_10MHZ': [20, 20, 20, 20],
    },
    'AZHL': {
        '5GC001208_10MHZ': [13, 13, 13, 13],
        '5GC001070_10MHZ': [13, 13, 13, 13],
        '5GC001116_0ms_10MHZ': [13, 13, 13, 13],
        '5GC001116_3ms_10MHZ': [13, 13, 13, 13],
    }
}

LIST__SISO_FAULT_allowed = [
    '4293',
    '4655',
    '4654',
    '61652',
    '61524',
    '4592',
    '61649',
    '49',
    '6327',
    '7107',
    '4614',
    '4741',
    '6823',
    '6824',
    '6825',
    '6826',
    '6827',
    '6828',
    '6829',
    '6830',
    '6831',
    '6832',
    '6833',
    '6351',
    '7305',
    '7300',
    '7319',
    '4589',
    '4459',
    '4298',
    '8000',
    '4123',
    '4125',
    '7304',
    '6202'
]

LIST__SYSLOG_ERROR_allowed = [
    'grep -v "findActiveCellPosition() failed"',
    'grep -v "NOT send NetworkPlanUpdateInd!"',
    'grep -v "No active cell with nrCellId"',
    'grep -v "No valid X2 Ipaddress"',
    'grep -v "releasing index failed."',
    'grep -v "Pm Agent fails to register dataset for cplaneCaProfile1SecAgg"',
    'grep -v "Not found CellElement"',
    'grep -v "SCTP connection failed. Error: Connection refused"',
]

PARAMS_TO_actRATResetEnhancement_false = {
    'update': [
        dict(value='false', dist_name='MRBTS-%s/MNL-1/MNLENT-1/FEATCADM-1' % (GLOBAL_BTS_ID),
             parameter='actRatResetEnhancement'),
        dict(value='false', dist_name='MRBTS-%s/MNL-1/MNLENT-1/FEATCADM-1' % (GLOBAL_BTS_ID),
             parameter='actL1ReconfigImprovement'),
        dict(value='false', dist_name='MRBTS-%s/MNL-1/MNLENT-1/FEATCADM-1' % (GLOBAL_BTS_ID),
             parameter='actBbReconfigImprovement'),
        dict(value='false', dist_name='MRBTS-%s/MNL-1/MNLENT-1/FEATCADM-1' % (GLOBAL_BTS_ID),
             parameter='actL2L3ReconfigImprovement'),
    ]
}

PARAMS_TO_actRATResetEnhancement_true = {
    'update': [
        dict(value='true', dist_name='MRBTS-%s/MNL-1/MNLENT-1/FEATCADM-1' % (GLOBAL_BTS_ID),
             parameter='actRatResetEnhancement'),
        dict(value='true', dist_name='MRBTS-%s/MNL-1/MNLENT-1/FEATCADM-1' % (GLOBAL_BTS_ID),
             parameter='actL1ReconfigImprovement'),
        dict(value='true', dist_name='MRBTS-%s/MNL-1/MNLENT-1/FEATCADM-1' % (GLOBAL_BTS_ID),
             parameter='actBbReconfigImprovement'),
        dict(value='true', dist_name='MRBTS-%s/MNL-1/MNLENT-1/FEATCADM-1' % (GLOBAL_BTS_ID),
             parameter='actL2L3ReconfigImprovement'),
    ]
}

# RULOG_TL = ['89', '289', '295', '842', '863']
BB_ignore_TL = ['89' '290']

RU_CMD_LIST = ["ip addr"]

# RU_CMD_LIST = ["sudo tcpdump -i bond0.257 'ether proto 0x8902 or (vlan and ether proto 0x8902)' -w \
# /ram/cfm_bond0_257.pcap &> /dev/null &\n\
# sudo tcpdump -i bond0.258 'ether proto 0x8902 or (vlan and ether proto 0x8902)' -w /ram/cfm_bond0_258.pcap \
# &> /dev/null &\n\
# sudo tcpdump -i bond0.259 'ether proto 0x8902 or (vlan and ether proto 0x8902)' -w /ram/cfm_bond0_259.pcap \
# &> /dev/null &\n\
# sudo tcpdump -i bond0.260 'ether proto 0x8902 or (vlan and ether proto 0x8902)' -w /ram/cfm_bond0_260.pcap \
# &> /dev/null &\n\
# sudo tcpdump -i arb0p0 'ether proto 0x8902 or (vlan and ether proto 0x8902)' -w /ram/cfm_arbop0.pcap &> /dev/null &"]
#
# RU_THOR_CMD_LIST = ["sudo tcpdump -i rfoe0 'ether proto 0x8902 or (vlan and ether proto 0x8902)' -w \
# /ram/cfm_rfoe0.pcap &> /dev/null &\n\
# sudo tcpdump -i rfoe1 'ether proto 0x8902 or (vlan and ether proto 0x8902)' -w /ram/cfm_rfoe1.pcap &> /dev/null &\n\
# sudo tcpdump -i rfoe2 'ether proto 0x8902 or (vlan and ether proto 0x8902)' -w /ram/cfm_rfoe2.pcap &> /dev/null &\n\
# sudo tcpdump -i rfoe3 'ether proto 0x8902 or (vlan and ether proto 0x8902)' -w /ram/cfm_rfoe3.pcap &> /dev/null &\n\
# sudo tcpdump -i rfoe4 'ether proto 0x8902 or (vlan and ether proto 0x8902)' -w /ram/cfm_rfoe4.pcap &> /dev/null &\n\
# sudo tcpdump -i br_rfoe0 'ether proto 0x8902 or (vlan and ether proto 0x8902)' -w /ram/cfm_br_rfoe0.pcap \
# &> /dev/null &\n\
# sudo tcpdump -i br_rfoe1 'ether proto 0x8902 or (vlan and ether proto 0x8902)' -w /ram/cfm_br_rfoe1.pcap \
# &> /dev/null &\n\
# sudo tcpdump -i br_rfoe2  'ether proto 0x8902 or (vlan and ether proto 0x8902)' -w /ram/cfm_br_rfoe2.pcap \
# &> /dev/null &\n\
# sudo tcpdump -i br_rfoe3  'ether proto 0x8902 or (vlan and ether proto 0x8902)' -w /ram/cfm_br_rfoe3.pcap \
# &> /dev/null &\n\
# sudo tcpdump -i bond0.257 'ether proto 0x8902 or (vlan and ether proto 0x8902)' -w /ram/cfm_thor_bond0_257.pcap\
#  &> /dev/null &\n\
# sudo tcpdump -i bond0.258 'ether proto 0x8902 or (vlan and ether proto 0x8902)' -w /ram/cfm_thor_bond0_258.pcap\
#  &> /dev/null &\n\
# sudo tcpdump -i bond0.259 'ether proto 0x8902 or (vlan and ether proto 0x8902)' -w /ram/cfm_thor_bond0_259.pcap\
#  &> /dev/null &\n\
# sudo tcpdump -i bond0.260 'ether proto 0x8902 or (vlan and ether proto 0x8902)' -w /ram/cfm_thor_bond0_260.pcap\
#  &> /dev/null &"]

RULOG_TL = {
    '89': {'site_reset': True, 'ru_reset': True, 'site_reset_withouthwf': True,
           'cell_reset': True, 'cell_lock_unlock': True, 'cell_block_unblock': True,
           'ru_lock_unlock': True, 'bbmod_reset': True, 'bbmod_lock_unlock': True,
           'rat_reset': True, 'rat_block_unblock': True, 'du_lock_unlock': True,
           'commission': True, 'power_reset': True, 'ru_power_reset': True
           },
    '289': {'site_reset': True, 'ru_reset': True, 'site_reset_withouthwf': True,
            'cell_reset': True, 'cell_lock_unlock': True, 'cell_block_unblock': True,
            'ru_lock_unlock': True, 'bbmod_reset': True, 'bbmod_lock_unlock': True,
            'rat_reset': True, 'rat_block_unblock': True, 'du_lock_unlock': True,
            'commission': True, 'power_reset': True, 'ru_power_reset': True
            },
    '295': {'site_reset': True, 'ru_reset': True, 'site_reset_withouthwf': True,
            'cell_reset': True, 'cell_lock_unlock': True, 'cell_block_unblock': True,
            'ru_lock_unlock': True, 'bbmod_reset': True, 'bbmod_lock_unlock': True,
            'rat_reset': True, 'rat_block_unblock': True, 'du_lock_unlock': True,
            'commission': True, 'power_reset': True, 'ru_power_reset': True
            },
    '842': {'site_reset': False, 'ru_reset': False, 'site_reset_withouthwf': False,
            'cell_reset': False, 'cell_lock_unlock': False, 'cell_block_unblock': False,
            'ru_lock_unlock': False, 'bbmod_reset': False, 'bbmod_lock_unlock': False,
            'rat_reset': False, 'rat_block_unblock': False, 'du_lock_unlock': False,
            'commission': False, 'power_reset': False, 'ru_power_reset': False
            },
    '863': {'site_reset': True, 'ru_reset': True, 'site_reset_withouthwf': True,
            'cell_reset': True, 'cell_lock_unlock': True, 'cell_block_unblock': True,
            'ru_lock_unlock': True, 'bbmod_reset': True, 'bbmod_lock_unlock': True,
            'rat_reset': True, 'rat_block_unblock': True, 'du_lock_unlock': True,
            'commission': True, 'power_reset': True, 'ru_power_reset': True
            },
    '846': {'site_reset': True, 'ru_reset': True, 'site_reset_withouthwf': True,
            'cell_reset': True, 'cell_lock_unlock': True, 'cell_block_unblock': True,
            'ru_lock_unlock': True, 'bbmod_reset': True, 'bbmod_lock_unlock': True,
            'rat_reset': True, 'rat_block_unblock': True, 'du_lock_unlock': True,
            'commission': True, 'power_reset': True, 'ru_power_reset': True
            },
    '293': {'site_reset': True, 'ru_reset': True, 'site_reset_withouthwf': True,
            'cell_reset': True, 'cell_lock_unlock': True, 'cell_block_unblock': True,
            'ru_lock_unlock': True, 'bbmod_reset': True, 'bbmod_lock_unlock': True,
            'rat_reset': True, 'rat_block_unblock': True, 'du_lock_unlock': True,
            'commission': True, 'power_reset': True, 'ru_power_reset': True
            },
    '864': {'site_reset': True, 'ru_reset': True, 'site_reset_withouthwf': True,
            'cell_reset': True, 'cell_lock_unlock': True, 'cell_block_unblock': True,
            'ru_lock_unlock': True, 'bbmod_reset': True, 'bbmod_lock_unlock': True,
            'rat_reset': True, 'rat_block_unblock': True, 'du_lock_unlock': True,
            'commission': True, 'power_reset': True, 'ru_power_reset': True
            },
    '94': {'site_reset': True, 'ru_reset': True, 'site_reset_withouthwf': True,
           'cell_reset': True, 'cell_lock_unlock': True, 'cell_block_unblock': True,
           'ru_lock_unlock': True, 'bbmod_reset': True, 'bbmod_lock_unlock': True,
           'rat_reset': True, 'rat_block_unblock': True, 'du_lock_unlock': True,
           'commission': True, 'power_reset': True, 'ru_power_reset': True
           },
}

egen_TL = []
DICT__BBMOD_TL = {
    '846': ['2']
}


L3CALL_TL = {'846': {
    '31': {'ue_index': '0', 'dl_tp_ratio': '1', 'ul_tp_ratio': '1', 'peak_tp_dl': '100', 'peak_tp_ul': '30',
           'duration': '60'},
    '32': {'ue_index': '0', 'dl_tp_ratio': '1', 'ul_tp_ratio': '1', 'peak_tp_dl': '100', 'peak_tp_ul': '30',
           'duration': '60'},
    '33': {'ue_index': '0', 'dl_tp_ratio': '1', 'ul_tp_ratio': '1', 'peak_tp_dl': '100', 'peak_tp_ul': '30',
           'duration': '60'}
   }
}

CELLS_TO_DEL = {
    '846': ['32', '33', '34']
}
