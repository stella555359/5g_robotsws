*** Settings ***
Documentation     [PURPOSE]
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/ca_swm_general.robot
#Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_syve.robot
#Library           hran_tools
Library           ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/tool_ping.py
Library           taf.sbts.oam.coam.admin
Library           ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/file_operation.py


*** Variables ***
${TARGET_SW_NAME}    ${None}    # SW package name. If not given, TC will choose newest package in a directory.
${TARGET_SW_DIR}    /home/ute/btsauto/TARGET_SW/
#...    # Directory in which TC should look for sw package. If not given, '/home/ute/btsauto/TARGET_SW' shall be used
${UPDATE_TIMEOUT}    1500    # Timeout for Download and Activation [sec]
${SW Download Timeout}    1800
${SW Activation Timeout}    150  # Given in seconds; That is a timeout for SW download and activation (without reset)
${Ping loss timeout}    420  # Timeout for ping loss during reset
${Ping regain timeout}    600  # Timeout for ping regain during reset
${BTS_OnAir_Timeout}    15  # Timeout for BTS on Air (in minutes)
${Test_Timeout}    30  # Test timeout (in minutes)


*** Keywords ***
TC_CB007335_02_02_Copy_BTS_SW_and_configuration_from_active_to_passive_Netact
    [Documentation]    ********************
    ...    1. Basic information
    ...    ********************
    ...
    ...    **Request ID:** TAT-14706
    ...
    ...    ***********************************************************
    ...    2. Description
    ...    ***********************************************************
    ...    Main purpose of this test is to BTS allows to copy SW and configuration
    ...    on the active partition to the passive partition.
    ...    ******************
    ...    History of changes
    ...    ******************
    [Timeout]    50 minutes
    Set Tags    CA-SWM    PHASE-CRT    SW-SBTS22R2    FEATURE-CB007335
    Step 1: Check initial BTS state and alarm status
    Step 2: Compare active and passive SW version
    Step 3: Create Netact plan without healthy check plan
    Step 4: Check version and Date after sync
    Step 5: Check final BTS state and alarm status
    Step 6: Recover BTS by Update software to make A-P different

Step ${index}: Check ${when} BTS state and alarm status
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${index}: <description>
    ...        ${when}: <description>
    Log Step Header  Step ${index}: Check ${when} BTS state
    Log  Will now check if BTS is OnAir, timeout=${BTS_OnAir_Timeout}min, interval=10sec  console=${TRUE}
    Wait until keyword succeeds  ${BTS_OnAir_Timeout} min  10 sec  Verify BTS states
    Log Important Message  BTS is OnAir, all cells and modules are in expected states

Step ${index}: Check ${when} alarms status
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${index}: <description>
    ...        ${when}: <description>
    Log Step Header  Step ${index}: Check ${when} alarms status
    ${alarms_status}    ${alarms_msg}=    Run Keyword If    ${alarms_check}    Run Keyword And Ignore Error
    ...    Admin Check Active Alarms    expected_patterns=${expected_alarms}   ignored_patterns=${ignored_alarms}
    ...    critical_patterns=${critical_alarms}
    Run keyword if    '${alarms_status}'=='FAIL'
    ...    Log    Critical fail while checking alarms: ${alarms_msg}    console=${TRUE}
    ...    ELSE IF    ${alarms_msg}    Set test restriction    Unexpected alarms are present: ${alarms_msg}

Step ${index}: Compare active and passive SW version
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${index}: <description>
    Log Step Header    Step ${index}: Compare active and passive SW version
    ${software_info}    taf.sbts.oam.coam.admin.Get Software Info
    Log    Active SW: ${software_info['Active SW version']}    console=${TRUE}
    Log    Passive SW: ${software_info['Passive SW version']}    console=${TRUE}
    ${active_sw_before_list}    Get Regexp Matches    ${software_info['Active SW version']}    SBTS([09]{0,2}).+
    ${passive_sw_before_list}    Get Regexp Matches    ${software_info['Passive SW version']}    SBTS([09]{0,2}).+
    Set Test Variable    ${active_version_before_sync}    ${active_sw_before_list[0]}
    Set Test Variable    ${passive_sw_before_sync}    ${passive_sw_before_list[0]}
    Should not be equal  ${active_version_before_sync}  ${passive_sw_before_sync}

Step ${index}: Create Netact plan without healthy check plan
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${index}: <description>
    Run keyword and ignore error        Postcondition Netact with TAF
    Precondition Netact with TAF
    ${mo_id}=    Set Variable    PLMN-PLMN/MRBTS-${BTS_INFO.ID}
    ${actual_conf}=    taf.nms.netact.Get Actual Configuration
    ${managed_object}=    taf.nms.netact.Get Managed Object    ${actual_conf}    ${mo_id}
    Copy To Passive Without Health Check
    Delete COPYSWTOPASSIVEREQ MO In SCF
    upload and provision scf to site	${CURDIR}/02_05_plan_files/  CB007335_copy_to_passive_without_health_check.xml
    wait until keyword succeeds		15min	10s		Copy To Passive_request Complete
    ${sw_CP_start}=  Get current date
    set test variable    ${sw_CP_start}
    Postcondition Netact with TAF

Copy To Passive Without Health Check
    [Documentation]    Short description.
	Delete COPYSWTOPASSIVEREQ MO In SCF
	upload and provision scf to site	${CURDIR}/02_05_plan_files/	 CB007335_copy_to_passive_without_health_check.xml
	wait until keyword succeeds		15min	10s		Copy To Passive_request Complete

Delete COPYSWTOPASSIVEREQ MO In SCF
    [Documentation]    Short description.
	${objs}=	taf.sbts.oam.coam.admin.Get Managed Objects		COPYSWTOPASSIVERES_R
	Log List	${objs}
	${is_contain}=		Run Keyword And Return Status	Should Not Be Empty		${objs}
	Run Keyword If	${is_contain}==${TRUE}
	...    upload and provision scf to site	${CURDIR}/02_05_plan_files/  CB007335_del_COPYSWTOPASSIVEREQ.xml
	${objs}=	taf.sbts.oam.coam.admin.Get Managed Objects		COPYSWTOPASSIVERES_R
	Log List	${objs}
	${is_contain}=		Run Keyword And Return Status	Should Be Empty	  ${objs}

upload and provision scf to site
	[Arguments]		${path}		${file}
	[Documentation]    kw for upload ${path}/${file} to netact then upload and provision scf to network
	Upload SCF To NetAct	${path}		${file}
	taf.nms.netact.Import Configuration	file_name=${file_name}		plan_name=${file_name}	ui_values=${TRUE}	verbose=${TRUE}
	taf.nms.netact.provision_plan	plan_name=${file_name}
	SSHLibrary.Start Command	rm /var/opt/oss/global/racops/import/${file_name}

Copy To Passive_request Complete
    [Documentation]    Short description.
    ${actual_conf}=    taf.nms.netact.Get Actual Configuration
    ${copy_para}    taf.nms.netact.Get Managed Object    ${actual_conf}
    ...    PLMN-PLMN/MRBTS-${BTS_INFO.ID}/MNL-1/CMD-1/COPYSWTOPASSIVEREQ-1/COPYSWTOPASSIVERES-1
    ${copy_str}    Convert to string    ${copy_para}
    ${copy_str_res}    Run keyword and return status    should not be empty    ${copy_str}
    Run Keyword If	'${copy_str_res}'=='${TRUE}'   Log   Copy To Passive_request Complete!

Step ${index}: Check version and Date after sync
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${index}: <description>
    Precondition Netact with TAF
    ${parameters_1}=   Create Dictionary    -lteHwContentInUse=${TRUE}    -sranBtsHwContentInUse=${TRUE}
    taf.nms.netact.Upload Configuration    PLMN-PLMN/MRBTS-${BTS_INFO.ID}    parameters=${parameters_1}
    ${time_stamp}  Run  date +%F_%H-%M-%S
    taf.nms.netact.Export Configuration
    ...    ta_check_actual_${time_stamp}.xml    local_dir=${BTSFiles}    dist_names=PLMN-PLMN/MRBTS-${BTS_INFO.ID}
    set test variable  ${XML_fullpath}  ${BTSFiles}/ta_check_actual_${time_stamp}.xml
    ${para_dict}=    Create dictionary
    set to Dictionary  ${para_dict}  activeSWReleaseVersion=${active_version_before_sync}
    set to Dictionary  ${para_dict}  passiveSWReleaseVersion=${active_version_before_sync}
    ${para_dic_result}=
    ...    Check paramers from XML  ${XML_fullpath}    PLMN-PLMN/MRBTS-${BTS_INFO.ID}/MNL-1/MNL_R-1    ${para_dict}
    Should not be empty    ${para_dic_result['latestCopyDate']}
    ${res_dic}=    Create dictionary    result  0
    ${check_res_result}=    Check paramers from XML  ${XML_fullpath}
    ...    PLMN-PLMN/MRBTS-${BTS_INFO.ID}/MNL-1/CMD-1/COPYSWTOPASSIVEREQ-1/COPYSWTOPASSIVERES-1  ${res_dic}
    ${sw_CP_end}=  Get current date
    set test variable    ${cp_expected_time}   360
    Operation_KPI_Check    ${sw_CP_end}    ${sw_CP_start}    ${cp_expected_time}    cp_active_to_passive
    Postcondition Netact with TAF

Step ${index}: Recover BTS by Update software to make A-P different
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${index}: <description>
    Find path to SW package
    Run Keyword If  '${Target SW path}'== ${None}   Fail
    ${software_update_start}=  Get current date
    ${sw_update_result}  ${sw_update_msg}=  Run keyword and ignore error
    ...  taf.sbts.oam.coam.admin.Update Software  ${Target SW path}  True  3000s
    Run keyword if  '${sw_update_result}'=='FAIL'  Set Test Failed  Software update failed: ${sw_update_msg}
    ${ping loss status}  Run keyword and return status
    ...    Wait For Target To Be Not Reachable  hostname=${SMOD1['TRS_IP']}  timeout=240
    Run keyword if  ${ping loss status}==${FALSE}
    ...    Log    BTS RESET after successful sw update DID NOT OCCUR   console=${TRUE}
    ...    ELSE    Log    BTS is resetting after successful sw update          console=${TRUE}
    ${ping regain status}  Run keyword and return status
    ...    Wait For Target To Be Reachable  hostname=${SMOD1['TRS_IP']}  timeout=300
    Run keyword if  ${ping regain status}==${False}  Set Test Failed  Ping has not been regained within timeout
    ${ping stable status}  Run keyword and return status
    ...    Check If Target Is Stable  ${SMOD1['TRS_IP']}  min_uptime=120  max_downtime=0  timeout=121
    Run keyword if  ${ping stable status}==${False}  Set Test Failed  Ping has not been available for 120 seconds
    Wait Until Keyword Succeeds  5 min  10 sec  Fail if connection with admin is not available

Fail if connection with admin is not available
    [Documentation]    Short description.
    ${status}=  Run keyword and return status   taf.sbts.oam.coam.admin.Get mrbts state
    Run keyword if  ${status}  Return from keyword
    ${admin_reset_status}  Run keyword and return status  taf.sbts.oam.coam.admin.Reset admin
    ${status}=  Run keyword and return status   taf.sbts.oam.coam.admin.Get mrbts state
    Run keyword if  ${status}  Return from keyword
    Fail  ${admin_reset_status}
