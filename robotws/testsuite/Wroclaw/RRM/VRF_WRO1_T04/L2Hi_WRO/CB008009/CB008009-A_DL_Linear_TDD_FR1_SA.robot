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
${lua_cfg_file}=   ${CURDIR}/config/basic_setup_TDD_FR1.cfg

*** Test Cases ***
CB008009-A_DL_Throughput_Distribution_counters_linear_for_NON_PMQAP_profile_SA

    [Setup]  Prepare test environment

    Wait for next full pm interval
    Register UE  UE_ID=1  CELL_ID=1
    Establish PDU session  UE_ID=1
    Start throughput on single ue  tput_type=SA_DL  ue=UE1  tput=30m   duration=10
    Start throughput on single ue  tput_type=SA_DL  ue=UE1  tput=75m   duration=10
    Start throughput on single ue  tput_type=SA_DL  ue=UE1  tput=125m  duration=10
    Start throughput on single ue  tput_type=SA_DL  ue=UE1  tput=175m  duration=10
    Start throughput on single ue  tput_type=SA_DL  ue=UE1  tput=225m  duration=10
    ${pm_counters}=  Wait for next pm interval and get counters
    Verify Last Counters In File
    ...    M55350C20002    8-14      DL_PDCP_UE_TPUT_BIN1
    ...    M55350C20003    8-14      DL_PDCP_UE_TPUT_BIN2
    ...    M55350C20004    8-14      DL_PDCP_UE_TPUT_BIN3
    ...    M55350C20005    8-14      DL_PDCP_UE_TPUT_BIN4
    ...    M55350C20006    8-14      DL_PDCP_UE_TPUT_BIN5
    ...    M55350C20007    0         DL_PDCP_UE_TPUT_BIN6
    ...    M55350C20008    0         DL_PDCP_UE_TPUT_BIN7
    ...    M55350C20009    0         DL_PDCP_UE_TPUT_BIN8
    ...    M55350C20010    0         DL_PDCP_UE_TPUT_BIN9
    ...    M55350C20011    0         DL_PDCP_UE_TPUT_BIN10
    ...    M55350C20012    0         DL_PDCP_UE_TPUT_BIN11
    ...    M55350C20013    0         DL_PDCP_UE_TPUT_BIN12
    ...    M55350C20014    0         DL_PDCP_UE_TPUT_BIN13
    ...    M55350C20015    0         DL_PDCP_UE_TPUT_BIN14
    ...    M55350C20016    0         DL_PDCP_UE_TPUT_BIN15
    ...    M55350C20017    0         DL_PDCP_UE_TPUT_BIN16
    ...    M55350C20018    0         DL_PDCP_UE_TPUT_BIN17
    ...    M55350C20019    0         DL_PDCP_UE_TPUT_BIN18
    ...    M55350C20020    0         DL_PDCP_UE_TPUT_BIN19
    ...    M55350C20021    0         DL_PDCP_UE_TPUT_BIN20
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}

    Register 3 additional UEs and establish PDUs sessions
    Start throughput on three ues  tput_type=SA_DL  tput1=30m   tput2=75m   tput3=125m  duration=10
    ${pm_counters2}=  Wait for next pm interval and get counters
    Verify Last Counters In File
    ...    M55350C20002    8-14      DL_PDCP_UE_TPUT_BIN1
    ...    M55350C20003    8-14      DL_PDCP_UE_TPUT_BIN2
    ...    M55350C20004    8-14      DL_PDCP_UE_TPUT_BIN3
    ...    M55350C20005    0         DL_PDCP_UE_TPUT_BIN4
    ...    M55350C20006    0         DL_PDCP_UE_TPUT_BIN5
    ...    M55350C20007    0         DL_PDCP_UE_TPUT_BIN6
    ...    M55350C20008    0         DL_PDCP_UE_TPUT_BIN7
    ...    M55350C20009    0         DL_PDCP_UE_TPUT_BIN8
    ...    M55350C20010    0         DL_PDCP_UE_TPUT_BIN9
    ...    M55350C20011    0         DL_PDCP_UE_TPUT_BIN10
    ...    M55350C20012    0         DL_PDCP_UE_TPUT_BIN11
    ...    M55350C20013    0         DL_PDCP_UE_TPUT_BIN12
    ...    M55350C20014    0         DL_PDCP_UE_TPUT_BIN13
    ...    M55350C20015    0         DL_PDCP_UE_TPUT_BIN14
    ...    M55350C20016    0         DL_PDCP_UE_TPUT_BIN15
    ...    M55350C20017    0         DL_PDCP_UE_TPUT_BIN16
    ...    M55350C20018    0         DL_PDCP_UE_TPUT_BIN17
    ...    M55350C20019    0         DL_PDCP_UE_TPUT_BIN18
    ...    M55350C20020    0         DL_PDCP_UE_TPUT_BIN19
    ...    M55350C20021    0         DL_PDCP_UE_TPUT_BIN20
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters2}

    [Teardown]    Deregister UEs and clear up test environment

*** Keywords ***
Prepare test environment
    Set feature flag NRBTS-1/thpHistScale to linear

