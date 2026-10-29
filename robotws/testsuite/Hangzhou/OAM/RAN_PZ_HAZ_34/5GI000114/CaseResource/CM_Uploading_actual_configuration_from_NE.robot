*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com

Resource   ../Resource/NetAct_Fast_Pass_common.robot

*** Variables ***
${WEB_DOWNLOAD_DIR}   ${OUTPUT_DIR}

*** Keyword ***
CM_Uploading_actual_configuration_from_NE
#    Open Netact Start Page    ${start_page}    omc    omc    ${true}
    ${REMOTE_PORT_OPERATIONS}   Open Application   app_name=CM Operations Manager
    Set Suite Variable    ${REMOTE_PORT_OPERATIONS}
    Wait Until Keyword Succeeds   3 times   10s   swing.Select From Main Menu And Wait   menuPath=Upload|New Upload...
    Sleep   3s
    Wait Until Keyword Succeeds   3 times   10s   swing.Select Window   identifier=Upload
    Sleep   3s
    swing.Select Tab   tabIdentifier=BSC
    FOR   ${i}    IN RANGE    8
       swing.Send Keyboard Event   keyCode=VK_RIGHT
    END
    swing.Select Tab   tabIdentifier=5G/LTE/SRAN
    Sleep   5s
    Wait Until Keyword Succeeds   3 times   10s   swing.Click On Component   identifier=SelectAllButton
    Wait Until Keyword Succeeds   3 times   10s   swing.Click On Component   identifier=DeselectAllButton
    Wait Until Keyword Succeeds   3 times   10s   swing.Expand All Tree Nodes   identifier=0
    ${nodes}   Search All tree nodes   tree_index=0
    ${bts_index}   Search dedicated node index   nodes=${nodes}   node_name=PLMN-PLMN/MRBTS-${BTS_ID}
    swing.Click On Tree Node   0   ${bts_index}   \#0
    Sleep   3s
    Wait Until Keyword Succeeds   3 times   10s   swing.Select Window   identifier=Upload
    Wait Until Keyword Succeeds   3 times   10s   swing.Push Button   identifier=Start
    Sleep   3s
    swing.Select Dialog   identifier=Confirmation
    Wait Until Keyword Succeeds   3 times   10s   swing.Push Button   identifier=Yes
    Sleep   15s
    ${CM_finished}   Run Keyword And Return Status   Wait Until Keyword Succeeds   3 times   10s
    ...   swing.Select Window   identifier=Upload: Finished
#    Run Keyword Unless  ${CM_finished}  Wait Until Keyword Succeeds      3 times   10s   swing.Select Window   Upload: Failed
    Sleep   5s
    Wait Until Keyword Succeeds   3 times   10s   swing.Push Button   identifier=Close
    Sleep   5s
    #Close Java app   app_name=cm3apps
    [Return]   ${CM_finished}

Search All tree nodes
    [Arguments]   ${tree_index}
    ${nodeCount}=    swing.Get Tree Node Count   identifier=${tree_index}
    @{nodes}   Create List
    FOR    ${index}    IN RANGE    ${nodeCount}
       ${node_name}=   swing.Get Tree Node Label   identifier=${tree_index}   nodeIndex=${index}
       Append To List   ${nodes}   ${node_name}
    END
    [Return]   ${nodes}

Search dedicated node index
    [Arguments]   ${nodes}   ${node_name}
    FOR   ${node}   IN   @{nodes}
       ${index}   Run Keyword If   ${node.count("${node_name}")} > 0   Get Index from List   ${nodes}   ${node}
       Exit For Loop If   ${node.count("${node_name}")} > 0
    END
    [Return]   ${index}

Case Setup: CM_Uploading_actual_configuration_from_NE
    Login NetAct Start Page and Remove File

Case Teardown: CM_Uploading_actual_configuration_from_NE
    Run Keyword And Ignore Error   Close Java Application by Remote Port   remote_port=${REMOTE_PORT_OPERATIONS}
    Run Keyword And Ignore Error   Close All Java Application Forced
    Run Keyword And Ignore Error   selenium_netact.Logout
    Run Keyword And Ignore Error   selenium_coam.Logout
    Run Keyword And Ignore Error   Common Case Teardown
