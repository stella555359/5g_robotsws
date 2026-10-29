*** Settings ***
Documentation
...            [Author]         "Sahana T C"
...            [Maintenance]    "TRS I & V Tools Bangalore Team"

Library    SSHLibrary
Library    OperatingSystem
Library    Process
Library    String
Library    BuiltIn
Library    Collections


*** Variables ***
${tc_variables}     testcase_variables.json
${variables}       ta_e2e_bts_trs_fw


*** Keywords ***
Check SSH Login
    [Arguments]    ${bts}
    SSHLibrary.Open Connection    ${bts}
    SSHLibrary.Login    ${USER}    ${PASSWORD}
    [Teardown]    SSHLibrary.Close Connection

Create fault id List
    [Arguments]    ${list}
    ${length}=    Get Length    ${list}
    ${list1}=    Create List
    FOR    ${i}    IN RANGE    ${length}
        Append To List    ${list1}    ${list[${i}]['faultId']}
    END
    [Return]    ${list1}

Fault list after reset
    [Arguments]    ${pre_alarm_faultids}    ${post_alarm_faultids}
    ${list}=    Create List
    FOR    ${i}    IN    @{post_alarm_faultids}
        Run Keyword If    ${i} in ${pre_alarm_faultids}    Continue For Loop
        Append To List    ${list}    ${i}
    END
    [Return]    ${list}

Delete File Addons
    [Arguments]    ${dir}    ${vnc_ip}
    SSHLibrary.Open Connection    ${vnc_ip}    port=22
    SSHLibrary.Login    ${USER}    ${PASSWORD}
    SSHLibrary.Execute Command    cd /home/ute/robotlte/testsuite/WMP/E2E_BTS_TRS_FW/fw_user_path/testcases/EDA_BTS_RESET
    ${prompt}=    OperatingSystem.List Directory    ${dir}
    FOR    ${i}    IN    @{prompt}
        Run Keyword If    'disconnect' in '${i}'    SSHLibrary.Execute Command    rm -r ${dir}/${i}
    END
    SSHLibrary.Close Connection

Read Syslog
    ${result}=    Run Process    python3    onair_time.py
    Log    ${result.stdout}
    [Return]    ${result.stdout}

Verify_BTS_startup_time
    Stop Syslog
    Sleep    3s
    Read Syslog
    ${onair_interval}=    Read Syslog
	${str1}    ${onair_interval_value}  	Should Match Regexp	${onair_interval}	(\\d+)
   Should Be True  ${onair_interval_value} < 480
