*** Settings ***
Documentation
...    author: Luo Tina
...    contact: tina.luo@nokia-sbell.com
...    squad group: MMW3
...    feature : 5GC000433-H & K

Resource      ../../common/taf_coam.robot
Library       taf.sbts.oam.coam.admin   WITH NAME   admin
Resource      5GC000433_common_keywords.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Variables     433_scf_modify.py
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Throughput_checking_from_GNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/gnb_sync.robot

*** Variables ***

*** Keywords ***
Collect snapshot log
    log to console     collect snapshot log
    ${local_file_path}    Catch Snapshot COAM    connection=GNB_OAM
    Set Suite Variable    ${local_file_path}


Delete snapshot
    [Documentation]
   	...  Removes directory
    [Arguments]    ${local_file_path}   ${unzipped}
    run  rm -rf ${local_file_path}
    run  rm -rf ${unzipped}

Get snapshot and check energy consumption counter
    ${time}=    Get Current Date    result_format=%Y%m%d-%H%M%S
    set suite variable    ${unzipped}    /home/ute/Downloads/s${time}
    set suite variable    ${unzipped_PM}    ${unzipped}/PM
    csn.connect_to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...               username=${tl.test_pc.default_ssh_connection_details.username}
    ...               password=${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=ute
    csn.execute    command=unzip -o ${local_file_path} -d ${unzipped}    connection=ute
    ${files}=    OperatingSystem.Run    ls /home/ute/Downloads/s${time}/ | grep _1011_part_
    ${PM_files_list}    Get correct file with PM    ${files}
    ${parsed_files}=    Extract and parse PM files    ${PM_files_list}    ${unzipped_PM}
    PM files should contain energy consumption counter      ${parsed_files}

Get correct file with PM
    [Arguments]     ${files}
    @{files_list}=    Split String    ${files}    \n
    ${num_of_files}    Get Length    ${files_list}
    @{PM_files_list}    create list
    FOR   ${i}   IN RANGE   ${num_of_files}
        ${no}   evaluate    ${num_of_files} - ${i}
        ${PM_file}=    Get Lines Containing String    ${files}    _1011_part_${no}
        OperatingSystem.Run    unzip ${unzipped}/${PM_file} -d ${unzipped_PM}
        ${RD_files}=    OperatingSystem.Run    ls ${unzipped}/PM | grep PM.BTS.*xml.gz
        @{RD_files_split_list}=    Split String    ${RD_files}    \n
        ${PMfile}=    get length    ${RD_files_split_list}
        Run Keyword If    ${PMfile}>1    Append to List    ${PM_files_list}    @{RD_files_split_list}
        Exit for loop if    ${PM_files_list}
    END
    [Return]    ${PM_files_list}

#    ${second_file}    evaluate    ${num_of_files} - 1
#    ${thrid_file}    evaluate    ${num_of_files} - 2
#    @{three_last_files}    create list   ${num_of_files}    ${second_file}      ${thrid_file}
#    @{PM_files_list}    create list
#    FOR    ${no}    IN    @{three_last_files}
#        ${PM_file}=    Get Lines Containing String    ${files}    _1011_part_${no}
#        OperatingSystem.Run    unzip ${unzipped}/${PM_file} -d ${unzipped_PM}
#        ${RD_files}=    OperatingSystem.Run    ls ${unzipped}/PM | grep PM.BTS.*xml.gz
#        @{RD_files_split_list}=    Split String    ${RD_files}    \n
#        ${PMfile}=    get length    ${RD_files_split_list}
#        Run Keyword If    ${PMfile}>1    Append to List    ${PM_files_list}    @{RD_files_split_list}
#        Exit for loop if    ${PM_files_list}
#    END
#    [Return]    ${PM_files_list}

Extract and parse PM files
    [Arguments]    ${PM_files_list}    ${unzipped_PM}
    ${num_of_PM_files}    Get Length    ${PM_files_list}
    ${no_PM_file}    evaluate    ${num_of_PM_files} - 1
    Run    gzip -d ${unzipped_PM}/${PM_files_list[${no_PM_file}]}
    ${extracted_file}    Fetch From Left    ${PM_files_list[${no_PM_file}]}    .gz
    csn.SendCommand    command=cat ${unzipped_PM}/${extracted_file}    connection=ute
    ${PMfile}    csn.read output    connection=ute
    Set Variable   ${PMfile}
    [Return]    ${PMfile}

PM files should contain energy consumption counter
    [Arguments]    ${parsed_files}
    ${M40002C0_matched_content}    Should Match Regexp      ${parsed_files}    M40002C0\>[1-9]\d*
    ${M40002C1_matched_content}    Should Match Regexp      ${parsed_files}    M40002C1\>[1-9]\d*
    ${M40002C2_matched_content}    Should Match Regexp      ${parsed_files}    M40002C2\>[1-9]\d*
    ${M40003C0_matched_content}    Should Match Regexp      ${parsed_files}    M40003C0\>[1-9]\d*
    ${M40003C1_matched_content}    Should Match Regexp      ${parsed_files}    M40003C1\>[1-9]\d*
    ${M40003C2_matched_content}    Should Match Regexp      ${parsed_files}    M40003C2\>[1-9]\d*
    ${M40003C3_matched_content}    Should Match Regexp      ${parsed_files}    M40003C3\>[1-9]\d*
    ${M40003C4_matched_content}    Should Match Regexp      ${parsed_files}    M40003C4\>[1-9]\d*
    ${M40003C5_matched_content}    Should Match Regexp      ${parsed_files}    M40003C5\>[1-9]\d*
    ${M40004C0_matched_content}    Should Match Regexp      ${parsed_files}    M40004C0\>[1-9]\d*
    ${M40004C1_matched_content}    Should Match Regexp      ${parsed_files}    M40004C1\>[1-9]\d*
    ${M40004C2_matched_content}    Should Match Regexp      ${parsed_files}    M40004C2\>[1-9]\d*
    ${M40004C3_matched_content}    Should Match Regexp      ${parsed_files}    M40004C3\>[1-9]\d*
    ${M40004C4_matched_content}    Should Match Regexp      ${parsed_files}    M40004C4\>[1-9]\d*
    ${M40004C5_matched_content}    Should Match Regexp      ${parsed_files}    M40004C5\>[1-9]\d*

Check BTS Counter M40002C of 5GC000433-H-K for case 003
    [Arguments]    ${interval}
    log to console    Check BTS Counter M40002C of 5GC000433-H-K for case 003
	Connect to Common Unit Master
	selenium login and disable screen lock
	${value_2C0}    Get PM Counter via Webem for 5GC000433-H-K    counter_id=M40002C0    interval=${interval}
	Should be True    ${value_2C0} == ${value_4C0}
    ${value_2C1}    Get PM Counter via Webem for 5GC000433-H-K    counter_id=M40002C1    interval=${interval}
    Should be True   ${M40003C2} *1.05 >${value_2C1} > ${M40003C2} *0.95
	${value_2C2}    Get PM Counter via Webem for 5GC000433-H-K    counter_id=M40002C2    interval=${interval}
	Should be True    ${value_2C2} == ${value_2C0} + ${value_2C1}
    selenium logout and close browser

Check BTS Counter M40002C of 5GC000433-H-K for case 004
    [Arguments]    ${interval}
    log to console   Check BTS Counter M40002C of 5GC000433-H-K for case 004
	Connect to Common Unit Master
	selenium login and disable screen lock
	${value_2C0}    Get PM Counter via Webem for 5GC000433-H-K    counter_id=M40002C0    interval=${interval}
	Should be True    ${M40004C0} *1.05 >${value_2C0} > ${M40004C0} *0.95
    ${value_2C1}    Get PM Counter via Webem for 5GC000433-H-K    counter_id=M40002C1    interval=${interval}
    Should be True    ${value_2C1} == ${value_3C2}
	${value_2C2}    Get PM Counter via Webem for 5GC000433-H-K    counter_id=M40002C2    interval=${interval}
	Should be True    ${value_2C2} == ${value_2C0} + ${value_2C1}
    selenium logout and close browser

Check BTS Counter M40004C of 5GC000433-H-K
    [Arguments]    ${interval}
    log to console   Check BTS Counter M40004C of 5GC000433-H-K
	Connect to Common Unit Master
	selenium login and disable screen lock
	${value_4C0}    Get PM Counter via Webem for 5GC000433-H-K    counter_id=M40004C0    interval=${interval}
	Set suite Variable     ${value_4C0}
	Should be True    ${M40004C0} *1.05 >${value_4C0} > ${M40004C0} *0.95
    ${value_4C1}    Get PM Counter via Webem for 5GC000433-H-K    counter_id=M40004C1    interval=${interval}
    Should be True    ${M40004C1_3} *1.05 >${value_4C1} > ${M40004C1_3} *0.95
	${value_4C2}    Get PM Counter via Webem for 5GC000433-H-K    counter_id=M40004C2    interval=${interval}
	Should be True    ${M40004C1_3} *1.05 >${value_4C2} > ${M40004C1_3} *0.95
	${value_4C3}    Get PM Counter via Webem for 5GC000433-H-K    counter_id=M40004C3    interval=${interval}
	Should be True    ${M40004C1_3} *1.05 >${value_4C3} > ${M40004C1_3} *0.95
	${value_4C4}    Get PM Counter via Webem for 5GC000433-H-K    counter_id=M40004C4    interval=${interval}
	Should be True    ${M40004C4_5} *1.05 >${value_4C4} > ${M40004C4_5} *0.95
	${value_4C5}    Get PM Counter via Webem for 5GC000433-H-K    counter_id=M40004C5    interval=${interval}
	Should be True    ${M40004C4_5} *1.05 >${value_4C5} > ${M40004C4_5} *0.95
    selenium logout and close browser

Check BTS Counter M40003C of 5GC000433-H-K
    [Arguments]    ${interval}
    log to console    Check BTS Counter M40003C of 5GC000433-H-K
	Connect to Common Unit Master
	selenium login and disable screen lock
	${value_3C0}    Get PM Counter via Webem for 5GC000433-H-K    counter_id=M40003C0    interval=${interval}
	Should be True     ${M40003C0_1} *1.05 >${value_3C0} > ${M40003C0_1} *0.95
    ${value_3C1}    Get PM Counter via Webem for 5GC000433-H-K    counter_id=M40003C1    interval=${interval}
    Should be True     ${M40003C0_1} *1.05 >${value_3C1} > ${M40003C0_1} *0.95
	${value_3C2}    Get PM Counter via Webem for 5GC000433-H-K    counter_id=M40003C2    interval=${interval}
	Set suite Variable     ${value_3C2}
	Should be True    ${M40003C2} *1.05 >${value_3C2} > ${M40003C2} *0.95
	${value_3C3}    Get PM Counter via Webem for 5GC000433-H-K    counter_id=M40003C3    interval=${interval}
	Should be True    ${M40003C3_5} *1.05 >${value_3C3} > ${M40003C3_5} *0.95
	${value_3C4}    Get PM Counter via Webem for 5GC000433-H-K    counter_id=M40003C4    interval=${interval}
	Should be True    ${M40003C3_5} *1.05 >${value_3C4} > ${M40003C3_5} *0.95
	${value_3C5}    Get PM Counter via Webem for 5GC000433-H-K    counter_id=M40003C5    interval=${interval}
	Should be True    ${M40003C3_5} *1.05 >${value_3C5} > ${M40003C3_5} *0.95
    selenium logout and close browser

#5GC000433-H-K Case Preparation
#    [Arguments]    ${gnb_index}=0
#    log to console    \n*** 5GC000433 SISO Coam Suite Setup***
#    ${connection}    set variable if    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
#    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
#    ${Active_SW_version}    Get Active SW Version    connection=${connection}
#    set suite variable      ${Active_SW_version}
#    ${gNb_CuType}   Get gNB CU type    connection=${connection}
#    set suite variable      ${gNb_CuType}
#    Generate suite log path
#    set suite variable      ${SAVE LOG DIRECTORY}    ${SUITE_LOG_PATH}
#    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
#    ...    connection=${connection}    gnb_index=${gnb_index}
#    ${Golden_SCF_Path}    Download SCF Download Via Rest Api    scf_dir_path=${SAVE LOG DIRECTORY}    connection=${connection}
#    set suite variable    ${Golden_SCF_Path}
#    ${mrbtsID}    ${nrbtsID}   Get mrbtsID and nrbtsID via SCF for gNB    scf_path=${Golden_SCF_Path}
#    log to console  MRBTS_ID:${mrbtsID}, NRBTS_ID:${nrbtsID}
#    set suite variable  ${mrbtsID}
#    set suite variable  ${nrbtsID}
#    run keyword if     '${testline_name}' == 'null'    add fault to the allowed fault list    faultId=${4681}
#    run keyword if     '${gNb_CuType}'=='NSA' or '${gNb_CuType}'=='SA+NSA'
#    ...    Run Keyword And Ignore Error    get eNB active version
#
#    ${output_scf_file_path}    coam_gnb_classical.COAM Modify scf file    scf_file_path=${Golden_SCF_Path}
#    ...    scf_parameters_list=${MODIFY_SCF_433}
#    &{result}    admin.perform_commissioning    scf_file=${output_scf_file_path}
#    ...    timeout=300    skip_parameter_relation_errors=${True}    connection=GNB_OAM
#    wait until keyword succeeds   25m   1m       COAM Check All Cells Onair    connection=GNB_OAM
#	${wait_time}    Get wait value minutes    interval=15min
#    sleep    ${wait_time}min
#	sleep    15min

5GC000433-H-K Case Preparation
    log to console    \n*** 5GC000433 Case Preparation***
    ${output_scf_file_path}    coam_gnb_classical.COAM Modify scf file    scf_file_path=${Golden_SCF_Path}
    ...    scf_parameters_list=${MODIFY_SCF_433}
    &{result}    admin.perform_commissioning    scf_file=${output_scf_file_path}
    ...    timeout=300    skip_parameter_relation_errors=${True}    connection=GNB_OAM
    wait until keyword succeeds   25m   1m       COAM Check All Cells Onair    connection=GNB_OAM
	${wait_time}    Get wait value minutes    interval=15min
    sleep    ${wait_time}min
	sleep    15min

Get PM Counter via Webem for 5GC000433-H-K
    [Documentation]  Author: tingting.zhong@nokia-sbell.com
    [Arguments]    ${counter_id}    ${interval}   ${dist_name}=${None}  ${counter_type}=BTS    ${full_path}=${None}
    ${content}    Get PM Counter content via Webem    counter_id=${counter_id}   dist_name=${dist_name}
    ...     counter_type=${counter_type}    full_path=${full_path}
    ${time_list}    get dictionary keys   ${content}
    sort list    ${time_list}
    ${status}    ${last_time}   run keyword and ignore error    set variable    ${time_list[-1]}
    ${current_time}   get time from gnb
    ${end_time}    robot.libraries.DateTime.add_time_to_date    ${last_time}    ${interval}
    ${diff}    robot.libraries.DateTime.subtract_date_from_date    ${current_time}     ${end_time}
    ${diff1}    robot.libraries.DateTime.subtract_time_from_time    ${diff}    ${interval}
    should be true    ${diff1}<30
    ${value}    get_from_dictionary   ${content}    ${last_time}
    [Return]    ${value}
