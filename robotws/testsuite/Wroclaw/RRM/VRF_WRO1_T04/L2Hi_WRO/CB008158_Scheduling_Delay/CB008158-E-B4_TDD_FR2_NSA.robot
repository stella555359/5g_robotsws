*** Settings ***
Force Tags    CRT    RAN_5G    RAN_5G_TDD    SBTS00
    ...    CLOUD_5G_I_LO_AP_LO
    ...    VARIANT_SA+NSA_FS_ECPRI_MMWV_TDD

Documentation
...    Author: Michal Gorski
...    Contact: michal.gorski@nokia.com
...    Description: Suite description in QC

Library    resources/ul_trace_analyzer.py
Resource   resources/CB008158_resources.robot
Resource     ../resources/common_configuration.robot

Suite Setup       Prepare suite environment with aliases
Suite Teardown    Clean suite environment

*** Variables ***
${scfc}=         ${CURDIR}/config/scfc_LCG_TDD_FR2.xml
${epc_cfg}=      ${CURDIR}/config/config_LCG_TDD_FR2.cfg
${filter}=       utcTimestampData|sfn|slot|rnti|ulFdSched|ulBsrRx|csiSrReport|ulPucchReceiveRespPsDat
${variant}=      TDD FR2

${counters_to_report}=    M55308C00063-M55308C00080

*** Test Cases ***
CB008158-SR-E_Grant_delay_after_SR_reception_and_MAC_contention_delay_TDD_FR2_NSA

    Attach UE    UE_ID=15
    Sleep  2s    reason=wait for stabilization
    SgNB Addition    UE_ID=15    CELL_ID=2
    Modify LTE-NR dual connectivity    UE_ID=15    BEARER_ID=1

    Attach UE    UE_ID=16
    Sleep  2s    reason=wait for stabilization
    SgNB Addition    UE_ID=16    CELL_ID=2
    Modify LTE-NR dual connectivity    UE_ID=16    BEARER_ID=3

    Attach UE    UE_ID=17
    Sleep  2s    reason=wait for stabilization
    SgNB Addition    UE_ID=17    CELL_ID=2
    Modify LTE-NR dual connectivity    UE_ID=17    BEARER_ID=5

    Attach UE    UE_ID=18
    Sleep  2s    reason=wait for stabilization
    SgNB Addition    UE_ID=18    CELL_ID=2
    Modify LTE-NR dual connectivity    UE_ID=18    BEARER_ID=7

    Attach UE    UE_ID=19
    Sleep  2s    reason=wait for stabilization
    SgNB Addition    UE_ID=19    CELL_ID=2

    Wait for next full pm interval

    Start TTI trace collection
    Sleep    5s    Time buffer after TTI trace collection start

    Start sending 100 short bursts from UE-15 on bearer-1
    Start sending 100 short bursts from UE-16 on bearer-3
    Start sending 100 short bursts from UE-17 on bearer-5
    Start sending 100 short bursts from UE-18 on bearer-7
    Start sending 100 short bursts from UE-19 on bearer-2
    Sleep    10s   Wait for all bursts to be sent

    Sleep    5s    Time buffer before TTI trace collection stop
    Stop and convert TTI trace collection    conversion_filter=${filter}

    ${expected_SR_values}=     Get SR expected values     tti_trace_path=${OUTPUT_DIR}/${TESTNAME}/TtiTraces/output_ul.csv
    ${expected_BSR_values}=    Get BSR expected values    tti_trace_path=${OUTPUT_DIR}/${TESTNAME}/TtiTraces/output_ul.csv
    Verify counters    ${expected_SR_values}    ${expected_BSR_values}
    Report counters

    [Teardown]    Run keywords
    ...           Detach multi UEs    first_ue_id=15    last_ue_id=19
    ...    AND    Send Configuration ID To Scout

*** Keywords ***
Prepare suite environment with aliases
    Prepare suite environment    scfc=${scfc}    egate_config=${epc_cfg}
    Create aliases

Verify counters
    [Arguments]    ${expected_SR_values}    ${expected_BSR_values}

    ${pm_counters}=    Wait for next pm interval and get counters
    Set test variable    ${pm_counters}

    Run keyword and continue on failure  Verify last counters in file
    ...    M55308C00071    ${expected_SR_values}[count]         INIT_UL_GRANT_SR
    ...    M55308C00072    ${expected_BSR_values}[counts][0]    TOT_UL_BURST_MAC_LCG0
    ...    M55308C00073    ${expected_BSR_values}[counts][1]    TOT_UL_BURST_MAC_LCG1
    ...    M55308C00074    ${expected_BSR_values}[counts][2]    TOT_UL_BURST_MAC_LCG2
    ...    M55308C00075    ${expected_BSR_values}[counts][3]    TOT_UL_BURST_MAC_LCG3
    ...    M55308C00076    ${expected_BSR_values}[counts][4]    TOT_UL_BURST_MAC_LCG4
    ...    M55308C00077    ${expected_BSR_values}[counts][5]    TOT_UL_BURST_MAC_LCG5
    ...    M55308C00078    ${expected_BSR_values}[counts][6]    TOT_UL_BURST_MAC_LCG6
    ...    M55308C00079    ${expected_BSR_values}[counts][7]    TOT_UL_BURST_MAC_LCG7
    ...    M55308C00080    ${expected_SR_values}[delay]         UL_SR_GRANT_DLY
    ...    M55308C00063    ${expected_BSR_values}[delays][0]    UL_MAC_CONT_DLY_LCG0
    ...    M55308C00064    ${expected_BSR_values}[delays][1]    UL_MAC_CONT_DLY_LCG1
    ...    M55308C00065    ${expected_BSR_values}[delays][2]    UL_MAC_CONT_DLY_LCG2
    ...    M55308C00066    ${expected_BSR_values}[delays][3]    UL_MAC_CONT_DLY_LCG3
    ...    M55308C00067    ${expected_BSR_values}[delays][4]    UL_MAC_CONT_DLY_LCG4
    ...    M55308C00068    ${expected_BSR_values}[delays][5]    UL_MAC_CONT_DLY_LCG5
    ...    M55308C00069    ${expected_BSR_values}[delays][6]    UL_MAC_CONT_DLY_LCG6
    ...    M55308C00070    ${expected_BSR_values}[delays][7]    UL_MAC_CONT_DLY_LCG7
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    file_path=${pm_counters}

Report counters
    Get counters value and report to RP
    ...    counters=${counters_to_report}
    ...    localmoid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    filepath=${pm_counters}
