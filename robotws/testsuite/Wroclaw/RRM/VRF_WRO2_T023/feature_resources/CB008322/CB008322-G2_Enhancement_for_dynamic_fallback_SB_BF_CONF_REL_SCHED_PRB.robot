*** Settings ***
Documentation
...   contact: Oleksandr Kulieshov

Library    DateTime
Library    SSHLibrary
Library    taf.ue
Resource   ../../resources/ca_IWK.robot
Resource   testsuite/Wroclaw/RRM/VRF_WRO2_T023/feature_resources/CB008322/resources/CB008322-G2_Enhancement_for_dynamic_fallback_keywords.robot

*** Variables ***
${NR_CELL_ID}                            # ID of tested NR cell
${NR_CALL_CELL_ID}                       # NR cell ID visible at UE
${CAPABILITY_NR_UE}                      # Capability of UE used to NR DL calls
${ITERATIONS_NUMBER}                     # Number of expected test iteration


*** Keywords ***
TC__CB008322-G2_Enhancement_for_dynamic_fallback_SB_BF_CONF_REL_SCHED_PRB
    Set Tags    CA-INTER_RAT    AUTHOR-tomasz.stawowczyk@nokia.com    OWNER-piotr.1.maj@nokia.com
    ...         MAINTAINER-tomasz.stawowczyk@nokia.com    PHASE-CRT   SW-SBTS24R2    FEATURE-CB008322   GROUP_IN_CHARGE-Pz_2_WRO_3

    Preconditions
    Step 1: Start High Data Transfer
    Looped Steps For SB_BF_CONF_REL_SCHED_PRB
    Step 8: Wait Required Period And Collect RD Counters
    Step 9: Stop High Data Transfer
    Step 10: Analyze SB_BF_CONF_REL_SCHED_PRB Counter


Preconditions
    Log    === Start Preconditions ===    console=True
    ${nrbts_id}    Get BTS ID From ADMIN    alias=gNB
    Set Test Variable    ${NRBTS_ID}    ${nrbts_id}
    Require UE  NR_UE  capabilities=${CAPABILITY_NR_UE}
    Create Directory  ${LOG_PATH}/RD_counters
    Initial Config
    ${loop_start_time}  Get Time
    Set Test Variable  ${LOOP_START_TIME}  ${loop_start_time}


Step ${index}: Start ${tput_level} Data Transfer
    Log  === Step ${index}: Start ${tput_level} Data Transfer ===  console=True
    ${tput_value}  Set Variable If  '${tput_level}'=='High'  1500  300
    Start Specific Data Transfer  ${tput_value}


Step ${index}: Stop ${tput_level} Data Transfer
    Log  === Step ${index}: Stop ${tput_level} Data Transfer ===  console=True
    ${tput_name}  Set Variable If  '${tput_level}'=='High'  NR_DL_high  NR_DL_low
    Stop Data Transfer  ${tput_name}


Looped Steps For SB_BF_CONF_REL_SCHED_PRB
    Log  \n=== Testing SB_BF_CONF_REL_SCHED_PRB In A Loop ===  console=True
    FOR  ${iteration}  IN RANGE  1  ${ITERATIONS_NUMBER}+1
        Set Test Variable  ${ITERATION}  ${iteration}
        Log  \n=== Checking SB_BF_CONF_REL_SCHED_PRB iteration: ${ITERATION} ===  console=True
        Step 2: Start Low Data Transfer
        Step 3: Stop High Data Transfer
        Step 4: Collect BIP Logs For Low_DT
        Step 5: Start High Data Transfer
        Step 6: Stop Low Data Transfer
        Step 7: Collect BIP Logs For High_DT
    END


Step ${index}: Collect BIP Logs For ${tput_level}
    Log  === Step ${index}: Collect BIP Logs For ${tput_level} ===  console=True
    ${tput_name}  Set Variable If  '${tput_level}'=='High_DT'  NR_DL_high  NR_DL_low
    Check Data Transfer Is Alive  ${tput_name}
    CB008322-G2_Enhancement_for_dynamic_fallback_keywords.Collect BIP Logs For Specific Amount Of Time  3  ${tput_level}


Step 8: Wait Required Period And Collect RD Counters
    Log    === Step 8: Wait Required Period And Collect RD Counters ===    console=True
    ${loop_end_time}  Get Time
    ${duration}  Subtract Date From Date  ${loop_end_time}  ${loop_start_time}
    ...  date1_format=%Y-%m-%d %H:%M:%S  date2_format=%Y-%m-%d %H:%M:%S
    ${number_of_periods}  Evaluate  int(${duration}//300 +1)
    ${waiting_time}    Count Measurement Period  ${GNB_OAM_IP}   5  ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}    60
    Log  === Waiting ${waiting_time} seconds till counters will be ready ===  console=true
    Sleep    ${waiting_time}s    reason=Wait till counters will be collected.
    Collect RD Counters From BTS  ${number_of_periods}
    ${sb_bf_conf_rel_list}  Create List  SB_BF_CONF_REL_SCHED_PRB
    ${sb_bf_conf_rel_dict}  Get Values Of Counters From List  ${LOG_PATH}/RD_counters  ${sb_bf_conf_rel_list}
    ...  MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID}
    Set Test Variable  ${SB_BF_CONF_REL_DICT}  ${sb_bf_conf_rel_dict}


Step 10: Analyze SB_BF_CONF_REL_SCHED_PRB Counter
    Log    === Step 10: Analyze SB_BF_CONF_REL_SCHED_PRB Counter ===    console=True
    ${sb_bf_conf_rel_sched_prb_int_list}      Evaluate  [int(x) for x in ${SB_BF_CONF_REL_DICT['SB_BF_CONF_REL_SCHED_PRB']}]
    ${sum_sb_bf_conf_rel_sched_prb_values}    Evaluate    sum(${sb_bf_conf_rel_sched_prb_int_list})
    Should Be True  ${sum_sb_bf_conf_rel_sched_prb_values} == ${ITERATION}
    ...  msg=SB_BF_CONF_REL_SCHED_PRB = ${sum_sb_bf_conf_rel_sched_prb_values} has value different than ${ITERATION}!
    Log    === Counter Values For SB_BF_CONF_REL_SCHED_PRB Are Correct ===    console=True


Initial Config
    Log    \n=== Prepare Initial Config To SB_BF_CONF_REL_SCHED_PRB Scenario ===    console=True
    ${srsforbeammgmt}  Create Dictionary
    ...  bSRS=2
    ...  comb=comb4
    ...  cSRS=63
    ...  srsPowerThresholdForDlBm=-1500
    ...  srsPowerThresholdForUlBm=-1320
    ...  srsTypeAllocForDlBm=antenna switching
    ...  srsUePeriodicity=slots40
    ${srsforsubbandbm}  Create Dictionary
    ...  actHoWithSbBf=false
    ...  actTasSrsForCriticalBandCombo=false
    ...  bfSubbandSize=16 PRBs
    ...  cbcTasConflictPolicy=CBC first
    ...  combPolicy=Avoid SRS for subband BF
    ...  dynamicSrsRmMode=mode0
    ...  maxNumUeSrs=4
    ...  numOfSrsSubbandInput=1
    ...  srsPowerThreshold=-1500
    ...  srsSinrThreshold=-400
    ...  srsUePeriodicityInput=slots80
    ${wbsbsrsswitch}  Create Dictionary
    ...  channelStabilityHysteresis=10
    ...  channelStabilityThreshold=30
    ...  enableSbSrsVolatilityCheck=false
    ...  maxWbSbSwitch=10
    ...  numWbSrsConfigSample=100
    ...  numWbSrsReleaseSample=100
    ...  prbRatioHysteresis=30
    ...  prbRatioThreshold=70
    ...  prbSampleHighLowPercentage=100
    ...  rankHysteresis=1
    ...  rankThreshold=1
    ...  rlqBadPercentage=100
    ...  rlqGoodPercentage=100
    ...  seHysteresis=50
    ...  seThreshold=91
    ...  sortingMetric=DL Spectral Efficiency
    ...  wbSrsConfigProhibitTimer=100
    ...  wbSrsPowerHysteresis=20
    ...  wbSrsPowerThreshold=-1300
    ...  wbSrsReleaseProhibitTimer=1000

    Create Delta    delta_id=nr_prb
    Append Complex Item To Delta  MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID}  srsForBeamMgmt    delta_id=nr_prb
    ...  &{srsforbeammgmt}
    Append Complex Item To Delta  MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID}  srsForSubbandBm   delta_id=nr_prb
    ...  &{srsforsubbandbm}
    Append Complex Item To Delta  MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID}  wbSbSrsSwitch     delta_id=nr_prb
    ...  &{wbsbsrsswitch}
    ${nr_prb_delta}   Get Delta   delta_id=nr_prb
    Log  Delta contents:\n${nr_prb_delta}  console=True
    Perform Delta Recommissioning  ${nr_prb_delta}  alias=gNB
    Wait Until Keyword Succeeds  3m  1m  _Verify Bts States For Iwk Test Helper  alias=gNB
    Log    === Initial Config Set Successful ===    console=True


TC Setup
    IWK Test Setup  local_enb_connection=False  single_bts=True


TC Teardown
    Log    === TC Teardown ===    console=True
    Run Keyword And Ignore Error    Stop data transfers for all UEs
    Detach UE    NR_UE
    IWK Test Teardown  single_bts=True  local_enb_connection=False
