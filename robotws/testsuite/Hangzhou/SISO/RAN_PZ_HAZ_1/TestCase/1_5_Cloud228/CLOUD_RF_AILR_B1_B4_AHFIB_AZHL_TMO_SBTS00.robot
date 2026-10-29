*** Settings ***
Documentation    Suite description
...    Author:        len.lin@nokia-sbell.com
...    Maintainer:    lin len

Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_fv.robot


Force Tags    CLOUD_RF_AILR_B1_B4_AHFIB_AZHL_TMO  CA_RAN_PZ_HAZ_1  SBTS00  RAN_5G  RAN_5G_TDD  CRT

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***
&{CLOUD_RF_AILR_B1_B4_AHFIB_AZHL_TMO}=        HW_ID=TMO        ONAIR_TIME=20 min        site_mode=5G


@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}    Failure in connection between BTS and 3rd party tool
...    No X2 link available
...    Cell Activation timeout at gNB-DU
...    Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability
#${INIT_CONFIG_ID}


*** Test Cases ***

[1][1.0] CB010655_I_1_enhancement_of_reset_counter
    [Tags]    QC_33277    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Reset_Counter
    ...    config_id=CLOUD_RF_AILR_B1_B4_AHFIB_AZHL_TMO
    [Timeout]    2h
    BBOX5 File Reset Counter    AH220201219
    [Teardown]    Testcase Basic Postcondition

[1][1.0] CB010655_H_1_support_BTS_ID_and_BTS_SW_version
    [Tags]    QC_33278    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=BTS_SW_version
    ...    config_id=CLOUD_RF_AILR_B1_B4_AHFIB_AZHL_TMO
    [Timeout]    2h
    Support BTSID And BTSSW    AH220201219
    [Teardown]    Testcase Basic Postcondition
