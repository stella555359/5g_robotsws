*** Settings ***
Documentation
...    Author: Szlovak Monika (monika.szlovak@nokia.com)
...    Maintainer: Szlovak Monika (monika.szlovak@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description: CB006577

Library        String
Library        Telnet
Library        OperatingSystem
Library        Process

Resource    ../../resources/admin.robot
Resource    ../../resources/pretest_posttest.robot
Resource    ../../resources/system.robot

*** Variables ***
${LOGGING_ENB_SYSLOG}=           True
${LOGGING_IPHY_SYSLOG}=          True
${LOGGING_ADMIN_LOG}=            True
${LOGGING_ADMIN_INFOMODEL_LOG}=  True
${LOGGING_EMSSIM_LOG}=           True

${path_actCli_feature}=         /MRBTS-1/RAT-1/BTS_L-*/BTS_CONF-1/NP-*/SCF-*/MRBTS_A-*/MNL_A-1/MNLENT_A-1/FEATCADM_A-1
${ADMIN_CLI_scripts_location}=    ${CURDIR}/../configurations

${delta_activate_actCli}=               ${CURDIR}/../configurations/Delta_Activate_ActCli.json
${delta_deactivate_actCli}=             ${CURDIR}/../configurations/Delta_Deactivate_ActCli.json

${SW_DESTINATION}     /home/ute
#${lterel_disc}=   http://lterel.es-si-s3-z2.eecloud.nsn-net.net/build
${lterel_disc}=   https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build
${sw_address}=    http://files.ute.nsn-rdnet.net/builds/enb/base

*** Keywords ***
4_WebEM_CLI_shall_support_command_getRadParam_with_DCC_user
    Log to console  getRadParam test
    ${result}=  Run  cd ${SW_DESTINATION}/ADMIN_CLI/;sh getRadParameters.sh
    Should contain  ${result}   "errorCode":0
    Sleep  10
    ${result_txt}=  OperatingSystem.Get File    /home/ute/ADMIN_CLI/getRadParameters.txt
    Should contain  ${result_txt}  "requestStatus":"completed"
    Log to console  Returned "requestStatus":"completed"
    Should contain  ${result_txt}  "errorCode":0
    Log to console  Returned "errorCode":0
    Sleep  10

8_WebEM_CLI_shall_support_command_startIPCaptureFile_with_DCC_user
    Log to console  startIPCaptureFile test
    ${result}=  Run  cd ${SW_DESTINATION}/ADMIN_CLI/;sh startIPCaptureFile.sh
    Should contain  ${result}   "errorCode":0
    Sleep  10
    ${result_txt}=  OperatingSystem.Get File    /home/ute/ADMIN_CLI/startIPCaptureFile.txt
    Should contain  ${result_txt}  "requestStatus":"completed"
    Log to console  Returned "requestStatus":"completed"
    Should contain  ${result_txt}  "errorCode":0
    Log to console  Returned "errorCode":0
    Sleep  10

13_WebEM_CLI_shall_support_command_checkAntennas_with_DCC_user
    Log to console  checkAntennas test
    ${result}=  Run  cd ${SW_DESTINATION}/ADMIN_CLI/;sh checkAntennas.sh
    Should contain  ${result}   "errorCode":0
    Sleep  10
    ${result_txt}=  OperatingSystem.Get File    /home/ute/ADMIN_CLI/checkAntennas.txt
    Should contain  ${result_txt}  "requestStatus":"completed"
    Log to console  Returned "requestStatus":"completed"
    Should contain  ${result_txt}  "errorCode":0
    Log to console  Returned "errorCode":0
    Sleep  10

15_WebEM_CLI_shall_support_command_checkFans_with_DCC_user
    Log to console  checkFans test
    ${result}=  Run  cd ${SW_DESTINATION}/ADMIN_CLI/;sh checkFans.sh
    Should contain  ${result}   "errorCode":0
    Sleep  10
    ${result_txt}=  OperatingSystem.Get File    /home/ute/ADMIN_CLI/checkFans.txt
    Should contain  ${result_txt}  "requestStatus":"completed"
    Log to console  Returned "requestStatus":"completed"
    Should contain  ${result_txt}  "errorCode":0
    Log to console  Returned "errorCode":0
    Sleep  10

16_WebEM_CLI_shall_support_command_checkHw_with_DCC_user
    Log to console  checkHw test
    ${result}=  Run  cd ${SW_DESTINATION}/ADMIN_CLI/;sh checkHw.sh
    Should contain  ${result}   "errorCode":0
    Sleep  10
    ${result_txt}=  OperatingSystem.Get File    /home/ute/ADMIN_CLI/checkHw.txt
    Should contain  ${result_txt}  "requestStatus":"completed"
    Log to console  Returned "requestStatus":"completed"
    Should contain  ${result_txt}  "errorCode":0
    Log to console  Returned "errorCode":0
    Sleep  10

22_WebEM_CLI_shall_support_command_getBasebandModuleList_with_DCC_user
    Log to console  getBasebandModuleList test
    ${result}=  Run  cd ${SW_DESTINATION}/ADMIN_CLI/;sh getBasebandModuleList.sh
    Should contain  ${result}   "errorCode":0
    Sleep  10
    ${result_txt}=  OperatingSystem.Get File    /home/ute/ADMIN_CLI/getBasebandModuleList.txt
    Should contain  ${result_txt}  "requestStatus": "completed"
    Log to console  Returned "requestStatus": "completed"
    Should contain  ${result_txt}  "errorCode": 0
    Log to console  Returned "errorCode": 0
    Should contain  ${result_txt}  "operationalState"
    Log to console  "operationalState" SUCCCESS
    Should contain  ${result_txt}  "administrativeState"
    Log to console  "administrativeState" SUCCCESS
    Should contain  ${result_txt}  "usageState"
    Log to console  "usageState" SUCCCESS
    Should contain  ${result_txt}  "proceduralStatus"
    Log to console  "proceduralStatus" SUCCCESS
    Sleep  10

24_WebEM_CLI_shall_support_command_getCellList_with_DCC_user
    Log to console  getCellList test
    Blocking cell
    Sleep   10
    ${result}=  Run  cd ${SW_DESTINATION}/ADMIN_CLI/;sh getCellList.sh
    run keyword and continue on failure   Should contain  ${result}   "errorCode":0
    Unblocking cell
    Sleep  10
    ${result_txt}=  OperatingSystem.Get File    /home/ute/ADMIN_CLI/getCellList.txt
    Should contain  ${result_txt}  "requestStatus": "completed"
    Log to console  Returned "requestStatus": "completed"
    Should contain  ${result_txt}  "errorCode": 0
    Log to console  Returned "errorCode": 0
    Should contain  ${result_txt}  "administrativeState"
    Log to console  "administrativeState" SUCCCESS
    Should contain  ${result_txt}  "availabilityStatus"
    Log to console  "availabilityStatus" SUCCCESS
    Should contain  ${result_txt}  "operationalState"
    Log to console  "operationalState" SUCCCESS
    Should contain  ${result_txt}  "usageState"
    Log to console  "usageState" SUCCCESS
    Should contain  ${result_txt}  "blockingState"
    Log to console  "blockingState" SUCCCESS
    Sleep  10

26_WebEM_CLI_shall_support_command_getRmodMeasurementsList_with_DCC_user
    Log to console  getRmodMeasurementsList test
    ${result}=  Run  cd ${SW_DESTINATION}/ADMIN_CLI/;sh getRmodMeasurementsList.sh
    Should contain  ${result}   "errorCode":0
    Sleep  10
    ${result_txt}=  OperatingSystem.Get File    /home/ute/ADMIN_CLI/getRmodMeasurementsList.txt
    Should contain  ${result_txt}  "requestStatus": "completed"
    Log to console  Returned "requestStatus": "completed"
    Should contain  ${result_txt}  "errorCode": 0
    Log to console  Returned "errorCode": 0
    Should contain  ${result_txt}  "measuredAntennaPathDelays"
    Log to console  "measuredAntennaPathDelays" SUCCCESS
    Should contain  ${result_txt}  "powerMeasurements"
    Log to console  "powerMeasurements" SUCCCESS
    Should contain  ${result_txt}  "vswr"
    Log to console  "vswr" SUCCCESS
    Should contain  ${result_txt}  "transmitPowerForAllTxPorts"
    Log to console  "transmitPowerForAllTxPorts" SUCCCESS
    Sleep  10

28_WebEM_CLI_shall_support_command_getSystemModuleList_with_DCC_user
    Log to console  getSystemModuleList test
    ${result}=  Run  cd ${SW_DESTINATION}/ADMIN_CLI/;sh getSystemModuleList.sh
    Should contain  ${result}   "errorCode":0
    Sleep  10
    ${result_txt}=  OperatingSystem.Get File    /home/ute/ADMIN_CLI/getSystemModuleList.txt
    Should contain  ${result_txt}  "requestStatus": "completed"
    Log to console  Returned "requestStatus": "completed"
    Should contain  ${result_txt}  "errorCode": 0
    Log to console  Returned "errorCode": 0
    Should contain  ${result_txt}  "systemModules"
    Log to console  "systemModules" SUCCCESS
    Should contain  ${result_txt}  "administrativeState"
    Log to console  "administrativeState" SUCCCESS
    Should contain  ${result_txt}  "operationalState"
    Log to console  "operationalState" SUCCCESS
    Should contain  ${result_txt}  "usageState"
    Log to console  "usageState" SUCCCESS
    Should contain  ${result_txt}  "proceduralStatus"
    Log to console  "proceduralStatus" SUCCCESS
    Sleep  10

38_WebEM_CLI_shall_support_command_reset_with_DCC_user
    Log to console  reset test
    ${result}=  Run  cd ${SW_DESTINATION}/ADMIN_CLI/;sh reset.sh
    Should contain  ${result}   "errorCode":0
    Sleep  10
    ${result_txt}=  OperatingSystem.Get File    /home/ute/ADMIN_CLI/reset.txt
    Should contain  ${result_txt}  "requestStatus": "ongoing"
    Log to console  Returned "requestStatus": "ongoing"
    Should contain  ${result_txt}  "requestStatus": "completed"
    Log to console  Returned "requestStatus": "completed"
    Should contain  ${result_txt}  "errorCode": 0
    Log to console  Returned "errorCode": 0
    Wait Until Keyword Succeeds   900   30   ADMIN INFOMODEL Check If BTS Is Commissioned
    Wait Until Keyword Succeeds   900   30   ADMIN INFOMODEL Check If BTS Is OnAir

39_WebEM_CLI_shall_support_command_softwareUpdate_with_DCC_user
    Log to console  softwareUpdate test
    Get active and passive sw versions before sw update
    Download Software T1 Package
    ${result}=  Run  cd ${SW_DESTINATION}/ADMIN_CLI/;sh softwareUpdate.sh
    Should contain  ${result}   "errorCode":0
    Sleep  10
    ${result_txt}=  OperatingSystem.Get File    /home/ute/ADMIN_CLI/softwareUpdate.txt
    Should contain  ${result_txt}  "requestStatus":"ongoing"
    Log to console  Returned "requestStatus":"ongoing"
    Should contain  ${result_txt}  "requestStatus":"completed"
    Log to console  Returned "requestStatus":"completed"
    Should contain  ${result_txt}  "errorCode":0
    Log to console  Returned "errorCode":0
    Wait Until Keyword Succeeds   900   30   ADMIN INFOMODEL Check If BTS Is Commissioned
    Wait Until Keyword Succeeds   2700   30   ADMIN INFOMODEL Check If BTS Is OnAir
    Sleep   10
    Get active and passive sw versions after sw update
    run keyword and continue on failure  Check if software was updated
    ...     post_update_sw=${post_update_active_sw}  pre_update_sw=${pre_update_active_sw}

45_WebEM_CLI_shall_support_command_getNmsState_with_DCC_user
    Log to console  getNmsState test
    ${result}=  Run  cd ${SW_DESTINATION}/ADMIN_CLI/;sh getNmsState.sh
    Should contain  ${result}   "errorCode":0
    Sleep  10
    ${result_txt}=  OperatingSystem.Get File    /home/ute/ADMIN_CLI/getNmsState.txt
    Should contain  ${result_txt}  "requestStatus":"completed"
    Log to console  Returned "requestStatus":"completed"
    Should contain  ${result_txt}  "errorCode":0
    Log to console  Returned "errorCode":0
    Sleep  10

46_WebEM_CLI_shall_support_command_getAllTroubleshootingScripts_DCC_user
    Log to console  getAllTroubleshootingScripts test
    ${result}=  Run  cd ${SW_DESTINATION}/ADMIN_CLI/;sh getAllTroubleshootingScripts.sh
    Should contain  ${result}   "errorCode":0
    Sleep  10
    ${result_txt}=  OperatingSystem.Get File    /home/ute/ADMIN_CLI/getAllTroubleshootingScripts.txt
    Should contain  ${result_txt}  "requestStatus":"ongoing"
    Log to console  Returned "requestStatus":"ongoing"
    Should contain  ${result_txt}  "requestStatus":"completed"
    Log to console  Returned "requestStatus":"completed"
    Should contain  ${result_txt}  "errorCode":0
    Log to console  Returned "errorCode":0
    Sleep  10

52_WebEM_CLI_shall_support_command_getRADDebugParameters_with_DCC_user
    Log to console  getRADDebugParameters test
    ${result}=  Run  cd ${SW_DESTINATION}/ADMIN_CLI/;sh getRADDebugParameters.sh
    Should contain  ${result}   "errorCode":0
    Sleep  10
    ${result_txt}=  OperatingSystem.Get File    /home/ute/ADMIN_CLI/getRADDebugParameters.txt
    Should contain  ${result_txt}  "requestStatus":"completed"
    Log to console  Returned "requestStatus":"completed"
    Should contain  ${result_txt}  "errorCode":0
    Log to console  Returned "errorCode":0
    Sleep  10

56_WebEM_CLI_shall_support_command_resetAllRADDebugParameters_with_DCC_user
    Log to console  resetAllRADDebugParameters test
    ${result}=  Run  cd ${SW_DESTINATION}/ADMIN_CLI/;sh resetAllRADDebugParameters.sh
    Should contain  ${result}   "errorCode":0
    Sleep  10
    ${result_txt}=  OperatingSystem.Get File    /home/ute/ADMIN_CLI/resetAllRADDebugParameters.txt
    Should contain  ${result_txt}  "requestStatus":"completed"
    Log to console  Returned "requestStatus":"completed"
    Should contain  ${result_txt}  "errorCode":0
    Log to console  Returned "errorCode":0
    Sleep  10

#.........................................................................
ADMIN_CLI Suite Setup
    Download ADMIN_CLI package
    Transfer ADMIN_CLI scripts
    Activate CLI feature and DCC user

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
    Run Keyword If     ${fileExists} is False   Run  wget ${lterel_disc}/${release}/${build_ver}/${build_ver}_ADMIN_CLI.zip -nv -P ${SW_DESTINATION}
    ${fileExists}      Run Keyword and Return Status  OperatingSystem.File Should Exist   ${SW_DESTINATION}/${build_ver}_ADMIN_CLI.zip
    Should Be Equal As Strings  ${fileExists}  True
    Run  unzip -o ${SW_DESTINATION}/${build_ver}_ADMIN_CLI.zip -d ${SW_DESTINATION}/ADMIN_CLI
    Log to Console     Download completed
    [Return]           ${build_ver}_ADMIN_CLI.zip

Download Software T1 Package
    ${SW_Version}     ADMIN Get Sw Version
    ${is_TrunkBuild}=     Run Keyword and Return Status    Should Contain      ${SW_Version}      _9999_
    ${build_ver}=     Run keyword if
    ...           ${is_Trunk_Build}==True        Replace String Using Regexp    ${SW_Version}    ^SBTS[A-Za-z0-9]+_    SBTS00_
    ...  ELSE     Set variable   ${SW_Version}
    ${release}        Fetch from left   ${build_ver}  _ENB_
    Run  wget ${sw_address}/${build_ver}/${build_ver}_release_BTSSM_downloadable_testpackage_T1.zip -nv -P ${SW_DESTINATION}
    ${T1_package}    Run   ls ${SW_DESTINATION}/${build_ver}_release_BTSSM_downloadable_testpackage_T1.zip
    Run  cp ${T1_package} ${SW_DESTINATION}/ADMIN_CLI/T1_package.zip
    Sleep   30

Activate CLI feature and DCC user
    ADMIN Perform Delta Recommissioning                 ${delta_activate_actCli}
    ...                                                 skip_parameter_relation_errors=True

Deactivate CLI feature and DCC user
    ADMIN Perform Delta Recommissioning                 ${delta_deactivate_actCli}
    ...                                                 skip_parameter_relation_errors=True

Get active and passive sw versions before sw update
	PREPOST Create List Of Bts Parameters
    PREPOST Get Active And Passive Software Versions
    log to console   active sw: ${OUT_ACTIVE_SW}
    log to console   passive sw: ${OUT_PASSIVE_SW}
    ${pre_update_active_sw}=   Set variable   ${OUT_ACTIVE_SW}
    ${pre_update_passive_sw}=   Set variable   ${OUT_PASSIVE_SW}
	set test variable      ${pre_update_active_sw}
	set test variable	   ${pre_update_passive_sw}

Get active and passive sw versions after sw update
    PREPOST Create List Of Bts Parameters
    PREPOST Get Active And Passive Software Versions
    log to console   active sw: ${OUT_ACTIVE_SW}
    log to console   passive sw: ${OUT_PASSIVE_SW}
    ${post_update_active_sw}=   Set variable   ${OUT_ACTIVE_SW}
    ${post_update_passive_sw}=   Set variable   ${OUT_PASSIVE_SW}
	set test variable      ${post_update_active_sw}
	set test variable	   ${post_update_passive_sw}

Check if software was updated
    [Arguments]  ${post_update_sw}  ${pre_update_sw}
    Log To Console  Check if SW ${post_update_sw} is the same with ${pre_update_sw}
    Should Be True  '${post_update_sw}' != '${pre_update_sw}'
    ...  msg=The software has not updated.

ADMIN INFOMODEL Check If BTS Is Commissioned
    ${bts_statuses_response}=    taf.sbts.oam.coam.admin.Get Bts Info
    ${actual_value}=    Get From Dictionary
    ...    dictionary=${bts_statuses_response['status']}
    ...    key=proceduralState
    Should Be Equal
    ...    first=${actual_value}
    ...    second=Commissioned

Blocking cell
    Get LNCEL_R path
    taf.sbts.oam.coam.admin.Block    dist_name=${LNCEL_R_path_1}

Unblocking cell
	taf.sbts.oam.coam.admin.Unblock   dist_name=${LNCEL_R_path_1}

Get LNCEL_R path
    ${LNCEL_R_distname}    Get Object Distname From Class Name if List
    ...    class_name=LNCEL_R
    ${LNCEL_R_distname_1}=   get from list   ${LNCEL_R_distname}   0
    ${LNCEL_R_distname_2}=   get from list   ${LNCEL_R_distname}   1
    ${LNCEL_R_path_1}=   Set variable   ${LNCEL_R_distname_1}
    ${LNCEL_R_path_2}=   Set variable   ${LNCEL_R_distname_2}
    Set test variable   ${LNCEL_R_path_1}
    Set test variable   ${LNCEL_R_path_2}

Get Object Distname From Class Name
    [Arguments]    ${class_name}
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_list_of_objects_parameters_dict}    taf.sbts.oam.coam.admin.Get Managed Objects
    ...    class_name=${class_name}
    ...    timeout=${timeout}
    ...    connection=${alias}
    FOR    ${element}    IN    @{out_list_of_objects_parameters_dict}
        ${distName}    Get From Dictionary    ${element}    distName
    END
    [Return]    ${distName}

Get Object Distname From Class Name if List
    [Arguments]    ${class_name}
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_list_of_objects_parameters_dict}    taf.sbts.oam.coam.admin.Get Managed Objects
    ...    class_name=${class_name}
    ...    timeout=${timeout}
    ...    connection=${alias}
    @{distname_list}   create list
    FOR    ${element}    IN    @{out_list_of_objects_parameters_dict}
        ${distName}    Get From Dictionary    ${element}    distName
        append to list   ${distname_list}   ${distName}
    END
    [Return]    ${distName_list}
