*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com

Resource   Common.robot


*** Keywords ***
# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
# WEBEM
UUF Process WebEM Upgrade
    Log To Console   //TODO: UUF Process WebEM Upgrade
    # [Arguments]   ${upgrade_sequence}
    # Example:
    #     ${upgrade_sequence}=[gnb_0, enb_0, enb_1]

    FOR   ${testline}   IN   @{UPGRADE_SEQUENCE}
        # Run Keyword If   "${TESTLINE_IDENTITY}" in ${UUF_PROCESS_ADMIN_TL}   ADMIN Upgrade Single Testline   testline=${testline}
        # ...   ELSE   Wait Until Keyword Succeeds   3x   10s   WebEM Upgrade Single Testline   testline=${testline}

        # UUF Check Point Process   testline=${testline}
        # # UUF Check Stop Check Point
        UUF Upgrade Execution Results   testline=${testline}
    END

    UUF Target Packge L3CALL Process


UUF Upgrade Execution Results
    [Arguments]   ${testline}
    ${start_time}   DateTime.Get Current Date   UTC   result_format=%Y-%m-%dT%H:%M:%S
    Run Keyword And Ignore Error   UUF Save Execution Results JSON Dictionary
    ...   action=${TEST_NAME}   testline=${testline}   add_key=start_time   add_value=${start_time}

    ${tmo_decoupling}   Run Keyword If
    ...   "${TESTLINE_IDENTITY}" in ${UUF_PROCESS_ADMIN_TL}   ADMIN Upgrade Single Testline   testline=${testline}
    ...   ELSE
    ...   Wait Until Keyword Succeeds   3x   10s   WebEM Upgrade Single Testline   testline=${testline}

    Return From Keyword If   "${tmo_decoupling}"=="tmo_decoupling"

    UUF Check Point Process   testline=${testline}
    # UUF Check Stop Check Point

    [Teardown]   Run Keyword And Ignore Error   Run Keyword If   "${tmo_decoupling}"!="tmo_decoupling"
    ...   UUF Save FOR Loop Result   testline=${testline}



WebEM Upgrade Single Testline
    [Arguments]   ${testline}

    Return From Keyword If   ${DEBUG}

    ${testline_type}   ${testline_index}   Set Variable   @{testline.split('_')}
    ${package_version}   Set Variable   ${UPGRADE_BUILD_INFO_DICT['${testline_type}']['target']['version']}
    ${package_path}   Set Variable   ${UPGRADE_BUILD_INFO_DICT['${testline_type}']['target']['path']}
    ${package_release}   Set Variable   ${UPGRADE_BUILD_INFO_DICT['${testline_type}']['target']['release']}

    Log To Console   WebEM Upgrade ${testline} To Target Build: ${package_version}

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


    ${swPrecheckNeedReset}   UUF Software Precheck Need Reset   testline=${testline}   package_type=target
    Set Suite Variable   ${swPrecheckNeedReset}

    Run Keyword And Ignore Error   COAM Wait Software Update Possible   testline=${testline}

    UUF WebEM Login   testline=${testline}
    UUF WebEM Upgrade   testline=${testline}   package_path=${package_path}
    ${logout_status}   Run Keyword And Return Status   UUF WebEM Logout   testline=${testline}

    ${disconnect_ims2_exist}   Run Keyword And Return Status
    ...   OperatingSystem.File Should Exist   ${OUTPUT_DIR}/admin_api_${testline}_disconnect_at_*.ims2
    Log To Console   Admin API Disconnect IMS2: ${disconnect_ims2_exist}
    Log To Console   WebEM Upgrade Finished.

    [Teardown]   Run Keywords
    ...   Run Keyword And Ignore Error   Run Keyword If   not ${logout_status}   UUF WebEM Logout   testline=${testline}   AND
    ...   Run Keyword And Ignore Error   COAM Logout   connection=${testline}


ADMIN Upgrade Single Testline
    [Arguments]   ${testline}

    Return From Keyword If   ${DEBUG}

    ${testline_type}   ${testline_index}   Set Variable   @{testline.split('_')}
    ${package_version}   Set Variable   ${UPGRADE_BUILD_INFO_DICT['${testline_type}']['target']['version']}
    ${package_path}   Set Variable   ${UPGRADE_BUILD_INFO_DICT['${testline_type}']['target']['path']}
    ${package_release}   Set Variable   ${UPGRADE_BUILD_INFO_DICT['${testline_type}']['target']['release']}

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

    ${swPrecheckNeedReset}   UUF Software Precheck Need Reset   testline=${testline}   package_type=target
    Set Suite Variable   ${swPrecheckNeedReset}

    Run Keyword And Ignore Error   COAM Wait Software Update Possible   testline=${testline}

    Wait Until Keyword Succeeds   20min   2min   UUF ADMIN Upgrade
    ...   testline=${testline}   package_path=${package_path}

    ${disconnect_ims2_exist}   Run Keyword And Return Status
    ...   OperatingSystem.File Should Exist   ${OUTPUT_DIR}/admin_api_${testline}_disconnect_at_*.ims2
    Log To Console   Admin API Disconnect IMS2: ${disconnect_ims2_exist}
    Log To Console   ADMIN Upgrade Finished.

    [Teardown]   Run Keyword And Ignore Error   COAM Logout   connection=${testline}


ADMIN Upgrade Single Testline Independent
    [Arguments]   ${testline}
    ${testline_type}   ${testline_index}   Set Variable   @{testline.split('_')}
    ${package_version}   Set Variable   ${UPGRADE_BUILD_INFO_DICT['${testline_type}']['target']['version']}
    ${package_path}   Set Variable   ${UPGRADE_BUILD_INFO_DICT['${testline_type}']['target']['path']}
    ${package_release}   Set Variable   ${UPGRADE_BUILD_INFO_DICT['${testline_type}']['target']['release']}

    ${webem_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_addr']}
    ${webem_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_username']}
    ${webem_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_password']}
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


    # Admin Upgrade RuSwOnly
    Log To Console   Admin Upgrade RuSwOnly.
    coam.update_software   sw_package=${package_path}   should_activate=${True}   timeout=${3600}   connection=${testline}
    ...   independent_sw_update_type=RuSwOnly

    Run Keyword And Ignore Error   COAM Logout   connection=${testline}

    #Check Point After RuSwOnly
    Log To Console   UUF Check Point Process After RuSwOnly
    ${package_version}   Replace String   ${package_version}   SBTS00   ${package_release}
    UUF Check Point Process After RuSwOnly   testline=${testline}   package_version=${package_version}

    # Admin Upgrade DU
    Log To Console   Admin Upgrade DU.
    Wait Until Keyword Succeeds   5m   1m
    ...   COAM Login
    ...   bts_host=${webem_addr}
    ...   username=${webem_username}
    ...   password=${webem_password}
    ...   alias=${testline}
    OperatingSystem.Run   command=rm -rf ${OUTPUT_DIR}/admin_api_*_disconnect_at_*.ims2
    OperatingSystem.File Should Not Exist   ${OUTPUT_DIR}/admin_api_*_disconnect_at_*.ims2

    ${swPrecheckNeedReset}   UUF Software Precheck Need Reset   testline=${testline}   package_type=target
    Set Suite Variable   ${swPrecheckNeedReset}

    Run Keyword And Ignore Error   COAM Wait Software Update Possible   testline=${testline}

    Wait Until Keyword Succeeds   20min   2min   UUF ADMIN Upgrade   testline=${testline}   package_path=${package_path}

    ${disconnect_ims2_exist}   Run Keyword And Return Status
    ...   OperatingSystem.File Should Exist   ${OUTPUT_DIR}/admin_api_${testline}_disconnect_at_*.ims2
    Log To Console   Admin API Disconnect IMS2: ${disconnect_ims2_exist}
    Log To Console   ADMIN Upgrade Finished.

    [Teardown]   Run Keyword And Ignore Error   COAM Logout   connection=${testline}

# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
# NetAct
UUF Process NetAct Upgrade
    # [Arguments]   ${upgrade_sequence}
    # Example:
    #     ${upgrade_sequence}=[gnb_0, enb_0, enb_1]

    FOR   ${testline}   IN   @{upgrade_sequence}
        # NetAct Upgrade Single Testline   testline=${testline}
        # UUF Check Point Process   testline=${testline}
        # # UUF Check Stop Check Point
        UUF NetAct Upgrade Execution Results   testline=${testline}
    END

    FOR   ${testline}   IN   @{upgrade_sequence}
        ${testline_type}   ${testline_index}   Split String   ${testline}   _
        Continue For Loop If   "${testline_type}"=="enb"

        NetAct Provision Single Testline   testline=${testline}
        UUF Check Point Process   testline=${testline}
    END


UUF NetAct Upgrade Execution Results
    [Arguments]   ${testline}
    ${start_time}   DateTime.Get Current Date   UTC   result_format=%Y-%m-%dT%H:%M:%S
    Run Keyword And Ignore Error   UUF Save Execution Results JSON Dictionary
    ...   action=${TEST_NAME}   testline=${testline}   add_key=start_time   add_value=${start_time}

    ${tmo_decoupling}  NetAct Upgrade Single Testline   testline=${testline}
    Return From Keyword If   "${tmo_decoupling}"=="tmo_decoupling"

    UUF Check Point Process   testline=${testline}
    # UUF Check Stop Check Point

    [Teardown]   Run Keyword And Ignore Error   Run Keyword If   "${tmo_decoupling}"!="tmo_decoupling"
    ...   UUF Save FOR Loop Result   testline=${testline}



NetAct Upgrade Single Testline
    [Arguments]   ${testline}

    Return From Keyword If   ${DEBUG}

    ${testline_type}   ${testline_index}   Split String   ${testline}   _
    ${package_version}   Set Variable   ${UPGRADE_BUILD_INFO_DICT['${testline_type}']['target']['version']}
    ${package_path}   Set Variable   ${UPGRADE_BUILD_INFO_DICT['${testline_type}']['target']['path']}
    ${package_release}   Set Variable   ${UPGRADE_BUILD_INFO_DICT['${testline_type}']['target']['release']}

    # ENB
    ${tmo_decoupling}   Run Keyword If   "${testline_type}"=="enb"   ADMIN Upgrade Single Testline   testline=${testline}
    Return From Keyword If   "${testline_type}"=="enb"   ${tmo_decoupling}

    ${webem_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_addr']}
    ${webem_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_username']}
    ${webem_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_password']}
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


    # GNB
    Log To Console   NetAct Upgrade ${testline} To Target Build: ${package_version}

    ${webem_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_addr']}
    ${webem_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_username']}
    ${webem_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_password']}

    OperatingSystem.Run   command=rm -rf ${OUTPUT_DIR}/admin_api_*_disconnect_at_*.ims2
    OperatingSystem.File Should Not Exist   ${OUTPUT_DIR}/admin_api_*_disconnect_at_*.ims2


    ${dist_name}   Get Variable Value   ${ALL_CONFIG_SCF["${testline}"]["dist_name"]}
    Run Keyword And Ignore Error   NetAct SWM Operation   dist_name=${dist_name}   operation=upload

    # COAM Login
    # ...   bts_host=${webem_addr}
    # ...   username=${webem_username}
    # ...   password=${webem_password}
    # ...   alias=${testline}

    ${swPrecheckNeedReset}   UUF Software Precheck Need Reset   testline=${testline}   package_type=target
    Set Suite Variable   ${swPrecheckNeedReset}

    Run Keyword And Ignore Error   COAM Wait Software Update Possible   testline=${testline}

    ${package_version}   Replace String   ${package_version}   SBTS00   ${package_release}
    Run Keyword And Continue On Failure   UUF SWM Precheck   testline=${testline}   package_version=${package_version}   precheckType=fullCheck
    NetAct SWM Operation   dist_name=${dist_name}   operation=download   package_version=${package_version}
    Wait Until Keyword Succeeds   2x   30s
    ...   NetAct SWM Operation   dist_name=${dist_name}   operation=activation   package_version=${package_version}

    ${disconnect_ims2_exist}   Run Keyword And Return Status
    ...   OperatingSystem.File Should Exist   ${OUTPUT_DIR}/admin_api_${testline}_disconnect_at_*.ims2
    Log To Console   Admin API Disconnect IMS2: ${disconnect_ims2_exist}


    Run Keyword And Ignore Error   COAM Logout   connection=${testline}

    Wait Until Keyword Succeeds   20m   1m
    ...   COAM Login
    ...   bts_host=${webem_addr}
    ...   username=${webem_username}
    ...   password=${webem_password}
    ...   alias=${testline}

    Log To Console   Reconnected.
    Log To Console   NetAct Upgrade ${testline} Done.
    [Teardown]   Run Keyword And Ignore Error   COAM Logout   connection=${testline}


NetAct Provision Single Testline
    [Arguments]   ${testline}
    Log To Console   NetAct Provision Single Testline: ${testline}

    Return From Keyword If   ${DEBUG}

    ${testline_type}   ${testline_index}   Split String   ${testline}   _
    ${package_version}   Set Variable   ${UPGRADE_BUILD_INFO_DICT['${testline_type}']['target']['version']}
    ${package_path}   Set Variable   ${UPGRADE_BUILD_INFO_DICT['${testline_type}']['target']['path']}
    ${package_release}   Set Variable   ${UPGRADE_BUILD_INFO_DICT['${testline_type}']['target']['release']}

    # ENB
    Return From Keyword If   "${testline_type}"=="enb"


    # GNB
    Log To Console   NetAct Provision ${testline} To Target Build: ${package_version}

    ${dist_name}   Get Variable Value   ${ALL_CONFIG_SCF["${testline}"]["dist_name"]}
    Run Keyword And Ignore Error   NetAct SWM Operation   dist_name=${dist_name}   operation=upload

    Set Suite Variable   ${swPrecheckNeedReset}   ${False}

    ${package_version}   Replace String   ${package_version}   SBTS00   ${package_release}
    Wait Until Keyword Succeeds   2x   30s
    ...   NetAct SWM Operation   dist_name=${dist_name}   operation=provision   package_version=${package_version}
    Log To Console   NetAct Provision ${testline} Done.


# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
# NetAct
UUF Process NetAct Upgrade Independent

    FOR   ${testline}   IN   @{upgrade_sequence}
        UUF NetAct Upgrade Execution Results Independent   testline=${testline}
    END

    FOR   ${testline}   IN   @{upgrade_sequence}
        ${testline_type}   ${testline_index}   Split String   ${testline}   _
        Continue For Loop If   "${testline_type}"=="enb"

        NetAct Provision Single Testline   testline=${testline}
        UUF Check Point Process   testline=${testline}
    END


UUF NetAct Upgrade Execution Results Independent
    [Arguments]   ${testline}
    ${start_time}   DateTime.Get Current Date   UTC   result_format=%Y-%m-%dT%H:%M:%S
    Run Keyword And Ignore Error   UUF Save Execution Results JSON Dictionary
    ...   action=${TEST_NAME}   testline=${testline}   add_key=start_time   add_value=${start_time}

    ${tmo_decoupling}  NetAct Upgrade Single Testline Independent   testline=${testline}
    Return From Keyword If   "${tmo_decoupling}"=="tmo_decoupling"

    UUF Check Point Process   testline=${testline}

    [Teardown]   Run Keyword And Ignore Error   Run Keyword If   "${tmo_decoupling}"!="tmo_decoupling"
    ...   UUF Save FOR Loop Result   testline=${testline}


NetAct Upgrade Single Testline Independent
    [Arguments]   ${testline}
    Log To Console   NetAct Upgrade Single Testline Independent: ${testline}

    ${testline_type}   ${testline_index}   Split String   ${testline}   _
    ${package_version}   Set Variable   ${UPGRADE_BUILD_INFO_DICT['${testline_type}']['target']['version']}
    ${package_path}   Set Variable   ${UPGRADE_BUILD_INFO_DICT['${testline_type}']['target']['path']}
    ${package_release}   Set Variable   ${UPGRADE_BUILD_INFO_DICT['${testline_type}']['target']['release']}

    # ENB
    # ${tmo_decoupling}   Run Keyword If   "${testline_type}"=="enb"   ADMIN Upgrade Single Testline Independent   testline=${testline}
    # ${tmo_decoupling}   Run Keyword If   "${testline_type}"=="enb"   ADMIN Upgrade Single Testline   testline=${testline}
    ${tmo_decoupling}   Run Keyword If   "${testline_type}"=="enb"   NetAct Upgrade Single Testline   testline=${testline}
    Return From Keyword If   "${testline_type}"=="enb"   ${tmo_decoupling}

    # GNB
    ${webem_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_addr']}
    ${webem_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_username']}
    ${webem_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_password']}


    ${dist_name}   Get Variable Value   ${ALL_CONFIG_SCF["${testline}"]["dist_name"]}
    Run Keyword And Ignore Error   NetAct SWM Operation   dist_name=${dist_name}   operation=upload

    Log To Console   NetAct Upgrade RuSwOnly Download.
    ${package_version}   Replace String   ${package_version}   SBTS00   ${package_release}
    NetAct SWM Operation   dist_name=${dist_name}   operation=download   package_version=${package_version}

    # NetAct Upgrade RuSwOnly
    Log To Console   NetAct Upgrade RuSwOnly Activation.
    ${custom_attributes}   Create Dictionary   independentSwUpgradeType=RuSwOnly
    Wait Until Keyword Succeeds   2x   30s   NetAct SWM Operation
    ...   dist_name=${dist_name}   operation=activation   package_version=${package_version}   custom_attributes=${custom_attributes}

    #Check Point After RuSwOnly
    Log To Console   UUF Check Point Process After RuSwOnly.
    UUF Check Point Process After RuSwOnly   testline=${testline}   package_version=${package_version}

    # NetAct Upgrade Du
    Log To Console   NetAct Upgrade DU.
    OperatingSystem.Run   command=rm -rf ${OUTPUT_DIR}/admin_api_*_disconnect_at_*.ims2
    OperatingSystem.File Should Not Exist   ${OUTPUT_DIR}/admin_api_*_disconnect_at_*.ims2

    COAM Login
    ...   bts_host=${webem_addr}
    ...   username=${webem_username}
    ...   password=${webem_password}
    ...   alias=${testline}

    ${swPrecheckNeedReset}   UUF Software Precheck Need Reset   testline=${testline}   package_type=target
    Set Suite Variable   ${swPrecheckNeedReset}

    Run Keyword And Ignore Error   COAM Wait Software Update Possible   testline=${testline}

    Wait Until Keyword Succeeds   2x   30s
    ...   NetAct SWM Operation   dist_name=${dist_name}   operation=activation   package_version=${package_version}

    ${disconnect_ims2_exist}   Run Keyword And Return Status
    ...   OperatingSystem.File Should Exist   ${OUTPUT_DIR}/admin_api_${testline}_disconnect_at_*.ims2
    Log To Console   Admin API Disconnect IMS2: ${disconnect_ims2_exist}

    Run Keyword And Ignore Error   COAM Logout   connection=${testline}

    Wait Until Keyword Succeeds   20m   1m
    ...   COAM Login
    ...   bts_host=${webem_addr}
    ...   username=${webem_username}
    ...   password=${webem_password}
    ...   alias=${testline}

    [Teardown]   Run Keyword And Ignore Error   COAM Logout   connection=${testline}

