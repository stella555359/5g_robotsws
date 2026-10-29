*** Settings ***

Documentation
...    author: Maciej Majewski
...    contact: maciej.majewski@nokia.com
...    Description: Suite description in QC

Resource       resources/CB008009_resources.robot
Resource     ../resources/common_configuration.robot

Force Tags    SKIPRUN

Suite Setup       Setup test environment
Test Teardown    Send Configuration ID To Scout
Suite Teardown    Clean suite environment

*** Variables ***
${lua_cfg_file}=   ${CURDIR}/config/basic_setup_FDD.cfg
${ap_xml}=         ${CURDIR}/config/FDD_CPRI_LO_AP_LO/iphy_FDD_SANSA_LO_AP_LO_2AWEUA_2cells.xml
${scfc}=           ${CURDIR}/config/FDD_CPRI_LO_AP_LO/scfc_FDD_SANSA_LO_AP_LO_2AWEUA_2cells.xml

*** Test Cases ***
CB008009-A_DL_Throughput_Distribution_counters_linear_for_PMQAP_profile_SA

    [Setup]  Prepare test environment

    Wait for next full pm interval
    Register UE  UE_ID=1  CELL_ID=1
    Establish PDU session  UE_ID=1
    Start throughput on single ue  tput_type=SA_DL  ue=UE1  tput=30m   duration=10
    Start throughput on single ue  tput_type=SA_DL  ue=UE1  tput=75m   duration=10
    Start throughput on single ue  tput_type=SA_DL  ue=UE1  tput=125m  duration=10
    Start throughput on single ue  tput_type=SA_DL  ue=UE1  tput=175m  duration=10
    Start throughput on single ue  tput_type=SA_DL  ue=UE1  tput=230m  duration=10
    ${pm_counters}=  Wait for next pm interval and get counters
    Verify Last Counters In File
    ...    M55352C03001    8-14    DL_PDCP_UE_TPUT_BIN1_PMQAP
    ...    M55352C03002    8-14    DL_PDCP_UE_TPUT_BIN2_PMQAP
    ...    M55352C03003    8-14    DL_PDCP_UE_TPUT_BIN3_PMQAP
    ...    M55352C03004    8-14    DL_PDCP_UE_TPUT_BIN4_PMQAP
    ...    M55352C03005    8-14    DL_PDCP_UE_TPUT_BIN5_PMQAP
    ...    M55352C03006    0       DL_PDCP_UE_TPUT_BIN6_PMQAP
    ...    M55352C03007    0       DL_PDCP_UE_TPUT_BIN7_PMQAP
    ...    M55352C03008    0       DL_PDCP_UE_TPUT_BIN8_PMQAP
    ...    M55352C03009    0       DL_PDCP_UE_TPUT_BIN9_PMQAP
    ...    M55352C03010    0       DL_PDCP_UE_TPUT_BIN10_PMQAP
    ...    M55352C03011    0       DL_PDCP_UE_TPUT_BIN11_PMQAP
    ...    M55352C03012    0       DL_PDCP_UE_TPUT_BIN12_PMQAP
    ...    M55352C03013    0       DL_PDCP_UE_TPUT_BIN13_PMQAP
    ...    M55352C03014    0       DL_PDCP_UE_TPUT_BIN14_PMQAP
    ...    M55352C03015    0       DL_PDCP_UE_TPUT_BIN15_PMQAP
    ...    M55352C03016    0       DL_PDCP_UE_TPUT_BIN16_PMQAP
    ...    M55352C03017    0       DL_PDCP_UE_TPUT_BIN17_PMQAP
    ...    M55352C03018    0       DL_PDCP_UE_TPUT_BIN18_PMQAP
    ...    M55352C03019    0       DL_PDCP_UE_TPUT_BIN19_PMQAP
    ...    M55352C03020    0       DL_PDCP_UE_TPUT_BIN20_PMQAP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}

    Register 3 additional UEs and establish PDUs sessions
    Start throughput on three ues  tput_type=SA_DL  tput1=30m  tput2=75m  tput3=75m  duration=10
    ${pm_counters2}=  Wait for next pm interval and get counters
    Verify Last Counters In File
    ...    M55352C03001    8-14     DL_PDCP_UE_TPUT_BIN1_PMQAP
    ...    M55352C03002    16-26    DL_PDCP_UE_TPUT_BIN2_PMQAP
    ...    M55352C03003    0        DL_PDCP_UE_TPUT_BIN3_PMQAP
    ...    M55352C03004    0        DL_PDCP_UE_TPUT_BIN4_PMQAP
    ...    M55352C03005    0        DL_PDCP_UE_TPUT_BIN5_PMQAP
    ...    M55352C03006    0        DL_PDCP_UE_TPUT_BIN6_PMQAP
    ...    M55352C03007    0        DL_PDCP_UE_TPUT_BIN7_PMQAP
    ...    M55352C03008    0        DL_PDCP_UE_TPUT_BIN8_PMQAP
    ...    M55352C03009    0        DL_PDCP_UE_TPUT_BIN9_PMQAP
    ...    M55352C03010    0        DL_PDCP_UE_TPUT_BIN10_PMQAP
    ...    M55352C03011    0        DL_PDCP_UE_TPUT_BIN11_PMQAP
    ...    M55352C03012    0        DL_PDCP_UE_TPUT_BIN12_PMQAP
    ...    M55352C03013    0        DL_PDCP_UE_TPUT_BIN13_PMQAP
    ...    M55352C03014    0        DL_PDCP_UE_TPUT_BIN14_PMQAP
    ...    M55352C03015    0        DL_PDCP_UE_TPUT_BIN15_PMQAP
    ...    M55352C03016    0        DL_PDCP_UE_TPUT_BIN16_PMQAP
    ...    M55352C03017    0        DL_PDCP_UE_TPUT_BIN17_PMQAP
    ...    M55352C03018    0        DL_PDCP_UE_TPUT_BIN18_PMQAP
    ...    M55352C03019    0        DL_PDCP_UE_TPUT_BIN19_PMQAP
    ...    M55352C03020    0        DL_PDCP_UE_TPUT_BIN20_PMQAP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters2}

    [Teardown]    Deregister UEs and clear up test environment

*** Keywords ***
Prepare test environment
    Configure SA PMQAP Profiles

