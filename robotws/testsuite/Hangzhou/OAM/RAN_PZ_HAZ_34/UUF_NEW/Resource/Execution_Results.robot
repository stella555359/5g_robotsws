*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com

Resource   Common.robot


*** Keywords ***
# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
UUF Initialize Execution Results JSON Suite Setup
    Log To Console   //TODO: UUF Initialize Execution Results JSON

    # &{result}   Create Dictionary
    # ...   downtime=${EMPTY}
    # ...   Download=${EMPTY}
    # ...   Activation=${EMPTY}
    # ...   blackbox=${EMPTY}
    # ...   l3_call=${EMPTY}
    # ...   disconnected_PC=@{EMPTY}
    # ...   active_alarm=@{EMPTY}
    # ...   history_alarm=@{EMPTY}

    # ...   testline_name=${EMPTY}
    # ...   configuration_id=${EMPTY}
    # ...   source_build=${EMPTY}
    # ...   target_build=${EMPTY}
    # ...   testline_type=${EMPTY}
    # ...   sw_config=${EMPTY}
    # ...   hw_config=${EMPTY}
    # ...   TDD_FDD_variant=${EMPTY}
    # ...   start_time=${EMPTY}
    # ...   end_time=${EMPTY}
    # ...   result=skip

    ${EXECUTION_RESULTS}   Create Dictionary   version=3.0

    Set Suite Variable   ${EXECUTION_RESULTS}
    Log To Console   ${EXECUTION_RESULTS}


UUF Initialize Execution Results JSON Test Setup
    ${UUF_PROCESS}   Get Variable Value   ${UUF_PROCESS}   Prepare
    ${action}   Get Variable Value   ${TEST_NAME}   ${UUF_PROCESS}

    Set To Dictionary   ${EXECUTION_RESULTS}   ${action}=&{EMPTY}

    FOR   ${testline}   IN   @{ALL_GNB_LIST}   @{ALL_ENB_LIST}

        ${testline_type}   ${testline_index}   Split String   ${testline}   _
        ${testline_name}   Get Variable Value   ${SCOUT_TESTLINE_MAPPING["${testline}"]}   ${EMPTY}
        ${configuration_id}   Get Variable Value   ${TESTLINE_CONFIGURATION_MAPPING["${testline}"]}   ${EMPTY}

        ${source_build}   Get Variable Value   ${UPGRADE_BUILD_INFO_DICT["${testline_type}"]["source"]["version"]}   ${EMPTY}
        ${target_build}   Get Variable Value   ${UPGRADE_BUILD_INFO_DICT["${testline_type}"]["target"]["version"]}   ${EMPTY}
        ${source_build}   Set Variable If   "${source_build}"=="${EMPTY}" or "${source_build}"=="${None}"   ${target_build}   ${source_build}

        ${source_build}   Set Variable If
        ...   "${UUF_PROCESS}"=="reset"   ${target_build}
        ...   "${source_build}"=="${EMPTY}" or "${source_build}"=="${None}"   ${target_build}
        ...   ${source_build}

        ${sw_config}   Get Variable Value   ${ALL_CONFIG_SCF["${testline}"]["sw_config"]}   ${EMPTY}
        ${hw_config}   Get Variable Value   ${ALL_CONFIG_SCF["${testline}"]["hw_config"]}   ${EMPTY}
        ${TDD_FDD_variant}   Get Variable Value   ${ALL_CONFIG_SCF["${testline}"]["TDD_FDD_variant"]}   ${EMPTY}

        &{init_result}   Create Dictionary   downtime=${EMPTY}   Download=${EMPTY}   Activation=${EMPTY}   blackbox=${EMPTY}   l3_call=${EMPTY}
        ...   disconnected_PC=@{EMPTY}   active_alarm=@{EMPTY}   history_alarm=@{EMPTY}   start_time=${EMPTY}   end_time=${EMPTY}   result=init

        ...   testline_name=${testline_name}   configuration_id=${configuration_id}   source_build=${source_build}   target_build=${target_build}
        ...   sw_config=${sw_config}   hw_config=${hw_config}   TDD_FDD_variant=${TDD_FDD_variant}   testline_type=${testline_type}

        Set To Dictionary   ${EXECUTION_RESULTS["${action}"]}   ${testline}=${init_result}

    END

    Set Suite Variable   ${EXECUTION_RESULTS}
    Log To Console   ${EXECUTION_RESULTS}


UUF Save FOR Loop Result
    [Arguments]   ${testline}
    ${UUF_PROCESS}   Get Variable Value   ${UUF_PROCESS}   Prepare
    ${action}   Get Variable Value   ${TEST_NAME}   ${UUF_PROCESS}
    ${result}   Convert To Lower Case   ${KEYWORD_STATUS}

    UUF Save Execution Results JSON Dictionary   action=${action}   testline=${testline}   add_key=result   add_value=${result}

    ${end_time}   DateTime.Get Current Date   UTC   result_format=%Y-%m-%dT%H:%M:%S
    UUF Save Execution Results JSON Dictionary   action=${action}   testline=${testline}   add_key=end_time   add_value=${end_time}


UUF Save Execution Results JSON Dictionary
    [Arguments]   ${action}   ${testline}   ${add_key}   ${add_value}
    # @{check_process_list}   Create List   upgrade   rollback   reset
    # Return From Keyword If   "${action}" not in ${check_process_list}

    @{string_list}   Create List   downtime   Download   Activation   blackbox   l3_call
    ...   testline_name   source_build   target_build   hw_config   TDD_FDD_variant   sw_config   configuration_id   start_time   end_time   result
    Run Keyword If   "${add_key}" in ${string_list}
    ...   Set To Dictionary   ${EXECUTION_RESULTS["${action}"]["${testline}"]}   ${add_key}   ${add_value}

    @{list_list}   Create List   disconnected_PC   active_alarm   history_alarm
    Run Keyword If   "${add_key}" in ${list_list}
    ...   Append To List   ${EXECUTION_RESULTS["${action}"]["${testline}"]["${add_key}"]}   @{add_value}

    Set Suite Variable   ${EXECUTION_RESULTS}
    Log   ${EXECUTION_RESULTS}


UUF Clear Execution Results JSON Dictionary
    FOR   ${action}   IN   @{EXECUTION_RESULTS.keys()}
        Continue For Loop If   "${action}"=="version"
        UUF Test Case Clear Execution Results JSON Dictionary   action=${action}
    END
    Set Suite Variable   ${EXECUTION_RESULTS}
    Log   ${EXECUTION_RESULTS}


UUF Test Case Clear Execution Results JSON Dictionary
    [Arguments]   ${action}
    FOR   ${testline}   IN   @{ALL_GNB_LIST}   @{ALL_ENB_LIST}
        ${init_result}   Get Variable Value    ${EXECUTION_RESULTS["${action}"]["${testline}"]["result"]}   init
        Run Keyword If   "${init_result}"=="init"
        ...   Remove From Dictionary   ${EXECUTION_RESULTS["${action}"]}   ${testline}
    END


UUF Save Execution Results JSON File
    ${EXECUTION_RESULTS}   Evaluate   json.dumps(${EXECUTION_RESULTS})   json
    Log To Console   EXECUTION_RESULTS:\n${EXECUTION_RESULTS}
    OperatingSystem.Create File   path=${OUTPUT_DIR}/execution_results.json   content=${EXECUTION_RESULTS}
