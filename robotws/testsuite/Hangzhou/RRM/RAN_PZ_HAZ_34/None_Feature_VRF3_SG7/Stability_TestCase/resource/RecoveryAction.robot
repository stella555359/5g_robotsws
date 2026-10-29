*** Settings ***
Resource   Common.robot

*** Variables ***
@{recovery_action_whitelist}   4681
@{recovery_action_check_point_list}   active_faults   cell_status


*** Keywords ***
UUF Recovery Action
    Log To Console   //TODO: UUF Recovery Action

    Log To Console   ALL_CHECK_ERROR: ${ALL_CHECK_ERROR}

    ${check_error_length}   Get Length   ${ALL_CHECK_ERROR}
    Return From Keyword If   "${check_error_length}"=="0"   ${True}


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
        run keyword if  not ${testline_key_exist}   Set To Dictionary   ${ALL_RECOVERY_ACTION}   ${testline}   ${EMPTY_DICT}

        ${check_point_exist}   Run Keyword And Return Status   Dictionary Should Contain Key   ${ALL_RECOVERY_ACTION["${testline}"]}   ${check_point}
        @{EMPTY_LIST}   Create List
        run keyword if  not ${check_point_exist}   Set To Dictionary   ${ALL_RECOVERY_ACTION["${testline}"]}   ${check_point}   ${EMPTY_LIST}

        Append To List   ${ALL_RECOVERY_ACTION["${testline}"]["${check_point}"]}   ${error}
    END
    Log To Console   ALL_RECOVERY_ACTION: ${ALL_RECOVERY_ACTION}
    # ALL_RECOVERY_ACTION = {
    #     "gnb_0": {
    #         "active_faults": ["4655_N/A", "4654_L1223202189"],
    #     }
    # }

    #Recovery Action LOOP All Testline
    FOR   ${testline}   IN   @{ALL_RECOVERY_ACTION.keys()}
        Continue For Loop If   "${testline}" in ${X2_ENB_LIST}

        ${testline_all_checkpoint_error}   Set Variable   ${ALL_RECOVERY_ACTION["${testline}"]}
        Set Suite Variable   ${TESTLINE_RECOVERY_SUCCEED}   ${False}
        UUF Recovery Action Check Point   testline=${testline}   testline_all_checkpoint_error=${testline_all_checkpoint_error}

        # Recovery Action Final Soultion
        run keyword if  not ${TESTLINE_RECOVERY_SUCCEED}
        ...   UUF Recovery Action Run Keyword   recovery_action_list=${Recovery_Action_Final}   testline=${testline}

        # Recovery Action Fail
        Run Keyword And Continue On Failure   run keyword if  not ${TESTLINE_RECOVERY_SUCCEED}   FAIL   msg=Recovery Action Failed: ${testline}
    END


UUF Recovery Action Check Point
    [Arguments]   ${testline}   ${testline_all_checkpoint_error}
    FOR   ${check_point}   IN  @{testline_all_checkpoint_error.keys()}
        ${single_checkpoint_error}   Set Variable   ${testline_all_checkpoint_error["${check_point}"]}
        Run Keyword If   "${check_point}"=="active_faults"   UUF Recovery Action Active Faults
        ...    testline=${testline}   error_list=${single_checkpoint_error}
        # Run Keyword If   "${check_point}"=="history_faults"   Log To Console   //TODO: Recovery Action: history_faults
        Exit For Loop If   ${TESTLINE_RECOVERY_SUCCEED}
    END


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
        # Run Keyword If   "${dist_name.find("RMOD")}"!="-1"   Set To Dictionary   ${parameter}   dist_name   ${dist_name}

        UUF Recovery Action Run Keyword   recovery_action_list=${recovery_action_list}   testline=${testline}   parameter=${parameter}
        Exit For Loop If   ${TESTLINE_RECOVERY_SUCCEED}
    END


UUF Recovery Action Run Keyword
    [Arguments]   ${testline}   ${recovery_action_list}   ${parameter}=&{EMPTY}
    FOR   ${recovery_action}   IN   @{recovery_action_list}
        ${status}   ${return}   Run Keyword And Ignore Error   Run Keyword   ${recovery_action}   testline=${testline}   parameter=${parameter}
        Log To Console   ${recovery_action} Status: ${status}
        Continue For Loop If   "${status}"=="FAIL"

        Run Keyword If   "${status}"=="PASS"   Set Suite Variable   ${TESTLINE_RECOVERY_SUCCEED}   ${True}
        Exit For Loop If   ${TESTLINE_RECOVERY_SUCCEED}
    END

# ================================================================================================================================================
# ================================================================================================================================================
# ================================================================================================================================================
Check Recovery Action Error Exist
    [Arguments]   ${testline}   ${check_point}   ${error_str}
    @{check_point_list}   Run Keyword If   "${check_point}"=="" or "${check_point}"=="${None}"
    ...   Create List   active_faults   cell_status   history_faults
    ...   ELSE   Create List   ${check_point}
    UUF Initialize Single Testline Check Point Error
    Run Keyword And Ignore Error   UUF Select Check Point   testline=${testline}   check_point_list=${check_point_list}
    Log To Console   SINGLE_TESTLINE_CHECK_ERROR: ${SINGLE_TESTLINE_CHECK_ERROR}
    # List Should Not Contain Value   ${SINGLE_TESTLINE_CHECK_ERROR}   ${testline};${check_point};${error_str}
    ${status}   Evaluate   any("${check_point}" in s and "${error_str}" in s for s in ${SINGLE_TESTLINE_CHECK_ERROR})
    Run Keyword If   "${check_point}"=="" or "${error_str}"=="" or "${check_point}"=="${None}" or "${error_str}"=="${None}"
    ...   Should Be True   ${SINGLE_TESTLINE_CHECK_ERROR}
    ...   ELSE   Should Be True   ${status}


# ================================================================================================================================================
# ================================================================================================================================================
# ================================================================================================================================================
Recovery Action Reset RU
    [Arguments]   ${testline}   ${parameter}=${EMPTY}

    ${dist_name}   Get Variable Value   ${parameter["dist_name"]}   ${EMPTY}
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

    # ${dist_name}   Set Variable   MRBTS-89/EQM-1/APEQM-1/RMOD-1
    Log To Console   Recovery Action: Reset RU: ${dist_name}

    COAM Reset RMOD   dist_name=${dist_name}   connection=${testline}

    # Wait Until Keyword Succeeds   10m   1m   UUF Wait Cell Onair   testline=${testline}
    UUF Wait Times For Cell OnAir   testline=${testline}

    ${Error_Exist}   Run Keyword And Return Status
    ...   Check Recovery Action Error Exist   testline=${testline}   check_point=${check_point}   error_str=${error_str}
    Should Be True   not ${Error_Exist}
    [Teardown]   Run Keyword And Ignore Error   COAM Logout   connection=${testline}


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
