*** Settings ***
Documentation
...   Author: Wang Yuhan
...   Contact: yuhan.wang@nokia-sbell.com
...   Description: This is the module test case

Resource          ../../../../RRM/RAN_PZ_HAZ_1/Resources/Cloud/AIC_Common_Resource.robot
Resource          ../../Resources/Cloud/AIC_Common_Resource.robot


Suite Setup        Common Suite Setup For AIC
Suite Teardown     Common Suite Teardown For AIC


Force Tags        CRT    QCD_MN_RAN    QCP_RAN_VRF    STATE_SKIP_AGENT
...               CA_RAN_PZ_HAZ_1    RAN_VRF_HAZ1    TA_LEVEL_22

Test Timeout      60 minutes

*** Variables ***
&{dcap_info}    host=10.69.9.51    port=443    username=dcapuser    password=Nokia1234!

*** Test Cases ***
# Normal cases
CB013789_TC05
    [Tags]    CRT   QC_241846    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: yuhan.wang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    22.09.2025, yuhan.wang@nokia-sbell.com, draft
    [Setup]    Common Test Setup For AIC

#    ${alias}  set variable   vdu_connection
#    ${vdu_index}  set variable   0
#    vDU Login By Rest    vdu_index=${vdu_index}    alias=${alias}
#    ${res_scripts}  Get Troubleshooting Scripts Information   vdu_connection=${alias}
#    Log To Console  ${res_scripts}
#    Check both vDU and vCU cells should be onair
#    Enable/Disable CB009409     allUes
#    Check both vDU and vCU cells should be onair
    Log to Console    triger vdu pod failure
    sleep    60s
#    Enable/Disable CB009409     disabled
    Check both vDU and vCU cells should be onair
    sleep    60s
    Log to Console    Wait vdu pod startup
    sleep    60s
    [Teardown]     Common Test Teardown For AIC

CB013789_TC08
    [Tags]    CRT   QC_241845    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: yuhan.wang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    22.09.2025, yuhan.wang@nokia-sbell.com, draft
    [Setup]    Common Test Setup For AIC

#    ${alias}  set variable   vdu_connection
#    ${vdu_index}  set variable   0
#    vDU Login By Rest    vdu_index=${vdu_index}    alias=${alias}
#    ${res_scripts}  Get Troubleshooting Scripts Information   vdu_connection=${alias}
#    Log To Console  ${res_scripts}
#    Check both vDU and vCU cells should be onair
#    Enable/Disable CB009409     allUes
#    Check both vDU and vCU cells should be onair
    Log to Console    triger vdu pod failure
    sleep    60s
    Log to Console    Wait vdu pod startup
    sleep    60s
#    Enable/Disable CB009409     disabled
    Check both vDU and vCU cells should be onair
    sleep    60s
    [Teardown]     Common Test Teardown For AIC

CB013789_TC25
    [Tags]    CRT   QC_241827    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: Wang Yuhan
    ...    history change: <date>,<who>,<what and how>
    ...    16.10.2025, yuhan.wang@nokia-sbell.com, draft
    [Setup]    Common Test Setup For AIC

#    Check both vDU and vCU cells should be onair
#    Enable/Disable CB009409     allUes
#    Check both vDU and vCU cells should be onair
    Log to Console    triger vdu container failure
    sleep    60s
    Log to Console    Wait vdu container startup
    sleep    60s
#    Enable/Disable CB009409     disabled
    Check both vDU and vCU cells should be onair
    sleep    60s
    [Teardown]     Common Test Teardown For AIC


CB013203_TC1
    [Tags]    CRT   QC_181466    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: Wang Yuhan
    ...    history change: <date>,<who>,<what and how>
    ...    26.5.2025, yuhan.wang@nokia-sbell.com, draft
    [Setup]    Common Test Setup For AIC

#    Check both vDU and vCU cells should be onair
#    Enable/Disable CB009409     allUes
#    Check both vDU and vCU cells should be onair
    Log to Console    triger vdu Process failure
    sleep    60s
    Log to Console    Wait vdu Process startup
    sleep    60s
#    Enable/Disable CB009409     disabled
    Check both vDU and vCU cells should be onair
    sleep    60s
    [Teardown]     Common Test Teardown For AIC

CB013203_TC03
    [Tags]    CRT   QC_181465    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: Wang Yuhan
    ...    history change: <date>,<who>,<what and how>
    ...    26.5.2025, yuhan.wang@nokia-sbell.com, draft
    [Setup]    Common Test Setup For AIC

#    Check both vDU and vCU cells should be onair
#    Enable/Disable CB009409     allUes
#    Check both vDU and vCU cells should be onair
    Log to Console    triger vdu Container failure
    sleep    60s
    Log to Console    Wait vdu Container startup
    sleep    60s
#    Enable/Disable CB009409     disabled
    Check both vDU and vCU cells should be onair
    sleep    60s
    [Teardown]     Common Test Teardown For AIC

#CB013203_TC05_RCPHC
#    [Tags]    CRT   QC_181464    QCD_MN_RAN      QCP_RAN_VRF
#    [Documentation]
#    ...    Author: Wang Yuhan
#    ...    history change: <date>,<who>,<what and how>
#    ...    26.5.2025, yuhan.wang@nokia-sbell.com, draft
#    [Setup]    Common Test Setup For AIC

#    Check both vDU and vCU cells should be onair
#    Enable/Disable CB009409     allUes
#    Check both vDU and vCU cells should be onair
#    Log to Console    triger vdu RCPHC failure
#    sleep    60s
#    Log to Console    Wait vdu RCPHC startup
#    sleep    60s
#    Enable/Disable CB009409     disabled
#    Check both vDU and vCU cells should be onair
#    sleep    60s
#    [Teardown]     Common Test Teardown For AIC

CB013203_TC02_CU_Process
    [Tags]    CRT   QC_181468    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: Wang Yuhan
    ...    history change: <date>,<who>,<what and how>
    ...    26.5.2025, yuhan.wang@nokia-sbell.com, draft
    [Setup]    Common Test Setup For AIC

#    Check both vDU and vCU cells should be onair
#    Enable/Disable CB009409     allUes
#    Check both vDU and vCU cells should be onair
    Log to Console    triger vcu Process failure
    sleep    60s
    Log to Console    Wait vcu Process startup
    sleep    60s
#    Enable/Disable CB009409     disabled
    Check both vDU and vCU cells should be onair
    sleep    60s
    [Teardown]     Common Test Teardown For AIC

CB013203_TC04_CU_Container
    [Tags]    CRT   QC_181469    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: Wang Yuhan
    ...    history change: <date>,<who>,<what and how>
    ...    26.5.2025, yuhan.wang@nokia-sbell.com, draft
    [Setup]    Common Test Setup For AIC

#    Check both vDU and vCU cells should be onair
#    Enable/Disable CB009409     allUes
#    Check both vDU and vCU cells should be onair
    Log to Console    triger vcu Container failure
    sleep    60s
    Log to Console    Wait vcu Container startup
    sleep    60s
#    Enable/Disable CB009409     disabled
    Check both vDU and vCU cells should be onair
    sleep    60s
    [Teardown]     Common Test Teardown For AIC

*** Keywords ***
Check both vDU and vCU cells should be onair
    Log To Console    \n*** check on air state in cu ***
    wait until keyword succeeds    1200    20
    ...        Check All Cells On Air In vCU
    Log To Console    \n*** check on air state in du ***
    wait until keyword succeeds    1200    20
    ...        vDU Check All Cells Status Should Be Onair

Reset vDU
    [Arguments]       ${vdu_index}=${0}    ${gnb_index}=${0}
    [Documentation]   Reset VDU By REST
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...
    ...   | Input Parameters | Man. | Description |
    ...   | need_check_on_air | no | if need to check cell on air |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...   Example
    ...  | Reset vDU With Check Cell On Air | need_check_on_air=${False} |
    ...
    log to console  Reset VDU By REST...
    vDU Login By Rest  vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${out}    vdu.reset_vdu
    ${error_msg}    set variable  ${out["error_message"]}
    should contain    ${error_msg}    No error
    ${out}    Wait Until Keyword Succeeds  60   10   _Check Reset VDU Status Should Be Expected    operation_id=${out["id"]}
    ...                                                                                expected_status=ongoing

Commission Full SCF For vDU
    [Arguments]    ${scf_path}
    vDU Update Full SCF By Rest    scf_path=${scf_path}
    ...                               vdu_index=${0}

Commission Full SCF For vCU
    [Arguments]    ${scf_path}   ${plan_name}=TA_plan_file
    vCU Full Commssion By Rest  path_of_commission_file=${scf_path}  plan_name=${plan_name}


Change PA settings
    [Arguments]    ${Select_Port}    ${Signal_setting}
    log    OK
    Pet Change PA Signal    devicetype=${PA_info.PA_device}    model=${PA_info.PA_model}    host=${PA_info.PA_host}
    ...                     port=${PA_info.PA_port}    totalinport=${PA_info.PA_totalinport}
    ...                     totaloutport=${PA_info.PA_totaloutport}    points=${Select_Port}    signal=${Signal_setting}

CU Check Maximum Plan Number And Delete One If Reach Maximum Number
    Login To vCU By Rest
    ${all_plans}   cu.get_staged_plans_list
    Should Be True  ${all_plans.__len__()}<=3
    Run Keyword If  ${all_plans.__len__()}==3   Log To Console  ${all_plans[0]["plan_name"]}/${all_plans[0]["plan_id"]} will be deleted!
    Run Keyword If  ${all_plans.__len__()}==3   cu.plan_delete   plan_id=${all_plans[0]["plan_id"]}
    Run Keyword And Ignore Error  Logout To vCU By Rest

Empty Setup
    Log To Console  Ok



