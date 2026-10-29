*** Settings ***
Documentation     [PURPOSE]
Suite Setup       suite setup
Suite Teardown    suite teardown
Force Tags        SBTS00    QCD_MN_RAN     QCP_RAN_ST    CA_RAN_PZ_HAZ_1
Library           taf.sbts.oam.coam.admin
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_common.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource          ../SWM/SWM__SW_pre_check_successful.robot
#Resource          ../SWM/RP002315/RP002315_05_03_Software Precheck from NetAct for single SBTS when stb file logs is full.robot
Resource          ../SWM/CB007944/CB007944_Robustness_Multiple_SW_Pre_check_No_available_disk_space.robot


*** Variables ***
${target_release}    SBTS00


*** Test Cases ***
#CB007944_ST_05_05_sw precheck succeed on Netact when there is not enough space in passive disk
#    [Tags]    QC_269860    QCD_MN_RAN    QCP_RAN_ST    3_5_UTESRAN261
#    [Setup]    run keywords    NR_Switch_Open
#    ...    AND    Set Library Search Order   RP002315_05_03_Software Precheck from NetAct for single SBTS when stb file logs is full
#    ...    AND    TC Setup
#    RP002315_05_03_Software_Precheck_from_NetAct_for_single_SBTS_when_stb_file_logs_is_full
#    [Teardown]    TC Teardown
CB007944_Robustness_Multiple_SW_Pre_check_No_available_disk_space
    [Tags]    QC_542902  HW_DualCore   10_5_UTESRAN264
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    Set Library Search Order  CB007944_Robustness_Multiple_SW_Pre_check_No_available_disk_space
    ...    AND    TC Setup
    TC_CB007944_Robustness_Multiple_SW_Pre_check_No_available_disk_spac
    [Teardown]    TC Teardown
