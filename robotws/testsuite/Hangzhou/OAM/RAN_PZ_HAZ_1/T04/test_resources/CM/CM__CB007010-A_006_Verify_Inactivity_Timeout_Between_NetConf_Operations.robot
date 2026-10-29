*** Settings ***
Documentation       Test case for
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot


*** Variables ***
${ONAP_GET_OUT_FILE}    /tmp/CB007010-A_006.xml
${Integrate_Need}        ${False}
${Check_Upload_Duration}    ${False}
${UPLOAD_DURATION_STANDARD}    20

*** Keywords ***
CM__CB007010-A_006_Verify_Inactivity_Timeout_Between_NetConf_Operations
        [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...   For case:RAN_ST_CB007010-A_006_CM_Verify Inactivity timeout between NetConf operations
    ...  The main steps performed for the test are:
    ...  - Set Parameter o1NetconfIdleSessionTimeout to 30
    ...  - Check Session Terminated Autonomously After 30
    ...  - Set Parameter o1NetconfIdleSessionTimeout to 60
    ...  - Check Session Terminated Autonomously After 60
    ...  - Set Parameter o1NetconfIdleSessionTimeout to 0
    ...  - Check Session Is Not Terminated Autonomously
    ...  - Unset Parameter o1NetconfIdleSessionTimeout
    ...  - Check Session Is Not Terminated Autonomously
    ...  Pass criteria: Parameter o1NetconfIdleSessionTimeout check success. Site is OK with no any unexpected alarm.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 16.05.2023 - New case
    ...  - 20.11.2023 - Real ONAP transfer to Simulator

    Set Tags    CA-CM    AUTHOR-yuyan.xu@nokia-sbell.com    OWNER-II_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com    API
    LOG    ${TEST_NAME} of ${SUITE_NAME} start.    console=${True}
    Step 1: Set Parameter o1NetconfIdleSessionTimeout to 30
    Step 2: Check Session Terminated Autonomously After 30
    Step 3: Set Parameter o1NetconfIdleSessionTimeout to 60
    Step 4: Check Session Terminated Autonomously After 60
    Step 5: Set Parameter o1NetconfIdleSessionTimeout to 0
    Step 6: Check Session Is Not Terminated Autonomously
    Step 7: Unset Parameter o1NetconfIdleSessionTimeout
    Step 8: Check Session Is Not Terminated Autonomously

TC SetUp
    Log    TC SetUp    console=True
    Common Test Setup SBTS    scf_check=${FALSE}
    ${BTS_ID}    Should Match Regexp    ${MRBTS_DN}    \\d+
    Set Test Variable    ${BTS_ID}
    Set Test Variable    ${host_ip}    ${ONAP["host_ip"]}
    Set Test Variable    ${user}    ${ONAP["user"]}
    Set Test Variable    ${pwd}    ${ONAP["pwd"]}
#    ${ONAP_INFOR}    Get Informations From ONAP    ${host_ip}    ${user}    ${pwd}
#    Set Test Variable      ${ONAP_INFOR}
#    run keyword if    ${Integrate_Need}    Integrate SBTS To ONAP    ${BTS_ID}    ${host_ip}    ${user}    ${pwd}
    Comment    Run Keyword If    ${Integrate_Need}    Integrate SBTS To ONAP Simulator    ${BTS_ID}    ${ONAP['host_ip']}
    Run Keyword If    ${SMOD1_syslog_started}    Collect syslog from SMOD1

Step ${index}: Set Parameter o1NetconfIdleSessionTimeout to ${timeout_session}
    Log    Step ${index}: Set Parameter o1NetconfIdleSessionTimeout to ${timeout_session}    console=True
    Wait Until Keyword Succeeds    3x    60s    Start syslog on SMOD1
    ${dic_o1NetconfIdleSessionTimeout}
    ...    create dictionary    parameterName=o1NetconfIdleSessionTimeout    operation=update    value=${timeout_session}
    @{parameter_list}    Create List    ${dic_o1NetconfIdleSessionTimeout}
    coam.Perform Object Recommissioning    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANEONAP-1
    ...    operation=update    parameter=@{parameter_list}
    Check SBTS SMOD RMOD Cells Alarms

Step ${index}: Check Session Terminated Autonomously After ${timeout_session}
    Log    Step ${index}: Check Session Terminated Autonomously After ${timeout_session}    console=True
#    ${ssh_index}    SSH to ONAP    ${host_ip}    ${user}    ${pwd}
#    SSHLibrary.Write    kubectl -n onap exec -it ${ONAP_INFOR['netconf_server']} bash
#    ${out_put}    SSHLibrary.Read Until Prompt
#    SSHLibrary.Set Client Configuration    timeout=200 seconds
#    ${time_tmp}    evaluate    20+${timeout_session}
#    SSHLibrary.Write    (echo "connect --tls --host ${MPLANE_IP}";sleep ${time_tmp}s)|netopeer2-cli
#    ${ret}    SSHLibrary.Read Until Prompt
    ${time_tmp}    evaluate    20+${timeout_session}
    ${ret}    Execute Command On ONAP Simulator    ${host_ip}    ${user}    ${pwd}    ${time_tmp}
    Log    ${ret}
    Should Contain    ${ret}    Communication socket unexpectedly closed
    Collect Syslog For SMOD1 on Step ${index}
    ${delta_time}    Get Delta Time On Syslog    ${UDP Logs}/SMOD1_UDP_Step${index}
    ${ts_int}    Convert To Integer    ${timeout_session}
    ${dt_int}    Convert To Integer    ${delta_time}
    Should Be True    ${ts_int}==${dt_int} or ${ts_int}==${dt_int-1} or ${ts_int}==${dt_int+1}
    ...    msg="Session Terminated Autonomously Failed"
    [Teardown]    run keyword and ignore error    SSHLibrary.Close Connection

Execute Command On ONAP Simulator
    [Arguments]    ${host_ip}    ${user}    ${pwd}    ${sleep_time}=30    ${ssh_cmd_timeout}=360
    SSHLibrary.Open Connection    ${host_ip}
    ${out_put}    SSHLibrary.Login    ${user}    ${pwd}
    SSHLibrary.Set Client Configuration    prompt=$
    SSHLibrary.Set Client Configuration    timeout=${ssh_cmd_timeout}
#    ${cmd_conn}    Catenate    connect --tls --host IPSEC    --key /home/ute/netconf/ca-key.pem
#    ...    --cert /home/ute/netconf/ee_cert.pem    --trusted /home/ute/netconf/ca-certificate.pem
    ${cmd_conn}    Catenate    connect --tls --host ONAP_Int_Test --key /home/ute/netconf/server-key.pem
    ...     --cert /home/ute/netconf/server-cert.pem --trusted /home/ute/netconf/ca-cert.pem
    ${start_time}    Get Time    epoch
    ${cmd_get}    Set Variable
    ...    get-config --source running --out=/tmp/temp_get_${start_time}.xml
    SSHLibrary.Write    (echo "${cmd_conn}";sleep ${sleep_time}s;echo ${cmd_get})|netopeer2-cli
    ${ret}    SSHLibrary.Read Until Prompt
    SSHLibrary.File Should Exist    /tmp/temp_get_${start_time}.xml
    ${end_time}    Get Time    epoch
    ${time}    Subtract Date From Date    ${end_time}    ${start_time}
    ${time}    Convert To String    ${time}
    ${sleep_time}    Convert To String    ${sleep_time}
    Run Keyword If    ${Check_Upload_Duration}    Should Be True    ${time}-${sleep_time}<${UPLOAD_DURATION_STANDARD}
    [Teardown]    SSHLibrary.Close Connection
    [Return]    ${ret}

Step ${index}: Check Session Is Not Terminated Autonomously
    Log    Step ${index}: Check Session Is Not Terminated Autonomously    console=True
#    ${ssh_index}    SSH to ONAP    ${host_ip}    ${user}    ${pwd}
#    SSHLibrary.Write    kubectl -n onap exec -it ${ONAP_INFOR['netconf_server']} bash
#    ${out_put}    SSHLibrary.Read Until Prompt
#    SSHLibrary.Set Client Configuration    timeout=200 seconds
#    ${time_tmp}    set variable    70
#    SSHLibrary.Write    (echo "connect --tls --host ${MPLANE_IP}";sleep ${time_tmp}s)|netopeer2-cli
#    ${ret}    SSHLibrary.Read Until Prompt
    ${time_tmp}    set variable    100
    ${ret}    Execute Command On ONAP Simulator    ${host_ip}    ${user}    ${pwd}    ${time_tmp}
    Log    ${ret}
    Should Not Contain    ${ret}    Communication socket unexpectedly closed
    Collect Syslog For SMOD1 on Step ${index}
    Check Session Timeout Message Not Existed On Syslog    ${UDP Logs}/SMOD1_UDP_Step${index}

Step ${index}: Unset Parameter o1NetconfIdleSessionTimeout
    Log    Step ${index}: Unset Parameter o1NetconfIdleSessionTimeout    console=True
    Wait Until Keyword Succeeds    3x    60s    Start syslog on SMOD1
    ${dic_o1NetconfIdleSessionTimeout}
    ...    create dictionary    parameterName=o1NetconfIdleSessionTimeout    operation=delete
    @{parameter_list}    Create List    ${dic_o1NetconfIdleSessionTimeout}
    coam.Perform Object Recommissioning    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANEONAP-1
    ...    operation=update    parameter=@{parameter_list}
    Check SBTS SMOD RMOD Cells Alarms


Collect Syslog For SMOD1 on Step ${index}
    Log To Console   SMOD1 syslog will be collected
    ${timestamp}    Generate Formatted Timestamp
    ${syslog_collected}=  Run keyword And Return Status  Collect syslog results  alias=SMOD1
    ...  destination=${UDP Logs}/SMOD1_UDP_Step${index}  unzip=true
    Run keyword if  ${syslog_collected}  Log  SMOD1 syslog collected to 'UDP Logs'    level=INFO      console=${TRUE}
    ...  ELSE  Log  SMOD1 syslog collection failed      level=ERROR    console=${TRUE}

Get Delta Time On Syslog
    [Arguments]        ${btslog_path}
    Log    Check Syslog    console=${True}
    ${result}    ${output}    OperatingSystem.Run And Return Rc And Output    ls -l ${btslog_path}/SMOD1_UDP*
    ${files}    Split To Lines    ${output}
    ${request_lines_list}    Create List
    ${timeout_lines_list}    Create List
    FOR    ${file}    IN    @{files}
        ${file_prop}    Split String    ${file}
        ${result}    ${output}    OperatingSystem.Run And Return Rc And Output
        #...    cat ${file_prop[8]} | grep ".*netconf/netopeer2-server.*was requested."
        ...    cat ${file_prop[8]} | grep ".*netconf/onap-netconf-svr,.*was requested."
        ${request_lines}    Split To Lines    ${output}
        ${request_lines_list}    Combine Lists    ${request_lines_list}    ${request_lines}
        ${result}    ${output}    OperatingSystem.Run And Return Rc And Output    cat ${file_prop[8]} | grep ".*session idle timeout elapsed."
        ${timeout_lines}    Split To Lines    ${output}
        ${timeout_lines_list}    Combine Lists    ${timeout_lines_list}    ${timeout_lines}
    END
    Log    ${request_lines_list}
    Log    ${timeout_lines_list}
    ${request_times_list}    Create List
    FOR    ${request_line}    IN    @{request_lines_list}
        Log    ${request_line}
        ${request_time}    Get Regexp Matches    ${request_line}    \\d{2}\.\\d{2}\\s{1}\\d{2}:\\d{2}:\\d{2}\.\\d{3}
        ${request_times_list}    Combine Lists    ${request_times_list}    ${request_time}
    END
    Log    All request times:${request_times_list}
    Sort List    ${request_times_list}
    Log    All request times after sort:${request_times_list}    console=${True}
    Log    Last request time:${request_times_list[-1]}    console=${True}
    ${timeout_times_list}    Create List
    FOR    ${timeout_line}    IN    @{timeout_lines_list}
        ${timeout_time}    Get Regexp Matches    ${timeout_line}    \\d{2}\.\\d{2}\\s{1}\\d{2}:\\d{2}:\\d{2}\.\\d{3}
        ${timeout_times_list}    Combine Lists    ${timeout_times_list}    ${timeout_time}
    END
    Log    First timeout time:${timeout_times_list[0]}    console=${True}
    ${end_time}    Convert Date    ${timeout_times_list[0]}    exclude_millis=False    date_format=%d.%m %H:%M:%S.%f
    ${start_time}    Convert Date    ${request_times_list[-1]}    exclude_millis=False    date_format=%d.%m %H:%M:%S.%f
    ${delta_time}    Subtract Date From Date    ${end_time}    ${start_time}    exclude_millis=True
    log    delta time:${delta_time}    console=${True}
    [return]    ${delta_time}

Check Session Timeout Message Not Existed On Syslog
    [Arguments]        ${btslog_path}
    Log    Check Syslog    console=${True}
    ${result}    ${output}    OperatingSystem.Run And Return Rc And Output    ls -l ${btslog_path}/SMOD1_UDP*
    ${files}    Split To Lines    ${output}
    FOR    ${file}    IN    @{files}
        ${file_prop}    Split String    ${file}
        ${result}    ${output}    OperatingSystem.Run And Return Rc And Output
        ...    cat ${file_prop[8]} | grep ".*session idle timeout elapsed."
        should be empty    ${output}
    END

Recovery SBTS
    Log    Recovery SBTS    console=True
    ${dic_o1NetconfIdleSessionTimeout}
    ...    create dictionary    parameterName=o1NetconfIdleSessionTimeout    operation=delete
    @{parameter_list}    Create List    ${dic_o1NetconfIdleSessionTimeout}
    coam.Perform Object Recommissioning    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANEONAP-1
    ...    operation=update    parameter=@{parameter_list}

TC TearDown
    Log    TC TearDown    console=True
    run keyword if test failed      Recovery SBTS
    Wait Until Keyword Succeeds    20 min    30 sec    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown SBTS
