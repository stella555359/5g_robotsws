*** Settings ***
Documentation
...    Author:          Bartlomiej Lebda | Jakub Klein
...    Maintainer:      Bartlomiej Lebda | Jakub Klein
...    Contact:         bartlomiej.lebda@nokia.com jakub.klein@nokia.com
...    Team in charge:  I_EXT_PZ_1_WRO_6_GMS
...    Description:     The following keywords are responsible for BTSlog collection

Library     taf.collectors.core      WITH NAME   core
Library     taf.collectors.btslog    WITH NAME   btslog
Library     taf.sbts.oam.coam.admin    WITH NAME     admin_cli
Library     taf.transport.ssh
Library     BuiltIn
Library     String
Library     DateTime
Resource    ../Admin_CLI/Basic_WebEM_operation.robot
Resource    ../Component_states/BasicKeywords.robot
Resource    ../Connections/Connectivity_keywords.robot

*** Variables ***
${LMP_IP}=    ${tl.gnbs[0].du.airscale.common_units[0].lmp_connection.addr}
${SysLogOutputMode}=    0x10041=5
${flag2}=    0x10040=1
${flag3}=    0x1003F=1
${SYSTEM_ENB_LOCAL_IP}=        192.168.255.1
${SYSTEM_ENB_SSH_USERNAME}=    toor4nsn
${SYSTEM_ENB_SSH_PASSWORD}=    oZPS0POrRieRtu
${SYSTEM_ALIAS_ASIK}=          asik
${SYSTEM_ALIAS_PROXY}=         rmod
${SYSTEM_RMOD_LOCAL_IP}
${SYSTEM_RMOD_SSH_USERNAME}    root
${SYSTEM_RMOD_SSH_PASSWORD}    umniedziala

*** Keywords ***
Save Test Logs
    [Arguments]    &{args}
    ADMIN Collect Snapshot
    BTSLOG Collect btslog
    ${save_pcap_log}=    Run Keyword And Return Status    Should Not Be Empty    ${args}
    Run Keyword If    ${save_pcap_log}    Save Pcap Log    &{args}

Save Pcap Log
    [Arguments]    &{args}
    FOR  ${key}    IN    @{args.keys()}
        Run    cd ${OUTPUTDIR} && mkdir ${key}
        Run    cp ${args["${key}"]} ${OUTPUTDIR}/${key}/
    END

#----ML
Start Logs collection
    [Arguments]     ${test_level}=${EMPTY}   ${F_sysLog}=${False}
    Log to console  \n ---- START ${test_level} collecting: sysLog=${F_sysLog} ----
    Run keyword if  ${F_sysLog}==${True}    BTSLOG Start btslog on local machine
BTSLOG Start btslog on local machine
    [Arguments]   ${bts_logs_dir}=/tmp/btslog2    ${name}=btslog
    Run  if [ ! -d ${bts_logs_dir} ]; then mkdir ${bts_logs_dir}; else rm ${bts_logs_dir}/*; fi
    btslog.create_btslog_collector
    ...    name=${name}
    ...    log_dir=${bts_logs_dir}
    core.setup_collectors    names=${name}
    core.start_collectors    names=${name}
    btslog.set_suite_alias    ${name}

Stop Logs collection
    [Arguments]    ${target_dir}=${OUTPUTDIR}   ${test_level}=${EMPTY}   ${F_sysLog}=${False}   ${F_snapshot}=${False}
    ${date}              DateTime.Get Current Date
    ${date}              String.Replace String
    ...                  string=${date}
    ...                  search_for=${SPACE}
    ...                  replace_with=_
    ${target_dir_with_timesamp}   Catenate    ${target_dir}/sysLog_${date[0:19]}
    Run Keyword If  ${F_sysLog}==${True}     BTSLOG Collect btslog     target_dir=${target_dir_with_timesamp}
    Run Keyword If  ${F_snapshot}==${True}   ADMIN Collect Snapshot    snapshot_name=${target_dir}/Snapshot_${date[0:19]}.zip
    Log to console  \n ---- STOP ${test_level} collecting: sysLog=${F_sysLog} snapshot=${F_snapshot}----

BTSLOG Collect btslog
    [Arguments]    ${target_dir}=${OUTPUTDIR}  ${bts_logs_dir}=/tmp/btslog2  ${name}=btslog
    run keyword and ignore error    Stop and collect btslog on local machine    ${name}    ${target_dir}
    #Copy btslog to logs dir and clean BTSlog workspace    ${bts_logs_dir}
    Run  rm ${bts_logs_dir}/*

Analyze SYSLOG whether BBPooling is activated
    BTSLOG Collect btslog
    ${actual_build}=    Check build version
    Run Process  command=gunzip -c syslog_files.tgz | tar xvf -  shell=yes  cwd=${OUTPUTDIR}/btslog/
    ${check_slowPrbPoolingTddFr1UlAllowed_to_true}=  Run Keyword If  '${actual_build}'=='SBTS23R3'
    ...    Run Process    command=grep -Hrn 'Bbrm conf UL: slowPrbPoolingTddFr1UlAllowed:true'  shell=yes  cwd=${OUTPUTDIR}/btslog/    ELSE
    ...    Run Process    command=grep -Hrn 'slowPrbPoolingTddFr1UlAllowed: boolean = true'  shell=yes  cwd=${OUTPUTDIR}/btslog/
    ${check_bbPoolEvalPeriod_set_to_50}=  Run Process
    ...    command=grep -Hrn 'Bbrm conf: bbPoolInfo present commonParameters: {"bbPoolMode":"BBPOOLMODE_LOADBASED","bbPoolEvalPeriod":50}'
    ...    shell=yes   cwd=${OUTPUTDIR}/btslog/
    ${check_actBbPoolTddFr1AlgEnh_to_true}=  Run Process
    ...    command=grep -Hrn 'actBbPoolTddFr1AlgEnh:true'
    ...    shell=yes   cwd=${OUTPUTDIR}/btslog/
    ${check_slowPrbPoolingTddFr1DlAllowed_to_true}=  Run Process
    ...    command=grep -Hrn 'slowPrbPoolingTddFr1DlAllowed: boolean = true'
    ...    shell=yes   cwd=${OUTPUTDIR}/btslog/
    ${check_spatialStreamPoolingAllowed_to_false}=    Run Process
    ...    command=grep -Hrn 'spatialStreamPoolingAllowed:false'
    ...    shell=yes    cwd=${OUTPUTDIR}/btslog/
    ${check_scheUePoolingAllowed_to_true}=    Run Process
    ...    command=grep -Hrn 'scheUePoolingAllowed: boolean = true'
    ...    shell=yes    cwd=${OUTPUTDIR}/btslog/
    Log to console  ${check_slowPrbPoolingTddFr1UlAllowed_to_true.stdout}
    Log to console  ${check_bbPoolEvalPeriod_set_to_50.stdout}
    Log to console  ${check_actBbPoolTddFr1AlgEnh_to_true.stdout}
    Log to console  ${check_slowPrbPoolingTddFr1DlAllowed_to_true.stdout}
    log to console  ${check_spatialStreamPoolingAllowed_to_false.stdout}
    log to console  ${check_scheUePoolingAllowed_to_true.stdout}
    Run Keyword If  '${actual_build}'=='SBTS23R3'
    ...    Should Contain  ${check_slowPrbPoolingTddFr1UlAllowed_to_true.stdout}  Bbrm conf UL: slowPrbPoolingTddFr1UlAllowed:true    ELSE
    ...    Should Contain  ${check_slowPrbPoolingTddFr1UlAllowed_to_true.stdout}  slowPrbPoolingTddFr1UlAllowed: boolean = true
    Should Contain  ${check_bbPoolEvalPeriod_set_to_50.stdout}
    ...    Bbrm conf: bbPoolInfo present commonParameters: {"bbPoolMode":"BBPOOLMODE_LOADBASED","bbPoolEvalPeriod":50}
    Should Contain  ${check_actBbPoolTddFr1AlgEnh_to_true.stdout}
    ...    actBbPoolTddFr1AlgEnh:true
    Should Contain    ${check_slowPrbPoolingTddFr1DlAllowed_to_true.stdout}
    ...    slowPrbPoolingTddFr1DlAllowed: boolean = true
    Should Contain    ${check_spatialStreamPoolingAllowed_to_false.stdout}
    ...    spatialStreamPoolingAllowed:false
    Should Contain    ${check_scheUePoolingAllowed_to_true.stdout}
    ...    scheUePoolingAllowed: boolean = true
    Run  rm -rf /home/ute/MN/UTE/robotws/btslog

Stop and collect btslog on local machine
    [Arguments]   ${name}=btslog    ${target_dir}=${OUTPUTDIR}
    core.stop_collectors         names=${name}
    core.collect_collectors      names=${name}    target_dir=${target_dir}
    core.teardown_collectors     names=${name}
    ${output}   Run  zcat ${target_dir}/*/*.tgz | head -1
    Log to console   ${target_dir}-->${output}

ADMIN Collect Snapshot
    [Arguments]    ${snapshot_name}=${OUTPUTDIR}/Snapshot.zip
    ...            ${coverage}=Full
    ...            ${force}=${TRUE}
    ...            ${timeout}=360
    ...            ${alias}=default  #${ADMIN_ALIAS}
    ${link_status}   run keyword and return status   admin_cli.check_link_status
    run keyword unless  ${link_status}   admin_cli.connect_to
    ${result}=   admin_cli.Collect Snapshot    target_file_name=${snapshot_name}
    ...                           coverage=${coverage}
    ...                           force=${force}
    ...                           timeout=${timeout}
    ...                           alias=${alias}
    run keyword unless  ${link_status}  admin_cli.teardown
    [Return]   ${result}

#----ML
Setup Log Collection
    BTSLOG Start btslog on local machine
    admin cli connection

Teardown Log Collection
    BTSLOG Collect btslog
    admin cli connection
    Run Keyword If Test Failed    Admin Collect Snapshot cOAM1
    Close Connections cOAM1

Activate SysLogOutputMode
    SYSTEM Add Flag In Swconfig File cOAM1    ${SysLogOutputMode}

gNB goes to OnAir after reset
    ADMIN CLI connection
    wait until keyword succeeds    900   30    Check If proceduralState Of gNB Is OnAir

gNB goes to configured after reset
    ADMIN CLI connection
    wait until keyword succeeds    900   30    Check If proceduralState Of gNB Is Configured Or OnAir

gNB goes to commissioned after reset
    ADMIN CLI connection
    wait until keyword succeeds    900   30    Check If proceduralState Of gNB Is Commissioned Or Configured

Add Flag In Swconfig File cOAM1
    [Arguments]    ${flags}
    @{flags}  Split String  ${flags}
    FOR  ${flag}  IN  @{flags}
        ${flag_id}  ${flag_value}=  Split String  ${flag}  =
        ${status}=    Execute Command On BTS  command=cat /rom/swconfig.txt | grep ${flag_id}
        Run Keyword If  '${status}'==''  Run Keywords  Add Flag To swconfig  ${flag}  AND  Continue For Loop
        Run Keyword If  '${status}'=='${flag}'  Continue for loop
        Remove Flag From swconfig  ${flag_id}
        Add Flag To swconfig  ${flag}
    END
    admin cli connection
    admin_cli.reset_site

Add Flag To swconfig
    [Arguments]  ${flag}
    Run Keywords
    ...    Execute Command On BTS
    ...    command=echo \n >> /rom/swconfig.txt    AND
    ...    Execute Command On BTS
    ...    command=echo \ >> /rom/swconfig.txt    AND
    ...    Execute Command On BTS
    ...    command=echo ${flag} >> /rom/swconfig.txt    AND
    ...    Execute Command On BTS
    ...    command=crasign /rom/swconfig.txt    #AND
#    ...    admin cli connection    AND
#    ...    admin_cli.reset_site

Remove Flag From swconfig
    [Arguments]  ${flag}
    Run Keyword
    ...    Execute Command On BTS
    ...    command=sed -i '/${flag}/d' /rom/swconfig.txt    #AND
#    ...    admin cli connection    AND
#    ...    admin_cli.reset_site

SYSTEM Add Flag In Swconfig File cOAM1
    [Arguments]    ${flag}
    ${status}    Execute Command On BTS
    ...    command=cat /rom/swconfig.txt | grep ${flag}
    ${status}    Run Keyword And Return Status    Should Be Empty    ${status}
    Run Keyword If    ${status}
    ...    Run Keywords
    ...    Execute Command On BTS
    ...    command=echo \n >> /rom/swconfig.txt    AND
    ...    Execute Command On BTS
    ...    command=echo \ >> /rom/swconfig.txt    AND
    ...    Execute Command On BTS
    ...    command=echo ${SysLogOutputMode} >> /rom/swconfig.txt    AND
    ...    Execute Command On BTS
    ...    command=echo ${flag2} >> /rom/swconfig.txt    AND
    ...    Execute Command On BTS
    ...    command=echo ${flag3} >> /rom/swconfig.txt    AND
    ...    Execute Command On BTS
    ...    command=crasign /rom/swconfig.txt    AND
    ...    admin cli connection    AND
    ...    admin_cli.reset_site    AND
    ...    Wait Until Keyword Succeeds
    ...    240
    ...    5
    ...    Check if eNB is not pingable

#Add Flag In Swconfig File cOAM1
#    [Arguments]    ${flag}
#    ${status}    Execute Command On BTS
#    ...    command=cat /rom/swconfig.txt | grep ${flag}
#    ${status}    Run Keyword And Return Status    Should Be Empty    ${status}
#    Run Keyword If    ${status}
#    ...    Run Keywords
#    ...    Execute Command On BTS
#    ...    command=echo \n >> /rom/swconfig.txt    AND
#    ...    Execute Command On BTS
#    ...    command=echo \ >> /rom/swconfig.txt    AND
#    ...    Execute Command On BTS
#    ...    command=echo ${flag} >> /rom/swconfig.txt    AND
#    ...    Execute Command On BTS
#    ...    command=crasign /rom/swconfig.txt    AND
#    ...    admin cli connection    AND
#    ...    admin_cli.reset_site

Remove Flag From Swconfig File cOAM1
    [Arguments]    ${flag}
    ${status}    Execute Command On BTS
    ...    command=cat /rom/swconfig.txt | grep ${flag}
    ${status}    Run Keyword And Return Status    Should Not Be Empty    ${status}
    Run Keyword If    ${status}
    ...    Run Keywords
    ...    Execute Command On BTS
    ...    command=sed -i '/${flag}/d' /rom/swconfig.txt    AND
    ...    admin cli connection    AND
    ...    admin_cli.reset_site

Admin Collect Snapshot cOAM1
    [Arguments]    ${snapshot_dir_path}=${OUTPUT_DIR}/${SUITE_NAME}/${TEST_NAME}/    ${snapshot_name}=snapshot.zip
    ADMIN CLI connection
    admin_cli.get_snapshot  target_file_name=${snapshot_dir_path}/${snapshot_name}    coverage=Full   timeout=2700
    ADMIN CLI disconnection

Admin Collect Snapshot Alias cOAM1
    [Arguments]    ${connection}=admin    ${snapshot_dir_path}=${OUTPUT_DIR}/${SUITE_NAME}/${TEST_NAME}/
    ...            ${snapshot_name}=snapshot.zip    ${snap_timeout}=900
    admin_cli.get_snapshot  target_file_name=${snapshot_dir_path}/${snapshot_name}  coverage=Full   timeout=${snap_timeout}

Admin Collect Snapshot cOAM1 Suite
    [Arguments]    ${snapshot_dir_path}=${OUTPUT_DIR}/${SUITE_NAME}/    ${snapshot_name}=snapshot.zip
    ADMIN CLI connection
    admin_cli.get_snapshot  target_file_name=${snapshot_dir_path}/${snapshot_name}    coverage=Full   timeout=2700
    ADMIN CLI disconnection
    Close Connections cOAM1

Stop and collect btslog on local machine cOAM1
    [Arguments]   ${name}=btslog
    core.stop_collectors         names=${name}
    core.collect_collectors      names=${name}
    core.teardown_collectors     names=${name}

Make empty BTS logs dir cOAM1
    [Arguments]     ${bts_logs_dir}=/tmp/btslog2
    Run  if [ ! -d ${bts_logs_dir} ]; then mkdir ${bts_logs_dir}; else rm ${bts_logs_dir}/*; fi

Copy btslog to logs dir and clean BTSlog workspace cOAM1
    [Arguments]     ${bts_logs_dir}=/tmp/btslog2
    Run  mv ${bts_logs_dir}/syslog_files.tgz ${OUTPUT_DIR}/${TEST_NAME}/bts_log.tgz
    Run  rm ${bts_logs_dir}/*

Prepare logs path cOAM1
    [Documentation]      Sets path and creates directory where collected log files will be saved.
    ...                  logs_path is unique per test suite run and accessible from Test Suite scope.
    [Arguments]          ${testCase_name}=${TEST_NAME}
    ${date}              DateTime.Get Current Date
    ${tc_name}           String.Replace String
    ...                  string=${testCase_name}
    ...                  search_for=${SPACE}
    ...                  replace_with=_
    Set Global Variable  ${logs_path}
    ...                  ${OUTPUT DIR}/OAM_TS_${date[0:10]}/${date[11:19]}_${tc_name}
    Run                  mkdir -p ${logs_path}

Save swconfig
    [Arguments]  ${remote_path}=/rom/swconfig.txt  ${local_path}=/home/ute/Desktop/swconfig.txt
    Connect Ssh To Asix
    ssh.download_file   remote_path=${remote_path}
    ...     local_path=${local_path}
    ...     connection=asik
    [Teardown]  Disconnect Ssh From Asix

Restore swconfig
    [Arguments]  ${remote_path}=/rom/swconfig.txt  ${local_path}=/home/ute/Desktop/swconfig.txt
    Connect Ssh To Asix
    ssh.upload_file   remote_path=${remote_path}
    ...     local_path=${local_path}
    ...     connection=asik
        Disconnect Ssh From Asix
    sleep  15s
    admin cli connection
    admin_cli.reset_site


#Execute Command On BTS
#    [Arguments]    ${command}
#    ...            ${hostname}=${SYSTEM_ENB_LOCAL_IP}
#    ...            ${username}=${SYSTEM_ENB_SSH_USERNAME}
#    ...            ${password}=${SYSTEM_ENB_SSH_PASSWORD}
#    ...            ${alias}=${SYSTEM_ALIAS_ASIK}
#    taf.transport.ssh.connect_to
#    ...    hostname=${hostname}
#    ...    username=${username}
#    ...    password=${password}
#    ...    alias=${alias}
#    ${reply}    taf.transport.ssh.execute
#    ...    command=${command}
#    ...    connection=${alias}
#    ${reply}    Evaluate
#    ...         expression="""${reply}""".rstrip(\r\n)
#    [Return]    ${reply}

Execute Command On BTS
    [Arguments]    ${command}
    Connect Ssh To Asix
    ${reply}    ssh.execute
    ...    command=${command}
    ...    connection=asik
    ${reply}    Evaluate
    ...         expression="""${reply}""".rstrip(\r\n)
    [Teardown]  Disconnect Ssh From Asix
    [Return]    ${reply}
