*** Settings ***
Documentation   Keywords including emssim configurations on VM.
...             Author:     Maciej Jopek
...             Contact:    maciej.jopek@nokia.com

Resource      ./emssim_variables.robot
Library       ta_emss
Library       Collections
Library       OperatingSystem
Library       SSHLibrary


*** Keywords ***
Add EMSSIM User on VM
    [Documentation]  Keyword is responsible for add emssim user on VM
    Log                 Creating user flexi${tl.gnbs[0].global_bts_id} on EMSSIM VM...    console=True
    Run                 sudo /opt/emssim/util/add_user.pl -u flexi${tl.gnbs[0].global_bts_id} -ip ${tl.gnbs[0].cu.backhaul_site_oam_ip.v4}
    Log                 Creating user flexi${tl.gnbs[0].global_bts_id} done    console=True

Apache Restart
    [Documentation]  Keyword is responsible for restarting Apache.
    Log    Restart apache2    console=True
    RUN   sudo systemctl restart

Certificates Copy
    [Documentation]  Keyword is responsible for copying unpleasant certificates on VM.
    Log    Copying certificates    console=True
    Run    sudo cp ${cert_path}/*.pem ${emssim_ssl_path}
    Run    sudo cp ${cert_path}/*.pem ${emssim_apache_key}
    Run    sudo cp ${cert_path}/*.pem ${emssim_apache_crt}

Setup environment for EMSSIM
    [Documentation]  Keyword including emssim configurations on VM.
    Log    Setup environment for EMSSIM started    console=True
    Certificates Copy
    Strings Replacing
    Apache Restart

Strings Replacing
    [Documentation]  Keyword is responsible for replacing necessary string in files on VM.
    Log    Replacing strings in files    console=True
    Run   sed -i 's/CipherString = DEFAULT@SECLEVEL=[0-9]/CipherString = DEFAULT@SECLEVEL=1/g' /etc/ssl/openssl.cnf
    Run   sed -i '34i\ SSLCertificateChainFile /etc/apache2/ssl.crt/cacert.pem' /home/ute/default-ssl.conf

EMSSIM All Cells Should Be Enabled
    [Arguments]    ${enb_id}=${EMSSIM_ENB_ID}
    ta_emss.All Cells Should Be Enabled    enb_id=${enb_id}

EMSSIM Check If Attribute Exists
    [Arguments]    ${object_name}
    ...            ${attribute}
    ...            ${enb_id}=${EMSSIM_ENB_ID}
    ta_emss.Check If Attribute Exists    object_name=${object_name}
    ...                                  attribute=${attribute}
    ...                                  enb_id=${enb_id}

EMSSIM Check If Object Exists
    [Arguments]    ${object_name}
    ...            ${enb_id}=${EMSSIM_ENB_ID}
    ta_emss.Check If Object Exists    object_name=${object_name}
    ...                               enb_id=${enb_id}

EMSSIM Check if message exists in log
    [Arguments]    ${message}
    ...            ${log_dir}=${EMSSIM_LOG_DIR}
    Log  Checking EMSSIM console for ${message}    console=yes
    ${log_file_content}=  Run  cat ${log_dir}
    Should Contain  ${log_file_content}  ${message}

EMSSIM Clear Alarm History
    [Arguments]    ${enb_id}=${EMSSIM_ENB_ID}
    ta_emss.Clear Alarm History    enb_id=${enb_id}

EMSSIM Check If There Are Number Of Occurrences Of Fault With Alarm In EMSS
    [Documentation]
    ...    Author: Monika Kurzyp
    [Arguments]     ${fault_id}
    ...             ${alarm_number}
    ...             ${number_of_occurrences}

    @{alarms}=   ta_emss.Get Alarm History
    ${count}=   Set Variable      0
    FOR  ${item}   IN    @{alarms}
        ${fault}=   Get From Dictionary   ${item}   FAULT ID
        ${ID}=   run keyword if   ${fault}==${fault_id}   Get From Dictionary   ${item}   ID
        ${object}=  run keyword if   ${fault}==${fault_id}   Get From Dictionary   ${item}   OBJECT
        ${count} =  run Keyword If    ${ID}==${alarm_number}    Set Variable  ${count}+1     ELSE     Set Variable    ${count}
        ${number_of_alarms}=   Evaluate    ${count}
    END
    Should Be Equal    ${number_of_alarms}   ${${number_of_occurrences}}

EMSSIM Enb Should Be OnAir
    [Arguments]    ${enb_id}=${EMSSIM_ENB_ID}
    ta_emss.Enb Should Be Onair    enb_id=${enb_id}

EMSSIM Get Enb Active Alarms
    [Arguments]    ${criteria}=ID
    ...            ${enb_id}=${EMSSIM_ENB_ID}
    ${alarm_list}=  ta_emss.Get Enb Active Alarms As String Of Ids    criteria=${criteria}
    ...                                                               enb_id=${enb_id}
    [Return]    ${alarm_list}

EMSSIM Get Enb Active Faults
    [Arguments]    ${retry_limit}=3
    ...            ${retry_sleep}=30
    ...            ${enb_id}=${EMSSIM_ENB_ID}
    @{alarm_list}=    ta_emss.Get Enb Active Alarms    retry_limit=${retry_limit}
    ...                                                retry_sleep=${retry_sleep}
    ...                                                enb_id=${enb_id}
    [Return]    @{alarm_list}

EMSSIM Get Faults History
    [Arguments]    ${enb_id}=${EMSSIM_ENB_ID}
    @{alarm_list}=    ta_emss.Get Alarm History    enb_id=${enb_id}
    [Return]    @{alarm_list}

EMSSIM Get LNBTS Object Name
    [Arguments]    ${enb_id}=${EMSSIM_ENB_ID}
    ${lnbts_name}=    Get LNBTS Object Name    enb_id=${enb_id}
    [Return]    ${lnbts_name}

EMSSIM Perform Software Rollback
    EMSSIM Run Emssim Command  command=sw_rollback
    ...                        timeout=720

EMSSIM Perform Software Update With Activation
     [Arguments]    ${software_path}
     ...            ${delay_after}=30
     ...            ${enb_id}=${EMSSIM_ENB_ID}
     ta_emss.Perform Software Update    target=${software_path}
     ...                                delay_after=${delay_after}
     ...                                enb_id=${enb_id}

EMSSIM Perform Software Update Without Activation
     [Arguments]    ${software_path}
     ...            ${command}=sw_update
     ...            ${timeout}=720
     ta_emss.Run Emssim Command  command=${command}
     ...                         params=${software_path} 0
     ...                         timeout=${timeout}

EMSSIM Run Emssim Command
     [Arguments]    ${command}
     ...            ${params}=${EMSSIM_COMMAND_PARAMS}
     ...            ${timeout}=${EMSSIM_COMMAND_TIMEOUT}
     ...            ${get_full_data}=${EMSSIM_COMMAND_FULL_DATA}
     ...            ${can_fail}=${EMSSIM_COMMAND_CAN_FAIL}
     ...            ${enb_id}=${EMSSIM_ENB_ID}
     ta_emss.Run Emssim Command  command=${command}
     ...                         params=${params}
     ...                         timeout=${timeout}
     ...                         get_full_data=${get_full_data}
     ...                         can_fail=${can_fail}
     ...                         enb_id=${enb_id}

EMSSIM Setup Emssim
    [Arguments]    ${timeout}=${EMSSIM_CONNECTION_TIMEOUT}
    ...            ${bts_timeout}=${EMSSIM_BTS_CONNECTION_TIMEOUT}
    ...            ${wait_connected}=${EMSSIM_WAIT_CONNECTED}
    ...            ${wait_discovered}=${EMSSIM_WAIT_DISCOVERED}
    ...            ${enb_id}=${EMSSIM_ENB_ID}
    ...            ${host}=${EMSSIM_HOST}
    ...            ${port}=${EMSSIM_PORT}
    ...            ${log_dir}=${EMSSIM_LOG_DIR}
    ...            ${log_level}=${EMSSIM_LOG_LEVEL}
    ta_emss.Setup EMSS    timeout=${timeout}
    ...                   bts_timeout=${bts_timeout}
    ...                   wait_connected=${wait_connected}
    ...                   wait_discovered=${wait_discovered}
    ...                   enb_id=${enb_id}
    ...                   host=${host}
    ...                   port=${port}
    ta_emss.Logging Stop
    EMSSIM Run Emssim Command  command=slog
    ...                        params=${log_dir} ${log_level}


EMSSIM Software On Active Partition Should Be
    [Arguments]    ${software_version}
    EMSSIM Software Version Should Be  software_version=${software_version}
    ...                                partition=Active

EMSSIM Software On Passive Partition Should Be
    [Arguments]    ${software_version}
    EMSSIM Software Version Should Be  software_version=${software_version}
    ...                                partition=Passive

EMSSIM Software Version Should Be
    [Arguments]    ${software_version}
    ...            ${partition}
    #...            ${enb_id}=${EMSSIM_ENB_ID}
    ta_emss.Software Version Should Be    version=${software_version}
    ...                                   type=${partition}
    ...                                   enb_id=${EMSSIM_ENB_ID}

EMSSIM Teardown Emssim
    [Arguments]    ${output_log_dir}=${EMSSIM_OUTPUT_LOG_DIR}
    ...            ${emssim_log_dir}=${EMSSIM_LOG_DIR}
    ...            ${enb_id}=${EMSSIM_ENB_ID}
    EMSSIM Run Emssim Command  command=slog
    ta_emss.Teardown EMSS    enb_id=${enb_id}
    Run Keyword If  '${output_log_dir}'!='${EMPTY}'
    ...  Copy File  ${emssim_log_dir}  ${output_log_dir}


EMSSIM RTPM Activate
    #[Arguments]     ${retry_limit}=3
    #...            ${retry_sleep}=30
    #...            ${enb_id}=${EMSSIM_ENB_ID}
    Run keyword and ignore error  ta_emss.Rtpm Activate

EMSSIM RTPM counters received
    #[Arguments]     ${enb_id}=${EMSSIM_ENB_ID}
    ta_emss.Wait For Rtpm After Test

EMSSIM RTPM counters are cleared
    #[Arguments]     ${enb_id}=${EMSSIM_ENB_ID}
    ta_emss.Wait For Rtpm Before test

EMSSIM RTPM interval and Counter value
    #[Arguments]     ${enb_id}=${EMSSIM_ENB_ID}
    ta_emss.Wait For Interval And Verify Rtpm Counter Value And Report To Rp

EMSSIM RTPM Counter value NOT changed
    #[Arguments]     ${counter_id}
    #...             ${enb_id}=${EMSSIM_ENB_ID}
    ta_emss.Verify That Rtpm Counter Was Not Incremented

EMSSIM RTPM Counter exists
    [Arguments]     ${counter_id}
    ...             ${object_name}
    ...             ${check_if_exists}=True
    #...             ${enb_id}=${EMSSIM_ENB_ID}
    ta_emss.Verify That Rtpm Counter Value Is Equal To    counter_id=${counter_id}
    ...                                                   object_name=${object_name}
    ...                                                   value=[0,999999]
    ...                                                   check_if_exists=${check_if_exists}
    ...                                                   enb_id=${EMSSIM_ENB_ID}
