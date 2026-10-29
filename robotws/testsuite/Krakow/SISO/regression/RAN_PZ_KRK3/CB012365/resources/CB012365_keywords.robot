*** Settings ***
Documentation
...   Keywords for CB012365 testing (CBRS channel bonding of PAL and GAA channels)
...   author: Marek Bodziony
...   contact: marek.bodziony@nokia.com

Library     DateTime
Library     taf.ue
Library     testsuite.Krakow.SISO.regression.RAN_PZ_KRK3.CB012365.resources.CBSD_helper.CBSD        WITH NAME   cbsd
Library     testsuite.Krakow.SISO.regression.RAN_PZ_KRK3.CB012365.resources.SASsim_helper.SASsim    WITH NAME   sas
Library     taf.rfrl.bts.devices.du.commissioning.GnbCommissioning                                  WITH NAME   commissioning
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    taf/rfrl/ue/robot/REAL_UE.robot
Resource    taf/rfrl/bts/robot/gnb.robot
Resource    testsuite/Krakow/resources/SMAwave_kws/DevNJ_UE_keywords.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py


*** Variables ***
${AWPQZ_category}           A
${SAS_Sim_configs_dir}      ${CURDIR}/SASsim_configs
${enable_CBRS}              ${CURDIR}/SCF_deltas/enable_CBRS.json
${disable_CBRS}             ${CURDIR}/SCF_deltas/disable_CBRS.json
${CBRS_config_BASIC}        ${CURDIR}/SCF_deltas/CBRS_config_BASIC.json
${CBRS_config_B1_TC04}      ${CURDIR}/SCF_deltas/CBRS_config_B1_TC04.json
${CBRS_config_B1_TC11}      ${CURDIR}/SCF_deltas/CBRS_config_B1_TC11.json
${CBRS_config_B2_TC05}      ${CURDIR}/SCF_deltas/CBRS_config_B2_TC05.json
${CBRS_config_B2_TC06}      ${CURDIR}/SCF_deltas/CBRS_config_B2_TC06.json
${CBRS_config_B2_TC07}      ${CURDIR}/SCF_deltas/CBRS_config_B2_TC07.json
${NRCBSDCELL_DN}            MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCBSDCELL-0
${NRCBSD_DN}                MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCBSD-1
${NRCBRSPR_DN}              MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCBRSPR-1
${actPalGaaBond_param_name}     Activate PAL and GAA channels bonding
${palGaaPwrDiff_param_name}     Max power difference allowed between PAL and GAA channels
${querySasServerPeriod_param_name}     Query SAS server period
@{CUSTOM_ALLOWED_ALARMS}    SAS Server Communication Failure
${first_msg}                1
${second_msg}               2
${cert_TA_path}             ${CURDIR}/certs

*** Keywords ***
Common Suite Setup with TestLine Preparation and Certificates for CBRS
    Common Suite Setup With OnAir Test Line Preparation
    ...     wait_for_on_air=${False}
    ...     increase_timeout_for_update_sw=${1200}
    Run Keyword And Ignore Error    gnbbbu.Install Certificate    cert_file=${cert_TA_path}/ca-certificate.pem
    ...     cert_type=CBRSAdditionalCa      cert_format=PEM

Enable CBRS and wait for onAir
    gnbscf.perform_bts_delta_json_commissioning    delta_file=${enable_CBRS}
    ...     skip_parameter_relation_errors=${false}    should_activate=${true}    timeout=${60}
    Wait Until Keyword Succeeds	    2 min	5 sec      verify_procedural_and_blocking_state     procedural_states=["OnAir"]

Disable CBRS
    gnbscf.perform_bts_delta_json_commissioning    delta_file=${disable_CBRS}
    ...     skip_parameter_relation_errors=${false}    should_activate=${true}    timeout=${60}
    Wait Until Keyword Succeeds	    2 min	5 sec      verify_procedural_and_blocking_state     procedural_states=["Configured"]

Wait for Grant and check correct Grant parameters for CBSD cell via GUI
    [Arguments]    ${type}   ${state}     ${low_freq}    ${high_freq}
    Wait Until Keyword Succeeds	    1 min	10 sec      Check if Grant was granted for CBSD
    Check correct Grant parameters for CBSD cell via GUI    type=${type}  state=${state}  low_freq=${low_freq}  high_freq=${high_freq}

Check if Grant was granted for CBSD
    ${grant_state_gui}=         get_gnb_parameter_value_via_gui         dist_name=${NRCBSDCELL_DN}
    ...                                                                 param_name=SAS grant operation state
    ...                                                                 param_abbr=grantOperationStateSub
    Should Be Equal     ${grant_state_gui}      Authorized

Check correct Grant parameters for CBSD cell via GUI
    [Arguments]    ${type}   ${state}     ${low_freq}    ${high_freq}
    ${grant_type_gui}=          get_gnb_parameter_value_via_gui         dist_name=${NRCBSDCELL_DN}
    ...                                                                 param_name=SAS grant channel type
    ...                                                                 param_abbr=grantChannelType
    ${grant_state_gui}=         get_gnb_parameter_value_via_gui         dist_name=${NRCBSDCELL_DN}
    ...                                                                 param_name=SAS grant operation state
    ...                                                                 param_abbr=grantOperationStateSub
    ${grant_low_freq_gui}=      get_gnb_parameter_value_via_gui         dist_name=${NRCBSDCELL_DN}
    ...                                                                 param_name=Grant spectrum low frequency
    ...                                                                 param_abbr=grantSpectrumFreqLow
    ${grant_high_freq_gui}=     get_gnb_parameter_value_via_gui         dist_name=${NRCBSDCELL_DN}
    ...                                                                 param_name=Grant spectrum high frequency
    ...                                                                 param_abbr=grantSpectrumFreqHigh
    Should Be Equal     ${type}                     ${grant_type_gui}
    Should Be Equal     ${state}                    ${grant_state_gui}
    Should Contain      ${grant_low_freq_gui}       ${low_freq}
    Should Contain      ${grant_high_freq_gui}      ${high_freq}

Check in WebEM if CBSD is registered with SAS
    ${cbsd_category}=               get_gnb_parameter_value_via_gui      dist_name=${NRCBSD_DN}
    ...                                                                 param_name=CBSD device category
    ...                                                                 param_abbr=cbsdCategory
    ${cbsd_registration_state}=     get_gnb_parameter_value_via_gui     dist_name=${NRCBSD_DN}
    ...                                                                 param_name=CBSD registration state
    ...                                                                 param_abbr=cbsdRegistrationState
    Should Be Equal      ${cbsd_category}               ${AWPQZ_category}
    Should Be Equal      ${cbsd_registration_state}     Registered

Change value of parameter '${param_abbreviation}' to '${param_val}' for CBSD via GUI
    commissioning.verify_if_parameter_changed_to_correct_value_via_gui
    ...                         dist_name=${NRCBRSPR_DN}
    ...                         parameter=${${param_abbreviation}_param_name}
    ...                         value=${param_val}

Update value of parameter 'supportedChBw' to [${channels_bw}] for CBSD
    cbsd.update supportedChBw for cbsd    new_channels_bw=${channels_bw}

Upload SASsim configuration for ${TC_num}
    sas.upload_new_config       config_path=${SAS_Sim_configs_dir}/${TC_num}-SAS_Sim.conf

Set basic CBRS configuration
    ${CBRS_config_BASIC}=       Set basic config file for current release
    gnbscf.perform_bts_delta_json_commissioning    delta_file=${CBRS_config_BASIC}
    ...     skip_parameter_relation_errors=${false}    should_activate=${true}    timeout=${60}
    Update value of parameter 'supportedChBw' to [10MHz, 20MHz, 30MHz, 40MHz, 50MHz, 60MHz, 70MHz, 80MHz, 90MHz, 100MHz] for CBSD

Set basic config file for current release
    ${sw_rel}     Get gNB Sw Release Name
    ${CBRS_config_BASIC}=     run keyword IF    '${sw_rel}'=='SBTS24R3'   set variable    ${CURDIR}/SCF_deltas/CBRS_config_BASIC_24R3.json
    ...     ELSE                                                          set variable    ${CURDIR}/SCF_deltas/CBRS_config_BASIC.json
    [Return]        ${CBRS_config_BASIC}

CBRS configuration for ${TC_num}
    ${CBRS_config}       Set config file for ${TC_num} for current release
    gnbscf.perform_bts_delta_json_commissioning    delta_file=${CBRS_config}
    ...     skip_parameter_relation_errors=${false}    should_activate=${true}    timeout=${60}

Set config file for ${TC_num} for current release
    ${sw_rel}     Get gNB Sw Release Name
    ${CBRS_config_TC}=     run keyword IF    '${sw_rel}'=='SBTS24R3'   set variable    ${CURDIR}/SCF_deltas/CBRS_config_${TC_num}_24R3.json
    ...     ELSE                                                          set variable    ${CURDIR}/SCF_deltas/CBRS_config_${TC_num}.json
    [Return]        ${CBRS_config_TC}

Start SASsim
    sas.start_sas_sim

Stop SASsim
    sas.stop_sas_sim

Download 'SAS_Sim.log' from SASsim
    sas.get_sas_sim_log

Check if there's only ${message_count} '${message_type}' message(s) in SAS_Sim.log
    sas.find_messages_in_sas_sim_log    message_type=${message_type}    expected_messages_num=${message_count}

Check if 'grantRequest' message for PAL channels have correct parameters
    [Arguments]     ${cbsdId}  ${groupId}  ${groupType}  ${measReport_elements}  ${accepted_maxEirp}  ${highFrequency}
    ...             ${lowFrequency}  ${messageNum}=${first_msg}
    ${grantRequest}=    sas.get_specific_message_from_sas_sim_log        message_type=grantRequest    message_num=${messageNum}
    sas.verify_grant_request_message
    ...             grant_request_msg=${grantRequest}
    ...             channel_type=PAL
    ...             cbsd_id=${cbsdId}
    ...             group_id=${groupId}
    ...             group_type=${groupType}
    ...             meas_report_elements=${measReport_elements}
    ...             max_eirp_accepted=${accepted_maxEirp}
    ...             high_freq=${highFrequency}
    ...             low_freq=${lowFrequency}

Check if 'grantRequest' message for GAA channels have correct parameters
    [Arguments]     ${cbsdId}  ${groupId}  ${groupType}  ${measReport_elements}  ${accepted_maxEirp}  ${highFrequency}
    ...             ${lowFrequency}  ${messageNum}=${first_msg}
    ${grantRequest}=    sas.get_specific_message_from_sas_sim_log        message_type=grantRequest    message_num=${messageNum}
    sas.verify_grant_request_message
    ...             grant_request_msg=${grantRequest}
    ...             channel_type=GAA
    ...             cbsd_id=${cbsdId}
    ...             group_id=${groupId}
    ...             group_type=${groupType}
    ...             meas_report_elements=${measReport_elements}
    ...             max_eirp_accepted=${accepted_maxEirp}
    ...             high_freq=${highFrequency}
    ...             low_freq=${lowFrequency}

Check if 'grantResponse' message for PAL channels have correct parameters
    [Arguments]    ${cbsdId}    ${grantId}   ${channelType}    ${responseCode}     ${responseMessage}   ${messageNum}=${first_msg}
    ${grantResponse}=    sas.get_specific_message_from_sas_sim_log        message_type=grantResponse    message_num=${messageNum}
    sas.verify_grant_response_message
    ...             grant_response_msg=${grantResponse}
    ...             cbsd_id=${cbsdId}
    ...             grant_id=${grantId}
    ...             channel_type=${channelType}
    ...             response_code=${responseCode}
    ...             response_message=${responseMessage}

Check if 'grantResponse' message for GAA channels have correct parameters
    [Arguments]    ${cbsdId}    ${grantId}   ${channelType}    ${responseCode}     ${responseMessage}   ${messageNum}=${first_msg}
    ${grantResponse}=    sas.get_specific_message_from_sas_sim_log        message_type=grantResponse    message_num=${messageNum}
    sas.verify_grant_response_message
    ...             grant_response_msg=${grantResponse}
    ...             cbsd_id=${cbsdId}
    ...             grant_id=${grantId}
    ...             channel_type=${channelType}
    ...             response_code=${responseCode}
    ...             response_message=${responseMessage}

Check if 'heartbeatRequest' message for PAL channels have correct parameters
    [Arguments]    ${cbsdId}    ${grantId}   ${groupId}   ${groupType}  ${measReport_elements}  ${operationState}   ${messageNum}=${first_msg}
    ${heartbeatRequest}=    sas.get_specific_message_from_sas_sim_log        message_type=heartbeatRequest    message_num=${messageNum}
    sas.verify_heartbeat_request_message
    ...             heartbeat_request_msg=${heartbeatRequest}
    ...             channel_type=PAL
    ...             cbsd_id=${cbsdId}
    ...             grant_id=${grantId}
    ...             group_id=${groupId}
    ...             group_type=${groupType}
    ...             meas_report_elements=${measReport_elements}
    ...             operation_state=${operationState}

Check if 'heartbeatRequest' message for GAA channels have correct parameters
    [Arguments]    ${cbsdId}    ${grantId}   ${groupId}   ${groupType}  ${measReport_elements}  ${operationState}   ${messageNum}=${first_msg}
    ${heartbeatRequest}=    sas.get_specific_message_from_sas_sim_log        message_type=heartbeatRequest    message_num=${messageNum}
    sas.verify_heartbeat_request_message
    ...             heartbeat_request_msg=${heartbeatRequest}
    ...             channel_type=GAA
    ...             cbsd_id=${cbsdId}
    ...             grant_id=${grantId}
    ...             group_id=${groupId}
    ...             group_type=${groupType}
    ...             meas_report_elements=${measReport_elements}
    ...             operation_state=${operationState}

Check if 'heartbeatResponse' message for PAL channels have correct parameters
    [Arguments]    ${cbsdId}    ${grantId}    ${responseCode}     ${responseMessage}    ${messageNum}=${first_msg}
    ${heartbeatResponse}=    sas.get_specific_message_from_sas_sim_log        message_type=heartbeatResponse    message_num=${messageNum}
    sas.verify_heartbeat_response_message
    ...             heartbeat_response_msg=${heartbeatResponse}
    ...             channel_type=PAL
    ...             cbsd_id=${cbsdId}
    ...             grant_id=${grantId}
    ...             response_code=${responseCode}
    ...             response_message=${responseMessage}

Check if 'heartbeatResponse' message for GAA channels have correct parameters
    [Arguments]    ${cbsdId}    ${grantId}    ${responseCode}     ${responseMessage}    ${messageNum}=${first_msg}
    ${heartbeatResponse}=    sas.get_specific_message_from_sas_sim_log        message_type=heartbeatResponse    message_num=${messageNum}
    sas.verify_heartbeat_response_message
    ...             heartbeat_response_msg=${heartbeatResponse}
    ...             channel_type=GAA
    ...             cbsd_id=${cbsdId}
    ...             grant_id=${grantId}
    ...             response_code=${responseCode}
    ...             response_message=${responseMessage}

Check if 'grantResponse' message for GAA channels received with failure
    [Arguments]    ${cbsdId}   ${channelType}   ${responseCode}     ${responseMessage}  ${messageNum}=${first_msg}
    ${grantResponse}=    sas.get_specific_message_from_sas_sim_log        message_type=grantResponse    message_num=${messageNum}
    sas.verify_response_message_with_failure
    ...             response_msg=${grantResponse}
    ...             message_type=grantResponse
    ...             cbsd_id=${cbsdId}
    ...             channel_type=${channelType}
    ...             response_code=${responseCode}
    ...             response_message=${responseMessage}

Check if 'grantResponse' message for PAL channels received with failure
    [Arguments]    ${cbsdId}   ${channelType}   ${responseCode}     ${responseMessage}  ${messageNum}=${first_msg}
    ${grantResponse}=    sas.get_specific_message_from_sas_sim_log        message_type=grantResponse    message_num=${messageNum}
    sas.verify_response_message_with_failure
    ...             response_msg=${grantResponse}
    ...             message_type=grantResponse
    ...             cbsd_id=${cbsdId}
    ...             channel_type=${channelType}
    ...             response_code=${responseCode}
    ...             response_message=${responseMessage}

Check if 'heartbeatResponse' message for GAA channels received with failure
    [Arguments]    ${cbsdId}  ${grantId}  ${channelType}   ${responseCode}     ${responseMessage}  ${messageNum}=${first_msg}
    ${heartbeatResponse}=    sas.get_specific_message_from_sas_sim_log        message_type=heartbeatResponse    message_num=${messageNum}
    sas.verify_response_message_with_failure
    ...             response_msg=${heartbeatResponse}
    ...             message_type=heartbeatResponse
    ...             cbsd_id=${cbsdId}
    ...             grant_id=${grantId}
    ...             channel_type=${channelType}
    ...             response_code=${responseCode}
    ...             response_message=${responseMessage}

Check if CBSD have relinquish Grant
    [Arguments]    ${cbsdId}   ${grantId}   ${channelType}  ${messageNum}=${first_msg}
    Check if there's only 1 'relinquishmentRequest' message(s) in SAS_Sim.log
    ${relinquishmentRequest}=    sas.get_specific_message_from_sas_sim_log        message_type=relinquishmentRequest    message_num=${messageNum}
    sas.verify_relinquishment_message
    ...             relinquishment_msg=${relinquishmentRequest}
    ...             message_type=relinquishmentRequest
    ...             channel_type=${channelType}
    ...             cbsd_id=${cbsdId}
    ...             grant_id=${grantId}
    Check if there's only 1 'relinquishmentResponse' message(s) in SAS_Sim.log
    ${relinquishmentResponse}=    sas.get_specific_message_from_sas_sim_log        message_type=relinquishmentResponse    message_num=${messageNum}
    sas.verify_relinquishment_message
    ...             relinquishment_msg=${relinquishmentResponse}
    ...             message_type=relinquishmentResponse
    ...             channel_type=${channelType}
    ...             cbsd_id=${cbsdId}
    ...             grant_id=${grantId}
    ...             response_code=0
    ...             response_message=CBSD request is approved by SAS

Wait until SAS timer expires and Second Grant will be granted
    [Arguments]    ${second_grant_type}   ${second_grant_state}     ${second_grant_low_freq}    ${second_grant_high_freq}
    Wait Until Keyword Succeeds	    3 min	20 sec      Check correct Grant parameters for CBSD cell via GUI
    ...     type=${second_grant_type}  state=${second_grant_state}  low_freq=${second_grant_low_freq}  high_freq=${second_grant_high_freq}

Perform L3 call
    [Arguments]    ${ue_index}=1    ${duration}=30    ${dl_throughput}=100M    ${ul_throughput}=20M    ${max_deviation}=20%
    Start DLUL Data Transfer And Verify Throughput on SMAwave
    ...     ue_index=${ue_index}
    ...     duration=${duration}
    ...     dl_throughput=${dl_throughput}
    ...     ul_throughput=${ul_throughput}
    ...     max_deviation=${max_deviation}

Common Preconditions With Watching Alarms for CBRS
    Run keywords
    ...         Start SASsim
    ...         Enable CBRS and wait for onAir
    ...         Common Preconditions With Watching Alarms
    ...         Disable CBRS
    ...         Stop SASsim

Start DLUL Data Transfer And Verify Throughput on SMAwave
    [Arguments]    ${ue_index}    ${duration}    ${dl_throughput}    ${ul_throughput}    ${max_deviation}
    UE Attach And Start ADB Log    ue_index=${ue_index}
    Sleep    15s
    ${start_time}=    Get Current Date
    ${expected_end_time}=    Add Time To Date    ${start_time}    ${duration}
    Log    \n--Starting DLUL data transfer--\n    console=${True}
    Log    \n--Start Time: ${start_time}--\n    console=${True}
    Log    \n--Expected end time: ${expected_end_time}--\n    console=${True}
    Start DL Async Process    ${ue_index}    ${dl_throughput}    ${duration}
    Start UL Async Process    ${ue_index}    ${ul_throughput}    ${duration}
    Sleep    ${duration}
    Calculate and Verify DL Async Tput    ${ue_index}    ${dl_throughput}    ${max_deviation}    0s
    Calculate and Verify UL Async Tput    ${ue_index}    ${ul_throughput}    ${max_deviation}    0s
    ${end_time}=    Get Current Date
    Postconditions_ForUE
    Log    \n--Finished DLUL data transfer--\n    console=${True}
    Log    \n--End Time: ${end_time}--\n    console=${True}
