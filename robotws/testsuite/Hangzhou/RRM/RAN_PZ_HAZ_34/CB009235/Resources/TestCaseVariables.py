import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')

CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
NRPMRNL_DIR = MR_NR_BTS_NAME + '/NRPMRNL-1'
NRDLMUMIMO_DIR = MR_NR_BTS_NAME + '/NRCELL-301/NRDLMUMIMO-1'

PARAMS_TO_MODIFY_FOR_9235 = [
    dict(
        dist_name=NRPMRNL_DIR,
        p_name='miNrCellUtilization',
        value='5min'),
    dict(
        dist_name=MR_NR_BTS_NAME + '/NRCELL-301',
        p_name='actDlMuMimoEnh',
        value='true'),
    dict(
        dist_name=MR_NR_BTS_NAME + '/NRCELL-301',
        p_name='maxNumPdschAllocationPerSlot',
        value='3'),
    dict(
        dist_name=MR_NR_BTS_NAME + '/NRCELL-301',
        p_name='maxNumPuschAllocationPerSlot',
        value='3'),
    dict(
        dist_name=NRDLMUMIMO_DIR,
        p_name='actMuAwareTdSch',
        value='true'),
    dict(
        dist_name=NRDLMUMIMO_DIR,
        p_name='dlMuAwarePrbRatio',
        value='100'),
    dict(
        dist_name=NRDLMUMIMO_DIR,
        p_name='dlMuAwareCorrThd',
        value='10'),
    dict(
        dist_name=NRDLMUMIMO_DIR,
        p_name='dlMuMaxNumLayerPerMuRbg',
        value='16'),
]
