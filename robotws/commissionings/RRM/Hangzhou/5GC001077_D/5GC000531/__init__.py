import os


CFG_DIR = os.path.dirname(os.path.abspath(__file__))
PARAMS_TO_DELETE = [
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-2'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-2/NRCELL_FDD-1'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-3'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-3/NRCELL_FDD-1'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-4'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-4/NRCELL_FDD-1')
]


# ------ 531 SCF Modifications ---------
MODIFY_SCF_531_003 = [
    dict(
        value='2x2 Closed Loop Spatial Multiplexing',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='dlMimoMode')
]


MODIFY_SCF_531_013 = [
    dict(
        value='2x2 Closed Loop Spatial Multiplexing',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='dlMimoMode')
]


MODIFY_SCF_531_017 = [
    dict(
        value='2x2 Closed Loop Spatial Multiplexing',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='dlMimoMode')
]


MODIFY_SCF_531_019 = [
    dict(
        value='2x2 Open Loop Spatial Multiplexing',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='dlMimoMode'),
    dict(
        value='true',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/FEATCADM-1',
        p_name='rfSharingEnabled'),
    dict(
        value='5G19/5g_pid12_class_eoc_2dl2ul_rfs',
        dist_name='MRBTS-1900/EQM-1/APEQM-1',
        p_name='rapProfile'),
    dict(
        value='1pps/ToD from Sync Hub Master',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1',
        p_name='syncInputType')
]

MODIFY_SCF_531_027 = [
    dict(
        value='2x2 Open Loop Spatial Multiplexing',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='dlMimoMode'),
]


MODIFY_SCF_531_035 = [
    dict(
        value='2x2 Open Loop Spatial Multiplexing',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='dlMimoMode'),
]
