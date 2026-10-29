*** Settings ***
Resource   Common.robot

*** Variables ***
&{WAIT_RU_DETECTED_LOG}   upgrade=&{EMPTY}   rollback=&{EMPTY}   reset=&{EMPTY}   others=&{EMPTY}


*** Keywords ***
# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
UUF Upgraded Testline Wait
    [Arguments]   ${testline}
    Run Keyword And Continue On Failure   UUF Testline Wait Ping     testline=${testline}
    UUF Testline Wait ADMIN    testline=${testline}
    UUF Testline Wait SMOD     testline=${testline}
    UUF Testline Wait BBMOD    testline=${testline}
    UUF Testline Wait RMOD     testline=${testline}
    UUF Testline Wait Cell     testline=${testline}
    UUF Testline Wait Fault    testline=${testline}
    UUF Testline Wait Minute   testline=${testline}


UUF Wait Other Testline
    [Arguments]   ${exclude_testline}
    Log To Console   //TODO: UUF ALL Wait Testline
    @{wait_sequence}   Create List   @{GNB_LIST}   @{CONCURRENT_ENB_LIST}
    Remove Values From List   ${wait_sequence}   ${exclude_testline}
    Log To Console   Other Testline List: ${wait_sequence}
    FOR   ${testline}   IN   @{wait_sequence}
        Log To Console   //TODO: Waiting ${testline}
        UUF Wait Other Single Testline   testline=${testline}
    END


UUF Wait Other Single Testline
    [Arguments]   ${testline}
    ${webem_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_addr']}
    ${webem_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_username']}
    ${webem_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_password']}
    COAM Login
    ...   bts_host=${webem_addr}
    ...   username=${webem_username}
    ...   password=${webem_password}
    ...   alias=${testline}
    UUF Wait Times For Cell OnAir       testline=${testline}
    UUF Testline Wait Fault    testline=${testline}
    [Teardown]   Run Keyword And Ignore Error   COAM Logout   connection=${testline}



# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
UUF Testline Wait Ping
    [Arguments]   ${testline}
    Log To Console   UUF Testline Wait Ping
    ${ssh_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['ssh_addr']}
    Wait Until Keyword Succeeds   10m   1m   Check Connection Status   ip_address=${ssh_addr}   status=connect
    [Teardown]   Run Keyword If   "${KEYWORD_STATUS}"=="FAIL"
    ...   UUF Save Single Testline Check Point Error   testline=${testline}   check_point=wait_ping   error=FAIL


UUF Testline Wait ADMIN
    [Arguments]   ${testline}
    Log To Console   UUF Testline Wait ADMIN
    ${webem_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_addr']}
    ${webem_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_username']}
    ${webem_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_password']}

    Wait Until Keyword Succeeds   10m   1m   COAM Login
    ...   bts_host=${webem_addr}
    ...   username=${webem_username}
    ...   password=${webem_password}
    ...   alias=${testline}

    [Teardown]   Run Keyword If   "${KEYWORD_STATUS}"=="FAIL"
    ...   UUF Save Single Testline Check Point Error   testline=${testline}   check_point=wait_admin   error=FAIL

UUF Testline Wait SMOD
    [Arguments]   ${testline}
    Log To Console   UUF Testline Wait SMOD
    UUF Wait Times SMOD Enabled   testline=${testline}
    [Teardown]   Run Keyword If   "${KEYWORD_STATUS}"=="FAIL"
    ...   UUF Save Single Testline Check Point Error   testline=${testline}   check_point=wait_smod   error=FAIL



UUF Testline Wait BBMOD
    [Arguments]   ${testline}
    Log To Console   UUF Testline Wait BBMOD
    UUF Wait Times BBMOD Enabled   testline=${testline}
    [Teardown]   Run Keyword If   "${KEYWORD_STATUS}"=="FAIL"
    ...   UUF Save Single Testline Check Point Error   testline=${testline}   check_point=wait_bbmod   error=FAIL


UUF Testline Wait RMOD
    [Arguments]   ${testline}
    Log To Console   UUF Testline Wait RMOD
    UUF Wait Times RU Detected    testline=${testline}    wait_ru_log=${True}
    Log To Console   Enable lmi-eth on
    Return From Keyword If   ${LMI_DEBUG}
    @{command_list}   Create List
    ...    lmi-eth on
    ...    touch /ram/disable_swman_cleanup
    Run Keyword And Ignore Error
    ...    Login to RU via System Module and execute command   testline=${testline}   command_list=${command_list}   cmd_with_sudo=${True}
    [Teardown]   Run Keyword If   "${KEYWORD_STATUS}"=="FAIL"
    ...    UUF Save Single Testline Check Point Error   testline=${testline}   check_point=wait_ru   error=FAIL


UUF Testline Wait Cell
    [Arguments]   ${testline}
    Log To Console   UUF Testline Wait Cell
    UUF Wait Times For Cell OnAir   testline=${testline}   wait_ru_log=${True}
    [Teardown]   Run Keyword If   "${KEYWORD_STATUS}"=="FAIL"
    ...   UUF Save Single Testline Check Point Error   testline=${testline}   check_point=wait_cell   error=FAIL


UUF Testline Wait Fault
    [Arguments]   ${testline}
    Log To Console   UUF Testline Wait Fault
    ${wait_fault_info}   Get Variable Value   ${TL_WAITING_DISAPPEAR_ACTIVE_FAULT["${TESTLINE_IDENTITY}"]}   ${None}
    Return From Keyword If   not ${wait_fault_info}
    ${isList}   Evaluate   "${wait_fault_info.__class__.__name__}"=="list"
    ${isDict}   Evaluate   "${wait_fault_info.__class__.__name__}"=="dict"
    ${fault_list}   Set Variable If   ${isList}   ${wait_fault_info}   ${wait_fault_info["fault_list"]}
    ${retry}   Set Variable If   ${isList}   20m   ${wait_fault_info["retry"]}
    ${retry_interval}   Set Variable If   ${isList}   1m   ${wait_fault_info["retry_interval"]}
    UUF Wait Times Fault Disappear   testline=${testline}   fault_list=${fault_list}   retry=${retry}   retry_interval=${retry_interval}
    [Teardown]   Run Keyword If   "${KEYWORD_STATUS}"=="FAIL"
    ...   UUF Save Single Testline Check Point Error   testline=${testline}   check_point=wait_fault   error=FAIL


UUF Testline Wait Minute
    [Arguments]   ${testline}
    Log To Console   UUF Testline Wait Minute
    Return From Keyword If   ${LMI_DEBUG}
    @{exclude_check_point}   Get Variable Value   ${Exclude_Check_Point_TL["${TESTLINE_IDENTITY}"]["${testline}"]}   @{EMPTY}
    ${UUF_PROCESS}   Get Variable Value   ${UUF_PROCESS}   Prepare
    ${testline_type}   ${testline_index}   Split String   ${testline}   _
    ${waitForMinutesFlag}   Evaluate   ("wait_for_minutes" not in ${exclude_check_point})
    ${waitForMinutesProcess}   Evaluate   ("${UUF_PROCESS}"=="upgrade")
    ${waitForMinutesTestlineType}   Evaluate   ("${testline_type}"!="enb")
    ${needWaitMinutes}   Evaluate   ${waitForMinutesFlag} and ${waitForMinutesProcess} and ${waitForMinutesTestlineType}
    Run Keyword If   ${needWaitMinutes}   Repeat Keyword   5m   UUF Check For Several Minute    testline=${testline}
    [Teardown]   Run Keyword If   "${KEYWORD_STATUS}"=="FAIL"
    ...   UUF Save Single Testline Check Point Error   testline=${testline}   check_point=wait_minute   error=FAIL





# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
UUF Wait Times SMOD Enabled
    [Arguments]   ${testline}   ${retry}=5m   ${retry_interval}=1m
    ${faultId_list}   Wait Until Keyword Succeeds   ${retry}   ${retry_interval}   UUF Wait SMOD Enabled   testline=${testline}
    Run Keyword If   ${faultId_list}   FAIL   msg=SMOD Not Enabled Due To Active Faults: ${faultId_list}

UUF Wait SMOD Enabled
    [Arguments]   ${testline}
    ${hw_info}   coam.get_detected_hw_info   connection=${testline}
    ${smod_list}   Get Variable Value   ${hw_info["systemModules"]}
    FOR   ${smod_info}   IN   @{smod_list}
        ${smod_status}   Get Variable Value   ${smod_info["status"]}

        ${administrativeState}   Get Variable Value   ${smod_status["administrativeState"]}
        ${operationalState}   Get Variable Value   ${smod_status["operationalState"]}
        ${usageState}   Get Variable Value   ${smod_status["usageState"]}
        ${proceduralStatus}   Get Variable Value   ${smod_status["proceduralStatus"]}
        Should Be Equal   ${operationalState.lower()}   enabled
    END


UUF Wait Times BBMOD Enabled
    [Arguments]   ${testline}   ${retry}=15m   ${retry_interval}=1m
    ${faultId_list}   Wait Until Keyword Succeeds   ${retry}   ${retry_interval}   UUF Wait BBMOD Enabled   testline=${testline}
    Run Keyword If   ${faultId_list}   FAIL   msg=BBMOD Not Enabled Due To Active Faults: ${faultId_list}


UUF Wait BBMOD Enabled
    [Arguments]   ${testline}
    ${hw_info}   coam.get_detected_hw_info   connection=${testline}
    ${bbmod_list}   Get Variable Value   ${hw_info["basebandModules"]}
    FOR   ${bbmod_info}   IN   @{bbmod_list}
        ${bbmod_status}   Get Variable Value   ${bbmod_info["status"]}
        ${administrativeState}   Get Variable Value   ${bbmod_status["administrativeState"]}
        ${operationalState}   Get Variable Value   ${bbmod_status["operationalState"]}
        ${usageState}   Get Variable Value   ${bbmod_status["usageState"]}
        ${proceduralStatus}   Get Variable Value   ${bbmod_status["proceduralStatus"]}
        Should Be Equal   ${operationalState.lower()}   enabled
    END


UUF Wait Times RU Detected
    [Arguments]   ${testline}   ${retry}=15m   ${retry_interval}=20s   ${wait_ru_log}=${False}
    ${faultId_list}   Wait Until Keyword Succeeds   ${retry}   ${retry_interval}
    ...    UUF Wait RU Detected   testline=${testline}   wait_ru_log=${wait_ru_log}
    Run Keyword If   ${faultId_list}   FAIL   msg=RU Not Detected Due To Active Faults: ${faultId_list}


UUF Wait RU Detected
    [Arguments]   ${testline}   ${wait_ru_log}=${False}
    # # Check active alarm
    # @{active_alarm_list}   UUF Get Format Alarm List   testline=${testline}   alarm_type=active
    # # ${faultId_list}   Evaluate   [alarm['faultId'] for alarm in ${active_alarm_list} if alarm['faultId'] in ${RU_NOT_DETECTED_ACTIVE_FAULTS}]
    # # Return From Keyword If   ${faultId_list}   ${faultId_list}

    # ${WAIT_RU_DETECTED_LOG}   Get Variable Value   ${WAIT_RU_DETECTED_LOG}   ${True}
    # ${rmod_serial_list}   Get Variable Value   ${ALL_CONFIG_SCF["${testline}"]["rmod_serial_list"]}   @{EMPTY}
    # ${rmod_sn_list}   Evaluate   [alarm['serialNo'] for alarm in ${active_alarm_list} if alarm['serialNo'] in ${rmod_serial_list}]
    # Run Keyword If   ${rmod_sn_list} and ${wait_ru_log} and ${WAIT_RU_DETECTED_LOG}   Run Keywords
    # ...   UUF Catch RU Log   prefix=Wait_RU_Detected   ru_list=${rmod_sn_list}
    # ...   AND
    # ...   Set Test Variable   ${WAIT_RU_DETECTED_LOG}   ${False}
    Run Keyword If   ${wait_ru_log}   Catch RU Log When Detected Active Alarm   testline=${testline}

    Log To Console   //TODO: UUF Wait RU Detected
    ${hw_info}   coam.get_detected_hw_info   connection=${testline}
    ${rmod_status_list}   Create List
    FOR   ${rmod}   IN   @{hw_info['radioModules']['rmod']}
        Append To List   ${rmod_status_list}   ${rmod['status']['proceduralStatus'].lower()}
    END
    List Should Not Contain Value   ${rmod_status_list}   not initialized
    List Should Not Contain Value   ${rmod_status_list}   initializing


UUF Wait Times Fault Disappear
    [Arguments]   ${testline}   ${fault_list}   ${retry}=15m   ${retry_interval}=1m
    ${faultId_list}   Wait Until Keyword Succeeds   ${retry}   ${retry_interval}
    ...   UUF Wait Fault Disappear   testline=${testline}   fault_list=${fault_list}
    Run Keyword If   ${faultId_list}   FAIL   msg=Unexpected Active Faults: ${faultId_list}

UUF Wait Fault Disappear
    [Arguments]   ${testline}   ${fault_list}
    @{active_alarm_list}   UUF Get Format Alarm List   testline=${testline}   alarm_type=active
    ${faultId_list}   Evaluate   [alarm['faultId'] for alarm in ${active_alarm_list} if alarm['faultId'] in ${fault_list}]
    Should Be Empty   ${faultId_list}


UUF Wait Times For Cell OnAir
    [Arguments]   ${testline}   ${retry}=15m   ${retry_interval}=1m   ${wait_ru_log}=${False}
    Log To Console   //TODO: UUF Wait Times For Cell OnAir
    ${faultId_list}   Wait Until Keyword Succeeds   ${retry}   ${retry_interval}
    ...   UUF Wait ALL Cell Link Status   testline=${testline}   wait_ru_log=${wait_ru_log}
    Run Keyword If   ${faultId_list}   FAIL   msg=Cell Not OnAir Due To Active Faults: ${faultId_list}


UUF Wait ALL Cell Link Status
    [Arguments]   ${testline}   ${wait_ru_log}=${False}
    # # Check active alarm
    # @{active_alarm_list}   UUF Get Format Alarm List   testline=${testline}   alarm_type=active
    # # ${faultId_list}   Evaluate   [alarm['faultId'] for alarm in ${active_alarm_list} if alarm['faultId'] in ${CELL_NOT_ONAIR_ACTIVE_FAULTS}]
    # # Return From Keyword If   ${faultId_list}   ${faultId_list}

    # ${WAIT_RU_DETECTED_LOG}   Get Variable Value   ${WAIT_RU_DETECTED_LOG}   ${True}
    # ${rmod_serial_list}   Get Variable Value   ${ALL_CONFIG_SCF["${testline}"]["rmod_serial_list"]}   @{EMPTY}
    # ${rmod_sn_list}   Evaluate   [alarm['serialNo'] for alarm in ${active_alarm_list} if alarm['serialNo'] in ${rmod_serial_list}]
    # Run Keyword If   ${rmod_sn_list} and ${wait_ru_log} and ${WAIT_RU_DETECTED_LOG}   Run Keywords
    # ...   UUF Catch RU Log   prefix=Wait_RU_Detected   ru_list=${rmod_sn_list}
    # ...   AND
    # ...   Set Test Variable   ${WAIT_RU_DETECTED_LOG}   ${False}
    Run Keyword If   ${wait_ru_log}   Catch RU Log When Detected Active Alarm   testline=${testline}
    UUF Wait Cell Onair   testline=${testline}
    UUF Wait X2 Link Status   testline=${testline}
    UUF Wait XP Link Status   testline=${testline}


UUF Wait Cell Onair
    [Arguments]   ${testline}
    Log To Console   //TODO: UUF Wait Cell Onair
    ${bts_info}   coam.get_bts_info   connection=${testline}   timeout=${60}
    ${cell_info}   Run Keyword If   'requestMessage' in @{bts_info.keys()}
    ...   Set Variable   ${bts_info['requestMessage']['cells']}
    ...   ELSE   Set Variable   ${bts_info['cells']}
    # [item for sublist in l for item in sublist]
    ${cell_list}   Get Dictionary Values   ${cell_info}
    ${cell_list}   Evaluate   [item for sublist in ${cell_list} for item in sublist]
    @{serial_console_testline}   Get Variable Value   ${SERIAL_CONSOLE_ACTIVATED_TL["${TESTLINE_IDENTITY}"]}   @{EMPTY}
    ${isSerialConsoleActivated}   Set Variable If   "${testline}" in ${serial_console_testline}   ${True}   ${False}
    FOR   ${cell}   IN   @{cell_list}
        ${operationalState}         Get Variable Value   ${cell['status']['operationalState']}      N/A
        ${usageState}               Get Variable Value   ${cell['status']['usageState']}            N/A
        ${proceduralStatus}         Get Variable Value   ${cell['status']['proceduralStatus']}      N/A
        ${administrativeState}      Get Variable Value   ${cell['status']['administrativeState']}   N/A
        ${availabilityStatus}       Get Variable Value   ${cell['status']['availabilityStatus']}    N/A
        Run Keyword If   "${operationalState}"!="N/A"
        ...   Should Be Equal   ${operationalState.lower()}       enabled
        # # Sometimes usageState=Idle
        # Run Keyword If   "${usageState}"!="N/A"
        # ...   Should Be Equal   ${usageState.lower()}             active
        Run Keyword If   "${proceduralStatus}"!="N/A"
        ...   Should Be Equal   ${proceduralStatus.lower()}       configured
        Run Keyword If   "${administrativeState}"!="N/A"
        ...   Should Be Equal   ${administrativeState.lower()}    unlocked

        Run Keyword And Continue On Failure
        ...   Run Keyword If   "${availabilityStatus}"!="N/A" and (not ${isSerialConsoleActivated})
        ...   Should Not Be Equal   ${availabilityStatus.lower()}   degraded
    END


UUF Wait X2 Link Status
    [Arguments]   ${testline}
    Log To Console   //TODO: UUF Wait X2 Link Status
    ${testline_type}   ${testline_index}   Split String   ${testline}   _
    ${X2_Type}   Get Variable Value   ${ALL_CONFIG_SCF["${testline}"]["X2_Type"]}
    Return From Keyword If   "${X2_Type}"=="${False}"
    ${scf_content}   coam.get_scf   export_type=configurationAndRuntimeObjects   connection=${testline}
    # Check X2 Status on ENB testline
    ${LNADJGNB_element_list}   Get Elements   ${scf_content}   xpath=cmData/managedObject[@class="NOKLTE:LNADJGNB"]
    FOR   ${LNADJGNB_element}   IN   @{LNADJGNB_element_list}
        Exit For Loop If   "${testline_type}"=="gnb"
        ${cPlaneIpAddr}   Get Element Text    ${LNADJGNB_element}   xpath=p[@name="cPlaneIpAddr"]
        Continue For Loop If   "${cPlaneIpAddr}" not in ${ALL_IP_LIST}
        ${x2ToGnbLinkStatus}   Get Element Text    ${LNADJGNB_element}   xpath=p[@name="x2ToGnbLinkStatus"]
        ${administrativeState}   Get Element Text    ${LNADJGNB_element}   xpath=p[@name="administrativeState"]
        Should Be Equal   ${x2ToGnbLinkStatus.lower()}   available
        Should Be Equal   ${administrativeState.lower()}   unlocked
    END

    # Check X2 Status on GNB testline
    ${LTEENB_element_list}   Get Elements   ${scf_content}   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:LTEENB"]
    ${LTEENB_element_length}   Get Length   ${LTEENB_element_list}
    Run Keyword If   "${LTEENB_element_length}"=="0" and "${testline_type}"=="gnb"   FAIL
    FOR   ${LTEENB_element}   IN   @{LTEENB_element_list}
        Exit For Loop If   "${testline_type}"=="enb"
        ${ipAddr}   Get Element Text   ${LTEENB_element}   xpath=p[@name="ipAddr"]
        Continue For Loop If   "${ipAddr}" not in ${ALL_IP_LIST}
        ${x2LinkStatus}   Get Element Text    ${LTEENB_element}   xpath=p[@name="x2LinkStatus"]
        ${x2LinkLock}   Get Element Text    ${LTEENB_element}   xpath=p[@name="x2LinkLock"]
        Should Be Equal   ${x2LinkStatus.lower()}   available
        Should Be Equal   ${x2LinkLock.lower()}   unlocked
    END
    # Check active alarm
    # @{active_alarm_list}   coam.get_active_alarms    connection=${testline}
    # :FOR   ${active_alarm}   IN   @{active_alarm_list}
    #     ${fault_id}   Get Variable Value   ${active_alarm['faultId']}
    #     Run Keyword If   "${fault_id}"=="7300"   Fail
    # END
    @{active_alarm_list}   UUF Get Format Alarm List   testline=${testline}   alarm_type=active
    ${fault_list}   Evaluate   [alarm['faultId'] for alarm in $active_alarm_list]
    List Should Not Contain Value   ${fault_list}   ${7300}


UUF Wait XP Link Status
    [Arguments]   ${testline}
    Log To Console   //TODO: UUF Wait XP Link Status
    ${testline_type}   ${testline_index}   Split String   ${testline}   _
    ${XP_Type}   Get Variable Value   ${ALL_CONFIG_SCF["${testline}"]["XP_Type"]}   ${False}
    Return From Keyword If   "${XP_Type}"=="${False}"
    ${scf_content}   coam.get_scf   export_type=configurationAndRuntimeObjects   connection=${testline}
    # Check XP Status on testline
    ${XPIFREMOTE_R_element_list}   Get Elements   ${scf_content}   xpath=cmData/managedObject[@class="com.nokia.srbts.mnl:XPIFREMOTE_R"]
    FOR   ${XPIFREMOTE_R_element}   IN   @{XPIFREMOTE_R_element_list}
        ${ipAddress}   Get Element Text   ${XPIFREMOTE_R_element}   xpath=p[@name="ipAddress"]
        Continue For Loop If   "${ipAddress}" not in ${ALL_IP_LIST}
        ${xpLinkStatus}   Get Element Text    ${XPIFREMOTE_R_element}   xpath=p[@name="xpLinkStatus"]
        Should Be Equal   ${xpLinkStatus.lower()}   available
    END
    # Check active alarm
    # @{active_alarm_list}   coam.get_active_alarms    connection=${testline}
    # :FOR   ${active_alarm}   IN   @{active_alarm_list}
    #     ${fault_id}   Get Variable Value   ${active_alarm['faultId']}
    #     Run Keyword If   "${fault_id}"=="6129"   Fail
    # END
    @{active_alarm_list}   UUF Get Format Alarm List   testline=${testline}   alarm_type=active
    ${fault_list}   Evaluate   [alarm['faultId'] for alarm in $active_alarm_list]
    List Should Not Contain Value   ${fault_list}   ${6129}


UUF Wait GPS status
    [Arguments]   ${testline}
    Log To Console   //TODO: UUF Check GPS status
    @{syncInputType}   Get Variable Value   ${ALL_CONFIG_SCF["${testline}"]["syncInputType"]}   @{EMPTY}
    Return From Keyword If   "1pps/ToD from external GNSS receiver" not in ${syncInputType}
    # @{active_alarm_list}   coam.get_active_alarms    connection=${testline}
    # :FOR   ${active_alarm}   IN   @{active_alarm_list}
    #     ${fault_id}   Get Variable Value   ${active_alarm['faultId']}
    #     Run Keyword If   "${fault_id}"=="4420"   Fail
    # END
    @{active_alarm_list}   UUF Get Format Alarm List   testline=${testline}   alarm_type=active
    ${fault_list}   Evaluate   [alarm['faultId'] for alarm in $active_alarm_list]
    List Should Not Contain Value   ${fault_list}   ${4420}
    ${gps_status}   coam.get_gnsses_statuses   timeout=${120}   connection=${testline}
    Should Be Equal  ${gps_status['GNSSE_R-1']['administrativeState'].lower()}   unlocked
    # Should Be Equal  ${gps_status['GNSSE_R-1']['availabilityStatus'].lower()}   online
    Should Be Equal  ${gps_status['GNSSE_R-1']['operationalState'].lower()}   enabled


# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
Catch RU Log When Detected Active Alarm
    [Arguments]   ${testline}
    ${UUF_PROCESS}   Get Variable Value   ${UUF_PROCESS}   others
    @{active_alarm_list}   UUF Get Format Alarm List   testline=${testline}   alarm_type=active
    Return From Keyword If   not ${active_alarm_list}
    ${rmod_serial_list}   Get Variable Value   ${ALL_CONFIG_SCF["${testline}"]["rmod_serial_list"]}   @{EMPTY}
    ${serialNo_list}   Evaluate   [alarm['serialNo'] for alarm in ${active_alarm_list} if alarm['serialNo'] in ${rmod_serial_list}]
    Return From Keyword If   not ${serialNo_list}
    @{rmod_sn_list}   Create List
    FOR   ${serialNo}   IN   @{serialNo_list}
        ${faultId_list}   Evaluate   [alarm["faultId"] for alarm in ${active_alarm_list} if alarm['serialNo']=="${serialNo}"]
        ${already_faultId_list}   Get Variable Value   ${WAIT_RU_DETECTED_LOG["${UUF_PROCESS}"]["${serialNo}"]}   @{EMPTY}
        ${already_catch}   Run Keyword And Return Status   List Should Contain Sub List   ${already_faultId_list}   ${faultId_list}
        Continue For Loop If   ${already_catch}
        Append To List   ${rmod_sn_list}   ${serialNo}
        @{record_faultId_list}   Create List   @{already_faultId_list}   @{faultId_list}
        Set To Dictionary   ${WAIT_RU_DETECTED_LOG["${UUF_PROCESS}"]}   ${serialNo}=${record_faultId_list}
    END
    ${time}   DateTime.Get Current Date   UTC   + 8 hours   result_format=%Y-%m-%d-%H_%M_%S
    Run Keyword If   ${rmod_sn_list}   Run Keyword And Ignore Error   UUF Catch RU Log   prefix=Wait_RU_Detected_${time}   ru_list=${rmod_sn_list}
    Log To Console   ${WAIT_RU_DETECTED_LOG}
