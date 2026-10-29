*** Settings ***
Documentation    Suite description
...    Author:        deli.wang@nokia-sbell.com
...    Maintainer:    Wang Deli

Suite Setup    Suite Precondition
Suite Teardown    Suite Postcondition

Variables    ./env.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/oam_kpi_test_fv.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_fv.robot

Force Tags    CLOUD_5G_CLASSICAL_NSA_ASILL_ABIPB1_4XAHFIB    CA_RAN_PZ_HAZ_1    SBTS00    RAN_5G
...    RAN_5G_FDD    PY36

*** Variables ***
${pk1}    "103":[80,20]
&{CNI138571_ULCOMP}    peak_rate_config={${pk1}}
...    site_mode=4G    HW_ID=T33333333    ONAIR_TIME=15 min

${GLO_TL_DESCRIPTOR_FILE_PATH}=      ${CURDIR}/TLdescriptor.xml
${INIT_CONFIG_ID}    CNI138571_ULCOMP
${attachs}     103
${SA_OR_NSA}
${TDD_OR_FDD}    FDD
${RU}    8AHFIB+2AHFIG
${HW_ID}    ASIM+ABIP+8AHFIB+2AHFIG
${TOP50}    True


*** Test Cases ***
[1][1.0] Common_SiSo_State Management_Cell block & unblock
    [Tags]    SBTS00:QC_172548    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Cell_Block_Unblock
    ...    config_id=CNI138571_ULCOMP
    Cell Block And Unblock All    required_cells=${attachs}
    [Teardown]    Testcase Basic Postcondition

[1][1.0] Common_SiSo_State Management_RF Lock & Unlock
    [Tags]    SBTS00:QC_172606    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Ru_Lock_Unlock
    ...    config_id=CNI138571_ULCOMP
    Ru lock And Unlock All    required_cells=${attachs}
    [Teardown]    Testcase Basic Postcondition
