*** Settings ***
Documentation     [PURPOSE]
Suite Setup       hran_frame_sbts.suite setup
Suite Teardown    hran_frame_sbts.suite teardown
Force Tags        SBTS00    QCD_MN_RAN  QCP_RAN_VRF
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource    ../SWM/CB006536/ASIB_ASIB/CB006536_01_08_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082.robot
Resource    ../SWM/CB006536/SWM/CB006536_LTE2866-R_01_09_ST_BTS_SW_fallback_in_primary_core_with_fault_4082.robot
Resource    ../SWM/CB006053/CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.robot
Resource    ../SWM/CB006536/ASIB_ASIB/SOAM_Software_Management_SWM_rollback_Software_for_multi-MRBTS.robot
Resource    ../HWM/LTE3656/LTE3656_V_10_reset_FHS_in_fullrack_BTS.robot
Resource    ../HWM/LTE4498/Dualcore_LTE4498.robot
Resource    ../SWM/LTE3332-T-b/SWM_Repeated_Background_SW_Update_To_BTS__HWrel-R4.robot
Resource          ../SWM/SWM_BTS_SOAM_Local_Software_Download_and_Activation_lock_unlock_BCF.robot
Resource          ../SWM/SWM__SW_update_for_RMOD_with_fault_23.robot

*** Variables ***
${target_release}    SBTS00


*** Test Cases ***
CB006536_LTE4934-C_ST_05_15_ Flat SOAM_Software Management_SWM_Provision Software
    [Tags]    QC_33351  feature:6056  original:3_5_UTESRAN232  1st:3_5_UTE4G217  Prio-1
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.TC_Custom Setup
    ...    AND    Set Library Search Order
    ...    CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software
    LTE4934-C_ST_05_15_ Flat SOAM_Software Management_SWM_Provision Software  CB006536
    [Teardown]    CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.TC_Custom Teardown
CB006536_LTE4934-C_ST_05_16_ Flat SOAM_Software Management_SWM_rollback_Software_for_multi-MRBTS
    [Tags]    QC_33353  feature:6056  original:3_5_UTESRAN232  1st:3_5_UTE4G217  Prio-1
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    SOAM_Software_Management_SWM_rollback_Software_for_multi-MRBTS.TC_Custom Setup
    ...    AND    Set Library Search Order    SOAM_Software_Management_SWM_rollback_Software_for_multi-MRBTS
    TC_SWM_rollback_Software_for_multi-MRBTS
    [Teardown]    SOAM_Software_Management_SWM_rollback_Software_for_multi-MRBTS.TC_Custom Teardown

LTE4498_ST_04_Do_HW_inverntory_upload_from_Netact_independently_form_CM
    [Tags]    QC_33325   21    3_5_UTE4G217
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    Set Library Search Order    Dualcore_LTE4498
    ...    AND    TC setup
    Dualcore_ASMI_LTE4498_ST_04_Do_HW_inverntory_upload_from_Netact_independently_form_CM
    [Teardown]    TC teardown
#Automated__SW_Management__Repeated_Background_SW_Update_To_BTS__HWrel-FSMr3
#    [Tags]    QC_33289    disconnect_Netact  robot:no-dry-run     3_5_UTE4G217
#    [Setup]    run keywords    TC Setup
#    ...    AND    Set Library Search Order   SWM_Repeated_Background_SW_Update_To_BTS__HWrel-R4.robot
#    TC__SWM_Repeated_Background_SW_Update_To_BTS__HWrel-R4
#    [Teardown]    TC Teardown
SWM_BTS_SOAM_Local_Software_Download_and_Activation_lock_unlock_BCF
    [Tags]    QC_33309    3_5_UTE4G204      1st:3_5_UTE4G884      prio-2
    [Setup]    run keywords   Set Library Search Order    SWM_BTS_SOAM_Local_Software_Download_and_Activation_lock_unlock_BCF
    ...    taf.sbts.oam.coam.admin     taf.nms.netact
    ...    AND    TC Setup
    TC__SWM_BTS_SOAM_Local_Software_Download_and_Activation_lock_unlock_BCF
    [Teardown]    TC Teardown
SWM__SW_update_for_RMOD_with_fault_23
    [Tags]    QC_33320    original:3_5_UTE4G500      1st:3_5_UTE4G884      prio-1      test
    [Setup]    run keywords    Set Library Search Order    SWM__SW_update_for_RMOD_with_fault_23    hran_general
    ...    AND     SWM__SW_update_for_RMOD_with_fault_23.TC_Custom Setup
    TC__SWM__SW_update_for_RMOD_with_fault_23
    [Teardown]    SWM__SW_update_for_RMOD_with_fault_23.TC_Custom Teardown

#CB007425_LTE4498_ST_01_Check HW inverntory information automatic updated after new HW_ABIAorRRU #add, change and remove
#    [Tags]    QC_33411     original:10_5_CLOUD602         1st:3_5_UTE4G884      prio-1
#    [Setup]    run keywords    NR_Switch_Open
#    ...    AND    Set Library Search Order    CB006053_LTE4498
#    ...    AND    TC setup
#    LTE4498_ST_01_Check HW inverntory information automatic updated after new HW_ABIAorRRU add,#change and remove_R4
#    [Teardown]    TC Teardown

#LTE4498_ST_04_Do_HW_inverntory_upload_from_Netact_independently_form_CM_884
#    [Tags]    QC_33410     original:10_5_CLOUD602         1st:3_5_UTE4G884      prio-1
#    [Setup]    run keywords    NR_Switch_Open
#    ...    AND    Set Library Search Order    Dualcore_LTE4498
#    ...    AND    TC setup
#    Dualcore_ASMI_LTE4498_ST_04_Do_HW_inverntory_upload_from_Netact_independently_form_CM
#    [Teardown]    TC teardown

