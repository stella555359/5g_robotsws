*** Settings ***
Documentation
...    = Author = Aleksandra Dagiel
...    _aleksandra.dagiel@nokia.com_
...    = Maintainer =
...    _aleksandra.chudzik@nokia.com_
...    = Reviewer =
...    _@nokia.com_
...    = Summary =
...    N/A
...    = Pre - Requirements =
...    _robotlte/config/<testline name>/__init__.py and site specific keyword_
...    = Additional Info =
...    Test in progress

*** Keywords ***
LTE4757_A_FeVe_02_Verify_all_cells_are_configured_as_PAL_if_cbrsFreqType_as_PAL_with_adequate_different_PAL_spectrum

   [Documentation]    PAL is not supportred for SAS ver 2 yet. All channels that are granted should be GAA. Not supported for
    ...    this TC, always fail is expected for ver 2.0.
    [Arguments]     ${start_sas_version}=2
    IF  ${start_sas_version}==2
        LTE4757_A_FeVe_02_Verify_all_cells_are_configured_as_PAL_if_cbrsFreqType_as_PAL_with_adequate_different_PAL_spectrum_PAL_not_supported
    ELSE
        LTE4757_A_FeVe_02_Verify_all_cells_are_configured_as_PAL_if_cbrsFreqType_as_PAL_with_adequate_different_PAL_spectrum_PAL_supported
    END

LTE4757_A_FeVe_02_Verify_all_cells_are_configured_as_PAL_if_cbrsFreqType_as_PAL_with_adequate_different_PAL_spectrum_PAL_not_supported
    [Timeout]     30min
    Log    Setting environment and variables for test...   console=true
    Wait Until BTS Is Not Busy
    Wait Until Keyword Succeeds    5x   30s    Enable CBRS Feature On eNB
    ${alias}   Set Variable    RAT_1ST
    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    ${spectrumInquiryResponse}   Load JSON From File    ${CURDIR}/Data/Common/spectrumInquiryResponse.json

    ${registrationResponse}   Load JSON From File    ${CURDIR}/Data/Common/registrationResponse.json

    ${responseCode_0}   Load JSON From File    ${CURDIR}/Data/Common/response_code_0.json

    Replace Variables In File    file_path=${CURDIR}/Data/Common/set_pal.json
    ...                 file_destination=${OUTPUT_DIR}/Delta/${TESTNAME}_set_pal.json
    ...                 enb_id=${enb_id}
    ${change_supported_spectrum_delta}=
    ...    Replace Variables In File     file_path=${CURDIR}/Data/Common/supportedSpectrumV2_65535.json
    ...                                  file_destination=${OUTPUT_DIR}/Delta/${TESTNAME}_supportedSpectrumV2_65535.json
    ...                                  enb_id=${enb_id}

    Wait Until BTS Is Not Busy
    Wait Until Keyword Succeeds    5x   30s    Perform Delta Recommissioning    ${change_supported_spectrum_delta}    connection=${alias}
    Sleep    60s
    Log    Configuring SAS: [pal_reserved_channel = 3590-3630]...   console=true
    Kill All SAS Processes
    ${sas_pid}    ${sas_log}   Start SAS Process   config=${CURDIR}/Data/FeVe_02/SAS_config_3590-3630.conf
    Sleep    60s
    ${cbsdId}   Wait Until Keyword Succeeds    20x    30s    Get CBSD Id From Infomodel     #waiting for CBRS to assign CbsdId
    Log    Assigned CDSD Id: ${cbsdId}    console=true
    Send Command To SAS Manager    alias=default      command=PPA_add ${cbsdId}

    Log    Setting PAL on eNB and collecting logs ...   console=true
    ${time_start}    Get Time
    Wait Until BTS Is Not Busy
    Wait Until Keyword Succeeds    5x   30s    Perform Delta Recommissioning     ${OUTPUT_DIR}/Delta/${TESTNAME}_set_pal.json    connection=${alias}
    Wait Until Keyword Succeeds    10x    20s    BTS Operational State Should Be OnAir    alias=${alias}
    No Alarm Except Allowed Should Appear On EnB    alias=${alias}
    Sleep    80s
    ${time_stop}    Get Time

    Log    Parsing Logs And Extracting Searched Values...   console=true
    ${parsed_log_file}     Parse Sas Log File    log_file_name=${sas_log}    date_start=${time_start}     date_stop=${time_stop}
    ${grantId_list}        Extract Values From Sas Log    log_name=${parsed_log_file}    parameter=grantId    data_type=heartbeatResponse
    ...    start_from=deregistrationRequest    packet_amount=1

    Log    Check the registration response message received from SAS simu    console=true
    Query Sas Log     log_name=${parsed_log_file}    data_type=registrationResponse     parameter=response    value=${registrationResponse}

    Log    Check the Spectrum Inquiry Request sent to SAS    console=true
    Query Sas Log     log_name=${parsed_log_file}    data_type=spectrumInquiryRequest     parameter=cbsdId
    ...    value=${cbsdId}     start_from=deregistrationRequest

    Log    Check the Spectrum Inquiry Response     console=true
    Query Sas Log    log_name=${parsed_log_file}    data_type=spectrumInquiryResponse     parameter=response
    ...    value=${spectrumInquiryResponse}     start_from=registrationRequest

    Log    Check the Grant Request message is sent to SAS    console=true
    Query Sas Log    log_name=${parsed_log_file}    data_type=grantRequest     parameter=cbsdId
    ...   value=${cbsdId}     start_from=deregistrationRequest

    Log    Check the Grant Response    console=true
    Sas Grantexpiretime Should Be Grater Than Transmitexpiretime    ${parsed_log_file}
    ${grantResponse_values}   Extract Values From Sas Log    log_name=${parsed_log_file}     parameter=channelType
    ...    data_type=grantResponse    start_from=deregistrationRequest    packet_amount=2
    Log    channelType:${grantResponse_values}    console=true
    Should Contain X Times    container=${grantResponse_values}    item=GAA    count=4
    Query Sas Log     log_name=${parsed_log_file}    data_type=grantResponse     parameter=response
    ...    value=${registrationResponse}     start_from=deregistrationRequest
    Query Sas Log     log_name=${parsed_log_file}    data_type=grantResponse     parameter=cbsdId
    ...     value=${cbsdId}    start_from=deregistrationRequest
    FOR   ${grant_id}   IN   @{grantId_list}
       Query Sas Log     log_name=${parsed_log_file}    data_type=debug     value=started a hb timer with 120 seconds for grant ${grant_id}
    END

    Log    Check the Heartbeat Request Message is sent to SAS    console=true
    FOR   ${grant_id}   IN   @{grantId_list}
       Query Sas Log     log_name=${parsed_log_file}    data_type=heartbeatRequest     parameter=grantId
       ...     value=${grant_id}    start_from=deregistrationRequest
    END
    Query Sas Log     log_name=${parsed_log_file}    data_type=heartbeatRequest    parameter=cbsdId
    ...    value=${cbsdId}    start_from=deregistrationRequest
    ${heartbeatRequest_values}   Extract Values From Sas Log    log_name=${parsed_log_file}     parameter=operationState
    ...    data_type=heartbeatRequest     start_from=deregistrationRequest    packet_amount=2
    Should Contain X Times    container=${heartbeatRequest_values}    item=GRANTED    count=4

    Log    Check the Heartbeat Response message and the further Heartbeat Request message after the first heartbeat     console=true
    Query Sas Log     log_name=${parsed_log_file}    data_type=heartbeatResponse     parameter=cbsdId
    ...    value=${cbsdId}    start_from=registrationRequest
    Query Sas Log     log_name=${parsed_log_file}    data_type=heartbeatResponse     parameter=response
    ...    value=${responseCode_0}    start_from=registrationRequest
    FOR   ${grant_id}   IN   @{grantId_list}
       Query Sas Log     log_name=${parsed_log_file}    data_type=heartbeatResponse     parameter=grantId
       ...    value=${grant_id}    start_from=registrationRequest
    END
    Query Sas Log     log_name=${parsed_log_file}    data_type=heartbeatRequest      parameter=cbsdId
    ...    value=${cbsdId}     start_from=heartbeatResponse
    Should Contain X Times    container=${heartbeatRequest_values}    item=AUTHORIZED    count=4

    Log    Check eNB and CBSD status     console=true
    Required CBSD Status Should Be Reached     expected_status=Registered    enb_id=${enb_id}
    No Alarm Except Allowed Should Appear On EnB    alias=${alias}
    BTS Operational State Should Be OnAir    alias=${alias}
    ute_admin_infomodel.Query Infomodel    timeout=20    alias=RAT_1ST
    ...    query=every /MRBTS-*/RAT-*/MCTRL-*/BBTOP_M-*/MRBTS_M-*/LNBTS_M-*/CELL_M-* is [stateInfo.proceduralState=regex"(?i)OnAir.*"]
    ute_admin_infomodel.Query Infomodel    timeout=20    alias=RAT_1ST
    ...    query=every /MRBTS-*/RAT-*/MCTRL-*/BBTOP_M-*/MRBTS_M-*/LNBTS_M-*/CELL_M-* is [stateInfo.operationalState=regex"(?i)Enable.*"]
    Log    Scenario passed    console=true
    [Teardown]    Teardown_LTE4757_A_FeVe_02_Verify_all_cells_are_configured_as_PAL_if_cbrsFreqType_as_PAL_with_adequate_PAL_spectrum



LTE4757_A_FeVe_02_Verify_all_cells_are_configured_as_PAL_if_cbrsFreqType_as_PAL_with_adequate_different_PAL_spectrum_PAL_supported
    [Documentation]    LTE4757 Support PAL Mode CBRS Service for Macro Site (Airscale) introduced PAL (Priority Access License)
    ...    to support in commercial deployment of CBRS as one of CBRS spectrum allocation type.
    ...    PAL is licensed by auction. PALs carriers will be within CBRS band (Band 48). PAL reserved channel
    ...    in the range of 3550-3650Mhz. one PAL =10MHz channel in one census tract.
    ...    The purpose of this test case is to check when there are adequate PAL spectrums for all cells request spectrums,
    ...    and the request spectrums are not among purchased PAL spectrums, the PAL mode CBRS service could be provided
    ...    successfully with appropriate purchased PAL spectrums after the CBSD is registered.
    ...    1) Every json file from path ${CURDIR}/Data/ used in keywords Load JSON From File
    ...    serves as a pattern of message searched in SAS logs (passed as a variable ${parsed_log_file}).
    ...    2) SFS/CFAMrequirement: OM_LTE_SFS_RNL.19554; OM_LTE_SFS_RNL.19577
    [Timeout]    30min

    Log    Setting environment and variables for test...   console=true
    Wait Until BTS Is Not Busy
    Wait Until Keyword Succeeds    5x   30s    Enable CBRS Feature On eNB
    ${alias}   Set Variable    RAT_1ST
    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    ${spectrumInquiryResponse}   Load JSON From File    ${CURDIR}/Data/Common/spectrumInquiryResponse.json
    ${availableChannel}     Replace Variables In File     file_path=${CURDIR}/Data/FeVe_02/availableChannel.json
    ...                                  file_destination=${OUTPUT_DIR}/Delta/${TESTNAME}_availableChannel.json
    ...                                  enb_id=${enb_id}
    ${availableChannel}   Load JSON From File     ${availableChannel}

    ${registrationResponse}   Load JSON From File    ${CURDIR}/Data/Common/registrationResponse.json

    ${responseCode_0}   Load JSON From File    ${CURDIR}/Data/Common/response_code_0.json

    Replace Variables In File    file_path=${CURDIR}/Data/Common/set_pal.json
    ...                 file_destination=${OUTPUT_DIR}/Delta/${TESTNAME}_set_pal.json
    ...                 enb_id=${enb_id}
    ${change_supported_spectrum_delta}=
    ...    Replace Variables In File     file_path=${CURDIR}/Data/Common/supportedSpectrumV2_65535.json
    ...                                  file_destination=${OUTPUT_DIR}/Delta/${TESTNAME}_supportedSpectrumV2_65535.json
    ...                                  enb_id=${enb_id}

    Wait Until BTS Is Not Busy
    Wait Until Keyword Succeeds    5x   30s    Perform Delta Recommissioning    ${change_supported_spectrum_delta}    connection=${alias}
    Sleep    60s
    Log    Configuring SAS: [pal_reserved_channel = 3590-3630]...   console=true
    Kill All SAS Processes
    ${sas_pid}    ${sas_log}   Start SAS Process    config=${CURDIR}/Data/FeVe_02/SAS_config_3590-3630.conf
    Sleep    60s
    ${cbsdId}   Wait Until Keyword Succeeds    20x    30s    Get CBSD Id From Infomodel     #waiting for CBRS to assign CbsdId
    Log    Assigned CDSD Id: ${cbsdId}    console=true
    Send Command To SAS Manager    alias=default      command=PPA_add ${cbsdId}

    Log    Setting PAL on eNB and collecting logs ...   console=true
    ${time_start}    Get Time
    Wait Until BTS Is Not Busy
    Wait Until Keyword Succeeds    5x   30s    Perform Delta Recommissioning     ${OUTPUT_DIR}/Delta/${TESTNAME}_set_pal.json    connection=${alias}
    Wait Until Keyword Succeeds    10x    20s    BTS Operational State Should Be OnAir    alias=${alias}
    No Alarm Except Allowed Should Appear On EnB    alias=${alias}
    Sleep    80s
    ${time_stop}    Get Time

    Log    Parsing Logs And Extracting Searched Values...   console=true
    ${parsed_log_file}     Parse Sas Log File    log_file_name=${sas_log}    date_start=${time_start}     date_stop=${time_stop}
    ${grantId_list}        Extract Values From Sas Log    log_name=${parsed_log_file}    parameter=grantId    data_type=heartbeatResponse
    ...    start_from=deregistrationRequest    packet_amount=1

    Log    Check the registration response message received from SAS simu    console=true
    Query Sas Log     log_name=${parsed_log_file}    data_type=registrationResponse     parameter=response    value=${registrationResponse}

    Log    Check the Spectrum Inquiry Request sent to SAS    console=true
    Query Sas Log     log_name=${parsed_log_file}    data_type=spectrumInquiryRequest     parameter=cbsdId
    ...    value=${cbsdId}     start_from=deregistrationRequest

    Log    Check the Spectrum Inquiry Response     console=true
    Query Sas Log    log_name=${parsed_log_file}    data_type=spectrumInquiryResponse     parameter=response
    ...    value=${spectrumInquiryResponse}     start_from=registrationRequest
    Query Sas Log    log_name=${parsed_log_file}    data_type=spectrumInquiryResponse     parameter=availableChannel
    ...    value=${availableChannel}       start_from=registrationRequest

    Log    Check the Grant Request message is sent to SAS    console=true
    Query Sas Log    log_name=${parsed_log_file}   data_type=grantRequest     parameter=cbsdId    value=${cbsdId}    start_from=deregistrationRequest

    Log    Check the Grant Response    console=true
    Sas Grantexpiretime Should Be Grater Than Transmitexpiretime    ${parsed_log_file}
    ${grantResponse_values}   Extract Values From Sas Log    log_name=${parsed_log_file}     parameter=channelType
    ...    data_type=grantResponse    start_from=deregistrationRequest    packet_amount=2
    Log    channelType:${grantResponse_values}    console=true
    Should Contain X Times    container=${grantResponse_values}    item=PAL    count=4
    Query Sas Log     log_name=${parsed_log_file}    data_type=grantResponse     parameter=response
    ...    value=${registrationResponse}     start_from=deregistrationRequest
    Query Sas Log   log_name=${parsed_log_file}    data_type=grantResponse    parameter=cbsdId    value=${cbsdId}    start_from=deregistrationRequest
    FOR   ${grant_id}   IN   @{grantId_list}
       Query Sas Log     log_name=${parsed_log_file}    data_type=debug     value=started a hb timer with 120 seconds for grant ${grant_id}
    END

    Log    Check the Heartbeat Request Message is sent to SAS    console=true
    FOR   ${grant_id}   IN   @{grantId_list}
       Query Sas Log     log_name=${parsed_log_file}    data_type=heartbeatRequest     parameter=grantId
       ...    value=${grant_id}    start_from=deregistrationRequest
    END
    Query Sas Log     log_name=${parsed_log_file}    data_type=heartbeatRequest    parameter=cbsdId
    ...    value=${cbsdId}    start_from=deregistrationRequest
    ${heartbeatRequest_values}   Extract Values From Sas Log    log_name=${parsed_log_file}     parameter=operationState
    ...    data_type=heartbeatRequest     start_from=deregistrationRequest    packet_amount=2
    Should Contain X Times    container=${heartbeatRequest_values}    item=GRANTED    count=4

    Log    Check the Heartbeat Response message and the further Heartbeat Request message after the first heartbeat     console=true
    Query Sas Log     log_name=${parsed_log_file}    data_type=heartbeatResponse     parameter=cbsdId
    ...    value=${cbsdId}    start_from=registrationRequest
    Query Sas Log     log_name=${parsed_log_file}    data_type=heartbeatResponse     parameter=response
    ...    value=${responseCode_0}    start_from=registrationRequest
    FOR   ${grant_id}   IN   @{grantId_list}
       Query Sas Log    log_name=${parsed_log_file}    data_type=heartbeatResponse    parameter=grantId
       ...    value=${grant_id}    start_from=registrationRequest
    END
    Query Sas Log     log_name=${parsed_log_file}    data_type=heartbeatRequest    parameter=cbsdId
    ...    value=${cbsdId}    start_from=heartbeatResponse
    Should Contain X Times    container=${heartbeatRequest_values}    item=AUTHORIZED    count=4

    Log    Check eNB and CBSD status     console=true
    Required CBSD Status Should Be Reached     expected_status=Registered    enb_id=${enb_id}
    No Alarm Except Allowed Should Appear On EnB    alias=${alias}
    BTS Operational State Should Be OnAir    alias=${alias}
    ute_admin_infomodel.Query Infomodel    timeout=20    alias=RAT_1ST
    ...    query=every /MRBTS-*/RAT-*/MCTRL-*/BBTOP_M-*/MRBTS_M-*/LNBTS_M-*/CELL_M-* is [stateInfo.proceduralState=regex"(?i)OnAir.*"]
    ute_admin_infomodel.Query Infomodel    timeout=20    alias=RAT_1ST
    ...    query=every /MRBTS-*/RAT-*/MCTRL-*/BBTOP_M-*/MRBTS_M-*/LNBTS_M-*/CELL_M-* is [stateInfo.operationalState=regex"(?i)Enable.*"]
    Log    Scenario passed    console=true
    [Teardown]    Teardown_LTE4757_A_FeVe_02_Verify_all_cells_are_configured_as_PAL_if_cbrsFreqType_as_PAL_with_adequate_PAL_spectrum


Teardown_LTE4757_A_FeVe_02_Verify_all_cells_are_configured_as_PAL_if_cbrsFreqType_as_PAL_with_adequate_PAL_spectrum
    Log    Teardown tor TestCase ${TESTNAME} started...    console=true
    ${alias}   Set Variable    RAT_1ST
    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    ${default_param_delta}=
    ...    Replace Variables In File     file_path=${CURDIR}/Data/FeVe_02/return_def_parameters_V2.json
    ...                                  file_destination=${OUTPUT_DIR}/Delta/${TESTNAME}_return_def_parameters_V2.json
    ...                                  enb_id=${enb_id}

    Get SAS Logs To Logs Dir    alias=default
    Log    Teardown: Set changed parameters to default values...    console=true
    Wait Until BTS Is Not Busy
    Wait Until Keyword Succeeds    10x   10s    Perform Delta Recommissioning
    ...    ${default_param_delta}   connection=${alias}      #waiting for commissioning in case the previous one is still ongoing
    Log    Teardown: Check alarms and operational state on eNB...    console=true
    Sleep    60s
    No Alarm Except Allowed Should Appear On EnB    alias=${alias}     #waiting for alarms to appear/disappear
    Wait Until Keyword Succeeds    10x   3s    ute_admin_infomodel.Query Infomodel
    ...     query=every /MRBTS-*/RAT-*/MCTRL-*/BBTOP_M-*/MRBTS_M-*/LNBTS_M-*/CELL_M-* is [stateInfo.proceduralState=regex"(?i)OnAir.*"]
    ...     timeout=20    alias=${alias}       #waiting for onair cells
    ute_admin_infomodel.Query Infomodel
    ...    query=every /MRBTS-*/RAT-*/MCTRL-*/BBTOP_M-*/MRBTS_M-*/LNBTS_M-*/CELL_M-* is [stateInfo.operationalState=regex"(?i)Enable.*"]
    ...    timeout=20    alias=${alias}

