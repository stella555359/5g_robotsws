*** Settings ***
Documentation
...    Author: Radu Turcu (radu.turcu@nokia.com)
...    Maintainer: Radu Turcu (radu.turcu@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description:CB006006
...    Sample execution: /opt/ute/python/bin/pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BOAM_VERIF_ET1/CB006006/general.robot

Library        String
Library        Telnet
Library        OperatingSystem
Library        Process
Library        BuiltIn
#Library        Selenium2Library
Library        DateTime
#Library        system.robot
Library        SSHLibrary
Library        taf.transport.ssh    WITH NAME    SSH


Resource    ../../resources/admin.robot
Resource    ../../resources/selenium.robot
Resource    ../../resources/pretest_posttest.robot
Resource    ../../resources/system.robot

Resource    ../../resources/admin_infomodel.robot

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
${URL_5G} =   http://lterel.es-si-s3-z2.eecloud.nsn-net.net/build

#########
${lterel_disc}=   http://lterel.es-si-s3-z2.eecloud.nsn-net.net/build
${jenkins_url}          http://files.ute.nsn-rdnet.net/builds/enb/base/
${TRUNK_VERSION}        SBTS23R2

${delta_file_reportingIntervalPm_5min_disable}=          ${CURDIR}/../resources/PM_interval_5min_disable.json
${delta_file_reportingIntervalPm_5min_enable}=          ${CURDIR}/../resources/PM_interval_5min_enable.json
${delta_file_reportingIntervalPm_5min_disable_per_lane}=  ${CURDIR}/../resources/PM_interval_5min_disable_per_lane.json
${delta_file_reportingIntervalPm_5min_enable_per_lane}=    ${CURDIR}/../resources/PM_interval_5min_enable_per_lane.json
*** Keywords ***
8.SFP_Monitoring_Transmission_mode_parameter_removed

    ADMIN INFOMODEL Check If BTS Is OnAir
    ${oruRunningSw}    ADMIN INFOMODEL Get Parameter Value
    ...    dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1/SFP_R-1
    ...    dict_param=transmissionRate
    Log to console    transmissionRate parameter is  ${Space}${oruRunningSw}
    Run Keyword And Expect Error  STARTS:Dictionary does not contain key    ADMIN INFOMODEL Get Parameter Value
    ...    dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1/SFP_R-1
    ...    dict_param=transmissionMode
    Log to console    No transmissionMode parameter available

10.Activate_Deactivate_the_reporting_of_the_counters_for_monitoring_SFP_module_temperature
    log to console  ${\n}delta commissioning - activate counters for monitoring SFP temperature
    Remove PM files from ENB
    Clear PM file from tmp
    ADMIN Perform Delta Recommissioning                 delta_file=${delta_file_reportingIntervalPm_5min_enable}
    ...                                                 skip_parameter_relation_errors=True
    Sleep   10
    wait to nearest 15 min measurement period
    sleep   60
    SYSTEM Download File From Server
        ...    password=oZPS0POrRieRtu
        ...    user=toor4nsn
        ...    server_IP=192.168.255.129
        ...    file_path=/ram
        ...    file_name=PM.BTS-1.*.*.*.*.gz
        ...    current_path=/tmp
        ...    current_name=
    Verify PM counters M4000x C3 C4 C5 C6

    log to console  ${\n}delta commissioning - deactivate counters for monitoring SFP temperature
    Remove PM files from ENB
    Clear PM file from tmp
    ADMIN Perform Delta Recommissioning                 delta_file=${delta_file_reportingIntervalPm_5min_disable}
    ...                                                 skip_parameter_relation_errors=True
    Sleep   10
    wait to nearest 15 min measurement period
    sleep   60
    SYSTEM Download File From Server
        ...    password=oZPS0POrRieRtu
        ...    user=toor4nsn
        ...    server_IP=192.168.255.129
        ...    file_path=/ram
        ...    file_name=PM.BTS-1.*.*.*.*.gz
        ...    current_path=/tmp
        ...    current_name=

    Verify NO PM counters M4000x C3 C4 C5 C6
    log to console  Raw values for M40005C3-C6/M40006C3-C3 counters cannot be reported to WebEM on request

12.Act_Deact_the_reporting_of_the_counters_for_monitoring_Tx_power_Rx_power_and_Tx_bias_current_per_lane
    log to console  ${\n}delta commissioning - activate counters for monitoring SFP per lane
    Remove PM files from ENB
    Clear PM file from tmp
    ADMIN Perform Delta Recommissioning      delta_file=${delta_file_reportingIntervalPm_5min_enable_per_lane}
    ...   skip_parameter_relation_errors=True
    Sleep   10
    wait to nearest 5 min measurement period
    sleep   60
    SYSTEM Download File From Server
        ...    password=oZPS0POrRieRtu
        ...    user=toor4nsn
        ...    server_IP=192.168.255.129
        ...    file_path=/ram
        ...    file_name=PM.BTS-1.*.*.*.*.gz
        ...    current_path=/tmp
        ...    current_name=
    Verify PM counters M400x C0 C1 C2 C3 C4 C5 C6 C7 C8 C9

    log to console  ${\n}delta commissioning - deactivate counters for monitoring SFP per lane
    Remove PM files from ENB
    Clear PM file from tmp
    ADMIN Perform Delta Recommissioning    delta_file=${delta_file_reportingIntervalPm_5min_disable_per_lane}
    ...     skip_parameter_relation_errors=True
    Sleep   10
    wait to nearest 5 min measurement period
    sleep   60
    SYSTEM Download File From Server
        ...    password=oZPS0POrRieRtu
        ...    user=toor4nsn
        ...    server_IP=192.168.255.129
        ...    file_path=/ram
        ...    file_name=PM.BTS-1.*.*.*.*.gz
        ...    current_path=/tmp
        ...    current_name=
    Verify NO PM counters M400x C0 C1 C2 C3 C4 C5 C6 C7 C8 C9
    log to console  Raw values for M40013C0-C9/M40014C0-C9 counters cannot be reported to WebEM on request

14.WebEM CLI shall support command sfpData
    Activate CLI feature
    log  run sfpData.sh and check error code 0 + verify bts info
    ${result}=  Run  ${SW_DESTINATION}/ADMIN_CLI/GET_sfpData.sh
    Should contain  ${result}   "errorCode":0
    Should not contain  ${result}   TransmissionMode
#    Should contain  ${result}   "mrbtsID":1
    log to console  The output of "sfpData" CLI command, does not contain transmissionMode parameter.
    Deactivate CLI feature

Remove PM files from ENB
        SYSTEM Execute Command On gNB
        ...    command=rm /ram/PM.BTS-1.*.*.*.xml.gz
        SYSTEM Execute Command On gNB
        ...    command=rm /ram/PM.BTS-1.*.*.*.raw.gz

Clear PM file from tmp
    Run  rm -f /tmp/PM.BTS-1.*.*.ANY.xml.gz
    Run  rm -f /tmp/PM.BTS-1.*.*.ANY.raw.gz
    Run  rm -f /tmp/PM_file.xml

Wait to nearest 5 min measurement period
	    Log To Console  Wait to nearest measurement period - 5 min
	    Wait Until Keyword Succeeds  6 min  1 min  wait for right period of 5min

wait to nearest 15 min measurement period
	Log To Console  Wait to nearest measurement period
	Wait Until Keyword Succeeds  16 min  1 min  wait for right period of 15min

wait for right period of 5min
	${list}=    Create List  00  05  10  15  20  25  30  35  40  45  50  55
	${actualTime}=   Get Current Date  result_format=%M   time_zone=UTC
	${actualHour}=   Get Current Date  result_format=%H   time_zone=UTC
	${date}=  		   Get Current Date  result_format=%Y-%m-%d   time_zone=UTC
	${actualEpoch}= 	Convert Date	${date} ${actualHour}:${actualTime}:00.000	epoch
	List Should Contain Value	${list}  ${actualTime}
	Log  ${actualTime}40
	Set Global Variable    ${actualTime}
	Set Global Variable    ${actualHour}
	Set Global Variable    ${actualEpoch}

wait for right period of 15min
	${list}=    Create List  00  15  30  45
	${actualTime}=   Get Current Date  result_format=%M   time_zone=UTC
	${actualHour}=   Get Current Date  result_format=%H   time_zone=UTC
	${date}=  		   Get Current Date  result_format=%Y-%m-%d   time_zone=UTC
	${actualEpoch}= 	Convert Date	${date} ${actualHour}:${actualTime}:00.000	epoch
	List Should Contain Value	${list}  ${actualTime}
	Log  ${actualTime}
	Set Global Variable    ${actualTime}
	Set Global Variable    ${actualHour}
	Set Global Variable    ${actualEpoch}

wait for right period of 30min
	${list}=    Create List  00  30
	${actualTimefor30min}=   Get Current Date  result_format=%M   time_zone=UTC
	${actualHourfor30min}=   Get Current Date  result_format=%H   time_zone=UTC
	${date}=  		   Get Current Date  result_format=%Y-%m-%d   time_zone=UTC
	${actualEpochfor30min}= 	Convert Date	${date} ${actualHourfor30min}:${actualTimefor30min}:00.000	epoch
	List Should Contain Value	${list}  ${actualTimefor30min}
	Log  ${actualTimefor30min}
	Set Global Variable    ${actualTimefor30min}
	Set Global Variable    ${actualHourfor30min}
	Set Global Variable    ${actualEpochfor30min}

Verify PM counters M4000x C3 C4 C5 C6
    ${PM_Files}=   Run  ls /tmp/PM.BTS-1.*.*.*.xml.* | sort -r
    ${list_of_PM_files}=   Split string    ${PM_files}    separator=\
    log to console   ${list_of_PM_files}
    ${first_PM_file}=  Get From List  ${list_of_PM_files}  0
    ${PM_File_unzipped}=   Run  gunzip ${first_PM_file}
    Run  mv /tmp/PM.BTS-1.*.xml /tmp/PM_file.xml

    log to console   Parsing Counters file
    ${XML}=   Parse XML   /tmp/PM_file.xml
    Parsing counters  5   ${XML}  RMOD
    Parsing counters  6   ${XML}  SMOD

Verify PM counters M400x C0 C1 C2 C3 C4 C5 C6 C7 C8 C9
    ${PM_Files}=   Run  ls /tmp/PM.BTS-1.*.*.*.xml.* | sort -r
    ${list_of_PM_files}=   Split string    ${PM_files}    separator=\
    log to console   ${list_of_PM_files}
    ${first_PM_file}=  Get From List  ${list_of_PM_files}  0
    ${PM_File_unzipped}=   Run  gunzip ${first_PM_file}
    Run  mv /tmp/PM.BTS-1.*.xml /tmp/PM_file.xml

    log to console   Parsing Counters file
    ${XML}=   Parse XML   /tmp/PM_file.xml
    Parsing counters per lane  13   ${XML}  RMOD
    Parsing counters per lane  14   ${XML}  SMOD

Parsing counters
    [Arguments]    ${counter}  ${XML}  ${type}
    FOR  ${j}  IN RANGE  3  7
        ${elemList}=   Get Elements  ${XML}
        ...  PMSetup/PMMOResult/NE-WBTS_1.0[@measurementType="SBTS_SFP_${type}"]/M4000${counter}C${j}
        @{elemList}=   Convert to List    ${elemList}
        ${length}=	 Get Length 	${elemList}
        Should be true   ${length}>0
        ...  msg=NO counter M4000xCy found
        ${values_list}=     Get Elements Texts  ${XML}
        ...  PMSetup/PMMOResult/NE-WBTS_1.0[@measurementType="SBTS_SFP_${type}"]/M4000${counter}C${j}
        ${length_values_list}=	 Get Length 	${values_list}
        Run keyword if   ${length_values_list}==1   Print the value  ${values_list}  ${counter}  ${j}
        Run keyword if   ${length_values_list}>1  Print 2 values  ${values_list}  ${counter}  ${j}
    END

Print the value
    [Arguments]    ${values_list}  ${counter}  ${j}
    ${value}=   Get From List   ${values_list}  0
    log to console   SFP1_M4000${counter}C${j}${SPACE}${value}
    Should be true   ${value}>0  msg=wrong counter value

Print 2 values
    [Arguments]    ${values_list}  ${counter}  ${j}
    ${value}=   Get From List   ${values_list}  0
    log to console   SFP1_M4000${counter}C${j}${SPACE}${value}
    Should be true   ${value}>0  msg=wrong counter value
    ${value}=   Get From List   ${values_list}  1
    log to console  SFP2_M4000${counter}C${j}${SPACE}${value}
    Should be true   ${value}>0
    ...  msg=wrong counter value

Parsing counters per lane
    [Arguments]    ${counter}  ${XML}  ${type}
    FOR  ${j}  IN RANGE  0  10
        ${elemList}=   Get Elements  ${XML}
        ...  PMSetup/PMMOResult/NE-WBTS_1.0[@measurementType="SBTS_SFP_${type}_LANE"]/M400${counter}C${j}
        @{elemList}=   Convert to List    ${elemList}
        ${length}=	 Get Length 	${elemList}
        Should be true   ${length}>0
        ...  msg=NO counter M400xCy found
        ${values_list}=     Get Elements Texts  ${XML}
        ...  PMSetup/PMMOResult/NE-WBTS_1.0[@measurementType="SBTS_SFP_${type}_LANE"]/M400${counter}C${j}
        ${length_values_list}=	 Get Length 	${values_list}
        Run keyword if  ${length_values_list}==1   Print the value per lane  ${values_list}  ${counter}  ${j}
        Run keyword if    ${length_values_list}>1  Print 2 values per lane  ${values_list}  ${counter}  ${j}
    END

Print the value per lane
    [Arguments]    ${values_list}  ${counter}  ${j}
    ${value}=   Get From List   ${values_list}  0
    log to console   SFP1_M400${counter}C${j}${SPACE}${value}
    Should be true   ${value}>=-40  msg=wrong counter value

Print 2 values per lane
    [Arguments]    ${values_list}  ${counter}  ${j}
    ${value}=   Get From List   ${values_list}  0
    log to console   SFP1_M400${counter}C${j}${SPACE}${value}
    Should be true   ${value}>=-40  msg=wrong counter value
    ${value}=   Get From List   ${values_list}  1
    log to console  SFP2_M400${counter}C${j}${SPACE}${value}
    Should be true   ${value}>=-40
    ...  msg=wrong counter value

Verify NO PM counters M4000x C3 C4 C5 C6
    ${PM_Files}=   Run  ls /tmp/PM.BTS-1.*.*.*.xml.* | sort -r
    ${list_of_PM_files}=   Split string    ${PM_files}    separator=\
    log to console   ${list_of_PM_files}
    ${first_PM_file}=  Get From List  ${list_of_PM_files}  0
    ${PM_File_unzipped}=   Run  gunzip ${first_PM_file}
    Run  mv /tmp/PM.BTS-1.*.xml /tmp/PM_file.xml

    log to console   Parsing Counters file
    ${XML}=   Parse XML   /tmp/PM_file.xml
    Check NO counters  5   ${XML}  RMOD
    Check NO counters  6   ${XML}  SMOD

Verify NO PM counters M400x C0 C1 C2 C3 C4 C5 C6 C7 C8 C9
    ${PM_Files}=   Run  ls /tmp/PM.BTS-1.*.*.*.xml.* | sort -r
    ${list_of_PM_files}=   Split string    ${PM_files}    separator=\
    log to console   ${list_of_PM_files}
    ${first_PM_file}=  Get From List  ${list_of_PM_files}  0
    ${PM_File_unzipped}=   Run  gunzip ${first_PM_file}
    Run  mv /tmp/PM.BTS-1.*.xml /tmp/PM_file.xml

    log to console   Parsing Counters file
    ${XML}=   Parse XML   /tmp/PM_file.xml
    Check NO counters per lane  13   ${XML}  RMOD
    Check NO counters per lane  14   ${XML}  SMOD

Check NO counters
    [Arguments]    ${counter}  ${XML}  ${type}
    FOR  ${j}  IN RANGE  3  7
        ${elemList}=   Get Elements  ${XML}
        ...  PMSetup/PMMOResult/NE-WBTS_1.0[@measurementType="SBTS_SFP_${type}"]/M4000${counter}C${j}
        @{elemList}=   Convert to List    ${elemList}
        ${length}=	 Get Length 	${elemList}
        Should be true   ${length}==0
        ...  msg=NO counter M4000xCy found
    END

Check NO counters per lane
    [Arguments]    ${counter}  ${XML}  ${type}
    FOR  ${j}  IN RANGE  0  10
        ${elemList}=   Get Elements  ${XML}
        ...  PMSetup/PMMOResult/NE-WBTS_1.0[@measurementType="SBTS_SFP_${type}_LANE"]/M400${counter}C${j}
        @{elemList}=   Convert to List    ${elemList}
        ${length}=	 Get Length 	${elemList}
        Should be true   ${length}==0
        ...  msg=NO counter M400xCy found
    END

ADMIN_CLI Suite Setup
    Download ADMIN_CLI package
    Transfer ADMIN_CLI scripts

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

#Download ADMIN_CLI package
#    Get SW load
#	${software_type}=  Get software version type
#	Set suite variable  ${software_type}
#	Run Keyword If  '${software_type}'=='9999'  Download ADMIN CLI Trunk Load
#	Run Keyword If  '${software_type}'=='0010'  Download ADMIN CLI 5G20B Load

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

#Download ADMIN_CLI Trunk Load
#    [Documentation]    Kw download Common Trunk AdminCLI from disc e.g.:
#    ...    https://lterel.es-si-s3-z4.eecloud.nsn-net.net/build/SBTS00/SBTS00_ENB_9999_210505_000001_ADMIN_CLI.zip
#    ${SW_Version}     ADMIN Get Sw Version
#    ${is_TrunkBuild}=     Run Keyword and Return Status    Should Contain      ${SW_Version}      _9999_
#    ${build_ver}=     Run keyword if
#    ...  ${is_Trunk_Build}==True        Replace String Using Regexp    ${SW_Version}    ^SBTS[A-Za-z0-9]+_    SBTS00_
#    ...  ELSE     Set variable   ${SW_Version}
#    ${release}        Fetch from left   ${build_ver}  _ENB_
#    ${fileExists}      Run Keyword and Return Status  OperatingSystem.File Should Exist
#    ...  ${SW_DESTINATION}/${build_ver}_ADMIN_CLI.zip
#    Run Keyword If     ${fileExists} is False   Run
#    ...  wget ${lterel_disc}/${release}/${build_ver}_ADMIN_CLI.zip -nv -P ${SW_DESTINATION}
#    ${fileExists}      Run Keyword and Return Status  OperatingSystem.File Should Exist
#    ...  ${SW_DESTINATION}/${build_ver}_ADMIN_CLI.zip
#    Should Be Equal As Strings  ${fileExists}  True
#    Run  unzip -o ${SW_DESTINATION}/${build_ver}_ADMIN_CLI.zip -d ${SW_DESTINATION}/ADMIN_CLI
#    Run  rm -f ${SW_DESTINATION}/${build_ver}_ADMIN_CLI.zip
#    Log to Console     Download completed
#    [Return]           ${build_ver}_ADMIN_CLI.zip

Branch or Trunk
    @{sw_version}=  Split String  ${out_active_sw}  separator=\_
    ${branch}=  Set Variable  @{sw_version}[0]
    Set Global Variable  ${branch}
