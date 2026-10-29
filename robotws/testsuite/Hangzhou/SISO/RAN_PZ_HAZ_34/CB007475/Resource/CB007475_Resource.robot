*** Settings ***
Documentation    author: Gao Ge, Hu Caoli
...               contact: ge.gao@nokia-sbell.com; caoli.hu@nokia-sbell.com
...               squad group: SG_01
...               feature : CB007475
Library                urllib
Library                String
Library                taf.config.scf                        WITH NAME    scf
Library                taf.transport.ssh		             WITH NAME	  ssh
Library                taf.sbts.oam.coam.admin                WITH NAME    coam
Library                taf.sw.dcap.rd                        WITH NAME    rd
#Library                taf.selenium.sbts                   WITH NAME  selenium_coam
#Library                ReadJason.py
Resource     ../../../../RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/L3Call.robot
Resource     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/None_Feature_SG1/OAM_Interface.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot

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

*** Keywords ***
TC.CB007475_B_07_NRTDD_LTE_FDD_Concurrent_with_NR_TDD_eCPRI_RF_Fiber_Split_on_Fullrack
    [Documentation]  step1: Commission BTS that NR TDD eCPRI Radio is split on full rack while ABIO is used for LTE FDD and NRTDD concurrent mode
    ...              step2: Make L3 call on NRTDD cell and LTEFDD cell.
#    MultiUE.L3Call    ue_index=${TLCommonConfig['MultiUECFG']['ue_index_for_call'][0]}
#    MultiUE.L3Call    ue_index=${TLCommonConfig['MultiUECFG']['ue_index_for_call'][1]}    protocol=${TLCommonConfig['MultiUECFG']['1']['protocol']}
    @{SA_UE}    create list    0
    Set To Dictionary    ${TLCommonConfig['MultiUECFG']}    ue_index_for_call     ${SA_UE}
    MultiUE.L3Call    UECFG=${TLCommonConfig['MultiUECFG']}
    @{LTE_UE}    create list    1
    Set To Dictionary    ${TLCommonConfig['MultiUECFG']}    ue_index_for_call     ${LTE_UE}
    MultiUE.L3Call    UECFG=${TLCommonConfig['MultiUECFG']}


TC.General_SiSo_Auto_gNB_Site_Reset_From_WebUI
    [Documentation]  step1: Site Reset form WebUI interface is performed
    ...              step2: all cells are air.
    KW.ResetSite


TC.Baseband module reset from BTSSM WebEM
    [Documentation]  step1: Concurrent Baseband module reset via WebEM reset button.
    ...              step2: Check state of reseted baseband module
    ...              step3: Check state of radio modules connected to reseted baseband module
    ...              step4: Check state of cells supported by reseted baseband module.
    ${bbModNum_Reset}   get length  ${CASE_INPUT_CB007475["Baseband_module_reset"]["BBMODs_Reset"]}
    Set Test Variable    ${GnbReset}    False
    sleep    90s
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

KW.ResetBBMOD
    [Arguments]  ${bbModNum}
    FOR  ${i}  IN RANGE  ${bbModNum}
        selenium_coam.reset_abil
        ...  abil_index=${CASE_INPUT_CB007475["Baseband_module_reset"]["BBMODs_Reset"][${i}]["index"]}
    END

KW.CheckResetBBModStatus
    [Documentation]  Check the status of the reset BBMod
    [Arguments]  ${bbModNum}  ${Operational_State}
    FOR  ${i}  IN RANGE  ${bbModNum}
        ${bbmode_info}    selenium_coam.get_abil_info
        ...               abil_index=${CASE_INPUT_CB007475["Baseband_module_reset"]["BBMODs_Reset"][${i}]["index"]}
        Should Be Equal As Strings    ${bbmode_info["Status"]["Operational state"]}    ${Operational_State}    ignore_case=${True}
#        Should Be Equal As Strings    ${bbmode_info["Status"]["Availability status"]}    ${Availability_Status}  ignore_case=${True}
    END

KW.CheckRuStatusOfResetBBMod
    [Arguments]  ${Operational_State}   ${bbModNum}
    FOR  ${i}  IN RANGE  ${bbModNum}
        KW.CheckRuStatusOfCertainBBMod  bbmod=${CASE_INPUT_CB007475["Baseband_module_reset"]["BBMODs_Reset"][${i}]}
        ...                             Operational_State=${Operational_State}
#        ...                             Availability_Status=${Availability_Status}
    END

KW.CheckRuStatusOfCertainBBMod
    [Arguments]  ${Operational_State}   ${bbmod}
    ${ruNnm}  get length  ${bbmod["Rus"]}
    FOR  ${i}  IN RANGE  ${ruNnm}
        ${rmode_info}    selenium_coam.get_ru_info  ru_index=${bbmod["Rus"][${i}]["index"]}
        Should Be Equal As Strings    ${rmode_info["Status"]["Operational state"]}    ${Operational_State}    ignore_case=${True}
#        Should Be Equal As Strings    ${rmode_info["Status"]["Availability status"]}    ${Availability_Status}   ignore_case=${True}
    END

KW.checkCellStatusOfResetBBMod
    [Arguments]  ${Operational_State}   ${bbModNum}
    FOR  ${i}  IN RANGE  ${bbModNum}
        KW.CheckCellStatusOfCertainBBMod  bbmod=${CASE_INPUT_CB007475["Baseband_module_reset"]["BBMODs_Reset"][${i}]}
        ...                               Operational_State=${Operational_State}
#        ...                               Availability_Status=${Availability_Status}
    END

KW.CheckCellStatusOfCertainBBMod
   [Arguments]  ${Operational_State}   ${bbmod}
   ${ruNnm}  get length  ${bbmod["Rus"]}
   FOR  ${i}  IN RANGE  ${ruNnm}
      KW.CheckCellStatusOfCertainRu  Ru=${bbmod["Rus"][${i}]}
      ...               Operational_State=${Operational_State}
#      ...               Availability_Status=${Availability_Status}
   END

KW.CheckCellStatusOfCertainRu
    [Arguments]  ${Operational_State}   ${Ru}
    ${cellNum}  get length  ${Ru["Cells"]}
    FOR  ${i}  IN RANGE  ${cellNum}
        KW.checkCertainCELLStatus  index=${Ru["Cells"][${i}]["index"]}   cell_type=${Ru["Cells"][${i}]["cell_type"]}
        ...               Operational_State=${Operational_State}
#        ...               Availability_Status=${Availability_Status}
    END

KW.checkCertainCELLStatus
    [Documentation]  check the status of certain CELL
    [Arguments]  ${index}  ${cell_type}  ${Operational_State}
    ${cell_info}    selenium_coam.get_cell_info  cell_idx=${index}  technology=${cell_type}
    Should Be Equal As Strings    ${cell_info["Status"]["Operational state"]}    ${Operational_State}    ignore_case=${True}
#    Should Be Equal As Strings    ${cell_info["Status"]["Availability status"]}    ${Availability_Status}   ignore_case=${True}
KW.ResetSite
    Set Test Variable    ${GnbReset}    True
    COAM_WebEM.Login    version=${sbts_stream}
    ${status}    Run Keyword And Return Status    selenium_coam.reset_site
    should be true    ${status}
    sleep    60s
    ${status}    Run Keyword And Return Status    KW.ConnectDualCoreBySSH
    Should not be true    ${status}
    COAM_WebEM.Login    version=${sbts_stream}
    Wait Until Keyword Succeeds    20min    1min    COAM_Admin.CheckAllCellsOnair     type=both
#    COAM_WebEM.Logout
    ${alarm_result}=    KW.GetAndCheckAlarm
    Run Keyword And Continue On Failure    Run keyword if    '${alarm_result}'=='False'    Fail
        ...    Please check unexpect Alarm
#    wait until keyword succeeds    20min    10s    COAM_Admin.CheckAllCellsOnair     type=lte

KW.ConnectDualCoreBySSH
    [Documentation]   ssh to the given IP with username and password
    @{ipList}    Create list    ${LMP_Primary}    ${ASIK_IP_Mplane}
    FOR    ${ip}    IN     @{ipList}
        ssh.Connect to    ${ip}    ${ASIK_USERNAME}    ${ASIK_PASSWORD}    alias=tmpConn
        ssh.disconnect    connection=tmpConn
    END


#COMMON SETUP AND TEARDOWM
Setup Suite
    log to console    \n***SISO Coam Suite Setup***
    Run Keyword If    '${testline_name}'!='null'    UTECloud.ForceAdaptCommissionFiles
    ...    ELSE     UTECloud.AdaptCommissionFiles
    TestSuite.Start
    Commission    ${CFGFILE_PATH}/SCF_CB007475.xml
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
    set suite variable      ${Active_SW_version}
    ${stream}   ${subversion}    Split String   string=${Active_SW_version}   separator=_     max_split=1
    ${stream}    set variable if   '${stream}'>='SBTS22R2'    SBTS22R2    SBTS21B
    set suite variable    ${sbts_stream}    ${stream}

    Generate suite log path
    set suite variable      ${SAVE LOG DIRECTORY}    ${SUITE_LOG_PATH}


Teardown Suite
    log to console    \n***SISO Coam Suite Teardown***
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
#    ${ru_status}    Run Keyword And Return Status    COAM Check GNB RU status
#    ${cell_status}    Run Keyword And Return Status    Verify all cells should be onair
#    Run Keyword If    ${ru_status}==${False} or ${cell_status}==${False}
#    ...    Commission    ${CFGFILE_PATH}/SCF_CB007475.xml
    ${cells_status}    Run Keyword And Return Status    COAM_Admin.CheckAllCellsOnair    type=both
#    ${cells_status_LTE}    Run Keyword And Return Status    COAM_Admin.CheckAllCellsOnair     type=lte
    run keyword if    '${cells_status}'=='False'    run keyword and ignore error    KW.ResetSite

    TestSuite.Stop


Setup case
    log to console    \n***SISO Coam Test Setup***
    log to console    Active_SW_version:${Active_SW_version}
    TestCase.Start
    Generate test case log path
    ${time_stamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    set test variable  ${TS_CASE_LOG_PATH}    ${TS_CASE_LOG_PATH}/${time_stamp}/
    create directory   ${TS_CASE_LOG_PATH}
    Set Test Variable    ${SAVE LOG DIRECTORY}    ${TS_CASE_LOG_PATH}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ${cells_status}    Run Keyword And Return Status    COAM_Admin.CheckAllCellsOnair     type=both
#    ${cells_status_LTE}    Run Keyword And Return Status    COAM_Admin.CheckAllCellsOnair     type=lte
    run keyword if    '${cells_status}'=='False'   run keyword and ignore error    KW.ResetSite
    Run Keyword And Ignore error    BtsLog.StartBTSlogCollection
#    ${ru_status}    Run Keyword And Return Status    COAM Check GNB RU status
#    ${cell_status}    Run Keyword And Return Status    Verify all cells should be onair
#    Run Keyword If    ${ru_status}==${False} or ${cell_status}==${False}    Fail    TEST
#    ...    Commission
#    Start Btslog With Path Check
    Run Keyword And Ignore Error    selenium_coam.close_browser

Teardown case
    log to console    \n***SISO Coam Test Teardown***
    Run Keyword And Ignore error     BtsLog.StopBTSlogCollectionandGetlog
    Connect to gnb coam via ssl
    Run Keyword If  '${TEST STATUS}' == 'FAIL'    Run Keyword And Ignore error    gNB.CollectSnapshot
    ...    ELSE    Pass Execution If    '${TEST STATUS}' == 'PASS'    Not collect snapshot logs
#    Connect to gnb coam via ssl
#    ${ru_status}   run keyword and ignore error   COAM Check GNB RU status
#    log to console  RU status: ${ru_status}
#    ${cell_status}    Run Keyword And Return Status    Verify all cells should be onair
#    should be true    ${cell_status}
#    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=@{ALLOWED_FAULT}
#    should be true    ${alarm_status}
#    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
#    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
#    ${rc}    ${output} =    Run and Return RC and Output    ps -ef | grep ${btslog_dir} | grep -v grep
#    run keyword if    '${btslog_dir}'!='none' and ${rc}==${0}    Stop Btslog Collect    target_dir=${SAVE LOG DIRECTORY}
#    run keyword if test failed     Collect Coam Snapshot    target_dir=${SAVE LOG DIRECTORY}
    COAM Teardown gnb connections
    Run Keyword And Ignore Error    run    command=ps xafu |grep node|grep -v grep|awk '{print $2}' | xargs kill -9
    Run Keyword And Ignore Error    run    command=killall firefox
    Run Keyword And Ignore Error    run    command=killall geckodriver
    Conn.ResetCache
#    CI_interface.Common Case Teardown
    TestCase.Stop

Commission
    [Arguments]    ${scf_file}
    COAM_Admin.commission    scf_file=${scf_file}
    wait until keyword succeeds   10x   2min  COAM_Admin.VerifyCellOnAir
    Wait Until Keyword Succeeds    20min    1min    COAM_Admin.CheckAllCellsOnair    type=both
#    wait until keyword succeeds    20min    10s    COAM_Admin.CheckAllCellsOnair     type=lte

KW.GetAndCheckAlarm
    @{Fault_whitelist}    Create list    4655   4654   61524   61652   4459    4681   7312
    Run Keyword if   '${GnbReset}' == 'True'    append to list    ${Fault_whitelist}    4592
#    COAM_WebEM.Login
    ${active_alarm}    selenium_coam.get_active_alarm_info
    log    ${active_alarm}
    ${history_alarm}    selenium_coam.get_history_alarm_info
    log    ${history_alarm}
    ${fault_id_list}    create list
    ${unexpect_fault}    create list
    FOR    ${item}    IN    @{active_alarm}
         ${fault_id}    get from dictionary    ${item}    Fault ID
         append to list    ${fault_id_list}    ${fault_id}
    END
    FOR    ${item}    IN    @{history_alarm}
         ${fault_id}    get from dictionary    ${item}    Fault ID
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
    ${alarm_result}=    run keyword and return status    should be empty    ${unexpect_fault}
    COAM_WebEM.Logout
    [Return]    ${alarm_result}



