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
${PS_CONFIG_PATH}                        # Path to Phase Shifter configuration prepared for specific test
${CAPABILITY_NR_UE}                      # Capability of UE used to NR DL calls
${ITERATIONS_NUMBER}                     # Number of expected test iteration
${PHY_LAYER_CELL_ID}                     # Physical layer cell ID
${GNB_IS_TRUNK_SW}                       # Determines currently used SW is trunk or branch
${DOWNLOAD_TTI_DEC}                      # Determines downloading and installing tti_dec, True or False


*** Keywords ***
TC__CB008322-G2_Enhancement_for_dynamic_fallback_SB_BF_CONF_REL_RANK
    Set Tags    CA-INTER_RAT    AUTHOR-tomasz.stawowczyk@nokia.com    OWNER-piotr.1.maj@nokia.com
    ...         MAINTAINER-tomasz.stawowczyk@nokia.com    PHASE-CRT   SW-SBTS24R2    FEATURE-CB008322   GROUP_IN_CHARGE-Pz_2_WRO_3

    Preconditions
    Step 1: Start High Data Transfer
    Looped Steps For SB_BF_CONF_REL_RANK
    Step 9: Wait Required Period And Collect RD Counters
    Step 10: Stop Data Transfer
    Step 11: Analyze SB_BF_CONF_REL_RANK Counter


Preconditions
    Log    === Start Preconditions ===    console=True
    ${nrbts_id}    Get BTS ID From ADMIN    alias=gNB
    Set Test Variable    ${NRBTS_ID}    ${nrbts_id}
    Setup TTI Decoder
    Require UE  NR_UE  capabilities=${CAPABILITY_NR_UE}
    Create Directory  ${LOG_PATH}/RD_counters
    Initial Config
    Setup Phaseshifter


Setup Phaseshifter
    [Documentation]  Any other connection to phase shifter (even manual connection) must be terminated
    ...              before using KW Setup MCS
    Log  === Start Setting At Phase Shifter ===  console=True
    Setup MCS
    ${att_list}    parser.get_att_output_channel   ${PS_CONFIG_PATH}
    ${phase_list}   parser.get_phase_output_channel   ${PS_CONFIG_PATH}
    Create output channels lists  ${att_list}   ${phase_list}
    ${length}    Get Length    ${ATT_B1}
    Update attenuations   ${length}
    Update phases   ${length}
    Log  === Phase Shifter Is Set! ===  console=True
    [Teardown]  Teardown MCS


Step 1: Start High Data Transfer
    Log  === Step 1: Start High Data Transfer ===  console=True
    ${loop_start_time}  Get Time
    Set Test Variable  ${LOOP_START_TIME}  ${loop_start_time}
    Start Specific Data Transfer  1500


Looped Steps For SB_BF_CONF_REL_RANK
    Log  \n=== Testing SB_BF_CONF_REL_RANK In A Loop ===  console=True
    FOR  ${iteration}  IN RANGE  1  ${ITERATIONS_NUMBER}+1
        Set Test Variable  ${ITERATION}  ${iteration}
        Create Directory  ${LOG_PATH}/trace/NR_TTI_${ITERATION}
        Log  \n=== Checking SB_BF_CONF_REL_RANK iteration: ${ITERATION} ===  console=True
        Step 2: Check If RANK4 Was Reached Before_reduction
        Step 3: Set Attenuation At Two Phase Shifter Outputs
        Step 4: Check If RANK2 Was Reached With_reduced
        Step 5: Collect BIP Logs For Rank2
        Step 6: Reduce Attenuation At Two Phase Shifter Outputs
        Step 7: Check If RANK4 Was Reached After_reduction
        Step 8: Collect BIP Logs For Rank4
    END


Step ${index}: Check If ${rank} Was Reached ${phase}
    Log  \n=== Step ${index}: Check If ${rank} Was Reached ${phase} ===  console=True
    Check Reached Rank  ${rank}  ${phase}


Step ${index}: ${action} Attenuation At Two Phase Shifter Outputs
    Log    === Step ${index}: ${action} Attenuation At Two Phase Shifter Outputs ===    console=True
    ${action} Attenuation At Two Phase Shifter Outputs
    Check Data Transfer Is Alive  NR_DL_high


Step ${index}: Collect BIP Logs For ${rank}
    Log  === Step ${index}: Collect BIP Logs For ${rank} ===  console=True
    CB008322-G2_Enhancement_for_dynamic_fallback_keywords.Collect BIP Logs For Specific Amount Of Time  3  ${rank}


Step 9: Wait Required Period And Collect RD Counters
    Log    === Step 9: Wait Required Period And Collect RD Counters ===    console=True
    ${loop_end_time}  Get Time
    ${duration}  Subtract Date From Date  ${loop_end_time}  ${LOOP_START_TIME}
    ...  date1_format=%Y-%m-%d %H:%M:%S  date2_format=%Y-%m-%d %H:%M:%S
    ${number_of_periods}  Evaluate  int(${duration}//300 +1)
    ${waiting_time}    Count Measurement Period  ${GNB_OAM_IP}   5  ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}    60
    Log  === Waiting ${waiting_time} seconds till counters will be ready ===  console=true
    Sleep    ${waiting_time}s    reason=Wait till counters will be collected.
    Collect RD Counters From BTS  ${number_of_periods}
    ${sb_bf_conf_rel_list}  Create List  SB_BF_CONF_REL_RANK
    ${sb_bf_conf_rel_dict}  Get Values Of Counters From List  ${LOG_PATH}/RD_counters  ${sb_bf_conf_rel_list}
    ...  MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID}
    Set Test Variable  ${SB_BF_CONF_REL_DICT}  ${sb_bf_conf_rel_dict}


Step 10: Stop Data Transfer
    Log  === Step 10: Stop Data Transfer ===  console=True
    Stop Data Transfer  NR_DL_high


Step 11: Analyze SB_BF_CONF_REL_RANK Counter
    Log    === Step 11: Analyze SB_BF_CONF_REL Counters ===    console=True
    ${sb_bf_conf_rel_rank_int_list}      Evaluate  [int(x) for x in ${SB_BF_CONF_REL_DICT['SB_BF_CONF_REL_RANK']}]
    ${sum_sb_bf_conf_rel_rank_values}    Evaluate    sum(${sb_bf_conf_rel_rank_int_list})
    Should Be True  ${sum_sb_bf_conf_rel_rank_values} == ${ITERATION}
    ...  msg=SB_BF_CONF_REL_RANK = ${sum_sb_bf_conf_rel_rank_values} has value different than ${ITERATION}!
    Log    === Counter Values For SB_BF_CONF_REL_RANK Are Correct ===    console=True


Initial Config
    Log    \n=== Prepare Initial Config To SB_BF_CONF_REL_RANK Scenario ===    console=True
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
    ...  prbRatioHysteresis=20
    ...  prbRatioThreshold=50
    ...  prbSampleHighLowPercentage=60
    ...  rankHysteresis=1
    ...  rankThreshold=4
    ...  rlqBadPercentage=50
    ...  rlqGoodPercentage=20
    ...  seHysteresis=50
    ...  seThreshold=91
    ...  sortingMetric=DL Spectral Efficiency
    ...  wbSrsConfigProhibitTimer=100
    ...  wbSrsPowerHysteresis=20
    ...  wbSrsPowerThreshold=-1300
    ...  wbSrsReleaseProhibitTimer=1000

    Create Delta    delta_id=nr_rank
    Append Complex Item To Delta  MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID}  srsForBeamMgmt    delta_id=nr_rank
    ...  &{srsforbeammgmt}
    Append Complex Item To Delta  MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID}  srsForSubbandBm   delta_id=nr_rank
    ...  &{srsforsubbandbm}
    Append Complex Item To Delta  MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID}  wbSbSrsSwitch     delta_id=nr_rank
    ...  &{wbsbsrsswitch}
    ${nr_rank_delta}   Get Delta   delta_id=nr_rank
    Log  Delta contents:\n${nr_rank_delta}  console=True
    Perform Delta Recommissioning  ${nr_rank_delta}  alias=gNB
    Wait Until Keyword Succeeds  3m  1m  _Verify Bts States For Iwk Test Helper  alias=gNB
    Log    === Initial Config Set Successful ===    console=True


Check Reached Rank
    [Arguments]    ${expected_rank}  ${file_name}
    ${release}  Get SW Release Name  connection=gNB
    Collect NR TTI Trace General  ${PHY_LAYER_CELL_ID}  ${GNB_VM_IP}  tti_output_dir=${LOG_PATH}/trace/NR_TTI_${ITERATION}
    ...    output_filename=NR_TTI_${file_name}  release=${release}    collecting_time=2s
    ${list_of_rank_values}  Read Column Values  ${LOG_PATH}/trace/NR_TTI_${ITERATION}/NR_TTI_${file_name}_dl.csv  dlFdSchedData.numOfLayers
    ${total_amount}         Get Length              ${list_of_rank_values}
    ${specific_amount}      Count Values In List    ${list_of_rank_values}    ${expected_rank}
    ${occurence_ratio}      Evaluate  ${specific_amount} / ${total_amount}
    ${result}               Evaluate  ${occurence_ratio} == 1.0
    Should Be True  ${result}  msg=Some samples do not have ${expected_rank}.
    Log  === Reached Rank Has Expected Value ===  console=True


TC Setup
    IWK Test Setup  local_enb_connection=False  single_bts=True


TC Teardown
    Log    === TC Teardown ===    console=True
    Run Keyword And Ignore Error    Stop data transfers for all UEs
    Detach UE    NR_UE
    IWK Test Teardown  single_bts=True  local_enb_connection=False
