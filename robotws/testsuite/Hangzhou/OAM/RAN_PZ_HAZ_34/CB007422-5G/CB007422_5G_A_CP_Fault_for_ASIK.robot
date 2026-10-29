*** Settings ***
Documentation     author: wang jiangrong
...               contact: jiangrong.wang@nokia-sbell.com
...               squad group: 5G_PZ_MMW_HZ_2_SG

Force Tags    STATE_SW_UPLOADED       CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AEQP    RAN_5G    RAN_5G_TDD 	SBTS00
...   PY39
Library            OperatingSystem
Library            ./PythonKeywords.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/asod.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G//5G_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/coam_check_status.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/ue.robot


#Suite Setup       Test Suite Setup
#Suite Teardown    Test Suite Teardown
Suite Setup       Suit setup for CB007422
Suite Teardown    Run Keyword And Ignore Error     SISO Coam Suite Teardown

*** Variables ***
${SUITE_LOG_PATH}
${TS_CASE_LOG_PATH}    /home/ute/
${ALARM_INFO}
@{ALLOWED_FAULTS}=  61649  61652  61524  61510  9000 4592 4527 1932 4334 61074 61618 4687 4654 4655 8150 6450



*** Test Cases ***
[1]CB007422_002_BTS_crash_with_autonomous_recovery_reset_fault_reported_after_reset
    [Documentation]    Sending fault signature when it is not possible to raise alarm
    ...                preceding autonomous reset of a unit/cOAM BTS with 
    ...                actCategoryAlarms is 'true'.
    [Tags]    CIT_TRUNK    CIT            
    [Setup]    Case setup for CB007422 fault
    AlarmWatchdog.add_allow_alarms     fault_id=4590
    #${status}    check if alarm is exist    alarm_info=FaultId: 4590    expect_result=False
    trigger fault report after bts reset
    Sleep    150s
    Wait Until Keyword Succeeds    20min    1s    Check certain alarm is raised and with FaultSignature    alarm_id=7115    fault_id=4590
    #Wait Until Keyword Succeeds    1min    2s    Check File Existed    filename=/tmp/startup_BTSOM.log    alias=ASOD    
    #Wait Until Keyword Succeeds    3min    2s    check if alarm is exist    alarm_info=FaultId: 4590    expect_result=True
    Wait Until Keyword Succeeds    20min    20s    COAM Check GNB cell on air
    #${status}    check if alarm is exist    alarm_info=FaultId: 4590    expect_result=True
    AlarmWatchdog.remove_allow_alarms    fault_id=4590
    [Teardown]    Run Keyword And Ignore Error    SISO Coam Test Teardown
    
[1]CB007422_001_BTS_crash_with_autonomous_recovery_reset_fault_reported_before_reset
    [Documentation]    This case describes scenario when after the crash or failure
    ...                the cOAM BTS is able to raise alarm preceding autonomous recovery
    ...                reset of a unit/BTS with actCategoryAlarms is 'true'.
    [Tags]    CIT_TRUNK    CIT           
    [Setup]     Case setup for CB007422 fault
    AlarmWatchdog.add_allow_alarms     fault_id=2080
    Get into RD parameters
    Trigger fault 2080 in RD models
    Sleep    5s
    #check if alarm is exist    alarm_info=FaultId: 2080    expect_result=True
    Wait Until Keyword Succeeds    2min    1s    Check certain alarm is raised and with FaultSignature    alarm_id=7101    fault_id=2080
    Get out RD parameters 
    Wait Until Keyword Succeeds    20min    20s    COAM Check GNB cell on air
    AlarmWatchdog.remove_allow_alarms    fault_id=2080
    [Teardown]    Run Keyword And Ignore Error    SISO Coam Test Teardown

[2]CB007422_005_BTS_fault_signature_with_alarm_indicating_BBMOD_overheating
    [Documentation]    This case describes sending fault signature when the temperature
    ...                of FSP/ABIx board has exceeded the critical threshold value.
    [Tags]    CRT_TRUNK             
    [Setup]     SISO Coam Test Setup
    ${status}    check if alarm is exist    alarm_info=FaultId: 4077    expect_result=False
    trigger bbmod overheating
    #Wait Until Keyword Succeeds    60min    1min    check if alarm is exist    alarm_info=FaultId: 4077    expect_result=True
    Wait Until Keyword Succeeds    60min    1min    Check certain alarm is raised and with FaultSignature    alarm_id=7116    fault_id=4077
    restore bbmod fans
    Wait Until Keyword Succeeds    20min    20s    COAM Check GNB cell on air
    [Teardown]    Run Keyword And Ignore Error    SISO Coam Test Teardown
    
[1]CB007422_005_BTS_fault_signature_with_alarm_indicating_BBMOD_overheating
    [Documentation]    This case describes sending fault signature when the temperature
    ...                of FSP/ABIx board has exceeded the critical threshold value.
    [Tags]    CRT_TRUNK             
    [Setup]     SISO Coam Test Setup
    ${status}    check if alarm is exist    alarm_info=FaultId: 4077    expect_result=False
    trigger bbmod overheating
    #Wait Until Keyword Succeeds    60min    1min    check if alarm is exist    alarm_info=FaultId: 4077    expect_result=True
    Wait Until Keyword Succeeds    60min    1min    Check certain alarm is raised and with FaultSignature    alarm_id=7116    fault_id=4077
    restore bbmod fans
    Wait Until Keyword Succeeds    20min    20s    COAM Check GNB cell on air
    [Teardown]    Run Keyword And Ignore Error    SISO Coam Test Teardown

*** Keywords ***
Test Suite Setup
    CI_interface.Common Suite Setup
    Connect to gnb coam via ssl
    coam.reset_site    timeout=20min    connection=GNB_OAM
    Wait Until Keyword Succeeds    20min    20s    COAM Check GNB cell on air

Test Suite Teardown
    Connect to gnb coam via ssl
    #coam.reset_site    timeout=20min    connection=GNB_OAM
    Wait Until Keyword Succeeds    20min    20s    COAM Check GNB cell on air
    COAM Teardown gnb connections

trigger fault report after bts reset
    Connect to ASOD
    ${pidinfo}    csn.execute
    ...           command=ps aux | grep "=nid=0x1011" | grep -v grep | awk '{print $2}'
    ...           connection=ASOD
    ${pidinfo}    Strip string    ${pidinfo}
    ${status}=    csn.execute    command=kill -11 ${pidinfo}    connection=ASOD
    should be empty    ${status}
    Run Keyword And Ignore Error    csn.Disconnect    connection=ASOD 

trigger bbmod overheating
    Connect to ASOD
    ${fan0_pwm}    csn.execute    command=cat /dev/ddal/fan/0/pwm    connection=ASOD
    ${fan1_pwm}    csn.execute    command=cat /dev/ddal/fan/1/pwm    connection=ASOD
    ${fan0_pwm}    Strip string    ${fan0_pwm}
    ${fan1_pwm}    Strip string    ${fan1_pwm}
    set suite variable    ${fan0_pwm}
    set suite variable    ${fan1_pwm}
    #${status}=    csn.execute
    #...           nohup watch -n0 "echo 0 > /dev/ddal/fan/0/pwm; echo 0 > /dev/ddal/fan/1/pwm" > myout.file 2>&1 &    
    #...           connection=ASOD
    #${cmd1}=  set variable  echo '#!/bin/bash' > /tmp/temp_script.sh; echo 'while [ 1 ]; do echo 0 > /dev/ddal/fan/0/pwm;
    #${cmd2}=  set variable  echo 0 > /dev/ddal/fan/1/pwm; done' >> /tmp/temp_script.sh; chmod 775 /tmp/temp_script.sh:
    #${cmd}  set variable  ${cmd1} ${cmd2}
    ${run_cmd}=  set variable  bash /tmp/temp_script.sh&
    #${run_cmd}=  set variable    nohup bash /tmp/temp_script.sh > myout.file 2>&1 &
    #csn.execute    command=${cmd}
    #...            connection=ASOD
    #csn.execute    command=${run_cmd}
    #...            connection=ASOD
    #should be empty    ${status}
    #Run Keyword And Ignore Error    csn.Disconnect    connection=ASOD
    PythonKeywords.connect_to_gnb    address=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}    alias=ASOD
    PythonKeywords.generate_fault_4077    
    #Disable enb fans
    
restore bbmod fans
    PythonKeywords.connect_to_gnb    address=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}    alias=ASOD
    PythonKeywords.disable_fault_4077
    Connect to ASOD
    ${status}=    csn.execute
    ...           command=echo ${fan0_pwm} > /dev/ddal/fan/0/pwm; echo ${fan1_pwm} > /dev/ddal/fan/1/pwm
    ...           connection=ASOD
    #should be empty    ${status}
    Run Keyword And Ignore Error    csn.Disconnect    connection=ASOD
    
    #Connect to enb
    #${status}=    csn.execute
    #...           command=echo ${fan0_pwm_enb} > /dev/ddal/fan/0/pwm; echo ${fan1_pwm_enb} > /dev/ddal/fan/1/pwm
    #...           connection=LTEenb
    #should be empty    ${status}
    #Run Keyword And Ignore Error    csn.Disconnect    connection=LTEenb

check if alarm is exist
    [Arguments]    ${alarm_info}    ${expect_result}
    csn.reset_cache
    Connect to ASOD
    ${cmd}     Catenate
    ...        cat /tmp/startup_BTSOM.log|grep '${alarm_info}'
    #${status}=    csn.execute
    #...           command=${cmd}
    #...           connection=ASOD
    ${status}=    Run    command=${cmd}
    Run Keyword And Ignore Error    csn.Disconnect    connection=ASOD
    #${actual_result}    run keyword and return status    should not be empty    ${status}
    ${actual_result}   Set Variable If     """${alarm_info}""" in """${status}"""     True     False
    #${actual_result}    convert to boolean    ${actual_result}
    should be equal    ${actual_result}    ${expect_result}
    
Get into RD parameters
    coam.change_bts_rad_parameters      component=69    params=39:1    connection=GNB_OAM
    
Get out RD parameters
    coam.change_bts_rad_parameters      component=69    params=39:0    connection=GNB_OAM
    
Trigger fault 2080 in RD models
    coam.send_hwapi_api2_alarm_msg      sender=269550144    receiver=269554178    fault_state=1    fault_id=2080    unit_id=16    connection=GNB_OAM
    
Check certain alarm is raised and with FaultSignature
    [Arguments]    ${alarm_id}    ${fault_id}    ${with_faultsignature}=True
    @{res}    coam.get_active_alarms    connection=GNB_OAM 
    FOR    ${i}    IN    @{res}
        ${Found_alarmid}    set variable if    '${i['alarmId']}' == '${alarm_id}'    ${True}    ${False}
        ${Found_faultid}    set variable if    '${i['faultId']}' == '${fault_id}'    ${True}    ${False}
        ${Found_withsignature}=    run keyword and return status   should not be empty    i['faultSignature']['loadName']
        exit for loop if    '${i['faultId']}' == '${fault_id}'
    END
    should be true    ${Found_alarmid} == ${True} and ${Found_faultid} == ${True}
    should be true    ${Found_withsignature} == ${True}   

Disable enb fans
    Connect to enb
    ${fan0_pwm}    csn.execute    command=cat /dev/ddal/fan/0/pwm    connection=LTEenb
    ${fan1_pwm}    csn.execute    command=cat /dev/ddal/fan/1/pwm    connection=LTEenb
    ${fan0_pwm_enb}    Strip string    ${fan0_pwm}
    ${fan1_pwm_enb}    Strip string    ${fan1_pwm}
    set suite variable    ${fan0_pwm_enb}
    set suite variable    ${fan1_pwm_enb}
    ${status}=    csn.send_command
    ...    command=nohup watch -n0 "echo 0 > /dev/ddal/fan/0/pwm; echo 0 > /dev/ddal/fan/1/pwm" > myout.file 2>&1 &
    ...    connection=LTEenb
    #should be empty    ${status}
    #Run Keyword And Ignore Error    csn.Disconnect    connection=LTEenb
    
Connect to enb
    [Arguments]    ${enb_index}=0
    ...    ${host}=${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.addr}
    ...    ${username}=${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.username}
    ...    ${password}=${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.password}
    ...    ${file_name}=ue_attach.pcap
    csn.Connect To     hostname=${host}    username=${username}     password=${password}    alias=LTEenb
    
Suit setup for CB007422
    Sleep    600s
    SISO Coam Suite Setup
    #Connect to gnb coam via ssl
    #Clean tmp log file
    #coam.reset_site    timeout=20min    connection=GNB_OAM
    #Wait Until Keyword Succeeds    20min    20s    COAM Check GNB cell on air
    
Clean tmp log file
    Connect to ASOD
    ${status}=    csn.execute
    ...           command=rm -rf /tmp/*.log
    ...           connection=ASOD
    Run Keyword And Ignore Error    csn.Disconnect    connection=ASOD

Check File Existed
    [Arguments]  ${filename}    ${alias}=default
    Connect to ASOD
    ${out}    csn.Execute     command=ls ${filename}   connection=${alias}
    ${bExist}   Set Variable If     """No such file or directory""" in """${out}"""     0     1
    Run Keyword And Ignore Error    csn.Disconnect    connection=ASOD
    [Return]   ${bExist}

Case setup for CB007422 fault
    SISO Coam Test Setup
    Connect to gnb coam via ssl
    Clean tmp log file
    coam.reset_site    timeout=20min    connection=GNB_OAM
    Wait Until Keyword Succeeds    20min    20s    COAM Check GNB cell on air
