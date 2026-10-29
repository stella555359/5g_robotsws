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


# ------ 532 SCF Modifications ---------
MODIFY_SCF_532_005 = [
    dict(
        value='11',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='ullaIniMcs'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='dllaIniMcs'),
]


MODIFY_SCF_532_014 = [
    dict(
        value='20',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='ullaIniMcs'),
    dict(
        value='20',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='dllaIniMcs'),
]


MODIFY_SCF_532_025 = [
    dict(
        value='20',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='ullaIniMcs'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='dllaIniMcs'),
]


MODIFY_SCF_532_026 = [
    dict(
        value='20',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='ullaIniMcs'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='dllaIniMcs'),
]


MODIFY_SCF_532_029 = [
    dict(
        value='27',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='ullaIniMcs'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='dllaIniMcs'),
]
