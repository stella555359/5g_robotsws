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
Library        OperatingSystem
Library        Process

Resource    ../../resources/admin.robot
Resource    ../../resources/pretest_posttest.robot
Resource    ../../resources/system.robot
Resource    ../../resources/fault_trigger.robot

*** Variables ***
${LOGGING_ENB_SYSLOG}=           True
${LOGGING_IPHY_SYSLOG}=          True
${LOGGING_ADMIN_LOG}=            True
${LOGGING_ADMIN_INFOMODEL_LOG}=  True
${LOGGING_EMSSIM_LOG}=           True

${DOWNLOAD_HOST}        https://artifactory-espoo1.ext.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release
#${BRANCH}               800
${SW_DESTINATION}       /home/ute/
${jenkins_url}          http://files.ute.nsn-rdnet.net/builds/enb/base/
${TRUNK_VERSION}        SBTS22R4

*** Keywords ***
Software_Update_Without_Activation
    log to console  Start test 1
    ${output}=  SYSTEM Execute Command On gNB
    ...    command=ls /ffs/stb/
    should contain  ${output}  	TargetBD_${OUT_PASSIVE_SW}.xml

    ADMIN Update Software Without Activation
    ...    sw_package=${SW_DESTINATION}${T1_package}
    ...    timeout=1200

    ${output}=  SYSTEM Execute Command On gNB
    ...    command=ls /ffs/stb/
    should not contain  ${output}  	TargetBD_${OUT_PASSIVE_SW}.xml
    Should Be Equal As Strings  ${output}  planned\r\n
    Sleep  30

Software_Rollback_After_Download
    log to console  Start test 2
    ${active_sw_version}=    ADMIN Get Sw Version
    ADMIN Update Software Without Activation
    ...    sw_package=${SW_DESTINATION}${T1_package}
    ...    timeout=1200

    ${output}=  SYSTEM Execute Command On gNB
    ...    command=ls /ffs/run/
    should contain  ${output}  	TargetBD_${active_sw_version}.xml
    ${output}=  SYSTEM Execute Command On gNB
    ...    command=ls /ffs/stb/
    Should Be Equal As Strings  ${output}  planned\r\n
    ${output}=  SYSTEM Execute Command On gNB
    ...    command=ls /ffs/stb/planned/
    should contain  ${output}  	TargetBD_${active_sw_version}T1.xml

    run keyword and expect error  *Passive software is not valid*  ADMIN Rollback Software

    ${output}=  SYSTEM Execute Command On gNB
    ...    command=ls /ffs/stb/
    Should Be Equal As Strings  ${output}  planned\r\n
    ${output}=  SYSTEM Execute Command On gNB
    ...    command=ls /ffs/stb/planned/
    should contain  ${output}  	TargetBD_${active_sw_version}T1.xml
    ${output}=  SYSTEM Execute Command On gNB
    ...    command=ls /ffs/run/
    should contain  ${output}  	TargetBD_${active_sw_version}.xml
    Sleep  30

Software_Activate_After_Download
    log to console  Start test 3
    ${active_sw_version}=    ADMIN Get Sw Version
    ADMIN Update Software Without Activation
    ...    sw_package=${SW_DESTINATION}${T1_package}
    ...    timeout=1200

    ${output}=  SYSTEM Execute Command On gNB
    ...    command=ls /ffs/stb/
    should not contain  ${output}  	TargetBD
    Should Be Equal As Strings  ${output}  planned\r\n
    ${output}=  SYSTEM Execute Command On gNB
    ...    command=ls /ffs/stb/planned/
    should contain  ${output}  	TargetBD_${active_sw_version}T1.xml

    ADMIN Update Software With Activation
    ...    sw_package=${SW_DESTINATION}${T1_package}
    ...    timeout=900
    SYSTEM Wait Till Gnb Will Not Be Pingable For A Given Period
    SYSTEM Wait Till Gnb Will Be Pingable For A Given Period
    Sleep  400
    ${output}=  SYSTEM Execute Command On gNB
    ...    command=ls /ffs/run/
    should contain  ${output}  	TargetBD_${active_sw_version}T1.xml
    ${output}=  SYSTEM Execute Command On gNB
    ...    command=ls /ffs/stb/
    should not contain  ${output}  	planned
    should contain  ${output}  	TargetBD_${active_sw_version}.xml
    Sleep  180

Software_Rollback
    log to console  Start test 4

    ${output}=  SYSTEM Execute Command On gNB
    ...    command=ls /ffs/run/
    should contain  ${output}  	TargetBD_${OUT_ACTIVE_SW}.xml
    ${output}=  SYSTEM Execute Command On gNB
    ...    command=ls /ffs/stb/
    should contain  ${output}  	TargetBD_${OUT_ACTIVE_SW}T1.xml

    ADMIN Rollback Software
    SYSTEM Wait Till Gnb Will Not Be Pingable For A Given Period
    SYSTEM Wait Till Gnb Will Be Pingable For A Given Period
    Sleep  400
    ${output}=  SYSTEM Execute Command On gNB
    ...    command=ls /ffs/run/
    should contain  ${output}  	TargetBD_${OUT_ACTIVE_SW}T1.xml
    ${output}=  SYSTEM Execute Command On gNB
    ...    command=ls /ffs/stb/
    should contain  ${output}  	TargetBD_${OUT_ACTIVE_SW}.xml
    Sleep  30

Radio_Software_Update
    Generate fault 23
    ADMIN Update Software With Activation
    ...    sw_package=${SW_DESTINATION}${main_package}
    ...    timeout=1200
    Sleep  400
    ADMIN Check If Alarm Is Not Active  fault_id=23
    #+check if radio is up - to be done



#Download SW
##    Set Suite Variable  ${OUT_ACTIVE_SW}  5G20B_GNB_0000_000800_001758
#    Set Suite Variable    ${active_software}    ${OUT_ACTIVE_SW}
#    ${active_software_split}=    Split String
#    ...                          string=${active_software}
#    ...                          separator=_
#    ...                          max_split=4
#    ${BRANCH}=   Get from list         ${active_software_split}    2
#    ${version}=  Run Keyword If  '${BRANCH}'=='0000'  Convert To String  0.800
#	...                    ELSE IF   '${BRANCH}'=='0011'  Convert To String  11.800
#    Set Suite Variable    ${active_software_number}    ${active_software_split[4]}
#    ${active_software_number}=    Convert To Integer    ${active_software_number[:6]}
#    Set Suite Variable    ${main_package}    AirScale-${version}.${active_software_number}.zip
#    Set Suite Variable    ${T1_package}    AirScale-${version}.${active_software_number}T1.zip
#    Set Suite Variable    ${T2_package}    AirScale-${version}.${active_software_number}T2.zip
#    Log    \nDownload SW packages    console=yes
#    Run    wget ${DOWNLOAD_HOST}/${version}.${active_software_number}/${main_package} -P ${SW_DESTINATION}
#    OperatingSystem.File Should Exist    path=${SW_DESTINATION}/${main_package}
#    Run    wget ${DOWNLOAD_HOST}/${version}.${active_software_number}/${T1_package} -P ${SW_DESTINATION}
#    OperatingSystem.File Should Exist    path=${SW_DESTINATION}/${T1_package}
#    Run    wget ${DOWNLOAD_HOST}/${version}.${active_software_number}/${T2_package} -P ${SW_DESTINATION}
#    OperatingSystem.File Should Exist    path=${SW_DESTINATION}/${T2_package}
#    Log    Download completed    console=yes


#Download SW
##    Set Suite Variable  ${OUT_ACTIVE_SW}  5G20B_GNB_0000_000800_001758
#    Set Suite Variable    ${active_software}    ${OUT_ACTIVE_SW}
#    ${active_software_split}=    Split String
#    ...                          string=${active_software}
#    ...                          separator=_
#    ...                          max_split=4
#    ${BRANCH}=   Get from list         ${active_software_split}    2
#    Run Keyword If  '${BRANCH}'=='9999'   Download SW for SBTS00
#    ...   ELSE IF   '${BRANCH}'=='0011'   Download SW for branch 5G

Download SW  #for SBTS00
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
    Run    wget ${jenkins_url}${download_build}/${main_package} -P ${SW_DESTINATION}
    OperatingSystem.File Should Exist    path=${SW_DESTINATION}/${main_package}
    Run    wget ${jenkins_url}${download_build}/${T1_package} -P ${SW_DESTINATION}
    OperatingSystem.File Should Exist    path=${SW_DESTINATION}/${T1_package}
    Run    wget ${jenkins_url}${download_build}/${T2_package} -P ${SW_DESTINATION}
    OperatingSystem.File Should Exist    path=${SW_DESTINATION}/${T2_package}
    Log    Download completed    console=yes

Download SW for branch 5G
    Set Suite Variable    ${active_software}    ${OUT_ACTIVE_SW}
    ${active_software_split}=    Split String
    ...                          string=${active_software}
    ...                          separator=_
    ...                          max_split=4
    ${BRANCH}=   Get from list         ${active_software_split}    2
    ${version}=  Run Keyword If  '${BRANCH}'=='0011'  Convert To String  11.800
    Set Suite Variable    ${active_software_number}    ${active_software_split[4]}
    ${active_software_number}=    Convert To Integer    ${active_software_number[:6]}
    Set Suite Variable    ${main_package}    AirScale-${version}.${active_software_number}.zip
    Set Suite Variable    ${T1_package}    AirScale-${version}.${active_software_number}T1.zip
    Set Suite Variable    ${T2_package}    AirScale-${version}.${active_software_number}T2.zip
    Log    \nDownload SW packages    console=yes
    Run    wget ${DOWNLOAD_HOST}/${version}.${active_software_number}/${main_package} -P ${SW_DESTINATION}
    OperatingSystem.File Should Exist    path=${SW_DESTINATION}/${main_package}
    Run    wget ${DOWNLOAD_HOST}/${version}.${active_software_number}/${T1_package} -P ${SW_DESTINATION}
    OperatingSystem.File Should Exist    path=${SW_DESTINATION}/${T1_package}
    Run    wget ${DOWNLOAD_HOST}/${version}.${active_software_number}/${T2_package} -P ${SW_DESTINATION}
    OperatingSystem.File Should Exist    path=${SW_DESTINATION}/${T2_package}
    Log    Download completed    console=yes



Generate fault 23
    log to console  Generate fault 23

    Check not uncommissioned state for BTS
    ADMIN Check If Alarm Is Not Active  fault_id=23

    SYSTEM Execute Command On IPHY  sed -i '/bldVersion/s/5G/4G/' /ffs/run/simmode/iphy.xml
    SYSTEM Execute Command On IPHY  ddal -s ddal_reboot_graceful
    SYSTEM Wait Till Iphy Will Not Be Pingable For A Given Period
    SYSTEM Wait Till Iphy Will Be Pingable For A Given Period
    Sleep  500
    ADMIN Check If Alarm Is Active  fault_id=23
