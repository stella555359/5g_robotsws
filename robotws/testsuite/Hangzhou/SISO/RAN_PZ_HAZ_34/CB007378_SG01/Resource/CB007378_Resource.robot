*** Settings ***
Documentation    Suite description
Library                urllib
Library                String
Library                taf.config.scf                        WITH NAME    scf
Library                taf.transport.ssh		             WITH NAME	  ssh
Library                taf.sbts.oam.coam.admin                WITH NAME    coam
Resource     ../../../../RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/L3Call.robot
Resource     ../../../../OAM/RAN_PZ_HAZ_34/5GC002479/Resources/5GC002479_CP_Resource.robot
#Resource     ../../../../OAM/RAN_PZ_HAZ_34/5GC002479/Resources/5GC002479_Resource.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot


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
TC.CB007378-5G_12_General_SiSo_RU_lock_unlock
    [Documentation]  step1: Lock RU(AWHQX) via WebEM ;
    ...              step2: Check state of RU and cell;
    ...              step3: Unlock RU(AWHQX) via WebEM;
    ...              step4: Check state of RU and cell;
    ...              step5: Check whether there is a core-dump abnormal case;
    ${ruNum_LockAndUnlock}  get length  ${CASE_INPUT_CB007378["RMODs_LockAndUnlock"]}
    COAM_WebEM.Login    version=${sbts_stream}
    KW.LockRu  ruNum=${ruNum_LockAndUnlock}
    sleep    1min
    Wait Until Keyword Succeeds  20min  1min
    ...     KW.CheckRuStatus  ruNum=${ruNum_LockAndUnlock}  Operational_State=Enabled
    ...     Administrative_Status=Locked    operate=lock
    Wait Until Keyword Succeeds  20min  1min
    ...     KW.CheckCellStatus  ruNum=${ruNum_LockAndUnlock}  Operational_State=Disabled
    ...     operate=lock

    KW.unLockRu  ruNum=${ruNum_LockAndUnlock}
    sleep    1min
    Wait Until Keyword Succeeds  20min  1min
    ...     KW.CheckRuStatus  ruNum=${ruNum_LockAndUnlock}  Operational_State=Enabled
    ...     Administrative_Status=Unlocked    operate=lock
    Wait Until Keyword Succeeds  20min  1min
    ...     KW.CheckCellStatus  ruNum=${ruNum_LockAndUnlock}  Operational_State=Enabled
    ...     operate=lock
    BtsLog.StopBTSlogCollectionandGetlog
    ${core-dump}    run    command=cat /tmp/btslog2/SYSLOG_*.LOG | grep "core-dump"
    Should Be Empty     ${core-dump}

TC.CB007378-5G_General_SiSo_BBMOD_reset
    [Documentation]  step1: Baseband module (ABIN) reset via WebEM reset button;
    ...              step2: Check state of reseted baseband module is disabled;
    ...              step3: Check state of reseted baseband module is Enabled;
    ...              step4: Check state of radio modules connected to reseted baseband module is Enabled;
    ...              step5: Check state of cells supported by reseted baseband module is Enabled.
    ...              step6: Check whether there is a core-dump abnormal case;
    ${bbModNum_Reset}   get length  ${CASE_INPUT_CB007378["Baseband_module_reset"]["BBMODs_Reset"]}
    COAM_WebEM.Login    version=${sbts_stream}
    KW.ResetBBMOD  bbModNum=${bbModNum_Reset}
    Wait Until Keyword Succeeds  5min  5s
    ...    KW.CheckResetBBModStatus  bbModNum=${bbModNum_Reset}  Operational_State=disabled
    sleep    1min
    Wait Until Keyword Succeeds  10min  1min
    ...    KW.CheckResetBBModStatus  bbModNum=${bbModNum_Reset}  Operational_State=Enabled
    Wait Until Keyword Succeeds  20min  2min
    ...    KW.CheckRuStatusOfResetBBMod  bbModNum=${bbModNum_Reset}  Operational_State=Enabled
    Wait Until Keyword Succeeds  10min  1min
    ...    KW.checkCellStatusOfResetBBMod  bbModNum=${bbModNum_Reset}  Operational_State=Enabled
    COAM_WebEM.Logout
    BtsLog.StopBTSlogCollectionandGetlog
    ${core-dump}    run    command=cat /tmp/btslog2/SYSLOG_*.LOG | grep "core-dump"
    Should Be Empty     ${core-dump}

KW.LockRu
    [Arguments]  ${ruNum}
    FOR  ${i}  IN RANGE  ${ruNum}
        selenium_coam.lock_ru
        ...  ru_index=${CASE_INPUT_CB007378["RMODs_LockAndUnlock"][${i}]["index"]}
    END

KW.unLockRu
    [Arguments]  ${ruNum}
    FOR  ${i}  IN RANGE  ${ruNum}
        selenium_coam.unlock_ru
        ...  ru_index=${CASE_INPUT_CB007378["RMODs_LockAndUnlock"][${i}]["index"]}
    END

KW.ResetBBMOD
    [Arguments]  ${bbModNum}
    FOR  ${i}  IN RANGE  ${bbModNum}
        selenium_coam.reset_abil
        ...  abil_index=${CASE_INPUT_CB007378["Baseband_module_reset"]["BBMODs_Reset"][${i}]["index"]}
    END


KW.CheckRuStatus
    [Arguments]  ${ruNum}  ${Operational_State}  ${Administrative_Status}    ${operate}
    run keyword if    '${operate}'=='reset'
    ...       set test variable    ${key}    RMODs_Reset

    run keyword if    '${operate}'=='lock'
    ...       set test variable    ${key}    RMODs_LockAndUnlock

    FOR  ${i}  IN RANGE  ${ruNum}
        ${rmode_info}    selenium_coam.get_ru_info  ru_index=${CASE_INPUT_CB007378['${key}'][${i}]["index"]}
        Should Be Equal As Strings    ${rmode_info["Status"]["Operational state"]}    ${Operational_State}    ignore_case=${True}
        Should Be Equal As Strings    ${rmode_info["Status"]["Administrative state"]}    ${Administrative_Status}    ignore_case=${True}

    END

KW.CheckCellStatus
    [Arguments]  ${Operational_State}   ${ruNum}  ${operate}
    run keyword if    '${operate}'=='reset'
    ...       set test variable    ${key}    RMODs_Reset
    run keyword if    '${operate}'=='lock'
    ...       set test variable    ${key}    RMODs_LockAndUnlock

    FOR  ${i}  IN RANGE  ${ruNum}
        KW.CheckCellStatusOfCertainRu  Ru=${CASE_INPUT_CB007378["${key}"][${i}]}
        ...                               Operational_State=${Operational_State}

    END

KW.CheckResetBBModStatus
    [Documentation]  Check the status of the reset BBMod
    [Arguments]  ${bbModNum}  ${Operational_State}
    FOR  ${i}  IN RANGE  ${bbModNum}
        ${bbmode_info}    selenium_coam.get_abil_info
        ...               abil_index=${CASE_INPUT_CB007378["Baseband_module_reset"]["BBMODs_Reset"][${i}]["index"]}
        Should Be Equal As Strings    ${bbmode_info["Status"]["Operational state"]}    ${Operational_State}    ignore_case=${True}
#        Should Be Equal As Strings    ${bbmode_info["Status"]["Availability status"]}    ${Availability_Status}  ignore_case=${True}
    END


KW.CheckRuStatusOfResetBBMod
    [Arguments]  ${Operational_State}   ${bbModNum}
    FOR  ${i}  IN RANGE  ${bbModNum}
        KW.CheckRuStatusOfCertainBBMod  bbmod=${CASE_INPUT_CB007378["Baseband_module_reset"]["BBMODs_Reset"][${i}]}
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
        KW.CheckCellStatusOfCertainBBMod  bbmod=${CASE_INPUT_CB007378["Baseband_module_reset"]["BBMODs_Reset"][${i}]}
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
        KW.checkCertainCELLStatus  index=${Ru["Cells"][${i}]["index"]}
        ...               Operational_State=${Operational_State}
#        ...               Availability_Status=${Availability_Status}
    END

KW.checkCertainCELLStatus
    [Documentation]  check the status of certain CELL
    [Arguments]  ${index}  ${Operational_State}
    ${cell_info}    selenium_coam.get_cell_info  cell_idx=${index}
    Should Be Equal As Strings    ${cell_info["Status"]["Operational state"]}    ${Operational_State}    ignore_case=${True}




#COMMON SISO SETUP AND TEARDOWM
SISO Suite Setup
    log to console    \n***SISO Coam Suite Setup***
    Run Keyword If    '${testline_name}'!='null'    UTECloud.ForceAdaptCommissionFiles
    ...    ELSE     UTECloud.AdaptCommissionFiles
    TestSuite.Start
    Commission    ${CFGFILE_PATH}/SCF_CB007378.xml
    Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
    set suite variable      ${Active_SW_version}
    ${stream}   ${subversion}    Split String   string=${Active_SW_version}   separator=_     max_split=1
    ${stream}    set variable if   '${stream}'>='SBTS22R2'    SBTS22R2    SBTS21B
    set suite variable    ${sbts_stream}    ${stream}
    Generate suite log path
    set suite variable      ${SAVE LOG DIRECTORY}    ${SUITE_LOG_PATH}


SISO Suite Teardown
    log to console    \n***SISO Coam Suite Teardown***
#    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
#    ${ru_status}    Run Keyword And Return Status    COAM Check GNB RU status
#    ${cell_status}    Run Keyword And Return Status    Verify all cells should be onair
#    Run Keyword If    ${ru_status}==${False} or ${cell_status}==${False}
#    ...    Commission
    #COAM Teardown gnb connections
    #Run Keyword And Ignore Error    process.Terminate All Processes    kill=True

SISO Test Setup
    log to console    \n***SISO Coam Test Setup***
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
#    ...    Commission
#    Start Btslog With Path Check
    BtsLog.StartBTSlogCollection
    Run Keyword And Ignore Error    selenium_coam.close_browser

SISO Test Teardown
    log to console    \n***SISO Coam Test Teardown***
    Run Keyword If  '${TEST STATUS}' == 'FAIL'    Run Keyword And Ignore error    gNB.CollectSnapshot
    ...    ELSE    Pass Execution If    '${TEST STATUS}' == 'PASS'    Not collect snapshot logs
    Connect to gnb coam via ssl
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
    CI_interface.Common Case Teardown

Get TestLine SCF
    Log    get test line scf from golden scf
    set suite variable     ${testline_scf}      ${CURDIR}/${testline_name}_scf.xml
    UTECloud.ForceAdaptCommissionFiles
    KW.AdaptCaseInput
    GNB.FormatBTSID
    ${res}    run keyword and ignore error    should not be equal  '${CASE_INPUT_CB005845['DeltaSCFCellNumber']}'  'None'
    ${scffile}    run keyword if    '${res[0]}'!='FAIL'    gNB.Generate TL SCF
    ...    GoldenSCF_PATH=${GoldenSCF_PATH}    TLDelta_PATH=${CFGFILE_PATH}
    ...    TestLineSCF_cell_num=${CASE_INPUT_CB005845['DeltaSCFCellNumber']}
    ...    cell_type=${CASE_INPUT_CB005845['CellType']}    MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
    run keyword if    '${res[0]}'!='FAIL'    run keyword and ignore error    gNB.Commission
    ...    scf_file=${scffile}    timeout=${1800}
    run keyword if    '${res[0]}'!='FAIL'    Check all cells Should Be On Air
    run keyword if    '${res[0]}'!='FAIL'    set suite variable    ${testline_scf}    ${scffile}
    set suite variable      ${Golden_SCF_Path}     ${testline_scf}

Commission
    [Arguments]    ${scf_file}=${testline_scf}
    COAM_Admin.commission    scf_file=${scf_file}
    wait until keyword succeeds   10x   2min  COAM_Admin.VerifyCellOnAir



