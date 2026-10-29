*** Settings ***
Documentation    Suite description
...    Author:        len.lin@nokia-sbell.com
...    Maintainer:    lin len

Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_fv.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/oam_kpi_test_fv.robot
Variables    ./env.py

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition


Force Tags    CLOUD_5G_CLASSICAL_NSA_ASIB_CA    CA_RAN_PZ_HAZ_1    SBTS00    RAN_5G    RAN_5G_FDD

*** Variables ***
&{5G_CB008434_S2_without_sleep}=        HW_ID=5G_CB008434        ONAIR_TIME=20 min        site_mode=SA

${GLO_TL_DESCRIPTOR_FILE_PATH}=      ${CURDIR}/TLdescriptor.xml
@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}    NgGnbInitPartialReset    NgGnbInitFullReset    Unit power reset


${YAFT}       YES
${INIT_SW_VERSION}        {'10451': 'SBTS23R4_ENB_0000_001194_000000'}
${TARGET_SW_VERSION}         {'10451': 'SBTS00_ENB_9999_230712_000013'}
${RB_TO_TARGET}     YES
${SPECIFIC_BRANCH}  SBTS24R3

${TOP50}                             False
${GLO_SCOUT_TESTLINE_NAME}           1_5_Cloud235

${SA_OR_NSA}
${TDD_OR_FDD}    TDD
${RU}    3AKQJ
${HW_ID}    ASIB+ABIO


*** Test Cases ***

[1][1.0] E2E_TL_SW_upgrade_rollback_with_OAM_KPI_and_L3_Call
    [Timeout]    12h
    [Tags]    QC_218918   QCD_MN_RAN   QCP_RAN_VRF
    [Setup]    Testcase UUF Precondition    case_name=E2E_TL_SW_upgrade_rollback_with_OAM_KPI_and_L3_Call
    ...    config_id=5G_CB008434_S2_without_sleep
    SW Upgrade And RollBack KPI2    L3Call=NO
    [Teardown]     Testcase KPI postcondition
