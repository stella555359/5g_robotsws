*** Settings ***
Resource    ../../WebEM/test_resources/WebEM__Script_naming_rule.robot
Resource    ../../WebEM/test_resources/WebEM__Troubleshooting_scripts_menu.robot
Resource    ../../WebEM/test_resources/WebEM__Troubleshooting_scripts_cli.robot

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

	
[1]WebEM__Script_naming_rule
    [Tags]  QC_380771
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    
    ...    AND    WebEM__Script_naming_rule.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Script_naming_rule
    TC__WebEM__Script_naming_rule
    [Teardown]    Run Keywords    WebEM__Script_naming_rule.TC Teardown
    ...    AND    Restore Resource Search Order	


[1]WebEM__Troubleshooting_scripts_menu
    [Tags]  QC_380769
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${COLLECTING_FILES_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    600
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    300
    
    ...    AND    WebEM__Troubleshooting_scripts_menu.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Troubleshooting_scripts_menu
    TC__WebEM__Troubleshooting_scripts_menu
    [Teardown]    Run Keywords    WebEM__Troubleshooting_scripts_menu.TC Teardown
    ...    AND    Restore Resource Search Order
	
	
[1]WebEM__Troubleshooting_scripts_cli
    [Tags]  QC_380770
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${COLLECTING_FILES_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    600
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    300
    
    ...    AND    WebEM__Troubleshooting_scripts_cli.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Troubleshooting_scripts_cli
    TC__WebEM__Troubleshooting_scripts_cli
    [Teardown]    Run Keywords    WebEM__Troubleshooting_scripts_cli.TC Teardown
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
