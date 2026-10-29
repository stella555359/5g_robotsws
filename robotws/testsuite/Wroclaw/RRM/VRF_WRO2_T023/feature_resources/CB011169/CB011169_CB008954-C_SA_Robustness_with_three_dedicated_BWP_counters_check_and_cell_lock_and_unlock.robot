*** Settings ***
Documentation
...   contact: Monika Ceglarek

Library     ute_ue
Library     ../../resources/tti_trace.py
Resource    ../../resources/ca_INTER_RAT.robot
Resource    ../../resources/ca_IWK.robot
Resource    ../../resources/cloud_bts.robot
Resource    resources/CB011169_resources.robot


*** Variables ***
${NR_CELL_ID}                                   # ID of tested NR cell
${NR_UE_CAPABILITY}                             # Capability of UE used for test
${CELL_ALIAS}                                   # Alias set for tested cell in attenuator configuration file
${ATTENUATION_VALUE}                            # Value of tested cell attenuation
${BWP_PROFILE_DN_INITIAL}                       # Dist name for initial BWP_PROFILE MO
${BWP_PROFILE_DN_100MHZ}                        # Dist name for dedicated BWP_PROFILE MO for 100MHZ
${BWP_PROFILE_DN_80MHZ}                         # Dist name for dedicated BWP_PROFILE MO for 80MHZ
${BWP_PROFILE_DN_40MHZ}                         # Dist name for dedicated BWP_PROFILE MO for 40MHZ
${MSG1_FREQ_START}                              # New value for msg1FrequencyStart
${NAMESPACE}                                    # vDU namespace used for collecting Cplane logs
${COUNTER_PERIOD}         5                     # Counter collecting interval in minutes. Default value: 5
${PHONE_NUMBER}           0105                  # Number to autoresponder for VoNR
${APN_CONTAINS}           n26wro/rmnet_data     # Part of APN name that does not change. Default value: n26wro/rmnet_data.
${MAX_UTF_LOGS_DELAY}     300s                  # Max time in seconds needed for change of UTF logs collecting status to 'running'
# Default value: 300s
${COLLECT_UE_LOGS}        True                  # Boolean indicating whether UE logs should be collected during test. Default value: True.

*** Keywords ***
TC__CB011169_CB008954-C_SA_Robustness_with_three_dedicated_BWP_counters_check_and_cell_lock_and_unlock

    Set Tags    CA-RRM    AUTHOR-monika.ceglarek@nokia.com    MAINTAINER-monika.ceglarek@nokia.com
    ...         PHASE-CRT   SW-SBTS24R3    GROUP_IN_CHARGE-Pz_2_WRO_2


    Preconditions
    Step 1: Lock Cell
    Step 2: Unlock Cell
    Step 3: Start Data Transfers And Start Voice Call For UE 1
    Step 4: Collect And Analyze Counters For UE 1
    Step 5: Analyze TTI Traces For UE 1
    Step 6: Start Data Transfers And Start Voice Call For UE 2
    Step 7: Collect And Analyze Counters For UE 2
    Step 8: Analyze TTI Traces For UE 2
    Step 9: Start Data Transfers And Start Voice Call For UE 3
    Step 10: Collect And Analyze Counters For UE 3
    Step 11: Analyze TTI Traces For UE 3


Preconditions
    Log  \n==== Preconditions ====  console=True

    Create Global Variables

    Save SCF VCU  vCU_SCF_original.xml
    Save SCF VDU  vDU_SCF_original.xml

    Prepare VCU For Feature CB011169  ${LOG_PATH}/misc_logs/vCU_SCF_original.xml
    Prepare VDU For Feature CB011169  ${LOG_PATH}/misc_logs/vDU_SCF_original.xml
    Wait Until Keyword Succeeds  600s  30s  Verify BTS States For Cloud BTS
    ...  ${IGNORED_ALARMS_VCU}  ${IGNORED_ALARMS_VDU}

    Save SCF VDU  vDU_SCF_after_commissioning.xml
    Save SCF VCU  vCU_SCF_after_commissioning.xml

    Require UE  NR_UE1  ${NR_UE_CAPABILITY}
    Require UE  NR_UE2  EFS1
    Require UE  NR_UE3  EFS2

    Setup TTI Decoder For Vdu

    Set Test Variable  ${WIRESHARK_STARTED}  True
    Start Wireshark Log Collection For VCU  namespace=${NAMESPACE}

    Set Test Variable  ${ATTENUATOR_SET}  True
    Set Attenuation For All Cells  100%
    Set Attenuation  ${CELL_ALIAS}  ${ATTENUATION_VALUE}

    [Teardown]  Run Keywords  Run Keyword And Ignore Error  vcu.Disconnect
    ...  AND  Run Keyword And Ignore Error  vdu.Disconnect


Create Global Variables
    Set Test Variable  ${ATTENUATOR_SET}  False
    Set Test Variable  ${WIRESHARK_STARTED}  False
    Set Test Variable  ${CELL_LOCKED}  False
    Set Test Variable  ${VCU_SCF_MODIFIED}  False
    Set Test Variable  ${VDU_SCF_MODIFIED}  False

    Get MRBTS ID From VDU
    Get MRBTS ID From VCU
    Get NRBTS ID From VDU

    ${nr_cell_identity} =  Get NR Cell Identity From VDU  ${NR_CELL_ID}
    Set Test Variable  ${NR_CALL_CELL_ID}  ${nr_cell_identity}

    &{dl_tput_dict} =  Create Dictionary
    Set Test Variable  ${DL_TPUT_DICT}
    &{ul_tput_dict} =  Create Dictionary
    Set Test Variable  ${UL_TPUT_DICT}


Step 1: Lock Cell
    Log  \n==== Step 1: Lock Cell ====  console=True

    ${cell_list} =  Create List  ${NR_CELL_ID}
    Connect To VDU
    Set Test Variable  ${CELL_LOCKED}  True
    ${operation_info} =  vdu.Lock Cells  ${cell_list}
    Wait Until Keyword Succeeds  1min  5s  Check If Cell Lock Operation Ended  ${operation_info['id']}
    Wait Until Keyword Succeeds  30s  5s  Verify BTS States For Cloud BTS - Locked Cell  ${NR_CELL_ID}
    ...  ignored_alarms_vcu=${IGNORED_ALARMS_VCU}  ignored_alarms_vdu=${IGNORED_ALARMS_VDU}


Step 2: Unlock Cell
    Log  \n==== Step 2: Unlock Cell ====  console=True

    ${cell_list} =  Create List  ${NR_CELL_ID}
    Connect To VDU
    ${operation_info} =  vdu.Unlock Cells  ${cell_list}
    Wait Until Keyword Succeeds  1min  5s  Check If Cell Unlock Operation Ended  ${operation_info['id']}
    Wait Until Keyword Succeeds  6min  5s  Verify BTS States For Cloud BTS
    ...  ignored_alarms_vcu=${IGNORED_ALARMS_VCU}  ignored_alarms_vdu=${IGNORED_ALARMS_VDU}
    Set Test Variable  ${CELL_LOCKED}  False


Step ${index}: Start Data Transfers And Start Voice Call For UE ${ue_id}
    Log  \n==== Step ${index}: Start Data Transfers And Start Voice Call For UE ${ue_id} ====  console=True

    Get Start Time
    Wait For New Counter Period

    ${tput_start_time1} =  Start Data Transfer And Voice Call For UE  ${ue_id}
    Log  Waiting 150s...  console=True
    ${waiting_time1} =  Count Measurement Period  ${VDU_MASTER_SSH_DETAILS.addr}  ${COUNTER_PERIOD}
    ...  user=${VDU_MASTER_SSH_DETAILS.username}  password=${VDU_MASTER_SSH_DETAILS.password}
    Sleep  150s  reason=Running data transfers and voice calls.
    Run Keyword And Continue On Failure  Check If Data Transfer Is Alive And Get Throughput  ${ue_id}  30

    Start Collecting Logs With UTF  ${NR_CELL_ID}
    Sleep  3s    reason=Wait for TTI to be collected.

    [Teardown]  Run Keywords  Stop UTF Traces and Download Logs  ${TRACE_ID}  ue_id=${ue_id}
    ...    AND  Stop Data Transfer And Voice Call For UE  ${ue_id}
    ...    AND  Wait For New Counter Period  ${waiting_time1}


Start Data Transfer And Voice Call For UE
    [Arguments]  ${ue_id}
    Run Keyword If  ${COLLECT_UE_LOGS}  Start RRC Logs  NR_UE${ue_id}
    cloud_bts.Prepare UE For Data Transfer  NR_UE${ue_id}  ${NR_CALL_CELL_ID}  retry_interval=10s  retry=2
    Log  \nUE${ue_id} attached to cell ${NR_CALL_CELL_ID}.  console=True

    Get UE Info  NR_UE${ue_id}  ALL

    ${apn} =  Get Full APN Name For UE  ${APN_CONTAINS}  ue_alias=NR_UE${ue_id}
    Start Data Transfer  NR_DL${ue_id}  NR_UE${ue_id}  dl  duration=900s
    ...  protocol=tcp  max_segment_size=1400  buffer=32M  apn=${apn}
    Log  \nDL data transfer started on UE${ue_id}.  console=True

    Start Data Transfer  NR_UL${ue_id}  NR_UE${ue_id}  ul  duration=900s
    ...  protocol=tcp  max_segment_size=1400  buffer=32M  apn=${apn}
    Log  \nUL data transfer started on UE${ue_id}.  console=True
    Sleep  15s  reason=Wait for throughput to stabilize.

    Start Voice Call  vc_alias=VOICE_CALL${ue_id}  ue_alias=NR_UE${ue_id}  to=${PHONE_NUMBER}  duration=900s
    Log  Voice call on UE${ue_id} started.  console=True

    ${tput_start_time} =  Get Time  epoch

    [Return]  ${tput_start_time}


Check If Data Transfer Is Alive And Get Throughput
    [Arguments]  ${ue_id}  ${omit}
    Get UE Info  NR_UE${ue_id}  ALL
    Check Data Transfer Is Alive  NR_DL${ue_id}
    ${nr_dl_tput} =  Get Average Throughput  NR_DL${ue_id}  omit=${omit}
    ${nr_dl_tput} =  Evaluate  ${nr_dl_tput}/1000.0
    Log  \nUE${ue_id} DL:${nr_dl_tput} Mbps  console=True
    Check Data Transfer Is Alive  NR_UL${ue_id}
    ${nr_ul_tput} =  Get Average Throughput  NR_UL${ue_id}  omit=${omit}
    ${nr_ul_tput} =  Evaluate  ${nr_ul_tput}/1000.0
    Log  \nUE${ue_id} UL:${nr_ul_tput} Mbps  console=True

    Set To Dictionary  ${DL_TPUT_DICT}  ${ue_id}=${nr_dl_tput}
    Set Test Variable  ${DL_TPUT_DICT}

    Set To Dictionary  ${UL_TPUT_DICT}  ${ue_id}=${nr_ul_tput}
    Set Test Variable  ${UL_TPUT_DICT}


Stop Data Transfer And Voice Call For UE
    [Arguments]  ${ue_id}
    Stop Data Transfer  NR_DL${ue_id}
    Stop Data Transfer  NR_UL${ue_id}
    Stop Voice Call  VOICE_CALL${ue_id}
    Detach UE  NR_UE${ue_id}
    Log  Data transfers and voice call stopped for UE${ue_id}. UE${ue_id} is detached.  console=True
    Run Keyword If  ${COLLECT_UE_LOGS}  Stop RRC Logs  NR_UE${ue_id}  timeout=900
    ...  logs_download_directory=${LOG_PATH}/misc_logs/NR_UE${ue_id}


Step ${index}: Collect And Analyze Counters For UE ${ue_id}
    Log  \n==== Step ${index}: Collect And Analyze Counters For UE ${ue_id} ====  console=True

    ${for_last} =  Evaluate  ${COUNTER_PERIOD} * 2
    ${counters_list} =  Run Keyword If  '${ue_id}' == '1'  Create List
    ...  M55308C00081  M55308C00083  M55139C02504  M55308C00082  M55308C00084  M55308C00085  M55308C00086  M55139C04509  M55139C04510
    ...  ELSE IF  '${ue_id}' == '2'  Create List
    ...  M55308C28005  M55308C28007  M55139C02502  M55308C28006  M55308C28008  M55308C29003  M55308C29004  M55139C04507  M55139C04508
    ...  ELSE IF  '${ue_id}' == '3'  Create List
    ...  M55308C28001  M55308C28003  M55139C02501  M55308C28002  M55308C28004  M55308C29001  M55308C29002  M55139C04505  M55139C04506
    Sleep  60s    reason=Additional waiting time for counters to update.
    Connect To VDU
    FOR  ${counter_id}  IN  @{counters_list}
        ${counter_value} =  Get Counter List For VDU  counter_id=${counter_id}
        ...  dimension_dn=MRBTS-${VDU_MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID}
        ...  counter_amount=1  start_time=${START_TIME}
        Log  ${counter_id} = ${counter_value}  console=True
        Run Keyword And Continue On Failure  Should Be True  ${counter_value[0]} > 0
        ...  msg=Vaule for counter ${counter_id} (${counter_value[0]}) is not > 0.
    END

    [Teardown]  Collect PM Counters  xml_files_left=1  host=${VDU_OAM_CONNECTION.addr}  user=${VDU_OAM_CONNECTION.username}
    ...  password=${VDU_OAM_CONNECTION.password}  time_interval=${for_last} min  intervals=${COUNTER_PERIOD}  bts_type=vdu
    ...  target_dir_path=${LOG_PATH}/pm_counters/UE${ue_id}


Step ${index}: Analyze TTI Traces For UE ${ue_id}
    Log  \n==== Step ${index}: Analyze TTI Traces For UE ${ue_id} ====  console=True
    ${expected_prbs_value} =  Set Variable If  '${ue_id}' == '1'  273
    ...                                        '${ue_id}' == '2'  217
    ...                                        '${ue_id}' == '3'  106
    Analyze PRBs  ue_id=${ue_id}  utf_logs_path=${UTF_LOGS_PATH}  destination_path=${LOG_PATH}/traces/UE${ue_id}
    ...  unzipped_path=/tmp/utf_unzipped_ue${ue_id}  expected_prbs_value=${expected_prbs_value}


Analyze PRBs
    [Arguments]  ${ue_id}  ${utf_logs_path}  ${destination_path}  ${unzipped_path}  ${expected_prbs_value}
    ${tti_file_path} =  Unzip TTI  ${utf_logs_path}
    ...  destination_path=${destination_path}  file_search_str=start_trace_5G_L2
    ...  unzipped_path=${unzipped_path}
    Convert 5G TTI With Eventdecoder Options  ${tti_file_path}  output_file_path=${destination_path}
    ...  eventdecoder_options=--split 200000 --include ${CURDIR}${/}resources${/}Included_TTI_Events_List.txt
    ${path_exist}  Run Keyword And Return Status  OperatingSystem.File Should Exist  ${destination_path}/NR_TTI_dl.csv
    ${csv_tti_path} =  Set Variable If  ${path_exist}  ${destination_path}/NR_TTI_dl.csv
    ...                                                ${destination_path}/NR_TTI_dl.0.csv
    ${max_prb_value} =  Run Keyword And Continue On Failure  Get Max PRB Value  ${csv_tti_path}
    Log  Max PRB value for UE${ue_id}: ${max_prb_value}  console=True
    Should Be Equal As Integers  ${max_prb_value}  ${expected_prbs_value}
    ...  msg=Max PRB value (${max_prb_value}) is not equal to expected PRB value (${expected_prbs_value}).


TC Setup
    Cloud BTS Test Setup  ignored_alarms_vcu=${IGNORED_ALARMS_VCU}  ignored_alarms_vdu=${IGNORED_ALARMS_VDU}
    Run Keyword If  ${COLLECT_UE_LOGS}  Get QXDM Licence
    Create Directory  ${LOG_PATH}/misc_logs/NR_UE1
    Create Directory  ${LOG_PATH}/misc_logs/NR_UE2
    Create Directory  ${LOG_PATH}/misc_logs/NR_UE3


TC Teardown
    [Timeout]  60 min
    Log  \n === TC Teardown ===   console=True
    Run Keyword If  ${COLLECT_UE_LOGS}  Release QXDM Licence
    Run Keyword If  ${CELL_LOCKED}  Step 2: Unlock Cell
    Run Keyword If  ${ATTENUATOR_SET}  Set Attenuation For All Cells  100%
    Run Keyword If  ${WIRESHARK_STARTED}  Stop Wireshark Log Collection
    Run Keyword If  ${VCU_SCF_MODIFIED}  Perform Commissioning On VCU  ${LOG_PATH}/misc_logs/vCU_SCF_original.xml
    Run Keyword If  ${VDU_SCF_MODIFIED}  Perform Commissioning On VDU  ${LOG_PATH}/misc_logs/vDU_SCF_original.xml
    Run Keyword If  ${VCU_SCF_MODIFIED} or ${VDU_SCF_MODIFIED}  Wait Until Keyword Succeeds  600s  30s
    ...  Verify BTS States For Cloud BTS  ${IGNORED_ALARMS_VCU}  ${IGNORED_ALARMS_VDU}
    Cloud BTS Test Teardown
