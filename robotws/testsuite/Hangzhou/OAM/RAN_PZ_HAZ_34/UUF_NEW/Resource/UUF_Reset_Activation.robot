*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com

Resource   Common.robot


*** Keywords ***
# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
# WEBEM
UUF Process WebEM Reset Activation
    Log To Console   //TODO: UUF Process WebEM Reset Activation
    FOR   ${testline}   IN   @{RESET_SEQUENCE}
        UUF Reset Activation Execution Results   testline=${testline}
    END


UUF Reset Activation Execution Results
    [Arguments]   ${testline}
    ${start_time}   DateTime.Get Current Date   UTC   result_format=%Y-%m-%dT%H:%M:%S
    Run Keyword And Ignore Error   UUF Save Execution Results JSON Dictionary
    ...   action=${TEST_NAME}   testline=${testline}   add_key=start_time   add_value=${start_time}

    ${package_type}   Set Variable If
    ...   "${UUF_PROCESS}"=="reset" and ${UUF_PROCESS_T1}   testpackage
    ...   "${UUF_PROCESS}"=="reset" and not ${UUF_PROCESS_T1}   target
    ...   others

    ${tmo_decoupling}   Reset Activation Single Testline   testline=${testline}   package_type=${package_type}
    Return From Keyword If   "${tmo_decoupling}"=="tmo_decoupling"
    UUF Check Point Process   testline=${testline}

    [Teardown]   Run Keyword And Ignore Error   UUF Save FOR Loop Result   testline=${testline}


Reset Activation Single Testline
    [Arguments]   ${testline}   ${package_type}

    Return From Keyword If   ${DEBUG}

    ${testline_type}   ${testline_index}   Set Variable   @{testline.split('_')}
    ${package_version}   Set Variable   ${UPGRADE_BUILD_INFO_DICT['${testline_type}']['${package_type}']['version']}
    ${package_path}   Set Variable   ${UPGRADE_BUILD_INFO_DICT['${testline_type}']['${package_type}']['path']}
    ${package_release}   Set Variable   ${UPGRADE_BUILD_INFO_DICT['${testline_type}']['${package_type}']['release']}

    Log To Console   ADMIN Upgrade ${testline} To Target Build: ${package_version}

    ${webem_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_addr']}
    ${webem_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_username']}
    ${webem_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_password']}

    OperatingSystem.Run   command=rm -rf ${OUTPUT_DIR}/admin_api_*_disconnect_at_*.ims2
    OperatingSystem.File Should Not Exist   ${OUTPUT_DIR}/admin_api_*_disconnect_at_*.ims2

    COAM Login
    ...   bts_host=${webem_addr}
    ...   username=${webem_username}
    ...   password=${webem_password}
    ...   alias=${testline}

    # Chek TMO DECOUPLING
    ${software_dict}   UUF Get Software Version   testline=${testline}
    ${active_version}   Set Variable   ${software_dict['active_version']}
    ${passive_version}   Set Variable   ${software_dict['passive_version']}
    ${enb_target_version}   Get Variable Value   ${UPGRADE_BUILD_INFO_DICT['enb']['target']['version']}   ${EMPTY}
    ${enb_source_version}   Get Variable Value   ${UPGRADE_BUILD_INFO_DICT['enb']['source']['version']}   ${EMPTY}
    ${TMO_DECOUPLING_UPGRADE}   Catenate
    ...   "${testline_type}"=="enb"
    ...   and ${TMO_DECOUPLING}
    ...   and "${active_version}"=="${enb_target_version}"
    # ...   and "${passive_version}"=="${enb_source_version}"
    Return From Keyword If   ${TMO_DECOUPLING_UPGRADE}   tmo_decoupling
    # Continue For Loop If   ${TMO_DECOUPLING_UPGRADE}


    ${swPrecheckNeedReset}   UUF Software Precheck Need Reset   testline=${testline}   package_type=${package_type}
    Set Suite Variable   ${swPrecheckNeedReset}

    Run Keyword And Ignore Error   COAM Wait Software Update Possible   testline=${testline}

    Wait Until Keyword Succeeds   20min   2min   UUF ADMIN Upgrade   testline=${testline}   package_path=${package_path}

    ${disconnect_ims2_exist}   Run Keyword And Return Status
    ...   OperatingSystem.File Should Exist   ${OUTPUT_DIR}/admin_api_${testline}_disconnect_at_*.ims2
    Log To Console   Admin API Disconnect IMS2: ${disconnect_ims2_exist}
    Log To Console   ADMIN Upgrade Finished.

    [Teardown]   Run Keyword And Ignore Error   COAM Logout   connection=${testline}

