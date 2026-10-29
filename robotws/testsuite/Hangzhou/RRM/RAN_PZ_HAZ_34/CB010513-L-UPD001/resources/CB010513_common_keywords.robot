*** Settings ***
Documentation     author: Chen Helen
...               contact: helen.1.chen@nokia-sbell.com
...               squad group: MMW_02

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/cell_addition_deletion_online.robot
Library           taf.collectors.btslog    WITH NAME   btslog
Library           taf.collectors.core   WITH NAME   core
Library           OperatingSystem

*** Variables ***


*** Keywords ***
Case_Setup
    [Documentation]    Author: Chen Helen
    ...                This keyword is setup
    [Arguments]    ${connection}=COAM    ${ue_index}=${0}    
    Log To Console    \n *** Case setup
	robot_common_operations.Common Case Setup

Case_Teardown
    [Documentation]    Author: Chen Helen
    ...                This keyword is teardown
	[Arguments]    ${is_case_teardown}=${True}    ${gnb_index}=${0}
    Log To Console    \n *** Case teardown
	ERR check in BTSlog
	${connection}    set variable if    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
	${test_fail_flag}    run keyword if    ${is_case_teardown}    run keyword if test failed
    ...    set variable    ${True}
	run keyword if    ${save_snapshot} and ${test_fail_flag}    run keywords
    ...    Generate suite log path                         AND
    ...    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}    AND
    ...    Save Coam Snapshot    target_dir=${SUITE_LOG_PATH}    connection=${connection}    AND
    ...    Capture RU logs    target_dir=${SUITE_LOG_PATH}    connection=${connection}     gnb_index=${gnb_index}
    ...    ELSE
    ...    log to console    don't collect snapshot in suite teardown!!!
	Run Keyword And Ignore Error     robot_common_operations.Common Suite Teardown

Start_BTS_Logs
    [Arguments]    ${name}=btslog     ${bts_logs_dir}=/opt/btslog    ${log_dir}=/tmp/btslog2    ${alias}=ute
	ssh.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...               username=${tl.test_pc.default_ssh_connection_details.username}
    ...               password=${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=${alias}
    ssh.execute  command=if [ ! -d ${log_dir} ]; then mkdir ${log_dir}; else rm ${log_dir}/*; fi    connection=${alias}
    btslog.create_btslog_collector    name=${name}    btslog_path=${bts_logs_dir}/btslog    
	...    btslog_launcher_path=${bts_logs_dir}/btslog_launcher    log_dir=${log_dir}
    core.setup_collectors        names=${name}
    core.start_collectors        names=${name}
    btslog.set_suite_alias       ${name}
	
Stop_BTS_Logs
    [Arguments]   ${name}=btslog    ${bts_logs_dir}=/tmp/btslog2
    core.stop_collectors         names=${name}
    core.collect_collectors      names=${name}
    core.teardown_collectors     names=${name}

Check_numMinPrbAllocDl_from_BTSLOG
    [arguments]    ${log_path}=/tmp/btslog2/    ${alias}=ute
	log to console    check btslog...
	ssh.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...               username=${tl.test_pc.default_ssh_connection_details.username}
    ...               password=${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=${alias}
    ssh.execute    command=cd ${log_path} && grep "BbpInfo for PRB CellSetup" ${log_path}*.LOG > test.txt    connection=${alias}
	${output}=    ssh.execute  command=awk 'BEGIN{FS="numMinPrbAllocDl:"} {print $NF}' ${log_path}/test.txt    connection=${alias}
	@{outputlist}    split string    ${output}    \r\n
	${outputlist}    remove duplicates    ${outputlist}    
	log list    ${outputlist}
	FOR    ${var}    IN    @{outputlist}
        run keyword if    '${var}' != ''    should be true    ${var}==96		
    END
	
ERR check in BTSlog
    [arguments]    ${log_path}=/tmp/btslog2/
    ${output} =    OperatingSystem.Run    ls ${log_path}
    Log    ${output}
    ${output} =    OperatingSystem.Run    grep -i ERR/L2-PS/ ${log_path}*.LOG
    Should Be Empty    ${output}
    ${output} =    OperatingSystem.Run    grep -e l1_application_rt.*ERR/ ${log_path}*.LOG
    Should Be Empty    ${output}
    ${output} =    OperatingSystem.Run    rm -f ${log_path}*.LOG
    Log    ${output}