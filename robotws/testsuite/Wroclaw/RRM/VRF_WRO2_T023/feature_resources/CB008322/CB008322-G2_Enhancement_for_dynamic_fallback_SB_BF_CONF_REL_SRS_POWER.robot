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
${DEDICATED_ATT}                         # Value of attenuation needed to ativate SB_BF_CONF_REL_SRS_POWER, value provided as float
${ITERATIONS_NUMBER}                     # Number of expected test iteration


*** Keywords ***
TC__CB008322-G2_Enhancement_for_dynamic_fallback_SB_BF_CONF_REL_SRS_POWER
    Set Tags    CA-INTER_RAT    AUTHOR-tomasz.stawowczyk@nokia.com    OWNER-piotr.1.maj@nokia.com
    ...         MAINTAINER-tomasz.stawowczyk@nokia.com    PHASE-CRT   SW-SBTS24R2    FEATURE-CB008322   GROUP_IN_CHARGE-Pz_2_WRO_3

    Preconditions
    Step 1: Start High Data Transfer
    Looped Steps For SB_BF_CONF_REL_SRS_POWER
    Step 9: Wait Required Period And Collect RD Counters
    Step 10: Stop Data Transfer
    Step 11: Analyze SB_BF_CONF_REL_SRS_POWER Counter


Preconditions
    Log    === Start Preconditions ===    console=True
    Set Test Variable  ${SWCONFIG_CHANGED}  False
    ${nrbts_id}    Get BTS ID From ADMIN    alias=gNB
    Set Test Variable    ${NRBTS_ID}    ${nrbts_id}
    Require UE  NR_UE  capabilities=${CAPABILITY_NR_UE}
    Create Directory  ${LOG_PATH}/RD_counters
    Activate Rddlsrslogcontrol Flag In Swconfig
    Reset Site  connection=gNB
    Wait Until Keyword Succeeds  5m  1m  _Verify Bts States For Iwk Test Helper  alias=gNB
    Start Wireshark Log Collection For IWK Test    options=-i any host ${GNB_OAM_IP} and not udp port 2152 -s 0 -W 1
    ...    replace_enb=False  replace_gnb=False
    Initial Config


Step 1: Start High Data Transfer
    Log  === Step 1: Start High Data Transfer ===  console=True
    ${loop_start_time}  Get Time
    Set Test Variable  ${LOOP_START_TIME}  ${loop_start_time}
    Start Specific Data Transfer  1500


Looped Steps For SB_BF_CONF_REL_SRS_POWER
    Log  \n=== Testing SB_BF_CONF_REL_SRS_POWER In A Loop ===  console=True
    FOR  ${iteration}  IN RANGE  1  ${ITERATIONS_NUMBER}+1
        Set Test Variable  ${ITERATION}  ${iteration}
        Log  \n=== Checking SB_BF_CONF_REL_SRS_POWER iteration: ${ITERATION} ===  console=True
        Step 2: Check If Srs Power Is Above Target
        Step 3: Set Attenuation At All Phase Shifter Outputs
        Step 4: Check If Srs Power Is Below Target
        Step 5: Collect BIP Logs For below_target
        Step 6: Reduce Attenuation At All Phase Shifter Outputs
        Step 7: Check If Srs Power Is Above Target
        Step 8: Collect BIP Logs For above_target
    END


Step ${index}: Check If Srs Power Is ${level} Target
    Log  === Step ${index}: Check If Srs Power Is ${level} Target ===  console=True
    ${srs_status}  Run Keyword And Return Status  Check Srs Power In Syslog  ${level}
    Run Keyword If  not ${srs_status}
    ...  Log  === No Prints In Syslog Indicating Expected Level Of Srs Power ===  level=WARN  console=True


Step ${index}: ${action} Attenuation At All Phase Shifter Outputs
    Log  === Step ${index}: ${action} Attenuation At All Phase Shifter Outputs ===  console=True
    ${action} Attenuation At All Phase Shifter Outputs
    Check Data Transfer Is Alive  NR_DL_high


Step ${index}: Collect BIP Logs For ${srs_level}
    Log  === Step ${index}: Collect BIP Logs For ${srs_level} ===  console=True
    CB008322-G2_Enhancement_for_dynamic_fallback_keywords.Collect BIP Logs For Specific Amount Of Time  3  ${srs_level}


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
    ${sb_bf_conf_rel_list}  Create List  SB_BF_CONF_REL_SRS_POWER
    ${sb_bf_conf_rel_dict}  Get Values Of Counters From List  ${LOG_PATH}/RD_counters  ${sb_bf_conf_rel_list}
    ...  MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID}
    Set Test Variable  ${SB_BF_CONF_REL_DICT}  ${sb_bf_conf_rel_dict}


Step 10: Stop Data Transfer
    Log  === Step 10: Stop Data Transfer ===  console=True
    Stop Data Transfer  NR_DL_high


Step 11: Analyze SB_BF_CONF_REL_SRS_POWER Counter
    Log    === Step 11: Analyze SB_BF_CONF_REL_SRS_POWER Counter ===    console=True
    ${sb_bf_conf_rel_srs_power_int_list}      Evaluate  [int(x) for x in ${SB_BF_CONF_REL_DICT['SB_BF_CONF_REL_SRS_POWER']}]
    ${sum_sb_bf_conf_rel_srs_power_values}    Evaluate    sum(${sb_bf_conf_rel_srs_power_int_list})
    Should Be True  ${sum_sb_bf_conf_rel_srs_power_values} == ${ITERATION}
    ...  msg=SB_BF_CONF_REL_SRS_POWER = ${sum_sb_bf_conf_rel_srs_power_values} has value different than ${ITERATION}!
    Log    === Counter Values For SB_BF_CONF_REL_SRS_POWER Are Correct ===    console=True


Initial Config
    Log    \n=== Prepare Initial Config To SB_BF_CONF_REL_SRS_POWER Scenario ===    console=True
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
    ...  rankThreshold=1
    ...  rlqBadPercentage=50
    ...  rlqGoodPercentage=20
    ...  seHysteresis=50
    ...  seThreshold=91
    ...  sortingMetric=DL Spectral Efficiency
    ...  wbSrsConfigProhibitTimer=100
    ...  wbSrsPowerHysteresis=100
    ...  wbSrsPowerThreshold=-950
    ...  wbSrsReleaseProhibitTimer=1000

    Create Delta    delta_id=nr_power
    Append Complex Item To Delta  MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID}  srsForBeamMgmt    delta_id=nr_power
    ...  &{srsforbeammgmt}
    Append Complex Item To Delta  MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID}  srsForSubbandBm   delta_id=nr_power
    ...  &{srsforsubbandbm}
    Append Complex Item To Delta  MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID}  wbSbSrsSwitch     delta_id=nr_power
    ...  &{wbsbsrsswitch}
    ${nr_power_delta}   Get Delta   delta_id=nr_power
    Log  Delta contents:\n${nr_power_delta}  console=True
    Perform Delta Recommissioning  ${nr_power_delta}  alias=gNB
    Wait Until Keyword Succeeds  3m  1m  _Verify Bts States For Iwk Test Helper  alias=gNB
    Log    === Initial Config Set Successful ===    console=True


Check Srs Power In Syslog
    [Arguments]    ${expected_value}
    Log  === Check Srs Power In Syslog ===  console=True
    ${operator}  Set Variable If  '${expected_value}'=='Below'  <  >
    ${start_time}  Get Time From BTS
    Sleep  10s  reason=To ensure expected prints in syslog file
    ${matching_prints}  Wait For Message In Syslog File
    ...  regexp=PortPower report: rnti: [0-9]+, (-[0-9]+\.[0-9]+), (-[0-9]+\.[0-9]+), (-[0-9]+\.[0-9]+), (-[0-9]+\.[0-9]+)  timeout=10s  alias=gNB
    ${syslog_list}  Split To Lines  ${matching_prints}
    ${all_prints}  Get Length  ${syslog_list}
    Should Be True  ${all_prints} > 0  msg=There were no prints found in syslog.

    ${current_line_time}  Get Regexp Matches  ${syslog_list[-1]}
    ...  ^\\d+:([0-9]{2}\\.[0-9]{2}\\s[0-2][0-9]:[0-5][0-9]:[0-5][0-9]\\.[0-9]{6})  1
    ${current_time}  Convert Date  ${current_line_time[0]}  date_format=%d.%m %H:%M:%S.%f  result_format=%d.%m %H:%M:%S
    ${difference}  Subtract Date From Date  ${current_time}  ${start_time}
    ...  date1_format=%d.%m %H:%M:%S  date2_format=%d.%m %H:%M:%S
    Should Be True  ${difference} > 0  msg=Timestamp is not older than start time.

    ${srs_power_tuples}  Get Regexp Matches  ${syslog_list[-1]}
    ...  PortPower report: rnti: [0-9]+, (-[0-9]+\.[0-9]+), (-[0-9]+\.[0-9]+), (-[0-9]+\.[0-9]+), (-[0-9]+\.[0-9]+)
    ...  1  2  3  4
    ${srs_power_list}  Evaluate  [float(value) for tup in ${srs_power_tuples} for value in tup]
    FOR  ${value}  IN  @{srs_power_list}
        Should Be True  ${value} ${operator} -110.0  msg=SRS power exceeds target
    END
    Log  === Each Mesured Sample Of Srs Power Meets Target ===  console=True


${action} Rddlsrslogcontrol Flag In Swconfig
    ${activation}          Set Variable If  '${action}'=='Activate'  true  false
    ${swconfig_changed}    Set Variable If  '${action}'=='Activate'  True  False
    Set Test Variable  ${SWCONFIG_CHANGED}  ${swconfig_changed}
    Setup Swconfig Operations    alias=swconfig_1
    Replace Swconfig Flag Value    0x580264    16    activate=${activation}    connection=swconfig_1
    Upload Swconfig To Bts    reboot_bts=False    connection=swconfig_1
    Log  \n=== Flag Rddlsrslogcontrol ${action} In Swconfig ===  console=True
    [Teardown]  Teardown All Aliases For Swconfig Operations


TC Setup
    IWK Test Setup  local_enb_connection=False  single_bts=True  start_wireshark=False


TC Teardown
    Log    === TC Teardown ===    console=True
    Run Keyword And Ignore Error    Stop data transfers for all UEs
    Detach UE    NR_UE
    Stop Wireshark Log Collection For IWK Test
    Run Keyword If  ${SWCONFIG_CHANGED}  Run keywords  Deactivate Rddlsrslogcontrol Flag In Swconfig
    ...  AND  Reset Site  connection=gNB
    ...  AND  Wait Until Keyword Succeeds  5m  1m  _Verify Bts States For Iwk Test Helper  alias=gNB
    IWK Test Teardown  single_bts=True  local_enb_connection=False  stop_wireshark=False
