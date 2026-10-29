*** Settings ***
Documentation
...  ASOG TEMP and ONAP feature

Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SRAN CLOUD_SRAN_N_10676_1ASOG_1AVQC STATE_COMMISSIONED
Library           XML  use_lxml=True


Resource    ../../ONAP/test_resources/PANO__5GC001104_Break_connection_to_ONAP_and_toggle_counters_format.robot
Resource    ../../PM/test_resources/PM__Check_RTPM_Via_EMSSIM.robot
Resource    ../../ONAP/test_resources/ONAP__5GC001556_3GPP_XML_measurement_file_enrichment.robot




Suite Setup   Run keywords   Set Library Search Order  coam   ute_admin   hran_frame_sbts_taf   hran_frame_sbts_siso   ca_CIT_general   ca_swm_general
...  AND  Map BuildShareTimi01


*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${ENB_BUILD}    SBTS00_ENB_9999_211207_000006
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1676
${SKIP_RU_POWER_CHECK}    ${TRUE}
${VM_WITH_PANO_IP}       10.5.47.47
${VM_WITH_PANO_USR}      ute
${VM_WITH_PANO_PASSWD}   UTE.debian12
${VES_PORT}              30510
${ADDITIONAL_IGNORED_ALARMS}  [['faultId', '4639', ' alarmId ', '7115']]
${TL_REPO_PATH}          /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1676/commissioning


${LTE_MEASUREMENT_PATH}=  SEPARATOR=
    ...  /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/PM/counters/SBTS19A__LTE_Counters_2019-07-01.csv

${LTE_ABBREVIATION_DICT_PATH}=  SEPARATOR=
    ...  /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/PM/counters/LTE_Abbreviations.csv



*** Test Cases ***

[1]Automated__PANO__5GC001104_Break_connection_to_ONAP_and_toggle_counters_format
    [Tags]     QC_300289
    [Setup]    Run Keywords    PANO__5GC001104_Break_connection_to_ONAP_and_toggle_counters_format.TC Setup
    ...    AND    Modify Resource Search Order    PANO__5GC001104_Break_connection_to_ONAP_and_toggle_counters_format
    ...    AND    Set Library Search Order    PANO__5GC001104_Break_connection_to_ONAP_and_toggle_counters_format
    [Timeout]    14400
    TC__PANO__5GC001104_Break_connection_to_ONAP_and_toggle_counters_format
    [Teardown]    Run Keywords    PANO__5GC001104_Break_connection_to_ONAP_and_toggle_counters_format.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__ONAP__5GC001556_3GPP_XML_measurement_file_enrichment
    [Tags]     QC_300291
    [Setup]    Run Keywords    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment.TC Setup
    ...    AND    Modify Resource Search Order    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment
    ...    AND    Set Library Search Order    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment
    [Timeout]    14400
    TC__ONAP__5GC001556_3GPP_XML_measurement_file_enrichment
    [Teardown]    Run Keywords    ONAP__5GC001556_3GPP_XML_measurement_file_enrichment.TC Teardown
    ...    AND    Restore Resource Search Order

PM__Check_RTPM_Via_EMSSIM
    [Tags]     QC_300290
    [Setup]  PM__Check_RTPM_Via_EMSSIM.TC Setup
    TC__PM__Check_RTPM_Via_EMSSIM
    [Teardown]  PM__Check_RTPM_Via_EMSSIM.TC Teardown




*** Keywords ***

Map BuildShareTimi01
    Run  sudo mkdir -p /media/BuildShareTimi01
    Run  sudo chown ute:ute /media/BuildShareTimi01
    ${sudo_command}  Catenate  sudo sh -c "echo //10.5.16.78/BuildShareTimi01 /media/BuildShareTimi01/
    ...  cifs _netdev,noperm,username=userbuild,nosuid,noexec,password=Aikon_123456*8 0 0 >>/etc/fstab"
    Run  ${sudo_command}
    Run  sudo mount -a
