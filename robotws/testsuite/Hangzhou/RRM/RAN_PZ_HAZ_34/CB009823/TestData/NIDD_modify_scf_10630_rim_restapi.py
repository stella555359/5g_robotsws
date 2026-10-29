from testsuite.Hangzhou.RRM.RAN_PZ_HAZ_34.CB009823.TestData.NIDD_modify_scf_restapi import *

ENABLE_12719_API_VICTIM = [
    dict(
        dist_name=DN_NRRIM,
        parameter='actRimPowerReduction',
        value='true')
]

DISABLE_12719_API_VICTIM = [
    dict(
        dist_name=DN_NRRIM,
        parameter='actRimPowerReduction',
        value='false')
]

DISABLE_13350_MUTE_CM_API_VICTIM = [
    dict(
        dist_name=DN_NRRIM,
        parameter='actRimSoftDlMuting',
        value='false'),
    dict(
        dist_name=DN_NRBTS,
        parameter='actRimCmFmReport',
        value=[dict(dlMutingStateReport='FM on, CM off')])
]

UPDATE_DLMUTINGFALLBACKTIMER_TO_1_API_VICTIM = [
    dict(
        dist_name=DN_NRRIM,
        parameter='dlMutingFallbackTimer',
        value='1')
]

UPDATE_CELLLOADTHRESHFORRIMMITIGATION_TO_1_API_VICTIM = [
    dict(
        dist_name=DN_NRRIM,
        parameter='cellLoadThreshForRimMitigation',
        value='1')
]

UPDATE_CELLLOADTHRESHFORRIMMITIGATION_TO_0_API_VICTIM = [
    dict(
        dist_name=DN_NRRIM,
        parameter='cellLoadThreshForRimMitigation',
        value='0')
]

# MODIFY_PMAX_AGGRESSOR_13350_SCF = [
#     dict(
#         value=230,
#         dist_name=DN_TDDCELL_GNB1,
#         p_name="pMax")
# ]

# RECOVERY_PMAX_AGGRESSOR_13350_REST = [
#     dict(
#         dist_name=DN_TDDCELL_GNB1,
#         parameter='pMax',
#         value=270)
# ]
