*** Settings ***
Documentation
...  This suite contains 4 test cases which calculates kpi1a and kpi1b with fault 252 active on SBTS.

Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SBTS00  SRAN  CLOUD_SRAN_NL_1747_2ASIB_4ABIO_9AHEH_3AHPE_3AZQS_3AZQU

Suite Teardown    Save kpi results

Resource    ../../KPI/test_resources/KPI__Site_Reset_With_CB012611.robot
Resource    ../../KPI/test_resources/KPI__Site_Reset_With_CB012611_Split_G.robot
Resource    ../../KPI/test_resources/KPI__Compare_KPI.robot

Variables    targets.py

*** Variables ***
${SCF_ID}    01
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1747
${REFERENCE_CONFIGURATION_ID}    CNF_SRAN_MR12


*** Test Cases ***
TC__Site_Reset_With_CB012611_Split_A
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    1800
	...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set Test Variable    ${LOKI_L_DN}    /MRBTS-1/RAT-1/BTS_L-4/EQM_L-1/CABINET_L-1/BBMOD_L-1/BBU_L-1/POWER_GROUP_L-2/SOC_L-1
    ...    AND    KPI__Site_Reset_With_CB012611.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_Reset_With_CB012611
    TC__KPI__Site_Reset_With_CB012611
    [Teardown]    Run Keywords    KPI__Site_Reset_With_CB012611.TC Teardown
    ...    AND    Restore Resource Search Order


TC__Site_Reset_With_CB012611_Split_B
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    1800
	...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set Test Variable    ${LOKI_L_DN}    /MRBTS-1/RAT-1/BTS_L-4/EQM_L-1/CABINET_L-1/BBMOD_L-1/BBU_L-1/POWER_GROUP_L-1/SOC_L-2
    ...    AND    KPI__Site_Reset_With_CB012611.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_Reset_With_CB012611
    TC__KPI__Site_Reset_With_CB012611
    [Teardown]    Run Keywords    KPI__Site_Reset_With_CB012611.TC Teardown
    ...    AND    Restore Resource Search Order


TC__Site_Reset_With_CB012611_Split_C
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    1800
	...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set Test Variable    ${LOKI_L_DN}    /MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/BBMOD_L-2/BBU_L-1/POWER_GROUP_L-2/SOC_L-1
    ...    AND    KPI__Site_Reset_With_CB012611.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_Reset_With_CB012611
    TC__KPI__Site_Reset_With_CB012611
    [Teardown]    Run Keywords    KPI__Site_Reset_With_CB012611.TC Teardown
    ...    AND    Restore Resource Search Order


TC__Site_Reset_With_CB012611_Split_G
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    1800
	...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    ...    AND    Set Test Variable    ${LOKI_L_DN}    /MRBTS-1/RAT-1/BTS_L-4/EQM_L-1/CABINET_L-1/BBMOD_L-2/BBU_L-1/POWER_GROUP_L-2/SOC_L-1
    ...    AND    KPI__Site_Reset_With_CB012611_Split_G.TC Setup
    ...    AND    Modify Resource Search Order    KPI__Site_Reset_With_CB012611_Split_G
    TC__KPI__Site_Reset_With_CB012611_Split_G
    [Teardown]    Run Keywords    KPI__Site_Reset_With_CB012611_Split_G.TC Teardown
    ...    AND    Restore Resource Search Order


KPI#1 Site Reset Downtime
    [Tags]  ***
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    kpi1a    kpi1b
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    KPI__Compare_KPI.TC Teardown