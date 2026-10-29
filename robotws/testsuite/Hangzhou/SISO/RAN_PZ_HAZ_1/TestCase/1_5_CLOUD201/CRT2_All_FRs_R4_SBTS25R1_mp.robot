*** Settings ***
Documentation    Suite description
...    Author:        shenghong.hu@nokia-sbell.com
...    Maintainer:    author

Library     Telnet
Library    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/kpiReporter.py
Resource   ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/oam_kpi_test_fv.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/reportportal.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_fv.robot
Variables    ./env.py

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

Force Tags    CA_RAN_PZ_HAZ_1    SBTS25R1    RAN_5G    RAN_5G_TDD    CRT    STATE_SW_UPLOADED
Test Timeout    73h

*** Variables ***
#&{1_5_CB009085_T3_L}=    peak_rate_config={"401":[750,50],"402":[350,50],"403":[120,10]}
&{1_5_CB012500_2NR10_50_4LTE_8T8R}=    peak_rate_config={"401":[30,3],"402":[200,20],"403":[40,2.5],"404":[55,4.5],"406":[100,9]}
...   HW_ID=CB009085
...   site_mode=8T8R
...   ONAIR_TIME=15 min

&{1_5_CB009085_T3_L}=    peak_rate_config={"401":[350,15],"402":[200,15],"403":[70,10]}
...   HW_ID=CB009085
...   site_mode=8T8R
...   ONAIR_TIME=15 min

${pk1}    "401":[220,10],"402":[150,10],"403":[150,10],"404":[220,10]
${pk2}    "405":[150,10],"406":[140,10],"407":[220,10],"408":[150,10]
&{1_5_CB009085_T332_Ma_Ia_Ia}=    peak_rate_config={${pk1},${pk2}}
...   HW_ID=CB009085
...   site_mode=8T8R
...   ONAIR_TIME=15 min

${GLO_TL_DESCRIPTOR_FILE_PATH}=      ${CURDIR}/TLdescriptor.xml
#${GLO_PERFORM_SAVE_LOG}    ALWAYS

${INIT_CONFIG_ID}    1_5_CB009085_T3_L
#${INIT_CONFIG_ID}    1_5_CB009085_T332_Ma_Ia_Ia
@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}   NgGnbInitFullReset    NgGnbInitPartialReset

${appserver_log_path}    /home/tdlte-tester/UDP
${ru_password_user}    5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=

${online_commissioning}    [['MRBTS-37188/NRBTS-37188/NRCELL-2',['chBw','30MHz']]]

${INIT_SW_VERSION}    {'37188': 'SBTS24R1_ENB_0000_000009_000000'}
${TARGET_SW_VERSION}    {'37188': 'SBTS00_ENB_9999_231013_000009'}
${RB_TO_TARGET}    YES
${YAFT}    YES
${TOP50}                             True
${RU}    AZHL
${SA_OR_NSA}
${TDD_OR_FDD}    TDD
${HW_ID}    ASIM+ABIP+AZHL
${SPECIFIC_BRANCH}     Yes

*** Test Cases ***
Data Transfer_T3
    [Tags]    QC_132767    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=L3call    config_id=1_5_CB009085_T3_L
    test_fv.Data Transfer
    [Teardown]    Testcase Basic Postcondition

[1] Common_SiSo_State Management_RF Lock_Then_resetBBMOD_Then_RF unlock
    [Tags]    QC_132770    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Common_SiSo_State Management_RF Lock_Then_resetBBMOD_Then_RF unlock
    ...    config_id=1_5_CB009085_T3_L
    Common_SiSo_State Management_RF Lock_Then_resetBBMOD_Then_RF unlock
    [Teardown]    Testcase Basic Postcondition
