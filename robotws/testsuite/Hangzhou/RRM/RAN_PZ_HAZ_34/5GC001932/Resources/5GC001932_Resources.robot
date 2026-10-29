*** Settings ***
Documentation    author: Lou Shuhui, Liu Tiffany
...               contact: shuhui.lou@nokia-sbell.com,tiffany.liu@nokia-sbell.com
...               squad group: SG_01
...               feature : 5GC001932
Resource          ../../5GC000496_C/Resources/L3Call.robot
Resource          taf/rfrl/common_resources/robot/coam_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Library                testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.gnb_alarm.AlarmWatchdog    WITH NAME    AlarmWatchdog
Library           taf.collectors.core   WITH NAME   core
Library           taf.collectors.btslog  WITH NAME   btslog
Library           ../../5GC000638/Resources/coam_close.py
#Variables         ${CFGFILE_ON_GIT}/Delta_SCF.py
#Variables         ${TLDelta_PATH_ON_GIT}TLDelta.py
Library           OperatingSystem
#Library           SeleniumLibrary

*** Variables ***
#${CFGFILE_PATH}    /home/ute/TAF/cfgfile/
#${CFGFILE_ON_GIT}           ${CFGFILE_PATH}5GC001932/
${initial_1932_SCF}    ${CFGFILE_PATH}/5GC001932/original_Configured_ALD.xml
#${TLDelta_PATH_ON_GIT}        /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/
#${GoldenSCF_ON_GIT}         /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/5G_PZ_HZ_1_SG/


${BTS_ID}                    1101
${rmod_index}                1
#@{ALLOWED_FAULT}            &{fault_61652}    &{fault_61524}
#${RU_TYPE}                  ${tl.gnbs[0].du.rus[0].radio_type.value}
${PROGRAM}                  ${None}

${WEBUI_URL}                https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_IP}                 ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}

${ASIK_LMP_IP}              ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_IP}                  ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}

${UTE_IP}                   ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}             ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}             ${tl.test_pc.default_ssh_connection_details.password}

${PB_PORT}                  5000

${PB_ASIK_IP}               ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${PB_ASIK_PORT}             ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}

${PB_5GRU_IP}               ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.addr}
${PB_5GRU_PORT}             ${tl.gnbs[0].dus[0].rus[0].pdu_port.port_no}

${MRBTS_ID}                  MRBTS-${tl.gnbs[0].instance_id}
${NRBTS_ID}                  NRBTS-${tl.gnbs[0].global_bts_id}

@{item_antFreqBand}           7112    4282    Configuration and hardware mismatch
@{item_DC_voltage}            7115    4141    DC voltage administratively disabled
@{item_HDLC_communication}    7115    4142    3GPP/AISG communication administratively disabled


##################define these variable for convenient############################
${ALIAS_ASIK}               asik                                                ##
${ALIAS_ASIK2}              asik2                                               ##
${ALIAS_ASIK_SLAVE}         asik_slave                                          ##
${ALIAS_ABIL}               abil                                                ##
${ALIAS_ABIL_SLAVE}         abil_slave                                          ##
${ALIAS_UTE}                ute                                                 ##
${ALIAS_ENBCTLPC}           ENB_PC                                              ##
${ALIAS_SHP}                SHP                                                 ##
${ALIAS_LONER}              LONER                                               ##
${ALIAS_ASP_1A}             ASP_1A                                              ##
${ALIAS_MTKPC}                MTKPC                                             ##
${ALIAS_APN1}               APN1                                                ##
${ALIAS_APN2}               APN2                                                ##
${UE_alias}                 UE_0                                                ##
${ALIAS_5GC}                5gc                                                 ##
########################END of alias Define#######################################

*** Keywords ***
TC.5GC001932_001_SiSo_ALD_HW_inventory_ALD_HW_properties_retrieval_and_visualization
    [Documentation]     Chosed for CRT
    [Tags]     CRT_TRUNK       CRT_20B       CRT_21A
#    [Setup]    Case SetUp
    [Timeout]    10 min
    ${ald_info} =    Get ALD Information via webUI   ald_index=1
    ${length_ald_PC}    Get length     ${ald_info["Product code"]}
    ${length_ald_SN}    Get length     ${ald_info["Serial number"]}
    ${length_ald_HW}    Get length     ${ald_info["HW version"]}
    ${length_ald_SW}    Get length     ${ald_info["SW version"]}
    set test variable    ${length}    5
    Should Be True    ${length_ald_PC}>=${length}
    Should Be True    ${length_ald_SN}>=${length}
    Should Be True    ${length_ald_HW}>=${length}
    Should Be True    ${length_ald_SW}>=${length}
    #Run keyword and continue on failure    Should Not Be Empty    ${ald_info["Product code"]}    msg=There is no Product code for ALD
    #Run keyword and continue on failure    Should Not Be Empty    ${ald_info["Serial number"]}    msg=There is no Serial number for ALD
    #Run keyword and continue on failure    Should Not Be Empty    ${ald_info["HW version"]}    msg=There is no HW version for ALD
    #Run keyword and continue on failure    Should Not Be Empty    ${ald_info["SW version"]}    msg=There is no SW version for ALD
#    [Teardown]  Teardown case


TC.5GC001932_003_SiSo_ALD_Configuration_Management_RAE_reading_beamforming_weight_factors
    [Documentation]      Chosed for CRT
    [Tags]     CRT_TRUNK     CRT_20B     CRT_21A
#    [Setup]    Case SetUp
    [Timeout]    10 min
    sleep    300s
    Log    ${AF_PATH}
    ${release}      String.Split String    ${AF_PATH}   _
    ${release}      set variable           ${release}[0]
    ${result}    Run Keyword And Return Status   Should Contain    ${AF_PATH}    SBTS23R3
    Run Keyword If    ${result}    Set test variable    ${horizontal}    3
    ...    ELSE    Set test variable    ${horizontal}    30
    COAM_WebEM.Login    version=${release}
    selenium_coam.update_weight_factor_file     file_path=${weight_factor_file}  timeout=40
    selenium_coam.get_beam_widths    rae_unit=ALD_R-1 (RAEU_R-1)    frequency=2575-2675   timeout=40
    selenium_coam.get_angles         rae_unit=ALD_R-1 (RAEU_R-1)    vertical=5  horizontal=${horizontal}    timeout=40
    selenium_coam.get_weight_factors   rae_unit=ALD_R-1 (RAEU_R-1)   downtilt=2   azimuth=-15    timeout=40
    COAM_WebEM.Logout
#    [Teardown]  Teardown case

TC.5GC001932_008_SiSo_ALD_FM_Antenna_Line_Device_faulty_notification_recovery_action_indication_and_visualization
    [Documentation]    5GC001932_E   &   chosed for CRT
    [Tags]    CRT_TRUNK     CRT_20B     CRT_21A
#    [Setup]    Case SetUp
    log to console    start to modify Parameters and check alarms
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
    set suite variable      ${Active_SW_version}
    ${stream}   ${subversion}    Split String   string=${Active_SW_version}   separator=_     max_split=1

    Check Alarm via Syslog
    run keyword if  '${stream}'!='SBTS26R1'    Check Alarm 4282 in Syslog
    ...   ELSE    Check Alarm 4282 via webEM
    #Check Alarm via webEM
#    [Teardown]  Teardown case

Check Alarm via Syslog
    Run Keyword And Continue On Failure    COAM.modfy parameters
    ...     DistName=${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${CASE_INPUT_5GC001932["ALD_RMOD"][0]}/RSL-1
    ...     FilterParam=DC voltage enabled   NewValue=false
    sleep  10s
    Run Keyword And Continue On Failure    COAM.modfy parameters
    ...     DistName=${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${CASE_INPUT_5GC001932["ALD_RMOD"][0]}/RSL-1
    ...     FilterParam=HDLC communication enabled   NewValue=false
    sleep  10s
    Run Keyword And Continue On Failure    COAM.modfy parameters
    ...     DistName=${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${CASE_INPUT_5GC001932["ALD_RMOD"][0]}/RSL-1
    ...     FilterParam=DC voltage enabled   NewValue=true
    sleep  10s
    Run Keyword And Continue On Failure    COAM.modfy parameters
    ...     DistName=${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${CASE_INPUT_5GC001932["ALD_RMOD"][0]}/RSL-1
    ...     FilterParam=HDLC communication enabled   NewValue=true
    sleep  10s

    AlarmWatchdog.add_allow_alarms    fault_id=4282
    Run Keyword And Continue On Failure    COAM.modfy parameters
    ...     DistName=${MRBTS_ID}/EQM-1/APEQM-1/ALD-1/RAEU-1    FilterParam=Antenna operating frequency band   NewValue=99
    sleep  10s
    Run Keyword And Continue On Failure    COAM.modfy parameters
    ...     DistName=${MRBTS_ID}/EQM-1/APEQM-1/ALD-1/RAEU-1    FilterParam=Antenna operating frequency band   NewValue=3
    AlarmWatchdog.remove_allow_alarms    fault_id=4282

    sleep  10s
    Stop BTSlogs Collection and get logs
    Check Alarms In Syslog
    #Check Alarm via webEM

Check Alarms In Syslog
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "reportAlarmNotif: faultId/subCaseId: 4141/0"|
        ...       awk '{print $7}'|head -n 1
    ${timestart}=     run    command=${cmd}
    Should Not Be Empty    ${timestart}

    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "reportAlarmNotif: faultId/subCaseId: 4142/0"|
        ...       awk '{print $7}'|head -n 1
    ${timestart}=     run    command=${cmd}
    Should Not Be Empty    ${timestart}

    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "clearAlarm (Fault: 4141/1)"|
        ...       awk '{print $7}'|head -n 1
    ${timestart}=     run    command=${cmd}
    Should Not Be Empty    ${timestart}

    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "clearAlarm (Fault: 4142/1)"|
    ...           awk '{print $7}'|head -n 1
    ${timestart}=     run    command=${cmd}
    Should Not Be Empty    ${timestart}

Check Alarm 4282 in Syslog
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "reportAlarmNotif: faultId/subCaseId: 4282/0"|
        ...       awk '{print $7}'|head -n 1
    ${timestart}=     run    command=${cmd}
    Should Not Be Empty    ${timestart}

    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "clearAlarm (Fault: 4282/3)"|
        ...       awk '{print $7}'|head -n 1
    ${timestart}=     run    command=${cmd}
    Should Not Be Empty    ${timestart}


Check Alarm via webEM
    #Run Keyword And Continue On Failure    COAM.modfy parameters and check alarms   item=${item_DC_voltage}
    #...     DistName=${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${CASE_INPUT_5GC001932["ALD_RMOD"][0]}/RSL-1
    #...     FilterParam=DC voltage enabled   NewValue=false  alarm_status=present
    #Run Keyword And Continue On Failure    COAM.modfy parameters and check alarms   item=${item_HDLC_communication}
    #...     DistName=${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${CASE_INPUT_5GC001932["ALD_RMOD"][0]}/RSL-1
    #...     FilterParam=HDLC communication enabled   NewValue=false   alarm_status=present
    #Run Keyword And Continue On Failure    COAM.modfy parameters and check alarms   item=${item_DC_voltage}
    #...     DistName=${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${CASE_INPUT_5GC001932["ALD_RMOD"][0]}/RSL-1
    #...     FilterParam=DC voltage enabled   NewValue=true    alarm_status=disapear
    #Run Keyword And Continue On Failure    COAM.modfy parameters and check alarms   item=${item_HDLC_communication}
    #...     DistName=${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${CASE_INPUT_5GC001932["ALD_RMOD"][0]}/RSL-1
    #...     FilterParam=HDLC communication enabled   NewValue=true    alarm_status=disapear

    AlarmWatchdog.add_allow_alarms    fault_id=4282
    Run Keyword And Continue On Failure    COAM.modfy parameters and check alarms   item=${item_antFreqBand}
    ...     DistName=${MRBTS_ID}/EQM-1/APEQM-1/ALD-1/RAEU-1    FilterParam=Antenna operating frequency band   NewValue=99   alarm_status=present
    sleep  10s
    Run Keyword And Continue On Failure    COAM.modfy parameters and check alarms   item=${item_antFreqBand}
    ...     DistName=${MRBTS_ID}/EQM-1/APEQM-1/ALD-1/RAEU-1    FilterParam=Antenna operating frequency band   NewValue=3    alarm_status=disapear
    AlarmWatchdog.remove_allow_alarms    fault_id=4282

Check Alarm 4282 via webEM
    AlarmWatchdog.add_allow_alarms    fault_id=4282
    Run Keyword And Continue On Failure    COAM.modfy parameters and check alarms   item=${item_antFreqBand}
    ...     DistName=${MRBTS_ID}/EQM-1/APEQM-1/ALD-1/RAEU-1    FilterParam=Antenna operating frequency band   NewValue=99   alarm_status=present
    sleep  10s
    Run Keyword And Continue On Failure    COAM.modfy parameters and check alarms   item=${item_antFreqBand}
    ...     DistName=${MRBTS_ID}/EQM-1/APEQM-1/ALD-1/RAEU-1    FilterParam=Antenna operating frequency band   NewValue=3    alarm_status=disapear
    AlarmWatchdog.remove_allow_alarms    fault_id=4282

Setup My Suite
    [Documentation]
    [Arguments]
    TestSuite.Start
    Import Variables      ${CFGFILE_PATH}TLConfiguration.py
    csn.connect_to    hostname=${UTE_IP}    username=${UTE_USERNAME}    password=${UTE_PASSWORD}    alias=connection_ute
    set suite variable   ${VM_ip}    ${CASE_INPUT_5GC001932["file_server_ip"]}
    set suite variable   ${VM_username}    ${CASE_INPUT_5GC001932["file_server_username"]}
    set suite variable   ${VM_pwd}    ${CASE_INPUT_5GC001932["file_server_password"]}
    set suite variable   ${file_path}    /home/ute/5GC001932/
    set suite variable   ${weight_factor_file}       /home/ute/5GC001932/RAE Weight file.bin
    set suite variable   ${External_Driver_ALD_file}       /home/ute/5GC001932/External_Driver_ALD_SW.zip
    #Run    scp ${VM_username}@${VM_ip}:/home/ute/5GC001932/* /home/ute/5GC001932/
    run    command=mkdir ${file_path}
    csn.send command   command=sshpass -p ${VM_pwd} scp ${VM_username}@${VM_ip}:${file_path}* ${file_path}
    ...     connection=connection_ute
    sleep   5s
    csn.Disconnect    connection=connection_ute
    Import Variables     ${file_path}/Delta_SCF.py
    Setup 1932 case suite
    gNB.SetLoggingSeverity    LoggingSeverity=debug
    ${outputfile}    gNB.GenerateTestLineSCFs
    #${outputfile}    gNB.Generate TL SCF
	#...                  GoldenSCF_PATH=${GoldenSCF_ON_GIT}/${GoldenSCF}   TLDelta_PATH=${CFGFILE_PATH}
	#...                  TestLineSCF_cell_num=${1}    cell_type=Both
	#...                  MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
	set suite variable    ${Original_CFGFILE}    ${outputfile}
    #ChangeSwcofigByFlag    flag=0x10043    value=50002
    gNB.ModifySCF    InputFile=${Original_CFGFILE}    OutputFile=${LOG_PATH}/1932_SCF.xml
    ...    MOsToAdd=${ADD_MOS_FOR_1932}
    ...    ListToAdd=${LIST_TO_ADD_FOR_1932}    ParamterToModify=${PARAMS_TO_MODIFY_1932}
    gNB.Commission    scf_file=${LOG_PATH}/1932_SCF.xml    timeout=${2400}
#    COAM_Admin.commission    scf_file=${CFGFILE_ON_GIT}/original_Configured_ALD.xml
    wait until keyword succeeds    15x    1min    gNB.VerifyOnAirViaOAMUntilReady


Setup 1932 case suite
    Create Log Directories
    set suite variable   ${OAM_TYPE}    COAM
    Conn.ResetCache


KW.CaseInit
    TestCase.Start
    Run Keyword And Ignore error   BtsLog.StartBTSlogCollection


COAM.modfy parameters and check alarms
    [Arguments]    ${item}    ${DistName}   ${FilterParam}   ${NewValue}    ${alarm_status}
    COAM_WebEM.Login
    Run Keyword And Continue On Failure     COAM_WebEM.ModifyAndActiveParameters   ${DistName}   ${FilterParam}   ${NewValue}
    log to console    Parameters modify completed
    COAM_WebEM.Logout
    sleep  30s
    ${alarm_check}    run keyword and return status    COAM.Check alarm via webui    ${item}
    Run keyword if    '${alarm_status}'=='present'     should be true    '${alarm_check}' == 'True'
    ...    ELSE IF    '${alarm_status}'=='disapeared'    should be true    '${alarm_check}' == 'false'

COAM.modfy parameters
    [Arguments]    ${DistName}   ${FilterParam}   ${NewValue}
    COAM_WebEM.Login
    Run Keyword And Continue On Failure     COAM_WebEM.ModifyAndActiveParameters   ${DistName}   ${FilterParam}   ${NewValue}
    log to console    Parameters modify completed
    COAM_WebEM.Logout
    sleep  30s

COAM.Check alarm via webui
    [Arguments]    ${item}
    Run Keyword And Continue On Failure    COAM_WebEM.Login
    ${alarm_info}    selenium_coam.get_active_alarm_info
    Set test variable    ${alarm_info}
    ${length}    Get length     ${alarm_info}
    FOR    ${i}    IN RANGE    ${length}
        Set test variable    ${i}
        ${res_check}    run keyword and return status    COAM.Check alarm    item=${item}
        ${res}=    Run Keyword And Ignore error    should be true    '${res_check}' == 'True'
        Run Keyword If    ${res} == ('PASS', None)    Exit For Loop
    END
    Run keyword if    ${res} != ('PASS', None)    Fail    alarm check fail
    Run Keyword And Continue On Failure    COAM_WebEM.Logout
    log to console    check alarms completed

COAM.Check alarm
    [Arguments]    ${item}
    ${alarm_id}   Set Variable   ${alarm_info[${i}]['Alarm ID']}
    ${fault_id}   Set Variable   ${alarm_info[${i}]['Fault ID']}
    ${alarm_name}   Set Variable   ${alarm_info[${i}]['Fault name']}
    Run Keyword And Continue On Failure    should contain   container=${Alarm ID}   item=${item[0]}
    Run Keyword And Continue On Failure    should contain   container=${fault_id}   item=${item[1]}
    Run Keyword And Continue On Failure    should contain   container=${alarm_name}   item=${item[2]}

Check fault on WebUI
    [Arguments]    ${alarm_filter}   ${Alarm_ID_CP}    ${Alarm_name_CP}    ${Fault_name_CP}
    #WEBUI Login
    @{alarm info}=    Wait Until Keyword Succeeds    1min    2s
    ...    selenium_coam.get_active_alarm_info    alarm_filter=${alarm_filter}    timeout=100
    ${fault_dic}   set variable    ${alarm info}[0]
    ${Alarm_ID}    set variable    ${fault_dic}[Alarm ID]
    ${Alarm_name}    set variable    ${fault_dic}[Alarm name]
    #${Fault_ID}    set variable    &{fault_dic}[Fault ID]
    ${Fault_name}    set variable    ${fault_dic}[Fault name]
    #${Severity}    set variable    &{fault_dic}[Severity]
    should be equal     ${Alarm_ID}     ${Alarm_ID_CP}
    should be equal     ${Alarm_name}     ${Alarm_name_CP}
    #should be equal     ${Fault_ID}     ${Fault_ID_CP}
    should be equal     ${Fault_name}     ${Fault_name_CP}
    #should be equal     ${Severity}     ${Severity_CP}
    #should be equal     ${Alarming_object}     ${Alarm_ob_CP}
COAM_WebEM.ModifyParameters
    [Arguments]    ${DistName}=MRBTS-1907/NRBTS-7/NRCELL-1    ${FilterParam}=Timer t301    ${NewValue}=600ms
    Wait Until Keyword Succeeds    3 times    30s
    ...    selenium_coam.set_parameter_value
    ...    dist_name=${DistName}    filter_param=${FilterParam}    new_value=${NewValue}

    COAM_WebEM.ValidateAndActiveParameters


check ALD Availability status
    [Arguments]   ${ALD_status}  ${ald_index}=1
    Log To Console    Info: ready to verify ALD should be ${ALD_status}...
    ${ald_info} =    Get ALD Information via webUI    ald_index=${ald_index}
    Should Be Equal As Strings    ${ald_info["Status"]["Availability status"]}    ${ALD_status}
    ...    msg=Current ALD availability_status is not online    ignore_case=${True}

RETU Should Be Online
    [Arguments]    ${retu_index}=1
    Log To Console    Info: ready to verify RETU should be online...
    ${retu_info} =    Get RETU Information via webUI    retu_index=${retu_index}
    Should Be Equal As Strings    ${retu_info["Status"]["Availability status"]}    Online
    ...    msg=Current RETU availability_status is not online    ignore_case=${True}

ALD Should Be poweroff
    [Arguments]    ${ald_index}=1
    Log To Console    Info: ready to verify ALD should be poweroff...
    ${ald_info} =    Get ALD Information via webUI    ald_index=${ald_index}
    Should Be Equal As Strings    ${ald_info["Status"]["Availability status"]}    poweroff
    ...    msg=Current ALD availability_status is not poweroff    ignore_case=${True}


check RAEU Availability status
    [Arguments]    ${RAEU_status}  ${raeu_index}=1
    ${raeu_info} =    Get RAEU Information via webUI    raeu_index=${raeu_index}
    Should Be Equal As Strings    ${raeu_info["Status"]["Availability status"]}     ${RAEU_status}
    ...    msg=Current RAEU availability_status is not online    ignore_case=${True}

RAEU Should Be poweroff
#    [Arguments]    ${ald_index}=1
    Log To Console    Info: ready to verify RAEU should be poweroff...
    ${raeu_info} =    Get RAEU Information via webUI    raeu_index=${raeu_index}
    Should Be Equal As Strings    ${raeu_info["Status"]["Availability status"]}   poweroff
    ...    msg=Current ALD availability_status is not poweroff    ignore_case=${True}

Case TearDown
    Run Keyword And Ignore Error    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    ...    file_path=${TS_CASE_LOG_PATH}
    #Run Keyword If Test Failed    COAM Save snapshot via rest api
    #run keyword and ignore error    COAM Teardown gnb connections
Get BTS Information via rest api
    [Arguments]    ${connection}=GNB_OAM
    Log to console    Info: ready to Get BTS Information
    ${bts_info} =    coam.get_bts_info    connection=${connection}
    [Return]    ${bts_info}
Get RETU Information via webUI
    [Arguments]    ${retu_index}=1
    Log to console    Info: ready to Get RETU Information
    COAM_WebEM.Login
    ${retu_info} =    selenium_coam.get_retu_info    retu_index=${retu_index}
    COAM_WebEM.Logout
    [Return]    ${retu_info}
Get RAEU Information via webUI
    [Arguments]    ${raeu_index}=1
    COAM_WebEM.Login
    ${raeu_info} =    selenium_coam.get_raeu_info    raeu_index=${raeu_index}
    COAM_WebEM.Logout
    [Return]    ${raeu_info}

Restore antFreqBand to Default Value via webUI
    [Documentation]    Author: Wang Yixiang
    &{restore_antFreqBand}    Create Dictionary    abbr=antFreqBand
    ...    dist_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1/ALD-1/RAEU-1
    ...    filter_param=Antenna operating frequency band
    ...    new_value=${pre_antFreqBand}
    @{restore_param}    Create List    ${restore_antFreqBand}
    Update parameters via webUI    parameters_to_update_via_webui=${restore_param}

Get ALD Information via webUI
    [Arguments]    ${ald_index}=1
    Log to console    Info: ready to Get ALD Information
    COAM_WebEM.Login
    ${ald_info} =    selenium_coam.get_ald_info    ald_index=${ald_index}
    COAM_WebEM.Logout
    [Return]    ${ald_info}

Get Parameter via webUI
    [Arguments]    ${dist_name}    ${abbr}    ${filter_param}
    COAM_WebEM.Login
    ${para_value} =    selenium_coam.get_parameter_value
    ...    dist_name=${dist_name}
    ...    abbr=${abbr}
    ...    filter_param=${filter_param}
    [Return]    ${para_value}
    COAM_WebEM.Logout

Update parameters via webUI
    [Arguments]      ${parameters_to_update_via_webui}
    ...    ${is_need_to_check_validation_errors}=${False}
    COAM_WebEM.Login
    @{diff_para} =    create list
    FOR  ${cur_para_to_update}  IN  @{parameters_to_update_via_webui}
        ${cur_para_value}    selenium_coam.get_parameter_value
        ...    dist_name=${cur_para_to_update['dist_name']}
        ...    abbr=${cur_para_to_update['abbr']}
        ...    filter_param=${cur_para_to_update['filter_param']}
        Run keyword if    '${cur_para_value}'=='${cur_para_to_update['new_value']}'
        ...    Log to console    current value is ${cur_para_value}, no need to update
        ...    ELSE    run keywords
        ...    selenium_coam.set_parameter_value
        ...    dist_name=${cur_para_to_update['dist_name']}
        ...    abbr=${cur_para_to_update['abbr']}
        ...    filter_param=${cur_para_to_update['filter_param']}
        ...    new_value=${cur_para_to_update['new_value']}    AND
        ...    Append to list    ${diff_para}    ${cur_para_to_update}
    END
    Run keyword if    ${diff_para}    run keywords
    ...    selenium_coam.validate_plan    AND
    ...    COAM check validation errors from webui
    ...    is_need_to_check_validation_errors=${is_need_to_check_validation_errors}    AND
    ...    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    COAM_WebEM.Logout

Check ALD Status
    [Arguments]    ${administrative_state}
    ...    ${availability_status}
    ...    ${operational_state}
    ...    ${procedural_status}
    ...    ${ald_index}=1
    Log To Console    Info: ready to check ALD status...
    ${ald_info} =    Get ALD Information via webUI    ald_index=${ald_index}
    Run keyword and continue on failure    Should Be Equal As Strings
    ...    ${ald_info["Status"]["Administrative state"]}    ${administrative_state}
    ...    msg=Current ALD administrative_state is not in ${administrative_state} status    ignore_case=${True}
    Run keyword and continue on failure    Should Be Equal As Strings
    ...    ${ald_info["Status"]["Availability status"]}    ${availability_status}
    ...    msg=Current ALD availability_status is not in ${availability_status} status    ignore_case=${True}
    Run keyword and continue on failure    Should Be Equal As Strings
    ...    ${ald_info["Status"]["Operational state"]}    ${operational_state}
    ...    msg=Current ALD operational_state is not in ${operational_state} status    ignore_case=${True}
    Run keyword and continue on failure    should contain
    ...    ${ald_info["Status"]["Procedural status"]}    ${procedural_status}
    ...    msg=Current ALD procedural_status is not in ${procedural_status} status    ignore_case=${True}

Check RAEU Status
    [Arguments]    ${administrative_state}
    ...    ${availability_status}
    ...    ${operational_state}
    ...    ${procedural_status}
    ...    ${raeu_index}=1

    Log To Console    Info: ready to check RAEU status...
    ${retu_info} =    Get RAEU Information via webUI    retu_index=${raeu_index}
    Should Be Equal As Strings    ${retu_info["Status"]["Administrative state"]}    ${administrative_state}
    ...    msg=Current RAEU administrative_state is not in ${administrative_state} status    ignore_case=${True}
    Should Be Equal As Strings    ${retu_info["Status"]["Availability status"]}    ${availability_status}
    ...    msg=Current RAEU availability_status is not in ${availability_status} status    ignore_case=${True}
    Should Be Equal As Strings    ${retu_info["Status"]["Operational state"]}    ${operational_state}
    ...    msg=Current RAEU operational_state is not in ${operational_state} status    ignore_case=${True}
    should contain    ${retu_info["Status"]["Procedural status"]}    ${procedural_status}
    ...    msg=Current RAEU procedural_status is not in ${procedural_status} status    ignore_case=${True}

Reset ALD via webUI
    [Documentation]    Description: Resrt ALD from webui
    ...    ${reset_type}: value can be software, hardware, defult to use hardware
    ...    ${ald_index}: index of ALD
    [Arguments]    ${reset_type}=hardware    ${ald_index}=1
    Log to console    Info: ready to Reset ALD
    COAM_WebEM.Login
    selenium_coam.reset_ald    reset_type=${reset_type}    ald_index=${ald_index}
    COAM_WebEM.Logout

ASIK.Connect
    [Arguments]   ${alias}=${ALIAS_ASIK}
    Run Keyword And Continue On Failure  ssh.Connect to    hostname=${ASIK_IP}
     ...    username=${ASIK_USERNAME}    password=${ASIK_PASSWORD}  alias=${alias}

ASIK.Disconnect
     [Arguments]   ${alias}=${ALIAS_ASIK}
    Run Keyword And Continue On Failure  Conn.Disconnect    ${alias}

Collect snapshot via webui
    [Arguments]
    COAM_WebEM.Login
    selenium_coam.snapshot_collection_settings    coverage=All log files     save_location=Local
    ${snapshot_file}    selenium_coam.collect_snapshot    snapshot_waiting_timeout=1200
    log    ${snapshot_file}
    COAM_WebEM.Logout
    Run Keyword And Ignore Error    run    command=cp ${snapshot_file} ${LOG_PATH}

Start BTSlogs Collection
    run keyword and ignore error    run    command=cd /tmp/btslog2 ; rm -rf TRACE_*.bin ; rm -rf SYSLOG_*.LOG
    btslog.create_btslog_collector
    ...   name=btslog
    ...   btslog_path=/home/ute/btslog/btslog
    ...   btslog_launcher_path=/home/ute/btslog/btslog_launcher
    ...   log_dir=/tmp/btslog2
    btslog.Set Global Alias     btslog
    core.setup_collectors      names=btslog
    core.start_collectors      names=btslog

Stop BTSlogs Collection and get logs
    core.teardown_collectors      names=btslog
    run    command=cd /tmp/btslog2 ; ls -al ; cat SYSLOG_*.LOG > SYSLOG_combine.LOG
    run    command=cd /tmp/btslog2 ; tar zcvf /tmp/${TEST NAME.replace(" ", "_")}_SYSLOG.tgz SYSLOG_combine.LOG
    run    command=cp /tmp/${TEST NAME.replace(" ", "_")}_SYSLOG.tgz ${LOG_PATH}

#Setup suite
#    Create Log Directories
#    #set suite variable      ${Log_PATH_Artifactory}    /root/workspace/CIT/Master/Case_Logs/
#    set suite variable   ${OAM_TYPE}    COAM
#	${outputfile}    gNB.Generate TL SCF
#	...                  GoldenSCF_PATH=${GoldenSCF_ON_GIT}/${GoldenSCF}   TLDelta_PATH=${CFGFILE_PATH}
#	...                  TestLineSCF_cell_num=${1}    cell_type=Both
#	...                  MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
#	${Original_CFGFILE_754}    Generate 754_1cell_SA    InputFile=${outputfile}
#	set suite variable    ${Original_CFGFILE_754}
#    gNB.Commission    scf_file=${Original_CFGFILE_754}    timeout=${2400}
#    Wait until keyword succeeds   30min   1min    COAM_VerifyOnAirViaFrontendAndBackend
#    Conn.ResetCache

Setup case
    run keyword and ignore error    Start BTSlogs Collection

KW.CaseDestroy
#    [Arguments]   ${connection}=COAM
    Run Keyword And Ignore Error    BtsLog.StopBTSlogCollectionandGetlog
    Run Keyword And Ignore Error    WEBUI.Backup current SCF
    log     ${TEST STATUS}
    Run Keyword If  '${TEST STATUS}' == 'FAIL'    WEBUI.Collect snapshot
    ...    ELSE    Pass Execution If    '${TEST STATUS}' == 'PASS'    Not collect snapshot logs
    #Run Keyword And Ignore Error    GNB.Clean pcap logs
    Run Keyword And Ignore Error    GNB.kill admin process
    Run Keyword And Ignore Error    run   command=killall firefox
    Conn.ResetCache
    TestCase.Stop

WEBUI.Collect snapshot
    [Arguments]
    COAM_WebEM.Login
    selenium_coam.snapshot_collection_settings    coverage=All log files     save_location=Local
    ${snapshot_file}    selenium_coam.collect_snapshot    snapshot_waiting_timeout=1200
    log    ${snapshot_file}
    COAM_WebEM.Logout
    Run Keyword And Ignore Error    run    command=cp ${snapshot_file} ${LOG_PATH}


WEBUI.Backup current SCF
    wait until keyword succeeds   3x   1min    COAM_Admin.Login
    coam.get_current_scf_file   local_dir_path=${LOG_PATH}   file_name=${TEST NAME.replace(" ", "_")}.xml   connection=COAM   timeout=10
    COAM_Admin.Logout


GNB.kill admin process
    run    command=ps xafu |grep node|grep -v grep|awk '{print $2}' | xargs kill -9

GNB.Clean pcap logs
    [Arguments]
    Conn.ConnectWithTimeout  alias=${ALIAS_ASIK}
    Conn.Execute  cmd=rm -rf /ffs/run/config/toor4nsn/2197*.pcap   alias=${ALIAS_ASIK}
    Conn.Disconnect  alias=${ALIAS_ASIK}

TestSuilt.Destroy
    TestSuite.Stop
