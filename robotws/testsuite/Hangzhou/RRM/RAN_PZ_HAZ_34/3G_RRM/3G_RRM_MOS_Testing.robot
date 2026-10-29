# @Time    : 2025/2/14 18:13
# @Author  : Chun.li
# @Email   : chun.li@nokia-sbell.com
# @File    : robot_Template.robot
# @Software: PyCharm
# @Doc     : 3G
*** Settings ***

Documentation
...    author: Chun Li
...    Contact: chun.li@nokia-sbell.com
...    Team: RAN RD VRF HAZ3 5
...    Feature: 3G

#Suite Setup         MMW5 Common Suite Setup
#Suite Teardown      MMW5 Common Suite Teardown
Test Setup          MMW5 Common Case Setup
Test Teardown       MMW5 Common Case Teardown
Force Tags        CRT_TRUNK

Resource    ./Resources/3G_RRM_Resources.robot

*** Variables ***
${imsi1}        ${tl.ues[0].imsi}
${imsi2}        ${tl.ues[1].imsi}
${callednum}    ${tl.ues[1].sec_key}
${ue_type}    pioneer
@{ues}    UE1    UE2
${mos_expect}    3.6

*** Test Cases ***
3G_SPS_002_AMR Voice quality MOS
    [Documentation]    This case verify the WCDMA CS voice quality. To measure the quality, the case checks MOS value from pionner tool.
    ...    MOS value should be > 3.6, the value is defined in CP_SPS_CAP.336 (WCDMA SPS)
    [Tags]
    [Timeout]    2 hour
    Open Pionner
    Log To Console    Open Pionner sucessful, start to Prepare UEs in Pionner
    Prepare 2UE In Pionner
    pioneer.UE Attach    ue_type=${UE_TYPE}    ue_index=${1}    ue_alias=UE1
    pioneer.UE Attach    ue_type=${UE_TYPE}    ue_index=${2}    ue_alias=UE2
    sleep    5s
    Log To Console    UE attach sucessful, Start MOS testing and collect statistics
    pioneer.start mos    ue_type=${UE_TYPE}    ue_index=${0}    calledue=${2}    callednum=${callednum}    duration=${130}    testcount=${10}
    ...    algorithms=${0}    mosboxtype=${1}    ue_alias=UE1
    sleep    10s
    pclient.start_statistics   ues=@{ues}    service=pioneer
    sleep    1485s
    pclient.stop_statistics    ues=@{ues}    service=pioneer
    sleep    10s
    Run Keyword And Ignore Error    pioneer.stop mos    ue_type=${UE_TYPE}    ue_index=${0}    ue_alias=UE1
    Log To Console    Testing done, checking results
    FOR    ${UE_ID}  IN  @{ues}
        Check 3G MOS    UE_ID=${UE_ID}
    END
    pclient.release_ues    service=pioneer
    Close Pioneer

    [Teardown]    Run Keywords     MMW5 Common Case Teardown    AND    close Pioneer
