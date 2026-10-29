*** Settings ***
Documentation     [PURPOSE]
Suite Setup       suite setup
Suite Teardown    suite teardown
Force Tags        SBTS25R1    QCD_MN_RAN     QCP_RAN_VRF   CA_RAN_PZ_HAZ_1

Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_common.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource          ../SWM/CB007335/CB007335_02_02_Copy_BTS_SW_and_configuration_from_ac_to_pa_par_Netact.robot


*** Variables ***
${target_release}   SBTS25R1


#*** Test Cases ***
#CB007335_02_02_Copy_BTS_SW_and_configuration_from_active_to_passive_Netact
#    [Tags]    QC_33337   7335    11
#    [Setup]    run keywords    Set Library Search Order
#    ...   CB007335_02_02_Copy_BTS_SW_and_configuration_from_ac_to_pa_par_Netact
#    ...    AND    TC Setup
#    TC_CB007335_02_02_Copy_BTS_SW_and_configuration_from_active_to_passive_Netact
#    [Teardown]    TC Teardown
