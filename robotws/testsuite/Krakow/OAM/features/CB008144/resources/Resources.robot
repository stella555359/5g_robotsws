*** Settings ***
Documentation
...   author: Marcin Szlapa
...    contact: marcin.szlapa@nokia.com
...  Resources for CB008144-5G Improved 5G sleeping cell detection

Resource   taf/rfrl/bts/robot/gnb.robot
Library    resources.py    WITH NAME    lr
Library    testsuite.Krakow.resources.alarm.Alarm
Variables  taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables  delta.py

*** Variables ***
${global_bts_id} =  ${tl.gnbs[0].global_bts_id}
@{TC_22_cells} =  MRBTS-${tl.gnbs[0].global_bts_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-1
...  MRBTS-${tl.gnbs[0].global_bts_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-2
@{additional_allowed_alarms}
...    Sleeping Cell Detection Due To Abnormal Antenna TX Power Measurements
...    Sleeping Cell Detection Due To Abnormal Antenna RX Power Measurements
...    Baseband card autonomous reset as recovery action
...    No feedback signal
...    BTS site autonomous reset as recovery action
...    Setup of X2 connectivity to gNB failed
...    NgGnbInitFullReset
...    No X2 link available
...    No X2 link available for a specific LTEENB
...    BTS Reset Cause

*** Keywords ***
CB008144-5G_1_Antenna_RX_power_sleeping_cell_detected_all_recovery_phases
    CB008144 Preconditions  prefix_tag=${NONE}
    gnb_counter.Wait for next PM period
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/MNL-1/MNLENT-1/TRBLCADM-1/SLCELLDRCONF-1
    ...  param_name=nrRxPwrSlCellDetLowPwrThr
    ...  param_value=1789
    ...  skip_parameter_relation_errors=${true}
    Wait Until Alarm Is Active On Gnb
    ...  fault_name=Sleeping Cell Detection Due To Abnormal Antenna RX Power Measurements
    ...  timeout=420
#    ${StartTime}=  Get Current Date  result_format=%M:%S
    Wait Until Alarm Is Active On Gnb
    ...  fault_name=Baseband card autonomous reset as recovery action
    ...  timeout=300
    Wait for BBMOD reset
    Wait for site to be onair
#    Wait for next PM period if needed  ${StartTime}
    gnb_counter.Wait for next PM period
    sleep  60
    Verify PM Counters Incremented Over Two Periods  ${counter_dict_9}
    Verify PM Counters Not Incremented  ${counter_dict_10}
    Wait Until Keyword Succeeds  2 min  15 sec  Verify BBMOD is up and running
    Verify gNB is onAir
    Wait Until Alarm Is Active On Gnb
    ...  fault_name=Sleeping Cell Detection Due To Abnormal Antenna RX Power Measurements
    ...  timeout=300
    Save gNB uptime
    Wait for gNB recovery action - autonomous reset
    sleep    120
    Wait for site to be onair
    Verify gNB reboot since last saved uptime
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/MNL-1/MNLENT-1/TRBLCADM-1/SLCELLDRCONF-1
    ...  param_name=nrRxPwrSlCellDetLowPwrThr
    ...  param_value=400
    ...  skip_parameter_relation_errors=${true}
    ${StartTime}=  Get Current Date  result_format=%M:%S
    Run Keyword And Expect Error
    ...  ExecutionException*Alarm*is not active*
    ...  Wait Until Alarm Is Active On Gnb
    ...  fault_name=Sleeping Cell Detection Due To Abnormal Antenna RX Power Measurement
    ...  timeout=300
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/MNL-1/MNLENT-1/FEATCADM-1
    ...  param_name=actNrAutRxPwrSlCellDetRec
    ...  param_value=false
    ...  skip_parameter_relation_errors=${true}
    Wait for next PM period if needed  ${StartTime}
    Verify One Of PM Counters Incremented  ${counter_dict_10}
    Verify PM Counters Not Incremented  ${counter_dict_9}
    Perform Delta Commissioning On gNB    ${tc_1_delta_1}
    Sleep  360
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/MNL-1/MNLENT-1/TRBLCADM-1/SLCELLDRCONF-1
    ...  param_name=nrRxPwrSlCellDetLowPwrThr
    ...  param_value=400
    ...  skip_parameter_relation_errors=${true}
    Run Keyword And Expect Error
    ...  ExecutionException*Alarm*is not active*
    ...  Wait Until Alarm Is Active On Gnb
    ...  fault_name=Sleeping Cell Detection Due To Abnormal Antenna RX Power Measurement
    ...  timeout=135
    Verify Alarm Is Not In Alarm History
    ...  Sleeping Cell Detection Due To Abnormal Antenna RX Power Measurement
    ...  ${TC_1_expected_cells_without_alarm}
    Perform Delta Commissioning On gNB    ${tc_1_delta_2}
    Perform Delta Commissioning On gNB    ${tc_1_delta_3}
    sleep  360
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/MNL-1/MNLENT-1/TRBLCADM-1/SLCELLDRCONF-1
    ...  param_name=nrRxPwrSlCellDetLowPwrThr
    ...  param_value=400
    ...  skip_parameter_relation_errors=${true}
    gnb_alarm.Stop watching alarms
    gnb_alarm.Start watching alarms    allowed_alarms=${allowed_alarms}
    Check if BBMOD did not reset  timeout=2 min
    gnb_alarm.Stop watching alarms
    Run Keyword If  ${additional_allowed_alarms}    Append To List  ${allowed_alarms}  @{additional_allowed_alarms}
    gnb_alarm.Start watching alarms    allowed_alarms=${allowed_alarms}
    Verify Alarm Is Not In Alarm History
    ...  Baseband card autonomous reset as recovery action
    ...  ${TC_1_expected_rmods_without_alarm}
    Verify PM Counters Not Incremented  ${counter_dict_11}
    gnb_counter.Wait for next PM period
    sleep  60
    Verify PM Counters Not Incremented  ${counter_dict_11}
    Wait for site to be onAir

CB008144-5G_6_Antenna_TX_power_sleeping_cell_detected_only_selected_recovery_phases
    CB008144 Preconditions
    Wait for site to be onair
    gnb_counter.Wait for next PM period
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/MNL-1/MNLENT-1/TRBLCADM-1/SLCELLDRCONF-1
    ...  param_name=nrTxPwrSlCellDetThr
    ...  param_value=500
    ...  skip_parameter_relation_errors=${true}
    Wait Until Alarm Is Active On Gnb
    ...  fault_name=Sleeping Cell Detection Due To Abnormal Antenna TX Power Measurements
    ...  timeout=600
    # alarm not expected on NRCELL-18001 due to pmax=46dBm, other cells have pmax=37dBm
    ${StartTime}=  Get Current Date  result_format=%M:%S
    Check if BBMOD did not reset  timeout=5 min
    Verify Alarm Is Active On Configuration Objects
    ...  Sleeping Cell Detection Due To Abnormal Antenna TX Power Measurements
    ...  ${TC_6_expected_cells_with_alarm}
    Verify Alarm Is Not Active On Configuration Objects
    ...  Sleeping Cell Detection Due To Abnormal Antenna TX Power Measurements
    ...  ${TC_6_not_expected_cells_with_alarm}
    Save gNB uptime
    Wait for next PM period if needed  ${StartTime}
    Verify PM Counters Incremented  ${counter_dict_3}
    Verify PM Counters Not Incremented  ${counter_dict_4}
    Wait for gNB recovery action - autonomous reset  not_pingable_timeout=20 min
    Sleep  15
    Verify gNB reboot since last saved uptime
    Wait for site to be onair
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/MNL-1/MNLENT-1/TRBLCADM-1/SLCELLDRCONF-1
    ...  param_name=nrTxPwrSlCellRecPhAct
    ...  param_value=Phase 2
    ...  skip_parameter_relation_errors=${true}
    Wait Until Alarm Is Active On Gnb
    ...  fault_name=Sleeping Cell Detection Due To Abnormal Antenna TX Power Measurements
    ...  timeout=600
    Wait Until Alarm Is Active On Gnb
    ...  fault_name=Baseband card autonomous reset as recovery action
    ...  timeout=600
    Wait for BBMOD reset
    Verify Alarm Is Active On Configuration Objects
    ...  Sleeping Cell Detection Due To Abnormal Antenna TX Power Measurements
    ...  ${TC_6_expected_cells_with_alarm}
    Verify Alarm Is Not Active On Configuration Objects
    ...  Sleeping Cell Detection Due To Abnormal Antenna TX Power Measurements
    ...  ${TC_6_not_expected_cells_with_alarm}
    Wait for site to be onair
    Wait Until Alarm Is Active On Gnb
    ...  fault_name=Sleeping Cell Detection Due To Abnormal Antenna TX Power Measurements
    ...  timeout=600
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/MNL-1/MNLENT-1/TRBLCADM-1/SLCELLDRCONF-1
    ...  param_name=nrTxPwrSlCellDetThr
    ...  param_value=0
    ...  skip_parameter_relation_errors=${true}
    ${StartTime}=  Get Current Date  result_format=%M:%S
    Wait Until Alarm Is Not Active On Gnb
    ...  fault_name=Sleeping Cell Detection Due To Abnormal Antenna TX Power Measurements
    ...  timeout=600
    Wait for next PM period if needed  ${StartTime}
    Verify PM Counters Not Incremented  ${counter_dict_5}
    Verify PM Counters Incremented  ${counter_dict_6}
    Verify One Of PM Counters Incremented Over Two Periods  ${counter_dict_7}
    Wait for site to be onAir

CB008144-5G_7_Antenna_RX_power_sleeping_cell_detected_limit_of_recovery_actions
    CB008144 5G 7 Preconditions
    Reset gNB
    Wait for site to be onair
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/MNL-1/MNLENT-1/TRBLCADM-1/SLCELLDRCONF-1
    ...  param_name=nrRxPwrSlCellDetLowPwrThr
    ...  param_value=1789
    ...  skip_parameter_relation_errors=${true}
    Wait Until Alarm Is Active On Gnb
    ...  fault_name=Sleeping Cell Detection Due To Abnormal Antenna RX Power Measurements
    ...  timeout=420
    Wait Until Alarm Is Active On Gnb
    ...  fault_name=Baseband card autonomous reset as recovery action
    ...  timeout=300
    Wait for BBMOD reset
    Wait Until Keyword Succeeds  5 min  15 sec  Verify BBMOD is up and running
    Wait for site to be onair
    Wait Until Alarm Is Active On Gnb
    ...  fault_name=Sleeping Cell Detection Due To Abnormal Antenna RX Power Measurements
    ...  timeout=600
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/MNL-1/MNLENT-1/TRBLCADM-1/SLCELLDRCONF-1
    ...  param_name=nrRxPwrSlCellDetLowPwrThr
    ...  param_value=400
    ...  skip_parameter_relation_errors=${true}
    Wait Until Alarm Is Not Active On Gnb
    ...  fault_name=Sleeping Cell Detection Due To Abnormal Antenna RX Power Measurements
    ...  timeout=420
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/MNL-1/MNLENT-1/TRBLCADM-1/SLCELLDRCONF-1
    ...  param_name=nrRxPwrSlCellDetLowPwrThr
    ...  param_value=1789
    ...  skip_parameter_relation_errors=${true}
    Wait Until Alarm Is Active On Gnb
    ...  fault_name=Sleeping Cell Detection Due To Abnormal Antenna RX Power Measurements
    ...  timeout=600
    Save gNB uptime
    Check if BBMOD did not reset
    Verify gNB reboot since last saved uptime
    Wait for site to be onair
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/MNL-1/MNLENT-1/TRBLCADM-1/SLCELLDRCONF-1
    ...  param_name=nrRxPwrSlCellRecPhAct
    ...  param_value=Phases 1 and 3
    ...  skip_parameter_relation_errors=${true}
    Wait Until Alarm Is Active On Gnb
    ...  fault_name=Sleeping Cell Detection Due To Abnormal Antenna RX Power Measurements
    ...  timeout=600
    Save gNB uptime
    Check if BBMOD did not reset
    Verify no gNB reboot since last saved uptime
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/MNL-1/MNLENT-1/TRBLCADM-1/SLCELLDRCONF-1
    ...  param_name=nrRxPwrSlCellDetLowPwrThr
    ...  param_value=400
    ...  skip_parameter_relation_errors=${true}
    Wait Until Alarm Is Not Active On Gnb
    ...  fault_name=Sleeping Cell Detection Due To Abnormal Antenna RX Power Measurements
    ...  timeout=420
    Wait for site to be onAir

CB008144-5G_22_Antenna_TX_power_sleeping_cell_is_not_detected_for_RU_TX_power_less_than_1mW_while_threshold_equals_0mW
    CB008144 Preconditions
    Save gNB uptime
    btslogcollector.Start Collecting Btslog
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/MNL-1/MNLENT-1/FEATCADM-1
    ...  param_name=actNrAutTxPwrSlCellDetRec
    ...  param_value=true
    ...  skip_parameter_relation_errors=${true}
    Check if BBMOD did not reset
    Verify Alarm Is Not Active On Configuration Objects
    ...  Sleeping Cell Detection Due To Abnormal Antenna TX Power Measurements
    ...  ${TC_22_cells}
    Verify Alarm Is Not In Alarm History
    ...  Sleeping Cell Detection Due To Abnormal Antenna TX Power Measurements
    ...  ${TC_22_cells}
    Verify no gNB reboot since last saved uptime
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/MNL-1/MNLENT-1/TRBLCADM-1/SLCELLDRCONF-1
    ...  param_name=nrTxPwrSlCellDetThr
    ...  param_value=50
    ...  skip_parameter_relation_errors=${true}
    Wait Until Alarm Is Active On Gnb
    ...  fault_name=Sleeping Cell Detection Due To Abnormal Antenna TX Power Measurements
    ...  timeout=420
    Verify Alarm Is Active On Configuration Objects
    ...  Sleeping Cell Detection Due To Abnormal Antenna TX Power Measurements
    ...  ${TC_22_cells}
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/MNL-1/MNLENT-1/TRBLCADM-1/SLCELLDRCONF-1
    ...  param_name=nrTxPwrSlCellDetThr
    ...  param_value=0
    ...  skip_parameter_relation_errors=${true}
    Wait Until Alarm Is Not Active On Gnb
    ...  fault_name=Sleeping Cell Detection Due To Abnormal Antenna TX Power Measurements
    ...  timeout=300
    btslogcollector.Stop Collecting Btslog
    Check Syslog
    ${snapshot_path}    Collect Snapshot From gNB
    Verify etpValue In Snapshot    ${snapshot_path}


CB008144 Preconditions
    [Arguments]    ${prefix_tag}=CB008144
    gnbbbu.Upload SWconfig    sw_config_path=${CURDIR}/swconfig.txt
    Perform commissioning on gNB to onAir state    prefix_tag=${prefix_tag}
    Go To State FCT


CB008144 5G 7 Preconditions
    CB008144 Preconditions
    Wait for site to be onair
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/MNL-1/MNLENT-1/TRBLCADM-1/SLCELLDRCONF-1
    ...  param_name=nrRxPwrSlCellRecPh3Tmr
    ...  param_value=130
    ...  skip_parameter_relation_errors=${true}
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/MNL-1/MNLENT-1/TRBLCADM-1/SLCELLDRCONF-1
    ...  param_name=nrRxPwrSlCellRecPhAct
    ...  param_value=Phases 1, 2 and 3
    ...  skip_parameter_relation_errors=${true}
    ${sw_release}=  Get sw release
    ${object}=  Run keyword if  '${sw_release}' == 'SBTS22R4' or '${sw_release}' == 'SBTS22R3'
    ...  set variable  TRBLCADM-1
    ...  ELSE
    ...  set variable   TRBLCADM-1/SLCELLDRCONF-1
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/MNL-1/MNLENT-1/${object}
    ...  param_name=maxNumSlCellRecActForBbuPerDay
    ...  param_value=1
    ...  skip_parameter_relation_errors=${true}
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/MNL-1/MNLENT-1/${object}
    ...  param_name=maxNumSlCellRecActForBtsPerDay
    ...  param_value=1
    ...  skip_parameter_relation_errors=${true}
    Wait for site to be onair


Check if eNB is pingable
    ${output}   Run       ping -c 1 -W 10 192.168.255.129
    Should contain      ${output}   1 packets transmitted, 1 received

Check if eNB is not pingable
    ${output}   Run       ping -c 1 -W 10 192.168.255.129
    Should contain      ${output}   1 packets transmitted, 0 received

Wait for gNB recovery action - autonomous reset
    [Arguments]    ${not_pingable_timeout}=25 min  ${pingable_timeout}=5 min
    Wait Until Keyword Succeeds  ${not_pingable_timeout}  10 sec  Check if eNB is not pingable
    Wait Until Keyword Succeeds  ${pingable_timeout}  10 sec  Check if eNB is pingable

Wait for BBMOD reset
    ${output}=  Run Keyword And Ignore Error  wait until keyword succeeds    30    2
    ...  Verify BBMOD Statuses
    ...  disabled  not initialized  offline  unlocked
    log to console   ${output}
    ${contains}=    Run Keyword And Return Status    Should Contain    ${output}[1]  initializing
    Run keyword if  '${output}[0]' != 'PASS' and ${contains} == True
    ...  Log       BBMOD proceduralStatus: initializing.    WARN
    ...  ELSE IF  '${output}[0]' != 'PASS' and ${contains} == False
    ...  Fail      ${output}[1]

Verify BBMOD is up and running
    Verify BBMOD Statuses
    ...  enabled  configured  online  unlocked

Check if BBMOD did not reset
    [Arguments]    ${timeout}=10 min
    ${status}=    run keyword and return status
    ...   wait until keyword succeeds    ${timeout}  5 sec    Verify BBMOD Statuses
    ...   operational_state=disabled    procedural_status=not initialized    availability_status=offline    administrative_state=unlocked
    Run keyword if  ${status} == True
    ...  Verify gNB reboot since last saved uptime

Verify gNB reboot since last saved uptime
    Run Keyword And Expect Error  STARTS:UnexpectedBtsResetOccurred
    ...  Verify no gNB reboot since last saved uptime

Wait for next PM period if needed
    [Arguments]    ${StartTime}
    ${EndTime}=  Get Current Date  result_format=%M:%S
    ${time} = 	 Subtract Time From Time 	${EndTime}  ${StartTime}
    ${status} =  check_time_for_counter_change  interval=${15}  elapsed_time=${time}  start_time=${StartTime}
    Run Keyword If  '${status}'=='${True}'  gnb_counter.Wait for next PM period
    sleep  40
