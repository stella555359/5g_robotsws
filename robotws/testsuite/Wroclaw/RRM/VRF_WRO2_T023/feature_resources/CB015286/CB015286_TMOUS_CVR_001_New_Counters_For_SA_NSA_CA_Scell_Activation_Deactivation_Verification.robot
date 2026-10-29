*** Settings ***
Documentation
...   contact: Igor Kleschenok

Library    ute_ue
Library    ute_tshark
Library    taf.config.scf
Library    taf.analyzer.pmcounter
Library    taf.collectors.core  WITH NAME  core
Library    taf.sbts.oam.coam.admin  WITH NAME  admin
Library    ta5g_pm_counters
Library    ute_fsmaccess
Resource   ../../resources/ca_IWK.robot
Resource   ../../resources/ca_INTER_RAT.robot
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T023/feature_resources/CB015286/resources/check_tti_parameters_values.py


*** Variables ***
${NR_CELL_SA}                   # NR SA global cell ID
${CELL_ID_FOR_CALL}             # ID of cell to which UE should attach during the test
${TYPE_UE_MODE}                 # Type of UE mode(SA or NSA)
${UE_CAPABILITY}                # UE capability
${LTE_CELL}                     # Boolean variable for keyword 'Prepare UE For Data Transfer'
${EVENT_DECODER_OPT}            # Additional options for the eventdecoder call
${COUNTER_1}                    # ID of first counter
${COUNTER_2}                    # ID of second counter
${COUNTER_3}                    # ID of third counter
${COUNTER_4}                    # ID of fourth counter


*** Keywords ***
TC__CB015286_TMOUS_CVR_001_New_Counters_For_SA_NSA_CA_Scell_Activation_Deactivation_Verification
    Set Tags    CA-INTER_RAT    AUTHOR-igor.kleschenok@nokia.com    OWNER-piotr.smolak@nokia.com
    ...  MAINTAINER-igor.kleschenok@nokia.com    PHASE-CRT   SW-SBTS26R1    FEATURE-CB015286    GROUP_IN_CHARGE-WRO_2_Vrf

    Preconditions
    Step 1: Start DL Traffic For UE
    Step 2: Stop Traffic And Release UE
    Step 3: Verify CA SCell Activation and Deactivation
    Step 4: Verify Pm Counters


Preconditions
    Log  \n==== Preconditions ====  console=True

    ${sbts_id} =  Get BTS ID From ADMIN  alias=gNB
    Set Test Variable  ${SBTS_ID}  ${sbts_id}

    ${nrbts_id} =  Get NRBTS ID  connection=gNB
    Set Test Variable  ${NRBTS_ID}  ${nrbts_id}

    Require Ue  ${TYPE_UE_MODE}  ${UE_CAPABILITY}
    Log  = Preconditions passed =  console=True


Step 1: Start DL Traffic For UE
    Log  \n==== Step 1: Start DL Traffic For UE ====  console=True

    ${waiting_time} =  ca_IWK.Count Measurement Period  ${GNB_OAM_IP}  5  delta=60
    Log To Console  Wait ${waiting_time}s till new period of counters is started
    Sleep  ${waiting_time}s  reason=Wait till new period of counter is started

    ${cells_list}  Create List  ${NR_CELL_SA}
    Setup TTI Decoder
    Start Collecting TTI Trace  ${cells_list}  ${GNB_VM_IP}  release=${RELEASE_LOCAL}
    Log  Start NR DL data transfer in cell NR-${NR_CELL_SA} on UE.  console=True
    Prepare UE For Data Transfer  ${TYPE_UE_MODE}  ${CELL_ID_FOR_CALL}  connection=gNB  lte_cell=${LTE_CELL}
    Start Data Transfer  DT_DL  ${TYPE_UE_MODE}  dl  protocol=tcp  packet_size=1400  duration=60s  buffer=32M
    Sleep  5  reason=Wait for stabilize traffic


Step 2: Stop Traffic And Release UE
    Log  \n=== Step 2: Stop Traffic And Release UE ===  console=True

    Stop Data Transfer  DT_DL
    Sleep  5  reason=Waiting for messages to be collected
    Detach Ue  ${TYPE_UE_MODE}  timeout=40
    Stop Collecting TTI Trace  tti_output_dir=${LOG_PATH}/trace  eventdecoder_options=${EVENT_DECODER_OPT}


Step 3: Verify CA SCell Activation and Deactivation
    Log  ==== Step 3: Verify CA SCell Activation and Deactivation ====  console=True

    ${path_exist}  Run Keyword And Return Status  OperatingSystem.File Should Exist  ${LOG_PATH}/trace/tcpdump_dl.csv
    ${logs_path} =  Set Variable If  ${path_exist}  ${LOG_PATH}/trace/tcpdump_dl.csv  ${LOG_PATH}/trace/tcpdump_dl.0.csv
    ${get_dict_length}  Check TTI Parameters Values  ${logs_path}  ${TYPE_UE_MODE}
    Should Be Equal As Integers  ${get_dict_length}  2    msg=Messages are missed or more than two


Step 4: Verify Pm Counters
    Log  \n=== Step 4: Verify Pm Counters ===  console=True

    ${waiting_time} =  Count Measurement Period  ${GNB_OAM_IP}  5  delta=60
    Log To Console  Wait ${waiting_time}s till new period of counters is started
    Sleep  ${waiting_time}s  reason=Wait till new period of counter is started.

    Wait Until Keyword Succeeds  5x  10s  Collect PM Counters  ${LOG_PATH}/pm_counters  host=${GNB_OAM_IP}
    ...                                                                    time_interval=5 min  intervals=5
    ${counter_list}   Create List  ${COUNTER_1}  ${COUNTER_2}  ${COUNTER_3}  ${COUNTER_4}
    ${counters_dict}  Get Values Of Counters From List  ${LOG_PATH}/pm_counters  ${counter_list}
    ...               MRBTS-${SBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_SA}  1

    Should Be Equal  ${counters_dict['${COUNTER_3}'][0]}  1
    ...  msg=The value of counter ${COUNTER_3} isn't in given range value
    Should Be True  ${counters_dict['${COUNTER_1}'][0]} >= 1
    ...  msg=The value of counter ${COUNTER_1} isn't in given range value
    Should Be Equal  ${counters_dict['${COUNTER_4}'][0]}  1
    ...  msg=The value of counter ${COUNTER_4} isn't in given range value
    Should Be True  ${counters_dict['${COUNTER_2}'][0]} >= 1
    ...  msg=The value of counter ${COUNTER_2} isn't in given range value


TC Setup
    Log  \n=== TC Setup ===  console=True

    Set Test Variable  ${EVENT_DECODER_OPT}  --split 200000 --include ${CURDIR}${/}resources${/}Included_TTI_Events_List.txt
    IWK Test Setup  local_enb_connection=False  single_bts=True


TC Teardown
    Log  \n=== TC Teardown ===  console=True

    Run Keyword And Ignore Error  Stop Data Transfers For All Ues
    Detach Ue  ${TYPE_UE_MODE}
    IWK Test Teardown  local_enb_connection=False  single_bts=True
