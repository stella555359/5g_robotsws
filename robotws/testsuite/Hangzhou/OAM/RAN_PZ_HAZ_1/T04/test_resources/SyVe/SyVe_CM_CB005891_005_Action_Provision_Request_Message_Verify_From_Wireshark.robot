*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${NEED_TO_CHECK_LTE_RAT_STATUS}    True

*** Keywords ***
SyVe_CM_CB005891_005_Action_Provision_Request_Message_Verify_From_Wireshark
    [Documentation]
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    New case for RAN_SyVe_CB005891_005_CM_Action provision request message verify from wireshark
    ...    This case is to verify provision request message content via wireshark logs
    ...
    ...    The main steps performed for the test are:
    ...    - Check initial BTS state
    ...    - Check initial alarms status from WebEM
    ...    - Check initial alarms status from Netact
    ...    - Upload configuration status
    ...    - Trigger NR RAT Reset Action Provision And Check SBTS Behavior
    ...    - Check Wireshark Messages As Expected
    ...    - Check final alarms status from WebEM
    ...    - Check final alarms status from Netact
    ...    - Check final BTS state
    ...    - Check final number and state of Cells and RMs
    ...
    ...    Pass criteria: Provision request success and message is correct from wireshark
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 27.04.2023 - New case
    ...    - 06.12.2023 - Updated by Kang Lixin - update wireshark collection logic
    ...    - 29.05.2024 - Modified by Kang Lixin -  operation result content change
    Set Tags    SyVe    AUTHOR-lixin.kang@nokia.com    PHASE-CRT    OWNER-I_NSB_MN_RAN_PZ1_HAZ_OPER1_VRF@internal.nsn.com
    Step 1: Check initial BTS state
    Step 2: Check initial alarms status from WebEM
    Step 3: Check initial alarms status from Netact
    Step 4: Upload configuration status
    Step 5: Trigger NR RAT Reset Action Provision And Check SBTS Behavior
    Step 6: Check Wireshark Messages As Expected
    Step 7: Check final alarms status from WebEM
    Step 8: Check final alarms status from Netact
    Step 9: Check final BTS state
    Step 10: Check final number and state of Cells and RMs

Step ${index}: Check ${when} BTS state
    [Documentation]    BTS each RAT procedural state is checked to be OnAir (at least one cell operational)
    ...    BTS State is checked according to ute_admin get parameters for all BTS. The JSON returned contains informations
    ...    such as btsName, btsId, btsProceduralstate
    ...    KW checks if BTS State is onAir. If not, it will fail with received state.
    Log    Step ${index}: Check ${when} BTS state    console=True
    Wait Until Keyword Succeeds    3 min    10 sec    Check BTS RAT Procedural State
    Admin Check Overall BTS Procedural State TAF

Step ${index}: Check ${when} alarms status from WebEM
    Log    Step ${index}: Check ${when} alarms status from WebEM    console=True
    Get and Check Alarms SyVe    source=Bts    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    critical_alarms=${CRITICAL_ALARMS}

Step ${index}: Check ${when} alarms status from Netact
    Log    Step ${index}: Check ${when} alarms status from Netact    console=True
    Get and Check Alarms SyVe    source=Netact    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    critical_alarms=${CRITICAL_ALARMS}    dist_name=${MRBTS_DN}

Step ${index}: Upload configuration status
    [Documentation]    Uploads configuration data from the network is checked
    Log    Step ${index}: Upload configuration status    console=True
    NetAct CM Upload    dist_names=${MRBTS_DN}

Step ${index}: Trigger NR RAT Reset Action Provision And Check SBTS Behavior
    Log    Step ${index}: Trigger NR RAT Reset Action Provision And Check SBTS Behavior    console=True
    ${dic_bts_infor}    coam.Get Bts Info
    ${nrBtsId}    Pop From Dictionary    ${dic_bts_infor}    nrBtsId
    ${mrbts_id}    Should Match Regexp    ${MRBTS_DN}    \\d+
    Start TCPDump On SBTS Common
    SSHLibrary.Open Connection    ${NETACT['was_host']}
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    Log    Provision Plan    console=True
    ${cmd}    Set Variable   racclimx.sh -op Reset_NE -DN MRBTS-${mrbts_id}/NRBTS-${nrBtsId} -v
    SSHLibrary.Start Command    ${cmd}
    Check Reset NR Behavior
    Sleep    10s    #Time for the delay of CCN for parameter changed.
    Stop TCPDump On SBTS Common
    [Teardown]    Run Keyword And Ignore Error    SSHLibrary.Close Connection

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]    Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log    Step ${index}: Check final number and state of Cells and RMs    console=True
    Final Checks SyVe

Step ${index}: Check Wireshark Messages As Expected
    Log    Step ${index}: Check Wireshark Messages As Expected    console=True
    ${file_content}    Save TCPDump File On Local And Get Content
    #check Provisionrequest message sent from NMS to SBTS
    Should Contain    ${file_content}    </provision>
    #check attachmentProperties element and some sub elements included in provision request message
    ${tmp_req_content}    Fetch From Left    ${file_content}    </provision>
    ${tmp_provision_req_content}    Fetch From Right    ${tmp_req_content}    <soapenv:Body>
    Should Contain    ${tmp_provision_req_content}    </attachmentProperties>
    ${tmp_str}    Set Variable    ${tmp_provision_req_content.replace(' ','').replace('\n','')}
    ${tmp_str}    Fetch From Right    ${tmp_str}    <attachmentProperties>
    ${tmp_str}    Fetch From Left    ${tmp_str}    </attachmentProperties>
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${content_to_check}    L_XML.Parse xml     <attachmentProperties>${tmp_str}</attachmentProperties>
    ${compression_value}    L_XML.Get Element Text    ${content_to_check}    /attachmentProperties/compression
    Should Be Equal As Strings    ${compression_value}    none
    ${contentType_value}    L_XML.Get Element Text    ${content_to_check}    /attachmentProperties/contentType
    Should Be Equal As Strings    ${contentType_value}    ocos
    ${algorithm_value}    L_XML.Get Element Text    ${content_to_check}    /attachmentProperties/checksum/algorithm
    Should Be Equal As Strings    ${algorithm_value}    sha1
    ${hash_value}    L_XML.Get Element Text    ${content_to_check}    /attachmentProperties/checksum/hash
    Should Match Regexp    ${hash_value}    \\w+
    #check primaryDocument element shall not be used
    Should Not Contain    ${file_content}    <primaryDocument
    #check SBTS sent provisionresponse to NMS when it receives provision request
    ${tmp_req_content}    Fetch From Left    ${file_content}    <provision
    ${tcp_header}    Fetch From Right     ${tmp_req_content}    Transmission Control Protocol
    ${next_seq_num}    Get Regexp Matches    ${tcp_header}     Next Sequence Number: (\\d+)    1
    ${next_seq}    Fetch From Right    ${file_content}    Acknowledgment Number: ${next_seq_num[0]}
    ${tmp_file_content}    Fetch From Left     ${next_seq}    Arrival Time
    Should Contain    ${tmp_file_content}    provisionResponse>
    Should Contain    ${file_content}     Requested actions completed

Check Reset ${techno} Behavior
    Log    Check Reset ${techno} Behavior    console=True
    FOR    ${index}    IN RANGE    0    900
        ${result}    ${rat_status}    Run Keyword And Ignore Error    Check ${techno} RAT status
        Check Other RAT Status Enabled
        ${reset}    Run Keyword And Return Status    Should Be Equal As Strings    ${rat_status}    ALL_DISABLED
        Exit For Loop If    ${reset}
    END
    ${result_Activate}    SSHLibrary.Read Command Output
    Should Contain    ${result_Activate}    Reset plan provision finished
    Should Contain    ${result_Activate}    Reset was successful for 1 objects
    Should Contain    ${result_Activate}    gracefulCellShutdown=true
    Should Be Equal As Strings    ${reset}    True
    FOR    ${index}    IN RANGE    0    200
        ${cells_Status}    Run Keyword And Return Status    coam.Assert Every    NRCEL    operationalState=${_Enabled_}
        Check Other RAT Status Enabled
        Exit For Loop If    ${cells_Status}
    END

Check ${rat_techo} RAT status
    ${rat}    String.Convert To Lower Case    ${rat_techo}
    ${btsinfo_list}    coam.Get Bts Info
    ${rat_status}    set variable    ${btsinfo_list['ratState']['${rat}']}
    [Return]    ${rat_status}

Check Other RAT Status Enabled
    ${gsm_state}    Run Keyword If    ${GSM_cell_ids}    Check GSM RAT status
    ${lte_state}    Run Keyword If    ${LTE_cell_ids} and ${NEED_TO_CHECK_LTE_RAT_STATUS}    Check LTE RAT status
    ${wcdma_state}    Run Keyword If    ${WCDMA_cell_ids}    Check WCDMA RAT status
    Run Keyword If    ${GSM_cell_ids}    Should Be Equal As Strings    ${gsm_state}    ALL_ENABLED
    Run Keyword If    ${LTE_cell_ids} and ${NEED_TO_CHECK_LTE_RAT_STATUS}    Should Be Equal As Strings    ${lte_state}    ALL_ENABLED
    Run Keyword If    ${WCDMA_cell_ids}   Should Be Equal As Strings    ${wcdma_state}    ALL_ENABLED

Particular Teardown
    Common Test Teardown

TC Setup
    Common Test Setup

TC Teardown
    Particular Teardown