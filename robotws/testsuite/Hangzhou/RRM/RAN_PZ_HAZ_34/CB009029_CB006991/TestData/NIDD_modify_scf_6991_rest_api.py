from testsuite.Hangzhou.RRM.RAN_PZ_HAZ_34.CB009029_CB006991.TestData.NIDD_modify_scf_6991_base import *

RESTAPI_MODIFY_UL_MITIGATION_ONLY = [
    dict(
        value=MITIGATION_SCHEME_UL_ONLY,
        dist_name=DN_TDDCELL + "/NRRIM_PROFILE-1",
        parameter="nrRimMitigationScheme",
    ),
]

RESTAPI_MODIFY_NO_MITIGATION = [
    dict(
        value=MITIGATION_SCHEME_NO_MITIGATION,
        dist_name=DN_TDDCELL + "/NRRIM_PROFILE-1",
        parameter="nrRimMitigationScheme",
    ),
]

RESTAPI_MODIFY_TARGET_TOTAL_LOAD = [
    dict(
        value=0,
        dist_name=DN_TDDCELL_GNB1,
        parameter="targetTotalLoad",
    ),
    dict(
        value=100,
        dist_name=DN_TDDCELL_GNB1,
        parameter="targetTotalLoadSectorBeam",
    ),
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

RESTAPI_MODIFY_NO_TARGET_TOTAL_LOAD = [
    dict(
        value=0,
        dist_name=DN_TDDCELL_GNB1,
        parameter="targetTotalLoad",
    ),
    dict(
        value=0,
        dist_name=DN_TDDCELL_GNB1,
        parameter="targetTotalLoadSectorBeam",
    ),
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

DELETE_MO_NRMTRACEDU_RESTAPI = [dict(dist_name=NRMTRACEDU)]
