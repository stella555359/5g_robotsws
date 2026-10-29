*** Settings ***
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/common_cases.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/scf.robot




*** Variables ***



*** Keywords ***
9275_test_trigger_1932
    [Arguments]    ${ru_index}=1
    connection_alias_store.Connect to Common Unit Master
    Connect to gnb coam via ssl

    log to console    ******* Step 1: log in RU (AQQQA)********
    Connect to RU With Allocated IP  ru_index=${ru_index}  ru_alias=RU_${ru_index}   asik_alias=ASIK Master

    log to console    ******* Step 2 : Trigger 1932 ********
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}

    log to console    2.2 create fan proxy
    ${cmd}   Set Variable
    ...  echo '/ action create ConfigAccess /CI/ConfigAccess_Module /module'|${sudo} frmonShellClient localhost 2000
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    sleep    2s

    log to console    2.3 get fans.json file
    ${cmd}   Set Variable
    ...  echo '/CI/ConfigAccess_Module action fetch DECODED "fans.bin" "/ram/fans.json"'|${sudo} frmonShellClient localhost 2000
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s

    log to console    2.4 modify  fans.json file
    csn.Send command  command=${sudo} cat /ram/fans.json    connection=RU_${ru_index}
    csn.Send command
    ...  command=${sudo} sed -i 's/"fanTestRpmMin": 600,/"fanTestRpmMin": 1400,/g' /ram/fans.json   connection=RU_${ru_index}
    sleep    1s
    csn.Send command
    ...  command=${sudo} sed -i 's/"fanTestPeriod": 30000,/"fanTestPeriod": 30000,/g' /ram/fans.json   connection=RU_${ru_index}
    sleep    1s
    csn.Send command
    ...  command=${sudo} sed -i 's/"fanDetectionPeriod": 3600000,/"fanDetectionPeriod": 60000,/g' /ram/fans.json   connection=RU_${ru_index}
    sleep    1s

    log to console    2.5 update config to RF
    ${cmd}   Set Variable
    ...  echo '/CI/ConfigAccess_Module action store PERMANENT DECODED "fans.bin" "/ram/fans.json"'|${sudo} frmonShellClient localhost 2000
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s


    log to console    2.6 update flag
    ${cmd}   Set Variable  ccsShell.sh rad -mpw 0x120040 0x00000334
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    Should Contain    ${output}    written succesfully
    sleep    2s

    ${cmd}   Set Variable  ccsShell.sh rad -mpw 0x120041 0x00000334
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    Should Contain    ${output}    written succesfully
    sleep    2s


    log to console    2.6 reboot ru, then wait 5 minutes
    csn.Send command  command=sudo su    connection=RU_${ru_index}
    csn.Send command  command=reboot    connection=RU_${ru_index}
    sleep    300s
	run keywords    csn.Disconnect  connection=RU_${ru_index}    AND    csn.Disconnect  connection=ASIK Master




Expect Fault Should Present on WebUI
    [Arguments]    ${faultId}    ${source}=${None}    ${severity}=${None}    ${alarmId}=${None}
    ...            ${configObjectName}=${None}    ${connection}=GNB_OAM
    ${faultId}    Convert To Integer    ${faultId}
    @{alarms}    coam.get_active_alarms    connection=${connection}
    ${alarm_num}    Get Length    ${alarms}
    ${present_status}    Set Variable    ${False}
    FOR  ${alarm}  IN  @{alarms}
       Exit For Loop If    ${alarm_num}==${0}
       ${present_status}    Run Keyword And Return Status    Run Keywords
                  ...      Dictionary Should Contain Item    ${alarm}    faultId    ${faultId}    AND
                  ...      Run Keyword If    '${source}'!='${None}'
                  ...      Should Be Equal     ${alarm['notifier']}    ${source}    case_insensitive=True    AND
                  ...      Run Keyword If    '${severity}'!='${None}'
                  ...      Should Contain     ${alarm['severity']}   ${severity}    case_insensitive=True    AND
                  ...      Run Keyword If    '${alarmId}'!='${None}'
                  ...      Should Be Equal As Strings    ${alarm['alarmId']}    ${alarmId}    AND
                  ...      Run Keyword If    '${config_object_name}'!='${None}'
                  ...      Should Contain    ${alarm['configObjectName']}    ${config_object_name}
      Exit For Loop If    ${present_status}
    END
    Run Keyword If    ${present_status}==${False}    Fail    faultId ${faultId} reported by source ${source} is not present on gnb.

Expect Fault Should Absent on WebUI
    [Arguments]   ${faultId}   ${source}=${None}   ${connection}=GNB_OAM
    ${status}    Run Keyword And Return Status   CB009275_common_keyword.Expect Fault Should Present on WebUI   faultId=${faultId}
    ...                                                                        source=${source}
    ...                                                                        connection=${connection}
    Run Keyword If  ${status}==${True}   Fail   faultId ${faultId} reported by source ${source} is still present on gnb.


Check 1932 Alarm on RMOD
    Connect to gnb coam via ssl

    Get runtime FAN Via Index  index=0
    Get runtime FAN Via Index  index=1
    Wait Until Keyword Succeeds    5min    30s
    ...   CB009275_common_keyword.Expect Fault Should Absent on WebUI  faultId=1932  source=[${btsname}] ${RMOD}/${FAN_R-1}
    Wait Until Keyword Succeeds    5min    30s
    ...   CB009275_common_keyword.Expect Fault Should Absent on WebUI  faultId=1932  source=[${btsname}] ${RMOD}/${FAN_R-2}
    Wait Until Keyword Succeeds    5min    30s
    ...   CB009275_common_keyword.Expect Fault Should Present on WebUI  faultId=1932  source=[${btsname}] ${RMOD}


    log to console     fault 1932 show on RMOD

Check 1932 Alarm on FAN_R
    Connect to gnb coam via ssl

    Get runtime FAN Via Index  index=0
    Get runtime FAN Via Index  index=1
    Wait Until Keyword Succeeds    5min    30s
    ...   CB009275_common_keyword.Expect Fault Should Present on WebUI  faultId=1932  source=[${btsname}] ${RMOD}/${FAN_R-1}
    Wait Until Keyword Succeeds    5min    30s
    ...   CB009275_common_keyword.Expect Fault Should Present on WebUI  faultId=1932  source=[${btsname}] ${RMOD}/${FAN_R-2}
    Wait Until Keyword Succeeds    5min    30s
    ...   CB009275_common_keyword.Expect Fault Should Absent on WebUI  faultId=1932  source=[${btsname}] ${RMOD}
    log to console     fault 1932 show on FAN



Recovery Fan1 and Fan2 and clear Alarm 1932
    [Arguments]    ${ru_index}=1
    connection_alias_store.Connect to Common Unit Master
    Connect to gnb coam via ssl
    log to console    ******* log in RU (AQQQA)********
    Connect to RU With Allocated IP  ru_index=${ru_index}  ru_alias=RU_${ru_index}   asik_alias=ASIK Master

    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}

    log to console    ******* Step 7：recovery Fan and clear Alarm*******
    ${cmd}   Set Variable  ccsShell.sh rad -mpw 0x120040 0
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    Should Contain    ${output}    written succesfully
    sleep    2s

    ${cmd}   Set Variable  ccsShell.sh rad -mpw 0x120041 0
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    Should Contain    ${output}    written succesfully
    sleep    2s


    ${cmd}   Set Variable
    ...   echo "/ action create ConfigAccess /CI/ConfigAccess_Module /module"|${sudo} frmonShellClient localhost 2000
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    sleep    2s

    ${cmd}   Set Variable  echo '/CI/ConfigAccess_Module action delete "fans.bin"'|${sudo} frmonShellClient localhost 2000
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    sleep    2s

    ${cmd}   Set Variable  echo "/CI/ConfigAccess_Module action terminate"|${sudo} frmonShellClient localhost 2000
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    sleep    2s

    #log to console    check fan status
    #COAM Check fan status    ru_index=${ru_index}    Availabilitystatus_exp='-'    operationalState_exp='enabled'
    COAM Teardown gnb connections
    sleep   240s     #wait alarm disappear

    [Teardown]  run keywords    csn.Disconnect  connection=RU_${ru_index}    AND    csn.Disconnect  connection=ASIK Master



Modify_actRadioFanFailureEarlyNotif_Paramater
    [Arguments]    ${value}=true
    #Connect to gnb coam via ssl
    #Verify all cells should be onair
    ${dist_name}    set variable    MRBTS-${mrbtsID}/MNL-1/MNLENT-1/FMCADM-1
    scf.Activate Parameter Value    dist_name=${dist_name}  p_name=actRadioFanFailureEarlyNotif  new_value=${value}
    sleep   300s
    #Connect to gnb coam via ssl
    #Verify all cells should be onair


#COAM Check fan status
#    [Arguments]    ${ru_index}=0    ${connection}=GNB_OAM   ${Availabilitystatus_exp}   ${operationalState_exp}
#    ${bts}    coam.get_bts_info    connection=${connection}
#    ${fans}    set variable    ${bts['radioModules']['rmod'][${ru_index}]['fanStatus']['fans']}
#    For    ${fan}    IN    ${fans}
#        ${operationalState}    set variable    ${fan['stateInfo']['operationalState']}
#        Should Be True    '${operationalState}'=='${operationalState_exp}'
#        ${Availabilitystatus}    set variable    ${fan['stateInfo']['availabilitystatus']}
#        Should Be True    '${Availabilitystatus}'=='${Availabilitystatus_exp}'
#    END

