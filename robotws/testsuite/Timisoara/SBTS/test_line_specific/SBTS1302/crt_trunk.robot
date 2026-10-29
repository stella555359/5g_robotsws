*** Settings ***
Documentation  This is crt_trunk suite
Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SBTS00  SRAN  CLOUD_SRAN_NL_10302_1ASOE_1AHEGA_1ARGA  STATE_SKIP_AGENT
Library    XML  use_lxml=True
Suite Setup    Run Keywords  Set Library Search Order  ca_WebEM_general  ca_WebEM_mobile  AND  Map BuildShareTimi01

Resource    ../../WebEM/test_resources/WebEM__Activation_deactivation_fault_6506_EFaultId_SsdLogStorageOverdrawAI.robot
Resource    ../../WebEM/test_resources/WebEM__Mobile_Simplified_Site_View_for_ASOE.robot
Resource    ../../WebEM/test_resources/WebEM__RAD_debug_parameters.robot
Resource    ../../WebEM/test_resources/WebEM__LTEL2CellConfigurationCollector_script.robot
Resource    ../../FM/test_resources/FM__FHNET_reset_counter_exceeded.robot


*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1302
${COLLECT_SNAPSHOT_FLAG}    always


*** Test Cases ***
[1]WebEM__RAD_debug_parameters
	[Tags]  QC_281493
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__RAD_debug_parameters.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__RAD_debug_parameters
    TC__WebEM__RAD_debug_parameters
    [Teardown]    Run Keywords    WebEM__RAD_debug_parameters.TC Teardown
    ...    AND    Restore Resource Search Order


*** Keywords ***

Map BuildShareTimi01
    Run  sudo mkdir -p /media/BuildShareTimi01
    Run  sudo chown ute:ute /media/BuildShareTimi01
    ${sh_command}  Catenate  sudo sh -c "echo //10.5.16.78/BuildShareTimi01 /media/BuildShareTimi01/
    ...                      cifs _netdev,noperm,username=userbuild,nosuid,noexec,password=Aikon_123456*8 0 0 >>/etc/fstab"
    Run  ${sh_command}
    Run  sudo mount -a