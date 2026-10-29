*** Settings ***

Resource  resources/ca_BSRF_general.robot

*** Keywords ***
TC__SiSo_PM_Antenna_Path_Delay_Measurement_CPRI-A
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-20544
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...
    ...  The main goal of TC is enabling and disabling of automatic application of measured roundtrip delay (LTE3367).
    ...  It mainly checks the scenario where the RU is unable to give accurate measurements.
    ...  Values for parameters antennaPathDelayValuesUsed and antennaPathDelayDLMeasured are checked.
    ...  If the RU is unable to measure, these parameters will have the following values (expected values)
    ...  antennaPathDelayValuesUsed -> '0-configured' and antennaPathDelayDLMeasured -> 'None'
    ...  Additionally, TC checks if there are appropriate prints in the syslog proving that the RU is unable to measurements.
    ...
    ...  ***  VARIABLES ***
    ...  RMOD_SN       - RU serial number
    ...  ANTENNA_LINES - Antennas for activate useMeasuredRoundTripDelay, if more than one separate with comma e.g. "1,2"
    ...  SYSLOG_DIR    - Directory to collect syslog with messages related with LTE3367,
    ...  if hran_ta  -> UDP Logs
    ...  if robotlte -> cfg.test_logs_path
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 19.11.2020 - https://jira3.int.net.nokia.com/browse/TAT-20544 - Initial creation
    ...  - 31.05.2021 - https://jira3.int.net.nokia.com/browse/TAT-21418 - Adaptation for robotlte workspace


    Set Tags    OWNER-mateusz.kawka@nokia.com
    ...         AUTHOR-mateusz.kawka@nokia.com
    ...         MAINTAINER-mateusz.kawka@nokia.com
    ...         PHASE-CRT
  Common Test Setup
  Logging With Timestamp
  ...  message=TC__SiSo_PM_Antenna_Path_Delay_Measurement_CPRI-A will be executed
  ...  style=ONGOING
    Step1: Preconditions For APDM_CPRI-A
    Step2: Activate Antenna Path Delay Measurement
    Step3: Perform Site Reset
    Step4: Check APDM After Site Reset
    Step5: Deactivate useMeasuredRoundTripDelay
    Step6: Deactivate Antenna Path Delay Measurement
  [Teardown]    Common Test Teardown

Step1: Preconditions For APDM_CPRI-A

  Log to console  -------------------------------------
  Log to console  Step1: Preconditions For APDM_CPRI-A
  Log to console  -------------------------------------${\n}

  Run Keyword If  '${ANTENNA_LINES}'=='${EMPTY}'  Fail  Variable ANTENNA_LINES cannot be empty !
  Run Keyword If  '${RMOD_SN}'=='${EMPTY}'  Fail  Variable RMOD_SN cannot be empty !

  ${ants_list}=  Split String  ${ANTENNA_LINES}  ,
  Set Test Variable  ${ANTENNA_LINES_LIST}  ${ants_list}

  ${bts_params} =  Get parameters for all  BTS  alias=${node}
  Set Test Variable  ${BTS_ID}  ${bts_params[0].btsId}

  ${rmods}=  Get Parameters For All  RMOD  alias=${node}

  FOR  ${rmod}  IN  @{rmods}
    Continue For Loop If  '${rmod.serialNumber}'!='${RMOD_SN}'
    Set Test Variable  ${RMOD_RUNTIME_ID}  ${rmod.id}
  END

  Log to console  Checking Antenna lines mapping for Runtime !${\n}
  Get ANTL Mapping By RMOD ID  ${RMOD_RUNTIME_ID}
  FOR  ${antl_config}  ${antl_rt}  IN ZIP  ${ANT_CONF_RT_DICT.keys()}  ${ANT_CONF_RT_DICT.values()}
    Log to console  Given ANTL-${antl_config} is mapped to ANTL_R-${antl_rt} in Runtime
  END

  ${actAPD_im_obj}  admin_im.Query Infomodel
  ...  get object /MRBTS-1/RAT-1/RUNTIME_VIEW-*/MRBTS_R-*/MNL_CONF_M-1/MNLENT_CONF_M-1/FEATCADM_CONF_M-1  alias=${node}
  ${actAPD}  Set Variable  ${actAPD_im_obj.actAntennaPathDelayMeasurement}

  Run Keyword If  '${actAPD}'=='True'  Fail  actAntennaPathDelayMeasurement is activated na BTS, please deactivate before TC start !
  ...  ELSE  Log to console  ${\n}actAntennaPathDelayMeasurement is deactivated !${\n}

  Log to console  Checking if useMeasuredRoundTripDelay is set to False or deleted for given antenna lines${\n}
  ${useMRTD_list}  Create List
  FOR  ${ant}  IN   @{ANTENNA_LINES_LIST}
    ${ant_conf_runtime}  Set Variable  ${RMOD_RUNTIME_ID}/ANTL_R-${ant}/ANTL_CONF_M-1
    ${useMRTD_im}  admin_im.Query Infomodel  get object ${ant_conf_runtime}  alias=${node}
    ${useMeasuredRTD}  Set Variable  ${useMRTD_im.useMeasuredRoundTripDelay}
    Log to console  ANTL_R-${ant} --> ${useMeasuredRTD}
    Append To List  ${useMRTD_list}  ${useMeasuredRTD}
  END

  Run Keyword If  'True' in '${useMRTD_list}'  Fail  Feature is activated on given antenna line(s), check it before TC start !
  ...  ELSE  Log to console  ${\n}Preconditions are met, going to next step !${\n}


Step2: Activate Antenna Path Delay Measurement

  Log to console  ------------------------------
  Log to console  Step2: Activate Antenna Path Delay Measurement
  Log to console  ------------------------------${\n}

  Perform Delta Recommissioning For APDM  True
  ${onair_status}  Run Keyword And Return Status  Check If All Cells Are OnAir  alias=${node}
  Run Keyword If  '${onair_status}'!='True'  Run Keywords
  ...  Log to console  BTS is not onAir after recommissioning, feature will be deactivated and set test fail !${\n}
  ...  AND  Perform Delta Recommissioning For APDM  False
  ...  AND  Fail  BTS not onAir after feature activation !

  # check feature enabling date
  ${APDM_obj}  admin_im.Query Infomodel
  ...  get object /MRBTS-1/RAT-1/RUNTIME_VIEW-*/MRBTS_R-*/EQM_R-*/APEQM_R-1  alias=${node}
  ${APDM_enabling_date}  Set Variable  ${APDM_obj.antennaPathDelayMeasurementEnablingDate}
  ${date} =	Get Current Date	result_format=%Y-%m-%d
  ${status}  Run Keyword And Return Status  Should Be Equal  ${date}  ${APDM_enabling_date}
  Run Keyword If  '${status}'=='True'  Log to console  Enabling date ${APDM_enabling_date} is equal to current date !${\n}
  ...  ELSE  Run Keywords  Log to console  Enabling Date is incorrect, feature deactivating and set test failed
  ...  AND  Perform Delta Recommissioning For APDM  false
  ...  AND  Fail  Enabling Date ${APDM_enabling_date}!=${date} !

  # check ValuesUsed and DLMeasured for user ANTLs
  FOR  ${ant}  IN  @{ANTENNA_LINES_LIST}
    Log to console  Parameters values for ANTL-R-${ant}:
    ${antl_object_runtime}  Set Variable  ${RMOD_RUNTIME_ID}/ANTL_R-${ant}
    ${dn_for_runtime_ant}  admin_im.Query Infomodel  get object ${antl_object_runtime}  alias=${node}
    ${apdValuesUsed}  Set Variable  ${dn_for_runtime_ant.antennaPathDelayValuesUsed}
    ${apdDLMeasured}  Set Variable  ${dn_for_runtime_ant.antennaPathDelayDLMeasured}
    Log to console  antennaPathDelayValuesUsed -> ${apdValuesUsed}
    Log to console  antennaPathDelayDLMeasured -> ${apdDLMeasured}${\n}
    ${ValuesUsed_status}  Run Keyword And Return Status  Should be equal  Configured  ${apdValuesUsed}
    ${DLMeasured_status}  Run Keyword And Return Status  Evaluate  ${apdDLMeasured} is None
    Run Keyword If  ('${ValuesUsed_status}' and '${DLMeasured_status}')=='False'  Run Keywords
    ...  Log to console  One of parameters has wrong value, feature deactivation and set test failed !${\n}
    ...  AND  Perform Delta Recommissioning For APDM  false
    ...  AND  Fail  One of parameters has wrong value !
  END

  Log To Console  Starting SYSLOG ... !${\n}
  Start Syslog  alias=SYSLOG_FOR_APDM_STEP_2  log_dir=${SYSLOG_DIR}  log_name=SYSLOG_FOR_APDM_STEP_2  ip=192.168.255.126
  Log To Console  SYSLOG_FOR_APDM_STEP_2 was started OK !${\n}

  Log to console  Waiting for messages in SYSLOG !${\n}
  ${mes_status}  Run Keyword And Return Status
  ...  Wait For Message In Syslog File  regexp=INC POWER IS BELOW SUPPORTED FLOOR  timeout=300s  alias=SYSLOG_FOR_APDM_STEP_2
  Collect Syslog Results  alias=SYSLOG_FOR_APDM_STEP_2

  Run Keyword If  '${mes_status}'!='True'  Run Keywords
  ...  Log to console  Cannot find "INC POWER IS BELOW SUPPORTED FLOOR" in SYSLOG, feature deactivating and set test failed!${\n}
  #...  AND  Perform Delta Recommissioning For APDM  false
  ...  AND  Fail  Cannot find "INC POWER IS BELOW SUPPORTED FLOOR" in SYSLOG! TC set failed!
  ...  ELSE
  ...  Log to console  "INC POWER IS BELOW SUPPORTED FLOOR" found in SYSLOG${\n}SYSLOG_FOR_APDM_STEP_2 saved in UDP Logs, going to next step !${\n}

Step3: Perform Site Reset

  Log to console  --------------------------
  Log to console  Step3: Perform Site Reset
  Log to console  --------------------------${\n}

#  Log to console  Site Reset performing ! Please wait !${\n}
#  Reset Site  600  alias=${node}
   Log to console  RMOD unit resetting, please wait !${\n}
   Reset unit  ${RMOD_RUNTIME_ID}  Hard  timeout=240  alias=${node}

  ${restore_status}  Run Keyword And Return Status  Wait Until Keyword Succeeds  10 min  20 s  Check If All Cells Are onAir  alias=${node}
  Run Keyword If  '${restore_status}'=='True'  Log to console  BTS restored successful after Site Reset !${\n}
  ...  ELSE  Run Keywords  Log to console  BTS cannot be restored after Site Reset, feature deactivation and set test failed !${\n}
  ...  AND  Perform Delta Recommissioning For APDM  false
  ...  AND  Fail  BTS cannot be restored after Site Reset !


Step4: Check APDM After Site Reset

  Log to console  ----------------------------------
  Log to console  Step4: Check APDM After Site Reset
  Log to console  ----------------------------------${\n}

  # check ValuesUsed and DLMeasured for user ANTLs
  FOR  ${ant}  IN  @{ANTENNA_LINES_LIST}
    Log to console  Parameters values for ANTL-R-${ant}:
    ${antl_object_runtime}  Set Variable  ${RMOD_RUNTIME_ID}/ANTL_R-${ant}
    ${dn_for_runtime_ant}  admin_im.Query Infomodel  get object ${antl_object_runtime}  alias=${node}
    ${apdValuesUsed}  Set Variable  ${dn_for_runtime_ant.antennaPathDelayValuesUsed}
    ${apdDLMeasured}  Set Variable  ${dn_for_runtime_ant.antennaPathDelayDLMeasured}
    Log to console  antennaPathDelayValuesUsed -> ${apdValuesUsed}
    Log to console  antennaPathDelayDLMeasured -> ${apdDLMeasured}${\n}
    ${ValuesUsed_status}  Run Keyword And Return Status  Should be equal  Configured  ${apdValuesUsed}
    ${DLMeasured_status}  Run Keyword And Return Status  Evaluate  ${apdDLMeasured} is None
    Run Keyword If  ('${ValuesUsed_status}' and '${DLMeasured_status}')=='False'  Run Keywords
    ...  Log to console  One of parameters has wrong value, feature deactivation and set test failed !${\n}
    ...  AND  Perform Delta Recommissioning For APDM  false
    ...  AND  Fail  One of parameters has wrong value !
  END

  Log To Console  Starting SYSLOG ... !${\n}
  Start Syslog  alias=SYSLOG_FOR_APDM_STEP_4  log_dir=${SYSLOG_DIR}  log_name=SYSLOG_FOR_APDM_STEP_4  ip=192.168.255.126
  Log To Console  SYSLOG_FOR_APDM_STEP_4 was started OK !${\n}

  Log to console  Waiting for messages in SYSLOG !${\n}

  ${below_supp_status}  Run Keyword And Return Status
  ...  Wait For Message In Syslog File  regexp=INC POWER IS BELOW SUPPORTED FLOOR  timeout=300s  alias=SYSLOG_FOR_APDM_STEP_4

  Run Keyword If  '${below_supp_status}'=='True'
  ...  Log to console  "INC POWER IS BELOW SUPPORTED FLOOR" found in SYSLOG!${\n}

  ${measureddown_status}  Run Keyword And Return Status
  ...  Wait For Message In Syslog File  regexp=MEASUREDDOWN=0   timeout=610s  alias=SYSLOG_FOR_APDM_STEP_4

  Run Keyword If  '${measureddown_status}'=='True'  Log to console  "MEASUREDDOWN=0" found in SYSLOG!${\n}
  ...  ELSE  Run Keywords  Log to console  "MEASUREDDOWN=0" NOT found in SYSLOG!${\n}
  ...  AND  Fail  "MEASUREDDOWN=0" NOT found in SYSLOG!${\n}

  Run Keyword If  '${below_supp_status}'!='True'  Run Keywords
  ...  Log to console   "INC POWER IS BELOW SUPPORTED FLOOR" NOT found in SYSLOG!${\n}
  ...  AND  Fail  "INC POWER IS BELOW SUPPORTED FLOOR" NOT found in SYSLOG!${\n}

  Collect Syslog Results  alias=SYSLOG_FOR_APDM_STEP_4

  Log to console  SYSLOG_FOR_APDM_STEP_4 saved in UDP Logs${\n}Going to next step !${\n}

Step5: Deactivate useMeasuredRoundTripDelay

  Log to console  ------------------------------
  Log to console  Step5: Deactivate useMeasuredRoundTripDelay
  Log to console  ------------------------------${\n}

  ${delta_id}  Set Variable  1
  Create Delta  ${delta_id}
  Append Parameters To Delta For All Ants  ${delta_id}  False
  ${delta}  Get Delta  ${delta_id}

  Log to console  Performing delta recommissioning, please wait !
  Perform Delta Recommissioning  ${delta}  skip_parameter_relation_errors=true  alias=${node}

  Remove Delta  ${delta_id}

  ${onair_status}  Run Keyword And Return Status  Check If All Cells Are onAir  alias=${node}
  Run Keyword If  '${onair_status}'!='True'  Run Keywords
  ...  Log to console  BTS is not onAir after recommissioning, feature will be deactivated and set test fail !${\n}
  ...  AND  Perform Parameter Recommissioning  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
  ...  actAntennaPathDelayMeasurement  update  false  skip_parameter_relation_errors=true  alias=${node}
  ...  AND  Fail  BTS not onAir after feature activation !  fail_fast=True

  # check ValuesUsed and DLMeasured for user ANTLs
  FOR  ${ant}  IN  @{ANTENNA_LINES_LIST}
    Log to console  Parameters values for ANTL-R-${ant}:
    ${antl_object_runtime}  Set Variable  ${RMOD_RUNTIME_ID}/ANTL_R-${ant}
    ${dn_for_runtime_ant}  admin_im.Query Infomodel  get object ${antl_object_runtime}  alias=${node}
    ${apdValuesUsed}  Set Variable  ${dn_for_runtime_ant.antennaPathDelayValuesUsed}
    ${apdDLMeasured}  Set Variable  ${dn_for_runtime_ant.antennaPathDelayDLMeasured}
    Log to console  antennaPathDelayValuesUsed -> ${apdValuesUsed}
    Log to console  antennaPathDelayDLMeasured -> ${apdDLMeasured}${\n}
    ${ValuesUsed_status}  Run Keyword And Return Status  Should be equal  Configured  ${apdValuesUsed}
    ${DLMeasured_status}  Run Keyword And Return Status  Evaluate  ${apdDLMeasured} is None
    Run Keyword If  ('${ValuesUsed_status}' and '${DLMeasured_status}')=='False'  Run Keywords
    ...  Log to console  One of parameters has wrong value, feature deactivation and set test failed !${\n}
    ...  AND  Perform Parameter Recommissioning  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...  actAntennaPathDelayMeasurement  update  false  skip_parameter_relation_errors=true  alias=${node}
    ...  AND  Fail  One of parameters has wrong value !  fail_fast=True
  END

Step6: Deactivate Antenna Path Delay Measurement

  Log to console  ------------------------------------------------
  Log to console  Step6: Deactivate Antenna Path Delay Measurement
  Log to console  ------------------------------------------------${\n}

  Log to console  Feature deactivating, please wait!${\n}
  Perform Parameter Recommissioning  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
  ...  actAntennaPathDelayMeasurement  update  false  skip_parameter_relation_errors=true  alias=${node}

  ${onair_status}  Run Keyword And Return Status  Check If All Cells Are OnAir  alias=${node}
  Run Keyword If  '${onair_status}'!='True'  Run Keywords  Log to console  BTS is not onAir after recommissioning, set test fail !${\n}
  ...  AND  Fail  BTS not onAir after feature deactivation !

Perform Delta Recommissioning For APDM
  [Arguments]  ${flag}

  ${delta_id}  Set Variable  1
  Create Delta  ${delta_id}

  Run Keyword If  '${flag}'=='True'  Run Keywords
  ...  Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1  actAntennaPathDelayMeasurement  true  ${delta_id}
  ...  AND  Append Parameters To Delta For All Ants  ${delta_id}  True
  ...  ELSE IF  '${flag}'=='False'  Run Keywords
  ...  Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1  actAntennaPathDelayMeasurement  false  ${delta_id}
  ...  AND  Append Parameters To Delta For All Ants  ${delta_id}  False

  ${delta}  Get Delta  ${delta_id}

  Log to console  Performing delta recommissioning, please wait !
  Perform Delta Recommissioning  ${delta}  skip_parameter_relation_errors=true  alias=${node}

  Remove Delta  ${delta_id}


Append Parameters To Delta For All Ants
  [Arguments]  ${delta_id}  ${flag}

  ${rmod_id_number}  Evaluate  re.search(r'RMOD-\\d+', '${RMOD_CONFIG_ID}').group(0)  re

  FOR  ${user_antl}  IN  @{ANTENNA_LINES_LIST}
    ${runtime_antl}  Get From Dictionary  ${ANT_CONF_RT_DICT}  ${user_antl}
    Run Keyword If  '${flag}'=='True'
    ...  Append Parameter Update To Delta  MRBTS-${BTS_ID}/EQM-1/APEQM-1/${rmod_id_number}/ANTL-${runtime_antl}
    ...  useMeasuredRoundTripDelay  true  ${delta_id}
    ...  ELSE IF  '${flag}'=='False'
    ...  Append Parameter Delete To Delta  MRBTS-${BTS_ID}/EQM-1/APEQM-1/${rmod_id_number}/ANTL-${runtime_antl}
    ...  useMeasuredRoundTripDelay  ${delta_id}
  END

Get ANTL Mapping by RMOD ID
  [Documentation]  KW return all LNCELs deployed on given RMOD.
  ...  KW also returns correctly cells deployed on RMOD in chaining configuration, unlike Get Cell Mapping By Module ID
  ...  To get LNCEL, RMOD id is needed.

  [Arguments]  ${radio_id}

  ${whole_list}=  Get Cell List  alias=${node}

  ${cell_list}=  Evaluate  (${whole_list}\['cells']['lte'])

  ${ant_conf_rt_dict}  Create Dictionary
  Set Test Variable  ${ANT_CONF_RT_DICT}

  FOR  ${cell}  IN  @{cell_list}
    ${carriers_list}  Evaluate  (${cell}\['carrierList'])
    ${status}  Carrier List Iterator For APDM  ${carriers_list}  ${radio_id}
    Continue For Loop If  '${status}'=='False'
    Carrier List Iterator For TX Antenna Lines  ${carriers_list}
  END

Carrier List Iterator For TX Antenna Lines
    [Arguments]  ${carrier_list}

    FOR  ${carrier}  IN  @{carrier_list}
        ${direction}  Get From Dictionary  ${carrier}  direction
        Continue For Loop If  '${direction}'!='TX'
        ${rmod_rt_id}  Evaluate  (${carrier}\['antennaLineId']['internal'])
        ${rmod_rt_id}  Evaluate  ('${rmod_rt_id}'.rsplit('/', 1)[0])
        Continue For Loop If  '${RMOD_RUNTIME_ID}'!='${rmod_rt_id}'
        ${rmod_id}  Evaluate  (${carrier}\['antennaLineId']['configuration'])
        ${antennaline_conf}  Evaluate  (${carrier}\['antennaLineId']['configuration'][-1:])
        Continue For Loop If  '${antennaline_conf}' not in '${ANTENNA_LINES}'
        ${antennaline_int}  Evaluate  (${carrier}\['antennaLineId']['internal'][-1:])
        Set To Dictionary  ${ANT_CONF_RT_DICT}  ${antennaline_conf}  ${antennaline_int}
    END

    Set Test Variable  ${RMOD_CONFIG_ID}  ${rmod_id}
    ${rmod_id_number}  Evaluate  re.search(r'RMOD-\\d+', '${rmod_id}').group(0)  re

Carrier List Iterator For APDM
    [Arguments]  ${carrier_list}  ${radio_id}

    FOR  ${carrier}  IN  @{carrier_list}
        ${antennaline}  Get From Dictionary  ${carrier}  antennaLineId
        ${rmod_id}  Evaluate  (${antennaline}\['internal'][0:-9])
        ${status}  Set Variable If  '${rmod_id}'=='${radio_id}'  True  False
        Return From Keyword If  '${status}'=='True'  ${status}
    END

    [Return]  ${status}



