*** Settings ***
Documentation    Suite description
...    Author:        weicheng.lin@nokia-sbell.com
...    Maintainer:    Lin Weicheng

Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/UUF.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/oam_kpi_test_fv.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/reportportal.robot
Resource    ./UTE4G105_common_variables.robot

Library    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/kpiReporter.py

Variables   ./env.py

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition
Test Timeout       24h

*** Variables ***
@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}    Failure in internal BTS connection or connection to 3rd party tool
...    Sanity Check Error    SRIO link outage    Diagnostic Files collected    Setup of X2 connectivity to gNB failed
...    Inter eNB communication failure    BTS reference clock missing    LMP access via port 443
...    Service account root access is enabled    Ethernet port security is disabled
...    BTS reference clock missing     Fan failure      Dead Peer Detected

${INIT_SW_VERSION}    {'2316': 'SBTS24R1_FSM3_0000_000189_000000', '2284':'SBTS24R1_FSM3_0000_000189_000000',
...    '2288':'SBTS24R1_FSM3_0000_000189_000000'}
${TARGET_SW_VERSION}    {'2316': 'SBTS24R3_FSM3_0000_000081_000000', '2284':'SBTS24R3_FSM3_0000_000081_000000',
...    '2288':'SBTS24R3_FSM3_0000_000081_000000'}
${middle_build}     {'2316': 'SBTS22R4_ENB_0000_000758_000062', '2284':'SBTS22R4_ENB_0000_000758_000062',
...    '2288':'SBTS22R4_ENB_0000_000758_000062'}

${TEST_PATH}     Root\Test_Sets\24R3\Regression\VRF_HAZ1\VRF_HAZ1_T05\SISO\Optus
${TESTSET_NAME}     Optus #5.0 CRT

${GLO_SCOUT_TESTLINE_NAME}    1_5_Cloud237_1



*** Test Cases ***
## UUF ###
[1][1.0] E2E_TL_SW_upgrade_rollback_with_OAM_KPI
    [Documentation]   Auther: lisa.ding@nokia-sbell.com
    [Tags]    QC_50490   QCD_MN_RAN    QCP_RAN_ST    1_5_Cloud237_3
    [Setup]    Testcase UUF Precondition    case_name=UUF_kpi
    ...    config_id=BTS_CLOUD_RF_FCA_T_F_105_LTE5205_3eNB    recover=manual
    [Timeout]      24h
    SW Upgrade And RollBack KPI2    recover=NO
    [Teardown]    Testcase KPI postcondition

[2][1.0] E2E_TL_SW_upgrade_rollback_with_OAM_KPI
   [Documentation]   Auther: lisa.ding@nokia-sbell.com
   [Tags]    QC_50490    QCD_MN_RAN    QCP_RAN_ST    1_5_Cloud237_3
   [Setup]    Testcase UUF Precondition    case_name=UUF_kpi
   ...    config_id=BTS_CLOUD_RF_FCA_T_F_105_LTE5205_3eNB    recover=manual
   [Timeout]      24h
#    SW Upgrade And RollBack KPI2    recover=NO    target_builds=${middle_build}
   SW Upgrade And RollBack KPI2    recover=NO
   [Teardown]    Testcase KPI postcondition

[3][1.0] E2E_TL_SW_upgrade_rollback_with_OAM_KPI
   [Documentation]   Auther: lisa.ding@nokia-sbell.com
   [Tags]    QC_50490    QCD_MN_RAN    QCP_RAN_ST    1_5_Cloud237_3
   [Setup]    Testcase UUF Precondition    case_name=UUF_kpi
   ...    config_id=BTS_CLOUD_RF_FCA_T_F_105_LTE5205_3eNB    recover=manual
   [Timeout]      24h
   SW Upgrade And RollBack KPI2    recover=YES
   [Teardown]    Testcase KPI postcondition

#### SiteReset without HWF ###
[1][1.0] E2E_TL_Site_reset_without_HWF_with_OAM_KPI
   [Tags]    QC_35811    QCD_MN_RAN    QCP_RAN_ST    1_5_Cloud237_1
   [Documentation]   Auther: lisa.ding@nokia-sbell.com
   [Setup]    Testcase Basic Precondition    case_name=siteResetRemoveHwBin_kpi
   ...    config_id=BTS_CLOUD_RF_FCA_T_F_105_LTE5205_3eNB
   [Timeout]      24h
   Reset With Remove HWBIN KPI1
   [Teardown]    Testcase KPI postcondition    CaseType=RESET

[2][1.0] E2E_TL_Site_reset_without_HWF_with_OAM_KPI
   [Tags]    QC_35811    QCD_MN_RAN    QCP_RAN_ST    1_5_Cloud237_1
   [Documentation]   Auther: lisa.ding@nokia-sbell.com
   [Setup]    Testcase Basic Precondition    case_name=siteResetRemoveHwBin_kpi
   [Timeout]      24h
   Reset With Remove HWBIN KPI1
   [Teardown]    Testcase KPI postcondition    CaseType=RESET

[3][1.0] E2E_TL_Site_reset_without_HWF_with_OAM_KPI
   [Tags]    QC_35811    QCD_MN_RAN    QCP_RAN_ST    1_5_Cloud237_1
   [Documentation]   Auther: lisa.ding@nokia-sbell.com
   [Setup]    Testcase Basic Precondition    case_name=siteResetRemoveHwBin_kpi
   [Timeout]      24h
   Reset With Remove HWBIN KPI1
   [Teardown]    Testcase KPI postcondition    CaseType=RESET

[4][1.0] E2E_TL_Site_reset_without_HWF_with_OAM_KPI
   [Tags]    QC_35811    QCD_MN_RAN    QCP_RAN_ST    1_5_Cloud237_1
   [Documentation]   Auther: lisa.ding@nokia-sbell.com
   [Setup]    Testcase Basic Precondition    case_name=siteResetRemoveHwBin_kpi
   [Timeout]      24h
   Reset With Remove HWBIN KPI1
   [Teardown]    Testcase KPI postcondition    CaseType=RESET

[5][1.0] E2E_TL_Site_reset_without_HWF_with_OAM_KPI
   [Tags]    QC_35811    QCD_MN_RAN    QCP_RAN_ST    1_5_Cloud237_1
   [Documentation]   Auther: lisa.ding@nokia-sbell.com
   [Setup]    Testcase Basic Precondition    case_name=siteResetRemoveHwBin_kpi
   [Timeout]      24h
   Reset With Remove HWBIN KPI1
   [Teardown]    Testcase KPI postcondition    CaseType=RESET

[6][1.0] E2E_TL_Site_reset_without_HWF_with_OAM_KPI
   [Tags]    QC_35811    QCD_MN_RAN    QCP_RAN_ST    1_5_Cloud237_1
   [Documentation]   Auther: lisa.ding@nokia-sbell.com
   [Setup]    Testcase Basic Precondition    case_name=siteResetRemoveHwBin_kpi
   [Timeout]      24h
   Reset With Remove HWBIN KPI1
   [Teardown]    Testcase KPI postcondition    CaseType=RESET

[7][1.0] E2E_TL_Site_reset_without_HWF_with_OAM_KPI
   [Tags]    QC_35811    QCD_MN_RAN    QCP_RAN_ST    1_5_Cloud237_1
   [Documentation]   Auther: lisa.ding@nokia-sbell.com
   [Setup]    Testcase Basic Precondition    case_name=siteResetRemoveHwBin_kpi
   [Timeout]      24h
   Reset With Remove HWBIN KPI1
   [Teardown]    Testcase KPI postcondition    CaseType=RESET

[8][1.0] E2E_TL_Site_reset_without_HWF_with_OAM_KPI
   [Tags]    QC_35811    QCD_MN_RAN    QCP_RAN_ST    1_5_Cloud237_1
   [Documentation]   Auther: lisa.ding@nokia-sbell.com
   [Setup]    Testcase Basic Precondition    case_name=siteResetRemoveHwBin_kpi
   [Timeout]      24h
   Reset With Remove HWBIN KPI1
   [Teardown]    Testcase KPI postcondition    CaseType=RESET

[9][1.0] E2E_TL_Site_reset_without_HWF_with_OAM_KPI
   [Tags]    QC_35811    QCD_MN_RAN    QCP_RAN_ST    1_5_Cloud237_1
   [Documentation]   Auther: lisa.ding@nokia-sbell.com
   [Setup]    Testcase Basic Precondition    case_name=siteResetRemoveHwBin_kpi
   [Timeout]      24h
   Reset With Remove HWBIN KPI1
   [Teardown]    Testcase KPI postcondition    CaseType=RESET

[10][1.0] E2E_TL_Site_reset_without_HWF_with_OAM_KPI
   [Tags]    QC_35811    QCD_MN_RAN    QCP_RAN_ST    1_5_Cloud237_1
   [Documentation]   Auther: lisa.ding@nokia-sbell.com
   [Setup]    Testcase Basic Precondition    case_name=siteResetRemoveHwBin_kpi
   [Timeout]      24h
   Reset With Remove HWBIN KPI1
   [Teardown]    Testcase KPI postcondition    CaseType=RESET

[11][1.0] E2E_TL_Site_reset_without_HWF_with_OAM_KPI
   [Tags]    QC_35811    QCD_MN_RAN    QCP_RAN_ST    1_5_Cloud237_1
   [Documentation]   Auther: lisa.ding@nokia-sbell.com
   [Setup]    Testcase Basic Precondition    case_name=siteResetRemoveHwBin_kpi
   [Timeout]      24h
   Reset With Remove HWBIN KPI1
   [Teardown]    Testcase KPI postcondition    CaseType=RESET

[12][1.0] E2E_TL_Site_reset_without_HWF_with_OAM_KPI
   [Tags]    QC_35811    QCD_MN_RAN    QCP_RAN_ST    1_5_Cloud237_1
   [Documentation]   Auther: lisa.ding@nokia-sbell.com
   [Setup]    Testcase Basic Precondition    case_name=siteResetRemoveHwBin_kpi
   [Timeout]      24h
   Reset With Remove HWBIN KPI1
   [Teardown]    Testcase KPI postcondition    CaseType=RESET

[13][1.0] E2E_TL_Site_reset_without_HWF_with_OAM_KPI
   [Tags]    QC_35811    QCD_MN_RAN    QCP_RAN_ST    1_5_Cloud237_1
   [Documentation]   Auther: lisa.ding@nokia-sbell.com
   [Setup]    Testcase Basic Precondition    case_name=siteResetRemoveHwBin_kpi
   [Timeout]      24h
   Reset With Remove HWBIN KPI1
   [Teardown]    Testcase KPI postcondition    CaseType=RESET

[14][1.0] E2E_TL_Site_reset_without_HWF_with_OAM_KPI
   [Tags]    QC_35811    QCD_MN_RAN    QCP_RAN_ST    1_5_Cloud237_1
   [Documentation]   Auther: lisa.ding@nokia-sbell.com
   [Setup]    Testcase Basic Precondition    case_name=siteResetRemoveHwBin_kpi
   [Timeout]      24h
   Reset With Remove HWBIN KPI1
   [Teardown]    Testcase KPI postcondition    CaseType=RESET

[15][1.0] E2E_TL_Site_reset_without_HWF_with_OAM_KPI
   [Tags]    QC_35811    QCD_MN_RAN    QCP_RAN_ST    1_5_Cloud237_1
   [Documentation]   Auther: lisa.ding@nokia-sbell.com
   [Setup]    Testcase Basic Precondition    case_name=siteResetRemoveHwBin_kpi
   [Timeout]      24h
   Reset With Remove HWBIN KPI1
   [Teardown]    Testcase KPI postcondition    CaseType=RESET

[16][1.0] E2E_TL_Site_reset_without_HWF_with_OAM_KPI
   [Tags]    QC_35811    QCD_MN_RAN    QCP_RAN_ST    1_5_Cloud237_1
   [Documentation]   Auther: lisa.ding@nokia-sbell.com
   [Setup]    Testcase Basic Precondition    case_name=siteResetRemoveHwBin_kpi
   [Timeout]      24h
   Reset With Remove HWBIN KPI1
   [Teardown]    Testcase KPI postcondition    CaseType=RESET

[17][1.0] E2E_TL_Site_reset_without_HWF_with_OAM_KPI
   [Tags]    QC_35811    QCD_MN_RAN    QCP_RAN_ST    1_5_Cloud237_1
   [Documentation]   Auther: lisa.ding@nokia-sbell.com
   [Setup]    Testcase Basic Precondition    case_name=siteResetRemoveHwBin_kpi
   [Timeout]      24h
   Reset With Remove HWBIN KPI1
   [Teardown]    Testcase KPI postcondition    CaseType=RESET

[18][1.0] E2E_TL_Site_reset_without_HWF_with_OAM_KPI
   [Tags]    QC_35811    QCD_MN_RAN    QCP_RAN_ST    1_5_Cloud237_1
   [Documentation]   Auther: lisa.ding@nokia-sbell.com
   [Setup]    Testcase Basic Precondition    case_name=siteResetRemoveHwBin_kpi
   [Timeout]      24h
   Reset With Remove HWBIN KPI1
   [Teardown]    Testcase KPI postcondition    CaseType=RESET

[19][1.0] E2E_TL_Site_reset_without_HWF_with_OAM_KPI
   [Tags]    QC_35811    QCD_MN_RAN    QCP_RAN_ST    1_5_Cloud237_1
   [Documentation]   Auther: lisa.ding@nokia-sbell.com
   [Setup]    Testcase Basic Precondition    case_name=siteResetRemoveHwBin_kpi
   [Timeout]      24h
   Reset With Remove HWBIN KPI1
   [Teardown]    Testcase KPI postcondition    CaseType=RESET

[20][1.0] E2E_TL_Site_reset_without_HWF_with_OAM_KPI
   [Tags]    QC_35811    QCD_MN_RAN    QCP_RAN_ST    1_5_Cloud237_1
   [Documentation]   Auther: lisa.ding@nokia-sbell.com
   [Setup]    Testcase Basic Precondition    case_name=siteResetRemoveHwBin_kpi
   [Timeout]      24h
   Reset With Remove HWBIN KPI1
   [Teardown]    Testcase KPI postcondition    CaseType=RESET

### RFM Reset ###
[1][1.0] E2E_TL_RU_Reset_with_OAM_KPI
   [Tags]    QC_35810    QCD_MN_RAN    QCP_RAN_ST
   [Setup]    Testcase Basic Precondition    case_name=rf_reset_kpi
   ...    config_id=BTS_CLOUD_RF_FCA_T_F_105_LTE5205_3eNB
   [Timeout]      24h
   RFM Reset KPI51    test_loops=1
   [Teardown]    Testcase Basic Postcondition

[2][1.0] E2E_TL_RU_Reset_with_OAM_KPI
   [Tags]    QC_35810    QCD_MN_RAN    QCP_RAN_ST
   [Setup]    Testcase Basic Precondition    case_name=rf_reset_kpi
    ...    config_id=BTS_CLOUD_RF_FCA_T_F_105_LTE5205_3eNB
   [Timeout]      24h
   RFM Reset KPI51    test_loops=20
   [Teardown]    Testcase Basic Postcondition

[3][1.0] E2E_TL_RU_Reset_with_OAM_KPI
   [Tags]    QC_35810    QCD_MN_RAN    QCP_RAN_ST
   [Setup]    Testcase Basic Precondition    case_name=rf_reset_kpi
    ...    config_id=BTS_CLOUD_RF_FCA_T_F_105_LTE5205_3eNB
   [Timeout]      24h
   RFM Reset KPI51    test_loops=20
   [Teardown]    Testcase Basic Postcondition

### Cell Block And Unblock ###
[1][1.0] E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
  [Tags]    QC_35812    QCD_MN_RAN    QCP_RAN_ST    1_5_Cloud237_2
  [Setup]    Testcase Basic Precondition    case_name=Cell_Block_And_Unblock_kpi
  ...    config_id=BTS_CLOUD_RF_FCA_T_F_105_LTE5205_3eNB
  [Timeout]      24h
  Cell Lock And Unlock KPI_16
  [Teardown]    Testcase Basic Postcondition

[2][1.0] E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
  [Tags]    QC_35812    QCD_MN_RAN    QCP_RAN_ST    1_5_Cloud237_2
  [Setup]    Testcase Basic Precondition    case_name=Cell_Block_And_Unblock_kpi
   ...    config_id=BTS_CLOUD_RF_FCA_T_F_105_LTE5205_3eNB
  [Timeout]      24h
  Cell Lock And Unlock KPI_16
  [Teardown]    Testcase Basic Postcondition

[3][1.0] E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
  [Tags]    QC_35812    QCD_MN_RAN    QCP_RAN_ST    1_5_Cloud237_2
  [Setup]    Testcase Basic Precondition    case_name=Cell_Block_And_Unblock_kpi
   ...    config_id=BTS_CLOUD_RF_FCA_T_F_105_LTE5205_3eNB
  [Timeout]      24h
  Cell Lock And Unlock KPI_16
  [Teardown]    Testcase Basic Postcondition

#### OAM_KPI_L3call###
#[1][1.0] Common_SiSo_Call_1UE ULDL L3 call(Robustness)
#    [Tags]    QC_709498    QCD_MN_RAN    QCP_RAN_ST
#    [Setup]    Testcase Basic Precondition    case_name=L3call_kpi
#    ...    config_id=BTS_CLOUD_RF_FCA_T_F_105_LTE5205_3eNB
#    [Timeout]      24h
#    OAM KPI L3Call     421:422:423:424:425:426
#    OAM KPI L3Call     431:432:433:434:435:436
#    OAM KPI L3Call     411:412:413:414:416:415
#    [Teardown]    Testcase Basic Postcondition

### Delta Commissioning ###
[1][1.0] [1.1]Common_SiSo_Configuration Management_Delta plan Commissioning
   [Tags]    QC_35809    QCD_MN_RAN    QCP_RAN_ST
   [Setup]    Testcase Basic Precondition    case_name=Recommissioning
#    ...    config_id=BTS_CLOUD_RF_FCA_T_F_105_LTE5205_3eNB
   [Timeout]      24h
   FOR    ${num}    IN RANGE   ${1}
       Delta Commissioning Kpi For SISO3    ${parameters}
       Delta Commissioning Kpi For SISO3    ${parameters_recover}
   END
   Delta Commissioning Kpi For SISO3    ${parameters}
   [Teardown]    Testcase Basic Postcondition
