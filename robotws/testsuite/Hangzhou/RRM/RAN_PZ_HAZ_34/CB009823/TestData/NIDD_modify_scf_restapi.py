from NIDD_modify_scf_common import *

MODIFY_rsTransTrigger_API_GNB1 = [
    dict(
        dist_name=DN_NRRIM_GNB1,
        parameter='rsTransTrigger',
        value='RI trigger')
]

RESTAPI_MODIFY_NO_TARGET_TOTAL_LOAD = [
    dict(
        value=0,
        dist_name=DN_TDDCELL_GNB1,
        parameter="targetTotalLoad",
    ),
    dict(
        dist_name=DN_TDDCELL_GNB1,
        parameter='targetTotalLoadSectorBeam',
        value=0),
    dict(
        dist_name=DN_TDDCELL_GNB1,
        parameter='actConfDlInterferenceGen',
        value='PDSCH+PDCCH+TRS+SSB'),
    dict(
        dist_name=DN_TDDCELL_GNB1,
        parameter='mcsIndexForArtificialLoad',
        value=28),
    dict(
        dist_name=DN_TDDCELL_GNB1,
        parameter='actDlRbgRandomization',
        value='enhanced'),
]

RESTAPI_MODIFY_TARGET_TOTAL_LOAD = [
    dict(
        value=0,
        dist_name=DN_TDDCELL_GNB1,
        parameter="targetTotalLoad",
    ),
    dict(
        dist_name=DN_TDDCELL_GNB1,
        parameter='targetTotalLoadSectorBeam',
        value=100),
    dict(
        dist_name=DN_TDDCELL_GNB1,
        parameter='actConfDlInterferenceGen',
        value='PDSCH+PDCCH+TRS+SSB'),
    dict(
        dist_name=DN_TDDCELL_GNB1,
        parameter='mcsIndexForArtificialLoad',
        value=28),
    dict(
        dist_name=DN_TDDCELL_GNB1,
        parameter='actDlRbgRandomization',
        value='enhanced'),
]

RESTAPI_repetitionRsType1_victim = [
    dict(
        dist_name=DN_NRRIM,
        parameter='repetitionRsType1',
        value='r2')
]

RESTAPI_repetitionRsType1_aggressor = [
    dict(
        dist_name=DN_NRRIM_GNB1,
        parameter='repetitionRsType1',
        value='r2')
]

RESTAPI_repetitionRsType2_victim = [
    dict(
        dist_name=DN_NRRIM,
        parameter='repetitionRsType2',
        value='r2')
]

RESTAPI_repetitionRsType2_aggressor = [
    dict(
        dist_name=DN_NRRIM_GNB1,
        parameter='repetitionRsType2',
        value='r2')
]

RESTAPI_numDetectedSetIdForMitigation_victim_2 = [
    dict(
        dist_name=DN_NRRIM,
        parameter='numDetectedSetIdForMitigation',
        value='2')
]

RESTAPI_numDetectedSetIdForMitigation_victim_1 = [
    dict(
        dist_name=DN_NRRIM,
        parameter='numDetectedSetIdForMitigation',
        value='1')
]

RESTAPI_rimDLMitigationManualTrigger_victim_S = [
    dict(
        dist_name=DN_NRRIM,
        parameter='rimDlMitigationManualTrigger',
        value='special slot muting')
]

RESTAPI_rimDLMitigationManualTrigger_victim_S_D = [
    dict(
        dist_name=DN_NRRIM,
        parameter='rimDlMitigationManualTrigger',
        value='DL+special slots muting')
]

RESTAPI_rsDetectionWindow_SUU = [
    dict(
        dist_name=DN_NRRIM,
        parameter='rsDetectionWindow',
        value='special+2UL slots')
]

RESTAPI_rsDetectionWindow_SU = [
    dict(
        dist_name=DN_NRRIM,
        parameter='rsDetectionWindow',
        value='special+UL slots')
]

RESTAPI_rsDetectionWindow_disable = [
    dict(
        dist_name=DN_NRRIM,
        parameter='rsDetectionWindow',
        value='disable RS detection')
]

RESTAPI_rsDetectionWindow_sloping = [
    dict(
        dist_name=DN_NRRIM,
        parameter='rsDetectionWindow',
        value='sloping based')
]

RESTAPI_rsDistanceThreshold_10 = [
    dict(
        dist_name=DN_NRRIM,
        parameter='rsDistanceThreshold',
        value=10)
]

RESTAPI_rsDistanceThreshold_0 = [
    dict(
        dist_name=DN_NRRIM,
        parameter='rsDistanceThreshold',
        value=0)
]

RESTAPI_p0NominalPusch = [
    dict(
        dist_name=DN_TDDCELL,
        parameter='ulPowerControlCommon',
        value=[dict(p0NominalPusch=-108)])
]

RESTAPI_p0NominalPusch_back = [
    dict(
        dist_name=DN_TDDCELL,
        parameter='ulPowerControlCommon',
        value=[dict(p0NominalPusch=-98)])
]

ENABLE_DLMUTING_RIMRS_CM_ON = [
    dict(
        dist_name=DN_NRBTS,
        parameter='actRimCmFmReport',
        value=[dict(dlMutingStateReport='FM off, CM on',
               rimRsStateReport='FM off, CM on')])
]

RESTAPI_Cancel_RI = MODIFY_rsTransTrigger_API_GNB1 + RESTAPI_MODIFY_NO_TARGET_TOTAL_LOAD
