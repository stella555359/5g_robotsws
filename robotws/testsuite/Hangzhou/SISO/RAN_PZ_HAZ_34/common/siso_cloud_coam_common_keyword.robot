*** Settings ***
Documentation    This is common keywords for siso coam related cases
...              Please do not modify the file without notification to author
...              Author: zhao nana
...              Contact: nana.zhao@nokia-sbell.com
...              Squard: MMW2

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/asod.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_cu.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot


#Resource    ../../../../resources/common/coam_cu.robot
#Library     ../../../../resources/python_libs/TestCaseRequirement.py
Library           taf.selenium.gnb.oam.coam.cu   WITH NAME   coam_cu
Library           taf.gnb.oam.coam.cu   WITH NAME   gnb_coam_cu

*** Variables ***
${RU_ALIAS}             rf_alias
${RU_ADDR}              ${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.addr}
${RU_USER}              ${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.username}
${RU_PASSWORD_trunk}          PD6N1DB0lWmwomtNL2qd3ISypbiocdGRy7U+Lipiksk=
${RU_PASSWORD_21B}          umniedziala
${du_web_addr}          ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${du_web_usr}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${du_web_pwd}           ${tl.gnbs[0].cu.oam_http_connection_details.password}

${alarm_filter_1937}     Unit \(module\) dangerously overheating
${TS_LOG_PATH_BASE}    /home/ute
${TS_CASE_LOG_PATH}    /home/ute
${testline_name}       null
${CONFIGURATION}       null


*** Keywords ***
Connect to ASOD
    [Arguments]    ${alias}=ASOD
    csn.connect to    hostname=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...               username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...               alias=${alias}

Connect to RU with diff stream
    [Documentation]    Author: zhao nana
    ...                This keyword is to ssh to ru which support differnt passwd.
	[Arguments]    ${ru_index}=${1}    ${ru_alias}=RU_1
    Cloud DU connect to gnb coam via ssl    connection=GNB_OAM
	${sw_version}    Coam Get Active SW Version
	${status}    run keyword and return status     Should contain    ${sw_version}    0.400
	wait until keyword succeeds   1 min    10 sec    Connect to ASOD
	Run Keyword If    ${status}
	...    Connect to RU With Allocated IP    asik_alias=ASOD    ru_alias=RU_${ru_index}
	...    ELSE
	...    Connect to RU With Allocated IP    asik_alias=ASOD    ru_alias=RU_${ru_index}
Login via Web
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=https://${du_web_addr}
    ...               username=${du_web_usr}
    ...               password=${du_web_pwd}
    selenium_coam.disable_message_box
   
Logout via Web   
    selenium_coam.logout
    selenium_coam.Disable Virtual Display

Suite_Common_Setup_Cloud_Coam
    [Documentation]    Author: zhao nana
    ...                Description: case common setup
    Login via Web
    CI_interface.Common Suite Setup
    Run Keyword And Ignore Error    Logout via Web

Suite_Common_Teardown_Cloud_Coam
    [Documentation]    Author: zhao nana
    ...                Description: case common teardown
    Run Keyword And Ignore Error    Logout via Web

Cases_Common_Coam_Cloud_Suite_Setup
    [Documentation]    Author: zhao nana
    ...                Description: check gnb status before case execute
    Login via Web
	Wait_all_Cells_onair_cloud_Coam
	Run Keyword And Ignore Error    Logout via Web
    
Cases_Common_Coam_Cloud_Suite_Teardown
    [Documentation]    Author: zhao nana
    ...                Description: check gnb status after case execute 
    Login via Web
	Wait_all_Cells_onair_cloud_Coam
    CI_interface.Common Case Teardown
	Run Keyword And Ignore Error    Logout via Web
    Run Keyword And Ignore Error    COAM Teardown gnb connections

COAM Get GNB RU Number
    [Documentation]  Author: Jia Lei
    ...                Descrition：get rru number from site
    [Arguments]    ${connection}=GNB_OAM
    ${hw_info}    coam.get_detected_hw_info    connection=${connection}
    log    ${hw_info}
    @{list_RUs}    Set variable    ${hw_info['radioModules']['rmod']}
    ${count_RUs}    Get length    ${list_RUs}
    ${count_RUs}    convert to integer    ${count_RUs}
    [Return]    ${count_RUs}
	
Common_Collect_RFSW_Logs_From_RU_Into_BTS_Snapshot
    [Documentation]  Author: nana.zhao@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM    ${gnb_connection}=ASIK Master
    
    ${ru_num}    COAM Get GNB RU Number    connection=${connection}
    @{ru_list}    Create List
    FOR    ${ru_index}    IN RANGE    1    ${ru_num}+${1}
        Append To List    ${ru_list}    ${ru_index}
    END
    FOR    ${ru_index}    IN    @{ru_list}
	    Connect to RU with diff stream    ru_index=${ru_index}
        
        Verify RFSW Log Include In Snapshot    ru_index=${ru_index}    ru_alias=RU_${ru_index}    connection=${connection}
    END
	
SSH To RU slave cOAM
    [Documentation]
    Connect to RU with diff stream
    csn.Send command    command=frmonShellClient 127.0.0.1 2000    connection=RU_1

make alarm on RF without recovery COAM
    [Documentation]
    SSH To RU slave cOAM
    csn.write_input    data=/ action create ConfigAccess /CI/ConfigAccess_Module /module\r\n\r\n
    ...    connection=RU_1
    ${result}    csn.read_output_until    match=done ok    connection=RU_1
    log    ${result}

    csn.write_input    data=/CI/ConfigAccess_Module action fetch DECODED "tempest_inst1.bin" "/run/tempest_inst1.json"\r\n\r\n
    ...    connection=RU_1
    ${result}    csn.read_output_until    match=done ok    connection=RU_1

    csn.write_input    data=/CI/ConfigAccess_Module action fetch DECODED "tcs.bin" "/run/tcs_default.json"\r\n\r\n
    ...    connection=RU_1
    ${result}    csn.read_output_until    match=done ok    connection=RU_1

    Connect to RU with diff stream

    csn.Send command    command=sudo sed -i 's/"tempOffset": 0,/"tempOffset": 80,/g' /run/tempest_inst1.json
    ...    connection=RU_1
    sleep    5s

    SSH To RU slave cOAM
    csn.write_input
    ...    data=/CI/ConfigAccess_Module action store TEMPORARY DECODED "tempest_inst1.bin" "/run/tempest_inst1.json"\r\n\r\n
    ...    connection=RU_1
    ${result}    csn.read_output_until    match=done ok    connection=RU_1
    csn.write_input    data=/CI/ConfigAccess_Module action update\r\n\r\n
    ...    connection=RU_1
    ${result}    csn.read_output_until    match=done ok    connection=RU_1

Common_RF_alarms_without_recovery_on_coam
    [Documentation]    Author: zhao nana
    ...                Description: make alarm on ru
    Cloud DU connect to gnb coam via ssl    connection=GNB_OAM
    Login via Web
    Check if alarm is unactive on coam
    make alarm on RF without recovery COAM
    Wait Until Keyword Succeeds    15min    5s    Verify Expected Alarm Is Raised After Action on coam
    [Teardown]    Recovery env

Verify Expected Alarm Is Raised After Action on coam
    [Documentation]    Author: zhao nana
    ...                this KW is to verify expected alarms is raised after actions
    [Arguments]    ${timeout}=${20}
    Log To Console    Info: ready to verify expected alarm is raised...
    @{alarm_info}=    selenium_coam.get_active_alarm_info
    ${alarms_string}=    Convert To String    ${alarm_info}
    Should Contain    ${alarms_string}    ${alarm_filter_1937}

Check if alarm is unactive on coam
    [Documentation]    Author: zhao nana
    ...                this KW is to verify expected alarms is disappear after actions
    @{alarm_info}=    selenium_coam.get_active_alarm_info
    ${alarms_string}=    Convert To String    ${alarm_info}
    Should not Contain    ${alarms_string}    ${alarm_filter_1937}

Common_Cell_Lock_and_Unlock_on_cloud_coam
    [Documentation]    Author: zhao nana
    ...                This keyword is lock or unlock cell
	Login via Web
    ${total_cell_number}    selenium_coam.get_number_of_cells
    Lock_one_cell_and_check_status_on_cloud_coam    Cell_number=${total_cell_number}
    Unlock_one_cell_and_check_status_on_cloud_coam    Cell_number=${total_cell_number}
	[Teardown]    Run Keyword And Ignore Error    Logout via Web

Lock_one_cell_and_check_status_on_cloud_coam
    [Documentation]    Author: zhao nana
    ...                This keyword is lock one cell
    [Arguments]  ${Cell_number}=1
    selenium_coam.lock_cell
    Verify_Cell_Status_Is_On_Air_Or_Not    operational_state=Disabled    administrative_state=Locked    cell=1
    FOR    ${cell_id}    IN RANGE    ${Cell_number-1}
        Verify_Cell_Status_Is_On_Air_Or_Not    operational_state=Enabled    administrative_state=Unlocked    cell=${cell_id+2}
    END

Unlock_one_cell_and_check_status_on_cloud_coam
    [Documentation]    Author: zhao nana
    ...                This keyword is unlock one cell
    [Arguments]  ${Cell_number}=1
    selenium_coam.unlock_cell
    FOR    ${cell_id}    IN RANGE    ${Cell_number}
        Verify_Cell_Status_Is_On_Air_Or_Not    operational_state=Enabled    administrative_state=Unlocked    cell=${cell_id+1}
    END

Verify_Cell_Status_Is_On_Air_Or_Not
    [Documentation]    Author: zhao nana
    ...                This keyword is to verify cell status
    [Arguments]    ${cell}=1    ${operational_state}=Disabled    ${administrative_state}=Locked
    Wait Until Keyword Succeeds    20min    5s    Check_Cell_Status_with_CellId_on_cloud_coam
    ...    operational_state=${operational_state}
    ...    administrative_state=${administrative_state}
    ...    cell=${cell}

Check_Cell_Status_with_CellId_on_cloud_coam
    [Documentation]    Author: zhao nana
    ...                This keyword is to verify cell status
    [Arguments]    ${operational_state}=Disabled
    ...            ${administrative_state}=Locked
    ...            ${cell}=1
    Run Keyword And Ignore Error  selenium_coam.close_start_up_view_window  timeout=${5}
    ${output}=    selenium_coam.get_cell_info    cell_idx=${cell}
    Log Many      ${output}
    should be equal      ${output['Status']['Operational state']}    ${operational_state}
    should be equal      ${output['Status']['Administrative state']}    ${administrative_state}

Recovery env
    [Documentation]    Author: zhao nana
    ...                This keyword is to reset ru and check cell onair
    selenium_coam.Reset Ru
    sleep  1min
    Wait_all_Cells_onair_cloud_Coam
    Run Keyword And Ignore Error    Logout via Web
    COAM Teardown gnb connections

Common_RU_Lock_and_unlock_on_cloud_coam
    [Documentation]    Author: zhao nana
    ...                This keyword is to lock and unlock ru
    Login via Web
    selenium_coam.lock_ru
    Verify_Status_on_RU_Cloud_Coam    ru_index=1    Status=Locked
    ${total_cell_number}    selenium_coam.get_number_of_cells
    Run Keyword If    ${total_cell_number}>8    Verify_cell_Status_locked_only_first_cellgroup
    ...    ELSE    Verify_cell_Status_on_All_cellgroup    total_cell_number=${total_cell_number}
    selenium_coam.unlock_ru
    Verify_Status_on_RU_Cloud_Coam    ru_index=1    Status=Unlocked
    Wait_all_Cells_onair_cloud_Coam
    [Teardown]    Run Keyword And Ignore Error    Logout via Web

Verify_cell_Status_locked_only_first_cellgroup
    [Documentation]    Author: zhao nana
    ...                This keyword is to check cells status  in the first cellgroup when ru locked
    ...                just for multiple sectors,for example 24cc
    FOR    ${cell_id}    IN RANGE    8
        Verify_Cell_Status_Is_On_Air_Or_Not    operational_state=Disabled    administrative_state=Unlocked    cell=${cell_id+1}
    END

Verify_cell_Status_on_All_cellgroup
    [Documentation]    Author: zhao nana
    ...                This keyword is to check cells status in all cellgroup when ru locked
    [Arguments]    ${total_cell_number}=1
    FOR    ${cell_id}    IN RANGE    ${total_cell_number}
        Verify_Cell_Status_Is_On_Air_Or_Not    operational_state=Disabled    administrative_state=Unlocked    cell=${cell_id+1}
    END

Verify_Status_on_RU_Cloud_Coam
    [Documentation]    Author: zhao nana
    ...                This keyword is to check ru status
    [Arguments]    ${ru_index}=1    ${Status}=Unlocked
    ${ru_info}    selenium_coam.get_ru_info    ru_index=${ru_index}
    should be equal  ${Status}     ${ru_info['Status']['Administrative state']}

Check_If_RU_Offline_Cloud_Coam
    [Documentation]    Author: zhao nana
    ...                This keyword is to check ru offline
    [Arguments]    ${ru_index}=1
    ${ru_info}    selenium_coam.get_ru_info    ru_index=${ru_index}
    should be equal  Disabled     ${ru_info['Status']['Operational state']}
    should be equal  NotInstalled     ${ru_info['Status']['Availability status']}

Wait_all_Cells_onair_cloud_Coam
    [Documentation]    Author: zhao nana
    ...   This keyword is to check all cells online
    Run Keyword And Ignore Error  selenium_coam.close_start_up_view_window  timeout=${5}
    ${total_cell_number}    selenium_coam.get_number_of_cells
    FOR    ${cell_id}    IN RANGE    ${total_cell_number}
        Verify_Cell_Status_Is_On_Air_Or_Not    operational_state=Enabled    administrative_state=Unlocked    cell=${cell_id+1}
    END

Common_RF_module_power_reset_Cloud_Coam
    [Documentation]    Author: zhao nana
    ...                This keyword is to power reset ru
    [Arguments]    ${ru_index}=1
	Login via Web
    coam_siso_common.Perform RU Power Off    ru_index=${ru_index}
    Wait Until Keyword Succeeds    90 sec    2 sec    Check_If_RU_Offline_Cloud_Coam    ru_index=${ru_index}
    coam_siso_common.Perform RU Power On    ru_index=${ru_index}
    Wait_all_Cells_onair_cloud_Coam
	[Teardown]    Run Keyword And Ignore Error    Logout via Web
	

	
Common_RF_module_reset_triggered_by_user_as_part_of_BTS_reset_cloud_coam
    [Documentation]    Author: zhao nana
    ...                This keyword is to verify after site reset, ru will be reset.
    [Arguments]    ${ru_index}=1
    Connect to RU with diff stream
    ${result1}    csn.Execute    command=ls -al /var/log/messages | awk '{print $8}'    connection=RU_1
    log    ${result1}
    Login via Web
    selenium_coam.reset_site
    sleep    3min
    Wait_all_Cells_onair_cloud_Coam
    Logout via Web
    csn.Reset Cache
    Connect to RU with diff stream
    ${result2}    csn.Execute    command=ls -al /var/log/messages | awk '{print $8}'    connection=RU_1
    log    ${result2}
    Should Not Be Equal    ${result1}    ${result2}
    [Teardown]    COAM Teardown gnb connections

General_SiSo_Commissioning_BTS_Template_Commissioning_Coam_Cloud
    [Documentation]    Author: jiayi tang
    ...                Description: load cu and du scf
    [Arguments]    ${cu_scf_path}    ${du_scf_path}    ${timeout}=300    ${is_pdl_checking_needed}=${True}
#    CU Full Commission    path_of_commission_file=${cu_scf_path}
    Sleep    5s
    DU General_SiSo_Commissioning_BTS_Recommissioning    scf_path=${du_scf_path}    scf_timeout=${timeout}
    ...   is_pdl_checking_needed=${is_pdl_checking_needed}
    Wait_all_Cells_onair_cloud_Coam	

Coam Du Check cell on air
    [Documentation]    Author: jiayi tang
    ...                Description: check cell onair
    Cloud DU connect to gnb coam via ssl    connection=GNB_OAM
    COAM Check GNB cell on air
    [Teardown]    COAM Teardown gnb connections

DU General_SiSo_Commissioning_BTS_Recommissioning
    [Documentation]    Author: jiayi tang
    ...                Description: load du scf
    [Arguments]    ${scf_path}    ${scf_timeout}=300    ${is_pdl_checking_needed}=${True}
    Cloud DU connect to gnb coam via ssl    connection=GNB_OAM
    COAM Commission with scf file    scf_file_path=${scf_path}    timeout=${scf_timeout}    is_pdl_checking_needed=${is_pdl_checking_needed}
    [Teardown]    COAM Teardown gnb connections

interger calculate coam
    [Documentation]    Author: xinyu gu
    ...                Description: integer convert
    [Arguments]    ${input_number}=0
    ${input_number}=    Convert To Integer    ${input_number}
    ${input_number}    Evaluate    ${input_number}+1
    Set Test Variable    ${fail_count}    ${input_number} 
    [Return ]    ${fail_count}

Collect_RFSW_logs_from_RU_into_BTS_Snapshot_Teardown
    [Documentation]    Author: zhao nana
    ...                Description: teardown for collect RF logs from ru into bts snapshot
    COAM Teardown gnb connections
    CI_interface.Common Case Teardown

Commission_DU
    [Documentation]    Author: zhao nana
    ...                Description: load du scf for UTE cloud and light CI
    [Arguments]    ${du_scf_name}    ${timeout}=300

    Cloud DU connect to gnb coam via ssl    connection=GNB_OAM
    ${TL_NAME}    set variable if    '${testline_name}' == 'null'    ${CONFIGURATION}    ${testline_name}
    ${pattern}    Set Variable    7_5(.*)
    ${TLNAME}    Get Regexp Matches    ${TL_NAME}    ${pattern}    1
    ${testlinename}    Set Variable    7_5${TLNAME}[0]
    COAM Commission with scf file
    ...    scf_file_path=${CURDIR}/../../../../../commissionings/HGZ/${testlinename}/${du_scf_name}
    ...    is_pdl_checking_needed=${False}
    ...    timeout=600
    wait until keyword succeeds    25 min    10 sec    COAM Check GNB cell on air
    [Teardown]    COAM Teardown gnb connections
