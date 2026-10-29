*** Settings ***
Documentation    TC__RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
Variables    tc_variables/RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${BTS_OAM_IP_ADDRESSES}    None                # List of all IP addresses of external BTS that contain anchor cell relation to any of the BTS NSA 5G
                                              # Cells separated by space. Default value: None.
                                              # Example: 10.0.71.104 10.0.71.204
${UEs_CAPABILITIES}    UE1 UE2 UE3 UE4         # List of Capabilities used to identify UEs from UE config;
                                              # The list elements must be separated by space
                                              # Example: LTE_UE WCDMA_UE NR_SA_UE
${UEs_BTS_CALL}    BTS1 BTS2 BTS3 BTS4         # List of BTS on which each UE is expected to perform call; Values: BTSx where x is the BTS number
                                              # Each list element must match in position one-on-one UEs_CAPABILITIES elements
                                              # The list elements must be separated by space
${UEs_TECHNOS}    NR LTE NR LTE                # List of tehnologies where each UE is expected to perform call; Possible Values: NR, LTE, WCDMA, GSM.
                                              # Each list element must match in position one-on-one UEs_CAPABILITIES elements
                                              # The list elements must be separated by space
${CELLS}    DEFAULT;DEFAULT;DEFAULT;DEFAULT    # List of lists of cells separated by ; on which UE call is expected;
                                              # The cell IDs in the lists (when not left DEFAULT) are separated by space
                                              # DEFAULT value means any cell that fulfills the other coditions (BTS, TECHNO) is considered ok
                                              # for call
                                              # Each list element must match in position one-on-one UEs_CAPABILITIES elements
                                              # For NR - use NRCellID; For LTE - use Eutran Cell Id; For WCDMA - use Global Cell Id;
                                              # For GSM - use Cell CI
                                              # Examples:
                                              # 12345 12346;35222 35223;12356 12357;35332 35333
                                              # DEFAULT;DEFAULT;DEFAULT;DEFAULT
                                              # 12345 12346;23468;DEFAULT;35332 35333 35334 35335 35336
${CALL_DIRECTIONS_UEs}    downlink downlink downlink downlink    # List of call direction of data transfer call for each UE1;
                                                                # Possible values: "downlink", "uplink" and "uplink_downlink"
                                                                # Each list element must match in position one-on-one UEs_CAPABILITIES elements
                                                                # list-type arguments
                                                                # The list elements must be separated by space
                                                                # Default value: downlink downlink downlink downlink
${CALL_DURATION}    100                        # Duration of data call for all UEs (in seconds); Default value: 100
${PROTOCOLS}    udp udp udp udp                # List of data transfer protocol for each UE. e.q. udp, tcp, ftp
                                              # Each list element must match in position one-on-one UEs_CAPABILITIES elements
                                              # The list elements must be separated by space
${DETACH_UEs}    False                        # Specify whether to dettach the UEs after the test execution; Possible values: True/False.
                                              # Default value: False
${CHECK_ATTACH_ONLY}    False                  # Flag for skipping data transfer part and perform check of attach only;
                                              # Possible values: True/False.
                                              # Default value: False
${USE_ATTENUATOR}    NO                        # Flag used for specifying if attenuator will be used in case of UEs with single eligible cell
                                              # for attach (specified by ID in the input argument CELLS). Possible values: YES, NO. Default value: NO
${SKIP_FAILING_UE}    False                   # Flag for skipping failing UEs. If set to True, will skip all UEs where at least one operation failed
                                              # from that point on. In the case of Attach operation or throughput operation, additional instant
                                              # BTS snapshot will be collected. Possible values: True, False. Default value: False
${DELAY_BETWEEN_SNAPSHOTS}    30              # In case of Snapshot collections during test (SKIP_FAILING_UE=True), defined as the delay time between
                                              # Snapshot collections measured in seconds. Default value: 30
${THPUT_CHECK_BTS_LOGS}    False              # Flag used to specify if throughput value check will be based on BTS Logs or Iperf;
                                              # Possible values: True (check from BTS Logs); False (check from Iperf report); Default value: False
                                              # Only applicable for NR and LTE; WCDMA and GSM will still be checked from iperf regardless of Flag
                                              # value
${UL_UE_GROUP_UEs}     0 0 0 0                 # List of UL UE groups used to extract UL throughput value from BTS Logs;
                                              # Only applicable if THPUT_CHECK_BTS_LOGS==True and TECHNO==LTE, otherwise not relevant
                                              # The list elements must be separated by space
                                              # Example: 0 1 0 1

*** Keywords ***
TC__RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    [Documentation]
    ...  [CASE LINK]:  https://jiradc.ext.net.nokia.com/browse/TAT-26841
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...
    ...  Test is used for performing simultaneous data transfer calls on one or more UEs, one or more RAT, one or more BTS
    ...  User defines which UE performs what call and where
    ...  For Data transfer part this TC requires mandatory CELL_TARGET_BW file set up
    ...
    ...  Below are described the variables that you can complete:
    ...
    ...
    ...  - BTS_OAM_IP_ADDRESSES        ---- List of all IP addresses of external BTS that contain anchor cell relation to any of the BTS NSA 5G Cells
    ...                                     separated by space. Default value: None.
    ...                                     Example: 10.0.71.104 10.0.71.204
    ...
    ...  - UEs_CAPABILITIES            ---- List of Capabilities used to identify UEs from UE config;
    ...                                     The list elements must be separated by space
    ...                                     Example: LTE_UE WCDMA_UE NR_SA_UE
    ...
    ...  - UEs_BTS_CALL                ---- List of BTS on which each UE is expected to perform call; Values: BTSx where x is the BTS number
    ...                                     Each list element must match in position one-on-one UEs_CAPABILITIES elements
    ...                                     The list elements must be separated by space
    ...
    ...  - UEs_TECHNOS                 ---- List of tehnologies where each UE is expected to perform call; Possible Values: NR, LTE, WCDMA, GSM.
    ...                                     Each list element must match in position one-on-one UEs_CAPABILITIES elements
    ...                                     The list elements must be separated by space
    ...
    ...  - CELLS                       ---- List of lists of cells separated by ; on which UE call is expected;
    ...                                     The cell IDs in the lists (when not left DEFAULT) are separated by space
    ...                                     DEFAULT value means any cell that fulfills the other coditions (BTS, TECHNO) is considered ok for call
    ...                                     Each list element must match in position one-on-one UEs_CAPABILITIES elements
    ...                                     For NR - use NRCellID; For LTE - use Eutran Cell Id; For WCDMA - use Global Cell Id;
    ...                                     For GSM - use Cell CI
    ...                                     Examples:
    ...                                     12345 12346;35222 35223;12356 12357;35332 35333
    ...                                     DEFAULT;DEFAULT;DEFAULT;DEFAULT
    ...                                     12345 12346;23468;DEFAULT;35332 35333 35334 35335 35336
    ...
    ...  - CALL_DIRECTIONS_UEs         ---- List of call direction of data transfer call for each UE1;
    ...                                     Possible values: "downlink", "uplink" and "uplink_downlink"
    ...                                     Each list element must match in position one-on-one UEs_CAPABILITIES elements
    ...                                     The list elements must be separated by space. Default value: downlink downlink downlink downlink
    ...
    ...  - CALL_DURATION               ---- Duration of data call for all UEs (in seconds); Default value: 100
    ...
    ...  - PROTOCOLS                   ---- List of ata transfer protocol for each UE. e.q. udp, tcp, ftp
    ...                                     Each list element must match in position one-on-one UEs_CAPABILITIES elements
    ...                                     The list elements must be separated by space
    ...
    ...  - DETACH_UEs                  ---- Specify whether to dettach the UEs after the test execution; Possible values: True/False.
    ...                                     Default value: False
    ...
    ...  - CHECK_ATTACH_ONLY           ---- Flag for skipping data transfer part and perform check of attach only;
    ...                                     Possible values: True/False.
    ...                                     Default value: False
    ...
    ...  - USE_ATTENUATOR              ---- Flag used for specifying if attenuator will be used in case of UEs with single eligible cell
    ...                                     for attach (specified by ID in the input argument CELLS). Possible values: YES, NO. Default value: NO
    ...
    ...  - SKIP_FAILING_UE             ---- Flag for skipping failing UEs. If set to True, will skip all UEs that had at least an operation failed
    ...                                     from that point on. In the case of Attach operation or Throughput operations, additional instant
    ...                                     BTS snapshot will be collected. Possible values: True, False. Default value: False
    ...
    ...  - DELAY_BETWEEN_SNAPSHOTS     ---- In case of Snapshot collections during test (SKIP_FAILING_UE=True), defined as the delay time between
    ...                                     Snapshot collections measured in seconds. Default value: 30
    ...
    ...  - THPUT_CHECK_BTS_LOGS        ---- Flag used to specify if throughput value check will be based on BTS Logs or Iperf;
    ...                                     Possible values: True (check from BTS Logs); False (check from Iperf report); Default value: False
    ...                                     Only applicable for NR and LTE; WCDMA and GSM will still be checked from iperf regardless of Flag
    ...                                     value
    ...
    ...  - UL_UE_GROUP_UEs             ---- List of UL UE groups used to extract UL throughput value from BTS Logs;
    ...                                     Only applicable if THPUT_CHECK_BTS_LOGS==True and TECHNO==LTE, otherwise not relevant
    ...                                     The list elements must be separated by space
    ...                                     Example: 0 1 0 1
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 21.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26814 - TC Delivery
    ...  - 28.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27217 - adjust data transfer packet size depending on RAT
    ...  - 19.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27280 - adjust automatically the channel attenuation using hytem
    ...  - 19.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27279 - adjustment for configurations where more than one UE are attached to
    ...  different NR cells on the same NR RAT
    ...  - 14.05.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27276 - RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    ...  adjustment for FAILED case when call is performed on multiple UEs
    ...  - 24.05.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27456 - Improvement needed for NSA mobility case when call is performed
    ...  on multiple RMODs
    ...  - 10.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27739 - Calls] Throughput measure from logs - robot part + 1 TC
    ...  - 12.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28440 - adapt
    ...  RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue to work on Cloud BTS
    ...  - 12.03.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28856 - Use only Common TC Setup and TC Teardown in RRM TCs
    ...  - 09.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29068 - increase Require UE timeout from 180s to 300s

    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-26814_RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.png

    Set Tags    CA-RRM    OWNER-dorin.caluser@nokia.com    AUTHOR-gabriel.stanculescu@nokia.com;    PHASE-QT    SW-SBTS24R2

    TC Parameters Check
    Step 1: Get Full Configuration Cell Info and Anchor Relation Info
    Step 2: Perform Simultaneous Data Call on all UEs
    Step 3: Check final number and state of Cells and RMs
    Check Test Verdict

    [Teardown]  Particular Teardown

TC Parameters Check
    ${UEs_CAPABILITIES_LIST}=  Split String  ${UEs_CAPABILITIES}  separator=
    Set Test Variable  ${UEs_CAPABILITIES_LIST}
    ${UEs_BTS_CALL_LIST}=  Split String  ${UEs_BTS_CALL}  separator=
    Set Test Variable  ${UEs_BTS_CALL_LIST}
    ${UEs_TECHNOS_LIST}=  Split String  ${UEs_TECHNOS}  separator=
    Set Test Variable  ${UEs_TECHNOS_LIST}
    ${CELLS_LIST}=  Split String  ${CELLS}  separator=;
    Set Test Variable  ${CELLS_LIST}
    ${CALL_DIRECTIONS_UEs_LIST}=  Split String  ${CALL_DIRECTIONS_UEs}  separator=
    Set Test Variable  ${CALL_DIRECTIONS_UEs_LIST}
    ${PROTOCOLS_LIST}=  Split String  ${PROTOCOLS}  separator=
    Set Test Variable  ${PROTOCOLS_LIST}
    ${UL_UE_GROUP_LIST}=  Split String  ${UL_UE_GROUP_UEs}  separator=
    Set Test Variable  ${UL_UE_GROUP_LIST}

    ${UEs_CAPABILITIES_len}=  Get Length  ${UEs_CAPABILITIES_LIST}
    ${UEs_BTS_CALL_len}=  Get Length  ${UEs_BTS_CALL_LIST}
    ${UEs_TECHNOS_len}=  Get Length  ${UEs_TECHNOS_LIST}
    ${CELLS_len}=  Get Length  ${CELLS_LIST}
    ${CALL_DIRECTIONS_UEs_len}=  Get Length  ${CALL_DIRECTIONS_UEs_LIST}
    ${PROTOCOLS_len}=  Get Length  ${PROTOCOLS_LIST}

    ${lenghts_list}=  Create List
    ...  ${UEs_CAPABILITIES_len}  ${UEs_BTS_CALL_len}  ${UEs_TECHNOS_len}  ${CELLS_len}  ${CALL_DIRECTIONS_UEs_len}  ${PROTOCOLS_len}

    ${lenghts_list}=  Remove Duplicates  ${lenghts_list}

    ${lengths_lists_length}=  Get Length  ${lenghts_list}
    Run Keyword If
    ...  ${lengths_lists_length}!=1
    ...  Fail
    ...  TC Parameter check failed: UEs_CAPABILITIES, UEs_BTS_CALL, UEs_TECHNOS, CELLS, CALL_DIRECTIONS_UEs, PROTOCOLS should have the same length!
    Set Test Variable  ${test_verdict}  Passed

Step ${index}: Get Full Configuration Cell Info and Anchor Relation Info
    Log  Step ${index}: Get Full Configuration Cell Info and Anchor Relation Info  console=True
    ${BTS_EXT_alias_list}=  Create List
    Set Test Variable  ${BTS_EXT_alias_list}

    ${BTS_OAM_IP_ADDRESSES_LIST}=  Split String  ${BTS_OAM_IP_ADDRESSES}  separator=
    FOR  ${BTS_OAM_IP}  IN  @{BTS_OAM_IP_ADDRESSES_LIST}
        Exit For Loop If  "${BTS_OAM_IP_ADDRESSES}" == "None"
        Wait until keyword succeeds  10 min  5 sec
        ...  Start ADMIN On External BTS  bts_mplane_ip=${BTS_OAM_IP}  alias=BTS_EXT_${BTS_OAM_IP}
        Append To List  ${BTS_EXT_alias_list}  BTS_EXT_${BTS_OAM_IP}
    END

    Get Full Configuration Anchor Cells Relations
    Get Full Configuration Cell IDs
    Get cell IDs list for call

Step ${index}: Perform Simultaneous Data Call on all UEs
    Log  Step ${index}: Perform Simultaneous Data Call on all UEs  console=True
    Log  Attempting to reserve UEs to be handled by taf.ue library  console=True
    ${skipped_ues}=  Create List
    Set Test Variable  ${skipped_ues}
    ${index}=  Set Variable  0
    FOR  ${BTS_CALL}  IN  @{UEs_BTS_CALL_LIST}
        ${ue_capability}=  Set Variable  ${UEs_CAPABILITIES_LIST[${index}]}
        ${techno}=  Set Variable  ${UEs_TECHNOS_LIST[${index}]}
        ${alias_ue}=  Set Variable  ${ue_capability}_on_${BTS_CALL}_${techno}
        ${status}=  Run Keyword And Return Status  Taf Ue Require Single UE  ue_alias=${alias_ue}  capabilities=${ue_capability}  timeout=300
        Run Keyword If  '${status}'=='True'
        ...  Log  Succesfully required UE capability ${ue_capability} and assigned alias ${alias_ue}  console=True
        Run Keyword If  '${status}'=='False' and ${SKIP_FAILING_UE}  Run Keywords
        ...  Log Long String  Since SKIP_FAILING_UE=True and failed to Require UE ${UEs_CAPABILITIES_LIST[${index}]}, this UE will be skipped
        ...  for the rest of the test
        ...  AND  Append To List  ${skipped_ues}  ${UEs_CAPABILITIES_LIST[${index}]}
        Run Keyword If  '${status}'=='False' and "${SKIP_FAILING_UE}"!="True"
        ...  Fail  Failed to require UE ${UEs_CAPABILITIES_LIST[${index}]}!
        ${index}=  Evaluate  ${index}+1
    END
    Run Keyword If  "${USE_ATTENUATOR}" == "YES"  Set initial radio conditions for all UEs where single eligible cell is mentioned
    Log  Attempting to attach UEs  console=True
    ${ue_to_cell_id_mapping}=  Create Dictionary
    Set Test Variable  ${ue_to_cell_id_mapping}
    ${index}=  Set Variable  0
    FOR  ${BTS_CALL}  IN  @{UEs_BTS_CALL_LIST}
        ${ue_capability}=  Set Variable  ${UEs_CAPABILITIES_LIST[${index}]}
        ${index}=  Set Variable If  '${ue_capability}' in ${skipped_ues}
        ...  ${index}+1  ${index}
        Run Keyword If  '${ue_capability}' in ${skipped_ues}
        ...  Run Keywords
        ...  Log  UE ${UEs_CAPABILITIES_LIST[${index}-1]} will be skipped!  console=True
        ...  AND  Continue For Loop
        ${BTS_number}=  Fetch From Right  ${BTS_CALL}  BTS
        ${BTS_number}=  Evaluate  ${BTS_number}-1
        ${admin_alias}=  Set Variable  ${alias_list[${BTS_number}]}
        ${techno}=  Set Variable  ${UEs_TECHNOS_LIST[${index}]}
        ${alias_ue}=  Set Variable  ${ue_capability}_on_${BTS_CALL}_${techno}
        ${ue_info}=  Taf UE Get UE info based on capabilities  searched_capability=${ue_capability}  mnb_profile_used=False
        ${status_first_try}=  Run Keyword And Return Status  Check attach UE on expected cell  ${alias_ue}  ${admin_alias}  ${techno}
        Run Keyword If  '${status_first_try}' == 'False'  Run Keywords
        ...  Log  First attempt was not successful so the UE will be reseted!  console=True
        ...  AND  Run Keyword And Ignore Error  Taf Ue Reboot UE based on UE class  ue_alias=${alias_ue}  ue_class=${ue_info[0]}
        ...  AND  Sleep  60s
        ...  AND  Run Keyword And Return Status  Check attach UE on expected cell  ${alias_ue}  ${admin_alias}  ${techno}
        Run Keyword If  '${status_first_try}'=='True'
        ...  Log  UE ${alias_ue} succesfully attached!  console=True
        Run Keyword If  '${status_first_try}'=='False'
        ...  Run Keyword If  '${status_second_try}'=='True'
        ...  Log  UE ${alias_ue} succesfully attached  console=True
        Run Keyword If  '${status_first_try}'=='False'
        ...  Run Keyword If  '${status_second_try}'=='False'
        ...  Run Keyword If  '${SKIP_FAILING_UE}'=='False'
        ...  Fail  Failed to attach UE ${alias_ue}!
        Run Keyword If  '${status_first_try}'=='False'
        ...  Run Keyword If  '${status_second_try}'=='False' and '${SKIP_FAILING_UE}'=='True'  Run Keywords
        ...  Log Long String  Since SKIP_FAILING_UE=True and failed to Attach UE ${UEs_CAPABILITIES_LIST[${index}]}, this UE will be skipped
        ...  for the rest of the test
        ...  AND  Append To List  ${skipped_ues}  ${UEs_CAPABILITIES_LIST[${index}]}
        ...  AND  Mid Test Snapshot collection  ${admin_alias}  Attach_Failed
        ${index}=  Evaluate  ${index}+1
    END
    Run Keyword If  '${CHECK_ATTACH_ONLY}'=='True'
    ...  Log  Data transfer part will be skipped due to attach_only flag set to True!  console=True
    ${index}=  Set Variable  0
    FOR  ${BTS_CALL}  IN  @{UEs_BTS_CALL_LIST}
        ${ue_capability}=  Set Variable  ${UEs_CAPABILITIES_LIST[${index}]}
        ${index}=  Set Variable If  '${ue_capability}' in ${skipped_ues}
        ...  ${index}+1  ${index}
        Run Keyword If  '${ue_capability}' in ${skipped_ues}
        ...  Run Keywords
        ...  Log  UE ${UEs_CAPABILITIES_LIST[${index}-1]} will be skipped!  console=True
        ...  AND  Continue For Loop
        ${techno}=  Set Variable  ${UEs_TECHNOS_LIST[${index}]}
        ${alias_ue}=  Set Variable  ${ue_capability}_on_${BTS_CALL}_${techno}
        Run Keyword If  '${CHECK_ATTACH_ONLY}'=='True' and ${DETACH_UEs}  Run Keywords
        ...  Log  Detaching UE ${alias_ue}  console=True
        ...  AND  Taf Ue Detach Single UE  ue_alias=${alias_ue}
        ${index}=  Evaluate  ${index}+1
    END
    Run Keyword If  '${CHECK_ATTACH_ONLY}'== 'True'  Return From Keyword
    Set Test Variable  ${IMPORT_CELL_TARGET_BW_FROM_CONFIG}  True
    Log  Attempting start data call on all UEs  console=True
    ${index}=  Set Variable  0
    FOR  ${BTS_CALL}  IN  @{UEs_BTS_CALL_LIST}
        ${ue_capability}=  Set Variable  ${UEs_CAPABILITIES_LIST[${index}]}
        ${index}=  Set Variable If  '${ue_capability}' in ${skipped_ues}
        ...  ${index}+1  ${index}
        Run Keyword If  '${ue_capability}' in ${skipped_ues}
        ...  Run Keywords
        ...  Log  UE ${UEs_CAPABILITIES_LIST[${index}-1]} will be skipped!  console=True
        ...  AND  Continue For Loop
        ${protocol}=  Set Variable  ${PROTOCOLS_LIST[${index}]}
        ${techno}=  Set Variable  ${UEs_TECHNOS_LIST[${index}]}
        ${alias_ue}=  Set Variable  ${ue_capability}_on_${BTS_CALL}_${techno}
        ${call_direction}=  Set Variable  ${CALL_DIRECTIONS_UEs_LIST[${index}]}
        ${cell_id}=  Set Variable  ${CELLS_LIST[${index}]}
        Log  Attempting start data call on ${alias_ue}  console=True
        ${status}=  Run Keyword And Return Status  Proceed to data transfer start on UE
        ...  ${alias_ue}  ${protocol}  ${call_direction}  ${techno}
        Run Keyword If  '${status}'=='True'
        ...  Log  Succesfully started data transfer on UE ${alias_ue}!  console=True
        Run Keyword If  '${status}'=='False' and ${SKIP_FAILING_UE}  Run Keywords
        ...  Log Long String  Since SKIP_FAILING_UE=True and failed to start data transfer on UE ${UEs_CAPABILITIES_LIST[${index}]},
        ...  this UE will be skipped for the rest of the test
        ...  AND  Append To List  ${skipped_ues}  ${UEs_CAPABILITIES_LIST[${index}]}
        Run Keyword If  '${status}'=='False' and "${SKIP_FAILING_UE}"!="True"
        ...  Fail  Failed to start data transfer on UE ${alias_ue}!
        ${index}=  Evaluate  ${index}+1
    END
    ${thput_start_time}=  Run Keyword If   '${THPUT_CHECK_BTS_LOGS}' == 'True'  syslog_thput.Get Syslog Throughput Analysis Start Time
    Run Keyword If   '${THPUT_CHECK_BTS_LOGS}' == 'True'  Set Test Variable  ${thput_start_time}
    Log  Succesfully started data call on all UEs  console=True
    Log  Wait for the call operations to end  console=True
    ${index}=  Set Variable  0
    FOR  ${BTS_CALL}  IN  @{UEs_BTS_CALL_LIST}
        ${ue_capability}=  Set Variable  ${UEs_CAPABILITIES_LIST[${index}]}
        ${index}=  Set Variable If  '${ue_capability}' in ${skipped_ues}
        ...  ${index}+1  ${index}
        Run Keyword If  '${ue_capability}' in ${skipped_ues}
        ...  Run Keywords
        ...  Log  UE ${UEs_CAPABILITIES_LIST[${index}-1]} will be skipped!  console=True
        ...  AND  Continue For Loop
        ${techno}=  Set Variable  ${UEs_TECHNOS_LIST[${index}]}
        ${alias_ue}=  Set Variable  ${ue_capability}_on_${BTS_CALL}_${techno}
        ${call_direction}=  Set Variable  ${CALL_DIRECTIONS_UEs_LIST[${index}]}
        ${status}=  Run Keyword And Return Status  Await data call finish on UE  ${alias_ue}  ${call_direction}
        Run Keyword If  '${status}'=='True'
        ...  Log  Succesfully await data transfer on UE ${alias_ue}!  console=True
        Run Keyword If  '${status}'=='False' and ${SKIP_FAILING_UE}  Run Keywords
        ...  Log Long String  Since SKIP_FAILING_UE=True and failed await data trasnfer finish on UE ${UEs_CAPABILITIES_LIST[${index}]},
        ...  this UE will be skipped for the rest of the test
        ...  AND  Append To List  ${skipped_ues}  ${UEs_CAPABILITIES_LIST[${index}]}
        Run Keyword If  '${status}'=='False' and "${SKIP_FAILING_UE}"!="True"
        ...  Fail  Failed to await data transfer finish on UE ${alias_ue}!
        Log  Call operation ended succesfully for ${alias_ue}  console=True
        ${index}=  Evaluate  ${index}+1
    END
    Log  Call operations ended succesfully for all UEs  console=True
    Log  Checking call results for all UEs  console=True
    ${index}=  Set Variable  0
    FOR  ${BTS_CALL}  IN  @{UEs_BTS_CALL_LIST}
        ${ue_capability}=  Set Variable  ${UEs_CAPABILITIES_LIST[${index}]}
        ${index}=  Set Variable If  '${ue_capability}' in ${skipped_ues}
        ...  ${index}+1  ${index}
        Run Keyword If  '${ue_capability}' in ${skipped_ues}
        ...  Run Keywords
        ...  Log  UE ${UEs_CAPABILITIES_LIST[${index}-1]} will be skipped!  console=True
        ...  AND  Continue For Loop
        ${BTS_number}=  Fetch From Right  ${BTS_CALL}  BTS
        ${BTS_number}=  Evaluate  ${BTS_number}-1
        ${admin_alias}=  Set Variable  ${alias_list[${BTS_number}]}
        ${techno}=  Set Variable  ${UEs_TECHNOS_LIST[${index}]}
        ${alias_ue}=  Set Variable  ${ue_capability}_on_${BTS_CALL}_${techno}
        ${call_direction}=  Set Variable  ${CALL_DIRECTIONS_UEs_LIST[${index}]}
        ${protocol}=  Set Variable  ${PROTOCOLS_LIST[${index}]}
        ${techno}=  Set Variable  ${UEs_TECHNOS_LIST[${index}]}
        ${cell_id}=  Set Variable  ${CELLS_LIST[${index}]}
        ${ue_group}=  Set Variable  ${UL_UE_GROUP_LIST[${index}]}
        ${status}=  Run Keyword And Return Status  Stop and check data call on UE  ${alias_ue}  ${admin_alias}  ${techno}  ${call_direction}
        ...  ${protocol}  ${ue_group}
        Run Keyword If  '${status}'=='True'
        ...  Log  Succesfully stopped and checked data transfer values for UE ${alias_ue}!  console=True
        Run Keyword If  '${status}'=='False' and ${SKIP_FAILING_UE}  Run Keywords
        ...  Log Long String  Since SKIP_FAILING_UE=True and failed checking data trasnfer finish on UE ${UEs_CAPABILITIES_LIST[${index}]},
        ...  this UE will be skipped for the rest of the test
        ...  AND  Append To List  ${skipped_ues}  ${UEs_CAPABILITIES_LIST[${index}]}
        ...  AND  Mid Test Snapshot collection  ${admin_alias}  Throughput_check_failed
        Run Keyword If  '${status}'=='False' and "${SKIP_FAILING_UE}"!="True"
        ...  Fail  Failed to stop and check data transfer on UE ${alias_ue}!
        ${index}=  Evaluate  ${index}+1
    END
    Log  Checking call results for all UEs succesful!  console=True
    Run Keyword If  not ${DETACH_UEs}  Return From Keyword
    Log  Detaching all UEs  console=True
    ${index}=  Set Variable  0
    FOR  ${BTS_CALL}  IN  @{UEs_BTS_CALL_LIST}
        ${ue_capability}=  Set Variable  ${UEs_CAPABILITIES_LIST[${index}]}
        ${index}=  Set Variable If  '${ue_capability}' in ${skipped_ues}
        ...  ${index}+1  ${index}
        Run Keyword If  '${ue_capability}' in ${skipped_ues}
        ...  Run Keywords
        ...  Log  UE ${UEs_CAPABILITIES_LIST[${index}-1]} will be skipped!  console=True
        ...  AND  Continue For Loop
        ${techno}=  Set Variable  ${UEs_TECHNOS_LIST[${index}]}
        ${alias_ue}=  Set Variable  ${ue_capability}_on_${BTS_CALL}_${techno}
        Taf Ue Detach Single UE  ue_alias=${alias_ue}
        Log  ${alias_ue} succesfully detached!  console=True
        ${index}=  Evaluate  ${index}+1
    END
    Log  Succesfully detached all UEs!  console=True

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Cells state is checked according to operationalState attribute
    ...  Check if number of configured cells and radio modules in SCF are properly mapping on BTS running view.
    ...  Also check RMs operationalState

    [Timeout]  30 min
    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Set initial radio conditions for all UEs where single eligible cell is mentioned
    Log  Since USE_ATTENUATOR=YES, will proceed to setting optimal radio conditions for all UEs that have a single eligible cell mentioned for attach
    ...  console=True
    Log  Cutting cells signal for all ports defined in pa.yaml  console=True
    ${techs}=  Create List   NR  LTE  WCDMA  GSM
    FOR  ${tech}  IN  @{techs}
        Run Keyword And Return Status  Cut Cells Signal  tech=${tech}
    END
    ${index}=  Set Variable  0
    FOR  ${BTS_CALL}  IN  @{UEs_BTS_CALL_LIST}
        ${BTS_number}=  Fetch From Right  ${BTS_CALL}  BTS
        ${BTS_number}=  Evaluate  ${BTS_number}-1
        ${admin_alias}=  Set Variable  ${alias_list[${BTS_number}]}
        ${ue_capability}=  Set Variable  ${UEs_CAPABILITIES_LIST[${index}]}
        ${techno}=  Set Variable  ${UEs_TECHNOS_LIST[${index}]}
        ${alias_ue}=  Set Variable  ${ue_capability}_on_${BTS_CALL}_${techno}
        ${cell_ids_list}=  Split String  ${CELLS_LIST[${index}]}  separator=
        ${len}=  Get Length  ${cell_ids_list}
        ${index}=  Evaluate  ${index}+1
        Continue For Loop If  ${len}>1
        Continue For Loop If  "${cell_ids_list[0]}"=="DEFAULT"
        Log  Setting good radio attenuation for UE ${alias_ue}  console=True
        Set Cell Attenuation  ${cell_ids_list[0]}  0  ${techno}  ${admin_alias}
        Check if NR cell needs commissioning  ${cell_ids_list[0]}
    END

Check if NR cell needs commissioning
    [Arguments]  ${nr_cell_id}
    ${anhor_cell}=  Set Variable  None
    ${alias_anhor_cell}=  Set Variable  None
    FOR  ${admin_alias}  IN  @{extended_admin_alias_list}
        ${anchor_relations}=  Set Variable  ${full_config_anchor_cell_relation["${admin_alias}"]}
        ${nr_cell_ids}=  Get nr cell IDs from all anchor relations  ${anchor_relations}
        Run Keyword If  '${nr_cell_id}' in ${nr_cell_ids}  Run Keywords
        ...  Log  Cell ID ${nr_cell_id} has anchor cell on BTS ${admin_alias}  console=True
        ...  AND  Log  Identifying anchor cell id  console=True
        ...  ELSE  Continue For Loop
        ${anchor_cell_id}=  Identify anchor cell for specific NR cell  ${nr_cell_id}  ${anchor_relations}
        Log  Anchor cell identified: ${anchor_cell_id}  console=True
        Log  Performing recommissioning for setting ${nr_cell_id} as target cell ID for anchor cell ${anchor_cell_id}   console=True
        Taf Ue Set target NR cell from defaultLnRelGnbCellId  ${anchor_cell_id}  ${nr_cell_id}  ${admin_alias}
        Exit For Loop
    END

Get nr cell IDs from all anchor relations
    [Arguments]  ${anchor_relations}
    ${nr_cell_ids}=  Create List
    FOR  ${anchor_relation}  IN  @{anchor_relations}
        ${nr_cell_ids}=  Combine Lists  ${nr_cell_ids}  ${anchor_relations[${anchor_relation}]}
    END
    Remove Duplicates  ${nr_cell_ids}
    [Return]  ${nr_cell_ids}

Identify anchor cell for specific NR cell
    [Arguments]  ${nr_cell_id}  ${anchor_relations}
    ${anchor_cell_ids}=  Get Dictionary Keys  ${anchor_relations}
    FOR  ${anchor_relation}  IN  @{anchor_relations}
        Return From Keyword If  '${nr_cell_id}' in ${anchor_relations[${anchor_relation}]}  ${anchor_relation}
    END

Check attach UE on expected cell
    [Arguments]  ${alias_ue}  ${admin_alias}  ${techno}
    Set Test Variable  ${status_second_try}  False
    ${wcdma_cell_id}=  Set Variable If  "${techno.upper()}"=="WCDMA"  True  False
    ${actual_ue_ip}  ${actual_cell_id}=  Taf Ue Attach Single UE  ue_alias=${alias_ue}  expected_serving_cell_list=None  timeout=120
    ...  call_type=data  wcdma_cell_id=${wcdma_cell_id}
    Log  UE ${alias_ue} attached on cell ${actual_cell_id} with IP ${actual_ue_ip}  console=True
    Log  Checking cell validity  console=True
    Run Keyword If  "${actual_cell_id}" in ${cell_ids_for_call_dict["${alias_ue}"]}
    ...  Set To Dictionary  ${ue_to_cell_id_mapping}  ${alias_ue}  ${actual_cell_id}
    Run Keyword If  "${actual_cell_id}" in ${cell_ids_for_call_dict["${alias_ue}"]}
    ...  Log  UE ${alias_ue} succesfully attached on expected ${techno} cell ${actual_cell_id}  console=True
    ...  ELSE IF  "${techno}"!="NR"  Fail  UE did not attach on expected cell. Actual cell ID: ${actual_cell_id}!
    ...  ELSE  Run Keywords
    ...  Check NR NSA Call  ${admin_alias}  ${actual_cell_id}  ${cell_ids_for_call_dict["${alias_ue}"]}  ${alias_ue}
    ...  AND  Set To Dictionary  ${ue_to_cell_id_mapping}  ${alias_ue}  ${nr_cell_id_call}
    Set Test Variable  ${status_second_try}  True

Check NR NSA Call
    [Arguments]  ${nr_admin_alias}  ${anchor_cell_id}  ${expected_nr_cells}  ${ue_alias}
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
    ${expected_PCI_list}=  Create List
    FOR  ${nr_cell_id}  IN  @{expected_nr_cells}
        ${pci}=  Set Variable  ${NRCellid_PCI[${nr_cell_id}]}
        Append To List  ${expected_PCI_list}  ${pci}
    END
    ${use_hop}=  Set Variable If  "${nr_admin_alias}"=="Master"  False  True
    ${nr_cell_id_call}=  Taf Ue Verify if UE is attached on NR cell with aahsell  ${ue_alias}  ${expected_pci_list}  ${nr_admin_alias}  ${use_hop}
    ...  False
    Log  Succesfully verified NR NSA attach!  console=True
    Set Test Variable  ${nr_cell_id_call}

Proceed to data transfer start on UE
    [Arguments]  ${alias_ue}  ${protocol}  ${call_direction}  ${techno}
    ${CALL_DURATION}=  Catenate  SEPARATOR=   ${CALL_DURATION}  s
    Extract current cell target BW based on cell ID  ${ue_to_cell_id_mapping["${alias_ue}"]}  ${techno}
    ${bw}=  Set Variable  ${CELL_TARGET_BW_params["Target_Bandwidth"]}
    Run Keyword If  '${call_direction}' not in ['uplink', 'downlink', 'uplink_downlink']
    ...  Fail  Wrong call direction set ${call_direction}. Accepted values: uplink, downlink, uplink_downlink
    Translate Call Direction  ${call_direction}
    ${packet_size}=  Set Variable If  ('gsm' in '${techno.lower()}' or 'wcdma' in '${techno.lower()}')  1200  1400
    Run Keyword If  '${call_direction}' != 'ul_dl'
    ...  Taf Ue Start Data Transfer Single UE  ue_alias=${alias_ue}  dt_name=dt_${alias_ue}_${call_direction}
    ...  call_duration=${CALL_DURATION}  call_direction=${call_direction}  throughput=${bw}}  protocol=${protocol}  packet_size=${packet_size}
    ...  ELSE  Run Keywords
    ...  Taf Ue Start Data Transfer Single UE  ue_alias=${alias_ue}  dt_name=dt_${alias_ue}_dl
    ...  call_duration=${CALL_DURATION}  call_direction=dl  throughput=${bw}  protocol=${protocol}  packet_size=${packet_size}
    ...  AND  Taf Ue Start Data Transfer Single UE  ue_alias=${alias_ue}  dt_name=dt_${alias_ue}_ul
    ...  call_duration=${CALL_DURATION}  call_direction=ul  throughput=${bw}  protocol=${protocol}  packet_size=${packet_size}

Await data call finish on UE
    [Arguments]  ${alias_ue}  ${call_direction}
    Translate Call Direction  ${call_direction}
    Run Keyword If  'ul' in '${CALL_DIRECTION}'  Taf Ue Await Data Transfer Finish Single UE  dt_name=dt_${alias_ue}_ul
    Run Keyword If  'dl' in '${CALL_DIRECTION}'  Taf Ue Await Data Transfer Finish Single UE  dt_name=dt_${alias_ue}_dl

Stop and check data call on UE
    [Arguments]  ${alias_ue}  ${alias_bts}  ${techno}  ${call_direction}  ${protocol}  ${ue_group}
    Translate Call Direction  ${call_direction}
    ${cell_id}=  Set Variable  ${ue_to_cell_id_mapping["${alias_ue}"]}
    Extract current cell target BW based on cell ID  ${cell_id}  ${techno}
    ${downlink_MIN_TPUT}=  Set Variable  ${CELL_TARGET_BW_params["DL_min"]}
    ${downlink_MAX_TPUT}=  Set Variable  ${CELL_TARGET_BW_params["DL_max"]}
    ${uplink_MIN_TPUT}=  Set Variable  ${CELL_TARGET_BW_params["UL_min"]}
    ${uplink_MAX_TPUT}=  Set Variable  ${CELL_TARGET_BW_params["UL_max"]}
    ${duration}=  Fetch From Left  ${CALL_DURATION}  s
    ${duration}=  Convert To Integer  ${duration}
    ${duration}=  Evaluate  ${duration}-5
    Run Keyword If  'dl' in '${call_direction}'  Run Keywords
    ...  Taf Ue Solution display expected throughput values  ${alias_ue}  dt_${alias_ue}_dl  dl  ${protocol}
    ...  ${downlink_MIN_TPUT}  ${downlink_MAX_TPUT}
    ...  AND  Verify Average Throughput  ${alias_ue}  ${alias_bts}  ${techno}  ${duration}  DL  ${protocol}  ${cell_id}  ${ue_group}
    ...  thput_min=${downlink_MIN_TPUT}  thput_max=${downlink_MAX_TPUT}
    ...  AND  taf.ue.Stop Data Transfer  dt_name=dt_${alias_ue}_dl
    Run Keyword If  'ul' in '${call_direction}'  Run Keywords
    ...  Taf Ue Solution display expected throughput values  ${alias_ue}  dt_${alias_ue}_ul  ul  ${protocol}
    ...  ${uplink_MIN_TPUT}  ${uplink_MAX_TPUT}
    ...  AND  Verify Average Throughput  ${alias_ue}  ${alias_bts}  ${techno}  ${duration}  UL  ${protocol}  ${cell_id}  ${ue_group}
    ...  thput_min=${uplink_MIN_TPUT}  thput_max=${uplink_MAX_TPUT}
    ...  AND  taf.ue.Stop Data Transfer  dt_name=dt_${alias_ue}_ul
    Log  Stop and check data call for ${alias_ue} finished succesfully!  console=True

Verify Average Throughput
    [Arguments]  ${alias_ue}  ${alias_bts}  ${techno}  ${duration}  ${direction}  ${protocol}  ${cell_id}
    ...  ${ue_group}  ${thput_min}  ${thput_max}

    Run Keyword If  '${THPUT_CHECK_BTS_LOGS}'=='False' or "${techno.upper()}" not in ["NR", "LTE"]  Run Keywords
    ...  Taf Ue Solution display actual throughput values  ${alias_ue}  dt_${alias_ue}_${direction.lower()}  ${direction.lower()}  ${protocol}
    ...  AND  Taf Ue Verify Average Throughput Single UE  dt_name=dt_${alias_ue}_${direction.lower()}  tput_min=${thput_min}  tput_max=${thput_max}
    ...  AND  Return From Keyword

    ${hostname}=  Set Variable  ${${alias_bts.upper()}}[${alias_bts.upper()}_PC_IP_ADDRESS]
    ${port}=  Set Variable  ${${alias_bts.upper()}}[${alias_bts.upper()}_PC_SSH_PORT]
    ${username}=  Set Variable  ${${alias_bts.upper()}}[${alias_bts.upper()}_PC_SSH_USERNAME]
    ${password}=  Set Variable  ${${alias_bts.upper()}}[${alias_bts.upper()}_PC_SSH_PASSWORD]

    BTS Log Display Actual Throughput Values  ${thput_start_time}  ${hostname}  ${port}  ${username}  ${password}  ${alias_bts}  ${techno}
    ...  ${duration}  ${direction}  ${cell_id}  ${ue_group}  ${alias_ue}  ${protocol}

    Log  Checking average ${direction} ${protocol} throughput from BTS log for UE ${alias_ue}  console=True
    BTS Log Verify Average Throughput  ${avg_bts_log_thput}  ${thput_min}  ${thput_max}

Display Actual Throughput Values
    [Arguments]  ${alias_ue}  ${techno}  ${direction}  ${protocol}

    ${dt_name}=  Set Variable  dt_${alias_ue}_${direction.lower()}
    Run Keyword If  '${THPUT_CHECK_BTS_LOGS}'=='False' or ${techno.upper()} not in ["NR", "LTE"]  Run Keywords
    ...  Taf Ue Solution display actual throughput values  ${alias_ue}  dt_${alias_ue}_${direction.lower()}  ${direction.lower()}  ${protocol}
    ...  AND  Return From Keyword
    Log  ============ ${direction.upper()} ${protocol.upper()} for ${alias_ue} thread ${dt_name} actual value ============  console=True
    Log  - ${direction.upper()} ${protocol.upper()} actual average value: ${avg_bts_log_thput} bps  console=True
    Log  ============  console=True

Translate Call Direction
    [Arguments]  ${direction}
    Run KeyWord If  '${direction}' == 'uplink'  Set Test Variable  ${CALL_DIRECTION}  ul
    Run KeyWord If  '${direction}' == 'downlink'  Set Test Variable  ${CALL_DIRECTION}  dl
    Run KeyWord If  '${direction}' == 'uplink_downlink'  Set Test Variable  ${CALL_DIRECTION}  ul_dl

Mid Test Snapshot collection
    [Arguments]  ${alias}  ${reason}
    Log  Mid Test Snapshot collection for ${reason} problem found on BTS ${alias}  console=True
    ${timestamp}=  Get Current Date  result_format=%Y-%m-%d_%H:%M:%S
    ${path}=  Set Variable  ${Test Results Dir}/Snapshot
    Log  Snapshot file collection on BTS ${alias} started  console=True
    ${folder_path}  ${Snapshot_filename}=  Snapshot collection on demand SOAM  ${alias}  ${path}/${timestamp}_BTS_${alias}_${reason}
    Log  Snapshot file collected: ${folder_path}/${Snapshot_filename}  console=True

    FOR  ${admin_alias}  IN  @{extended_admin_alias_list}
        Continue For Loop If  '${admin_alias}'=='${alias}'
        Log  Snapshot file collection on BTS ${admin_alias} started  console=True
        ${folder_path}  ${Snapshot_filename}=  Snapshot collection on demand SOAM
        ...  ${admin_alias}  ${path}/${timestamp}_BTS_${admin_alias}_${reason}
        Log  Snapshot file collected: ${folder_path}/${Snapshot_filename}  console=True
    END
    Run Keywords
    ...  Log  Wait static time of ${DELAY_BETWEEN_SNAPSHOTS} seconds between Snapshot collections  console=True
    ...  AND  Sleep  ${DELAY_BETWEEN_SNAPSHOTS}s

Particular Teardown
    Run Keyword If  '${DETACH_UEs}' == 'True'
    ...  Run Keyword And Return Status  Taf Ue Detach All Used UEs
    Return From Keyword If  "${BTS_OAM_IP_ADDRESSES}" == "None"
    ${BTS_OAM_IP_ADDRESSES_LIST}=  Split String  ${BTS_OAM_IP_ADDRESSES}  separator=
    FOR  ${BTS_OAM_IP}  IN  @{BTS_OAM_IP_ADDRESSES_LIST}
        Wait until keyword succeeds  10 min  5 sec
        ...  Teardown Admin  alias=BTS_EXT_${BTS_OAM_IP}
    END

TC Setup
    Run Keyword And Continue On Failure  Common Test Setup  infomodelSetup=${FALSE}  newAlarmsFormat=${TRUE}

Check Test Verdict
    ${number_of_skipped_UEs}=  Get Length  ${skipped_ues}
    Run Keyword If  ${number_of_skipped_UEs}!=0
    ...  Fail  At least one UE was skipped due to at least one failed operation during test execution!

TC Teardown
    Common Test Teardown
