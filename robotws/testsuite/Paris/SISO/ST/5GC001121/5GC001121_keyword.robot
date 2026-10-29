*** Settings ***
Documentation
...         Description : Testcases for Feature 5GC001121_AMOD
...         5GC001121 aims to support of 5G classical gNB and cloud gNB-DU on ASIK A102/M02 and ABIL/ABIL2
...            on AMOD Sub-rack
...
...         AUTHOR (I&V):   Merwane CHEMSSI         merwane.chemssi@nokia.com
...                         Joseph SOQUES           joseph.soques@nokia.com
...                         Philippe GABORIEAU      philippe.gaborieau@nokia.com


Library    BuiltIn
Library    Collections
Library    taf.rfrl.bts.commissioning
Library    taf.gnb.oam.coam.admin                    WITH NAME    admin
Library    taf.transport.ssh                         WITH NAME    ssh

Library     OperatingSystem
Library     String
Library     Process
Library     DateTime

Library     ute_reporting_portal

Resource    ../resources/kw_coam_UTECM.robot
Resource    ../resources/kw_classical.robot


*** Keywords ***

kw_5GC001121_A_8_Check HW infos
    Wait until Keyword Succeeds     180s    10s      Check Rack Type


kw_5GC001121_A_4_5gBTS_Basic_Synchro
    Wait until Keyword Succeeds   300s  5s    Check Sync Status


kw_5GC001121_A_6_5gBTS_Site_Reset
    [Documentation]  Loop of 5 resets with check of status of all HW modules
    ...              a sleep of 15min is necessary between two resets to avoid fallback

    FOR    ${TEST_LOOP}   IN RANGE   0  ${MAX_LOOP}
       ${date}=                                         Get Current Date        result_format=%Y-%m-%d_%H:%M:%S
       Log                                   GNB Reset Iteration ${TEST_LOOP} in progress at: ${date}
        Perform gNB Site Reset
        Wait until Keyword Succeeds     300s        30s         Check FSM Status From WEBUI
        Wait until Keyword Succeeds     300s        30s         Check FBBs Status From WEBUI
        Wait until Keyword Succeeds     600s        30s         Check RUs Status
        Wait until Keyword Succeeds     300s        30s         Check Cell Status
       Sleep                                            300s
    END


kw_5GC001121_A_7_5gBTS_Snapshot
    ${current_date}=                Get Current Date        result_format=%Y%m%d_%H%M%S
    set suite variable              ${current_date}
    Wait until Keyword Succeeds     600s    30s      CreateSnapshot


kw_5GC001121_A_9_Cell_Setup
    Wait until Keyword Succeeds     300s        30s         Check FSM Status From WEBUI
    Wait until Keyword Succeeds     300s        30s         Check FBBs Status From WEBUI
    Wait until Keyword Succeeds     300s        30s         Check Cell Status
