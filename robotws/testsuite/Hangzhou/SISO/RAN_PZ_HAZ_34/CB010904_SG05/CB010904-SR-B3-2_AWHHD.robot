*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown
Test Timeout        120 min

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/cell_addition_deletion_online.robot


Documentation
...    Author: Liu Yue
...    Contact: yue.2.liu@nokia-sbell.com
...    squad group:SG_05
...    Feature CB010904 in 5G24R3 program

Force Tags    5G_RAN_TDD
*** Variables ***

*** Test Cases ***
[1]CB010904-SR-B3-2_AWHHD_Split&ConcurrentMode_SuperCell_Supercell_active_deactive_with_L3call_CB009542-G#1
    [Tags]   1S-1CC-2D2U_SuperCell
    Deactivate NR Supercell
    ${cell_list}    create list    ${1}
    Get UE From Init File and Make call    cell_list=${cell_list}    with_peak=${False}
    Activate NR Supercell
    Get UE From Init File and Make call    cell_list=${cell_list}    with_peak=${True}
*** Keywords ***
Deactivate NR Supercell
    log to console    Deactivate NR Supercell
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    filter_param=Activate super cell    abbr=actSuperCell    new_value=false
    sleep    1s
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2    timeout=15
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-3    timeout=15
    sleep    1s
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-0
    ...    filter_param=Number of transmitted Synchronization Signal Blocks    abbr=numberOfTransmittedSsBlocks    new_value=1 beam
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    filter_param=Number of paging frames in a DRX cycle    abbr=numOfPagingFrames    new_value=halfT
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-1
        ...    filter_param=First PDCCH monitoring occasion of paging occasion     abbr=fPdcchMonOccsnPo
        ...    new_value=${2}
        ...    node_index=${0}
    Activate Parameters
    [Teardown]    Selenium Logout And Close Browser
Activate NR Supercell
    log to console    Activate NR Supercell
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    filter_param=Activate super cell    abbr=actSuperCell    new_value=true
    sleep    1s
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1
        ...    object_class_name=CHANNELGROUP    plan_to_copy_from=CURRENT_BTS_CONF-1
        ...    copy_from=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1
        ...    id_value=${2}    timeout=15
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1
        ...    object_class_name=CHANNELGROUP    plan_to_copy_from=CURRENT_BTS_CONF-1
        ...    copy_from=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1
        ...    id_value=${3}    timeout=15
    sleep    1s
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-0
    ...    filter_param=Number of transmitted Synchronization Signal Blocks    abbr=numberOfTransmittedSsBlocks    new_value=3 beams
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    filter_param=Number of paging frames in a DRX cycle    abbr=numOfPagingFrames    new_value=quaterT
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-1
        ...    filter_param=First PDCCH monitoring occasion of paging occasion     abbr=fPdcchMonOccsnPo
        ...    new_value=${0}
        ...    node_index=${0}
    Activate Parameters
    [Teardown]    Selenium Logout And Close Browser
