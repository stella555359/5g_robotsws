*** Settings ***
Resource   Common.robot

*** Variables ***

*** Keywords ***
UUF Process WebEM Rollback
    Log To Console   //TODO: UUF Process WebEM Rollback

    Return From Keyword If   ${DEBUG}

    FOR   ${testline}   IN   @{ROLLBACK_SEQUENCE}
        Run Keyword If   "${TESTLINE_IDENTITY}" in ${UUF_PROCESS_ADMIN_TL}   ADMIN Rollback Single Testline   testline=${testline}
        ...   ELSE   Wait Until Keyword Succeeds   3x   10s   WebEM Rollback Single Testline   testline=${testline}
        UUF Check Point Process   testline=${testline}
        # UUF Check Stop Check Point
    END


WebEM Rollback Single Testline
    [Arguments]   ${testline}

    Return From Keyword If   ${DEBUG}

    Log To Console   WebEM Rollback ${testline}
    UUF WebEM Login   testline=${testline}
    UUF WebEM Rollback   testline=${testline}

    Log To Console   WebEM Rollback Finished.

    [Teardown]   Run Keyword And Ignore Error   UUF WebEM Logout   testline=${testline}


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

    UUF ADMIN Rollback   testline=${testline}

    Log To Console   ADMIN Rollback Finished.
    [Teardown]   Run Keyword And Ignore Error   COAM Logout   connection=${testline}



# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================


UUF Process NetAct Rollback
    Log To Console   //TODO: UUF Process WebEM Rollback

    Return From Keyword If   ${DEBUG}

    FOR   ${testline}   IN   @{ROLLBACK_SEQUENCE}
        NetAct Rollback Single Testline   testline=${testline}
        UUF Check Point Process   testline=${testline}
        # UUF Check Stop Check Point
    END


NetAct Rollback Single Testline
    [Arguments]   ${testline}

    Return From Keyword If   ${DEBUG}

    Log To Console   NetAct Rollback ${testline}

    # ENB
    ${testline_type}   ${testline_index}   Set Variable   @{testline.split('_')}
    Run Keyword If   "${testline_type}"=="enb"   WebEM Rollback Single Testline   testline=${testline}
    Return From Keyword If   "${testline_type}"=="enb"


    # GNB
    ${dist_name}   Get Variable Value   ${ALL_CONFIG_SCF["${testline}"]["dist_name"]}
    ${operation_id}   Wait Until Keyword Succeeds   5x   10s
    ...   Selenium NetAct SWM Operation   dist_name=${dist_name}   operation=Rollback
    Log To Console   Rollback operation_id: ${operation_id}
    Wait Until Keyword Succeeds   60m   1m   swmCLI Check NetAct SWM Operation By Operation ID   dist_name=${dist_name}   operation_id=${operation_id}

    Log To Console   NetAct Rollback Finished. Wait For Reconnection...

    ${webem_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_addr']}
    ${webem_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_username']}
    ${webem_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_password']}

    Wait Until Keyword Succeeds   20m   1m
    ...   COAM Login
    ...   bts_host=${webem_addr}
    ...   username=${webem_username}
    ...   password=${webem_password}
    ...   alias=${testline}

    Log To Console   Reconnected.
    Log To Console   NetAct Rollback ${testline} Done.
    [Teardown]   Run Keyword And Ignore Error   COAM Logout   connection=${testline}
