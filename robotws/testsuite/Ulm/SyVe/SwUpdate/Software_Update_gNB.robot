*** Settings ***
Documentation    Suite description
Library    OperatingSystem
Library    sw_update_kw.py

Resource   ../resources/syve_testline.robot
Resource   ../../resources/Common/testline.robot
Resource   ../../resources/Common/log_collection.robot
Resource   ../../resources/Common/btslog.robot
Resource   ../../resources/Common/snapshot.robot
Resource   ../../resources/Common/commissioning.robot
Resource   ../../resources/Common/connect.robot
Resource   ../../resources/Common/gnb.robot
Resource   ../resources/installation.robot
Resource   ../resources/enb.robot
Resource    resources/Software_upgrade-keywords.robot
Resource    resources/tti_dec.robot

*** Variables ***
${TARGET_SW_VERSION_ENB}    None
${ENB_SW_UPDATE_NODES}      None
${TARGET_SW_VERSION_GNB}    None
${GNB_SW_UPDATE_NODES}      None


*** Test Cases ***
Update_eNB_gNB_Software
    [Documentation]    Automatic SW update for eNBs and gNBs
    [Tags]             sw_update   sw_update_gnb
    [Setup]            testline.Create Test Suite Result Base Directory

    ${TARGET_SW_VERSION}   OperatingSystem.Get Environment Variable   TARGET_SW_VERSION   ${EMPTY}
    ${TARGET_SW_VERSION_GNB}   Set Variable If   '${TARGET_SW_VERSION}' != ''   ${TARGET_SW_VERSION}   ${TARGET_SW_VERSION_GNB}
    Set Suite Variable   ${TARGET_SW_VERSION_GNB}

    ${SCF_FILE_NAME}    OperatingSystem.Get Environment Variable    SCF_FILE_NAME    ${EMPTY}
    IF    '${SCF_FILE_NAME}' != ''    Set Suite Variable   ${SCF_FILE_NAME}

    ${SW_UPDATE_NODES}   OperatingSystem.Get Environment Variable   SW_UPDATE_NODES   ${EMPTY}
    ${GNB_SW_UPDATE_NODES}   Set Variable If   '${SW_UPDATE_NODES}' != ''   ${SW_UPDATE_NODES}   ${GNB_SW_UPDATE_NODES}
    Set Suite Variable   ${GNB_SW_UPDATE_NODES}

    @{GNB_SW_UPDATE_NODE_LIST}    sw_update_kw.Get Node Ids From Node Names   ${GNB_SW_UPDATE_NODES}
    Set Suite Variable    @{GNB_SW_UPDATE_NODE_LIST}

    ${with_onair_state_check}    Run Keyword And Return Status    Should Not Contain Any    ${SCF_FILE_NAME}    _AP    _CUS

    FOR   ${gnb_id}   IN    @{GNB_SW_UPDATE_NODE_LIST}
        syve_testline.Start Syslog Collection For CCRTS    node_id=${gnb_id}    node_type=gnb

        Software_upgrade-keywords.Log Source And Target Software Versions For All GNBs That Shall Be Updated

        Software_upgrade-keywords.Perform GNB SW Update    gnb_id=${gnb_id}    with_onair_state_check=${with_onair_state_check}

        Log To Console    \ngNB-${gnb_id} Sw updated successfully
    END
    [Teardown]    Stop Logs For GNB

*** Keywords ***
Stop Logs For GNB
    FOR   ${g_id}   IN    @{GNB_SW_UPDATE_NODE_LIST}
        Collect Snapshot For Nodes In CCRTs    node_id=${g_id}    node_type=gnb
        Stop Syslog Collection For CCRTS       node_id=${g_id}    node_type=gnb
    END
