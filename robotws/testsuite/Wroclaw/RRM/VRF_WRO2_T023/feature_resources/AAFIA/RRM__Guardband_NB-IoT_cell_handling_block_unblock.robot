*** Settings ***
Documentation
...   contact: Oleksandr Kulieshov

Library       SSHLibrary
Library       ute_ue
Library       taf.sbts.oam.coam.admin    WITH NAME    admin
Resource      ../../resources/ca_IWK.robot


*** Variables ***
${NB_IOT_GLOBAL_CELL_ID}                            # global cell ID of tested NB-IoT cell (in DEC)
${NB_IOT_CELL_ID_HEX}                               # eutra cell ID of tested NB-IoT cell visible on UE and in wireshark (in HEX)
${LTE_CELL_ID}                                      # ID of LTE cell - parent of tested NB-IoT cell
${DUAL_OR_SINGLE}                                   # Variable determining if test is for dual or single sector case.
# Possible values: 'Single Sector', 'Dual Sector'
${TIME_FOR_IDLE}           10                       # Time in seconds needed for UE to enter idle state. Default value: 10
${LOOPS_COUNT}             4                        # Number of loops + 1 for steps 11-13

*** Keywords ***
TC__RRM__Guardband_NB-IoT_cell_handling_block_unblock

    Set Tags    CA-RRM    AUTHOR-monika.ceglarek@nokia.com    OWNER-piotr.smolak@nokia.com
    ...         MAINTAINER-monika.ceglarek@nokia.com    PHASE-CRT   SW-SBTS23R1    FEATURE-LTE4852
    ...         FEATURE-LTE4529  FEATURE-CB007256  GROUP_IN_CHARGE-Pz_2_WRO_2


    Preconditions
    Step 1: Perform Attach To NB-IoT Cell
    Step 2: Perform Data Transfer In NB-IoT Cell
    Step 3: Check If UE Changed State To Idle After Attach
    Step 4: Check If UE Changed State To Idle After Data Transfer
    Step 5: Block LTE Cell Related To NB-IoT Cell
    Step 6: Check BTS State After Cell Block
    Step 7: Unblock LTE Cell Related To NB-IoT Cell
    Step 8: Check BTS State After Cell Unblock
    Step 9: Perform Attach To NB-IoT Cell
    Step 10: Check If UE Changed State To Idle After Attach
    Looped Steps
    Step 14: Check BTS State After Paging

Looped Steps
    FOR  ${loop}  IN RANGE  1  ${LOOPS_COUNT}
        Set Test Variable  ${LOOP}  ${loop}
        Log  \n--- LOOP${LOOP} START ---  console=True
        Step 11: Perform Data Transfer In NB-IoT Cell
        Step 12: Check If UE Changed State To Idle After Data Transfer
        Step 13: Check Paging For NB-IoT Cell
        Log  --- LOOP${LOOP} END ---\n  console=True
    END


Preconditions
    Log  \n==== Preconditions ====  console=True

    Set Test Variable  ${CONNECTION_OPENED}  False
    Set Test Variable  ${CELL_BLOCKED}  False
    Set Test Variable  ${LOOP}  not_loop
    ${_}  ${parsed_scf} =  Save And Parse SCF  SCF_original
    ${lncel_dist_name} =  Get DistName Attribute From SCF  ${parsed_scf}  LNCEL  LNCEL-${LTE_CELL_ID}  dist_name_substring=True
    Set Test Variable  ${LNCEL_DIST_NAME}  ${lncel_dist_name}
    ${lnbts_id} =  Get BTS ID From ADMIN
    Set Test Variable  ${LNBTS_ID}  ${lnbts_id}
    Connect To UEPC And FTP
    AT serial write  AT+CFUN=1,1


Connect To UEPC And FTP
    Set Test Variable  ${CONNECTION_OPENED}  True
    SSHLibrary.Open Connection  ${PC_IOT['IP']}  alias=uepc
    SSHLibrary.Login  ${PC_IOT['username']}  ${PC_IOT['password']}
    SSHLibrary.Open Connection  ${FTP_IOT['IP']}  alias=ftp
    SSHLibrary.Login  ${FTP_IOT['username']}  ${FTP_IOT['password']}


Step ${index}: Perform Attach To NB-IoT Cell
    Log  \n==== Step ${index}: Perform Attach To NB-IoT Cell ====  console=True

    Start Wireshark Log Collection For IWK Test  options=-i any host ${ENB_OAM_IP} and not udp port 2152 -s 0 -W 1
    ...                                          replace_enb=False  replace_gnb=False  alias=tcpdump_ATT_S${index}_L${LOOP}
    Prepare UE For Call
    Wait Until Keyword Succeeds  2x  5s  Check Cell And IP
    [Teardown]  Stop Tcpdump Logs Collecting  ${index}  ATT


Prepare UE For Call
    Log To Console   \nPrepare UE for call...
    ${response} =  Wait Until Keyword Succeeds  4x  5s  Run AT Command And Check If Response Is Not Empty  at+cfun=4
    Should Match Regexp  ${response}  OK  msg=Regexp message did not return 'OK'.
    ${response} =  Wait Until Keyword Succeeds  4x  5s  Run AT Command And Check If Response Is Not Empty  at+cfun=1
    Should Match Regexp  ${response}  OK  msg=Regexp message did not return 'OK'.
    Sleep  10s  Reason=Wait for UE attach


Check Cell And IP
    Log  Ensure that UE is attached to appropriate NB-IoT cell...  console=True
    ${response} =  Wait Until Keyword Succeeds  4x  5s  Run AT Command And Check If Response Is Not Empty  AT+CEREG?
    Should Match Regexp  ${response}  ${NB_IOT_CELL_ID_HEX}  msg=UE is not attached to correct cell, test set to failed.
    Log  UE attached to ${NB_IOT_CELL_ID_HEX}  console=True

    Log  \nFetch UE IP Address...  console=True
    ${response} =  Wait Until Keyword Succeeds  4x  5s  Run AT Command And Check If Response Is Not Empty  AT+CGDCONT?
    ${ip}  Should Match Regexp  ${response}  \\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}  msg=Invalid IP address.
    Set Test Variable  ${UE_IP}  ${ip}


Stop Tcpdump Logs Collecting
    [Arguments]  ${index}  ${operation}
    ${tcpdump_path} =  Stop Wireshark Log Collection For IWK Test  alias=tcpdump_${operation}_S${index}_L${LOOP}
    Run Keyword If  '${index}' == '1' or '${index}' == '9'  Set Test Variable  ${TCPDUMP_ATTACH_PATH}  ${tcpdump_path}
    ...  ELSE  Set Test Variable  ${TCPDUMP_DATA_TRANSFER_PATH}  ${tcpdump_path}


Step ${index}: Perform Data Transfer In NB-IoT Cell
    Log  \n==== Step ${index}: Perform Data Transfer In NB-IoT Cell ====  console=True

    Start Wireshark Log Collection For IWK Test  options=-i any host ${ENB_OAM_IP} and not udp port 2152 -s 0 -W 1
    ...                                          replace_enb=False  replace_gnb=False  alias=tcpdump_DT_S${index}_L${LOOP}
    Run Keyword If  '${index}' == '12'  Wait Until Keyword Succeeds  2x  5s  Check Cell And IP
    Log  Starting DL data transfer...  console=True
    ${stdout}  ${stderr}  ${rc} =  SSHLibrary.Execute Command   iperf -c ${UE_IP} -u -b 30K -p 6029 -i 1 -t 60
    ...  return_stderr=True  return_rc=True  timeout=3min
    Should Be Equal As Integers  ${rc}  ${0}  msg=RC is not equal to 0. Check also errors: ${stderr}
    Sleep  ${TIME_FOR_IDLE}s  reason=Wait for UE to go into idle state.
    [Teardown]  Stop Tcpdump Logs Collecting  ${index}  DT


Step ${index}: Check If UE Changed State To Idle After Attach
    Log  \n==== Step ${index}: Check If UE Changed State To Idle After Attach ====  console=True

    ${packet_count} =  Tcpdump Packet Filtering  ${TCPDUMP_ATTACH_PATH}
    ...  nas_eps.nas_msg_emm_type == 0x43
    ...  Attach Complete
    Should Be True  ${packet_count} >= 1  msg=There are no Attach Complete packets.

    ${field} =  Set Variable   frame.number
    ${frame_numbers} =  Tcpdump Packet Filtering  ${TCPDUMP_ATTACH_PATH}
    ...  nas_eps.nas_msg_emm_type == 0x43
    ...  Attach Complete
    ...  command=tshark -r "${TCPDUMP_ATTACH_PATH}" -Y "nas_eps.nas_msg_emm_type == 0x43" -T fields -e "${field}"
    ...  msg=Attach Complete frame number(s):
    ...  log_to_console=False
    Should Not Be Empty  ${frame_numbers}  msg=There are no packets indicating ongoing data transfer (DownlinkNASTransport/ESM data transport).
    ${frame_numbers} =  Split To Lines  ${frame_numbers}

    ${packet_count} =  Tcpdump Packet Filtering  ${TCPDUMP_ATTACH_PATH}
    ...  s1ap.procedureCode == 23 && s1ap.CellIdentity == 0x${NB_IOT_CELL_ID_HEX} && frame.number > ${frame_numbers[-1]}
    ...  UEContextReleaseComplete
    Should Be True  ${packet_count} >= 1  msg=There are no packets indicating that UE entered idle state (UEContextReleaseComplete) after attach.


Step ${index}: Check If UE Changed State To Idle After Data Transfer
    Log  \n==== Step ${index}: Check If UE Changed State To Idle After Data Transfer ====  console=True

    ${field} =  Set Variable   frame.number
    ${frame_numbers} =  Tcpdump Packet Filtering  ${TCPDUMP_DATA_TRANSFER_PATH}
    ...  s1ap.procedureCode == 11
    ...  DownlinkNASTransport/ESM data transport
    ...  command=tshark -r "${TCPDUMP_DATA_TRANSFER_PATH}" -Y "s1ap.procedureCode == 11" -T fields -e "${field}"
    ...  msg=DownlinkNASTransport/ESM data transport frame numbers:
    ...  log_to_console=False
    Should Not Be Empty  ${frame_numbers}  msg=There are no packets indicating ongoing data transfer (DownlinkNASTransport/ESM data transport).
    ${frame_numbers} =  Split To Lines  ${frame_numbers}

    ${packet_count} =  Tcpdump Packet Filtering  ${TCPDUMP_DATA_TRANSFER_PATH}
    ...  s1ap.procedureCode == 23 && s1ap.CellIdentity == 0x${NB_IOT_CELL_ID_HEX} && frame.number > ${frame_numbers[-1]}
    ...  UEContextReleaseComplete
    Should Be True  ${packet_count} >= 1  msg=There are no packets indicating that UE entered idle state (UEContextReleaseComplete).


Step 5: Block LTE Cell Related To NB-IoT Cell
    Log  \n==== Step 5: Block LTE Cell Related To NB-IoT Cell ====  console=True

    Set Test Variable  ${CELL_BLOCKED}  True
    Block Cell  ${LNCEL_DIST_NAME}
    Log  Cell ${LNCEL_DIST_NAME} blocked.  console=True


Step 6: Check BTS State After Cell Block
    Log  \n==== Step 6: Check BTS State After Cell Block ====  console=True

    ${expected_alarm_lte} =  Set Variable  faultId=49, configObjectName=regex"^.*MRBTS-${LNBTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-${LTE_CELL_ID}"
    ${expected_alarm_nb_iot} =  Set Variable
    ...  faultId=49, configObjectName=regex"^.*MRBTS-${LNBTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-${NB_IOT_GLOBAL_CELL_ID}"
    Set Test Variable  ${EXPECTED_ALARM_LTE}  ${expected_alarm_lte}
    Set Test Variable  ${EXPECTED_ALARM_NB_IOT}  ${expected_alarm_nb_iot}
    Wait Until Keyword Succeeds  2m  20s  _verify bts states after cell block helper


Step 7: Unblock LTE Cell Related To NB-IoT Cell
    Log  \n==== Step 7: Unblock LTE Cell Related To NB-IoT Cell ====  console=True

    Unblock Cell  ${LNCEL_DIST_NAME}
    Set Test Variable  ${CELL_BLOCKED}  False
    Log  Cell ${LNCEL_DIST_NAME} unblocked.  console=True


Step 8: Check BTS State After Cell Unblock
    Log  \n==== Step 8: Check BTS State After Cell Unblock ====  console=True

    Wait Until Keyword Succeeds  30s  5s  _verify bts states for iwk test helper
    Log  BTS state checked.  console=True


Step 13: Check Paging For NB-IoT Cell
    Log  \n==== Step 13: Check Paging For NB-IoT Cell ====  console=True

    ${packet_count} =  Tcpdump Packet Filtering  ${TCPDUMP_DATA_TRANSFER_PATH}
    ...  s1ap.procedureCode == 10
    ...  Paging
    Should Be True  ${packet_count} >= 1  msg=There are no Paging packets.

    ${field} =  Set Variable   s1ap.Paging_element
    ${paging_element_field_value} =  Tcpdump Packet Filtering  ${TCPDUMP_DATA_TRANSFER_PATH}
    ...  s1ap.procedureCode == 10
    ...  Paging
    ...  command=tshark -r "${TCPDUMP_DATA_TRANSFER_PATH}" -Y "s1ap.procedureCode == 10" -T fields -e "${field}"
    ...  msg=s1ap.Paging_element field value:
    Should Not Be Empty  ${paging_element_field_value}  msg=There is no paging message in wireshark logs.

    ${packet_count} =  Tcpdump Packet Filtering  ${TCPDUMP_DATA_TRANSFER_PATH}
    ...  s1ap.procedureCode == 11
    ...  DownlinkNASTransport/ESM data transport
    Should Be True  ${packet_count} >= 10
    ...  msg=There is not enough packets suggesting ongoing data transfer (DownlinkNASTransport/ESM data transport).


Step 14: Check BTS State After Paging
    Log  \n==== Step 14: Check BTS State After Paging ====  console=True

    _verify bts states for iwk test helper
    Log  BTS state checked.  console=True


Run AT Command And Check If Response Is Not Empty
    [Arguments]  ${at_command}
    ${response} =  AT serial write  ${at_command}
    ${response_length} =  Get Length  ${response}
    Should Be True  ${response_length} > 0  msg=Response is empty for command ${at_command}.
    [Teardown]  Run Keyword If  '${KEYWORD_STATUS}' == 'FAIL'  AT serial write  AT+CFUN=1,1
    [Return]  ${response}


Tcpdump Packet Filtering
    [Arguments]  ${tcpdump_path}  ${display_filter}  ${packet_type}
    ...  ${command}=tshark -r "${tcpdump_path}" -Y "${display_filter}" |wc -l
    ...  ${msg}=${packet_type} packets count:  ${log_to_console}=True

    ${result} =  Run Process  command=${command}  shell=True
    Should Be Equal As Integers  ${result.rc}  0    msg=RC is not equal to 0.
    Should Be Equal As Strings  '${result.stderr}'  ''
    ...  msg=Command for ${packet_type} packets: ${command} generated errors.\nError message: ${result.stderr}
    Log  ${msg} ${result.stdout}  console=${log_to_console}

    [Return]  ${result.stdout}


_verify bts states after cell block helper
    [Arguments]  ${alias}=default
    Log  Checking BTS state after cell block.  console=True
    ${gncels_exist} =   Check If Cells From Specific RAT Exist In ADMIN  gsm      connection=${alias}
    ${wncels_exist} =   Check If Cells From Specific RAT Exist In ADMIN  wcdma    connection=${alias}
    ${nrcels_exist} =   Check If Cells From Specific RAT Exist In ADMIN  nr       connection=${alias}

    ${smod_onair_states}=  Catenate  SEPARATOR=   operationalState=regex"[Ee]nabled",
    ...                                           administrativeState=regex"[Uu]nlocked"
    ${rmod_onair_states}=  Catenate  SEPARATOR=   operationalState=regex"[Ee]nabled",
    ...                                           administrativeState=regex"[Uu]nlocked"
    ${gln_cell_onair_states}=  Catenate  SEPARATOR=  operationalState=regex"[Ee]nabled",
    ...                                              administrativeState=regex"[Uu]nlocked",
    ...                                              blockingState=regex"[Uu]nblocked"
    ${w_cell_onair_states}=  Catenate  SEPARATOR=  operationalState=regex"[Ee]nabled",
    ...                                            blockingState=regex"[Uu]nblocked"


    ${smods_onair}=
    ...  Run Keyword And Return Status  _check statuses for all objects
    ...  SMOD  ${smod_onair_states}  connection=${alias}
    ${rmods_onair}=
    ...  Run Keyword And Return Status  _check statuses for all objects
    ...  RMOD  ${rmod_onair_states}  connection=${alias}
    ${nrcells_onair}=  Run Keyword If  ${nrcels_exist}
    ...  Run Keyword And Return Status  _check statuses for all objects
    ...  NRCEL  ${gln_cell_onair_states}  connection=${alias}
    ...  ELSE  Set Variable  ${TRUE}
    ${wncells_onair}=  Run Keyword If  ${wncels_exist}
    ...  Run Keyword And Return Status  _check statuses for all objects
    ...  WNCEL  ${w_cell_onair_states}  connection=${alias}
    ...  ELSE  Set Variable  ${TRUE}
    ${gncells_onair}=  Run Keyword If  ${gncels_exist}
    ...  Run Keyword And Return Status  _check statuses for all objects
    ...  GNCEL  ${gln_cell_onair_states}  connection=${alias}
    ...  ELSE  Set Variable  ${TRUE}

    ${lncels_correct_states} =  Run Keyword And Return Status  Check LTE Cells After Cell Block  ${gln_cell_onair_states}

    Add Allowed Alarm  ${EXPECTED_ALARM_LTE}  connection=${alias}
    Add Allowed Alarm  ${EXPECTED_ALARM_NB_IOT}  connection=${alias}

    ${alarms_status} =  Run Keyword And Return Status  Assert No Unexpected Active Alarms  connection=${alias}
    ${alarm_49_lte_status} =  Run Keyword And Return Status  Assert Alarm Active  ${EXPECTED_ALARM_LTE}  connection=${alias}
    ${alarm_49_nb_iot_status} =  Run Keyword And Return Status  Assert Alarm Active  ${EXPECTED_ALARM_NB_IOT}  connection=${alias}

    Clear Allowed Alarms List  connection=${alias}
    Add Standard Allowed Alarms  ${alias}

    ${statuses_dictionary}=  Create Dictionary
    ...  smods_onair=${smods_onair}  rmods_onair=${rmods_onair}
    ...  gncells_onair=${gncells_onair}  wncels_onair=${wncells_onair}
    ...  lncels_correct_states=${lncels_correct_states}  nrcells_onair=${nrcells_onair}  alarms_status=${alarms_status}
    ...  alarm_49_lte_status=${alarm_49_lte_status}  alarm_49_nb_iot_status=${alarm_49_nb_iot_status}
    ${pretty_statuses}=  Evaluate  pprint.pformat(${statuses_dictionary}, indent=4)  modules=pprint

    ${modules_statuses} =  Evaluate  ${smods_onair} and ${rmods_onair}
    ${cell_statuses} =  Evaluate   ${gncells_onair} and ${wncells_onair} and ${lncels_correct_states} and ${nrcells_onair}
    Should Be True  ${modules_statuses} and ${cell_statuses} and ${alarms_status} and ${alarm_49_lte_status} and ${alarm_49_nb_iot_status}
    ...  msg=BTS verification failed. Details:\n${pretty_statuses}
    Log  BTS state checked.  console=True


Check LTE Cells After Cell Block
    [Arguments]  ${l_cell_onair_states}  ${alias}=default
    ${l_cell_blocked_states} =  Catenate  SEPARATOR=  availabilityStatus=regex"[Oo]ff line",
    ...                                           operationalState=regex"[Dd]isabled",
    ...                                           administrativeState=regex"[Uu]nlocked",
    ...                                           blockingState=regex"[Bb]locked"
    ${all_runtime_lncels} =  Get IDs For All  LNCEL
    ${lte_cell_runtime_distname} =  Get Runtime Dist Name For LTE Cell  ${LTE_CELL_ID}  connection=${alias}
    ${nb_iot_cell_runtime_distname} =  Get Runtime Dist Name For LTE Cell  ${NB_IOT_GLOBAL_CELL_ID}  connection=${alias}
    Remove Values From List  ${all_runtime_lncels}  ${lte_cell_runtime_distname}  ${nb_iot_cell_runtime_distname}
    FOR  ${cell}  IN  @{all_runtime_lncels}
        _check cell state helper  LNCEL  ${cell}  ${l_cell_onair_states}
        ...  timeout=15s  connection=${alias}
    END
    _check cell state helper  LNCEL  ${lte_cell_runtime_distname}  ${l_cell_blocked_states}
    ...  timeout=15s  connection=${alias}
    _check cell state helper  LNCEL  ${nb_iot_cell_runtime_distname}  ${l_cell_blocked_states}
    ...  timeout=15s  connection=${alias}


TC Setup
    IWK Test Setup   single_bts=True


TC Teardown
    [Timeout]  30 min
    Log  \n === TC Teardown ===   console=True

    ${response} =  Run Keyword If  ${CONNECTION_OPENED}  Wait Until Keyword Succeeds  4x  5s
    ...  Run AT Command And Check If Response Is Not Empty  at+cfun=4
    Run Keyword If  ${CONNECTION_OPENED}  Run Keywords
    ...  Should Match Regexp  ${response}  OK  msg=Regexp message did not return 'OK'.
    ...  AND  SSHLibrary.Close All Connections
    Sleep  5s  reason=Waiting for UE to detach.

    Run Keyword If  ${CELL_BLOCKED}  Run Keywords  Unblock Cell  ${LNCEL_DIST_NAME}
    ...  AND  Wait Until Keyword Succeeds  30s  5s  _verify bts states for iwk test helper

    IWK Test Teardown  single_bts=True
