*** Settings ***
Documentation    Suite description
...    Author:        len.lin@nokia-sbell.com
...    Maintainer:    lin len

Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_fv.robot
Variables   ./env.py

Force Tags    CLOUD_5G_CLASSICAL_NSA_ASIB_3xAHGD    CA_RAN_PZ_HAZ_1    SBTS26R1    RAN_5G    RAN_5G_FDD    STATE_SW_UPLOADED

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***
&{5G_CB008434_S2_without_sleep}=        HW_ID=5G_CB008434        ONAIR_TIME=20 min     site_mode=SA
...    peak_rate_config={"188":[750,65],"189":[750,65]}    iperf_type=via_command

#
${GLO_TL_DESCRIPTOR_FILE_PATH}=      ${CURDIR}/TLdescriptor.xml
@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}    NgGnbInitPartialReset    NgGnbInitFullReset    Unit power reset
#${INIT_CONFIG_ID}


*** Test Cases ***

[1][1.0] Common_SiSo_Recovery_RF module reset_Then_RAT_reset
    [Timeout]    2h
    [Tags]    QC_252146    QCD_MN_RAN  QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=RF_RAT_Reset    config_id=5G_CB008434_S2_without_sleep
    Common_SiSo_Recovery_RF_module_reset_Then_RAT_reset
    [Teardown]    Testcase Basic Postcondition
