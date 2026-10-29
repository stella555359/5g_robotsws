import os

__team__ = 'MN 5G RAN I&V 4 Pz HZG SG1'
__email__ = 'I_MN_5G_RAN_IV4_LINE_HZG_1@internal.nsn.com'
# #########Feature CB008974#########
CB008974_REPLACE_PRA = {
    "Old_Pra": ["RMOD-2", "LCELNR-2", "LCELNR-3", "NRCELL-2", "NRCELL-3", "NRCELLGRP-1", "NRCELLGRP-2"],
    "New_Pra": ["RMOD-1", "LCELNR-1", "LCELNR-2", "NRCELL-1", "NRCELL-2", "NRCELLGRP-0", "NRCELLGRP-1"],
}

CB008974_PARAMS_TO_DELETE_BASE = [
    dict(dist_name='MRBTS-1204/EQM-1/APEQM-1/RMOD-1'),
    dict(dist_name='MRBTS-1204/EQM-1/HWTOP-1/CABLINK-2'),
    dict(dist_name='MRBTS-1204/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1'),
    dict(dist_name="MRBTS-1204/MNL-1/MNLENT-1/SYNC-2", list_name="targetDNList"),
    dict(dist_name='MRBTS-1204/NRBTS-1204/NRCELL-1'),
    dict(dist_name='MRBTS-1204/NRBTS-1204/NRCELLGRP-0'),
    dict(dist_name='MRBTS-1204/NRBTS-1204/NRCELLGRP-1', list_name="nrCellList"),
    dict(dist_name='MRBTS-1204/NRBTS-1204/NRCELLGRP-2', list_name="nrCellList"),
    dict(dist_name='MRBTS-1204/NRBTS-1204/NRDU-1', list_name="refNrCellGroup"),
    dict(dist_name='MRBTS-1204/TNLSVC-1/TNL-2/ETHSVC-1/ETHIF-2'),
    dict(dist_name='MRBTS-1204/TNLSVC-1/TNL-2/ETHSVC-1/ETHLK-2'),
]

CB008974_ADD_MOS_BASE = [

]

CB008974_LIST_TO_ADD_BASE = [
    dict(
        dist_name="MRBTS-1204/MNL-1/MNLENT-1/SYNC-2",
        list_name="targetDNList",
        elements=["MRBTS-1204/EQM-1/APEQM-1/RMOD-1"],
    ),
    dict(
        dist_name="MRBTS-1204/NRBTS-1204/NRCELLGRP-1",
        list_name="nrCellList",
        elements=["1"],
    ),
    dict(
        dist_name="MRBTS-1204/NRBTS-1204/NRCELLGRP-2",
        list_name="nrCellList",
        elements=["2"],
    ),
    dict(
        dist_name="MRBTS-1204/NRBTS-1204/NRDU-1",
        list_name="refNrCellGroup",
        elements=["0", "1"],
    ),
]

CB008974_PARAMS_TO_MODIFY_BASE = [
    dict(
        value="TL1204_CB008974_BASE_2CC_AWPTD_SA",
        dist_name="MRBTS-1204",
        p_name="btsName",
    ),
    dict(
        value="1",
        dist_name="MRBTS-1204/NRBTS-1204/NRCELL-2",
        p_name="lcrId",
    ),
    dict(
        value="2",
        dist_name="MRBTS-1204/NRBTS-1204/NRCELL-3",
        p_name="lcrId",
    ),
]

CB008974_LIST_PARAMS_TO_MODIFY_BASE = [

]
# ##General_SiSo_Cell_block_and_unblock##
CB008974_PARAMS_TO_DELETE_CELL_BLOCK = [
    dict(dist_name='MRBTS-1204/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2'),
    dict(dist_name='MRBTS-1204/NRBTS-1204/NRCELL-2'),
    dict(dist_name='MRBTS-1204/NRBTS-1204/NRCELLGRP-1'),
    dict(dist_name='MRBTS-1204/NRBTS-1204/NRDU-1', list_name="refNrCellGroup"),

]

CB008974_ADD_MOS_BASE_CELL_BLOCK = [

]

CB008974_LIST_TO_ADD_BASE_CELL_BLOCK = [
    dict(
        dist_name="MRBTS-1204/NRBTS-1204/NRDU-1",
        list_name="refNrCellGroup",
        elements=["0"],
    ),
]

CB008974_PARAMS_TO_MODIFY_BASE_CELL_BLOCK = [
    dict(
        value="TL1204_CB008974_BASE_1CC_AWPTD_SA",
        dist_name="MRBTS-1204",
        p_name="btsName",
    ),
]

CB008974_LIST_PARAMS_TO_MODIFY_BASE_CELL_BLOCK = [

]

# #########Feature CB007758#########
CB007758_PARAMS_TO_DELETE_BASE = [
    dict(dist_name='MRBTS-1204/EQM-1/APEQM-1/RMOD-2'),
    dict(dist_name='MRBTS-1204/EQM-1/HWTOP-1/CABLINK-3'),
    dict(dist_name='MRBTS-1204/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2'),
    dict(dist_name='MRBTS-1204/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3'),
    dict(dist_name="MRBTS-1204/MNL-1/MNLENT-1/SYNC-2", list_name="targetDNList"),
    dict(dist_name='MRBTS-1204/NRBTS-1204/NRCELL-2'),
    dict(dist_name='MRBTS-1204/NRBTS-1204/NRCELL-3'),
    dict(dist_name='MRBTS-1204/NRBTS-1204/NRCELLGRP-1'),
    dict(dist_name='MRBTS-1204/NRBTS-1204/NRCELLGRP-2'),
    dict(dist_name='MRBTS-1204/NRBTS-1204/NRDU-1', list_name="refNrCellGroup"),
    dict(dist_name='MRBTS-1204/TNLSVC-1/TNL-2/ETHSVC-1/ETHIF-3'),
    dict(dist_name='MRBTS-1204/TNLSVC-1/TNL-2/ETHSVC-1/ETHLK-3'),
]

CB007758_ADD_MOS_BASE = [

]

CB007758_LIST_TO_ADD_BASE = [
    dict(
        dist_name="MRBTS-1204/MNL-1/MNLENT-1/SYNC-2",
        list_name="targetDNList",
        elements=["MRBTS-1204/EQM-1/APEQM-1/RMOD-1"],
    ),
    dict(
        dist_name="MRBTS-1204/NRBTS-1204/NRDU-1",
        list_name="refNrCellGroup",
        elements=["0"],
    ),
]

CB007758_PARAMS_TO_MODIFY_BASE = [
    dict(
        value="TL1204_CB007758_BASE_1CC_AWHQX_SA",
        dist_name="MRBTS-1204",
        p_name="btsName",
    ),
]

CB007758_LIST_PARAMS_TO_MODIFY_BASE = [

]
