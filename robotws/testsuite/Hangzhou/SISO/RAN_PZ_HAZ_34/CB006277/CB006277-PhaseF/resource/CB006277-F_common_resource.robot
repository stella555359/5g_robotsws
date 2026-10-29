*** Settings ***
Documentation
...    author: Liu Yue
...    contact: yue.2.liu@nokia-sbell.com
...    squad group: SG_05
...    feature : CB006277-F

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot

*** Variables ***
${host_addr}    ${tl.test_pc.default_ssh_connection_details.addr}
${host_username}     ${tl.test_pc.default_ssh_connection_details.username}
${host_password}     ${tl.test_pc.default_ssh_connection_details.password}
*** Keywords ***
General_SiSo_modify_FH_delay_parameter_cableLenghtRangeMin_ABIO
    Selenium Login And Disable Screen Lock
    Modify actForceUnitAutoReset Parameter    actForceUnitAutoReset=true
    ${modify_params}  create list
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${ru_index}
        ...    filter_param=Minimum value of range of cable length between baseband and radio
        ...    p_name=cableLenghtRangeMin  value=30
        append to list  ${modify_params}  ${item}
    END
    Modify Parameters On Webem    modify_params=${modify_params}
    wait until keyword succeeds   10m   60s   Verify all cells should be onair
    ${modify_params2}  create list
    ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
    ...    filter_param=Minimum value of range of cable length between baseband and radio  p_name=cableLenghtRangeMin  value=1
    append to list  ${modify_params2}  ${item}
    Modify Parameters On Webem    modify_params=${modify_params2}
	wait until keyword succeeds   10m   60s   Verify all cells should be onair
	sleep    3s
	check log to verify TimingsCalculation
	
check log to verify TimingsCalculation
    Save Coam Snapshot 1    target_dir=${SAVE LOG DIRECTORY}
	log    ${SAVE LOG DIRECTORY}
	Run Process    unzip ${SAVE LOG DIRECTORY}Snapshot_${time_stamp}.zip -d ${SAVE LOG DIRECTORY}tmp    shell=True
  Run Process    rm -r ${SAVE LOG DIRECTORY}tmp/BTS_p*.zip;rm -r ${SAVE LOG DIRECTORY}tmp/BTS_L*.zip;rm -r ${SAVE LOG DIRECTORY}tmp/BTS*_123*.zip
    ...    shell=True
	Run Process    cd ${SAVE LOG DIRECTORY}tmp;ls *.zip | xargs -n1 unzip;unzip *_1011_runtime.zip -d oam_runtime    shell=True
	csn.connect_to    hostname=${host_addr}    username=${host_username}    password=${host_password}    alias=VM
	${output1}=     csn.execute    command=xzcat ${SAVE LOG DIRECTORY}tmp/oam_runtime/runtime_BTSOM.log.xz | grep ECPRI_DELAY_L
    ...     connection=VM
	csn.disconnect    connection=VM
	csn.connect_to    hostname=${host_addr}    username=${host_username}    password=${host_password}    alias=VM
	${output2}=     csn.execute    command=xzcat ${SAVE LOG DIRECTORY}tmp/oam_runtime/runtime_BTSOM.log.xz | grep TimingsCalculation
    ...     connection=VM
	csn.disconnect    connection=VM
	Should Not Be Empty    ${output1}
	Should Not Be Empty    ${output2}
	[Teardown]    Run Process    rm -r ${SAVE LOG DIRECTORY}tmp    shell=True
Save Coam Snapshot 1
    [Arguments]    ${target_dir}=${OUTPUT DIR}     ${coverage}=Full    ${force}=0     ${timeout}=900    ${connection}=GNB_OAM
    ${time_stamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    set suite variable    ${time_stamp}
    ${snapshot_path}      Set Variable    ${target_dir}/Snapshot_${time_stamp}.zip
    ${log_status}         Run Keyword And Return Status    coam.Get Snapshot
    ...                   target_file_name=${snapshot_path}
    ...                   coverage=${coverage}
    ...                   force=${force}
    ...                   connection=${connection}
    ...                   timeout=${timeout}
    Run Keyword If        ${log_status}    Log To Console    Collecting Snapshot [DONE]
General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed_acceptedClockClass
    Selenium Login And Disable Screen Lock
	@{clock_class_list}    create list    8    
    Modify Accepted clock class list with activate ignore error    acceptedClockClass=${clock_class_list}
	Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds    10min    30s    Alarm in Given Alarm list Present
	[Teardown]  run keywords    Close Start Up View    timeout=60    AND
    ...    Commissioning SCF And Check On Air      scf_path=${Golden_SCF_Path}    AND
    ...    Selenium Logout And Close Browser


Modify Accepted clock class list with activate ignore error
    [Arguments]  ${acceptedClockClass}
    log to console    \n Modify Accepted clock class list to ${acceptedClockClass}
    ${modify_params}    create list
	${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1
	...    filter_param=Accepted clock class list  p_name=acceptedClockClass  value=${acceptedClockClass}
    append to list  ${modify_params}  ${item}
    ${value}    Get Parameter Via Webem    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1
	...    filter_param=Accepted clock class list
    Modify Parameters On Webem    modify_params=${modify_params}    despite_errors=${True}
    [Return]  ${value}
	
