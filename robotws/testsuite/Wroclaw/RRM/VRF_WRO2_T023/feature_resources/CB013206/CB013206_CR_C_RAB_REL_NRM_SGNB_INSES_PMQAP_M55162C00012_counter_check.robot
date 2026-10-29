*** Settings ***
Documentation
...   contact: Monika Ceglarek

Library     ta5g_ue_mobility
Resource    ../../resources/ca_INTER_RAT.robot
Resource    ../../resources/ca_IWK.robot
Resource    ../../resources/cloud_bts.robot


*** Variables ***
${NR_CELL_ID}                                   # ID of tested NR cell
${UE_ID}                                        # ID of UE from EGATE configuration file
${NAMESPACE}                                    # vDU namespace used for collecting Cplane logs
${COUNTER_PERIOD}              5                # Counter collecting interval in minutes. Default value: 5

*** Keywords ***
TC__CB013206_CR_C_RAB_REL_NRM_SGNB_INSES_PMQAP_M55162C00012_counter_check

    Set Tags    CA-RRM    AUTHOR-monika.ceglarek@nokia.com    MAINTAINER-monika.ceglarek@nokia.com
    ...         PHASE-CRT   SW-SBTS24R3    GROUP_IN_CHARGE-Pz_2_WRO_2


    Preconditions
    Step 1: Perform Data Transfer
    Step 2: Perform SgNB Release
    Step 3: Check Tcpdump
    Step 4: Collect And Analyze Counters


Preconditions
    Log  \n==== Preconditions ====  console=True

    Create Global Variables

    Save SCF VCU  vCU_SCF_after_commissioning.xml
    Save SCF VDU  vDU_SCF_after_commissioning.xml

    Verify Preconditions For CB013206 On VCU

    Wait For New Counter Period

    [Teardown]  Run Keywords  Run Keyword And Ignore Error  vcu.Disconnect
    ...  AND  Run Keyword And Ignore Error  vdu.Disconnect


Create Global Variables
    Set Test Variable  ${ATTENUATOR_SET}  False

    Get Start Time

    Get MRBTS ID From VDU
    Get MRBTS ID From VCU
    Get NRBTS ID From VDU


Verify Preconditions For CB013206 On VCU
    Connect To VCU
    Verify Value On VCU  MRBTS-${VCU_MRBTS_ID}/NRBTS-${NRBTS_ID}  actNrpmqapProfiles  true
    Verify Value On VCU  MRBTS-${VCU_MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPMRNL-1  miNrX2ccNrpmqap  ${COUNTER_PERIOD}min
    [Teardown]  vcu.Disconnect


Verify Value On VCU
    [Arguments]  ${dist_name}  ${parameter_name}  ${expected_value}

    ${parameters} =  vcu.Get Parameters  dist_name=${dist_name}
    ${parameter_data} =  Evaluate  [x for x in @{parameters['parameters']} if '${parameter_name}' in str(x)]
    Should Be True  '${parameter_data[0]['simple_parameter']['name']}' == '${parameter_name}'
    ...  msg=Parameter name (${parameter_data[0]['simple_parameter']['name']}') is different from '${parameter_name}'.
    ${current_value} =  Set Variable  ${parameter_data[0]['simple_parameter']['value']}
    Should Be True  '${current_value}' == '${expected_value}'
    ...  msg=Value for ${parameter_name} (${current_value}) on vCU is different than expected (${expected_value}).
    Log  ${parameter_name} check on vCU successful.  console=True


Step 1: Perform Data Transfer
    Log  \n==== Step 1: Perform Data Transfer ====  console=True

    Start Wireshark Log Collection For VCU  namespace=${NAMESPACE}
    Attach UE To Enb  ue_id=${UE_ID}
    Start Gnb Addition Procedure  ue=${UE_ID}  bearer=2  target_gnb=2  target_cells=${NR_CELL_ID}
    ...  dc_type=split_scg  timeout=30
    Execute EGATE Command  cmd=ue_disp
    Execute EGATE Command  cmd=trf_data_start ue=${UE_ID} id=2 dir=dl trf_id=5 mbps=100
    ...  pass_regexp=.*UE ${UE_ID}: UDP DL TRF: period_ms.+size.+rate.+
    Sleep  15s  reason=Wait for traffic to start and continue for a while.
    Execute EGATE Command  cmd=ue_stats_nr id=${UE_ID} type=pusch,pdsch scell=${NR_CELL_ID}

    [Teardown]  Run Keyword If  '${KEYWORD_STATUS}' == 'FAIL'
    ...  Run Keywords  Stop Data Transfer For Simulated UE
    ...  AND  Stop Wireshark Logs


Stop Data Transfer For Simulated UE
    Execute EGATE Command  cmd=trf_data_stop ue=${UE_ID} dir=dl trf_id=5
    ...  pass_regexp=.*Traffic was stopped for 1 bearers \\(DL traffics: 1\\).*
    Sleep  10s  reason=Wait for traffic to stop
    Detach UE  ue_id=${UE_ID}
    Execute EGATE Command  cmd=ue_disp  pass_regexp=.*Configured UEs.*


Stop Wireshark Logs
    ${tcpdump_path} =  Stop Wireshark Log Collection
    Set Test Variable  ${TCPDUMP_PATH}  ${tcpdump_path}


Step 2: Perform SgNB Release
    Log  \n==== Step 2: Perform SgNB Release ====  console=True
    Execute EGATE Command  cmd=ue_meas_cfg_disp id=${UE_ID} meas_obj_type=nr
    Execute EGATE Command  cmd=ue_measurement_send_nr id=${UE_ID} meas_id=3 event=A2 srsrp_nr=30
    ...  pass_regexp=.*Bearer-type change from SCG-split to MCG is successful.*
    Sleep    5s

    [Teardown]  Run Keywords  Stop Data Transfer For Simulated UE
    ...  AND  Stop Wireshark Logs


Step 3: Check Tcpdump
    Log  \n==== Step 3: Check Tcpdump ====  console=True

    Run Keyword And Continue On Failure  Check If Message Appeared  nr-rrc.measId == 3 && nr-rrc.measQuantityResults.rsrp == 30  1  ${TCPDUMP_PATH}
    Run Keyword And Continue On Failure  Check If Message Appeared  x2ap.radioNetwork == 31  1  ${TCPDUMP_PATH}
    Run Keyword And Continue On Failure  Check If Message Appeared  f1ap.radioNetwork == 10  1  ${TCPDUMP_PATH}
    Run Keyword And Continue On Failure  Check If Message Appeared  e1ap.dRB_Released_In_Session == 0  1  ${TCPDUMP_PATH}


Step 4: Collect And Analyze Counters
    Log  \n==== Step 4: Collect Counters ====  console=True

    ${for_last} =  Evaluate  ${COUNTER_PERIOD} * 4

    Wait For New Counter Period
    Sleep  70s  reason=Additional waiting time for counters to update.
    Connect To VCU

    ${m55162c00012} =  Get Counter List For VCU  counter_id=M55162C00012
    ...  dimension_dn=MRBTS-${VCU_MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID}/NRPMQAP-1
    ...  counter_amount=1  start_time=${START_TIME}
    Log  M55162C00012 = ${m55162c00012}  console=True

    Should Be True  ${m55162c00012[0]} == 1
    ...  msg=Value of counter M55162C00012 is different from 1.

    [Teardown]  Run Keywords
    ...  Log  Collecting counter files form vCU...  console=True
    ...  AND  Collect PM Counters  xml_files_left=2  host=${VCU_OAM_CONNECTION.addr}  user=${VCU_OAM_CONNECTION.username}
    ...  password=${VCU_OAM_CONNECTION.password}  time_interval=${for_last} min  intervals=${COUNTER_PERIOD}  bts_type=vcu


TC Setup
    Cloud BTS Test Setup  ignored_alarms_vcu=${IGNORED_ALARMS_VCU}  ignored_alarms_vdu=${IGNORED_ALARMS_VDU}


TC Teardown
    [Timeout]  60 min
    Log  \n === TC Teardown ===   console=True
    Cloud BTS Test Teardown
