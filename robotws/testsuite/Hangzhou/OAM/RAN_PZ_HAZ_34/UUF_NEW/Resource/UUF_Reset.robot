*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com

Resource   Common.robot

*** Keywords ***
UUF Process WebEM Reset
    Log To Console   //TODO: UUF Process WebEM Reset

    # Return From Keyword If   ${DEBUG}

    FOR   ${testline}   IN   @{RESET_SEQUENCE}
        ${testline_type}   ${testline_index}   Split String   ${testline}   _
        Continue For Loop If   "${testline_type}"=="enb" and ${TMO_DECOUPLING}

        # Run Keyword If   "${TESTLINE_IDENTITY}" in ${UUF_PROCESS_ADMIN_TL}   ADMIN Reset Single Testline   testline=${testline}
        # ...   ELSE   WebEM Reset Single Testline   testline=${testline}
        # UUF Check Point Process   testline=${testline}
        # # UUF Check Stop Check Point
        UUF Reset Execution Results   testline=${testline}
    END


UUF Reset Execution Results
    [Arguments]   ${testline}
    ${start_time}   DateTime.Get Current Date   UTC   result_format=%Y-%m-%dT%H:%M:%S
    Run Keyword And Ignore Error   UUF Save Execution Results JSON Dictionary
    ...   action=${TEST_NAME}   testline=${testline}   add_key=start_time   add_value=${start_time}

    Run Keyword If   "${TESTLINE_IDENTITY}" in ${UUF_PROCESS_ADMIN_TL}   ADMIN Reset Single Testline   testline=${testline}
    ...   ELSE   WebEM Reset Single Testline   testline=${testline}
    UUF Check Point Process   testline=${testline}
    # UUF Check Stop Check Point

    [Teardown]   UUF Save FOR Loop Result   testline=${testline}



WebEM Reset Single Testline
    [Arguments]   ${testline}

    Return From Keyword If   ${DEBUG}

    Log To Console   WebEM Reset ${testline}

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

    UUF WebEM Login   testline=${testline}
    UUF WebEM Reset   testline=${testline}

    ${disconnect_ims2_exist}   Run Keyword And Return Status
    ...   OperatingSystem.File Should Exist   ${OUTPUT_DIR}/admin_api_${testline}_disconnect_at_*.ims2
    Log To Console   Admin API Disconnect IMS2: ${disconnect_ims2_exist}
    Log To Console   WebEM Reset Finished.

    [Teardown]   Run Keywords
    ...   Run Keyword And Ignore Error   UUF WebEM Logout   testline=${testline}
    ...   AND
    ...   Run Keyword And Ignore Error   COAM Logout   connection=${testline}


ADMIN Reset Single Testline
    [Arguments]   ${testline}

    Return From Keyword If   ${DEBUG}

    Log To Console   ADMIN Reset ${testline}
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


    Wait Until Keyword Succeeds   20min   2min   Run Keywords
    ...   oam_kpi.save_search_start_timestamp
    ...   AND
    ...   Sleep   6s
    ...   AND
    ...   UUF ADMIN Reset   testline=${testline}

    ${disconnect_ims2_exist}   Run Keyword And Return Status
    ...   OperatingSystem.File Should Exist   ${OUTPUT_DIR}/admin_api_${testline}_disconnect_at_*.ims2
    Log To Console   Admin API Disconnect IMS2: ${disconnect_ims2_exist}
    Log To Console   ADMIN Reset ${testline} Done.
    [Teardown]   Run Keyword And Ignore Error   COAM Logout   connection=${testline}
