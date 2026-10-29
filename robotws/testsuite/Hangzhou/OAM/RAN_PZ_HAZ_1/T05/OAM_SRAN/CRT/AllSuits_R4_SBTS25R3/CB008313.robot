*** Settings ***
Documentation     [PURPOSE]
Suite Setup       suite setup
Suite Teardown    suite teardown
Force Tags        SBTS25R3    QCD_MN_RAN     QCP_RAN_VRF   CA_RAN_PZ_HAZ_1
Library           taf.sbts.oam.coam.admin
Library           ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/verdict.py
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_common.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource          ../SWM/CB006053/CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.robot
Resource          ../SWM/CB008313/CB008313_LTE655.robot
Resource          ../SWM/CB008313/CB008313_LTE655_05_09_Automatic_SW_Fallback.robot


*** Variables ***
${target_release}    SBTS25R3


#*** Test Cases ***
#CB008313_LTE4934-C_ST_05_16_ Flat SOAM_Software Management_SWM_rollback Software for multi-MRBTS
##The function case include three kpi check,1th is upload,2th is provision, 3th is rollback, the final step is rollback
##so choose rollback as the case name
#    [Tags]    QC_694013   10_5_UTESRAN261    SWM
#    [Setup]    run keywords    NR_Switch_Open
#    ...    AND    CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.TC_Custom Setup
#    ...    AND    Set Library Search Order    CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software
#    LTE4934-C_ST_05_15_ Flat SOAM_Software Management_SWM_Provision Software  CB006053
#    [Teardown]    CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.TC_Custom Teardown

#CB008313_LTE4934-C_ST_05_15_ Flat SOAM_Software Management_SWM_Provision Software
## just kpi result fetch, to update QC
##    [Tags]    QC_694014   10_5_UTESRAN261    SWM
##    Run keyword if    '${SW_UPLOAD_KPI_Check}'=='True'    Log    SW_CONFIGURATION_UPLOAD_OPERATION_KPI is as expected.
##    ...  ELSE   FAIL   SW_CONFIGURATION_UPLOAD_OPERATION_KPI is not expected, you can find result in the previous case.
##    [Teardown]    TC Teardown
#    [Tags]    QC_694014   10_5_UTESRAN261    SWM
#    [Setup]    run keywords    NR_Switch_Open
#    ...    AND    CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.TC_Custom Setup
#    ...    AND    Set Library Search Order    CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software
#    LTE4934-C_ST_05_15_ Flat SOAM_Software Management_SWM_Provision Software  CB006053
#    [Teardown]    CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.TC_Custom Teardown
#
#CB008313_LTE655_05_09_Automatic_SW_Fallback
#    [Tags]    QC_33336   10_5_UTESRAN261    SWM
#    [Setup]    run keywords    NR_Switch_Open
#    ...    AND    Set Library Search Order    CB008313_LTE655_05_09_Automatic_SW_Fallback
#    ...    AND    TC Setup
#    CB008313_LTE655_05_09_Automatic_SW_Fallback
#    [Teardown]    TC Teardown
