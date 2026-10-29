*** Settings ***
Documentation
...  contact: Szymon Startek

Library     DateTime
Library     ute_ue
Library     taf.analyzer.pmcounter
Resource    ../../resources/ca_INTER_RAT.robot
Resource    ../../resources/ca_IWK.robot


*** Variables ***
${LTE_CELL_ID}                                # ID of LTE DSS cell for which LTE4750 will be tested
${NR_CALL_CELL_ID}                            # ID of NR DSS cell used for data transfer visible on UE
${EXP_VAL_C211}                               # Expected value of counter M8029C211 dependent on configuration
${EXP_VAL_C212}                               # Expected value of counter M8029C212 dependent on configuration
${MCC}                                        # MCC used on TL for counter paths
${MNC}                                        # MNC used on TL for counter paths
${LTE_UE_ALIAS}                               # Alias of the LTE UE
${NR_UE_ALIAS}                                # Alias of the NR UE
${COUNTER_PERIOD}                             # Interval of generating PM files with the required counters (in minutes)
*** Keywords ***
TC__IWK__LTE_DL_dss_counters__LTE4750
    Set Tags    CA-INTER_RAT    AUTHOR-tomasz.stawowczyk@nokia.com    OWNER-piotr.1.maj@nokia.com
    ...         MAINTAINER-szymon.startek@nokia.com    PHASE-CRT   SW-SBTS20    FEATURE-LTE4750    GROUP_IN_CHARGE-WRO_2_Vrf

    Preconditions
    Step 1: Perform DL Data Transfers
    Step 2: Collect LTE DSS Counters
    Step 3: Check All Counters Values


Preconditions
    Log  \n*** Preconditions ***  console=True
    Set Test Variables For CB005860 Test
    Check Preconditions For CB005860 Test  8
    ${scf_path_enb}  ${parsed_scf_enb} =  Save And Parse SCF  SCF  alias=default
    Set Test Variable  ${SCF_PATH_ENB}  ${scf_path_enb}
    Set Test Variable  ${PARSED_SCF_ENB}  ${parsed_scf_enb}
    Check Element In SCF  ${PARSED_SCF_ENB}  PMCADM  PMCADM-1  /p[@name='reportingIntervalPm']
    ...  <p name="reportingIntervalPm">${COUNTER_PERIOD}min</p>  dist_name_substring=True
    Check Element In SCF  ${PARSED_SCF_ENB}  PMRNL  PMRNL-1  /p[@name='mtMAC']
    ...  <p name="mtMAC">${COUNTER_PERIOD}min</p>  dist_name_substring=True
    Log  \nCounter parameters are correct for the given counter period equal to ${COUNTER_PERIOD} minutes!  console=True
    Require UE  LTE_UE  ${LTE_UE_ALIAS}
    Require UE  NR_UE  ${NR_UE_ALIAS}
    Set Attenuation  GNB_CELL_8_1  0dB
    Set Attenuation  GNB_CELL_8_2  0dB
    Log  \nPreconditions passed!  console=True


Step 1: Perform DL Data Transfers
    Log  \n*** Step 1: Perform DL Data Transfers ***  console=True
    ${sleep_time} =  ca_IWK.Count Measurement Period    ip=${ENB_OAM_IP}    counter_period=${COUNTER_PERIOD}
    ${end_of_sleep_date} =  Get Current Date  increment=${sleep_time}s  result_format=%H:%M:%S
    Log  \nWaiting for new counters interval until ${end_of_sleep_date}  console=True
    Sleep  ${sleep_time}s  reason=Wait till new counters interval.

    Prepare UE For Data Transfer  NR_UE  ${NR_CALL_CELL_ID}    connection=gNB
    Start Data Transfer  NR_DT  NR_UE  dl  throughput=150 Mbits/sec  packet_size=1400  duration=500s  buffer=32M  protocol=udp
    Log  \n5G Data Transfer started  console=True
    Sleep  75s
    Prepare UE For Data Transfer  LTE_UE   ${LTE_CELL_ID}
    Start Data Transfer  LTE_DT   LTE_UE   dl  throughput=150 Mbits/sec  packet_size=1400  duration=300s  buffer=32M  protocol=udp
    Log  \nLTE Data Transfer started  console=True
    Sleep  75s
    Stop Datatransfer  NR_DT
    Log  \n5G Data Transfer stopped  console=True
    Sleep  75s
    Prepare UE For Data Transfer  NR_UE  ${NR_CALL_CELL_ID}    connection=gNB
    Start Data Transfer  NR_DT  NR_UE  dl  throughput=150 Mbits/sec  packet_size=1400  duration=900s  buffer=32M  protocol=udp
    Log  \n5G Data Transfer started  console=True
    Sleep  75s
    Stop Datatransfer  LTE_DT
    Log  \nLTE Data Transfer stopped  console=True


Step 2: Collect LTE DSS Counters
    Log  \n*** Step 2: Collect LTE DSS Counters ***  console=True
    ${sleep_time} =  ca_IWK.Count Measurement Period    ip=${ENB_OAM_IP}    counter_period=${COUNTER_PERIOD}    delta=120
    ${end_of_sleep_date} =  Get Current Date  increment=${sleep_time}s  result_format=%H:%M:%S
    Log  \nWaiting for counters collection until ${end_of_sleep_date}  console=True
    Sleep  ${sleep_time}s  reason=Wait till counters are collected.

    Collect PM Counters  ${LOG_PATH}/pm_counters_s  xml_files_left=2  time_interval=15 min    host=${ENB_OAM_IP}    intervals=15
    ${m8029c211} =  Get Counters Values
    ...  ${LOG_PATH}/pm_counters_s  M8029C211  MRBTS-${LNBTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-${LTE_CELL_ID}/PLMN-PLMN/MCC-${MCC}/MNC-${MNC}  5
    Set Test Variable  ${M8029C211}  ${m8029c211}
    ${m8029c212} =  Get Counters Values
    ...  ${LOG_PATH}/pm_counters_s  M8029C212  MRBTS-${LNBTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-${LTE_CELL_ID}/PLMN-PLMN/MCC-${MCC}/MNC-${MNC}  5
    Set Test Variable  ${M8029C212}  ${m8029c212}
    ${m8029c217} =  Get Counters Values
    ...  ${LOG_PATH}/pm_counters_s  M8029C217  MRBTS-${LNBTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-${LTE_CELL_ID}/PLMN-PLMN/MCC-${MCC}/MNC-${MNC}  5
    Set Test Variable  ${M8029C217}  ${m8029c217}
    ${m8029c218} =  Get Counters Values
    ...  ${LOG_PATH}/pm_counters_s  M8029C218  MRBTS-${LNBTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-${LTE_CELL_ID}/PLMN-PLMN/MCC-${MCC}/MNC-${MNC}  5
    Set Test Variable  ${M8029C218}  ${m8029c218}
    ${m8029c220} =  Get Counters Values
    ...  ${LOG_PATH}/pm_counters_s  M8029C220  MRBTS-${LNBTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-${LTE_CELL_ID}/PLMN-PLMN/MCC-${MCC}/MNC-${MNC}  5
    Set Test Variable  ${M8029C220}  ${m8029c220}
    ${m8029c221} =  Get Counters Values
    ...  ${LOG_PATH}/pm_counters_s  M8029C221  MRBTS-${LNBTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-${LTE_CELL_ID}/PLMN-PLMN/MCC-${MCC}/MNC-${MNC}  5
    Set Test Variable  ${M8029C221}  ${m8029c221}
    Log  \nCounters collected!  console=True


Get Counters Values
    [Arguments]  ${files_path}  ${counter}  ${dist_name}  ${counters_amount}=all
    ${counter_list} =  Create List  ${counter}
    ${pi_dict} =  Get PI Value
    ...  pi_list=${counter_list}
    ...  pi_dir=${files_path}
    ...  pi_file_pattern=PM*
    ${pi_dict} =  Set Variable If  '${counters_amount}'.lower() == 'all'
    ...                             ${pi_dict}
    ...                             ${pi_dict[-${counters_amount}:]}
    ${all_counters_dicts} =  Evaluate  [list(x.values())[0] for x in ${pi_dict}]
    ${counter_values} =  Evaluate  [x['${counter}']['${dist_name}'] for x in ${all_counters_dicts} if '${counter}' in x.keys()]
    Should Not Be Empty  ${counter_values}  msg=Counter was not collected
    [Return]  ${counter_values}

Step 3: Check All Counters Values
    Log  \n*** Step 3: Check All Counters Values ***  console=True
    ${c211_each} =  Evaluate  all([x == '${EXP_VAL_C211}' for x in ${M8029C211}])
    ${c212_each} =  Evaluate  all([x == '${EXP_VAL_C212}' for x in ${M8029C212}])
    ${int_M8029C217} =  Evaluate  [int(i) for i in ${M8029C217}]
    ${c217_sum} =  Evaluate  sum(${int_M8029C217})
    ${int_M8029C218} =  Evaluate  [int(i) for i in ${M8029C218}]
    ${c218_sum} =  Evaluate  sum(${int_M8029C218})
    ${int_M8029C220} =  Evaluate  [int(i) for i in ${M8029C220}]
    ${c220_sum} =  Evaluate  sum(${int_M8029C220})
    ${int_M8029C221} =  Evaluate  [int(i) for i in ${M8029C221}]
    ${c221_sum} =  Evaluate  sum(${int_M8029C221})
    Should Be True  ${c211_each}  msg=At least one of the values of counter M8029C211 is other than ${EXP_VAL_C211}
    Should Be True  ${c212_each}  msg=At least one of the values of counter M8029C212 is other than ${EXP_VAL_C212}
    Should Be True  ${c217_sum}>0  msg=None of the values of counter M8029C217 isn't greater than 0
    Should Be True  ${c218_sum}>0  msg=None of the values of counter M8029C218 isn't greater than 0
    Should Be True  ${c220_sum}>0  msg=None of the values of counter M8029C220 isn't greater than 0
    Should Be True  ${c221_sum}>0  msg=None of the values of counter M8029C221 isn't greater than 0
    Log  \nAll counters values are correct!  console=True

TC Setup
    IWK Test Setup  local_enb_connection=False

TC Teardown
    Log  \n*** Test Specific Teardown ***  console=True
    Stop Data Transfers For All Ues
    Detach UE  LTE_UE
    Detach UE  NR_UE
    Set Attenuation For All Cells  100%
    IWK Test Teardown    local_enb_connection=False
