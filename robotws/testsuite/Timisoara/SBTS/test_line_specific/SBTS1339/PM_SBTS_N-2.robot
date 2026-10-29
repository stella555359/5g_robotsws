*** Settings ***
Documentation
...  SBTS10339 PM TC trunk sutie

Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SRAN  CLOUD_SRAN_LWG_10339_1ASIA_2ABIA_2FXDB_1FHEL_2FRGY  STATE_COMMISSIONED
Library           XML  use_lxml=True

Resource    ../../PM/test_resources/PM__LTE_measurements_disabling_with_validation.robot
Resource    ../../PM/test_resources/PM__Reporting_interval_reconfiguration_to_shorter_than_currently_used.robot
Resource    ../../PM/test_resources/PM__Reporting_interval_reconfiguration_to_longer_than_currently_used_30_min.robot
Resource    ../../PM/test_resources/PM__LTE_DL_UL_Throughput_Check.robot
Resource    ../../PM/test_resources/PM__Robustness_Check_Counters_On_PM_Reports_After_Site_And_Power_Reset.robot
Resource    ../../PM/test_resources/PM__WCDMA_measurement_interval_change-counters_collection_disabling.robot
Resource    ../../PM/test_resources/PM__MME_Connection_Outage.robot
Resource    ../../PM/test_resources/PM__NE3S_Interface_Setup_In_Startup.robot
Resource    ../../PM/test_resources/PM__SFP_Dynamic_Data.robot
Resource    ../../PM/test_resources/PM__Measurements_Interval_Change_From_Longer_To_Shorter.robot
Resource    ../../PM/test_resources/PM__Check_Counters_Number_On_NetAct_Reports.robot
Resource    ../../PM/test_resources/PM__Sum_NR_Counters_Suppression.robot
Resource    ../../PM/test_resources/PM__PPM_File_Transfer_To_ONAP.robot
Resource    ../../PM/test_resources/PM__PPM_File_Transfer_To_Mantaray.robot

Suite Setup      Set Library Search Order  coam   ute_admin   hran_frame_sbts_taf   hran_frame_sbts_siso   ca_CIT_general   ca_swm_general

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${ENB_BUILD}    SBTS00_ENB_9999_211207_000006
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1339
${SKIP_RU_POWER_CHECK}    ${TRUE}


*** Test Cases ***
PM__Sum_NR_Counters_Suppression
    [Tags]     QC_255768
    [Setup]    Run Keywords
    ...    PM__Sum_NR_Counters_Suppression.TC Setup
    ...    AND    Modify Resource Search Order    PM__Sum_NR_Counters_Suppression
    ...    AND    Set Library Search Order    PM__Sum_NR_Counters_Suppression
	TC__PM__Sum_NR_Counters_Suppression
    [Teardown]    Run Keywords    PM__Sum_NR_Counters_Suppression.TC Teardown
    ...    AND    Restore Resource Search Order


PM__Check_Counters_Number_On_NetAct_Reports
    [Tags]     QC_159979
    [Setup]    Run Keywords
    ...    Set Test Variable    ${WEB_URL}    srnclab2002lbwas.srnblr.nsn-rdnet.net
    ...    AND    Set Test Variable    ${CMWAS_SERVICE_IP}    10.82.47.15
    ...    AND    PM__Check_Counters_Number_On_NetAct_Reports.TC Setup
    ...    AND    Modify Resource Search Order    PM__Check_Counters_Number_On_NetAct_Reports
    ...    AND    Set Library Search Order    PM__Check_Counters_Number_On_NetAct_Reports
    TC__PM__Check_Counters_Number_On_NetAct_Reports
    [Teardown]    Run Keywords    PM__Check_Counters_Number_On_NetAct_Reports.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__ PM__LTE_measurements_disabling_with_validation
    [Tags]  QC_255766
    [Setup]    Run Keywords    Set Test Variable    ${PMRNL_PARAMETER}    mtCellAvailability, mtTranspLoad
    ...    AND    Set Test Variable    ${SKIP_PARAMETER_RELATION_ERRORS}    True
    ...    AND    PM__LTE_measurements_disabling_with_validation.TC Setup
    ...    AND    Modify Resource Search Order    PM__LTE_measurements_disabling_with_validation
    ...    AND    Set Library Search Order    PM__LTE_measurements_disabling_with_validation
    [Timeout]    14400
    TC__PM__LTE_measurements_disabling_with_validation
    [Teardown]    Run Keywords    PM__LTE_measurements_disabling_with_validation.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__PM__WCDMA_measurement_interval_change-counters_collection_disabling
    [Tags]     QC_255765
    [Setup]    Run Keywords    Set Test Variable    @{WNPMRNL_DICTIONARY}
    ...    AND    Set Test Variable    ${WNPMRNL_PARAMETER}    mtFrameProtWBTS
    ...    AND    PM__WCDMA_measurement_interval_change-counters_collection_disabling.TC Setup
    ...    AND    Modify Resource Search Order    PM__WCDMA_measurement_interval_change-counters_collection_disabling
    ...    AND    Set Library Search Order    PM__WCDMA_measurement_interval_change-counters_collection_disabling
    [Timeout]    21600
    TC__PM__WCDMA_measurement_interval_change-counters_collection_disabling
    [Teardown]    Run Keywords    PM__WCDMA_measurement_interval_change-counters_collection_disabling.TC Teardown
    ...    AND    Restore Resource Search Order



[1]Automated__PM__Reporting_interval_reconfiguration_to_shorter_than_currently_used
    [Tags]  QC_255761
    [Setup]    Run Keywords    Set Test Variable    ${NEW_ReportingInterval}    15min
    ...    AND    Set Test Variable    ${skip_parameter_relation_errors}    False
    ...    AND    PM__Reporting_interval_reconfiguration_to_shorter_than_currently_used.TC Setup
    ...    AND    Modify Resource Search Order    PM__Reporting_interval_reconfiguration_to_shorter_than_currently_used
    ...    AND    Set Library Search Order    PM__Reporting_interval_reconfiguration_to_shorter_than_currently_used
    [Timeout]    14400
    TC__PM__Reporting_interval_reconfiguration_to_shorter_than_currently_used
    [Teardown]    Run Keywords    PM__Reporting_interval_reconfiguration_to_shorter_than_currently_used.TC Teardown
    ...    AND    Restore Resource Search Order



[1]PM__Robustness_Check_Counters_On_PM_Reports_After_Site_And_Power_Reset
    [Tags]     QC_255760
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    PM__Robustness_Check_Counters_On_PM_Reports_After_Site_And_Power_Reset.TC Setup
    ...    AND    Modify Resource Search Order    PM__Robustness_Check_Counters_On_PM_Reports_After_Site_And_Power_Reset
    TC__PM__Robustness_Check_Counters_On_PM_Reports_After_Site_And_Power_Reset
    [Teardown]    Run Keywords    PM__Robustness_Check_Counters_On_PM_Reports_After_Site_And_Power_Reset.TC Teardown
    ...    AND    Restore Resource Search Order



PM__PPM_File_Transfer_To_ONAP
    [Tags]     QC_255770
    [Setup]    Run Keywords
    ...    Set Test Variable    ${VM_WITH_PANO_IP}    10.5.47.47
    ...    AND    Set Test Variable    ${VM_WITH_PANO_USR}    ute
    ...    AND    Set Test Variable    ${VM_WITH_PANO_PASSWD}    UTE.debian12
    ...    AND    PM__PPM_File_Transfer_To_ONAP.TC Setup
    ...    AND    Modify Resource Search Order    PM__PPM_File_Transfer_To_ONAP
    ...    AND    Set Library Search Order    PM__PPM_File_Transfer_To_ONAP
    TC__PM__PPM_File_Transfer_To_ONAP
    [Teardown]    Run Keywords    PM__PPM_File_Transfer_To_ONAP.TC Teardown
    ...    AND    Restore Resource Search Order


PM__PPM_File_Transfer_To_Mantaray
    [Tags]     QC_255762
    [Setup]    Run Keywords
    ...    PM__PPM_File_Transfer_To_Mantaray.TC Setup
    ...    AND    Modify Resource Search Order    PM__PPM_File_Transfer_To_Mantaray
    ...    AND    Set Library Search Order    PM__PPM_File_Transfer_To_Mantaray
    TC__PM__PPM_File_Transfer_To_Mantaray
    [Teardown]    Run Keywords    PM__PPM_File_Transfer_To_Mantaray.TC Teardown
    ...    AND    Restore Resource Search Order


*** Keywords ***

Map BuildShareTimi01
    Run  sudo mkdir -p /media/BuildShareTimi01
    Run  sudo chown ute:ute /media/BuildShareTimi01
    ${sudo_command}  Catenate  sudo sh -c "echo //10.5.16.78/BuildShareTimi01 /media/BuildShareTimi01/
    ...  cifs _netdev,noperm,username=userbuild,nosuid,noexec,password=Aikon_123456*8 0 0 >>/etc/fstab"
    Run  ${sudo_command}
    Run  sudo mount -a


