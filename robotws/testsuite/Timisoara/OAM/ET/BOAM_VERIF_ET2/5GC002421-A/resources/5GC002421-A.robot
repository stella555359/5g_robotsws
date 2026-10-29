*** Settings ***
Documentation
...    Author: Madalin Budulan (madalin.budulan@nokia.com)
...    Maintainer: Madalin Budulan (madalin.budulan@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description:
...    Sample execution: /opt/ute/python/bin/pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_FMRECOV/5GC002421-A/general.robot

Library        String
Library        Telnet
Library        OperatingSystem
Library        Process

Resource    ../../resources/admin.robot
Resource    ../../resources/pretest_posttest.robot
Resource    ../../resources/system.robot
Resource    ../../resources/selenium.robot
#Resource    ../../resources/pdu.robot
Resource    ../../resources/fault_trigger.robot

*** Variables ***
${LOGGING_ENB_SYSLOG}=           True
${LOGGING_IPHY_SYSLOG}=          True
${LOGGING_ADMIN_LOG}=            True
${LOGGING_ADMIN_INFOMODEL_LOG}=  True
${LOGGING_EMSSIM_LOG}=           True

${path_actCli_feature}=         /MRBTS-1/RAT-1/BTS_L-*/BTS_CONF-1/NP-*/SCF-*/MRBTS_A-*/MNL_A-1/MNLENT_A-1/FEATCADM_A-1

${delta_activate_actCli}=       ${CURDIR}/../configurations/Delta_Activate_ActCli.json
${delta_deactivate_actCli}=     ${CURDIR}/../configurations/Delta_Deactivate_ActCli.json
#${getBtsInformation}=           ${EXECDIR}/testsuite/WMP/SOAM3/5G/5GC002421-A/resources/GET_BTS_INFORMATION_TC25.sh

#${ADMIN_CLI_scripts_location}=    ${EXECDIR}/testsuite/WMP/SOAM3/5G/5GC002421-A/resources
${ADMIN_CLI_scripts_location}=    ${CURDIR}/../configurations

${SW_DESTINATION}     /home/ute
${URL_4G} =   http://lterel.es-si-s3-z2.eecloud.nsn-net.net/build
${URL_5G}=    https://artifactory-espoo1.int.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release
#/0.836.1516/5G_0.836.1516_ADMIN_CLI.zip

*** Keywords ***
ADMIN_CLI Suite Setup
    Download ADMIN_CLI package
    Transfer ADMIN_CLI scripts

Operator tries to execute command with invalid command name
    Activate CLI feature
    log  run ErrorCode_2_TC_1.sh and check error code 2
    ${result}=  Run  ${SW_DESTINATION}/ADMIN_CLI/ErrorCode_2_TC_1.sh
    Should contain  ${result}   "errorCode":2
    Deactivate CLI feature

Operator tries to execute command with invalid additional parameter values
    Activate CLI feature
    log  run Error_code_3_TC_2.sh and check error code 3
    ${result}=  Run  ${SW_DESTINATION}/ADMIN_CLI/Error_code_3_TC_2.sh
    Should contain  ${result}   "errorCode":3
    Deactivate CLI feature

Operator tries to execute command with invalid credentials
    Activate CLI feature
    log  run Error_code_6_TC3.sh and check error code 6
    ${result}=  Run  ${SW_DESTINATION}/ADMIN_CLI/Error_code_6_TC3.sh
    Should contain  ${result}   "errorCode":6
    Deactivate CLI feature

BTS supports dedicated port for connection 3600
    Activate CLI feature
    log  run Port3600_TC_4.sh and check error code 0
    ${result}=  Run  ${SW_DESTINATION}/ADMIN_CLI/Port3600_TC_4.sh
    Should contain  ${result}   "errorCode":0
    Deactivate CLI feature

BTS supports dedicated port for connection 443
    Activate CLI feature
    log  run Port443_TC_5.sh and check error code 0
    ${result}=  Run  ${SW_DESTINATION}/ADMIN_CLI/Port443_TC_5.sh
    Should contain  ${result}   "errorCode":0
    Deactivate CLI feature

Connection with the BTS is detected and error code 4 - Site unreachable - is reported
    Activate CLI feature
    log  run Error_code_4_TC_7.sh and check error code 4
    ${result}=  Run  timeout 15 ${SW_DESTINATION}/ADMIN_CLI/Error_code_4_TC_7.sh
    Should contain  ${result}   "errorCode":4
    Deactivate CLI feature

Error code - License not available - is detected by CLI
    run keyword and ignore error  Deactivate CLI feature
    log  run GET_ACTIVE_ALARMS.sh and check error "License not available"
    ${result}=  Run  ${SW_DESTINATION}/ADMIN_CLI/GET_ACTIVE_ALARMS.sh
    Should contain  ${result}   "License not available","errorCode":9

WebEM CLI shall support command Commission
    Activate CLI feature
    log  run commision_TC_14.sh and check btsName changed to Alecu
    ${result}=  Run  ${SW_DESTINATION}/ADMIN_CLI/commision_TC_14.sh
    Should contain  ${result}   "errorCode":0
    ${result2}=  Run  ${SW_DESTINATION}/ADMIN_CLI/GET_BTS_INFORMATION_TC25.sh
    Should contain  ${result2}   "name":"Alecu"
    Deactivate CLI feature

WebEM CLI shall support command generate SCF
    Activate CLI feature
    log  run GENERATE_TC_24.sh and check error code 0 + verify scf.xml download
    ${result}=  Run  ${SW_DESTINATION}/ADMIN_CLI/GENERATE_TC_24.sh
    Should contain  ${result}   "errorCode": 0
    Should exist  ${EXECDIR}/scf.xml   #/home/ute/robotlte/scf.xml
    Deactivate CLI feature

WebEM CLI shall support command getBtsInformation
    Activate CLI feature
    log  run GET_BTS_INFORMATION_TC25.sh and check error code 0 + verify bts info
    ${result}=  Run  ${SW_DESTINATION}/ADMIN_CLI/GET_BTS_INFORMATION_TC25.sh
    Should contain  ${result}   "errorCode":0
    Should contain  ${result}   "mrbtsID":1
    Deactivate CLI feature

WebEM CLI shall support command recommission
    Activate CLI feature
    log  run recommision_TC29.sh and check error code 0 + recommissioned param
    ${result}=  Run  ${SW_DESTINATION}/ADMIN_CLI/recommision_TC29.sh
    Should contain  ${result}   "errorCode":0
    ${result2}=  Run  ${SW_DESTINATION}/ADMIN_CLI/GET_BTS_INFORMATION_TC25.sh
    Should contain  ${result2}   "name":"Alecu2"
    Deactivate CLI feature

Activate CLI feature
    ADMIN Perform Delta Recommissioning                 delta_file=${delta_activate_actCli}
    ...                                                 skip_parameter_relation_errors=True
#    ADMIN INFOMODEL Query infomodel  ${path_actCli_feature}  actCli=regex"true|True"  timeout=60
#    ADMIN INFOMODEL Check Parameter Value
#    ...    dist_name=${path_actCli_feature}
#    ...    dict_param=actCli
#    ...    value=regex"true|True"

Deactivate CLI feature
    ADMIN Perform Delta Recommissioning                 delta_file=${delta_deactivate_actCli}
    ...                                                 skip_parameter_relation_errors=True
#    ADMIN INFOMODEL Query infomodel  ${path_actCli_feature}  actCli=regex"false|False"  timeout=60
#    ADMIN INFOMODEL Check Parameter Value
#    ...    dist_name=${path_actCli_feature}
#    ...    dict_param=actCli
#    ...    value=regex"false|False"

Download ADMIN_CLI package
    Get SW load
	${software_type}=  Get software version type
	Set suite variable  ${software_type}
	Run Keyword If  '${software_type}'=='0000'  Download ADMIN CLI Trunk Load
	Run Keyword If  '${software_type}'=='0010'  Download ADMIN CLI 5G20B Load

Transfer ADMIN_CLI scripts
    Run  cp ${ADMIN_CLI_scripts_location}/* ${SW_DESTINATION}/ADMIN_CLI/
    Run  chmod 777 ${SW_DESTINATION}/ADMIN_CLI/*

Get software version type
    ${active_software}=    ADMIN Get Sw Version
    set suite variable  ${active_software}
    ${split_active_software}=    Split string          ${active_software}    separator=\_
    ${active_software_version_flag}=   Get from list         ${split_active_software}     2
    [Return]              ${active_software_version_flag}

Get SW load
	${active_sw}=  ADMIN Get Sw Version
    Log To Console  Active SW - '${active_sw}'
	set suite variable      ${active_sw}
	${split_active_sw}=    Split string   ${active_sw}    separator=\_
	${version}=   Get from list         ${split_active_sw}    4
	${CLI_version}=  Convert To Integer   ${version[:6]}
	set suite variable      ${CLI_version}

Download ADMIN CLI Trunk Load
    Run       mkdir ${SW_DESTINATION}
	Set suite variable  ${download_url}  ${URL_5G}/0.800.${CLI_version}/5G_0.800.${CLI_version}_ADMIN_CLI.zip
    run  wget ${download_url} -P ${SW_DESTINATION}/
    OperatingSystem.File should exist   path=${SW_DESTINATION}/5G_0.800.${CLI_version}_ADMIN_CLI.zip
    Run  unzip -o ${SW_DESTINATION}/5G_0.800.${CLI_version}_ADMIN_CLI.zip -d ${SW_DESTINATION}/ADMIN_CLI
    #Ex:  https://artifactory-espoo1.int.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release/0.836.1516/5G_0.836.1516_ADMIN_CLI.zip
    Log to console  Download completed

Download ADMIN CLI 5G20B Load
    Run       mkdir ${SW_DESTINATION}
    Set suite variable  ${download_url}  ${URL_5G}/10.1800.${CLI_version}/5G20B_10.1800.${CLI_version}_ADMIN_CLI.zip
    run  wget ${download_url} -P ${SW_DESTINATION}/
    OperatingSystem.File should exist   path=${SW_DESTINATION}/5G20B_10.1800.${CLI_version}_ADMIN_CLI.zip
    Run  unzip -o ${SW_DESTINATION}/5G20B_10.1800.${CLI_version}_ADMIN_CLI.zip -d ${SW_DESTINATION}/ADMIN_CLI
    Log to console  Download completed


