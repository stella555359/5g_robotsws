*** Settings ***
Resource    ../coam_ulm.robot
Resource    ../connect.robot
Library     taf.sbts.oam.coam.admin     WITH NAME   admin

Suite Setup      Create Admin Session
Suite Teardown   Teardown All Admin Sessions


*** Test Cases ***
Test Verify BTS Sync Mode
    [TAGS]              COAM
    Verify BTS Sync Mode    sync_mode=PhaseSync    alias=${oam_alias}

Test Verify BTS Sync Mode Error Case
    [TAGS]              COAM
    Run Keyword And Expect Error    *   Verify BTS Sync Mode    sync_mode=FreqSync    alias=${oam_alias}

Test Get BTS Active Sync Source
    [TAGS]              COAM
    Get BTS Active Sync Source      alias=${oam_alias}

Test Get BTS Active Sync Source Error Case
    [TAGS]              COAM
    Run Keyword And Expect Error    *   Get BTS Active Sync Source  alias=${oam_alias}  tuning_mode=Unknown
    Run Keyword And Expect Error    *   Get BTS Active Sync Source  alias=${oam_alias}  sync_mode=Unknown

Test Verify Active BTS Sync Source
    [TAGS]              COAM
    Verify Active BTS Sync Source   alias=${oam_alias}

Test Verify Active BTS Sync Source Error Case
    [TAGS]              COAM
    Run Keyword And Expect Error    *   Verify Active BTS Sync Source   alias=${oam_alias}  sync_type=Unknown

Test Verify Common Unit State
    [TAGS]              COAM
    Verify Common Unit State        alias=${oam_alias}

Test Verify Capacity Unit State
    [TAGS]              COAM
    Verify Capacity Unit State      alias=${oam_alias}

Test Detected HW Info
    [TAGS]              COAM
    ${bts_hw}   Detected HW Info    alias=${oam_alias}
    ${sorted_keys}  Get Dictionary Keys     ${bts_hw}
    Should Not Be Empty     ${sorted_keys}  BTS Info dictionary has no keys!

Test Get Software Version
    [TAGS]              COAM
    ${bts_sw}   Get Software Version    alias=${oam_alias}
    Should Not Be Empty     ${bts_sw}

Test Get cOAM Bts Info
    [TAGS]              COAM
    ${bts_info}     Get cOAM Bts Info       alias=${oam_alias}
    ${sorted_keys}  Get Dictionary Keys     ${bts_info}
    Should Not Be Empty     ${sorted_keys}  BTS Info dictionary has no keys!

Test Get avaiabilityStatus from Status Dictionary
    [TAGS]              COAM
    &{status_dict_prior_CNI-61110}  Create Dictionary   usageState=Active  proceduralStatus=configured
    ...     barringStatus=unbarred      administrativeState=Unlocked
    ...     availabilityStatus=Online
    ${state}    Get avaiabilityStatus from Status Dictionary    ${status_dict_prior_CNI-61110}
    Log To Console  ${\n}avaiabilityStatus is '${state}'
    Should Be Equal     ${state}    Online
    &{status_dict_post_CNI-61110}  Create Dictionary   usageState=Active  proceduralStatus=configured
    ...     barringStatus=unbarred      administrativeState=Unlocked
    ${state}    Get avaiabilityStatus from Status Dictionary    ${status_dict_post_CNI-61110}
    Log To Console  ${\n}avaiabilityStatus is '${state}'
    Should Not Be Equal     ${state}    Online


Test Nidd availabilityStatus Value Should Be One Of Prior CNI-61110
    [TAGS]              COAM
    &{status_dict}  Create Dictionary   usageState=Active  proceduralStatus=configured
    ...     barringStatus=unbarred      administrativeState=Unlocked
    ...     availabilityStatus=Online
    Nidd availabilityStatus Value Should Be One Of  ${status_dict}   Online,Degraded
    Nidd availabilityStatus Value Should Be One Of  ${status_dict}   Online
    Run Keyword And Expect Error    *   Nidd availabilityStatus Value Should Be One Of  ${status_dict}   Degraded

Test Nidd availabilityStatus Value Should Be One Of Post CNI-61110
    [TAGS]              COAM
    &{status_dict}  Create Dictionary   usageState=Active  proceduralStatus=configured
    ...     barringStatus=unbarred      administrativeState=Unlocked
    Nidd availabilityStatus Value Should Be One Of  ${status_dict}   Online,Degraded
    Nidd availabilityStatus Value Should Be One Of  ${status_dict}   Online
    Run Keyword And Expect Error    *   Nidd availabilityStatus Value Should Be One Of  ${status_dict}   Offline
    Run Keyword And Expect Error    *   Nidd availabilityStatus Value Should Be One Of  ${status_dict}   Offline,PowerOff


*** Keywords ***
Create Admin Session
    ${oam_alias}    connect.Setup OAM Http session  node_type=gnb   node_id=${0} 
    Set Suite Variable   ${oam_alias}
Teardown All Admin Sessions
    admin.Teardown All Aliases For Admin

