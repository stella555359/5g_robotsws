*** Settings ***
Documentation
...    Author: Madalin Budulan (madalin.budulan@nokia.com)
...    Maintainer: Zaharia Andreea-Oana (andreea-oana.zaharia@nokia.com)
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
Resource    ../../5GC001525-SA-TA/resources/keyword.robot

*** Variables ***
${LOGGING_ENB_SYSLOG}=           True
${LOGGING_IPHY_SYSLOG}=          True
${LOGGING_ADMIN_LOG}=            True
${LOGGING_ADMIN_INFOMODEL_LOG}=  True
${LOGGING_EMSSIM_LOG}=           True

${ADMIN_CLI_scripts_location}=    ${CURDIR}/../configurations

${SW_DESTINATION}     /home/ute

##########
${lterel_disc}=   http://lterel.es-si-s3-z2.eecloud.nsn-net.net/build
${jenkins_url}          http://files.ute.nsn-rdnet.net/builds/enb/base/
${TRUNK_VERSION}        SBTS23R2

#/0.836.1516/5G_0.836.1516_ADMIN_CLI.zip

*** Keywords ***
Prepare testline for CB007944
    log to console  Prepare testline
#    PREPOST Setup Admin
    Download testpackage
    Download ADMIN_CLI package
    Transfer dev_cli package from server
    Prepare test files
#    ADMIN Teardown Admin

CB007944_SW_Pre_check_No_available_disk_space_in_single_core_mode
    log to console  check bts connection is establish
    Check not uncommissioned state for BTS
    wait until keyword succeeds  500s  10s    ADMIN INFOMODEL Check If BTS Is Configured
    wait until keyword succeeds  240s  10s    ADMIN INFOMODEL Check if RMOD is in availabilityStatus Online
    log to console   check disk space availability status by running sh script
    Should Not Be Empty    ${SW_DESTINATION}/CB007944/
    Run  ls ${SW_DESTINATION}/CB007944/
    ${result}=  Run  /home/ute/CB007944/softwarePrecheckForLocal.sh
    OperatingSystem.File Should Exist    /home/ute/CB007944/outputFullCheck.txt
    ${result}=  Run  cat ${SW_DESTINATION}/CB007944/outputFullCheck.txt
    Should contain  ${result}   "feedback": "Enough space on passive partition"
    log to console  fill stb/temp partition with dummy files from active partition
    Create temp directory on bts standby partition and copy dummy files
    log to console   check disk space non-availability status by running sh script
    ${result}=  Run  /home/ute/CB007944/softwarePrecheckForLocal.sh
    OperatingSystem.File Should Exist    /home/ute/CB007944/outputFullCheck.txt
    ${result}=  Run  cat ${SW_DESTINATION}/CB007944/outputFullCheck.txt
    Should contain  ${result}   "feedback": "Not enough space on passive partition"
    log to console   get sw load and perform swr with error and check 30 fault
    Get active and passive sw versions before sw update
    run keyword and expect error  *AdminApiProcedureFailureException:*   ADMIN Update Software With Activation
    ...            sw_package=/tmp/SBTS00_testpackage.zip
    ...            timeout=900
    ADMIN Wait Until Fault Should Be Raised    fault_id=30
    SYSTEM Check if fault is in active raw alarm  0030   EFaultId_SwUpdateAl
    ADMIN Check If Alarm Is Active  fault_id=30
    log to console  delete temp directory and perform swr with no error
    SYSTEM Execute Command On gNB
    ...    command=rm -rf /ffs/stb/temp
    ADMIN Update Software With Activation
    ...            sw_package=/tmp/SBTS00_testpackage.zip
    ...            timeout=2000
    log to console   sleep 300
    Sleep  300
    Wait Until Keyword Succeeds   900   30   ADMIN INFOMODEL Check If BTS Is Configured
    wait until keyword succeeds  240s  10s    ADMIN INFOMODEL Check if RMOD is in availabilityStatus Online
    Get active and passive sw versions after sw update
    Check if sw after sw update is the same
    SYSTEM Check if fault is not in active raw alarm  0030   EFaultId_SwUpdateAl
    ADMIN Check If Alarm Is Not Active  fault_id=30
    log to console   remove unnecessary files
#    Remove already used preparation files





Download testpackage  #for SBTS00
    Set Suite Variable    ${active_software}    ${OUT_ACTIVE_SW}
    ${split_build}=    Split string       ${active_software}    separator=\_
    ${trunk_flag}=     Get from list       ${split_build}     2
    ${version_flag}=   Get from list       ${split_build}     0
    ${download_build}=    Run keyword if    '${trunk_flag}'=='0000'    Set Variable   ${active_software}
    ...   ELSE IF   '${version_flag}'=='${TRUNK_VERSION}'    Replace String    ${active_software}    ${TRUNK_VERSION}    SBTS00
	...   ELSE   	Set Variable   ${active_software}
    Set Suite Variable    ${main_package}    ${download_build}_release_BTSSM_downloadable.zip
    Set Suite Variable    ${T1_package}    ${download_build}_release_BTSSM_downloadable_testpackage_T1.zip
    Set Suite Variable    ${T2_package}    ${download_build}_release_BTSSM_downloadable_testpackage_T2.zip
    Log    \nDownload SW packages    console=yes
#    Run    wget ${jenkins_url}${download_build}/${main_package} -P ${SW_DESTINATION}
#    OperatingSystem.File Should Exist    path=${SW_DESTINATION}/${main_package}
    Run    wget ${jenkins_url}${download_build}/${T1_package} -P /tmp/
    OperatingSystem.File Should Exist    path=/tmp/${T1_package}
#    Run    wget ${jenkins_url}${download_build}/${T2_package} -P /tmp/
#    OperatingSystem.File Should Exist    path=/tmp/${T2_package}
    Run  mv /tmp/${T1_package} /tmp/SBTS00_testpackage.zip
#    Run  mv /tmp/${T2_package} /tmp/SBTS00_testpackage.zip
    Log    Download completed    console=yes

Transfer dev_cli package from server
    Run And Return Rc And Output  sshpass -p 'zO&n1W*ktp7' scp coam@10.5.25.105:/opt/coam/NU_STERGE/CB007944/admin-cli-2.8.2.zip /tmp/
    OperatingSystem.File Should Exist  /tmp/admin-cli-2.8.2.zip

Prepare test files
    Run  unzip -o /tmp/admin-cli-2.8.2.zip -d ${SW_DESTINATION}/CB007944
    Run  rm -f /tmp/admin-cli-2.8.2.zip
    Run  cp ${SW_DESTINATION}/ADMIN_CLI/bundle.js ${SW_DESTINATION}/CB007944
    Run  rm -rf ${SW_DESTINATION}/ADMIN_CLI
    Run  cp ${CURDIR}/softwarePrecheckForLocal.sh ${SW_DESTINATION}/CB007944
    Run  chmod 777 ${SW_DESTINATION}/CB007944/*

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
    Run  rm -f ${SW_DESTINATION}/${build_ver}_ADMIN_CLI.zip
    Log to Console     Download completed
    [Return]           ${build_ver}_ADMIN_CLI.zip

Create temp directory on bts standby partition and copy dummy files
    SYSTEM Execute Command On gNB
    ...    command=ls /ffs/stb/
#    SYSTEM Execute Command On gNB
#    ...    command=cd /ffs/stb/
#    SYSTEM Execute Command On gNB
#    ...    command=ls
    SYSTEM Execute Command On gNB
    ...    command=mount -o remount rw /ffs/stb
    SYSTEM Execute Command On gNB
    ...    command=mkdir /ffs/stb/temp/
##    SYSTEM Execute Command On gNB
##    ...    command=cd /ffs/stb/temp
#    SYSTEM Execute Command On gNB
#    ...    command=ls
    SYSTEM Execute Command On gNB
    ...    command=df -h
    SYSTEM Execute Command On gNB
    ...    command=cp -r /ffs/run/* /ffs/stb/temp/
    Sleep  100
    SYSTEM Execute Command On gNB
    ...    command=df -h
   ${content}=  SYSTEM Execute Command On gNB
    ...    command=df -h
    ${status}   Run Keyword And Return Status  should contain   ${content}    100% /ffs/fs1
    Run Keyword Unless   ${status}   should contain   ${content}
    ...                     100% /ffs/fs2


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

Check if sw after sw update is the same
#    [Arguments]     ${post_update_active_sw}
#    ...             ${pre_update_active_sw}
    Log To Console  Check if SW ${post_update_passive_sw} is the same with ${pre_update_active_sw}
    Should Be True  '${post_update_passive_sw}' == '${pre_update_active_sw}'
    ...  msg=Post update SW doesn't match target Sw.

Remove already used preparation files
    Run  rm -rf ${SW_DESTINATION}/CB007944
    Run  rm -f /tmp/SBTS00_testpackage.zip
