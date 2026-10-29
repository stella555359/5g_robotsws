*** Settings ***
Documentation
...  contact: Szymon Startek

Library     ute_ue
Resource       ../../resources/ca_IWK.robot


*** Variables ***
${NR_CELL_ID}                                   # NRCEL ID of target NR cell where VoNR will be performed to check PM counters
${CELL_ID_FOR_CALL}                             # Global cell ID of NR cell used for call
${EXP_VAL_M55190C00001}        1                # Expected value of counter M55190C00001. Default value: 1
${EXP_VAL_M55187C00001}        1                # Expected value of counter M55187C00001. Default value: 1
${COUNTER_PERIOD}              5                # Counter collecting interval in minutes. Default value: 5
${UE_CAPABILITY}               POWER_CLASS_2    # Capability of UE used in test. Default value: POWER_CLASS_2
${PHONE_NUMBER}                0105             # Phone/Autoresponder number for VoNR call. Default value: 0105
${CALL_DURATION}               5                # Duration of VoNR call in seconds the duration needs to be longer than 4s.
${CONNECTION}                  gNB              # Alias used for ADMIN to check NR cell attach. Default value: gNB


*** Keywords ***
TC__CB008127-F_B5_Successful_configuration_of_intra-freq_A2_A3_A5_using_meas_profiles_upon_setup_VoNR
    Set Tags    CA-INTER_RAT    AUTHOR-krzysztof.mirecki@nokia.com    OWNER-krzysztof.mirecki@nokia.com
    ...         MAINTAINER-szymon.startek@nokia.com    PHASE-CRT   SW-SBTS24R2    FEATURE-CB008127   GROUP_IN_CHARGE-Pz_2_WRO_2

    Preconditions
    Step 1: Checking Delay And Start Wireshark Log
    Step 2: Perform VoNR
    Step 3: Stop Wireshark Log
    Step 4: Tcpdump Verification
    Step 5: Collect Counters
    Step 6: Check Counters Values

Preconditions
    Log  \n*** Preconditions ***  console=True
    ${nrbts_id}  Get BTS ID From ADMIN  alias=gNB
    Set Test Variable  ${NRBTS_ID}  ${nrbts_id}
    Require UE  NR_UE  ${UE_CAPABILITY}
    Log UE Info  NR_UE  ALL


Step 1: Checking Delay And Start Wireshark Log
    Log    \n*** Step 1: Checking delay and start wireshark log ***    console=True
    ${time}    Count Measurement Period  counter_period=${COUNTER_PERIOD}  ip=${GNB_OAM_IP}
    ...  user=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...  password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    Log     Sleep time : ${time} seconds for measurement period to start    console=True
    Sleep    ${time}s   reason=Wait for measurement period to start
    Set Test Variable  ${STARTED_TCPDUMP}  True
    Start Wireshark Log Collection For IWK Test  options=-i any port 38412 or port 38472 or port 36422 or port 29211
    ...                                          replace_enb=False  replace_gnb=False


Step 2: Perform VoNR
    Log  \n*** Step 2: Perform VoNR ***  console=True
    Log  Performing attach to ${CELL_ID_FOR_CALL}...  console=True
    Prepare UE For Data Transfer  NR_UE  ${CELL_ID_FOR_CALL}  connection=${CONNECTION}
    Start Voice Call  vc_alias=VOICE_CALL  ue_alias=NR_UE  to=${PHONE_NUMBER}  duration=${CALL_DURATION}s
    Log  Voice call running, expected duration: ${CALL_DURATION}s  console=True
    Sleep  ${CALL_DURATION}s


Step 3: Stop Wireshark Log
    Log  \n*** Step 3: Stop Wireshark Log ***  console=True
    ${tcpdump_path}  Stop Wireshark Log Collection For IWK Test
    Set Test Variable  ${STARTED_TCPDUMP}  False
    Set Test Variable  ${TCPDUMP_PATH}  ${tcpdump_path}


Step 4: Tcpdump Verification
    Log  \n*** Step 4: Tcpdump Verification ***  console=True
    ${filter1}  Catenate  (((((((((((((((nr-rrc.eventId==1)&&(nr-rrc.hysteresis==9))&&(nr-rrc.timeToTrigger==1)) &&
    ...  (nr-rrc.measTriggerQuantity.rsrp==67))&&(nr-rrc.hysteresis==12))&&(nr-rrc.timeToTrigger==13)) &&
    ...  (nr-rrc.measTriggerQuantity.rsrp==32))&&(nr-rrc.eventId==2))&&(nr-rrc.hysteresis==7)) &&
    ...  (nr-rrc.measTriggerQuantityOffset.rsrp==9))&&(nr-rrc.timeToTrigger==3))&&(nr-rrc.eventId==4)) &&
    ...  (nr-rrc.hysteresis==11))&&(nr-rrc.measTriggerQuantity.rsrp==59))&&(nr-rrc.measTriggerQuantity.rsrp==66)) &&
    ...  (nr-rrc.timeToTrigger==0)
    ${vonr_filter} =  Set Variable  ngap && ngap.qosFlowIdentifier == 1 && ngap.NGAP_PDU == 1
    ${result} =  Run Process
    ...  command=tshark -r ${TCPDUMP_PATH} -Y "${vonr_filter}" |wc -l  shell=True
    Should Be Equal As Integers  ${result.rc}  0
    ...  msg=RC is not equal to 0. There were some errors during execution of tshark command.\nError message: ${result.stderr}.
    Should Be Equal As Strings  '${result.stderr}'  ''
    ...  msg=Errors appeared while executing command: tshark -r ${TCPDUMP_PATH} -Y "${vonr_filter}" |wc -l.\nError message: ${result.stderr}
    Should Be True  ${result.stdout} > 0
    ...  msg=There are no packets indicationg succesfully started VoNR call. Please verify tcpdump logs.
    Log  Messages found in pcap logs with display filter: ${vonr_filter}.  console=True
    ${result} =  Run Process
    ...  command=tshark -r ${TCPDUMP_PATH} -Y "${filter1}" |wc -l  shell=True
    Should Be Equal As Integers  ${result.rc}  0
    ...  msg=RC is not equal to 0. There were some errors during execution of tshark command.\nError message: ${result.stderr}.
    Should Be Equal As Strings  '${result.stderr}'  ''
    ...  msg=Errors appeared while executing command: tshark -r ${TCPDUMP_PATH} -Y "${filter1}" |wc -l.\nError message: ${result.stderr}
    Should Not Be True  ${result.stdout} == 0
    ...  msg=Proper configuration for intra freq events a2,a3,a5 is not present.
    Log  Number of filtered packets:${result.stdout}, which means proper a2,a3,a5 intra-frequency configs are avaliable.  console=True


Step 5: Collect Counters
    Log    \n*** Step 5: Collect Counters ***  console=True
    Log    Waiting for counters, that may take a while ...  console=True
    ${time}    Count Measurement Period  counter_period=${COUNTER_PERIOD}  ip=${GNB_OAM_IP}
    ...    user=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...    password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ...    delta=30
    Sleep    ${time}s  reason=Wait till new PM file is available
    Collect PM Counters  ${LOG_PATH}/pm_counters_s  xml_files_left=2  time_interval=5 min  intervals=5
    ${m55190c00001} =  Get Counters Values
    ...    ${LOG_PATH}/pm_counters_s  M55190C00001  MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID}/PLMN-PLMN/NRMASA-2  1
    Set Test Variable  ${M55190C00001}  ${m55190c00001}
    ${m55187c00001} =  Get Counters Values
    ...    ${LOG_PATH}/pm_counters_s  M55187C00001  MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID}/PLMN-PLMN/NRMIAF-2  1
    Set Test Variable  ${M55187C00001}  ${m55187c00001}


Step 6: Check Counters Values
    Log    \n*** Step 6: Check Counters Values ***  console=True
    ${m55190c00001_evaluation} =  Evaluate  all([x == '${EXP_VAL_M55190C00001}' for x in ${M55190C00001}])
    ${m55187c00001_evaluation} =  Evaluate  all([x == '${EXP_VAL_M55187C00001}' for x in ${M55187C00001}])
    Should Be True  ${m55190c00001_evaluation}  msg=Counter value for M55190C00001 is other than ${EXP_VAL_M55190C00001}
    Should Be True  ${m55187c00001_evaluation}  msg=Counter value for M55187C00001 is other than ${EXP_VAL_M55187C00001}


Get Counters Values
    [Arguments]  ${files_path}  ${counter}  ${dist_name}  ${counters_amount}=all
    ${counter_list} =  Create List  ${counter}
    ${pi_dict} =  Get PI Value
    ...    pi_list=${counter_list}
    ...    pi_dir=${files_path}
    ...    pi_file_pattern=PM*
    ${pi_dict} =  Set Variable If  '${counters_amount}'.lower() == 'all'
    ...                             ${pi_dict}
    ...                             ${pi_dict[-${counters_amount}:]}
    ${all_counters_dicts} =  Evaluate  [list(x.values())[0] for x in ${pi_dict}]
    ${counter_values} =  Evaluate
    ...    [x['${counter}']['${dist_name}'] for x in ${all_counters_dicts} if '${counter}' in x.keys()]
    Should Not Be Empty  ${counter_values}  msg=Counter was not collected
    [Return]  ${counter_values}


TC Setup
    IWK Test Setup  local_enb_connection=False  single_bts=True  start_wireshark=False


TC Teardown
    Log  \n=== TC Teardown ===  console=True
    Detach UE  NR_UE
    Run Keyword If  ${STARTED_TCPDUMP}  Stop Wireshark Log Collection For IWK Test
    IWK Test Teardown  local_enb_connection=False  single_bts=True  stop_wireshark=False


