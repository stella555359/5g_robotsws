*** Settings ***
Documentation
...    Author: Perecz Alexandru (alexandru.perecz@nokia.com)
...    Maintainer: Perecz Alexandru (alexandru.perecz@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description: CB008082
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
${ADMIN_CLI_scripts_location}=    ${CURDIR}/../configurations

${delta_enable_actGnssJammingSpoofing}=       ${CURDIR}/../configurations/Delta_Enable_actGnssJammingSpoofing.json
${delta_disable_actGnssJammingSpoofing}=     ${CURDIR}/../configurations/Delta_Disable_actGnssJammingSpoofing.json

${SW_DESTINATION}     /home/ute
${lterel_disc}=   http://lterel.es-si-s3-z2.eecloud.nsn-net.net/build
${URL_4G} =   http://lterel.es-si-s3-z2.eecloud.nsn-net.net/build
${URL_5G}=    https://artifactory-espoo1.int.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release

*** Keywords ***
ADMIN_CLI Suite Setup
    Download ADMIN_CLI package
    Transfer ADMIN_CLI scripts

ADMIN_CLI_getGpsInventoryList
    Enable JammingAndSpoofing feature
    Log to console  Feature Enabled
    ${result}=  Run  cd ${SW_DESTINATION}/ADMIN_CLI/;sh getGpsInventoryList.sh
    Should contain  ${result}   "errorCode":0
    Log to console  Returned "errorCode":0
    Sleep  30
    ${result_txt}=  OperatingSystem.Get File    /home/ute/ADMIN_CLI/GpsList.txt
    Should contain  ${result_txt}  "gnssTrustedLatitude"
    Log to console  "gnssTrustedLatitude" SUCCCESS
    Should contain  ${result_txt}  "gnssTrustedLongitude"
    Log to console  "gnssTrustedLongitude" SUCCCESS
    Disable JammingAndSpoofing feature
    Log to console  Feature Disabled

Enable JammingAndSpoofing feature
    ADMIN Perform Delta Recommissioning                 delta_file=${delta_enable_actGnssJammingSpoofing}
    ...                                                 skip_parameter_relation_errors=True

Disable JammingAndSpoofing feature
    ADMIN Perform Delta Recommissioning                 delta_file=${delta_disable_actGnssJammingSpoofing}
    ...                                                 skip_parameter_relation_errors=True

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

Download ADMIN_CLI Package
    [Documentation]    Kw download Common Trunk AdminCLI from disc e.g.:
    ...    https://lterel.es-si-s3-z4.eecloud.nsn-net.net/build/SBTS00/SBTS00_ENB_9999_210505_000001_ADMIN_CLI.zip
    ${SW_Version}     ADMIN Get Sw Version
    ${is_TrunkBuild}=     Run Keyword and Return Status    Should Contain      ${SW_Version}      _9999_
    ${build_ver}=     Run keyword if
    ...           ${is_Trunk_Build}==True        Replace String Using Regexp    ${SW_Version}    ^SBTS[A-Za-z0-9]+_    SBTS00_
    ...  ELSE     Set variable   ${SW_Version}
    ${release}        Fetch from left   ${build_ver}  _ENB_
    ${fileExists}      Run Keyword and Return Status  OperatingSystem.File Should Exist   ${SW_DESTINATION}/${build_ver}_ADMIN_CLI.zip
    Run Keyword If     ${fileExists} is False   Run  wget ${lterel_disc}/${release}/${build_ver}_ADMIN_CLI.zip -nv -P ${SW_DESTINATION}
    ${fileExists}      Run Keyword and Return Status  OperatingSystem.File Should Exist   ${SW_DESTINATION}/${build_ver}_ADMIN_CLI.zip
    Should Be Equal As Strings  ${fileExists}  True
    Run  unzip -o ${SW_DESTINATION}/${build_ver}_ADMIN_CLI.zip -d ${SW_DESTINATION}/ADMIN_CLI
    Log to Console     Download completed
    [Return]           ${build_ver}_ADMIN_CLI.zip
