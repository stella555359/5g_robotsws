*** Settings ***
Documentation
...  Before bts reset, change one files content that has distributed, let restart fail. trigger fault 1802
...  Example of execution:
...  pybot --variable CONFIGURATION:Wroclaw.IAV_WRO_TL101 -L TRACE -b debug.log -d results testsuite/WMP/OAM/SWM/
...  Automated__SW_Management__Failure_In_Nyquist_DSP_Runtime_SW_Download_Caused_By_Checksum_Errors.robot
...  "Author: tracy.hao@nokia.com"
...  Execution:
...         pybot -v CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log -d results testsuite/WMP/SOAM3/SWM/SRAN_SWM/Trunk_Rel4/CRT/
...  Automated__SW_Management__Failure_In_Nyquist_DSP_Runtime_SW_Download_Caused_By_Checksum_Errors.robot


*** Variables ***
${6450_auto_trigger_delay}  		${CURDIR}/snapshotUploadDelayForFault6450_set_to_2.json
${6450_auto_trigger_recover}		${CURDIR}/snapshotUploadDelayForFault6450_set_to_0.json
${destination_dir}                      /home/ute/btsauto/Basic/
${SW Update Timeout}                    1800      # Given in seconds; That is a timeout for SW download and activation (without reset)


*** Keywords ***
Automated__SW_Management__Failure_In_Nyquist_DSP_Runtime_SW_Download_Caused_By_Checksum_Errors
    [Documentation]    Short description.
    run_keyword_and_ignore_error     Run    rm -r /home/ute/btsauto/Basic
    run_keyword_and_ignore_error    Disable fault 6450 auto trigger snapshot
    Get SW load and Type for bts
    Modify files and reboot BTS
    Wait Until Keyword Succeeds  15m  1m  Check if all radio modules are available
    Wait Until Keyword Succeeds    8 min    10 sec    Check if fault present in this testcase
    ...      1802
    Sleep  100
    Recover BTS SW
    Wait Until Keyword Succeeds  15m  1m  Check if all radio modules are available
    Wait Until Keyword Succeeds    8 min    10 sec    Check if fault absent in this testcase    1802

Modify files and reboot BTS
    [Documentation]    Short description.
    ${active_build}=   Download_Specify_Build_By_Aria    ${ACTIVE_SW_BEFORE}    Basic    ${destination_dir}
    ${checkfilename}  ${file_checksum}=     Get File name of DSP file '${active_build}'
    Set Test Variable    ${command}	  sed -i 's/checksum="${file_checksum}"/checksum=""/' /ffs/run/FileDirectory.xml
    Wait log and update '${checkfilename}' '${command}'
    ${ping_loss}  Run keyword and return status  Wait for target to be not reachable  hostname=192.168.255.1  timeout=600
    Run keyword if    not ${ping_loss}  Fail  Activation reset was not performed after Planfile download during autoconfiguration.  console=${true}
    ${ping_regain}  Run keyword and return status  Wait for target to be reachable  hostname=192.168.255.129  timeout=240
    Run keyword if    not ${ping_regain}  Fail  Ping has not been regained within timeout
    set test variable   ${active_build}

Wait log and update '${filename}' '${cmd}'
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${filename}: <description>
    ...        ${cmd}: <description>
#   Wait for message in syslog file     regexp='\"Update result: successful and automaticActivation\"'    alias=enb_syslog    timeout=600
    Setup Enb Fsm Access            alias=enb1
    Execute Command on Enb     sed -i 's/<Crc32>0x.*<\\/Crc32>/<Crc32>0x00000000<\\/Crc32>/' /rom/swpool/DSP/${filename}   alias=enb1
    Execute Command on Enb     crasign /rom/swpool/DSP/${filename}      alias=enb1
    Execute Command on Enb     ${cmd}      alias=enb1
    Execute Command on Enb     rm -rf /ffs/run/HashContainer*  alias=enb1
    Execute command on enb     reboot    return_rc=${True}    alias=enb1
    Teardown Enb Fsm Access         alias=enb1

Get File name of DSP file '${load}'
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${load}: <description>
    ...
    ...    Returns:
    ...        ${FL-K2-UPDSP_name}: <description>
    ...        ${FL-K2-UPDSP_checksum}: <description>
    #${substring}=     Get Substring   ${load}     24	53
    Run     unzip ${load} -d ${destination_dir}${ACTIVE_SW_BEFORE}
    ${root}=        Parse XML       ${destination_dir}${ACTIVE_SW_BEFORE}/bts_sw/TargetBD_${ACTIVE_SW_BEFORE}.xml
    ${FL-K2-UPDSP}=            Get Element     ${root}     buildElement[@name="FL-K2-UPDSP"][@hwUnit="FCTJ"]
    ${FL-K2-UPDSP_version}=    Get Element Attribute    ${FL-K2-UPDSP}      version
    ${FL-K2-UPDSP_name}=       Set Variable   FL-K2-UPDSP${FL-K2-UPDSP_version}
    ${FL-K2-UPDSP_checksum}=   Get Element Attribute    ${FL-K2-UPDSP}      checksum
    Run    rm -r ${destination_dir}${/}Load
    [Return]              ${FL-K2-UPDSP_name}  ${FL-K2-UPDSP_checksum}

Disable fault 6450 auto trigger snapshot
    [Documentation]    Short description.
	taf.sbts.oam.coam.admin.perform_delta_recommissioning  	delta_file=${6450_auto_trigger_delay}    skip_parameter_relation_errors=${True}

Recover fault 6450 auto trigger snapshot
    [Documentation]    Short description.
	taf.sbts.oam.coam.admin.perform_delta_recommissioning  	delta_file=${6450_auto_trigger_recover}    skip_parameter_relation_errors=${True}

Recover BTS SW
    [Documentation]    Short description.
    Log to console with time    start to Recover BTS SW
    ${update_result}=    Run keyword and return status    taf.sbts.oam.coam.admin.update software    ${active_build}    True    ${SW Update Timeout}
    ${ping_status}  Check If Target Is Stable  ip=192.168.255.129  min_uptime=300  max_downtime=900  timeout=1800
    Run keyword if    not ${ping_status}  FAIL  BTS is not stable after upgrade.

Get SW load and Type for bts
    [Documentation]    Short description.
	${ACTIVE_SW_BEFORE}    ${PASSIVE_SW_BEFORE}    Admin Get BTS SW Version
	${build_type}=  Should Match Regexp  ${PASSIVE_SW_BEFORE}  .{2}$
        ${split_build}=    Split string         ${ACTIVE_SW_BEFORE}    separator=\_
   	${TRUNK_VERSION}=     Get from list         ${split_build}     0

	set test variable    ${ACTIVE_SW_BEFORE}
	set test variable    ${build_type}
    set test variable    ${TRUNK_VERSION}

Check if fault present in this testcase
    [Documentation]    Short description.
    ...    Args:
    ...        ${faultId}: <description>
    [Arguments]    ${faultId}
    Log    =============================================================${\n}Checking if fault ${faultId} is present
    ${expected_alarms}=    Create Dictionary    faultId=${faultId}
    ${expected_patterns}=    Create List    ${expected_alarms}
    #${critical_alarms}=    Create Dictionary    severity=Major|Critical
    #${critical_patterns}=    Create List    ${critical_alarms}
    ${alarms_status}    ${alarms_return}=    Run Keyword And Ignore Error    Admin Check Active Alarms    expected_patterns=${expected_patterns}
    Run keyword if    '${alarms_status}'=='FAIL'    Fail    Failed at expected alarms:${expected_alarms}
    #Run keyword if    ${alarms_return}    Set Test Restriction    Minor alarm found.

Check if fault absent in this testcase
    [Documentation]    Short description.
    ...    Args:
    ...        ${faultId}: <description>
    [Arguments]    ${faultId}
    Log    =============================================================${\n}Checking if fault ${faultId} is present
    ${expected_alarms}=    Create Dictionary    faultId=${faultId}
    ${expected_patterns}=    Create List    ${expected_alarms}
    #${critical_alarms}=    Create Dictionary    severity=Major|Critical
    #${critical_patterns}=    Create List    ${critical_alarms}
    ${alarms_status}    ${alarms_return}=    Run Keyword And Ignore Error    Admin Check Active Alarms    expected_patterns=${expected_patterns}
    Run keyword if    '${alarms_status}'=='PASS'    Fail    Failed at not expected alarms:${expected_alarms}
    #Run keyword if    ${alarms_return}    Set Test Restriction    Minor alarm found.
