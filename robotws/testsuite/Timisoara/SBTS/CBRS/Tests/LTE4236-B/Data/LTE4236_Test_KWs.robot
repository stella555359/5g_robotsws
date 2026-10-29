*** Settings ***
Documentation
...    = Author =
...    Lukasz.lechowicz@nokia.com
...    = Maintainer =
...    Lukasz.lechowicz@nokia.com
...    = Summary =
...    Set of Keywords used for LTE5281-specific System Testing

Library    Collections

*** Keywords ***

Verify Registration Procedure
    [Arguments]        ${time_start}    ${time_stop}    ${sas_log_path}    ${enb_id}
    [Documentation]    Extracts values for grantResponse:grantId for each CBSD cell from SAS log
    ...                verifies if grant procedure has been executed only for valid frequencies.
    ...                Parameters:
    ...                time_start - timestamp for SAS log parser
    ...                time_stop - timestamp for SAS log parser
    ...                sas_log_path - path of the SAS_Sim.log file
    ${bts_side}   set variable        ${1}
    ${cbsd_info_scfc}   ute_admin_infomodel.Query Infomodel    timeout=30    alias=RAT_1ST
    ...    query=get object /MRBTS-*/RAT-*/BTS_L-${bts_side}/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-${enb_id}/LNBTS_A-${enb_id}/CBSD_A-*
    ${cbsd_info_runtime}   ute_admin_infomodel.Query Infomodel        timeout=30    alias=RAT_1ST
    ...    query=get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/LNBTS_R-${enb_id}/CBSD_R-1

    ${userId}             Get From Dictionary    ${cbsd_info_scfc}    userId
    ${fccId}             Get From Dictionary    ${cbsd_info_scfc}    fccId
    ${assignedCbsdId}     Get From Dictionary    ${cbsd_info_runtime}    assignedCbsdId
    ${cbsdCategory}       Get From Dictionary    ${cbsd_info_runtime}    cbsdCategory
    ${cbsdSerialNumber}   Get From Dictionary    ${cbsd_info_runtime}    cbsdSerialNumber

    ${parsed_log_file}             Parse Sas Log File    log_file_name=${sas_log_path}     date_start=${time_start}     date_stop=${time_stop}

    ${registration_request_userId}   Extract Values From Sas Log    log_name=${parsed_log_file}
    ...    parameter=userId    data_type=registrationRequest
    ${registration_request_fccId}   Extract Values From Sas Log    log_name=${parsed_log_file}
    ...    parameter=fccId    data_type=registrationRequest
    ${registration_request_cbsdSerialNumber}   Extract Values From Sas Log    log_name=${parsed_log_file}
    ...    parameter=cbsdSerialNumber    data_type=registrationRequest
    ${registration_request_cbsdCategory}   Extract Values From Sas Log    log_name=${parsed_log_file}
    ...    parameter=cbsdCategory    data_type=registrationRequest

    ${registration_response_responseCode}   Extract Values From Sas Log    log_name=${parsed_log_file}
    ...    parameter=responseCode    data_type=registrationResponse

    Should Be Equal    ${registration_request_userId[0]}    ${userId}
    Should Be Equal    ${registration_request_fccId[0]}    ${fccId}
    Should Be Equal    ${registration_request_cbsdSerialNumber[0]}    ${cbsdSerialNumber}
    Should Be Equal    ${registration_request_cbsdCategory[0]}    B
    Should Be Equal    ${registration_response_responseCode[0]}    ${0}


Verify SpectrumInquiry Procedure
    [Arguments]        ${time_start}    ${time_stop}    ${sas_log_path}    ${enb_id}
    [Documentation]    Extracts values for grantResponse:grantId for each CBSD cell from SAS log
    ...                verifies if grant procedure has been executed only for valid frequencies.
    ...                Parameters:
    ...                time_start - timestamp for SAS log parser
    ...                time_stop - timestamp for SAS log parser
    ...                sas_log_path - path of the SAS_Sim.log file

    ${cbsd_info_runtime}   ute_admin_infomodel.Query Infomodel    timeout=30    alias=RAT_1ST
    ...    query=get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/LNBTS_R-${enb_id}/CBSD_R-1
    ${assignedCbsdId}     Get From Dictionary    ${cbsd_info_runtime}    assignedCbsdId

    ${parsed_log_file}             Parse Sas Log File    log_file_name=${sas_log_path}     date_start=${time_start}     date_stop=${time_stop}

    ${spectrumInquiryRequest_cbsdId}   Extract Values From Sas Log    log_name=${parsed_log_file}     parameter=cbsdId
    ...    data_type=spectrumInquiryRequest    packet_amount=1
    ${spectrumInquiryRequest_inquiredSpectrum}   Extract Values From Sas Log    log_name=${parsed_log_file}     parameter=inquiredSpectrum
    ...    data_type=spectrumInquiryRequest    packet_amount=1
    ${spectrumInquiryRequest_inquiredSpectrum_count}         Get Length   ${spectrumInquiryRequest_inquiredSpectrum[0]}
    ${spectrumInquiryResponse_cbsdId}   Extract Values From Sas Log    log_name=${parsed_log_file}     parameter=cbsdId
    ...    data_type=spectrumInquiryResponse    packet_amount=1
    ${spectrumInquiryResponse_availableChannels}   Extract Values From Sas Log    log_name=${parsed_log_file}     parameter=availableChannel
    ...    data_type=spectrumInquiryResponse    packet_amount=1
    ${spectrumInquiryResponse_availableChannels_count}         Get Length   ${spectrumInquiryResponse_availableChannels[0]}

    ${availableChannels_list}   create list
    FOR        ${i}    in range    ${spectrumInquiryResponse_availableChannels_count}
               append to list     ${availableChannels_list}       ${spectrumInquiryResponse_availableChannels[0][${i}]['frequencyRange']}
    END

    Should Be Equal    ${spectrumInquiryRequest_cbsdId[0]}    ${assignedCbsdId}
    Should Be Equal    ${spectrumInquiryResponse_cbsdId[0]}    ${assignedCbsdId}
    Should Be Equal    ${availableChannels_list}    ${spectrumInquiryRequest_inquiredSpectrum[0]}
    RETURN  ${availableChannels_list}



Verify Grant Request Procedure
    [Arguments]        ${time_start}    ${time_stop}    ${sas_log_path}    ${enb_id}    ${availableChannels_list}
    [Documentation]    Extracts values for grantResponse:grantId for each CBSD cell from SAS log
    ...                verifies if grant procedure has been executed only for valid frequencies.
    ...                Parameters:
    ...                time_start - timestamp for SAS log parser
    ...                time_stop - timestamp for SAS log parser
    ...                sas_log_path - path of the SAS_Sim.log file

    ${cbsd_info_runtime}   ute_admin_infomodel.Query Infomodel    timeout=30    alias=RAT_1ST
    ...    query=get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/LNBTS_R-${enb_id}/CBSD_R-1
    ${assignedCbsdId}     Get From Dictionary    ${cbsd_info_runtime}    assignedCbsdId

    ${parsed_log_file}             Parse Sas Log File    log_file_name=${sas_log_path}     date_start=${time_start}     date_stop=${time_stop}

    ${grantRequest_cbsdId}   Extract Values From Sas Log    log_name=${parsed_log_file}     parameter=cbsdId
    ...    data_type=grantRequest    packet_amount=1

    #TODO    Sprawdzic czy łączy listę z dwóch grant requestów. jesli tak, to czy wyzszy indeks zawsze = późniejsza wiadomość.
    ${grantRequest_operationFrequencyRange}   Extract Values From Sas Log    log_name=${parsed_log_file}
    ...    parameter=grantRequest    data_type=grantRequest
    ${templog}   log    ${grantRequest_operationFrequencyRange[0][0]['operationParam']['operationFrequencyRange']}
    ${grantRequest_operationFrequencyRange_count}         get length   ${grantRequest_operationFrequencyRange[0]}

    ${requestedChannels_list}   create list
    FOR    ${i}    in range    ${grantRequest_operationFrequencyRange_count}
           append to list    ${requestedChannels_list}
           ...               ${grantRequest_operationFrequencyRange[0][${i}]['operationParam']['operationFrequencyRange']}
    END

    ${requestedInquiredChannels}   List Should Contain Sub List       ${availableChannels_list}      ${requestedChannels_list}


List Response Codes Of Grants
    [Arguments]    ${grantResponse_responseMessage}

    ${grantResponse_Channels_count}   get length    ${grantResponse_responseMessage}
    ${ResponseCodes}   create list
    FOR    ${i}   in range     ${grantResponse_Channels_count}
           append to list     ${ResponseCodes}    ${grantResponse_responseMessage[${i}]['responseCode']}
    END
    RETURN    ${ResponseCodes}

List pMax Values For All Cells
    [Arguments]        ${enb_id}
    [Documentation]    Queries the eNB for details of each cell, extracts their pMax values and adds to the dictionary as 'cellName'='pMax' pair.
    ...                Returns the result as a dictionary.
    ...                Parameters:
    ...                enb_id - ID of the eNB
    @{pMax_list}     ute_admin_infomodel.Query Infomodel    alias=RAT_1ST
    ...    query=get list /MRBTS-*/RAT-*/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-${enb_id}/LNBTS_A-${enb_id}/LNCEL_A-*
    ${cell_num}      get length    ${pMax_list}
    ${pmax_dict}     Create Dictionary
    FOR               ${i}   IN RANGE    ${cell_num}
                      ${pmax_dict}   Set To Dictionary    ${pmax_dict}    "${pMax_list[${i}]["cellName"]}"=${pMax_list[${i}]["pMax"]}
    END
    RETURN           ${pmax_dict}

List earfcn Values For All Cells
    [Arguments]        ${enb_id}
    [Documentation]    Queries the eNB for details of each cell, extracts their pMax values and adds to the dictionary as 'cellName'='pMax' pair.
    ...                Returns the result as a dictionary.
    ...                Parameters:
    ...                enb_id - ID of the eNB
    @{lncel_param_list}     ute_admin_infomodel.Query Infomodel    alias=RAT_1ST
    ...    query=get list /MRBTS-*/RAT-*/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-${enb_id}/LNBTS_A-${enb_id}/LNCEL_A-*/LNCEL_TDD_A-0
    ${cell_num}      get length    ${lncel_param_list}
    ${earfcn_list}   Create List
    FOR               ${i}   IN RANGE    ${cell_num}
                      append to list    ${earfcn_list}    ${lncel_param_list[${i}]['earfcn']}
    END
    RETURN           ${earfcn_list}    ${cell_num}


Fetch eNB ID
    [Documentation]    Connects to the eNB using Admin Infomodel, queries the eNB for its ID and returns it as a string.
    ${enb_id}   ute_admin_infomodel.Query Infomodel    query=get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*  timeout=30    alias=RAT_1ST
    ${enb_id}   Get From Dictionary    ${enb_id}    mrbtsId
    RETURN    ${enb_id}

Fetch CBSD ID
    [Arguments]           ${enb_id}
    [Documentation]       Connects to the eNB using Admin Infomodel, queries the eNB for the CBSD ID and returns it as a string.
    ...                   Parameters:
    ...                   enb_id - ID of the eNB
    ${cbsd_info}        ute_admin_infomodel.Query Infomodel    timeout=30    alias=RAT_1ST
    ...    query=get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/LNBTS_R-${enb_id}/CBSD_R-1
    ${assignedCbsdId}   Get From Dictionary    ${cbsd_info}    assignedCbsdId
    RETURN     ${assignedCbsdId}


Replace Delta Parameters
    [Arguments]        ${delta_path}    ${enb_id}
    [Documentation]    Takes a text file as input, replaces occurences of 'BTS_ID' with value of eNB ID and saves
    ...                the new file removing '_tmp' from file name.
    ...                Parameters:
    ...                enb_id - ID of the eNB
    ...                delta_path - path to the delta commissioning JSON file
    ${delta_tmp}     OperatingSystem.Get File    ${delta_path}
    ${enb_id}        convert to string   ${enb_id}
    ${new_delta}     Replace String    ${delta_tmp}    BTS_ID    ${enb_id}
    ${new_path}      Replace String    ${delta_path}    _tmp    ${EMPTY}
    Create File        ${new_path}    ${new_delta}
    RETURN           ${new_path}

Create generic delta and perform commissioning
    [Arguments]        ${enb_id}
    ...                ${delta_file_tmp}
    ...                ${delta_file_final}
    [Documentation]    Takes JSON file as an input, replaces occurences of 'BTS_ID' with the value provided in enb_id
    ...                and performs recommissioning of the eNB.
    ...                Parameters:
    ...                enb_id - ID of the eNB
    ...                delta_file_tmp - path to the generic delta commissioning JSON file
    ...                delta_file_final - desired path for the delta commissioning JSON file ready to be sent to the eNB
    ${delta_prep}    Replace Delta Parameters   ${delta_file_tmp}    ${enb_id}
    Set Variable       ${delta_file_final}    ${delta_file_final}
    Perform Delta Recommissioning    delta_file=${delta_file_final}    connection=RAT_1ST


Assert Fault Presence
    [Documentation]
    [Arguments]    ${cell_id}    ${fault_id}    ${alarm_name}    ${bts_side}
    ${query}   Set Variable     //LNBTS_L-${bts_side}/LNCEL_L-${cell_id}/ALARM_L-*
    ute_admin_infomodel.Query InfoModel    alias=RAT_1ST    timeout=120
    ...    query=check  ${query} is [alarmInformation.faultId=${fault_id},alarmInformation.alarmText.alarmDetail="${alarm_name}"]


Compare pMax Values For All Cells
    [Arguments]        ${pMax_1}    ${pMax_2}
    [Documentation]    Compares key:value pairs of two dictionaries.
    ...                Parameters:
    ...                pMax_1, pMax_2 - dictionaries to be compared
    Dictionaries Should Be Equal    ${pMax_1}    ${pMax_2}

Wait For All Cells To Be OnAir
    [Arguments]        ${times}=30x    ${wait_time}=10s
    [Documentation]    Author:       michal.kosicki@nokia.com
    ...                Maintainer:   Michal Kosicki
    ...                Parameters:
    ...                - times - How many times will be checked if cells are onAir
    ...                - wait_time - Wait time between each try
    ...                - alias - "RAT_1ST" or "RAT_2ND"
    Wait Until Keyword Succeeds    ${times}    ${wait_time}    ute_admin_infomodel.Query InfoModel    alias=RAT_1ST    timeout=10
    ...    query=every //LNBTS_M-1/CELL_M-* is [stateInfo.proceduralState=regex"(?i)OnAirDone"]

Check If Cells Are Disabled
    [Arguments]        ${enb_id}    ${alias}=RAT_1ST
    [Documentation]    First it queries the cells until they all are in 'disabled' state
    ...                Parameters:
    ...                enb_id - ID of the eNB
    ute_admin_infomodel.Query Infomodel    alias=${alias}    timeout=120
    ...    query=every /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/LNBTS_R-${enb_id}/LNCEL_R-* is [stateInfo.operationalState=regex"(?i)Disabled"]

List Values of GrantId For All Cells
    [Arguments]         ${enb_id}
    [Documentation]     Queries the eNB for details of each CBSDCEL, extracts their GrantId values.
    ...                 It returns the results as a list of GrantId values.
    ...                 Parameters:
    ...                 enb_id - ID of the eNB
    @{cbsdcel_list}   ute_admin_infomodel.Query Infomodel    alias=RAT_1ST
    ...    query=get list /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/LNBTS_R-${enb_id}/LNCEL_R-*/CBSDCEL_R-0
    ${cell_num}       Get Length    ${cbsdcel_list}
    ${grantId_list}   Create List   @{EMPTY}
    FOR                ${i}    IN RANGE    ${cell_num}
                       Append to list    ${grantId_list}    ${cbsdcel_list[${i}]["grantId"]}
    END
    RETURN            ${grantId_list}

Wait For Any Cell To Be Dropped
    [Arguments]        ${times}=60x    ${wait_time}=2s
    [Documentation]    Author:       michal.kosicki@nokia.com
    ...                Maintainer:   Michal Kosicki
    ...                Parameters:
    ...                - times - How many times will be checked if cells are onAir
    ...                - wait_time - Wait time between each try
    ...                - alias - "RAT_1ST" or "RAT_2ND"
    Wait Until Keyword Succeeds    ${times}    ${wait_time}    ute_admin_infomodel.Query InfoModel    alias=RAT_1ST    timeout=10
    ...    query=check //LNBTS_M-1/CELL_M-* is [stateInfo.operationalState=regex"(?i)Disabled"]

Check For Unwanted Faults
    [Documentation]    This keyword compares alarms that are active on the eNB with user defined list of allowed alarms.
    ...                If some active alarm is not defined as allowed, the keyword fails.
    [Arguments]    ${allowed_faults}=@{EMPTY}   ${active_alarm_list}=@{EMPTY}
    List Should Contain Sub List    ${allowed_faults}    ${active_alarm_list}

List Active eNB Faults
    [Documentation]    This keyword checks for alarms that are visible on the eNB,
    ...                then fetches the faultId of the alarm and appends it to the list.
    [Arguments]     ${alias}=RAT_1ST
    @{enb_alarms}     Get Active Alarms    connection=${alias}
    ${faults_ids}    Create List
    FOR  ${enb_alarm}  IN  @{enb_alarms}
      ${fault_id}  Get From Dictionary  ${enb_alarm}  faultId
      Append To list  ${faults_ids}  ${fault_id}
    END
    RETURN    ${faults_ids}