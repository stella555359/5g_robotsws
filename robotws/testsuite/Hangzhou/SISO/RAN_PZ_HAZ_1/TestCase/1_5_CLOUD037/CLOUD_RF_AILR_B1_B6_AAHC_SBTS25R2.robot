*** Settings ***
Documentation    Suite description
...    Author:        len.lin@nokia-sbell.com
...    Maintainer:    lin len

Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_fv.robot
Variables   ./env.py


Force Tags    CLOUD_RF_AILR_B1_B6_AAHC  CA_RAN_PZ_HAZ_1  SBTS25R2  RAN_5G  RAN_5G_TDD  CRT

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***
&{CLOUD_RF_AILR_B1_B6_AAHC_SBTS25R2_T3_20M}=        HW_ID=T3_20M        ONAIR_TIME=20 min        site_mode=4G
...    peak_rate_config={"430":[111.81,9.99],"431":[111.81,9.99],"432":[111.81,9.99]}
&{CLOUD_RF_AILR_B1_B6_AAHC_SBTS25R2_T3_10M}=        HW_ID=T3_10M        ONAIR_TIME=20 min        site_mode=4G
...    peak_rate_config={"430":[55.91,4.99],"431":[111.81,9.99],"432":[111.81,9.99]}


@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}    Failure in connection to Real-time PM Collection Entity
#${INIT_CONFIG_ID}


*** Test Cases ***

[1][1.0] Operational_Cell block & unblock
    [Timeout]    2h
    [Tags]      QC_146623    QCD_MN_RAN  QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Cell_Block_And_Unblock
    ...    config_id=CLOUD_RF_AILR_B1_B6_AAHC_SBTS25R2_T3_20M
    Cell Block And Unblock All
    [Teardown]    Testcase Basic Postcondition
[1][1.0] CP_UP_Throughput Measurement_UDP_BW20M
    [Timeout]    1h
    [Tags]      QC_146624    QCD_MN_RAN  QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=L3call
    ...    config_id=CLOUD_RF_AILR_B1_B6_AAHC_SBTS25R2_T3_20M
    test_fv.Data Transfer
    [Teardown]    Testcase Basic Postcondition
[1][1.0] Operational_RF power off then on
    [Timeout]    1h
    [Tags]      QC_146625    QCD_MN_RAN  QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=RU_module_reset
    ...    config_id=CLOUD_RF_AILR_B1_B6_AAHC_SBTS25R2_T3_20M
    SISO_RF module power reset
    [Teardown]    Testcase Basic Postcondition
[2][1.0] BS_FV_TX and RX antenna Calibration TA
    [Timeout]    2h
    [Tags]      QC_146626    QCD_MN_RAN  QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=calibration
    ...    config_id=CLOUD_RF_AILR_B1_B6_AAHC_SBTS25R2_T3_10M
    SISO Antenna Calibration Check
    [Teardown]    Testcase Basic Postcondition
#[6][1.0] Onair
#    [Timeout]    1h
#    [Tags]    QC_21200    QCD_MN_RAN  QCP_RAN_ST
#    [Setup]    Testcase Basic Precondition    case_name=Onair
#    ...    config_id=CLOUD_RF_AILR_B1_B6_AAHC_SBTS25R2_T3_10M
#    Site Reset
#    [Teardown]    Testcase Basic Postcondition
[2][1.0] 1UE ULDL Peak rate
    [Timeout]    1h
    [Tags]      QC_146639    QCD_MN_RAN  QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=L3call
    ...    config_id=CLOUD_RF_AILR_B1_B6_AAHC_SBTS25R2_T3_10M
    test_fv.Data Transfer
    [Teardown]    Testcase Basic Postcondition
