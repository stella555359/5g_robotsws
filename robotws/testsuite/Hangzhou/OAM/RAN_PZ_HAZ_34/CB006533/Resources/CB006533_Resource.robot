*** Settings ***
Documentation     author:Cheng Jiajing
...               contact: jiajing.1.cheng@nokia-sbell.com
...               squad group: SG_01
...               feature : CB006533
...               Current case only support Single Core
Resource          ../../5GC002479/Resources/5GC002479_Resouce.robot
Library           IPCheck.py
*** Variables ***
${ASIK_IP}             ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_username}	   ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${ASIK_password}	   ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${CFGFILE_PATH}       /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/


##################define these variable for convenient############################
${ALIAS_ASIK}               asik                                                ##
${ALIAS_ASIK2}              asik2                                               ##
${ALIAS_ASIK_SLAVE}         asik_slave                                          ##
${ALIAS_ABIL}               abil                                                ##
${ALIAS_ABIL_SLAVE}         abil_slave                                          ##
${ALIAS_LMP_PRIMARY}        lmp_primary                                         ##
${ALIAS_LMP_SECONDARY}      lmp_secondary                                       ##
${ALIAS_UTE}                ute                                                 ##
${ALIAS_ENBCTLPC}           ENB_PC                                              ##
${ALIAS_SHP}                SHP                                                 ##
${ALIAS_LONER}              LONER                                               ##
${ALIAS_ASP_1A}             ASP_1A                                              ##
${UE_alias}                 UE_0                                                ##
${ALIAS_5GC}                5gc                                                 ##
########################END of alias Define#######################################
*** Keywords ***
TC.CB006533-SR_01_RU_detection_with_eCPRI_MPlane_IPv6_address
    [Documentation]
    ...   IPV6 check, cells onair
    KW.IPV6Migration
    KW.IPV6CheckSingleDual
    KW.RFResetOneByOneWithRetry      retry_times=1
    KW.BBMODResetOneByOneWithRetry   retry_times=1
    KW.SiteResetWithRetry            retry_times=1
    ${alarm_result}=    KW.CheckUnexpectAlarm
    should be true       ${alarm_result}

TC.CB006533-SR_31_eCPRI_MPlane_IP_version_migration
    [Documentation]
    ...   IPV6 check, cells onair
    KW.IPV4SCFComssion
    KW.IPV6Migration
    KW.IPV6CheckSingleDual
    ${alarm_result}=    KW.CheckUnexpectAlarm    GnbReset=True
    should be true       ${alarm_result}

TC.CB006533-SR_02_Basic_Operability_regression
    [Documentation]
    ...   site reset, finally Check onair and unexpected alarm, IPV6 check
    ...   BBMOD reset one by one, finally Check onair and unexpected alarm, IPV6 check
    ...   RF reset one by one, finally Check onair and unexpected alarm, IPV6 check
    KW.IPV6CheckSingleDual
    KW.RFResetOneByOneWithRetry      retry_times=1
    KW.BBMODResetOneByOneWithRetry   retry_times=1
    KW.SiteResetWithRetry            retry_times=1

TC.SiteResetWithRetry
    [Documentation]
    ...   site reset, finally Check onair and unexpected alarm
    [Arguments]   ${retry_times}=2
    KW.SiteResetWithRetry             retry_times=${retry_times}

TC.BBMODResetOneByOneWithRetry
    [Documentation]
    ...   BBMOD reset one by one, finally Check onair and unexpected alarm
    [Arguments]   ${retry_times}=2
    KW.BBMODResetOneByOneWithRetry    retry_times=${retry_times}

TC.RFResetOneByOneWithRetry
    [Documentation]
    ...   RF reset one by one, finally Check onair and unexpected alarm
    [Arguments]   ${retry_times}=2
    KW.RFResetOneByOneWithRetry      retry_times=${retry_times}

TC.IPV6Check
    KW.IPV6CheckSingleDual

Suite setup for 6533
    Import Variables        ${CFGFILE_PATH}TLConfiguration.py

#SetUp Case
#    TestCase.Start
#    wait until keyword succeeds    5min    20s     COAM_Admin.CheckAllCellsOnair

KW.SiteResetWithRetry
    [Documentation]
    ...   site reset, finally Check onair and unexpected alarm
    [Arguments]   ${retry_times}=2
    FOR    ${i}    IN RANGE    ${retry_times}
        log to console    loop=${i}
        KW.SiteReset
        KW.IPV6CheckSingleDual
    END

KW.BBMODResetOneByOneWithRetry
    [Documentation]
    ...   BBMOD reset one by one, finally Check onair and unexpected alarm
    [Arguments]   ${retry_times}=2
    FOR    ${i}    IN RANGE    ${retry_times}
        log to console    loop=${i}
        KW.BBMODResetOneByOne
        KW.IPV6CheckSingleDual
    END

KW.RFResetOneByOneWithRetry
    [Documentation]
    ...   RF reset one by one, finally Check onair and unexpected alarm
    [Arguments]   ${retry_times}=2
    FOR    ${i}    IN RANGE    ${retry_times}
        log to console    loop=${i}
        KW.RFReset
        KW.IPV6CheckSingleDual
    END

KW.IPV6CheckSingleDual
    run keyword if         '${CASE_INPUT_CB006533["Site_Deploy"]}'=='Dual'
    ...       Run keywords
    ...       run keyword and ignore error    KW.IPV6IPV4Check
    ...       connection=${ALIAS_ASIK}
    ...       Deploy=Primary
    ...       AND
    ...       run keyword and ignore error    KW.IPV6IPV4Check
    ...       connection=${ALIAS_ASIK}
    ...       Deploy=Second
    ...       ELSE
    ...       run keyword and ignore error     KW.IPV6IPV4CheckOnlineSingle

KW.SiteReset
    wait until keyword succeeds    15min    20s     COAM_Admin.CheckAllCellsOnair
    &{logtype}     create dictionary    btslog={"type":"true"}    snapshot={"type":"true"}
    Log.Init       logtype=${logtype}
    wait until keyword succeeds   10x   1min    COAM_Admin.Login
    COAM_Admin.ResetSite     timeout=1800
    run keyword and ignore error    COAM_Admin.Logout
    wait until keyword succeeds    15min    20s     COAM_Admin.CheckAllCellsOnair
    ${alarm_result}=    KW.CheckUnexpectAlarm        GnbReset=True
    ${Logs}   Log.Collect
    Run keyword if    '${alarm_result}'=='True'     Run Keyword And Ignore Error
    ...     Run      command=rm ${Logs['snapshot']}
    Run keyword if    '${alarm_result}'=='True'     Run Keyword And Ignore Error
    ...     Run      command=rm ${Logs['btslog'][1]}
    Run keyword if    '${alarm_result}'=='False'    Fatal Error    Please check unexpect Alarm


KW.BBMODResetOneByOne
    wait until keyword succeeds    15min    20s     COAM_Admin.CheckAllCellsOnair
    &{logtype}     create dictionary    btslog={"type":"true"}    snapshot={"type":"true"}
    Log.Init       logtype=${logtype}
    #BtsLog.StartBTSlogCollection
    ${BTSInfo}     COAM_Admin.GetBTSInfo
    wait until keyword succeeds    10min    10s    COAM_WebEM.Login
    FOR    ${BBMOD}   IN    @{BTSInfo['basebandModules']}
        ${BBMOD_config}=    Split String From Right    ${BBMOD['id']['configuration']}     /
        ${tmp}=    Split String From Right   ${BBMOD_config[-1]}      -
        ${BBMOD_INDEX}    Set Variable   ${tmp[-1]}
        selenium_coam.reset_baseband    baseband_index=${BBMOD_INDEX}
        sleep    10s
    END
    run keyword and ignore error    COAM_WebEM.Logout
    wait until keyword succeeds    15min    20s     COAM_Admin.CheckAllCellsOnair
    ${alarm_result}=    KW.CheckUnexpectAlarm
    #BtsLog.StopBTSlogCollectionandGetlog
    ${Logs}   Log.Collect
    Run keyword if    '${alarm_result}'=='True'     Run Keyword And Ignore Error
    ...     Run      command=rm ${Logs['snapshot']}
    Run keyword if    '${alarm_result}'=='True'     Run Keyword And Ignore Error
    ...     Run      command=rm ${Logs['btslog'][1]}
    Run keyword if    '${alarm_result}'=='False'    Fatal Error    Please check unexpect Alarm

KW.RFReset
    wait until keyword succeeds    15min    20s     COAM_Admin.CheckAllCellsOnair
    &{logtype}     create dictionary    btslog={"type":"true"}    snapshot={"type":"true"}
    Log.Init       logtype=${logtype}
    set test variable    ${with_graceful}    False
    ${BTSInfo}     COAM_Admin.GetBTSInfo
    wait until keyword succeeds    10min    10s    COAM_WebEM.Login
    FOR    ${RU}   IN    @{BTSInfo['radioModules']['rmod']}
        @{RMODsList}=  Create List
        ${RMOD}=  Set Variable    ${RU['productName']}
        Append To List    ${RMODsList}    ${RMOD}
        ${res}   Run Keyword And Ignore Error    Split String From Right    ${RU['id']['configuration']}     /
        run keyword if    '${res[0]}'!='PASS'    Continue For Loop
        ${tmp}=    Split String From Right    ${res[1][-1]}    -
        ${RU_Reset_INDEX}    Set Variable   ${tmp[-1]}
        WEBUI.ResetRU    ru_index=${RU_Reset_INDEX}    with_graceful=${with_graceful}
        sleep    10s
    END
    run keyword and ignore error    COAM_WebEM.Logout
    wait until keyword succeeds    15min    20s     COAM_Admin.CheckAllCellsOnair
    ${alarm_result}=    KW.CheckUnexpectAlarm
    ${Logs}   Log.Collect
    Run keyword if    '${alarm_result}'=='True'     Run Keyword And Ignore Error
    ...     Run      command=rm ${Logs['snapshot']}
    Run keyword if    '${alarm_result}'=='True'     Run Keyword And Ignore Error
    ...     Run      command=rm ${Logs['btslog'][1]}
    Run keyword if    '${alarm_result}'=='False'    Fatal Error    Please check unexpect Alarm

KW.CheckUnexpectAlarm
    [Arguments]   ${GnbReset}=False
    @{Fault_whitelist}    Create list    4657   4655   4654   61524   61652   4459   61649    61618    61011    4590    4681   7307
    Run Keyword if   '${GnbReset}' == 'True'    append to list    ${Fault_whitelist}    4592
    COAM_WebEM.Login
    ${active_alarm}=    Wait Until Keyword Succeeds    3X    1min    selenium_coam.get_active_alarm_info
    log    ${active_alarm}
    ${history_alarm}=    Wait Until Keyword Succeeds    3X    1min    selenium_coam.get_history_alarm_info
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


KW.IPV6Check
    [Arguments]   ${RF_SN}       ${connection}=${ALIAS_ASIK}
    gNB.Connect
    ${FRIpsOutPut}    ssh.execute    command=cat /ffs/run/config/FRIps.txt    connection=${connection}
    gNB.Disconnect
    ${FRIp}    Fetch From Left     ${FRIpsOutPut}      ;${RF_SN}
    ${FRIp}    Fetch From Right    ${FRIp}   ;
    ${IPV6_result}        check_ipv6     ${FRIp}
    should be true       ${IPV6_result}
    [Return]    ${IPV6_result}

KW.IPV4Check
    [Arguments]    ${RF_SN}     ${connection}=${ALIAS_ASIK}
    gNB.Connect
    ${FRIpsOutPut}    ssh.execute    command=cat /ffs/run/config/FRIps.txt    connection=${connection}
    gNB.Disconnect
    ${FRIp}    Fetch From Left     ${FRIpsOutPut}      ;${RF_SN}
    ${FRIp}    Fetch From Right    ${FRIp}   ;
    ${IPV4_result}        check_ipv4     ${FRIp}
    should be true       ${IPV4_result}
    [Return]    ${IPV4_result}

KW.IPV6IPV4Check
    [Arguments]   ${connection}=${ALIAS_ASIK}
    ...           ${Deploy}=Primary
    Log      ${CASE_INPUT_CB006533['IPV6_RF_SN_${Deploy}']}
    ${length}    Get length     ${CASE_INPUT_CB006533['IPV6_RF_SN_${Deploy}']}
    FOR  ${i}  IN RANGE    ${length}
            Log    ${CASE_INPUT_CB006533['IPV6_RF_SN_${Deploy}'][${i}]}
            KW.IPV6Check   connection=${connection}    RF_SN=${CASE_INPUT_CB006533['IPV6_RF_SN_${Deploy}'][${i}]}
    END
    ${length}    Get length     ${CASE_INPUT_CB006533['IPV4_RF_SN_${Deploy}']}
    FOR  ${i}  IN RANGE  ${length}
            KW.IPV4Check   connection=${connection}    RF_SN=${CASE_INPUT_CB006533['IPV4_RF_SN_${Deploy}'][${i}]}
    END

KW.IPV6IPV4CheckOnlineSingle
    log to console    start check IPV6 and IPV4 address ONLINE Single
    ${BTSInfo}     COAM_Admin.GetBTSInfo
    COAM_WebEM.Login
    FOR    ${RU}   IN    @{BTSInfo['radioModules']['rmod']}
        ${RMOD}=  Set Variable    ${RU['productName']}
        ${RMOD_SN}=   Set Variable    ${RU['serialNumber']}
        ${IPV6_RF}    Set Variable If
        ...           '${RMOD}'=='AWHQN'     IPV6
        ...           '${RMOD}'=='AKQJ'      IPV6
        run keyword if     '${IPV6_RF}'=='IPV6'
        ...       KW.IPV6Check              RF_SN=${RMOD_SN}
        ...       ELSE                      KW.IPV4Check        RF_SN=${RMOD_SN}
    END


KW.IPV4SCFComssion
    log to console    start change to IPV4
    ${BTSInfo}     COAM_Admin.GetBTSInfo
    COAM_WebEM.Login
    FOR    ${RU}   IN    @{BTSInfo['radioModules']['rmod']}
        @{RMODsList}=  Create List
        ${RMOD}=  Set Variable    ${RU['productName']}
        Append To List    ${RMODsList}    ${RMOD}
        ${res}   Run Keyword And Ignore Error    Split String From Right    ${RU['id']['configuration']}     /
        run keyword if    '${res[0]}'!='PASS'    Continue For Loop
        ${tmp}=    Split String From Right    ${res[1][-1]}    -
        ${RU_INDEX}    Set Variable   ${tmp[-1]}
        ${IPV6_RF}    Set Variable If
        ...           '${RMOD}'=='AWHQN'     IPV6
        ...           '${RMOD}'=='AKQJ'      IPV6
        run keyword if     '${IPV6_RF}'=='IPV6'
        ...       COAM_WebEM.SetParameterValue
        ...       distName=${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${RU_INDEX}    abbr=Internet protocol version
        ...       value=IPV4    Abbreviation=internetProtocolVersion
    END
    COAM_WebEM.SetParameterValue
    ...       distName=${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1    abbr=Activate eCPRI Transport with M plane over IPv6
    ...       value=false    Abbreviation=actEcpriMplaneIPV6
    COAM_WebEM.ValidateAndActiveParameters      activate_plan_despite_errors=False
    log to console    change to IPV4 done and wait for onair
    Run keyword and ignore error        COAM_WebEM.Logout
    wait until keyword succeeds    15min    20s     COAM_Admin.CheckAllCellsOnair

KW.IPV6Migration
    log to console    start change to IPV6
    ${BTSInfo}     COAM_Admin.GetBTSInfo
    COAM_WebEM.Login
    FOR    ${RU}   IN    @{BTSInfo['radioModules']['rmod']}
        @{RMODsList}=  Create List
        ${RMOD}=  Set Variable    ${RU['productName']}
        Append To List    ${RMODsList}    ${RMOD}
        ${res}   Run Keyword And Ignore Error    Split String From Right    ${RU['id']['configuration']}     /
        run keyword if    '${res[0]}'!='PASS'    Continue For Loop
        ${tmp}=    Split String From Right    ${res[1][-1]}    -
        ${RU_INDEX}    Set Variable   ${tmp[-1]}
        ${IPV6_RF}    Set Variable If
        ...           '${RMOD}'=='AWHQN'     IPV6
        ...           '${RMOD}'=='AKQJ'      IPV6
        run keyword if     '${IPV6_RF}'=='IPV6'
        ...       COAM_WebEM.SetParameterValue
        ...       distName=${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${RU_INDEX}    abbr=Internet protocol version
        ...       value=IPV6    Abbreviation=internetProtocolVersion
    END
    COAM_WebEM.SetParameterValue
    ...       distName=${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1    abbr=Activate eCPRI Transport with M plane over IPv6
    ...       value=true    Abbreviation=actEcpriMplaneIPV6
    COAM_WebEM.ValidateAndActiveParameters      activate_plan_despite_errors=False
    log to console    change to IPV6 done and wait for onair
    Run keyword and ignore error        COAM_WebEM.Logout
    wait until keyword succeeds    15min    20s     COAM_Admin.CheckAllCellsOnair
