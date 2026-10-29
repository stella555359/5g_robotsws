*** Settings ***
Documentation
...               Upgrade build to specified software
...               Usage      : robot -v Build:<Software build number> Build_upgrade.robot
...               Example    : robot -v Build:SBTS22R4_ENB_0000_000207_000000 Build_upgrade.robot
...                            Pass variable SCF_file to perform commissioning. [-v SCF_file:/home/ute/Scf.xml]
...               Author     : Rakshith B
...               Email Id   : Rakshith.b@nokia.com

Library           String
Library           DateTime
Library           OperatingSystem
Library           Common_script.py
Library           taf.transport.ssh    WITH NAME    ssh
Library           taf.collectors.core    WITH NAME    core
Library           taf.ul.alarms_watchdog   WITH NAME    alarm
Library           taf.sbts.oam.coam.admin    WITH NAME    COAM
Library           taf.collectors.btslog    WITH NAME    btslog

Test setup        Admin Setup
Test Teardown     Admin Teardown

*** Variables ***
${BTS_IP}                   192.168.255.129                                         # IP for BTS
${Update_timeout}           60m                                                     # Timeout for software update
${Download_path}            /home/ute/Downloads                                     # Software download path in test pc
${connection}               Active_Session                                          # Alias used for connection
${File_extension}           _release_BTSSM_downloadable_A54.zip                     # Build extension used in download and upgrade build
${wget_link}                https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build
${Build_download_timeout}   30m                                                     # Timeout to download build

*** Test Cases ***
Upgrade_software
    [Documentation]   Upgrade BTS with provided build
    Check build file and Upgrade build

*** Keywords ***
Admin Setup
    [Documentation]    This keyword checks the BTS status and whether the RU interface IP is reachable
    COAM.setup_admin    bts_host=${BTS_IP}    alias=${connection}    admin_api_log_dir=/tmp
    Wait Until Keyword Succeeds    10 times    30    Check BTS is OnAir
    ${BTS_details}      COAM.get_bts_info       connection=${connection}
    Set global variable    ${BTS_ID}     ${BTS_details['mrbtsID']}
    ${Active_alarm}    COAM.get_active_alarms    connection=${connection}
    LOG     ${Active_alarm}
    Start watching alarm
    Create testcase folder

Admin Teardown
    [Documentation]    This keyword check BTS status post execution and alarms in runtime
    Check BTS is OnAir
    alarm.check_detected_alarms
    alarm.stop_watching_alarms
    ${Active_alarm}    COAM.get_active_alarms    connection=${connection}
    LOG     ${Active_alarm}
    Run keyword And Ignore Error    Stop BTS logs and check
    COAM.teardown_admin    connection=${connection}

Start BTS logs
    [Documentation]    Starts BTS log in testpc
    Run    killall btslog
    btslog.create_btslog_collector    name=btslog
    ${status} 	Run Keyword And Return Status 		core.setup_collectors    names=btslog
    Run Keyword If 		'${status}'=='False'		Log to console		ERROR IN BTSLOG COLLECTION !!!
    core.set_suite_alias    btslog
    ${status} 	Run Keyword And Return Status 		core.start_collectors    names=btslog
	Run Keyword If 		'${status}'=='False'		Log to console		ERROR IN BTSLOG COLLECTION !!!

Stop BTS logs and check
    [Documentation]    Stops BTS log and check for crash
    core.stop_collectors    names=btslog
    ${status} 	Run Keyword And Return Status 		core.collect_collectors    names=btslog    target_dir=${log_path}
	Run Keyword If 		'${status}'=='False'		Log		ERROR IN BTSLOG COLLECTION !!!	WARN
    core.teardown_collectors    names=btslog
    ${check}    Run Keyword If 		'${status}'=='True'        Check_bts_logs    ${log_path}/btslog
    Run Keyword If    ${check} == False   Log   Unexpected prints found in syslog !!!    WARN

Start watching alarm
    [Documentation]     Start watching for alarms
    ${Active_alarm}    COAM.get_active_alarms    connection=${connection}
    ${allowed_alarms}    Expected alarm
    alarm.Watch alarms    allowed_alarms=${allowed_alarms}    connection_kwargs=${connection}       log_dir=/tmp

Expected alarm
    [Documentation]     Alarm exception list which are ignored in watch alarm
    ${allowed_alarm_1}    Create alarm    alarm_id=7220    fault_id=61524    fault_name=SSH enabled
    ${allowed_alarm_2}    Create alarm    alarm_id=7220    fault_id=4654     fault_name=Ethernet port security is disabled
    ${allowed_alarm_3}    Create alarm    alarm_id=7220    fault_id=61649    fault_name=LMP access via port 443
    ${allowed_alarm_4}    Create alarm    alarm_id=7220    fault_id=4655     fault_name=Service account root access is enabled
    ${allowed_alarm_5}    Create alarm    alarm_id=7220    fault_id=61652    fault_name=R&D Service Port enabled
    ${allowed_alarm_6}    Create alarm    alarm_id=7220    fault_id=61648    fault_name=LMP connectivity detected
    ${allowed_alarm_7}    Create alarm    				    fault_id=4592     fault_name=BTS Reset Cause
    ${allowed_alarm_8}    Create alarm    alarm_id=7108    fault_id=4298     fault_name=ToP reference missing
    ${allowed_alarm_9}    Create alarm    alarm_id=7116    fault_id=16       fault_name=Unit synchronization failed
    ${allowed_alarm_10}    Create alarm    alarm_id=7114    fault_id=4479     fault_name=Failure detected on assigned antennas
    ${allowed_alarm_11}    Create alarm    fault_name=No feedback signal
    ${allowed_alarm_12}    Create alarm    fault_name=TX out of order
    ${allowed_alarm_13}    Create alarm    alarm_id=7652    fault_id=6261
	...						fault_name=Failure in internal BTS connection or connection to 3rd party tool
    ${allowed_alarm_14}    Create alarm    fault_name=IP Traffic Capturing ongoing
    ${allowed_alarm_15}   Create alarm     fault_name=No X2 link available for a specific LTEENB
    ${allowed_alarm_16}   Create alarm     fault_name=No X2 link available
    ${allowed_alarm_17}   Create alarm     fault_name=Fronthaul Synchronization Error
    ${allowed_alarm_18}   Create alarm     fault_name=PPS reference missing
    ${allowed_alarm_19}   Create alarm     fault_name=Phase error exceeds the interference limit
    ${allowed_alarm_20}   Create alarm     fault_name=Mismatch of RU reported capabilities with static HW Validation information
    ${allowed_alarm_21}   Create alarm     fault_name=SSH Login Configuration failed
    ${allowed_alarms}     Create list    ${allowed_alarm_1}    ${allowed_alarm_2}    ${allowed_alarm_3}    ${allowed_alarm_4}    ${allowed_alarm_5}
    ...     ${allowed_alarm_6}      ${allowed_alarm_7}      ${allowed_alarm_8}      ${allowed_alarm_9}      ${allowed_alarm_10}
    ...     ${allowed_alarm_11}     ${allowed_alarm_12}     ${allowed_alarm_13}     ${allowed_alarm_14}     ${allowed_alarm_15}
    ...     ${allowed_alarm_16}     ${allowed_alarm_17}     ${allowed_alarm_18}     ${allowed_alarm_19}     ${allowed_alarm_20}	${allowed_alarm_21}
    [Return]    ${allowed_alarms}

Check BTS is OnAir
    [Documentation]    Check BTS status and fail if BTS status is not OnAir
    ${bts_status}    COAM.get_bts_statuses    connection=${connection}
    LOG    ${bts_status}
    Should Be Equal As Strings    ${bts_status["proceduralState"]}    OnAir
    Run Keyword If    '${bts_status["proceduralState"]}'=='OnAir'    LOG    BTS procedural state is now: ${bts_status["proceduralState"]}
    ...    ELSE    fail
    Log to console    \nBTS procedural state : ${bts_status["proceduralState"]}

Create testcase folder
    [Documentation]     Logs folder will be created
    ${val}    Run Keyword And Return Status    LOG    ${OUTPUT_DIR}/${Folder}/${TEST NAME}
    Run Keyword If    ${val} == False    Get Date
    Create directory    ${OUTPUT_DIR}/${TEST NAME}
    Set suite variable      ${log_path}      ${OUTPUT_DIR}/${TEST NAME}

Get Date
    [Documentation]     Current date is set as logs folder name
    ${date}    Get Current Date    result_format=%d_%m_%Y_%H%M%S_%f
    ${date}    Convert to String    ${date}
    Set global variable    ${Folder}    ${date}

Check build file and Upgrade build
    [Documentation]     Check the build file and download to testpc
    ${current_sw}    Check current software
    Run keyword if    "${current_sw}" != "${Build}"    Update BTS software
    ...    ELSE    Log to console    \nPlanned software is already active in BTS ${BTS_IP}

Check file in vm
    [Documentation]     Check the build file in testpc
    ${files}    List Files In Directory    ${Download_path}
    ${val}      Set Variable    False
    FOR    ${file}    IN    @{files}
        ${val}    Run keyword if    "${file}" == "${Build}${File_extension}"    Set variable    True
        ...    ELSE    Set variable     False
        Run keyword if    "${file}" == "${Build}${File_extension}"    Log to console    \nBuild file ${file} is already present in vm
        Exit For Loop If    ${val} == True
    END
    Run keyword if    ${val} == False    Download build

Download build
    [Documentation]     Download build to test pc
    ${Branch}    Split string    ${Build}    _
    Log to console    \nPlanned build branch is ${Branch}[0]
    Log to console    \nPlanned build is ${Build}
    ${File}     Setvariable     ${Build}${File_extension}
    ${cmd}    set variable    wget -o ${log_path}/wget_download_log.txt ${wget_link}/${Branch}[0]/${Build}/${File}
    Log to console    \nDownloading build ${Build} to path ${Download_path}, it may take some while
    Log to console    \nRunning command : ${cmd}
    ${rc}    Run And Return Rc    cd ${Download_path} && timeout ${Build_download_timeout} ${cmd}
    ${output}   Get File    ${log_path}/wget_download_log.txt
    Log     ${output}
    Run Keyword If    ${rc} == ${0}     Log to console      \nDownload successfull
    ...     ELSE        Run keywords    RUN    rm ${Download_path}/${Build}${File_extension}
    ...     AND     Log to console      \n${output}
    ...     AND     Log to console      \n\nDownload failed
    Should be equal     ${rc}   ${0}

Check current software
    [Documentation]     Check current software in BTS
    ${current_sw}    COAM.get_sw_version    timeout=10    connection=${connection}
	@{sw_list} 		String.Split String 	${current_sw}	 _
	${status} 	Run Keyword And Return Status 		Should Be True		${sw_list[2]}==9999
	${current_trunk_sw}		Run Keyword If 		'${status}'=='True'		Replace String      ${current_sw}       ${sw_list[0]}     SBTS00
	...		ELSE	Set variable    ${current_sw}
    Log to console    \nCurrent software in BTS ${BTS_IP} is ${current_sw}
    [Return]    ${current_trunk_sw}

Update BTS software
    [Documentation]     Upgrade software build in BTS
    Check file in vm
    Log to console    \nUpdating software in BTS ${BTS_IP} to ${Build}
    Start BTS logs
    COAM.update_software    sw_package=${Download_path}/${Build}${File_extension}    should_activate=True
    ...     timeout=${Update_timeout}    connection=${connection}
    Log to console    \nSoftware update completed, rebooting BTS ${BTS_IP} and waiting for reconnection
    Sleep   5m      reason=Wait for reboot and reconnection
    #COAM.reset_admin     connection=${connection}
    ${val}    Run Keyword And Return Status    Log to console    Performing site commissioning, SCF file : ${SCF_file}
    Run Keyword If    ${val} == True    COAM.Perform Commissioning      bts_id=${BTS_ID}        scf_file=${SCF_file}
    ...     skip_parameter_relation_errors=True     should_activate=True    timeout=300      connection=${connection}
    Log to console      \nWaiting for BTS status to be OnAir
    Wait Until Keyword Succeeds    15 times    60    Check for BTS status
    alarm.stop_watching_alarms
    Start watching alarm
    ${current_sw}    Check current software
    Run keyword if    "${current_sw}" == "${Build}"    Log to console    \nSoftware update successfull
    ...    ELSE    Log to console    \nSoftware update failed
    Run keyword And Continue On Failure     Stop BTS logs and check
    Snapshot download from BTS
    Should Be Equal As Strings    ${current_sw}    ${Build}
    Log to console      \nDeleting build file ${Build}${File_extension}
    RUN    rm ${Download_path}/${Build}${File_extension}
    Sleep   2m

Check for BTS status
    [Documentation]     Check for BTS on air after software upgrade
    ${bts_status}      COAM.get_bts_statuses       connection=${connection}
    Should Be Equal As Strings    ${bts_status["proceduralState"]}    OnAir
    Check cell status

Check cell status
	[Documentation]		Check all cell status
    ${cells}    COAM.get_ids_for_all    NRCEL    timeout=30s    connection=${connection}
    FOR    ${cell}    IN    @{cells}
		${cell_status}	COAM.get_cell_specific_info		cell_id=${cell}	connection=${connection}
		${administrativeState}		Set Variable		${cell_status['status']['administrativeState']}
		Run keyword And Continue On Failure		Should Be Equal		${administrativeState}		Unlocked
		${operationalState}	Set Variable	${cell_status['status']['operationalState']}
		Run keyword And Continue On Failure		Should Be Equal		${operationalState}		enabled
		${usageState}		Set Variable	${cell_status['status']['usageState']}
		Run keyword And Continue On Failure		Should Be Equal		${usageState}		Active
		${blockingState}		Set Variable	${cell_status['status']['blockingState']}
		Run keyword And Continue On Failure		Should Be Equal		${blockingState}		Unblocked
		${proceduralStatus}		Set Variable	${cell_status['status']['proceduralStatus']}
		Run keyword And Continue On Failure		Should Be Equal		${proceduralStatus}		configured
		${barringStatus}		Set Variable	${cell_status['status']['barringStatus']}
		Run keyword And Continue On Failure		Should Be Equal		${barringStatus}		unbarred
		${status}		Run Keyword And Return Status 		Set Variable	${cell_status['status']['availabilityStatus']}
		Run keyword And Continue On Failure		Should Not Be True		${status}
	END

Snapshot download from BTS
    [Documentation]     Collect BTS snaphot for packets verification
    Log to console      \nDownloading Snapshot from BTS
    ${check}    Run Keyword And Return Status 		COAM.collect_snapshot    target_file_name=${log_path}/Snapshot.zip
    ...     coverage=Full    force=True     timeout=2000s    connection=${connection}
    Run Keyword If    ${check} == False   Log   Snapshot download failed !!!    WARN
