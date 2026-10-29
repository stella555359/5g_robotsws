*** Settings ***
Documentation
...  Common keyword for ET cases
...  Example of execution:


*** Variables ***
${FAULT_SNAPSHOT_TRIGGER_path}		/MRBTS-1/RAT-1/BTS_L-*/FUNC_L-1/ALARM_CONF-1/FAULT_SNAPSHOT_TRIGGER_LIST_CONF-*
${SW_UPDATE_RESULT_path}		/MRBTS-1/RAT-1/URI-1/SW_UPDATE_IND-1/SW_UPDATE_RESULT-1
${RF_module_path}			/MRBTS-1/RAT-1//EQM_L-1/RMOD_L-*/RU_L-1

${snapshot_local_directory}=            ${CURDIR}${/}Snapshot
${log_dir}=                             ${/}var${/}tmp
${indent}=                              \ \ \ \
${destination_dir}=                     /home/ute/btsauto/Basic/


*** Keywords ***
prepare different build
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${package Path}: <description>
    ${ACTIVE_SW_BEFORE}    ${PASSIVE_SW_BEFORE}    Admin Get BTS SW Version
    ${new_sw_build}=    Select different build    ${ACTIVE_SW_BEFORE}
    ${build_type}=  Should Match Regexp  ${PASSIVE_SW_BEFORE}  .{2}$

    ${download_build}=      set variable if     '${ACTIVE_SW_BEFORE}' in '${PASSIVE_SW_BEFORE}'    ${new_sw_build}    ${ACTIVE_SW_BEFORE}
    ${package Path}=    Download_Specify_Build_By_Aria    ${download_build}    T1     ${destination_dir}

    [Return]    ${package Path}

Select different build
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${ACTIVE_SW}: <description>
    ...
    ...    Returns:
    ...        ${sw_build}: <description>
    [Arguments]    ${ACTIVE_SW}=${ACTIVE_SW_BEFORE}
    ${release_list}=    get_enb    ${target_release}
    ${sw_build}    Run Keyword If
    ...  '${release_list[-1]}'!='${ACTIVE_SW}'
    ...  Set Variable    ${release_list[-1]}
    ...    ELSE IF    '${release_list_2}'!='${ACTIVE_SW}'
    ...  Set Variable    ${release_list_2}
    [Return]    ${sw_build}

Check which T type it should be
    [Documentation]    Short description.
	#${T_type}   Set Variable If
	#...      '${build_type}' !='T1'    T1
	set test variable    ${T_type}     T1

Change '${Part}' in '${active_build_T}' to make SW '${T_type}' update fail for FSM'${n}'
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${Part}: <description>
    ...        ${active_build_T}: <description>
    ...        ${T_type}: <description>
    ...        ${n}: <description>
    Log To Console     start to change ${part} file
    ${tempdir}    Set Variable    ${/}home${/}ute${/}tmpdir
    Log To Console    start to unzip
    Run     unzip -o ${active_build_T} -d ${tempdir}
    Log To Console    unzip successfully
    ${split_build}=    Split string         ${active_build_T}    separator=\_
    ${trunk_flag}=     Get from list         ${split_build}     2
    #${trunk_substring}=         Get Substring   ${active_build_T}       32      54
    ${build_substring}=     Set Variable    ${split_build}[1]_${split_build}[2]_${split_build}[3]_${split_build}[4]
    ${brach_version}    Get Regexp Matches    ${active_build_T}    SBTS\\d{2,2}\\w[0-9]?_
    ${root}=  Run keyword if  '${trunk_flag}'=='9999'  Parse XML  ${tempdir}${/}bts_sw/TargetBD_${TRUNK_VERSION}_${build_substring}${T_type}.xml
                ...     ELSE  Parse XML  ${tempdir}${/}bts_sw/TargetBD_${brach_version[0]}${build_substring}${T_type}.xml
    ${Part}=    Run keyword if      "${n}" == "6"    Get Element  ${root}  buildElement[@name="${Part}"][@hwUnit="FCTP"]
	            ...     ELSE IF     "${n}" == "4"    Get Element  ${root}   buildElement[@name="${Part}"][@hwUnit="FCTJ"]
	            ...     ELSE IF     "${n}" == "2"    Get Element  ${root}   buildElement[@name="${Part}"][@hwUnit="FCTM"]
	            ...     ELSE                         Get Element  ${root}   buildElement[@name="${Part}"][@hwUnit="FCT"]     # n = 3
    Set Element Attribute   ${Part}  checksum  10

    Run keyword if      "${n}" == "6"    Remove Element  ${root}   buildElement[@name="HashContainer"][@hwUnit="FCTP"]
	...     ELSE IF     "${n}" == "4"    Remove Element  ${root}   buildElement[@name="HashContainer"][@hwUnit="FCTJ"]
	...     ELSE IF     "${n}" == "2"    Remove Element  ${root}   buildElement[@name="HashContainer"][@hwUnit="FCTM"]
	...     ELSE                         Remove Element  ${root}   buildElement[@name="HashContainer"][@hwUnit="FCT"]     # n = 3

    Run keyword if      "${n}" == "6"    Remove Element  ${root}   buildElement[@name="HashContainerSignature"][@hwUnit="FCTP"]
	...     ELSE IF     "${n}" == "4"    Remove Element  ${root}   buildElement[@name="HashContainerSignature"][@hwUnit="FCTJ"]
	...     ELSE IF     "${n}" == "2"    Remove Element  ${root}   buildElement[@name="HashContainerSignature"][@hwUnit="FCTM"]
	...     ELSE                         Remove Element  ${root}   buildElement[@name="HashContainerSignature"][@hwUnit="FCT"]     # n = 3

    Run keyword if    '${trunk_flag}'=='9999'
    ...    Save XML    ${root}     ${tempdir}${/}bts_sw/TargetBD_${TRUNK_VERSION}_${build_substring}${T_type}.xml
    ...    ELSE    Save XML    ${root}     ${tempdir}${/}bts_sw/TargetBD_${brach_version[0]}${build_substring}${T_type}.xml
    OperatingSystem.Remove File             ${active_build_T}
    OperatingSystem.Run                     zip -r ${active_build_T} ${tempdir}${/}bts_sw
    OperatingSystem.Remove Directory        ${tempdir}${/}bts_sw   recursive=True

Change '${Part}' in '${active_build_T}' to make SW update fail for FSM'${n}'
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${Part}: <description>
    ...        ${active_build_T}: <description>
    ...        ${n}: <description>
    ${tempdir}    Set Variable    ${/}home${/}ute${/}tmpdir
    Run    unzip -o ${active_build_T} -d ${tempdir}
    ${substring}=    Get Substring   ${active_build_T}   31      53
    ${root}=    Parse XML   ${tempdir}${/}bts_sw/TargetBD_${TRUNK_VERSION}_FSM${n}_9999_${substring}.xml
    ${Part}=    Run keyword if     "${n}" == "6"    Get Element  ${root}  buildElement[@name="${Part}"][@hwUnit="FCTP"]
        		            ...     ELSE IF     "${n}" == "4"    Get Element  ${root}   buildElement[@name="${Part}"][@hwUnit="FCTJ"]
        		            ...     ELSE IF     "${n}" == "2"    Get Element  ${root}   buildElement[@name="${Part}"][@hwUnit="FCTM"]
    	                    ...     ELSE                         Get Element  ${root}   buildElement[@name="${Part}"][@hwUnit="FCT"]     # n = 3
    Set Element Attribute   ${Part}  checksum  10
    Save XML    ${root}     ${tempdir}${/}bts_sw/TargetBD_${TRUNK_VERSION}_FSM${n}_9999_${substring}.xml
    OperatingSystem.Remove File             ${destination_dir}/${active_build_T}
    OperatingSystem.Run                     zip -r ${destination_dir}/${active_build_T} ./bts_sw
    OperatingSystem.Remove Directory        ${tempdir}${/}bts_sw   recursive=True

Get eNB HW Platform
    [Documentation]    Short description.
#    ${enb_hardware_name}=	ute_admin_infomodel.check infomodel object   /MRBTS-1/EQM-1/SMOD-* is [variant=FSMF]
    ${enb_hardware_name_FCT}=	ute_admin_infomodel.check infomodel object
    ...  /MRBTS-1/RAT-1/BTS_L-*/EQM_L-1/CABINET_L-1/SMOD_L-1/SMOD_BP_L-1 is [hwResourceBuildKey=FCT]
    ${enb_hardware_name_FCTJ}=	ute_admin_infomodel.check infomodel object
    ...  /MRBTS-1/RAT-1/BTS_L-*/EQM_L-1/CABINET_L-1/SMOD_L-1/SMOD_BP_L-1 is [hwResourceBuildKey=FCTJ]
    ${enb_hardware_name_FCTP}=	ute_admin_infomodel.check infomodel object
    ...  /MRBTS-1/RAT-1/BTS_L-*/EQM_L-1/CABINET_L-1/SMOD_L-1/SMOD_BP_L-1 is [hwResourceBuildKey=FCTP]
    ${enb_hardware_name_FCTM}=	ute_admin_infomodel.check infomodel object
    ...  /MRBTS-1/RAT-1/BTS_L-*/EQM_L-1/CABINET_L-1/SMOD_L-1/SMOD_BP_L-1 is [hwResourceBuildKey=FCTM]

    Run Keyword If    '${enb_hardware_name_FCTP}'=='True'        Set Suite Variable    ${FSM_num}    6
    ...     ELSE IF   '${enb_hardware_name_FCTJ}'=='True'        Set Suite Variable    ${FSM_num}    4
    ...     ELSE IF   '${enb_hardware_name_FCTM}'=='True'        Set Suite Variable    ${FSM_num}    2
    ...     ELSE                                                 Set Suite Variable    ${FSM_num}    3

Get SW load and Type
    [Documentation]    Short description.
	${ACTIVE_SW_BEFORE}    ${PASSIVE_SW_BEFORE}    Admin Get BTS SW Version
	${build_type}=  Should Match Regexp  ${PASSIVE_SW_BEFORE}  .{2}$
        ${split_build}=    Split string         ${ACTIVE_SW_BEFORE}    separator=\_
   	${TRUNK_VERSION}=     Get from list         ${split_build}     0

	set test variable    ${ACTIVE_SW_BEFORE}
	set test variable    ${build_type}
        set test variable    ${TRUNK_VERSION}

Check if fault present
    [Documentation]    Short description.
    ...
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

Check if fault absent
    [Documentation]    Short description.
    ...
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

Collect Dedicated File from BTS
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${sourcepath}: <description>
    ...        ${destinationpath}: <description>
    [Arguments]    ${sourcepath}    ${destinationpath}
    ${status}    ${result}=    Run Keyword And Ignore Error
    ...  Get File From System Module    source_path=${sourcepath}   destination_path=${destinationpath}
    Run Keyword If    '${status}'=='PASS'    Log    ${sourcepath} from System module collected    console=${True}
    ...    ELSE    Run Keyword
    ...  Fail    ${sourcepath} could not be retrieved from System Module! Error: ${result}

Update Modified SW and Check alarm
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${active_build}: <description>
    [Arguments]    ${active_build}
    Log To Console    start to update modified SW to trigger alarm
    Run Keyword And Expect Error    *    taf.sbts.oam.coam.admin.Update Software    ${active_build}   timeout=2000
    Wait Until Keyword Succeeds    5 min    10 sec    Check if fault present    ${fault_id}
    #Get and check swdlReport and Targetbd
    ${ACTIVE_SW_Current}    ${PASSIVE_SW_Current}    Admin Get BTS SW Version
    Collect Dedicated File from BTS    /rom/config/SWDLreport.txt      ${Test Results Dir}/SWDLreport.txt
    Collect Dedicated File from BTS    /rom/TargetBD_${ACTIVE_SW_Current}.xml    ${Test Results Dir}/TargetBD.xml

Wait for eNB configure and RF swCheckDone status
    [Documentation]    Short description.
    #Log  Wait till BTS is stable and ensure admin connectivity  console=${TRUE}
    #${ping_loss}  Run keyword and return status  Wait for target to be not reachable  hostname=192.168.255.129  timeout=480
    #Run keyword if    not ${ping_loss}  Fail  Activation reset was not performed.
    sleep    300s
    Log  Waiting for ping return  console=${TRUE}
    ${ping_regain}  Run keyword and return status  Wait for target to be reachable  hostname=192.168.255.129  timeout=600
    Run keyword if    not ${ping_regain}  Fail  Ping has not been regained within timeout
    Wait until eNB reaches configured state
    Check if every RF module is on swCheckDone status

Wait until eNB reaches configured state
    [Documentation]    Short description.
    Wait Until Keyword Succeeds  500s  10s  ute_admin_infomodel.Query infomodel
    ...  query=/MRBTS-1/RAT-1/MCTRL-*/BBTOP_M-1/MRBTS_M-1/LNBTS_M-* is [stateInfo.proceduralState=regex"Configured|IntegratedToRan|OnAir"]
    ...  timeout=50

Check if every RF module is on swCheckDone status
    [Documentation]    Short description.
    ute_admin_infomodel.Query Infomodel    query=every ${RF_module_path} is [stateInfo.proceduralState=swCheckDone]   timeout=400
    ute_admin_infomodel.Query Infomodel    query=every ${RF_module_path} is [stateInfo.availabilityStatus!=regex"Offline|offline"]   timeout=50
    Log to console    Every RU_L is swCheckDone

Check if every RF module is on swCheckDone status for Dual Core
    [Documentation]    Short description.
    ute_admin_infomodel.Query Infomodel
    ...  query=every /MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/RMOD_L-*/RU_L-1 is [stateInfo.proceduralState=swCheckDone]   timeout=400
    ute_admin_infomodel.Query Infomodel
    ...    query=every /MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/RMOD_L-*/RU_L-1 is [stateInfo.availabilityStatus!=regex"Offline|offline"]   timeout=50
    ute_admin_infomodel.Query Infomodel
    ...    query=every /MRBTS-1/RAT-1/BTS_L-4/EQM_L-1/RMOD_L-*/RU_L-1 is [stateInfo.proceduralState=swCheckDone]   timeout=400
    ute_admin_infomodel.Query Infomodel
    ...    query=every /MRBTS-1/RAT-1/BTS_L-4/EQM_L-1/RMOD_L-*/RU_L-1 is [stateInfo.availabilityStatus!=regex"Offline|offline"]   timeout=50
    Log to console    Every RU_L is swCheckDone
