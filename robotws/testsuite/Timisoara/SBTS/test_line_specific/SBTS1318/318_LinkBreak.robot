*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SBTS00  SRAN  CLOUD_SRAN_L_10318_1ASIB_1ABIA_1FRMF_1FXED_1ARGA  
Library           XML  use_lxml=True

Resource    ../../CIT/test_resources/SWM__SW_download_and_activation__SBTS_to_SBTS.robot
Resource    ../../FM/test_resources/FM__Link_break_GTPU.robot
Resource    ../../FM/test_resources/FM__link_break_X2_short.robot
Resource    ../../FM/test_resources/FM__link_break_X2_long.robot
Resource    ../../CIT/test_resources/SWM__SCF_validation_errors_check.robot
Resource    ../../FM/test_resources/FM__FSP_Lom_Fault_Service_crash.robot
Resource    ../../WebEM/test_resources/WebEM__LTEL2CellConfigurationCollector_script.robot

Suite Setup   Run keywords    Map BuildShareTimi01

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${LTEVlan}            ${451}
${Switch_IP}          10.255.10.108
${Switch_type}        Nokia_Nuage
${INTERFACE_TYPE}     GigabitEthernet
${INTERFACE_ID}       4
${Switch_USER}        AutoUser
${Switch_PASSWORD}    AutoPass123$
${REQUEST_SCF_SCOUT}    ${TRUE}
${ENB_BUILD}    SBTS00_ENB_9999_230827_000011
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1318
${QC_DOMAIN}=           MN_RAN
${QC_PROJECT}=          RAN_ST
${TEST_QC_ID}=  ${None}


*** Test Cases ***

[1]Automated__SWM__SCF_validation_errors_check
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${SKIP_PARAM_RELATION_ERRORS}    ${TRUE}
    
    ...    AND    Modify Resource Search Order    SWM__SCF_validation_errors_check
    ...    AND    SWM__SCF_validation_errors_check.TC Setup
    TC__SWM__SCF_validation_errors_check
    [Teardown]    Run Keywords    SWM__SCF_validation_errors_check.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset

[1]Automated__SWM__SW_download_and_activation__SBTS_to_SBTS
    [Tags]    STOPONFAIL
    [Setup]    Run Keywords    Set Test Variable    ${Target SW name}    ${None}
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/TARGET_SW
    ...    AND    Set Test Variable    ${SW Update Timeout}    3600
    ...    AND    Set Test Variable    ${Ping loss timeout}    900
    ...    AND    Set Test Variable    ${Ping regain timeout}    1900
    ...    AND    Set Test Variable    ${onAir Check Number}    150
    ...    AND    Set Test Variable    ${First Cell On Air Timeout}    35
    ...    AND    Set Test Variable    ${Ping stable timeout}    409
    ...    AND    Set Test Variable    ${Test Timeout}    120
    ...    AND    Modify Resource Search Order    SWM__SW_download_and_activation__SBTS_to_SBTS
    ...    AND    SWM__SW_download_and_activation__SBTS_to_SBTS.TC Setup

    Run  mkdir ${Target SW dir}
    Run  sudo chmod 777 ${Target SW dir} -R
    Run  wget files.ute.nsn-rdnet.net/builds/enb/base/${ENB_BUILD}/${ENB_BUILD}_release_BTSSM_downloadable.zip -P ${Target SW dir}
    [Timeout]    60 minutes
    TC__SWM__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]    Run Keywords    SWM__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order

[2]Automated__SWM__SCF_validation_errors_check
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${SKIP_PARAM_RELATION_ERRORS}    ${TRUE}
    
    ...    AND    Modify Resource Search Order    SWM__SCF_validation_errors_check
    ...    AND    SWM__SCF_validation_errors_check.TC Setup
    TC__SWM__SCF_validation_errors_check
    [Teardown]    Run Keywords    SWM__SCF_validation_errors_check.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset



[1]FM__Link_break_GTPU
    [Tags]  QC_650560
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    
    ...    AND    FM__Link_break_GTPU.TC Setup
    ...    AND    Modify Resource Search Order    FM__Link_break_GTPU
    TC__FM__Link_break_GTPU
    [Teardown]    Run Keywords    FM__Link_break_GTPU.TC Teardown
    ...    AND    Restore Resource Search Order


[1] Automated__FM__link_break_X2_short
    [Tags]  QC_650557
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${NUMBER_OF_LOOPS}    3

    ...    AND    FM__link_break_X2_short.TC Setup
    ...    AND    Modify Resource Search Order    FM__link_break_X2_short
    TC__FM__link_break_X2_short
    [Teardown]    Run Keywords    FM__link_break_X2_short.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__link_break_X2_long
    [Tags]  QC_650556
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    FM__link_break_X2_long.TC Setup
    ...    AND    Modify Resource Search Order    FM__link_break_X2_long
    TC__FM__link_break_X2_long
    [Teardown]    Run Keywords    FM__link_break_X2_long.TC Teardown
    ...    AND    Restore Resource Search Order
	
[1]WebEM__LTEL2CellConfigurationCollector_script
    [Tags]  QC_380768
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${COLLECTING_FILES_TIMEOUT}    600
    
    ...    AND    WebEM__LTEL2CellConfigurationCollector_script.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__LTEL2CellConfigurationCollector_script
    TC__WebEM__LTEL2CellConfigurationCollector_script
    [Teardown]    Run Keywords    WebEM__LTEL2CellConfigurationCollector_script.TC Teardown
    ...    AND    Restore Resource Search Order


[1]CNI-93958-C4_FM_FSP_LOM_Fault_service_crash_handling
    [Tags]  QC_583958
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ABIA
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    900
    
    ...    AND    FM__FSP_Lom_Fault_Service_crash.TC Setup
    ...    AND    Modify Resource Search Order    FM__FSP_Lom_Fault_Service_crash
    TC__FM__FSP_Lom_Fault_Service_crash
    [Teardown]    Run Keywords    FM__FSP_Lom_Fault_Service_crash.TC Teardown
    ...    AND    Restore Resource Search Order
	

*** Keywords ***

Map BuildShareTimi01
    Run  sudo mkdir -p /media/BuildShareTimi01
    Run  sudo chown ute:ute /media/BuildShareTimi01
    ${sudo_command}  Catenate  SEPARATOR=  sudo sh -c "echo //10.5.16.78/BuildShareTimi01 /media/BuildShareTimi01/ cifs _netdev,
    ...  noperm,username=userbuild,,nosuid,noexec,password=Aikon_123456*8 0 0 >>/etc/fstab"
    Run  ${sudo_command}
    Run  sudo mount -a
    Run  sudo cp -r /home/ute/testline_configuration/10_18_UTESRANCLOUD1318 /home/ute/
