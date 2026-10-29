*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SBTS24R2  SRAN  CLOUD_SRAN_NLWG_10745_ASIB_ABIA_ABIN_ABIO_AZNB_AEHC_FXDB  STATE_SKIP_AGENT
Library    XML  use_lxml=True
Suite Setup     Run Keywords  Set Library Search Order  ca_WebEM_general  ca_WebEM_mobile  AND  Map BuildShareTimi01   

Resource    ../../WebEM/test_resources/WebEM__Admin_CLI_getRmodMeasurementsById.robot
Resource    ../../WebEM/test_resources/WebEM__Mobile_Simplified_Site_View_Performing_Operations_on_Selected_Units.robot


*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1745
${COLLECT_SNAPSHOT_FLAG}    always


*** Test Cases ***
[1]WebEM__Mobile_Simplified_Site_View_Performing_Operations_on_Selected_Units
    [Tags]  QC_785457					 
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    1200
    
    ...    AND    WebEM__Mobile_Simplified_Site_View_Performing_Operations_on_Selected_Units.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Mobile_Simplified_Site_View_Performing_Operations_on_Selected_Units
    TC__WebEM__Mobile_Simplified_Site_View_Performing_Operations_on_Selected_Units
    [Teardown]    Run Keywords    WebEM__Mobile_Simplified_Site_View_Performing_Operations_on_Selected_Units.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Admin_CLI_getRmodMeasurementsById
    [Tags]  QC_785458					 
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    
    ...    AND    WebEM__Admin_CLI_getRmodMeasurementsById.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Admin_CLI_getRmodMeasurementsById
    TC__WebEM__Admin_CLI_getRmodMeasurementsById
    [Teardown]    Run Keywords    WebEM__Admin_CLI_getRmodMeasurementsById.TC Teardown
    ...    AND    Restore Resource Search Order


*** Keywords ***

Map BuildShareTimi01
    Run  sudo mkdir -p /media/BuildShareTimi01
    Run  sudo chown ute:ute /media/BuildShareTimi01
    ${sh_command}  Catenate  sudo sh -c "echo //10.5.16.78/BuildShareTimi01 /media/BuildShareTimi01/
    ...                      cifs _netdev,noperm,username=userbuild,nosuid,noexec,password=Aikon_123456*8 0 0 >>/etc/fstab"
    Run  ${sh_command}
    Run  sudo mount -a
