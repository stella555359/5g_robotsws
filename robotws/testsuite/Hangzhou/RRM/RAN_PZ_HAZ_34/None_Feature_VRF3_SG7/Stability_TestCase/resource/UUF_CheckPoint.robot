*** Settings ***
Resource   Common.robot

*** Variables ***
${Truck_Roll_Record_File_Path}   ${OUTPUT_DIR}/../Truck_Roll_Record/UUF_Truck_Roll_Detect


*** Keywords ***
# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
# Truck Roll Check
UUF Truck Roll Check
    Return From Keyword If   ${LMI_DEBUG}

    Log To Console   UUF Truck Roll Check Start...
#     ${Truck_Roll_Detect}   Run Keyword And Return Status   File Should Not Be Empty   ${Truck_Roll_Record_File_Path}
#     ${truck_roll_msg}   Run Keyword If   ${Truck_Roll_Detect}   Get File   ${Truck_Roll_Record_File_Path}
#     Run Keyword If   ${Truck_Roll_Detect}   Fatal Error   msg=${truck_roll_msg}

    @{check_sequence}   Create List   @{ALL_GNB_LIST}   @{ALL_ENB_LIST}
    FOR   ${testline}   IN   @{check_sequence}
        Single Testline Truck Roll Check   testline=${testline}
    END
    run keyword if   ('${TESTLINE_IDENTITY}' in ${UUF_L3Call})    UUF L3CALL Check
    Log To Console   UUF Truck Roll Check Finished...


Single Testline Truck Roll Check
    [Arguments]   ${testline}
    Log To Console   Checking ${testline}...

    ${testline_type}   ${testline_index}   Split String   ${testline}   _

    ${webem_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_addr']}
    ${webem_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_username']}
    ${webem_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_password']}
    ${mplane_login}   Run Keyword And Return Status   COAM Login
    ...   bts_host=${webem_addr}
    ...   username=${webem_username}
    ...   password=${webem_password}
    ...   alias=${testline}

    Run Keyword If   not ${mplane_login}
    ...   Fatal Error   msg=Truck Roll Detect, BTS is not reachable (WebEM connection cannot be established) via M-Plane


    # Trunk Roll Fault + Extra Stop Flag
    @{Active_Extra_Stop_Flag}   Get Variable Value   ${Extra_Stop_Flag_TL["${TESTLINE_IDENTITY}"]["${testline}"]["active"]}   @{EMPTY}
    @{truck_roll_fault}   Create List   @{Trunk_Roll_Fault_List}   @{Active_Extra_Stop_Flag}
    # ${active_alarms}   coam.get_active_alarms    connection=${testline}
    @{active_alarms}   UUF Get Format Alarm List   testline=${testline}   alarm_type=active
    FOR   ${active_alarm}    IN   @{active_alarms}
        ${faultId}   Get Variable Value   ${active_alarm['faultId']}   ${EMPTY}
        Continue For Loop If   "${faultId}"=="${EMPTY}"

        ${truck_roll_detect}   Run Keyword And Return Status
        ...   Collections.List Should Contain Value   ${truck_roll_fault}   ${faultId}
        # Run Keyword If   ${truck_roll_detect}
        # ...   OperatingSystem.Create File   path=${Truck_Roll_Record_File_Path}   content=Truck Roll Detect, Fault ID: ${faultId}
        Run Keyword If   ${truck_roll_detect}
        ...   Fatal Error   msg=Truck Roll Detect, Fault ID: ${faultId}
    END

    @{History_Extra_Stop_Flag}   Get Variable Value   ${Extra_Stop_Flag_TL["${TESTLINE_IDENTITY}"]["${testline}"]["history"]}   @{EMPTY}
    Return From Keyword If   len(${History_Extra_Stop_Flag})==0
    ${history_alarms}   coam.get_historic_alarms   load_history=${True}   connection=${testline}   timeout=${600}
    FOR   ${history_alarm}    IN   @{history_alarms}
        ${truck_roll_detect}   Run Keyword And Return Status
        ...   Collections.List Should Contain Value   ${History_Extra_Stop_Flag}   ${history_alarm['faultId']}
        # Run Keyword If   ${truck_roll_detect}
        # ...   OperatingSystem.Create File  path=${Truck_Roll_Record_File_Path}  content=Extra Stop Flag Detect, Fault ID: ${active_alarm['faultId']}
        Run Keyword If   ${truck_roll_detect}
        ...   Fatal Error   msg=Extra Stop Flag Check Failed, Fault ID: ${history_alarm['faultId']}
    END

    [Teardown]   Run Keyword And Ignore Error   COAM Logout   connection=${testline}


# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
UUF Check Point Process
    [Arguments]   ${testline}
    Run Keyword And Continue On Failure   UUF Initialize Single Testline Check Point Error
    Run Keyword And Continue On Failure   UUF Upgraded Testline Wait   testline=${testline}
    Run Keyword And Continue On Failure   UUF Upgraded Testline Check Point   testline=${testline}
    Run Keyword And Continue On Failure   UUF Wait Other Testline   exclude_testline=${testline}
    Run Keyword And Continue On Failure   UUF ALL Check Point   uuf_process_testline=${testline}
    [Teardown]   UUF Save ALL Check Point Error   testline=${testline}

# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
UUF Upgraded Testline Check Point
    [Arguments]   ${testline}
    Log To Console   UUF Upgraded Testline Check Point
    @{exclude_check_point}   Get Variable Value   ${Exclude_Check_Point_TL["${TESTLINE_IDENTITY}"]["${testline}"]}   @{EMPTY}

    Run Keyword If   not ${LMI_DEBUG}   Run Keyword And Continue On Failure   Run Keyword If   "sw_upgrade_downtime" not in ${exclude_check_point}
    ...   UUF Check SW Upgrade Downtime     testline=${testline}    save_execution_results=${True}
    Run Keyword If   not ${LMI_DEBUG}   Run Keyword And Continue On Failure   Run Keyword If   "validate_error" not in ${exclude_check_point}
    ...   UUF Check Validation Error        testline=${testline}
    Run Keyword If   not ${LMI_DEBUG}   Run Keyword And Continue On Failure   Run Keyword If   "sw_version" not in ${exclude_check_point}
    ...   UUF Check SW Version              testline=${testline}
    Run Keyword If   not ${LMI_DEBUG}   Run Keyword And Continue On Failure   Run Keyword If   "syslog_error" not in ${exclude_check_point}
    ...   UUF Check Syslog Error   testline=${testline}

    Run Keyword And Continue On Failure   Run Keyword If   "nms_status" not in ${exclude_check_point}   UUF Check NMS Status   testline=${testline}
    Run Keyword And Continue On Failure   Run Keyword If   "amf_status" not in ${exclude_check_point}   UUF Check AMF Status   testline=${testline}
    Run Keyword And Continue On Failure   Run Keyword If   "pm_report" not in ${exclude_check_point}    UUF Check PM Report    testline=${testline}

    Run Keyword If   not ${LMI_DEBUG}   Run Keyword And Continue On Failure
    ...   Wait Until Keyword Succeeds   20m   1m   UUF Wait GPS status   testline=${testline}

    Run Keyword And Continue On Failure   Run Keyword If   "netact_operations" not in ${exclude_check_point}
    ...   UUF Check NetAct Operations     testline=${testline}

    [Teardown]   Run Keyword And Ignore Error   COAM Logout   connection=${testline}


UUF ALL Check Point
    [Arguments]   ${uuf_process_testline}
    Log To Console   UUF ALL Check Point
    ${check_sequence}   Create List   @{ALL_GNB_LIST}   @{ALL_ENB_LIST}
    FOR   ${testline}   IN   @{check_sequence}
        Single Testline ALL Check Point   testline=${testline}   uuf_process_testline=${uuf_process_testline}
    END

Single Testline ALL Check Point
    [Arguments]   ${testline}   ${uuf_process_testline}
    Log To Console   UUF ALL Check Point: ${testline}

    ${testline_type}   ${testline_index}   Split String   ${testline}   _

    ${webem_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_addr']}
    ${webem_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_username']}
    ${webem_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_password']}
    ${coam_login_succeed}   Run Keyword And Return Status   Wait Until Keyword Succeeds   5m   1m   COAM Login
    ...   bts_host=${webem_addr}
    ...   username=${webem_username}
    ...   password=${webem_password}
    ...   alias=${testline}

    Run Keyword If   not ${coam_login_succeed}
    ...   UUF Save Single Testline Check Point Error   testline=${testline}   check_point=coam_login   error=FAIL
    Return From Keyword If   not ${coam_login_succeed}

    #ALL
    @{exclude_check_point}   Get Variable Value   ${Exclude_Check_Point_TL["${TESTLINE_IDENTITY}"]["${testline}"]}   @{EMPTY}

    Run Keyword And Continue On Failure   Run Keyword If   "active_faults" not in ${exclude_check_point}
    ...   UUF Check Active Faults       testline=${testline}   uuf_process_testline=${uuf_process_testline}   save_execution_results=${True}
    Run Keyword And Continue On Failure   Run Keyword If   "history_faults" not in ${exclude_check_point}
    ...   UUF Check History Faults      testline=${testline}   uuf_process_testline=${uuf_process_testline}   save_execution_results=${True}

    Run Keyword And Continue On Failure   Run Keyword If   "blackbox" not in ${exclude_check_point}
    ...   UUF Check Blackbox            testline=${testline}   save_execution_results=${True}
    Run Keyword And Continue On Failure   Run Keyword If   "hardware_status" not in ${exclude_check_point}
    ...   UUF Check HW Status           testline=${testline}
    Run Keyword And Continue On Failure   Run Keyword If   "cablink_status" not in ${exclude_check_point}
    ...   UUF Check Cablink Status      testline=${testline}
    Run Keyword And Continue On Failure   Run Keyword If   "cell_status" not in ${exclude_check_point}
    ...   UUF Check Cell Status         testline=${testline}


    [Teardown]   Run Keyword And Ignore Error   COAM Logout   connection=${testline}

# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
UUF Select Check Point
    [Arguments]   ${testline}   ${check_point_list}=@{EMPTY}   ${save_check_point}=${True}

    # ${testline_type}   ${testline_index}   Split String   ${testline}   _

    # ${webem_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_addr']}
    # ${webem_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_username']}
    # ${webem_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_password']}
    # COAM Login
    # ...   bts_host=${webem_addr}
    # ...   username=${webem_username}
    # ...   password=${webem_password}
    # ...   alias=${testline}

    @{include_check_point}   Set Variable If   "${check_point_list}"=="@{EMPTY}"   ${Check_Point_Type}   ${check_point_list}
    @{exclude_check_point}   Get Variable Value   ${Exclude_Check_Point_TL["${TESTLINE_IDENTITY}"]["${testline}"]}   @{EMPTY}

    Remove Values From List   ${include_check_point}   @{exclude_check_point}

    Run Keyword And Continue On Failure   Run Keyword If   "cell_status" in ${include_check_point}
    ...   UUF Check Cell Status             testline=${testline}   save_check_point=${save_check_point}
    Run Keyword And Continue On Failure   Run Keyword If   "hardware_status" in ${include_check_point}
    ...   UUF Check HW Status               testline=${testline}   save_check_point=${save_check_point}
    Run Keyword And Continue On Failure   Run Keyword If   "cablink_status" in ${include_check_point}
    ...   UUF Check Cablink Status          testline=${testline}   save_check_point=${save_check_point}
    Run Keyword And Continue On Failure   Run Keyword If   "active_faults" in ${include_check_point}
    ...   UUF Check Active Faults           testline=${testline}   save_check_point=${save_check_point}
    Run Keyword And Continue On Failure   Run Keyword If   "history_faults" in ${include_check_point}
    ...   UUF Check History Faults          testline=${testline}   save_check_point=${save_check_point}
    Run Keyword And Continue On Failure   Run Keyword If   "sw_version" in ${include_check_point}
    ...   UUF Check SW Version              testline=${testline}   save_check_point=${save_check_point}
    Run Keyword And Continue On Failure   Run Keyword If   "sw_upgrade_downtime" in ${include_check_point}
    ...   UUF Check SW Upgrade Downtime     testline=${testline}   save_check_point=${save_check_point}
    Run Keyword And Continue On Failure   Run Keyword If   "validate_error" in ${include_check_point}
    ...   UUF Check Validation Error        testline=${testline}   save_check_point=${save_check_point}
    Run Keyword And Continue On Failure   Run Keyword If   "nms_status" in ${include_check_point}
    ...   UUF Check NMS Status              testline=${testline}   save_check_point=${save_check_point}
    Run Keyword And Continue On Failure   Run Keyword If   "amf_status" in ${include_check_point}
    ...   UUF Check AMF Status              testline=${testline}   save_check_point=${save_check_point}
    Run Keyword And Continue On Failure   Run Keyword If   "blackbox" in ${include_check_point}
    ...   UUF Check Blackbox                testline=${testline}   save_check_point=${save_check_point}
    Run Keyword And Continue On Failure   Run Keyword If   "pm_report" in ${include_check_point}
    ...   UUF Check PM Report               testline=${testline}   save_check_point=${save_check_point}

    # [Teardown]   COAM Logout   connection=${testline}


UUF Check Testlines Status
    [Arguments]   ${testline_list}=ALL   ${check_point_list}=@{EMPTY}   ${save_check_point}=${True}
    # Log To Console   //TODO: UUF Check Testlines Status
    # # UUF Truck Roll Check

    Run Keyword If   ${save_check_point}   UUF Initialize ALL Check Point Error

    @{check_sequence}   Run Keyword If   "${testline_list}"=="ALL"   Create List   @{ALL_GNB_LIST}   @{ALL_ENB_LIST}
    ...   ELSE   Create List   @{testline_list}

    @{check_point_list}   Run Keyword If   "${check_point_list}"=="@{EMPTY}" or "${check_point_list}"=="" or "${check_point_list}"=="${None}"
    ...   Create List   cell_status   hardware_status   cablink_status   active_faults   validate_error   nms_status
       # history_faults   blackbox
    ...   ELSE   Create List   @{check_point_list}


    FOR   ${testline}   IN   @{check_sequence}
        Run Keyword If   ${save_check_point}   UUF Initialize Single Testline Check Point Error

        ${webem_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_addr']}
        ${webem_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_username']}
        ${webem_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_password']}
        ${coam_login_succeed}   Run Keyword And Return Status   COAM Login
        ...   bts_host=${webem_addr}
        ...   username=${webem_username}
        ...   password=${webem_password}
        ...   alias=${testline}

        Run Keyword If   not ${coam_login_succeed}
        ...   UUF Save Single Testline Check Point Error   testline=${testline}   check_point=coam_login   error=FAIL
        Continue For Loop If   not ${coam_login_succeed}

        Run Keyword And Continue On Failure
        ...   UUF Select Check Point   testline=${testline}   check_point_list=${check_point_list}   save_check_point=${save_check_point}

        Run Keyword And Continue On Failure   Run Keyword If   ${save_check_point}
        ...   UUF Save ALL Check Point Error   testline=${testline}   snapshot=${False}   check_exit=${False}

        Run Keyword And Ignore Error   COAM Logout   connection=${testline}
    END


# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
# Below Check Point In All Testline
UUF Check Cell Status
    [Arguments]   ${testline}   ${save_check_point}=${True}   ${log_to_console}=${True}
    Run Keyword If   ${log_to_console}
    ...   Log To Console   //TODO: UUF Check Cell Status

    # # gNB, X2 eNB, all concurrent eNBs
    # ${check_sequence}   Create List   @{ALL_GNB_LIST}   @{ALL_ENB_LIST}
    # Return From Keyword If   "${testline}" not in ${check_sequence}

    ${bts_info}   coam.get_bts_info   connection=${testline}   timeout=${60}
    ${cell_info}   Run Keyword If   'requestMessage' in @{bts_info.keys()}
    ...   Set Variable   ${bts_info['requestMessage']['cells']}
    ...   ELSE   Set Variable   ${bts_info['cells']}
    # [item for sublist in l for item in sublist]
    ${cell_list}   Get Dictionary Values   ${cell_info}
    ${cell_list}   Evaluate   [item for sublist in ${cell_list} for item in sublist]

    ${cell_number}   Get Length   ${cell_list}
    Run Keyword If   "${cell_number}"=="0"   Fail   msg=Cell Configuration Missing.

    @{serial_console_testline}   Get Variable Value   ${SERIAL_CONSOLE_ACTIVATED_TL["${TESTLINE_IDENTITY}"]}   @{EMPTY}
    ${isSerialConsoleActivated}   Set Variable If   "${testline}" in ${serial_console_testline}   ${True}   ${False}

    FOR   ${cell}   IN   @{cell_list}
        # # Should Be Equal   ${cell['status']['administrativeState']}   Unlocked
        # Should Be Equal   ${cell['status']['operationalState'].lower()}   enabled
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
    [Teardown]   Run Keyword If   "${KEYWORD_STATUS}"=="FAIL" and ${save_check_point}
    ...   UUF Save Single Testline Check Point Error   testline=${testline}   check_point=cell_status   error=FAIL


UUF Check HW Status
    [Arguments]   ${testline}   ${save_check_point}=${True}
    Log To Console   //TODO: UUF Check HW Status

    Return From Keyword If   "${testline}" in ${X2_ENB_LIST}



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

    ${bbmod_list}   Get Variable Value   ${hw_info["basebandModules"]}
    FOR   ${bbmod_info}   IN   @{bbmod_list}
        ${bbmod_status}   Get Variable Value   ${bbmod_info["status"]}

        ${administrativeState}   Get Variable Value   ${bbmod_status["administrativeState"]}
        ${operationalState}   Get Variable Value   ${bbmod_status["operationalState"]}
        ${usageState}   Get Variable Value   ${bbmod_status["usageState"]}
        ${proceduralStatus}   Get Variable Value   ${bbmod_status["proceduralStatus"]}

        Should Be Equal   ${operationalState.lower()}   enabled
    END

    ${rmod_list}   Get Variable Value   ${hw_info["radioModules"]["rmod"]}
    FOR   ${rmod_info}   IN   @{rmod_list}
        ${rmod_status}   Get Variable Value   ${rmod_info["status"]}

        ${administrativeState}   Get Variable Value   ${rmod_status["administrativeState"]}
        ${operationalState}   Get Variable Value   ${rmod_status["operationalState"]}
        ${usageState}   Get Variable Value   ${rmod_status["usageState"]}
        ${proceduralStatus}   Get Variable Value   ${rmod_status["proceduralStatus"]}

        Should Be Equal   ${operationalState.lower()}   enabled
    END
    [Teardown]   Run Keyword If   "${KEYWORD_STATUS}"=="FAIL" and ${save_check_point}
    ...   UUF Save Single Testline Check Point Error   testline=${testline}   check_point=hardware_status   error=FAIL


UUF Check Cablink Status
    [Arguments]   ${testline}   ${save_check_point}=${True}
    Log To Console   //TODO: UUF Check Cablink Status

    Return From Keyword If   "${testline}" in ${X2_ENB_LIST}


    ${hw_info}   coam.get_detected_hw_info   connection=${testline}

    ${cable_list}   Get Variable Value   ${hw_info["cables"]}
    FOR   ${cable_info}   IN   @{cable_list}
        ${cable_status}   Get Variable Value   ${cable_info["status"]}

        ${operationalState}   Get Variable Value   ${cable_status["operationalState"]}
        Should Be Equal   ${operationalState.lower()}   enabled
    END
    [Teardown]   Run Keyword If   "${KEYWORD_STATUS}"=="FAIL" and ${save_check_point}
    ...   UUF Save Single Testline Check Point Error   testline=${testline}   check_point=cablink_status   error=FAIL


UUF Check Active Faults
    [Arguments]   ${testline}   ${uuf_process_testline}=NONE
    ...   ${save_check_point}=${True}   ${save_execution_results}=${False}
    ...   ${log_to_console}=${True}
    Run Keyword If   ${log_to_console}
    ...   Log To Console   //TODO: UUF Check Active Faults

    Return From Keyword If   "${testline}" in ${X2_ENB_LIST}

    #Check The Testline is the UUF Process Testline
    ${notProcessTestline}   Set Variable If   "${testline}"!="${uuf_process_testline}"   ${True}   ${False}

    # # If Software Upgrade Don't Need Reset. Add Some NotReset Alarm.
    ${swPrecheckNeedReset}   Get Variable Value   ${swPrecheckNeedReset}   ${True}
    @{software_not_reset_whitelist}   Run Keyword If   not ${swPrecheckNeedReset}
    ...   Get Variable Value   ${SOFTWARE_NOT_RESET_ALLOWED_ACTIVE_FAULTS}   @{EMPTY}

    # # If Process=Prepare, Add prepare allowed active fault.
    ${UUF_PROCESS}   Get Variable Value   ${UUF_PROCESS}   Prepare
    @{prepare_whitelist}   Run Keyword If   "${UUF_PROCESS}"=="Prepare"
    ...   Get Variable Value   ${ALLOWED_ACTIVE_FAULTS_PREPARE}   @{EMPTY}

    # # If Current testline not upgrade yet, Add prepare allowed active fault.
    ${testline_type}   ${testline_index}   Split String   ${testline}   _
    ${source_package_version}   Set Variable   ${UPGRADE_BUILD_INFO_DICT['${testline_type}']['source']['version']}
    ${software_dict}   UUF Get Software Version   testline=${testline}
    ${active_version}   Get Variable Value   ${software_dict["active_version"]}
    @{source_whitelist}   Run Keyword If   "${source_package_version}"=="${active_version}"
    ...   Get Variable Value   ${ALLOWED_ACTIVE_FAULTS_PREPARE}   @{EMPTY}

    # # Serial Console Activated Testline
    @{serial_console_testline}   Get Variable Value   ${SERIAL_CONSOLE_ACTIVATED_TL["${TESTLINE_IDENTITY}"]}   @{EMPTY}
    @{serial_whitelist}   Run Keyword If   "${testline}" in ${serial_console_testline}
    ...   Get Variable Value   ${SERIAL_CONSOLE_ACTIVE_FAULTS}   @{EMPTY}

    # # DSS Whitelist
    ${XP_Type}   Get Variable Value   ${ALL_CONFIG_SCF["${testline}"]["XP_Type"]}   ${False}
    @{dss_whitelist}   Run Keyword If   ${XP_Type}
    ...   Get Variable Value   ${DSS_ACTIVE_FAULTS}   @{EMPTY}

    # # Testline Whitelist
    @{testline_whitelist}   Get Variable Value   ${TL_SPECIFIC_ALLOWED_ACTIVE_FAULTS["${TESTLINE_IDENTITY}"]}   @{EMPTY}

    # # Special Testline Whitelist
    # ${condition}   Evaluate   (not ${swPrecheckNeedReset}) or (${notProcessTestline} and len(${ALL_SAME_RU_TESTLINE_MAPPING["${testline}"]})>=2)
    ${condition}   Evaluate   (not ${swPrecheckNeedReset}) or (len(${ALL_SAME_RU_TESTLINE_MAPPING["${testline}"]})>=2)
    @{concurrent_whitelist}   Run Keyword If   ${isConCurrent} and ${condition}
    ...   Get Variable Value   ${CONCURRENT_ALLOWED_ACTIVE_FAULTS}   @{EMPTY}
    @{moran_whitelist}   Run Keyword If   ${isMoRAN} and ${condition}
    ...   Get Variable Value   ${MORAN_ALLOWED_ACTIVE_FAULTS}   @{EMPTY}

    @{ALLOWED_ACTIVE_FAULTS}   Create List
    ...   @{ALLOWED_ACTIVE_FAULTS}
    ...   @{testline_whitelist}
    ...   @{concurrent_whitelist}
    ...   @{moran_whitelist}
    ...   @{prepare_whitelist}
    ...   @{source_whitelist}
    ...   @{serial_whitelist}
    ...   @{dss_whitelist}
    ...   @{software_not_reset_whitelist}

    @{active_alarm_list}   UUF Get Format Alarm List   testline=${testline}   alarm_type=active

    Log   ${ALL_CONFIG_SCF["${testline}"]}

    @{Unexpected_fault_active}   Create List
    FOR   ${active_alarm}   IN   @{active_alarm_list}

        ${faultId}   Set Variable   ${active_alarm['faultId']}
        ${serialNo}   Set Variable   ${active_alarm['serialNo']}
        ${configObjectName}   Set Variable   ${active_alarm['configObjectName']}

        ${hardware_type}   Get Variable Value   ${ALL_CONFIG_SCF["${testline}"]["rmod_serial_mapping"]["${serialNo}"]["productName"]}   NA

        # Get Hardware Type If dist_name is CABLINK
        ${isCablink}   Run Keyword And Return Status   Should Contain   ${configObjectName}   CABLINK
        ${rmod_dn}   Run Keyword If   ${isCablink}
        ...   Get Variable Value   ${ALL_CONFIG_SCF["${testline}"]["cablink_mapping"]["${configObjectName}"]}   NA
        ...   ELSE   Set Variable   NA
        ${isRMOD}   Run Keyword And Return Status   Should Contain   ${rmod_dn}   RMOD
        ${hardware_type}   Run Keyword If   ${isRMOD}
        ...   Get Variable Value   ${ALL_CONFIG_SCF["${testline}"]["rmod_dn_mapping"]["${rmod_dn}"]}   NA
        ...   ELSE   Set Variable   ${hardware_type}

        @{allowed_ru_white_list}   Get Variable Value   ${RU_ALLOWED_ACTIVE_FAULTS[${faultId}]}   @{EMPTY}

        Run Keyword If   ${faultId} not in ${ALLOWED_ACTIVE_FAULTS} and "${hardware_type}" not in ${allowed_ru_white_list}
        ...   Run Keywords   Run Keyword If   ${save_check_point}
        ...   UUF Save Single Testline Check Point Error   testline=${testline}   check_point=active_faults   error=${faultId}_${configObjectName}
        ...   AND
        ...   Append To List   ${Unexpected_fault_active}   ${active_alarm}
    END

    ${testline_type}   ${testline_index}   Split String   ${testline}   _
    ${webem_addr}   Get Variable Value   ${ALL_CONFIG_INIT['${testline}']['webem_addr']}   ${testline}
    ${add_key}   Set Variable If   "${testline_type}"=="enb"   eNB_active_alarm   active_alarm
    ${add_value}   Run Keyword If   "${testline_type}"=="enb"   Create Dictionary   ${webem_addr}=${Unexpected_fault_active}
    ...   ELSE   Set Variable   ${Unexpected_fault_active}

    Should Be Empty   ${Unexpected_fault_active}
    [Return]   ${Unexpected_fault_active}
    [Teardown]   Run Keyword And Ignore Error   Run Keyword If   "${KEYWORD_STATUS}"=="FAIL" and ${save_execution_results}
    ...   UUF Save Execution Results JSON Dictionary
    ...   action=${UUF_PROCESS}   add_key=${add_key}   add_value=${add_value}


UUF Check History Faults
    [Arguments]   ${testline}   ${uuf_process_testline}=NONE   ${save_check_point}=${True}   ${save_execution_results}=${False}
    Log To Console   //TODO: UUF Check History Faults

    Return From Keyword If   "${testline}" in ${X2_ENB_LIST}

    #Check The Testline is the UUF Process Testline
    ${notProcessTestline}   Set Variable If   "${testline}"!="${uuf_process_testline}"   ${True}   ${False}

    # # If Software Upgrade Don't Need Reset. Add Some NotReset Alarm.
    ${swPrecheckNeedReset}   Get Variable Value   ${swPrecheckNeedReset}   ${True}
    @{software_not_reset_whitelist}   Run Keyword If   not ${swPrecheckNeedReset}
    ...   Get Variable Value   ${SOFTWARE_NOT_RESET_ALLOWED_HISTORY_FAULTS}   @{EMPTY}

    # # Testline Whitelist
    @{testline_whitelist}   Get Variable Value   ${TL_SPECIFIC_ALLOWED_HISTORY_FAULTS["${TESTLINE_IDENTITY}"]}   @{EMPTY}

    # # Special Testline Whitelist
    ${condition}   Evaluate   (not ${swPrecheckNeedReset}) or (${notProcessTestline} and len(${ALL_SAME_RU_TESTLINE_MAPPING["${testline}"]})>=2)
    @{concurrent_whitelist}   Run Keyword If   ${isConCurrent} and ${condition}
    ...   Get Variable Value   ${CONCURRENT_ALLOWED_HISTORY_FAULTS}   @{EMPTY}
    @{moran_whitelist}   Run Keyword If   ${isMoRAN} and ${condition}
    ...   Get Variable Value   ${MORAN_ALLOWED_HISTORY_FAULTS}   @{EMPTY}

    # # DSS whitelist
    ${XP_Type}   Get Variable Value   ${ALL_CONFIG_SCF["${testline}"]["XP_Type"]}   ${False}
    @{dss_whitelist}   Run Keyword If   ${XP_Type}
    ...   Get Variable Value   ${DSS_HISTORY_FAULTS}   @{EMPTY}

    @{ALLOWED_HISTORY_FAULTS}   Create List
    ...   @{ALLOWED_HISTORY_FAULTS}
    ...   @{testline_whitelist}
    ...   @{concurrent_whitelist}
    ...   @{moran_whitelist}
    ...   @{dss_whitelist}
    ...   @{software_not_reset_whitelist}

    # @{history_alarm_list}   coam.get_historic_alarms
    # ...   load_history=${True}
    # ...   connection=${testline}
    # ...   timeout=${600}

    @{history_alarm_list}   UUF Get Format Alarm List   testline=${testline}   alarm_type=history

    Log   ${ALL_CONFIG_SCF["${testline}"]}

    @{Unexpected_fault_history}   Create List
    FOR   ${history_alarm}   IN   @{history_alarm_list}
        ${faultId}   Set Variable   ${history_alarm['faultId']}
        ${serialNo}   Set Variable   ${history_alarm['serialNo']}
        ${configObjectName}   Set Variable   ${history_alarm['configObjectName']}
        ${appeardTimeStamp}   Set Variable   ${history_alarm['appeardTimeStamp']}
        ${clearedTimeStamp}   Set Variable   ${history_alarm['clearedTimeStamp']}

        ${UUF_START_TIMESTAMP}   Get Variable Value   ${UUF_PROCESS_START}   ${SUITE_SETUP_START}
        Continue For Loop If   ${appeardTimeStamp} < ${UUF_START_TIMESTAMP}

        ${hardware_type}   Get Variable Value   ${ALL_CONFIG_SCF["${testline}"]["rmod_serial_mapping"]["${serialNo}"]["productName"]}   NA

        # Get Hardware Type If dist_name is CABLINK
        ${isCablink}   Run Keyword And Return Status   Should Contain   ${configObjectName}   CABLINK
        ${rmod_dn}   Run Keyword If   ${isCablink}
        ...   Get Variable Value   ${ALL_CONFIG_SCF["${testline}"]["cablink_mapping"]["${configObjectName}"]}   NA
        ...   ELSE   Set Variable   NA
        ${isRMOD}   Run Keyword And Return Status   Should Contain   ${rmod_dn}   RMOD
        ${hardware_type}   Run Keyword If   ${isRMOD}
        ...   Get Variable Value   ${ALL_CONFIG_SCF["${testline}"]["rmod_dn_mapping"]["${rmod_dn}"]}   NA
        ...   ELSE   Set Variable   ${hardware_type}

        @{allowed_ru_white_list}   Get Variable Value   ${RU_ALLOWED_HISTORY_FAULTS[${faultId}]}   @{EMPTY}

        Run Keyword If   ${faultId} not in ${ALLOWED_HISTORY_FAULTS} and "${hardware_type}" not in ${allowed_ru_white_list}
        ...   Run Keywords   Run Keyword If   ${save_check_point}
        ...   UUF Save Single Testline Check Point Error   testline=${testline}   check_point=history_faults   error=${faultId}_${serialNo}   AND
        ...   Append To List   ${Unexpected_fault_history}   ${history_alarm}
    END

    ${testline_type}   ${testline_index}   Split String   ${testline}   _
    ${webem_addr}   Get Variable Value   ${ALL_CONFIG_INIT['${testline}']['webem_addr']}   ${testline}
    ${add_key}   Set Variable If   "${testline_type}"=="enb"   eNB_history_alarm   history_alarm
    ${add_value}   Run Keyword If   "${testline_type}"=="enb"   Create Dictionary   ${webem_addr}=${Unexpected_fault_history}
    ...   ELSE   Set Variable   ${Unexpected_fault_history}

    Should Be Empty   ${Unexpected_fault_history}
    [Return]   ${Unexpected_fault_history}
    [Teardown]   Run Keyword And Ignore Error   Run Keyword If   "${KEYWORD_STATUS}"=="FAIL" and ${save_execution_results}
    ...   UUF Save Execution Results JSON Dictionary
    ...   action=${UUF_PROCESS}   add_key=${add_key}   add_value=${add_value}


UUF Check Blackbox
    [Arguments]   ${testline}   ${save_check_point}=${True}   ${save_execution_results}=${False}
    Log To Console   //TODO: UUF Check Blackbox

    Return From Keyword If   "${testline}" in ${X2_ENB_LIST}

    ${UUF_START_TIMESTAMP}   Get Variable Value   ${UUF_PROCESS_START}   ${SUITE_SETUP_START}

    ${ssh_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['ssh_addr']}
    ${ssh_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['ssh_username']}
    ${ssh_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['ssh_password']}

    csn.Connect to   hostname=${ssh_addr}   username=${ssh_username}   password=${ssh_password}   alias=${testline}
    ${blackbox}   csn.Execute   command=cd /ffs/run/config/lifedata;cat blackbox   timeout=${300}   connection=${testline}
    @{blackbox_split}   Split String   ${blackbox}   \r\n

    @{blackbox_info_list}   Create List
    FOR   ${blackbox_line}   IN   @{blackbox_split}
        ${isoutctime}   Set Variable   ${blackbox_line[:24]}
        ${status}   Run Keyword And Return Status
        ...   Should Match Regexp   ${isoutctime}   \\d{4}-[01]\\d-[0-3]\\dT[0-2]\\d:[0-5]\\d:[0-5]\\d\.\\d+([+-][0-2]\\d:[0-5]\\d|Z)
        Continue For Loop If   not ${status}
        ${datetime}   DateTime.Convert Date   date=${isoutctime}+0000   result_format=datetime   date_format=%Y-%m-%dT%H:%M:%S.%fZ%z
        ${timestamp}   Evaluate   dateutil.parser.parse("${datetime.isoformat()}").timestamp()   dateutil.parser,dateutil
        Run Keyword If   ${timestamp} > ${UUF_START_TIMESTAMP}   Append To List   ${blackbox_info_list}   ${blackbox_line}
    END

    @{Extra_Reset}   Create List
    ...   System module site reset : Recovery (Execute reset.)
    ...   probably SW crash
    ...   Recovery (Execute reset.)
    ...   Watchdog reset
    FOR   ${blackbox_info}   IN   @{blackbox_info_list}
        ${is_Extra_Reset}   Evaluate   any(s in "${blackbox_info}" for s in ${Extra_Reset})
        Run Keyword If   ${is_Extra_Reset}   Fail   msg=BlackBox Unexpected Reset Happen: ${blackbox_info}
    END
    [Teardown]   Run Keywords
    ...   Run Keyword And Ignore Error   csn.Disconnect   connection=${testline}
    ...   AND
    ...   Run Keyword And Ignore Error   Run Keyword If   "${KEYWORD_STATUS}"=="FAIL" and ${save_check_point}
    ...   UUF Save Single Testline Check Point Error   testline=${testline}   check_point=blackbox   error=FAIL
    ...   AND
    ...   Run Keyword And Ignore Error   Run Keyword If   "${KEYWORD_STATUS}"=="FAIL" and ${save_execution_results}
    ...   UUF Save Execution Results JSON Dictionary   action=${UUF_PROCESS}   add_key=blackbox   add_value=${blackbox_info}


# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
# Below Check Point Only Check in the upgrade testline
UUF Check For Several Minute
    [Arguments]   ${testline}
    UUF Check Cell Status   testline=${testline}   log_to_console=${False}
    UUF Check Active Faults   testline=${testline}   log_to_console=${False}
    Sleep   10s


UUF Check SW Version
    [Arguments]   ${testline}   ${save_check_point}=${True}   ${package_type}=NONE   ${needConnect}=${False}   ${passive_check}=${False}
    Log To Console   //TODO: UUF Check SW Version

    ${testline_type}   ${testline_index}   Split String   ${testline}   _
    ${webem_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_addr']}
    ${webem_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_username']}
    ${webem_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_password']}

    Run Keyword If   ${needConnect}
    ...   COAM Login
    ...   bts_host=${webem_addr}
    ...   username=${webem_username}
    ...   password=${webem_password}
    ...   alias=${testline}

    # upgrade testline
    ${UUF_PROCESS}   Get Variable Value   ${UUF_PROCESS}   Prepare
    Log To Console   UUF_PROCESS: ${UUF_PROCESS}
    ${package_type}   Set Variable If
    ...   "${package_type}"!="NONE"   ${package_type}
    ...   "${UUF_PROCESS}"=="upgrade"   target
    ...   "${UUF_PROCESS}"=="rollback"   source
    ...   "${UUF_PROCESS}"=="reset"   target
    ...   others
    Log To Console   package_type: ${package_type}

    ${passive_package_type}   Set Variable If
    ...   "${package_type}"=="target"   source
    ...   "${package_type}"=="source"   target
    ...   others
    Run Keyword If   ${passive_check}   Log To Console   passive_package_type: ${passive_package_type}

    ${testline_type}   ${testline_index}   Split String   ${testline}   _
    ${package_version}   Set Variable   ${UPGRADE_BUILD_INFO_DICT['${testline_type}']['${package_type}']['version']}
    ${passive_package_version}   Set Variable   ${UPGRADE_BUILD_INFO_DICT['${testline_type}']['${passive_package_type}']['version']}

    ${software_dict}   UUF Get Software Version   testline=${testline}
    ${active_version}   Get Variable Value   ${software_dict["active_version"]}
    ${passive_version}   Get Variable Value   ${software_dict["passive_version"]}

    Should Be Equal   ${package_version}   ${active_version}
    Run Keyword If   ${passive_check}
    ...   Should Be Equal   ${passive_package_version}   ${passive_version}


    [Teardown]   Run Keywords
    ...   Run Keyword And Ignore Error   Run Keyword If   ${needConnect}   COAM Logout   connection=${testline}
    ...   AND
    ...   Run Keyword If   "${KEYWORD_STATUS}"=="FAIL" and ${save_check_point}
    ...   UUF Save Single Testline Check Point Error   testline=${testline}   check_point=sw_version   error=FAIL


UUF Check All Testline SW Version
    [Arguments]   ${package_type}
    Log To Console   //TODO: UUF Check All Testline SW Version
    @{check_sequence}   Set Variable If
    ...   "${UUF_PROCESS}"=="upgrade"   ${UPGRADE_SEQUENCE}
    ...   "${UUF_PROCESS}"=="rollback"   ${ROLLBACK_SEQUENCE}
    ...   "${UUF_PROCESS}"=="reset"   ${RESET_SEQUENCE}
    ${passive_check}   Set Variable If   "${UUF_PROCESS}"=="rollback"   ${True}   ${False}
    FOR   ${testline}   IN   @{check_sequence}
        UUF Check SW Version   testline=${testline}   save_check_point=${False}   package_type=${package_type}
        ...   needConnect=${True}   passive_check=${passive_check}
    END


UUF Check SW Upgrade Downtime
    [Arguments]   ${testline}   ${save_check_point}=${True}   ${save_execution_results}=${False}
    Log To Console   //TODO: UUF Check SW Upgrade Downtime
    ${UUF_PROCESS}   Get Variable Value   ${UUF_PROCESS}   Prepare
    Log To Console   UUF_PROCESS: ${UUF_PROCESS}
    ${testline_type}   ${testline_index}   Split String   ${testline}   _

    # If Serial Console is Activated, Skip Check Downtime. (Cell Degrade)
    @{serial_console_testline}   Get Variable Value   ${SERIAL_CONSOLE_ACTIVATED_TL["${TESTLINE_IDENTITY}"]}   @{EMPTY}
    ${isSerialConsoleActivated}   Set Variable If   "${testline}" in ${serial_console_testline}   ${True}   ${False}

    Return From Keyword If   ("${UUF_PROCESS}"!="upgrade" and "${UUF_PROCESS}"!="reset") or "${testline_type}"=="enb" or ${isSerialConsoleActivated}

    ${disconnect_ims2_exist}   Run Keyword And Return Status
    ...   OperatingSystem.File Should Exist   ${OUTPUT_DIR}/admin_api_${testline}_disconnect_at_*.ims2
    Return From Keyword If   not ${disconnect_ims2_exist}

    @{disconnect_ims2}   OperatingSystem.List Files In Directory   ${OUTPUT_DIR}   admin_api_${testline}_disconnect_at_*.ims2
    coam.collect_im_snapshot   connection=${testline}   target_file_name=${OUTPUT_DIR}/IMS2_${testline}_${UUF_PROCESS}.ims2   timeout=${300}

    @{ims_file_path}   Create List   ${OUTPUT_DIR}/${disconnect_ims2[0]}   ${OUTPUT_DIR}/IMS2_${testline}_${UUF_PROCESS}.ims2
    ${status}   ${result}   Run Keyword And Ignore Error
    ...   Run Keyword If   "${UUF_PROCESS}"=="upgrade"   oam_kpi.calculate_kpi2a   ims_file_path=${ims_file_path}
    ...   ELSE IF   "${UUF_PROCESS}"=="reset"   oam_kpi.calculate_kpi1a   ims_file_path=${ims_file_path}
    Return From Keyword If   "${status}"=="FAIL"

    ${kpi_name}   Set Variable If
    ...   "${UUF_PROCESS}"=="upgrade"   kpi2a
    ...   "${UUF_PROCESS}"=="reset"   kpi1a
    ${downtime}   Get Variable Value   ${result['${kpi_name}'][0]['delta'].total_seconds()}   0

    Run Keyword And Ignore Error   Run Keyword If   ${save_execution_results}   UUF Save Execution Results JSON Dictionary
    ...   action=${UUF_PROCESS}   add_key=downtime   add_value=${downtime}

    oam_kpi.clear_results

    ${release}   Get Variable Value   ${UPGRADE_BUILD_INFO_DICT['${testline_type}']['target']['release']}
    ${maxtime}   Get Variable Value   ${Downtime_With_Different_Config["${release}"]}   ${Downtime_With_Different_Config["SBTS00"]}

    Should Be True   ${downtime} <= ${maxtime}
    Log To Console   Downtime: ${downtime} <= Allowed MaxTime: ${maxtime}
    [Teardown]   Run Keyword And Ignore Error   Run Keyword If   "${KEYWORD_STATUS}"=="FAIL" and ${save_check_point}
    ...   UUF Save Single Testline Check Point Error   testline=${testline}   check_point=sw_upgrade_downtime   error=FAIL


UUF Check Validation Error
    [Arguments]   ${testline}   ${save_check_point}=${True}
    Log To Console   //TODO: UUF Check Validation Error
    ${UUF_PROCESS}   Get Variable Value   ${UUF_PROCESS}   Prepare
    Log To Console   UUF_PROCESS: ${UUF_PROCESS}

    ${file_name}   Set Variable   SCF_Validate_${UUF_PROCESS}_${testline}.xml

    coam.get_current_scf_file
    ...   local_dir_path=${OUTPUT_DIR}
    ...   file_name=${file_name}
    ...   connection=${testline}
    ...   timeout=${60}

    ${output}   coam.validate_scf_online
    ...   scf_file=${OUTPUT_DIR}/${file_name}
    ...   connection=${testline}

    ${pdl_logs}   Get Variable Value   ${output["requestMessage"]["pdlValidationResult"]["logs"]}
    ${nidd_logs}   Get Variable Value   ${output["requestMessage"]["niddValidationResult"]["logs"]}

    ${pdl_status}   Get Variable Value   ${output["requestMessage"]["pdlValidationResult"]["status"]}
    ${nidd_status}   Get Variable Value   ${output["requestMessage"]["niddValidationResult"]["status"]}

    Should Be Equal   ${pdl_status}   OK
    Should Be Equal   ${nidd_status}   OK
    [Teardown]   Run Keyword If   "${KEYWORD_STATUS}"=="FAIL" and ${save_check_point}
    ...   UUF Save Single Testline Check Point Error   testline=${testline}   check_point=validate_error   error=FAIL


UUF Check NMS Status
    [Arguments]   ${testline}   ${save_check_point}=${True}
    Log To Console   //TODO: UUF Check NMS Status
    ${testline_type}   ${testline_index}   Split String   ${testline}   _
    Return From Keyword If   "${testline_type}"=="enb"

    # [{'oamTlsStatus': 'notApplicable', 'downlinkFromNMS': 'notApplicable', 'uplinkToNMS': 'notApplicable', 'managerInfo': []}]
    # [[{'managerId': 'oes-mf-ne3sws-mediation-10.110.144.188','managerIpAddress': '10.110.144.188'}],
    # 'oamTlsStatus': 'notSecured','uplinkToNMS': 'notSecured'}]
    # Secured
    ${output}   coam.get_nms_state   connection=${testline}
    ${oamTlsStatus}   Get Variable Value   ${output[0]["oamTlsStatus"]}
    ${uplinkToNMS}   Get Variable Value   ${output[0]["uplinkToNMS"]}
    ${downlinkFromNMS}   Get Variable Value   ${output[0]["downlinkFromNMS"]}
    # Should Not Be Equal   ${oamTlsStatus.lower()}   notapplicable
    # Should Not Be Equal   ${uplinkToNMS.lower()}   notapplicable
    # Should Contain   ${oamTlsStatus.lower()}   secured
    # Should Contain   ${uplinkToNMS.lower()}   secured
    Should Not Contain   ${oamTlsStatus.lower()}   notconnected
    Should Not Contain   ${uplinkToNMS.lower()}   notconnected
    [Teardown]   Run Keyword If   "${KEYWORD_STATUS}"=="FAIL" and ${save_check_point}
    ...   UUF Save Single Testline Check Point Error   testline=${testline}   check_point=nms_status   error=FAIL


UUF Check AMF Status
    [Arguments]   ${testline}   ${save_check_point}=${True}
    Log To Console   //TODO: UUF Check AMF Status
    ${testline_type}   ${testline_index}   Split String   ${testline}   _
    ${SA_Type}   Get Variable Value   ${ALL_CONFIG_SCF["${testline}"]["SA_Type"]}
    Return From Keyword If   "${testline_type}"=="enb" or "${SA_Type}"=="${False}"

    ${scf_content}   coam.get_scf   export_type=configurationAndRuntimeObjects   connection=${testline}
    ${administrativeState_list}   XML.Get Elements Texts   ${scf_content}
    ...   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:SERVEDAMF"]/p[@name="administrativeState"]
    ${ngLinkStatus_list}   XML.Get Elements Texts   ${scf_content}
    ...   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:SERVEDAMF"]/p[@name="ngLinkStatus"]

    FOR   ${administrativeState}   IN   @{administrativeState_list}
        Should Be Equal   ${administrativeState.lower()}   unlocked
    END

    FOR   ${ngLinkStatus}   IN   @{ngLinkStatus_list}
        Should Be Equal   ${ngLinkStatus.lower()}   active
    END
    [Teardown]   Run Keyword If   "${KEYWORD_STATUS}"=="FAIL" and ${save_check_point}
    ...   UUF Save Single Testline Check Point Error   testline=${testline}   check_point=amf_status   error=FAIL


UUF Check PM Report
    [Arguments]   ${testline}   ${save_check_point}=${True}
    Log To Console   //TODO: UUF Check PM Report
    ${UUF_PROCESS}   Get Variable Value   ${UUF_PROCESS}   Prepare
    Log To Console   UUF_PROCESS: ${UUF_PROCESS}
    Run Keyword If   "${UUF_PROCESS}"!="upgrade"   Log To Console   Skip PM Report Check.
    Return From Keyword If   "${UUF_PROCESS}"!="upgrade"

    ${testline_type}   ${testline_index}   Split String   ${testline}   _

    Run Keyword If   "${testline_type}"=="enb"   Log To Console   Testline Type: ENB, Skip PM Report Check.
    Return From Keyword If   "${testline_type}"=="enb"

    ${counter_ids}   Set Variable If
    ...   "${testline_type}"=="gnb"   M55601C00002
    ...   "${testline_type}"=="enb"   M8020C3

    ${counters}   Wait Until Keyword Succeeds   3x   10s
    ...   coam.get_pm_counters   counter_ids=${counter_ids}   connection=${testline}
    @{values}   GetPMCountersValues   counters=${counters}
    @{values}   Evaluate   [i for i in ${values} if (i!=0 and i!="0")]

    Should Not Be Empty   ${values}

    [Teardown]   Run Keyword If   "${KEYWORD_STATUS}"=="FAIL" and ${save_check_point}
    ...   UUF Save Single Testline Check Point Error   testline=${testline}   check_point=pm_report   error=FAIL


UUF Check NetAct Operations
    [Arguments]   ${testline}   ${save_check_point}=${True}
    Log To Console   //TODO: UUF Check NetAct Operations

    ${testline_type}   ${testline_index}   Split String   ${testline}   _

    ${UUF_FUNCTION}   Get Variable Value   ${UUF_FUNCTION}   Prepare
    Log To Console   UUF_FUNCTION: ${UUF_FUNCTION}
    Run Keyword If   "${UUF_FUNCTION}"!="netact"   Log To Console   Skip Check NetAct Operations.
    Return From Keyword If   "${UUF_FUNCTION}"!="netact" or "${testline_type}"=="enb"


    @{exclude_check_point}   Get Variable Value   ${Exclude_Check_Point_TL["${TESTLINE_IDENTITY}"]["${testline}"]}   @{EMPTY}

    Run Keyword And Continue On Failure   Run Keyword If   "cm_upload" not in ${exclude_check_point}   Wait Until Keyword Succeeds   3x   10s
    ...   UUF CM Upload             testline=${testline}
    Run Keyword And Continue On Failure   Run Keyword If   "cm_provision" not in ${exclude_check_point}   Wait Until Keyword Succeeds   3x   10s
    ...   UUF CM Provision          testline=${testline}
    Run Keyword And Ignore Error   Run Keyword If   "fm_auto_upload" not in ${exclude_check_point}   Wait Until Keyword Succeeds   3x   10s
    ...   UUF FM Auto Upload        testline=${testline}
    Run Keyword And Continue On Failure   Run Keyword If   "fm_manual_upload" not in ${exclude_check_point}   Wait Until Keyword Succeeds   3x   10s
    ...   UUF FM Manual Upload      testline=${testline}
    Run Keyword And Continue On Failure   Run Keyword If   "swm_upload" not in ${exclude_check_point}   Wait Until Keyword Succeeds   3x   10s
    ...   UUF SWM Upload            testline=${testline}
    [Teardown]   Run Keyword If   "${KEYWORD_STATUS}"=="FAIL" and ${save_check_point}
    ...   UUF Save Single Testline Check Point Error   testline=${testline}   check_point=netact_operations   error=FAIL


UUF Check Syslog Error
    [Arguments]   ${testline}
    Log To Console   //TODO: UUF Check Syslog Error

    ${UUF_PROCESS}   Get Variable Value   ${UUF_PROCESS}   Prepare
    Log To Console   UUF_PROCESS: ${UUF_PROCESS}
    Return From Keyword If   "${UUF_PROCESS}"!="reset" and "${UUF_PROCESS}"!="upgrade"

    @{common_units}   Get Variable Value   ${ALL_CONFIG_INIT['${testline}']['common_units']}   @{EMPTY}
    FOR   ${common_unit}   IN   @{common_units}
        UUF Check Syslog Error Single Common Unit   common_unit=${common_unit}
    END


UUF Check Syslog Error Single Common Unit
    [Arguments]   ${common_unit}

    ${test_pc_addr}   Get Variable Value   ${common_unit["test_pc_addr"]}   ${EMPTY}
    ${test_pc_username}   Get Variable Value   ${common_unit["test_pc_username"]}   ${EMPTY}
    ${test_pc_password}   Get Variable Value   ${common_unit["test_pc_password"]}   ${EMPTY}

    Return From Keyword If   "${test_pc_addr}"=="" or "${test_pc_addr}"=="${None}" or "${test_pc_addr}"=="1.1.1.1"

    ${connection_status}   Run Keyword And Return Status   csn.Connect to
    ...   hostname=${test_pc_addr}   username=${test_pc_username}   password=${test_pc_password}   alias=${test_pc_addr}   timeout=${10}
    Run Keyword If   not ${connection_status}   Log To Console   Test PC Can Not Connect: ${test_pc_addr}
    Return From Keyword If   not ${connection_status}

    ${output}   csn.Execute   command=ls -al /tmp/btslog2/SYSLOG*.LOG   connection=${test_pc_addr}
    ${syslog_exist}   Run Keyword And Return Status   Should Not Contain   ${output}   No such file or directory
    Return From Keyword If   not ${syslog_exist}

    Log To Console   Check Syslog Error On TestPC: ${test_pc_addr}
    Log To Console   Syslog File List:
    Log To Console   ${output}

    ${offline_output}   csn.Execute   connection=${test_pc_addr}
    ...   command=cat /tmp/btslog2/SYSLOG*.LOG | grep 'CELL NOTIFICATION 4329 Radio memory consumption exceeds abnormal threshold'
    ${status1}   Run Keyword And Return Status   Should Be Empty   ${offline_output}   Syslog Crash verification failed

    ${offline_output}   csn.Execute   connection=${test_pc_addr}
    ...   command=cat /tmp/btslog2/SYSLOG*.LOG | grep 'FaultId: 4329'
    ${status2}   Run Keyword And Return Status   Should Be Empty   ${offline_output}   Syslog Crash verification failed

    ${offline_output}   csn.Execute   connection=${test_pc_addr}
    ...   command=cat /tmp/btslog2/SYSLOG*.LOG | grep 'FaultId: 4330'
    ${status3}   Run Keyword And Return Status   Should Be Empty   ${offline_output}   Syslog Crash verification failed

    ${offline_output}   csn.Execute   connection=${test_pc_addr}
    ...   command=cat /tmp/btslog2/SYSLOG*.LOG | grep 'Detector 4329'
    ${status4}   Run Keyword And Return Status   Should Be Empty   ${offline_output}   Syslog Crash verification failed

    ${offline_output}   csn.Execute   connection=${test_pc_addr}
    ...   command=cat /tmp/btslog2/SYSLOG*.LOG | grep 'Detector 4330'
    ${status5}   Run Keyword And Return Status   Should Be Empty   ${offline_output}   Syslog Crash verification failed

    ${offline_output}   csn.Execute   connection=${test_pc_addr}
    ...   command=cat /tmp/btslog2/SYSLOG*.LOG | grep 'active 4329'
    ${status6}   Run Keyword And Return Status   Should Be Empty   ${offline_output}   Syslog Crash verification failed

    ${offline_output}   csn.Execute   connection=${test_pc_addr}
    ...   command=cat /tmp/btslog2/SYSLOG*.LOG | grep 'active 4330'
    ${status7}   Run Keyword And Return Status   Should Be Empty   ${offline_output}   Syslog Crash verification failed

    ${offline_output}   csn.Execute   connection=${test_pc_addr}
    ...   command=cat /tmp/btslog2/SYSLOG*.LOG | grep '4230 Radio memory consumption exceeds critical threshold'
    ${status8}   Run Keyword And Return Status   Should Be Empty   ${offline_output}   Syslog Crash verification failed

    ${offline_output}   csn.Execute   connection=${test_pc_addr}
    ...   command=cat /tmp/btslog2/SYSLOG*.LOG | grep '\\-\\=\\-\\='
    ${status9}   Run Keyword And Return Status   Should Be Empty   ${offline_output}   Syslog Crash verification failed

    ${command}   Catenate   SEPARATOR=
    ...   cat /tmp/btslog2/SYSLOG*.LOG
    ...   | grep 'Please contact the owner'
    ...   | grep -v '/ffs/run/logs'
    ...   | grep -v 'is not defined in SysinfoQuota.xml'
    ${offline_output}   csn.Execute   connection=${test_pc_addr}   command=${command}
    ${status10}   Run Keyword And Return Status   Should Be Empty   ${offline_output}   Syslog Crash verification failed

    ${command}   Catenate   SEPARATOR=
    ...   cat /tmp/btslog2/SYSLOG*.LOG
    ...   | grep 'ERR'
    ...   | grep '/ffs/run/logs'
    ...   | grep 'is not defined in SysinfoQuota.xml'
    ...   | grep 'Please contact the owner'
    ${offline_output}   csn.Execute   connection=${test_pc_addr}   command=${command}
    ${status11}   Run Keyword And Return Status   Should Be Empty   ${offline_output}   Syslog Crash verification failed


    ${status_list}   Create List   ${status1}   ${status2}   ${status3}   ${status4}   ${status5}   ${status6}
    ...   ${status7}   ${status8}   ${status9}   ${status10}   ${status11}
    Run Keyword And Continue On Failure   List Should Not Contain Value   ${status_list}   ${False}

    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${test_pc_addr}



# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
UUF Initialize ALL Check Point Error
    @{ALL_CHECK_ERROR}   Create List
    Set Suite Variable   ${ALL_CHECK_ERROR}


UUF Initialize Single Testline Check Point Error
    @{SINGLE_TESTLINE_CHECK_ERROR}   Create List
    Set Suite Variable   ${SINGLE_TESTLINE_CHECK_ERROR}


UUF Save Single Testline Check Point Error
    [Arguments]   ${testline}   ${check_point}   ${error}
    # testline + checkpoint + error
    # SINGLE_TESTLINE_CHECK_ERROR = ["enb_0;cell_status;FAIL", "enb_0;active_faults;1868_SN"]
    ${check_error}   Set Variable   ${testline};${check_point};${error}
    ${SINGLE_TESTLINE_CHECK_ERROR}   Get Variable Value   ${SINGLE_TESTLINE_CHECK_ERROR}   ${None}
    Return From Keyword If   "${SINGLE_TESTLINE_CHECK_ERROR}"=="${None}"

    Append To List   ${SINGLE_TESTLINE_CHECK_ERROR}   ${check_error}
    Set Suite Variable   ${SINGLE_TESTLINE_CHECK_ERROR}


UUF Save ALL Check Point Error
    [Arguments]   ${testline}   ${snapshot}=${True}   ${check_exit}=${True}
    Log To Console   //TODO: UUF Save ALL Check Point Error
    # ALL_CHECK_ERROR = ["enb_0;cell_status;FAIL", "enb_0;active_faults;1868_SN"]
    ${SINGLE_TESTLINE_CHECK_ERROR}   Get Variable Value   ${SINGLE_TESTLINE_CHECK_ERROR}   ${None}
    ${ALL_CHECK_ERROR}   Get Variable Value   ${ALL_CHECK_ERROR}   ${None}
    Return From Keyword If   "${SINGLE_TESTLINE_CHECK_ERROR}"=="${None}" or "${ALL_CHECK_ERROR}"=="${None}"

    ${new_check_error}   Evaluate   [i for i in ${SINGLE_TESTLINE_CHECK_ERROR} if i not in ${ALL_CHECK_ERROR}]
    ${status}   Set Variable If   len(${new_check_error})>0   ${True}   ${False}

    ${testline_list}   Get Variable Value   ${ALL_SAME_RU_TESTLINE_MAPPING["${testline}"]}
    Log To Console   new_check_error: ${new_check_error}

    Append To List   ${ALL_CHECK_ERROR}   @{new_check_error}
    Set Suite Variable   ${ALL_CHECK_ERROR}

    Return From Keyword If   not ${check_exit}

    @{continue_check_point}   Create List
    ...   sw_upgrade_downtime
    ...   validate_error
    ...   history_faults
    ...   blackbox
    ...   netact_operations
    ${ExitUUFProcess}   Evaluate   any(i for i in ${new_check_error} if i.split(';')[1] not in ${continue_check_point})
    Log To Console   Exit UUF Process: ${ExitUUFProcess}

    ${time}   DateTime.Get Current Date   UTC   + 8 hours   result_format=%H_%M_%S
    Run Keyword If   ${status} and ${snapshot} and ${CHECK_ERROR_SNAPSHOT_FLAG} and (not ${ExitUUFProcess})
    ...   Run Keyword And Ignore Error   UUF Catch Snapshot   testline_list=${testline_list}   prefix=ContinueUUFProcess_${time}

    Run Keyword If   ${ExitUUFProcess}   FAIL   msg=Stop UUF Process, Check Point Error: ${new_check_error}


# UUF Check Stop Check Point
#     @{continue_check_point}   Create List
#     ...   sw_upgrade_downtime
#     ...   validate_error
#     ...   history_faults
#     ...   blackbox
#     ...   netact_operations

#     Log   ${ALL_CHECK_ERROR}
#     ${ExitUUFProcess}   Set Variable   ${False}
#     :FOR   ${check_error}   IN   @{ALL_CHECK_ERROR}
#         ${testline}   ${check_point}   ${error}   Split String   ${check_error}   ;
#         # Run Keyword If   "${check_point}" not in ${continue_check_point}
#         # ...   Fatal Error   msg=Stop Check Point Error Detected. Stop Continue UUF Process.
#         ${ExitUUFProcess}   Set Variable If   "${check_point}" not in ${continue_check_point}   ${True}   ${False}
#         Exit For Loop If   "${check_point}" not in ${continue_check_point}
#     END
#     # Run Keyword And Ignore Error   Exit For Loop If   ${ExitUUFProcess}
#     ${time}   DateTime.Get Current Date   UTC   + 8 hours   result_format=%H_%M_%S
#     Run Keyword And Ignore Error   Run Keyword If   not ${ExitUUFProcess} and ${ALL_CHECK_ERROR}
#     ...   UUF Catch Snapshot   prefix=ContinueUUFProcess_${time}
#     Run Keyword If   ${ExitUUFProcess}   FAIL   msg=Stop UUF Process, Check Point Error: ${ALL_CHECK_ERROR}

# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
UUF Initialize Execution Results JSON
    Log To Console   //TODO: UUF Initialize Execution Results JSON
    # &{result}   Create Dictionary
    # ...   downtime=${EMPTY}
    # ...   Download=${EMPTY}
    # ...   Activation=${EMPTY}
    # ...   disconnected_PC=@{EMPTY}
    # ...   active_alarm=@{EMPTY}
    # ...   history_alarm=@{EMPTY}
    # ...   eNB_active_alarm=@{EMPTY}
    # ${EXECUTION_RESULTS}   Create Dictionary   upgrade=${result}   rollback=${result}

    ${execution_results_str}   Catenate   SEPARATOR=
    ...   {
    ...       "upgrade": {
    ...           "downtime": null, "Download": null, "Activation": null, "blackbox": null, "l3_call": null,
    ...           "disconnected_PC": [], "active_alarm": [], "history_alarm": [],
    ...           "eNB_active_alarm": {}, "eNB_history_alarm": {}
    ...       },
    ...       "rollback": {
    ...           "downtime": null, "Download": null, "Activation": null, "blackbox": null, "l3_call": null,
    ...           "disconnected_PC": [], "active_alarm": [], "history_alarm": [],
    ...           "eNB_active_alarm": {}, "eNB_history_alarm": {}
    ...       },
    ...       "GNB_reset": {
    ...           "downtime": null, "Download": null, "Activation": null, "blackbox": null, "l3_call": null,
    ...           "disconnected_PC": [], "active_alarm": [], "history_alarm": [],
    ...           "eNB_active_alarm": {}, "eNB_history_alarm": {}
    ...       }
    ...   }

    ${EXECUTION_RESULTS}   Evaluate   json.loads('${execution_results_str}')   json
    Set Suite Variable   ${EXECUTION_RESULTS}


UUF Save Execution Results JSON Dictionary
    [Arguments]   ${action}   ${add_key}   ${add_value}
    @{check_process_list}   Create List   upgrade   rollback   reset
    Return From Keyword If   "${action}" not in ${check_process_list}

    ${action}   Set Variable If   "${action}"=="reset"   GNB_reset   ${action}

    @{string_list}   Create List   downtime   Download   Activation   l3_call   blackbox
    Run Keyword If   "${add_key}" in ${string_list}   Set To Dictionary   ${EXECUTION_RESULTS["${action}"]}   ${add_key}   ${add_value}

    @{list_list}   Create List   disconnected_PC   active_alarm   history_alarm
    Run Keyword If   "${add_key}" in ${list_list}   Append To List   ${EXECUTION_RESULTS["${action}"]["${add_key}"]}   @{add_value}

    @{dict_list}   Create List   eNB_active_alarm   eNB_history_alarm
    Run Keyword If   "${add_key}" in ${dict_list}   Set To Dictionary   ${EXECUTION_RESULTS["${action}"]["${add_key}"]}   &{add_value}

    Set Suite Variable   ${EXECUTION_RESULTS}
    Log   ${EXECUTION_RESULTS}


UUF Save Execution Results JSON File
    ${EXECUTION_RESULTS}   Evaluate   json.dumps(${EXECUTION_RESULTS})   json
    Log To Console   EXECUTION_RESULTS:\n${EXECUTION_RESULTS}
    OperatingSystem.Create File   path=${OUTPUT_DIR}/execution_results.json   content=${EXECUTION_RESULTS}
