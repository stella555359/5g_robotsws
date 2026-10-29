from robot.libraries.BuiltIn import BuiltIn
import logging

tl = BuiltIn().get_variable_value('${tl}')
program = BuiltIn().get_variable_value('${PROGRAM}')

NR_NAME = 'NRBTS-' + str(tl.gnbs[0].global_bts_id)
NR_CELL_NAME = NR_NAME + '/NRCELL-1'
LTE_NAME = 'LNBTS-' + str(tl.enbs[0].global_bts_id)
LTE_CELL_NAME = LTE_NAME + '/LNCELL-1'

# These NIDD parameters are modified via api, and no restart is required.
TURN_ON_actNonGbrServiceDiff = [
    dict(
        value='true',
        dist_name=NR_NAME,
        parameter='actNonGbrServiceDiff')
]

TURN_OFF_actNonGbrServiceDiff = [
    dict(
        value='false',
        dist_name=NR_NAME,
        parameter='actNonGbrServiceDiff')
]

ONLINE_MODIFY_DRB4_schedulWeight = [
    dict(
        value='10',
        dist_name=NR_NAME + '/NRDRB-4',
        parameter='schedulWeight')
]

ONLINE_MODIFY_schedulWeight_DEFAULT = [
    dict(
        value='10',
        dist_name=NR_NAME + '/NRDRB-1',
        parameter='schedulWeight'
    ),
    dict(
        value='20',
        dist_name=NR_NAME + '/NRDRB-2',
        parameter='schedulWeight'
    ),
    dict(
        value='5',
        dist_name=NR_NAME + '/NRDRB-4',
        parameter='schedulWeight'
    ),
    dict(
        value='1',
        dist_name=NR_NAME + '/NRDRB-5',
        parameter='schedulWeight'
    ),
    dict(
        value='40',
        dist_name=NR_NAME + '/NRDRB-6',
        parameter='schedulWeight'
    ),
    dict(
        value='30',
        dist_name=NR_NAME + '/NRDRB-7',
        parameter='schedulWeight'
    )
]

ONLINE_MODIFY_schedulWeight_CONF = [
    dict(
        value='20',
        dist_name=NR_NAME + '/NRDRB-1',
        parameter='schedulWeight'
    ),
    dict(
        value='10',
        dist_name=NR_NAME + '/NRDRB-2',
        parameter='schedulWeight'
    ),
    dict(
        value='30',
        dist_name=NR_NAME + '/NRDRB-4',
        parameter='schedulWeight'
    ),
    dict(
        value='10',
        dist_name=NR_NAME + '/NRDRB-5',
        parameter='schedulWeight'
    ),
    dict(
        value='20',
        dist_name=NR_NAME + '/NRDRB-6',
        parameter='schedulWeight'
    ),
    dict(
        value='40',
        dist_name=NR_NAME + '/NRDRB-7',
        parameter='schedulWeight'
    )
]

ONLINE_MODIFY_schedulWeight_B01 = [
    dict(
        value='30',
        dist_name=NR_NAME + '/NRDRB-1',
        parameter='schedulWeight'
    ),
    dict(
        value='50',
        dist_name=NR_NAME + '/NRDRB-2',
        parameter='schedulWeight'
    ),
    dict(
        value='10',
        dist_name=NR_NAME + '/NRDRB-4',
        parameter='schedulWeight'
    ),
    dict(
        value='100',
        dist_name=NR_NAME + '/NRDRB-5',
        parameter='schedulWeight'
    ),
    dict(
        value='20',
        dist_name=NR_NAME + '/NRDRB-6',
        parameter='schedulWeight'
    ),
    dict(
        value='15',
        dist_name=NR_NAME + '/NRDRB-7',
        parameter='schedulWeight'
    )
]

ONLINE_MODIFY_schedulWeight_B03 = [
    dict(
        value='10',
        dist_name=NR_NAME + '/NRDRB-1',
        parameter='schedulWeight'
    ),
    dict(
        value='20',
        dist_name=NR_NAME + '/NRDRB-2',
        parameter='schedulWeight'
    ),
    dict(
        value='5',
        dist_name=NR_NAME + '/NRDRB-4',
        parameter='schedulWeight'
    ),
    dict(
        value='1',
        dist_name=NR_NAME + '/NRDRB-5',
        parameter='schedulWeight'
    ),
    dict(
        value='40',
        dist_name=NR_NAME + '/NRDRB-6',
        parameter='schedulWeight'
    ),
    dict(
        value='30',
        dist_name=NR_NAME + '/NRDRB-7',
        parameter='schedulWeight'
    )
]

# These NIDD parameters are modified into scf, and using scf to commission CU and DU.
MODIFY_SCF_CU = [
    dict(
        value='true',
        dist_name=NR_NAME,
        p_name='actNonGbrServiceDiff'
    ),
    dict(
        value='false',
        dist_name=NR_NAME + '/NRDRB-2',
        p_name='actPrioritizeX2AfterInactivity'
    ),
    dict(
        value='dlOverF1U',
        dist_name=NR_NAME + '/NRDRB-2',
        p_name='dlDataSplitMode'
    ),
    dict(
        value='initDLoverF1U',
        dist_name=NR_NAME + '/NRDRB-2',
        p_name='initialDLTrafficRouting'
    ),
    dict(
        value='ulOverNr',
        dist_name=NR_NAME + '/NRDRB-2',
        p_name='ulDataPath'
    ),
    dict(
        value='false',
        dist_name=NR_NAME,
        p_name='actInactDetNSAUe'
    )
]

MODIFY_SCF_DU = [
    dict(
        value='true',
        dist_name=NR_NAME,
        p_name='actNonGbrServiceDiff'),
    dict(
        value='10',
        dist_name=NR_CELL_NAME,
        p_name='dllaIniMcs'
    ),
    dict(
        value='15',
        dist_name=NR_CELL_NAME,
        p_name='ullaIniMcs'
    )
]

# These are R&D parameters modified to swconfig
# # Feature 5GC000517 - Link adaptation: Activation / deactivation
# # The Link Adaptation is activated by default (There is no NIDD parameters to activate/deactivate the feature)
# # In order to deactivate the link adaptation the 4 R&D parameters
# (rdActIllaDl, rdActOllaDl, rdActIllaUl, rdActOllaul) need to be set to 0
# # rdActIllaDl: Set to 0 deactivates the ILLA in DL (default value 1)
# 0x580011=0
# # rdActOllaDl: Set to 0 deactivates the OLLA in DL (default value 1)
# 0x580013=0
# # rdActIllaUl: Set to 0 deactivates the ILLA in UL (default value 1)
# 0x580012=0
# # rdActOllaUl: Set to 0 deactivates the OLLA in UL (default value 1)
# 0x580014=0
# # rdULRank
# 0x580019 = 1
# # rdDLRank
# 0x580017 = 1

MODIFY_SWCONFIG_COMMON = [
    '0x580011=0',
    '0x580013=0',
    '0x580012=0',
    '0x580014=0',
    '0x580019=1',
    '0x580017=1'
]
