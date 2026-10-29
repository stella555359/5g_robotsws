*** Settings ***
Documentation    Suite description
...    Author:        lei.10.huang@nokia-sbell.com
...    Maintainer:    Huang Lei

Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_fv.robot

Variables    ./env.py

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***

&{5G_CNI118649_ASIL_ABIP_AQQF_100M_1xeCL25}    HW_ID=CNI118649   site_mode=5G   ONAIR_TIME=20 min
...									peak_rate_config={"1007":[780,51]}

&{5G_CNI118649_ASIL_ABIP_AQQF_50M_50M_1xeCL25}    HW_ID=CNI118649   site_mode=5G   ONAIR_TIME=20 min
...									peak_rate_config={"1006":[372,23],"1007":[372,23]}

&{5G_CNI118649_ASIL_ABIP_AQQF_50M_50M_2xeCL10}    HW_ID=CNI118649   site_mode=5G   ONAIR_TIME=20 min
...									peak_rate_config={"1006":[372,23],"1007":[372,23]}

&{5G_CNI118649_ASIL_ABIP_AQQF_50M_50M_2xeCL25_16UL_8DL}    HW_ID=CNI118649   site_mode=5G   ONAIR_TIME=20 min
...									peak_rate_config={"1006":[372,23],"1007":[372,23]}

${GLO_TL_DESCRIPTOR_FILE_PATH}=      ${CURDIR}/TLdescriptor.xml
${INIT_CONFIG_ID}    5G_CNI118649_ASIL_ABIP_AQQF_50M_50M_2xeCL25_16UL_8DL

${GLO_PERFORM_SAVE_LOG}      FAIL

@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}    NgGnbInitFullReset    NgGnbInitPartialReset    ToP reference missing
...									LOS on SMOD-1, EIF4
${YAFT}    YES
${RB_TO_TARGET}    NO

*** Test Cases ***
[1][4.0] Manual_SiSo_TEST_LTE_NR_RF_Diagnostic_Test
    [Tags]    QC_146168    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=rfDiagnosticTest    config_id=5G_CNI118649_ASIL_ABIP_AQQF_100M_1xeCL25
    RF Diagnostic Test for NR
    [Teardown]    Testcase Basic Postcondition

[1][1.0] Common_SiSo_State Management_Cell block_Then_RF reset_Then_Cell unblock
    [Tags]    QC_146166    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=L3call    config_id=5G_CNI118649_ASIL_ABIP_AQQF_50M_50M_2xeCL25_16UL_8DL
    Cell Block And Unblock All with rfreset    required_cells=1006:1007
    [Teardown]    Testcase Basic Postcondition

[1][1.0] Common_SiSo_State Management_RF Lock_Then_resetBBMOD_Then_RF unlock
    [Tags]    QC_146165  QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Ru_lock_and_RU_reset_with_resetBBMOD
    ...    config_id=5G_CNI118649_ASIL_ABIP_AQQF_100M_1xeCL25
    Common_SiSo_State Management_RF Lock_Then_resetBBMOD_Then_RF unlock
    [Teardown]    Testcase Basic Postcondition

[1.0] Common_SiSo_Recovery_BTS SiteReset
    [Tags]    QC_146169   QCD_MN_RAN   QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=site_reset    config_id=5G_CNI118649_ASIL_ABIP_AQQF_50M_50M_2xeCL10
    FOR    ${i}    IN RANGE    ${50}
        Site Reset
    END
    [Teardown]    Testcase Basic Postcondition

[1][2.0] Common_SiSo_Call_Throughput Measurements
    [Tags]    QC_146167   QCD_MN_RAN   QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Tput    config_id=5G_CNI118649_ASIL_ABIP_AQQF_100M_1xeCL25
    test_fv.Data Transfer    required_cells=1007
    [Teardown]    Testcase Basic Postcondition

[2][2.0] Common_SiSo_Call_Throughput Measurements
    [Tags]    QC_146170   QCD_MN_RAN   QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Tput    config_id=5G_CNI118649_ASIL_ABIP_AQQF_50M_50M_1xeCL25
    test_fv.Data Transfer    required_cells=1006:1007
    [Teardown]    Testcase Basic Postcondition

#[1][1.0] General_SiSo_uDTX_verification
#    [Tags]    QC_821106    QCD_MN_RAN    QCP_RAN_VRF
#    [Setup]    Testcase Basic Precondition   case_name=uDTX    config_id=5G_CNI118649_ASIL_ABIP_AQQF_100M_1xeCL25
#    Manual Siso PM 5G uDTX
#    [Teardown]    Testcase Basic Postcondition
#
#[1][2.0] Common_SiSo_Startup_RF power off then on
#    [Tags]    QC_821109    QCD_MN_RAN    QCP_RAN_VRF
#    [Setup]    Testcase Basic Precondition    case_name=RF_Power_Reset    config_id=5G_CNI118649_ASIL_ABIP_AQQF_50M_50M_1xeCL25
#    SISO_RF module power reset    required_cells=1006:1007
#    [Teardown]    Testcase Basic Postcondition
#
#[1][1.0] Common_SiSo_State Management_RF Lock & Unlock
#    [Tags]    QC_821116    QCD_MN_RAN   QCP_RAN_VRF
#    [Setup]    Testcase Basic Precondition    case_name=Ru_Lock_And_Unlock    config_id=5G_CNI118649_ASIL_ABIP_AQQF_50M_50M_2xeCL10
#    Ru lock And Unlock All    required_cells=1006:1007
#    [Teardown]    Testcase Basic Postcondition
#
#[1][1.0] Common_SiSo_Startup_BTS Site Power Reset
#    [Tags]    QC_821118    QCD_MN_RAN    QCP_RAN_VRF
#    [Setup]    Testcase Basic Precondition    case_name=Bts_Power_Reset    config_id=5G_CNI118649_ASIL_ABIP_AQQF_50M_50M_1xeCL25
#    Bts Power Reset
#    [Teardown]    Testcase Basic Postcondition
#
#[1][4.0] Manual_SiSo_SM_NR_RAT_reset
#    [Tags]    QC_821119    QCD_MN_RAN   QCP_RAN_VRF
#    [Setup]    Testcase Basic Precondition    case_name=NR_RAT_reset    config_id=5G_CNI118649_ASIL_ABIP_AQQF_50M_50M_1xeCL25
#    RAT reset from WebEm For NR testline    required_cells=1006:1007
#    [Teardown]    Testcase Basic Postcondition
#
#[1][1.0] Common_SiSo_Performance Management_TX and RX Antenna Calibration Checking
#    [Tags]    QC_821121   QCD_MN_RAN   QCP_RAN_VRF
#    [Setup]    Testcase Basic Precondition    case_name=Calibration    config_id=5G_CNI118649_ASIL_ABIP_AQQF_100M_1xeCL25
#    SISO Antenna Calibration Check AQQF    ru_password_user=3Is6ezFJ7dFlB29cgs0yp3RCM3fUF1zNO1+6Z08tlAc=    required_rfs=1M242200242
#    [Teardown]    Testcase Basic Postcondition
#
#[2][1.0] Common_SiSo_Performance Management_TX and RX Antenna Calibration Checking
#    [Tags]    QC_821122   QCD_MN_RAN   QCP_RAN_VRF
#    [Setup]    Testcase Basic Precondition    case_name=Calibration    config_id=5G_CNI118649_ASIL_ABIP_AQQF_50M_50M_1xeCL25
#    SISO Antenna Calibration Check AQQF    ru_password_user=3Is6ezFJ7dFlB29cgs0yp3RCM3fUF1zNO1+6Z08tlAc=    required_rfs=1M242200242
#    [Teardown]    Testcase Basic Postcondition
#
#[2][2.0] Common_SiSo_Call_Throughput Measurements
#    [Tags]    QC_821123   QCD_MN_RAN   QCP_RAN_VRF
#    [Setup]    Testcase Basic Precondition    case_name=Tput    config_id=5G_CNI118649_ASIL_ABIP_AQQF_50M_50M_1xeCL25
#    test_fv.Data Transfer    required_cells=1006:1007
#    [Teardown]    Testcase Basic Postcondition

*** Keywords ***
RF Diagnostic Test for NR
    FOR    ${bts_id}    IN    @{ALL_BTS_ID_LIST}
        ${connection_id}    Set Variable   ${CASE_NAME}_${bts_id}
        Run Keyword And Continue On Failure    Admin Alarms Get And Check    allowed=${GLO_ADMIN_ALLOWED_ALARM}
        ...    alias=${connection_id}
    END
    FOR    ${cell_info}    IN    @{ALL_CELL_LIST}
        ${cellId}    Set Variable    ${cell_info["cellId"]}
        Run RF Diagnostic Test    ${cellId}    NR    alias=rfDiagnosticTest_${bts_id}
        Get And Check RF Diagnostic Test Result 5G    alias=rfDiagnosticTest_${bts_id}
    END
    Verify All Cells OnAir
    Check Alarms
    Check Historical Alarms
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0
