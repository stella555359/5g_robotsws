*** Settings ***
Documentation     [PURPOSE]
Suite Setup       suite setup
Suite Teardown    suite teardown
Force Tags        SBTS00    QCD_MN_RAN     QCP_RAN_VRF
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_common.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource          ../SWM/CB007335/CB007335_02_05_Health_check_before_copy_BTS_SW_and_configuration.robot
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
[1]RP002956_ST_05_06 SWM duration of cancel SW Management from NetAct single BTS
    [Tags]    QC_184492    3_5_UTESRAN251
    [Setup]    run keywords    Set Library Search Order   SWM__Local_Software_Download_Cancel
    ...    AND    TC Setup
    TC__SWM__Local_Software_Download_Cancel
    [Teardown]    TC Teardown

[1]CB007215_ST_05_01 Max Duration of SW Pre-check - single Netact
    [Tags]    QC_184490   BTS_Side    3_5_UTESRAN251
    [Setup]    run keywords    Set Library Search Order   SWM__SW_pre_check_successful
    ...    AND    TC Setup
    TC__SWM__SW_pre_check_successful
    [Teardown]    TC Teardown

[1]CB007215_ST_05_01 Max Duration of SW Pre-check - single BTS
    [Tags]    QC_184490   Netact_Side    3_5_UTESRAN251
    [Setup]    run keywords    Set Library Search Order   SWM__SW_pre_check_successful
    ...    AND    TC Setup
    RP002315_05_01_Software Precheck from NetAct for single SBTS
    [Teardown]    TC Teardown

[1]RP002956_ST_05_02 SWM duration of SW Activation from NetAct single BTS
#The case include download and activation, and the case result is decided by the final step_activation,so it represent the result of activate.
    [Tags]    QC_184493    3_5_UTESRAN251
    [Setup]    run keywords    Set Library Search Order   RP002956_ST_SWM_duration_of_SW_Download_Activation_KPI
    ...    AND    TC Setup
    TC__ST_SWM_duration_of_SW_Download_Activation_KPI
    [Teardown]    TC Teardown

[1]RP002956_ST_05_01 SWM duration of SW Download from NetAct single BTS
# just kpi result fetch, to update QC
    [Tags]    QC_184491    3_5_UTESRAN251
    [Setup]    run keywords    Set Library Search Order   RP002956_ST_SWM_duration_of_SW_Download_Activation_KPI
    ...    AND    TC Setup
    Run keyword if    '${Download_KPI_check}'=='True'    Log    SW_DOWNLOA_BTS_KPI is as expected.
    ...  ELSE   FAIL   SW_DOWNLOA_BTS_KPI is not expected, you can find result in the previous case.
    [Teardown]    TC Teardown

[1]CB007215_ST_05_02 Max Duration of SW Post-check - single BTS
    [Tags]    QC_184496   BTS_Side    3_5_UTESRAN251
    [Setup]    run keywords    Set Library Search Order   SWM__SW_post_check_successful
    ...    AND    TC Setup
    TC__SWM__SW_post_check_successful
    [Teardown]    TC Teardown

[1]CB007215_ST_05_02 Max Duration of SW Post-check - single Netact
    [Tags]    QC_184496    Netact_Side    3_5_UTESRAN251
    [Setup]    run keywords    Set Library Search Order   SWM__SW_post_check_successful
    ...    AND    TC Setup
    RP002315_05_02_Software Postcheck from NetAct for single SBTS
    [Teardown]    TC Teardown

[1]RP002956_ST_05_04 SWM duration of SW Rollback from NetAct single BTS
#The function case include three kpi check, 1th is upload, 2th is provision, 3th is rollback, the final step is rollback,
# so choose rollback as the case name.
    [Tags]    QC_184494    veriry_new_way    3_5_UTESRAN251
    [Setup]    run keywords    Set Library Search Order    CB006053_LTE4934-C_ST_05_15_ Flat SOAM_Software Management_SWM_Provision Software
    ...    AND    TC Setup
    LTE4934-C_ST_05_15_ Flat SOAM_Software Management_SWM_Provision Software  CB008457
    [Teardown]    TC Teardown

[1]RP002956_ST_05_03 SWM duration of SW Provision from NetAct single BTS
# just kpi result fetch, to update QC
    [Tags]    QC_184497    veriry_new_way    3_5_UTESRAN251
    [Setup]    run keywords    Set Library Search Order    CB006053_LTE4934-C_ST_05_15_ Flat SOAM_Software Management_SWM_Provision Software
    ...    AND    TC Setup
    Run keyword if    '${SW_UPLOAD_KPI_Check}'=='True'    Log    SW_CONFIGURATION_UPLOAD_OPERATION_KPI is as expected.
    ...  ELSE   FAIL   SW_CONFIGURATION_UPLOAD_OPERATION_KPI is not expected, you can find result in the previous case.
    [Teardown]    TC Teardown

[1]RP002956_ST_05_05 SWM Upload SW Configuration from NetAct single BTS
# just kpi result fetch, to update QC
    [Tags]    QC_184495    veriry_new_way    3_5_UTESRAN251
    [Setup]    run keywords    Set Library Search Order    CB006053_LTE4934-C_ST_05_15_ Flat SOAM_Software Management_SWM_Provision Software
    ...    AND    TC Setup
    Run keyword if    '${SW_PROVISION_KPI_Check}'=='True'    Log    SW_PROVISION_BTS_KPI is as expected.
    ...  ELSE   FAIL   SW_PROVISION_BTS_KPI is not expected, you can find result in the main case.
    [Teardown]    TC Teardown
#[1]CB008181_ST_05_01 Duration of Copy SW from Active to Passive Partition
#    [Tags]    QC_608857    3_5_UTESRAN251
#    [Setup]    run keywords    Set Library Search Order   CB007335_02_05_Health_check_before_copy_BTS_SW_and_configuration
#    ...    AND    TC Setup
#    TC_CB007335_02_05_Health_check_before_copy_BTS_SW_and_configuration_from_active_to_passive_partition
#    [Teardown]    TC Teardown

CB009402_ST_05_01_SW_Download_Throughput_Measurements
    [Tags]    QC_184489  robot:no-dry-run    3_5_UTESRAN251
    [Setup]    run keywords    Common Test Setup
    ...    AND    Set Library Search Order    CB009402_ST_05_01_SW_Download_Throughput_Measurements    hran_general
    TC__CB009402_ST_05_01_SW_Download_Throughput_Measurements
    [Teardown]    Common Test Teardown
