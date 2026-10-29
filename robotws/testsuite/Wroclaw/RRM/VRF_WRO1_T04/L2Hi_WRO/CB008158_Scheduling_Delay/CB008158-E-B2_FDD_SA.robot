*** Settings ***
Force Tags    CRT    RAN_5G    RAN_5G_TDD    SBTS00    SKIPRUN
    ...    CLOUD_5G_I_LO_AP_LO
    ...    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

Documentation
...    author: Patryk Wojcik
...    contact: patryk.wojcik@nokia.com
...    Description: Suite description in QC

Library    resources/ul_trace_analyzer.py
Resource   resources/CB008158_resources.robot
Resource     ../resources/common_configuration.robot

Suite Setup    Run Keywords    Prepare suite environment  egate_config=${lua_cfg_file}  scfc=${scfc}
...                     AND    Create aliases
Suite Teardown   Clean suite environment

*** Variables ***
${scfc}=          ${CURDIR}/config/scfc_LCG_FDD_TDD_FR1.xml
${lua_cfg_file}=  ${CURDIR}/config/config_LCG_FDD_FR1_AHLOA.cfg
${filter}=        ulFdSched|ulBsrRx|csiSrReport|ulPucchReceiveRespPsDat|rnti

*** Test Cases ***
[1]CB008158-SR-E-B2_number_of_UL_Grants_after_SR_reception_FDD_SA

    Wait for next full pm interval
    Start TTI trace collection

    Set pdu param for internal traffic  UE_ID=1
    Register UE  UE_ID=1  CELL_ID=3
    Establish PDU session  UE_ID=1  PDU_ID=1  SLICE_ID=2

    Set pdu param for internal traffic  UE_ID=2
    Register UE  UE_ID=2  CELL_ID=3
    Establish PDU session  UE_ID=2  PDU_ID=2  SLICE_ID=3

    Set pdu param for internal traffic  UE_ID=3
    Register UE  UE_ID=3  CELL_ID=3
    Establish PDU session  UE_ID=3  PDU_ID=3  SLICE_ID=4

    Set pdu param for internal traffic  UE_ID=4
    Register UE  UE_ID=4  CELL_ID=3
    Establish PDU session  UE_ID=4  PDU_ID=4
    Modify pdu session  UE_ID=4  QOS=1

    Set pdu param for internal traffic  UE_ID=5
    Register UE  UE_ID=5  CELL_ID=3
    Establish PDU session  UE_ID=5  PDU_ID=5
    Modify pdu session  UE_ID=5  QOS=2

    Set pdu param for internal traffic  UE_ID=6
    Register UE  UE_ID=6  CELL_ID=3
    Establish PDU session  UE_ID=6  PDU_ID=6

    Set pdu param for internal traffic  UE_ID=7
    Register UE  UE_ID=7  CELL_ID=3
    Establish PDU session  UE_ID=7  PDU_ID=7  SLICE_ID=7

    Start SA traffic  ue=1  dir=ul  traffic_rate=1mbps    packets=1000
    Start SA traffic  ue=2  dir=ul  traffic_rate=2mbps    packets=1000
    Start SA traffic  ue=3  dir=ul  traffic_rate=1mbps    packets=1000
    Start SA traffic  ue=4  qfi=2  dir=ul  traffic_rate=128kbps    packets=1000
    Start SA traffic  ue=5  qfi=2  dir=ul  traffic_rate=256kbps    packets=1000
    Start SA traffic  ue=6  dir=ul  traffic_rate=512kbps    packets=1000
    Start SA traffic  ue=7  dir=ul  traffic_rate=4mbps    packets=1000

    Sleep  10s   reason=wait for traffic stabilization

    Deregister multi UEs  first_ue_id=1  last_ue_id=7

    Sleep  3s    reason=wait for stabilization after deregister

    Stop and convert TTI trace collection  conversion_filter=${filter}

    ${TOT_UL_BURST_MAC_LCG}=    Get TOT UL BURST MAC LCG    tti_trace_path=${OUTPUT_DIR}/${TESTNAME}/TtiTraces/output_ul.csv
    ${INIT_UL_GRANT_SR}=        Get INIT UL GRANT SR        tti_trace_path=${OUTPUT_DIR}/${TESTNAME}/TtiTraces/output_ul.csv

    Verify counters    ${TOT_UL_BURST_MAC_LCG}    ${INIT_UL_GRANT_SR}

    [Teardown]    Send Configuration ID To Scout

*** Keywords ***
Verify counters
    [Arguments]    ${TOT_UL_BURST_MAC_LCG}    ${INIT_UL_GRANT_SR}
    ${pm_counters}=  Wait for next pm interval and get counters
    Run keyword and continue on failure  Verify last counters in file
    ...    M55308C00071    ${INIT_UL_GRANT_SR}           INIT_UL_GRANT_SR
    ...    M55308C00072    ${TOT_UL_BURST_MAC_LCG}[0]    TOT_UL_BURST_MAC_LCG0
    ...    M55308C00073    ${TOT_UL_BURST_MAC_LCG}[1]    TOT_UL_BURST_MAC_LCG1
    ...    M55308C00074    ${TOT_UL_BURST_MAC_LCG}[2]    TOT_UL_BURST_MAC_LCG2
    ...    M55308C00075    ${TOT_UL_BURST_MAC_LCG}[3]    TOT_UL_BURST_MAC_LCG3
    ...    M55308C00076    ${TOT_UL_BURST_MAC_LCG}[4]    TOT_UL_BURST_MAC_LCG4
    ...    M55308C00077    ${TOT_UL_BURST_MAC_LCG}[5]    TOT_UL_BURST_MAC_LCG5
    ...    M55308C00078    ${TOT_UL_BURST_MAC_LCG}[6]    TOT_UL_BURST_MAC_LCG6
    ...    M55308C00079    ${TOT_UL_BURST_MAC_LCG}[7]    TOT_UL_BURST_MAC_LCG7
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    file_path=${pm_counters}
