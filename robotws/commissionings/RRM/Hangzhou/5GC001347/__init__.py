import os

from taf.config.testline.legacy import (CONFIG_5G, SCF)

CFG_DIR = os.path.dirname(os.path.abspath(__file__))
_NRBTSname = 'MRBTS-1900/NRBTS-1'
_NRCELLname = 'MRBTS-1900/NRBTS-1/NRCELL-1'
_p_name = 'dlFlowControlAlgo'


PARAMS_TO_DELETE = [
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-2'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-2/NRCELL_FDD-1'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELLGRP-0', list_name='nrCellList', index=1),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-3'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-3/NRCELL_FDD-1'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELLGRP-0', list_name='nrCellList', index=1),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-4'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-4/NRCELL_FDD-1'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELLGRP-0', list_name='nrCellList', index=1),

]

PARAMS_TO_MODIFY = [
    dict(value='7_5_HZ_TLIV034', dist_name='MRBTS-1900', p_name='btsName'),
    dict(value='262', dist_name=_NRBTSname, p_name='mcc'),
    dict(value='3', dist_name=_NRBTSname, p_name='mnc'),
    dict(value='2', dist_name=_NRBTSname, p_name='mncLength'),
    dict(value='2059003', dist_name=_NRCELLname, p_name='nrarfcn'),
    dict(value='150', dist_name=_NRCELLname, p_name='ullaDeltaSinrMax'),
    dict(value='150', dist_name=_NRCELLname, p_name='dllaDeltaCqiMax'),
    dict(value='5G19/5g_pid11_abil_l2rt_eoc', dist_name='MRBTS-1900/EQM-1/APEQM-1', p_name='rapProfile'),
    dict(value='Nokia HGZ', dist_name='MRBTS-1900/EQM-1/APEQM-1', p_name='location'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1', p_name='ethernetPortSecurityEnabled'),
    dict(value='true', dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1', p_name='actServiceAccountSsh'),
    dict(value='(GMT+8) Asia/Shanghai', dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/TIME-1', p_name='timeZone'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1/MNLENT-1/FEATCADM-1', p_name='systemAcctPermEnable'),
    dict(value='15min', dist_name='MRBTS-1900/MNL-1/PMCADM-1', p_name='reportingIntervalPm'),
    dict(value='3gppFlowControl', dist_name=_NRBTSname, list_name='qciTab5Nsa3x', p_name=_p_name),
    dict(value='3gppFlowControl', dist_name=_NRBTSname, list_name='qciTab69Nsa3x', p_name=_p_name),
    dict(value='3gppFlowControl', dist_name=_NRBTSname, list_name='qciTab6Nsa3x', p_name=_p_name),
    dict(value='3gppFlowControl', dist_name=_NRBTSname, list_name='qciTab70Nsa3x', p_name=_p_name),
    dict(value='3gppFlowControl', dist_name=_NRBTSname, list_name='qciTab79Nsa3x', p_name=_p_name),
    dict(value='3gppFlowControl', dist_name=_NRBTSname, list_name='qciTab7Nsa3x', p_name=_p_name),
    dict(value='3gppFlowControl', dist_name=_NRBTSname, list_name='qciTab8Nsa3x', p_name=_p_name),
    dict(value='3gppFlowControl', dist_name=_NRBTSname, list_name='qciTab9Nsa3x', p_name=_p_name),
    dict(value='3gppFlowControl', dist_name=_NRBTSname, list_name='fiveQiTab5', p_name=_p_name),
    dict(value='3gppFlowControl', dist_name=_NRBTSname, list_name='fiveQiTab6', p_name=_p_name),
    dict(value='3gppFlowControl', dist_name=_NRBTSname, list_name='fiveQiTab7', p_name=_p_name),
    dict(value='3gppFlowControl', dist_name=_NRBTSname, list_name='fiveQiTab8', p_name=_p_name),
    dict(value='3gppFlowControl', dist_name=_NRBTSname, list_name='fiveQiTab9', p_name=_p_name),
    dict(value='dlOverF1U', dist_name=_NRBTSname, list_name='qciTab5Nsa3x', p_name='dlDataSplitMode'),
    dict(value='dlOverF1U', dist_name=_NRBTSname, list_name='qciTab69Nsa3x', p_name='dlDataSplitMode'),
    dict(value='dlOverF1U', dist_name=_NRBTSname, list_name='qciTab6Nsa3x', p_name='dlDataSplitMode'),
    dict(value='dlOverF1U', dist_name=_NRBTSname, list_name='qciTab70Nsa3x', p_name='dlDataSplitMode'),
    dict(value='dlOverF1U', dist_name=_NRBTSname, list_name='qciTab79Nsa3x', p_name='dlDataSplitMode'),
    dict(value='dlOverF1U', dist_name=_NRBTSname, list_name='qciTab7Nsa3x', p_name='dlDataSplitMode'),
    dict(value='dlOverF1U', dist_name=_NRBTSname, list_name='qciTab8Nsa3x', p_name='dlDataSplitMode'),
    dict(value='dlOverF1U', dist_name=_NRBTSname, list_name='qciTab9Nsa3x', p_name='dlDataSplitMode'),
]

LIST_TO_CREATE = [
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPRT-1', list_name='staticRoutes'),
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPRT-1', list_name='staticRoutes'),
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPRT-1', list_name='staticRoutes'),
]

LIST_ITEM_TO_ADD = [
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPRT-1', list_name='staticRoutes',
         elements=dict(destIpAddr='0.0.0.0', destinationIpPrefixLength='0', gateway='10.57.250.129', preference='1')),
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPRT-1', list_name='staticRoutes',
         elements=dict(destIpAddr='0.0.0.0', destinationIpPrefixLength='0', gateway='10.57.250.129', preference='1')),
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPRT-1', list_name='staticRoutes',
         elements=dict(destIpAddr='0.0.0.0', destinationIpPrefixLength='0', gateway='10.57.229.33', preference='1')),
]
