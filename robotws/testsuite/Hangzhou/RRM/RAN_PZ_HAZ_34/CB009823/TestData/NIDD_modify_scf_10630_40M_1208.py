from testsuite.Hangzhou.RRM.RAN_PZ_HAZ_34.CB009823.TestData.NIDD_modify_scf_40M_1208 import *

TC_02_13350_1208_40MHZ_MODIFY_SCF_VICTIM = [
    dict(
        dist_name=DN_TDDCELL,
        p_name='actNrRim',
        value='RI detection and mitigation'),
    dict(
        dist_name=DN_NRRIM,
        p_name='actRiDetectTriggerDlMitigation',
        value='true'),
    dict(
        dist_name=DN_NRRIM,
        p_name='actRimSoftDlMuting',
        value='true'),
    dict(
        dist_name=DN_NRRIM,
        p_name='actRimPowerReduction',
        value='false'),
    # dict(
    #     dist_name=DN_NRRIM,
    #     p_name='dlMutingFallbackTimer',
    #     value='300'),
    dict(
        dist_name=DN_NRBTS,
        list_name='actRimCmFmReport',
        p_name='asymmetricStateReport',
        value='FM off, CM on'),
    dict(
        dist_name=DN_NRBTS,
        list_name='actRimCmFmReport',
        p_name='dlMutingStateReport',
        value='FM off, CM on'),
    dict(
        dist_name=DN_NRBTS,
        list_name='actRimCmFmReport',
        p_name='rimRsStateReport',
        value='FM off, CM on'),
    dict(
        dist_name=DN_NRBTS,
        list_name='actRimCmFmReport',
        p_name='riStateReport',
        value='FM on, CM off')
]

TC_02_13350_1208_40MHZ_ADD_SCF_NRRIM_VICTIM = [
    dict(
        dist_name=DN_NRRIM,
        p_name='windowDurationForCellLoadAvg',
        value='10'),
    dict(
        dist_name=DN_NRRIM,
        p_name='cellLoadThreshForRimMitigation',
        value='40'),
]

TC_02_13350_1208_40MHZ_MODIFY_SCF_AGGRESSOR = [
    dict(
        dist_name=DN_TDDCELL_GNB1,
        p_name='actNrRim',
        value='RI detection and mitigation'),
    dict(
        dist_name=DN_NRRIM_GNB1,
        p_name='actRiDetectTriggerDlMitigation',
        value='true')
]

PARAMS_TO_MODIFY_DIC[0] = PARAMS_TO_MODIFY_DIC[0] + TC_02_13350_1208_40MHZ_MODIFY_SCF_VICTIM
PARAMS_TO_MODIFY_DIC[1] = PARAMS_TO_MODIFY_DIC[1] + TC_02_13350_1208_40MHZ_MODIFY_SCF_AGGRESSOR
PARAMS_TO_ADD_DIC[0] = PARAMS_TO_ADD_DIC[0] + TC_02_13350_1208_40MHZ_ADD_SCF_NRRIM_VICTIM
