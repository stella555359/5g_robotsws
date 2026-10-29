*** Settings ***
Documentation
...    = Author = Aleksandra Dagiel
...    _aleksandra.dagiel@nokia.com_
...    = Maintainer =
...    _aleksandra.chudzik@nokia.com_
...    = Reviewer =
...    _artur.czainski@nokia.com_
...    = Summary =
...    N/A
...    = Pre - Requirements =
...    _robotlte/config/<testline name>/__init__.py and site specific keyword_
...    = Additional Info =
...    Test created for 4cells, if more cells needed there are some changes required.

*** Keywords ***
CNI35112_Verify_the_behavior_of_cbrsFreqType_online_modification
    [Documentation]    PAL is not supportred for SAS ver 2 yet. All channels that are granted should be GAA.
    [Arguments]     ${start_sas_version}=2
    ${sw_info}  Get Software Info  connection=RAT_1ST
    ${sw_build}  Get From Dictionary  ${sw_info}  Active SW version
    ${sw_ver}  Fetch From Left  ${sw_build}   _
    IF  '${sw_ver}'=='SBTS21A' or '${sw_ver}'=='SBTS20C'
        Supported or not    ${start_sas_version}
    ELSE
        CNI35112_Verify_the_behavior_of_cbrsFreqType_online_modification_PAL_supported
    END

Supported or not
    [Arguments]     ${start_sas_version}
    IF  ${start_sas_version}==2
        CNI35112_Verify_the_behavior_of_cbrsFreqType_online_modification_PAL_not_supported
    ELSE
        CNI35112_Verify_the_behavior_of_cbrsFreqType_online_modification_PAL_supported
    END

CNI35112_Verify_the_behavior_of_cbrsFreqType_online_modification_PAL_not_supported
    [Timeout]     30min
    Log    Create Test Case Variables and Set Environment    console=true
    Kill All SAS Processes
    ${alias}   Set Variable    RAT_1ST
    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    ${deregistrationResponse}   Load JSON From File    ${CURDIR}/Data/Common/deregistrationResponse.json
    ${registrationResponse}   Load JSON From File    ${CURDIR}/Data/Common/registrationResponse.json
    ${spectrumInquiryResponse}   Load JSON From File    ${CURDIR}/Data/Common/spectrumInquiryResponse.json
    ${deregistrationResponse}   Load JSON From File    ${CURDIR}/Data/Common/deregistrationResponse.json

    ${responseCode_0}   Load JSON From File    ${CURDIR}/Data/Common/response_code_0.json

    Replace Variables In File    file_path=${CURDIR}/Data/Common/actCbrs_false.json
    ...                 file_destination=${OUTPUT_DIR}/Delta/${TESTNAME}_actCbrs_false.json
    ...                 enb_id=${enb_id}
    Replace Variables In File    file_path=${CURDIR}/Data/Common/actCbrs_true.json
    ...                 file_destination=${OUTPUT_DIR}/Delta/${TESTNAME}_actCbrs_true.json
    ...                 enb_id=${enb_id}
    Replace Variables In File    file_path=${CURDIR}/Data/Common/set_gaa.json
    ...                 file_destination=${OUTPUT_DIR}/Delta/${TESTNAME}_set_gaa.json
    ...                 enb_id=${enb_id}
    Replace Variables In File    file_path=${CURDIR}/Data/Common/set_pal.json
    ...                 file_destination=${OUTPUT_DIR}/Delta/${TESTNAME}_set_pal.json
    ...                 enb_id=${enb_id}
    Replace Variables In File    file_path=${CURDIR}/Data/CNI35112/set_none.json
    ...                 file_destination=${OUTPUT_DIR}/Delta/${TESTNAME}_set_none.json
    ...                 enb_id=${enb_id}
    Wait Until BTS Is Not Busy
    Wait Until Keyword Succeeds    10x    10s    Perform Delta Recommissioning
    ...     ${OUTPUT_DIR}/Delta/${TESTNAME}_set_pal.json    connection=${alias}
    Wait Until BTS Is Not Busy
    Enable CBRS Feature On eNB
    ${sas_pid}    ${sas_log}   Start SAS Process   config=${CURDIR}/Data/Common/SAS_Sim.conf
    ${cbsdId}   Wait Until Keyword Succeeds    20x    30s    Get CBSD Id From Infomodel     #waiting for CBRS to assign CbsdId
    Log    Assigned CDSD Id: ${cbsdId}    console=true
    Send Command To SAS Manager    alias=default      command=PPA_add ${cbsdId}
    Sleep And Display Progress    60    s   #waiting for recommisioning and sas logs that run in background
    ${time_start}    Get Time
    Log     __________________________________________________________________________________    console=true
    Log    Verify the behavior of cbrsFreqType online modification from PAL to GAA    console=true
    Log    Change cbrsFreqType to GAA    console=true
    Wait Until BTS Is Not Busy
    Wait Until Keyword Succeeds    10x    10s    Perform Delta Recommissioning
    ...     ${OUTPUT_DIR}/Delta/${TESTNAME}_set_gaa.json    connection=${alias}
    Sleep And Display Progress    60    s   #waiting for recommisioning and sas logs that run in background
    ${time_stop}    Get Time

    Log    Check Alarms after recommissioning    console=true
    No Alarm Except Allowed Should Appear On EnB    alias=${alias}

    Log    Check Deregistration packets between BTS and SAS simu    console=true
    ${parsed_log_file}     Parse Sas Log File    log_file_name=${sas_log}    date_start=${time_start}     date_stop=${time_stop}
    ${grantId_list}    Extract Values From Sas Log
    ...    log_name=${parsed_log_file}    parameter=grantId    data_type=heartbeatResponse    start_from=deregistrationResponse    packet_amount=1
    Log    Collected Grant Id list: ${grantId_list}    console=true
    Query Sas Log     log_name=${parsed_log_file}    data_type=deregistrationRequest      parameter=cbsdId      value=${cbsdId}
    Query Sas Log     log_name=${parsed_log_file}    data_type=deregistrationResponse     parameter=response    value=${deregistrationResponse}
    Query Sas Log     log_name=${parsed_log_file}    data_type=deregistrationResponse     parameter=cbsdId      value=${cbsdId}

    Log    Check the registration response message received from SAS simu    console=true
    Query Sas Log     log_name=${parsed_log_file}    data_type=registrationResponse     parameter=response    value=${registrationResponse}

    Log    Check the Spectrum Inquiry Request sent to SAS    console=true
    Query Sas Log     log_name=${parsed_log_file}    data_type=spectrumInquiryRequest     parameter=cbsdId              value=${cbsdId}

    Log    Check the Spectrum Inquiry Response     console=true
    Query Sas Log    log_name=${parsed_log_file}    data_type=spectrumInquiryResponse    parameter=response    value=${spectrumInquiryResponse}

    Log    Check the Grant Request message is sent to SAS    console=true
    Query Sas Log    log_name=${parsed_log_file}    data_type=grantRequest     parameter=cbsdId            value=${cbsdId}

    Log    Check the Grant Response    console=true
    Sas Grantexpiretime Should Be Grater Than Transmitexpiretime    ${parsed_log_file}
    ${grantResponse_values}   Extract Values From Sas Log
    ...    log_name=${parsed_log_file}     parameter=channelType    data_type=grantResponse   start_from=deregistrationRequest    packet_amount=1
    Should Contain X Times    container=${grantResponse_values}    item=GAA    count=4
    Query Sas Log     log_name=${parsed_log_file}    data_type=grantResponse     parameter=response       value=${registrationResponse}
    Query Sas Log     log_name=${parsed_log_file}    data_type=grantResponse     parameter=cbsdId         value=${cbsdId}
    FOR   ${grant_id}   IN   @{grantId_list}
       Query Sas Log     log_name=${parsed_log_file}    data_type=debug     value=started a hb timer with 120 seconds for grant ${grant_id}
    END

    Log    Check the Heartbeat Request Message is sent to SAS    console=true
    FOR   ${grant_id}   IN   @{grantId_list}
       Query Sas Log     log_name=${parsed_log_file}    data_type=heartbeatRequest     parameter=grantId       value=${grant_id}
    END

    Query Sas Log     log_name=${parsed_log_file}    data_type=heartbeatRequest     parameter=cbsdId        value=${cbsdId}
    ${heartbeatRequest_values}   Extract Values From Sas Log
    ...    log_name=${parsed_log_file}     parameter=operationState    data_type=heartbeatRequest     start_from=deregistrationRequest
    Should Contain X Times    container=${heartbeatRequest_values}    item=GRANTED    count=4

    Log    Check the Heartbeat Response message and the Heartbeat Request message     console=true
    Query Sas Log     log_name=${parsed_log_file}    data_type=heartbeatResponse     parameter=cbsdId
    ...        value=${cbsdId}    start_from=deregistrationRequest
    Query Sas Log     log_name=${parsed_log_file}    data_type=heartbeatResponse     parameter=response      value=${responseCode_0}
    FOR   ${grant_id}   IN   @{grantId_list}
       Query Sas Log     log_name=${parsed_log_file}    data_type=heartbeatResponse     parameter=grantId
       ...    value=${grant_id}    start_from=deregistrationRequest
    END

    Log    Check eNB and CBSD status     console=true
    Required CBSD Status Should Be Reached     expected_status=Registered    enb_id=${enb_id}
    No Alarm Except Allowed Should Appear On EnB    alias=${alias}
    BTS Operational State Should Be OnAir    alias=${alias}
    ute_admin_infomodel.Query Infomodel    timeout=20    alias=${alias}
    ...    query=every /MRBTS-*/RAT-*/MCTRL-*/BBTOP_M-*/MRBTS_M-*/LNBTS_M-*/CELL_M-* is [stateInfo.proceduralState=regex"(?i)OnAir.*"]

    Log     __________________________________________________________________________________    console=true
    Log    Verify the behavior of cbrsFreqType online modification from GAA to PAL    console=true
    Log    Change cbrsFreqType to PAL    console=true

    ${time_start}    Get Time
    Wait Until BTS Is Not Busy
    Perform Delta Recommissioning     ${OUTPUT_DIR}/Delta/${TESTNAME}_set_pal.json    connection=${alias}
    Sleep And Display Progress    60    s    #waiting for recommisioning and sas logs that run in background
    ${time_stop}    Get Time

    Log    Check Alarms after recommissioning    console=true
    No Alarm Except Allowed Should Appear On EnB    alias=${alias}

    Log    Check Deregistration packets between BTS and SAS simu    console=true
    ${parsed_log_file}     Parse Sas Log File    log_file_name=${sas_log}     date_start=${time_start}     date_stop=${time_stop}
    ${grantId_list}    Extract Values From Sas Log    log_name=${parsed_log_file}    parameter=grantId
    ...    data_type=heartbeatResponse    start_from=deregistrationRequest    packet_amount=1
    Log    Collected Grant Id list: ${grantId_list}    console=true
    Query Sas Log     log_name=${parsed_log_file}    data_type=deregistrationRequest      parameter=cbsdId      value=${cbsdId}
    Query Sas Log     log_name=${parsed_log_file}    data_type=deregistrationResponse     parameter=response    value=${deregistrationResponse}
    Query Sas Log     log_name=${parsed_log_file}    data_type=deregistrationResponse     parameter=cbsdId      value=${cbsdId}

    Log    Check the registration response message received from SAS simu    console=true
    Query Sas Log     log_name=${parsed_log_file}    data_type=registrationResponse     parameter=response    value=${registrationResponse}

    Log    Check the Spectrum Inquiry Request sent to SAS    console=true
    Query Sas Log     log_name=${parsed_log_file}    data_type=spectrumInquiryRequest     parameter=cbsdId              value=${cbsdId}

    Log    Check the Spectrum Inquiry Response     console=true
    Query Sas Log    log_name=${parsed_log_file}    data_type=spectrumInquiryResponse     parameter=response      value=${spectrumInquiryResponse}

    Log    Check the Grant Request message is sent to SAS    console=true
    Query Sas Log    log_name=${parsed_log_file}    data_type=grantRequest     parameter=cbsdId            value=${cbsdId}

    Log    Check the Grant Response    console=true
    Sas Grantexpiretime Should Be Grater Than Transmitexpiretime    ${parsed_log_file}
    ${grantResponse_values}   Extract Values From Sas Log    log_name=${parsed_log_file}     parameter=channelType
    ...    data_type=grantResponse    start_from=deregistrationRequest    packet_amount=1
    Should Contain X Times    container=${grantResponse_values}    item=GAA    count=4
    Query Sas Log     log_name=${parsed_log_file}    data_type=grantResponse     parameter=response       value=${registrationResponse}
    Query Sas Log     log_name=${parsed_log_file}    data_type=grantResponse     parameter=cbsdId         value=${cbsdId}
    FOR   ${grant_id}   IN   @{grantId_list}
       Query Sas Log     log_name=${parsed_log_file}    data_type=debug     value=started a hb timer with 120 seconds for grant ${grant_id}
    END

    Log    Check the Heartbeat Request Message is sent to SAS    console=true
    FOR   ${grant_id}   IN   @{grantId_list}
       Query Sas Log     log_name=${parsed_log_file}    data_type=heartbeatRequest     parameter=grantId       value=${grant_id}
    END
    Query Sas Log     log_name=${parsed_log_file}    data_type=heartbeatRequest     parameter=cbsdId        value=${cbsdId}
    ${heartbeatRequest_values}   Extract Values From Sas Log    log_name=${parsed_log_file}     parameter=operationState
    ...    data_type=heartbeatRequest     start_from=deregistrationRequest
    Should Contain X Times    container=${heartbeatRequest_values}    item=GRANTED    count=4

    Log    Check the Heartbeat Response message    console=true
    Query Sas Log    log_name=${parsed_log_file}    data_type=heartbeatResponse    parameter=cbsdId
    ...    value=${cbsdId}    start_from=deregistrationRequest
    Query Sas Log    log_name=${parsed_log_file}    data_type=heartbeatResponse    parameter=response
    ...    value=${responseCode_0}
    FOR   ${grant_id}   IN   @{grantId_list}
       Query Sas Log    log_name=${parsed_log_file}    data_type=heartbeatResponse     parameter=grantId
       ...       value=${grant_id}    start_from=deregistrationRequest
    END

    Log    Check eNB and CBSD status     console=true
    No Alarm Except Allowed Should Appear On EnB    alias=${alias}
    BTS Operational State Should Be OnAir    alias=${alias}
    Required CBSD Status Should Be Reached     expected_status=Registered    enb_id=${enb_id}
    ute_admin_infomodel.Query Infomodel    timeout=20    alias=${alias}
    ...   query=every /MRBTS-*/RAT-*/MCTRL-*/BBTOP_M-*/MRBTS_M-*/LNBTS_M-*/CELL_M-* is [stateInfo.proceduralState=regex"(?i)OnAir.*"]
    ${sw_info}  Get Software Info  connection=RAT_1ST
    ${sw_build}  Get From Dictionary  ${sw_info}  Active SW version
    ${sw_ver}  Fetch From Left  ${sw_build}   _
    IF  '${sw_ver}'=='SBTS21A' or '${sw_ver}'=='SBTS20C'
        Set cbrsFreqType As Null For Old SW Release And PAL Is Not Supported
        ...    ${alias}    ${sas_log}    ${cbsdId}    ${enb_id}    ${deregistrationResponse}    ${registrationResponse}
        ...    ${spectrumInquiryResponse}    ${deregistrationResponse}
    END

    [Teardown]        Teardown_CNI35112_Verify_the_behavior_of_cbrsFreqType_online_modification



CNI35112_Verify_the_behavior_of_cbrsFreqType_online_modification_PAL_supported
    [Documentation]
    ...    1) Test contains 4 test cases
    ...    * A_FeVe_07_Verify_the_behavior_of_cbrsFreqType_online_modification_from_PAL_to_GAA
    ...    LTE4757 Support PAL Mode CBRS Service for Macro Site (Airscale) introduced PAL (Priority Access License) to
    ...    support in commercial deployment of CBRS as one of CBRS spectrum allocation type.
    ...    PAL is licensed by auction. PALs carriers will be within CBRS band (Band 48).
    ...    PAL reserved channel in the range of 3550-3650Mhz. one PAL =10MHz channel in one census tract.
    ...    Feature activation should be together with LTE3663 GAA operation.
    ...    The purpose of this test case is to check when the cbrsFreqType is online modified from PAL to GAA,
    ...    CBSD would re-registered and the GAA mode CBRS service could be provided successfully after the CBSDs are registered.
    ...    * A_FeVe_08_Verify_the_behavior_of_cbrsFreqType_online_modification_from_GAA_to_PAL
    ...    * A_FeVe_09_Verify_the_behavior_of_cbrsFreqType_online_modification_from_GAA_to_NULL
    ...    * A_FeVe_10_Verify_the_behavior_of_cbrsFreqType_online_modification_from_NULL_to_PAL
    ...    2) NULL behavior changed 10.2018 due to: "CNI-35112:
    ...    Airscale CBRS: Support PAL(Priority Access License)-cbsdFreqType: empty as PAL to cover missing configuration scenario"
    ...    """[https://jira3.int.net.nokia.com/browse/CNI-35112]"""
    ...    where empty cbsdFreqType is treated as PAL.
    ...    3) Every json file from path used in keywords Load JSON From File serves as a pattern of message searched in SAS logs
    ...    (passed as a variable ${parsed_log_file}).
    ...    4) SFS/CFAMrequirement: CNI-35112; OM_LTE_SFS_RNL.19554; OM_LTE_SFS_RNL.19577
    [Timeout]     30min
    Log    Create Test Case Variables and Set Environment    console=true
    Kill All SAS Processes
    ${alias}   Set Variable    RAT_1ST
    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    ${deregistrationResponse}   Load JSON From File    ${CURDIR}/Data/Common/deregistrationResponse.json
    ${registrationResponse}   Load JSON From File    ${CURDIR}/Data/Common/registrationResponse.json
    ${spectrumInquiryResponse}   Load JSON From File    ${CURDIR}/Data/Common/spectrumInquiryResponse.json
    ${deregistrationResponse}   Load JSON From File    ${CURDIR}/Data/Common/deregistrationResponse.json
    ${availableChannel}      Replace Variables In File     file_path=${CURDIR}/Data/Common/spectrumInquiryResponse_availableChannel.json
    ...                       file_destination=${OUTPUT_DIR}/Delta/${TESTNAME}_spectrumInquiryResponse_availableChannel.json
    ...                       enb_id=${enb_id}

    ${availableChannel}   Load JSON From File    ${availableChannel}

    ${responseCode_0}   Load JSON From File    ${CURDIR}/Data/Common/response_code_0.json

    Replace Variables In File    file_path=${CURDIR}/Data/Common/actCbrs_false.json
    ...                 file_destination=${OUTPUT_DIR}/Delta/${TESTNAME}_actCbrs_false.json
    ...                 enb_id=${enb_id}
    Replace Variables In File    file_path=${CURDIR}/Data/Common/actCbrs_true.json
    ...                 file_destination=${OUTPUT_DIR}/Delta/${TESTNAME}_actCbrs_true.json
    ...                 enb_id=${enb_id}
    Replace Variables In File    file_path=${CURDIR}/Data/Common/set_gaa.json
    ...                 file_destination=${OUTPUT_DIR}/Delta/${TESTNAME}_set_gaa.json
    ...                 enb_id=${enb_id}
    Replace Variables In File    file_path=${CURDIR}/Data/Common/set_pal.json
    ...                 file_destination=${OUTPUT_DIR}/Delta/${TESTNAME}_set_pal.json
    ...                 enb_id=${enb_id}
    Replace Variables In File    file_path=${CURDIR}/Data/CNI35112/set_none.json
    ...                 file_destination=${OUTPUT_DIR}/Delta/${TESTNAME}_set_none.json
    ...                 enb_id=${enb_id}
    Wait Until BTS Is Not Busy
    Wait Until Keyword Succeeds    10x    10s    connection.Perform Delta Recommissioning
    ...     ${OUTPUT_DIR}/Delta/${TESTNAME}_set_pal.json    connection=${alias}
    Wait Until BTS Is Not Busy
    Enable CBRS Feature On eNB
    ${sas_pid}    ${sas_log}   Start SAS Process    config=${CURDIR}/Data/Common/SAS_Sim.conf
    ${cbsdId}   Wait Until Keyword Succeeds    20x    30s    Get CBSD Id From Infomodel     #waiting for CBRS to assign CbsdId
    Log    Assigned CDSD Id: ${cbsdId}    console=true
    Send Command To SAS Manager    alias=default      command=PPA_add ${cbsdId}
    Sleep And Display Progress    60    s   #waiting for recommisioning and sas logs that run in background
    ${time_start}    Get Time
    Log     __________________________________________________________________________________    console=true
    Log    Verify the behavior of cbrsFreqType online modification from PAL to GAA    console=true
    Log    Change cbrsFreqType to GAA    console=true
    Wait Until BTS Is Not Busy
    Wait Until Keyword Succeeds    10x    10s    Perform Delta Recommissioning    ${OUTPUT_DIR}/Delta/${TESTNAME}_set_gaa.json    connection=${alias}
    Sleep And Display Progress    60    s   #waiting for recommisioning and sas logs that run in background
    ${time_stop}    Get Time

    Log    Check Alarms after recommissioning    console=true
    No Alarm Except Allowed Should Appear On EnB    alias=${alias}

    Log    Check Deregistration packets between BTS and SAS simu    console=true
    ${parsed_log_file}     Parse Sas Log File    log_file_name=${sas_log}    date_start=${time_start}     date_stop=${time_stop}
    ${grantId_list}    Extract Values From Sas Log    log_name=${parsed_log_file}    parameter=grantId    data_type=heartbeatResponse
    ...    start_from=deregistrationResponse    packet_amount=1
    Log    Collected Grant Id list: ${grantId_list}    console=true
    Query Sas Log     log_name=${parsed_log_file}    data_type=deregistrationRequest      parameter=cbsdId      value=${cbsdId}
    Query Sas Log     log_name=${parsed_log_file}    data_type=deregistrationResponse     parameter=response    value=${deregistrationResponse}
    Query Sas Log     log_name=${parsed_log_file}    data_type=deregistrationResponse     parameter=cbsdId      value=${cbsdId}

    Log    Check the registration response message received from SAS simu    console=true
    Query Sas Log     log_name=${parsed_log_file}    data_type=registrationResponse     parameter=response    value=${registrationResponse}

    Log    Check the Spectrum Inquiry Request sent to SAS    console=true
    Query Sas Log     log_name=${parsed_log_file}    data_type=spectrumInquiryRequest     parameter=cbsdId              value=${cbsdId}

    Log    Check the Spectrum Inquiry Response     console=true
    Query Sas Log    log_name=${parsed_log_file}    data_type=spectrumInquiryResponse     parameter=response        value=${spectrumInquiryResponse}
    Query Sas Log    log_name=${parsed_log_file}    data_type=spectrumInquiryResponse     parameter=availableChannel    value=${availableChannel}

    Log    Check the Grant Request message is sent to SAS    console=true
    Query Sas Log    log_name=${parsed_log_file}    data_type=grantRequest     parameter=cbsdId            value=${cbsdId}

    Log    Check the Grant Response    console=true
    Sas Grantexpiretime Should Be Grater Than Transmitexpiretime    ${parsed_log_file}
    ${grantResponse_values}   Extract Values From Sas Log    log_name=${parsed_log_file}     parameter=channelType    data_type=grantResponse
    ...   start_from=deregistrationRequest    packet_amount=1
    Should Contain X Times    container=${grantResponse_values}    item=GAA    count=4
    Query Sas Log     log_name=${parsed_log_file}    data_type=grantResponse     parameter=response       value=${registrationResponse}
    Query Sas Log     log_name=${parsed_log_file}    data_type=grantResponse     parameter=cbsdId         value=${cbsdId}
    FOR   ${grant_id}   IN   @{grantId_list}
       Query Sas Log     log_name=${parsed_log_file}    data_type=debug     value=started a hb timer with 120 seconds for grant ${grant_id}
    END

    Log    Check the Heartbeat Request Message is sent to SAS    console=true
    FOR   ${grant_id}   IN   @{grantId_list}
       Query Sas Log     log_name=${parsed_log_file}    data_type=heartbeatRequest     parameter=grantId       value=${grant_id}
    END

    Query Sas Log     log_name=${parsed_log_file}    data_type=heartbeatRequest     parameter=cbsdId        value=${cbsdId}
    ${heartbeatRequest_values}   Extract Values From Sas Log    log_name=${parsed_log_file}     parameter=operationState
    ...    data_type=heartbeatRequest     start_from=deregistrationRequest
    Should Contain X Times    container=${heartbeatRequest_values}    item=GRANTED    count=4

    Log    Check the Heartbeat Response message and the Heartbeat Request message     console=true
    Query Sas Log    log_name=${parsed_log_file}    data_type=heartbeatResponse    parameter=cbsdId
    ...    value=${cbsdId}    start_from=deregistrationRequest
    Query Sas Log     log_name=${parsed_log_file}    data_type=heartbeatResponse     parameter=response      value=${responseCode_0}
    FOR   ${grant_id}   IN   @{grantId_list}
       Query Sas Log     log_name=${parsed_log_file}    data_type=heartbeatResponse    parameter=grantId
       ...    value=${grant_id}    start_from=deregistrationRequest
    END

    Log    Check eNB and CBSD status     console=true
    Required CBSD Status Should Be Reached     expected_status=Registered    enb_id=${enb_id}
    No Alarm Except Allowed Should Appear On EnB    alias=${alias}
    BTS Operational State Should Be OnAir    alias=${alias}
    ute_admin_infomodel.Query Infomodel    timeout=20    alias=${alias}
    ...    query=every /MRBTS-*/RAT-*/MCTRL-*/BBTOP_M-*/MRBTS_M-*/LNBTS_M-*/CELL_M-* is [stateInfo.proceduralState=regex"(?i)OnAir.*"]

    Log     __________________________________________________________________________________    console=true
    Log    Verify the behavior of cbrsFreqType online modification from GAA to PAL    console=true
    Log    Change cbrsFreqType to PAL    console=true

    ${time_start}    Get Time
    Wait Until BTS Is Not Busy
    Perform Delta Recommissioning     ${OUTPUT_DIR}/Delta/${TESTNAME}_set_pal.json    connection=${alias}
    Sleep And Display Progress    60    s    #waiting for recommisioning and sas logs that run in background
    ${time_stop}    Get Time

    Log    Check Alarms after recommissioning    console=true
    No Alarm Except Allowed Should Appear On EnB    alias=${alias}

    Log    Check Deregistration packets between BTS and SAS simu    console=true
    ${parsed_log_file}     Parse Sas Log File    log_file_name=${sas_log}     date_start=${time_start}     date_stop=${time_stop}
    ${grantId_list}    Extract Values From Sas Log    log_name=${parsed_log_file}    parameter=grantId    data_type=heartbeatResponse
    ...    start_from=deregistrationRequest    packet_amount=1
    Log    Collected Grant Id list: ${grantId_list}    console=true
    Query Sas Log     log_name=${parsed_log_file}    data_type=deregistrationRequest      parameter=cbsdId      value=${cbsdId}
    Query Sas Log     log_name=${parsed_log_file}    data_type=deregistrationResponse     parameter=response    value=${deregistrationResponse}
    Query Sas Log     log_name=${parsed_log_file}    data_type=deregistrationResponse     parameter=cbsdId      value=${cbsdId}

    Log    Check the registration response message received from SAS simu    console=true
    Query Sas Log     log_name=${parsed_log_file}    data_type=registrationResponse     parameter=response    value=${registrationResponse}

    Log    Check the Spectrum Inquiry Request sent to SAS    console=true
    Query Sas Log     log_name=${parsed_log_file}    data_type=spectrumInquiryRequest     parameter=cbsdId              value=${cbsdId}

    Log    Check the Spectrum Inquiry Response     console=true
    Query Sas Log    log_name=${parsed_log_file}    data_type=spectrumInquiryResponse    parameter=response    value=${spectrumInquiryResponse}
    Query Sas Log    log_name=${parsed_log_file}    data_type=spectrumInquiryResponse     parameter=availableChannel    value=${availableChannel}

    Log    Check the Grant Request message is sent to SAS    console=true
    Query Sas Log    log_name=${parsed_log_file}    data_type=grantRequest     parameter=cbsdId            value=${cbsdId}

    Log    Check the Grant Response    console=true
    Sas Grantexpiretime Should Be Grater Than Transmitexpiretime    ${parsed_log_file}
    ${grantResponse_values}   Extract Values From Sas Log    log_name=${parsed_log_file}     parameter=channelType    data_type=grantResponse
    ...    start_from=deregistrationRequest    packet_amount=1
    Should Contain X Times    container=${grantResponse_values}    item=PAL    count=4
    Query Sas Log     log_name=${parsed_log_file}    data_type=grantResponse     parameter=response       value=${registrationResponse}
    Query Sas Log     log_name=${parsed_log_file}    data_type=grantResponse     parameter=cbsdId         value=${cbsdId}
    FOR   ${grant_id}   IN   @{grantId_list}
       Query Sas Log     log_name=${parsed_log_file}    data_type=debug     value=started a hb timer with 120 seconds for grant ${grant_id}
    END

    Log    Check the Heartbeat Request Message is sent to SAS    console=true
    FOR   ${grant_id}   IN   @{grantId_list}
       Query Sas Log     log_name=${parsed_log_file}    data_type=heartbeatRequest     parameter=grantId       value=${grant_id}
    END
    Query Sas Log     log_name=${parsed_log_file}    data_type=heartbeatRequest     parameter=cbsdId        value=${cbsdId}
    ${heartbeatRequest_values}   Extract Values From Sas Log    log_name=${parsed_log_file}     parameter=operationState
    ...    data_type=heartbeatRequest     start_from=deregistrationRequest
    Should Contain X Times    container=${heartbeatRequest_values}    item=GRANTED    count=4

    Log    Check the Heartbeat Response message    console=true
    Query Sas Log     log_name=${parsed_log_file}    data_type=heartbeatResponse    parameter=cbsdId
    ...    value=${cbsdId}    start_from=deregistrationRequest
    Query Sas Log     log_name=${parsed_log_file}    data_type=heartbeatResponse     parameter=response      value=${responseCode_0}
    FOR   ${grant_id}   IN   @{grantId_list}
       Query Sas Log     log_name=${parsed_log_file}    data_type=heartbeatResponse     parameter=grantId
       ...    value=${grant_id}    start_from=deregistrationRequest
    END

    Log    Check eNB and CBSD status     console=true
    No Alarm Except Allowed Should Appear On EnB    alias=${alias}
    BTS Operational State Should Be OnAir    alias=${alias}
    Required CBSD Status Should Be Reached     expected_status=Registered    enb_id=${enb_id}
    ute_admin_infomodel.Query Infomodel    timeout=20    alias=${alias}
    ...    query=every /MRBTS-*/RAT-*/MCTRL-*/BBTOP_M-*/MRBTS_M-*/LNBTS_M-*/CELL_M-* is [stateInfo.proceduralState=regex"(?i)OnAir.*"]
    ${sw_info}  Get Software Info  connection=RAT_1ST
    ${sw_build}  Get From Dictionary  ${sw_info}  Active SW version
    ${sw_ver}  Fetch From Left  ${sw_build}   _
    IF  '${sw_ver}'=='SBTS21A' or '${sw_ver}'=='SBTS20C'
        Set cbrsFreqType As Null For Old SW Release And PAL Is Supported
        ...    ${alias}    ${sas_log}    ${cbsdId}    ${enb_id}    ${deregistrationResponse}    ${registrationResponse}
        ...    ${spectrumInquiryResponse}    ${deregistrationResponse}    ${availableChannel}
    END

    [Teardown]        Teardown_CNI35112_Verify_the_behavior_of_cbrsFreqType_online_modification

Teardown_CNI35112_Verify_the_behavior_of_cbrsFreqType_online_modification
    Log    Teardown tor TestCase ${TESTNAME} started...    console=true
    ${alias}   Set Variable    RAT_1ST
    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    Replace Variables In File    file_path=${CURDIR}/./Data/Common/set_gaa.json
    ...                 file_destination=${OUTPUT_DIR}/Delta/${TESTNAME}_set_gaa.json
    ...                 enb_id=${enb_id}
    Get SAS Logs To Logs Dir    alias=default
    Log    Teardown: Set changed parameters to default values...    console=true
    Wait Until BTS Is Not Busy
    Wait Until Keyword Succeeds    10x   10s    Perform Delta Recommissioning
    ...    ${OUTPUT_DIR}/Delta/${TESTNAME}_set_gaa.json   connection=${alias}   #waiting for commissioning in case the previous one is still ongoing
    Log    Teardown: Check alarms and operational state on eNB...    console=true
    Sleep    60s
    No Alarm Except Allowed Should Appear On EnB    alias=${alias}     #waiting for alarms to appear/disappear
    Wait Until Keyword Succeeds    10x   3s    ute_admin_infomodel.Query Infomodel
    ...     query=every /MRBTS-*/RAT-*/MCTRL-*/BBTOP_M-*/MRBTS_M-*/LNBTS_M-*/CELL_M-* is [stateInfo.proceduralState=regex"(?i)OnAir.*"]
    ...     timeout=20    alias=${alias}       #waiting for onair cells

Set cbrsFreqType As Null For Old SW Release And PAL Is Not Supported
    [Arguments]   ${alias}  ${sas_log}  ${cbsdId}  ${enb_id}
    ...     ${deregistrationResponse}  ${registrationResponse}  ${spectrumInquiryResponse}  ${deregistrationResponse}
    Log     __________________________________________________________________________________    console=true
    Log     Verify the behavior of cbrsFreqType online modification to empty    console=true
    Log     Modification from PAL to NULL    console=true
    ${time_start}    Get Time
    Wait Until BTS Is Not Busy
    Perform Delta Recommissioning     ${OUTPUT_DIR}/Delta/${TESTNAME}_set_none.json    connection=${alias}
    Sleep And Display Progress    6   s    #waiting for recommisioning and sas logs that run in background
    ${time_stop}    Get Time

    Log    Check Alarms after recommissioning    console=true
    No Alarm Except Allowed Should Appear On EnB    alias=${alias}

    Log    Check Deregistration packets between BTS and SAS simu: message shouldn't appear    console=true
    ${parsed_log_file}     Parse Sas Log File    log_file_name=${sas_log}     date_start=${time_start}     date_stop=${time_stop}
    Should Not Contain    '${parsed_log_file}'    deregistrationRequest

    ${grantId_list}    Extract Values From Sas Log    log_name=${parsed_log_file}    parameter=grantId
    ...    data_type=heartbeatResponse     packet_amount=1
    Log    Collected Grant Id list: ${grantId_list}    console=true

    Log    Check the further Heartbeat Request message after the first heartbeat    console=true
    Query Sas Log     log_name=${parsed_log_file}    data_type=heartbeatRequest      parameter=cbsdId         value=${cbsdId}
    FOR   ${grant_id}   IN   @{grantId_list}
       Query Sas Log     log_name=${parsed_log_file}    data_type=heartbeatRequest     parameter=grantId       value=${grant_id}
    END

    ${heartbeatRequest_values}   Extract Values From Sas Log    log_name=${parsed_log_file}     parameter=operationState
    ...    data_type=heartbeatRequest     start_from=heartbeatRequest
    Should Contain X Times    container=${heartbeatRequest_values}    item=AUTHORIZED    count=4

    Log    Check eNB and CBSD status     console=true
    No Alarm Except Allowed Should Appear On EnB    alias=${alias}
    BTS Operational State Should Be OnAir    alias=${alias}
    Required CBSD Status Should Be Reached     expected_status=Registered    enb_id=${enb_id}
    ute_admin_infomodel.Query Infomodel    timeout=20    alias=${alias}
    ...    query=every /MRBTS-*/RAT-*/MCTRL-*/BBTOP_M-*/MRBTS_M-*/LNBTS_M-*/CELL_M-* is [stateInfo.proceduralState=regex"(?i)OnAir.*"]
    ute_admin_infomodel.Query Infomodel   timeout=20    alias=${alias}
    ...    query=every /MRBTS-*/RAT-*/MCTRL-*/BBTOP_M-*/MRBTS_M-*/LNBTS_M-*/CELL_M-* is [stateInfo.operationalState=regex"(?i)Enable.*" ]

    Log     Modification from GAA to NULL    console=true
    Wait Until BTS Is Not Busy
    Perform Delta Recommissioning     ${OUTPUT_DIR}/Delta/${TESTNAME}_set_gaa.json   connection=${alias}
    Sleep And Display Progress    60    s    #waiting for recommisioning
    ${time_start}    Get Time
    Wait Until BTS Is Not Busy
    Perform Delta Recommissioning     ${OUTPUT_DIR}/Delta/${TESTNAME}_set_none.json    connection=${alias}
    Sleep And Display Progress    60    s    #waiting for recommisioning and sas logs that run in background
    ${time_stop}    Get Time
    Log    Check Alarms after recommissioning    console=true
    No Alarm Except Allowed Should Appear On EnB    alias=${alias}    #waiting for alarms to appear/disappear

    Log    Check Deregistration packets between BTS and SAS simu    console=true
    ${parsed_log_file}     Parse Sas Log File    log_file_name=${sas_log}     date_start=${time_start}     date_stop=${time_stop}
    Should Contain    '${parsed_log_file}'    deregistrationRequest

    ${grantId_list}    Extract Values From Sas Log    log_name=${parsed_log_file}    parameter=grantId
    ...    data_type=heartbeatResponse    start_from=registrationRequest
    Log    Collected Grant Id list: ${grantId_list}    console=true
    Query Sas Log     log_name=${parsed_log_file}    data_type=deregistrationRequest      parameter=cbsdId      value=${cbsdId}
    Query Sas Log     log_name=${parsed_log_file}    data_type=deregistrationResponse     parameter=response    value=${deregistrationResponse}
    Query Sas Log     log_name=${parsed_log_file}    data_type=deregistrationResponse     parameter=cbsdId      value=${cbsdId}

    Log    Check the registration response message received from SAS simu    console=true
    Query Sas Log     log_name=${parsed_log_file}    data_type=registrationResponse     parameter=response    value=${registrationResponse}

    Log    Check the Spectrum Inquiry Request sent to SAS    console=true
    Query Sas Log     log_name=${parsed_log_file}    data_type=spectrumInquiryRequest     parameter=cbsdId         value=${cbsdId}

    Log    Check the Spectrum Inquiry Response     console=true
    Query Sas Log    log_name=${parsed_log_file}    data_type=spectrumInquiryResponse     parameter=response    value=${spectrumInquiryResponse}

    Log    Check the Grant Request message is sent to SAS    console=true
    Query Sas Log    log_name=${parsed_log_file}    data_type=grantRequest     parameter=cbsdId            value=${cbsdId}

    Log    Check the Grant Response    console=true
    Sas Grantexpiretime Should Be Grater Than Transmitexpiretime    ${parsed_log_file}
    ${grantResponse_values}   Extract Values From Sas Log    log_name=${parsed_log_file}     parameter=channelType
    ...    data_type=grantResponse    packet_amount=1
    Should Contain X Times    container=${grantResponse_values}    item=GAA    count=4
    Query Sas Log     log_name=${parsed_log_file}    data_type=grantResponse     parameter=response       value=${registrationResponse}
    Query Sas Log     log_name=${parsed_log_file}    data_type=grantResponse     parameter=cbsdId         value=${cbsdId}
    FOR   ${grant_id}   IN   @{grantId_list}
       Query Sas Log     log_name=${parsed_log_file}    data_type=debug     value=started a hb timer with 120 seconds for grant ${grant_id}
    END

    Log    Check the Heartbeat Request Message is sent to SAS    console=true
    Query Sas Log     log_name=${parsed_log_file}    data_type=heartbeatRequest     parameter=grantId       value=${grantId_list[0]}
    FOR   ${grant_id}   IN   @{grantId_list}
       Query Sas Log     log_name=${parsed_log_file}    data_type=heartbeatRequest     parameter=grantId       value=${grant_id}
    END
    Query Sas Log     log_name=${parsed_log_file}    data_type=heartbeatRequest     parameter=cbsdId        value=${cbsdId}
    ${heartbeatRequest_values}   Extract Values From Sas Log    log_name=${parsed_log_file}     parameter=operationState
    ...    data_type=heartbeatRequest     start_from=registrationRequest
    Should Contain X Times    container=${heartbeatRequest_values}    item=GRANTED    count=4

    Log    Check eNB and CBSD status     console=true
    No Alarm Except Allowed Should Appear On EnB    alias=${alias}    #waiting for alarms to appear/disappear
    BTS Operational State Should Be OnAir    alias=${alias}
    Required CBSD Status Should Be Reached     expected_status=Registered    enb_id=${enb_id}
    ute_admin_infomodel.Query Infomodel    timeout=60    alias=${alias}
    ...    query=every /MRBTS-*/RAT-*/MCTRL-*/BBTOP_M-*/MRBTS_M-*/LNBTS_M-*/CELL_M-* is [stateInfo.proceduralState=regex"(?i)OnAir.*"]

    Log     __________________________________________________________________________________    console=true
    Log     Verify the behavior of cbrsFreqType online modification from NULL to GAA    console=true
    ${time_start}    Get Time
    Wait Until BTS Is Not Busy
    Perform Delta Recommissioning     ${OUTPUT_DIR}/Delta/${TESTNAME}_set_gaa.json    connection=${alias}
    Sleep And Display Progress    60    s   #waiting for recommisioning and sas logs that run in background
    ${time_stop}    Get Time
    No Alarm Except Allowed Should Appear On EnB    alias=${alias}    #waiting for alarms to appear/disappear

    Log    Check Deregistration packets between BTS and SAS simu    console=true
    ${parsed_log_file}     Parse Sas Log File    log_file_name=${sas_log}     date_start=${time_start}     date_stop=${time_stop}
    ${grantId_list}    Extract Values From Sas Log    log_name=${parsed_log_file}    parameter=grantId    data_type=heartbeatResponse
    ...    start_from=deregistrationResponse    packet_amount=1
    Log    Collected Grant Id list: ${grantId_list}    console=true
    Query Sas Log     log_name=${parsed_log_file}    data_type=deregistrationRequest      parameter=cbsdId      value=${cbsdId}
    Query Sas Log     log_name=${parsed_log_file}    data_type=deregistrationResponse     parameter=response    value=${deregistrationResponse}
    Query Sas Log     log_name=${parsed_log_file}    data_type=deregistrationResponse     parameter=cbsdId      value=${cbsdId}

    Log    Check the registration response message received from SAS simu    console=true
    Query Sas Log     log_name=${parsed_log_file}    data_type=registrationResponse     parameter=response    value=${registrationResponse}

    Log    Check the Spectrum Inquiry Request sent to SAS    console=true
    Query Sas Log     log_name=${parsed_log_file}    data_type=spectrumInquiryRequest     parameter=cbsdId              value=${cbsdId}

    Log    Check the Spectrum Inquiry Response     console=true
    Query Sas Log    log_name=${parsed_log_file}    data_type=spectrumInquiryResponse     parameter=response       value=${spectrumInquiryResponse}

    Log    Check the Grant Request message is sent to SAS    console=true
    Query Sas Log    log_name=${parsed_log_file}    data_type=grantRequest     parameter=cbsdId            value=${cbsdId}

    Log    Check the Grant Response    console=true
    Sas Grantexpiretime Should Be Grater Than Transmitexpiretime    ${parsed_log_file}
    ${grantResponse_values}   Extract Values From Sas Log    log_name=${parsed_log_file}     parameter=channelType
    ...    data_type=grantResponse     start_from=deregistrationRequest    packet_amount=1
    Should Contain X Times    container=${grantResponse_values}    item=GAA    count=4
    Query Sas Log     log_name=${parsed_log_file}    data_type=grantResponse     parameter=response       value=${registrationResponse}
    Query Sas Log     log_name=${parsed_log_file}    data_type=grantResponse     parameter=cbsdId         value=${cbsdId}
    FOR   ${grant_id}   IN   @{grantId_list}
       Query Sas Log     log_name=${parsed_log_file}    data_type=debug     value=started a hb timer with 120 seconds for grant ${grant_id}
    END

    Log    Check the Heartbeat Request Message is sent to SAS    console=true
    FOR   ${grant_id}   IN   @{grantId_list}
       Query Sas Log     log_name=${parsed_log_file}    data_type=heartbeatRequest     parameter=grantId       value=${grant_id}
    END

    Query Sas Log     log_name=${parsed_log_file}    data_type=heartbeatRequest     parameter=cbsdId        value=${cbsdId}
    ${heartbeatRequest_values}   Extract Values From Sas Log    log_name=${parsed_log_file}     parameter=operationState
    ...    data_type=heartbeatRequest     start_from=deregistrationRequest
    Should Contain X Times    container=${heartbeatRequest_values}    item=GRANTED    count=4

    Log    Check eNB and CBSD status     console=true
    No Alarm Except Allowed Should Appear On EnB    alias=${alias}    #waiting for alarms to appear/disappear
    BTS Operational State Should Be OnAir    alias=${alias}
    Required CBSD Status Should Be Reached     expected_status=Registered    enb_id=${enb_id}
    Log    Test scenario passed!    console=true

Set cbrsFreqType As Null For Old SW Release And PAL Is Supported
    [Arguments]   ${alias}    ${sas_log}    ${cbsdId}    ${enb_id}
    ...    ${deregistrationResponse}    ${registrationResponse}    ${spectrumInquiryResponse}
    ...    ${deregistrationResponse}    ${availableChannel}
    Log     __________________________________________________________________________________    console=true
    Log     Verify the behavior of cbrsFreqType online modification to empty    console=true
    Log     Modification from PAL to NULL    console=true
    ${time_start}    Get Time
    Wait Until BTS Is Not Busy
    Perform Delta Recommissioning     ${OUTPUT_DIR}/Delta/${TESTNAME}_set_none.json    connection=${alias}
    Sleep And Display Progress    6   s    #waiting for recommisioning and sas logs that run in background
    ${time_stop}    Get Time

    Log    Check Alarms after recommissioning    console=true
    No Alarm Except Allowed Should Appear On EnB    alias=${alias}

    Log    Check Deregistration packets between BTS and SAS simu: message shouldn't appear    console=true
    ${parsed_log_file}     Parse Sas Log File    log_file_name=${sas_log}     date_start=${time_start}     date_stop=${time_stop}
    Should Not Contain    '${parsed_log_file}'    deregistrationRequest

    ${grantId_list}    Extract Values From Sas Log    log_name=${parsed_log_file}    parameter=grantId
    ...    data_type=heartbeatResponse     packet_amount=1
    Log    Collected Grant Id list: ${grantId_list}    console=true

    Log    Check the further Heartbeat Request message after the first heartbeat    console=true
    Query Sas Log     log_name=${parsed_log_file}    data_type=heartbeatRequest      parameter=cbsdId         value=${cbsdId}
    FOR   ${grant_id}   IN   @{grantId_list}
       Query Sas Log     log_name=${parsed_log_file}    data_type=heartbeatRequest     parameter=grantId       value=${grant_id}
    END

    ${heartbeatRequest_values}   Extract Values From Sas Log    log_name=${parsed_log_file}     parameter=operationState
    ...    data_type=heartbeatRequest     start_from=heartbeatRequest
    Should Contain X Times    container=${heartbeatRequest_values}    item=AUTHORIZED    count=4

    Log    Check eNB and CBSD status     console=true
    No Alarm Except Allowed Should Appear On EnB    alias=${alias}
    BTS Operational State Should Be OnAir    alias=${alias}
    Required CBSD Status Should Be Reached     expected_status=Registered    enb_id=${enb_id}
    ute_admin_infomodel.Query Infomodel    timeout=20    alias=${alias}
    ...    query=every /MRBTS-*/RAT-*/MCTRL-*/BBTOP_M-*/MRBTS_M-*/LNBTS_M-*/CELL_M-* is [stateInfo.proceduralState=regex"(?i)OnAir.*"]
    ute_admin_infomodel.Query Infomodel    timeout=20    alias=${alias}
    ...    query=every /MRBTS-*/RAT-*/MCTRL-*/BBTOP_M-*/MRBTS_M-*/LNBTS_M-*/CELL_M-* is [stateInfo.operationalState=regex"(?i)Enable.*"]

    Log     Modification from GAA to NULL    console=true
    Wait Until BTS Is Not Busy
    Perform Delta Recommissioning     ${OUTPUT_DIR}/Delta/${TESTNAME}_set_gaa.json   connection=${alias}
    Sleep And Display Progress    60    s    #waiting for recommisioning
    ${time_start}    Get Time
    Wait Until BTS Is Not Busy
    Perform Delta Recommissioning     ${OUTPUT_DIR}/Delta/${TESTNAME}_set_none.json    connection=${alias}
    Sleep And Display Progress    60    s    #waiting for recommisioning and sas logs that run in background
    ${time_stop}    Get Time
    Log    Check Alarms after recommissioning    console=true
    No Alarm Except Allowed Should Appear On EnB    alias=${alias}    #waiting for alarms to appear/disappear

    Log    Check Deregistration packets between BTS and SAS simu    console=true
    ${parsed_log_file}     Parse Sas Log File    log_file_name=${sas_log}     date_start=${time_start}     date_stop=${time_stop}
    Should Contain    '${parsed_log_file}'    deregistrationRequest

    ${grantId_list}    Extract Values From Sas Log    log_name=${parsed_log_file}    parameter=grantId
    ...    data_type=heartbeatResponse    start_from=registrationRequest
    Log    Collected Grant Id list: ${grantId_list}    console=true
    Query Sas Log     log_name=${parsed_log_file}    data_type=deregistrationRequest      parameter=cbsdId      value=${cbsdId}
    Query Sas Log     log_name=${parsed_log_file}    data_type=deregistrationResponse     parameter=response    value=${deregistrationResponse}
    Query Sas Log     log_name=${parsed_log_file}    data_type=deregistrationResponse     parameter=cbsdId      value=${cbsdId}

    Log    Check the registration response message received from SAS simu    console=true
    Query Sas Log     log_name=${parsed_log_file}    data_type=registrationResponse     parameter=response    value=${registrationResponse}

    Log    Check the Spectrum Inquiry Request sent to SAS    console=true
    Query Sas Log     log_name=${parsed_log_file}    data_type=spectrumInquiryRequest     parameter=cbsdId              value=${cbsdId}

    Log    Check the Spectrum Inquiry Response     console=true
    Query Sas Log    log_name=${parsed_log_file}    data_type=spectrumInquiryResponse     parameter=response        value=${spectrumInquiryResponse}
    Query Sas Log    log_name=${parsed_log_file}    data_type=spectrumInquiryResponse     parameter=availableChannel    value=${availableChannel}

    Log    Check the Grant Request message is sent to SAS    console=true
    Query Sas Log    log_name=${parsed_log_file}    data_type=grantRequest     parameter=cbsdId            value=${cbsdId}

    Log    Check the Grant Response    console=true
    Sas Grantexpiretime Should Be Grater Than Transmitexpiretime    ${parsed_log_file}
    ${grantResponse_values}   Extract Values From Sas Log    log_name=${parsed_log_file}     parameter=channelType
    ...    data_type=grantResponse    packet_amount=1
    Should Contain X Times    container=${grantResponse_values}    item=PAL    count=4
    Query Sas Log     log_name=${parsed_log_file}    data_type=grantResponse     parameter=response       value=${registrationResponse}
    Query Sas Log     log_name=${parsed_log_file}    data_type=grantResponse     parameter=cbsdId         value=${cbsdId}
    FOR   ${grant_id}   IN   @{grantId_list}
       Query Sas Log     log_name=${parsed_log_file}    data_type=debug     value=started a hb timer with 120 seconds for grant ${grant_id}
    END

    Log    Check the Heartbeat Request Message is sent to SAS    console=true
    Query Sas Log     log_name=${parsed_log_file}    data_type=heartbeatRequest     parameter=grantId       value=${grantId_list[0]}
    FOR   ${grant_id}   IN   @{grantId_list}
       Query Sas Log     log_name=${parsed_log_file}    data_type=heartbeatRequest     parameter=grantId       value=${grant_id}
    END
    Query Sas Log     log_name=${parsed_log_file}    data_type=heartbeatRequest     parameter=cbsdId        value=${cbsdId}
    ${heartbeatRequest_values}   Extract Values From Sas Log    log_name=${parsed_log_file}     parameter=operationState
    ...    data_type=heartbeatRequest     start_from=registrationRequest
    Should Contain X Times    container=${heartbeatRequest_values}    item=GRANTED    count=4

    Log    Check eNB and CBSD status     console=true
    No Alarm Except Allowed Should Appear On EnB    alias=${alias}    #waiting for alarms to appear/disappear
    BTS Operational State Should Be OnAir    alias=${alias}
    Required CBSD Status Should Be Reached     expected_status=Registered    enb_id=${enb_id}
    ute_admin_infomodel.Query Infomodel    timeout=60    alias=${alias}
    ...    query=every /MRBTS-*/RAT-*/MCTRL-*/BBTOP_M-*/MRBTS_M-*/LNBTS_M-*/CELL_M-* is [stateInfo.proceduralState=regex"(?i)OnAir.*"]

    Log     __________________________________________________________________________________    console=true
    Log     Verify the behavior of cbrsFreqType online modification from NULL to GAA    console=true
    ${time_start}    Get Time
    Wait Until BTS Is Not Busy
    Perform Delta Recommissioning     ${OUTPUT_DIR}/Delta/${TESTNAME}_set_gaa.json    connection=${alias}
    Sleep And Display Progress    60    s   #waiting for recommisioning and sas logs that run in background
    ${time_stop}    Get Time
    No Alarm Except Allowed Should Appear On EnB    alias=${alias}    #waiting for alarms to appear/disappear

    Log    Check Deregistration packets between BTS and SAS simu    console=true
    ${parsed_log_file}     Parse Sas Log File    log_file_name=${sas_log}     date_start=${time_start}     date_stop=${time_stop}
    ${grantId_list}    Extract Values From Sas Log    log_name=${parsed_log_file}    parameter=grantId    data_type=heartbeatResponse
    ...    start_from=deregistrationResponse    packet_amount=1
    Log    Collected Grant Id list: ${grantId_list}    console=true
    Query Sas Log     log_name=${parsed_log_file}    data_type=deregistrationRequest      parameter=cbsdId      value=${cbsdId}
    Query Sas Log     log_name=${parsed_log_file}    data_type=deregistrationResponse     parameter=response    value=${deregistrationResponse}
    Query Sas Log     log_name=${parsed_log_file}    data_type=deregistrationResponse     parameter=cbsdId      value=${cbsdId}

    Log    Check the registration response message received from SAS simu    console=true
    Query Sas Log     log_name=${parsed_log_file}    data_type=registrationResponse     parameter=response    value=${registrationResponse}

    Log    Check the Spectrum Inquiry Request sent to SAS    console=true
    Query Sas Log     log_name=${parsed_log_file}    data_type=spectrumInquiryRequest     parameter=cbsdId              value=${cbsdId}

    Log    Check the Spectrum Inquiry Response     console=true
    Query Sas Log    log_name=${parsed_log_file}    data_type=spectrumInquiryResponse     parameter=response        value=${spectrumInquiryResponse}
    Query Sas Log    log_name=${parsed_log_file}    data_type=spectrumInquiryResponse     parameter=availableChannel    value=${availableChannel}

    Log    Check the Grant Request message is sent to SAS    console=true
    Query Sas Log    log_name=${parsed_log_file}    data_type=grantRequest     parameter=cbsdId            value=${cbsdId}

    Log    Check the Grant Response    console=true
    Sas Grantexpiretime Should Be Grater Than Transmitexpiretime    ${parsed_log_file}
    ${grantResponse_values}   Extract Values From Sas Log    log_name=${parsed_log_file}     parameter=channelType    data_type=grantResponse
    ...     start_from=deregistrationRequest    packet_amount=1
    Should Contain X Times    container=${grantResponse_values}    item=GAA    count=4
    Query Sas Log     log_name=${parsed_log_file}    data_type=grantResponse     parameter=response       value=${registrationResponse}
    Query Sas Log     log_name=${parsed_log_file}    data_type=grantResponse     parameter=cbsdId         value=${cbsdId}
    FOR   ${grant_id}   IN   @{grantId_list}
       Query Sas Log     log_name=${parsed_log_file}    data_type=debug     value=started a hb timer with 120 seconds for grant ${grant_id}
    END

    Log    Check the Heartbeat Request Message is sent to SAS    console=true
    FOR   ${grant_id}   IN   @{grantId_list}
       Query Sas Log     log_name=${parsed_log_file}    data_type=heartbeatRequest     parameter=grantId       value=${grant_id}
    END

    Query Sas Log     log_name=${parsed_log_file}    data_type=heartbeatRequest     parameter=cbsdId        value=${cbsdId}
    ${heartbeatRequest_values}   Extract Values From Sas Log    log_name=${parsed_log_file}     parameter=operationState
    ...    data_type=heartbeatRequest     start_from=deregistrationRequest
    Should Contain X Times    container=${heartbeatRequest_values}    item=GRANTED    count=4

    Log    Check eNB and CBSD status     console=true
    No Alarm Except Allowed Should Appear On EnB    alias=${alias}    #waiting for alarms to appear/disappear
    BTS Operational State Should Be OnAir    alias=${alias}
    Required CBSD Status Should Be Reached     expected_status=Registered    enb_id=${enb_id}
    Log    Test scenario passed!    console=true
