*** Settings ***
Documentation
...   Keywords for regression testing of feature CB009226
...   author: Mateusz Bugaj
...   contact: mateusz.bugaj@nokia.com

Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     taf/rfrl/bts/robot/gnb.robot

Library      taf.rfrl.procedures.resources.python.common_allowed_alarms                     WITH NAME    alarm
Library      taf.rfrl.utilities.logger.custom_logger                                        WITH NAME    logger
Library      ute_syslog                                                                     WITH NAME    syslog
Library      ./resources.py                                                                 WITH NAME    local_resources


*** Keywords ***
Verify SFP Data
    [Arguments]     ${expected_items_sfp}
    local_resources.verify sfp data from bts        expected_items_sfp=${expected_items_sfp}

Verify Temperature Data
    [Arguments]     ${rfsw_credentials}
    Set Test Variable   ${rfsw_credentials}   ${rfsw_credentials}
    local_resources.read temperature data from ru

Prepare RU link order
    [Arguments]     ${rfsw_credentials}
    Set Test Variable   ${rfsw_credentials}   ${rfsw_credentials}
    logger.log_info_to_console      Checking Link Order
    local_resources.Create SFP Info Agent
    ${res} =    local_resources.is link swap needed
    WHILE    ${res}
        Run Keyword And Expect Error            CommandTimeout*     local_resources.SFP override gpio
        ...                                     port_id_on_ru=2      action=TX_FAULT     fault=true
        BuiltIn.Sleep       60s
        local_resources.SFP override gpio       port_id_on_ru=2      action=TX_FAULT     fault=false
        Wait Until Keyword Succeeds             900 sec     30 sec      gnbcell.Verify All Cells Are Onair

        ${res} =    local_resources.is link swap needed
    END
    local_resources.Terminate SFP Info Agent

Trigger Faults On Secondary Link
    [Arguments]     ${rfsw_credentials}     ${alarms_on_ru}     ${port_id_on_ru}=2
    ...             ${log_dir}=${OUTPUT_DIR}        ${log_name}=syslog_BTSSM.log
    Set Test Variable   ${rfsw_credentials}   ${rfsw_credentials}
    logger.log_info_to_console      Triggering Faults On Secondary Link
    local_resources.Create SFP Info Agent

    syslog.Start Syslog     log_dir=${log_dir}       log_name=${log_name}
    local_resources.SFP override gpio       port_id_on_ru=${port_id_on_ru}      action=TX_FAULT     fault=true
    Wait Until Keyword Succeeds             5x          10s     local_resources.verify_if_alarm_is_visible_on_ru
    ...                                     expected_alarms=${alarms_on_ru}[Step2]
    syslog.Collect Syslog Results
    syslog.teardown_all_aliases_for_syslog
    local_resources.verify_if_alarm_is_visible_in_log       log_file_path=${log_dir}/${log_name}
    ...                                                     alarm_ids=${syslog_alarms}[Step2]
    Wait Until Keyword Succeeds             150 sec     10 sec       Verify Alarm is Active on gNB
    ...                                     fault_name=Unit synchronization failed      fault_id=16

    syslog.Start Syslog     log_dir=${log_dir}       log_name=${log_name}
    local_resources.SFP override gpio       port_id_on_ru=${port_id_on_ru}      action=TX_FAULT     fault=false
    BuiltIn.Sleep       10s
    Wait Until Keyword Succeeds             5x          10s     local_resources.verify_if_alarm_is_visible_on_ru
    ...                                     expected_alarms=${alarms_on_ru}[Step3]
    local_resources.verify_if_alarm_is_not_visible_in_log       log_file_path=${log_dir}/${log_name}
    ...                                                     alarm_ids=${syslog_alarms}[Step3]
    syslog.teardown_all_aliases_for_syslog
    Wait Until Keyword Succeeds             150 sec     10 sec       Verify Alarm is not Active on gNB
    ...                                     fault_name=Unit synchronization failed      fault_id=16

    syslog.Start Syslog     log_dir=${log_dir}       log_name=${log_name}
    local_resources.SFP override gpio       port_id_on_ru=${port_id_on_ru}      action=SIGNAL_LOSS     fault=true
    BuiltIn.Sleep       10s
    Wait Until Keyword Succeeds             5x          10s     local_resources.verify_if_alarm_is_visible_on_ru
    ...                                     expected_alarms=${alarms_on_ru}[Step4]
    BuiltIn.Sleep       80s
    local_resources.verify_if_alarm_is_visible_in_log       log_file_path=${log_dir}/${log_name}
    ...                                                     alarm_ids=${syslog_alarms}[Step4]
    syslog.teardown_all_aliases_for_syslog
    Wait Until Keyword Succeeds             150 sec     10 sec       Verify Alarm is Active on gNB
    ...                                     fault_name=Unit synchronization failed      fault_id=16

    syslog.Start Syslog     log_dir=${log_dir}       log_name=${log_name}
    local_resources.SFP override gpio       port_id_on_ru=${port_id_on_ru}      action=SIGNAL_LOSS     fault=false
    BuiltIn.Sleep       10s
    Wait Until Keyword Succeeds             5x          10s     local_resources.verify_if_alarm_is_visible_on_ru
    ...                                     expected_alarms=${alarms_on_ru}[Step5]
    local_resources.verify_if_alarm_is_not_visible_in_log       log_file_path=${log_dir}/${log_name}
    ...                                                     alarm_ids=${syslog_alarms}[Step5]
    syslog.teardown_all_aliases_for_syslog
    Wait Until Keyword Succeeds             150 sec     10 sec       Verify Alarm is not Active on gNB
    ...                                     fault_name=Unit synchronization failed      fault_id=16
    Wait Until Keyword Succeeds             900 sec     30 sec      gnbcell.Verify All Cells Are Onair
    local_resources.Terminate SFP Info Agent

Trigger Faults On Primary Link
    [Arguments]     ${rfsw_credentials}     ${port_id_on_ru}=1
    ...             ${log_dir}=${OUTPUT_DIR}        ${log_name}=syslog_BTSSM.log
    Set Test Variable   ${rfsw_credentials}   ${rfsw_credentials}
    logger.log_info_to_console      Triggering Faults On Primary Link
    local_resources.Create SFP Info Agent
    syslog.Start Syslog     log_dir=${log_dir}       log_name=${log_name}
    Run Keyword And Expect Error            CommandTimeout*     local_resources.SFP override gpio
    ...                                     port_id_on_ru=${port_id_on_ru}      action=TX_FAULT     fault=true
    BuiltIn.Sleep       10s
    Wait Until Keyword Succeeds             15x          10s     local_resources.verify_if_alarm_is_visible_on_ru
    ...                                     expected_alarms=${alarms_on_ru}[Step6]
    local_resources.verify_if_alarm_is_not_visible_in_log       log_file_path=${log_dir}/${log_name}
    ...                                                     alarm_ids=${syslog_alarms}[Step6]
    syslog.teardown_all_aliases_for_syslog
    Wait Until Keyword Succeeds             150 sec     10 sec       Verify Alarm is Active on gNB
    ...                                     fault_name=No connection to unit     fault_id=10
    Wait Until Keyword Succeeds             900 sec     30 sec       Verify Alarm is not Active on gNB
    ...                                     fault_name=No connection to unit      fault_id=10
    Wait Until Keyword Succeeds             900 sec     30 sec      gnbcell.Verify All Cells Are Onair
    local_resources.Create SFP Info Agent       initial_state=RU
    syslog.Start Syslog     log_dir=${log_dir}       log_name=${log_name}

# After first fault on primiary link, secondary becomes primiary and vice versa
    local_resources.SFP override gpio       port_id_on_ru=${port_id_on_ru}      action=SIGNAL_LOSS     fault=true
    BuiltIn.Sleep       10s
    Wait Until Keyword Succeeds             5x          10s     local_resources.verify_if_alarm_is_visible_on_ru
    ...                                     expected_alarms=${alarms_on_ru}[Step4a]
    BuiltIn.Sleep       80s
    local_resources.verify_if_alarm_is_visible_in_log       log_file_path=${log_dir}/${log_name}
    ...                                                     alarm_ids=${syslog_alarms}[Step4a]
    syslog.teardown_all_aliases_for_syslog

    syslog.Start Syslog     log_dir=${log_dir}       log_name=${log_name}
    local_resources.SFP override gpio       port_id_on_ru=${port_id_on_ru}      action=SIGNAL_LOSS     fault=false
    BuiltIn.Sleep       10s
    Wait Until Keyword Succeeds             5x          10s     local_resources.verify_if_alarm_is_visible_on_ru
    ...                                     expected_alarms=${alarms_on_ru}[Step5a]
    local_resources.verify_if_alarm_is_not_visible_in_log       log_file_path=${log_dir}/${log_name}
    ...                                                     alarm_ids=${syslog_alarms}[Step5a]
    syslog.teardown_all_aliases_for_syslog
    Wait Until Keyword Succeeds             900 sec     10 sec       Verify Alarm is not Active on gNB
    ...                                     fault_name=Unstable eCPRI Link Detected      fault_id=4741
    Wait Until Keyword Succeeds             900 sec     30 sec      gnbcell.Verify All Cells Are Onair
    local_resources.Terminate SFP Info Agent

Trigger Faults With Temperature
    [Arguments]     ${rfsw_credentials}     ${monitoring_params}        ${port_id_on_ru}=1
    Set Test Variable   ${rfsw_credentials}   ${rfsw_credentials}
    logger.log_info_to_console      Triggering Faults With SFP Temperature for port num: ${port_id_on_ru}
    local_resources.perform_recommisioning_on_bts       monitoring_params=${monitoring_params}
    ...                                                 param_value=Transceiver alarms
    local_resources.Create SFP Info Agent

    local_resources.SFP Override Memory     port_id_on_ru=${port_id_on_ru}    action=PAGE PAGE_1    fault=0x70 DATA 0x80
    Wait Until Keyword Succeeds             150 sec     10 sec       Verify Alarm is Active on gNB
    ...                                     fault_name=SFP Transceiver temperature too high     fault_id=4698
    local_resources.SFP Override Memory     port_id_on_ru=${port_id_on_ru}    action=PAGE PAGE_1    fault=0x70 DATA 0x04
    Wait Until Keyword Succeeds             150 sec     10 sec       Verify Alarm is not Active on gNB
    ...                                     fault_name=SFP Transceiver temperature too high     fault_id=4698
    Wait Until Keyword Succeeds             180 sec     10 sec       Verify Alarm is Active on gNB
    ...                                     fault_name=TX Bias Current too low      fault_id=4699

    local_resources.SFP Override Memory     port_id_on_ru=${port_id_on_ru}    action=PAGE PAGE_1    fault=0x70 DATA 0x01
    Wait Until Keyword Succeeds             150 sec     10 sec       Verify Alarm is not Active on gNB
    ...                                     fault_name=TX Bias Current too low     fault_id=4699
    Wait Until Keyword Succeeds             150 sec     10 sec       Verify Alarm is Active on gNB
    ...                                     fault_name=TX Power too low     fault_id=4700

    local_resources.SFP Override Memory     port_id_on_ru=${port_id_on_ru}    action=PAGE PAGE_1    fault=0x71 DATA 0x40
    Wait Until Keyword Succeeds             150 sec     10 sec       Verify Alarm is not Active on gNB
    ...                                     fault_name=TX Power too low     fault_id=4700
    Wait Until Keyword Succeeds             150 sec     10 sec       Verify Alarm is Active on gNB
    ...                                     fault_name=RX Power too low    fault_id=4701
    local_resources.cancel_override_memory      port_num_id=${port_id_on_ru}
    Wait Until Keyword Succeeds             900 sec     30 sec      gnbcell.Verify All Cells Are Onair

    local_resources.perform_recommisioning_on_bts       monitoring_params=${monitoring_params}
    ...                                                 param_value=Transceiver alarms and warnings

# After CNI-124210 minor SFP alarms are not displayed anymore
#    local_resources.SFP Override Memory     port_id_on_ru=${port_id_on_ru}    action=PAGE PAGE_1    fault=0x74 DATA 0x80
#    Wait Until Keyword Succeeds             150 sec     10 sec       Verify Alarm is Active on gNB
#    ...                                     fault_name=SFP Transceiver temperature too high     fault_id=4698
#
#    local_resources.SFP Override Memory     port_id_on_ru=${port_id_on_ru}    action=PAGE PAGE_1    fault=0x74 DATA 0x04
#    Wait Until Keyword Succeeds             150 sec     10 sec       Verify Alarm is not Active on gNB
#    ...                                     fault_name=SFP Transceiver temperature too high     fault_id=4698
#    Wait Until Keyword Succeeds             150 sec     10 sec       Verify Alarm is Active on gNB
#    ...                                     fault_name=TX Bias Current too low    fault_id=4699
#
#    local_resources.SFP Override Memory     port_id_on_ru=${port_id_on_ru}    action=PAGE PAGE_1    fault=0x74 DATA 0x01
#    Wait Until Keyword Succeeds             150 sec     10 sec       Verify Alarm is not Active on gNB
#    ...                                     fault_name=TX Bias Current too low   fault_id=4699
#    Wait Until Keyword Succeeds             150 sec     10 sec       Verify Alarm is Active on gNB
#    ...                                     fault_name=TX Power too low    fault_id=4700
#
#    local_resources.SFP Override Memory     port_id_on_ru=${port_id_on_ru}    action=PAGE PAGE_1    fault=0x75 DATA 0x40
#    Wait Until Keyword Succeeds             150 sec     10 sec       Verify Alarm is not Active on gNB
#    ...                                     fault_name=TX Power too low    fault_id=4700
#    Wait Until Keyword Succeeds             150 sec     10 sec       Verify Alarm is Active on gNB
#    ...                                     fault_name=RX Power too low    fault_id=4701

    local_resources.perform_recommisioning_on_bts       monitoring_params=${monitoring_params}
    ...                                                 param_value=Off
    Wait Until Keyword Succeeds             150 sec     10 sec       Verify Alarm is not Active on gNB
    ...                                     fault_name=RX Power too low    fault_id=4701
    Wait Until Keyword Succeeds             900 sec     30 sec      gnbcell.Verify All Cells Are Onair

Set additional alarms
    [Arguments]    ${alarms_for_test}
    Set Test Variable    ${CUSTOM_ALLOWED_ALARMS}    ${alarms_for_test}

Actions before test
    [Arguments]    ${alarms_for_test}=${None}
    ${default_alarms}=    alarm.get_variables
    Set Test Variable    ${allowed_alarms}    ${default_alarms}[allowed_alarms]
    Set Test Variable    ${ASIR_ALLOWED_ALARMS}    ${default_alarms}[ASIR_ALLOWED_ALARMS]
    Run keyword if    "${alarms_for_test}!=${None}"    Set additional alarms    ${alarms_for_test}
    Common Preconditions With Watching Alarms

Actions after test
    Common Postconditions With Watching Alarms
    Remove custom allowed alarms if defined
