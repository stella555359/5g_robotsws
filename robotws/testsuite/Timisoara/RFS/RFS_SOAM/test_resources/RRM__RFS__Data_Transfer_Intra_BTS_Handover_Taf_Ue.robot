*** Settings ***
Documentation    TC__RRM__RFS__Data_Transfer_Intra_BTS_Handover_Taf_Ue
Variables    tc_variables/RRM__RFS__Data_Transfer_Intra_BTS_Handover_Taf_Ue.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}    3              # Number of Source Cell - Target Cell and Target Cell - Source Cell Intra BTS Handover cycles to be performed
${BTS_CALL}    BTS1                 # Specify BTS on which call and intra BTS Handover will be peformed; Default value: BTS1 (Master)
${UE_CAPABILITIES}                  # Label used to identify a specific UE defined in ue config (from config: CAPABILITIES)
${TECHNO}    NR                     # Specified technology on which call will be peformed;
                                    # Possible values: "WCDMA", "GSM", "LTE", "NR"; Defaul value: NR
${Source_Cell_ID}                   # ID Of Source cell from selected TECHNO from whcih to start Intra BTS Handover procedure
                                    # For WCDMA - Global Cell Id is used, for LTE -  Eutran Cell Id is used, for GSM - Cell CI is used,
                                    # for NR - NRCellID is used.
${Target_Cell_ID}                   # ID Of Target cell from selected TECHNO onwards to perform Intra BTS Handover procedure
                                    # For WCDMA - Global Cell Id is used, for LTE -  Eutran Cell Id is used, for GSM - Cell CI is used,
                                    # for NR - NRCellID is used.
${Source_Cell_Start_att}   0        # Source Cell Attenuation for start (good radio conditions); Default Value: 0
${Target_Cell_Start_att}   0        # Target Cell Attenuation for start (good radio conditions); Default Value: 0
${Source_Cell_End_att}     10       # Source Cell Attenuation for end (good radio conditions); Default Value: 10
${Target_Cell_End_att}     10       # Target Cell Attenuation for start (good radio conditions); Default Value: 10
${attenuation_step}   1             # Value of attenuation to add on source cell and subtract from targel cell attenuation during one step from the
                                    # intra BTS Handover triggering procedure; Default Value: 1
${CALL_DIRECTION}  uplink_downlink  # Call direction of data transfer call to be performed
                                    # Possible values: downlink, uplink and uplink_downlink; Default Value: uplink_downlink
${BTS_OAM_IP_ADDRESSES}    None     # List of all IP addresses of external BTS that contain anchor cell relation to any of the BTS NSA 5G
                                    # Values separated by space. Default value: None.
                                    # Example: 10.0.71.104 10.0.71.204
${PROTOCOL}    udp                  # Data transfer protocol. Possible values: udp, tcp, ftp; Default value: udp
${MCC}  244                         # Mobile Country Code from BTS. Needed for checking Handovers via PM Counters; Default value: 244
${MNC}  08                          # Mobile Network Code from BTS. Needed for checking Handovers via PM Counters; Default value: 08
${DETACH_UE}    False               # Flag to set if Detach UE is needed at the end of the test; Possible values: True, False. Default value: False
${PM_duration}    60                # PM duration for checking handover (in seconds); Default value: 60

*** Keywords ***
TC__RRM__RFS__Data_Transfer_Intra_BTS_Handover_Taf_Ue
    [Documentation]
    ...  [CASE LINK]:  https://jiradc.ext.net.nokia.com/browse/TAT-28927
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...
    ...  Test for performing Intra BTS Handover between two cells specified as input arguments
    ...
    ...  Below are described the variables that you can complete:
    ...
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for all BTS
    ...  - set good radio conditions on source cell and bad radio conditions on target cell
    ...  - perform attach and start data transfer on source cell
    ...  - perform Intra BTS Handover for a number of cycles specified as input argument
    ...  - stop data transfer and detach UE
    ...  - check final state and alarms for all BTS
    ...  - Pass criteria: handover procedure is considered successful if the handover attempt and handover success PM counters are increased by 1
    ...  and the handover failure PM counter is not increased after each handover, and also if the throughput after handover is stable
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...
    ...  - 20.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-25015 - TC Delivery
    ...

    Set Tags    CA-STATE    OWNER-ancuta.muresan@nokia.com    AUTHOR-gabriel.stanculescu@nokia.com    PHASE-QT    SW-SBTS26R2

    Step 1: Get Full Configuration Cell Info and Anchor Relation Info
    Step 2: Check initial all BTS state
    Step 3: Check initial all BTS alarms
    Step 4: Set Good Radio Conditions on Source Cell and Bad Radio Conditions on Target Cell
    Step 5: Perform attach and start data transfer on source cell
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 6: Perform Intra BTS Handover for iteration ${INDEX}
    END
    Step 7: Stop Data Transfer and Detach UE
    Step 8: Check final all BTS state
    Step 9: Check final all BTS alarms

    [Teardown]  Particular Teardown

Step ${index}: Get Full Configuration Cell Info and Anchor Relation Info
    Log  Step ${index}: Get Full Configuration Cell Info and Anchor Relation Info  console=True

    Start Sessions on External BTS if needed
    Get Full Configuration Anchor Cells Relations
    Get Full Configuration Cell IDs

Step ${index}: Check ${when} all BTS state
    [Documentation]
    ...  SBTS state is checked according to Admin for BTS and each configured RAT

    Log  Step ${index}: Check ${when} all BTS state  console=True

    FOR  ${alias}  IN  @{alias_list}

        Log  ***** Check ${when} BTS ${alias} state *****  console=True

        Admin Check BTS RAT Procedural State  alias=${alias}  timeout=600

        Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  alias=${alias}

        Log  BTS ${alias} site - proceduralState: OnAir, blockingState: Unblocked  console=True

    END

Step ${index}: Check ${when} all BTS alarms
    [Documentation]
    ...  SBTS alarms are compared with values from expected, ignored and critical alarms lists. SBTS alarms are get
    ...  from Admin

    Log  Step ${index}: Check ${when} all BTS alarms  console=True

    FOR  ${alias}  IN  @{alias_list}

        Log  ***** Check ${when} BTS ${alias} alarms *****  console=True

        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}
        ...  critical_alarms=${test_alarms_list['${alias.upper()}_CRITICAL_ALARMS']}

        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

    END

Step ${index}: Set Good Radio Conditions on Source Cell and Bad Radio Conditions on Target Cell
    Log  Step ${index}: Set Good Radio Conditions on Source Cell and Bad Radio Conditions on Target Cell  console=True

    ${BTS_number}=  Fetch From Right  ${BTS_CALL}  BTS
    ${BTS_number_int}=  Convert To Integer  ${BTS_number}
    ${BTS_number_int}=  Evaluate  ${BTS_number_int}-1
    ${admin_alias}=  Set Variable  ${alias_list[${BTS_number_int}]}
    Set Test Variable  ${admin_alias}
    Wait Until Keyword Succeeds  10 min  10 sec  Cut Cells Signal  tech=${TECHNO}
    Set Cell Attenuation  ${Source_Cell_ID}  ${Source_Cell_Start_att}  ${TECHNO}  ${admin_alias}

Step ${index}: Perform attach and start data transfer on source cell
    Log  Step ${index}: Perform attach and start data transfer on source cell     console=True

    ${alias_ue}=  Set Variable  Handover_UE
    Set Test Variable  ${alias_ue}
    ${status}=  Run Keyword And Return Status  Taf Ue Require Single UE  ue_alias=${alias_ue}  capabilities=${UE_CAPABILITIES}  timeout=180
    Run Keyword If  '${status}'=='True'
    ...  Log  Succesfully required UE capability ${UE_CAPABILITIES} and assigned alias ${alias_ue}  console=True

    ${ue_info}=  Taf UE Get UE info based on capabilities  searched_capability=${UE_CAPABILITIES}  mnb_profile_used=False

    ${status_first_try}=  Run Keyword And Return Status  Check attach UE on expected cell  ${admin_alias}  ${Source_Cell_ID}  ${TECHNO}
    Run Keyword If  '${status_first_try}' == 'False'  Run Keywords
    ...  Log  First attempt was not successful so the UE will be reseted!  console=True
    ...  AND  Run Keyword And Ignore Error  Taf Ue Reboot UE based on UE class  ue_alias=${alias_ue}  ue_class=${ue_info[0]}
    ...  AND  Sleep  60s
    ...  AND  Run Keyword And Return Status  Check attach UE on expected cell  ${admin_alias}  ${Source_Cell_ID}  ${TECHNO}
    Run Keyword If  '${status_first_try}'=='False'
    ...  Run Keyword If  '${status_second_try}'=='False'
    ...  Fail  Failed to attach UE ${alias_ue}!

    Proceed to data transfer start on UE  ${protocol}  ${CALL_DIRECTION}  ${TECHNO}

    Get Current Time  start_data_transfer

Step ${index}: Perform Intra BTS Handover for iteration ${INDEX}
    Log  Step ${index}: Perform Intra BTS Handover for iteration ${INDEX}  console=True

    Log  Perform Intra BTS Handover ${Source_Cell_ID} --> ${Target_Cell_ID}  console=True
    Perform Intra BTS Handover  ${Source_Cell_ID}  ${Target_Cell_ID}  ${Source_Cell_Start_att}
    ...  ${Source_Cell_End_att}  ${Target_Cell_Start_att}  ${Target_Cell_End_att}
    Log  Perform Intra BTS Handover Back ${Target_Cell_ID} --> ${Source_Cell_ID}  console=True
    Perform Intra BTS Handover  ${Target_Cell_ID}  ${Source_Cell_ID}  ${Target_Cell_Start_att}
    ...  ${Target_Cell_End_att}  ${Source_Cell_Start_att}  ${Source_Cell_End_att}

Step ${index}: Stop Data Transfer and Detach UE
    Log  Step ${index}: Stop Data Transfer and Detach UE  console=True

    Run Keyword If  '${call_direction}' != 'ul_dl'  Taf Ue Stop Data Transfer Single UE  dt_name=dt_${alias_ue}_${CALL_DIRECTION}
    ...  ELSE  Run Keywords
    ...  Taf Ue Stop Data Transfer Single UE  dt_name=dt_${alias_ue}_ul
    ...  AND  Taf Ue Stop Data Transfer Single UE  dt_name=dt_${alias_ue}_dl
    Run Keyword If  '${DETACH_UE}' == 'True'
    ...  Taf Ue Detach Single UE  ue_alias=${alias_ue}

Perform Intra BTS Handover
    [Arguments]   ${cell_source}  ${cell_target}  ${cell_source_start_att}
    ...  ${cell_source_end_att}  ${cell_target_start_att}  ${cell_target_end_att}
    Synchronize handover event to PM generation
    Get Handover timestamp info  start
    ${event_epoch_time}=  GET event epoch time
    Set Test Variable  ${handover_event_epoch_time_start}  ${event_epoch_time}
    Log  Handover procedure start epoch time: ${handover_event_epoch_time_start}  console=True
    Trigger Handover Between Two Cells    ${cell_source}  ${cell_target}  ${cell_source_start_att}
    ...  ${cell_source_end_att}  ${cell_target_start_att}  ${cell_target_end_att}  ${TECHNO}  ${admin_alias}  ${attenuation_step}
    Get Handover timestamp info  end
    ${event_epoch_time}=  GET event epoch time
    Set Test Variable  ${handover_event_epoch_time_end}  ${event_epoch_time}
    Log  Handover procedure end epoch time: ${handover_event_epoch_time_end}  console=True
    Sleep  100s
    Log  Check Handover Event based on PM Counters  console=True
    Log  Checking INTRA_HO_ATT_NB (Intra handover attempts number). Expected value: 1  console=True
    Check PM counters  M8015C1  ${cell_source}  ${cell_target}  ${TECHNO}  ${admin_alias}   1
    Log  Checking INTRA_HO_ATT_NB (Intra handover attempts number) successful!  console=True
    Log  Checking INTRA_HO_SUCC_NB (Intra handover succesful number)  console=True
    Check PM counters  M8015C2  ${cell_source}  ${cell_target}  ${TECHNO}  ${admin_alias}   1
    Log  Checking INTRA_HO_SUCC_NB (Intra handover succesful number) successful!  console=True
    Log  Checking INTRA_HO_FAIL_NB (Intra handover failure number). Expected value: 0  console=True
    Check PM counters  M8015C15  ${cell_source}  ${cell_target}  ${TECHNO}  ${admin_alias}   0
    Log  Checking INTRA_HO_FAIL_NB (Intra handover failure number) successful!  console=True
    Check Throughput Is Stable

Check Throughput Is Stable

    Log  Checking if throughput is stable after handover  console=True

    ${call_direction_long}=  Set Variable If  '${call_direction}'=='ul'  UPLINK  '${call_direction}'=='dl'  DOWNLINK
    ${cell_id}=  taf.ue.Get Ue Info  ${alias_ue}  CELL_ID
    Extract current cell target BW based on cell ID  ${cell_id}  ${techno}
    ${downlink_MIN_TPUT}=  Set Variable  ${CELL_TARGET_BW_params["DL_min"]}
    ${downlink_MAX_TPUT}=  Set Variable  ${CELL_TARGET_BW_params["DL_max"]}
    ${uplink_MIN_TPUT}=  Set Variable  ${CELL_TARGET_BW_params["UL_min"]}
    ${uplink_MAX_TPUT}=  Set Variable  ${CELL_TARGET_BW_params["UL_max"]}

    Get Current Time  current
    ${elapsed_time}=  DateTime.Subtract Date from Date  ${time_current}  ${time_start_data_transfer}  number
    Sleep  15s
    Run Keyword If  '${call_direction}' != 'ul_dl'
    ...  taf.ue.Verify Average Throughput  dt_name=dt_${alias_ue}_${call_direction}  tput_min=${${call_direction_long}_MIN_TPUT}
    ...  tput_max=${${call_direction_long}_MAX_TPUT}  omit=${elapsed_time}
    ...  ELSE  Run Keywords
    ...  taf.ue.Verify Average Throughput  dt_name=dt_${alias_ue}_ul  tput_min=${UPLINK_MIN_TPUT}  tput_max=${UPLINK_MAX_TPUT}  omit=${elapsed_time}
    ...  AND  taf.ue.Verify Average Throughput  dt_name=dt_${alias_ue}_dl  tput_min=${DOWNLINK_MIN_TPUT}  tput_max=${DOWNLINK_MAX_TPUT}
    ...  omit=${elapsed_time}

    Log  Throughput checked stable after handover  console=True

Check counter value
    [Arguments]    ${counter_id}  ${counter_value}  ${expected_value}
    Log  Counter ${counter_id} expected value: ${expected_value}; found value: ${counter_value}  console=True
    Run Keyword If  ${counter value} != ${expected_value}
    ...  Fail  Handover Counter ${counter_id} value check failed!
    ...  ELSE  Log  Counter ${counter_id} value succesfully checked!

GET event epoch time
    ${epoch_time}=  OperatingSystem.Run    date +%s
    [Return]  ${epoch_time}

Get Handover timestamp info
    [Arguments]  ${when}

    Get Current Date UTC info  ${when}
    Log  UTC ${when}_point_timestamp: ${date_timestamp_${when}_UTC}  console=True

Synchronize handover event to PM generation
    ${epoch_time_now}=  GET event epoch time
    ${current_PM_sec_elapsed}=  Evaluate  ${epoch_time_now}%${PM_duration}
    ${mid_PM_duration_seconds}=  Set Variable  30
    ${mid_PM_duration_seconds_int}=  Convert To Integer  ${mid_PM_duration_seconds}
    ${time_to_wait}=  Evaluate  ${current_PM_sec_elapsed}-${mid_PM_duration_seconds_int}
    ${time_to_wait}=  Evaluate  ${time_to_wait}+5
    Run Keyword If  ${time_to_wait}>0  Run Keywords
    ...  Log  Waiting ${time_to_wait} seconds more to synchronize event with PM generation  console=True
    ...  AND  Sleep  ${time_to_wait}s

Check PM counters
    [Arguments]  ${counter_id}  ${Cell_Id}  ${Target_Cell_Id}  ${techno}  ${alias}  ${expected_value}

    Log  Checking ${counter_id} counter value on BTS ${alias}  console=True
    ${techno_cells}=  Get From Dictionary  ${${alias}_all_cell_id_internal_id_mapping}  ${techno.upper()}
    ${internal_cell_id}=  Get From Dictionary  ${techno_cells}  ${Cell_Id}
    ${cell_scf_dn}=  Get CELL SCF runtime distinguished name  ${internal_cell_id}  ${alias}  ${techno.lower()}
    ${counter_path}=  Catenate  SEPARATOR=/  ${cell_scf_dn}  MCC-${MCC}  MNC-${MNC}  ECI-${Target_Cell_Id}  MCC-${MCC}  MNC-${MNC}
    ...  ${techno.upper()}_Neighb_Cell_HO
    ${counter value}=  Get Cumulative PM Counter Value from Admin
    ...  ${counter_path}   ${counter_id}  ${handover_event_epoch_time_start}  ${handover_event_epoch_time_end}  ${PM_duration}  ${alias}
    Check counter value  ${counter_id}  ${counter value}  ${expected_value}

Check attach UE on expected cell
    [Arguments]  ${admin_alias}  ${expected_cell_id}  ${techno}
    Set Test Variable  ${status_second_try}  False
    ${wcdma_cell_id}=  Set Variable If  "${techno.upper()}"=="WCDMA"  True  False
    ${actual_ue_ip}  ${actual_cell_id}=  Taf Ue Attach Single UE  ue_alias=${alias_ue}  expected_serving_cell_list=None  timeout=120
    ...  call_type=data  wcdma_cell_id=${wcdma_cell_id}
    Log  UE ${alias_ue} attached on cell ${actual_cell_id} with IP ${actual_ue_ip}  console=True
    Log  Checking cell validity  console=True
    Run Keyword If  "${actual_cell_id}" == "${expected_cell_id}"
    ...  Log  UE ${alias_ue} succesfully attached on expected ${TECHNO} cell ${actual_cell_id}  console=True
    ...  ELSE IF  "${TECHNO}"!="NR"  Fail  UE did not attach on expected cell. Actual cell ID: ${actual_cell_id}!
    ...  ELSE  Check NR NSA Call  ${admin_alias}  ${actual_cell_id}  ${expected_cell_id}  ${alias_ue}
    Set Test Variable  ${status_second_try}  True

Check NR NSA Call
    [Arguments]  ${nr_admin_alias}  ${anchor_cell_id}  ${expected_nr_cell_id}  ${alias_ue}
    Log  Checking if NR call is NSA  console=True
    ${anchor_cell_confirmed}=  Set Variable  ${FALSE}
    FOR  ${admin_alias}  IN  @{extended_admin_alias_list}
        ${anchor_relations}=  Set Variable  ${full_config_anchor_cell_relation["${admin_alias}"]}
        ${anchor_cell_ids}=  Get Dictionary Keys  ${anchor_relations}
        Run Keyword If  ${anchor_cell_id} in ${anchor_cell_ids}  Run Keywords
        ...  Log  Cell ID ${anchor_cell_id} confirmed as anchor cell on BTS ${admin_alias}  console=True
        ...  AND  Set Test Variable   ${anchor_cell_confirmed}  ${TRUE}
        ...  AND  Exit FOR Loop
    END
    Run Keyword If  not ${anchor_cell_confirmed}  Fail  Cell ID ${anchor_cell_id} not confirmed as anchor cell, NR attach is failed!
    Log  Checking NR NSA attach using aashell  console=True
    ${pci}=  Set Variable  ${NRCellid_PCI[${expected_nr_cell_id}]}
    ${expected_pci_list}=  Create List  ${pci}
    ${use_hop}=  Set Variable If  "${nr_admin_alias}"=="Master"  False  True
    ${nr_cell_id_call}=  Taf Ue Verify if UE is attached on NR cell with aahsell  ${alias_ue}  ${expected_pci_list}  ${nr_admin_alias}  ${use_hop}
    ...  False
    Log  Succesfully verified NR NSA attach!  console=True
    Set Test Variable  ${nr_cell_id_call}

Proceed to data transfer start on UE
    [Arguments]  ${protocol}  ${call_direction}  ${techno}
    ${CALL_DURATION}=  Set Variable  1800s
    Extract current cell target BW based on cell ID  ${Source_Cell_ID}  ${techno}
    ${bw}=  Set Variable  ${CELL_TARGET_BW_params["Target_Bandwidth"]}
    Run Keyword If  '${call_direction}' not in ['uplink', 'downlink', 'uplink_downlink']
    ...  Fail  Wrong call direction set ${call_direction}. Accepted values: uplink, downlink, uplink_downlink
    Translate Call Direction  ${call_direction}
    ${packet_size}=  Set Variable If  ('gsm' in '${techno.lower()}' or 'wcdma' in '${techno.lower()}')  1200  1400
    Run Keyword If  '${call_direction}' != 'ul_dl'
    ...  Taf Ue Start Data Transfer Single UE  ue_alias=${alias_ue}  dt_name=dt_${alias_ue}_${call_direction}
    ...  call_duration=${CALL_DURATION}  call_direction=${call_direction}  throughput=${bw}  protocol=${protocol}  packet_size=${packet_size}
    ...  ELSE  Run Keywords
    ...  Taf Ue Start Data Transfer Single UE  ue_alias=${alias_ue}  dt_name=dt_${alias_ue}_dl
    ...  call_duration=${CALL_DURATION}  call_direction=dl  throughput=${bw}  protocol=${PROTOCOL}  packet_size=${packet_size}
    ...  AND  Taf Ue Start Data Transfer Single UE  ue_alias=${alias_ue}  dt_name=dt_${alias_ue}_ul
    ...  call_duration=${CALL_DURATION}  call_direction=ul  throughput=${bw}  protocol=${PROTOCOL}  packet_size=${packet_size}

Translate Call Direction
    [Arguments]  ${direction}
    Run Keyword If  '${direction}' == 'uplink'  Set Test Variable  ${CALL_DIRECTION}  ul
    Run Keyword If  '${direction}' == 'downlink'  Set Test Variable  ${CALL_DIRECTION}  dl
    Run Keyword If  '${direction}' == 'uplink_downlink'  Set Test Variable  ${CALL_DIRECTION}  ul_dl

Start Sessions on External BTS if needed
    ${BTS_EXT_alias_list}=  Create List
    Set Test Variable  ${BTS_EXT_alias_list}
    Return From Keyword If  "${BTS_OAM_IP_ADDRESSES}" == "None"
    ${BTS_OAM_IP_ADDRESSES_LIST}=  Split String  ${BTS_OAM_IP_ADDRESSES}  separator=
    FOR  ${BTS_OAM_IP}  IN  @{BTS_OAM_IP_ADDRESSES_LIST}
        Wait until keyword succeeds  10 min  5 sec
        ...  Start ADMIN On External BTS  bts_mplane_ip=${BTS_OAM_IP}  alias=BTS_EXT_${BTS_OAM_IP}
        Append To List  ${BTS_EXT_alias_list}  BTS_EXT_${BTS_OAM_IP}
    END

Particular Teardown
    Run Keyword If  '${DETACH_UE}' == 'True'
    ...  Run Keyword And Return Status  Taf Ue Detach All Used UEs
    Return From Keyword If  "${BTS_OAM_IP_ADDRESSES}" == "None"
    ${BTS_OAM_IP_ADDRESSES_LIST}=  Split String  ${BTS_OAM_IP_ADDRESSES}  separator=
    FOR  ${BTS_OAM_IP}  IN  @{BTS_OAM_IP_ADDRESSES_LIST}
        Wait until keyword succeeds  10 min  5 sec
        ...  Teardown Admin  alias=BTS_EXT_${BTS_OAM_IP}
    END

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${FALSE}  infomodelSetup=${FALSE}  newAlarmsFormat=${TRUE}

TC Teardown
    Common Test Teardown
