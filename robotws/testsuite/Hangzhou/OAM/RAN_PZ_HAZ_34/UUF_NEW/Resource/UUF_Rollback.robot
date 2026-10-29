*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com

Resource   Common.robot


*** Keywords ***
UUF Process WebEM Rollback
    Log To Console   //TODO: UUF Process WebEM Rollback

    # Return From Keyword If   ${DEBUG}

    FOR   ${testline}   IN   @{ROLLBACK_SEQUENCE}
        ${testline_type}   ${testline_index}   Split String   ${testline}   _
        Continue For Loop If   "${testline_type}"=="enb" and ${TMO_DECOUPLING}

        # Run Keyword If   "${TESTLINE_IDENTITY}" in ${UUF_PROCESS_ADMIN_TL}   ADMIN Rollback Single Testline   testline=${testline}
        # ...   ELSE   Wait Until Keyword Succeeds   3x   10s   WebEM Rollback Single Testline   testline=${testline}
        # UUF Check Point Process   testline=${testline}
        # # UUF Check Stop Check Point
        UUF Rollback Execution Results   testline=${testline}
    END


UUF Rollback Execution Results
    [Arguments]   ${testline}
    ${start_time}   DateTime.Get Current Date   UTC   result_format=%Y-%m-%dT%H:%M:%S
    Run Keyword And Ignore Error   UUF Save Execution Results JSON Dictionary
    ...   action=${TEST_NAME}   testline=${testline}   add_key=start_time   add_value=${start_time}

    Run Keyword If   "${TESTLINE_IDENTITY}" in ${UUF_PROCESS_ADMIN_TL}   ADMIN Rollback Single Testline   testline=${testline}
    ...   ELSE   Wait Until Keyword Succeeds   3x   10s   WebEM Rollback Single Testline   testline=${testline}
    UUF Check Point Process   testline=${testline}
    # UUF Check Stop Check Point

    [Teardown]   UUF Save FOR Loop Result   testline=${testline}



WebEM Rollback Single Testline
    [Arguments]   ${testline}

    Return From Keyword If   ${DEBUG}

    ${webem_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_addr']}
    ${webem_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_username']}
    ${webem_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_password']}

    COAM Login
    ...   bts_host=${webem_addr}
    ...   username=${webem_username}
    ...   password=${webem_password}
    ...   alias=${testline}

    Run Keyword And Ignore Error   COAM Wait Software Update Possible   testline=${testline}

    Log To Console   WebEM Rollback ${testline}
    UUF WebEM Login   testline=${testline}
    UUF WebEM Rollback   testline=${testline}

    Log To Console   WebEM Rollback Finished.

    [Teardown]   Run Keywords
    ...   Run Keyword And Ignore Error   UUF WebEM Logout   testline=${testline}   AND
    ...   Run Keyword And Ignore Error   COAM Logout   connection=${testline}


ADMIN Rollback Single Testline
    [Arguments]   ${testline}

    Return From Keyword If   ${DEBUG}

    Log To Console   ADMIN Rollback ${testline}

    ${webem_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_addr']}
    ${webem_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_username']}
    ${webem_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_password']}

    COAM Login
    ...   bts_host=${webem_addr}
    ...   username=${webem_username}
    ...   password=${webem_password}
    ...   alias=${testline}

    Run Keyword And Ignore Error   COAM Wait Software Update Possible   testline=${testline}

    Wait Until Keyword Succeeds   20min   2min   UUF ADMIN Rollback   testline=${testline}

    Log To Console   ADMIN Rollback Finished.
    [Teardown]   Run Keyword And Ignore Error   COAM Logout   connection=${testline}



# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================


UUF Process NetAct Rollback
    Log To Console   //TODO: UUF Process WebEM Rollback

    Return From Keyword If   ${DEBUG}

    FOR   ${testline}   IN   @{ROLLBACK_SEQUENCE}
        ${testline_type}   ${testline_index}   Split String   ${testline}   _
        Continue For Loop If   "${testline_type}"=="enb" and ${TMO_DECOUPLING}

        # NetAct Rollback Single Testline   testline=${testline}
        # UUF Check Point Process   testline=${testline}
        # # UUF Check Stop Check Point
        UUF NetAct Rollback Execution Results   testline=${testline}
    END


UUF NetAct Rollback Execution Results
    [Arguments]   ${testline}
    ${start_time}   DateTime.Get Current Date   UTC   result_format=%Y-%m-%dT%H:%M:%S
    Run Keyword And Ignore Error   UUF Save Execution Results JSON Dictionary
    ...   action=${TEST_NAME}   testline=${testline}   add_key=start_time   add_value=${start_time}

    NetAct Rollback Single Testline   testline=${testline}
    UUF Check Point Process   testline=${testline}
    # UUF Check Stop Check Point

    [Teardown]   UUF Save FOR Loop Result   testline=${testline}



NetAct Rollback Single Testline
    [Arguments]   ${testline}

    Return From Keyword If   ${DEBUG}

    Log To Console   NetAct Rollback ${testline}

    # ENB
    ${testline_type}   ${testline_index}   Set Variable   @{testline.split('_')}
    Run Keyword If   "${testline_type}"=="enb"   ADMIN Rollback Single Testline   testline=${testline}
    Return From Keyword If   "${testline_type}"=="enb"


    # GNB
    ${webem_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_addr']}
    ${webem_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_username']}
    ${webem_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_password']}

    COAM Login
    ...   bts_host=${webem_addr}
    ...   username=${webem_username}
    ...   password=${webem_password}
    ...   alias=${testline}

    Run Keyword And Ignore Error   COAM Wait Software Update Possible   testline=${testline}

    ${dist_name}   Get Variable Value   ${ALL_CONFIG_SCF["${testline}"]["dist_name"]}
    Wait Until Keyword Succeeds   2x   30s
    ...   NetAct SWM Operation   dist_name=${dist_name}   operation=rollback

    Log To Console   NetAct Rollback Finished. Wait For Reconnection...

    Run Keyword And Ignore Error   COAM Logout   connection=${testline}

    Wait Until Keyword Succeeds   20m   1m
    ...   COAM Login
    ...   bts_host=${webem_addr}
    ...   username=${webem_username}
    ...   password=${webem_password}
    ...   alias=${testline}

    Log To Console   Reconnected.
    Log To Console   NetAct Rollback ${testline} Done.
    [Teardown]   Run Keyword And Ignore Error   COAM Logout   connection=${testline}
