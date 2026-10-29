from testsuite.Hangzhou.RRM.RAN_PZ_HAZ_34.CB009823.TestData.NIDD_modify_scf_60M_1116_0ms_6GP import *

TC_06_12719_1116_0MS_6GP_60MHZ_MODIFY_SCF_VICTIM = [
    dict(
        dist_name=DN_NRRIM,
        p_name='actRimSoftDlMuting',
        value='false'),
    dict(
        dist_name=DN_NRRIM,
        p_name='actRimPowerReduction',
        value='true'),
    dict(
        dist_name=DN_NRRIM,
        p_name='actRimPdcchMutingOnSpecialSlot',
        value='false'),
    dict(
        dist_name=DN_NRBTS + '/NRRIM_PWR_PROFILE-0',
        p_name='rimPowerReduction',
        value='20'),
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
        value='FM off, CM on')
]

TC_02_13350_1116_0MS_6GP_60MHZ_ADD_SCF_NRRIM_VICTIM = [
    dict(
        dist_name=DN_NRRIM,
        p_name='dlMutingFallbackTimer',
        value='300'),
    dict(
        dist_name=DN_NRRIM,
        p_name='windowDurationForCellLoadAvg',
        value='10'),
    dict(
        dist_name=DN_NRRIM,
        p_name='cellLoadThreshForRimMitigation',
        value='50')
]

PARAMS_TO_MODIFY_DIC[0] = PARAMS_TO_MODIFY_DIC[0] + TC_06_12719_1116_0MS_6GP_60MHZ_MODIFY_SCF_VICTIM
PARAMS_TO_ADD_DIC[0] = PARAMS_TO_ADD_DIC[0] + TC_02_13350_1116_0MS_6GP_60MHZ_ADD_SCF_NRRIM_VICTIM
