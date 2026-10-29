*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    ../resources/common_variables.robot
Resource    keywords_CB008379.robot
Resource     ../resources/common_configuration.robot
Library     ../resources/common_keywords.py
Library     ../5GC000774_ROHC/keywords_ROHC.py
Documentation
...    author: Marcin Kotula
...    maintainer: Marcin Kotula (marcin.kotula@nokia.com)
...    testline: CLOUD_5G_O_E_AP_LOO
...    release: 22R3

Suite Setup     Run Keywords    Modify Config To 8 Cells
    ...       AND    Enable Syslog Info Level Prints
    ...       AND    Configure VM interfaces For Second Gnb
    ...       AND    Enable Vonr And Rohc
    ...       AND    Enable ActNonVoNRGbrService
    ...       AND    Add Profiles For GBR 5QI ASOE
    ...       AND    Disable Uplane Ciphering
    ...       AND    Prepare Sa Test Environement
    ...       AND    Reach Onair    lua_cfg=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}
    ...       AND    Set Internal Traffic Type To UEs
Suite Teardown    Run Keywords    Check For An Unexpected Alarm
...            AND    Stop Default Processes And Gather Logs And Compress Logs
Test Teardown     Run Keywords    Deregister Ue   ue_id=1
   ...        AND   Sleep    5s   Waiting for deregister
   ...        AND   Send Configuration ID To Scout

*** Test Cases ***
CB008379-F_B2_1_PDCP_discard_GBR_DRB_5QI3_using_18_bit_PDCP_SN
    Prepare Bler Testmode For Bad Rf Condition Target Mcs 3
    Set Discard Timer To 100ms For Gbr
    Attach Ue With Gbr Um 5QI 3
    Start 30Mbps In Dl and Ul For Gbr
    Check Traffic Statistic
    Deteriorate Rf Condition
    Check Pm Counters For Timer Discarding And Pdcp Packet Delay
    Improve Rf Condition
    Check Traffic Statistic

CB008379-F_B2_2_PDCP_discard_GBR_DRB_5QI4_using_18_bit_PDCP_SN
    Prepare Bler Testmode For Bad Rf Condition Target Mcs 3
    Set Discard Timer To 100ms For Gbr
    Attach Ue With Gbr Am 5QI 4
    Start 30Mbps In Dl and Ul For Gbr
    Check Traffic Statistic
    Deteriorate Rf Condition
    Check Pm Counters For Timer Discarding And Pdcp Packet Delay
    Improve Rf Condition
    Check Traffic Statistic