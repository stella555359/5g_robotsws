# robocop: off
*** Settings ***

Documentation
...    Author:   lucja.kazimieruk@nokia.com
...    Maintainer:    Author

Library    Collections
Library    Process
Library    String
Library    XML    use_lxml=true
Library    OperatingSystem
Library    SSHLibrary


Resource    ./lg_hr_infomodel.robot

Resource    ./lg_hr_switch.robot





*** Variables ***
${MANDATORY_ALARM_NO_CONNECTION_TO_UNIT}=         {'alarmDetail': 'No connection to unit',
...                                               'faultId': '10', 'alarmSeverity': 'Critical'}
${MANDATORY_ALARM_FAILURE_IN_OPTICAL_INTERFACE}=  {'alarmDetail': 'Failure in optical interface',
...                                               'faultId': '10', 'alarmSeverity': 'Critical'}
${MANDATORY_ALARM_NO_CONNECTION_TO_UNIT_MINOR}=   {'alarmDetail': 'No connection to unit',
...                                               'faultId': '10', 'alarmSeverity': 'Minor'}
${MANDATORY_ALARM_NO_CONNECTION_TO_UNIT_MAJOR}=   {'alarmDetail': 'No connection to unit',
...                                               'faultId': '10', 'alarmSeverity': 'Major'}
${MANDATORY_ALARM_ADMIN_BASEBAN_BUS}=             {'alarmDetail': 'Not able to synchronize baseband bus',
...                                               'faultId': '1815', 'alarmSeverity': 'Critical'}
${MANDATORY_ALARMS_ADMIN_NOT_ENOUGH_HW_FOR_LCR}=  {'alarmDetail': 'BTS configuration error.*',
...                                               'faultId': '1868', 'alarmSeverity': 'Critical'}
${MANDATORY_ALARM_ADMIN_BASEBAN_BUS_MINOR}=       {'alarmDetail': 'Not able to synchronize baseband bus',
...                                               'faultId': '1815', 'alarmSeverity': 'Minor'}
${MANDATORY_ALARM_ADMIN_INVALID_FREQUENCY_CHANNEL}=    {'alarmDetail': 'Invalid frequency channel for the BTS HW',
...                                               'faultId': '1807', 'alarmSeverity': 'Critical'}
${MANDATORY_ALARM_INCOMPATIBLE_SW_ADMIN}=         {'alarmDetail':'Incompatible SW version detected.*',
...                                               'faultId':'23','alarmSeverity':'Critical'}
${MANDATORY_ALARM_INCOMPATIBLE_SW_ADMIN_MAJOR}=   {'alarmDetail':'Incompatible SW version detected.*',
...                                               'faultId':'23','alarmSeverity':'Major'}
${MANDATORY_ALARM_FAULT_ID_49_SCHEME}=            {'alarmDetail': 'Cell blocked',
...                                               'faultId': '49', 'alarmSeverity': 'Critical'}
${BTS_AUTONOMOUS_RESET_AS_RECOVERY_ACTION}=       {'alarmDetail': 'BTS site autonomous reset as recovery action',
...                                               'faultId': '4001', 'alarmSeverity': 'Warning'}
${BTS_RESET_REQUIRED}=                            {'alarmDetail': 'BTS reset required',
...                                               'faultId': '4001', 'alarmSeverity': 'Critical'}
${RM_AUTONOMOUS_RESET_AS_RECOVERY_ACTION}=        {'alarmDetail': 'Radio autonomous reset as recovery action',
...                                               'faultId': '1811', 'alarmSeverity': 'Warning'}
${DISTRIBUTED_SITE_SUPPORT_NOT_ENABLED}=          {'alarmDetail': 'Distributed site support not enabled',
...                                               'faultId': '4076', 'alarmSeverity': 'Critical'}
${TRASMISSION_PATH_FAILURE}=                      {'alarmDetail': 'Transmission path failure',
...                                               'faultId': '4003', 'alarmSeverity': 'Critical'}
${TRASMISSION_PATH_FAILURE_MINOR}=                 {'alarmDetail': 'Transmission path failure',
...                                               'faultId': '4003', 'alarmSeverity': 'Minor'}
${ADMIN_FAULT_ID_4310_SCHEME}=    {'alarmDetail':'Connection Unstable At 3Gbps',
...                                               'faultId':'4310','alarmSeverity':'Critical'}
${ADMIN_FAULT_ID_4309_SCHEME}=    {'alarmDetail':'Connection Unstable At 6Gbps',
...                                               'faultId':'4309','alarmSeverity':'Critical'}
${RECEIFING_FAILURE_IN_OPT_INTERFACE_2002}=       {'alarmDetail':'Receiving failure in Optical Interface',
...                                               'faultId':'2002','alarmSeverity':'Minor'}
${RECEIFING_FAILURE_IN_OPT_INTERFACE_2002_critical}=       {'alarmDetail':'Receiving failure in Optical Interface',
...                                               'faultId':'2002','alarmSeverity':'Critical'}

@{BASEBAND BUS FAILURE}=  .*Baseband bus failur.*
...                       .*Not able to synchronize baseband bus.*
&{SET_BEFORE_TEST}=  switch1=1
...            switch2=4
...            switch3=4

${OUT_RMOD_MATCHED_CABLNKS_COUNT}
@{SYSTEM_MODULE_PORT_LIST}=       [0, 1, 2]
&{OUT_OPTICAL_SWITCH_SETTINGS_PRECONDITION}=    switch4=1
${OPTICAL_LINK_SYNCH_TIMEOUT}=          240
&{OPTICAL_SWITCH_SETTINGS_LINK_OFF}=     switch4=4
${OPTICAL_LINK_BREAKS_COUNT}=           3
${OUT_CELL_COUNT_FOR_CONFIGURATION}
${OUT_TESTCASE_LOGS_DIR_PATH}
${OUT_RMOD_MATCHED_CABLNKS}
${OUT_RMOD_LIST}
&{OptFi1}=    switch1=4
&{OptFi2}=    switch2=4
&{OptFi3}=    switch1=1
&{OptFi4}=    switch2=2
&{SWITCH_CHANNEL_OFF}    switch3=4
${OUT_SCFC_CURRENT_FILE_PATH}
${OUT_MANDATORY_ALARMS_LIST}
${OUT_SOURCE_DIST_NAME_LIST}
${OUT_LIST_WORKING_CELL}
${OUT_sm_port_LIST}
${PHY_DATE_PORT_LIST}
${OUT_WORKING_CELL}
${OUT_SUITE_BACKUP_LOGS_DIR_PATH}
${OUT_TESTED_FR_SERIAL_NUMBER_LIST}
${OUT_TESTED_FSM_SERIAL_NUMBER_LIST}
${OUT_CELL_COU}
${ENB_ACTIONS_TRIGGER}
${SUITE_LOGS_DIR_PATH}
${ADDITIONAL_STARTUP_TIME_IN_CASE_OF_CHAIN}=   60
${GLO_POWER_SETUP_BETWEEN_ON_OFF}=      20
${SW_BUILDS_DIR_PATH}
${UTE_UE_CONFIG}
${KEY_PERFORM_HW_SETUP}
${GLO_SCFC_PATH}
${SW_RELEASE}
${GLO_MAKE_CALL}
${ENB_IP_ADDRESS}=                      192.168.255.1
${BTSSM_CLI_PATH}=        /opt/btssm_cli_tools/
${GLO_CELL_BLOCKED_FAULT_ID}=                49
${GLO_CELL_BLOCKED_FAULT_COUNT}=             1
${GLO_CELL_BLOCKED_FAULT_TIMEOUT}=           5
${LOCK_TYPE}=                       True
*** Keywords ***
Test Line Repair
    [Arguments]    ${alias}=default     ${test_line_setup}=False
    [Documentation]  Keyword Test Line Setup if test before end with status "Failed"
#    ${out_testcase_dir_logs_path}=                          Logging Create Suite Logs Directory
#    ...                                                     logs_dir_path=${OUT_SUITE_LOGS_DIR_PATH}Test_Line_Repari
#    Set Suite Variable       ${OUT_TESTCASE_LOGS_DIR_PATH}  ${out_testcase_dir_logs_path}
#    Logging Test Group Start                                logs_dir_path=${out_testcase_dir_logs_path}
    ...                                                     file_name_postfix=Repair   alias=${alias}
    Test Line Check                                         ${alias}
#    Logging Test Group Save And Stop                        logs_dir_path=${out_testcase_dir_logs_path}
#    ...                                                     file_name_postfix=Repair   alias=${alias}

Test Line Check
    [Arguments]    ${alias}=default     ${fr_serial_number}=${OUT_CURRENT_FR_SERIAL_NUMBERS}
    Log    Test Line Check    WARN
    Optical Reconfiguration Tested Configuration            ${OUT_CURRENT_TESTED_CONFIGURATION}
    FR Autodetection                                        ${fr_serial_number}  ${alias}
    Log    Test Line Ready For Testing
    [Teardown]   Run Keyword If   '${KEYWORD STATUS}'!='PASS'   Commissioning

Commissioning
    [Arguments]    ${alias}=default      ${test_line_setup}=False
    Convert Commissioning File                              scfc_file_path=${OUT_SCFC_CURRENT_FILE_PATH}
    Perform Commissioning From File                         scfc_file_path=${OUT_SCFC_CURRENT_FILE_PATH}
    Run Keyword And Continue On Failure  Info Model LCELLs Count In Procedural State Should Be
    ...                                                     ${OUT_CELL_COUNT_FOR_CONFIGURATION}
    ...                                                     OnAirDone    timeout=300   alias=${alias}
    Info Model Alarms Get And Check                         allowed=${GLO_ALLOWED_ALARMS}    alias=${alias}
    Log    Test Line Ready For Testing

Prepare Test Variable
    [Arguments]  ${alias}=default       ${scfc_configuration}=${CONFIGURATION_NAME}     ${HWF_delete}=False
    ${out_os}    Run Keyword And Return Status    List Should Contain Value    ${${cfg.configuration_name}}   OS
    ${out_ox}    Run Keyword And Return Status    List Should Contain Value    ${${cfg.configuration_name}}    OX

#    Run Keyword if   "${out_os}" == "True"   Run Keyword    Optical Preconditions   alias=${alias}
#    Run Keyword If   "${out_os}" == "False"    Run Keyword     Run Keyword If   "${out_ox}" == "True"
#    ...    Run Keyword     Optical Preconditions   alias=${alias}
#    ${cell_count_for_configuration}=    Info Model Get Cell Count   alias=${alias}
    Set Test Variable     ${OUT_CELL_COUNT_FOR_CONFIGURATION}   ${cfg.NODES['${BTS_ID}']['scf_cell_count']['ALL']}
    Set Test Variable     ${ACT_CATEGORY_ALARMS}   ${cfg.NODES['${BTS_ID}']['scf_alarms_category']}
#    ${ACT_CATEGORY_ALARMS}=    SCFC Get Activate Category Alarms Value     ${OUT_SCFC_REFERENCE_FILE_PATH}
    ${fault_count}=       Set Variable If    "${cfg.NODES['${BTS_ID}']['scf_alarms_category']}"=="True"    1     ${cell_count_for_configuration}
    Set Test Variable     ${OUT_FAULT_COUNT}    ${fault_count}
    ${fault_10}=          Set Variable If    "${cfg.NODES['${BTS_ID}']['scf_alarms_category']}"=="True"
    ...                   ${MANDATORY_ALARM_NO_CONNECTION_TO_UNIT}     ${MANDATORY_ALARM_FAILURE_IN_OPTICAL_INTERFACE}
    Set Test Variable     ${OUT_FAULT_10}    ${fault_10}
    ${out_LcrID_list_for_spec_serial_number}=   SCFC Create LcrId List For FR Serial Numbers List
    ...                                         ${cfg.NODES['${BTS_ID}']['parsed_scf']}    ${cfg.NODES['${BTS_ID}']['scf_hw_fr_list']}
    Set Suite Variable    ${OUT_LCRID_LIST_FOR_SPEC_SERIAL_NUMBER}     ${out_LcrID_list_for_spec_serial_number}
    ${out_LncelID_list}=                        SCFC Create LncelId List For LcrdId List
    ...                                         ${cfg.NODES['${BTS_ID}']['parsed_scf']}    ${OUT_LCRID_LIST_FOR_SPEC_SERIAL_NUMBER}
    Set Suite Variable    ${OUT_LNCELID_LIST}    ${out_LncelID_list}
    Set Cell Information Dictionary    ${out_LncelID_list}    ${OUT_SCFC_CURRENT_FILE_PATH}    alias=${alias}

Optical Preconditions
    [Arguments]  ${alias}=default       ${scfc_configuration}=${${cfg.configuration_name}}

    ${OS}=  Set Variable  OS
    ${OX}=  Set Variable  OX
    ${os_config_ip} =   Evaluate Xpath  ${GLO_TL_DESCRIPTOR_FILE_PATH}  //Unit[@Type="OS"][@Number="1"]/Setup/@IP
    ${ox_config_ip} =   Evaluate Xpath  ${GLO_TL_DESCRIPTOR_FILE_PATH}  //Unit[@Type="OX"][@Number="1"]/Setup/@IP
    ${out_os}    Run Keyword And Return Status    List Should Contain Value    ${scfc_configuration}    ${OS}
    Run Keyword If   "${out_os}" == "True"   run keywords
    ...    Set Test Variable     ${SWITCH_TYPE}    ${OS}
    ...    AND    Set Test Variable    ${OUT_SWITCH_IP}    ${os_config_ip[0]}
    ${out_ox}    Run Keyword And Return Status    List Should Contain Value    ${scfc_configuration}    ${OX}
    Run Keyword If   "${out_os}" == "False"    Run Keyword     Run Keyword If   "${out_ox}" == "True"  Run keywords
    ...    Set Test Variable     ${SWITCH_TYPE}    ${OX}
    ...    AND   Set Test Variable     ${OUT_SWITCH_IP}    ${ox_config_ip[0]}

    ${OUT_SWITCH_IP}=    Check Optical Unit IP    1    ${SWITCH_TYPE}
    Run Keyword If   "${out_os}" == "True"   Run Keyword     Run Keyword If     '${SWITCH_MODEL}'=='5x4'
    ...    Number of cablinks    switch_ip=${OUT_SWITCH_IP}[0]       model=${SWITCH_MODEL}
    Run Keyword If   "${out_os}" == "True"   Run Keyword     Run Keyword If     '${SWITCH_MODEL}'=='5x4'
    ...    Create Switch Settings Dictionary
#    Number of cablinks   ${OUT_SWITCH_IP}[0]   ${SWITCH_MODEL}

Prepare test variable for Block RM
    Set Suite Variable    ${OUT_SCFC_REFERENCE_FILE_PATH}     ${OUT_SCFC_CURRENT_FILE_PATH}
    Set Suite Variable    ${FR_UNDER_TEST_SERIAL_NUMBER}      ${OUT_CURRENT_FR_SERIAL_NUMBERS[0]}
    Set Suite Variable    ${BTS_ID}                       ${BTS_ID}
    ${out_lcr_id_list_for_frs}=   SCFC Create LcrId List For FR Serial Numbers List
    ...                                                       scfc_file_path=${OUT_SCFC_REFERENCE_FILE_PATH}
    ...                                                       fr_serial_number_list=${OUT_CURRENT_FR_SERIAL_NUMBERS}
    Set Suite Variable    ${OUT_LCR_ID_LIST_FOR_FRS}          ${out_lcr_id_list_for_frs}
    ${out_lncel_id_list_for_frs}=    SCFC Create LncelId List For LcrdId List
    ...                                                       scfc_file_path=${OUT_SCFC_REFERENCE_FILE_PATH}
    ...                                                       lcr_id_list=${OUT_LCR_ID_LIST_FOR_FRS}
    Set Suite Variable    ${OUT_LNCEL_ID_LIST_FOR_FRS}        ${out_lncel_id_list_for_frs}
    Log To Console        ${OUT_LNCEL_ID_LIST_FOR_FRS}
#    Prepare Variables For Test

Prepare test variable for Block cells
    ${out_lcr_id_list}=     SCFC Create LcrId List            scfc_file_path=${OUT_SCFC_CURRENT_FILE_PATH}
    Set Test Variable       ${OUT_LCR_ID_LIST_FOR_FR_UNDER_TEST}      ${out_lcr_id_list}
    ${out_lncel_id_list}=   SCFC Create LncelId List For LcrdId List
    ...                                                       scfc_file_path=${OUT_SCFC_CURRENT_FILE_PATH}
    ...                                                       lcr_id_list=${out_lcr_id_list}
    Set Test Variable       ${OUT_LNCEL_ID_LIST_FOR_FR_UNDER_TEST}      ${out_lncel_id_list}
    ${out_cells_count}=     SCFC Get Cells Count              ${OUT_SCFC_CURRENT_FILE_PATH}
    Set Test Variable       ${out_cells_count}                ${out_cells_count}
    ${cell_subcell_dict}=   SCFC Create Dict With Cell And Subcell     ${OUT_SCFC_CURRENT_FILE_PATH}
    Set Test Variable       ${cell_subcell_dict}

Create LNcellid List For Proper List Of Cells
    [Arguments]    ${list_working_cell}
    ${out_LcrID_list_for_spec_serial_number}=   SCFC Create LcrId List For FR Serial Numbers List
    ...                                         ${OUT_SCFC_CURRENT_FILE_PATH}    ${OUT_CURRENT_FR_SERIAL_NUMBERS}
    ${out_LncelID_list}=                        SCFC Create LncelId List For LcrdId List
    ...                                         ${OUT_SCFC_CURRENT_FILE_PATH}    ${out_lcrid_list_for_spec_serial_number}
    Sort List    ${list_working_cell}
    Reverse List    ${list_working_cell}
    FOR  ${out_index}  IN   @{list_working_cell}
        ${working_cell}=   convert to integer    ${out_index}
        ${index}=   evaluate    ${working_cell}-1
        Remove From List    ${out_LncelID_list}    ${index}
    END
    Set Suite Variable    ${OUT_LNCELID_LIST}    ${out_LncelID_list}

SM Port List For FSMr3
    [Arguments]   ${sm_port_list}
    [Documentation]   This keyword is requier for logic system with hot insert removed collection for FSMr3
    @{out_new_sm_port_list}=    create list
    ${items}=    Get Length    ${sm_port_list}
    FOR  ${index}   IN RANGE    ${items}
        ${temp_value}=   convert to integer  ${sm_port_list[${index}]}
        ${temp_value}=   evaluate  ${temp_value} + 1
        ${temp_value}=   convert to string  ${temp_value}
        append to list    ${out_new_sm_port_list}    ${temp_value}
    END
    Sort List    ${out_new_sm_port_list}
    Set Test Variable    ${OUT_SM_PORT_LIST}    ${out_new_sm_port_list}

Alarms Expected Detection
    [Arguments]   ${mandatory_alarms}    ${fr_serial_number}   ${alias}
    ${mandatory_alarms_list}=   Info Model Create Mandatory Alarms List      ${OUT_LNCELID_LIST}    ${mandatory_alarms}
    ...                                                                          ${ACT_CATEGORY_ALARMS}
    ${all_alarms}=                  Combine Lists   ${OUT_MANDATORY_ALARMS_LIST}    ${mandatory_alarms_list}
    Set Test Variable               ${OUT_MANDATORY_ALARMS_LIST}        ${all_alarms}
    Info Model Alarms Get And Check    allowed=${GLO_ALLOWED_ALARMS}    mandatory=${OUT_MANDATORY_ALARMS_LIST}   alias=${alias}
    Log to console       mandatory alarm: ${OUT_MANDATORY_ALARMS_LIST}

Disabled Optical Links Detection
    [Arguments]    ${cablink_list}    ${sm_port_list}    ${alias}   ${not_enought_link_capacity_test_case}=False
    Info Model Wait For Cablnk States        cablnk_list=${cablink_list}
    ...                                      operationalState=Disabled
    ...                                      availabilityStatus=NotInstalled
    ...                                      timeout=60    alias=${alias}
    run keyword if  ${not_enought_link_capacity_test_case}==False   Wait Until Keyword Succeeds  1min  1s
    ...                                      Info Model Check Cablnk Reasoning State    cablnk_list=${cablink_list}
    ...                                      state_to_be_checked=BasebandBusSynchronizationFailed    alias=${alias}


SM Port And Cablnk Detection
    [Arguments]   ${fr_serial_number}    ${expected_cablnk_count}=${OUT_EXPECTED_CABLINK_COUNT}   ${operationalState}=Enabled
    ...           ${availabilityStatus}=Online    ${alias}=default
    Cablnk Detection     fr_serial_number=${fr_serial_number}    expected_cablnk_count=${expected_cablnk_count}
    ...                  operationalState=${operationalState}    availabilityStatus=${availabilityStatus}
    ...                  timeout=900    alias=${alias}
    SM Port Detection    timeout=10     alias=${alias}

SM Port And Cablnk Detection for one rm
    [Arguments]   ${fr_serial_number}    ${expected_cablnk_count}=1   ${operationalState}=Enabled
    ...           ${availabilityStatus}=Online    ${alias}=default
    One Cablnk Detection     fr_serial_number=${fr_serial_number}    expected_cablnk_count=${expected_cablnk_count}
    ...                  operationalState=${operationalState}    availabilityStatus=${availabilityStatus}
    ...                  timeout=120    alias=${alias}
    SM Port Detection    timeout=10     alias=${alias}

Cablnk Detection
	[Arguments]   ${fr_serial_number}    ${expected_cablnk_count}=${OUT_EXPECTED_CABLINK_COUNT}    ${operationalState}=Enabled
	...           ${availabilityStatus}=Online    ${alias}=default    ${timeout}=10
    ${rmod_path_list}=    Info Model Create Rmod Path For Fr Serial Number  fr_serial_number=${fr_serial_number}
    ...                                                                     alias=${alias}   timeout=${timeout}
    Info Model Wait For Cablnks Count With Expected States    source_dist_name_list=${rmod_path_list}
    ...                                                       expected_cablnk_count=${expected_cablnk_count}
    ...                                                       alias=${alias}   timeout=${timeout}
    ${cablink_list}=    Info Model Get Cablnk Path List For Connected Links   source_dist_name_list=${rmod_path_list}
    ...                                                                       alias=${alias}    timeout=${timeout}
    Set Test Variable    ${OUT_CABLINK_LIST}    ${cablink_list}

SM Port Detection
    [Arguments]    ${cablnk_list}=${OUT_CABLINK_LIST}    ${alias}=default    ${timeout}=10
    ${sm_port_list}=    Info Model Create SM Ports List For Cablnks    cablnk_list=${cablnk_list}    alias=${alias}
    ...                                                                timeout=${timeout}
    Run Keyword If    "${SW_REL_TESTED_TRUNK_TAG}"=="FSM3"   SM Port List For FSMr3    ${sm_port_list}
    ...    ELSE    Set Test Variable    ${OUT_SM_PORT_LIST}    ${sm_port_list}

Hot Remove Optical Links
  [Arguments]    ${sm_port_list}=${OUT_SM_PORT_LIST}   ${out_os_config_ip}=${OUT_SWITCH_IP}
  ...            ${switch_10x2_port}='switch1'   ${switch_10x2_set}=2
  Log To Console  Hot Remove is being performed
  Run keyword if  "${SWITCH_MODEL}"=="10x2"  Hot Remove Optical Links for x2 Switch    ${out_os_config_ip}   ${switch_10x2_port}   ${switch_10x2_set}
  ...    ELSE     Hot Remove Optical Links for x4 Switch    ${sm_port_list}   ${out_os_config_ip}

Hot Remove Optical Links for x4 Switch
    [Arguments]    ${sm_port_list}=${OUT_SM_PORT_LIST}   ${out_os_config_ip}=${OUT_SWITCH_IP}
    ${Ports_to_remove_list}=   Create List
    ${os_conf}=    Get From Dictionary    ${${CONFIGURATION_NAME}}    OS
    ${current_os_config}     Split String    ${os_conf}    |
    ${current_os_config2}    Split String    ${current_os_config[0]}   :
    ${current_os_config3}    Split String    ${current_os_config2[1]}   ,
    FOR   ${index}    IN   @{current_os_config3}
        Run keyword if    ${index[2]}!=4
        ...   Change Switch Settings    ${index[0]}-4    timeout=10
    END

Hot Remove Optical Links for x2 Switch
    [Arguments]    ${out_os_config_ip}=${OUT_SWITCH_IP}   ${switch_10x2_port}='switch1'     ${switch_10x2_set}=2
    Optical Switch Channel Change   ${out_os_config_ip}    {${switch_10x2_port}: ${switch_10x2_set}}     10x2
    Sleep   3
    Optical Switch Channel Change   ${out_os_config_ip}    {'switch2': ${switch_10x2_set}}     10x2
    Sleep   3
    Optical Switch Channel Change   ${out_os_config_ip}    {'switch3': ${switch_10x2_set}}     10x2
    Sleep   3
    Optical Switch Channel Change   ${out_os_config_ip}    {'switch4': ${switch_10x2_set}}     10x2
    Sleep    30s

Hot remove by X-Point
    [Arguments]   ${OX_IP}=10.42.170.220    ${CONF}=CONF_0.ini
    SSHLibrary.open connection    ${OX_IP}
    SSHLibrary.login    nsn    nsn
    SSHLibrary.Read
    Sleep   3
    SSHLibrary.execute command      cp /home/nsn/${CONF} /home/nsn/config.ini
    SSHLibrary.Read
    Sleep   3
    SSHLibrary.execute command      sudo reboot
    SSHLibrary.Read
    Sleep   3
    SSHLibrary.close connection

Hot remove chain by X-Point
    SSHLibrary.open connection    10.42.170.220
    SSHLibrary.login    nsn    nsn
    SSHLibrary.Read
    Sleep   3
    SSHLibrary.execute command      cp /home/nsn/CONF_Chain.ini /home/nsn/config.ini
    SSHLibrary.Read
    Sleep   3
    SSHLibrary.execute command      sudo reboot
    SSHLibrary.Read
    Sleep   3
    SSHLibrary.close connection

Hot Remove One Radio
    Change Switch Settings                               switch_settings=1-4,2-2,3-4

Hot Insert Optical Links
  [Arguments]    ${sm_port_list}=${OUT_SM_PORT_LIST}   ${out_os_config_ip}=${OUT_SWITCH_IP}    ${switch_value}=4
  ...            ${switch_10x2_port}='switch1'   ${switch_10x2_set}=1
  Log To Console  Hot Insert is being performed
  Run keyword if  "${SWITCH_MODEL}"=="10x2"  Hot Insert Optical Links for x2 Switch  ${out_os_config_ip}    ${switch_10x2_port}   ${switch_10x2_set}
  ...    ELSE     Hot Insert Optical Links for x4 Switch     ${switch_value}   ${sm_port_list}   ${out_os_config_ip}

Hot Insert Optical Links for x4 Switch
    [Arguments]   ${switch_value}   ${sm_port_list}=${OUT_SM_PORT_LIST}    ${out_os_config_ip}=${OUT_SWITCH_IP}
        Optical Reconfiguration Tested Configuration    ${${CONFIGURATION_NAME}}

Hot Insert Optical Links for x2 Switch
    [Arguments]    ${out_os_config_ip}=${OUT_SWITCH_IP}   ${switch_10x2_port}='switch7'   ${switch_10x2_set}=1
    Optical Reconfiguration Tested Configuration                      ${${CONFIGURATION_NAME}}
    Sleep    120s

Hot Insert Optical Links for different port
    [Arguments]    ${switch_value}=4    ${sm_port_list}=${OUT_SM_PORT_LIST}   ${out_os_config_ip}=${OUT_SWITCH_IP}
    sort list   ${sm_port_list}
    FOR  ${item}  IN  @{sm_port_list}
        Optical Switch Insert Optical Link To Free Port    ${item}    ${out_os_config_ip}    ${switch_value}
    END
    Sleep    20s

Hot Remove Optical Links for different port
    [Arguments]    ${sm_port_list}=${OUT_SM_PORT_LIST}   ${out_os_config_ip}=${OUT_SWITCH_IP}
    sort list   ${sm_port_list}
    FOR  ${item}  IN  @{sm_port_list}
        Optical Switch Remove Optical Link    ${item}    4   ${out_os_config_ip}
    END
    Sleep    20s

Hot Insert Different Radio
    [Arguments]  ${fr_serial_number}    ${switch_settings}     ${switch_ip}=${OUT_SWITCH_IP}
    ...          ${model}=${SWITCH_MODEL}    ${alias}=default
    Log To Console  Hot Insert is being performed
    PDU Switch On Device Lists    ${fr_serial_number}
    ${os_config_settings_list}    Set Optical Configuration    ${switch_settings}
    ${model}=    set variable         ${OPTICAL_SWITCHES_MATRIX['${model}']}
    Setup Optical Switch Settigs   ${switch_ip}   ${model}   Leoni   ${os_config_settings_list}  ${alias}
#    ${os_config_settings_list}    Set Optical Configuration    ${switch_settings}
#    Setup Optical Switch    ip=${switch_ip}    model=${model}   alias=${alias}
#    Set Optical Switch Channels    ${os_config_settings_list}   alias=${alias}
#    ${switch_settings}=    Get optical switch channels    ${alias}

    sleep  20s
#    optical_switch.teardown    ${alias}

Change Switch Settings
    [Arguments]    ${switch_settings}     ${switch_ip}=${OUT_SWITCH_IP}
    ...          ${model}=${SWITCH_MODEL}    ${alias}=default    ${timeout}=60
    ${os_config_settings_list}    Set Optical Configuration    ${switch_settings}
#    Setup Optical Switch Configuration   ${switch_ip}   ${model}   Leoni   ${os_config_settings_list}  ${alias}
    ${model}=    set variable         ${OPTICAL_SWITCHES_MATRIX['${model}']}
    ${switch_settings}=  Setup Optical Switch Settigs   ${switch_ip}   ${model}   Leoni   ${os_config_settings_list}  default
#    Setup Optical Switch    ip=${switch_ip}    model=${model}   alias=${alias}
#    Set Optical Switch Channels    ${os_config_settings_list}   alias=${alias}
#    ${switch_settings}=    Get optical switch channels    ${alias}

    sleep  ${timeout}
#    Teardown Optical Switch    alias=${alias}

Hot Insert CPRI Radio Module
    [Arguments]  ${switch_ip}=${OUT_SWITCH_IP}    ${fr_serial_number}=${FR_SERIAL_NUMBER_CPRI}    ${model}=${SWITCH_MODEL}    ${alias}=default
    PDU Switch On Device Lists    ${FR_SERIAL_NUMBER_CPRI}
    ${switch_value}=   Create Dictionary    1=1
    ...                                     4=3
#    ${os_config_settings_list}    Set Optical Configuration    ${switch_value}
    ${model}=    set variable         ${OPTICAL_SWITCHES_MATRIX['${model}']}
    ${os_config_settings_list}    Set Optical Configuration    1-1,4-3
    Setup Optical Switch Settigs   ${switch_ip}   ${model}   Leoni   ${os_config_settings_list}  ${alias}
#    Setup Optical Switch    ip=${switch_ip}    model=${model}   alias=${alias}
#    Set Optical Switch Channels    ${switch_value}   alias=${alias}
#    ${switch_settings}=    Get optical switch channels    ${alias}
#    sleep  1s
#    Teardown Optical Switch    alias=${alias}
    Sleep    200

Hot Insert Additional Optical Fiber
    [Arguments]  ${fr_serial_number}    ${switch_ip}    ${model}=${SWITCH_MODEL}   ${alias}=default   ${alias_im}=default
    Log To Console  Hot Insert Additional link is being performed
    ${old_cablink_list}=       Set Variable             ${OUT_CABLINK_LIST}
    SM Port Not Used Detection                           fr_serial_number=${fr_serial_number}
    ...                                                  alias=${alias}    timeout=60
    ${switch_value}=   Create Dictionary                 switch3=${OUT_NOT_USED_SM_PORT}
    ${os_config_settings_list}    Set Optical Configuration    ${switch_value}
    Setup Optical Switch Configuration   ${switch_ip}   ${model}   Leoni   ${os_config_settings_list}  ${alias}
#    Setup Optical Switch                                 ip=${switch_ip}    model=${model}    alias=${alias}
    ${switch_channels}=   Get Optical Switch Configuration    ${switch_ip}   ${model}   Leoni   ${os_config_settings_list}
    Set Optical Switch Channels                          ${switch_value}   alias=${alias}
    sleep                                                5s
    ${switch_channels}=   Get Optical Switch Configuration    ${switch_ip}   ${model}   Leoni   ${os_config_settings_list}
#    ${switch_channels}=   get optical switch channels    alias=${alias}
#    Teardown Optical Switch                              alias=${alias}
    sleep                                                20s
    ${additional_expected_cablnk_count}=   evaluate    ${OUT_EXPECTED_CABLINK_COUNT}+1
    FR Autodetection                                     fr_serial_number=${fr_serial_number}
    ...                                                  alias=More_Fibers_${fr_serial_number[0]}
    ...                                                  expected_cablnk_count=${additional_expected_cablnk_count}
    Cablnk Detection     fr_serial_number=${fr_serial_number}    expected_cablnk_count=${additional_expected_cablnk_count}
    ...                  operationalState=Disabled       availabilityStatus=Online
    ...                  timeout=360    alias=${alias}
    ${OUT_NOT_USED_LIST}=     Create List                       ${OUT_CABLINK_LIST[-1]}
    Set Test Variable         ${OUT_NOT_USED_CABLINK_LIST}      ${OUT_NOT_USED_LIST}
    Set Test Variable         ${OUT_EXPECTED_CABLINK_COUNT}     ${additional_expected_cablnk_count}
    Log To Console   \nAdditional optical fiber plugged in.\n

Hot Insert To Another Port
    [Arguments]  ${switch_ip}=${OUT_SWITCH_IP}   ${model}=${SWITCH_MODEL}    ${alias}=default
    ${os_config_settings_list}    Set Optical Configuration    ${Switch_for_another_port}
    ${model}=    set variable         ${OPTICAL_SWITCHES_MATRIX['${model}']}
    Setup Optical Switch Settigs   ${switch_ip}   ${model}   Leoni   ${os_config_settings_list}  ${alias}
#    Setup Optical Switch    ip=${switch_ip}    model=${model}   alias=${alias}
#    Set Optical Switch Channels    ${os_config_settings_list}   alias=${alias}
    optical_switch.setup_optical_switch
    ...    addr=${switch_ip}
    ...    model=${model}
    ...    optical_switch=Leoni
    ...    alias=${alias}
    ${switch_channels}=  optical_switch.get_optical_switch_channels    optical_switch_device=${alias}
#    ${switch_settings}=    Get Optical Switch Configuration    ${switch_ip}   ${SWITCH_MODEL}   Leoni   ${os_config_settings_list}
    sleep  200s
    optical_switch.teardown    optical_switch_device=${alias}

FR Removal Detection
    [Arguments]    ${fr_serial_number}    ${sm_port_list}     ${cablink_list}     ${alias}
    ...            ${cell_count_for_configuration}=${OUT_CELL_COUNT_FOR_CONFIGURATION}
    ...            ${not_enought_link_capacity_test_case}=False      ${timeout_for_fault_10}=10
    ...            ${fault_10}=${MANDATORY_ALARM_NO_CONNECTION_TO_UNIT_MINOR}    ${fault_count}=${OUT_FAULT_COUNT}
    Log to console   \nFR ${fr_serial_number} removal detection started!
    Disabled Optical Links Detection                     cablink_list=${cablink_list}
    ...                                                  sm_port_list=${sm_port_list}
    ...                                                  alias=${alias}
    ...                                      not_enought_link_capacity_test_case=${not_enought_link_capacity_test_case}
    Alarm detection                                      fault_id=10      alias=${alias}
    ...                                                  fault_details=${OUT_FAULT_10}
    ...                                                  fault_count=${fault_count}
    ...                                                  timeout=${timeout_for_fault_10}
    Run Keyword If   "${fault_count}"=="2"
    ...     Alarm detection                              fault_id=10      alias=${alias}
    ...                                                  fault_details=${fault_10}
    ...                                                  fault_count=${fault_count}
    ...                                                  timeout=${timeout_for_fault_10}
    Info Model Wait For Specific RF States RU_L Object    fr_serial_number=${fr_serial_number}
    ...                                                   operationalState=Disabled
    ...                                                   availabilityStatus=NotInstalled
    ...                                                   alias=${alias}
    Run Keyword If   ${not_enought_link_capacity_test_case}==False    Wait Until Keyword Succeeds  1min  1s
    ...    Info Model Check RU_L Object Reasoning State   reasoningStatus=NoConnectionToUnit
    ...                                                   fr_serial_number=${fr_serial_number}    timeout=10   alias=${alias}
    Info Model Wait For Cell Count in Specific States     operationalState=Disabled
    ...                                                   availabilityStatus=Failed
    ...                                                   proceduralState=Initializing
    ...                                                   expected_cell_count=${cell_count_for_configuration}
    ...                                                   timeout=120    alias=${alias}
    Run Keyword If   ${not_enought_link_capacity_test_case}==False    Wait Until Keyword Succeeds  1min  1s
    ...     Info Model Check Resoning Status Of Disabled Cell    reasoningStatus=NotEnoughRadioHardware
    ...                                                   fault_count=${cell_count_for_configuration}   alias=${alias}
    Log to console   FR ${fr_serial_number} removal detection finished successfully!\n

FR Removal One RM Detection
    [Arguments]
    ...  ${fr_serial_number}
    ...  ${sm_port_list}
    ...  ${cablink_list}
    ...  ${cell_count_for_configuration}
    ...  ${alias}
    ...  ${not_enought_link_capacity_test_case}=False
    Log to console   \nFR ${fr_serial_number} removal detection started!
    Disabled Optical First Link Detection    cablink_list=${cablink_list}
    ...                                 sm_port_list=${sm_port_list}
    ...                                 alias=${alias}
    ...                                 not_enought_link_capacity_test_case=${not_enought_link_capacity_test_case}
    Info Model Wait For Specific RF States RU_L Object    fr_serial_number=${fr_serial_number}
    ...                                                   operationalState=Disabled
    ...                                                   availabilityStatus=NotInstalled
    ...                                                   alias=${alias}
    Run Keyword If   ${not_enought_link_capacity_test_case}==False    Wait Until Keyword Succeeds  1min  1s
    ...    Info Model Check RU_L Object Reasoning State   reasoningStatus=NoConnectionToUnit
    ...                                                   fr_serial_number=${fr_serial_number}    timeout=10
    Info Model Wait For Cell Count in Specific States     operationalState=Disabled
    ...                                                   availabilityStatus=Failed
    ...                                                   proceduralState=Initializing
    ...                                                   expected_cell_count=${cell_count_for_configuration}
    ...                                                   timeout=120    alias=${alias}
    Run Keyword If   ${not_enought_link_capacity_test_case}==False    Wait Until Keyword Succeeds  1min  1s
    ...     Info Model Check Resoning Status Of Disabled Cell    reasoningStatus=NotEnoughRadioHardware
    ...                                                   fault_count=${cell_count_for_configuration}     alias=${alias}
    Log to console   FR ${fr_serial_number} removal detection finished successfully!\n

FR Autodetection
    [Arguments]    ${fr_serial_number}   ${alias}    ${expected_cablnk_count}=${OUT_EXPECTED_CABLINK_COUNT}
    ...            ${proceduralState}=swCheckDone    ${cell_count_for_configuration}=${OUT_CELL_COUNT_FOR_CONFIGURATION}
    ...            ${timeout_detection}=60   ${23}=${MANDATORY_ALARM_INCOMPATIBLE_SW_ADMIN}
    Log To Console  \nFR ${fr_serial_number[0]} autodetection started!
    SM Port And Cablnk Detection                              fr_serial_number=${fr_serial_number}
    ...                                                       expected_cablnk_count=${expected_cablnk_count}
    ...                                                       alias=${alias}
    Info Model Wait For Specific RF State RMOD_L Object       fr_serial_number=${fr_serial_number[0]}
    ...                                                       fr_state_to_be_checked=stateInfo.availabilityStatus=Online
    ...                                                       timeout=${timeout_detection}    alias=${alias}
    Info Model Wait For Specific RF State RU_L Object         fr_serial_number=${fr_serial_number[0]}
    ...                                                       fr_state_to_be_checked=stateInfo.availabilityStatus=Online
    ...                                                       timeout=240    alias=${alias}
#    ${sw_status}=    Info Model HW SW Version Is Compatible With BTS SW      ${fr_serial_number}
    ${sw_status}=    SWM.SWM Check HW List SW Version Is Compatible With BTS SW
    ...  RMOD
    ...  ${fr_serial_number}
    ...  timeout=${HARDWARE_DETECTION_TIME}
    ...  alias=${alias}
    Run Keyword If    "${sw_status}" == "False" and "${KEY_PERFORM_HW_SETUP}" == "True"   Run Keywords
    ...  Alarm detection                              fault_id=23     alias=${alias}
    ...                                               fault_details=${23}
    ...  AND   Log   \nRF Software mismatch - running software update procedure
    ...  AND   Check Main Software Package Availability    ${cfg.NODES['${bts_id}']['software_active']}    ${bts_id}
    ...  AND   Set To Dictionary    ${cfg.NODES['${bts_id}']}    software_active_file=${software_active_file}
    ...  AND   Run Keyword And Ignore Error    Wait Sw Update Possible
    ...     bts_ready=True
    ...     readiness_timeout=750
    ...     timeout=800
    ...     connection=${bts_id}
    ...  AND   Update Software
    ...  sw_package=${cfg.NODES['${bts_id}']['software_active_file']}
    ...  timeout=${HARDWARE_DETECTION_TIME}    alias=${BTS_ID}

    ...  AND   Sleep   60
    ...  AND   SM Port And Cablnk Detection                              fr_serial_number=${fr_serial_number}
    ...                                                       expected_cablnk_count=${expected_cablnk_count}   alias=${alias}
    ...  AND   Info Model Wait For Specific RF State RMOD_L Object       fr_serial_number=${fr_serial_number[0]}
    ...                                                       fr_state_to_be_checked=stateInfo.availabilityStatus=Online
    ...                                                       timeout=60    alias=${alias}
    ...  AND   Info Model Wait For Specific RF State RU_L Object         fr_serial_number=${fr_serial_number[0]}
    ...                                                       fr_state_to_be_checked=stateInfo.availabilityStatus=Online
    ...                                                       timeout=120    alias=${alias}
    Info Model Wait For Specific RF State RU_L Object         fr_serial_number=${fr_serial_number[0]}
    ...                                                       fr_state_to_be_checked=stateInfo.operationalState=Enabled
    ...                                                       timeout=120    alias=${alias}
    Info Model Wait For Specific RF State RMOD_L Object       ${fr_serial_number[0]}
    ...                                                       fr_state_to_be_checked=stateInfo.operationalState=Enabled
    ...                                                       timeout=10   alias=${alias}
    Info Model Wait For Specific RF State RU_L Object         fr_serial_number=${fr_serial_number[0]}
    ...                                                       fr_state_to_be_checked=stateInfo.proceduralState=${proceduralState}
    ...                                                       timeout=10    alias=${alias}
    Info Model Wait For Specific RF State RMOD_L Object       ${fr_serial_number[0]}
    ...                                                       fr_state_to_be_checked=stateInfo.proceduralState=ethernetEnabled
    ...                                                       timeout=10   alias=${alias}
    Info Model Wait For Cell Count in Specific States         operationalState=Enabled
    ...                                                       availabilityStatus=Online
    ...                                                       proceduralState=OnAirDone
    ...                                                       expected_cell_count=${cell_count_for_configuration}
    ...                                                       timeout=120    alias=${alias}
    Log To Console  FR ${fr_serial_number[0]} autodetection finished successfully.

One FR Autodetection
    [Arguments]    ${fr_serial_number}   ${alias}    ${expected_cablnk_count}=1   ${proceduralState}=swCheckDone
    Log To Console  \nFR ${fr_serial_number[0]} autodetection started!
    SM Port And Cablnk Detection for one rm                   fr_serial_number=${fr_serial_number}
    ...                                                       expected_cablnk_count=${expected_cablnk_count}   alias=${alias}
    Info Model Wait For Specific RF State RMOD_L Object       fr_serial_number=${fr_serial_number[0]}
    ...                                                       fr_state_to_be_checked=stateInfo.availabilityStatus=Online
    ...                                                       timeout=60    alias=${alias}
    Info Model Wait For Specific RF State RU_L Object         fr_serial_number=${fr_serial_number[0]}
    ...                                                       fr_state_to_be_checked=stateInfo.availabilityStatus=Online
    ...                                                       timeout=120    alias=${alias}
    ${sw_status}=    Info Model HW SW Version Is Compatible With BTS SW      ${fr_serial_number}
    Run Keyword If    "${sw_status}" == "False" and "${KEY_PERFORM_HW_SETUP}" == "True"   Run Keywords
    ...  Alarm detection                              fault_id=23     alias=${alias}
    ...                                               fault_details=${MANDATORY_ALARM_INCOMPATIBLE_SW_ADMIN_MAJOR}
    ...  AND   Log   \nRF Software mismatch - running software update procedure
    ...  AND   Check Main Software Package Availability    ${cfg.NODES['${bts_id}']['software_active']}    ${bts_id}
    ...  AND   Set To Dictionary    ${cfg.NODES['${bts_id}']}    software_active_file=${software_active_file}    AND
    ...  AND   Run Keyword And Ignore Error    Wait Sw Update Possible
    ...     bts_ready=True
    ...     readiness_timeout=750
    ...     timeout=800
    ...     connection=${bts_id}     AND
    ...  AND   Update Software  sw_package=${software_package_path}  timeout=${CONFIGURATION_SWUPDATE_TIMEOUT}  alias=${BTS_ID}
    ...  AND   Sleep   60
    ...  AND   SM Port And Cablnk Detection                              fr_serial_number=${fr_serial_number}
    ...                                                       expected_cablnk_count=${expected_cablnk_count}   alias=${alias}
    ...  AND   Info Model Wait For Specific RF State RMOD_L Object       fr_serial_number=${fr_serial_number[0]}
    ...                                                       fr_state_to_be_checked=stateInfo.availabilityStatus=Online
    ...                                                       timeout=60    alias=${alias}
    ...  AND   Info Model Wait For Specific RF State RU_L Object         fr_serial_number=${fr_serial_number[0]}
    ...                                                       fr_state_to_be_checked=stateInfo.availabilityStatus=Online
    ...                                                       timeout=120    alias=${alias}
    Info Model Wait For Specific RF State RU_L Object         fr_serial_number=${fr_serial_number[0]}
    ...                                                       fr_state_to_be_checked=stateInfo.operationalState=Enabled
    ...                                                       timeout=120    alias=${alias}
    Info Model Wait For Specific RF State RMOD_L Object       ${fr_serial_number[0]}
    ...                                                       fr_state_to_be_checked=stateInfo.operationalState=Enabled
    ...                                                       timeout=10   alias=${alias}
    Info Model Wait For Specific RF State RU_L Object         fr_serial_number=${fr_serial_number[0]}
    ...                                                       fr_state_to_be_checked=stateInfo.proceduralState=${proceduralState}
    ...                                                       timeout=10    alias=${alias}
    Info Model Wait For Specific RF State RMOD_L Object       ${fr_serial_number[0]}
    ...                                                       fr_state_to_be_checked=stateInfo.proceduralState=ethernetEnabled
    ...                                                       timeout=10   alias=${alias}
    Log To Console  FR ${fr_serial_number[0]} autodetection finished successfully!

Not commissioned FR Autodetection
    [Arguments]    ${fr_serial_number}   ${alias}    ${expected_cablnk_count}=${OUT_EXPECTED_CABLINK_COUNT}
    ...            ${cell_count_for_configuration}=${OUT_CELL_COUNT_FOR_CONFIGURATION}
    ...            ${cablink_list}=${OUT_CABLINK_LIST}     ${timeout}=90
    ...            ${expected_cablnk_count}=${OUT_EXPECTED_CABLINK_COUNT}
    ...            ${not_enought_link_capacity_test_case}=False    ${proceduralState}=swCheckDone
    Log To Console  \nFR ${fr_serial_number[0]} with not commissioned state autodetection started!
    SM Port And Cablnk Detection                              fr_serial_number=${fr_serial_number}
    ...                                                       expected_cablnk_count=${expected_cablnk_count}   alias=${alias}
    Info Model Wait For Specific RF State RMOD_L Object       fr_serial_number=${fr_serial_number[0]}
    ...                                                       fr_state_to_be_checked=stateInfo.availabilityStatus=Online
    ...                                                       timeout=60    alias=${alias}
    Info Model Wait For Specific RF State RU_L Object         fr_serial_number=${fr_serial_number[0]}
    ...                                                       fr_state_to_be_checked=stateInfo.availabilityStatus=Online
    ...                                                       timeout=120    alias=${alias}
    Data Optical Link Detection                               ${fr_serial_number}    ${alias}   timeout=${timeout}
    ${new_sm_port_lis}=     Combine Lists    ${OUT_DATA_SM_PORT_LIST}    ${OUT_NOT_USED_SM_PORT_LIST}
    Info Model Wait For Specific RF State RU_L Object         fr_serial_number=${fr_serial_number[0]}
    ...                                                       fr_state_to_be_checked=stateInfo.operationalState=Enabled
    ...                                                       timeout=10    alias=${alias}
    Info Model Wait For Specific RF State RMOD_L Object       ${fr_serial_number[0]}
    ...                                                       fr_state_to_be_checked=stateInfo.operationalState=Enabled
    ...                                                       timeout=10   alias=${alias}
    Info Model Wait For Specific RF State RU_L Object         fr_serial_number=${fr_serial_number[0]}
    ...                                                       fr_state_to_be_checked=stateInfo.proceduralState=${proceduralState}
    ...                                                       timeout=10    alias=${alias}
    Info Model Wait For Specific RF State RMOD_L Object       ${fr_serial_number[0]}
    ...                                                       fr_state_to_be_checked=stateInfo.proceduralState=ethernetEnabled
    ...                                                       timeout=10   alias=${alias}
    ${sm_port_date_and_config_before_test}=   Set Variable       ${OUT_CONF_SM_PORT_LIST}
    ${sm_port_not_used_before_test}=   Set Variable       ${OUT_NOT_USED_SM_PORT_LIST}
    Set test variable    ${out_sm_port_not_used_before_test}    ${sm_port_not_used_before_test}
    SM Port Not Used Detection                fr_serial_number=${fr_serial_number}    alias=${alias}   timeout=${timeout}
    Data And Config Optical Link Detection               fr_serial_number=${fr_serial_number}    alias=${alias}
    Should Be Equal         "${OUT_NOT_USED_SM_PORT_LIST[0]}"      "${sm_port_date_and_config_before_test[0]}"
    Alarm detection                                      fault_id=10      alias=${alias}
    ...                                                  fault_details=${MANDATORY_ALARM_NO_CONNECTION_TO_UNIT}
    Log to console                                       Fault 10 for commissioned RM detected!
    Info Model Wait For Cell Count in Specific States     operationalState=Disabled
    ...                                                   availabilityStatus=Failed
    ...                                                   proceduralState=Initializing
    ...                                                   expected_cell_count=${cell_count_for_configuration}
    ...                                                   timeout=120    alias=${alias}
    Run Keyword If   ${not_enought_link_capacity_test_case}==False    Wait Until Keyword Succeeds  1min  1s
    ...     Info Model Check Resoning Status Of Disabled Cell    reasoningStatus=NotEnoughRadioHardware
    ...                                                   fault_count=${cell_count_for_configuration}     alias=${alias}
    Log to console   FR ${fr_serial_number} not commissioned detection finished successfully!\n

FR with fault 1807 Autodetection
    [Arguments]    ${fr_serial_number}   ${alias}    ${expected_cablnk_count}=${OUT_EXPECTED_CABLINK_COUNT}
    ...            ${proceduralState}=swCheckDone    ${cell_count_for_configuration}=${OUT_CELL_COUNT_FOR_CONFIGURATION}
    Log To Console  \nFR ${fr_serial_number[0]} autodetection started!
    SM Port And Cablnk Detection                              fr_serial_number=${fr_serial_number}
    ...                                                       expected_cablnk_count=${expected_cablnk_count}   alias=${alias}
    Info Model Wait For Specific RF State RMOD_L Object       fr_serial_number=${fr_serial_number[0]}
    ...                                                       fr_state_to_be_checked=stateInfo.availabilityStatus=Online
    ...                                                       timeout=60    alias=${alias}
    Info Model Wait For Specific RF State RU_L Object         fr_serial_number=${fr_serial_number[0]}
    ...                                                       fr_state_to_be_checked=stateInfo.availabilityStatus=Online
    ...                                                       timeout=120    alias=${alias}
    ${sw_status}=    Info Model HW SW Version Is Compatible With BTS SW      ${fr_serial_number}
    Run Keyword If    "${sw_status}" == "False" and "${KEY_PERFORM_HW_SETUP}" == "True"   Run Keywords
    ...  Alarm detection                              fault_id=23     alias=${alias}
    ...                                               fault_details=${MANDATORY_ALARM_INCOMPATIBLE_SW_ADMIN}
    ...  AND   Log   \nRF Software mismatch - running software update procedure
    ...  AND   Check Main Software Package Availability    ${cfg.NODES['${bts_id}']['software_active']}    ${bts_id}
    ...  AND   Set To Dictionary    ${cfg.NODES['${bts_id}']}    software_active_file=${software_active_file}    AND
    ...  AND   Run Keyword And Ignore Error    Wait Sw Update Possible
    ...     bts_ready=True
    ...     readiness_timeout=750
    ...     timeout=800
    ...     connection=${bts_id}     AND
    ...  AND   Update Software  sw_package=${software_package_path}  timeout=${CONFIGURATION_SWUPDATE_TIMEOUT}  alias=${BTS_ID}
    ...  AND   Sleep   60
    ...  AND   SM Port And Cablnk Detection                              fr_serial_number=${fr_serial_number}
    ...                                                       expected_cablnk_count=${expected_cablnk_count}   alias=${alias}
    ...  AND   Info Model Wait For Specific RF State RMOD_L Object       fr_serial_number=${fr_serial_number[0]}
    ...                                                       fr_state_to_be_checked=stateInfo.availabilityStatus=Online
    ...                                                       timeout=60    alias=${alias}
    ...  AND   Info Model Wait For Specific RF State RU_L Object         fr_serial_number=${fr_serial_number[0]}
    ...                                                       fr_state_to_be_checked=stateInfo.availabilityStatus=Online
    ...                                                       timeout=120    alias=${alias}
#    Info Model Check SM Ports Led Color                       port_number=${OUT_SM_PORT_LIST}
#    ...                                                       led_state_to_be_check=Green     alias=${alias}
    Info Model Wait For Specific RF State RU_L Object         fr_serial_number=${fr_serial_number[0]}
    ...                                                       fr_state_to_be_checked=stateInfo.operationalState=Enabled
    ...                                                       timeout=120    alias=${alias}
    Info Model Wait For Specific RF State RMOD_L Object       ${fr_serial_number[0]}
    ...                                                       fr_state_to_be_checked=stateInfo.operationalState=Enabled
    ...                                                       timeout=10   alias=${alias}
    Info Model Wait For Specific RF State RU_L Object         fr_serial_number=${fr_serial_number[0]}
    ...                                                       fr_state_to_be_checked=stateInfo.proceduralState=${proceduralState}
    ...                                                       timeout=10    alias=${alias}
    Info Model Wait For Specific RF State RMOD_L Object       ${fr_serial_number[0]}
    ...                                                       fr_state_to_be_checked=stateInfo.proceduralState=ethernetEnabled
    ...                                                       timeout=10   alias=${alias}
    Sleep     60
    Alarm detection                                      fault_id=1807      alias=${alias}
    ...                                                  fault_details=${MANDATORY_ALARM_ADMIN_INVALID_FREQUENCY_CHANNEL}
    ...                                                  fault_count=${cell_count_for_configuration}
    Log To Console  FR ${fr_serial_number[0]} autodetection finished successfully, Fault 1807 is active!

Block FR Autodetection
    [Arguments]    ${fr_serial_number}   ${alias}
    SM Port And Cablnk Detection                              fr_serial_number=${fr_serial_number}
    ...                                                       expected_cablnk_count=${OUT_EXPECTED_CABLINK_COUNT}   alias=${alias}
    Info Model Wait For Specific RF State RMOD_L Object       fr_serial_number=${fr_serial_number[0]}
    ...                                                       fr_state_to_be_checked=stateInfo.availabilityStatus=Online
    ...                                                       timeout=60    alias=${alias}
    Info Model Wait For Specific RF State RU_L Object         fr_serial_number=${fr_serial_number[0]}
    ...                                                       fr_state_to_be_checked=stateInfo.availabilityStatus=Online
    ...                                                       timeout=120    alias=${alias}
    Info Model Wait For Specific RF State RU_L Object         fr_serial_number=${fr_serial_number[0]}
    ...                                                       fr_state_to_be_checked=stateInfo.operationalState=Enabled
    ...                                                       timeout=60    alias=${alias}
    Info Model Wait For Specific RF State RMOD_L Object       ${fr_serial_number[0]}
    ...                                                       fr_state_to_be_checked=stateInfo.operationalState=Enabled
    ...                                                       timeout=60   alias=${alias}
    Verify RU Block Unblock State    ${RU_BTS_ID}    ${RU_DIST_NAME}    Blocked   90 sec
    Log to console                                            FR: ${fr_serial_number} locked

FR with blocked cells Autodetection
    [Arguments]    ${fr_serial_number}   ${alias}
    SM Port And Cablnk Detection                              fr_serial_number=${fr_serial_number}
    ...                                                       expected_cablnk_count=${expected_cablnk_count}   alias=${alias}
    Info Model Wait For Specific RF State RMOD_L Object       fr_serial_number=${fr_serial_number[0]}
    ...                                                       fr_state_to_be_checked=stateInfo.availabilityStatus=Online
    ...                                                       timeout=60    alias=${alias}
    Info Model Wait For Specific RF State RU_L Object         fr_serial_number=${fr_serial_number[0]}
    ...                                                       fr_state_to_be_checked=stateInfo.availabilityStatus=Online
    ...                                                       timeout=120    alias=${alias}
    Info Model Wait For Specific RF State RU_L Object         fr_serial_number=${fr_serial_number[0]}
    ...                                                       fr_state_to_be_checked=stateInfo.operationalState=Enabled
    ...                                                       timeout=10    alias=${alias}
    Info Model Wait For Specific RF State RMOD_L Object       ${fr_serial_number[0]}
    ...                                                       fr_state_to_be_checked=stateInfo.operationalState=Enabled
    ...                                                       timeout=10   alias=${alias}
    Info Model Wait For Specific RF State RU_L Object         fr_serial_number=${fr_serial_number[0]}
    ...                                                       fr_state_to_be_checked=stateInfo.proceduralState=${proceduralState}
    ...                                                       timeout=10    alias=${alias}
    Info Model Wait For Specific RF State RMOD_L Object       ${fr_serial_number[0]}
    ...                                                       fr_state_to_be_checked=stateInfo.proceduralState=ethernetEnabled
    ...                                                       timeout=10   alias=${alias}
    Cell Should Be Blocked                                    ${lcr_id_list[${cell_index}]}
    Info Model Wait For Alarm                                 ${GLO_CELL_BLOCKED_FAULT_ID}     ${GLO_CELL_BLOCKED_FAULT_COUNT}
    ...                                         ${GLO_CELL_BLOCKED_FAULT_TIMEOUT}   act_category_alarms=${ACT_CATEGORY_ALARMS}
    Alarms Expected Detection                                 mandatory_alarms=${GLO_CELL_BLOCKED_FAULT_COUNT}
    ...                                                       fr_serial_number=${fr_serial_number}
    ...                                                       alias=${alias}
    log to console               \nCell ${lcr_id_list[${cell_index}]} blocked

FR Autodetection With Not Enough Link Capasity
    [Arguments]    ${fr_serial_number}    ${alias}
    Info Model Wait For Specific RF States RU_L Object    fr_serial_number=${fr_serial_number[0]}
    ...                                                   operationalState=Enabled
    ...                                                   availabilityStatus=Online
    ...                                                   timeout=180    alias=${alias}
#    Wait Until Keyword Succeeds  3min  1s                 Info Model Check Resoning Status Of Disabled Cell
#    ...                                                   reasoningStatus=NotEnoughThroughput
    ${Out_expected_count}=  evaluate   ${OUT_CELL_COUNT_FOR_CONFIGURATION}-1
    Info Model Wait For Cell Count in Specific States     operationalState=Enabled
    ...                                                   availabilityStatus=Online
    ...                                                   proceduralState=OnAirDone
    ...                                                   expected_cell_count=${Out_expected_count}
    ...                                                   timeout=800   alias=${alias}
    Alarm detection                                       fault_id=1868      alias=${alias}
    ...                                                   fault_details=${MANDATORY_ALARMS_ADMIN_NOT_ENOUGH_HW_FOR_LCR}
    ...                                                   timeout=800
    Info Model LNBTS Should Be In Degraded State          state=Degraded   timeout=10
    Log to console     Fault 1868 is active!

Configuration link removal detection
    [Arguments]    ${fr_serial_number}    ${sm_port_test_list}     ${cablink_test_list}        ${alias}
    ...            ${sm_port_list}=${OUT_SM_PORT_LIST}     ${cablink_list}=${OUT_CABLINK_LIST}
    ...            ${cell_count_for_configuration}=${OUT_CELL_COUNT_FOR_CONFIGURATION}
    ...            ${expected_cablnk_count}=${OUT_EXPECTED_CABLINK_COUNT}
    ...            ${not_enought_link_capacity_test_case}=False    ${proceduralState}=swCheckDone
    FR Removal Detection                                 fr_serial_number=${fr_serial_number[0]}
    ...                                                  sm_port_list=${sm_port_list}
    ...                                                  cablink_list=${cablink_list}
    ...                                                  alias=${alias}
    Disabled Optical Links Detection                     cablink_list=${OUT_CONF_CABLINK_LIST}
    ...                                                  sm_port_list=${OUT_CONF_SM_PORT_LIST}
    ...                                                  alias=${alias}
    ${Out_expected_cell_count}=  evaluate   ${cell_count_for_configuration}-1
    ${Out_expected_cablink_count}=  evaluate   ${expected_cablnk_count}-1
    FR Autodetection                                     fr_serial_number=${fr_serial_number}
    ...                                                  alias=${alias}
    ...                                                  cell_count_for_configuration=${Out_expected_cell_count}
    ...                                                  expected_cablnk_count=${Out_expected_cablink_count}
    Log to Console                                       Configuration link removal correctly detected.

Data link removal detection
    [Arguments]    ${fr_serial_number}    ${sm_port_test_list}     ${cablink_test_list}        ${alias}
    ...            ${expected_cablnk_count}=${OUT_EXPECTED_CABLINK_COUNT}
    ...            ${fault_2002}=${RECEIFING_FAILURE_IN_OPT_INTERFACE_2002_critical}
    ...            ${proceduralState}=swCheckDone     ${data_links}=${OUT_DATA_CABLINK_LIST}
    ...            ${cell_count_for_configuration}=${OUT_CELL_COUNT_FOR_CONFIGURATION}
    ${Out_expected_cell_count}=  evaluate   ${cell_count_for_configuration}-1
    ${number_data_links}=      get length     ${data_links}
    ${Out_expected_cablink_count}=  evaluate   ${expected_cablnk_count}-${number_data_links}
    ${OUT_cell_count}=  Run Keyword If   ${fault_2002}==${RECEIFING_FAILURE_IN_OPT_INTERFACE_2002_critical}
    ...                                  Set Variable  ${Out_expected_cell_count}
    ...   ELSE                           Set Variable  ${cell_count_for_configuration}
    FR Autodetection                                     fr_serial_number=${fr_serial_number}
    ...                                                  alias=${alias}
    ...                                                  cell_count_for_configuration=${OUT_cell_count}
    ...                                                  expected_cablnk_count=${Out_expected_cablink_count}
    Info Model Wait For Alarm                            fault_id=2002
    ...                                                  fault_count=1
    ...                                                  timeout=400    alias=${alias}
    ...                                                  act_category_alarms=${ACT_CATEGORY_ALARMS}
    Info Model Check Severity                            fault_id=1868
    ...                                                  alias=${alias}
    Run Keyword If     ${SEVERITY}=="Critical"          Run Keywords
    ...   Add Mandatory Alarm                           fault_details=${fault_2002}
    ...   AND   Run Keyword if     ${number_data_links}==2
    ...   Alarm detection                                fault_id=2002      alias=${alias}
    ...                                                  fault_details=${RECEIFING_FAILURE_IN_OPT_INTERFACE_2002}
    ...                                                  fault_count=${number_data_links}
    ...   ELSE       Run Keywords
    ...   Alarm detection                                fault_id=2002      alias=${alias}
    ...                                                  fault_details=${RECEIFING_FAILURE_IN_OPT_INTERFACE_2002}
    ...                                                  fault_count=${number_data_links}
    ...   AND   Alarm detection                          fault_id=1868      alias=${alias}
    ...                                                  fault_details=${MANDATORY_ALARMS_ADMIN_NOT_ENOUGH_HW_FOR_LCR}
    ...                                                  timeout=5


SM Port Not Used Detection
    [Arguments]  ${fr_serial_number}  ${expected_cablnk_count}=${OUT_EXPECTED_CABLINK_COUNT}   ${alias}=default    ${timeout}=10
    SM Port And Cablnk Detection        fr_serial_number=${fr_serial_number}   expected_cablnk_count=${expected_cablnk_count}   alias=${alias}
    ${active_ports}=    Set Variable    ${OUT_SM_PORT_LIST}
    ${sm_port_list}=    Create List    1    2    3
    FOR    ${item}    IN    @{active_ports}
       ${item}=   convert to string   ${item}
       remove values from list     ${sm_port_list}    ${item}
    END
    Set Test Variable   ${OUT_NOT_USED_SM_PORT_LIST}    ${sm_port_list}
    Set Test Variable   ${OUT_NOT_USED_SM_PORT}    ${sm_port_list[0]}
    Log To Console  \nNot used SM port: ${OUT_NOT_USED_SM_PORT}

Data Optical Link Detection
    [Arguments]    ${fr_serial_number}    ${alias}    ${timeout}=10
    ${path_rmod_under_test}=    Info Model Create Rmod Path For Fr Serial Number    fr_serial_number=${fr_serial_number}
    ...                                                                             alias=${alias}   timeout=${timeout}
    ${cablink_list}=    Info Model Create Cablnk List For Data Links    source_dist_name_list=${path_rmod_under_test}
    ...                                                                 alias=${alias}    timeout=${timeout}
    ${sm_port_list}=    Info Model Create SM Ports List For Cablnks    cablnk_list=${cablink_list}    alias=${alias}
    ...                                                                timeout=${timeout}
    Run Keyword If    "${SW_REL_TESTED_TRUNK_TAG}"=="FSM3"    Run Keywords
    ...    SM Port List For FSMr3       ${sm_port_list}
    ...    AND     Set Test Variable    ${OUT_DATA_SM_PORT_LIST}    ${OUT_SM_PORT_LIST}
    ...    ELSE    Set Test Variable    ${OUT_DATA_SM_PORT_LIST}    ${sm_port_list}
    Set Test Variable    ${OUT_DATA_CABLINK_LIST}    ${cablink_list}
    Log To Console    \nData optical link is connected to port: ${OUT_DATA_SM_PORT_LIST[0]}

Data And Config Optical Link Detection
    [Arguments]    ${fr_serial_number}    ${alias}    ${timeout}=10
    ${path_rmod_under_test}=    Info Model Create Rmod Path For Fr Serial Number    fr_serial_number=${fr_serial_number}
    ...                                                                             alias=${alias}   timeout=${timeout}
    ${cablink_list}=    Info Model Get Cablnk Path For Data And Config Link
    ...                                                  source_dist_name_list=${path_rmod_under_test}    alias=${alias}
    ${sm_port_list}=    Info Model Create SM Ports List For Cablnks      cablnk_list=${cablink_list}    alias=${alias}
    Run Keyword If    "${SW_REL_TESTED_TRUNK_TAG}"=="FSM3"    Run Keywords
    ...    SM Port List For FSMr3       ${sm_port_list}
    ...    AND     Set Test Variable    ${OUT_CONF_SM_PORT_LIST}    ${OUT_SM_PORT_LIST}
    ...    ELSE    Set Test Variable    ${OUT_CONF_SM_PORT_LIST}    ${sm_port_list}
    Set Test Variable    ${OUT_CONF_CABLINK_LIST}    ${cablink_list}
    Log To Console    \nData and config optical link is connected to port: ${OUT_CONF_SM_PORT_LIST[0]}

Check and set Config Link To Port One
    [Arguments]    ${fr_serial_number}    ${alias}    ${switch_ip}=${OUT_SWITCH_IP}    ${timeout}=10
    Run Keyword If    "${OUT_CONF_SM_PORT_LIST[0]}"!="1"     Run Keywords
    ...    Log to console    "${OUT_CONF_SM_PORT_LIST[0]}"!="1"
    ...    AND   Change Switch Settings                              switch_settings=1-4,2-4,3-4
    ...    AND   Alarm detection                                    fault_id=10      alias=${alias}
    ...                                                  fault_details=${MANDATORY_ALARM_NO_CONNECTION_TO_UNIT}
    ...    AND   Change Switch Settings                              switch_settings=1-1,2-4,3-4
    ...    AND   Sleep   30
    ...    AND   Change Switch Settings                              switch_settings=1-1,2-2,3-4
    ...    AND   FR Autodetection                                  ${fr_serial_number}    ${alias}
    ...    AND   Data And Config Optical Link Detection            ${fr_serial_number}    ${alias}   timeout=60
    Should Be Equal    "${OUT_CONF_SM_PORT_LIST[0]}"       "1"

Detected additional faults
    [Arguments]    ${alias}
    Log To Console                                       Check for additional faults
    Save Infomodel Log                                   ${OUT_TESTCASE_LOGS_DIR_PATH}infomodel_${alias}.ims2
    ...                                                  alias=${alias}
    ${alarms_available}=  Ims2 Get All Alarms            ims2_file_path=${OUT_TESTCASE_LOGS_DIR_PATH}infomodel_${alias}.ims2
    ...                                                  alias=${alias}
    ...                                                  act_category_alarms=${ACT_CATEGORY_ALARMS}
    Info Model Alarms Check                              available=${alarms_available}    allowed=${GLO_ALLOWED_ALARMS}
    ...                                                  mandatory=${OUT_MANDATORY_ALARMS_LIST}

Detected additional faults block
    [Arguments]    ${fr_serial_number}    ${alias}
    Mandatory And Allowed Alarms Should Be As Expected    btssm_alarms_file_name=BtsSmAlarms\-FrUnderTestBlockUnblock.xml
    ...                                                   alias=${alias}
    Ims2 FSM Should Not Be Rebooted                      ims2_file_path=${OUT_TESTCASE_LOGS_DIR_PATH}infomodel_${alias}.ims2
    ...                                                  alias=${alias}

Hot Remove Insert FR With Block Cell
    [Arguments]    ${lcr_id_list}    ${lncel_id_list}    ${cell_index}
    ...   ${fr_serial_number}=${OUT_CURRENT_FR_SERIAL_NUMBERS}    ${alias}=${TC_ALIAS}
    Cell Should Be Unblocked     ${lncel_id_list[${cell_index}]}    alias=${alias}
    Perform Cell Block    ${BTS_ID}    ${lncel_id_list[${cell_index}]}    LNCEL    30
    Cell Should Be Blocked       ${lncel_id_list[${cell_index}]}    alias=${alias}
    Info Model Wait For Alarm    ${GLO_CELL_BLOCKED_FAULT_ID}     ${GLO_CELL_BLOCKED_FAULT_COUNT}
    ...                          timeout=10   act_category_alarms=${ACT_CATEGORY_ALARMS}    alias=${alias}
    log to console               \nCell ${lcr_id_list[${cell_index}]} blocked
    ${out_tmp_cell_list}=        Create List
    Append To List    ${out_tmp_cell_list}    ${lcr_id_list[${cell_index}]}
    ${out_expected_cell_count}=  evaluate    ${OUT_CELL_COUNT_FOR_CONFIGURATION}-1
    FR Autodetection             fr_serial_number=${OUT_CURRENT_FR_SERIAL_NUMBERS}
    ...                          alias=${alias}
    ...                          cell_count_for_configuration=${out_expected_cell_count}
    SM Port And Cablnk Detection                         fr_serial_number=${OUT_CURRENT_FR_SERIAL_NUMBERS}    alias=${alias}
    Hot Remove Optical Links
    FR Removal Detection         fr_serial_number=${fr_serial_number[0]}
    ...                          sm_port_list=${OUT_SM_PORT_LIST}
    ...                          cablink_list=${OUT_CABLINK_LIST}
    ...                          cell_count_for_configuration=${OUT_CELL_COUNT_FOR_CONFIGURATION}
    ...                          alias=${alias}
    Info Model Wait For Alarm    ${GLO_CELL_BLOCKED_FAULT_ID}
    ...                          ${GLO_CELL_BLOCKED_FAULT_COUNT}
    ...                          ${GLO_CELL_BLOCKED_FAULT_TIMEOUT}
    ...                          act_category_alarms=${ACT_CATEGORY_ALARMS}
    ...                           alias=${alias}
    Alarm detection                                      fault_id=49      alias=${alias}
    ...                                                  fault_details=${MANDATORY_ALARM_FAULT_ID_49_SCHEME}
    Hot Insert Optical Links
    FR Autodetection             fr_serial_number=${fr_serial_number}
    ...                          alias=${alias}
    ...                          cell_count_for_configuration=${out_expected_cell_count}
    Info Model Wait For Alarm    ${GLO_CELL_BLOCKED_FAULT_ID}
    ...                          ${GLO_CELL_BLOCKED_FAULT_COUNT}
    ...                          ${GLO_CELL_BLOCKED_FAULT_TIMEOUT}
    ...                          act_category_alarms=${ACT_CATEGORY_ALARMS}
    ...                         alias=${alias}
    Alarm detection                                      fault_id=49      alias=${alias}
    ...                                                  fault_details=${MANDATORY_ALARM_FAULT_ID_49_SCHEME}
    Perform Cell Unblock         ${BTS_ID}    ${lncel_id_list[${cell_index}]}    LNCEL    30
#    Unblock Selected Cell        ${lncel_id_list[${cell_index}]}
    Cell Should Be Unblocked      ${lncel_id_list[${cell_index}]}     alias=${alias}
    Info Model Wait For Cell Count in Specific States    operationalState=Enabled
    ...                                                  availabilityStatus=Online
    ...                                                  proceduralState=OnAirDone
    ...                                                  expected_cell_count=${OUT_CELL_COUNT_FOR_CONFIGURATION}
    ...                                                  timeout=60
    ...                                                   alias=${alias}
    log to console     \nCell ${lcr_id_list[${cell_index}]} unblocked
    log to console     \nCell ${lcr_id_list[${cell_index}]}: Tested

    [Teardown]    Run Keywords
    ...     Unblock Selected Cell If Blocked    ${lcr_id_list[${cell_index}]}     alias=${alias}
    ...     AND    Hot Insert Optical Links

Remove HWF
    [Arguments]    ${sm_sn}=${CURRENT_SM_SERIAL_NUMBERS}    ${bts_conf}=${EMPTY}
    Setup eNB Fsm Access
    ${ls_res}=   Execute command on enb     ls -al /rom/config
    Execute command on enb     rm /rom/config/hwf.bin.gz
    ${ls_res}=   Execute command on enb     ls -al /rom/config
    log to console      Turn off BTS
    PDU Switch OFF Device Lists       ${sm_sn}
    run keyword and ignore error    Teardown Enb Fsm Access

Alarm detection
    [Arguments]    ${fault_id}     ${alias}    ${fault_details}     ${timeout}=600
    ...            ${fault_count}=${OUT_FAULT_COUNT}
    Info Model Wait For Alarm                            fault_id=${fault_id}
    ...                                                  fault_count=${fault_count}
    ...                                                  timeout=${timeout}    alias=${alias}
    ...                                                  act_category_alarms=${ACT_CATEGORY_ALARMS}
    Add Mandatory Alarm                                  ${fault_details}
    Log to console         Fault ${fault_id} is detected!

Add Mandatory Alarm
    [Arguments]    ${fault_details}
    @{mandatory_alarms_list}=   Info Model Create Mandatory Alarms List      ${OUT_LNCELID_LIST}
    ...                                                   ${fault_details}
    ...                                                   ${ACT_CATEGORY_ALARMS}
    ${OUT_MANDATORY_ALARMS_LIST}=    Convert to list   ${OUT_MANDATORY_ALARMS_LIST}
    ${all_alarms}=         Combine Lists   ${OUT_MANDATORY_ALARMS_LIST}    ${mandatory_alarms_list}
    Set Test Variable      ${OUT_MANDATORY_ALARMS_LIST}        ${all_alarms}

Add Alarm for All Cells
    [Arguments]    ${fault_details}
    FOR   ${index}    IN   @{OUT_LCR_ID_LIST_FOR_FR_UNDER_TEST}
         Add Mandatory Alarm   ${fault_details}
    END

Info Model Check Severity
    [Arguments]    ${fault_id}   ${timeout}=60   ${act_category_alarms}=False
    ...            ${bts_l_id}=*    ${alias}=default
    ${a}  ${b}=  run keyword and ignore error
    ...    Query InfoModel    query=check //FRI-${bts_l_id}/ALARM-* is [faultId=regex"^${fault_id}(?:$|\\D)"]
    ...    timeout=${timeout}    alias=${alias}
    Run Keyword If   '${a}' == 'PASS'
    ...    Set Test Variable     ${SEVERITY}    "Minor"
    ...    ELSE   Set Test Variable     ${SEVERITY}    "Critical"
    Log to console     2002 is detected as ${SEVERITY}

Check SFP Status
    [Arguments]    ${sfp_number}   ${sfp_value}
        SSHLibrary.write    get_sfp_status ${sfp_number}
        Sleep  2
        ${output} =  SSHLibrary.Read
        ${rx_value}=  Get Lines Matching Pattern   ${output}   SFP Rx Power(mW)=*
        ${signal_value}=   Split String   ${rx_value}   =${SPACE}${SPACE}
        Should Be True    ${signal_value[1]} >= ${sfp_value}

Get SFP status
    [Arguments]    ${sfp_number}   ${sfp_value}   ${HW}   ${timeout}=20 min
    Log to console    Check ${HW} signal
    SSHLibrary.open connection    10.42.170.220
        SSHLibrary.login    nsn    nsn
        SSHLibrary.write    start
        Sleep  1
        SSHLibrary.write    tk
        Sleep  1
        SSHLibrary.write    tk
        Sleep  1
        Wait Until Keyword Succeeds   ${timeout}   1 s    Check SFP Status  ${sfp_number}   ${sfp_value}
        SSHLibrary.Close Connection

Turn on/off and check Signal
    [Arguments]    ${list}    ${rm1_sfp_number}    ${rm1_sfp_value}=0.0   ${turn}=off    ${bts_sfp_number}=1
    ...            ${bts_sfp_value}=0.0     ${rm2_sfp_number}=6   ${rm2_sfp_value}=0.0   ${timeout}=20 min
    ${RF_number}=   get length  ${OUT_CURRENT_FR_SERIAL_NUMBERS}
    Run Keyword If   "${turn}"=="off"
    ...  PDU Switch OFF Device Lists       ${list}
    ...  ELSE   PDU Switch On Device Lists    ${list}
    Run Keyword If   "${RF_number}"=="2"   Run Keywords
     ...  Get SFP status                           sfp_number=${rm1_sfp_number}     sfp_value=${rm1_sfp_value}    HW=rm1
     ...  AND  Get SFP status                      sfp_number=${rm2_sfp_number}     sfp_value=${rm2_sfp_value}    HW=rm2
     ...  ELSE   Get SFP status                           sfp_number=${rm1_sfp_number}     sfp_value=${rm1_sfp_value}    HW=rm1

Chang x-point settings
    ${ALL_DEVICES}=  combine lists  ${OUT_CURRENT_FR_SERIAL_NUMBERS}   ${CURRENT_SM_SERIAL_NUMBERS}
    FOR  ${index}  IN   @{ALL_DEVICES}
         ${port}=   Get Lines Matching Regexp   "inport = *${\n}rate = *${\n}user = admin${\n}comment = ${index}_*_port1"
         Replace Variables In File  ${CONF_OX}      rate = RP3-8x    ${port}
    END



Slim Carrier Activation Without Filters
    [Arguments]  ${scfc_file_path}=${OUT_SCFC_CURRENT_FILE_PATH}
    ...          ${log_dir_path}=/home/ute/logs    ${numBlankDlPrbsDown}=7  ${numBlankDlPrbsUp}=7
    ${out_lcr_id_list}=     SCFC Create LcrId List       scfc_file_path=${OUT_SCFC_CURRENT_FILE_PATH}
    Set Suite Variable      ${OUT_LCR_ID_LIST_FOR_FR_UNDER_TEST}      ${out_lcr_id_list}
    ${out_lncel_id_list}=   SCFC Create LncelId List For LcrdId List
    ...                                                  scfc_file_path=${OUT_SCFC_CURRENT_FILE_PATH}
    ...                                                  lcr_id_list=${out_lcr_id_list}
    Set Test Variable      ${OUT_LNCEL_ID_LIST}      ${out_lncel_id_list}
    Log To Console   Slim Carrier Activation
    Create Delta
    ${blankedPucch}=  Evaluate  ${numBlankDlPrbsDown}+${numBlankDlPrbsUp}
    FOR   ${index}   IN   @{out_lncel_id_list}
      Append Parameter Update To Delta    dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${index}/LNCEL_FDD-0
       ...    parameter=actDlSlimCarrier   value=true
      Append Parameter Update To Delta   dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${index}
       ...    parameter=dlsDciCch    value=DCI format 1A
      Append Parameter Update To Delta    dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${index}/LNCEL_FDD-0
       ...    parameter=numBlankDlPrbsDown  value=${numBlankDlPrbsDown}
      Append Parameter Update To Delta   dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${index}/LNCEL_FDD-0
       ...    parameter=numBlankDlPrbsUp    value=${numBlankDlPrbsUp}
    END
    Create Directory                  ${log_dir_path}/slim/
    Save Delta                        ${log_dir_path}/slim/slim_activation.json
    Perform Delta Recommissioning     ${log_dir_path}/slim/slim_activation.json
    ...                               skip_parameter_relation_errors=True
    ...                               alias=${alias}
    [Teardown]   Teardown Delta Recommissioning  ${KEYWORD_STATUS}

Add/Remove Flags on RM
    [Arguments]    ${add/remove}    ${rf_serial_number}     ${alias}
    Open Connection To Radio Module With Serial Number
    ...  rmod_serial_number=${rf_serial_number}
    ...  alias=${RU_BTS_ID}
    LOG  \nConnected to Radio   console=True
    ${active_processes}=  Send Command and return output
    ...  command=rad -pw 0x1e2 ${add/remove}
    ...  prompt=$
    LOG  \nFlag command executed. Value changed to ${add/remove}  console=True
    PDU Switch OFF Device Lists     ${OUT_CURRENT_FR_SERIAL_NUMBERS}
    LOG  \nPDU Turned Off   console=True
    Alarm detection                                      fault_id=10      alias=${alias}
    ...                                                  fault_details=${MANDATORY_ALARM_NO_CONNECTION_TO_UNIT}
    PDU Switch On Device Lists     ${OUT_CURRENT_FR_SERIAL_NUMBERS}
    LOG  \nPDU Turned On. \nWaiting for Radio to be Online.   console=True
    Assert Every    RMOD    operationalState=regex"\[Ee\]nabled", productName=FRMB   timeout=120   alias=${alias}
    LOG  \nFR ${rf_serial_number[0]} autodetection finished successfully!   console=True
    [Teardown]   Close SSH Connection




Teardown Delta Recommissioning
    [Arguments]   ${status}
    Run Keyword And Ignore Error  admin.Remove Delta
    Run Keyword If   "${status}"=="FAIL"  Log  Something went wrong with Delta Recommissioning  ERROR

Throughput Comparison
    [Arguments]         ${ulChBw}=15   ${slimChBw}=12.4
    ${value}=    SCFC Get Activate Category Alarms Value    ${scfc_file_path}
    ${cells_number}=   Get Length    ${OUT_LCR_ID_LIST_FOR_FR_UNDER_TEST}
    Set Suite Variable    ${ACT_CATEGORY_ALARMS}    ${value}
    FOR   ${index}   IN RANGE   ${cells_number}
       ${cell}=   Evaluate    ${index}-1
       ${ulChBw_real}=    Evaluate Xpath    ${scfc_file_path}
        ...   .//managedObject[@class='NOKLTE:LNCEL_FDD' and contains(@distName, "LNCEL-${OUT_LNCEL_ID_LIST[${cell}]}")]/p[@name='ulChBw']/text()
        ${ulChBw}=   Split String   ${ulChBw_real[0]}   ${SPACE}
        ${dl_1}=   Get From Dictionary    ${DL_THROUGHPUTS_1}    ${OUT_LCR_ID_LIST_FOR_FR_UNDER_TEST[${cell}]}
        ${dl_1}=   Set Variable   ${dl_1[0]}
        ${ul_1}=   Get From Dictionary    ${UL_THROUGHPUTS_1}    ${OUT_LCR_ID_LIST_FOR_FR_UNDER_TEST[${cell}]}
        ${ul_1}=   Set Variable   ${ul_1[0]}
        ${dl_2}=   Get From Dictionary    ${DL_THROUGHPUTS_2}    ${OUT_LCR_ID_LIST_FOR_FR_UNDER_TEST[${cell}]}
        ${dl_2}=   Set Variable   ${dl_2[1]}
        ${ul_2}=   Get From Dictionary    ${UL_THROUGHPUTS_2}    ${OUT_LCR_ID_LIST_FOR_FR_UNDER_TEST[${cell}]}
        ${ul_2}=   Set Variable   ${ul_2[1]}
        ${dl_3}=   Get From Dictionary    ${DL_THROUGHPUTS_3}    ${OUT_LCR_ID_LIST_FOR_FR_UNDER_TEST[${cell}]}
        ${dl_3}=   Set Variable   ${dl_3[2]}
        ${ul_3}=   Get From Dictionary    ${UL_THROUGHPUTS_3}    ${OUT_LCR_ID_LIST_FOR_FR_UNDER_TEST[${cell}]}
        ${ul_3}=   Set Variable   ${ul_3[2]}
        ${ul_down}=    Evaluate   ((${slimChBw}*${ul_1})/${ulChBw[0]})*0.8
        ${ul_up}=      Evaluate   ((${slimChBw}*${ul_1})/${ulChBw[0]})*1.3
        ${result_ul2}=        evaluate  ${ul_down}< ${ul_2} < ${ul_up}
        run keyword if    '${result_ul2}'=='True'     LOG  UL:${ul_1} and Slim UL:${ul_2}
        run keyword if    '${result_ul2}'=='False'    run keyword and continue on failure    FAIL
        ${result_ul3}=        evaluate  ${ul_1}*0.9 < ${ul_3} < ${ul_1}*1.1
        run keyword if    '${result_ul3}'=='True'     LOG  UL before:${ul_1} and UL after:${ul_3}
        run keyword if    '${result_ul3}'=='False'    run keyword and continue on failure    FAIL
        ${result_dl3}=        evaluate  ${dl_1}*0.9 < ${dl_3} < ${dl_1}*1.1
        run keyword if    '${result_dl3}'=='True'     LOG  DL before:${dl_1} and DL after:${dl_3}
        run keyword if    '${result_dl3}'=='False'    run keyword and continue on failure    FAIL
        ${dl_down}=    Evaluate   ((${slimChBw}*${dl_1})/${ulChBw[0]})*0.8
        ${dl_up}=      Evaluate   ((${slimChBw}*${dl_1})/${ulChBw[0]})*1.3
        ${result_dl2}=        evaluate  ${dl_down} < ${dl_2} < ${dl_up}
        run keyword if    '${result_dl2}'=='True'     LOG  DL:${dl_1} and Slim DL:${dl_2}
        run keyword if    '${result_dl2}'=='False'    run keywords
         ...    LOG    ${dl_down} < ${dl_2} < ${dl_up}  it's not true   console=true
         ...    AND    run keyword and continue on failure    FAIL
     END

UE recovery
    ${ue_aliasses}  ${ue_aliasses_list}=    Get All Ue Aliases from YML file
    ${ue_dict}=   Get Yaml File Into Dict    ${UTE_UE_CONFIG}
    ${UEPC_IP}=   Get From Dictionary
    ...  ${ue_dict['UE_POOLS']['AndroidUePool']['inline_config']['${ue_aliasses_list[0]}']['CONSTRUCTOR_PARAMETERS']['configuration']}   ue_pc_ip
    ${UE_id}=   Get From Dictionary
    ...  ${ue_dict['UE_POOLS']['AndroidUePool']['inline_config']['${ue_aliasses_list[0]}']['CONSTRUCTOR_PARAMETERS']}   serial_number
    SSHLibrary.open connection    ${UEPC_IP}  timeout=30
        SSHLibrary.login    username=plwr4gsiso    password=Ut3pa5s#1be1
        Sleep  5
        SSHLibrary.write    adb -s ${UE_id} kill-server
        Sleep  25
        SSHLibrary.write    adb -s ${UE_id} shell settings put global airplane_mode_off 1
        Sleep  5
        SSHLibrary.write    adb -s ${UE_id} shell settings put global mobile_data_on 1
        Sleep  5
    SSHLibrary.Close Connection

BTS Should Be Accessible
    [Arguments]    ${timeout}=300
    wait until keyword succeeds         ${timeout}    10    BTS Address Is Pingable   ${ENB_IP_ADDRESS}
    wait until keyword succeeds         ${timeout}    10    SSH Is Reachable      ${ENB_IP_ADDRESS}


SSH Is Reachable
    [Arguments]  ${host_ip_addr}
    ${out_rc}  ${output}=  run and return rc and output
    ...     sshpass -p oZPS0POrRieRtu ssh -o "StrictHostKeyChecking no" -o "UserKnownHostsFile=/dev/null" ${host_ip_addr} 'ls'
    log  ${output}
    should be equal as integers  ${out_rc}  0

Cell Should Be Blocked
    [Arguments]    ${cell_id}    ${timeout}=15   ${alias}=default
    [Documentation]  Check in Info Model if Cell is blocked and other parameters. Required parameters ${cell_id} and ${alias}
    ${dist_name}=    Get From Dictionary    ${cfg.NODES['${BTS_ID}']['LNCEL']['${cell_id}']}    dist_name
    ${dist_name}=    Convert To String    ${dist_name}
    Verify Cell State    ${BTS_ID}    ${cell_id}    ${dist_name}   Blocked    LNCEL    ${timeout}
    ${lcr_id}=    get from dictionary    ${cfg.NODES['${BTS_ID}']['LNCEL']['${cell_id}']}    lcr_id
    ${fault_49_count}=    Set Variable If   "${CELL_INFO['${lcr_id}']['slave_lcr_id']}"!="${EMPTY}"    2    1
    Info Model Wait For Alarm                           fault_id=49
    ...                                                 fault_count=${fault_49_count}
    ...                                                 timeout=15
    ...                                                 act_category_alarms=${ACT_CATEGORY_ALARMS}
    ...                                                 alias=${alias}

Cell Should Be Unblocked
    [Arguments]    ${cell_id}    ${timeout}=70    ${alias}=${alias}
    [Documentation]  Check in Info Model if Cell is blocked and other parameters. Required parameters ${lcr_id} and ${alias}
    ${dist_name}=    Get From Dictionary    ${cfg.NODES['${BTS_ID}']['LNCEL']['${cell_id}']}    dist_name
    ${dist_name}=    Convert To String    ${dist_name}
    Verify Cell State    ${BTS_ID}    ${cell_id}    ${dist_name}   Unblocked    LNCEL    ${timeout}

Unblock Selected Cell If Blocked
    [Arguments]    ${cell_id}   ${alias}=${TC_ALIAS}    ${scfc_file_path}=${OUT_SCFC_CURRENT_FILE_PATH}
    ${lncel_id}=    SCFC Get Lncel Or Parent Lncel List For Lcrid    scfc_file_path=${scfc_file_path}    lcr_id=${cell_id}
    ${lncel_distname}=    Info Model Get LNCEL DistName For Given BtsId And LncelId      ${BTS_ID}    ${lncel_id}    alias=${alias}
    ${cell_is_blocked}=    Run Keyword And Return Status    admin.Assert    LNCEL    ${lncel_distname}    blockingState=Blocked    alias=${alias}
    Run Keyword If    ${cell_is_blocked}   Perform Cell Unblock    ${BTS_ID}    ${lncel_id}    LNCEL   60

Unblock Selected Cell
    [Arguments]    ${lncel_id}=-1  ${lcr_id}=-1  ${alias}=${alias}
    Run Keyword If    "${lncel_id}"=="-1" and "${lcr_id}"=="-1"  Fail  Cell not provided!
    ${lncel_id}=   Run Keyword If  "${lncel_id}"=="-1"  Get LncelId Of LcrId  ${lcr_id}
    ...  ELSE         Set Variable  ${lncel_id}
   Perform Cell Unblock    ${BTS_ID}    ${lncel_id}    LNCEL   60

Get LncelId Of LcrId
    [Arguments]  ${lcr_id}  ${lcr_id_list}=${FR_INFO['${FR_UNDER_TEST_SERIAL_NUMBER}']['cell_list']}
    ...          ${lncel_id_list}=${FR_INFO['${FR_UNDER_TEST_SERIAL_NUMBER}']['lncel_id_list']}
    ${lcr_index}=       Get Index From List  ${lcr_id_list}     ${lcr_id}
    ${lncel_id}=        Get From List        ${lncel_id_list}   ${lcr_index}
    [Return]  ${lncel_id}

LG Hot Remove Precondition
  [Arguments]    ${alias}=${CFG.primary_node_bts_id}
    Set Test Variable    ${CONFIGURATION_NAME}   ${CFG.configuration_name}
    Set Test Variable    ${BTS_ID}    ${CFG.primary_node_bts_id}
    Set Test Variable    ${scfc_file_path}   ${CFG['NODES']['${BTS_ID}']['scf_file_path']}
    Set Test Variable    ${SCFC_REFERENCE_FILE_PATH}   ${CFG['NODES']['${BTS_ID}']['scf_file_path']}
    Set Test Variable    ${OUT_SCFC_REFERENCE_FILE_PATH}   ${CFG['NODES']['${BTS_ID}']['scf_file_path']}
    ${SW_RELEASE}=  Set Variable If      ${CFG['NODES']['${BTS_ID}']['trunk_status']}    SBTS00    ${CFG['NODES']['${BTS_ID}']['active_release']}
    Set Test Variable    ${SW_RELEASE}   ${SW_RELEASE}
    Set Test Variable    ${OUT_SCFC_CURRENT_FILE_PATH}   ${CFG['NODES']['${BTS_ID}']['scf_file_path']}
    Set Test Variable    ${alias}   ${CFG.primary_node_bts_id}
    ${act_category_alarms}=    Get From Dictionary    ${cfg.NODES['${BTS_ID}']}    scf_alarms_category
    Set Test Variable    ${ACT_CATEGORY_ALARMS}    ${act_category_alarms}
    set test variable    ${FR_SERIAL_NUMBER}     ${cfg.scf_hw_all_fr_list}
    set test variable    ${CURRENT_SM_SERIAL_NUMBERS}     ${cfg['NODES']['${BTS_ID}']['scf_hw_sm_list']}
    set test variable    ${OUT_CURRENT_FR_SERIAL_NUMBERS}     ${cfg.scf_hw_all_fr_list}
    ${ru_bts_id}    ${ru_dist_name}=    Get RU Node Data    ${CFG.scf_rmods_under_test[0]}
    Set Test Variable    ${RU_DIST_NAME}   ${ru_dist_name}
    Set Test Variable    ${RU_BTS_ID}   ${ru_bts_id}






LG Hot Remove Postcondition
  [Arguments]    ${alias}=default     ${test_line_setup}=False
  Test Line Check   ${alias}
