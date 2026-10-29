*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SBTS00  SRAN  CLOUD_SRAN_L_10470_1ASIA_3ABIA_2FXED_1FXED_3FRGU_2FXDB_1FRMF 
Library           XML  use_lxml=True

Resource    ../../FM/test_resources/FM__link_break_Abis_long.robot
Resource    ../../FM/test_resources/FM__link_break_IuB_CNBAP_short.robot
Resource    ../../FM/test_resources/FM__link_break_IuB_long.robot
Resource    ../../FM/test_resources/FM__link_break_IuB_short.robot
Resource    ../../FM/test_resources/FM__link_break_IuB_DNBAP_short.robot
Resource    ../../FM/test_resources/FM__link_break_IuB_startup.robot
Resource    ../../FM/test_resources/FM__link_break_SBTS_long.robot
Resource    ../../FM/test_resources/FM__Iub_CNBAP_link_break.robot
Resource    ../../FM/test_resources/FM__Iub_DNBAP_link_break.robot
Resource    ../../CIT/test_resources/SWM__SCF_validation_errors_check.robot

Suite Setup   Run keywords    Map BuildShareTimi01

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${ENB_BUILD}    SBTS00_ENB_9999_211207_000006
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1470
@{GSMVlan}            ${251}  ${252}
${WCDMAVlan}          ${454}
${LTEVlan}            ${451}
${Switch_IP}          10.255.10.108
${Switch_type}        Nokia_Nuage
${INTERFACE_TYPE}     GigabitEthernet
${INTERFACE_ID}       15
${Switch_USER}        AutoUser
${Switch_PASSWORD}    AutoPass123$
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1470

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

[1]Automated__FM__link_break_Abis_long
    [Tags]  QC_654776
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    FM__link_break_Abis_long.TC Setup
    ...    AND    Modify Resource Search Order    FM__link_break_Abis_long
    TC__FM__link_break_Abis_long
    [Teardown]    Run Keywords    FM__link_break_Abis_long.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__link_break_IuB_CNBAP_short
    [Tags]  QC_654780
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${NUMBER_OF_LOOPS}    10

    ...    AND    FM__link_break_IuB_CNBAP_short.TC Setup
    ...    AND    Modify Resource Search Order    FM__link_break_IuB_CNBAP_short
    TC__FM__link_break_IuB_CNBAP_short
    [Teardown]    Run Keywords    FM__link_break_IuB_CNBAP_short.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__link_break_IuB_CNBAP
    [Tags]  QC_654779
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${NUMBER_OF_LOOPS}    1

    ...    AND    FM__Iub_CNBAP_link_break.TC Setup
    ...    AND    Modify Resource Search Order    FM__Iub_CNBAP_link_break
    TC__FM__Iub_CNBAP_link_break
    [Teardown]    Run Keywords    FM__Iub_CNBAP_link_break.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__link_break_IuB_DNBAP
    [Tags]  QC_654781
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${NUMBER_OF_LOOPS}    1

    ...    AND    FM__Iub_DNBAP_link_break.TC Setup
    ...    AND    Modify Resource Search Order    FM__Iub_DNBAP_link_break
    TC__FM__Iub_DNBAP_link_break
    [Teardown]    Run Keywords    FM__Iub_DNBAP_link_break.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__link_break_IuB_long
    [Tags]  QC_654783
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    FM__link_break_IuB_long.TC Setup
    ...    AND    Modify Resource Search Order    FM__link_break_IuB_long
    TC__FM__link_break_IuB_long
    [Teardown]    Run Keywords    FM__link_break_IuB_long.TC Teardown
    ...    AND    Restore Resource Search Order



[1]Automated__FM__link_break_IuB_short
    [Tags]  QC_663978
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${NUMBER_OF_LOOPS}    3

    ...    AND    FM__link_break_IuB_short.TC Setup
    ...    AND    Modify Resource Search Order    FM__link_break_IuB_short
    TC__FM__link_break_IuB_short
    [Teardown]    Run Keywords    FM__link_break_IuB_short.TC Teardown
    ...    AND    Restore Resource Search Order



[1]Automated__FM__link_break_IuB_DNBAP_short
    [Tags]  QC_654782
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${NUMBER_OF_LOOPS}    10

    ...    AND    FM__link_break_IuB_DNBAP_short.TC Setup
    ...    AND    Modify Resource Search Order    FM__link_break_IuB_DNBAP_short
    TC__FM__link_break_IuB_DNBAP_short
    [Teardown]    Run Keywords    FM__link_break_IuB_DNBAP_short.TC Teardown
    ...    AND    Restore Resource Search Order



[1]Automated__FM__link_break_IuB_startup
    [Tags]  QC_654784
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Timer}    600

    ...    AND    FM__link_break_IuB_startup.TC Setup
    ...    AND    Modify Resource Search Order    FM__link_break_IuB_startup
    TC__FM__link_break_IuB_startup
    [Teardown]    Run Keywords    FM__link_break_IuB_startup.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__link_break_SBTS_long
    [Tags]  QC_663977
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    FM__link_break_SBTS_long.TC Setup
    ...    AND    Modify Resource Search Order    FM__link_break_SBTS_long
    TC__FM__link_break_SBTS_long
    [Teardown]    Run Keywords    FM__link_break_SBTS_long.TC Teardown
    ...    AND    Restore Resource Search Order


*** Keywords ***

Map BuildShareTimi01
    Run  sudo mkdir -p /media/BuildShareTimi01
    Run  sudo chown ute:ute /media/BuildShareTimi01
    ${sudo_command}  Catenate  SEPARATOR=  sudo sh -c "echo //10.5.16.78/BuildShareTimi01 /media/BuildShareTimi01/ cifs _netdev,
    ...  noperm,username=userbuild,,nosuid,noexec,password=Aikon_123456*8 0 0 >>/etc/fstab"
    Run  ${sudo_command}
    Run  sudo mount -a
    Run  sudo cp -r /home/ute/testline_configuration/10_18_UTESRANCLOUD1470 /home/ute/
	
