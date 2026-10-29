*** Settings ***
Documentation     [PURPOSE]
Suite Setup       suite setup
Suite Teardown    suite teardown
Force Tags        SBTS25R1    QCD_MN_RAN     QCP_RAN_VRF   CA_RAN_PZ_HAZ_1
#Library           hran_ssh
#Library           hran_compa
#Library           hran_tools

Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_common.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource          ../SWM/SWM__Local_Software_Download_Cancel.robot
Resource          ../SWM/CB002956/RP002956_ST_SWM_duration_of_SW_Download_Activation_KPI.robot
Resource          ../SWM/SWM__SW_pre_check_successful.robot
Resource          ../SWM/SWM__SW_post_check_successful.robot
Resource          ../SWM/CB006053/CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.robot
Resource          ../SWM/RP002315/RP002315_05_01_Software_Precheck_postcheck_from_NetAct_for_single_SBTS.robot
Resource          ../SWM/CB009402_ST_05_01_SW_Download_Throughput_Measurements.robot


*** Variables ***
${target_release}    SBTS00


*** Test Cases ***
[1]RP002956_ST_05_02 SWM duration of SW Activation from NetAct single BTS
#The case include download and activation
    [Tags]    QC_392110    3_5_UTE4G223
    [Setup]    run keywords    Set Library Search Order   RP002956_ST_SWM_duration_of_SW_Download_Activation_KPI
    ...    AND    TC Setup
    TC__ST_SWM_duration_of_SW_Download_Activation_KPI
    [Teardown]    TC Teardown

[1]RP002956_ST_05_01 SWM duration of SW Download from NetAct single BTS
# just kpi result fetch, to update QC
    [Tags]    QC_392109    3_5_UTE4G223
    [Setup]    run keywords    Set Library Search Order   RP002956_ST_SWM_duration_of_SW_Download_Activation_KPI
    ...    AND    TC Setup
    Run keyword if    '${Download_KPI_check}'=='True'    Log    SW_DOWNLOA_BTS_KPI is as expected.
    ...  ELSE   FAIL   SW_DOWNLOA_BTS_KPI is not expected, you can find result in the previous case.

    [Teardown]    TC Teardown

[1]RP002956_ST_05_04 SWM duration of SW Rollback from NetAct single BTS
#The function case include three kpi check, 1th is upload
    [Tags]    QC_392112    veriry_new_way    3_5_UTE4G223    2302
    [Setup]    run keywords    Set Library Search Order    CB006053_LTE4934-C_ST_05_15_ Flat SOAM_Software Management_SWM_Provision Software
    ...    AND    TC Setup
    LTE4934-C_ST_05_15_ Flat SOAM_Software Management_SWM_Provision Software  CB008457
    [Teardown]    TC Teardown

[1]RP002956_ST_05_03 SWM duration of SW Provision from NetAct single BTS
# just kpi result fetch, to update QC
    [Tags]    QC_392111    veriry_new_way    3_5_UTE4G223    2302
    [Setup]    run keywords    Set Library Search Order   CB006053_LTE4934-C_ST_05_15_ Flat SOAM_Software Management_SWM_Provision Software
    ...    AND    TC Setup
    Run keyword if    '${SW_UPLOAD_KPI_Check}'=='True'    Log    SW_CONFIGURATION_UPLOAD_OPERATION_KPI is as expected.
    ...  ELSE   FAIL   SW_CONFIGURATION_UPLOAD_OPERATION_KPI is not expected, you can find result in the previous case.
    [Teardown]    TC Teardown
