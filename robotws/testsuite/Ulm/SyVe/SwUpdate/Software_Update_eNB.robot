*** Settings ***
Documentation    Suite description
Library    OperatingSystem
Library    sw_update_kw.py

Resource   ../../resources/Common/testline.robot
Resource   ../../resources/Common/log_collection.robot
Resource   ../../resources/Common/btslog.robot
Resource   ../../resources/Common/snapshot.robot
Resource   ../../resources/Common/commissioning.robot
Resource   ../../resources/Common/connect.robot
Resource   ../../resources/Common/gnb.robot
Resource   ../resources/syve_testline.robot
Resource   ../resources/installation.robot
Resource   ../resources/enb.robot
Resource    resources/Software_upgrade-keywords.robot

*** Variables ***
${TARGET_SW_VERSION_ENB}    None
${ENB_SW_UPDATE_NODES}      None
${TARGET_SW_VERSION_GNB}    None
${GNB_SW_UPDATE_NODES}      None


*** Test Cases ***
Update_eNB_gNB_Software
    [Documentation]    Automatic SW update for eNBs and gNBs
    [Tags]             sw_update   sw_update_enb
    [Setup]            Test Case Setup ENB Upgrade
    ${TARGET_SW_VERSION}=   OperatingSystem.Get Environment Variable   TARGET_SW_VERSION   ${EMPTY}
    ${TARGET_SW_VERSION_ENB}=   Set Variable If   '${TARGET_SW_VERSION}' != ''   ${TARGET_SW_VERSION}   ${TARGET_SW_VERSION_ENB}
    Set Suite Variable   ${TARGET_SW_VERSION_ENB}

    ${SW_UPDATE_NODES}=   OperatingSystem.Get Environment Variable   SW_UPDATE_NODES   ${EMPTY}
    ${ENB_SW_UPDATE_NODES}=   Set Variable If   '${SW_UPDATE_NODES}' != ''   ${SW_UPDATE_NODES}   ${ENB_SW_UPDATE_NODES}
    Set Suite Variable   ${ENB_SW_UPDATE_NODES}
    @{ENB_SW_UPDATE_NODE_LIST}=    sw_update_kw.Get Node Ids From Node Names   ${ENB_SW_UPDATE_NODES}
    Set Suite Variable    @{ENB_SW_UPDATE_NODE_LIST}

    FOR   ${enb_id}   IN    @{ENB_SW_UPDATE_NODE_LIST}
        Log To Console   ${\n}Running 'Update_eNB_gNB_Software' for node ENB-${enb_id}
        syve_testline.Start Syslog Collection For CCRTS    node_id=${enb_id}    node_type=enb
        Software_upgrade-keywords.Log Source And Target Software Versions For All ENBs That Shall Be Updated
        Software_upgrade-keywords.Perform ENB SW Update    enb_id=${enb_id}
        Log To Console    ${\n}ENB-${enb_id} SW updated successfully
    END
    [Teardown]    Stop Logs For ENB

*** Keywords ***
Test Case Setup ENB Upgrade
    [Documentation]    Keyword for Test case setup.
    ...                Checks if we can skip the whole test to avoid PASS verdict even no upgrade was performed.
    ${SW_UPDATE_NODES}   OperatingSystem.Get Environment Variable   SW_UPDATE_NODES   ${EMPTY}
    ${ENB_SW_UPDATE_NODES}   Set Variable If   '${SW_UPDATE_NODES}' != ''   ${SW_UPDATE_NODES}   ${ENB_SW_UPDATE_NODES}
    Set Suite Variable   ${ENB_SW_UPDATE_NODES}
    ${ENB_SW_UPDATE_NODE_LIST}    sw_update_kw.Get Node Ids From Node Names   ${ENB_SW_UPDATE_NODES}
    Set Suite Variable    ${ENB_SW_UPDATE_NODE_LIST}
    Skip If   not len(${ENB_SW_UPDATE_NODE_LIST})   msg=Skip test, ENB_SW_UPDATE_NODE_LIST is empty!
    testline.Create Test Suite Result Base Directory


Stop Logs For ENB
    FOR   ${e_id}   IN    @{ENB_SW_UPDATE_NODE_LIST}
        syve_testline.Collect Snapshot For Nodes In CCRTs    node_id=${e_id}    node_type=enb
        syve_testline.Stop Syslog Collection For CCRTS       node_id=${e_id}    node_type=enb
    END
