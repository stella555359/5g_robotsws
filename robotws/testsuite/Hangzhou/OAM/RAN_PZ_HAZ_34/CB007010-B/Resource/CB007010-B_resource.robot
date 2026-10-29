*** Settings ***
Documentation      author: Shuhui Lou
...                 contact: shuhui.lou@nokia-sbell.com
...                This robot file is for cb007010.

Resource          ../../../../RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/L3Call.robot
Library           ../../../../RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/L3CallScript.py
Library          ../../../../RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/check_loadbuild.py
Library           taf.collectors.core   WITH NAME   core
Library           taf.sbts.oam.coam.admin  WITH NAME   admin
Library           taf.collectors.btslog  WITH NAME   btslog
Library           taf.selenium.sbts   WITH NAME   selenium_sbts
Library           taf.ul.selenium.netact     WITH NAME     selenium_netact
Library           OperatingSystem
Library           XML

#Variables         ${CFGFILE_PATH}TLDelta.py

*** Variables ***
#Configure the TL specific variable

${YAFT_PATH}              /opt/ute/YAFT
${WTS_FILE_PATH}       ${tl.core.dir_path}

${UTE_IP}              ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}        ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}        ${tl.test_pc.default_ssh_connection_details.password}


${ASIK_LMP_IP}        ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_LMP_USERNAME}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${ASIK_LMP_PASSWORD}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${ASIK_LMP_IP_URL}          https://${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_IP}             ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}

${WEBUI_IP}                 ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${WEBUI_URL}                https://${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}

${NRBTS_ID}                 ${tl.gnbs[0].global_bts_id}
${MRBTS_ID}                 ${tl.gnbs[0].instance_id}
${distname}                 ${MRBTS_ID}/${NRBTS_ID}

${PB_ASIK_IP}     ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${PB_ASIK_PORT}    ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}


##################define these variable for convenient############################
${ALIAS_ASIK}     asik    ##
${ALIAS_ASIK_SLAVE}    asik_slave    ##
${ALIAS_UTE}      ute    ##
${ALIAS_UTE_2}      ute2    ##
########################END of alias Define#######################################

*** Keywords ***
TC.CB008181_SR_A_07_CM_Delta_Plan_Provision_Operation_No_Service_Outage
    ONAP.start VES simulator and netopeer2
    ONAP.update_xml_file_on_server
    ${add_configuration_duration}      ONAP.add huge configuration
    ${succ_validation_duration}        ONAP.validate xml file
    ${Delta_Plan_provision_duration}   ONAP.Delta_Plan_Provision
    ${roll_back_duration}              ONAP.Roll back modified parameters
    ${delete_configuration_duration}   ONAP.delete huge configuration
    Should Be True    ${Delta_Plan_provision_duration} <= ${TLCommonConfig['ONAP']['KPI']['edit_config_timer']}
    [Teardown]  Run Keyword And Ignore Error   teardown simulator and connection

ONAP.start VES simulator and netopeer2
    log to console    --- Preparing to start VES simulator ---
    ssh.Connect to    hostname=${TLCommonConfig['ONAP']['VES_simulator']['SERVER_IP']}
    ...               username=${TLCommonConfig['ONAP']['VES_simulator']['SERVER_USERNAME']}
    ...               password=${TLCommonConfig['ONAP']['VES_simulator']['SERVER_PASSWORD']}
    ...               alias=${ALIAS_UTE_2}
    log to console    --- start to check if backhaul IP has been configured in VES simulator ---
    ${output_tmp}=         ssh.execute    command=cat /etc/hosts | grep 'ONAP_Int_Test' |awk '{print $1}'    connection=${ALIAS_UTE_2}
    ${output}    Set Variable   ${output_tmp.replace("\r\n", "")}
    Should Be True    '${output}' == '${WEBUI_IP}'
    ssh.send command    command=cd ${TLCommonConfig['ONAP']['VES_simulator']['PATH']}; python3 VES_simulator.py      connection=${ALIAS_UTE_2}
    log to console    --- VES simulator started ---
    log to console    --- Preparing to start netopeer2 ---
    ${asccon}  ${ascch}    SSHShellConnectAndInvokeShell
       ...       ip=${TLCommonConfig['ONAP']['netopeer2']['SERVER_IP']}
       ...       username=${TLCommonConfig['ONAP']['netopeer2']['SERVER_USERNAME']}
       ...       password=${TLCommonConfig['ONAP']['netopeer2']['SERVER_PASSWORD']}    port=22
    ${result}    SSHShellExecuteCommand   ${ascch}    netopeer2-cli\r\n
    ${cmd}=      Catenate    SEPARATOR=${SPACE}   connect --tls --host ONAP_Int_Test --key /home/ute/netconf/ca-key.pem
    ...          --cert /home/ute/netconf/ee_cert.pem --trusted
    ...          /home/ute/netconf/ca-certificate.pem\r\n
    ${result}    SSHShellExecuteCommand   ${ascch}      ${cmd}     timeout=20
    ${Output_1}    ONAP.Output the response of netopeer2  ${result}
    Should Contain      ${Output_1}    WARNING: Schema node
    log to console      --- Netopeer2 started ---
    Set Test Variable   ${asccon}
    Set Test Variable   ${ascch}
ONAP.validate xml file
    ${validate_xml_path}  Set Variable     ${TLCommonConfig['ONAP']['netopeer2']['validate_xml_file_save_path']}
    ${validate_xml_name}  Set Variable     ${TLCommonConfig['ONAP']['netopeer2']['validate_xml_file_save_name']}
    ${Validate_Xml_File_Path}  Join path   ${validate_xml_path}   ${validate_xml_name}
    set test variable    ${Validate_Xml_File_Path}
    ${result1}    SSHShellExecuteCommand   ${ascch}    cmd=get-config --source running --out ${Validate_Xml_File_Path}\r\n
    ...   timeout=30
    ${Output1}         ONAP.Output the response of netopeer2  ${result1}
    Should Contain     ${Output1}    >
    log to console     --- Get config done ---
    run keyword and ignore error       KW.BtsLog.StartBTSlogCollection
    log to console     --- Start to validate xml file, threshold is ${TLCommonConfig['ONAP']['KPI']['valdate_timer']} s ---
    ONAP.delete data tag in xml file   XmlFilePath=${Validate_Xml_File_Path}
    ${rpc-timeout} =    Evaluate    ${TLCommonConfig['ONAP']['KPI']['valdate_timer']} + 50
    ${timeout} =        Evaluate    ${TLCommonConfig['ONAP']['KPI']['valdate_timer']} + 60
    ${result1}          SSHShellExecuteCommand   ${ascch}    cmd=validate --src-config=${Validate_Xml_File_Path} --rpc-timeout ${rpc-timeout}\r\n
    ...   timeout=${timeout}
    ${Output1}          ONAP.Output the response of netopeer2  ${result1}
    Should Contain      ${Output1}    OK
    ${succ_validation_duration}    Check validate duration from syslog
    log to console    --- Validate done ---
    [Return]  ${succ_validation_duration}
    [Teardown]  run keyword and ignore error    BtsLog.StopBTSlogCollectionandGetlog
ONAP.Delta_Plan_Provision
    run keyword and ignore error     KW.BtsLog.StartBTSlogCollection
    ${edit_config_xml_path}   Set Variable  ${TLCommonConfig['ONAP']['netopeer2']['edit_config_xml_file_path']}
    ${edit_config_xml_name}   Set Variable  ${TLCommonConfig['ONAP']['netopeer2']['edit_config_xml_file_name']}
    ${edit_config_File_Path}  Join path     ${edit_config_xml_path}   ${edit_config_xml_name}
    Run Keyword And Ignore Error    run    command=cp ${CFGFILE_PATH}/${edit_config_xml_name} ${edit_config_File_Path}
    ${rpc-timeout} =          Evaluate      ${TLCommonConfig['ONAP']['KPI']['edit_config_timer']} + 50
    ${timeout} =              Evaluate      ${TLCommonConfig['ONAP']['KPI']['edit_config_timer']} + 60
    log to console    --- Start Delta Plan Provision, threshold is ${TLCommonConfig['ONAP']['KPI']['edit_config_timer']} s ---
    ${result1}    SSHShellExecuteCommand   ${ascch}
    ...  cmd=edit-config --target running --config=${edit_config_File_Path} --rpc-timeout=${rpc-timeout}\r\n   timeout=${timeout}
    ${Output2}  ONAP.Output the response of netopeer2  ${result1}
    Should Contain    ${Output2}    OK
    ${CM provision operation}   Check provision activate duration from syslog
    log to console    --- Delta Plan Provision done ---
    [Return]  ${CM provision operation}
    [Teardown]  run keyword and ignore error    BtsLog.StopBTSlogCollectionandGetlog

ONAP.Roll back modified parameters
    run keyword and ignore error     KW.BtsLog.StartBTSlogCollection
    ${edit_config_xml_path}    Set Variable  ${TLCommonConfig['ONAP']['netopeer2']['roll_back_parameters_file_path']}
    ${edit_config_xml_name}    Set Variable  ${TLCommonConfig['ONAP']['netopeer2']['roll_back_parameters_file_name']}
    ${edit_config_File_Path}   Join path     ${edit_config_xml_path}   ${edit_config_xml_name}
    Run Keyword And Ignore Error    run    command=cp ${CFGFILE_PATH}/${edit_config_xml_name} ${edit_config_File_Path}
    ${rpc-timeout} =           Evaluate      ${TLCommonConfig['ONAP']['KPI']['edit_config_timer']} + 50
    ${timeout} =               Evaluate      ${TLCommonConfig['ONAP']['KPI']['edit_config_timer']} + 60
    log to console    --- Start to roll back modified parameters, threshold is ${TLCommonConfig['ONAP']['KPI']['edit_config_timer']} s ---
    ${result1}                 SSHShellExecuteCommand     ${ascch}
    ...  cmd=edit-config --target running --config=${edit_config_File_Path} --rpc-timeout=${rpc-timeout}\r\n   timeout=${timeout}
    ${Output2}                 ONAP.Output the response of netopeer2  ${result1}
    Should Contain    ${Output2}    OK
    Log To Console    --- Check roll back parameters duration from syslog ---
    ${CM provision operation}   Check provision activate duration from syslog
    log to console    --- Roll back parameters done ---
    [Return]  ${CM provision operation}
    [Teardown]  run keyword and ignore error    BtsLog.StopBTSlogCollectionandGetlog
ONAP.add huge configuration
    run keyword and ignore error     KW.BtsLog.StartBTSlogCollection
    ${edit_config_xml_path}       Set Variable  ${TLCommonConfig['ONAP']['huge_configuration']['add_high_num_of_MOs']['file_path']}
    ${edit_config_xml_name}       Set Variable  ${TLCommonConfig['ONAP']['huge_configuration']['add_high_num_of_MOs']['file_name']}
    ${add_huge_config_File_Path}  Join path     ${edit_config_xml_path}   ${edit_config_xml_name}
    Run Keyword And Ignore Error    run    command=cp ${CFGFILE_PATH}/${edit_config_xml_name} ${add_huge_config_File_Path}
    ${rpc-timeout} =              Evaluate      ${TLCommonConfig['ONAP']['huge_configuration']['add_high_num_of_MOs']['timer']} + 20
    ${timeout} =                  Evaluate      ${TLCommonConfig['ONAP']['huge_configuration']['add_high_num_of_MOs']['timer']} + 30
    log to console    --- Start to active huge configuration ---
    ${result1}    SSHShellExecuteCommand   ${ascch}
    ...  cmd=edit-config --target running --config=${add_huge_config_File_Path} --rpc-timeout=${rpc-timeout}\r\n   timeout=${timeout}
    ${Output2}  ONAP.Output the response of netopeer2  ${result1}
    Should Contain    ${Output2}    OK
    Log To Console    --- Check add huge configuration duration from syslog ---
    ${CM provision operation}  Check provision activate duration from syslog
    log to console    --- Active huge configuration done ---
    [Return]  ${CM provision operation}
    [Teardown]  run keyword and ignore error    BtsLog.StopBTSlogCollectionandGetlog
ONAP.delete huge configuration
    run keyword and ignore error     KW.BtsLog.StartBTSlogCollection
    ${edit_config_xml_path}          Set Variable  ${TLCommonConfig['ONAP']['huge_configuration']['delete_high_num_of_MOs']['file_path']}
    ${edit_config_xml_name}          Set Variable  ${TLCommonConfig['ONAP']['huge_configuration']['delete_high_num_of_MOs']['file_name']}
    ${delete_huge_config_File_Path}  Join path   ${edit_config_xml_path}   ${edit_config_xml_name}
    Run Keyword And Ignore Error    run    command=cp ${CFGFILE_PATH}/${edit_config_xml_name} ${delete_huge_config_File_Path}
    ${rpc-timeout} =                 Evaluate    ${TLCommonConfig['ONAP']['huge_configuration']['delete_high_num_of_MOs']['timer']} + 20
    ${timeout} =                     Evaluate    ${TLCommonConfig['ONAP']['huge_configuration']['delete_high_num_of_MOs']['timer']} + 30
    log to console    --- Start to delete huge configuration ---
    ${result1}    SSHShellExecuteCommand   ${ascch}
    ...  cmd=edit-config --target running --config=${delete_huge_config_File_Path} --rpc-timeout=${rpc-timeout}\r\n   timeout=${timeout}
    ${Output2}    ONAP.Output the response of netopeer2  ${result1}
    Should Contain    ${Output2}    OK
    SSHShellDisconnect    accon=${asccon}
    Log To Console    --- Check delete huge configuration duration from syslog ---
    ${CM provision operation}  Check provision activate duration from syslog
    log to console    --- Delete huge configuration done ---
    [Return]  ${CM provision operation}
    [Teardown]  run keyword and ignore error    BtsLog.StopBTSlogCollectionandGetlog
Check validate duration from syslog
    #[Arguments]  ${threshold}
    ${PLAN_VALIDATE_start_check_point}  Set Variable  ${TLCommonConfig['ONAP']['PLAN_VALIDATE_start_check_point']}
    ${PLAN_VALIDATE_end_check_point}    Set Variable  ${TLCommonConfig['ONAP']['PLAN_VALIDATE_end_check_point']}
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "${PLAN_VALIDATE_start_check_point}"|
    ...       awk '{print $7}'|head -n 1|tail -1
    ${succ_validation_startTime}=     run    command=${cmd}
    Should Not Be Empty     ${succ_validation_startTime}
    ${succ_validation_startTime}     DateTime.convert date
    ...    ${succ_validation_startTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "${PLAN_VALIDATE_end_check_point}"|
    ...      awk '{print $7}'|head -n 1|tail -1
    ${succ_validation_endTime}=     run    command=${cmd}
    Should Not Be Empty      ${succ_validation_endTime}
    ${succ_validation_endTime}        DateTime.convert date
    ...     ${succ_validation_endTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${succ_validation_duration}    Evaluate    round(${succ_validation_endTime}-${succ_validation_startTime}, 2)
    Log To Console    --- Actual validation duration is ${succ_validation_duration}s ---
    #Should Be True    ${succ_validation_duration} <= ${threshold}
    [Return]  ${succ_validation_duration}
Check provision activate duration from syslog
    #[Arguments]  ${threshold}
    ${PLAN_VALIDATE_start_check_point}  Set Variable  ${TLCommonConfig['ONAP']['PLAN_VALIDATE_start_check_point']}
    ${PLAN_VALIDATE_end_check_point}    Set Variable  ${TLCommonConfig['ONAP']['PLAN_VALIDATE_end_check_point']}
    ${PLAN_ACTIVATE_start_check_point}  Set Variable  ${TLCommonConfig['ONAP']['PLAN_ACTIVATE_start_check_point']}
    ${PLAN_ACTIVATE_end_check_point}    Set Variable  ${TLCommonConfig['ONAP']['PLAN_ACTIVATE_end_check_point']}
    log to console  --- start to Evaluate validation duration ---
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "${PLAN_VALIDATE_start_check_point}"|
    ...       awk '{print $7}'|head -n 1|tail -1
    ${succ_validation_startTime}=     run    command=${cmd}
    Should Not Be Empty     ${succ_validation_startTime}
    log to console    --- succ_validation_startTime is ${succ_validation_startTime} s ---
    ${succ_validation_startTime}     DateTime.convert date
    ...    ${succ_validation_startTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "${PLAN_VALIDATE_end_check_point}"|
    ...      awk '{print $7}'|head -n 1|tail -1
    ${succ_validation_endTime}=     run    command=${cmd}
    Should Not Be Empty      ${succ_validation_endTime}
    log to console    --- succ_validation_endTime is ${succ_validation_endTime} ---
    ${succ_validation_endTime}        DateTime.convert date
    ...     ${succ_validation_endTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${succ_validation_duration}    Evaluate    round(${succ_validation_endTime}-${succ_validation_startTime}, 2)
    log to console    --- start to Evaluate activation duration ---
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "${PLAN_ACTIVATE_start_check_point}"|
    ...       awk '{print $7}'|head -n 1|tail -1
    ${full_activation_startTime}=     run    command=${cmd}
    Should Not Be Empty     ${full_activation_startTime}
    log to console    --- full_activation_startTime is ${full_activation_startTime} ---
    ${full_activation_startTime}     DateTime.convert date
    ...    ${full_activation_startTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "${PLAN_ACTIVATE_end_check_point}"|
    ...      awk '{print $7}'|head -n 1|tail -1
    ${full_activation_endTime}=     run    command=${cmd}
    Should Not Be Empty     ${full_activation_endTime}
    log to console    --- full_activation_endTime is ${full_activation_endTime} ---
    ${full_activation_endTime}        DateTime.convert date
    ...     ${full_activation_endTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${succ_activation_duration}    Evaluate    round(${full_activation_endTime}-${full_activation_startTime}, 2)
    ${CM provision operation}    Evaluate    round(${full_activation_endTime}-${succ_validation_startTime}, 2)
    Log To Console    --- Actual CM provision operation duration is ${CM provision operation} s ---
    #Should Be True    ${CM provision operation}  <= ${threshold}
    [Return]    ${CM provision operation}

teardown simulator and connection
    [Arguments]
    ssh.Connect to    hostname=${TLCommonConfig['ONAP']['VES_simulator']['SERVER_IP']}
    ...               username=${TLCommonConfig['ONAP']['VES_simulator']['SERVER_USERNAME']}
    ...               password=${TLCommonConfig['ONAP']['VES_simulator']['SERVER_PASSWORD']}
    ...               alias=${ALIAS_UTE}
    ssh.send command    command=ps -ef | grep VES_simulator.py |grep -v grep|awk '{print $2}' | xargs kill -9      connection=${ALIAS_UTE}
    ssh.send command    command=ps -ef | grep netopeer2-cli |grep -v grep|awk '{print $2}' | xargs kill -9      connection=${ALIAS_UTE}
    Run Keyword And Ignore Error    ssh.disconnect    connection=${ALIAS_UTE}
    Run Keyword And Ignore Error    ssh.disconnect    connection=${ALIAS_UTE_2}
ONAP.delete data tag in xml file
    [Arguments]    ${XmlFilePath}
    ${TagToRemove}    Set Variable    data
    ssh.Connect to    hostname=${TLCommonConfig['ONAP']['VES_simulator']['SERVER_IP']}
    ...               username=${TLCommonConfig['ONAP']['VES_simulator']['SERVER_USERNAME']}
    ...               password=${TLCommonConfig['ONAP']['VES_simulator']['SERVER_PASSWORD']}
    ...               alias=${ALIAS_UTE}
    ${output}   ssh.execute    command=head -n 1 ${XmlFilePath}   connection=${ALIAS_UTE}
    log   ${output}
    ${first_10_chars}    Set Variable    ${output[1:5]}
    log   ${first_10_chars}
    Run Keyword if  "${TagToRemove}" in "${first_10_chars}"
    ...   ssh.execute    command=sed -i '1d' ${XmlFilePath}   connection=${ALIAS_UTE}

    ${output1}   ssh.execute    command=tail -n 1 ${XmlFilePath}   connection=${ALIAS_UTE}
    ${first_10_chars1}    Set Variable    ${output1[2:6]}
    Run Keyword if  "${TagToRemove}" in "${first_10_chars1}"
        ...   ssh.execute    command=sed -i '$d' ${XmlFilePath}   connection=${ALIAS_UTE}
    ssh.execute    command=chmod 777 ${XmlFilePath}   connection=${ALIAS_UTE}
    [Teardown]    Run Keyword And Ignore Error    ssh.disconnect    connection=${ALIAS_UTE}

ONAP.Output the response of netopeer2
    [Arguments]    ${result}
    ${result_string}    Decode Bytes To String    ${result}    utf-8
    ${lines}    Split String    ${result_string}    \r\n
    ${Output}    Get From List    ${lines}    1
    log    ${Output}
    [Return]   ${Output}

KW.BtsLog.StartBTSlogCollection
    [Documentation]    collect syslogs from ute VM.
    run keyword and ignore error    run    command=cd /tmp/btslog2 ; rm -rf TRACE_*.bin ; rm -rf SYSLOG_*.LOG
    btslog.create_btslog_collector
    ...   name=btslog
    ...   btslog_path=/home/ute/btslog/btslog
    ...   btslog_launcher_path=/home/ute/btslog/btslog_launcher
    ...   log_dir=/tmp/btslog2
    btslog.Set Global Alias     btslog
    core.setup_collectors       names=btslog
    core.start_collectors       names=btslog


KW.Setup case
    TestCase.Start
    Set Test Variable    ${SCF}     ${TLCommonConfig['ONAP']['SCF_name']}
    teardown simulator and connection
    ${CFGFILE_PATH_for_ONAP}   Join path   ${CFGFILE_PATH}   ONAP
    Set test variable  ${CFGFILE_PATH_for_ONAP}
    run    command=cp ${CFGFILE_PATH_for_ONAP}/${SCF} ${LOG_PATH}/${SCF}
    Run Keyword And Ignore Error    ONAP.Certificate_Install    cert_file=${CFGFILE_PATH_for_ONAP}/CMPHZ.p12
    AlarmWatchdog.add_allow_alarms    fault_id=4639
    Run Keyword If  ${TLCommonConfig['ONAP']['gNB_Commission']} == True    Start with gNB Commission

Start with gNB Commission
    gNB.CommissionWithRetry   scf_file=${LOG_PATH}/${SCF}    model=${tl.gnbs[0].du.airscale.common_units[0].pdu_port.pdu.vendor}
     ...    RUmodel=${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.vendor}
    wait until keyword succeeds     15min   1min    gNB.VerifyOnAirViaOAMUntilReady

KW.Teardown case
    Run Keyword And Ignore Error    COAM_Admin.commission    scf_file=${CFGFILE_PATH}/SCF_SBTS00.xml
    Wait until keyword succeeds   20min   1min    COAM_VerifyOnAirViaFrontendAndBackend
    Run Keyword And Ignore Error    run    command=sudo ps -ef|grep multi_ue_attach_detach | grep -v grep | awk '{print $2}' | xargs kill -9
    Run Keyword And Ignore Error    run    command=ps xafu |grep node|grep -v grep|awk '{print $2}' | xargs kill -9
    Run Keyword And Ignore Error    run    command=killall firefox
    Run Keyword And Ignore Error    run    command=killall geckodriver
    Conn.ResetCache

KW.Setup Suite
    TestSuite.Start
    Create Log Directories
    set suite variable   ${OAM_TYPE}    COAM
    gNB.SetLoggingSeverity    LoggingSeverity=debug
    Run Keyword And Ignore Error    gNB.ReplaceSwconfig    Path=${CFGFILE_PATH}    filename=swconfig.txt
    Conn.ResetCache
    Import Variables        ${CFGFILE_PATH}TLConfiguration.py

KW.Teardown Suite
    TestSuite.Stop




ONAP.update_xml_file_on_server
    log to console    --- start to update xml files ---
    ${validate_xml_path}  Set Variable     ${TLCommonConfig['ONAP']['netopeer2']['validate_xml_file_save_path']}
    ${validate_xml_name}  Set Variable     ${TLCommonConfig['ONAP']['netopeer2']['validate_xml_file_save_name']}
    ${Validate_Xml_File_Path}  Join path   ${validate_xml_path}   ${validate_xml_name}
    set test variable   ${Validate_Xml_File_Path}
    ${result1}    SSHShellExecuteCommand   ${ascch}    cmd=get-config --source running --out ${Validate_Xml_File_Path}\r\n
    ...   timeout=30
    ${Output1}         ONAP.Output the response of netopeer2  ${result1}
    Should Contain     ${Output1}    >
    ONAP.delete data tag in xml file   XmlFilePath=${Validate_Xml_File_Path}
    ssh.Connect to    hostname=${TLCommonConfig['ONAP']['VES_simulator']['SERVER_IP']}
    ...               username=${TLCommonConfig['ONAP']['VES_simulator']['SERVER_USERNAME']}
    ...               password=${TLCommonConfig['ONAP']['VES_simulator']['SERVER_PASSWORD']}
    ...               alias=${ALIAS_UTE}
    ssh.download_file   local_path=/tmp/${validate_xml_name}    remote_path=${Validate_Xml_File_Path}   connection=${ALIAS_UTE}
    sleep    20s
    ${xml_file} =  Set Variable   /tmp/${validate_xml_name}
    ${xml} =  Parse XML  ${xml_file}
    ${NRBTS_element} =  XML.Get Element  ${xml}  NRBTS
    ${NRBTS_xmlns_value} =  XML.Get Element Attribute  ${NRBTS_element}  xmlns
    ${TNLSVC_element} =  XML.Get Element  ${xml}  TNLSVC
    ${TNLSVC_xmlns_value} =  XML.Get Element Attribute  ${TNLSVC_element}  xmlns


    ${add_huge_config_xml_name}        Set Variable  ${TLCommonConfig['ONAP']['huge_configuration']['add_high_num_of_MOs']['file_name']}
    ${delete_huge_config_xml_name}          Set Variable  ${TLCommonConfig['ONAP']['huge_configuration']['delete_high_num_of_MOs']['file_name']}
    ${edit_parameters_xml_name}   Set Variable  ${TLCommonConfig['ONAP']['netopeer2']['edit_config_xml_file_name']}
    ${roll_back_parameters_xml_name}   Set Variable  ${TLCommonConfig['ONAP']['netopeer2']['roll_back_parameters_file_name']}
    ${validate_xml_path}           Set Variable     ${TLCommonConfig['ONAP']['netopeer2']['validate_xml_file_save_path']}

    # 解析第二个 XML 文件
    ${xml2} =  Parse XML  ${CFGFILE_PATH_for_ONAP}/${add_huge_config_xml_name}
    # 查找相同标签并设置新的 xmlns 属性值
    ${second_NRBTS_element} =  XML.Get Element  ${xml2}  NRBTS
    XML.Set Element Attribute  ${second_NRBTS_element}  xmlns  ${NRBTS_xmlns_value}
    Save XML  ${xml2}  /tmp/${add_huge_config_xml_name}

    ${xml3} =  Parse XML  ${CFGFILE_PATH_for_ONAP}/${delete_huge_config_xml_name}
    ${third_NRBTS_element} =  XML.Get Element  ${xml3}  NRBTS
    # 修改 xmlns 属性的值
    XML.Set Element Attribute  ${third_NRBTS_element}  xmlns  ${NRBTS_xmlns_value}
    Save XML  ${xml3}  /tmp/${delete_huge_config_xml_name}

    ${xml4} =  Parse XML  ${CFGFILE_PATH_for_ONAP}/${edit_parameters_xml_name}
    # 查找相同标签并设置新的 xmlns 属性值
    ${fourth_NRBTS_element} =  XML.Get Element  ${xml4}  TNLSVC
    XML.Set Element Attribute  ${fourth_NRBTS_element}  xmlns  ${TNLSVC_xmlns_value}

    Save XML  ${xml4}  /tmp/${edit_parameters_xml_name}

    ${xml5} =  Parse XML  ${CFGFILE_PATH_for_ONAP}/${roll_back_parameters_xml_name}
    ${fifth_NRBTS_element} =  XML.Get Element  ${xml5}  TNLSVC
    # 修改 xmlns 属性的值
    XML.Set Element Attribute  ${fifth_NRBTS_element}  xmlns  ${TNLSVC_xmlns_value}
#    # 保存修改后的 XML 文件
    Save XML  ${xml5}  /tmp/${roll_back_parameters_xml_name}

    ssh.upload_file   local_path=/tmp/${add_huge_config_xml_name}      remote_path=${validate_xml_path}${add_huge_config_xml_name}
       ...   connection=${ALIAS_UTE}
    ssh.upload_file   local_path=/tmp/${delete_huge_config_xml_name}   remote_path=${validate_xml_path}${delete_huge_config_xml_name}
        ...   connection=${ALIAS_UTE}
    ssh.upload_file   local_path=/tmp/${edit_parameters_xml_name}      remote_path=${validate_xml_path}${edit_parameters_xml_name}
        ...   connection=${ALIAS_UTE}
    ssh.upload_file   local_path=/tmp/${roll_back_parameters_xml_name}   remote_path=${validate_xml_path}${roll_back_parameters_xml_name}
        ...   connection=${ALIAS_UTE}
    # 移除 XML 声明
    ssh.execute    command=sed -i '1d' ${validate_xml_path}${add_huge_config_xml_name}   connection=${ALIAS_UTE}
    ssh.execute    command=sed -i '1d' ${validate_xml_path}${delete_huge_config_xml_name}   connection=${ALIAS_UTE}
    ssh.execute    command=sed -i '1d' ${validate_xml_path}${edit_parameters_xml_name}   connection=${ALIAS_UTE}
    ssh.execute    command=sed -i '1d' ${validate_xml_path}${roll_back_parameters_xml_name}   connection=${ALIAS_UTE}
    [Teardown]    Run Keyword And Ignore Error    ssh.disconnect    connection=${ALIAS_UTE}

ONAP.Certificate_Install
    [Arguments]  ${cert_file}=/home/ute/CIENV/CMPHZ.p12  ${cert_type}=BtsTrustChain  ${cert_format}=P12  ${password}=ute
    ...          ${key_pool_type}=RSA
    COAM_Admin.Login  alias=COAM_ONAP
    ${cert_list}    create list
    ${cert_list}=   coam.get_certificate_list    cert_type=BTS  connection=COAM_ONAP
    ${length}    Get Length    ${cert_list}
    run keyword if   ${length}==${0}
    ...    coam.install_certificate    cert_file=${cert_file}  cert_type=${cert_type}  cert_format=${cert_format}
    ...    password=${password}  connection=COAM_ONAP  key_pool_type=${key_pool_type}
    coam.teardown    connection=COAM_ONAP
