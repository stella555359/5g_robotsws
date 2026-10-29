*** Settings ***
Documentation
...   contact: Monika Ceglarek

Library     ute_ue
Library     taf.ul.alarms_watchdog    WITH NAME    alarms_watchdog_main
Library     taf.ul.alarms_watchdog    WITH NAME    alarms_watchdog_ho
Resource    ../../resources/ca_INTER_RAT.robot
Resource    ../../resources/ca_IWK.robot
Resource    ../../resources/attenuator.robot
Resource    resources/UTF_Logs_Collecting_For_HO.robot


*** Variables ***
${NR_CELL_ID1}                                        # ID of NR cell from which HO will be performed.
${NR_CELL_ID2}                                        # ID of NR cell to which HO will be performed.
${TARGET_SMOD_SERIAL_NUMBER}                          # Serial number of target SMOD.
${SOURCE_ATTENUATION_LIST}                            # List of source BTS attenuation values.
${TARGET_ATTENUATION_LIST}                            # List of target BTS attenuation values.
${SOURCE_CELL_ALIAS}                                  # Alias set for source cell in attenuator configuration file.
${TARGET_CELL_ALIAS}                                  # Alias set for target cell in attenuator configuration file.
${TA_ATTENUATOR_CONFIG}                               # Absolute path to YAML file with attenuator configuration.
${IS_HO_TEST_CASE}                                    # Boolean value defining if test execution should perform HO. True if yes, False if no.
${GNB_CPLANE_IP}                                      # Target gNB C-Plane IP
${ADDITIONAL_UE_CAPABILITY}                           # Additional capability of UE (mainly for differentiating between android and iphone).
${APN_CONTAINS}                n26wro                 # Part of APN name that does not change. Default value: n26wro.
${MAX_UTF_LOGS_DELAY}          300s                   # Max time in seconds needed for change of UTF logs collecting status to 'running'
# Default value: 300s
${VIRTUALENV_DIR}     /home/ute/.pyenv/versions/3.11.9/envs/test_repo/     # Absolute path to virtual environment for syslog.
${IGNORED_ALARMS}              @{EMPTY}               # Ignored alarms list, e.g. faultId=6327  faultId=1234


*** Keywords ***
TC__Rjio_E2E_34_Intra-Frequency_And_Inter-Gnb_Ho_And_ANR_Ng_Based

    Set Tags    CA-RRM    AUTHOR-monika.ceglarek@nokia.com    MAINTAINER-marcel.behen@nokia.com
    ...         PHASE-CDRT   SW-SBTS24R1    GROUP_IN_CHARGE-Pz_2_WRO_2


    Preconditions
    Step 1: Remove NRADJNRCELL And NRREL If Any Exist
    Looped Steps
    Run Keyword And Continue On Failure    Step 6: Check If NR-NR Neighbour Was Created
    Step 7: Check BTS State
    Return From Keyword If  not ${IS_HO_TEST_CASE}
    Step 8: Set Attenuation On Ports
    Step 9: Perform Attach
    Step 10: Start Collecting Wireshark Logs
    Step 11: Start DL Data Transfer
    Step 12: Change Attenuation
    Step 13: Stop And Collect Wireshark Logs
    Step 14: Check Messages For Inter GNB HO
    Step 15: Stop Data Transfer
    Step 16: Check BTS State


Looped Steps
    FOR  ${loop}  IN RANGE  1  3
        Set Test Variable  ${LOOP}  ${loop}
        Log  \n--- LOOP${LOOP} START ---  console=True
        Step 2: Set Attenuation On Ports
        Step 3: Perform Attach
        Step 4: Change Attenuation
        Step 5: Detach UE
        Log  --- LOOP${LOOP} END ---\n  console=True
    END


Preconditions
    Log  \n==== Preconditions ====  console=True

    Check If ANR And Handover for Source And Target Are Configured

    _choose ue type helper
    ${ue_capabilities} =  Create List  NR_LOCKED_POWER_SAVING  ${ADDITIONAL_UE_CAPABILITY}
    Require UE  UE  ${ue_capabilities}

    Set Test Variable  ${ATTENUATOR_SET}  True
    Set Attenuation For All Cells  100%
    Set Attenuation  ${SOURCE_CELL_ALIAS}  ${0}

    Run Keyword If  '${UE_TYPE}' == 'iphone'  Remove Baseband Logs  UE


Create Global Variables
    Set Test Variable  ${TEST_STARTED}  True
    Set Test Variable  ${TCPDUMP_STARTED}  False
    Set Test Variable  ${ATTENUATOR_SET}  False
    Set Test Variable  ${TEST_CONNECTION}  main
    Set Test Variable  ${CHECK_IN_TEARDOWN}  True

    ${nrbts_id} =  Get BTS ID From ADMIN  alias=${TEST_CONNECTION}
    Set Test Variable  ${NRBTS_ID}  ${nrbts_id}

    ${_}  ${scf_gnb1} =  Save And Parse SCF  SCF_gNB1  alias=${TEST_CONNECTION}
    Set Test Variable  ${SCF_GNB1}  ${scf_gnb1}

    ${_}  ${scf_gnb2} =  Save And Parse SCF  SCF_gNB2  alias=${TARGET_SMOD_SERIAL_NUMBER}
    Set Test Variable  ${SCF_GNB2}  ${scf_gnb2}

    ${nrbts_dist_name} =  Get DistName Attribute From SCF  ${SCF_GNB2}  NRBTS  NRBTS
    ${nrbts_id2} =  Fetch From Right  ${nrbts_dist_name}  -
    Set Test Variable  ${NRBTS_ID2}  ${nrbts_id2}

    ${lcr_id} =  Get Parameter Value From SCF  ${SCF_GNB2}  NRCELL  NRCELL-${NR_CELL_ID2}
    ...  /p[@name='lcrId']  dist_name_substring=True
    Set Test Variable  ${LCR_ID}  ${lcr_id}

    ${global_nr_cell_id} =  Get NR Global Cell ID From NR Cell ID  ${NR_CELL_ID1}  connection=${TEST_CONNECTION}
    Set Test Variable  ${NR_CALL_CELL_ID1}  ${global_nr_cell_id}

    ${global_nr_cell_id} =  Get NR Global Cell ID From NR Cell ID  ${NR_CELL_ID2}  connection=${TARGET_SMOD_SERIAL_NUMBER}
    Set Test Variable  ${NR_CALL_CELL_ID2}  ${global_nr_cell_id}


Check If ANR And Handover for Source And Target Are Configured
    Log  Checking if NRBTS-${NRBTS_ID} has actSaUeBasedAnrEutra=true...  console=True
    Check Element In SCF  ${SCF_GNB1}  NRBTS  NRBTS-${NRBTS_ID}  /p[@name='actSaUeBasedAnrNr']
    ...  <p name="actSaUeBasedAnrNr">true</p>  dist_name_substring=True


Step 1: Remove NRADJNRCELL And NRREL If Any Exist
    Log  \n==== Step 1: Remove NRADJNRCELL And NRREL If Any Exist ====  console=True

    ${nradjnrcell_exists}  ${nrrel_exists} =  Check If NRADJNRCELL And NRREL Exist
    Return From Keyword If  not (${nradjnrcell_exists} or ${nrrel_exists})

    Create Delta  delete_for_anr
    Run Keyword If  ${nradjnrcell_exists}  Add Deleting Of NRADJNRCELL Object To Delta
    Run Keyword If  ${nrrel_exists}  Add Deleting Of NRREL Object To Delta
    ${delta} =  Get Delta  delete_for_anr
    Log  Delta contents:\n${delta}\n  console=True
    Perform Delta Recommissioning  ${delta}  timeout=600s  alias=${TEST_CONNECTION}
    Check BTS State For Multiple BTS Configuration  ${IGNORED_ALARMS}

    [Teardown]  Run Keyword If  ${nradjnrcell_exists} or ${nrrel_exists}  Remove Delta  delete_for_anr


Add Deleting Of NRADJNRCELL Object To Delta
    ${nradjnrcell_dist_name} =  Get DistName Attribute From SCF  ${SCF_GNB1}  NRADJNRCELL
    ...  MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}/NRADJNRCELL
    ...  /p[@name='lcrId'][.='${LCR_ID}']/../p[@name='gNbId'][.='${NRBTS_ID2}']/..
    Append Managed Object To Delta  ${nradjnrcell_dist_name}  delete  delta_id=delete_for_anr


Add Deleting Of NRREL Object To Delta
    ${nrrel_dist_name} =  Get DistName Attribute From SCF  ${SCF_GNB1}  NRREL
    ...  MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID1}/NRREL
    ...  /p[@name='lcrId'][.='${LCR_ID}']/../p[@name='gNbId'][.='${NRBTS_ID2}']/..
    Append Managed Object To Delta  ${nrrel_dist_name}  delete  delta_id=delete_for_anr


Check If NRADJNRCELL And NRREL Exist
    Log  Checking if MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}/NRADJNRCELL for gNbId=${NRBTS_ID2} and lcrId=${LCR_ID} exists...  console=True
    ${nradjnrcell_exists} =  Run Keyword And Return Status  Check If Element Exists In SCF  ${SCF_GNB1}  NRADJNRCELL
    ...  MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}/NRADJNRCELL
    ...  /p[@name='lcrId'][.='${LCR_ID}']/../p[@name='gNbId'][.='${NRBTS_ID2}']

    Log  Checking if MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID1}/NRREL for gNbId=${NRBTS_ID2} and lcrId=${LCR_ID} exists...
    ...  console=True
    ${nrrel_exists} =  Run Keyword And Return Status  Check If Element Exists In SCF  ${SCF_GNB1}  NRREL
    ...  MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID1}/NRREL
    ...  /p[@name='lcrId'][.='${LCR_ID}']/../p[@name='gNbId'][.='${NRBTS_ID2}']
    [Return]  ${nradjnrcell_exists}  ${nrrel_exists}


Step ${index}: Set Attenuation On Ports
    Log  \n==== Step ${index}: Set Attenuation On Ports ====  console=True

    Set Test Variable  ${CHECK_IN_TEARDOWN}  True

    Set Attenuation  ${SOURCE_CELL_ALIAS}  ${0}
    Set Attenuation  ${TARGET_CELL_ALIAS}  100%


Step ${index}: Perform Attach
    Log  \n==== Step ${index}: Perform Attach ====  console=True

    Get UE Info  UE  ALL
    Prepare UE For Data Transfer  UE  ${NR_CALL_CELL_ID1}  connection=${TEST_CONNECTION}  apn=${APN_CONTAINS}  ue_type=${UE_TYPE}
    ...  lte_cell=False
    Log  \nUE attached to cell ${NR_CALL_CELL_ID1}.  console=True


Step ${index}: Change Attenuation
    Log  \n==== Step ${index}: Change Attenuation ====  console=True

    FOR  ${source_attenuation}  ${target_attenuation}  IN ZIP  ${SOURCE_ATTENUATION_LIST}  ${TARGET_ATTENUATION_LIST}
        Set Attenuation For Ports  ${TARGET_CELL_ALIAS}  ${target_attenuation}
        Set Attenuation For Ports  ${SOURCE_CELL_ALIAS}  ${source_attenuation}
    END


Set Attenuation For Ports
    [Arguments]  ${cell_alias}  ${attenuation}
    Log  Setting attenuation to ${attenuation} for cell: ${cell_alias}...  console=True
    Set Attenuation  ${cell_alias}  ${attenuation}
    Sleep  1s


Step 5: Detach UE
    Log  \n==== Step 5: Detach UE ====  console=True
    Detach UE  UE


Step 6: Check If NR-NR Neighbour Was Created
    Log  \n==== Step 6: Check If NR-NR Neighbour Was Created ====  console=True

    Log  Wait 3min for NR-NR neighbor to be created...   console=True
    Sleep  3 min  reason=Wait for NR-NR neighbor to be created.
    ${_}  ${scf_gnb1} =  Save And Parse SCF  SCF_gNB1_Step6  alias=${TEST_CONNECTION}
    Set Test Variable  ${SCF_GNB1}  ${scf_gnb1}
    ${nradjnrcell_exists}  ${nrrel_exists} =  Check If NRADJNRCELL And NRREL Exist
    Should Be True  ${nradjnrcell_exists} and ${nrrel_exists}
    ...  msg=One or both: NRADJNRCELL (${nradjnrcell_exists}) and NRREL (${nrrel_exists}) were not found.


Step ${index}: Check BTS State
    Log  \n==== Step ${index}: Check BTS State ====  console=True

    Append To List  ${IGNORED_ALARMS}  faultId=61641
    Check BTS State For Multiple BTS Configuration  ${IGNORED_ALARMS}
    Set Test Variable  ${CHECK_IN_TEARDOWN}  False
    alarms_watchdog_main.Check Detected Alarms
    alarms_watchdog_ho.Check Detected Alarms


Step 10: Start Collecting Wireshark Logs
    Log  \n==== Step 10: Start Collecting Wireshark Logs ====  console=True

    Set Test Variable  ${TCPDUMP_STARTED}  True
    Start Wireshark Log Collection On Remote  serial_number=${TARGET_SMOD_SERIAL_NUMBER}  options=-i any sctp
    ...  alias=tcpdump_BTS_${NRBTS_ID2}_IP_${GNB_CPLANE_IP}


Step 11: Start DL Data Transfer
    Log  \n==== Step 11: Start DL Data Transfer ====  console=True

    ${apn} =  Get Full APN Name For UE  ${APN_CONTAINS}
    Log  Starting DL data transfer.  console=True
    Start Data Transfer  NR_DL  UE  dl  throughput=400 Mbits/sec  duration=540s
    ...  protocol=udp  packet=1400  parallel_streams=4  apn=${apn}
    Log  Data transfer ongoing...  console=True
    Sleep  10s  reason=Wait for throughput to start and stabilize.


Step 13: Stop And Collect Wireshark Logs
    [Timeout]  30min
    Log  \n==== Step 13: Stop And Collect Wireshark Logs ====  console=True

    ${tcpdump_path} =  Stop Wireshark Log Collection  alias=tcpdump_BTS_${NRBTS_ID2}_IP_${GNB_CPLANE_IP}
    Set Test Variable  ${TCPDUMP_STARTED}  False
    Set Test Variable  ${TCPDUMP_PATH}  ${tcpdump_path}


Step 14: Check Messages For Inter GNB HO
    Log  \n==== Step 14: Check Messages For Inter GNB HO ====  console=True

    ${target_data} =  Get From Dictionary  ${ALL_BTS_DATA}  ${TARGET_SMOD_SERIAL_NUMBER}
    ${gnb_mplane_ip} =  Get From Dictionary  ${target_data}  mplane_ip

    Log  Checking messages from ${TCPDUMP_PATH}...  console=True
    Run Keyword And Continue On Failure
    ...  _check messages helper  tcpdump_path=${TCPDUMP_PATH}
    ...  display_filter=xnap.procedureCode == 0 and ip.src == ${gnb_mplane_ip}
    ...  msg_string=HO request
    Run Keyword And Continue On Failure
    ...  _check messages helper  tcpdump_path=${TCPDUMP_PATH}
    ...  display_filter=xnap.procedureCode == 0 and ip.dst == ${gnb_mplane_ip}
    ...  msg_string=HO response
    Run Keyword And Continue On Failure
    ...  _check messages helper  tcpdump_path=${TCPDUMP_PATH}
    ...  display_filter=ngap.procedureCode == 25 and ip.src == ${gnb_mplane_ip}
    ...  msg_string=HO path switch request
    Run Keyword And Continue On Failure
    ...  _check messages helper  tcpdump_path=${TCPDUMP_PATH}
    ...  display_filter=ngap.procedureCode == 25 and ip.dst == ${gnb_mplane_ip}
    ...  msg_string=path switch ACK
    Run Keyword And Continue On Failure
    ...  _check messages helper  tcpdump_path=${TCPDUMP_PATH}
    ...  display_filter=xnap.procedureCode == 6
    ...  msg_string=UE context release


_check messages helper
    [Arguments]  ${tcpdump_path}  ${display_filter}  ${msg_string}
    ${result} =  Run Process
    ...  command=tshark -r ${tcpdump_path} -Y "${display_filter}" |wc -l  shell=True
    Should Be Equal As Integers  ${result.rc}  0
    ...  msg=RC is not equal to 0. There were some errors during execution of tshark command.\nError message: ${result.stderr}.
    Should Be Equal As Strings  '${result.stderr}'  ''
    ...  msg=Errors appeared while executing command: tshark -r ${tcpdump_path} -Y "${display_filter}" |wc -l.\nError message: ${result.stderr}
    Should Be True  ${result.stdout} >= 1
    ...  msg=There are no packets for correct ${msg_string}. Filter used: (${display_filter}). Please verify tcpdump logs.


Step 15: Stop Data Transfer
    Log  \n==== Step 15: Stop Data Transfer ====  console=True

    Get UE Info  UE  ALL
    Check Data Transfer Is Alive  NR_DL
    ${nr_dl_tput} =  Get Average Throughput  NR_DL
    ${nr_dl_tput} =  Evaluate  ${nr_dl_tput}/1000.0
    Log  \nDL:${nr_dl_tput} Mbps  console=True

    [Teardown]  Run Keywords  Get UE Info  UE  ALL
    ...    AND  Stop Data Transfer  NR_DL
    ...    AND  Detach UE  UE
    ...    AND  Log  Data transfer finished.  console=True


_choose ue type helper
    IF  '${ADDITIONAL_UE_CAPABILITY}' == 'REAL_IPHONE_UE'
        Set Test Variable  ${UE_TYPE}  iphone
    ELSE
        Set Test Variable  ${UE_TYPE}  android
    END


TC Setup
    Multiple BTS Test Setup  virtual_env_path=${VIRTUALENV_DIR}  ignored_alarms=${IGNORED_ALARMS}
    Alarm Watchdog Setup  ${IGNORED_ALARMS_FOR_HO_TC}  instance=alarms_watchdog_main
    Alarm Watchdog Setup  ${IGNORED_ALARMS_FOR_HO_TC}  bts_config=${tl.gnbs[1]}  instance=alarms_watchdog_ho
    Create Global Variables
    Run Keyword And Ignore Error  Start Collecting Logs With UTF  source_cell_id=${NR_CELL_ID1}
    ...  target_cell_id=${NR_CELL_ID2}  target_rat=NR  source_bts_id=${NRBTS_ID}  target_bts_id=${NRBTS_ID2}


TC Teardown
    [Timeout]  30 min
    Log  \n === TC Teardown ===   console=True

    Run Keyword If  ${IS_HO_TEST_CASE}  Run Keyword And Ignore Error  Stop Data Transfer  NR_DL
    Detach UE  UE
    Run Keyword If  ${TCPDUMP_STARTED}  Stop Wireshark Log Collection  alias=tcpdump_BTS_${NRBTS_ID2}_IP_${GNB_CPLANE_IP}
    Run Keyword If  ${ATTENUATOR_SET}  Set Attenuation For All Cells  100%
    Run Keyword If  '${UE_TYPE}' == 'iphone'  Collect And Save Baseband Logs For Iphone  UE
    Run Keyword If  ${UTF_STARTED}  Run Keyword And Ignore Error  Stop UTF Traces and Download Logs
    ...  main_trace_id=${MAIN_TRACE_ID}  ho_trace_id=${HO_TRACE_ID}  source_bts_id=${NRBTS_ID}  target_bts_id=${NRBTS_ID2}
    Alarm Watchdog Teardown  ${CHECK_IN_TEARDOWN}  instance=alarms_watchdog_main
    Alarm Watchdog Teardown  ${CHECK_IN_TEARDOWN}  instance=alarms_watchdog_ho
    Multiple BTS Test Teardown
