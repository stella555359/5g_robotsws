*** Settings ***
Force Tags    CRT    RAN_5G    RAN_5G_TDD    SBTS00    SKIPRUN
    ...    CLOUD_5G_I_LO_AP_LO
    ...    VARIANT_SA+NSA_FS_ECPRI_MMWV_TDD

Documentation
...    author: Patryk Wojcik
...    contact: patryk.wojcik@nokia.com
...    Description: Suite description in QC

Library    resources/ul_trace_analyzer.py
Resource   resources/CB008158_resources.robot
Resource     ../resources/common_configuration.robot

Suite Setup      Run Keywords    Prepare suite environment  egate_config=${lua_cfg_file}  scfc=${scfc}
...                       AND    Create aliases
Suite Teardown   Clean suite environment

*** Variables ***
${scfc}=          ${CURDIR}/config/scfc_LCG_TDD_FR2.xml
${lua_cfg_file}=  ${CURDIR}/config/config_LCG_TDD_FR2.cfg
${filter}=        ulFdSched|ulBsrRx|csiSrReport|ulPucchReceiveRespPsDat|rnti

*** Test Cases ***
[1]CB008158-SR-E-B2_number_of_UL_Grants_after_SR_reception_TDD_FR2_NSA

    Wait for next full pm interval
    Start TTI trace collection

    Attach UE  UE_ID=15
    SgNB Addition  UE_ID=15  CELL_ID=2
    Modify LTE-NR dual connectivity  UE_ID=15  BEARER_ID=1
    Start NSA traffic  ue=15  dir=ul  bearer=1  traffic_rate=1Mbps    packets=400

    Attach UE  UE_ID=16
    SgNB Addition  UE_ID=16  CELL_ID=2
    Modify LTE-NR dual connectivity  UE_ID=16  BEARER_ID=3
    Start NSA traffic  ue=16  dir=ul  bearer=3  traffic_rate=1Mbps    packets=400

    Attach UE  UE_ID=17
    SgNB Addition  UE_ID=17  CELL_ID=2
    Modify LTE-NR dual connectivity  UE_ID=17  BEARER_ID=5
    Start NSA traffic  ue=17  dir=ul  bearer=5  traffic_rate=1Mbps    packets=400

    Attach UE  UE_ID=18
    SgNB Addition  UE_ID=18  CELL_ID=2
    Modify LTE-NR dual connectivity  UE_ID=18  BEARER_ID=7
    Start NSA traffic  ue=18  dir=ul  bearer=7  traffic_rate=1Mbps    packets=400

    Attach UE  UE_ID=19
    SgNB Addition  UE_ID=19  CELL_ID=2
    Start NSA traffic  ue=19  dir=ul  bearer=2  traffic_rate=1Mbps    packets=400

    Sleep  5s   reason=wait for traffic stabilization

    Detach multi UEs  first_ue_id=15  last_ue_id=19

    Sleep  3s    reason=wait for stabilization after detach

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
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    file_path=${pm_counters}
