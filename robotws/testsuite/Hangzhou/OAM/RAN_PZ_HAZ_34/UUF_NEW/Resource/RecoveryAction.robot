*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com

Resource   Common.robot

*** Variables ***
@{recovery_action_whitelist}   4681   4592   4589
@{recovery_action_check_point_list}   active_faults   cell_status   validate_error   RuSwOnly


*** Keywords ***
UUF Recovery Action
    Log To Console   //TODO: UUF Recovery Action

    Log To Console   ALL_CHECK_ERROR: ${ALL_CHECK_ERROR}

    ${check_error_length}   Get Length   ${ALL_CHECK_ERROR}
    Return From Keyword If   "${check_error_length}"=="0"   ${True}

    ${needRecovery}   Evaluate   any(i for i in ${ALL_CHECK_ERROR} if i.split(';')[1] in ${recovery_action_check_point_list})
    Return From Keyword If   not ${needRecovery}   ${True}

    Return From Keyword If   ${DEBUG}


    &{ALL_RECOVERY_ACTION}   Create Dictionary

    # Get ALL_RECOVERY_ACTION From ALL_CHECK_ERROR
    FOR   ${check_error}   IN   @{ALL_CHECK_ERROR}
        ${check_error_list}   Split String   ${check_error}   ;

        ${testline}   Set Variable   ${check_error_list[0]}
        ${check_point}   Set Variable   ${check_error_list[1]}
        ${error}   Set Variable   ${check_error_list[2]}

        Continue For Loop If   "${check_point}" not in ${recovery_action_check_point_list}

        ${status}   Evaluate   any(s in "${error}" for s in ${recovery_action_whitelist})
        Continue For Loop If   ${status}

        ${testline_key_exist}   Run Keyword And Return Status   Dictionary Should Contain Key   ${ALL_RECOVERY_ACTION}   ${testline}
        &{EMPTY_DICT}   Create Dictionary
        Run Keyword If   not ${testline_key_exist}   Set To Dictionary   ${ALL_RECOVERY_ACTION}   ${testline}   ${EMPTY_DICT}

        ${check_point_exist}   Run Keyword And Return Status   Dictionary Should Contain Key   ${ALL_RECOVERY_ACTION["${testline}"]}   ${check_point}
        @{EMPTY_LIST}   Create List
        Run Keyword If   not ${check_point_exist}   Set To Dictionary   ${ALL_RECOVERY_ACTION["${testline}"]}   ${check_point}   ${EMPTY_LIST}

        Append To List   ${ALL_RECOVERY_ACTION["${testline}"]["${check_point}"]}   ${error}
    END
    Log To Console   ALL_RECOVERY_ACTION: ${ALL_RECOVERY_ACTION}
    # ALL_RECOVERY_ACTION = {
    #     "gnb_0": {
    #         "active_faults": ["4655_N/A", "4654_L1223202189"],
    #     }
    # }

    #Recovery Action LOOP All Testline
    @{Recovery_Testline}   Create List   @{UPGRADE_SEQUENCE}   @{ROLLBACK_SEQUENCE}   @{RESET_SEQUENCE}
    FOR   ${testline}   IN   @{ALL_RECOVERY_ACTION.keys()}
        Continue For Loop If   ("${testline}" in ${X2_ENB_LIST}) and ("${testline}" not in ${Recovery_Testline})

        ${testline_all_checkpoint_error}   Set Variable   ${ALL_RECOVERY_ACTION["${testline}"]}
        # Set Suite Variable   ${TESTLINE_RECOVERY_SUCCEED}   ${False}
        UUF Recovery Action Check Point   testline=${testline}   testline_all_checkpoint_error=${testline_all_checkpoint_error}

        # Recovery Action Final Soultion
        UUF Recovery Action Run Keyword   recovery_action_list=${Recovery_Action_Final}   testline=${testline}

        # Recovery Action Fail
        Run Keyword And Continue On Failure   Check Recovery Action Error Exist Final   testline=${testline}
    END


UUF Recovery Action Check Point
    [Arguments]   ${testline}   ${testline_all_checkpoint_error}
    FOR   ${check_point}   IN  @{testline_all_checkpoint_error.keys()}
        ${single_checkpoint_error}   Set Variable   ${testline_all_checkpoint_error["${check_point}"]}
        Run Keyword If   "${check_point}"=="RuSwOnly"   UUF Recovery Action RuSwOnly
        ...    testline=${testline}   error_list=${single_checkpoint_error}
    END
    FOR   ${check_point}   IN  @{testline_all_checkpoint_error.keys()}
        ${single_checkpoint_error}   Set Variable   ${testline_all_checkpoint_error["${check_point}"]}
        Run Keyword If   "${check_point}"=="active_faults"   UUF Recovery Action Active Faults
        ...    testline=${testline}   error_list=${single_checkpoint_error}
        # Run Keyword If   "${check_point}"=="history_faults"   Log To Console   //TODO: Recovery Action: history_faults
    END
    FOR   ${check_point}   IN  @{testline_all_checkpoint_error.keys()}
        ${single_checkpoint_error}   Set Variable   ${testline_all_checkpoint_error["${check_point}"]}
        Run Keyword And Ignore Error   Run Keyword If   "${check_point}"=="validate_error"   UUF Recovery Action Validate Error
        ...    testline=${testline}   error_list=${single_checkpoint_error}
    END


UUF Recovery Action RuSwOnly
    [Arguments]   ${testline}   ${error_list}
    Log To Console   //TODO: UUF Recovery Action RuSwOnly
    Log To Console   ${error_list}
    ${parameter}   Create Dictionary   check_point=RuSwOnly   error_str=FAIL
    Run Keyword And Ignore Error   Recovery Action RuSwOnly   testline=${testline}   parameter=${parameter}


UUF Recovery Action Active Faults
    [Arguments]   ${testline}   ${error_list}
    # Sort The Error List Accoring To The Defined Sequence.
    @{new_error_list}   Create List
    FOR   ${check_error}   IN   @{Active_Fault_Sequence}
        ${items}   Evaluate   [i for i in ${error_list} if i.find(str(${check_error}))!=-1]
        Append To List   ${new_error_list}   @{items}
    END
    Remove Values From List   ${error_list}   @{new_error_list}
    Append To List   ${new_error_list}   @{error_list}


    # Start Recovery Action
    FOR   ${error_str}   IN   @{new_error_list}
        ${error_split}   Split String   ${error_str}   _
        ${error}   Get Variable Value   ${error_split[0]}
        ${error}   Convert To Integer   ${error}
        ${dist_name}   Get Variable Value   ${error_split[1]}

        @{recovery_action_list}   Get Variable Value
        ...   ${Recovery_Action_Active_Fault_Keyword[${error}]}
        ...   @{EMPTY}
        # ...   ${Recovery_Action_Active_Fault_Keyword["others"]}

        ${parameter}   Create Dictionary   dist_name=${dist_name}   check_point=active_faults   error_str=${error_str}
        UUF Recovery Action Run Keyword   recovery_action_list=${recovery_action_list}   testline=${testline}   parameter=${parameter}
    END


UUF Recovery Action Validate Error
    [Arguments]   ${testline}   ${error_list}
    Log To Console   //TODO: UUF Recovery Action Validate Error
    Log To Console   ${error_list}
    ${parameter}   Create Dictionary   check_point=validate_error   error_str=FAIL
    Run Keyword And Ignore Error   Recovery Action Load SCF   testline=${testline}   parameter=${parameter}


UUF Recovery Action Run Keyword
    [Arguments]   ${testline}   ${recovery_action_list}   ${parameter}=&{EMPTY}
    FOR   ${recovery_action}   IN   @{recovery_action_list}
        ${status}   ${return}   Run Keyword And Ignore Error   Run Keyword   ${recovery_action}   testline=${testline}   parameter=${parameter}
        Log To Console   ${recovery_action} Status: ${status}
        Exit For Loop If   "${status}"=="PASS"
    END

# ================================================================================================================================================
# ================================================================================================================================================
# ================================================================================================================================================
Check Recovery Action Error Exist
    [Arguments]   ${testline}   ${check_point}=${EMPTY}   ${error_str}=${EMPTY}
    @{check_point_list}   Run Keyword If   "${check_point}"=="" or "${check_point}"=="${None}"
    ...   Create List   active_faults   cell_status   history_faults
    ...   ELSE   Create List   ${check_point}
    UUF Initialize Single Testline Check Point Error
    Run Keyword And Ignore Error   UUF Select Check Point   testline=${testline}   check_point_list=${check_point_list}
    # Log To Console   SINGLE_TESTLINE_CHECK_ERROR: ${SINGLE_TESTLINE_CHECK_ERROR}
    # List Should Not Contain Value   ${SINGLE_TESTLINE_CHECK_ERROR}   ${testline};${check_point};${error_str}
    ${status}   Evaluate   any("${check_point}" in s and "${error_str}" in s for s in ${SINGLE_TESTLINE_CHECK_ERROR})
    Run Keyword If   "${check_point}"=="" or "${error_str}"=="" or "${check_point}"=="${None}" or "${error_str}"=="${None}"
    ...   Should Be True   ${SINGLE_TESTLINE_CHECK_ERROR}
    ...   ELSE   Should Be True   ${status}


Check Recovery Action Error Exist Final
    [Arguments]   ${testline}   ${check_point}=${EMPTY}   ${error_str}=${EMPTY}

    ${webem_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_addr']}
    ${webem_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_username']}
    ${webem_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_password']}
    COAM Login
    ...   bts_host=${webem_addr}
    ...   username=${webem_username}
    ...   password=${webem_password}
    ...   alias=${testline}

    @{check_point_list}   Run Keyword If   "${check_point}"=="" or "${check_point}"=="${None}"
    ...   Create List   active_faults   cell_status   history_faults
    ...   ELSE   Create List   ${check_point}
    UUF Initialize Single Testline Check Point Error
    Run Keyword And Ignore Error   UUF Select Check Point   testline=${testline}   check_point_list=${check_point_list}
    # Log To Console   SINGLE_TESTLINE_CHECK_ERROR: ${SINGLE_TESTLINE_CHECK_ERROR}
    # List Should Not Contain Value   ${SINGLE_TESTLINE_CHECK_ERROR}   ${testline};${check_point};${error_str}
    ${status}   Evaluate   any("${check_point}" in s and "${error_str}" in s for s in ${SINGLE_TESTLINE_CHECK_ERROR})
    Run Keyword If   "${check_point}"=="" or "${error_str}"=="" or "${check_point}"=="${None}" or "${error_str}"=="${None}"
    ...   Should Not Be True   ${SINGLE_TESTLINE_CHECK_ERROR}
    ...   ELSE   Should Not Be True   ${status}
    [Teardown]   Run Keyword And Ignore Error   COAM Logout   connection=${testline}


# ================================================================================================================================================
# ================================================================================================================================================
# ================================================================================================================================================
Recovery Action Reset RU
    [Arguments]   ${testline}   ${parameter}=${EMPTY}

    ${dist_name}   Get Variable Value   ${parameter["dist_name"]}   ${EMPTY}
    ${dist_name_list}   Get Regexp Matches   ${dist_name}   MRBTS-\\d+/EQM-\\d+/APEQM-\\d+/RMOD-\\d+
    ${dist_name}   Get Variable Value   ${dist_name_list[0]}

    ${check_point}   Get Variable Value   ${parameter["check_point"]}   ${EMPTY}
    ${error_str}   Get Variable Value   ${parameter["error_str"]}   ${EMPTY}

    ${error_testline}   Set Variable   ${testline}
    ${error_serialNumber}   Set Variable   ${EMPTY}
    # ${error_radioMasterDN}   Set Variable   ${EMPTY}
    # ${error_isRadioMaster}   Set Variable   ${EMPTY}
    @{rmod_detail_list}   Set Variable   ${ALL_CONFIG_SCF["${error_testline}"]["rmod_detail_list"]}
    FOR   ${rmod_detail}   IN   @{rmod_detail_list}
        ${error_serialNumber}   Set Variable If   "${rmod_detail["configDN"]}"=="${dist_name}"   ${rmod_detail["serialNumber"]}   ${EMPTY}
        # ${error_radioMasterDN}   Set Variable If   "${rmod_detail["configDN"]}"=="${dist_name}"   ${rmod_detail["radioMasterDN"]}   ${EMPTY}
        # ${error_isRadioMaster}   Set Variable If   "${rmod_detail["configDN"]}"=="${dist_name}"   ${rmod_detail["isRadioMaster"]}   ${EMPTY}
        Exit For Loop If   "${rmod_detail["configDN"]}"=="${dist_name}"
    END

    Log To Console   Error RU Serial Number: ${error_serialNumber}
    # Log To Console   ${error_radioMasterDN}
    # Log To Console   ${error_isRadioMaster}


    ${recovery_testline}   Set Variable   ${testline}
    ${recovery_dist_name}   Set Variable   ${dist_name}
    FOR   ${RadioMaster_testline}   IN   @{ALL_CONFIG_SCF.keys()}
        @{rmod_detail_list}   Set Variable   ${ALL_CONFIG_SCF["${RadioMaster_testline}"]["rmod_detail_list"]}
        ${isRadioMaster_list}   Evaluate
        ...   [rmod_detail["isRadioMaster"] for rmod_detail in ${rmod_detail_list} if rmod_detail["serialNumber"]=="${error_serialNumber}"]
        ${configDN_list}   Evaluate
        ...   [rmod_detail["configDN"] for rmod_detail in ${rmod_detail_list} if rmod_detail["serialNumber"]=="${error_serialNumber}"]
        ${recovery_testline}   Set Variable If   ${isRadioMaster_list[0]}   ${RadioMaster_testline}   ${recovery_testline}
        ${recovery_dist_name}   Set Variable If   ${isRadioMaster_list[0]}   ${configDN_list[0]}   ${recovery_dist_name}
        Exit For Loop If   ${isRadioMaster_list[0]}
    END


    ${error_webem_addr}   Set Variable   ${ALL_CONFIG_INIT['${error_testline}']['webem_addr']}
    ${error_webem_username}   Set Variable   ${ALL_CONFIG_INIT['${error_testline}']['webem_username']}
    ${error_webem_password}   Set Variable   ${ALL_CONFIG_INIT['${error_testline}']['webem_password']}

    ${recovery_webem_addr}   Set Variable   ${ALL_CONFIG_INIT['${recovery_testline}']['webem_addr']}
    ${recovery_webem_username}   Set Variable   ${ALL_CONFIG_INIT['${recovery_testline}']['webem_username']}
    ${recovery_webem_password}   Set Variable   ${ALL_CONFIG_INIT['${recovery_testline}']['webem_password']}

    COAM Login
    ...   bts_host=${error_webem_addr}
    ...   username=${error_webem_username}
    ...   password=${error_webem_password}
    ...   alias=${error_testline}

    ${Error_Exist}   Run Keyword And Return Status
    ...   Check Recovery Action Error Exist   testline=${error_testline}   check_point=${check_point}   error_str=${error_str}
    Return From Keyword If   not ${Error_Exist}

    Log To Console   Recovery Action Reset RU: Error Testline: ${testline}: ${dist_name}
    Log To Console   Recovery Action Reset RU: Recovery Testline: ${recovery_testline}: ${recovery_dist_name}

    Run Keyword If   "${error_testline}"!="${recovery_testline}"
    ...   COAM Login
    ...   bts_host=${recovery_webem_addr}
    ...   username=${recovery_webem_username}
    ...   password=${recovery_webem_password}
    ...   alias=${recovery_testline}

    COAM Reset RMOD   dist_name=${recovery_dist_name}   connection=${recovery_testline}

    Run Keyword If   "${error_testline}"!="${recovery_testline}"   UUF Wait Times For Cell OnAir   testline=${recovery_testline}
    UUF Wait Times For Cell OnAir   testline=${error_testline}


    ${Error_Exist}   Run Keyword And Return Status
    ...   Check Recovery Action Error Exist   testline=${error_testline}   check_point=${check_point}   error_str=${error_str}
    Should Be True   not ${Error_Exist}

    [Teardown]   Run Keywords
    ...   Run Keyword And Ignore Error   Run Keyword If   "${error_testline}"!="${recovery_testline}"   COAM Logout  connection=${recovery_testline}
    ...   AND
    ...   Run Keyword And Ignore Error   COAM Logout   connection=${error_testline}


    # ${webem_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_addr']}
    # ${webem_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_username']}
    # ${webem_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_password']}
    # COAM Login
    # ...   bts_host=${webem_addr}
    # ...   username=${webem_username}
    # ...   password=${webem_password}
    # ...   alias=${testline}

    # ${Error_Exist}   Run Keyword And Return Status
    # ...   Check Recovery Action Error Exist   testline=${testline}   check_point=${check_point}   error_str=${error_str}
    # Return From Keyword If   not ${Error_Exist}

    # # ${dist_name}   Set Variable   MRBTS-89/EQM-1/APEQM-1/RMOD-1
    # Log To Console   Recovery Action: Reset RU: ${dist_name}

    # COAM Reset RMOD   dist_name=${dist_name}   connection=${testline}

    # # Wait Until Keyword Succeeds   10m   1m   UUF Wait Cell Onair   testline=${testline}
    # UUF Wait Times For Cell OnAir   testline=${testline}

    # ${Error_Exist}   Run Keyword And Return Status
    # ...   Check Recovery Action Error Exist   testline=${testline}   check_point=${check_point}   error_str=${error_str}
    # Should Be True   not ${Error_Exist}
    # [Teardown]   Run Keyword And Ignore Error   COAM Logout   connection=${testline}


Recovery Action Reset Site
    [Arguments]   ${testline}   ${parameter}=${EMPTY}

    ${check_point}   Get Variable Value   ${parameter["check_point"]}   ${EMPTY}
    ${error_str}   Get Variable Value   ${parameter["error_str"]}   ${EMPTY}

    ${webem_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_addr']}
    ${webem_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_username']}
    ${webem_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_password']}
    COAM Login
    ...   bts_host=${webem_addr}
    ...   username=${webem_username}
    ...   password=${webem_password}
    ...   alias=${testline}


    ${Error_Exist}   Run Keyword And Return Status
    ...   Check Recovery Action Error Exist   testline=${testline}   check_point=${check_point}   error_str=${error_str}
    Return From Keyword If   not ${Error_Exist}

    Log To Console   Recovery Action: Reset Site: ${testline}
    COAM Reset Site   connection=${testline}
    # Wait Until Keyword Succeeds   20m   1m   UUF Wait Cell Onair   testline=${testline}
    # Wait Until Keyword Succeeds   5m   1m   UUF Wait X2 Link Status   testline=${testline}
    UUF Wait Times For Cell OnAir   testline=${testline}

    ${Error_Exist}   Run Keyword And Return Status
    ...   Check Recovery Action Error Exist   testline=${testline}   check_point=${check_point}   error_str=${error_str}
    Should Be True   not ${Error_Exist}

    [Teardown]   Run Keyword And Ignore Error   COAM Logout   connection=${testline}


Recovery Action Clear FallBack Fault
    [Arguments]   ${testline}   ${parameter}=${EMPTY}
    # 4082,4083,4085: fall back fault
    #     ->  rm -rf /ffs/run/config/fallbackCause.txt
    #     ->  reboot
    #     ->  fault23
    ${testline_type}   ${testline_index}   Split String   ${testline}   _

    ${ssh_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['ssh_addr']}
    ${ssh_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['ssh_username']}
    ${ssh_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['ssh_password']}

    csn.Connect to   hostname=${ssh_addr}   username=${ssh_username}   password=${ssh_password}   alias=${testline}

    Log To Console   rm -rf /ffs/run/config/fallbackCause.txt
    csn.Execute   command=rm -rf /ffs/run/config/fallbackCause.txt   connection=${testline}

    Run Keyword And Ignore Error   csn.disconnect    connection=${testline}

    ${webem_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_addr']}
    ${webem_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_username']}
    ${webem_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_password']}
    COAM Login
    ...   bts_host=${webem_addr}
    ...   username=${webem_username}
    ...   password=${webem_password}
    ...   alias=${testline}

    COAM Reset Site   connection=${testline}

    ${fault23}   Wait Until Keyword Succeeds   30m   3m   COAM RU Detected And Fault23 Appeared   testline=${testline}
    Wait Until Keyword Succeeds   3x   5m   Run Keyword If   ${fault23}
    ...   Recovery Action Upgrade Current Software   testline=${testline}   parameter=${parameter}

    [Teardown]   Run Keywords
    ...   Run Keyword And Ignore Error   csn.disconnect    connection=${testline}   AND
    ...   Run Keyword And Ignore Error   COAM Logout   connection=${testline}


Recovery Action Upgrade Current Software
    [Arguments]   ${testline}   ${parameter}=${EMPTY}
    # 23: "Upgrade to Current SW Version",

    ${webem_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_addr']}
    ${webem_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_username']}
    ${webem_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_password']}
    COAM Login
    ...   bts_host=${webem_addr}
    ...   username=${webem_username}
    ...   password=${webem_password}
    ...   alias=${testline}

    ${check_point}   Get Variable Value   ${parameter["check_point"]}   ${EMPTY}
    ${error_str}   Get Variable Value   ${parameter["error_str"]}   ${EMPTY}
    ${Error_Exist}   Run Keyword And Return Status
    ...   Check Recovery Action Error Exist   testline=${testline}   check_point=${check_point}   error_str=${error_str}
    Return From Keyword If   not ${Error_Exist}


    ${software_dict}   UUF Get Software Version   testline=${testline}
    ${active_version}   Get Variable Value   ${software_dict["active_version"]}

    # ${testline_type}   ${testline_index}   Split String   ${testline}   _
    # ${source}   Get Variable Value   ${UPGRADE_BUILD_INFO_DICT["${testline_type}"]["source"]["version"]}
    # ${target}   Get Variable Value   ${UPGRADE_BUILD_INFO_DICT["${testline_type}"]["target"]["version"]}
    # ${package_type}   Set Variable If
    # ...   "${source}"=="${active_version}"   source
    # ...   "${target}"=="${active_version}"   target

    # ${package_path}   Get Variable Value   ${UPGRADE_BUILD_INFO_DICT["${testline_type}"]["${package_type}"]["path"]}
    ${package_path}   Download Classical Common Package   package_version=${active_version}
    coam.update_software   sw_package=${package_path}   should_activate=${True}   timeout=${5400}   connection=${testline}
    Run Keyword And Ignore Error   COAM Logout   connection=${testline}
    Sleep   3m
    Wait Until Keyword Succeeds   20m   1m
    ...   COAM Login
    ...   bts_host=${webem_addr}
    ...   username=${webem_username}
    ...   password=${webem_password}
    ...   alias=${testline}
    # Wait Until Keyword Succeeds   20m   1m   UUF Wait Cell Onair   testline=${testline}
    # Wait Until Keyword Succeeds   5m   1m   UUF Wait X2 Link Status   testline=${testline}
    UUF Wait Times For Cell OnAir   testline=${testline}

    ${Error_Exist}   Run Keyword And Return Status
    ...   Check Recovery Action Error Exist   testline=${testline}   check_point=${check_point}   error_str=${error_str}
    Should Be True   not ${Error_Exist}

    [Teardown]   Run Keyword And Ignore Error   COAM Logout   connection=${testline}


Recovery Action Wait Auto Upgrade
    [Arguments]   ${testline}   ${parameter}=${EMPTY}
    # 1850: "Wait Auto Upgrade",

    ${webem_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_addr']}
    ${webem_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_username']}
    ${webem_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_password']}
    Wait Until Keyword Succeeds   10m   1m
    ...   COAM Login
    ...   bts_host=${webem_addr}
    ...   username=${webem_username}
    ...   password=${webem_password}
    ...   alias=${testline}

    ${check_point}   Get Variable Value   ${parameter["check_point"]}   ${EMPTY}
    ${error_str}   Get Variable Value   ${parameter["error_str"]}   ${EMPTY}
    ${Error_Exist}   Run Keyword And Return Status
    ...   Check Recovery Action Error Exist   testline=${testline}   check_point=${check_point}   error_str=${error_str}
    Return From Keyword If   not ${Error_Exist}

    Run Keyword And Ignore Error   COAM Wait Software Update Possible   testline=${testline}
    Sleep   3m
    Run Keyword And Ignore Error   UUF Wait Times For Cell OnAir   testline=${testline}

    ${Error_Exist}   Run Keyword And Return Status
    ...   Check Recovery Action Error Exist   testline=${testline}   check_point=${check_point}   error_str=${error_str}
    Should Be True   not ${Error_Exist}

    [Teardown]   Run Keyword And Ignore Error   COAM Logout   connection=${testline}


Recovery Action Catch Snapshot
    [Arguments]   ${testline}   ${parameter}=${EMPTY}

    ${check_point}   Get Variable Value   ${parameter["check_point"]}   ${EMPTY}
    ${error_str}   Get Variable Value   ${parameter["error_str"]}   ${EMPTY}

    ${webem_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_addr']}
    ${webem_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_username']}
    ${webem_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_password']}
    COAM Login
    ...   bts_host=${webem_addr}
    ...   username=${webem_username}
    ...   password=${webem_password}
    ...   alias=${testline}


    ${Error_Exist}   Run Keyword And Return Status
    ...   Check Recovery Action Error Exist   testline=${testline}   check_point=${check_point}   error_str=${error_str}
    Return From Keyword If   not ${Error_Exist}

    Log To Console   Recovery Action: Catch Snapshot: ${testline}
    ${time}    DateTime.Get Current Date    UTC    + 8 hours    result_format=%Y-%m-%d-%H_%M_%S
    ${snapshot_name}   Set Variable   Snapshot_Recovery_Action_${testline}_${time}.zip
    coam.Collect Snapshot
    ...   target_file_name=${OUTPUT_DIR}/${snapshot_name}
    ...   coverage=Full
    ...   force=True
    ...   timeout=${5400}
    ...   connection=${testline}
    # COAM Reset Site   connection=${testline}
    # Wait Until Keyword Succeeds   20m   1m   UUF Wait Cell Onair   testline=${testline}
    # Wait Until Keyword Succeeds   5m   1m   UUF Wait X2 Link Status   testline=${testline}

    ${Error_Exist}   Run Keyword And Return Status
    ...   Check Recovery Action Error Exist   testline=${testline}   check_point=${check_point}   error_str=${error_str}
    Should Be True   not ${Error_Exist}

    [Teardown]   Run Keyword And Ignore Error   COAM Logout   connection=${testline}


Recovery Action Load SCF
    [Arguments]   ${testline}   ${parameter}=${EMPTY}

    ${check_point}   Get Variable Value   ${parameter["check_point"]}   ${EMPTY}
    ${error_str}   Get Variable Value   ${parameter["error_str"]}   ${EMPTY}

    ${webem_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_addr']}
    ${webem_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_username']}
    ${webem_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_password']}
    COAM Login
    ...   bts_host=${webem_addr}
    ...   username=${webem_username}
    ...   password=${webem_password}
    ...   alias=${testline}


    ${Error_Exist}   Run Keyword And Return Status
    ...   Check Recovery Action Error Exist   testline=${testline}   check_point=${check_point}   error_str=${error_str}
    Return From Keyword If   not ${Error_Exist}

    Log To Console   Waiting For SCF Commission.

    ${release}   COAM Get SW Release   connection=${testline}
    ${scf_path}   Set Variable   ${GOLDEN_SCF_DIR}/TL${TESTLINE_IDENTITY}/SCF_${release}_${testline}.xml
    OperatingSystem.File Should Exist   path=${scf_path}
    Wait Until Keyword Succeeds   20m   1m   COAM SCF Commission   filepath=${scf_path}   connection=${testline}
    Run Keyword And Ignore Error   COAM Logout   connection=${testline}
    Run Keyword And Ignore Error   Wait Until Keyword Succeeds   1m   10s   Check Connection Status   ip_address=${ssh_addr}   status=disconnect
    Log To Console   SCF Commission Finished. Waiting For Reconnection...

    Wait Until Keyword Succeeds   20m   1m
    ...   COAM Login
    ...   bts_host=${webem_addr}
    ...   username=${webem_username}
    ...   password=${webem_password}
    ...   alias=${testline}
    Log To Console   Reconnected.
    UUF Wait Times For Cell OnAir   testline=${testline}

    ${Error_Exist}   Run Keyword And Return Status
    ...   Check Recovery Action Error Exist   testline=${testline}   check_point=${check_point}   error_str=${error_str}
    Should Be True   not ${Error_Exist}

    [Teardown]   Run Keyword And Ignore Error   COAM Logout   connection=${testline}


Recovery Action RuSwOnly
    [Arguments]   ${testline}   ${parameter}=${EMPTY}

    ${check_point}   Get Variable Value   ${parameter["check_point"]}   ${EMPTY}
    ${error_str}   Get Variable Value   ${parameter["error_str"]}   ${EMPTY}

    ${webem_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_addr']}
    ${webem_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_username']}
    ${webem_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_password']}
    COAM Login
    ...   bts_host=${webem_addr}
    ...   username=${webem_username}
    ...   password=${webem_password}
    ...   alias=${testline}


    ${Error_Exist}   Run Keyword And Return Status
    ...   Check Recovery Action Error Exist   testline=${testline}   check_point=${check_point}   error_str=${error_str}
    Return From Keyword If   not ${Error_Exist}

    # Log To Console   Waiting For SCF Commission.

    ${software_dict}   UUF Get Software Version   testline=${testline}
    ${active_version}   Get Variable Value   ${software_dict["active_version"]}

    # ${package_path}   Get Variable Value   ${UPGRADE_BUILD_INFO_DICT["${testline_type}"]["${package_type}"]["path"]}
    ${package_path}   Download Classical Common Package   package_version=${active_version}

    Log To Console   Recovery Start Update Software RuSwOnly.
    coam.update_software   sw_package=${package_path}   should_activate=${True}   timeout=${3600}   connection=${testline}
    ...   independent_sw_update_type=RuSwOnly
    Log To Console   Recovery Update Software RuSwOnly Finished.

    Run Keyword And Ignore Error   COAM Logout   connection=${testline}

    Wait Until Keyword Succeeds   20m   1m
    ...   COAM Login
    ...   bts_host=${webem_addr}
    ...   username=${webem_username}
    ...   password=${webem_password}
    ...   alias=${testline}
    Wait Until Keyword Succeeds   5m   1m   UUF Check RuSwOnly   testline=${testline}   save_check_point=${False}

    UUF Wait Times For Cell OnAir   testline=${testline}

    ${Error_Exist}   Run Keyword And Return Status
    ...   Check Recovery Action Error Exist   testline=${testline}   check_point=${check_point}   error_str=${error_str}
    Should Be True   not ${Error_Exist}

    [Teardown]   Run Keyword And Ignore Error   COAM Logout   connection=${testline}
