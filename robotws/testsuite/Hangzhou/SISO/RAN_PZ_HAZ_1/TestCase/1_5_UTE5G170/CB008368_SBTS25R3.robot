*** Settings ***
Documentation    Suite description
...    Author:        qing.2.he@nokia-sbell.com
...    Maintainer:    He Qing

Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_fv.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/reportportal.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/oam_kpi_test_fv.robot
Variables    ./env.py

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition


*** Variables ***
${peak_rate1}    "771":[840,114],"772":[840,114],"773":[840,114], "774":[60,44],"775":[60,44],"776":[60,44]
&{5G_RJIO_2AHPB_3AQQJ_5cells}=    HW_ID=CB008368    site_mode=4T4R_32T32R    ONAIR_TIME=30 min
...									peak_rate_config={${peak_rate1}}

${GLO_TL_DESCRIPTOR_FILE_PATH}=      ${CURDIR}/TLdescriptor.xml
${INIT_CONFIG_ID}    5G_RJIO_2AHPB_3AQQJ_5cells
#&{tl_config}    UE_INFO=${UE_INFO}
@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}    NgGnbInitFullReset    NgGnbInitPartialReset
${INIT_SW_VERSION}    {'11227': 'SBTS25R2_ENB_0000_000606_000000'}
${TARGET_SW_VERSION}    {'11227': 'SBTS00_ENB_9999_241114_000003'}
${RB_TO_TARGET}    YES
${YAFT}    YES
${TOP50}                             True
${RU}    AQQJ
${SA_OR_NSA}
${TDD_OR_FDD}    TDD
${HW_ID}    ASOE+AQQJ+AHPB
${SPECIFIC_BRANCH}     Yes
*** Test Cases ***
[1][1.0] Common_SiSo_Startup_Onair
    [Tags]    QC_203878  QCD_MN_RAN   QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=SiteOnair   config_id=5G_RJIO_2AHPB_3AQQJ_5cells
    site reset
    [Teardown]    Testcase Basic Postcondition

[1][1.0] Common_SiSo_State Management_Cell block_Then_RF reset_Then_Cell unblock
    [Tags]    QC_203877    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=L3call   config_id=5G_RJIO_2AHPB_3AQQJ_5cells
    Cell Block And Unblock All with rfreset
    [Teardown]    Testcase Basic Postcondition

[1][1.0] Common_SiSo_State Management_RF Lock & Unlock_Then_Cell Block & unblock
    [Tags]    QC_203874  QCD_MN_RAN   QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=rf lock with cell lock   config_id=5G_RJIO_2AHPB_3AQQJ_5cells
    Ru lock And Unlock All
    Cell Block And Unblock All
    [Teardown]    Testcase Basic Postcondition

[1][1.0] General_SiSo_RAT_Reset
    [Tags]    QC_203875    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=RAT_reset_from_WebEm   config_id=5G_RJIO_2AHPB_3AQQJ_5cells
    RAT reset from WebEm For NR testline
    [Teardown]    Testcase Basic Postcondition

[2][1.0] [UUF4ALL]_Upgrade of eNB from older release to the newest release
    [Tags]    QC_203876     QCD_MN_RAN      QCP_RAN_VRF
    [Setup]    Run Keywords    Run Process    rm /home/ute/.ute-ca/cache/bts/* -rf    shell=True
    ...    AND    Testcase UUF Precondition    case_name=UUF_kpi   config_id=5G_RJIO_2AHPB_3AQQJ_5cells
    SW Upgrade And RollBack KPI2    L3Call=NO
    [Teardown]     Testcase KPI postcondition

#[1][1.1] General_SiSo_Commissioning_BTS_Template_Commissioning
#    [Tags]    QC_736807    QCD_MN_RAN    QCP_RAN_VRF
#    [Timeout]    72h
#    [Setup]    Testcase Basic Precondition    case_name=Recommissioning    config_id=5G_RJIO_2AHPB_3AQQJ_5cells
#    General_SiSo_Commissioning_BTS_Template_Commissioning
#    [Teardown]    Testcase Basic Postcondition
#
#[1][1.0] Data Transfer
#    [Tags]    QC_451569    QCD_MN_RAN    QCP_RAN_VRF
#    [Setup]    Testcase Basic Precondition    case_name=L3call    config_id=5G_RJIO_2AHPB_3AQQJ_5cells
#    ...      config_id=5G_RJIO_2AHPB_3AQQJ_5cells
#    test_fv.Data Transfer
#    [Teardown]    Testcase Basic Postcondition
#
#[1][1.0] E2E_TL_Site_reset_without_HWF_with_OAM_KPI
#    [Tags]    QC_106509    QCD_MN_RAN    QCP_RAN_VRF
#    [Setup]    Testcase Basic Precondition    case_name=hwf     config_id=5G_RJIO_2AHPB_3AQQJ_5cells
#    [Timeout]    72h
#    FOR    ${num}    IN RANGE    ${5}
#        Site Reset with Remove Hwbin
#    END
#    [Teardown]    Testcase Basic Postcondition
#
#[1][1.0] Common_SiSo_State Management_RF Lock & Unlock_with_BTS Reset
#    [Tags]    QC_106508    QCD_MN_RAN    QCP_RAN_VRF
#    [Setup]    Testcase Basic Precondition    case_name=RF lock And Unlock with BTS Reset       config_id=5G_RJIO_2AHPB_3AQQJ_5cells
#    RF lock And Unlock with BTS Reset
#    [Teardown]    Testcase Basic Postcondition
#
#[1][1] Common_SiSo_State Management_RF Lock & Unlock_with_RF Reset
#    [Tags]    QC_106510  QCD_MN_RAN   QCP_RAN_VRF
#    [Setup]    Testcase Basic Precondition    case_name=RFlock_with_RfReset   config_id=5G_RJIO_2AHPB_3AQQJ_5cells
#    Common_SiSo_State Management_RF Lock & Unlock_with_RF Reset
#    [Teardown]    Testcase Basic Postcondition
