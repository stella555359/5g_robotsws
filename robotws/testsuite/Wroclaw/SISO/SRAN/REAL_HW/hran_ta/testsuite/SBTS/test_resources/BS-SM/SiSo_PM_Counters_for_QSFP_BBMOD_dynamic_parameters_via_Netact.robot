*** Settings ***
Documentation
...  The purpose of this test case is to addres issues covered by EDA 03199873

Library  taf.nms.netact  WITH NAME  netact

Resource    ../../../../resources/hran_frame_sbts_siso.robot
Resource    ../../../../resources/ca_BSRF_general.robot


*** Variables ***
${NETACT_NAME}=  srnclab1025
${NETACT_URL}=  https://${NETACT_NAME}lbwas.srnblr.nsn-rdnet.net/authentication/Login
${NETACT_USERNAME}=  omc
${NETACT_PASSWORD}=  Medsql!_1893

*** Keywords ***

TC__SiSo_PM_Counters_for_QSFP_BBMOD_dynamic_parameters_via_Netact
  [Documentation]
  ...  The purpose of this test case is to addres issues covered by EDA 03199873
  ...  The goal of the test is to confirm that following SFP counters have meaningfull values in NetAct
  ...  M40015C8 - SBTS_SFPBM_BIASCURR_LANE_MAX
  ...  M40015C7 - SBTS_SFPBM_BIASCURR_LANE_MIN
  ...  M40015C9 - SBTS_SFPBM_BIASCURR_LANE_SUM
  ...  In particular SUM counter shouldn't be equal MIN counter
  ...
  ...  |  **Author:**      dawid.bak@nokia.com
  ...  |  **Maintainer:**  dawid.bak@nokia.com

  SiSo_PM_Counters_for_QSFP_BBMOD_dynamic_parameters_via_Netact.step1: Preconditions
  SiSo_PM_Counters_for_QSFP_BBMOD_dynamic_parameters_via_Netact.step2: Enable SFP Counters Monitoring
  SiSo_PM_Counters_for_QSFP_BBMOD_dynamic_parameters_via_Netact.step3: Disable SFP Counters Monitoring
  step4: Check NetAct Counters

step1: Preconditions
  [Documentation]
  ...  Setups main test variables and collects baisic data
  ...
  ...  |  **Author:**      dawid.bak@nokia.com
  ...  |  **Maintainer:**  dawid.bak@nokia.com

  Log To Console  ${\n}++ step1: Preconditions ++${\n}
  Set Test Variable  ${SFP_BBMOD_LANE_COUNTERS}  M40015C7,M40015C8,M40015C9
  ${bts_params}  admin.Get parameters for all  BTS  alias=${node}
  Set Test Variable  ${BTS_ID}  ${bts_params[0].btsId}
  Set Test Variable  ${SFP_OBJECT}  MRBTS-${bts_id}/MNL-1/MNLENT-1/PMMNL-1
  SiSo_PM_Counters_for_QSFP_BBMOD_dynamic_parameters_via_Netact.Check Interval  ${INTERVAL}
  ${sfps_params}  admin.Get Parameters For All  SFP  alias=${node}
  Set Test Variable  ${BBMOD_SFP_NUMBER}  ${0}
  FOR  ${sfp}  IN  @{sfps_params}
      Run Keyword If  'BBMOD' in '${sfp['id']}'
      ...  Set Test Variable  ${BBMOD_SFP_NUMBER}  ${BBMOD_SFP_NUMBER+1}
  END

  ${new_counters_path}    Check If Current Build Is Newer Than    SBTS24R2_ENB_9999_231220_000004
  Set Test Variable    ${NEW_COUNTERS_PATH}

step2: Enable SFP Counters Monitoring
  [Documentation]
  ...  Activates counter collections in SCF and initiates counter collection
  ...
  ...  |  **Author:**      dawid.bak@nokia.com
  ...  |  **Maintainer:**  dawid.bak@nokia.com

  Log To Console  ${\n}++ step2: Enable SFP Counters Monitoring ++${\n}
  Parameters Recommissioning For SFP Monitoring  ${INTERVAL}min

  ${status}  Run Keyword And Return Status  Check If All Cells Are onAir  alias=${node}
  Run Keyword If  '${status}'=='False'  Run Keywords
  ...  Parameters Recommissioning For SFP Monitoring    disabled
  ...  AND  Fail  Cells are not onAir after recommissioning! Feature deactivated and set test failed !
  ...  ELSE
  ...  Log to console  All cells are onAir !${\n}

  ${time_to_sleep}  ${time_to_verdict}  Time To Sleep  ${INTERVAL}
  Log To Console  Waiting for ${time_to_sleep} minutes to Get PM Counters ! ${\n}Verdict will be released at *${time_to_verdict}* !
  Sleep  ${time_to_sleep} minutes

  ${END_TIME}=  Get Current Date  time_zone=local
  ...  increment=0
  ...  result_format=datetime
  Set Test Variable  ${END_TIME}
  ${watch_period}=    Evaluate    ${INTERVAL}*3
  ${START_TIME}=  Subtract Time From Date  date=${END_TIME}
  ...  time=${watch_period} minutes
  ...  result_format=datetime
  Set Test Variable  ${START_TIME}

  ${sfp_bbmod_lane_counters_len}  Verify EEM Counters And Return Length  BBMOD_LANE  ${SFP_BBMOD_LANE_COUNTERS}  ${BBMOD_SFP_NUMBER}  -40  2000
  Set Test Variable  ${SFP_BBMOD_LANE_ENABLED}   ${sfp_bbmod_lane_counters_len}

step3: Disable SFP Counters Monitoring
  [Documentation]
  ...  Deactivates counter collections in SCF and verifies deactivation
  ...
  ...  |  **Author:**      dawid.bak@nokia.com
  ...  |  **Maintainer:**  dawid.bak@nokia.com

  Log To Console  ${\n}++ step3: Disable SFP Counters Monitoring ++${\n}
  Parameters Recommissioning For SFP Monitoring  disabled
  ${status}  Run Keyword And Return Status  Check If All Cells Are onAir  alias=${node}
  Run Keyword If  '${status}'=='False'
  ...  Fail  Cells are not onAir after recommissioning! Feature deactivated and set test failed !
  ...  ELSE
  ...  Log to console  All cells are onAir !${\n}

  ${time_to_sleep}  ${time_to_verdict}  Time To Sleep  ${INTERVAL}
  Log To Console  Waiting ${time_to_sleep} minutes for re-collect PM counters to check if feature was correctly deactivated !
  Log To Console  Verdict will be released at *${time_to_verdict}* !
  Sleep  ${time_to_sleep} minutes

  ${sfp_bbmod_lane_counters_len}  Verify EEM Counters And Return Length  BBMOD_LANE  ${SFP_BBMOD_LANE_COUNTERS}  ${BBMOD_SFP_NUMBER}  -40  2000
  ${bbmod_lane_verdict}  Run Keyword And Return Status  Should Be Equal  ${SFP_BBMOD_LANE_ENABLED}  ${sfp_bbmod_lane_counters_len}
  Run Keyword If
  ...  ${bbmod_lane_verdict}==True
  ...  Log To Console  Embedded Power Meter feature deactivation was successfull !
  ...  ELSE  Fail  Embedded Power Meter feature deactivation wasn't successfull !

step4: Check NetAct Counters
  [Documentation]
  ...  Calls all keywords needed to collect and process informations about counters in NetAct
  ...
  ...  |  **Author:**      dawid.bak@nokia.com
  ...  |  **Maintainer:**  dawid.bak@nokia.com

  Log To Console  ${\n}++ step4: Check NetAct Counters ++${\n}
  Connect To NetAct
  ${netact_counters_results}=  Collect Counters From NetAct
  Validate Counters From NetAct  counters=${netact_counters_results}

Connect To NetAct
  [Documentation]
  ...  Initiates NetAct connection
  ...
  ...  |  **Author:**      dawid.bak@nokia.com
  ...  |  **Maintainer:**  dawid.bak@nokia.com

  netact.Add Web URL  web_url=${NETACT_URL}
  ...  username=${NETACT_USERNAME}
  ...  password=${NETACT_PASSWORD}
  ...  alias=${NETACT_NAME}

Disconnect From NetAct
  [Documentation]
  ...  Closes NetAct connection
  ...
  ...  |  **Author:**      dawid.bak@nokia.com
  ...  |  **Maintainer:**  dawid.bak@nokia.com

  netact.Clean All  alias=${NETACT_NAME}

Collect Counters From NetAct
  [Documentation]
  ...  Gathers counters from NetAct
  ...
  ...  |  **Author:**      dawid.bak@nokia.com
  ...  |  **Maintainer:**  dawid.bak@nokia.com
  ...
  ...  **Return parameters**
  ...
  ...  +---------------+-------------------------------------------------------------------+
  ...  | Parameter     | Description                                                       |
  ...  +===============+===================================================================+
  ...  | results       | response from Get PM Counters keyword, containing counters values |
  ...  +---------------+-------------------------------------------------------------------+

  ${results}=  netact.Get PM Counters    technology=SBTS-Nokia Multi Radio Transceiver Station
  ...  measurement=SBTS SFP BBMOD LANE
  ...  counters=ALL
  ...  filter_by=MRBTS
  ...  mo_names=PLMN-PLMN/MRBTS-${BTS_ID}
  ...  object_aggregation=PLMN/MRBTS
  ...  time_aggregation=RAW
  ...  time_filter=absolute
  ...  start_time=${START_TIME}
  ...  end_time=${END_TIME}
  ...  alias=${NETACT_NAME}
  Log To Console  \n${results}
  [Return]  ${results}

Validate Counters From NetAct
  [Arguments]  ${counters}
  [Documentation]
  ...  Analyses counters gathered from NetAct.
  ...  Checks if SUM, MIN and MAX counters have meaningfull values in relation to each other
  ...
  ...  |  **Author:**      dawid.bak@nokia.com
  ...  |  **Maintainer:**  dawid.bak@nokia.com
  ...
  ...  **Input Parameters:**
  ...
  ...  +--------------+------+-------------------------------------------------------------------+
  ...  | Parameter    | Man. | Description                                                       |
  ...  +==============+======+===================================================================+
  ...  | counters     | Yes  | response from Get PM Counters keyword, containing counters values |
  ...  +--------------+------+-------------------------------------------------------------------+

  ${counters_list_length}=  Get Length  ${counters}
  Log To Console  NetAct Counters:${\n}
  Log To Console  SBTS_SFPBM_BIASCURR_LANE_MAX=${counters[-1]['SBTS_SFPBM_BIASCURR_LANE_MAX']}${\n}
  Log To Console  SBTS_SFPBM_BIASCURR_LANE_MIN=${counters[-1]['SBTS_SFPBM_BIASCURR_LANE_MIN']}${\n}
  Log To Console  SBTS_SFPBM_BIASCURR_LANE_SUM=${counters[-1]['SBTS_SFPBM_BIASCURR_LANE_SUM']}${\n}

  ${status_1}=  Evaluate  ${counters[-1]['SBTS_SFPBM_BIASCURR_LANE_SUM']} > ${counters[-1]['SBTS_SFPBM_BIASCURR_LANE_MAX']}
  ${status_2}=  Evaluate  ${counters[-1]['SBTS_SFPBM_BIASCURR_LANE_SUM']} > ${counters[-1]['SBTS_SFPBM_BIASCURR_LANE_MIN']}
  ${status_3}=  Evaluate  ${counters[-1]['SBTS_SFPBM_BIASCURR_LANE_MAX']} > ${counters[-1]['SBTS_SFPBM_BIASCURR_LANE_MIN']}

  Run Keyword If  ${status_1} and ${status_2} and ${status_3}
  ...  Log to console  All counters met conditions
  ...  ELSE  Fail  At least one counter did not met conditions

Parameters Recommissioning For SFP Monitoring
    [Arguments]  ${interval}

    admin.Create Delta
    admin.Append Parameter Update To Delta   ${SFP_OBJECT}  mtSBTSSfpRMOD  ${interval}
    admin.Append Parameter Update To Delta   ${SFP_OBJECT}  mtSbtsSfpRmodLane  ${interval}
    admin.Append Parameter Update To Delta   ${SFP_OBJECT}  mtSBTSSfpSMOD  ${interval}
    admin.Append Parameter Update To Delta   ${SFP_OBJECT}  mtSbtsSfpSmodLane  ${interval}
    admin.Append Parameter Update To Delta   ${SFP_OBJECT}  mtSBTSSfpBBMOD  ${interval}
    admin.Append Parameter Update To Delta   ${SFP_OBJECT}  mtSbtsSfpBbmodLane  ${interval}
    #coam.Append Parameter Update To Delta   ${SFP_OBJECT}  mtSbtsSfpAsirmod  ${interval}
    #coam.Append Parameter Update To Delta   ${SFP_OBJECT}  mtSbtsSfpAsirmodLane  ${interval}
    admin.Append Parameter Update To Delta   ${SFP_OBJECT}  mtSbtsSfpFhs  ${interval}
    admin.Append Parameter Update To Delta   ${SFP_OBJECT}  mtSbtsSfpFhsLane  ${interval}

    Log To Console  Updating parameters for SFP monitoring under ${SFP_OBJECT} to ${interval} ...

     ${delta}  admin.Get Delta
     admin.Perform Delta Recommissioning  ${delta}  skip_parameter_relation_errors=True  alias=${node}
     admin.Remove Delta

Check Interval
    [Arguments]  ${int}

    @{available_intervals}=  Create List  15  30  60  360  720  1440
    ${interval_status}=  Run Keyword And Return Status  List Should Contain Value  ${available_intervals}  ${int}
    Set Test Variable  ${interval_status_teardown}  ${interval_status}
    Run Keyword If  ${interval_status}==False  Fail  Given interval ${int} does't meet condition. Allowed values 15 30 60 360 720 1440.
    ...  ELSE  Log To Console  Given interval ${int} is correct.

Verify EEM Counters And Return Length
    [Arguments]  ${type}  ${counters}  ${required_counters_number}  ${min_value}  ${max_value}

    Log to console  ${\n}Verifying ${type} counters: ${counters}${\n}
    ${pm_counters_dict}  admin.Get Pm Counters  ${counters}  alias=${node}
    ${counter_dict_to_string}  Convert To String  ${pm_counters_dict}
    ${counters_list}  Split string  ${counters}  ,

    FOR  ${counter}  IN  @{counters_list}
        ${matches_count}  Evaluate  "${counter_dict_to_string}".count("${counter}")
        ${is_equal}  Run Keyword And Return Status  Should Be Equal  ${matches_count}  ${required_counters_number}
        Run Keyword If  ${is_equal}
        ...  Log To Console  Number of counter ${counter} is ${matches_count}, required ${required_counters_number} -> PASS
        ...  ELSE  Run Keywords
        ...  Log To Console  Number of counter ${counter} is ${matches_count}, required ${required_counters_number} -> FAILED
        ...  AND  Run Keyword And Continue On Failure  Fail  Wrong total number of counter ${counter} !
    END

    Run Keyword If  'RMOD' in '${type}'
    ...  Verify RMOD Counters  ${type}  ${pm_counters_dict}  ${min_value}  ${max_value}
    ...  ELSE IF  'SMOD' in '${type}'
    ...  Verify SMOD Counters  ${type}  ${pm_counters_dict}  ${min_value}  ${max_value}
    ...  ELSE IF  'BBMOD' in '${type}'
    ...  Verify BBMOD Counters  ${type}  ${pm_counters_dict}  ${min_value}  ${max_value}

    ${pm_length}  Get Length  ${counter_dict_to_string}

    [Return]  ${pm_length}

Verify RMOD Counters
    [Arguments]  ${type}  ${counters_dict}  ${min_value}  ${max_value}

    ${rmod_counters}    Set Variable If
    ...    ${NEW_COUNTERS_PATH}
    ...    ${counters_dict['BTS']['MRBTS-${BTS_ID}']['EQM-1']['APEQM-1']}
    ...    ${counters_dict['BTS']['SMOD']}

    FOR  ${sfp}  ${rmod}  IN ZIP  ${rmod_counters.keys()}  ${rmod_counters.values()}
        ${counters}  Get Dictionary Values  ${rmod}
        Run Keyword If  '${type}'=='RMOD_LANE'
        ...  Validate Counters For All Lane SFP Every  ${type}  ${counters}  ${min_value}  ${max_value}
        ...  ELSE
        ...  Validate Counters For All SFP  ${counters}  SBTS_SFP_RMOD  ${min_value}  ${max_value}
    END

Validate Counters For All Lane SFP Every
    [Arguments]  ${module}  ${list_of_dicts}  ${min_value}  ${max_value}

    FOR  ${lane}  IN  @{list_of_dicts}
        ${counters}  Get Dictionary Values  ${lane}
        Run Keyword If  'RMOD' in '${module}'
        ...  Validate Counters For All SFP  ${counters}  SBTS_SFP_${module}  ${min_value}  ${max_value}
        ...  ELSE
        ...  Validate Counters For All SFP Every  ${module}  ${counters}  ${min_value}  ${max_value}
    END

Verify BBMOD Counters
    [Arguments]  ${type}  ${counters_dict}  ${min_value}  ${max_value}

    ${bbmod_counters}    Set Variable If
    ...    ${NEW_COUNTERS_PATH}
    ...    ${counters_dict['BTS']['MRBTS-${BTS_ID}']['EQM-1']['APEQM-1']}
    ...    ${counters_dict['BTS']['SMOD']}

    FOR  ${sfp}  ${cabinet}  IN ZIP  ${bbmod_counters.keys()}  ${bbmod_counters.values()}
        ${smods}  Get Dictionary Values  ${cabinet}
        Run Keyword If  '${type}'=='BBMOD_LANE'
        ...  Validate Counters For All Lane SFP Every  ${type}  ${smods}  ${min_value}  ${max_value}
        ...  ELSE
        ...  Validate Counters For All SFP Every  ${type}  ${smods}  ${min_value}  ${max_value}
    END


Verify SMOD Counters
    [Arguments]  ${type}  ${counters_dict}  ${min_value}  ${max_value}

    ${smod_counters}    Set Variable If
    ...    ${NEW_COUNTERS_PATH}
    ...    ${counters_dict['BTS']['MRBTS-${BTS_ID}']['EQM-1']['APEQM-1']}
    ...    ${counters_dict['BTS']['SMOD']}

    FOR  ${sfp}  ${cabinet}  IN ZIP  ${smod_counters.keys()}  ${smod_counters.values()}
        ${smods}  Get Dictionary Values  ${cabinet}
        Run Keyword If  '${type}'=='SMOD_LANE'
        ...  Validate Counters For All Lane SFP Every  ${type}  ${smods}  ${min_value}  ${max_value}
        ...  ELSE
        ...  Validate Counters For All SFP Every  ${type}  ${smods}  ${min_value}  ${max_value}
    END


Validate Counters For All SFP Every
    [Arguments]  ${module}  ${list_of_dicts}  ${min_value}  ${max_value}

    FOR  ${smod}  IN  @{list_of_dicts}
        ${counters}  Get Dictionary Values  ${smod}
        Validate Counters For All SFP  ${counters}  SBTS_SFP_${module}  ${min_value}  ${max_value}
    END


Validate Counters For All SFP
    [Arguments]  ${sfp_counters_list}  ${sfp_module}  ${min_value}  ${max_value}

    FOR  ${sfp}  IN  @{sfp_counters_list}
        ${counters_dict}  Get From Dictionary  ${sfp}  ${sfp_module}
        Validate Counters  ${counters_dict}  ${sfp_module}  ${min_value}  ${max_value}
    END


Validate Counters
    [Arguments]  ${counters_dict}  ${module}  ${min_value}  ${max_value}


    Log to console  ${\n}Validating counters for ${module}${\n}
    Log to console  Every counter must be in range ${min_value} <= COUNTER_VALUE <= ${max_value}${\n}
    ${verdict_list}  Create List
    FOR  ${counter}  ${values}  IN ZIP  ${counters_dict.keys()}  ${counters_dict.values()}
        ${mV_values}  Get Dictionary Values  ${values}
        ${in_range}  Evaluate  all(float(${min_value}) <= float(x) <= float(${max_value}) for x in ${mV_values})
        Append To List  ${verdict_list}  ${in_range}
        Run Keyword If  '${in_range}'=='True'
        ...  Log to console  Validating ${counter} -> PASS
        ...  ELSE
        ...  Log to Console  Validating ${counter} -> FAIL
    END

    ${validate_status}  Run Keyword And Return Status  List Should Not Contain Value  ${verdict_list}  ${FALSE}
    Run Keyword If  '${validate_status}'=='False'  Run Keywords
    ...  Log To Console  At least one counter doesn't meet condition ${min_value} <= counter_value <= ${max_value} !${\n}
    ...  AND  Run Keyword And Continue On Failure  Fail
    ...  At least one counter doesn't meet condition ${min_value} <= counter_value <= ${max_value} !

TC Setup
  Common Test Setup

TC Teardown
  Disconnect From NetAct
  Common Test Teardown
