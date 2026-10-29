*** Settings ***
Documentation
...    Implementation of CB009275_Feature_Enable_with_Fault_1932_actived test case. Dedicated for RU AWKUC.
...    author: Rafal Kawa
...    contact: rafal.kawa@nokia.com

Library     taf.rfrl.bts.devices.du.commissioning.GnbCommissioning    WITH NAME      gnbscf
Library     taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME      gnbcell
Library     taf.rfrl.bts.devices.du.alarm_verification.GnbAlarmVerification    WITH NAME    gnbalarm
Library     taf.rfrl.bts.devices.ru.ru_operations.GnbRuOperations    WITH NAME      gnbru
Library     ../python/RadioOperations.py   WITH NAME    radio_keywords
Library     ../python/AlarmKeywords.py   WITH NAME    alarm_keywords


*** Keywords ***
CB009275_Feature_Enable_with_Fault_1932_actived
    [Documentation]
    ...    Test dedicated to RU AWKUC. Validates CB009275 Feature when radio alarm 1932 already exists.
    ...    ARGS:
    ...    - ru_id (int, optional): The id of radio unit based on Test Line configuration. Defaults to 0.
    ...    - fan_1_id (str, optional):  The id of RU fan to disable/enable. For AWKUC one of <0, 3>. Defaults to 0.
    ...    - fan_2_id (str, optional):  The id of RU fan to disable/enable. For AWKUC one of <0, 3> - {fan_1_id}.
    ...      Defaults to 1.
    ...    - fanDetectionPeriod (int, optional): The value of RU fans param fanDetectionPeriod loaded during test.
    ...      Defaults to 60000.
    ...    - fanTestRpmMin (int, optional): The value of RU fans param fanTestRpmMin loaded during test.
    ...      Defaults to 1300.
    ...    - default_fanDetectionPeriod (int, optional): Default value of RU fans param fanDetectionPeriod.
    ...      Defaults to 1300.
    ...    - default_fanTestRpmMin (int, optional):  Default value of RU fans param fanTestRpmMin. Defaults to 1000.
    ...    - timeout_onair (int, optional): The BTS OnAir timeout in seconds after RU reset. Defaults to 600.
    ...    - fan_detection_period_deviation (int, optional): Allowed deviation from fanDetectionPeriod time
    ...      in percentage. Defaults to 60.
    ...    - fmcadm_distname (int, optional): The dist name of FMCADM SCF object.
    ...      Defaults to. MRBTS-{}/MNL-1/MNLENT-1/FMCADM-1
    ...    - allow_fault_no_x2 (bool, optional): Flag to allow no X2 link alarms during RU reset. Defaults to True.
    ...    - delta_act_category_alarms (int, optional): List containing delta file to activate category alarms.
    ...      If None delta commissioning skipped. Defaults to None.
    ...      Example:
    ...      [{'distName': 'MRBTS-{}/MNL-1/MNLENT-1/FMCADM-1',
    ...      'operation': 'update',
    ...      'parameters': [{'operation': 'update',
    ...      'parameterName': 'actCategoryAlarms',
    ...      'value': 'true'}]}]
    [Arguments]
    ...    ${ru_id}=${0}
    ...    ${fan_1_id}=0
    ...    ${fan_2_id}=1
    ...    ${fanDetectionPeriod}=${60000}
    ...    ${fanTestRpmMin}=${1300}
    ...    ${default_fanDetectionPeriod}=${3600000}
    ...    ${default_fanTestRpmMin}=${1000}
    ...    ${timeout_onair}=${600}
    ...    ${fan_detection_period_deviation}=${60}
    ...    ${fmcadm_distname}=MRBTS-{}/MNL-1/MNLENT-1/FMCADM-1
    ...    ${allow_fault_no_x2}=${True}
    ...    ${delta_act_category_alarms}=${None}

    Set Radio Fan Failure Early Notification
    ...    fmcadm_distname=${fmcadm_distname}
    ...    value=false
    Run Keyword If    ${delta_act_category_alarms}
    ...    Activate Category Alarms
    ...    delta=${delta_act_category_alarms}
    ...    timeout=${timeout_onair}

    ${timeout_fault_trigger}=    Evaluate    int(${fanDetectionPeriod}/${1000})
    Prepare Fan Settings On Radio Unit    ru_id=${ru_id}
    ...    fanDetectionPeriod=${fanDetectionPeriod}
    ...    fanTestRpmMin=${fanTestRpmMin}
    ...    timeout_onair=${timeout_onair}
    ...    allow_fault_no_x2=${allow_fault_no_x2}
    Trigger Fault No Module Fan Detected On FAN    fan_id=${fan_1_id}
    ...    reset_ru=${True}
    ...    ru_id=${ru_id}
    ...    timeout=${timeout_fault_trigger}
    ...    timeout_deviation=${fan_detection_period_deviation}
    ...    timeout_onair=${timeout_onair}
    ...    allow_fault_no_x2=${allow_fault_no_x2}
    Trigger Fault No Module Fan Detected On FAN    fan_id=${fan_2_id}
    ...    ru_id=${ru_id}
    ...    timeout=${timeout_fault_trigger}
    ...    timeout_deviation=${fan_detection_period_deviation}
    Activate Radio Fan Failure Early Notification And Check Faults
    ...    fmcadm_distname=${fmcadm_distname}
    ...    expected_occurrences=2

    [Teardown]    Run Keywords
    ...    Cancel Fault No Module Fan Detected On FAN    fan_id=${fan_1_id}
    ...    ru_id=${ru_id}
    ...    timeout=${timeout_fault_trigger}
    ...    timeout_deviation=${fan_detection_period_deviation}
    ...    AND
    ...    Cancel Fault No Module Fan Detected On FAN    fan_id=${fan_2_id}
    ...    ru_id=${ru_id}
    ...    timeout=${timeout_fault_trigger}
    ...    timeout_deviation=${fan_detection_period_deviation}
    ...    check_fault_deactivation=${True}
    ...    AND
    ...    Prepare Fan Settings On Radio Unit    ru_id=${ru_id}
    ...    fanDetectionPeriod=${default_fanDetectionPeriod}
    ...    fanTestRpmMin=${default_fanTestRpmMin}
    ...    timeout_onair=${timeout_onair}
    ...    allow_fault_no_x2=${allow_fault_no_x2}
    ...    AND
    ...    Set Radio Fan Failure Early Notification
    ...    fmcadm_distname=${fmcadm_distname}
    ...    value=true

Prepare Fan Settings On Radio Unit
    [Arguments]
    ...    ${ru_id}
    ...    ${fanDetectionPeriod}
    ...    ${fanTestRpmMin}
    ...    ${timeout_onair}
    ...    ${allow_fault_no_x2}=${True}
    radio_keywords.execute_frmonshell_action
    ...    action_name=create
    ...    agent_type=ConfigAccess
    ...    agent_instance_path=/CI/ConfigAccess_Module
    ...    init_parameter=/module
    ...    ru_id=${ru_id}
    radio_keywords.execute_frmonshell_action
    ...    action_name=create
    ...    agent_type=FanDevice
    ...    agent_instance_path=/CI/fan1
    ...    init_parameter=/fan/1
    ...    ru_id=${ru_id}
    radio_keywords.execute_frmonshell_action
    ...    node=/CI/ConfigAccess_Module
    ...    action_name=fetch
    ...    agent_type=DECODED
    ...    agent_instance_path="fans.bin"
    ...    init_parameter="/ram/fans.json"
    ...    ru_id=${ru_id}

    radio_keywords.replace_text_on_ru_file
    ...    re_old_value="fanTestRpmMin":.*
    ...    new_value="fanTestRpmMin": ${fanTestRpmMin},
    ...    file_path=/ram/fans.json
    ...    ru_id=${ru_id}
    radio_keywords.replace_text_on_ru_file
    ...    re_old_value="fanDetectionPeriod":.*
    ...    new_value="fanDetectionPeriod": ${fanDetectionPeriod},
    ...    file_path=/ram/fans.json
    ...    ru_id=${ru_id}

    radio_keywords.execute_frmonshell_action
    ...    node=/CI/ConfigAccess_Module
    ...    action_name=store
    ...    agent_type=PERMANENT DECODED
    ...    agent_instance_path="fans.bin"
    ...    init_parameter="/ram/fans.json"
    ...    ru_id=${ru_id}
    Trigger RU Reset
    ...    ru_id=${ru_id}
    ...    timeout_onair=${timeout_onair}
    ...    allow_no_x2=${allow_fault_no_x2}

Trigger Fault No Module Fan Detected On FAN
    [Arguments]
    ...    ${fan_id}
    ...    ${ru_id}
    ...    ${timeout}
    ...    ${timeout_deviation}=40
    ...    ${expected_occurrences}=1
    ...    ${reset_ru}=${False}
    ...    ${timeout_onair}=${None}
    ...    ${allow_fault_no_x2}=${False}

    ${runtime_fan_id}=    Evaluate    int(${fan_id})+${1}
    ${timeout_with_tolerance}    Evaluate    int(${timeout})*(${1}+int(${timeout_deviation})/${100})
    gnbalarm.allow alarm    alarm=No module fan detected
    radio_keywords.set_rfsw_rad_flag
    ...    flag=0x12004${fan_id}
    ...    value=1100
    ...    options=mpw
    ...    ru_id=${ru_id}
    Run Keyword If    ${reset_ru}
    ...    Trigger RU Reset
    ...    ru_id=${ru_id}
    ...    timeout_onair=${timeout_onair}
    ...    allow_no_x2=${allow_fault_no_x2}
    Wait Until Keyword Succeeds    ${timeout_with_tolerance}s    10s    radio_keywords.verify_ru_fan_statuses
    ...    fan_id=${runtime_fan_id}
    ...    ru_id=${ru_id}
    ...    operational_state=disabled
    Wait Until Keyword Succeeds    5x    5s    gnbalarm.verify_alarm_is_active
    ...    fault_name=No module fan detected
    ...    fault_id=1932
    gnbalarm.verify_alarm_occurrences
    ...    fault_name=No module fan detected
    ...    occurrences=${expected_occurrences}
    alarm_keywords.check_fault_alarming_object
    ...    fault_name=No module fan detected
    ...    object_type=runtime
    ...    re_object_pattern=RMOD_R-\\d+$

Set Radio Fan Failure Early Notification
    [Arguments]
    ...    ${fmcadm_distname}
    ...    ${value}=true
    gnbscf.perform_parameter_recommissioning    parameter=actRadioFanFailureEarlyNotif
    ...    dist_name=${fmcadm_distname}
    ...    operation=update
    ...    value=${value}

Activate Radio Fan Failure Early Notification And Check Faults
    [Arguments]
    ...    ${fmcadm_distname}
    ...    ${expected_occurrences}=2
    Set Radio Fan Failure Early Notification
    ...    fmcadm_distname=${fmcadm_distname}
    ...    value=true
    Wait Until Keyword Succeeds    3x    5s     gnbalarm.verify_alarm_occurrences
    ...    fault_name=No module fan detected
    ...    occurrences=${expected_occurrences}
    gnbalarm.verify_alarm_is_active
    ...    fault_name=No module fan detected
    ...    fault_id=1932
    alarm_keywords.check_fault_alarming_object
    ...    fault_name=No module fan detected
    ...    object_type=runtime
    ...    re_object_pattern=FAN_R-\\d+$

Cancel Fault No Module Fan Detected On FAN
    [Arguments]
    ...    ${fan_id}
    ...    ${ru_id}
    ...    ${timeout}
    ...    ${timeout_deviation}=40
    ...    ${check_fault_deactivation}=${False}
    ${runtime_fan_id}=    Evaluate    int(${fan_id})+${1}
    ${timeout_with_tolerance}    Evaluate    int(${timeout})*(${1}+int(${timeout_deviation})/${100})
    Wait Until Keyword Succeeds    3x    10s     radio_keywords.set_rfsw_rad_flag
    ...    flag=0x12004${fan_id}
    ...    value=0
    ...    options=mpw
    ...    ru_id=${ru_id}
    Wait Until Keyword Succeeds    ${timeout_with_tolerance}s    10s    radio_keywords.verify_ru_fan_statuses
    ...    fan_id=${runtime_fan_id}
    ...    ru_id=${ru_id}
    ...    operational_state=enabled
    Run Keyword If    ${check_fault_deactivation}
    ...    gnbalarm.verify_alarm_is_not_active
    ...    fault_name=No module fan detected
    Run Keyword If    ${check_fault_deactivation}
    ...    gnbalarm.disallow_alarm    alarm=No module fan detected

Trigger RU Reset
    [Arguments]
    ...    ${ru_id}
    ...    ${timeout_onair}
    ...    ${allow_no_x2}=${True}
    ${ru_scf_id}=    Wait Until Keyword Succeeds    3x    10    radio_keywords.get_ru_configuration_id    ru_id=${ru_id}
    Run Keyword If    ${allow_no_x2}
    ...    Allow No X2 Alarms
    Wait Until Keyword Succeeds    3x    10    gnbru.reset_radio_unit    radio_unit_id=${ru_scf_id}
    gnbru.wait_for_radio_unit_to_be_online    ru_id=${ru_scf_id}
    gnbcell.wait_for_all_cells_to_be_onair    timeout=${timeout_onair}
    Disallow No X2 Alarms

Activate Category Alarms
    [Arguments]
    ...    ${delta}
    ...    ${timeout}
    gnbscf.Perform BTS Delta Commissioning    delta=${delta}
    gnbcell.wait_for_all_cells_to_be_onair    timeout=${timeout}

Allow No X2 Alarms
    gnbalarm.allow alarm    alarm=No X2 link available
    gnbalarm.allow alarm    alarm=No X2 link available for a specific LTEENB

Disallow No X2 Alarms
    gnbalarm.disallow alarm    alarm=No X2 link available
    gnbalarm.disallow alarm    alarm=No X2 link available for a specific LTEENB
