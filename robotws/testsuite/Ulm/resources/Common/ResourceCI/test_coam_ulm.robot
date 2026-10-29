*** Settings ***

Documentation
...   This is a test suite used in KW resourceCI running against real classical TL.
...   It verifies proper function of KWs in coam_ulm.robot for classical deployments.

Resource    ../coam_ulm.robot
Resource    ../connect.robot
Library     taf.sbts.oam.coam.admin     WITH NAME   admin

Suite Setup      Create Admin Session
Suite Teardown   Teardown All Admin Sessions


*** Test Cases ***
Test Verify BTS Sync Mode
    [TAGS]              COAM
    coam_ulm.Verify BTS Sync Mode    sync_mode=PhaseSync

Test Verify BTS Sync Mode Error Case
    [TAGS]              COAM
    Run Keyword And Expect Error    *   coam_ulm.Verify BTS Sync Mode    sync_mode=FreqSync

Test Get BTS Active Sync Source
    [TAGS]              COAM
    coam_ulm.Get BTS Active Sync Source

Test Get BTS Active Sync Source Error Case
    [TAGS]              COAM
    Run Keyword And Expect Error    *   coam_ulm.Get BTS Active Sync Source  tuning_mode=Unknown
    Run Keyword And Expect Error    *   coam_ulm.Get BTS Active Sync Source  sync_mode=Unknown

Test Verify Active BTS Sync Source
    [TAGS]              COAM
    coam_ulm.Verify Active BTS Sync Source

Test Verify Active BTS Sync Source Error Case
    [TAGS]              COAM
    Run Keyword And Expect Error    *   coam_ulm.Verify Active BTS Sync Source  sync_type=Unknown

Test Detected HW Info
    [TAGS]              COAM
    ${bts_hw}   coam_ulm.Detected HW Info
    ${sorted_keys}  Get Dictionary Keys     ${bts_hw}
    Should Not Be Empty     ${sorted_keys}  BTS Info dictionary has no keys!

Test Get Software Version
    [TAGS]              COAM
    ${bts_sw}   coam_ulm.Get Software Version
    Should Not Be Empty     ${bts_sw}

Test Get cOAM Bts Info
    [TAGS]              COAM
    ${bts_info}     coam_ulm.Get COAM BTS Info
    ${sorted_keys}  Get Dictionary Keys     ${bts_info}
    Should Not Be Empty     ${sorted_keys}  BTS Info dictionary has no keys!

Test Get AvailabilityStatus From Status Dictionary
    [TAGS]              COAM
    &{status_dict_prior_CNI-61110}  Create Dictionary   usageState=Active  proceduralStatus=configured
    ...     barringStatus=unbarred      administrativeState=Unlocked
    ...     availabilityStatus=Online
    ${state}    Get AvailabilityStatus From Status Dictionary    ${status_dict_prior_CNI-61110}
    Log To Console  ${\n}availabilityStatus is '${state}'
    Should Be Equal     ${state}    Online
    &{status_dict_post_CNI-61110}  Create Dictionary   usageState=Active  proceduralStatus=configured
    ...     barringStatus=unbarred      administrativeState=Unlocked
    ${state}    Get AvailabilityStatus From Status Dictionary    ${status_dict_post_CNI-61110}
    Log To Console  ${\n}availabilityStatus is '${state}'
    Should Not Be Equal     ${state}    Online


Test Nidd availabilityStatus Value Should Be One Of Prior CNI-61110
    [TAGS]              COAM
    &{status_dict}  Create Dictionary   usageState=Active  proceduralStatus=configured
    ...     barringStatus=unbarred      administrativeState=Unlocked
    ...     availabilityStatus=Online
    Nidd AvailabilityStatus Value Should Be One Of  ${status_dict}   Online,Degraded
    Nidd AvailabilityStatus Value Should Be One Of  ${status_dict}   Online
    Run Keyword And Expect Error    *   Nidd AvailabilityStatus Value Should Be One Of  ${status_dict}   Degraded

Test Nidd availabilityStatus Value Should Be One Of Post CNI-61110
    [TAGS]              COAM
    &{status_dict}  Create Dictionary   usageState=Active  proceduralStatus=configured
    ...     barringStatus=unbarred      administrativeState=Unlocked
    Nidd AvailabilityStatus Value Should Be One Of  ${status_dict}   Online,Degraded
    Nidd AvailabilityStatus Value Should Be One Of  ${status_dict}   Online
    Run Keyword And Expect Error    *   Nidd AvailabilityStatus Value Should Be One Of  ${status_dict}   Offline
    Run Keyword And Expect Error    *   Nidd AvailabilityStatus Value Should Be One Of  ${status_dict}   Offline,PowerOff


*** Keywords ***
Create Admin Session
    connect.Setup OAM HTTP Session  node_type=gnb   node_id=${0}
Teardown All Admin Sessions
    admin.Teardown All Aliases For Admin

