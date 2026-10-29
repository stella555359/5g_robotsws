*** Settings ***
Documentation
...   CB008490 Test cases regression - CRT
...   Topology  CLOUD_5G_I_[MP][MP]_AP_[LOOO]
...   Variant    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_GMC
...   author:   Marcin Kotuła (marcin.kotula@nokia.com)

Variables    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_variables.py

Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_variables.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_keywords.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_configuration.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/feature_activation.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/logs_collection.robot

Library      ta5g_pm_counters
Library      testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_keywords.py
Library      testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/pm_counters_validator.py

Resource     ${folder_path}/CB008490-L_B2_Handling_of_the_UE-Capability_pdcch-BlindDetection_in_the_SCG.robot
Resource     ${folder_path}/CB008490-L_B101_SRS_Port_Update.robot
Resource     ${folder_path}/CB008490-L_B101_Successful_Beam_Group_Change.robot
Resource     ${folder_path}/CB008490-L_B102_Overload_Handling.robot
Resource     ${folder_path}/CB008490-L_B102_TimerXnDcOverall_Takeback.robot

Test Teardown    Common Test Teardown CB008490

*** Variables ***
${folder_path}=     ../../CB008490_Inter-gNB_FR1-FR2_NR_DC_for_Fixed_Wireless_Access
${iphy}=            iphy_MN_AEQE_SN_AWEUB_8CC.xml
${MN_scf}=          full_scf_gnb2_MN_8CC.xml
${SN_scf}=          full_scf_gnb3_SN_8CC.xml
${cfg_filepath}=    ${EPCSIM_CFG_PATH_NRDC_8CC}

*** Test Cases ***
[1][1.0]CB008490-L_B101_Successful_Beam_Group_Change
    [Setup]     Run Keywords    Prepare Test Environement for Real MN With SN And Reach Onair    ${iphy}    ${MN_scf}    ${SN_scf}    ${cfg_filepath}
    ...         AND             Setup multigNB devices aliases

    CB008490-L_B101_Successful_Beam_Group_Change

[1][1.0] CB008490-L_B2_Handling_of_the_UE-Capability_pdcch-BlindDetection_in_the_SCG
    [Setup]     Run Keywords    Prepare Test Environement for Real MN With SN And Reach Onair    ${iphy}    ${MN_scf}    ${SN_scf}    ${cfg_filepath}
    ...         AND             Setup multigNB devices aliases

    CB008490-L_B2_Handling_of_the_UE-Capability_pdcch-BlindDetection_in_the_SCG

[1][1.0] CB008490-L-B101_SRS_port_updated
    [Setup]     Run Keywords    Set rdRsrpCellCenteredThreshold To -128 on gNB3
    ...         AND             Prepare Test Environement for Real MN With SN And Reach Onair    ${iphy}    ${MN_scf}    ${SN_scf}    ${cfg_filepath}
    ...         AND             Setup multigNB devices aliases
    ...         AND             Enable actCoverageNonCoherentUes on gNB3

    CB008490-L-B101_SRS_port_updated

[1][1.0]CB008490-L_B102_Exceptional_Case_TimerXnDcOverall_Takeback
    [Setup]     Run Keywords    Prepare Test Environement for Real MN With SN And Reach Onair    ${iphy}    ${MN_scf}    ${SN_scf}    ${cfg_filepath}
    ...         AND             Decrease timerXnDcOverall On MN And SN

    CB008490-L_B102_Exceptional_Case_TimerXnDcOverall_Takeback

[1][1.0]CB008490-L_B102_Exceptional_Case_Overload_Handling
    [Setup]     Run Keywords    Prepare Test Environement for Real MN With SN And Reach Onair    ${iphy}    ${MN_scf}    ${SN_scf}    ${cfg_filepath}
    ...         AND             Enable ovlSNInitModRej On MN

    CB008490-L_B102_Exceptional_Case_Overload_Handling
