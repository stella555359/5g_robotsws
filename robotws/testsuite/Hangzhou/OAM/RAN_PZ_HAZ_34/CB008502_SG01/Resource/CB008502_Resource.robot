*** Settings ***
Documentation    Suite description
Resource     ../../../../RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/L3Call.robot
Resource     ../../../../OAM/RAN_PZ_HAZ_34/5GC002479/Resources/5GC002479_CP_Resource.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/btslog.robot
Variables    CaseSCFDelta.py

*** Variables ***
${WEBUI_URL}           https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}      ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}      ${tl.gnbs[0].cu.oam_http_connection_details.password}
${WEBUI_IP}            ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${ASIK_IP_Mplane}      ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${ASIK_IP}             ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_username}	   ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${ASIK_password}	   ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${MRBTS_ID}            ${tl.gnbs[0].instance_id}
${NRBTS_ID}            ${tl.gnbs[0].global_bts_id}

&{condition_ru_same}     rf-FRU6=diff

*** Keywords ***

SuiteSetup
    log to console    \n*** Coam Suite Setup***
    Run Keyword If    '${testline_name}'!='null'    UTECloud.ForceAdaptCommissionFiles
    ...    ELSE     UTECloud.AdaptCommissionFiles
    TestSuite.Start
    Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
    set suite variable      ${Active_SW_version}
    @{result}    string.split string    ${Active_SW_version}    separator=_
    ${stream}     convert to string    ${result}[-5]
    set suite variable    ${stream}
    ${gNb_CuType}   Get gNB CU type
    set suite variable      ${gNb_CuType}
    Generate suite log path
    set suite variable      ${SAVE LOG DIRECTORY}    ${SUITE_LOG_PATH}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    gNB.FormatBTSID


SuiteTearDown
    TestSuilt.Stop


CB008502 Test Setup
    log to console    \n***Coam Test Setup***
    log to console    Active_SW_version:${Active_SW_version}
    Generate test case log path
    ${time_stamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    set test variable  ${TS_CASE_LOG_PATH}    ${TS_CASE_LOG_PATH}/${time_stamp}/
    create directory   ${TS_CASE_LOG_PATH}
    Set Test Variable    ${SAVE LOG DIRECTORY}    ${TS_CASE_LOG_PATH}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ${ru_status}    Run Keyword And Return Status    COAM Check GNB RU status
    ${cell_status}    Run Keyword And Return Status    Verify all cells should be onair
    Run Keyword If    ${ru_status}==${False} or ${cell_status}==${False}    Fail    TEST
    Run Keyword And Ignore error     BtsLog.StartBTSlogCollection
    Run Keyword And Ignore Error    selenium.close_browser

CB008502 Test Teardown
    log to console    \n***Coam Test Teardown***
    Connect to gnb coam via ssl
    ${ru_status}   run keyword and ignore error   COAM Check GNB RU status
    log to console  RU status: ${ru_status}
    ${cell_status}    Run Keyword And Return Status    Verify all cells should be onair
    should be true    ${cell_status}
#    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=@{ALLOWED_FAULT}
#    should be true    ${alarm_status}
#    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
#    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
    Run Keyword And Ignore error     BtsLog.StopBTSlogCollectionandGetlog
    run keyword if test failed     Collect_snapshot_by_WEBUI
    COAM Teardown gnb connections
#    CI_interface.Common Case Teardown
    TestCase.Stop

Collect_snapshot_by_WEBUI
    [Arguments]    ${loop}=0
    COAM_WebEM.Login
    selenium_coam.snapshot_collection_settings    coverage=All log files     save_location=Local
    ${snapshot_file}    selenium_coam.collect_snapshot    snapshot_waiting_timeout=1200
    log    ${snapshot_file}
    Run Keyword And Ignore Error    COAM_WebEM.Logout
    ${filename}    set variable    ${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "").replace("[", "").replace("]", "")}
    Run Keyword And Ignore Error    run    command=mv ${snapshot_file} ${SAVE LOG DIRECTORY}/snapshot_${filename}_${loop}.zip


KW.CB008502_01_BTS_Deployment_via_Commissioning_wizard_or_SCF_load_25_eCPRI
    gNB.GenerateCaseSCF    InputFile=${CFGFILE_PATH}/SCF_SBTS00.xml    OutputFile=${LOG_PATH}/CB008502_TC1.xml
    ...               ResourceFolder=${CURDIR}
    ...               ParameterToDelete=PARAMS_TO_DELETE_8502_TC1
	...               MOsToAdd=MOs_TO_ADD_8502_TC1
    ...               ParamterToModify=PARAMS_TO_MODIFY_8502_TC1
    ...               ListParamterToModify=LIST_PARAMS_TO_MODIFY_8502_TC1
    ...               ListToAdd=LIST_TO_ADD_8502_TC1
   COAM_Admin.commission    scf_file=${LOG_PATH}/CB008502_TC1.xml
   wait until keyword succeeds   10x   2min  COAM_Admin.VerifyCellOnAir

KW.CB008502_02_BTS_Deployment_via_Commissioning_wizard_or_SCF_load_10_eCPRI
    ${SCF}    set variable if    "${stream}"=="SBTS24R2"    SCF_SBTS24R2.xml    SCF_SBTS00.xml
    gNB.GenerateCaseSCF    InputFile=${CFGFILE_PATH}/${SCF}    OutputFile=${LOG_PATH}/CB008502_TC2.xml
    ...               ResourceFolder=${CURDIR}
    ...               ParameterToDelete=PARAMS_TO_DELETE_8502_TC2
	...               MOsToAdd=MOs_TO_ADD_8502_TC2
    ...               ParamterToModify=PARAMS_TO_MODIFY_8502_TC2
    ...               ListParamterToModify=LIST_PARAMS_TO_MODIFY_8502_TC2
    ...               ListToAdd=LIST_TO_ADD_8502_TC2
   COAM_Admin.commission    scf_file=${LOG_PATH}/CB008502_TC2.xml
   wait until keyword succeeds   10x   2min  COAM_Admin.VerifyCellOnAir

KW.CB008502_04_Ethernet_mode_reconfiguration_during_BTS_runtime
    [Arguments]
    Log To Console    Step1:Check link speed
    wait until keyword succeeds   15min    10s    COAM_WebEM.Login
    ${linkSpeed_org}    selenium_coam.get_parameter_value
    ...    dist_name=${MRBTS_ID}/EQM-1/HWTOP-1/CABLINK-5    filter_param=Link speed     abbr=linkSpeed
    log to console    ${linkSpeed_org}
    set test variable      ${linkSpeed_org}

    Log To Console    step2.Change ecpri link speed to 25G if link speed is 10G,vice versa
    ${linkSpeed_new}    set variable if     '${linkSpeed_org}'=='eCpri10'   eCpri25    eCpri10
    log to console    ${linkSpeed_new}
    set test variable      ${linkSpeed_new}
    selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/EQM-1/HWTOP-1/CABLINK-5
     ...    filter_param=Link speed    node_index=${0}    new_value=${linkSpeed_new}   abbr=linkSpeed
    COAM_WebEM.ValidateAndActiveParameters    activate_plan_despite_errors=False
    run keyword and ignore error    COAM_WebEM.Logout
    wait until keyword succeeds    15min    20s     COAM_Admin.CheckAllCellsOnair

    Log To Console    Step3:Change ecpri link speed back to orignal value
    wait until keyword succeeds   5min    10s    COAM_WebEM.Login
    selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/EQM-1/HWTOP-1/CABLINK-5
    ...    filter_param=Link speed    node_index=${0}    new_value=${linkSpeed_org}   abbr=linkSpeed
    COAM_WebEM.ValidateAndActiveParameters    activate_plan_despite_errors=False
    run keyword and ignore error    COAM_WebEM.Logout
    wait until keyword succeeds    15min    20s     COAM_Admin.CheckAllCellsOnair


KW.CB008502_Change_ecpri_speed_and_protocal
     [Arguments]   ${linkspeed}=eCpri25    ${radioprotocal}=25eCPRI
     Wait Until Keyword Succeeds    2 times    30s     selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/EQM-1/HWTOP-1/CABLINK-5
     ...    filter_param=Link speed    node_index=${0}    new_value=${linkspeed}   abbr=linkSpeed
     Wait Until Keyword Succeeds    2 times    30s     selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/EQM-1/HWTOP-1/CABLINK-5
     ...    filter_param=Radio protocol type    node_index=${0}    new_value=${radioprotocal}   abbr=radioProtocolType
