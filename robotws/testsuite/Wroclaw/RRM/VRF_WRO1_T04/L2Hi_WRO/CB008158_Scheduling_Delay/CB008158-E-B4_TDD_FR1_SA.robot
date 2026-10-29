*** Settings ***
Force Tags    CRT    RAN_5G    RAN_5G_TDD    SBTS00
    ...    CLOUD_5G_I_MP_AP_LO
    ...    VARIANT_SANSA_FS_ECPRI_CMWV_TDD

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
${scfc}=         ${CURDIR}/config/scfc_LCG_TDD_FR1_ASIM_ABIP.xml
${epc_cfg}=      ${CURDIR}/config/config_LCG_TDD_FR1_ASIM_ABIP.cfg
${filter}=       utcTimestampData|sfn|slot|rnti|ulFdSched|ulBsrRx|csiSrReport|ulPucchReceiveRespPsDat
${variant}=      TDD FR1

${counters_to_report}=    M55308C00063-M55308C00080

*** Test Cases ***
CB008158-SR-E_Grant_delay_after_SR_reception_and_MAC_contention_delay_TDD_FR1_SA

    Set pdu param for internal traffic  UE_ID=1
    Register UE  UE_ID=1  CELL_ID=1
    Establish PDU session  UE_ID=1  PDU_ID=1  SLICE_ID=2

    Set pdu param for internal traffic  UE_ID=2
    Register UE  UE_ID=2  CELL_ID=1
    Establish PDU session  UE_ID=2  PDU_ID=2  SLICE_ID=3

    Set pdu param for internal traffic  UE_ID=3
    Register UE  UE_ID=3  CELL_ID=1
    Establish PDU session  UE_ID=3  PDU_ID=3  SLICE_ID=4

    Set pdu param for internal traffic  UE_ID=4
    Register UE  UE_ID=4  CELL_ID=1
    Establish PDU session  UE_ID=4  PDU_ID=4
    Modify pdu session  UE_ID=4  QOS=1

    Set pdu param for internal traffic  UE_ID=5
    Register UE  UE_ID=5  CELL_ID=1
    Establish PDU session  UE_ID=5  PDU_ID=5
    Modify pdu session  UE_ID=5  QOS=2

    Set pdu param for internal traffic  UE_ID=6
    Register UE  UE_ID=6  CELL_ID=1
    Establish PDU session  UE_ID=6  PDU_ID=6

    Set pdu param for internal traffic  UE_ID=7
    Register UE  UE_ID=7  CELL_ID=1
    Establish PDU session  UE_ID=7  PDU_ID=7  SLICE_ID=7

    Wait for next full pm interval

    Start TTI trace collection
    Sleep    5s    Time buffer after TTI trace collection start

    Start sending 100 short bursts from UE-1 on QFI-1
    Start sending 100 short bursts from UE-2 on QFI-1
    Start sending 100 short bursts from UE-3 on QFI-1
    Start sending 100 short bursts from UE-4 on QFI-2
    Start sending 100 short bursts from UE-5 on QFI-2
    Start sending 100 short bursts from UE-6 on QFI-1
    Start sending 100 short bursts from UE-7 on QFI-1
    Sleep    10s   Wait for all bursts to be sent

    Sleep    5s    Time buffer before TTI trace collection stop
    Stop and convert TTI trace collection    conversion_filter=${filter}

    ${expected_SR_values}=     Get SR expected values     tti_trace_path=${OUTPUT_DIR}/${TESTNAME}/TtiTraces/output_ul.csv
    ${expected_BSR_values}=    Get BSR expected values    tti_trace_path=${OUTPUT_DIR}/${TESTNAME}/TtiTraces/output_ul.csv
    Verify counters    ${expected_SR_values}    ${expected_BSR_values}
    Report counters

    [Teardown]    Run keywords
    ...           Deregister multi UEs  first_ue_id=1  last_ue_id=7
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
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}

Report counters
    Get counters value and report to RP
    ...    counters=${counters_to_report}
    ...    localmoid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    filepath=${pm_counters}
