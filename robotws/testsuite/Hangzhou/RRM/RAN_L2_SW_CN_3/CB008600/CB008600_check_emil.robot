# @Time    : 2025/6/11 14:25
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @Group   : NSB MN RAN RD VRF HAZ3 5
# @File    : CB008600_check_emil.robot
# @Software: PyCharm
# @Doc     : This is common robot keywords template
*** Settings ***
Documentation
...    Feature: CB008600:Delay-critical GBR services
Resource    ../../RAN_L2_SW_CN_3/resources/VRF3_T05/internal_resource/internal_resource.robot
Resource    ../../RAN_L2_SW_CN_3/resources/sg10/internal_resource/internal_resource.robot

*** Keywords ***
Check Emil For A114 Step1
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/05/26 11:18
    [Arguments]    ${connection}=M5_DCAP
    Run Keyword And Ignore Error    Dcap Stop Trace Via Trace ID    download_trace=true
    Dcap Verify Trace Status Ready After Stop Trace    trace_id=${NOW_TRACE_ID}
    ${dcap_zip}    get_results    result_id=${NOW_TRACE_ID}    connection=${connection}
    ${dcap_folder}    my_unzip    zip_file=${dcap_zip}
    ${emil_files}    find_special_file_from_folder    ${dcap_folder}    .5gm
    ${upload_result}    Wait Until Keyword Succeeds    5x    3s
    ...    rd.upload_encoded_file    file_name=${emil_files[-1]}    connection=${connection}
    ${session_id}    Set Variable    ${upload_result['session_id']}
    ${data_source_id}    Set Variable    ${upload_result['grid_ids'][0]}

    # Step1: check NGAP: InitialContextSetupFailure
    ${filter}    Create List    ZMQ/SCTP name==NGAP: InitialContextSetupFailure
    ${decoded_content}    Get Decoded File Contents In Json    session_id=${session_id}    data_source_id=${data_source_id}
    ...    what=source    filter=${filter}    connection=${connection}
    ${values}    get_values_via_key    ${decoded_content}    PDUSessionResourceFailedToSetupListCxtFail
    Should Be Equal    ${values[0]}    ${PDUSessionResourceFailedToSetupListCxtFail}

    # Step2: check E1AP: BearerContextSetupRequest
    ${filter}    Create List    User data==E1AP: BearerContextSetupRequest
    ${decoded_content}    Get Decoded File Contents In Json    session_id=${session_id}    data_source_id=${data_source_id}
    ...    what=source    filter=${filter}    connection=M5_DCAP
    ${values}    get_values_via_key    ${decoded_content}    dRB-To-Setup-List-NG-RAN
    Should Be Equal    ${values}    ${dRB_To_Setup_List_NG_RAN_82_85}

    # Step3: check F1AP: UeContextSetupRequest
    ${filter}    Create List    Message number==DE30
    ${decoded_content}    Get Decoded File Contents In Json    session_id=${session_id}    data_source_id=${data_source_id}
    ...    what=source    filter=${filter}    connection=M5_DCAP
    ${values}    get_values_via_key    ${decoded_content}    DRBs-ToBeSetup-Item
    Should Be Equal
    ...    ${values[0]["qoSInformation"]["choice-extension"]["value"]["DRB-Information"]["dRB-QoS"]["qoS-Characteristics"]["non-Dynamic-5QI"]}
    ...    ${DRBs_ToBeSetup_Item_82_MDBV}
    Should Be Equal    ${values[0]["rLCMode"]}    rlc-um-bidirectional
    Should Be Equal    ${values[0]["iE-Extensions"][0]["extensionValue"]["PDCPSNLength"]}    twelve-bits

    Should Be Equal
    ...    ${values[1]["qoSInformation"]["choice-extension"]["value"]["DRB-Information"]["dRB-QoS"]["qoS-Characteristics"]["non-Dynamic-5QI"]}
    ...    ${DRBs_ToBeSetup_Item_85_MDBV}
    Should Be Equal    ${values[1]["rLCMode"]}    rlc-um-bidirectional
    Should Be Equal    ${values[1]["iE-Extensions"][0]["extensionValue"]["PDCPSNLength"]}    twelve-bits

Check Emil For A114 Step2
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/05/26 11:18
    [Arguments]    ${connection}=M5_DCAP
    Run Keyword And Ignore Error    Dcap Stop Trace Via Trace ID    download_trace=true
    Dcap Verify Trace Status Ready After Stop Trace    trace_id=${NOW_TRACE_ID}
    ${dcap_zip}    get_results    result_id=${NOW_TRACE_ID}    connection=${connection}
    ${dcap_folder}    my_unzip    zip_file=${dcap_zip}
    ${emil_files}    find_special_file_from_folder    ${dcap_folder}    .5gm
    ${upload_result}    Wait Until Keyword Succeeds    5x    3s
    ...    rd.upload_encoded_file    file_name=${emil_files[-1]}    connection=${connection}
    ${session_id}    Set Variable    ${upload_result['session_id']}
    ${data_source_id}    Set Variable    ${upload_result['grid_ids'][0]}

    # Step1: check E1AP: BearerContextSetupRequest
    ${filter}    Create List    User data==E1AP: BearerContextSetupRequest
    ${decoded_content}    Get Decoded File Contents In Json    session_id=${session_id}    data_source_id=${data_source_id}
    ...    what=source    filter=${filter}    connection=M5_DCAP
    ${values}    get_values_via_key    ${decoded_content}    dRB-To-Setup-List-NG-RAN
    Should Be Equal    ${values}    ${dRB_To_Setup_List_NG_RAN_88_128_225}

    # Step2: check F1AP: UeContextSetupRequest
    ${filter}    Create List    Message number==DE30
    ${decoded_content}    Get Decoded File Contents In Json    session_id=${session_id}    data_source_id=${data_source_id}
    ...    what=source    filter=${filter}    connection=M5_DCAP
    ${values}    get_values_via_key    ${decoded_content}    DRBs-ToBeSetup-Item
    Should Be Equal
    ...    ${values[0]["qoSInformation"]["choice-extension"]["value"]["DRB-Information"]["dRB-QoS"]["qoS-Characteristics"]["non-Dynamic-5QI"]}
    ...    ${DRBs_ToBeSetup_Item_88_MDBV}
    Should Be Equal    ${values[0]["rLCMode"]}    rlc-um-bidirectional
    Should Be Equal    ${values[0]["iE-Extensions"][0]["extensionValue"]["PDCPSNLength"]}    twelve-bits

    Should Be Equal
    ...    ${values[1]["qoSInformation"]["choice-extension"]["value"]["DRB-Information"]["dRB-QoS"]["qoS-Characteristics"]["non-Dynamic-5QI"]}
    ...    ${DRBs_ToBeSetup_Item_128_MDBV}
    Should Be Equal    ${values[1]["rLCMode"]}    rlc-um-bidirectional
    Should Be Equal    ${values[1]["iE-Extensions"][0]["extensionValue"]["PDCPSNLength"]}    twelve-bits

    Should Be Equal
    ...    ${values[2]["qoSInformation"]["choice-extension"]["value"]["DRB-Information"]["dRB-QoS"]["qoS-Characteristics"]["non-Dynamic-5QI"]}
    ...    ${DRBs_ToBeSetup_Item_225_MDBV}
    Should Be Equal    ${values[2]["rLCMode"]}    rlc-um-bidirectional
    Should Be Equal    ${values[2]["iE-Extensions"][0]["extensionValue"]["PDCPSNLength"]}    twelve-bits

Check Emil For A236
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/06/27 11:51
    [Arguments]    ${connection}=M5_DCAP
    Run Keyword And Ignore Error    Dcap Stop Trace Via Trace ID    download_trace=true
    Dcap Verify Trace Status Ready After Stop Trace    trace_id=${NOW_TRACE_ID}
    ${dcap_zip}    get_results    result_id=${NOW_TRACE_ID}    connection=${connection}
    ${dcap_folder}    my_unzip    zip_file=${dcap_zip}
    ${emil_files}    find_special_file_from_folder    ${dcap_folder}    .5gm
    ${upload_result}    Wait Until Keyword Succeeds    5x    3s
    ...    rd.upload_encoded_file    file_name=${emil_files[-1]}    connection=${connection}
    ${session_id}    Set Variable    ${upload_result['session_id']}
    ${data_source_id}    Set Variable    ${upload_result['grid_ids'][0]}

    ${filter}    Create List    User data==E1AP: BearerContextSetupRequest
    ${decoded_content}    Get Decoded File Contents In Json    session_id=${session_id}    data_source_id=${data_source_id}
    ...    what=source    filter=${filter}    connection=M5_DCAP
    log    ${decoded_content}

    ${filter}    Create List    User data==E1AP: BearerContextSetupResponse
    ${decoded_content}    Get Decoded File Contents In Json    session_id=${session_id}    data_source_id=${data_source_id}
    ...    what=source    filter=${filter}    connection=M5_DCAP
    log    ${decoded_content}

    ${filter}    Create List    User data==E1AP: BearerContextModificationRequest
    ${decoded_content}    Get Decoded File Contents In Json    session_id=${session_id}    data_source_id=${data_source_id}
    ...    what=source    filter=${filter}    connection=M5_DCAP
    log    ${decoded_content}

    ${filter}    Create List    User data==E1AP: BearerContextModificationResponse
    ${decoded_content}    Get Decoded File Contents In Json    session_id=${session_id}    data_source_id=${data_source_id}
    ...    what=source    filter=${filter}    connection=M5_DCAP
    log    ${decoded_content}

    ${filter}    Create List    User data==F1AP: UEContextSetupRequest
    ${decoded_content}    Get Decoded File Contents In Json    session_id=${session_id}    data_source_id=${data_source_id}
    ...    what=source    filter=${filter}    connection=M5_DCAP
    log    ${decoded_content}

    ${filter}    Create List    User data==F1AP: UEContextSetupResponse
    ${decoded_content}    Get Decoded File Contents In Json    session_id=${session_id}    data_source_id=${data_source_id}
    ...    what=source    filter=${filter}    connection=M5_DCAP
    log    ${decoded_content}

    ${filter}    Create List    User data==F1AP: UEContextModificationRequest
    ${decoded_content}    Get Decoded File Contents In Json    session_id=${session_id}    data_source_id=${data_source_id}
    ...    what=source    filter=${filter}    connection=M5_DCAP
    log    ${decoded_content}

    ${filter}    Create List    ZMQ/SCTP name==NGAP: PDUSessionResourceSetupRequest
    ${decoded_content}    Get Decoded File Contents In Json    session_id=${session_id}    data_source_id=${data_source_id}
    ...    what=source    filter=${filter}    connection=M5_DCAP
    log    ${decoded_content}

Check Emil For B005
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/05/28 15:06
    [Arguments]    ${connection}=M5_DCAP
    Run Keyword And Ignore Error    Dcap Stop Trace Via Trace ID    download_trace=true
    Dcap Verify Trace Status Ready After Stop Trace    trace_id=${NOW_TRACE_ID}
    ${dcap_zip}    get_results    result_id=${NOW_TRACE_ID}    connection=${connection}
    ${dcap_folder}    my_unzip    zip_file=${dcap_zip}
    ${emil_files}    find_special_file_from_folder    ${dcap_folder}    .5gm
    ${upload_result}    Wait Until Keyword Succeeds    5x    3s
    ...    rd.upload_encoded_file    file_name=${emil_files[-1]}    connection=${connection}
    ${session_id}    Set Variable    ${upload_result['session_id']}
    ${data_source_id}    Set Variable    ${upload_result['grid_ids'][0]}

    ${filter}    Create List    Message name==ZmqMessage
    ${decoded_content}    Get Decoded File Contents In Json    session_id=${session_id}    data_source_id=${data_source_id}
    ...    what=source    filter=${filter}    connection=M5_DCAP
    ${values}    get_values_via_key    ${decoded_content}    mac-LogicalChannelConfig
    List Should Contain Value    ${values}    ${mac_LogicalChannelConfig_5qi_82_84}
    List Should Contain Value    ${values}    ${mac_LogicalChannelConfig_5qi_83}

Check Emil For C103
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/06/04 13:34
    [Arguments]    ${connection}=M5_DCAP
    Run Keyword And Ignore Error    Dcap Stop Trace Via Trace ID    download_trace=true
    Dcap Verify Trace Status Ready After Stop Trace    trace_id=${NOW_TRACE_ID}
    ${dcap_zip}    get_results    result_id=${NOW_TRACE_ID}    connection=${connection}
    ${dcap_folder}    my_unzip    zip_file=${dcap_zip}
    ${emil_files}    find_special_file_from_folder    ${dcap_folder}    .5gm
    ${upload_result}    Wait Until Keyword Succeeds    5x    3s
    ...    rd.upload_encoded_file    file_name=${emil_files[-1]}    connection=${connection}
    ${session_id}    Set Variable    ${upload_result['session_id']}
    ${data_source_id}    Set Variable    ${upload_result['grid_ids'][0]}

    # Step1: check E1AP: BearerContextModificationRequest
    ${filter}    Create List    User data==E1AP: BearerContextModificationRequest
    ${decoded_content}    Get Decoded File Contents In Json    session_id=${session_id}    data_source_id=${data_source_id}
    ...    what=source    filter=${filter}    connection=M5_DCAP
    ${values}    get_values_via_key    ${decoded_content}    dRB-To-Setup-List-NG-RAN
    Should Be Equal    ${values[0]}    ${dRB_To_Setup_List_NG_RAN_84}

    # Step2: check ITF_L2_HI_CU_USER_BEARERSETUPREQ_ID
    ${filter}    Create List    Message name==ITF_L2_HI_CU_USER_BEARERSETUPREQ_ID
    ${decoded_content}    Get Decoded File Contents In Json    session_id=${session_id}    data_source_id=${data_source_id}
    ...    what=source    filter=${filter}    connection=M5_DCAP
    ${values}    get_values_via_key    ${decoded_content}    Content
    ${results}    Create List    @{EMPTY}
    FOR    ${v}    IN    @{values}
        ${result}    Create Dictionary    &{EMPTY}
        Set To Dictionary    ${result}    flowControlActive    ${v["dataProcessing"]["flowControlActive"]["Value"]}
        Set To Dictionary    ${result}    drbIdentity    ${v["drbIdentity"]["Value"]}
        Set To Dictionary    ${result}    resourceType    ${v["qos"]["mapping"]["resourceType"]["Value"]}
        Set To Dictionary    ${result}    rlcMode    ${v["pdcpParams"]["rlcMode"]["Value"]}
        Set To Dictionary    ${result}    snFieldLength    ${v["pdcpParams"]["snFieldLength"]["Value"]}
        Set To Dictionary    ${result}    reorderingTimer    ${v["pdcpParams"]["reorderingTimer"]["Value"]}
        Run Keyword And Ignore Error    Set To Dictionary    ${result}    dlMdbv
        ...    ${v["dataProcessing"]["primaryPathParams"]["mdbvEnforce"][0]["dlMdbv"]["Value"]}
        Run Keyword And Ignore Error    Set To Dictionary    ${result}    mdbvMargin
        ...    ${v["dataProcessing"]["primaryPathParams"]["mdbvEnforce"][0]["mdbvMargin"]["Value"]}
        Run Keyword And Ignore Error    Set To Dictionary    ${result}    dlRanPdb
        ...    ${v["dataProcessing"]["primaryPathParams"]["mdbvEnforce"][0]["dlRanPdb"]["Value"]}
        Run Keyword And Ignore Error    Set To Dictionary    ${result}    dlMdbv
        ...    ${v["dataProcessing"]["primaryPathParams"]["mdbvEnforce"]["values"][0]["dlMdbv"]["Value"]}
        Run Keyword And Ignore Error    Set To Dictionary    ${result}    mdbvMargin
        ...    ${v["dataProcessing"]["primaryPathParams"]["mdbvEnforce"]["values"][0]["mdbvMargin"]["Value"]}
        Run Keyword And Ignore Error    Set To Dictionary    ${result}    dlRanPdb
        ...    ${v["dataProcessing"]["primaryPathParams"]["mdbvEnforce"]["values"][0]["dlRanPdb"]["Value"]}
        Append To List    ${results}    ${result}
    END
    List Should Contain Value    ${results}    ${ITF_L2_HI_CU_USER_BEARERSETUPREQ_ID}

    # Step3: check E1AP: BearerContextModificationResponse
    ${filter}    Create List    User data==E1AP: BearerContextModificationResponse
    ${decoded_content}    Get Decoded File Contents In Json    session_id=${session_id}    data_source_id=${data_source_id}
    ...    what=source    filter=${filter}    connection=M5_DCAP
    ${values}    get_values_via_key    ${decoded_content}    dRB-Setup-List-NG-RAN
    Should Not Be Empty    ${values}
    #${result}    Run Keyword And Return Status    List Should Contain Value    ${values}
    #...    ${BearerContextModificationResponse}
    #Run Keyword If    ${result}==False    List Should Contain Value    ${values}
    #...    ${BearerContextModificationResponse2}

    # Step4: check ITF_L2_HI_CU_USER_BEARERSETUPREQ_ID
    ${filter}    Create List    Message name==ITF_L2_PS_USER_BEARERSETUPREQ_ID
    ${decoded_content}    Get Decoded File Contents In Json    session_id=${session_id}    data_source_id=${data_source_id}
    ...    what=source    filter=${filter}    connection=M5_DCAP
    ${values}    get_values_via_key    ${decoded_content}    Content
    ${results}    Create List    @{EMPTY}
    FOR    ${v}    IN    @{values}
        ${result}    Create Dictionary    &{EMPTY}
        Run Keyword And Ignore Error    Set To Dictionary    ${result}    dlMdbv
        ...    ${v["drbAddReqPs"][0]["delayCriticalGbrDrbParameters"][0]["dlMdbv"]["Value"]}
        Run Keyword And Ignore Error    Set To Dictionary    ${result}    ulMdbv
        ...    ${v["drbAddReqPs"][0]["delayCriticalGbrDrbParameters"][0]["ulMdbv"]["Value"]}
        Run Keyword And Ignore Error    Set To Dictionary    ${result}    dlRanPdb
        ...    ${v["drbAddReqPs"][0]["delayCriticalGbrDrbParameters"][0]["dlRanPdb"]["Value"]}
        Run Keyword And Ignore Error    Set To Dictionary    ${result}    ulRanPdb
        ...    ${v["drbAddReqPs"][0]["delayCriticalGbrDrbParameters"][0]["ulRanPdb"]["Value"]}
        Run Keyword And Ignore Error    Set To Dictionary    ${result}    avgWindow
        ...    ${v["drbAddReqPs"][0]["delayCriticalGbrDrbParameters"][0]["avgWindow"]["Value"]}
        Run Keyword And Ignore Error    Set To Dictionary    ${result}    discardTimerDl
        ...    ${v["drbAddReqPs"][0]["delayCriticalGbrDrbParameters"][0]["discardTimerDl"]["Value"]}
        Run Keyword And Ignore Error    Set To Dictionary    ${result}    dlMdbv
        ...    ${v["drbAddReqPs"][0]["delayCriticalGbrDrbParameters"]["values"][0]["dlMdbv"]["Value"]}
        Run Keyword And Ignore Error    Set To Dictionary    ${result}    ulMdbv
        ...    ${v["drbAddReqPs"][0]["delayCriticalGbrDrbParameters"]["values"][0]["ulMdbv"]["Value"]}
        Run Keyword And Ignore Error    Set To Dictionary    ${result}    dlRanPdb
        ...    ${v["drbAddReqPs"][0]["delayCriticalGbrDrbParameters"]["values"][0]["dlRanPdb"]["Value"]}
        Run Keyword And Ignore Error    Set To Dictionary    ${result}    ulRanPdb
        ...    ${v["drbAddReqPs"][0]["delayCriticalGbrDrbParameters"]["values"][0]["ulRanPdb"]["Value"]}
        Run Keyword And Ignore Error    Set To Dictionary    ${result}    avgWindow
        ...    ${v["drbAddReqPs"][0]["delayCriticalGbrDrbParameters"]["values"][0]["avgWindow"]["Value"]}
        Run Keyword And Ignore Error    Set To Dictionary    ${result}    discardTimerDl
        ...    ${v["drbAddReqPs"][0]["delayCriticalGbrDrbParameters"]["values"][0]["discardTimerDl"]["Value"]}
        Append To List    ${results}    ${result}
    END
    List Should Contain Value    ${results}    ${ITF_L2_PS_USER_BEARERSETUPREQ_ID}

Check Emil For F201
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/06/11 16:09
    [Arguments]    ${connection}=M5_DCAP
    Run Keyword And Ignore Error    Dcap Stop Trace Via Trace ID    download_trace=true
    Dcap Verify Trace Status Ready After Stop Trace    trace_id=${NOW_TRACE_ID}
    ${dcap_zip}    get_results    result_id=${NOW_TRACE_ID}    connection=${connection}
    ${dcap_folder}    my_unzip    zip_file=${dcap_zip}
    ${emil_files}    find_special_file_from_folder    ${dcap_folder}    .5gm

    ${syslog_files}    find_special_file_from_folder    ${dcap_folder}    syslog.log
    Set Test Variable    ${SYSLOG_FILE}    ${syslog_files[-1]}

    ${upload_result}    Wait Until Keyword Succeeds    5x    3s
    ...    rd.upload_encoded_file    file_name=${emil_files[-1]}    connection=${connection}
    ${session_id}    Set Variable    ${upload_result['session_id']}
    ${data_source_id}    Set Variable    ${upload_result['grid_ids'][0]}

    ${filter}    Create List    ZMQ/SCTP name==NGAP: PDUSessionResourceSetupRequest
    ${decoded_content}    Get Decoded File Contents In Json    session_id=${session_id}    data_source_id=${data_source_id}
    ...    what=source    filter=${filter}    connection=M5_DCAP
    ${values}    get_values_via_key    ${decoded_content}    QosFlowSetupRequestList
    Should Be Equal    ${values[0]}    ${QosFlowSetupRequestList}

    ${filter}    Create List    ZMQ/SCTP name==NGAP: PDUSessionResourceReleaseCommand
    ${decoded_content}    Get Decoded File Contents In Json    session_id=${session_id}    data_source_id=${data_source_id}
    ...    what=source    filter=${filter}    connection=M5_DCAP
    ${values}    get_values_via_key    ${decoded_content}    PDUSessionResourceToReleaseListRelCmd
    Should Be Equal    ${values[0]}    ${PDUSessionResourceToReleaseListRelCmd}

Check Emil For F202
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/06/13 14:40
    [Arguments]    ${connection}=M5_DCAP
    Run Keyword And Ignore Error    Dcap Stop Trace Via Trace ID    download_trace=true
    Dcap Verify Trace Status Ready After Stop Trace    trace_id=${NOW_TRACE_ID}
    ${dcap_zip}    get_results    result_id=${NOW_TRACE_ID}    connection=${connection}
    ${dcap_folder}    my_unzip    zip_file=${dcap_zip}
    ${emil_files}    find_special_file_from_folder    ${dcap_folder}    .5gm

    ${upload_result}    Wait Until Keyword Succeeds    5x    3s
    ...    rd.upload_encoded_file    file_name=${emil_files[-1]}    connection=${connection}
    ${session_id}    Set Variable    ${upload_result['session_id']}
    ${data_source_id}    Set Variable    ${upload_result['grid_ids'][0]}

    ${filter}    Create List    User data==E1AP: BearerContextModificationRequest
    ${decoded_content}    Get Decoded File Contents In Json    session_id=${session_id}    data_source_id=${data_source_id}
    ...    what=source    filter=${filter}    connection=M5_DCAP
    ${values}    find_target_key_values    ${decoded_content}    dRB-To-Setup-Mod-List-NG-RAN
    Lists Should Be Equal    ${values}    ${dRB_To_Setup_Mod_List_NG_RAN_6_84}

    ${filter}    Create List    User data==E1AP: BearerContextModificationResponse
    ${decoded_content}    Get Decoded File Contents In Json    session_id=${session_id}    data_source_id=${data_source_id}
    ...    what=source    filter=${filter}    connection=M5_DCAP
    Should Not Be Empty    ${decoded_content["emil_data"]["rows"]}
    ${filter}    Create List    User data==F1AP: UEContextModificationRequest
    ${decoded_content}    Get Decoded File Contents In Json    session_id=${session_id}    data_source_id=${data_source_id}
    ...    what=source    filter=${filter}    connection=M5_DCAP
    Should Not Be Empty    ${decoded_content["emil_data"]["rows"]}
    ${filter}    Create List    User data==F1AP: UEContextModificationFailure
    ${decoded_content}    Get Decoded File Contents In Json    session_id=${session_id}    data_source_id=${data_source_id}
    ...    what=source    filter=${filter}    connection=M5_DCAP
    ${values}    find_target_key_values    ${decoded_content}    radioNetwork
    Should Be Equal    ${values}    no-radio-resources-available
    ${filter}    Create List    ZMQ/SCTP name==NGAP: PDUSessionResourceSetupResponse
    ${decoded_content}    Get Decoded File Contents In Json    session_id=${session_id}    data_source_id=${data_source_id}
    ...    what=source    filter=${filter}    connection=M5_DCAP
    ${values}    find_target_key_values    ${decoded_content}    radioNetwork
    Should Be Equal    ${values}    radio-resources-not-available

Check Emil For F305
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/07/14 14:52
    [Arguments]    ${connection}=M5_DCAP
    Run Keyword And Ignore Error    Dcap Stop Trace Via Trace ID    download_trace=true
    Dcap Verify Trace Status Ready After Stop Trace    trace_id=${NOW_TRACE_ID}
    ${dcap_zip}    get_results    result_id=${NOW_TRACE_ID}    connection=${connection}
    ${dcap_folder}    my_unzip    zip_file=${dcap_zip}
    ${emil_files}    find_special_file_from_folder    ${dcap_folder}    .5gm

    ${upload_result}    Wait Until Keyword Succeeds    5x    3s
    ...    rd.upload_encoded_file    file_name=${emil_files[-1]}    connection=${connection}
    ${session_id}    Set Variable    ${upload_result['session_id']}
    ${data_source_id}    Set Variable    ${upload_result['grid_ids'][0]}

    ${filter}    Create List    Message name==ITF_L2_PS_USER_BEARERSETUPREQ_ID
    ${decoded_content}    Get Decoded File Contents In Json    session_id=${session_id}    data_source_id=${data_source_id}
    ...    what=source    filter=${filter}    connection=M5_DCAP
    ${values}    find_target_key_values    ${decoded_content}    delayCriticalGbrDrbParameters
    Should Be Equal As Numbers    ${values[0]["payloadSizeSr"]["Value"]}    ${1000}
    Should Be Equal As Numbers    ${values[0]["srPeriodicityDrb"]["Value"]}    ${10}

    ${filter}    Create List    Message name==ITF_L2_PS_USER_USERMODIFYREQ_ID
    ${decoded_content}    Get Decoded File Contents In Json    session_id=${session_id}    data_source_id=${data_source_id}
    ...    what=source    filter=${filter}    connection=M5_DCAP
    ${values}    find_target_key_values    ${decoded_content}    perSrConfig
    Should Be Equal As Numbers    ${values[0]["periodicity"]["Value"]}    ${20}
    Should Be Equal As Strings    ${values[0]["periodicity"]["Constants"]}    SL20
    Should Be Empty    ${values[0]["payloadSizeSr"]}
    Should Be Empty    ${values[0]["srPeriodicityDrb"]}
