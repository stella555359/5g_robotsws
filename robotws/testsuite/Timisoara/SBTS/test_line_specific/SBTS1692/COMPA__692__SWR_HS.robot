*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SRAN  CLOUD_SRAN_LWG_10692_1ASIA_2ABIA_1ASIA_1ABIA_1FRGU_1FXDB_1FXEB_1AZNB_2AZNA  STATE_COMMISSIONED
Library           XML  use_lxml=True

Resource    ../../CIT/test_resources/SWM__SW_download_and_activation__SBTS_to_SBTS.robot
Resource    ../../CIT/test_resources/SWM__SCF_validation_errors_check.robot
Resource    ../../COMPA/test_resources/Hot_SWAP.robot
Resource    ../../CIT/test_resources/LOGS__Snapshot.robot

Suite Setup   Run keywords    Map BuildShareTimi01  AND  Map BuildShareTimi01 on SLAVE

*** Variables ***
${ENB_BUILD}    SBTS00_ENB_9999_220510_000009
${Target_SW_dir}  /home/ute/TARGET_SW

*** Test Cases ***


[1]Automated__SWM__SW_download_and_activation__SBTS_to_SBTS
    [Tags]    STOPONFAIL
    [Setup]    Run Keywords    Set Test Variable    ${Target SW name}    ${None}
    ...    AND    Set Test Variable    ${Target SW dir}    ${Target_SW_dir} 
    ...    AND    Set Test Variable    ${SW Update Timeout}    3600
    ...    AND    Set Test Variable    ${Ping loss timeout}    900
    ...    AND    Set Test Variable    ${Ping regain timeout}    1900
    ...    AND    Set Test Variable    ${onAir Check Number}    150
    ...    AND    Set Test Variable    ${First Cell On Air Timeout}    35
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

[1]Automated__SWM__SCF_validation_errors_check
    [Timeout]    14401
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${SKIP_PARAM_RELATION_ERRORS}    ${TRUE}
    ...    AND    SWM__SCF_validation_errors_check.TC Setup
    ...    AND    Modify Resource Search Order    SWM__SCF_validation_errors_check
    TC__SWM__SCF_validation_errors_check
    [Teardown]    Run Keywords    SWM__SCF_validation_errors_check.TC Teardown
    ...    AND    Restore Resource Search Order
	
	
[1]Automated__Hot_SWAP_Slave_SBTS
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${sw_package_path}    ${Target_SW_dir}
    ...    AND    Set Test Variable    ${SW Update Timeout}    1000
    ...    AND    Set Test Variable    ${ping_loss_timeout}    240}
    ...    AND    Set Test Variable    ${ping_regain_timeout}    600
    ...    AND    Set Test Variable    ${restore_timeout}     240
    ...    AND    Set Test Variable    ${esm_ip}   192.168.255.119
    ...    AND    Set Test Variable    ${MSM_ip}   192.168.255.129
    ...    AND    Set Test Variable    ${FAULT_4001_TIMEOUT}   3
    ...    AND    Set Test Variable    ${TARGET_SW_PATTERN}    SBTS
    ...    AND    Set Test Variable    ${SW_DIRECTORY}    /media/BuildShareTimi01/Testare/dcozma/FDSW/ASIA
    ...    AND    Set Test Variable    ${SWCONFIG_PATH}    
    ...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1692/swconfig/swconfig.txt
    ...    AND    Set Test Variable    ${Make Additional Checks}    	${FALSE}
    ...    AND    Set Test Variable    	${Additional Checks Number}    5
    ...    AND    Set Test Variable    	${Sleep interval}   1 min
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    ...    AND    Hot_SWAP.TC Setup
    ...    AND    Modify Resource Search Order    Hot_SWAP_Slave_SBTS
    TC__Hot_SWAP_Slave_SBTS
    [Teardown]    Run Keywords    Hot_SWAP.TC Teardown
    ...    AND    Restore Resource Search Order


*** Keywords ***

Map BuildShareTimi01
    Run  sudo mkdir -p /media/BuildShareTimi01
    Run  sudo chown ute:ute /media/BuildShareTimi01
    ${sudo_command}  Catenate  SEPARATOR=  sudo sh -c "echo //10.5.16.78/BuildShareTimi01 /media/BuildShareTimi01/ cifs _netdev,
    ...  noperm,username=userbuild,,nosuid,noexec,password=Aikon_123456*8 0 0 >>/etc/fstab"
    Run  ${sudo_command}
    Run  sudo mount -a
    Run  sudo cp -r /home/ute/testline_configuration/10_18_UTESRANCLOUD1692 /home/ute/

Map BuildShareTimi01 on SLAVE
    Run  ssh ute@10.5.20.54
    Run  sudo mkdir -p /media/BuildShareTimi01
    Run  sudo chown ute:ute /media/BuildShareTimi01
    ${sudo_command}  Catenate  SEPARATOR=  sudo sh -c "echo //10.5.16.78/BuildShareTimi01 /media/BuildShareTimi01/ cifs _netdev,
    ...  noperm,username=userbuild,,nosuid,noexec,password=Aikon_123456*8 0 0 >>/etc/fstab"
    Run  ${sudo_command}
    Run  sudo mount -a
    Run  exit

