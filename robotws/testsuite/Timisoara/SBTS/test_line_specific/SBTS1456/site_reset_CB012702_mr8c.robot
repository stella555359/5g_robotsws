*** Settings ***
Documentation  Test suite contain KPI TCs
Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SBTS00  SRAN  CLOUD_SRAN_LWG_1ASIB_2ABIA_1ABIL_1FRGU_2FXCB_1AHOLA


Suite Teardown    Save kpi results


Resource    ../../KPI/test_resources/KPI__Site_Reset_With_CB012702.robot

Variables    targets.py

*** Variables ***

${SCF_ID}    01
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1456
${REFERENCE_CONFIGURATION_ID}    CNF_SRAN_MR8c


*** Test Cases ***

TC__Site_reset_WITH_SNAPSHOT_enabled_CB012702
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    100
     ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
     ...    AND    Set Test Variable    ${BBMOD_SERIAL_NUMBER}    L1233203422
    ...    AND    KPI__Site_Reset_With_CB012702.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_reset
    TC__KPI__Site_Reset_With_CB012702
    [Teardown]    Run Keywords    KPI__Site_Reset_With_CB012702.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  and ${admin_started}==${TRUE}  CIT Recover Test Line By Power Reset
