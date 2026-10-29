*** Settings ***
Documentation
...      == COPYRIGHT ==
...          Nokia Networks
...      == AUTHORS ==
...        - Michal Gorski <michal.gorski@nokia.com>
...        - Krzysztof Korczak <krzysztof.korczak@nokia.com>
...        - Maciej Majewski <maciej.majewski@nokia.com>
...        - Tomasz Siuta <tomasz.siuta@nokia.com>
...        - Arkadiusz Sobejko <arkadiusz.sobejko@nokia.com>
...        - Patryk Wojcik <patryk.wojcik@nokia.com>
...      == MAINTAINER ==
...        - Michal Gorski <michal.gorski@nokia.com>
...        - Krzysztof Korczak <krzysztof.korczak@nokia.com>
...        - Maciej Majewski <maciej.majewski@nokia.com>
...        - Tomasz Siuta <tomasz.siuta@nokia.com>
...        - Arkadiusz Sobejko <arkadiusz.sobejko@nokia.com>
...        - Patryk Wojcik <patryk.wojcik@nokia.com>

Library     ute_fsmaccess
Library     ute_wtssim
Library     ta5g_pm_counters
Library     ta5g_testline_management
Library     ta_emss
Library     ta_messaging
Resource    ../../resources_kr/robot/common_keywords.robot
Library     ../../resources_kr/python/common_keywords.py
Library     CB008009_resources.py


*** Keywords ***
Setup test environment
    Prepare suite environment  egate_config=${lua_cfg_file}  ap_xml=${ap_xml}  scfc=${scfc}

Attach 3 additional UEs and start gNB Addition Procedure
    Attach UE    UE_ID=12
    SgNB Addition  UE_ID=12  CELL_ID=1
    Attach UE    UE_ID=13
    SgNB Addition  UE_ID=13  CELL_ID=1
    Attach UE    UE_ID=14
    SgNB Addition  UE_ID=14  CELL_ID=1

Register 3 additional UEs and establish PDUs sessions
    Register UE  UE_ID=2  CELL_ID=1
    Establish PDU session  UE_ID=2
    Register UE  UE_ID=3  CELL_ID=1
    Establish PDU session  UE_ID=3
    Register UE  UE_ID=4  CELL_ID=1
    Establish PDU session  UE_ID=4

Detach NR-UEs and deconfigure gNB and clear environment
    SgNB release  UE_ID=14
    SgNB release  UE_ID=13
    SgNB release  UE_ID=12
    SgNB release  UE_ID=11
    Detach UE  UE_ID=14
    Detach UE  UE_ID=13
    Detach UE  UE_ID=12
    Detach UE  UE_ID=11
    Deactivate automatic PM Stats

Deregister UEs and clear up test environment
    Release PDU session  UE_ID=4
    Release PDU session  UE_ID=3
    Release PDU session  UE_ID=2
    Release PDU session  UE_ID=1
    Deregister UE  UE_ID=4
    Deregister UE  UE_ID=3
    Deregister UE  UE_ID=2
    Deregister UE  UE_ID=1

Set feature flag ${MOC}-${ID}/${parameter} to ${value}
    Log to console  Set feature flag ${MOC}-${ID}/${parameter} to ${value}
    Configure  {'MOC': '${MOC}', 'ID': '${ID}', '${parameter}': '${value}'}

Activate automatic PM Stats
    Run Emssim Command    auto_stats    params=on

Deactivate automatic PM Stats
    Run Emssim Command    auto_stats    params=off

Change feature scale to logarithmic
    Set feature flag NRBTS-1/thpHistScale to logarithmic

Configure NSA PMQAP Profiles
    Configure   ${CURDIR}/../config/activating_NSA_PMQAP_profiles.yaml

Configure SA PMQAP Profiles
    Configure   ${CURDIR}/../config/activating_SA_PMQAP_profiles.yaml

Verify value of counter
    [Arguments]  ${counter_id}  ${pm_counter_file}  ${expected_value}  ${margin}=10
    ${counter}=  Get counter values  counter_id=${counter_id}  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1  pm_counter_file=${pm_counter_file}
    Run Keyword And Continue On Failure
    ...  Check counter value  counter_id=${counter_id}  pm_counters_values=${counter}
    ...  expected_value=${expected_value}  margin=${margin}

Get counter values and evaluate division
    [Arguments]  ${counter_1}  ${counter_2}  ${min}  ${max}  ${pm_counters}

    ${counter_1_val}=    Get Nonzero Counter Values    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...                  counter_id=${counter_1}    pm_counter_file=${pm_counters}
    ${counter_2_val}=    Get Nonzero Counter Values    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...                  counter_id=${counter_2}    pm_counter_file=${pm_counters}
    ${throughput}=      Evaluate    ${counter_1_val}/(${counter_2_val}/1000)
	Log to console      Throughput counted by division of counters ${counter_1} and ${counter_2} is ${throughput} kbps.
    Run Keyword And Continue On Failure
    ...  Should Be True      ${min}<=${throughput}<=${max}
