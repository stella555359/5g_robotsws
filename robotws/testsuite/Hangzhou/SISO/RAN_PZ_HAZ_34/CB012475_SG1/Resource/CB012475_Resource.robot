*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC002479/Resources/5GC002479_CP_Resource.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/basic/simple_ue.robot
Library     testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.gnb_alarm.AlarmWatchdog    WITH NAME    AlarmWatchdog

*** Variables ***
${UE_TYPE}                  ${tl.ues[0].capabilities[-1]}
${IMSI}                     ${tl.ues[0].imsi}
${IMSI1}                    ${tl.ues[1].imsi}
#${NRBTS_ID}                 ${tl.gnbs[0].global_bts_id}
#${MRBTS_ID}                 ${tl.gnbs[0].instance_id}
${MRBTS_ID}                  MRBTS-${tl.gnbs[0].instance_id}
${NRBTS_ID}                  NRBTS-${tl.gnbs[0].global_bts_id}

${ASIK_IP}                  ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${WEBUI_IP}                 ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${WEBUI_URL}                https://${tl.gnbs[0].cu.oam_http_connection_details.addr}


${Original_CFGFILE}         ${LOG_PATH}/TestLineSCF1Cell_Both.xml

${UE_alias}                 UE_0

${TLDelta_PATH}              ${CFGFILE_PATH}
${initial_S1_SCF}            ${LOG_PATH}/TestLineSCF1Cell_Both.xml

${AMF_IP}                   ${tl.core.mme_ip}
${5GC_IP}                   ${tl.core.default_ssh_connection_details.addr}
${5GC_USERNAME}             ${tl.core.default_ssh_connection_details.username}
${5GC_PASSWORD}             ${tl.core.default_ssh_connection_details.password}
${ENB_WEBUI_IP}             ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
@{CBRS_cell_list}           11    12   13

*** Keywords ***
KW.TestSuilt.Stop_12475
    run keyword and ignore error    COAM_Admin.commission  scf_file=${CFGFILE_PATH}/SCF_SBTS00_NRFinal.xml
    TestSuilt.Stop

KW.TestSuilt.Start_12475
    log to console    Start to do test suite
    run keyword and ignore error    run    command=rm -rf /tmp/
    run keyword and ignore error    run    command=rm -rf /opt/ute/YAFT/YAFT_IMAGE/
    run keyword and ignore error    run    command=rm -rf /home/ute/Download_gNB_Package/
#    run keyword and ignore error    run    command=cd /opt/transformers.dynamic.nsn-net.net/ ; rm -rf *
#    Run Keyword If    '${testline_name}'!='null'    UTECloud.ForceAdaptCommissionFiles
#    ...    ELSE     UTECloud.AdaptCommissionFiles
    UTECloud.ForceAdaptCommissionFiles
    TestSuilt.Start
    #Import Variables     ${CFGFILE_PATH}/TLConfiguration.py
    COAM_Admin.Login
    ${version}    COAM_Admin.GetActiveSoftwareVersion
    Run Keyword And Ignore Error     COAM_Admin.Logout
    run keyword and Ignore error    KW.SWM.Init   vstring=${version}
    set suite variable    ${OAM_TYPE}    COAM
    set suite variable    ${TLDelta_PATH_ON_GIT}        ${CFGFILE_PATH}
    run keyword and ignore error    set suite variable    ${REFERENCE_CONFIGURATION_ID}
    ...    ${CASE_INPUT_5GC002479['REFERENCE_CONFIGURATION_ID']}
    gNB.FormatBTSID       MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
    set suite variable    ${dist_name}   ${MRBTS_ID}/${NRBTS_ID}
    set suite variable    ${AdjRMOD}   None
    set suite variable    ${GracefulCellShutdown}   WithOut_GracefulCellShutdown

    TestCase.Set_Case_Variable     vstring=${version}
    #KW.NetAct.Init
    #KW.WebEM.EnableActcli
    # KW.DisableGracefulCellShutdown
    ${BACKUP_SCF}   COAM_Admin.BackupSCF
    set suite variable    ${BACKUP_SCF}
    COAM_Admin.Login
    ${version}    COAM_Admin.GetActiveSoftwareVersion
    Run Keyword And Ignore Error     COAM_Admin.Logout
    ${version}    Basic.GetStreamAndVersion     vstring=${version}
    log    ${version}
    set suite variable    ${sbts_version}   ${version[1]}

    @{suite_name}    Split String    ${SUITE SOURCE}    /
    @{suite_name}    Split String    ${suite_name[-1]}    .

    ${stream}   ${subversion}    Split String   string=${version[1]}   separator=_     max_split=1
#    ${stream}    set variable if   '${stream}'>='SBTS22R2'    SBTS22R2    SBTS21B
    set suite variable    ${sbts_stream}    ${stream}

    @{version_total}    Split String   string=${version[1]}   separator=_     max_split=3
    set suite variable    ${version_number}    ${version_total[3]}
    log    ${version_number}

    set suite variable    ${case_result_save_path}    ${CASE_RESULT_FLIE_PATH}${testline_name}_${suite_name[0]}_${version[1]}.csv
    Create File    ${case_result_save_path}

    ${file_head}    Catenate    SEPARATOR=,    case name    requirement id    index    Ru type    Ru index
    ...    target value    result value    case result\n
    Append To File    ${case_result_save_path}    ${file_head}
    COAM_WebEM.Login
#    ${version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
#    ${Active_SW_version}    string.split string    string=${version}[Active]
#    set suite variable    ${Active_SW_version}
#    ${SW1}    string.split string    string=${version}[Active]    separator=_
#    ${Active_SwVersion}     convert to string    ${SW1}[-5]
#    set suite variable    ${Active_SwVersion}
    log to console    End test suite succeed

TestCase.Start_12475
    [Arguments]    ${scf_file}    ${sasconf}=${CFGFILE_PATH}SAS_Sim.conf
    log to console    \nStart to do test case start
    AlarmWatchdog.add_allow_alarms    fault_id=6825
    AlarmWatchdog.add_allow_alarms    fault_id=6828
    AlarmWatchdog.add_allow_alarms    fault_id=10
    AlarmWatchdog.add_allow_alarms    fault_id=4589
    AlarmWatchdog.add_allow_alarms    fault_id=6833
    AlarmWatchdog.add_allow_alarms    fault_id=6823
    AlarmWatchdog.add_allow_alarms    fault_id=6829
    AlarmWatchdog.add_allow_alarms    fault_id=49
    AlarmWatchdog.add_allow_alarms    fault_id=6831
    AlarmWatchdog.add_allow_alarms    fault_id=6830
    AlarmWatchdog.add_allow_alarms    fault_id=6826
    AlarmWatchdog.add_allow_alarms    fault_id=6827
    AlarmWatchdog.add_allow_alarms    fault_id=6833
    Run Keyword And Ignore error   gNB.ReplaceSwconfig
    Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
    COAM_Admin.commission    scf_file=${scf_file}   skip_parameter_relation_errors=False
    KW.ReplaceSAS_Conf    sasconf=${sasconf}
    KW.RestartSAS_UTE
    set test variable    ${graceful_cell_shutdown}    True
    log to console   \nEnd test case start succeed

TeardownCase_12475
    sleep    5min
    Teardown case if case fail
    Run Keyword And Ignore error    KW.GetSASLog_UTE
    Run Keyword And Ignore error    COAM_WebEM.Login
#    Run Keyword And Ignore error    COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}
#    ...    abbr=Activate NR CBRS    value=false
#    Run Keyword And Ignore error    COAM_WebEM.ValidateAndActiveParameters
    Run Keyword And Ignore error    COAM_WebEM.Logout
    Run Keyword And Ignore error    KW.ReplaceSAS_Conf
    #Run Keyword And Ignore error    KW.RestartSAS_UTE
    #COAM_WebEM.Login
    #Run Keyword And Ignore error    COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}
    #...    abbr=Activate NR CBRS    value=true
   # Run Keyword And Ignore error    COAM_WebEM.ValidateAndActiveParameters
    #COAM_WebEM.Logout
    TestCase.Stop
    AlarmWatchdog.remove_allow_alarms    fault_id=6825
    AlarmWatchdog.remove_allow_alarms    fault_id=6828
    AlarmWatchdog.remove_allow_alarms    fault_id=10
    AlarmWatchdog.remove_allow_alarms    fault_id=4589
    AlarmWatchdog.remove_allow_alarms    fault_id=6833
    AlarmWatchdog.remove_allow_alarms    fault_id=6823
    AlarmWatchdog.remove_allow_alarms    fault_id=6829
    AlarmWatchdog.remove_allow_alarms    fault_id=49
    AlarmWatchdog.remove_allow_alarms    fault_id=6831
    AlarmWatchdog.remove_allow_alarms    fault_id=6830
    AlarmWatchdog.remove_allow_alarms    fault_id=6833
    AlarmWatchdog.remove_allow_alarms    fault_id=6827
    AlarmWatchdog.remove_allow_alarms    fault_id=6826
    log to console   End test case teardown

KW.RestartSAS_UTE
    [Arguments]   ${SAS_IP}=${CASE_INPUT_CB012475['SAS_IP']}
    ...           ${SAS_UserName}=${CASE_INPUT_CB012475['SAS_UserName']}
    ...           ${SAS_Password}=${CASE_INPUT_CB012475['SAS_Password']}
    wait until keyword succeeds   5x   30s   Conn.ConnectToDev  IP=${SAS_IP}
    ...    USERNAME=${SAS_UserName}
    ...    PASSWORD=${SAS_Password}   alias=SAS_UTE
    Conn.Execute  cmd=ps -ef|grep SAS_Sim|grep -v grep|awk '{print $2}' | xargs kill -9    alias=SAS_UTE
    ${cmd_temp}   Set Variable
    ...    source /home/ute/CIENV/${testline_name}/bin/activate&&cd /opt/ute/tools/sasserver/&&python SAS_Sim.py
#    Conn.Execute    cmd=${cmd_temp}    alias=SAS_UTE
    ssh.send_command    command=${cmd_temp}   connection=SAS_UTE
#    sleep   5s
    ${result}    run    ps -ef|grep SAS_Sim
    log to console   \n${result}\n
	Conn.Disconnect   alias=SAS_UTE
#    wait until keyword succeeds   5x   30s   Conn.ConnectToDev  IP=${SAS_IP}
#    ...    USERNAME=${SAS_UserName}
#    ...    PASSWORD=${SAS_Password}   alias=SAS_UTE
#    Conn.Execute  cmd=ps -ef|grep SAS_Sim|grep -v grep|awk '{print $2}' | xargs kill -9    alias=SAS_UTE
#    ${cmd_temp}   Set Variable
#    ...    source /home/ute/CIENV/${testline_name}/bin/activate&&nohup python /opt/ute/tools/sasserver/SAS_Sim.py &>/dev/null &\r\n
#    Conn.Execute    cmd=${cmd_temp}    alias=SAS_UTE
#    sleep   5s
#    ${result}    run    ps -ef|grep SAS_Sim
#    log to console   \n${result}\n
#	Conn.Disconnect   alias=SAS_UTE
#    ${result_kill}=  run    ps -ef|grep SAS_Sim|grep -v grep|awk '{print $2}' | xargs kill -9
#    ${result_start}=  run   nohup /bin/bash -c "python /opt/ute/tools/sasserver/SAS_Sim.py &>/dev/null &\r\n"
#    ${result_process}=  run    ps -ef|grep SAS_Sim
#    log to console    ${result_process}

KW.GetSASLog_UTE
    [Arguments]  ${saspath}=/opt/ute/tools/sasserver/    ${SAS_IP}=${CASE_INPUT_CB012475['SAS_IP']}
    ...           ${SAS_UserName}=${CASE_INPUT_CB012475['SAS_UserName']}
    ...           ${SAS_Password}=${CASE_INPUT_CB012475['SAS_Password']}
    ${current_time}         Get Current Date
    ${current_time}         convert date    ${current_time}     epoch
    #${filename}    set variable    ${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "").replace("[", "").replace("]", "")}
    #run   cp ${saspath}SAS_Sim.log ${LOG_PATH}/SAS_Sim_${filename}.log
	wait until keyword succeeds   5x   30s   Conn.ConnectToDev  IP=${SAS_IP}
    ...    USERNAME=${SAS_UserName}
    ...    PASSWORD=${SAS_Password}   alias=SAS_Log
	Conn.Execute  cmd=scp ${saspath}SAS_Sim.log ${LOG_PATH}/SAS_Sim_${current_time}.log   alias=SAS_Log
	ssh.download_file   local_path=${LOG_PATH}/SAS_Sim_${current_time}.log
	...    remote_path=${saspath}SAS_Sim.log   connection=SAS_Log
	Conn.Disconnect   alias=SAS_Log

KW.ReplaceSAS_Conf
    [Arguments]  ${saspath}=/opt/ute/tools/sasserver/     ${sasconf}=${CFGFILE_PATH}SAS_Sim.conf
    ...          ${SAS_IP}=${CASE_INPUT_CB012475['SAS_IP']}
    ...           ${SAS_UserName}=${CASE_INPUT_CB012475['SAS_UserName']}
    ...           ${SAS_Password}=${CASE_INPUT_CB012475['SAS_Password']}
    wait until keyword succeeds   5x   30s   Conn.ConnectToDev  IP=${SAS_IP}
    ...    USERNAME=${SAS_UserName}
    ...    PASSWORD=${SAS_Password}   alias=SAS_Conf
    Conn.UploadFile    local_path=${sasconf}    remote_path=${saspath}SAS_Sim.conf    alias=SAS_Conf
    Conn.Disconnect   alias=SAS_Conf

KW.Expect_Fault_Should_Absent
    [Documentation]
    [Arguments]   ${target_alarm_id}   ${target_fault_id}   ${target_fault_name}    ${target_severity}
    ${status}    Run Keyword And Return Status   Alarm.Check Certain Alarm with Severity form Active Alarms
    ...                                                 target_alarm_id=${target_alarm_id}
    ...                                                 target_fault_id=${target_fault_id}
    ...                                                 target_fault_name=${target_fault_name}
    ...                                                 target_severity=${target_severity}
    Run Keyword If  ${status}==${True}   Fail   faultId ${target_fault_id} is still present on gnb.

KW.Check_ParameterValue_inFullSCF
    [Arguments]     ${file_path}    ${dist_name}    ${p_name}    ${list_name}    ${target_value}
    scf.Load Scf          file_path=${file_path}
    ${check_value}=    scf.get_all_values_from_scf    dist_name=${dist_name}  p_name=${p_name}
    ...    list_name=${list_name}
    log to console    ${check_value}
    ${length}=   Get Length   ${check_value}
    run keyword if    ${length}<=0    Fail    There has no value of ${list_name}_${p_name} in the full scf.
    FOR    ${index}    IN RANGE   0    ${length}
        Should be equal as strings    ${check_value[${index}]}    ${target_value}    ignore_case=${True}
    END

TC.CB012475_SR_B_19_06_SiSo_Supercell_setup_with_one_radiol_not_detected_1Supercell_3subcells_MixedConfig
    [Documentation]    PR763331
    ...                Step1: commission with 1supercell_3subcells and noramllcell mixed, CBRS flag is deactive
    ...                Step2: power off CBSD which constitue supercell
    ...                Step3: active CBRS flag, check fault 10, NRCBSDCELL grant info
    ...                Step4: power on CBSD, check fault, NRCBSDCELL grant info, supercell and normalcell state
    ...                Step5: power off CBSD which constitue supercell
    ...                Step6: check fault 10, NRCBSDCELL grant info, supercell state
    ...                Step7: power on CBSD, check fault, NRCBSDCELL grant info, supercell and normalcell state
    [Arguments]    ${ru_Index}=6    ${supercell_Index}=11
    log to console    Step2 power off CBSD which constitue supercell
    COAM_WebEM.Login
    Power.OnOff    pdu_ip=${tl.gnbs[0].dus[0].rus[${ru_Index}].pdu_port.pdu.addr}
    ...    Port_Number=${tl.gnbs[0].dus[0].rus[${ru_Index}].pdu_port.port_no}
    ...    Action=power_off
    ...    model=${tl.gnbs[0].dus[0].rus[${ru_Index}].pdu_port.pdu}
    log to console    Step3 active CBRS flag, check fault 10, NRCBSDCELL grant info
    COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}
    ...    abbr=Activate NR CBRS	    value=true
    COAM_WebEM.ValidateAndActiveParameters
    sleep   3min
    ##check
    ${BTSInfo}      COAM_Admin.GetBTSInfo    bts_host=${WEBUI_IP}
    ${CellsInfo}    set variable    ${BTSInfo['cells']['nr']}
    ${CellNum}    selenium_coam.get_number_of_cells
    wait until keyword succeeds   5min   2s    Alarm.Check Certain Alarm with Severity form Active Alarms   target_alarm_id=7116
    ...    target_fault_id=10    target_fault_name=No connection to unit    target_severity=critical
    log to console    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    sleep    2min
    ${full_scf}    Get SCF with Runtime Objects    file_dir=${LOG_PATH}
    FOR  ${cell_id}  IN  @{CBRS_cell_list}
         KW.Check_ParameterValue_inFullSCF
         ...    file_path=${full_scf}
         ...    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-${cell_id}/NRCBSDCELL-0
         ...    p_name=grantOperationStateSub
         ...    list_name=subGrantInfo
         ...    target_value=Authorized
    END
    COAM_WebEM.Logout

    log to console    Step 4 power on CBSD, check fault, NRCBSDCELL grant info, supercell and normalcell state
    Power.OnOff    pdu_ip=${tl.gnbs[0].dus[0].rus[${ru_Index}].pdu_port.pdu.addr}
    ...    Port_Number=${tl.gnbs[0].dus[0].rus[${ru_Index}].pdu_port.port_no}
    ...    Action=power_on
    ...    model=${tl.gnbs[0].dus[0].rus[${ru_Index}].pdu_port.pdu}

    COAM_WebEM.Login
    Wait until keyword succeeds    10min    30s    KW.Expect_Fault_Should_Absent    target_alarm_id=7116
    ...    target_fault_id=10    target_fault_name=No connection to unit    target_severity=critical

    sleep   3min
    ${full_scf}    Get SCF with Runtime Objects    file_dir=${LOG_PATH}
    FOR  ${cell_id}  IN  @{CBRS_cell_list}
         KW.Check_ParameterValue_inFullSCF
         ...    file_path=${full_scf}
         ...    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-${cell_id}/NRCBSDCELL-0
         ...    p_name=grantOperationStateSub
         ...    list_name=subGrantInfo
         ...    target_value=Authorized
         ${cell_info}    selenium_coam.get_cell_info    cell_idx=${cell_id}
         log    ${cell_info} and ${cell_info['Status']['Availability status']}
         Should be equal as strings
         ...      ${cell_info['Status']['Operational state']}    Enabled    ignore_case=${True}
    END
    COAM_WebEM.Logout

    log to console    Step5: power off CBSD which constitue supercell
    Power.OnOff    pdu_ip=${tl.gnbs[0].dus[0].rus[${ru_Index}].pdu_port.pdu.addr}
    ...    Port_Number=${tl.gnbs[0].dus[0].rus[${ru_Index}].pdu_port.port_no}
    ...    Action=power_off
    ...    model=${tl.gnbs[0].dus[0].rus[${ru_Index}].pdu_port.pdu}

    log to console    Step6: check fault 10, NRCBSDCELL grant info, supercell state
    COAM_WebEM.Login
    wait until keyword succeeds   5min   2s    Alarm.Check Certain Alarm with Severity form Active Alarms   target_alarm_id=7116
    ...    target_fault_id=10    target_fault_name=No connection to unit    target_severity=major
    sleep  3min
    ${cell_info}    selenium_coam.get_cell_info    cell_idx=${supercell_Index}
    log    ${cell_info} and ${cell_info['Status']['Availability status']}
    Should be equal as strings
    ...      ${cell_info['Status']['Availability status']}    degraded    ignore_case=${True}
    COAM_WebEM.Logout

    log to console    Step7: power on CBSD, check fault, NRCBSDCELL grant info, supercell and normalcell state
    Power.OnOff    pdu_ip=${tl.gnbs[0].dus[0].rus[${ru_Index}].pdu_port.pdu.addr}
    ...    Port_Number=${tl.gnbs[0].dus[0].rus[${ru_Index}].pdu_port.port_no}
    ...    Action=power_on
    ...    model=${tl.gnbs[0].dus[0].rus[${ru_Index}].pdu_port.pdu}

    COAM_WebEM.Login
    Wait until keyword succeeds    10min    30s    KW.Expect_Fault_Should_Absent    target_alarm_id=7116
    ...    target_fault_id=10    target_fault_name=No connection to unit    target_severity=major
    sleep    3min
    ${full_scf}    Get SCF with Runtime Objects    file_dir=${LOG_PATH}
    FOR  ${cell_id}  IN  @{CBRS_cell_list}
         KW.Check_ParameterValue_inFullSCF
         ...    file_path=${full_scf}
         ...    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-${cell_id}/NRCBSDCELL-0
         ...    p_name=grantOperationStateSub
         ...    list_name=subGrantInfo
         ...    target_value=Authorized
         ${cell_info}    selenium_coam.get_cell_info    cell_idx=${cell_id}
         log    ${cell_info} and ${cell_info['Status']['Availability status']}
         Should be equal as strings
         ...      ${cell_info['Status']['Operational state']}    Enabled    ignore_case=${True}
    END
    COAM_WebEM.Logout
    [Teardown]    run keywords      Power.OnOff    pdu_ip=${tl.gnbs[0].dus[0].rus[${ru_Index}].pdu_port.pdu.addr}
    ...    Port_Number=${tl.gnbs[0].dus[0].rus[${ru_Index}].pdu_port.port_no}
    ...    Action=power_on
    ...    model=${tl.gnbs[0].dus[0].rus[${ru_Index}].pdu_port.pdu}
    ...    AND    sleep    5min

TC.CB012475_SR_B_20_03_SiSo_one_subcell_degraded_after_Supercell_setup_1Supercell_3subcells_MixedConfig
    [Arguments]    ${supercell_Index}=1
    log to console   \nStep2: active CBRS flag, check NRCBSDCELL grant info, supercell and normalcell state
    COAM_WebEM.Login
    COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}
    ...    abbr=Activate NR CBRS	    value=true
    COAM_WebEM.ValidateAndActiveParameters
    sleep    1min
    ${CellNum}    selenium_coam.get_number_of_cells
    ${full_scf}    Get SCF with Runtime Objects    file_dir=${LOG_PATH}
    FOR  ${cell_id}  IN RANGE    1    ${CellNum}+1
         KW.Check_ParameterValue_inFullSCF
         ...    file_path=${full_scf}
         ...    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-${cell_id}/NRCBSDCELL-0
         ...    p_name=grantOperationStateSub
         ...    list_name=subGrantInfo
         ...    target_value=Authorized
         ${cell_info}    selenium_coam.get_cell_info    cell_idx=${cell_id}
         log    ${cell_info} and ${cell_info['Status']['Availability status']}
         Should be equal as strings
         ...      ${cell_info['Status']['Operational state']}    Enabled    ignore_case=${True}
    END
   log to console   \nStep3: wait SAS server response HB code 500, check fault and supercell state
    wait until keyword succeeds   5min   2s    Alarm.Check Certain Alarm with Severity form Active Alarms   target_alarm_id=7116
    ...    target_fault_id=6823    target_fault_name=SAS Grant Termination Revocation Failure    target_severity=major

    ${cell_info}    selenium_coam.get_cell_info    cell_idx=${supercell_Index}
    log    ${cell_info} and ${cell_info['Status']['Availability status']}
    Should be equal as strings
    ...      ${cell_info['Status']['Availability status']}    degraded    ignore_case=${True}

    log to console   \nStep4: wait querySasServerPeriod expired, check fault and supercell state
    Wait until keyword succeeds    5min    30s    KW.Expect_Fault_Should_Absent    target_alarm_id=7116
    ...    target_fault_id=6823    target_fault_name=SAS Grant Termination Revocation Failure    target_severity=major
    sleep    3min
    ${full_scf}    Get SCF with Runtime Objects    file_dir=${LOG_PATH}
    FOR  ${cell_id}  IN RANGE    1    ${CellNum}+1
         KW.Check_ParameterValue_inFullSCF
         ...    file_path=${full_scf}
         ...    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-${cell_id}/NRCBSDCELL-0
         ...    p_name=grantOperationStateSub
         ...    list_name=subGrantInfo
         ...    target_value=Authorized
         ${cell_info}    selenium_coam.get_cell_info    cell_idx=${cell_id}
         log    ${cell_info} and ${cell_info['Status']['Availability status']}
         Should be equal as strings
         ...      ${cell_info['Status']['Operational state']}    Enabled    ignore_case=${True}
    END
    COAM_WebEM.Logout
    log to console   \nStep5: Block supercell CBSD and normalcell CBSD, wait LockCellTimer expired
   COAM_WebEM.Login
   FOR  ${cell_id}  IN RANGE    1    ${CellNum}+1
       COAM_WEBEM.BlockUnBlcokCell    cell_idx=${cell_id}    action=block
   END
   COAM_WebEM.Logout
   sleep   3min

   log to console   \nStep6: check NRCBSDCELL grant info, supercell and normalcell state
   COAM_WebEM.Login
   ${full_scf}    Get SCF with Runtime Objects    file_dir=${LOG_PATH}
   FOR  ${cell_id}  IN RANGE    1    ${CellNum}+1
         KW.Check_ParameterValue_inFullSCF
         ...    file_path=${full_scf}
         ...    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-${cell_id}/NRCBSDCELL-0
         ...    p_name=grantOperationStateSub
         ...    list_name=subGrantInfo
         ...    target_value=Idle
   END
   COAM_WebEM.Logout
   log to console   \nStep7: unBlock supercell CBSD and normalcell CBSD
   COAM_WebEM.Login
   FOR  ${cell_id}  IN RANGE    1    ${CellNum}+1
       COAM_WEBEM.BlockUnBlcokCell    cell_idx=${cell_id}    action=unblock
   END
   COAM_WebEM.Logout
   sleep   3min
   COAM_WebEM.VerifyAllCellsAreOnline


Reset Site
    [Documentation]
    [Arguments]  ${loop_times}=3    ${duration_target}=600
    log to console    Start to Reset site
    ${duration_KPI}      set variable    0
    FOR  ${i}  IN RANGE  1  ${loop_times}+1
        log to console    Start site reset loop${i}
        Wait until keyword succeeds   2min   20s    COAM_WebEM.Login    version=${Active_SwVersion}
        ${start_time}    Get Time    epoch
        Wait until keyword succeeds   1min   2s    selenium_sbts.reset_site
        Run Keyword And Ignore error   COAM_WebEM.Logout
        wait until keyword succeeds   15min   15s    COAM_Admin.CheckAllCellsOnair
        ${end_time}    Get Time    epoch
        ${duration_tmp}=    Evaluate    ${end_time} - ${start_time}
        ${duration_KPI}=    Evaluate    ${duration_tmp} + ${duration_KPI}
        Set test Variable    ${duration_KPI}    ${duration_KPI}
    END
    ${duration_KPI}    Evaluate   round(${duration_KPI}/${loop_times}, 2)
    Should be true     ${duration_KPI} < ${duration_target}

Get SCF with Runtime Objects
    [Arguments]   ${file_dir}=${file_dir}   ${connection}=COAM
    ${timestamp}    Get Time    epoch
    ${file_name}    set variable    ${timestamp}_scf.xml
    wait until keyword succeeds   3x   1min    COAM_Admin.Login
    coam.get_current_scf_file   local_dir_path=${file_dir}   file_name=${file_name}   connection=${connection}
    ...    export_type=configurationAndRuntimeObjects    timeout=20
    ${full_scf}=   Join Path   ${file_dir}   ${file_name}
    Run Keyword And Ignore error    COAM_Admin.Logout
    [Return]  ${full_scf}