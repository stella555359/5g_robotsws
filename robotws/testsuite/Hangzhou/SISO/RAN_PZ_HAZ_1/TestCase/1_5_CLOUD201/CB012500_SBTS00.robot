*** Settings ***
Documentation    Suite description
...    Author:        wei.ren@nokia-sbell.com
...    Maintainer:    author

Library     Telnet
Library    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/kpiReporter.py
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/oam_kpi_test_fv.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/reportportal.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_fv.robot
Variables    ./env.py

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

Force Tags    CA_RAN_PZ_HAZ_1    SBTS00    RAN_5G    RAN_5G_TDD    CRT    STATE_SW_UPLOADED
Test Timeout    73h

*** Variables ***
#&{1_5_CB009085_T3_L}=    peak_rate_config={"401":[100,10],"402":[700,50],"403":[80,4],"404":[120,6],"406":[170,9]}
&{1_5_CB012500_2NR10_50_4LTE_8T8R}=    peak_rate_config={"401":[30,3],"402":[200,20],"403":[40,2.5],"404":[55,4.5],"406":[100,9]}
...   HW_ID=CB009085
...   site_mode=8T8R
...   ONAIR_TIME=15 min

${pk1}    "401":[100,10],"402":[700,50],"403":[80,4],"404":[120,6]
${pk2}    "405":[150,15],"406":[170,9],"407":[220,15],"408":[150,15]
&{1_5_CB009085_T332_Ma_Ia_Ia}=    peak_rate_config={${pk1},${pk2}}
...   HW_ID=CB009085
...   site_mode=8T8R
...   ONAIR_TIME=15 min

${GLO_TL_DESCRIPTOR_FILE_PATH}=      ${CURDIR}/TLdescriptor.xml
#${GLO_PERFORM_SAVE_LOG}    ALWAYS

${INIT_CONFIG_ID}    1_5_CB012500_2NR10_50_4LTE_8T8R
#${INIT_CONFIG_ID}    1_5_CB009085_T332_Ma_Ia_Ia
@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}   NgGnbInitFullReset    NgGnbInitPartialReset

${appserver_log_path}    /home/tdlte-tester/UDP
${ru_password_user}    wcdjLlTpqEY3cAmOe11u6aELwGI3rDvpGJQvCkcyHZc=

${online_commissioning}    [['MRBTS-37188/NRBTS-37188/NRCELL-2',['chBw','30MHz']]]

${INIT_SW_VERSION}    {'37188': 'SBTS24R1_ENB_0000_000009_000000'}
${TARGET_SW_VERSION}    {'37188': 'SBTS00_ENB_9999_231013_000009'}
${RB_TO_TARGET}    YES
${YAFT}    YES

${RU}    AZHL
${SA_OR_NSA}
${TDD_OR_FDD}    TDD
${HW_ID}    ASIM+ABIP+AZHL
${SPECIFIC_BRANCH}     Yes

*** Test Cases ***

[1][1.0] Common_SiSo_Performance Management_TX and RX Antenna Calibration Checking
    [Tags]    QC_33102   QCD_MN_RAN   QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=calibration    config_id=1_5_CB012500_2NR10_50_4LTE_8T8R
    SISO Antenna Calibration Check ECPRI    required_rfs=AH222602968
    ...    ru_password_user=${ru_password_user}
    [Teardown]    Testcase Basic Postcondition

[1][1] Common_SiSo_Call_Throughput_Measurements_UDP
    [Tags]    QC_33101  QCD_MN_RAN   QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Tput    config_id=1_5_CB012500_2NR10_50_4LTE_8T8R
    test_fv.Data Transfer    required_cells=401:402:403
    [Teardown]    Testcase Basic Postcondition

