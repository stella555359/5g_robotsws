*** Settings ***
Documentation    Suite description
...    Author:        len.lin@nokia-sbell.com
...    Maintainer:    lin len

Suite Setup    Suite Precondition
Suite Teardown    Suite Postcondition

Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/UUF.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/oam_kpi_test_fv.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/reportportal.robot

Library    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/kpiReporter.py

Variables    ./env.py


Force Tags    CLOUD_RF_AIR_B4_AEQM    CA_RAN_PZ_HAZ_1  SBTS25R1  RAN_5G  RAN_5G_TDD  CRT


*** Variables ***

&{CLOUD_RF_AIR_B4_AZHL_SBTS25R1_T2_495}=    HW_ID=T2    ONAIR_TIME=20 min    site_mode=5G

### For UUF ###

${SA_OR_NSA}
${TDD_OR_FDD}    TDD
${RU}    AZHL
${HW_ID}    ASIM+ABIO+AZHL
${TOP50}    True



*** Test Cases ***
[1][1.0] E2E_TL_Site_reset_without_HWF_with_OAM_KPI
    [Tags]    QC_159140    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=siteResetRemoveHwBin_kpi
    ...    config_id=CLOUD_RF_AIR_B4_AZHL_SBTS25R1_T2_495
    [Timeout]      2h
    Reset With Remove HWBIN KPI1
    [Teardown]    Testcase KPI postcondition    CaseType=RESET
