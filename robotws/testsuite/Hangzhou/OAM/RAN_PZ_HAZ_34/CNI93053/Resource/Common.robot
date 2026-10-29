*** Settings ***
Documentation
...  author: dalwang
...  contact: dali.wang@nokia-sbell.com
Library     DateTime
Library     XML    True
Library     Collections
Library     OperatingSystem
Library     taf.transport.ssh    WITH NAME    csn
Library     taf.collectors.btslog       WITH NAME    btslog
Library     taf.collectors.core         WITH NAME    core
Library     taf.sbts.oam.coam.admin    WITH NAME    coam
Resource     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_log.robot
Resource    ../../common/taf_coam.robot
Resource    ../../common/coam_resource.robot
Resource    ../../common/qc_tag.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/log/symptom_collectors_hangzhou.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/common.robot
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001821/Resource/702.robot
Variables   ../../libraries/global_vars.py
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001545_AA/Resource/common_license.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Variables ***
&{fault_4459}    faultId=${4459}
&{fault_4655}    faultId=${4655}
&{fault_4654}    faultId=${4654}
&{fault_61652}    faultId=${61652}
&{fault_61524}    faultId=${61524}
&{fault_6502}    faultId=${6502}
&{fault_7523}    faultId=${7523}
&{fault_7100}    faultId=${7100}
@{ALLOWED_FAULT}    &{fault_4459}   &{fault_4655}   &{fault_4654}   &{fault_61652}   &{fault_61524}   &{fault_6502}
...               &{fault_7523}   &{fault_7100}
${TS_CASE_LOG_PATH}   ${OUTPUT_DIR}
*** Keyword ***
Case Setup for 93053
    [Documentation]   Setup WEBUI login and start btslog collection
    robot_common_operations.Common Case Setup
    run keyword and ignore error     COAM WEBUI Login   display=${${DEBUG}}
#    run keyword and ignore error     COAM WEBUI Login   display=true
    run keyword and ignore error     COAM WEBUI Whether Close Start Up View Window
    run keyword and ignore error     COAM Login
    ${is_cells_onair}   Run Keyword and Return Status   COAM Check All Cells Onair
    Log to Console   Check all cells should be onair result is ${is_cells_onair}
    ${scfname}    Return scf name for release
    Set Suite Variable   ${scfname}
    COAM Backup SCF
    #run keyword and ignore error   Start BTS Log Collection
    #DO NOT CLOSE FIREFOX AFTER WEBUI LOGIN HERE

Return scf name for release
       ${gnb_release}   Get gnb release    host=${LMP_ADDR}
       ${scfname}    Run keyword if   '${gnb_release}'=='TRUNK'     set variable   TRUNK
       ...   ELSE IF    '${gnb_release}'!='TRUNK'    String.Fetch From Right    string=${gnb_release}    marker=SBTS
       [Return]     ${scfname}

Common Setup
    COAM Try Connect gNB
    Wait Until Keyword Succeeds   3x   30s   COAM commissioning if not onair
    ${gnb_release}   Get gnb release
    Wait Until Keyword Succeeds   10m   1m   COAM WEBUI Login
    COAM Backup SCF
#    Wait Until Keyword Succeeds   3x   30s   Perform sub-feature SCF   feature_name=CB007308
    ${is_cells_onair}   Run Keyword and Return Status   COAM Check All Cells Onair
    Set GNB Oamtls Param
#    Add COAM User at VM
    Log to Console   Check all cells should be onair result is ${is_cells_onair}
    COAM WEBUI Whether Close Start Up View Window
    # Set QC Instance ID Test Tag
#
#Common Teardown
#    Run Keyword And Ignore Error   COAM Login
##    wait until keyword succeeds     5x    5min   COAM SCF Commission
#    Run Keyword And Ignore Error   COAM WEBUI Logout
#    Run Keyword And Ignore Error   COAM Logout
#    CI_interface.Common Case Teardown

Set QC Instance ID Test Tag
    ${qc_def}   Get Common Tags Info By SMOD and Release   file_path=${CURDIR}${/}qc_id_def.csv
    Set Case Common Tags By Test Aggregate   qc_def=${qc_def}


Wait for Cell Onair
    [Arguments]   ${wait_timer}   ${cell_index}
    ${status}   run keyword and return status   wait until keyword succeeds   ${wait_timer}   20s
    ...   COAM WEBUI Check Cell Status   cell_index=${cell_index}
    run keyword if  not ${status}   selenium_coam.refresh_page
    run keyword and ignore error    COAM WEBUI Whether Close Start Up View Window
    run keyword if  not ${status}   COAM WEBUI Check Cell Status   cell_index=${cell_index}
    run keyword if  not ${status}   Log to Console   Found cell ${cell_index} status not refresh automatically

Syslog Capture Start
    [Arguments]   ${name}=btslog
    ...           ${bts_logs_dir}=/tmp/btslog2
    log to console    syslog_start
    __Make empty BTS logs dir      ${bts_logs_dir}
    btslog.create_btslog_collector
    ...    name=${name}
    ...    log_dir=${bts_logs_dir}
    core.setup_collectors        names=${name}
    core.start_collectors        names=${name}
    btslog.set_suite_alias       ${name}

Syslog Capture Stop and Collect
    [Arguments]  ${bts_logs_dir}=/tmp/btslog2
    log to console    syslog_stop
    run keyword and ignore error    __Stop and collect btslog on local machine
    __Copy btslog to logs dir and clean BTSlog workspace    ${bts_logs_dir}


__Stop and collect btslog on local machine
    [Arguments]   ${name}=btslog
    core.stop_collectors         names=${name}
    core.collect_collectors      names=${name}
    core.teardown_collectors     names=${name}
    Run  rm -rf ${OUTPUTDIR}/5GC*

__Make empty BTS logs dir
    [Arguments]     ${bts_logs_dir}=/tmp/btslog2
    Run  if [ ! -d ${bts_logs_dir} ]; then mkdir ${bts_logs_dir}; else rm ${bts_logs_dir}/*; fi

__Copy btslog to logs dir and clean BTSlog workspace
    [Arguments]     ${bts_logs_dir}=/tmp/btslog2
    Run   if [ ! -d ${LOG_PATH}/${TESTNAME}/BTSlog ]; then mkdir ${LOG_PATH}/${TESTNAME}/BTSlog; else rm ${LOG_PATH}/${TESTNAME}/BTSlog/*; fi
    Run   cat ${bts_logs_dir}/*.LOG > ${bts_logs_dir}/SYSLOG.LOG
    Run   cp ${bts_logs_dir}/SYSLOG.LOG ${LOG_PATH}/${TESTNAME}/BTSlog/SYSLOG.LOG
    Run   rm -rf ${OUTPUTDIR}/5GC*

Print BTSlog
    [Arguments]    ${message_name}    ${bts_logs_dir}=/tmp/btslog2
    log to console    check btslog
    ${message} =    OperatingSystem.Grep File    ${bts_logs_dir}/SYSLOG.LOG    ${message_name}
    log to console   ${message}
    [Return]      ${message}

Common Suite Setup for COAM
#    COAM Create log directory    is_set_to_test_case_level=${False}
    [Arguments]  ${swconfig_flag}=${False}
    COAM Try Connect gNB
    Wait Until Keyword Succeeds   3x   30s   COAM commissioning if not onair
    robot_common_operations.Common Suite Setup
    run keyword if   ${swconfig_flag}    upload swconfig and reboot gnb
    Set Suite Variable    ${epc_log_path}    ${LOG_PATH}
    Create directory    ${epc_log_path}
#    Reboot UE For 93053
    ${gnb_release}     Get gnb release    host=${LMP_ADDR}
    Set Suite Variable    ${gnb_release}
    Run keyword if   '${gnb_release}'!='SBTS23R1'      Set Suite Variable    ${comma}   ,
    ...   ELSE    Set Suite Variable   ${comma}    ${EMPTY}

COAM Teardown gnb connections
    [Arguments]    ${connection}=COAM
    coam.teardown    connection=${connection}

upload swconfig and reboot gnb
    log to console   ***begin upload swconfig and reboot gnb!***
    ${ute_env}    run keyword and return status    run keywords
    ...    Variable Should Exist    ${CONFIGURATION}    AND    Variable Should Exist    ${ENB_BUILD}
    ${testline}   run keyword if    ${ute_env}    String.Fetch From Right    string=${CONFIGURATION}    marker=.
    ...           ELSE    set variable     ${testline_name}
    Upload Swconfig File
    ...   swconfig_path=${CURDIR}/../../../../../../commissionings/HGZ/${testline}/swconfig.txt
    COAM Login
    COAM Reset Site
    Wait Until Keyword Succeeds   7m   30s   COAM Check All Cells Onair
    log to console   ***upload swconfig and reboot gnb finished!***
    [Teardown]   COAM Logout

Reboot UE For 93053
    [Arguments]    ${ue_type}=huawei   ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    log to console    ue_reboot
    Run Keyword And Ignore Error   csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=${connection}
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} reboot
    ...   connection=${connection}
    Run Keyword And Ignore Error   csn.disconnect      connection=${connection}
