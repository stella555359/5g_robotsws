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
LTE4757_A_FeVe_04_Verify_the_maximum_cells_are_configured_as_PAL_if_cbrsFreqType_as_PAL
    [Documentation]    1) LTE4757 Support PAL Mode CBRS Service for Macro Site (Airscale) introduced
    ...    PAL (Priority Access License) to support in commercial deployment of CBRS as one of CBRS spectrum allocation type.
    ...    PAL is licensed by auction. PALs carriers will be within CBRS band (Band 48). PAL reserved channel
    ...    in the range of 3550-3650Mhz. one PAL =10MHz channel in one census tract.
    ...    Feature activation should be together with LTE3663 GAA operation.
    ...    2) Every json file from path ${CURDIR}/Data/ used in keywords Load JSON From File
    ...    serves as a pattern of message searched in SAS logs (passed as a variable ${parsed_log_file}).
    ...    3) SFS/CFAMrequirement: OM_LTE_SFS_RNL.19554; OM_LTE_SFS_RNL.19577
    ...    4) The purpose of this test case is to check when there are enough PAL spectrums for all cells request spectrum,
    ...    but the request spectrums are not the same as purchased PAL spectrums, the PAL mode CBRS service could be
    ...    provided successfully with available PAL spectrums after the CBSD is registered.
    [Timeout]    15min

    ${alias}   Set Variable    RAT_1ST
    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    ${enb_root_user}            Set Variable    toor4nsn
    ${enb_root_pass}            Set Variable    oZPS0POrRieRtu
    ${bts_side}   Set Variable    *
    Synchronize Time Between VM And eNB In Case Of Difference
    Log    Setting environment and variables for test...   console=true
    ${version}   Get Version Of SupportedSpectrum    ${alias}
    ${file_version}  Set Variable If    '${version[0]}'=='supportedSpectrumV2'    return_def_parameters_V2.json    return_parameters.json
    Wait Until BTS Is Not Busy
    Enable CBRS Feature On eNB
    ${registrationResponse}   Load JSON From File    ${CURDIR}/Data/Common/registrationResponse.json
    ${spectrumInquiryRequest_inquiredSpectrum}   Load JSON From File    ${CURDIR}/Data/FeVe_04/spectrumInquiryRequest_inquiredSpectrum.json
    ${spectrumInquiryResponse}   Load JSON From File    ${CURDIR}/Data/Common/spectrumInquiryResponse.json
    ${availableChannel}          Load JSON From File    ${CURDIR}/Data/FeVe_04/availableChannel.json
    ${responseCode_0}   Load JSON From File    ${CURDIR}/Data/Common/response_code_0.json
    Replace Variables In File     file_path=${CURDIR}/Data/FeVe_04/${file_version}
    ...                        file_destination=${OUTPUT_DIR}/Delta/${TESTNAME}_${file_version}
    ...                        enb_id=${enb_id}
    Replace Variables In File    file_path=${CURDIR}/Data/Common/set_pal.json
    ...                 file_destination=${OUTPUT_DIR}/Delta/${TESTNAME}_set_pal.json
    ...                 enb_id=${enb_id}
    Log    Configuring SAS: [pal_reserved_channel = 3550-3580]...   console=true
    Kill All SAS Processes
    ${sas_pid}    ${sas_log}   Start SAS Process    config=${CURDIR}/Data/FeVe_04/SAS_config.conf
    ${cbsdId}   Wait Until Keyword Succeeds    20x    30s    Get CBSD Id From Infomodel     #waiting for CBRS to assign CbsdId
    Sleep   120    #to be sure that all SAS messages are initiated before next test step

    Log    Assigned CDSD Id: ${cbsdId}    console=true
    Send Command To SAS Manager    alias=default      command=PPA_add ${cbsdId}

    Log    Setting PAL on eNB and collecting logs ...   console=true
    Wait Until BTS Is Not Busy
    ${time_start}    Get Time
    Perform Delta Recommissioning     ${OUTPUT_DIR}/Delta/${TESTNAME}_set_pal.json    connection=${alias}
    Wait Until Keyword Succeeds    10x    20s    BTS Operational State Should Be OnAir    alias=${alias}
    No Alarm Except Allowed Should Appear On EnB    alias=${alias}
    Sleep    30s
    ${time_stop}    Get Time

    Log    Parsing Logs And Extracting Searched Values...   console=true
    ${parsed_log_file}     Parse Sas Log File    log_file_name=${sas_log}   date_start=${time_start}     date_stop=${time_stop}
    ${grantId_list}        Extract Values From Sas Log    log_name=${parsed_log_file}    parameter=grantId    data_type=heartbeatResponse
    ...    packet_amount=1    start_from=deregistrationRequest

    Log    Check the registration response message received from SAS simu    console=true
    Query Sas Log     log_name=${parsed_log_file}    data_type=registrationResponse     parameter=response    value=${registrationResponse}

    Log    Check the Spectrum Inquiry Request sent to SAS    console=true
    Query Sas Log     log_name=${parsed_log_file}    data_type=spectrumInquiryRequest     parameter=inquiredSpectrum
    ...    value=${spectrumInquiryRequest_inquiredSpectrum}    start_from=registrationRequest
    Query Sas Log     log_name=${parsed_log_file}    data_type=spectrumInquiryRequest     parameter=cbsdId
    ...   value=${cbsdId}     start_from=registrationRequest

    Log    Check the Spectrum Inquiry Response     console=true
    Query Sas Log    log_name=${parsed_log_file}    data_type=spectrumInquiryResponse     parameter=response
    ...    value=${spectrumInquiryResponse}     start_from=deregistrationRequest
    Query Sas Log    log_name=${parsed_log_file}    data_type=spectrumInquiryResponse     parameter=availableChannel
    ...    value=${availableChannel}       start_from=deregistrationRequest

    Log    Check the Grant Request message is sent to SAS    console=true
    Query Sas Log    log_name=${parsed_log_file}    data_type=grantRequest     parameter=cbsdId
    ...    value=${cbsdId}     start_from=deregistrationRequest

    Log    Check the Grant Response    console=true
    Sas Grantexpiretime Should Be Grater Than Transmitexpiretime    ${parsed_log_file}
    ${grantResponse_values}   Extract Values From Sas Log    log_name=${parsed_log_file}     parameter=channelType
    ...    data_type=grantResponse    start_from=deregistrationRequest    packet_amount=2

    Log   channelType:${grantResponse_values}    console=true
    Should Contain X Times    container=${grantResponse_values}    item=PAL    count=4
    Query Sas Log     log_name=${parsed_log_file}    data_type=grantResponse     parameter=response
    ...    value=${registrationResponse}     start_from=deregistrationRequest
    Query Sas Log     log_name=${parsed_log_file}    data_type=grantResponse     parameter=cbsdId
    ...    value=${cbsdId}    start_from=registrationRequest      start_from=deregistrationRequest
    FOR   ${grant_id}   IN   @{grantId_list}
       Query Sas Log     log_name=${parsed_log_file}    data_type=debug     value=started a hb timer with 120 seconds for grant ${grant_id}
    END

    Log    Check the Heartbeat Request Message is sent to SAS    console=true
    FOR   ${grant_id}   IN   @{grantId_list}
       Query Sas Log     log_name=${parsed_log_file}    data_type=heartbeatRequest     parameter=grantId
       ...    value=${grant_id}    start_from=deregistrationRequest
    END
    Query Sas Log     log_name=${parsed_log_file}    data_type=heartbeatRequest    parameter=cbsdId
    ...   value=${cbsdId}    start_from=deregistrationRequest
    ${heartbeatRequest_values}   Extract Values From Sas Log    log_name=${parsed_log_file}     parameter=operationState
    ...    data_type=heartbeatRequest     start_from=deregistrationRequest    packet_amount=2
    Log    HB collected list: ${heartbeatRequest_values}    console=true
    Should Contain X Times    container=${heartbeatRequest_values}    item=GRANTED    count=4

    Log    Check the Heartbeat Response messages     console=true
    Query Sas Log     log_name=${parsed_log_file}    data_type=heartbeatResponse     parameter=cbsdId
    ...   value=${cbsdId}    start_from=deregistrationRequest
    Query Sas Log     log_name=${parsed_log_file}    data_type=heartbeatResponse     parameter=response
    ...    value=${responseCode_0}    start_from=deregistrationRequest
    FOR   ${grant_id}   IN   @{grantId_list}
       Query Sas Log     log_name=${parsed_log_file}    data_type=heartbeatResponse     parameter=grantId
       ...    value=${grant_id}    start_from=registrationRequest
    END
    Query Sas Log     log_name=${parsed_log_file}    data_type=heartbeatRequest      parameter=cbsdId
    ...     value=${cbsdId}     start_from=heartbeatResponse
    Should Contain X Times    container=${heartbeatRequest_values}    item=AUTHORIZED    count=4

    Log    Check eNB and CBSD status     console=true
    Required CBSD Status Should Be Reached     expected_status=Registered    enb_id=${enb_id}
    ute_admin_infomodel.Query Infomodel    timeout=20    alias=${alias}
    ...    query=every /MRBTS-*/RAT-*/MCTRL-*/BBTOP_M-*/MRBTS_M-*/LNBTS_M-*/CELL_M-* is [stateInfo.proceduralState=regex"(?i)OnAir.*"]
    Log    Scenario passed!!   console=true
    [Teardown]         Run Keywords
    ...    Get SAS Logs To Logs Dir    alias=default    AND
    ...    Wait Until BTS Is Not Busy    AND
    ...    Perform Delta Recommissioning    ${OUTPUT_DIR}/Delta/${TESTNAME}_${file_version}   skip_parameter_relation_errors=${TRUE}
    ...    connection=${alias}

Get Version Of SupportedSpectrum
    [Arguments]    ${alias}
    ${CBSD_parameters}   ute_admin_infomodel.Query Infomodel
    ...    query=get list /MRBTS-*/RAT-*/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-*/LNBTS_A-*/CBSD_A-1    alias=${alias}
    ${keys}   Get Dictionary Keys    ${CBSD_parameters[0]}
    ${version}   Get Matches    ${keys}    supported*
    RETURN    ${version}
