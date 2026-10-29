*** Settings ***
Resource   Common.robot

*** Variables ***

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
        Run Keyword If   "${TESTLINE_IDENTITY}" in ${UUF_PROCESS_ADMIN_TL}   ADMIN Upgrade Single Testline   testline=${testline}
        ...   ELSE   Wait Until Keyword Succeeds   3x   10s   WebEM Upgrade Single Testline   testline=${testline}

         UUF Check Point Process   testline=${testline}
        # UUF Check Stop Check Point
    END

    run keyword if  ${l3_call.count('Y')}>0 and ('${TESTLINE_IDENTITY}' in ${UUF_L3Call})
    ...    UUF Target Packge L3CALL Process


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

    ${swPrecheckNeedReset}   UUF Software Precheck Need Reset   testline=${testline}   package_type=target
    Set Suite Variable   ${swPrecheckNeedReset}

    UUF WebEM Login   testline=${testline}
    UUF WebEM Upgrade   testline=${testline}   package_path=${package_path}
    ${logout_status}   Run Keyword And Return Status   UUF WebEM Logout   testline=${testline}

    ${disconnect_ims2_exist}   Run Keyword And Return Status
    ...   OperatingSystem.File Should Exist   ${OUTPUT_DIR}/admin_api_${testline}_disconnect_at_*.ims2
    Log To Console   Admin API Disconnect IMS2: ${disconnect_ims2_exist}
    Log To Console   WebEM Upgrade Finished.

    [Teardown]   Run Keywords
    ...   Run Keyword And Ignore Error   run keyword if  not ${logout_status}   UUF WebEM Logout   testline=${testline}   AND
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

    ${swPrecheckNeedReset}   UUF Software Precheck Need Reset   testline=${testline}   package_type=target
    Set Suite Variable   ${swPrecheckNeedReset}

    UUF ADMIN Upgrade   testline=${testline}   package_path=${package_path}

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
        NetAct Upgrade Single Testline   ${testline}
        UUF Check Point Process   testline=${testline}
        # UUF Check Stop Check Point
    END


NetAct Upgrade Single Testline
    [Arguments]   ${testline}

    Return From Keyword If   ${DEBUG}

    ${testline_type}   ${testline_index}   Set Variable   @{testline.split('_')}
    ${package_version}   Set Variable   ${UPGRADE_BUILD_INFO_DICT['${testline_type}']['target']['version']}
    ${package_path}   Set Variable   ${UPGRADE_BUILD_INFO_DICT['${testline_type}']['target']['path']}
    ${package_release}   Set Variable   ${UPGRADE_BUILD_INFO_DICT['${testline_type}']['target']['release']}

    # ENB
    Run Keyword If   "${testline_type}"=="enb"   WebEM Upgrade Single Testline   testline=${testline}
    Return From Keyword If   "${testline_type}"=="enb"


    # GNB
    Log To Console   NetAct Upgrade ${testline} To Target Build: ${package_version}

    ${webem_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_addr']}
    ${webem_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_username']}
    ${webem_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_password']}

    OperatingSystem.Run   command=rm -rf ${OUTPUT_DIR}/admin_api_*_disconnect_at_*.ims2
    OperatingSystem.File Should Not Exist   ${OUTPUT_DIR}/admin_api_*_disconnect_at_*.ims2

    Run Keyword And Ignore Error   UUF SWM Upload   testline=${testline}

    COAM Login
    ...   bts_host=${webem_addr}
    ...   username=${webem_username}
    ...   password=${webem_password}
    ...   alias=${testline}

    ${swPrecheckNeedReset}   UUF Software Precheck Need Reset   testline=${testline}   package_type=target
    Set Suite Variable   ${swPrecheckNeedReset}

    ${dist_name}   Get Variable Value   ${ALL_CONFIG_SCF["${testline}"]["dist_name"]}
    ${package_version}   Replace String   ${package_version}   SBTS00   ${package_release}
    ${operation_id}   Wait Until Keyword Succeeds   5x   10s
    ...   Selenium NetAct SWM Operation   dist_name=${dist_name}   operation=Download   package_version=${package_version}
    Log To Console   Download operation_id: ${operation_id}
    Wait Until Keyword Succeeds   60m   1m   swmCLI Check NetAct SWM Operation By Operation ID   dist_name=${dist_name}   operation_id=${operation_id}

    ${operation_id}   Wait Until Keyword Succeeds   5x   10s
    ...   Selenium NetAct SWM Operation   dist_name=${dist_name}   operation=Activation   package_version=${package_version}
    Log To Console   Activation operation_id: ${operation_id}
    Wait Until Keyword Succeeds   20m   1m   swmCLI Check NetAct SWM Operation By Operation ID   dist_name=${dist_name}   operation_id=${operation_id}


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
