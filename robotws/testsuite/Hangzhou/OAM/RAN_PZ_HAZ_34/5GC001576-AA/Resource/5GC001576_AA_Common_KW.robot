*** Settings ***
Documentation     author: Shenrao
...               Group: 5G_PZ_MMW_HZ_3_SG
...               contact: shengrong.rao@nokia-sbell.com

Resource          ../../common/taf_coam.robot
Resource          ../../common/coam_resource.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Library           create_dus_objects.py
Library           5GC001576-AA.py

*** Variables ***
${mrbts_id}    MRBTS-${tl.gnbs[0].instance_id}
${nrbts_id}    NRBTS-${tl.gnbs[0].global_bts_id}
${web_ui}=                   https://[${tl.gnbs[0].cu.oam_ssh_connection_details.addr}]
${Max_loop_number}    5
@{linkspeed_list}      Cpri2    Cpri3    Cpri5    Cpri6    Cpri7
@{linkspeed_list1}      Obsai3Gbps    Obsai6Gbps
${mrbts_instance_id}     ${tl.gnbs[0].instance_id}
${DU_OAM_IP}            ${tl.gnbs[0].dus[0].f1_m_ip_addr}

*** Keywords ***
AdminCli disconnection and Test teardown
    [Documentation]
    ...     Disconnects connection to gNB ADMIN and collect snapshot if any TC failed
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    admin_cli.teardown    connection=COAM
    CI_interface.Common Case Teardown

Case_teardown
    Run Keyword And Ignore Error    csn.send_command     command=rm -rf /home/ute/snapshot/*    connection=ute
    run keyword and ignore error    AdminCli disconnection and Test teardown

unzip snapshot log and check hw files
    [Arguments]    ${local_file_path}
    csn.connect_to    hostname=${host_addr}    username=${host_username}    password=${host_password}    alias=ute
    #csn.execute    command=cp ${snapshot_log} ${SAVE LOG DIRECTORY}    connection=ute
    csn.SendCommand    command=mkdir /home/ute/snapshot    connection=ute
    ${snapshot_extract}    Set Variable    /home/ute/snapshot
    csn.execute    command=unzip -o ${local_file_path} -d ${snapshot_extract}    connection=ute
    sleep     5s
    csn.SendCommand    command=cat /home/ute/snapshot/snapshot_file_list.txt    connection=ute
    ${hwfile}    csn.read output    connection=ute
    Should Not Match Regexp      ${hwfile}    BTS${mrbts_instance_id}_11.*?
    Should Not Match Regexp      ${hwfile}    BTS${mrbts_instance_id}_13.*?
    ${matched_content0}    Should Match Regexp      ${hwfile}    BTS${mrbts_instance_id}_10.*?
    ${matched_content1}    Should Match Regexp      ${hwfile}    BTS${mrbts_instance_id}_12.*?
    should not be empty    ${matched_content0}
    should not be empty    ${matched_content1}
    csn.send_command     command=rm -rf /home/ute/snapshot/*    connection=ute
    #csn.Disconnect    connection=ute

COAM Check GNB_DU cell on air
    [Documentation]  Author: Ding Binmei
    ...              Description: Check if GNB is in cell on air status
    [Arguments]    ${connection}=COAM
    wait until keyword succeeds     2s    1s
    ...      admin_cli.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
    ...      username=Nemuadmin
    ...      password=nemuuser
    ...      name=${connection}
    COAM Check All Cells Onair

Connect to DU via ssl
    [Arguments]  ${connection}=${connection}    ${bts_host}=${DU_OAM_IP}
    ...    ${username}=${WEBUI_USER}
    ...    ${password}=${WEBUI_PASSWORD}
    coam.connect_to    bts_host=${bts_host}    bts_port=${443}    username=${username}    password=${password}
    ...   name=${connection}

Config CABLINKs parameter
    log to console     Config CABLINKs parameter
    Connect to DU via ssl
    Run Keyword And Continue On Failure    ADD One CABLINK object

Modify CABLINKs parameter and check pdl result
    log to console     Modify CABLINKs parameter and check pdl result
    #Modify CABLINK linkspeed and check pdl result

Delete One CABLINK object
    [Arguments]    ${connection}=COAM
    ${mandatory_params}   params to create new cablink obj      mrbtsId=${mrbtsId}    rmodid=${Rmod_ID_05}
    ${distname}    Set Variable    ${mrbtsId}/EQM-1/HWTOP-1/CABLINK-${CABLINK_ID_05}
    ${recommission_result}=    admin_cli.perform_object_recommissioning    dist_name=${mrbtsId}/EQM-1/HWTOP-1/CABLINK-${CABLINK_ID_05}
    ...                                         parameter=${mandatory_params}
    ...                                         operation=delete
    ...                                         skip_parameter_relation_errors=${True}
    ...                                         should_activate=${True}
    ...                                         connection=${connection}
    ${activate_result}=    Get From Dictionary    ${recommission_result['commissioningResult']['activationResult']['resultNode']['parameters']}
    ...                                         result
    [Return]    ${activate_result}

ADD One CABLINK object
    ${mandatory_params}   params to create new cablink obj      mrbtsId=${mrbtsId}    rmodid=${Rmod_ID_05}
    ${NEW_CABLINK_ID}    evaluate    random.randint(1,65)    random
    Set Suite Variable        ${CABLINK_ID_05}    ${NEW_CABLINK_ID}
    ${distname}    Set Variable    ${mrbtsId}/EQM-1/HWTOP-1/CABLINK-${CABLINK_ID_05}
    ${recommission_result}=    admin_cli.perform_object_recommissioning    dist_name=${mrbtsId}/EQM-1/HWTOP-1/CABLINK-${CABLINK_ID_05}
    ...                                         parameter=${mandatory_params}
    ...                                         operation=create
    ...                                         skip_parameter_relation_errors=${True}
    ...                                         should_activate=${True}
    ...                                         connection=${connection}
    ${activate_result}=    Get From Dictionary    ${recommission_result['commissioningResult']['activationResult']['resultNode']['parameters']}
    ...                                         result
    [Return]    ${activate_result}

Get Cablink distname of RF
    [Documentation]
    ...  gets all CABLINK-R* objects and:
    ...  1) checks if CABLINK is backplane or optical link
    ...  2) for optical links checks the status of link -
    ...  availabilityStatus: Online means link is detected between RMOD and BBMOD
    [Arguments]    ${status}    ${CABLINK_STATUSES}    ${CABLINK_STATUSES_A}
    ${len}=    Get Length    ${CABLINK_STATUSES}

    FOR    ${index}    IN RANGE    ${len}
        ${response}=    Get From Dictionary    ${CABLINK_STATUSES[${index}]['parameters']['stateInfo']}    ${status}
        Run Keyword If    '${response}'=='None'        Get CABLINK information    CABLINK_STATUSES=${CABLINK_STATUSES}
    ...    index=${index}
    END

    @{distname_L}   Create List
    ${len_A}=    Get Length    ${CABLINK_STATUSES_A}
    @{distname_Cablink_RF}   Create List
    FOR    ${index}    IN RANGE    ${len_A}
        ${distname1}=    Get From Dictionary    ${CABLINK_STATUSES_A[${index}]}     distName
        ${Cablink_ID}=    Fetch From Right    ${distname1}    marker=CABLINK_A-
        Append To List   ${distname_L}   ${mrbts_id}/EQM-1/HWTOP-1/CABLINK-${Cablink_ID}
        ${response}=    Get From Dictionary    ${CABLINK_STATUSES_A[${index}]['parameters']}    firstEndpointLabel
        Run Keyword If    '${response}'!='BACKPLANE'    Append To List   ${distname_Cablink_RF}   ${mrbts_id}/EQM-1/HWTOP-1/CABLINK-${Cablink_ID}
    END
    Set Suite Variable    @{distname_L}
    Set Suite Variable    @{distname_Cablink_RF}

Get CABLINK information
    [Arguments]    ${CABLINK_STATUSES}    ${index}
    ${firstEndpointLabel}=     Get From Dictionary    ${CABLINK_STATUSES[${index}]['parameters']}     firstEndpointLabel
    ${firstEndpointPortId}=     Get From Dictionary    ${CABLINK_STATUSES[${index}]['parameters']}     firstEndpointPortId
    ${secondEndpointLabel}=     Get From Dictionary    ${CABLINK_STATUSES[${index}]['parameters']}     secondEndpointLabel
    ${secondEndpointPortId}=     Get From Dictionary    ${CABLINK_STATUSES[${index}]['parameters']}     secondEndpointPortId
     Should Be Equal    ${firstEndpointLabel}    BACKPLANE
     Should Be True    ${firstEndpointPortId}==1
     Should Be Equal    ${secondEndpointLabel}    BACKPLANE
     Should Be True    ${secondEndpointPortId}==1




Get CABLINK Detection Results
     ${CABLINK_STATUSES}=    admin_cli.get_managed_objects    class_name=CABLINK_R  connection=COAM
     ${CABLINK_STATUSES_A}=    admin_cli.get_managed_objects    class_name=CABLINK_A  connection=COAM
     Set Suite Variable    ${CABLINK_STATUSES_A}
     Set Suite Variable    ${CABLINK_STATUSES}


Get RMOD Detection Results
    ${RMODs}=    admin_cli.get_frm    connection=COAM
    #${RMODs}=    Get From Dictionary    ${FRM_detection_response}      rmod
    ${RF_len}=    Get Length      ${RMODs}
    #Set Suite Variable    ${RF_len}
    @{distname_RF}   Create List
    FOR    ${index}    IN RANGE    ${RF_len}
        ${distname1}=    Get From Dictionary    ${RMODs[${index}]['id']}    configuration
        ${distname2}     Convert To String    ${distname1}
        Append To List   ${distname_RF}   ${distname2}
    END
    Set Suite Variable    @{distname_RF}
    [Return]    @{distname_RF}

Create RMOD Object
    [Documentation]     to create RMOD object with required parameters
    [Arguments]    ${Max_loop_number}    ${distname_RF}
    ${mandatory_params}   params to create rmod obj
    Set Suite Variable    ${mandatory_params}
    #Set Suite Variable   ${Max_loop_number}
    FOR    ${index}    IN RANGE    ${Max_loop_number}
         ${activate_result}    ${Rmod_ID}   ADD RMOD object    Max_loop_number=${Max_loop_number}   distname_RF=${distname_RF}
         Exit For Loop If  '${activate_result}'=='Success'
    END
    [Return]    ${Rmod_ID}

Create RMOD_ASOD Object
    [Documentation]     to create RMOD_ASOD object with required parameters
    [Arguments]    ${Max_loop_number}    ${distname_RF}
    ${mandatory_params}   params to create rmod_ASOD obj
    Set Suite Variable    ${mandatory_params}
    Set Suite Variable   ${Max_loop_number}
    FOR    ${index}    IN RANGE    ${Max_loop_number}
         ${activate_result}    ${Rmod_ID}   ADD RMOD object    Max_loop_number=${Max_loop_number}   distname_RF=${distname_RF}
         Exit For Loop If  '${activate_result}'=='Success'
    END
    [Return]    ${Rmod_ID}

ADD RMOD object
    [Arguments]    ${Max_loop_number}    ${distname_RF}
    FOR    ${index}    IN RANGE    ${Max_loop_number}
        ${Rmod_ID}    evaluate    random.randint(1,24)    random
        Set Suite Variable    ${Rmod_ID}
        ${distname1}    Set Variable    ${mrbtsId}/EQM-1/APEQM-1/RMOD-${Rmod_ID}
        Run Keyword If  '${distname1}' not in @{distname_RF}    Exit for loop
    END
    ${recommission_result1}=    admin_cli.perform_object_recommissioning    dist_name=${mrbtsId}/EQM-1/APEQM-1/RMOD-${Rmod_ID}
    ...                                         parameter=${mandatory_params}
    ...                                         operation=create
    ...                                         skip_parameter_relation_errors=${True}
    ...                                         should_activate=${True}
    ...                                         connection=COAM
    ${activate_result}=    Get From Dictionary    ${recommission_result1['commissioningResult']['activationResult']['resultNode']['parameters']}
    ...                                         result
    [Return]    ${activate_result}    ${Rmod_ID}

ADD CABLINK object
    [Arguments]    ${Rmod_ID}    ${distname_L}
    ${mandatory_params}   params to create cablink1 obj      mrbtsId=${mrbtsId}    rmodid=${Rmod_ID}
    FOR    ${index}    IN RANGE    ${Max_loop_number}
        ${CABLINK_ID}    evaluate    random.randint(1,65)    random
        Set Suite Variable        ${CABLINK_ID}
        ${distname1}    Set Variable    ${mrbtsId}/EQM-1/HWTOP-1/CABLINK-${CABLINK_ID}
        Run Keyword If  '${distname1}' not in @{distname_L}    Exit for loop
    END
    ${recommission_result1}=    admin_cli.perform_object_recommissioning    dist_name=${mrbtsId}/EQM-1/HWTOP-1/CABLINK-${CABLINK_ID}
    ...                                         parameter=${mandatory_params}
    ...                                         operation=create
    ...                                         skip_parameter_relation_errors=${True}
    ...                                         should_activate=${True}
    ...                                         connection=COAM
    ${activate_result}=    Get From Dictionary    ${recommission_result1['commissioningResult']['activationResult']['resultNode']['parameters']}
    ...                                         result
    [Return]    ${activate_result}    ${CABLINK_ID}

ADD CABLINK_ASOD object
    [Arguments]    ${Rmod_ID}    ${distname_L}
    ${mandatory_params}   params to create cablink1_ASOD obj      mrbtsId=${mrbtsId}    rmodid=${Rmod_ID}
    FOR    ${index}    IN RANGE    ${Max_loop_number}
        ${CABLINK_ID}    evaluate    random.randint(1,65)    random
        Set Suite Variable        ${CABLINK_ID}
        ${distname1}    Set Variable    ${mrbtsId}/EQM-1/HWTOP-1/CABLINK-${CABLINK_ID}
        Run Keyword If  '${distname1}' not in @{distname_L}    Exit for loop
    END
    ${recommission_result1}=    admin_cli.perform_object_recommissioning    dist_name=${mrbtsId}/EQM-1/HWTOP-1/CABLINK-${CABLINK_ID}
    ...                                         parameter=${mandatory_params}
    ...                                         operation=create
    ...                                         skip_parameter_relation_errors=${True}
    ...                                         should_activate=${True}
    ...                                         connection=COAM
    ${activate_result}=    Get From Dictionary    ${recommission_result1['commissioningResult']['activationResult']['resultNode']['parameters']}
    ...                                         result
    [Return]    ${activate_result}    ${CABLINK_ID}

Delete CABLINK object
    [Arguments]    ${CABLINK_ID}
    ${recommission_result1}=    admin_cli.perform_object_recommissioning    dist_name=${mrbtsId}/EQM-1/HWTOP-1/CABLINK-${CABLINK_ID}
    ...                                         parameter=@{empty}
    ...                                         operation=delete
    ...                                         skip_parameter_relation_errors=${True}
    ...                                         should_activate=${True}
    ...                                         connection=COAM
    ${activate_result}=    Get From Dictionary    ${recommission_result1['commissioningResult']['activationResult']['resultNode']['parameters']}
    ...                                         result
    [Return]    ${activate_result}

Delete RMOD object
    [Arguments]    ${Rmod_ID}
    ${recommission_result1}=    admin_cli.perform_object_recommissioning    dist_name=${mrbtsId}/EQM-1/APEQM-1/RMOD-${Rmod_ID}
    ...                                         parameter=@{empty}
    ...                                         operation=delete
    ...                                         skip_parameter_relation_errors=${True}
    ...                                         should_activate=${True}
    ...                                         connection=COAM
    ${activate_result}=    Get From Dictionary    ${recommission_result1['commissioningResult']['activationResult']['resultNode']['parameters']}
    ...                                          result
    [Return]    ${activate_result}


