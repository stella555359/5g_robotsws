*** Settings ***
Documentation    Suite description
...    Author: deli.wang@nokia-sbell.com
...    Maintainer: Author

Suite Setup    Suite Precondition
Suite Teardown    Suite Postcondition

Variables    ./env.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_fv.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/oam_kpi_test_fv.robot

Force Tags    CLOUD_RF_F_CRT1_1026    CA_RAN_PZ_HAZ_1      SBTS00  RAN_4G    RAN_4G_TDD    #CRT
Test Timeout    73h

*** Variables ***
${GLO_TL_DESCRIPTOR_FILE_PATH}=    ${CURDIR}/TLdescriptor.xml
&{CLOUD_RF_AIL_B1_B3_CRT1_129172_SBTS25R2}=    site_mode=4G5G    HW_ID=T4-M     ONAIR_TIME=15 min
${INIT_CONFIG_ID}=    CLOUD_RF_AIL_B1_B3_CRT1_129172_SBTS25R2
${required_cells}    333


*** Test Cases ***
[1.0] Common_SiSo_Recovery_RF module reset_Then_RAT_reset
    [Tags]    QC_146612    QCD_MN_RAN   QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Common_SiSo_Recovery_RF module reset_Then_RAT_reset
    ...    config_id=CLOUD_RF_AIL_B1_B3_CRT1_129172_SBTS25R2
    Common_SiSo_Recovery_RF_module_reset_Then_RAT_reset    required_cells=${required_cells}
    [Teardown]    Testcase Basic Postcondition

E2E_TL_SW_upgrade_rollback_with_OAM_KPI_and_L3_Call
    [Tags]    QC_146613     QCD_MN_RAN      QCP_RAN_VRF
    [Setup]    Testcase UUF Precondition    case_name=UUF_kpi
    ...    config_id=CLOUD_RF_AIL_B1_B3_CRT1_129172_SBTS25R2
    SW Upgrade And RollBack KPI2    L3Call=NO
    [Teardown]     Testcase KPI postcondition
