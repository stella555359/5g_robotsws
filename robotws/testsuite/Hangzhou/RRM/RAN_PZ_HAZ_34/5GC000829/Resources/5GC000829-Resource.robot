*** Settings ***
Documentation          author: Zhang Wenjin
...                            Luo Frank
...                            Cai Wenjuan
...                            Li Yajie
...                            Gao Ge
...                    contact: wenjin.zhang@nokia-sbell.com
...                    squard group: SG_01
...                    feature: 5GC000829
Library                urllib
Library                String
Library                taf.config.scf                        WITH NAME    scf
Library                taf.transport.ssh		             WITH NAME	  ssh
Library                taf.sbts.oam.coam.admin                WITH NAME    coam
Library                taf.sw.dcap.rd                        WITH NAME    rd
Library                taf.fdsw.rc                            WITH NAME  fdswrc
Library                taf.selenium.sbts   WITH NAME   selenium_sbts
#Variables              ${CFGFILE_PATH}TLDelta.py
Library                testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC000829/Resources/ReadJason.py
Library                testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.gnb_alarm.AlarmWatchdog    WITH NAME    AlarmWatchdog
Library          ../../../../RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/check_loadbuild.py
Resource               ../../5GC000496_C/Resources/L3Call.robot
Resource               testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/None_Feature_SG1/OAM_Interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/UEs/Spark_common_keywords.robot


*** Variables ***
${WEBUI_URL}           https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}      ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}      ${tl.gnbs[0].cu.oam_http_connection_details.password}
${WEBUI_IP}            ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${LMP_Primary}         ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${LMP_Secondary}       ${tl.gnbs[0].dus[0].airscale.common_units[1].lmp_connection.addr}
${ASIK_IP_Mplane}      ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}

${ASIK_IP}             ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_username}	   ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${ASIK_password}	   ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}

${LMP_Primary_URL}     https://${LMP_Primary}
${LMP_Secondary_URL}   https://${LMP_Secondary}

#${link_to_Artifact}    https://esisoj70.emea.nsn-net.net/artifactory/mnp5g-central-public/System_Release/
#${link_to_Artifact_CB}      https://lterel.es-si-s3-z2.eecloud.nsn-net.net/build/
${link_to_Artifact_CB}      https://artifactory-hz1.int.net.nokia.com/artifactory/mn5gran_hzlog-local/
${surffix_common_build}    release_BTSSM_downloadable_A54.zip
${UPDATE_FILE_PATH}    /home/ute/Download_gNB_Package

${MRBTS_ID}            ${tl.gnbs[0].instance_id}
${NRBTS_ID}            ${tl.gnbs[0].global_bts_id}

${Dula_core_base_scf}                       ${LOG_PATH}/TestLineSCF2Cell_Both.xml
${Single_core_primary_base_scf}             ${CFGFILE_PATH}TestLineSCF1Cell_Both_left.xml
${Single_core_secondary_base_scf}           ${CFGFILE_PATH}TestLineSCF1Cell_Both_right.xml

#${CFGFILE_PATH}           /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/
#${CFGFILE_PATH}          /home/ute/ZWJ/gnb_configuration/Hangzhou/${testline_name}/
${ORIGINAL_SCF}     ${CFGFILE_PATH}TestLineSCF2Cell_Both.xml

${UE_TYPE}                ${tl.ues[0].capabilities[-1]}
${UTE_USERNAME}           ${tl.test_pcs[1].default_ssh_connection_details.username}
${UTE_PASSWORD}           ${tl.test_pcs[1].default_ssh_connection_details.password}
${RIGHT_UTE_IP}           ${tl.test_pcs[1].default_ssh_connection_details.addr}
${PB_ASIK_IP}             ${tl.gnbs[0].dus[0].airscale.common_units[1].pdu_port.pdu.addr}
${PB_ASIK_PORT}           ${tl.gnbs[0].dus[0].airscale.common_units[1].pdu_port.port_no}

${ALIAS_ASIK}             asik
${ALIAS_ASIK_SLAVE}       asik_slave
${ALIAS_LMP_PRIMARY}      lmp_primary
${ALIAS_LMP_SECONDARY}    lmp_secondary
${ALIAS_UTE}              ute

#${GoldenSCF_ON_GIT}         /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/5G_PZ_HZ_1_SG/
#${TLDelta_PATH_ON_GIT}        /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/



*** Keywords ***
TC.SecondaryCoreRecovery
    COAM_WebEM.Login    version=${sbts_stream}
    Basic.CheckVariableValid    var=CASE_INPUT_SCR['runtimes']      default_value=1    is_digit=true
    Basic.ExecFuncWithLoop    func=KW.SecondaryCoreRecovery    retry_times=${CASE_INPUT_SCR['runtimes']}
    [Teardown]
    Run Keyword And Ignore error    gNB.CollectSnapshot
    run keyword and ignore error    KW.UploadFileAndExecuteCaseOnRemoteUTE      caseTag=105
    run keyword and ignore error   COAM_WebEM.Logout
KW.SecondaryCoreRecovery
    Basic.CheckVariableValid    var=CASE_INPUT_SCR['HostName']      default_value=""
    ssh.Connect to    ${LMP_Primary}    ${ASIK_USERNAME}    ${ASIK_PASSWORD}    alias=tmpConn_P
    run keyword if    '${CASE_INPUT_SCR["HostName"]}'!=''    run keywords
    ...    ssh.Connect to    ${CASE_INPUT_SCR['HostName']}    ${ASIK_USERNAME}    ${ASIK_PASSWORD}    proxy=tmpConn_P    alias=tmpConn_S
    ...    AND     set suite variable    ${TargetAlias}    tmpConn_S
    ...    ELSE    set suite variable    ${TargetAlias}    tmpConn_P
    ssh.Send Command    command=ddal -s ddal_eth_switch_set_port_state 6 111 0; sleep 7s; ddal -s ddal_eth_switch_set_port_state 6 111 3;
    ...    connection=${TargetAlias}
    AlarmWatchdog.add_allow_alarms    fault_id=4352
    AlarmWatchdog.add_allow_alarms    fault_id=4367
    wait until keyword succeeds    10min    30s    KW.CheckAlarm4352    status=present
    wait until keyword succeeds    30min    30s    KW.CheckAlarm4352    status=disappear
    wait until keyword succeeds    20min    10s    COAM_Admin.CheckAllCellsOnair    type=both
    [Teardown]
    run keyword and ignore error   ssh.disconnect    connection=tmpConn_P
    run keyword and ignore error   ssh.disconnect    connection=tmpConn_S

KW.CheckAlarm4352
    [Arguments]       ${status}=present
    ${res}    Run Keyword And Return Status    KW.Check_Alarm_from_Active_Alarms     target_alarm_id=7116
    ...                                         target_fault_id=4352
    ...                                         target_alarm_name=No connection between primary and BTS extension system module
    ...                                         target_alarm_object=SMOD
    run keyword if   '${status}'=='present'
    ...    should be true    ${res}==${True}
    ...    ELSE    should be true    ${res}==${False}

TC.Secondary_Core_SW_Upgrade_from_FDSW
    KW.UnCommisionAirScale  IP=${WEBUI_IP}
    ${fdsw_alarm_result}=    KW.Check_FDSW_Alarms
    Run Keyword And Continue On Failure    Run keyword if    '${fdsw_alarm_result}'=='False'    Fail
        ...    Please check unexpect FDSW Alarm
    ${StreamTarget}      ${version_Target}      Basic.GetStreamAndVersion
    ${candidate_builds}    get_loadbuild_candidates    max_num=500   stream=${StreamTarget}
    ...       status=[released ,released_with_restrictions]
    ${sw_version_filtered}    filter_target_loadbuild_from_candidates
    ...           original_build=${version_Target}    candidates=${candidate_builds}
    Run Keyword If      '${sw_version_filtered}' == 'None'       Run Keywords
    ...           Log To Console      no condition matched build is found
    ...           AND    FAIL
    Log to Console      Latest match condition build: ${sw_version_filtered}
    ${upgrade_package_path}    SoftwareUpdate.DownloadPackageFromWFT       build_version=${sw_version_filtered}
    #${latest_version}    get_latest_version_form_wft
    #${version}    KW.GetCorrectPackageName    build_version=${latest_version}
    #${upgrade_package_path}    SoftwareUpdate.DownloadPackageFromWFT       build_version=${version}
    #set test variable    ${upgrade_package_path}
    KW.Software_update_from_FDSW    sw_pkg_path=${upgrade_package_path}
    AlarmWatchdog.add_allow_alarms    fault_id=4681
    AlarmWatchdog.add_allow_alarms    fault_id=23
    AlarmWatchdog.add_allow_alarms    fault_id=10
    AlarmWatchdog.add_allow_alarms    fault_id=6328
    sleep    600s
    KW.CommissionFromFDSWToDualCore
    sleep    600s
    wait until keyword succeeds    10min    30s    COAM_WebEM.Login
    ${alarm_info}    selenium_coam.get_active_alarm_info  alarm_filter=23
    should not be empty    ${alarm_info}
    should contain    ${alarm_info[0]["Configuration alarming object"]}    SMOD
    COAM_WebEM.Logout
    KW.Download_And_Update_Package_Of_Site      upgrade_package_path=${upgrade_package_path}
    sleep    300s

    wait until keyword succeeds    10min    30s    COAM_WebEM.Login
    ${alarm_info}    selenium_coam.get_active_alarm_info  alarm_filter=23
    COAM_WebEM.Logout
    log to console    ${alarm_info}
    ${count}=    Get Length    ${alarm_info}
    Run Keyword If    ${count}!=${0}    run keywords    KW.Download_And_Update_Package_Of_Site
    ...   upgrade_package_path=${upgrade_package_path}   AND    sleep  5min

    wait until keyword succeeds    30min    30s    COAM_WebEM.Login
    Wait Until Keyword Succeeds    30min    1min    COAM_Admin.CheckAllCellsOnair     type=both

    selenium_coam.reset_site
    wait until keyword succeeds   20min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    COAM_WebEM.Logout
    @{case_whitelist}    Create list        4590
    ${alarm_result}=    KW.GetAndCheckAlarm      add_whitelist=${case_whitelist}
    Run Keyword And Continue On Failure    Run keyword if    '${alarm_result}'=='False'    Fail
        ...    Please check unexpect Alarm
    AlarmWatchdog.remove_allow_alarms    fault_id=4681
    AlarmWatchdog.remove_allow_alarms    fault_id=23
    AlarmWatchdog.remove_allow_alarms    fault_id=10
    AlarmWatchdog.remove_allow_alarms    fault_id=6328

TC.Secondary_Core_SW_Upgrade_via_WebEM
    #${model}    set variable    ${tl.gnbs[0].dus[0].airscale.common_units[1].pdu_port.pdu.vendor}
    #${PB_ASIK_IP}    set variable    ${tl.gnbs[0].dus[0].airscale.common_units[1].pdu_port.pdu.addr}
    #${PB_ASIK_PORT}    set variable    ${tl.gnbs[0].dus[0].airscale.common_units[1].pdu_port.port_no}

    #set parameter for UTE CLOUD TL
    run keyword and ignore error   set suite variable    ${model}    ${tl.gnbs[1].dus[0].airscale.common_units[0].pdu_port.pdu.vendor}
    run keyword and ignore error   set suite variable    ${PB_ASIK_IP}   ${tl.gnbs[1].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
    run keyword and ignore error   set suite variable    ${PB_ASIK_PORT}   ${tl.gnbs[1].dus[0].airscale.common_units[0].pdu_port.port_no}

    run keyword and ignore error   set suite variable    ${model}    ${tl.gnbs[0].dus[0].airscale.common_units[1].pdu_port.pdu.vendor}

    Power.OnOff         pdu_ip=${PB_ASIK_IP}    Port_Number=${PB_ASIK_PORT}
                 ...   Action=power_off   model=${model}
    sleep    3min
    COAM_WebEM.Login
    ${alarm_info}    selenium_coam.get_active_alarm_info  alarm_filter=4352
    should not be empty    ${alarm_info}
    COAM_WebEM.Logout

    ${latest_version}    get_latest_version_form_wft
    ${version}    KW.GetCorrectPackageName    build_version=${latest_version}
    ${upgrade_package_path}    SoftwareUpdate.DownloadPackageFromWFT       build_version=${version}
    set test variable    ${upgrade_package_path}
    KW.Download_And_Update_Package_Of_Site      upgrade_package_path=${upgrade_package_path}
    sleep  10min
    ${Result}    Run Keyword And Ignore error     BtsLog.StopBTSlogCollectionandGetlog
    ${SyslogResult}      set variable           ${Result}[1][0]
    Run Keyword If  '${SyslogResult}' == 'FAIL'   Run Keyword And Ignore error    gNB.CollectSnapshot

    Run Keyword And Ignore error    BtsLog.StartBTSlogCollection
    Power.OnOff         pdu_ip=${PB_ASIK_IP}    Port_Number=${PB_ASIK_PORT}
                ...    Action=power_on   model=${model}
    sleep     3min

    COAM_WebEM.Login
    ${alarm_info}    selenium_coam.get_active_alarm_info  alarm_filter=23
    should not be empty    ${alarm_info}
    should contain    ${alarm_info[0]["Configuration alarming object"]}    SMOD
    COAM_WebEM.Logout

    KW.Download_And_Update_Package_Of_Site      upgrade_package_path=${upgrade_package_path}
    sleep  15min

    COAM_WebEM.Login
    ${alarm_info}    selenium_coam.get_active_alarm_info  alarm_filter=23
    ${res1}    run keyword and return status    should not be empty    ${alarm_info}
    ${res2}    run keyword and return status    should contain    ${alarm_info[0]["Configuration alarming object"]}    RMOD
    COAM_WebEM.Logout

    Run Keyword If    '${res1}'=='True' and '${res1}'=='True'    run keywords
    ...   KW.Download_And_Update_Package_Of_Site      upgrade_package_path=${upgrade_package_path}
    ...   AND    sleep  10min

    COAM_WebEM.Login
    Wait Until Keyword Succeeds    30min    1min    COAM_Admin.CheckAllCellsOnair     type=both
    COAM_WebEM.Logout
    @{case_whitelist}    Create list        4590
    ${alarm_result}=    KW.GetAndCheckAlarm      add_whitelist=${case_whitelist}
    Run Keyword And Continue On Failure    Run keyword if    '${alarm_result}'=='False'    Fail
        ...    Please check unexpect Alarm


TC.Sync_UI_in_dual-core_gNB
    [Documentation]   Aim to test "Diagnostic">"Synchronization">"Status" info is right on WEBUI
    ...    Precondition: gNB is onair with dualcore SCF
    ...    Test Steps:
    ...       Step1: Login WebEM,go to "Diagnostic">"Synchronization">"Status"
    ...             ->Exp Result: show Synchronization status for Primary core and Secondary core separately
    ...       Step2: Check Primary UI fields:"Synchronization source","Status"
    ...             ->Exp Result: Synchronization source=1pps/ToD from external GNSS receiver,Status=Available, usable
    ...       Step3: Check Secondary UI fields:"Synchronization source","Status"
    ...             ->Exp Result: Synchronization source=1pps/ToD from backplane, Status=Available, usable
    ...    Configuration Paramsters:
    ...       TL configuration: N/A
    ...       TC configuration: N/A
    ...       Checkpoint configuration: N/A
    COAM_WebEM.Login    version=${sbts_stream}
    ${UI_fields_Primary}     selenium_coam.get_synchronization_sources    is_dual_core=${TRUE}  core_index=1
    ${UI_fields_Secondary}    selenium_coam.get_synchronization_sources    is_dual_core=${TRUE}  core_index=2
    should be true    '${UI_fields_Primary[0]["Synchronization source"]}'=='1pps/ToD from external GNSS receiver'
    should be true    '${UI_fields_Primary[0]["Status"]}'=='Available, usable'

    should be true    '${UI_fields_Secondary[0]["Synchronization source"]}'=='1pps/ToD from backplane'
    should be true    '${UI_fields_Secondary[0]["Status"]}'=='Available, usable'
    COAM_WebEM.Logout

TC.HWInventoryRetrievalInDualCore
    [Documentation]  Aim to verify HW and Cell section fields on "BTS Status"->"BTS Start-up View".
    ...    Precondition: init.py info shall be right/gNB is onair with dualcore
    ...    Test Steps:
    ...         Step1: Login WEBEM, get current 'startup view' info and cell number
    ...         Step2: Get numbers of smod and rmods and cells from BTSTopo and init.py
    ...         Step3: Compare with Step1 and Step2 result, shall be equal
    ...    Configuration Paramsters:
    ...       TL configuration: N/A
    ...       TC configuration: N/A
    ...       Checkpoint configuration: N/A
    COAM_WebEM.Login    version=${sbts_stream}
    ${startup_view_info}    selenium_coam.get_bts_start_up_view_info
    ${number_of_cells}    selenium_coam.get_number_of_cells

    ${num _of_smods}    get length    ${tl.gnbs[0].dus[0].airscale.common_units}
    set test variable  ${num_of_bbmods}  0

    FOR  ${i}    IN RANGE    ${num _of_smods}
        ${numOfBBModsTmp}  get length  ${tl.gnbs[0].dus[0].airscale.common_units[${i}].capacity_units}
        ${num_of_bbmods}    evaluate    ${num_of_bbmods} + ${numOfBBModsTmp}
    END

    ${numOfConfiguredBasebandModules}  evaluate  ${num_of_bbmods}+${num _of_smods}

    Should Be Equal As Numbers    ${startup_view_info["Cells"]["Cells in configuration"]}    ${number_of_cells}
    Should Be Equal As Numbers    ${startup_view_info["Hardware"]["Configured baseband modules"]}
    ...                           ${numOfConfiguredBasebandModules}


TC.ResetMoudlesOfDualCore
    ${bbModNum_Reset}   get length  ${CASE_INPUT_5GC000829["829_A_009"]["BBMODs_Reset"]}
    ${ruNum_Reset}  get length  ${CASE_INPUT_5GC000829["829_A_009"]["RMODs_Reset"]}
    ${ruNum_LockAndUnlock}  get length  ${CASE_INPUT_5GC000829["829_A_009"]["RMODs_LockAndUnlock"]}
    ${cellNum_LockAndUnlock}  get length  ${CASE_INPUT_5GC000829["829_A_009"]["CELLs_LockAndUnlock"]}

    COAM_WebEM.Login    version=${sbts_stream}
    KW.ResetBBMOD  bbModNum=${bbModNum_Reset}
    sleep    1min
    Wait Until Keyword Succeeds  20min  2min
    ...    KW.CheckResetBBModStatus  bbModNum=${bbModNum_Reset}  Operational_State=Enabled
    Wait Until Keyword Succeeds  20min  2min
    ...    KW.CheckRuStatusOfResetBBMod  bbModNum=${bbModNum_Reset}  Operational_State=Enabled
    Wait Until Keyword Succeeds  20min  2min
    ...    KW.checkCellStatusOfResetBBMod  bbModNum=${bbModNum_Reset}  Operational_State=Enabled
#    COAM_WebEM.Logout
    ${alarm_result}=    KW.GetAndCheckAlarm
    Run Keyword And Continue On Failure    Run keyword if    '${alarm_result}'=='False'    Fail
        ...    Please check unexpect Alarm

    COAM_WebEM.Login    version=${sbts_stream}
    KW.ResetRu  ruNum=${ruNum_Reset}
    sleep    1min
    Wait Until Keyword Succeeds  60min  2min
    ...    KW.CheckRuStatus  ruNum=${ruNum_Reset}  Operational_State=Enabled  operate=reset
    Wait Until Keyword Succeeds  20min  2min
    ...    KW.CheckCellStatus  ruNum=${ruNum_Reset}  Operational_State=Enabled
    ...    operate=reset
#    COAM_WebEM.Logout
    ${alarm_result}=    KW.GetAndCheckAlarm
    Run Keyword And Continue On Failure    Run keyword if    '${alarm_result}'=='False'    Fail
        ...    Please check unexpect Alarm

    COAM_WebEM.Login    version=${sbts_stream}
    KW.LockRu  ruNum=${ruNum_LockAndUnlock}
    sleep    1min
    Wait Until Keyword Succeeds  20min  1min
    ...     KW.CheckRuStatus  ruNum=${ruNum_LockAndUnlock}  Operational_State=Enabled  operate=lock
    Wait Until Keyword Succeeds  20min  1min
    ...     KW.CheckCellStatus  ruNum=${ruNum_LockAndUnlock}  Operational_State=Disabled
    ...     operate=lock

    KW.unLockRu  ruNum=${ruNum_LockAndUnlock}
    sleep    1min
    Wait Until Keyword Succeeds  20min  1min
    ...     KW.CheckRuStatus  ruNum=${ruNum_LockAndUnlock}  Operational_State=Enabled  operate=lock
    Wait Until Keyword Succeeds  20min  1min
    ...     KW.CheckCellStatus  ruNum=${ruNum_LockAndUnlock}  Operational_State=Enabled
    ...     operate=lock

    KW.LockCell  cellNum=${cellNum_LockAndUnlock}
    sleep    1min
    Wait Until Keyword Succeeds  20min  1min
    ...     KW.CheckLockUnlockCellStatus  cellNum=${cellNum_LockAndUnlock}  Operational_State=Disabled

    KW.unLockCell  cellNum=${ruNum_LockAndUnlock}
    sleep    1min
    Wait Until Keyword Succeeds  20min  1min
    ...     KW.CheckLockUnlockCellStatus  cellNum=${cellNum_LockAndUnlock}  Operational_State=Enabled
    ${alarm_result}=    KW.GetAndCheckAlarm
    Run Keyword And Continue On Failure    Run keyword if    '${alarm_result}'=='False'    Fail
        ...    Please check unexpect Alarm
#    COAM_WebEM.Logout
    AlarmWatchdog.add_allow_alarms    fault_id=4592
    COAM_WebEM.Login    version=${sbts_stream}
    selenium_coam.reset_site
    sleep    120s
    wait until keyword succeeds   20min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    Run Keyword And Ignore Error     COAM_WebEM.Logout

#    Selenium_Login_And_Disable_Screen_Lock
    COAM_WebEM.Login    version=${sbts_stream}
    selenium_sbts.reset_nr
    sleep    120s
#    Selenium_Logout_And_Close_Browser
    wait until keyword succeeds   20min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    Run Keyword And Ignore Error     COAM_WebEM.Logout

#    Selenium_Login_And_Disable_Screen_Lock
    COAM_WebEM.Login    version=${sbts_stream}
    selenium_sbts.power_reset    timeout=${180}
    sleep    150s
#    Selenium_Logout_And_Close_Browser
    wait until keyword succeeds   20min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    Run Keyword And Ignore Error     COAM_WebEM.Logout
    sleep    120s
    AlarmWatchdog.remove_allow_alarms    fault_id=4592

#    Selenium_Login_And_Disable_Screen_Lock
    AlarmWatchdog.add_allow_alarms    fault_id=16
    COAM_WebEM.Login    version=${sbts_stream}
    ${UnitsList}    selenium_sbts.get_units_to_be_reset
    ${length}       Get length     ${UnitsList}
    FOR    ${i}    IN RANGE    ${length}
        selenium_sbts.baseband_power_reset    baseband_unit=${UnitsList[${i}]}
        sleep    30s
    END
    sleep    120s
#    Selenium_Logout_And_Close_Browser
    wait until keyword succeeds   20min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    Run Keyword And Ignore Error     COAM_WebEM.Logout
    AlarmWatchdog.remove_allow_alarms    fault_id=16

TC.OnlineModifyTypeNIDDInDualCore
    [Documentation]  Aim to verify CM procedures for online modify-type NIDD parameter(s)
    ...              in dual-core gNB are handled in the same way as single-core gNB.
    ...    Precondition: install tshark in UTE
    ...    Test Steps:
    ...         Step1: Modify parameter 'Cell Barred' from not barred to barred
    ...         Step2: Capture CPIF log and check cell shall be barred
    ...         Step3: Modify parameter 'Cell Barred' from barred to not barred
    ...         Step4: Captuer CPIF log and check cell shall be notbarred
    ...    Configuration Paramsters:
    ...       TL configuration: N/A
    ...       TC configuration: N/A
    ...       Checkpoint configuration: {CASE_INPUT_5GC000829["829_A_010"]["nrcell"]}
    gNB.Connect
    Wireshark.StartCaptureLogFromContainer    filename=cpiflog_barred.pcap
    ...                                       nodename=CPIF

    COAM_WebEM.Login    version=${sbts_stream}
    COAM_WebEM.ModifyAndActiveParameters
    ...                DistName=${MRBTS_ID}/${NRBTS_ID}/NRCELL-${CASE_INPUT_5GC000829["829_A_010"]["nrcell"]}
    ...                FilterParam=Cell Barred
    ...                NewValue=barred

    sleep   30s
    Wireshark.StopCapturinglogFromContainer    nodename=CPIF

    ${conn}    gNB.GetSystemModuleType    alias=${ALIAS_ASIK}

    Wireshark.DownloadLogToUTE                 log_dir=/tmp/node_CPIF00/tmp    filename=cpiflog_barred.pcap
    ...                                        connection=${conn}
    Wireshark.ReadLog                          filename=cpiflog_barred.pcap    filepath=${LOG_PATH}    filter=f1ap
    Wireshark.CheckExpression                  expression=nr-rrc.cellBarred == 0

    Wireshark.StartCaptureLogFromContainer     filename=cpiflog_notBarred.pcap
    ...                                        nodename=CPIF

    COAM_WebEM.ModifyAndActiveParameters       DistName=${MRBTS_ID}/${NRBTS_ID}/NRCELL-${CASE_INPUT_5GC000829["829_A_010"]["nrcell"]}
    ...                                        FilterParam=Cell Barred
    ...                                        NewValue=notBarred

    sleep   30s
    Wireshark.StopCapturinglogFromContainer    nodename=CPIF
    Wireshark.DownloadLogToUTE                 log_dir=/tmp/node_CPIF00/tmp    filename=cpiflog_notBarred.pcap
    ...                                        connection=${conn}
    Wireshark.ReadLog                          filename=cpiflog_notBarred.pcap    filepath=${LOG_PATH}    filter=f1ap
    Wireshark.CheckExpression                  expression=nr-rrc.cellBarred == 1

    COAM_WebEM.Logout
    gNB.Disconnect

TC.PMWithoutCallInDualCore
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    COAM_WebEM.Login    version=${sbts_stream}
    ${cellNum}    selenium_coam.get_number_of_cells
    FOR  ${i}  IN RANGE  ${cellNum}
        ${i}    evaluate    ${i}+1
        ${index}  convert to string  ${i}
        ${info}     selenium_coam.get_bts_counters_info    counter_id=M55601C00002    dist_name=CELLS/NRCELL-${index}/NR Cell Availability
        ${values}  Get Dictionary Values  ${info}
        should be true  ${values[-1]} > 0
    END
    COAM_WebEM.Logout

TC.FMForSmodInDualCore
    [Documentation]  Aim to test trigeer fault on SMOD, fault numbers and contents are rigth on dualcore gNB.
    ...    Test Steps:
    ...         Step1: Set actServiceAccountSsh=true, actServicePortState=true
    ...         Step2: Check FID=61524 and FID=61652 is active
    ...         Step3: Set actServiceAccountSsh=false, actServicePortState=false
    ...         Step4: Check FID=61524 and FID=61652 is clear
    ...         Step5: Check connet to gNB with ssh will be failed
    ...         Step6: Set actServiceAccountSsh=true, actServicePortState=true
    ...         Step7: Check FID=61524 and FID=61652 is active
    ...         Step8: Check connet to gNB with ssh will be succeed
   	...    Configuration Parameters:
	...        TL configuration: N/A
	...        TC configuration: N/A
	...        Checkpoint configuration: N/A
    COAM_WebEM.Login    version=${sbts_stream}
    ${value_of_actServiceAccountSsh}    selenium_coam.get_parameter_value    dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                                                                      filter_param=Activate service account SSH
    ${value_of_actServicePortState}     selenium_coam.get_parameter_value    dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                                                                      filter_param=Activate service port state

    run keyword if    '${value_of_actServiceAccountSsh}'=='false'
    ...                selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                                                     filter_param=Activate service account SSH
    ...                                                     new_value=true

    run keyword if    '${value_of_actServicePortState}'=='false'
    ...                selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                                                     filter_param=Activate service port state
    ...                                                     new_value=true

    ${result}    evaluate  '${value_of_actServicePortState}'=='false' or '${value_of_actServiceAccountSsh}'=='false'
    log to console    Step1: Set actServiceAccountSsh=true, actServicePortState=true
    run keyword if    ${result}
    ...               COAM_WebEM.ValidateAndActiveParameters
    log to console    Step2: Check FID=61524 and FID=61652 is active
    KW.CheckAlaram_For_Case016    alarm=active

    selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                                  filter_param=Activate service account SSH    new_value=false
    selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                                  filter_param=Activate service port state    new_value=false
    log to console    Step3: Set actServiceAccountSsh=false, actServicePortState=false
    COAM_WebEM.ValidateAndActiveParameters
    log to console    Step4: Check FID=61524 and FID=61652 is clear
    KW.CheckAlaram_For_Case016    alarm=deactive
    log to console    Step5: Check connet to gNB with ssh will be failed
    ${res_ssh}  Run Keyword And Return Status    ssh.Connect to
    ...                                    ${LMP_Primary}    ${ASIK_USERNAME}    ${ASIK_PASSWORD}    alias=${ALIAS_ASIK}
    should be true    ${res_ssh}==${False}
    selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                                  filter_param=Activate service account SSH    new_value=true
    selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                                  filter_param=Activate service port state    new_value=true
    sleep    3s
    log to console    Step6: Set actServiceAccountSsh=true, actServicePortState=true
    COAM_WebEM.ValidateAndActiveParameters
    log to console    Step7: Check FID=61524 and FID=61652 is active
    KW.CheckAlaram_For_Case016     alarm=active
    log to console    Step8: Check connet to gNB with ssh will be succeed
    ssh.Connect to    ${LMP_Primary}    ${ASIK_USERNAME}    ${ASIK_PASSWORD}    alias=${ALIAS_ASIK}

    ssh.disconnect    connection=${ALIAS_ASIK}
    COAM_WebEM.Logout

TC.5GC000829_A_018_Troubleshooting_Snapshot_in_dual-core_gNB
#    [Arguments]    ${MRBTSID}=${MRBTS_ID}
    wait until keyword succeeds    30x    1min    gNB.VerifyOnAirViaOAMUntilReady
    ${snapshot_file}    gNB.CollectSnapshot
    Run Keyword And Ignore Error    run    command=cd ${LOG_PATH}/. ; mkdir 829_A_018 ; cp ${snapshot_file} ${LOG_PATH}/829_A_018/.

    @{ru_serial_number_secondary}    create list
    ${bbmod_num}    get length    ${tl.gnbs[1].dus[0].airscale.common_units[0].capacity_units}

    FOR  ${i}    IN RANGE    ${bbmod_num}
        @{result}  KW.getRUSerialNumber    bbmod=${tl.gnbs[1].dus[0].airscale.common_units[0].capacity_units[${i}]}
        @{ru_serial_number_secondary}    create list    @{ru_serial_number_secondary}    @{result}
    END

    ${secondary_ru_num}   get length  ${ru_serial_number_secondary}
    FOR  ${i}  IN RANGE  ${secondary_ru_num}
        KW.Check_Snapshot_Log    check_value=${ru_serial_number_secondary[${i}]}_RMOD
    END

TC.5GC000829_A_019_Troubleshooting_BTSLog_in_dual-core_gNB
    wait until keyword succeeds    30x    1min    gNB.VerifyOnAirViaOAMUntilReady
    BtsLog.StartBTSlogCollection
    sleep    15s
    Run Keyword And Ignore Error    BtsLog.StopBTSlogCollectionandGetlog
    KW.Check_BTSlog    value_1011=FCT-1011   value_2011=FCT-2011

TC.RestartReuiredTypeNIDDUpdateInDualCore
    [Documentation]  step1: check actSACallProcessingDU value, it's filter name is
    ...                     "Activate state transition and call processing (Option 2) for DU"
    ...              step2: if "true"  online change to "false", while change to "true"
    ...              step3: active
    ...              step4: check whether gNB restart for both primary core and secondary core
    ...              step5: check whether actSACallProcessingDU is setted to be new value
    ...              step6: check whether cell on air
    COAM_WebEM.Login    version=${sbts_stream}
    ${actSACallProcessingDU_filter}   set variable   Activate state transition and call processing (Option 2) for DU
    Set test variable     ${actSACallProcessingDU_filter}
    ${value_of_SA_call_1}    selenium_coam.get_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}
    ...            filter_param=${actSACallProcessingDU_filter}
    Set test variable     ${value_of_SA_call_1}
    ${new_flag}    set variable if    '${value_of_SA_call_1}'=='true'   false    true
    COAM_WebEM.ModifyAndActiveParameters     DistName=${MRBTS_ID}/${NRBTS_ID}
    ...     FilterParam=${actSACallProcessingDU_filter}      NewValue=${new_flag}
    Run Keyword and Ignore Error     COAM_WebEM.Logout
    Run Keyword And Ignore Error    run    command=killall firefox

    sleep    20s
    gNB.CheckgNBReset
    KW.CheckSecondaryCoreReset
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    COAM_WebEM.Login    version=${sbts_stream}
    ${value_of_SA_call_2}    selenium_coam.get_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}
    ...                                                         filter_param=${actSACallProcessingDU_filter}
    COAM_WebEM.Logout
    Should Be Equal   ${value_of_SA_call_2}   ${new_flag}


TC.5GC000829_A_017_FM_for_otherMOD_in_dual-core_gNB
    [Documentation]        test secondary core
    ...    step1: login core FHNET_Container
    ...    step2: Set rlan Interface Down
    ...    step3: check fault 10 via webui
    ...    step4: check cell status
    ...    step5: Set rlan Interface Up
    ...    step6: fault 10 dissapper via webui
    ...    step7: check cell status

    run keyword if    '${IS_COmmon_Build}'=='true'
    ...    set test variable   ${object1}    APEQM-1
    ...    ELSE
    ...    set test variable   ${object1}    APEQM_R-1
    Run Keyword And Continue On Failure     KW.Get_FHNET_Container_ID    hostname=${LMP_Primary}    alias=${ALIAS_LMP_PRIMARY}
    Run Keyword And Continue On Failure    KW.Set_rlan_Interface_Down_Or_Up    cmd_A17=ip link set rlan0.cpri down
    ...    hostname=${LMP_Primary}    alias=${ALIAS_LMP_PRIMARY}
    sleep    3min
    Run Keyword And Continue On Failure    COAM_WebEM.Login    version=${sbts_stream}
    Run Keyword And Continue On Failure    KW.Check_Alarm_from_Active_Alarms    target_fault_id=10    target_alarm_id=7116
    ...    target_alarm_name=No connection to unit
    ...    target_alarm_object=${object1}/RMOD
    ${cell_res}    run keyword and return status    COAM_Admin.CheckAllCellsOnair    type=both
    Run Keyword And Continue On Failure    should be true    '${cell_res}'=='False'
    Run Keyword And Continue On Failure    KW.Set_rlan_Interface_Down_Or_Up    cmd_A17=ip link set rlan0.cpri up
    ...    hostname=${LMP_Primary}    alias=${ALIAS_LMP_PRIMARY}
    sleep     3min
    ${alarm_res}=   run keyword and return status        KW.Check_Alarm_from_Active_Alarms    target_fault_id=10
    ...    target_alarm_id=7116    target_alarm_name=No connection to unit
    ...    target_alarm_object=${object1}/RMOD
    Run Keyword And Continue On Failure    should be true    '${alarm_res}'=='False'
    Run Keyword And Continue On Failure    COAM_Admin.CheckAllCellsOnair    type=both
    Run Keyword And Ignore error    COAM_WebEM.Logout


TC.ConnectionsToDualCoregNB
    [Documentation]   Aim to verify different kinds of connection to dual-core gNB.
    ...    Precondition: gNB is onair with dualcore SCF
    ...    Test Steps:
    ...         Step1: Login WebEM via MPlane, check all cells status
    ...         Step2: Login SSH via MPlane and Primary LMP ip
    ...         Step3: SSH login between two SystemBands
    ...         Step4: Login SSH via Seconady LMP ip
    ...    Configuration Parameters:
	...        TL configuration: N/A
	...        TC configuration: N/A
	...        Checkpoint configuration: N/A
    KW.ConnectDualCoreByWebEM
    KW.ConnectDualCoreBySSH
    KW.SSHBetweenTwoSystemBands
    KW.UploadFileAndExecuteCaseOnRemoteUTE    caseTag=TC004

TC.SiteResetInDualCore
    [Documentation]   Aim to verify site reset and BTS lock/unlock scenarios via webEM for dual-core gNB are handled
    ...               in the same way as single-core gNB.
    ...    Precondition: gNB is onair with dualcore
    ...    Test Steps:
    ...         Step1: Reset site via WEBEM
    ...         ->Whole site shall reset, gNB shall return to onair after starting up
    ...         Step2: Lock/unlock site via WEBEM
    ...         ->BTS operational/availability status shall be same as single-core gNB
    ...    Configuration Parameters:
	...        TL configuration: N/A
	...        TC configuration: N/A
	...        Checkpoint configuration: N/A
    KW.ResetSite
    #for CB008797 introduce in SBTS22R3, the value '5gClassicalBTS' of parameter 'productVariantPlanned' won't exist
    #future and replaced by 'sBTS'. After SBTS22R3, there is no 'Lock BTS'. Adapt to the change.
    COAM_WebEM.Login    version=${sbts_stream}
    ${value_of_productVariantPlanned}    selenium_coam.get_parameter_value    dist_name=${MRBTS_ID}/MNL-1
    ...                                                                      filter_param=Product variant planned
    COAM_Admin.Login
    ${version_active}     coam.get_sw_version    connection=COAM
    ${stream_active}   ${subversion_active}    Split String   string=${version_active}   separator=_     max_split=1
    run keyword if   '${stream_active}'>='SBTS22R3' or '${value_of_productVariantPlanned}'=='sBTS'   KW.BlockUnblockSite
    ...     ELSE    KW.LockUnlockBTS
    run keyword and ignore error    COAM_Admin.Logout
    run keyword and ignore error    COAM_WebEM.Logout


TC.RecommissionFromDualCoreToSingleCore
    KW.PreparegNBTODualCore
    KW.CommissionFromDualCoreToSingleCore

TC.ModuleDetectInUncommissionState
    [Documentation]  step1: Login to WebUI
    ...              step2: un-commission gNB
    ...              step3: Login to WebUI via LMP
    ...              step4: select dual-core mode
    ...              step5: check HW status, all HWs can be shown in WebEM
    KW.PreparegNBTODualCore
    COAM_WebEM.Login    version=${sbts_stream}
    selenium_coam.configuration_reset

    sleep    30s
    Run Keyword And Ignore Error    run    command=killall firefox

    KW.CommissionOnPrimaryCore    scfPath=${Dula_core_base_scf}    gNBCoreMode=dual

    ${ASIK_num_From_Init}   KW.GetHWNumFromInit      HW_Type=ASIK
    ${ABIL_num_From_Init}   KW.GetHWNumFromInit      HW_Type=ABIL

    COAM_WebEM.Login    version=${sbts_stream}
    ${ASIK_num_From_WebInfo}    run keyword if    '${IS_COmmon_Build}'=='true'
    ...    KW.GetHWNumFromWebInfo      HW_type=ASIK

    ${ABIL_num_From_WebInfo}    run keyword if    '${IS_COmmon_Build}'=='true'
    ...    KW.GetHWNumFromWebInfo      HW_type=ABIL

    run keyword if    '${IS_COmmon_Build}'=='true'    run keywords
    ...    Should be equal   ${ASIK_num_From_Init}   ${ASIK_num_From_WebInfo}
    ...    AND    Should be equal   ${ABIL_num_From_Init}   ${ABIL_num_From_WebInfo}

    COAM_WebEM.Logout

#    run keyword if    '${IS_COmmon_Build}'=='true'    run keywords
#    ...   Run Keyword and Ignore Error    COAM_WebEM.Login    version=${sbts_stream}
#    ...   ${ASIK_num_From_Init}   KW.GetHWNumFromInit      HW_Type=ASIK
#    ...   ${ABIL_num_From_Init}   KW.GetHWNumFromInit      HW_Type=ABIL
#    ...
#    ...   ${ASIK_num_From_WebInfo}    KW.GetHWNumFromWebInfo    HW_type=ASIK
#    ...   ${ABIL_num_From_WebInfo}    KW.GetHWNumFromWebInfo    HW_type=ABIL
#    ...
#    ...   Should be equal   ${ASIK_num_From_Init}   ${ASIK_num_From_WebInfo}
#    ...   Should be equal   ${ABIL_num_From_Init}   ${ABIL_num_From_WebInfo}
#    ...   Run Keyword And Ignore Error    COAM_WebEM.Logout

TC.L3callOnPrimaryCore
    [Documentation]  Step1:  reconmission gNB as dual core which left ASIK is primary core
    ...              Step2:  select the cell in the primary core
    ...              Step3:  lock other cells
    ...              Step4:  trigger UE attach and traffic
    ...              Step5:  check UL/DL traffic excuted successfully
    ...              Step6:  release call
    Basic.CheckVariableValid   var=TLCommonConfig["MultiUECFG"]["0"]["detach_request"]    default_value=${true}
    Basic.CheckVariableValid   var=TLCommonConfig["MultiUECFG"]["0"]["power_reset"]        default_value=true
    set test variable    ${IMSI}    ${tl.ues[0].imsi}
    ${cell_num}    get length    ${CASE_INPUT_5GC000829["829_A_021"]["lock_unlock_cell_index"]}
    FOR  ${i}  IN RANGE  ${cell_num}
        KW.LockSpecifyCell     cell_idx=${CASE_INPUT_5GC000829["829_A_021"]["lock_unlock_cell_index"][${i}]}
    END
    #UE.One_UE_Call_with_traffic    ue_type=${UE_TYPE}    ue_index=${0}
    #...                            cell_idx=${CASE_INPUT_5GC000829["829_A_021"]["call_cell_index"]}
    #...    detach_request=${TLCommonConfig["MultiUECFG"]["0"]["detach_request"]}
    #...    power_reset=${TLCommonConfig["MultiUECFG"]["0"]["power_reset"]}
    #...    apn_address=${TLCommonConfig["MultiUECFG"]["0"]["apn"]}
    KW.Make L3call with multi PDU    ue_index=${0}    ue_type=${UE_TYPE}

TC.5GC000829_A_022_L3callOnSecondaryCore
    [Documentation]  Step1:  reconmission gNB as dual core which left ASIK is primary core
    ...              Step2:  select the cell in the secondary core
    ...              Step3:  lock other cells
    ...              Step4:  trigger UE attach and traffic
    ...              Step5:  check UL/DL traffic excuted successfully
    ...              Step6:  release call
    &{bts_info}   Create Dictionary    host=${WEBUI_IP}    username=${WEBUI_USERNAME}
    ...                                password=${WEBUI_PASSWORD}    port=443

    @{profile}    Create List    cp_5g

    #rd.connect_to    host=${CASE_INPUT_5GC000829["dcap_server_ip"]}
    #...              port=${CASE_INPUT_5GC000829["dcap_server_port"]}
    #...              secure=True
    #...              rd_version=dcapv3
    #DCAP.Delete_Bts_if_Exist
    #rd.create_bts    host=${WEBUI_IP}
    #rd.start_trace    bts=&{bts_info}    gnb_custom_profile=@{profile}
    #sleep    2min

    set test variable    ${IMSI}    ${tl.ues[1].imsi}
    ${cell_num}    get length    ${CASE_INPUT_5GC000829["829_A_022"]["lock_unlock_cell_index"]}
    FOR  ${i}  IN RANGE  ${cell_num}
        KW.LockSpecifyCell     cell_idx=${CASE_INPUT_5GC000829["829_A_022"]["lock_unlock_cell_index"][${i}]}
    END
    UE.One_UE_Call_with_traffic    ue_type=${UE_TYPE}    ue_index=${1}    cell_idx=2
    ...    detach_request=${TLCommonConfig["MultiUECFG"]["0"]["detach_request"]}
    ...    power_reset=${TLCommonConfig["MultiUECFG"]["0"]["power_reset"]}
    ...    apn_address=${TLCommonConfig["MultiUECFG"]["0"]["apn"]}

TC.WhenSecondaryCoreLostSyncFromPrimaryFault4385Raise
    [Documentation]  Aim to verify when secondary core lost synchronization signal from primary core,
    ...               fault4385:  EFaultId_PpsRefFromBackplaneMissingAl shall be raised by secondary core
    ...    Precondition: gNB is onair with dualcore
    ...    Test Steps:
    ...         Step1: Trige Fault 4385 by command
    ...         Step2: Check Fault 4385 from active alarms
    ...         Step3: Check primary cell status shall be online and secondary cell status shall be degraded
    ...         Step4: Recovery the backplane syn signal
    ...         Step5: Check Fault 4385 is cleared and secondary cell retrun to normal
    ...    Configuration Parameters:
	...        TL configuration: N/A
	...        TC configuration: N/A
	...        Checkpoint configuration: N/A
    gNB.Connect
    ${result}   Conn.Execute        cmd=ddal -s ddal_clk_io_configure_output_signal 1 DDAL_CLK_IO_SIGNAL_GND DDAL_CLK_IO_PORT_BP_PPS
    ...                             alias=${ALIAS_ASIK}
    gNB.Disconnect
    sleep                           3min
    KW.Check_Fault_from_Active_Alarms  target_fault_id=4385

    KW.CheckCellStatusOfPrimaryCore  Operational_State=Enabled
    KW.CheckCellStatusOfSecondaryCore  Operational_State=Enabled

    gNB.Connect
    ${result}   Conn.Execute        cmd=ddal -s ddal_clk_io_configure_output_signal 1 DDAL_CLK_IO_SIGNAL_PPS_INTERNAL DDAL_CLK_IO_PORT_BP_PPS
    ...                             alias=${ALIAS_ASIK}
    gNB.Disconnect
    sleep                           4min
    Run Keyword And Return Status  KW.Check_Fault_from_Active_Alarms
    ...                            target_fault_id=4385

    KW.CheckCellStatusOfSecondaryCore  Operational_State=Enabled

TC.5GC000829_A_036_Dual-core_Commission_Exception_when_Primary_core_in_single-core_Mode
    [Documentation]  Step1: prepare gNB to Two Single core
    ...              Step2: uncommison secondary core
    ...              Step3: Login to primary core from Mplane
    ...              Step4: Check HW visualization, can not see secondary HW
    ...              Step4: Try to commision scf file
    KW.PreparegNBTOSingleCore
    KW.UploadFileAndExecuteCaseOnRemoteUTE      caseTag=Unconmission

    ${ASIK_num_From_Init}   KW.GetHWNumFromInit      HW_Type=ASIK
    ${ABIL_num_From_Init}   KW.GetHWNumFromInit      HW_Type=ABIL

    ${ASIK_num_From_WebInfo}    KW.GetHWNumFromWebInfo    HW_type=ASIK
    ${ABIL_num_From_WebInfo}    KW.GetHWNumFromWebInfo    HW_type=ABIL

    Should Not Be Equal     ${ASIK_num_From_Init}   ${ASIK_num_From_WebInfo}
    Should Not Be Equal     ${ABIL_num_From_Init}   ${ABIL_num_From_WebInfo}

    ${status}   Run Keyword And Return Status   gNB.Commission      scf_file=${Dula_core_base_scf}      timeout=${2400}
    Should Be True   '${status}'=='False'

TC.5GC000829_C_001_Secondary_core_System_Module_reboot
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    ssh.Connect to    ${LMP_Primary}    ${ASIK_USERNAME}    ${ASIK_PASSWORD}    alias=tmpConn_P
    ${value}    ssh.Execute     hostname    connection=tmpConn_P
    ${hostname}=    Remove String    ${value}    \r\n
    ${status}    Run Keyword If    '${hostname}'=='fct-4a'    KW.RebootSecondaryCoreInLeft
    ...    ELSE IF    '${hostname}'=='fct-0a'    KW.RebootSecondaryCoreInRight
    should be equal    '${status}'    'False'
    AlarmWatchdog.add_allow_alarms    fault_id=4352
    AlarmWatchdog.add_allow_alarms    fault_id=4367
    AlarmWatchdog.add_allow_alarms    fault_id=6450
    AlarmWatchdog.add_allow_alarms    fault_id=4590

    sleep    10s
    #KW.CheckCellStatusOfPrimaryCore  Operational_State=Enabled

    wait until keyword succeeds    5x    5s    KW.Check_Fault_from_Active_Alarms
    ...                                target_fault_id=4352

    KW.CheckCellStatusOfPrimaryCore  Operational_State=Enabled
    KW.CheckCellStatusOfSecondaryCore  Operational_State=Disabled

    wait until keyword succeeds    5x    40s    KW.CheckCellStatusOfSecondaryCore
    ...                            Operational_State=Enabled

    ${status}    Run Keyword And Return Status    KW.Check_Fault_from_Active_Alarms
    ...                                target_fault_id=4352
    Should not be true    ${status}
    AlarmWatchdog.remove_allow_alarms    fault_id=4352
    AlarmWatchdog.remove_allow_alarms    fault_id=4590
    AlarmWatchdog.remove_allow_alarms    fault_id=4367

    ${alarm_result}=    KW.GetAndCheckAlarm      6450check=True
    Run Keyword And Continue On Failure    Run keyword if    '${alarm_result}'=='False'    Fail
        ...    Please check unexpect Alarm
        ...    ELSE    Run Keyword And Ignore error    gNB.CollectSnapshot
    AlarmWatchdog.remove_allow_alarms    fault_id=6450

TC.5GC000829_C_004_Secondary_core_Recovery_reset_after_inter-core_connection_restored
    KW.UploadFileAndExecuteCaseOnRemoteUTE      caseTag=C-004

TC.5GC000829_K_002_Remote_Migration_from_single-core_to_dual-core_gNB_left_as_primary
#    @{expected_faults} =	Create List   61652   61524   4352   4592
    AlarmWatchdog.add_allow_alarms       fault_id=4681
    AlarmWatchdog.add_allow_alarms       fault_id=1868
    AlarmWatchdog.add_allow_alarms       fault_id=4367
    KW.PrepareOneSingleCoregNB
    ${Result}    Run Keyword And Ignore error     BtsLog.StopBTSlogCollectionandGetlog
    ${SyslogResult}      set variable           ${Result}[1][0]
    Run Keyword If  '${SyslogResult}' == 'FAIL'   Run Keyword And Ignore error    gNB.CollectSnapshot

    Run Keyword And Ignore error    BtsLog.StartBTSlogCollection
    KW.MigrationFromSingleCoreToDualCore
    sleep    6min
#    ${unexpected_faults}    KW.CheckUnexpectedFaultsFromAllAlarms   #expected_faults = ${expected_faults}
#    should be empty  ${unexpected_faults}
    AlarmWatchdog.remove_allow_alarms    fault_id=4681
    COAM_WebEM.Login    version=${sbts_stream}
    Wait Until Keyword Succeeds    30min    1min    COAM_Admin.CheckAllCellsOnair     type=both
    AlarmWatchdog.remove_allow_alarms    fault_id=1868
    AlarmWatchdog.remove_allow_alarms    fault_id=4367
    ${alarm_result}=    KW.GetAndCheckAlarm
    Run Keyword And Continue On Failure    Run keyword if    '${alarm_result}'=='False'    Fail
        ...    Please check unexpect Alarm
#   wait until keyword succeeds    20min    10s    COAM_Admin.CheckAllCellsOnair     type=lte

TC.CB007310_A_104_SWM_Secondary_core_SW_fallback
   ##[Teardown]  KW.CaseTeardown
   ##[Timeout]   2h
   ##run   command= cp ${ORIGINAL_SCF} ${LOG_PATH}
   ##KW.PreparegNBTODualCore
   #${target_version}    KW.Get_gNB_Passive_SW_Version
   #KW.SW_Download_Upgrade_Delete   ${target_version}
   #sleep    10min
   #Wait Until Keyword Succeeds    30min    1min    COAM_Admin.CheckAllCellsOnair     type=both
   #${Result}    Run Keyword And Ignore error     BtsLog.StopBTSlogCollectionandGetlog
   #${SyslogResult}      set variable           ${Result}[1][0]
   #Run Keyword If  '${SyslogResult}' == 'FAIL'   Run Keyword And Ignore error    gNB.CollectSnapshot

   #Run Keyword And Ignore error    BtsLog.StartBTSlogCollection
   #rollback site
   #${Result}    Run Keyword And Ignore error     BtsLog.StopBTSlogCollectionandGetlog
   #${SyslogResult}      set variable           ${Result}[1][0]
   #Run Keyword If  '${SyslogResult}' == 'FAIL'   Run Keyword And Ignore error    gNB.CollectSnapshot

   Run Keyword And Ignore error    BtsLog.StartBTSlogCollection
   AlarmWatchdog.add_allow_alarms    fault_id=4352
   AlarmWatchdog.add_allow_alarms    fault_id=4367
   AlarmWatchdog.add_allow_alarms    fault_id=4753
   AlarmWatchdog.add_allow_alarms    fault_id=6328
   AlarmWatchdog.add_allow_alarms    fault_id=4082
   AlarmWatchdog.add_allow_alarms    fault_id=10

   ${res}    run keyword and ignore error    KW.UploadFileAndExecuteCaseOnRemoteUTE      caseTag=secondaryfallback
   Run Keyword If   '${res[0]}'=='FAIL'   Fail    secondary core fallback failed
   wait until keyword succeeds    6x  5min     KW.Check_Fault_from_Active_Alarms  target_fault_id=4082
   KW.check secondarycore after fallback

   ${target_version}    KW.Get_gNB_Active_SW_Version
   KW.SW_Download_Upgrade_Delete   ${target_version}
   sleep    10min
   wait until keyword succeeds    15min   1min    KW.CheckAlarm104Disapear4082
   Wait Until Keyword Succeeds    30min    1min    COAM_Admin.CheckAllCellsOnair     type=both
   AlarmWatchdog.remove_allow_alarms    fault_id=4352
   AlarmWatchdog.remove_allow_alarms    fault_id=4367
   AlarmWatchdog.remove_allow_alarms    fault_id=4753
   AlarmWatchdog.remove_allow_alarms    fault_id=6328
   AlarmWatchdog.remove_allow_alarms    fault_id=4082
   AlarmWatchdog.remove_allow_alarms    fault_id=10

   ${alarm_result}=    KW.GetAndCheckAlarm
   Run Keyword And Continue On Failure    Run keyword if    '${alarm_result}'=='False'    Fail
        ...    Please check unexpect Alarm

   ${res}    run keyword and ignore error    KW.UploadFileAndExecuteCaseOnRemoteUTE      caseTag=105
   Run Keyword If   '${res[0]}'!='FAIL'   set suite variable    ${CASE105_2}    PASS
   ...    ELSE    set suite variable    ${CASE105_2}    FAIL

TC.5GC000829_K_005_Remote_Migration_Exception_when_extension_module_already_commissioned
    run keyword if    '${IS_COmmon_Build}'=='true'    run keywords
    ...    set test variable   ${object1}    SMOD-1
    ...    AND    set test variable   ${object2}    SMOD-2
    ...    ELSE    run keywords
    ...    set test variable   ${object1}    SMOD_R-1
    ...    AND    set test variable   ${object2}    SMOD_R-2
#    @{expected_faults} =	Create List   61652   61524   4352   4592
    KW.PrepareBothCoretoSingleCore
    KW.MigrationFromSingleCoreToDualCore    file_path=${LOG_PATH}/829_K005_SCF.xml
    sleep    6min
#    ${unexpected_faults}    KW.CheckUnexpectedFaultsFromAllAlarms   #expected_faults = ${expected_faults}
#    should be empty  ${unexpected_faults}
    wait until keyword succeeds    5x    5s    KW.Check_Fault_from_Active_Alarms
    ...                                target_fault_id=4352
    KW.CheckCellStatusOfSecondaryCore  Operational_State=Disabled
    KW.CheckCellStatusOfPrimaryCore  Operational_State=Enabled

    KW.UploadFileAndExecuteCaseOnRemoteUTE      caseTag=Unconmission

    sleep  8min
    wait until keyword succeeds    10min    30s    COAM_WebEM.Login    version=${sbts_stream}
    ${res1}    Run Keyword And Return Status    KW.Check_Alarm_from_Active_Alarms     target_alarm_id=7111
    ...                                         target_fault_id=23
    ...                                         target_alarm_name=Incompatible SW version detected
    ...                                         target_alarm_object=${object2}
    should be true    ${res1}
    run keyword and ignore error    COAM_WebEM.Logout

    ${status}    Run Keyword And Return Status    KW.Check_Fault_from_Active_Alarms
    ...                                target_fault_id=4352
    Should not be true    ${status}

    ${target_version}    KW.Get_gNB_Active_SW_Version
    KW.SW_Download_Upgrade_Delete   ${target_version}
    sleep    10min

    COAM_WebEM.Login    version=${sbts_stream}
    Wait Until Keyword Succeeds    30min    1min    COAM_Admin.CheckAllCellsOnair     type=both
    #${alarm_result}=    KW.GetAndCheckAlarm
    #Run Keyword And Continue On Failure    Run keyword if    '${alarm_result}'=='False'    Fail
    #    ...    Please check unexpect Alarm
#   wait until keyword succeeds    20min    10s    COAM_Admin.CheckAllCellsOnair     type=lte

TC.CB007310_A_106_Secondary_core_Power_Reset
    #set parameter for UTE CLOUD TL
    run keyword and ignore error   set suite variable    ${model}    ${tl.gnbs[1].dus[0].airscale.common_units[0].pdu_port.pdu.vendor}
    run keyword and ignore error   set suite variable    ${PB_ASIK_IP}   ${tl.gnbs[1].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
    run keyword and ignore error   set suite variable    ${PB_ASIK_PORT}   ${tl.gnbs[1].dus[0].airscale.common_units[0].pdu_port.port_no}

    run keyword and ignore error   set suite variable    ${model}    ${tl.gnbs[0].dus[0].airscale.common_units[1].pdu_port.pdu.vendor}
    AlarmWatchdog.add_allow_alarms    fault_id=4352
    AlarmWatchdog.add_allow_alarms    fault_id=4367
    AlarmWatchdog.add_allow_alarms    fault_id=4590
    AlarmWatchdog.add_allow_alarms    fault_id=6450
    log to console      2nd core Poweroff started
    Power.OnOff         pdu_ip=${PB_ASIK_IP}    Port_Number=${PB_ASIK_PORT}
                 ...   Action=power_off   model=${model}
    log to console      2nd core Poweroff finished
    COAM_WebEM.Login    version=${sbts_stream}
    wait until keyword succeeds    2min    1s    KW.CheckAlarmFor_Case_A101

    log to console      2nd core Poweron started
    Power.OnOff         pdu_ip=${PB_ASIK_IP}    Port_Number=${PB_ASIK_PORT}
                ...    Action=power_on   model=${model}
    sleep     1min
    COAM_WebEM.Login    version=${sbts_stream}
    Wait Until Keyword Succeeds    30min    1min    COAM_Admin.CheckAllCellsOnair     type=both

    @{case_whitelist}    Create list     4352   4590
    ${alarm_result}=    KW.GetAndCheckAlarm      add_whitelist=${case_whitelist}    6450check=True
    Run Keyword And Continue On Failure    Run keyword if    '${alarm_result}'=='False'    Fail
        ...    Please check unexpect Alarm
        ...    ELSE    Run Keyword And Ignore error    gNB.CollectSnapshot
    AlarmWatchdog.remove_allow_alarms    fault_id=4352
    AlarmWatchdog.remove_allow_alarms    fault_id=4367
    AlarmWatchdog.remove_allow_alarms    fault_id=4590
    AlarmWatchdog.remove_allow_alarms    fault_id=6450

KW.CheckAlarm104Disapear4082
   ${res}    Run Keyword And Return Status    KW.Check_Fault_from_Active_Alarms   target_fault_id=4082
   Should not be true    ${res}

TC.CB007310_A_105
    run keyword if    '${CASE105_1}'=='PASS' and '${CASE105_2}'=='PASS'    log     pass
    ...    ELSE    Fail    Case not pass

TC.CB007310_A_101_Secondary_core_failure_escalate_to_Site_Reset
    COAM_WebEM.Login    version=${sbts_stream}
    KW.UploadFileAndExecuteCaseOnRemoteUTE      caseTag=RebootGnb

    AlarmWatchdog.add_allow_alarms    fault_id=4352
    AlarmWatchdog.add_allow_alarms    fault_id=4367
    AlarmWatchdog.add_allow_alarms    fault_id=6450
    AlarmWatchdog.add_allow_alarms    fault_id=4590
    AlarmWatchdog.add_allow_alarms    fault_id=16
    wait until keyword succeeds    2min    1s    KW.CheckAlarmFor_Case_A101
    #wait until keyword succeeds    5min    1s    gNB.CheckgNBReset
    COAM_WebEM.Logout

    wait until keyword succeeds    30min    30s    KW.CheckCellStatusOfPrimaryCore
    ...                            Operational_State=Enabled
    wait until keyword succeeds    30min    30s    KW.CheckCellStatusOfSecondaryCore
    ...                            Operational_State=Enabled

    COAM_WebEM.Login    version=${sbts_stream}
    ${status}    Run Keyword And Return Status    KW.CheckAlarmFor_Case_A101
    COAM_WebEM.Logout
    AlarmWatchdog.remove_allow_alarms    fault_id=4352
    AlarmWatchdog.remove_allow_alarms    fault_id=4367

    Should not be true    ${status}

    ${alarm_result}=    KW.GetAndCheckAlarm      6450check=True
    Run Keyword And Continue On Failure    Run keyword if    '${alarm_result}'=='False'    Fail
        ...    Please check unexpect Alarm
        ...    ELSE    Run Keyword And Ignore error    gNB.CollectSnapshot
    AlarmWatchdog.remove_allow_alarms    fault_id=6450
    AlarmWatchdog.remove_allow_alarms    fault_id=4590
    AlarmWatchdog.remove_allow_alarms    fault_id=16

KW.CheckAlarm103
    wait until keyword succeeds    10min    30s    COAM_WebEM.Login    version=${sbts_stream}
   ${res1}    Run Keyword And Return Status    KW.Check_Alarm_from_Active_Alarms     target_alarm_id=7111
   ...                                         target_fault_id=4082
   ...                                         target_alarm_name=SW fallback
   ...                                         target_alarm_object=${object1}
   should be true    ${res1}
   ${res2}    Run Keyword And Return Status    KW.Check_Alarm_from_Active_Alarms     target_alarm_id=7111
   ...                                         target_fault_id=23
   ...                                         target_alarm_name=Incompatible SW version detected
   ...                                         target_alarm_object=${object2}
   should be true    ${res2}
   COAM_WebEM.Logout
KW.CheckAlarm103Disapear23
    wait until keyword succeeds    10min    30s    COAM_WebEM.Login    version=${sbts_stream}

   ${res}    Run Keyword And Return Status    KW.Check_Alarm_from_Active_Alarms     target_alarm_id=7111
   ...                                         target_fault_id=23
   ...                                         target_alarm_name=Incompatible SW version detected
   ...                                         target_alarm_object=${object2}
   run keyword and ignore error    COAM_WebEM.Logout
   should be true    '${res}'=='False'

KW.CheckAlarm103Disapear4082
   wait until keyword succeeds    10min    30s    COAM_WebEM.Login    version=${sbts_stream}
   ${res}    Run Keyword And Return Status    KW.Check_Alarm_from_Active_Alarms     target_alarm_id=7111
   ...                                         target_fault_id=4082
   ...                                         target_alarm_name=SW fallback
   ...                                         target_alarm_object=${object1}
   run keyword and ignore error    COAM_WebEM.Logout
   should be true    '${res}'=='False'

TC.5GC000829_A_103_SWM_Primary_core_SW_fallback
    run keyword if    '${IS_COmmon_Build}'=='true'    run keywords
    ...    set test variable   ${object1}    SMOD-1
    ...    AND    set test variable   ${object2}    SMOD-2
    ...    ELSE    run keywords
    ...    set test variable   ${object1}    SMOD_R-1
    ...    AND    set test variable   ${object2}    SMOD_R-2
   ##${build_version}    KW.Get_gNB_Active_SW_Version
   ##${sbts_stream}   Fetch From Left    ${build_version}   _
   #${target_version}    KW.Get_gNB_Passive_SW_Version
   #KW.SW_Download_Upgrade_Delete   ${target_version}
   #sleep    1min
   #Wait Until Keyword Succeeds    40min    1min    COAM_Admin.CheckAllCellsOnair     type=both
   #${Result}    Run Keyword And Ignore error     BtsLog.StopBTSlogCollectionandGetlog
   #${SyslogResult}      set variable           ${Result}[1][0]
   #Run Keyword If  '${SyslogResult}' == 'FAIL'   Run Keyword And Ignore error    gNB.CollectSnapshot

   #Run Keyword And Ignore error    BtsLog.StartBTSlogCollection
   #rollback site
   #${Result}    Run Keyword And Ignore error     BtsLog.StopBTSlogCollectionandGetlog
   #${SyslogResult}      set variable           ${Result}[1][0]
   #Run Keyword If  '${SyslogResult}' == 'FAIL'   Run Keyword And Ignore error    gNB.CollectSnapshot

   AlarmWatchdog.add_allow_alarms    fault_id=10
   AlarmWatchdog.add_allow_alarms    fault_id=23
   AlarmWatchdog.add_allow_alarms    fault_id=4082
   AlarmWatchdog.add_allow_alarms    fault_id=6450
   AlarmWatchdog.add_allow_alarms    fault_id=4592
   AlarmWatchdog.add_allow_alarms    fault_id=4367
   AlarmWatchdog.add_allow_alarms    fault_id=4681
   AlarmWatchdog.add_allow_alarms    fault_id=4753
   AlarmWatchdog.add_allow_alarms    fault_id=6328
#   AlarmWatchdog.add_allow_alarms    fault_id=2002
   AlarmWatchdog.add_allow_alarms    fault_id=7505
   AlarmWatchdog.add_allow_alarms    fault_id=7504

   Run Keyword And Ignore error    BtsLog.StartBTSlogCollection
   log to console    Trigger PrimaryCore FallBack
   KW.TriggerPrimaryCoreFallBack
   wait until keyword succeeds    30min    60s    KW.CheckAlarm103
   KW.check secondarycore after fallback
   ${Result}    Run Keyword And Ignore error     BtsLog.StopBTSlogCollectionandGetlog
   ${SyslogResult}      set variable           ${Result}[1][0]
   Run Keyword If  '${SyslogResult}' == 'FAIL'   Run Keyword And Ignore error    gNB.CollectSnapshot

   Run Keyword And Ignore error    BtsLog.StartBTSlogCollection
   ${target_version}    KW.Get_gNB_Active_SW_Version
   KW.SW_Download_Upgrade_Delete   ${target_version}
   sleep    1min
   wait until keyword succeeds    25min    60s    KW.CheckAlarm103Disapear23
   #Wait Until Keyword Succeeds    15min    1min    COAM_Admin.CheckAllCellsOnair     type=both

   ${res}    run keyword and ignore error    KW.UploadFileAndExecuteCaseOnRemoteUTE      caseTag=105
   Run Keyword If   '${res[0]}'!='FAIL'   set suite variable    ${CASE105_1}    PASS
   ...    ELSE    set suite variable    ${CASE105_1}    FAIL
   ${Result}    Run Keyword And Ignore error     BtsLog.StopBTSlogCollectionandGetlog
   ${SyslogResult}      set variable           ${Result}[1][0]
   Run Keyword If  '${SyslogResult}' == 'FAIL'   Run Keyword And Ignore error    gNB.CollectSnapshot

   Run Keyword And Ignore error    BtsLog.StartBTSlogCollection
   ${target_version}    KW.Get_gNB_Passive_SW_Version
   AlarmWatchdog.add_allow_alarms    fault_id=4261
   KW.SW_Download_Upgrade_Delete   ${target_version}
   AlarmWatchdog.remove_allow_alarms    fault_id=4261
   sleep    10min
   wait until keyword succeeds    10min    60s    KW.CheckAlarm103Disapear4082
   Wait Until Keyword Succeeds    30min    1min    COAM_Admin.CheckAllCellsOnair     type=both

   ${alarm_result}=    KW.GetAndCheckAlarm
   Run Keyword And Continue On Failure    Run keyword if    '${alarm_result}'=='False'    Fail
        ...    Please check unexpect Alarm
   AlarmWatchdog.remove_allow_alarms    fault_id=10
   AlarmWatchdog.remove_allow_alarms    fault_id=23
   AlarmWatchdog.remove_allow_alarms    fault_id=4082
   AlarmWatchdog.remove_allow_alarms    fault_id=6450
   AlarmWatchdog.remove_allow_alarms    fault_id=4592
   AlarmWatchdog.remove_allow_alarms    fault_id=4367
   AlarmWatchdog.remove_allow_alarms    fault_id=4681
   AlarmWatchdog.remove_allow_alarms    fault_id=4753
   AlarmWatchdog.remove_allow_alarms    fault_id=6328
   AlarmWatchdog.remove_allow_alarms    fault_id=7505
   AlarmWatchdog.remove_allow_alarms    fault_id=7504

TC.CB007310_A_201_Software_download_reject
    log to console     Get active and passive sw versions before sw update
    ${Pre_Passive_version}    KW.Get_gNB_Passive_SW_Version
    ${Pre_Active_version}    KW.Get_gNB_Active_SW_Version
    log to console     Remove TargetBD file to make SW update fail
    KW.SW_Download_Remove_TargetBDfile_update_fail_Delete   ${Pre_Passive_version}
    Sleep  60
    log to console     Get active and passive sw versions after sw update
    ${After_Passive_version}    KW.Get_gNB_Passive_SW_Version
    ${After_Active_version}     KW.Get_gNB_Active_SW_Version
    Should Be True  '${Pre_Active_version}' == '${After_Active_version}'
    Should Be True  '${Pre_Passive_version}' == '${After_Passive_version}'

TC.CB007310_A_202_Stop_software_download
    log to console     Get active and passive sw versions before sw update
    ${Pre_Passive_version}    KW.Get_gNB_Passive_SW_Version
    ${Pre_Active_version}     KW.Get_gNB_Active_SW_Version
    KW.SW_Download_and_Cancel    ${Pre_Passive_version}
    Sleep  30
    log to console     Get active and passive sw versions after sw update
    ${After_Passive_version}    KW.Get_gNB_Passive_SW_Version
    ${After_Active_version}     KW.Get_gNB_Active_SW_Version
    Should Be True  '${Pre_Active_version}' == '${After_Active_version}'
    Should Be True  '${Pre_Passive_version}' == '${After_Passive_version}'

TC.Inter_Core_Communication_Broken_And_Recovery
    gNB.Connect
    ${isPrimaryCoreInLeftSubrack}    Set Variable    ${True}
    ${isPrimaryCoreInLeftSubrack}    gNB.IsPrimaryCoreInLeftSubrack
    gNB.Disconnect

    COAM_WebEM.Login
    KW.Inter_Core_Broken_Recovery    action=broken    isPrimaryCoreInLeftSubrack=${isPrimaryCoreInLeftSubrack}
    AlarmWatchdog.add_allow_alarms    fault_id=10
    AlarmWatchdog.add_allow_alarms    fault_id=4352
    AlarmWatchdog.add_allow_alarms    fault_id=4367
    AlarmWatchdog.add_allow_alarms    fault_id=6450
    AlarmWatchdog.add_allow_alarms    fault_id=4590
    AlarmWatchdog.add_allow_alarms    fault_id=4753
    AlarmWatchdog.add_allow_alarms    fault_id=6328
    wait until keyword succeeds   10min   5s    KW.CheckFault4352
    ...    fault_name=BTS secondary core autonomous reset as recovery action
    wait until keyword succeeds   10min   5s    KW.CheckFault4352
    ...    fault_name=No connection between primary and BTS extension system module
    wait until keyword succeeds   10min   5s    KW.CheckFault4352
    ...    fault_name=BTS secondary core warm reset via subrack backplane autonomous reset as recovery action
    COAM_WebEM.Logout

    sleep    6min
    COAM_WebEM.Login
    KW.Inter_Core_Broken_Recovery    action=recovery    isPrimaryCoreInLeftSubrack=${isPrimaryCoreInLeftSubrack}

    ${smodtype}   Get_SMOD_type
    ${result}   run keyword and return status     Should not Contain   ${smodtype}    ASIK
    Run Keyword If    '${result}'=='True'
    ...   wait until keyword succeeds   10min   5s    KW.CheckFault4352    fault_name=RAT autonomous reset as recovery action
    COAM_WebEM.Logout

    sleep    5min

    wait until keyword succeeds    10min    20s        COAM_Admin.CheckAllCellsOnair     type=both
    KW.CheckUnexpectFault    6450check=True
    Run Keyword And Ignore error    gNB.CollectSnapshot
    AlarmWatchdog.remove_allow_alarms    fault_id=10
    AlarmWatchdog.remove_allow_alarms    fault_id=4352
    AlarmWatchdog.remove_allow_alarms    fault_id=4367
    AlarmWatchdog.remove_allow_alarms    fault_id=6450
    AlarmWatchdog.remove_allow_alarms    fault_id=4590
    AlarmWatchdog.remove_allow_alarms    fault_id=4753
    AlarmWatchdog.remove_allow_alarms    fault_id=6328

Get_SMOD_type
    run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
    ${output}    selenium_coam.get_hw_parameters    hw_type=SMOD    index=1
    ${output_tmp}    set variable    ${output}[Runtime parameters]
    set suite variable    ${P_name_smod}    ${output_tmp}[Product name]
    [Return]      ${P_name_smod}

KW.Inter_Core_Broken_Recovery
    [Arguments]    ${action}    ${isPrimaryCoreInLeftSubrack}
    gNB.Connect
    Run Keyword If    '${action}'=='broken' and '${isPrimaryCoreInLeftSubrack}'=='${True}'
    ...    ssh.Execute     ip6tables -A INPUT -s fd5f:4268:2387:a881:0040:43ff:fe80:1000 -p sctp --dport 29211 -j DROP    connection=${ALIAS_ASIK}
    ...    ELSE IF    '${action}'=='broken' and '${isPrimaryCoreInLeftSubrack}'=='${False}'
    ...    ssh.Execute     ip6tables -A INPUT -s fd5f:4268:2387:a881:0040:43ff:fe80:0 -p sctp --dport 29211 -j DROP    connection=${ALIAS_ASIK}

    Run Keyword If    '${action}'=='recovery' and '${isPrimaryCoreInLeftSubrack}'=='${True}'
    ...    ssh.Execute    ip6tables -D INPUT -s fd5f:4268:2387:a881:0040:43ff:fe80:1000 -p sctp --dport 29211 -j DROP    connection=${ALIAS_ASIK}
    ...    ELSE IF    '${action}'=='recovery' and '${isPrimaryCoreInLeftSubrack}'=='${False}'
    ...    ssh.Execute    ip6tables -D INPUT -s fd5f:4268:2387:a881:0040:43ff:fe80:0 -p sctp --dport 29211 -j DROP    connection=${ALIAS_ASIK}

    gNB.Disconnect

KW.CheckFault4352
    [Arguments]    ${fault_name}
    ${active_alarm}    selenium_coam.get_active_alarm_info
    ${history_alarm}    selenium_coam.get_history_alarm_info

    ${result1}    set variable    ${False}
    FOR    ${item}    IN   @{active_alarm}
        ${id}    get from dictionary    ${item}    Fault ID
        ${name}    get from dictionary    ${item}    Fault name
        ${result1}    set variable if   '${id}'=='4352' and '${name}'=='${fault_name}'    ${True}    ${False}
        Exit For Loop If    '${result1}'=='${True}'
    END

    ${result2}    set variable    ${False}
    FOR    ${item}    IN   @{history_alarm}
        ${id}    get from dictionary    ${item}    Fault ID
        ${name}    get from dictionary    ${item}    Fault name
        ${result2}    set variable if   '${id}'=='4352' and '${name}'=='${fault_name}'    ${True}    ${False}
        Exit For Loop If    '${result2}'=='${True}'
    END

    should be true    '${result1}'=='${True}' or '${result2}'=='${True}'


#-------------------------------------------Test Case End---------------------------------------------------------------

#-------------------------------------Execute On Remote UTE Begin-------------------------------------------------------

KW.UploadFileAndExecuteCaseOnRemoteUTE
    [Arguments]    ${caseTag}    ${files}=None   ${uteIP}=${RIGHT_UTE_IP}
    [Teardown]    Run Keyword And Ignore Error    KW.RemoveFileOnRemoteUTE    ${files}   uteIP=${uteIP}
    Run Keyword If    ${files}==None    KW.SetFilesList
    KW.UploadFileToRemoteUTE    files=${files}    uteIP=${uteIP}
    KW.ExecuteOnRemoteUTE     caseTag=${caseTag}    uteIP=${uteIP}

KW.SetFilesList
    ${files}    Create List    ${CURDIR}/TC_Execute_On_Remote_UTE.robot
    Set Test Variable    ${files}

KW.RemoveFileOnRemoteUTE
    [Arguments]    ${files}    ${uteIP}=${RIGHT_UTE_IP}
    ssh.Connect to    hostname=${uteIP}    username=${UTE_USERNAME}    password=${UTE_PASSWORD}    alias=tmpConn_UTE
    FOR    ${file}    IN    @{files}
        ssh.Send Command    rm /tmp/${file.split('/')[-1]}    connection=tmpConn_UTE
        ${file_on_ute}    ssh.File Exists    /tmp/${file.split('/')[-1]}    connection=tmpConn_UTE
        Should Not Be True    ${file_on_ute}
    END
    ssh.disconnect    connection=tmpConn_UTE

KW.UploadFileToRemoteUTE
    [Arguments]    ${files}    ${uteIP}=${RIGHT_UTE_IP}
    ssh.Connect to    hostname=${uteIP}    username=${UTE_USERNAME}    password=${UTE_PASSWORD}    alias=tmpConn_UTE
    FOR    ${file}    IN    @{files}
        ssh.Upload File    ${file}    /tmp/${file.split('/')[-1]}    connection=tmpConn_UTE
        ${file_on_ute}    ssh.File Exists    /tmp/${file.split('/')[-1]}    connection=tmpConn_UTE
        Should Be True    ${file_on_ute}
    END
    ssh.disconnect    connection=tmpConn_UTE

KW.ExecuteOnRemoteUTE
    [Arguments]    ${caseTag}=None    ${tcIndex}=None    ${uteIP}=${RIGHT_UTE_IP}
    ssh.Connect to    hostname=${uteIP}    username=${UTE_USERNAME}    password=${UTE_PASSWORD}    alias=tmpConn_UTE
    Set test variable    ${activate}    source ~/${CIENVPATH}/bin/activate
    Set test variable    ${case1}
    ...  robot -i ${caseTag} -v isCommonBuild:${IS_COmmon_Build} -L TRACE -l /home/ute/log_${caseTag}_${tcIndex}
    Set test variable    ${case2}    -v AF_PATH:${AF_PATH} /tmp/TC_Execute_On_Remote_UTE.robot
    ${case}    catenate    ${case1}  ${case2}
    Set test variable    ${deactivae}    deactivate
    ${out}    ssh.Execute    ${activate} && ${case} && ${deactivae}    connection=tmpConn_UTE
    should contain    ${out}    1 test, 1 passed, 0 failed
    ssh.disconnect    connection=tmpConn_UTE

#--------------------------------------------Execute On Remote UTE End--------------------------------------------------

#----------------------------------------------setup and teardown Begin-------------------------------------------------
KW.CaseTeardown_For_SecondaryCoreSWUpgradeViaWebEM
   run  rm -rf ${upgrade_package_path}
   KW.CaseTeardown


KW.CaseSetup_For_SecondaryCoreSWUpgradeViaWebEM
    TestCase.Start
    COAM_Admin.CheckAllCellsOnair     type=both
    ${Passive_version}    KW.Get_gNB_Passive_SW_Version
    ${prefix}   ${stream}    ${mid}   ${last}   Split String From Right    string=${Passive_version}   separator=_    max_split=3
    run keyword if    '${stream}'=='0000'    run keywords
    ...    COAM_WebEM.Login    version=${sbts_stream}
    ...    AND  selenium_coam.software_rollback
    ...    AND  sleep    20min
    ...    AND  Wait Until Keyword Succeeds    30min    1min    COAM_Admin.CheckAllCellsOnair     type=both
    ...    AND  Run Keyword And Ignore Error    COAM_Admin.Logout
    Run Keyword And Ignore error    BtsLog.StartBTSlogCollection


KW.CaseSetup_For_InterCoreBrokenAndRecovery
    TestCase.Start
    COAM_Admin.CheckAllCellsOnair     type=both
    COAM_WebEM.Login    version=${sbts_stream}
	COAM_WebEM.ModifyAndActiveParameters    DistName=${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
	...    FilterParam=Activate secondary core backplane resets    NewValue=enableAll
	sleep    30s
	COAM_WebEM.Logout
	Wait Until Keyword Succeeds    30min    1min    COAM_Admin.CheckAllCellsOnair     type=both
    BtsLog.StartBTSlogCollection

KW.829Setup Suite
    KW.SuiteSetup
#    set suite variable   ${IS_COmmon_Build}       ${CASE_INPUT_5GC000829["isCommonbuild"]}
    set suite variable   ${OAM_TYPE}    COAM
#    set suite variable   ${RIGHT_UTE_IP}   ${CASE_INPUT_5GC000829['RIGHT_UTE_IP']}
    gNB.FormatBTSID

    ${version}    Set variable        ${AF_PATH}
    run keyword if    ${version.count('SBTS')}>${0}    set suite variable    ${IS_COmmon_Build}    true
    ...    ELSE    set suite variable    ${IS_COmmon_Build}    false

    run keyword if    '${IS_COmmon_Build}'=='true'
    ...    set suite variable    ${alarm_object}    Configuration alarming object
    ...    ELSE    set suite variable    ${alarm_object}    Alarming object

    set suite variable    ${dist_name}   ${MRBTS_ID}/${NRBTS_ID}
    ${res}    Run Keyword And Ignore error    gNB.GenerateTestLineSCFs
    #${res}    Run Keyword And Ignore error    gNB.Generate TL SCF
	#...                  GoldenSCF_PATH=${GoldenSCF_ON_GIT}/${GoldenSCF}   TLDelta_PATH=${CFGFILE_PATH}
	#...                  TestLineSCF_cell_num=${2}    cell_type=Both
	#...                  MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}

#	run keyword if    '${testline_name}'=='7_5_UTE5G402T1111'
#	...     Set Suite Variable    ${Dula_core_base_scf}    ${CFGFILE_PATH}TestLineSCF1Cell_Both_dual.xml
#	...     ELSE    Set Suite Variable    ${Dula_core_base_scf}    ${LOG_PATH}/TestLineSCF2Cell_Both.xml

    run keyword if    '${res[0]}'=='PASS'    gNB.Commission   scf_file=${res[1]}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both

KW.SuiteSetup
    TestSuite.Start
    wait until keyword succeeds   3x   1min    COAM_Admin.Login
    ${sw_version}     coam.get_sw_version    connection=COAM
#    ${status}    run keyword and return status     Should Contain   ${sw_version}    SBTS22R3
#    set suite variable   ${is_master}    ${status}
    ${stream}   ${subversion}    Split String   string=${sw_version}   separator=_     max_split=1
    ${stream}    set variable if   '${stream}'>='SBTS22R2'    SBTS22R2    SBTS21B
    set suite variable    ${sbts_stream}    ${stream}
    set suite variable     ${DeltaPath}     ${CURDIR}/CaseSCFDelta.py
    COAM_Admin.Logout

KW.SuiteTeardown
    Run Keyword And Ignore error    run    command=rm -rf /home/ute/Download_gNB_Package/*
    TestSuite.Stop

KW.CaseSetup
    TestCase.Start
    Run Keyword And Ignore error    KW.PreparegNBTODualCore
    ${cells_status}    Run Keyword And Return Status    COAM_Admin.CheckAllCellsOnair     type=both
#    ${cells_status_LTE}    Run Keyword And Return Status    COAM_Admin.CheckAllCellsOnair     type=lte
    run keyword if    '${cells_status}'=='False'   run keyword and ignore error    KW.ResetSite
    Run Keyword And Ignore error    BtsLog.StartBTSlogCollection
    set test variable    ${Single_core_primary_base_scf}             ${CFGFILE_PATH}TestLineSCF1Cell_Both_left.xml
    set test variable    ${Single_core_secondary_base_scf}           ${CFGFILE_PATH}TestLineSCF1Cell_Both_right.xml
    set test variable    ${Dula_core_base_scf}                       ${CFGFILE_PATH}TestLineSCF1Cell_Both_dual.xml
#    AlarmWatchdog.add_allow_alarms    fault_id=1806
#    AlarmWatchdog.add_allow_alarms    fault_id=2002

KW.CaseSetupForK005
    KW.CaseSetup
    Run Keyword And Continue On Failure    GNB Commission For K005 Case    SCF=829_K005_SCF.xml
    ...    ParameterToDelete=PARAMS_TO_DELETE_829_K005
    ...    ParamterToModify=PARAMS_TO_MODIFY_829_K005    MOsToAdd=ADD_MOs_829_K005    ListToAdd=ADD_TO_List_829_K005

GNB Commission For K005 Case
    [Arguments]    ${SCF}    ${ParameterToDelete}    ${ParamterToModify}    ${MOsToAdd}    ${ListToAdd}    ${InputFile}=${Dula_core_base_scf}
    run   command=cp ${CFGFILE_PATH}\SCF_SBTS00.xml ${InputFile}
    gNB.ReplaceDeltaID    DeltaPath=${DeltaPath}
    gNB.GenerateCaseSCF    InputFile=${InputFile}    OutputFile=${LOG_PATH}/${SCF}
    ...                    ResourceFolder=${CURDIR}
    ...                    ParameterToDelete=${ParameterToDelete}
    ...                    ParamterToModify=${ParamterToModify}
    ...                    MOsToAdd=${MOsToAdd}
    ...                    ListToAdd=${ListToAdd}
    gNB.CommissionWithRetry    scf_file=${LOG_PATH}/${SCF}    model=HBTE
    wait until keyword succeeds   10x   1min    gNB.VerifyOnAirViaOAMUntilReady

KW.CaseTeardown
#    AlarmWatchdog.remove_allow_alarms    fault_id=1806
#    AlarmWatchdog.remove_allow_alarms    fault_id=2002
    ${Result}    Run Keyword And Ignore error     BtsLog.StopBTSlogCollectionandGetlog
    TestCase.Stop
    ${SyslogResult}      set variable           ${Result}[1][0]
    Run Keyword If  '${TEST STATUS}' == 'FAIL' or '${SyslogResult}' == 'FAIL'   Run Keyword And Ignore error    gNB.CollectSnapshot
    ...    ELSE    Pass Execution If    '${TEST STATUS}' == 'PASS'    Not collect snapshot logs
    Run Keyword And Ignore error     KW.Kill Xvfb in UTE
    Run Keyword And Ignore error     force_close_coam_webdriver
    Run Keyword And Ignore error     run    command=killall firefox
    Run Keyword And Ignore error     run    command=killall geckodriver

#    TestCase.Stop
    #KW.PreparegNBTODualCore

KW.CaseTeardownForK005
    gNB.CommissionWithRetry    scf_file=${CFGFILE_PATH}/SCF_SBTS00.xml   model=HBTE
    wait until keyword succeeds   10x   1min    gNB.VerifyOnAirViaOAMUntilReady
    KW.CaseTeardown

KW.Kill Xvfb in UTE
    ${Xvfb_Cnt}  run  command=ps -ef | grep -i Xvfb |grep -v grep|awk '{print$2}'|awk 'END{print NR}'
    FOR    ${i}    IN RANGE    ${Xvfb_Cnt}
        ${PID1}  run  command=ps -ef|grep -i Xvfb|awk '{{print $2}}'|head -n 1
        Log  message=Killing ${i+1}st Xvfb process with PID ${PID1}.
        run  command=/bin/kill -9 ${PID1.strip()}
    END
    run  command=ps -ef | grep -i Xvfb |grep -v grep

KW.CaseSetupOf5GC000829_A_010
    TestCase.Start
    COAM_WebEM.Login    version=${sbts_stream}
    Run Keyword And Ignore error  COAM_WebEM.ModifyAndActiveParameters
    ...                           DistName=${MRBTS_ID}/${NRBTS_ID}/NRCELL-${CASE_INPUT_5GC000829["829_A_010"]["nrcell"]}
    ...                           FilterParam=Cell Barred    NewValue=notBarred
    COAM_WebEM.Logout

KW.CaseTeardownOf5GC000829_A_010
    KW.Delete_CPIFLOG_From_GNB    /tmp/node_CPIF00/tmp    cpiflog_barred.pcap    cpiflog_notBarred.pcap
    COAM_WebEM.Login    version=${sbts_stream}
    Run Keyword And Ignore error  COAM_WebEM.ModifyAndActiveParameters
    ...                           DistName=${MRBTS_ID}/${NRBTS_ID}/NRCELL-${CASE_INPUT_5GC000829["829_A_010"]["nrcell"]}
    ...                           FilterParam=Cell Barred    NewValue=notBarred
    COAM_WebEM.Logout
    KW.CaseTeardown
    TestCase.Stop

#KW.CaseTeardownWithReconmissionTestLineScf
#    gNB.Commission      scf_file=${Dula_core_base_scf}      timeout=${2400}
#    TestCase.Stop

KW.CaseTeardownOf5GC000829_A_016
    COAM_WebEM.Login    version=${sbts_stream}
    ${value_of_actServiceAccountSsh}    selenium_coam.get_parameter_value    dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                                                                      filter_param=Activate service account SSH
    ${value_of_actServicePortState}     selenium_coam.get_parameter_value    dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                                                                      filter_param=Activate service port state

    run keyword if    '${value_of_actServiceAccountSsh}'=='false'
    ...                selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                                                     filter_param=Activate service account SSH
    ...                                                     new_value=true

    run keyword if    '${value_of_actServicePortState}'=='false'
    ...                selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                                                     filter_param=Activate service port state
    ...                                                     new_value=true

    ${result}    evaluate  '${value_of_actServicePortState}'=='false' or '${value_of_actServiceAccountSsh}'=='false'
    run keyword if    ${result}
    ...               COAM_WebEM.ValidateAndActiveParameters

    COAM_WebEM.Logout

KW.CaseTeardownOf5GC000829_A_018
    Run Keyword And Ignore error     run    command=cd ${LOG_PATH}/829_A_018/. ; rm -rf *
    TestCase.Stop

KW.CaseTeardownOf5GC000829_A_012
    COAM_WebEM.Login    version=${sbts_stream}
    COAM_WebEM.ModifyAndActiveParameters     DistName=${MRBTS_ID}/${NRBTS_ID}
    ...     FilterParam=${actSACallProcessingDU_filter}      NewValue=${value_of_SA_call_1}
    Run Keyword And Return Status    COAM_WebEM.Logout
    sleep    8min     #wait for gNB state change to onair,this is a WA,don't delete this keyword.
    TestCase.Stop
    Run Keyword And Ignore error     KW.Kill Xvfb in UTE
    Run Keyword And Ignore error     force_close_coam_webdriver
    Run Keyword And Ignore error     run    command=killall firefox
    Run Keyword And Ignore error     run    command=killall geckodriver
    KW.PreparegNBTODualCore

KW.CaseTeardownOf5GC000829_A_021
    ${cell_num}    get length    ${CASE_INPUT_5GC000829["829_A_021"]["lock_unlock_cell_index"]}
    FOR  ${i}  IN RANGE  ${cell_num}
        KW.UnLockSpecifyCell     cell_idx=${CASE_INPUT_5GC000829["829_A_021"]["lock_unlock_cell_index"][${i}]}
    END
    ${Result}    Run Keyword And Ignore error     BtsLog.StopBTSlogCollectionandGetlog
    ${SyslogResult}      set variable           ${Result}[1][0]
    TestCase.Stop
    Run Keyword If  '${TEST STATUS}' == 'FAIL' or '${SyslogResult}' == 'FAIL'   Run Keyword And Ignore error    gNB.CollectSnapshot
    ...    ELSE    Pass Execution If    '${TEST STATUS}' == 'PASS'    Not collect snapshot logs
#    TestCase.Stop
    Run Keyword And Ignore error     KW.Kill Xvfb in UTE
    Run Keyword And Ignore error     force_close_coam_webdriver
    Run Keyword And Ignore error     run    command=killall firefox
    Run Keyword And Ignore error     run    command=killall geckodriver
#    KW.PreparegNBTODualCore

KW.CaseTeardownOf5GC000829_A_022
    #Run Keyword And Ignore error     rd.stop_trace
    #wait until keyword succeeds    10min    2min    rd.get_results
    #sleep    2min
    #${trace_logpath}    rd.get_results

    #run    command=cp ${trace_logpath} ${LOG_PATH}
    #run    command=rm -f ${trace_logpath}

    #rd.delete_trace
    #rd.delete_bts

    ${cell_num}    get length    ${CASE_INPUT_5GC000829["829_A_022"]["lock_unlock_cell_index"]}
    FOR  ${i}  IN RANGE  ${cell_num}
        KW.UnLockSpecifyCell     cell_idx=${CASE_INPUT_5GC000829["829_A_022"]["lock_unlock_cell_index"][${i}]}
    END
    ${Result}    Run Keyword And Ignore error     BtsLog.StopBTSlogCollectionandGetlog
    ${SyslogResult}      set variable           ${Result}[1][0]
    TestCase.Stop
    Run Keyword If  '${TEST STATUS}' == 'FAIL' or '${SyslogResult}' == 'FAIL'   Run Keyword And Ignore error    gNB.CollectSnapshot
    ...    ELSE    Pass Execution If    '${TEST STATUS}' == 'PASS'    Not collect snapshot logs
#    TestCase.Stop
    Run Keyword And Ignore error     KW.Kill Xvfb in UTE
    Run Keyword And Ignore error     OAM_Interface.force_close_coam_webdriver
    Run Keyword And Ignore error     run    command=killall firefox
    Run Keyword And Ignore error     run    command=killall geckodriver
#    KW.PreparegNBTODualCore

KW.ResetSite
    COAM_WebEM.Login    version=${sbts_stream}
    ${status}    Run Keyword And Return Status    selenium_coam.reset_site
    should be true    ${status}
    sleep    60s
    # ${status}    Run Keyword And Return Status    KW.ConnectDualCoreBySSH
    # Should not be true    ${status}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    Run Keyword And Ignore error    gNB.CollectSnapshot
#    ssh.Connect to    ${LMP_Primary}    ${ASIK_USERNAME}    ${ASIK_PASSWORD}    alias=tmpConn
#    ${uptime_timer}    ssh.execute    uptime|awk '{{print $3}}'    connection=tmpConn
#	${uptime_timer}    Fetch From Left    ${uptime_timer}  ,
#	Should be True    '${uptime_timer}' < '0:10'
#	ssh.disconnect    connection=tmpConn

KW.ResetBBMOD
    [Arguments]  ${bbModNum}
    FOR  ${i}  IN RANGE  ${bbModNum}
        selenium_coam.reset_abil
        ...  abil_index=${CASE_INPUT_5GC000829["829_A_009"]["BBMODs_Reset"][${i}]["index"]}
    END

KW.ResetRu
    [Arguments]  ${ruNum}
    FOR  ${i}  IN RANGE  ${ruNum}
        selenium_coam.reset_ru
        ...  ru_index=${CASE_INPUT_5GC000829["829_A_009"]["RMODs_Reset"][${i}]["index"]}
    END

#-------------------------------------------------Reset Operation End---------------------------------------------------

#-----------------------------------------------Lock and Unlock Operation Begin-----------------------------------------

KW.LockUnlockBTS
    ${cellNum}   KW.GetCellNum
    COAM_WebEM.Login    version=${sbts_stream}
    selenium_coam.lock_bts
    selenium_coam.get_bts_lock_or_unlock
    Wait Until Keyword Succeeds    5min    2min    KW.CheckAllCellStatus
    ...   Operational_State=Disabled
    COAM_WebEM.Login    version=${sbts_stream}
    selenium_coam.unlock_bts
    Wait Until Keyword Succeeds    5min    2min    KW.CheckAllCellStatus

KW.BlockUnblockSite
    COAM_WebEM.Login    version=${sbts_stream}
	selenium_coam.block_site
	Wait Until Keyword Succeeds    6x    2min    KW.CheckAllCellStatus
    ...   Operational_State=Disabled
	COAM_WebEM.Login    version=${sbts_stream}
	selenium_coam.unblock_site
	Wait Until Keyword Succeeds    6x    2min    KW.CheckAllCellStatus

KW.LockRu
    [Arguments]  ${ruNum}
    FOR  ${i}  IN RANGE  ${ruNum}
        selenium_coam.lock_ru
        ...  ru_index=${CASE_INPUT_5GC000829["829_A_009"]["RMODs_LockAndUnlock"][${i}]["index"]}
    END

KW.unLockRu
    [Arguments]  ${ruNum}
    FOR  ${i}  IN RANGE  ${ruNum}
        selenium_coam.unlock_ru
        ...  ru_index=${CASE_INPUT_5GC000829["829_A_009"]["RMODs_LockAndUnlock"][${i}]["index"]}
    END

KW.LockCell
    [Arguments]  ${cellNum}
    FOR  ${i}  IN RANGE  ${cellNum}
        COAM_WEBEM.LockUnlcokCell
        ...  cell_idx=${CASE_INPUT_5GC000829["829_A_009"]["CELLs_LockAndUnlock"][${i}]["index"]}    action=lock
    END

KW.unLockCell
    [Arguments]  ${cellNum}
    FOR  ${i}  IN RANGE  ${cellNum}
        COAM_WEBEM.LockUnlcokCell
        ...  cell_idx=${CASE_INPUT_5GC000829["829_A_009"]["CELLs_LockAndUnlock"][${i}]["index"]}    action=unlock
    END

KW.LockSpecifyCell
    [Arguments]  ${cell_idx}
    COAM_WebEM.Login    version=${sbts_stream}
    COAM_WEBEM.LockUnlcokCell     cell_idx=${cell_idx}    timeout=60     action=lock
    #selenium_coam.lock_cell     cell_idx=${cell_idx}
    COAM_WebEM.Logout

KW.UnLockSpecifyCell
    [Arguments]  ${cell_idx}
    COAM_WebEM.Login    version=${sbts_stream}
    COAM_WEBEM.LockUnlcokCell     cell_idx=${cell_idx}    timeout=60     action=unlock
    #selenium_coam.unlock_cell     cell_idx=${cell_idx}
    COAM_WebEM.Logout

#-----------------------------------------------Lock and Unlock Operation End-----------------------------------------

#-------------------------------------------------other kwd Begin-------------------------------------------------------

COAM_WebEM.LoginWithSync
     [Arguments]      ${button}    ${url}    ${virtual_enable}=${TRUE}    ${version}=SBTS21B
     ${action}   Create Dictionary  modal_name=Additional hardware detected   button=${button}    timeout=${60}
     ${action_list}   Create List  ${action}
     run keyword if     ${virtual_enable}     selenium_coam.enable_virtual_display
     run keyword and ignore error    selenium_coam.logout
     Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
     ${Active_SW_version}    Get Active SW Version
     set suite variable      ${Active_SW_version}
     ${version}   ${subversion}    Split String   string=${Active_SW_version}   separator=_     max_split=1
     selenium_coam.login    url=${url}    username=${WEBUI_USERNAME}    password=${WEBUI_PASSWORD}
     ...    modal_action_configurations=${action_list}    version=${version}
     run keyword and ignore error    selenium_coam.continue_after_plug_and_play_modal_appear
     selenium_coam.disable_message_box
     selenium_coam.disable_screen_lock
     sleep    15s
     ${res}    selenium_coam.start_up_view_window_exists
     run keyword if    '${res}'=='True'        selenium_coam.close_start_up_view_window

KW.RebootSecondaryCoreInLeft
    ssh.Connect to    fct0s0icom.local    ${ASIK_USERNAME}    ${ASIK_PASSWORD}    proxy=tmpConn_P    alias=tmpConn_S
    ssh.Execute    system-module-reboot    connection=tmpConn_S
    ${status}    Run Keyword And Return Status    ssh.Connect to    fct0s0icom.local    ${ASIK_USERNAME}    ${ASIK_PASSWORD}
    [Return]     ${status}

KW.RebootSecondaryCoreInRight
    ssh.Connect to    fct4s0icom.local    ${ASIK_USERNAME}    ${ASIK_PASSWORD}    proxy=tmpConn_P    alias=tmpConn_S
    ssh.Execute    system-module-reboot    connection=tmpConn_S
    ${status}    Run Keyword And Return Status    ssh.Connect to    fct4s0icom.local    ${ASIK_USERNAME}    ${ASIK_PASSWORD}
    [Return]     ${status}

KW.SSHBetweenTwoSystemBands
    [Documentation]   ssh connection between two system band
    ssh.Connect to    ${LMP_Primary}    ${ASIK_USERNAME}    ${ASIK_PASSWORD}    alias=tmpConn_P
    ssh.Connect to    fct4s0icom.local    ${ASIK_USERNAME}    ${ASIK_PASSWORD}    proxy=tmpConn_P    alias=tmpConn_S
    ${hostname}    ssh.Execute       hostname    connection=tmpConn_S
    Should Contain    ${hostname}    fct-4a
    ssh.Connect to    fct0s0icom.local    ${ASIK_USERNAME}    ${ASIK_PASSWORD}    proxy=tmpConn_S    alias=tmpConn_P
    ${hostname}    ssh.Execute       hostname    connection=tmpConn_P
    Should Contain    ${hostname}    fct-0a
    ssh.disconnect    connection=tmpConn_P
    ssh.disconnect    connection=tmpConn_S

KW.TriggerSecondaryCoreFallBack
    ssh.Connect to    ${LMP_Primary}    ${ASIK_USERNAME}    ${ASIK_PASSWORD}    alias=tmpConn_P
    ssh.Connect to    fct4s0icom.local    ${ASIK_USERNAME}    ${ASIK_PASSWORD}    proxy=tmpConn_P    alias=tmpConn_S
    ssh.Execute    command=ddal -s ddal_boot_set_reset_loop_count 3    connection=tmpConn_S
    #ssh.send_command    command=reboot   connection=tmpConn_S
    ssh.send_command    command=ddal -s ddal_reboot_sm_site_graceful DDAL_REBOOT_SM_SHELF_SIDE_OWN   connection=tmpConn_S
    sleep  5min
    ${status}    Run Keyword And Return Status    ssh.Connect to    fct4s0icom.local    ${ASIK_USERNAME}    ${ASIK_PASSWORD}
    ...    roxy=tmpConn_P    alias=tmpConn_S
    run keyword and ignore error   ssh.disconnect    connection=tmpConn_P
    run keyword and ignore error   ssh.disconnect    connection=tmpConn_S
    [Return]     ${status}

KW.TriggerPrimaryCoreFallBack
    ssh.Connect to    ${LMP_Primary}    ${ASIK_USERNAME}    ${ASIK_PASSWORD}    alias=tmpConn_P
    #ssh.Connect to    fct4s0icom.local    ${ASIK_USERNAME}    ${ASIK_PASSWORD}    proxy=tmpConn_P    alias=tmpConn_S
    ssh.Execute    command=ddal -s ddal_boot_set_reset_loop_count 3    connection=tmpConn_P
    #ssh.send_command    command=reboot   connection=tmpConn_P
    ssh.send_command    command=ddal -s ddal_reboot_sm_site_graceful DDAL_REBOOT_SM_SHELF_SIDE_OWN   connection=tmpConn_P
    sleep  5min
    ${status}    Run Keyword And Return Status    ssh.Connect to    ${LMP_Primary}    ${ASIK_USERNAME}
    ...    ${ASIK_PASSWORD}    alias=tmpConn_P
    run keyword and ignore error   ssh.disconnect    connection=tmpConn_P
    #run keyword and ignore error   ssh.disconnect    connection=tmpConn_S
    [Return]     ${status}

KW.ConnectDualCoreBySSH
    [Documentation]   ssh to the given IP with username and password
    @{ipList}    Create list    ${LMP_Primary}    ${ASIK_IP_Mplane}
    FOR    ${ip}    IN     @{ipList}
        ssh.Connect to    ${ip}    ${ASIK_USERNAME}    ${ASIK_PASSWORD}    alias=tmpConn
        ssh.disconnect    connection=tmpConn
    END

KW.ConnectDualCoreByWebEM
     @{ipList}    Create list    ${LMP_Primary}    ${ASIK_IP_Mplane}
    FOR    ${ip}    IN     @{ipList}
        Set test variable   ${WEBUI_URL}    https://${ip}
        COAM_WebEM.Login    version=${sbts_stream}
        KW.CheckAllCellStatus
    END

KW.Delete_CPIFLOG_From_GNB
    [Arguments]   ${log_dir}
    ...           @{list_of_filename}
    gNB.Connect
    ${conn}    gNB.GetSystemModuleType    alias=${ALIAS_ASIK}
    FOR    ${filename}    IN    @{list_of_filename}
        ssh.execute    rm -f ${log_dir}/${filename}    connection=${conn}
    END
    gNB.Disconnect

KW.CheckSecondaryCoreReset
    ${result}    SecondaryUte.PingLMP
    ${status}    Run Keyword and Return Status    Should Contain    ${result}    64 bytes from  ${LMP_Secondary}
    Should Be True   '${status}'=='False'
    [Return]    ${status}

SecondaryUte.PingLMP
    [Arguments]    ${uteIP}=${RIGHT_UTE_IP}
    ssh.Connect to    hostname=${uteIP}    username=${UTE_USERNAME}    password=${UTE_PASSWORD}    alias=tmpConn_UTE
    ${result}    ssh.Execute    command=ping ${LMP_Secondary} -c 5    connection=tmpConn_UTE
    [Return]     ${result}

KW.Connect_To_GNB
    [Arguments]    ${hostname}=${ASIK_IP}    ${alias}=${ALIAS_ASIK}
    ssh.Connect to    hostname=${hostname}    username=${ASIK_USERNAME}    password=${ASIK_PASSWORD}   alias=${alias}

KW.Get_FHNET_Container_ID
    [Documentation]    ContainerID is 0x1018 for left side of AMIA, 0x2018 for right side.
    [Arguments]    ${hostname}=${ASIK_IP}    ${alias}=${ALIAS_ASIK}
    KW.Connect_To_GNB    hostname=${hostname}    alias=${alias}
    ${output}    Conn.Execute   cmd=lxc-ls    alias=${alias}
    ${res}   Split string    string=${output}
    ${container_id}    Set Variable    ${res[0]}
    Set Test Variable    ${container_id}
    Conn.Disconnect    alias=${alias}

KW.Set_rlan_Interface_Down_Or_Up
    [Documentation]   cpri or ecpri depends TL : ip link set rlan0.cpri/rlan0.ecpri down
    ...                                          ip link set rlan0.cpri/rlan0.ecpri up
    [Arguments]    ${cmd_A17}    ${hostname}=${ASIK_IP}    ${alias}=${ALIAS_ASIK}
    KW.Connect_To_GNB    hostname=${hostname}    alias=${alias}
    ssh.send command    command=lxc-attach -n ${container_id} -- ${cmd_A17}   connection=${alias}
    Conn.Disconnect    alias=${alias}

#-------------------------------------------------other kwd End---------------------------------------------------------

#----------------------------------------------Collect and Check Log Begin----------------------------------------------

KW.CheckUnexpectFault
    [Arguments]    ${6450check}=False
    @{Fault_whitelist}    Create list    4655   4654   61524   61652   4459   61649    61618    61011    4590    4681
#    Run Keyword if   '${GnbReset}' == 'True'    append to list    ${Fault_whitelist}    4592
    COAM_WebEM.Login
    ${active_alarm}=    Wait Until Keyword Succeeds    3X    1min    selenium_coam.get_active_alarm_info
    log    ${active_alarm}
    ${history_alarm}=    Wait Until Keyword Succeeds    3X    1min    selenium_coam.get_history_alarm_info
    log    ${history_alarm}
    ${fault_id_list}    create list
    ${unexpect_fault}    create list
    FOR    ${item}    IN    @{active_alarm}
         ${fault_id}    get from dictionary    ${item}    Fault ID
         ${object}    get from dictionary    ${item}    Configuration alarming object
         Run Keyword if   '${fault_id}' == '6450' and '${6450check}' == 'True'
         ...    Should Contain     ${object}    SMOD-2
         ...    ELSE    append to list    ${fault_id_list}    ${fault_id}
    END
    FOR    ${item}    IN    @{history_alarm}
         ${fault_id}    get from dictionary    ${item}    Fault ID
         ${object}    get from dictionary    ${item}    Configuration alarming object
         Run Keyword if   '${fault_id}' == '6450' and '${6450check}' == 'True'
         ...    Should Contain     ${object}    SMOD-2
         ...    ELSE    append to list    ${fault_id_list}    ${fault_id}
    END
    log    ${fault_id_list}
    ${length}    Get length     ${fault_id_list}
    FOR    ${i}    IN RANGE    ${length}
        ${result}=    Run Keyword And Return Status    list should contain value      ${Fault_whitelist}    ${fault_id_list[${i}]}
        Run Keyword if   '${result}' == 'False'
        ...   append to list    ${unexpect_fault}    ${fault_id_list[${i}]}
    END
    log    ${unexpect_fault}
    ${alarm_result}=    run keyword and return status    should be empty    ${unexpect_fault}
    COAM_WebEM.Logout
    [Return]    ${alarm_result}

KW.getRUSerialNumber
    [Arguments]  ${bbmod}
    @{ru_sn}    create list
    ${ruNum}    get length   ${bbmod.rus}

    FOR  ${i}  IN RANGE  ${ruNum}
        @{ru_sn}    create list    @{ru_sn}    ${bbmod.rus[${i}].serial_number}
    END

    [Return]  @{ru_sn}

KW.Check_Snapshot_Log
    [Arguments]    ${check_value}
     ${result}    run    command=unzip -o ${LOG_PATH}/829_A_018/Snapshot*.zip
     should contain     ${result}   snapshot_file_list.txt
     ${value}     run    command=cat snapshot*.txt
     should contain     ${value}    ${check_value}

KW.Check_BTSlog
    [Arguments]    ${value_1011}     ${value_2011}
    ${result}    run    command=cd /tmp/btslog2/. ; cat SYSLOG*.LOG
    should contain     ${result}    ${value_1011}
    should contain     ${result}    ${value_2011}

KW.CheckAlarmFor_Case_A101
    ${all_alarm}    selenium_coam.get_active_alarm_info
    log     ${all_alarm}
    ${alarm_info}    selenium_coam.get_active_alarm_info  alarm_filter=4352
    should not be empty    ${alarm_info}

KW.Check_Alarm_from_Active_Alarms
    [Arguments]     ${target_fault_id}    ${target_alarm_id}    ${target_alarm_name}    ${target_alarm_object}
    ${alarm_info}    selenium_coam.get_active_alarm_info
    ${length}        Get length     ${alarm_info}
    FOR    ${i}    IN RANGE    ${length}
        ${res}    run keyword and return status    run keywords
        ...                should be equal as strings    ${alarm_info[${i}]['Fault name']}    ${target_alarm_name}
        ...                AND    should be equal as strings    ${alarm_info[${i}]['Fault ID']}      ${target_fault_id}
        ...                AND    should be equal as strings    ${alarm_info[${i}]['Alarm ID']}      ${target_alarm_id}
        ...                AND    should contain                ${alarm_info[${i}]['${alarm_object}']}    ${target_alarm_object}
        run keyword if    ${res}    exit for loop
    END
    run keyword if  not ${res}    fail    Alarm ${target_alarm_id} not found!

KW.CheckAlaram_For_Case016
    [Documentation]
    ...    Scenario1: param IS_COmmon_Build=true alarm=true, shall only raise FID=61524 and FID=61652 in SMOD-1
    ...    Scenario2: param IS_COmmon_Build=true alarm=false, shall clear FID=61524 and FID=61652
    ...    Scenario3: param IS_COmmon_Build=false alarm=true, shall raise FID=61524 and FID=61652 in SMOD_R-1 and SMOD_R-2
    ...    Scenario4: param IS_COmmon_Build=false alarm=false, shall clear FID=61524 and FID=61652
    [Arguments]  ${alarm}=active
    run keyword if    '${IS_COmmon_Build}'=='true'    run keywords
    ...    set test variable   ${object1}    SMOD-1
    ...    AND    set test variable   ${object2}    SMOD-2
    ...    ELSE    run keywords
    ...    set test variable   ${object1}    SMOD_R-1
    ...    AND    set test variable   ${object2}    SMOD_R-2
    ${res1}    set variable   true
    ${res2}    set variable   true
    ${res3}    set variable   true
    ${res4}    set variable   true
    ${res1}    Run Keyword And Return Status    KW.Check_Alarm_from_Active_Alarms     target_alarm_id=7220
    ...                                         target_fault_id=61524
    ...                                         target_alarm_name=SSH enabled
    ...                                         target_alarm_object=${object1}

    ${res2}    Run Keyword And Return Status    KW.Check_Alarm_from_Active_Alarms     target_alarm_id=7220
    ...                                         target_fault_id=61652
    ...                                         target_alarm_name=R&D Service Port enabled
    ...                                         target_alarm_object=${object1}
    run keyword if   '${alarm}'=='active'
    ...    should be true    ${res1}==${res2}==${True}
    ...    ELSE    should be true    ${res1}==${res2}==${False}

    ${res3}    Run Keyword And Return Status    KW.Check_Alarm_from_Active_Alarms     target_alarm_id=7220
    ...                                  target_fault_id=61524
    ...                                  target_alarm_name=SSH enabled
    ...                                  target_alarm_object=${object2}
    ${res4}    Run Keyword And Return Status    KW.Check_Alarm_from_Active_Alarms     target_alarm_id=7220
    ...                                   target_fault_id=61652
    ...                                   target_alarm_name=R&D Service Port enabled
    ...                                   target_alarm_object=${object2}
    run keyword if   '${alarm}'=='active' and '${IS_COmmon_Build}'!='true'
    ...    should be true    ${res3}==${res4}==${True}
    ...    ELSE IF  '${alarm}'=='deactive' and '${IS_COmmon_Build}'!='true'
    ...    should be true    ${res3}==${res4}==${False}
    ...    ELSE IF  '${alarm}'=='active' and '${IS_COmmon_Build}'=='true'
    ...    should be true    ${res3}==${res4}==${False}
    ...    ELSE IF  '${alarm}'=='deactive' and '${IS_COmmon_Build}'=='true'
    ...    should be true    ${res3}==${res4}==${False}

KW.CheckAlarmObject
    [Arguments]  ${alarm_object}  ${role}
    ${smod_index}  Get Substring  ${alarm_object}  -1
    COAM_WebEM.Login    version=${sbts_stream}
    ${smod_info}  selenium_coam.get_hw_parameters  hw_type=SMOD  index=${smod_index}
    COAM_WebEM.Logout
    run keyword if    '${IS_COmmon_Build}'=='true'
    ...   Should Be Equal As Strings  ${smod_info["Runtime parameters"]["Active Role"]}  ${role}

    return from keyword if     '${IS_COmmon_Build}'=='true'

    ${smod_runtime_object}  Get Substring  ${alarm_object}  -8
    COAM_Admin.Login
    ${hw_info}  coam.get_detected_hw_info  connection=COAM
    COAM_Admin.Logout  connection=COAM

    ${smod_num}  get length  ${hw_info["systemModules"]}
    FOR  ${i}  IN RANGE  ${smod_num}
		${res}  run keyword and return status  Should Contain  ${hw_info["systemModules"][${i}]["id"]["runtime"]}
		...                                                    ${smod_runtime_object}
		run keyword if  ${res}  run keywords
		...                     set test variable  ${conf_alarm_object}  ${hw_info["systemModules"][${i}]["id"]["configuration"]}
		...                     AND  exit for loop
	END
	run keyword if  not ${res}  fail

    ${smod_conf_object}  Get Substring  ${conf_alarm_object}  -6
    ${smod_index}  Get Substring  ${smod_conf_object}  -1

    COAM_WebEM.Login    version=${sbts_stream}
    ${smod_info}  selenium_coam.get_hw_parameters  hw_type=SMOD  index=${smod_index}
    Should Be Equal As Strings  ${smod_info["Runtime parameters"]["Active Role"]}  ${role}
    COAM_WebEM.Logout

KW.Check_Fault_from_Active_Alarms
    [Arguments]  ${target_fault_id}
    COAM_WebEM.Login    version=${sbts_stream}
    ${alarm_info}    selenium_coam.get_active_alarm_info  alarm_filter=${target_fault_id}
    log  ${alarm_info}
    COAM_WebEM.Logout
    should not be empty    ${alarm_info}
    #run keyword if  '${role}' != 'None'
    #...    KW.CheckAlarmObject   alarm_object=${alarm_info[0]['${alarm_object}']}  role=${role}

KW.CheckResetBBModStatus
    [Documentation]  Check the status of the reset BBMod
    [Arguments]  ${bbModNum}  ${Operational_State}
    FOR  ${i}  IN RANGE  ${bbModNum}
        ${bbmode_info}    selenium_coam.get_abil_info
        ...               abil_index=${CASE_INPUT_5GC000829["829_A_009"]["BBMODs_Reset"][${i}]["index"]}
        Should Be Equal As Strings    ${bbmode_info["Status"]["Operational state"]}    ${Operational_State}    ignore_case=${True}
#        run keyword if  ${is_master}==${False}
#        ...    Should Be Equal As Strings    ${bbmode_info["Status"]["Availability status"]}    ${Availability_Status}
#        ...    ignore_case=${True}
    END

KW.CheckRuStatus
    [Arguments]  ${ruNum}  ${Operational_State}  ${operate}
    run keyword if    '${operate}'=='reset'
    ...       set test variable    ${key}    RMODs_Reset

    run keyword if    '${operate}'=='lock'
    ...       set test variable    ${key}    RMODs_LockAndUnlock

    FOR  ${i}  IN RANGE  ${ruNum}
        ${rmode_info}    selenium_coam.get_ru_info  ru_index=${CASE_INPUT_5GC000829["829_A_009"]['${key}'][${i}]["index"]}
        Should Be Equal As Strings    ${rmode_info["Status"]["Operational state"]}    ${Operational_State}    ignore_case=${True}
#        run keyword if  ${is_master}==${False}
#        ...    Should Be Equal As Strings     ${rmode_info["Status"]["Availability status"]}    ${Availability_Status}
#        ...    ignore_case=${True}
    END

KW.CheckRuStatusOfResetBBMod
    [Arguments]  ${Operational_State}  ${bbModNum}
    FOR  ${i}  IN RANGE  ${bbModNum}
        KW.CheckRuStatusOfCertainBBMod  bbmod=${CASE_INPUT_5GC000829["829_A_009"]["BBMODs_Reset"][${i}]}
        ...                             Operational_State=${Operational_State}
    END

KW.CheckRuStatusOfCertainBBMod
    [Arguments]  ${Operational_State}  ${bbmod}
    ${ruNnm}  get length  ${bbmod["Rus"]}
    FOR  ${i}  IN RANGE  ${ruNnm}
        ${rmode_info}    selenium_coam.get_ru_info  ru_index=${bbmod["Rus"][${i}]["index"]}
        Should Be Equal As Strings    ${rmode_info["Status"]["Operational state"]}    ${Operational_State}    ignore_case=${True}
#        run keyword if  ${is_master}==${False}
#        ...    Should Be Equal As Strings    ${rmode_info["Status"]["Availability status"]}    ${Availability_Status}
#        ...    ignore_case=${True}
    END

KW.GetCellNum
    COAM_WebEM.Login    version=${sbts_stream}
    ${cellNum}   selenium_coam.get_number_of_cells
    COAM_WebEM.Logout
    [Return]    ${cellNum}

KW.CheckAllCellStatus
    [Arguments]  ${Operational_State}=Enabled
    ${cellNum}   KW.GetCellNum
    COAM_WebEM.Login    version=${sbts_stream}
    FOR    ${index}    IN RANGE    ${cellNum}
        ${index}    evaluate    ${index}+${1}
        KW.checkCertainCELLStatus    ${index}    Operational_State=${Operational_State}
    END
    COAM_WebEM.Logout

KW.CheckCellStatusOfPrimaryCore
    [Arguments]  ${Operational_State}
    COAM_WebEM.Login    version=${sbts_stream}
    ${cellNum}  get length  ${CASE_INPUT_5GC000829["cellIndexOfPrimary"]}
    FOR  ${i}  IN RANGE  ${cellNum}
        KW.checkCertainCELLStatus  index=${CASE_INPUT_5GC000829["cellIndexOfPrimary"][${i}]}
        ...                        Operational_State=${Operational_State}
    END
    COAM_WebEM.Logout

KW.CheckCellStatusOfSecondaryCore
    [Arguments]  ${Operational_State}
    COAM_WebEM.Login    version=${sbts_stream}
    ${cellNum}  get length  ${CASE_INPUT_5GC000829["cellIndexOfSecondary"]}
    FOR  ${i}  IN RANGE  ${cellNum}
        KW.checkCertainCELLStatus  index=${CASE_INPUT_5GC000829["cellIndexOfSecondary"][${i}]}
        ...                        Operational_State=${Operational_State}
    END
    COAM_WebEM.Logout

KW.CheckLockUnlockCellStatus
   [Arguments]  ${Operational_State}  ${cellNum}
   FOR  ${i}  IN RANGE  ${cellNum}
      KW.checkCertainCELLStatus  index=${CASE_INPUT_5GC000829["829_A_009"]["CELLs_LockAndUnlock"][${i}]["index"]}
      ...                        Operational_State=${Operational_State}
   END

KW.CheckCellStatus
    [Arguments]  ${Operational_State}  ${ruNum}  ${operate}
    run keyword if    '${operate}'=='reset'
    ...       set test variable    ${key}    RMODs_Reset
    run keyword if    '${operate}'=='lock'
    ...       set test variable    ${key}    RMODs_LockAndUnlock

    FOR  ${i}  IN RANGE  ${ruNum}
        KW.CheckCellStatusOfCertainRu  Ru=${CASE_INPUT_5GC000829["829_A_009"]["${key}"][${i}]}
        ...                               Operational_State=${Operational_State}
    END

KW.checkCellStatusOfResetBBMod
    [Arguments]  ${Operational_State}  ${bbModNum}
    FOR  ${i}  IN RANGE  ${bbModNum}
        KW.CheckCellStatusOfCertainBBMod  bbmod=${CASE_INPUT_5GC000829["829_A_009"]["BBMODs_Reset"][${i}]}
        ...                               Operational_State=${Operational_State}
    END

KW.CheckCellStatusOfCertainBBMod
   [Arguments]  ${Operational_State}  ${bbmod}
   ${ruNnm}  get length  ${bbmod["Rus"]}
   FOR  ${i}  IN RANGE  ${ruNnm}
      KW.CheckCellStatusOfCertainRu  Ru=${bbmod["Rus"][${i}]}
      ...               Operational_State=${Operational_State}
   END

KW.CheckCellStatusOfCertainRu
    [Arguments]  ${Operational_State}  ${Ru}
    ${cellNum}  get length  ${Ru["Cells"]}
    FOR  ${i}  IN RANGE  ${cellNum}
        KW.checkCertainCELLStatus  index=${Ru["Cells"][${i}]["index"]}
        ...               Operational_State=${Operational_State}
    END

KW.checkCertainCELLStatus
    [Documentation]  check the status of certain CELL
    [Arguments]  ${index}  ${Operational_State}
    ${cell_info}    selenium_coam.get_cell_info  cell_idx=${index}
    Should Be Equal As Strings    ${cell_info["Status"]["Operational state"]}    ${Operational_State}    ignore_case=${True}
#    run keyword if  ${is_master}==${False}
#    ...    Should Be Equal As Strings    ${cell_info["Status"]["Availability status"]}    ${Availability_Status}
#    ...    ignore_case=${True}

KW.GetHWNumFromInit
    [Arguments]    ${HW_Type}
    ${HW_num}    Run keyword if    '${HW_Type}'=='ASIK'
    ...   KW.GetCommonUnitsNum
    ...   ELSE IF     '${HW_Type}'=='ABIL'      KW.GetCapacityUnitsNum
    ...   ELSE    Fail    Unknown HW type !!!

    [Return]   ${HW_num}

KW.GetCommonUnitsNum
    ${HW_num}=   Get Length   ${tl.gnbs[0].dus[0].airscale.common_units}
    log     Number of common units is ${HW_num}
    [Return]     ${HW_num}

KW.GetCapacityUnitsNum
    Set test variable   ${HW_num}    ${0}
    ${CommonUnits_num}=   Get Length   ${tl.gnbs[0].dus[0].airscale.common_units}
    FOR  ${i}    IN RANGE    ${CommonUnits_num}
          ${temp}  Get Length  ${tl.gnbs[0].dus[0].airscale.common_units[${i}].capacity_units}
          ${HW_num}  Evaluate  ${HW_num} + ${temp}
    END
    log      Number of capacity units is ${HW_num}
    [Return]     ${HW_num}

KW.GetHWNumFromWebInfo
    [Arguments]    ${HW_type}
    ${HW_Num_From_Web_Info}     Run Keyword if    '${HW_Type}'=='ASIK'
    ...   KW.GetSMNumFromWebInfo
    ...   ELSE IF     '${HW_Type}'=='ABIL'     KW.GetBBMNumFromWebInfo
    ...   ELSE      Fail  Unknown HW Type !!!
    [Return]     ${HW_Num_From_Web_Info}

KW.GetSMNumFromWebInfo
    Set test variable    ${WEBUI_IP}    ${LMP_Primary}
    ${BTSInfo}     COAM_Admin.GetBTSInfo
    ${SM_num_from_web}    Get Length   ${BTSInfo['systemModules']}
    log to console   ${SM_num_from_web}
    [Return]     ${SM_num_from_web}


KW.GetBBMNumFromWebInfo
    Set test variable    ${WEBUI_IP}    ${LMP_Primary}
    ${BTSInfo}     COAM_Admin.GetBTSInfo
    ${BBM_num_from_web}    Get Length   ${BTSInfo['basebandModules']}
    [Return]     ${BBM_num_from_web}

KW.CheckGNBIsDualOrSingle
    ${status}    ssh.Execute    command=ping 192.168.255.119 -c 5    connection=tmpConn_Primary
    ${result}    Run Keyword and Return Status    Should Contain    ${status}      64 bytes from 192.168.255.119: icmp_seq=5
    Run Keyword If     ${result}    Set test variable    ${mode}    Dualcore
    ...    ELSE    Set test variable    ${mode}    Singlecore
    [Return]    ${mode}

KW.CheckgNBCoreMode
    ${ret}  Run Keyword and Return Status  ssh.Connect to    hostname=${ASIK_IP}    username=${ASIK_username}
    ...                                    password=${ASIK_password}    alias=tmpConn_Primary

    ${mode}    Run Keyword If     ${ret}    KW.CheckGNBIsDualOrSingle
    ...    ELSE    Set Variable    uncommission
    run keyword and ignore error    ssh.disconnect    connection=tmpConn_Primary
    [Return]    ${mode}

KW.UnCommisionAirScale
    [Arguments]  ${IP}
    Set test variable   ${WEBUI_URL}    https://${IP}
    COAM_WebEM.Login    version=${sbts_stream}
    selenium_coam.configuration_reset
    Run Keyword And Return Status    COAM_WebEM.Logout

KW.CommissionOnPrimaryCore
    [Arguments]    ${scfPath}    ${gNBCoreMode}
    Run Keyword If    '${gNBCoreMode}'=='dual'    Set Test Variable    ${button}    Start sync
    ...    ELSE IF    '${gNBCoreMode}'=='single'    Set Test Variable    ${button}    close
    wait until keyword succeeds  20min  3min  COAM_WebEM.LoginWithSync  url=${LMP_Primary_URL}  button=${button}    version=${sbts_stream}
     Set test variable    ${version}    ${AF_PATH}
    run keyword if    ${version.count('SBTS')}>${0}    run keywords
    ...    selenium_coam.continue_after_plug_and_play_modal_appear
    ...    AND  selenium_coam.load_commissioning_file_and_check_load_status    file_path=${scfPath}
    ...    AND  selenium_coam.validate_plan
    ...    AND  selenium_coam.activate_plan    activate_plan_despite_errors=True
    ...    ELSE    run keywords
    ...    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${scfPath}
    ...    AND  selenium_coam.validate_plan
    ...    AND  selenium_coam.activate_plan    activate_plan_despite_errors=True
    Run Keyword And Return Status    COAM_WebEM.Logout
    sleep    8min
    Wait Until Keyword Succeeds    20min    1min    COAM_Admin.CheckAllCellsOnair    type=both    bts_host=192.168.255.129
#    wait until keyword succeeds    20min    10s    COAM_Admin.CheckAllCellsOnair     type=lte

KW.CommissionOnSecondaryCore
    @{files}    Create List    ${Single_core_secondary_base_scf}    ${CURDIR}/TC_Execute_On_Remote_UTE.robot
    KW.UploadFileAndExecuteCaseOnRemoteUTE      caseTag=Conmission    files=@{files}

KW.CommissionFromSingleCoreToDualCore
    [Documentation]   Step1: Uncommision left and right airscale
    ...               Step2: Login to Left gNB to select sync botton
    ...               Step3: Commission Dual Core scf file
    ...               Step4: Wait until cell on air

    KW.UnCommisionAirScale    IP=${LMP_Primary}
    KW.UploadFileAndExecuteCaseOnRemoteUTE    caseTag=Unconmission
    KW.CommissionOnPrimaryCore    gNBCoreMode=dual    scfPath=${Dula_core_base_scf}

KW.CommissionFromDualCoreToSingleCore
    [Documentation]   Step1: Uncommision dual core
    ...               Step2: Login to Left gNB to select unsync botton
    ...               Step3: Login to Left gNB to commision left scf
    ...               Step4: Login to right gNB to commision right scf
    ...               Step5: Wait until cell on air

    KW.UnCommisionAirScale     IP=${WEBUI_IP}
    KW.CommissionOnPrimaryCore    gNBCoreMode=single    scfPath=${Single_core_primary_base_scf}
    KW.CommissionOnSecondaryCore

KW.PreparegNBTODualCore
    ${gNBMode}    KW.CheckgNBCoreMode
    Run keyword if     '${gNBMode}'=='Dualcore'   log to console     gNB is already in Dual Core Mode
    ...      ELSE IF   '${gNBMode}'=='uncommission'    KW.CommissionOnPrimaryCore    gNBCoreMode=dual    scfPath=${Dula_core_base_scf}
    ...      ELSE IF   '${gNBMode}'=='Singlecore'    KW.CommissionFromSingleCoreToDualCore

KW.PreparegNBTOSingleCore
    ${gNBMode}    KW.CheckgNBCoreMode
    Run keyword if      '${gNBMode}'=='Singlecore'   log to console     gNB is already in Single Core Mode
    ...      ELSE IF    '${gNBMode}'=='uncommission'    Run Keywords
    ...                  KW.CommissionOnPrimaryCore    gNBCoreMode=single    scfPath=${Single_core_primary_base_scf}
    ...                  AND  KW.CommissionOnSecondaryCore
    ...      ELSE IF    '${gNBMode}'=='Dualcore'    KW.CommissionFromDualCoreToSingleCore

KW.PrepareOneSingleCoregNB
    [Documentation]   Purpose: to make one core as single-core gnb, the other as uncommissioned.
    ...  based on the presumption that the env is alway dualcore after one case finished running.
    [Arguments]      ${position}=left
    KW.UnCommisionAirScale  IP=${WEBUI_IP}
    gNB.Activate_SBTS_Package_After_Configuration_Reset    ip_address=${WEBUI_IP}
    KW.UploadFileAndExecuteCaseOnRemoteUTE      caseTag=Upgrade2ndcore
    Run keyword if    "${position}"=="left"
    ...       KW.CommissionOnPrimaryCore   gNBCoreMode=single   scfPath=${Single_core_primary_base_scf}
    ...   ELSE IF   "${position}"=="right"
    ...       KW.CommissionOnSecondaryCore

KW.PrepareBothCoretoSingleCore
    [Documentation]   Purpose: to make both core as single-core gnb, the other as uncommissioned.
    ...  based on the presumption that the env is alway dualcore after one case finished running.
    KW.PrepareOneSingleCoregNB
    KW.PrepareOneSingleCoregNB    position=right

KW.MigrationFromSingleCoreToDualCore
    [Documentation]   Step1: Uncommision left and right airscale
    [Arguments]  ${file_path}=${Dula_core_base_scf}
    COAM_WebEM.Login    version=${sbts_stream}
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${file_path}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    Run Keyword And Return Status    COAM_WebEM.Logout

gNB.Activate_SBTS_Package_After_Configuration_Reset
    [Arguments]    ${ip_address}   ${port}=443    ${username}=Nemuadmin   ${password}=nemuuser
    ...    ${auto_discover}=True    ${secure}=True    ${name}=default
    wait until keyword succeeds     10min    30s     fdswrc.connect to    ip_address=${ip_address}   port=${port}    username=${username}
    ...    password=${password}    auto_discover=${auto_discover}    secure=${secure}    name=${name}
    ${activeslot_id}    fdswrc.get_active_sw_partition
    ${reset_option}    fdswrc.get_available_reset_options    slot_id=${activeslot_id}
    fdswrc.software_rollback    sw_slot_id=${activeslot_id}    reset_type=${reset_option[3]}
    sleep    180s
    wait until keyword succeeds     10min    30s    gNB.PingOAM    IP=${ip_address}

#----------------------------------------Commission and UnCommission end------------------------------------------------

#-------------------------------------------Software Update Begin-------------------------------------------------------

KW.Download_And_Update_Package_Of_Site
    [Documentation]    the input value should be False or Ture
    [Arguments]    ${upgrade_package_path}
    COAM_WebEM.Login    version=${sbts_stream}
    ${result}    selenium_coam.load_software_package_from_local_drive    ${upgrade_package_path}
    should be equal      ${result}    software package load success
    selenium_coam.software_update     is_activate=${True}    start_enable_timeout=3600
    wait until keyword succeeds    50min    30s    KW.Check_SW_Download_Progress_finished
    sleep    300s
    #Run Keyword And Ignore Error    Wait until keyword succeeds    20min    10s    gNB.CheckgNBReset
    Run Keyword And Ignore Error    COAM_WebEM.Logout

KW.Get_gNB_Active_SW_Version
    [Arguments]   ${connection}=COAM
    wait until keyword succeeds   3x   1min    COAM_Admin.Login
    ${sw_info}   coam.get_software_info   connection=${connection}   timeout=10
    ${active_sw_version}   Run Keyword If   "${sw_info['Active SW version']}"!="${None}" and "${sw_info['Active SW version']}"!=""
    ...   COAM_Admin.Transfer SW Version   ${sw_info['Active SW version']}
    log to console       get gNB SW version completed
    COAM_Admin.Logout
    [Return]   ${active_sw_version}

KW.Get_gNB_Passive_SW_Version
    [Arguments]   ${connection}=COAM
    wait until keyword succeeds   3x   1min    COAM_Admin.Login
    ${sw_info}   coam.get_software_info   connection=${connection}   timeout=10
    ${passive_sw_version}   Run Keyword If   "${sw_info['Passive SW version']}"!="${None}" and "${sw_info['Passive SW version']}"!=""
    ...   COAM_Admin.Transfer SW Version   ${sw_info['Passive SW version']}
    log to console       get gNB passive SW version completed
    COAM_Admin.Logout
    [Return]   ${passive_sw_version}

KW.GetCorrectPackageName
    [Arguments]    ${build_version}
    ${prefix}   ${stream}    ${mid}   ${last}   Split String From Right    string=${build_version}   separator=_    max_split=3
    ${version}    set variable if    '${stream}'=='9999'  SBTS00_ENB_9999_${mid}_${last}    ${build_version}
    [Return]     ${version}

KW.Software_Updat_Download_CB_Package
# common load package provided different hash algorithm: SHA256, rather than md5 for 5G build.  to be updated later.
#  Hash value is displayed on the wft page, instead of a downloadable file.
    [Arguments]    ${build_version}
    ${version}    KW.GetCorrectPackageName    build_version=${build_version}
    ${upgrade_package_path}    SoftwareUpdate.DownloadPackageFromWFT       build_version=${version}
    [Return]       ${upgrade_package_path}

KW.Check_SW_Download_Progress_finished
    ${result}    selenium_coam.check_software_update_progress
    log to console   ${result}
#    should be equal    &{result}[status]    Download completed
    ${res}    Basic.CheckContainString    substring=Activating software...    string=${result}[status]
    return from keyword if    '${res}'=='true'    true
    ${res}    Basic.CheckContainString    substring=Activation completed      string=${result}[status]
    return from keyword if    '${res}'=='true'    true
    ${res}    Basic.CheckContainString    substring=Activation completed, require unit reset    string=${result}[status]
    return from keyword if    '${res}'=='true'    true
    ${res}    Basic.CheckContainString    substring=Site resetting    string=${result}[status]
    return from keyword if    '${res}'=='true'    true
    ${res}    Basic.CheckContainString    substring=Download failed    string=${result}[status]
    return from keyword if    '${res}'=='true'    false
    Fail    need more check

KW.SW_Download_Upgrade_Delete
   [Arguments]    ${target_version}       ${uteIP}=${RIGHT_UTE_IP}
   ${package_path}   KW.Software_Updat_Download_CB_Package    build_version=${target_version}
   KW.Download_And_Update_Package_Of_Site      upgrade_package_path=${package_path}
   #wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
   #Conn.ConnectWithTimeout  alias=${ALIAS_ASIK}
   #Conn.Execute  cmd=rm -rf ${package_path}   alias=${ALIAS_ASIK}
   #Conn.Disconnect  alias=${ALIAS_ASIK}
   ssh.Connect to    hostname=${uteIP}    username=${UTE_USERNAME}    password=${UTE_PASSWORD}    alias=tmpConn_UTE
   ${result}    ssh.Execute    command=rm -rf ${package_path}    connection=tmpConn_UTE
   ssh.disconnect    connection=tmpConn_UTE
   [Return]    ${result}

KW.GetAndCheckAlarm
    [Arguments]    ${add_whitelist}=False    ${6450check}=False
    log    ${add_whitelist}
    @{Fault_whitelist_com}    Create list    4655   4654   61524   61652   4459   4681    4592   61649   7312
    ${Fault_whitelist}=   Run Keyword if   "${add_whitelist}" != "False"
         ...       Combine Lists   ${Fault_whitelist_com}  ${add_whitelist}
         ...       ELSE       set variable  ${Fault_whitelist_com}
    COAM_WebEM.Login
    log   ${Fault_whitelist}
    ${active_alarm}    selenium_coam.get_active_alarm_info
    log    ${active_alarm}
    ${history_alarm}    selenium_coam.get_history_alarm_info
    log    ${history_alarm}
    ${fault_id_list}    create list
    ${unexpect_fault}    create list
    FOR    ${item}    IN    @{active_alarm}
         ${fault_id}    get from dictionary    ${item}    Fault ID
         ${object}    get from dictionary    ${item}    Configuration alarming object
         Run Keyword if   '${fault_id}' == '6450' and '${6450check}' == 'True'
         ...    Should Contain     ${object}    SMOD-2
         ...    ELSE    append to list    ${fault_id_list}    ${fault_id}
    END
    FOR    ${item}    IN    @{history_alarm}
         ${fault_id}    get from dictionary    ${item}    Fault ID
         ${object}    get from dictionary    ${item}    Configuration alarming object
         Run Keyword if   '${fault_id}' == '6450' and '${6450check}' == 'True'
         ...    Should Contain     ${object}    SMOD-2
         ...    ELSE    append to list    ${fault_id_list}    ${fault_id}
    END
    log    ${fault_id_list}
    ${length}    Get length     ${fault_id_list}
    FOR    ${i}    IN RANGE    ${length}
        ${result}=    Run Keyword And Return Status    list should contain value      ${Fault_whitelist}    ${fault_id_list[${i}]}
        Run Keyword if   '${result}' == 'False'
        ...   append to list    ${unexpect_fault}    ${fault_id_list[${i}]}
    END
    log    ${unexpect_fault}
    ${alarm_result}=    run keyword and return status     should be empty    ${unexpect_fault}
    COAM_WebEM.Logout
    [Return]    ${alarm_result}

KW.SW_Download_Remove_TargetBDfile_update_fail_Delete
   [Arguments]    ${target_version}
   ${package_path}   KW.Software_Updat_Download_CB_Package    build_version=${target_version}
   Run     unzip -o ${package_path} -d /tmp
   Run     ls -ltr /tmp/bts_sw/TargetBD*.xml
   Run     rm -rf /tmp/bts_sw/TargetBD*.xml
   Run     rm -rf ${package_path}
   Run     zip -r ${package_path} /tmp/bts_sw
   Remove Directory     /tmp/bts_sw   recursive=True
   #KW.Download_And_Update_Package_Of_Site      upgrade_package_path=${package_path}
   COAM_WebEM.Login    version=${sbts_stream}
   ${result}    selenium_coam.load_software_package_from_local_drive    ${package_path}
   should not be equal      ${result}    software package load success
   Run     rm -rf ${package_path}
   [Return]    ${result}

KW.SW_Download_and_Cancel
   [Arguments]    ${target_version}
   ${package_path}   KW.Software_Updat_Download_CB_Package    build_version=${target_version}
   COAM_WebEM.Login    version=${sbts_stream}
   ${result}    selenium_coam.load_software_package_from_local_drive    ${package_path}
   should be equal      ${result}    software package load success
   selenium_coam.software_update     is_activate=${False}   timeout=1
#   sleep    15s
   wait until keyword succeeds    10min    3s    selenium_coam.cancel_software_update
   wait until keyword succeeds    10min    30s   KW.Check_Cancel_Software_Update_Progress
   Run     rm -rf ${package_path}
   [Return]    ${result}

KW.Check_Cancel_Software_Update_Progress
    ${result}    selenium_coam.check_software_update_progress
    should be equal    ${result}[status]    Software download canceled.

KW.Check_SW_Download_Progress
    [Arguments]
    ${result}    selenium_coam.check_software_update_progress
    log to console   \nCheck software progress after Download SW Build to gNB: ${result}[percentage]
    should contain any   ${result}[percentage]    completed   100%

KW.check secondarycore after fallback
   ${res}    run keyword and ignore error    KW.UploadFileAndExecuteCaseOnRemoteUTE      caseTag=CheckFile
   Run Keyword If   '${res[0]}'=='FAIL'   Fail    secondary core collect snapshot file failed

KW.Make L3call with multi PDU
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${UE_TYPE}
    ...           ${check_throughput_dl}=10          ${check_throughput_ul}=5
    ...           ${check_avg_percent}=0.95    ${min_percent}=0.85
    gNB.Connect
    Wireshark.StartCaptureLogFromContainer    filename=cpiflog_752multiPDU.pcap    nodename=CPIF
    Start Prepare UE    ue_index=${ue_index}    ue_type=${UE_TYPE}
    Start UE Attach    ue_index=${ue_index}    ue_alias=UE_${ue_index}
    Create Multi PDU Session    ue_index=${ue_index}
    #spark.get_pdu_ip_by_AT    id=2
    Start L3 Traffic    ue_index=${ue_index}    ue_type=${UE_TYPE}
    log to console    CHECK THROUGHPUT
    process.check_Bi_throughput    ue_type=${UE_TYPE}     ue_index=${ue_index}
    ...    ultarget_throughput=${check_throughput_ul}    dltarget_throughput=${check_throughput_dl}
    ...    target_avg_percent=${check_avg_percent}   min_percent=${min_percent}
    log to console    CHECK THROUGHPUT START DATA TRANSFER success
    Stop L3 Traffic    ue_index=${ue_index}    ue_type=${UE_TYPE}
    Log To Console    INFO:-- start to release PDU 2 --
    spark.release_pdu_session    ue_alias=UE_${ue_index}    id=2
    Start UE Detach
    Wireshark.StopCapturinglogFromContainer    nodename=CPIF
    ${conn}    gNB.GetSystemModuleType    alias=${ALIAS_ASIK}
    Wireshark.DownloadLogToUTE                 log_dir=/tmp/node_CPIF00/tmp    filename=cpiflog_752multiPDU.pcap
    ...                                        connection=${conn}

KW.Check_FDSW_Alarms
    [Arguments]    ${ip_address}=192.168.255.129   ${port}=443    ${username}=Nemuadmin   ${password}=nemuuser
    ...    ${auto_discover}=True    ${secure}=True    ${name}=default
    @{Fault_whitelist}    Create list    61648      4405
    log     ${Fault_whitelist}
    wait until keyword succeeds     10min    30s     fdswrc.connect to    ip_address=${ip_address}   port=${port}    username=${username}
    ...    password=${password}    auto_discover=${auto_discover}    secure=${secure}    name=${name}
    ${fdsw_alarm}    fdswrc.get_alarms
    log     ${fdsw_alarm}
    ${fault_id_list}    Create list
    ${unexpect_fault}    Create list
    FOR    ${item}    IN    @{fdsw_alarm}
         ${fault_id}    get from dictionary    ${item}    fault_id
         ${fault_id}    convert to string    ${fault_id}
         append to list    ${fault_id_list}    ${fault_id}
    END
    log    ${fault_id_list}
    ${length}    Get length     ${fault_id_list}
    FOR    ${i}    IN RANGE    ${length}
        ${result}=    Run Keyword And Return Status    list should contain value      ${Fault_whitelist}    ${fault_id_list[${i}]}
        Run Keyword if   '${result}' == 'False'
        ...   append to list    ${unexpect_fault}    ${fault_id_list[${i}]}
    END
    log    ${unexpect_fault}
    ${alarm_result}=    run keyword and return status     should be empty    ${unexpect_fault}
    Run keyword and ignore error    Teardown FDSW
    [Return]    ${alarm_result}


KW.Software_update_from_FDSW
    [Arguments]    ${ip_address}=192.168.255.129   ${port}=443    ${username}=Nemuadmin   ${password}=nemuuser
    ...    ${auto_discover}=True    ${secure}=True    ${name}=default    ${sw_pkg_path}=123
    wait until keyword succeeds     10min    30s     fdswrc.connect to    ip_address=${ip_address}   port=${port}    username=${username}
    ...    password=${password}    auto_discover=${auto_discover}    secure=${secure}    name=${name}
    ${activeslotID}    fdswrc.get_active_sw_partition
    fdswrc.software_update   sw_slot_id=${activeslotID}     sw_pkg_path=${sw_pkg_path}
    ...  timeout=1800  activate=True
    [Teardown]    Run keyword and ignore error    Teardown FDSW

Teardown FDSW
    [Arguments]  ${alias}=default
    fdswrc.teardown  connection=${alias}

KW.CommissionFromFDSWToDualCore
    [Documentation]   Step1: Uncommision left and right airscale
    [Arguments]  ${file_path}=${Dula_core_base_scf}
    wait until keyword succeeds     15min    30s    COAM_WebEM.Login    version=${sbts_stream}
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${file_path}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    Run Keyword And Return Status    COAM_WebEM.Logout

rollback site
    [Arguments]   ${connection}=COAM
    wait until keyword succeeds   3x   1min    COAM_Admin.Login
    ${sw_info}   Run Keyword And Ignore Error   coam.get_software_info   connection=${connection}   timeout=10
    log to console    ${sw_info}
    log to console     rollback site on webUI
    wait until keyword succeeds    10min    60s    COAM_WebEM.Login    version=${sbts_stream}
    selenium_coam.software_rollback
    Wait until keyword succeeds    20min    20s    gNB.CheckResetOrNot
    sleep  3min
    Wait Until Keyword Succeeds    30min    1min    COAM_Admin.CheckAllCellsOnair     type=both
    Run Keyword And Ignore Error    COAM_Admin.Logout
    wait until keyword succeeds    10min    60s    COAM_Admin.Login
    ${sw_info}   Run Keyword And Ignore Error    coam.get_software_info   connection=${connection}   timeout=10
    log to console    ${sw_info}
    COAM_Admin.Logout

gNB.CheckResetOrNot
    ${status}    Run Keyword And Return Status    gNB.PingOAMIP
    Should Be True    '${status}'=='False'

gNB.PingOAMIP
    ${result}  run   command=ping ${ASIK_IP} -c 10
    should contain    ${result}    64 bytes from ${ASIK_IP}

Selenium_Login_And_Disable_Screen_Lock
    [Arguments]    ${timeout}=${60}
#    ...            ${gnb_index}=${0}
    ...            ${url}=${WEBUI_URL}
    ...            ${username}=${WEBUI_USERNAME}
    ...            ${password}=${WEBUI_PASSWORD}
    selenium_sbts.enable_virtual_display
    selenium_sbts.login    url=${url}
    ...                    username=${username}
    ...                    password=${password}
    ...                    timeout=${timeout}
    selenium_sbts.disable_message_box
    selenium_sbts.disable_screen_lock

Selenium_Logout_And_Close_Browser
    Run Keyword And Ignore Error    selenium_sbts.logout
    Run Keyword And Ignore Error    selenium_sbts.disable_virtual_display
    Run Keyword And Ignore Error    selenium_sbts.close_browser
