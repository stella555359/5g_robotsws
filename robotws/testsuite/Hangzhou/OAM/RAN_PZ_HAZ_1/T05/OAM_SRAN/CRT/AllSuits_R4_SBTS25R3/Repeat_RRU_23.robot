*** Settings ***
Documentation     [PURPOSE]
Suite Setup       hran_frame_sbts.suite setup    #for debug
Suite Teardown    hran_frame_sbts.suite teardown
Force Tags        SBTS25R3    QCD_MN_RAN     QCP_RAN_VRF   CA_RAN_PZ_HAZ_1
#Library           hran_ssh
#Library           hran_compa
#Library           hran_tools
#Library           hran_tools
Library           ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/verdict.py
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_common.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource          ../SWM/Repeated_SWM__SW_update_for_Second_Core_RMOD_with_fault_23.robot
Library           taf.pdu  WITH NAME  pdu


*** Variables ***
${target_release}   SBTS25R3


#*** Test Cases ***
#Automated__SWM__SW_update_for_RMOD_with_fault_23
#    [Tags]    QC_599099   3_5_UTESRAN704    SWM    EDA
#    [Setup]    run keywords    NR_Switch_Open
#    ...    AND    Set Library Search Order    Repeated_SWM__SW_update_for_Second_Core_RMOD_with_fault_23
#    ...    AND    Repeated_SWM__SW_update_for_Second_Core_RMOD_with_fault_23.TC_Custom Setup
#    TC__Repeated_SWM__SW_update_for_Second_Core_RMOD_with_fault_23
#    [Teardown]    Repeated_SWM__SW_update_for_Second_Core_RMOD_with_fault_23.TC_Custom Teardown
