*** Settings ***
Documentation    CI interface keywords,
...              WA to report configuration id to reporting portal test-runs view
...              Please do not modify the file without notification to author
...              Author: Fan Geyou
...              Contact: geyou.fan@nokia-sbell.com

Library          taf.sw.scout
Library          Collections
Library          OperatingSystem

*** Variables ***
&{TL_IN_SCOUT}    7_5_UTE5G402T382=7_5_UTE5G402T382_11    7_5_UTE5G402T344=7_5_UTE5G402T344_11
...               7_5_UTE5G402T385=7_5_UTE5G402T385_11    7_5_UTE5G402T386=7_5_UTE5G402T386_11    7_5_UTE5G402T387=7_5_UTE5G402T387_11
...               7_5_UTE5G402T777=7_5_UTE5G402T777_5G-1    7_5_UTE5G402T242=7_5_UTE5G402T242_11
...               7_5_UTE5G402T383=7_5_UTE5G402T383_11    7_5_UTE5G402T852=7_5_UTE5G402T852_5G
...               7_5_UTE5G402T384=7_5_UTE5G402T384_1
...               7_5_UTE5G402T2012=7_5_UTE5G402T2012_2

*** Keywords ***
Requset Configuration Id Report
    [Documentation]    keyword to collect configuration_id stuff
    ${no_ute_env}    run keyword and return status    Environment Variable Should Not Be Set    CM_EXECUTION_ID
    ${testline}   run keyword if    ${no_ute_env}    set variable     ${testline_name}
    ...           ELSE    String.Fetch From Right    string=${CONFIGURATION}    marker=.
    ${specail}    run keyword and return status    Dictionary Should Contain Key    ${TL_IN_SCOUT}    ${testline}
    ${testline}    set variable if    ${specail}    ${TL_IN_SCOUT}[${testline}]    ${testline}
    ${scout_tl}    Get Variable Value  ${SCOUT_TL_NAME}    ${testline}
    ${success}    run keyword and return status    __Request Scf By Scout    scout_tl=${scout_tl}    no_ute=${no_ute_env}
    run keyword if  not ${success}    __Request Scf By Scout    scout_tl=${scout_tl}_11    no_ute=${no_ute_env}
    [Return]    ${testline}

__Request Scf By Scout
    [Timeout]    8 minutes
    [Arguments]    ${scout_tl}    ${no_ute}=${True}
    ${tl_on_scout}    run keyword and return status    taf.sw.scout.setup_scout    ${scout_tl}
    return from keyword if    '${tl_on_scout}'=='False'
    ${scf_id}    Wait Until Keyword Succeeds    3x    5 sec    taf.sw.scout.request_scf
    ...    use_scout_internal_id=${no_ute}    timeout=${90}
    run keyword if    ${no_ute}    set tags   ute:id:${scf_id}
    [Teardown]    run keyword if    ${tl_on_scout}    taf.sw.scout.teardown_scout_api
