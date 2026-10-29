*** Settings ***
Documentation    This is for UUF common keywords.
...              Please do not modify the file without notification to author
...              Author: tingting.1.liu@nokia-sbell.com
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/TMO/TMO_common_keywords.robot

*** Variables ***
${BASIC_SCF}    tmo_basic.xml
${target_version}
${enb_target_ver}
${SBTS22R4_package_link}     https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/SBTS22R4_packages/
${SBTS23R1_package_link}     https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/SBTS23R1_packages/
${SBTS23R2_package_link}     https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/SBTS23R2_packages/
${SBTS00_package_link}       https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/SBTS00_packages/
${package_version_1525-CA}      ${target_version}
${enb_upgrade_package}          ${enb_target_ver}
${sw_url}    https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build/


*** Keywords ***
#--- Setup And TearDown---#
UUF_Common_Suite_Setup
    [Documentation]    Author: tingting.1.liu@nokia-sbell.com
    [Arguments]    ${is_commission}=${False}    ${ute_space}=20
    log    ${ute_space}
    log    ${is_commission}
    Clearup UTE Space while keep syslog
#    ${stream_version}    gnb_classical_hangzhou.Get program version based on stream version
    ${stream_version}    Common_setup_and_teardown.Get Active SW Version Based On Stream Version
    Set Suite Variable    ${stream_version}
    ${btsName_in_gnb}    TMO_common_keywords_part_one.Get BtsName From Gnb
    Set Suite Variable    ${btsName_in_gnb}
    # get tl_prefix, such as T813/T073
    Set Suite Variable    ${tl_prefix}    ${testline_name.split('_')[-1][-4:]}
    ${SCOUT_TL_NAME}    Set Variable    ${testline_name}
    Set Suite Variable    ${SCOUT_TL_NAME}
    # get how many ENBs
    ${enb_length}    Get Length    ${tl.enbs}
    Set Suite Variable    ${enb_length}
    ${dict_enb_Technology_index}    Get LTE Technology Value
    Set Suite Variable    ${DICT_ENB_TECHNOLOGY_INDEX}    ${dict_enb_Technology_index}
    ${lte_whether_in_gnb}    Check LTE Whether In Gnb
    Set Suite Variable    ${LTE_WHETHER_IN_GNB}    ${lte_whether_in_gnb}
    Suite Log Path Create
    ${btsName_output}    OperatingSystem.Run    cat ${SCF_PATH_ON_UTE}/${tl_prefix}_gNB_${stream_version}.xml | grep -i btsName
    ${btsName_in_scf}    Set Variable    ${btsName_output.split("</")[0].split(">")[-1]}
    Set Suite Variable    ${btsName_in_scf}
    Check TMO Gnb Ready And All Cell On Air
    Verify All Enbs Cell On Air
    &{fault_4203}     Create Dictionary     faultId=${4203}
    &{fault_4459}     Create Dictionary     faultId=${4459}
    &{fault_1932}     Create Dictionary     faultId=${1932}
    &{fault_1933}     Create Dictionary     faultId=${1933}
    &{fault_1934}     Create Dictionary     faultId=${1934}
    &{fault_61631}     Create Dictionary     faultId=${61631}
    &{fault_1838}     Create Dictionary     faultId=${1838}
    &{fault_4741}     Create Dictionary     faultId=${4741}
    &{fault_4293}     Create Dictionary     faultId=${4293}
    &{fault_4046}     Create Dictionary     faultId=${4046}
    &{fault_1898}     Create Dictionary     faultId=${1898}
    &{fault_4589}     Create Dictionary     faultId=${4589}
    &{fault_4775}     Create Dictionary     faultId=${4775}
    &{fault_6261}     Create Dictionary     faultId=${6261}
    &{fault_4776}     Create Dictionary     faultId=${4776}
    &{fault_7535}     Create Dictionary     faultId=${7535}
    &{fault_7525}     Create Dictionary     faultId=${7525}
    &{fault_8000}     Create Dictionary     faultId=${8000}
    ${GNB_ALLOWED_FAULT}   Create List   @{ALLOWED_FAULT}   ${fault_4203}    ${fault_4459}   ${fault_1932}   ${fault_1933}    ${fault_1934}
    ...                    ${fault_1838}     ${fault_4741}     ${fault_4293}     ${fault_4046}
    ...                    ${fault_4589}    ${fault_4775}    ${fault_6261}    ${fault_4776}    ${fault_7535}    ${fault_7525}    ${fault_8000}
    Run Keyword If    '${tl_prefix}'=='T813' or '${tl_prefix}'=='T284'         append to list    ${GNB_ALLOWED_FAULT}    ${fault_1898}
    Set Suite Variable    ${GNB_ALLOWED_FAULT}
    ${ALLOWED_HISTORY_FAULT}   Create List   @{ALLOWED_HISTORY_FAULT}   ${fault_61631}   ${fault_1838}   ${fault_4741}
    ...                                                                 ${fault_4589}    ${fault_4775}    ${fault_6261}    ${fault_4776}
    ...     ${fault_8000}
    Set Suite Variable    ${ALLOWED_HISTORY_FAULT}
    robot_common_operations.Common Suite Setup

UUF_Common_Suite_Teardown
    robot_common_operations.Common Suite Teardown
    run keyword and ignore error    Collect Snapshot Log in gnb and enb    log_path=${SUITE_LOG_PATH}    timeout=${2400}

Modify Swconfig File
    [Documentation]   tingting.1.liu@nokia-sbell.com
    [Arguments]    ${para_update}    ${local_path}=${TS_CASE_LOG_PATH}
    Run    rm ${local_path}/swconfig*
    csn.Connect to     hostname=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...                username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...                password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...                alias=ASIK Master
    csn.send command    command=cp /ffs/run/swconfig.txt /ffs/run/swconfig.txt.bak   connection=ASIK Master
    swconf.Download swConfig file from asik to test pc    localFilePath=${local_path}/swconfig.txt
    ...                                                   asik_alias=ASIK Master
    ...                                                   remoteFilePath=/ffs/run/swconfig.txt
    FOR   ${swconfig}   IN   @{para_update}
        ${config_id}    should match regexp     ${swconfig}    .*?(?==)
        Run   sed -i -e '/${config_id}.*=.*/'d ${local_path}/swconfig.txt
    END
    swconf.Modify swConfig file    parametersList=${para_update}    filePath=${local_path}/swconfig.txt
    swconf.Upload swConfig file to asik and crasign    localFilePath=${local_path}/swconfig.txt
    ...                                                asik_alias=ASIK Master
    run keyword and ignore error  csn.disconnect    connection=ASIK Master

Check Gnb Startup Log
    [Documentation]   tingting.1.liu@nokia-sbell.com
    [Arguments]  ${connection}=GNB_OAM
    log    ${connection}
    csn.Connect to     hostname=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...                username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...                password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...                alias=ASIK Master
    ${startup_command} =    set variable    cat /tmp/startup_BTSOM.log |grep -i 'startService loading from hwf is disabled'
    ${startup_xz_command} =  set variable
    ...       xzcat /ffs/run/logs/fct-0a_aasyslog/startup_BTSOM.log.xz |grep -i 'startService loading from hwf is disabled'
    ${startup_log} =    Check Startup Defualt Log On ASIK
    ...    startup_cmd=${startup_command}    startup_xz_cmd=${startup_xz_command}    info=startService loading from hwf is disabled
    run keyword and ignore error  csn.disconnect    connection=ASIK Master

Check Enb Startup Log
    [Documentation]    jun.8.chen@nokia-sbell.com
    [Arguments]    ${connection}=ENB_Startup    ${enb_index}=${0}
    log    ${connection}
    csn.Connect to     hostname=${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.addr}
    ...                username=${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.username}
    ...                password=${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.password}
    ...                alias=${connection}
    ${startup_cmd}    Set Variable    cat /tmp/startup_BTSOM.log |grep -i 'startService loading from hwf is disabled'
    ${startup_xz_cmd}    Set Variable
    ...    xzcat /ffs/run/logs/fct-0a_aasyslog/startup_BTSOM.log.xz |grep -i 'startService loading from hwf is disabled'
    ${info}    Set Variable    startService loading from hwf is disabled
    ${startup_default}    ${match}    Check Startup Log    command=${startup_cmd}    info=${info}    alias=${connection}
    ${startup_final_log}    ${match1}    Run Keyword If    '${match[0]}'=='FAIL'
    ...            Check Startup Log    command=${startup_xz_cmd}    info=${info}    alias=${connection}
    ...    ELSE    Check Startup Log    command=${startup_cmd}    info=${info}    alias=${connection}
    [Teardown]    Run Keyword And Ignore Error    csn.disconnect    connection=ENB_Startup

Check Btslog After Reset
    [Documentation]   tingting.1.liu@nokia-sbell.com
    [Arguments]   ${log_path}
    ${bts_gz_command1} =  set variable
        ...   gunzip -c ${log_path} |grep -i 'CELL NOTIFICATION 4329 Radio memory consumption exceeds abnormal threshold'
	${bts_gz_command2} =  set variable   gunzip -c ${log_path} |grep -i 'FaultId: 4329'
	${bts_gz_command3} =  set variable   gunzip -c ${log_path} |grep -i 'FaultId: 4330'
	${bts_gz_command4} =  set variable   gunzip -c ${log_path} |grep -i 'Detector 4329'
	${bts_gz_command5} =  set variable   gunzip -c ${log_path} |grep -i 'Detector 4330'
	${bts_gz_command6} =  set variable   gunzip -c ${log_path} |grep -i 'active 4329'
	${bts_gz_command7} =  set variable   gunzip -c ${log_path} |grep -i 'active 4330'
	${common_list}    create list   ${bts_gz_command1}  ${bts_gz_command2}  ${bts_gz_command3}  ${bts_gz_command4}
	...                             ${bts_gz_command5}  ${bts_gz_command6}  ${bts_gz_command7}
	${status_list}    create list
	FOR   ${common}   IN   @{common_list}
	    ${offline_output}   RUN    ${common}
	    ${status}    run keyword and return status    should be empty    ${offline_output}    Syslog Crash verification failed
	    Append To List    ${status_list}    ${status}
	END
	list should not contain value    ${status_list}    ${False}

Check Normal Gnb Version
    [Documentation]    author: tingting.1.liu@nokia-sbell.com
    csn.reset_cache
    csn.Connect to    hostname=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...               username=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...               password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ...               alias=asik
    csn.send_command    command=ls /ffs/run/TargetBD*\.xml    connection=asik
    ${result}     csn.read_output    connection=asik
    should contain    ${result}    ${package_version_1525-CA}
    csn.reset_cache

Check Normal Enb Version
    [Documentation]    author: tingting.1.liu@nokia-sbell.com
    [Arguments]    ${enb_index}=${0}
    csn.reset_cache
    csn.Connect to    hostname=${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.addr}
    ...               username=${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.password}
    ...               alias=asik
    csn.send_command    command=ls /ffs/run/TargetBD*\.xml    connection=asik
    ${result}     csn.read_output    connection=asik
    should contain    ${result}    ${package_version_1525-CA}
    csn.reset_cache

Gnb And All Enb Upgrade
    [Documentation]    author: tingting.1.liu@nokia-sbell.com
    [Arguments]    ${gnb_connection}=GNB_OAM    ${timeout}=7200
    Set Test Variable    ${upgrade_package_path}    /home/ute/${package_version_1525-CA}_release_BTSSM_downloadable_A54.zip
    Set Test Variable    ${enb_upgrade_package_path}    /home/ute/${enb_upgrade_package}_release_BTSSM_downloadable_A54.zip
    log to console    --- start to download sw build from artifactory---
    Run Keyword And Continue On Failure      Download SW Build from artifactory
    Run Keyword And Continue On Failure      Download SW Build from artifactory     target_version=${enb_upgrade_package}
    log to console    --- start to upgrade---
    wait until keyword succeeds     5 min   10 sec     Connect to gnb coam via ssl
    coam.update_software    sw_package=${upgrade_package_path}    timeout=${timeout}    connection=${gnb_connection}
    Run Keyword And Ignore Error    COAM Teardown gnb connections
    FOR    ${enb_id}    IN RANGE    ${enb_length}
        Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_id}    connection=enblte_${enb_id}
        Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False}    coam.update_software    sw_package=${enb_upgrade_package_path}
        ...    timeout=${timeout}    connection=enblte_${enb_id}
        Run Keyword And Ignore Error    Enblte close down    connection=enblte_${enb_id}
    END
    [Teardown]   Run Keywords    run keyword and ignore error    COAM Teardown gnb connections   AND
    ...    Run Keyword And Ignore Error    Enblte close down    connection=${0}   AND
    ...    Run Keyword And Ignore Error    Enblte close down    connection=${1}


Gnb Upgrade Only
    [Documentation]    author: lei.jia@nokia-sbell.com
    [Arguments]    ${gnb_connection}=GNB_OAM    ${timeout}=7200
    log many    ${gnb_connection}    ${timeout}
    Set Test Variable    ${upgrade_package_path}    /home/ute/${package_version_1525-CA}_release_BTSSM_downloadable_A54.zip
    log to console    --- \ncheck whether rollback needed---
    Check Rollback is needed before sw upgrade
    log to console    --- start to download sw build from artifactory---
    Download SW Build from artifactory
    log to console    --- start to upgrade---
    wait until keyword succeeds     5 min   10 sec     Connect to gnb coam via ssl
    coam.update_software    sw_package=${upgrade_package_path}    timeout=7200    connection=GNB_OAM
    Run Keyword And Ignore Error    COAM Teardown gnb connections
    [Teardown]   run keyword and ignore error    COAM Teardown gnb connections

Gnb Rallback Only
    [Documentation]    author: lei.jia@nokia-sbell.com
    [Arguments]    ${gnb_connection}=GNB_OAM    ${timeout}=7200
    log to console    --- start to rallback---
    wait until keyword succeeds     5 min   10 sec     Connect to gnb coam via ssl
    coam.rollback_software    timeout=${timeout}    connection=${gnb_connection}
    Run Keyword And Ignore Error    COAM Teardown gnb connections
    [Teardown]   run keyword and ignore error    COAM Teardown gnb connections

Gnb And All Enb Rallback
    [Documentation]    author: tingting.1.liu@nokia-sbell.com
    [Arguments]    ${gnb_connection}=GNB_OAM    ${timeout}=7200
    log to console    --- start to rallback---
    wait until keyword succeeds     5 min   10 sec     Connect to gnb coam via ssl
    coam.rollback_software    timeout=${timeout}    connection=${gnb_connection}
    Run Keyword And Ignore Error    COAM Teardown gnb connections
    FOR    ${enb_id}    IN RANGE    ${enb_length}
        Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_id}    connection=enblte_${enb_id}
        Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False}    coam.rollback_software    timeout=${timeout}    connection=enblte_${enb_id}
        Run Keyword And Ignore Error    Enblte close down    connection=enblte_${enb_id}
    END
    [Teardown]   Run Keywords    run keyword and ignore error    COAM Teardown gnb connections   AND
    ...    Run Keyword And Ignore Error    Enblte close down    connection=${0}   AND
    ...    Run Keyword And Ignore Error    Enblte close down    connection=${1}

Get BTS SW Version
    [Documentation]    author: lei.jia@nokia-sbell.com
    [Arguments]    ${gnb_index}=${0}    ${gnb_connection}=GNB_OAM${gnb_index}    ${timeout}=180
    wait until keyword succeeds     5 min   10 sec     Connect to gnb coam via ssl    connection=${gnb_connection}
    ...    gnb_index=${gnb_index}
    ${BTS_SW_Info}=   coam.get_software_info    timeout=${timeout}    connection=${gnb_connection}
    ${active_SW}=     Get from dictionary    ${BTS_SW_Info}    Active SW version
    ${passive_SW}=    Get from dictionary    ${BTS_SW_Info}    Passive SW version
    Log To Console    Active partition SW: ${active_SW}
    Log To Console    Passive partition SW: ${passive_SW}\n
    Set Test Variable    ${ACTIVE_SW}    ${active_SW}
    Set Test Variable    ${PASSIVE_SW}    ${passive_SW}
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections    connection=${gnb_connection}

Rollback gNB package
    [Documentation]    author: lei.jia@nokia-sbell.com
    [Arguments]    ${gnb_connection}=GNB_OAM    ${timeout}=7200    ${gnb_index}=${0}
    log to console    --- start to rallback---
    wait until keyword succeeds     5 min   10 sec     Connect to gnb coam via ssl    connection=${gnb_connection}
    ...    gnb_index=${gnb_index}
    coam.rollback_software    timeout=${timeout}    connection=${gnb_connection}
    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${gnb_connection}
    sleep  5min
    Check TMO Gnb Ready And All Cell On Air    gnb_id=${gnb_index}   connection=${gnb_connection}
    [Teardown]   run keyword and ignore error    COAM Teardown gnb connections    connection=${gnb_connection}

Confirm Rollback Success
    [Documentation]    author: lei.jia@nokia-sbell.com
    [Arguments]    ${gnb_connection}=GNB_OAM    ${timeout}=180    ${gnb_index}=${0}
    log to console    confirm rollback success
    wait until keyword succeeds    15min    1min    Check Active SW is wanted    gnb_connection=${gnb_connection}
    ...    timeout=${timeout}    gnb_index=${gnb_index}
    sleep    5s

Check Active SW is wanted
    [Documentation]    author: lei.jia@nokia-sbell.com
    [Arguments]    ${gnb_connection}=GNB_OAM    ${timeout}=180    ${gnb_index}=${0}
    wait until keyword succeeds     5 min   10 sec     Connect to gnb coam via ssl    connection=${gnb_connection}
    ...    gnb_index=${gnb_index}
    ${BTS_SW_Info}=   coam.get_software_info    timeout=${timeout}    connection=${gnb_connection}
    ${current_SW}=     Get from dictionary    ${BTS_SW_Info}    Active SW version
    should be equal as strings    ${current_SW}    ${PASSIVE_SW}
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections    connection=${gnb_connection}

Check Rollback is needed before sw upgrade
    [Documentation]    author: lei.jia@nokia-sbell.com
    [Arguments]  ${gnb_index}=${0}    ${active_sw_flag}=Low    ${gnb_connection}=GNB_OAM${gnb_index}    ${timeout}=7200
    Get BTS SW Version    gnb_index=${gnb_index}
#    ${active_sw_stream}    Fetch From Left    ${ACTIVE_SW}   _
#    ${passive_sw_stream}    Fetch From Left    ${PASSIVE_SW}    _
    ${active_sw_stream}    ${passive_sw_stream}    Compare The Version For BTS SW Version    active_software=${ACTIVE_SW}
    ...                                                                                      passive_software=${PASSIVE_SW}
    ${condition}    Set Variable If    '${active_sw_flag}'=='Low'    '${passive_sw_stream}'<'${active_sw_stream}'
    ...                                '${active_sw_flag}'=='High'   '${passive_sw_stream}'>'${active_sw_stream}'
    ...                                '${passive_sw_stream}'>'${active_sw_stream}'
    Run Keyword If    ${condition}    run keywords    Rollback gNB package    gnb_connection=${gnb_connection}
    ...    timeout=${timeout}    gnb_index=${gnb_index}
    ...    AND    Confirm Rollback Success    gnb_connection=${gnb_connection}
    ...    timeout=${timeout}    gnb_index=${gnb_index}
    ...    ELSE    Log to console    ---No Need To Rollback, active sw build is ${active_sw_stream} ---

Compare The Version For BTS SW Version
    [Documentation]    author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${active_software}    ${passive_software}
    @{version_active}    Split String    ${active_software}    separator=_
    @{version_passive}    Split String    ${passive_software}    separator=_
    ${status}    Run Keyword And Return Status    Should Be Equal    ${version_active}[0]    ${version_passive}[0]
    ${status1}    Run Keyword And Return Status    Should Be Equal    ${version_active}[3]    ${version_passive}[3]
    ${active_sw_stream}    Set Variable If    ${status} and ${status1}    ${version_active}[-1]
    ...                                       ${status} and not ${status1}    ${version_active}[3]
    ...                                       not ${status}    ${version_active}[0]
    ...                                       ${version_active}[0]
    ${passive_sw_stream}    Set Variable If    ${status} and ${status1}    ${version_passive}[-1]
    ...                                       ${status} and not ${status1}    ${version_passive}[3]
    ...                                       not ${status}    ${version_passive}[0]
    ...                                       ${version_passive}[0]
    [Return]    ${active_sw_stream}    ${passive_sw_stream}

get stream from target version
    [Arguments]  ${target_version}  ${convert_to_trunk}=${True}
    log    ${convert_to_trunk}
    @{version_split}    string.split string    ${target_version}    separator=_
    ${stream}       set variable    ${version_split}[0]
    [Return]  ${stream}

Download SW Build from artifactory
    [Documentation]    author: lei.jia@nokia-sbell.com
    [Arguments]    ${target_version}=${package_version_1525-CA}    ${sw_url}=${sw_url}    ${ute_path}=/home/ute
    ${stream}    get stream from target version    target_version=${target_version}
    ${download_link} = 	Catenate    SEPARATOR=
    ...    ${sw_url}   ${stream}/    ${target_version}/
    ...    ${target_version}_release_BTSSM_downloadable_A54.zip
    ${file_exist}    Run Keyword And Return Status    OperatingSystem.File Should Exist
    ...    ${ute_path}/${target_version}_release_BTSSM_downloadable_A54.zip
    Return From Keyword If    ${file_exist}
#    get md5 file
    Run Keyword And Ignore Error    Run    rm ${ute_path}/*.md5
    Run     wget --no-proxy ${download_link}.md5 -P ${ute_path}
    ${output} = 	List Files In Directory 	${ute_path} 	*.md5    absolute=${TRUE}
    ${md5_file}     set variable    ${output}[0]
    ${md5_value}      OperatingSystem.get file    ${md5_file}
    # download sw build
    Run    wget --no-proxy ${download_link} -P ${ute_path}
    sleep    1min
    wait until keyword succeeds    10min    10s    Check Download Completed Successfully
    ...    upgrade_package_path=${ute_path}/${target_version}_release_BTSSM_downloadable_A54.zip     md5_value=${md5_value}
    OperatingSystem.File Should Exist
    ...    ${ute_path}/${target_version}_release_BTSSM_downloadable_A54.zip

Check Download Completed Successfully
    [Documentation]    author: lei.jia@nokia-sbell.com
    [Arguments]    ${upgrade_package_path}    ${md5_value}
    ${sum}=        Set Variable     md5sum ${upgrade_package_path}
    ${res}    ${output}    Run And Return Rc And Output    ${sum}
    ${res}    string.split string    ${output}
    should be equal    ${md5_value}    ${res}[0]

Get Enb SW Version
    [Documentation]    author: xiangsheng@nokia-sbell.com
    [Arguments]    ${enb_index}=${0}    ${enb_connection}=enblte   ${timeout}=180
    wait until keyword succeeds     5 min   10 sec     Connect to eNB via ssl    connection=${enb_connection}     enb_index=${enb_index}
    ${BTS_SW_Info}=   coam.get_software_info    timeout=${timeout}    connection=${enb_connection}
    ${active_SW}=     Get from dictionary    ${BTS_SW_Info}    Active SW version
    ${passive_SW}=    Get from dictionary    ${BTS_SW_Info}    Passive SW version
    Log To Console    Active partition SW: ${active_SW}
    Log To Console    Passive partition SW: ${passive_SW}\n
    Set Test Variable    ${enb_ACTIVE_SW}    ${active_SW}
    Set Test Variable    ${enb_PASSIVE_SW}    ${passive_SW}
    [Teardown]    run keyword and ignore error    Enblte close down    connection=${enb_connection}

Check Enb Rollback is needed before sw upgrade
    [Documentation]    author: xiangsheng.chu@nokia-sbell.com
    log to console    --- start to rallback---
    FOR    ${enb_id}    IN RANGE    ${enb_length}
         Get Enb SW Version    enb_index=${enb_id}    enb_connection=enblte_${enb_id}
#         ${active_enb_sw_stream}    Fetch From Left    ${enb_ACTIVE_SW}   _
#         ${passive_enb_sw_stream}    Fetch From Left    ${enb_PASSIVE_SW}    _
         ${active_enb_sw_stream}    ${passive_enb_sw_stream}    Compare The Version For BTS SW Version    active_software=${enb_ACTIVE_SW}
         ...                                                                                              passive_software=${enb_PASSIVE_SW}
         Run Keyword If    '${passive_enb_sw_stream}'<'${active_enb_sw_stream}'    run keywords    Rollback eNB package
         ...         enb_index=${enb_id}    connection=enblte_${enb_id}
         ...         AND    Confirm enb Rollback Success    enb_index=${enb_id}    connection=enblte_${enb_id}
    END

Rollback Enb package
    [Documentation]    author: xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${enb_index}=${0}    ${connection}=enblte    ${timeout}=1200
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}    connection=${connection}
    coam.rollback_software    timeout=${timeout}    connection=${connection}
    Run Keyword And Ignore Error    Enblte close down    connection=${connection}
    [Teardown]   Run Keyword And Ignore Error    Enblte close down    connection=${connection}

Check enb Active SW is wanted
    [Documentation]    author: xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${enb_index}=${0}    ${connection}=enblte    ${timeout}=300
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}    connection=${connection}
    ${BTS_SW_Info}=   coam.get_software_info    timeout=${timeout}    connection=${connection}
    ${current_SW}=     Get from dictionary    ${BTS_SW_Info}    Active SW version
    should be equal as strings    ${current_SW}    ${enb_PASSIVE_SW}
    [Teardown]    run keyword and ignore error    Enblte close down    connection=${connection}

Confirm enb Rollback Success
    [Documentation]    author: xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${enb_index}=${0}    ${connection}=enblte    ${timeout}=1200
    log    ${timeout}
    log to console    confirm rollback success
    wait until keyword succeeds    15min    1min    Check enb Active SW is wanted     enb_index=${enb_index}    connection=${connection}
    sleep    5s

gNB_enb_SW_Upgrade_loops_with_WebUI_RFS
    [Documentation]    Author:xiangsheng.chu@nokia-sbell.com
    ...                update with gnb/enb sw upgrade
    ...                enb only upgrade to SBTS24R1_ENB_0000_000452_000004
    [Arguments]    ${whether_do_lte_first}=${False}
    gNB_enb_SW_Upgrade_with_WebUI_RFS    whether_do_lte_first=${whether_do_lte_first}
    gNB_enb_SW_Rollback_with_WebUI_RFS    whether_do_lte_first=${whether_do_lte_first}

gNB_enb_SW_Upgrade_with_WebUI_RFS
    [Arguments]    ${whether_do_lte_first}=${False}
    log to console    --- start to upgrade---
    run keyword If    '${whether_enb_up}'=='true' and '${enb_upgrade_flag}'=='true' and ${whether_do_lte_first}    Enb Upgrade Only
    run keyword If    '${whether_enb_up}'=='true' and '${enb_upgrade_flag}'=='true' and ${whether_do_lte_first}    Sleep  5min
    wait until keyword succeeds     5 min   10 sec     Connect to gnb coam via ssl    connection=GNB_upgrade
    run keyword If    '${whether_gnb_up}'=='true'    coam.update_software    sw_package=${upgrade_package_path}
    ...                                                                      timeout=7200
    ...                                                                      connection=GNB_upgrade
    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=GNB_upgrade
    Sleep  5min
    run keyword If    '${whether_enb_up}'=='true' and '${enb_upgrade_flag}'=='true' and '${whether_do_lte_first}'=='${False}'    Enb Upgrade Only
    Check TMO Gnb Ready And All Cell On Air
    Verify All Enbs Cell On Air
    Check GNB Whether Unexpect Alarm Should Not Exist    allowed_faults=${GNB_ALLOWED_FAULT_with_4742}
    Check ENB Whether Unexpect Alarm Should Not Exist    allowed_faults=${GNB_ALLOWED_FAULT_with_4110_4742}

gNB_enb_SW_Rollback_with_WebUI_RFS
    [Arguments]    ${whether_do_lte_first}=${False}
    log to console    --- start to rallback---
    Run Keyword If    '${whether_gnb_up}'=='true' and ${whether_do_lte_first}    Run Keywords
    ...    Check Rollback is needed before sw upgrade    AND
    ...    sleep  2min    AND
    ...    Verify All Enbs Cell On Air    AND
    ...    Check GNB Whether Unexpect Alarm Should Not Exist    allowed_faults=${GNB_ALLOWED_FAULT_with_4742}    AND
    ...    Check ENB Whether Unexpect Alarm Should Not Exist    allowed_faults=${GNB_ALLOWED_FAULT_with_4742}
    Run Keyword If    '${whether_enb_up}'=='true'    Run Keywords
    ...    Check Enb Rollback is needed before sw upgrade    AND
    ...    sleep  3min    AND
    ...    Check TMO Gnb Ready And All Cell On Air    AND
    ...    Verify All Enbs Cell On Air    AND
    ...    Check GNB Whether Unexpect Alarm Should Not Exist    allowed_faults=${GNB_ALLOWED_FAULT}    AND
    ...    Check ENB Whether Unexpect Alarm Should Not Exist    allowed_faults=${GNB_ALLOWED_FAULT}
    Run Keyword If    '${whether_gnb_up}'=='true' and '${whether_do_lte_first}'=='${False}'    Run Keywords
    ...    Check Rollback is needed before sw upgrade    AND
    ...    sleep  2min    AND
    ...    Verify All Enbs Cell On Air    AND
    ...    Check GNB Whether Unexpect Alarm Should Not Exist    allowed_faults=${GNB_ALLOWED_FAULT_with_4742}    AND
    ...    Check ENB Whether Unexpect Alarm Should Not Exist    allowed_faults=${GNB_ALLOWED_FAULT_with_4742}

gNB_enb_SW_Upgrade_loops_with_WebUI_RFS_Precondition
    [Documentation]    Author:jun.8.chen@nokia-sbell.com
    [Arguments]    ${whether_do_lte_first}=${False}
    ${gnb_allowed_fault_Before_Commission}   Create List    4203    1838    4741    4681   7311   7331    7107    10
    ...                                                     4293    4297    4420    4775   1932   1934    1933    8150
    ...                                                     7300    1815    1898    7319    4731    16   4298    4405
    ...                                                     6261    6150
    Set Test Variable    ${gnb_allowed_fault_Before_Commission}
    AlarmWatchdog.add_allow_alarms    fault_id=${gnb_allowed_fault_Before_Commission}
    Create Case Log Path
    Check TMO Gnb Ready And All Cell On Air
    Verify All Enbs Cell On Air
    Check GNB Whether Unexpect Alarm Should Not Exist    allowed_faults=${GNB_ALLOWED_FAULT}
    Check ENB Whether Unexpect Alarm Should Not Exist    allowed_faults=${GNB_ALLOWED_FAULT}
#    COAM Create log directory
    Set Test Variable    ${upgrade_package_path}    /home/ute/${package_version_1525-CA}_release_BTSSM_downloadable_A54.zip
    Set Test Variable    ${enb_upgrade_package_path}    /home/ute/${enb_target_sw}_release_BTSSM_downloadable_A54.zip
    ${gnb_up}    Set Variable If    '${package_version_1525-CA}'==''      false    true
    ${enb_up}    Set Variable If    '${enb_target_sw}'==''      false    true
    Set Test Variable    ${whether_gnb_up}    ${gnb_up}
    Set Test Variable    ${whether_enb_up}    ${enb_up}
    ${enb_upgrade_flag}    Run Keyword If    '${whether_enb_up}'=='true'    Get Enb Upgrade Flag For Target SW Version
    ...                                                                         sw_version=${enb_target_sw}
    Set Test Variable    ${enb_upgrade_flag}
    log to console    --- start to download sw build from artifactory---
    IF    ${whether_do_lte_first}
        Run Keyword If    '${whether_gnb_up}'=='true'    Check Rollback is needed before sw upgrade
        Run Keyword If    '${whether_enb_up}'=='true'    Check Enb Rollback is needed before sw upgrade
    ELSE
        Run Keyword If    '${whether_enb_up}'=='true'    Check Enb Rollback is needed before sw upgrade
        Run Keyword If    '${whether_gnb_up}'=='true'    Check Rollback is needed before sw upgrade
    END
    Check TMO Gnb Ready And All Cell On Air
    Verify All Enbs Cell On Air
    Check GNB Whether Unexpect Alarm Should Not Exist    allowed_faults=${GNB_ALLOWED_FAULT}
    Check ENB Whether Unexpect Alarm Should Not Exist    allowed_faults=${GNB_ALLOWED_FAULT}
    log to console    --- start to commission---
    ${is_commission_gnb}    ${is_commission_enb}    ${version_in_gnb}    ${version_in_enb}
    ...    Check GNB And Enb Whether Need To Commission    whether_gnb_up=${whether_gnb_up}    whether_enb_up=${whether_enb_up}
    UUF_common_keywords.Need To Do SCF Commission    scf_name=${tl_prefix}_gNB_${version_in_gnb}.xml
    ...                                              is_commission=${is_commission_gnb}
    ...                                              tdd_enb_scf_name=${tl_prefix}_FDDeNB_${version_in_enb}.xml
    ...                                              is_tdd_enb_commission=${is_commission_enb}
    ...                                              timeout_for_commission=20 min
    Run Keyword If    ${is_commission_gnb}    Check GNB Whether Unexpect Alarm Should Not Exist    allowed_faults=${GNB_ALLOWED_FAULT}
    Run Keyword If    ${is_commission_enb}    Check ENB Whether Unexpect Alarm Should Not Exist    allowed_faults=${GNB_ALLOWED_FAULT}
    Run Keyword And Continue On Failure    run keyword If    '${whether_gnb_up}'=='true'    Download SW Build from artifactory
    Run Keyword And Continue On Failure    run keyword If    '${whether_enb_up}'=='true'    Download SW Build from artifactory
    ...                                                                                         target_version=${enb_target_sw}
    &{fault_4742}     Create Dictionary     faultId=${4742}
    ${GNB_ALLOWED_FAULT_with_4742}    Create List    @{GNB_ALLOWED_FAULT}    ${fault_4742}
    Set Test Variable    ${GNB_ALLOWED_FAULT_with_4742}
    &{fault_4110}     Create Dictionary     faultId=${4110}
    ${GNB_ALLOWED_FAULT_with_4110_4742}    Create List    @{GNB_ALLOWED_FAULT}    ${fault_4110}    ${fault_4742}
    Set Test Variable    ${GNB_ALLOWED_FAULT_with_4110_4742}

gNB_enb_SW_Upgrade_loops_with_WebUI_RFS_after_cells_enter_energysaving
    [Documentation]    Author:jun.8.chen@nokia-sbell.com
    [Arguments]    ${whether_do_lte_first}=${False}
    ${cell_list}    ${lbpsCellList_length}    ${lbpsCellPeriodList_length}    Get The Cell List What Will Be Enter Energy Saving Mode
    Update Related Parameters For Exit Energy Saving    cell_list=${cell_list}
    ...                                                 reportAmountCA_value=r2
    ...                                                 qRxLevMin_value=-60
    ...                                                 actBadUplinkRadioRedirect_vlaue=highUlBlerBased
    ...                                                 ulBlerThresholdRedirectData=40
    ...                                                 ulBlerThresholdRedirectVoNR=20
    Check Cell energySavingState    cell_list=${cell_list}    whether_check_energy_saving=${False}
    ${hour}    ${minute}    Get The Time For Energy Saving
    Update Related Parameters For Energy Saving    Duration=360
    ...                                            Hour=${hour}
    ...                                            Minute=${minute}
    ...                                            lbpsCellList_num=${lbpsCellList_length}
    ...                                            lbpsCellPeriodList_num=${lbpsCellPeriodList_length}
    Wait Until Keyword Succeeds    45 min    60 sec    Check Cell energySavingState    cell_list=${cell_list}
    gNB_enb_SW_Upgrade_with_WebUI_RFS    whether_do_lte_first=${whether_do_lte_first}
    ${hour}    ${minute}    Get The Time For Energy Saving
    Update Related Parameters For Energy Saving    Duration=80
    ...                                            Hour=${hour}
    ...                                            Minute=${minute}
    ...                                            lbpsCellList_num=${lbpsCellList_length}
    ...                                            lbpsCellPeriodList_num=${lbpsCellPeriodList_length}
    Wait Until Keyword Succeeds    45 min    60 sec    Check Cell energySavingState    cell_list=${cell_list}
    Sleep  30sec
    Update Related Parameters For Exit Energy Saving    cell_list=${cell_list}
    Wait Until Keyword Succeeds    45 min    15 sec    Check Cell energySavingState    cell_list=${cell_list}
    ...                                                                                whether_check_energy_saving=${False}
    gNB_enb_SW_Rollback_with_WebUI_RFS    whether_do_lte_first=${whether_do_lte_first}

Enb Upgrade Only
    [Documentation]    Author:xiangsheng.chu@nokia-sbell.com
    ...                update with enb sw upgrade
    ...                enb only upgrade to SBTS24R1_ENB_0000_000452_000004
    FOR    ${enb_id}    IN RANGE    ${enb_length}
        Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_id}
        ...                                                                        connection=enbupgrade_${enb_id}
        coam.update_software    sw_package=${enb_upgrade_package_path}    timeout=7200    connection=enbupgrade_${enb_id}
        Run Keyword And Ignore Error    Enblte close down    connection=enbupgrade_${enb_id}
        sleep  5min
        Wait Until Keyword Succeeds    3 min    5 sec    Connect to eNB via ssl    enb_index=${enb_id}    connection=enbupgrade_${enb_id}
        Run Keyword And Ignore Error    Enblte close down    connection=enbupgrade_${enb_id}
#        Check GNB On Air And Unexpect Alarm Should Not Exist
#        Check ENB On Air And Unexpect Alarm Should Not Exist
    END

Get BtsName And Version From ENB
    [Documentation]    author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${enb_index}=${0}    ${enb_connection}=enblte_${enb_index}    ${timeout}=300
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}    connection=${enb_connection}
    ${enb_info}    coam.get_bts_info    connection=${enb_connection}    timeout=${timeout}
    ${enb_btsName}    Set Variable    ${enb_info['name']}
    ${swVersion}    Set Variable    ${enb_info['swInfo']['swVersion']}
    [Return]    ${enb_btsName}    ${swVersion}
    [Teardown]    run keyword and ignore error    Enblte close down    connection=${enb_connection}

Check GNB Whether Unexpect Alarm Should Not Exist
    [Documentation]    author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${allowed_faults}    ${gnb_connection}=GNB_OAM    ${timeout}=180    ${gnb_index}=${0}
    log to console    --- start to check gnb Unexpect Alarm Should Not Exist---
    wait until keyword succeeds    2min    10sec    Connect to gnb coam via ssl    connection=${gnb_connection}    gnb_index=${gnb_index}
    Unexpect Alarm Should Not Exist    allowed_faults=${allowed_faults}    connection=${gnb_connection}    timeout=${timeout}
    [Teardown]   run keyword and ignore error    COAM Teardown gnb connections    connection=${gnb_connection}

Check ENB Whether Unexpect Alarm Should Not Exist
    [Documentation]    author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${allowed_faults}    ${enb_index}=${0}    ${enb_connection}=enbalarm_${enb_index}    ${timeout}=180
    log to console    --- start to check gnb Unexpect Alarm Should Not Exist---
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}    connection=${enb_connection}
    Unexpect Alarm Should Not Exist    allowed_faults=${allowed_faults}    connection=${enb_connection}    timeout=${timeout}
    [Teardown]   run keyword and ignore error    Enblte close down    connection=${enb_connection}

Check GNB And Enb Whether Need To Commission
    [Documentation]    author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${whether_gnb_up}    ${whether_enb_up}
    ...            ${gnb_id}=${0}    ${connection}=GNB_OAM${gnb_id}    ${timeout}=${900}
    ...            ${enb_index}=${0}    ${connection_enb}=enblte
    ${btsName_in_gnb}    ${gnb_swVersion}    Get BtsName and SwVersion    gnb_id=${gnb_id}
    ...                                                                   connection=${connection}
    ...                                                                   timeout=${timeout}
    ${version_in_gnb}    Get Current SW Version From Version Name    active_version=${gnb_swVersion}
    ${btsName_output}    OperatingSystem.Run    cat ${SCF_PATH_ON_UTE}/${tl_prefix}_gNB_${version_in_gnb}.xml | grep -i btsName
    ${btsName_in_scf}    Set Variable    ${btsName_output.split("</")[0].split(">")[-1]}
    ${whether_need_do_gnb_commssion}    Set Variable If    '${btsName_in_gnb}'=='${btsName_in_scf}'    ${False}    ${True}
    ${is_commission_gnb}    Set Variable If    '${whether_gnb_up}'=='false'    ${False}    ${whether_need_do_gnb_commssion}
    ${btsName_in_enb}    ${enb_swVersion}    Get BtsName And Version From ENB    enb_index=${enb_index}
    ...                                                                          enb_connection=${connection_enb}
    ...                                                                          timeout=${timeout}
    ${version_in_enb}    Get Current SW Version From Version Name    active_version=${enb_swVersion}
    ${enb_btsName_output}    OperatingSystem.Run    cat ${SCF_PATH_ON_UTE}/${tl_prefix}_FDDeNB_${version_in_enb}.xml | grep -i btsName
    ${enb_btsName_in_scf}    Set Variable    ${enb_btsName_output.split("</")[0].split(">")[-1]}
    ${whether_need_do_enb_commssion}    Set Variable If    '${btsName_in_enb}'=='${enb_btsName_in_scf}'    ${False}    ${True}
    ${is_commission_enb}    Set Variable If    '${whether_enb_up}'=='false'    ${False}    ${whether_need_do_enb_commssion}
    [Return]    ${is_commission_gnb}    ${is_commission_enb}    ${version_in_gnb}    ${version_in_enb}

Get Current SW Version From Version Name
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${active_version}
    ${version_splitted}    Split String    ${active_version}    _
    ${tmp_program_version}    Replace String Using Regexp    string=${version_splitted[0]}    pattern=SBTS|5G    replace_with=${EMPTY}
    ${is_trunk}    Run Keyword And Return Status    Should Contain Any    ${active_version}    _9999_    _9990_
    ${branch}    Set Variable If    ${is_trunk}    master    ${tmp_program_version}
    [Return]    ${branch}

Need To Do SCF Commission
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]     ${scf_name}=None    ${tdd_enb_scf_name}=None
    ...             ${connection}=GNB_OAM0    ${is_commission}=True    ${is_tdd_enb_commission}=False
    ...             ${timeout_for_commission}=900    ${is_pdl_checking_needed}=${True}
    ...             ${tdd_enb_index}=${0}    ${tdd_enb_connection}=enbcommission_${tdd_enb_index}
    Run Keyword If    ${is_commission}    run keywords
    ...    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${0}    AND
    ...    COAM Commission with scf file    scf_file_path=${SCF_PATH_ON_UTE}/${scf_name}
    ...                                     connection=${connection}
    ...                                     timeout=${timeout_for_commission}
    ...                                     is_pdl_checking_needed=${is_pdl_checking_needed}
    Run Keyword If    ${is_commission}    Check TMO Gnb Ready And All Cell On Air    connection=${connection}
    Run Keyword If    ${is_tdd_enb_commission}    run keywords
    ...    Connect to eNB via ssl    enb_index=${tdd_enb_index}    connection=${tdd_enb_connection}    AND
    ...    COAM Commission with scf file    scf_file_path=${SCF_PATH_ON_UTE}/${tdd_enb_scf_name}
    ...                                     connection=${tdd_enb_connection}
    ...                                     timeout=${timeout_for_commission}
    ...                                     is_pdl_checking_needed=${is_pdl_checking_needed}
    Run Keyword If    ${is_tdd_enb_commission}    Verify All Enbs Cell On Air
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}    AND
    ...           Run Keyword And Ignore Error    Enblte close down   connection=${tdd_enb_connection}

#Update Sw On Gnb
#    [Documentation]    author: tingting.1.liu@nokia-sbell.com
#    log to console    step1:Login WebUI
#    run keyword and ignore error    selenium_coam.logout
#    selenium_coam.login
#    ...    url=https://${tl.gnbs[0].cu.oam_http_connection_details.addr}/    username=Nemuadmin    password=nemuuser
#    Step2 Check Current Sw Version 1
#    Step3 Upgrade Site With Active
#    Step4 Check Sw Version After Upgrade
#    sleep  10min
#    Step6 Check Site Status
#    log to console    step7:logout webui
#    run keyword and ignore error    selenium_coam.logout

#Step2 Check Current Sw Version 1
#    [Documentation]    author: tingting.1.liu@nokia-sbell.com
#    log to console   step2:check current sw version 1
#    ${version}    wait until keyword succeeds    1min    10s    selenium_coam.check_current_software_version
#    ${output}    set variable    &{version}[Active]
#    set suite variable    ${pre_active_version_1}   ${output}
#    sleep    5s
#
#Step2 Check Current Sw Version 2
#    [Documentation]    author: tingting.1.liu@nokia-sbell.com
#    log to console    step2:check current sw version 2
#    ${version}    wait until keyword succeeds    1min    10s    selenium_coam.check_current_software_version
#    ${output}    set variable    &{version}[Active]
#    ${pre_active_version_2}    set variable    ${output}
#    set suite variable    ${pre_active_version_2}
#    ${pre_passive_version_2}    set variable    &{version}[Passive]
#    set suite variable    ${pre_passive_version_2}
#    sleep    5s
#
#Step3 Execute Rollback
#    [Documentation]    author: tingting.1.liu@nokia-sbell.com
#    log to console    step3:execute rollback
#    run keyword and ignore error     selenium_coam.disable_screen_lock
#    wait until keyword succeeds    1min    10s    selenium_coam.software_rollback
#    sleep    5min
#
#Step3 Upgrade Site With Active
#    [Documentation]    author: tingting.1.liu@nokia-sbell.com
#    log to console    step3:upgrade site with active
#    csn.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
#    ...               username=${tl.test_pc.default_ssh_connection_details.username}
#    ...               password=${tl.test_pc.default_ssh_connection_details.password}
#    ...               alias=TESTPC
#    ${package_full_link}    Get Download Path From Target Value
#    ${upgrade_package_path}    Download SW Build To VM    package_full_link=${package_full_link}
#    set suite variable    ${upgrade_package_path}
#    csn.disconnect    connection=TESTPC
#    wait until keyword succeeds     5 min   10 sec
#    ...     coam.connect to       bts_host=${asik_addr}     name=coam_admin
#    coam.update_software    sw_package=${upgrade_package_path}    timeout=7200    connection=coam_admin
#
#Step4 Confirm Rollback Success
#    [Documentation]    author: tingting.1.liu@nokia-sbell.com
#    log to console    step4:confirm rollback success
#    wait until keyword succeeds    15min    1min    check if rollback success
#    sleep    5s
#
#Step4 Check Sw Version After Upgrade
#    [Documentation]    author: tingting.1.liu@nokia-sbell.com
#    log to console    step4:check SW version after upgrade
#    wait until keyword succeeds     40min    2min    Check if Airscal Upgrade Successfully
#    Check If SW Upgrade Success
#
#Step5 Env Recovery
#    [Documentation]   tingting.1.liu@nokia-sbell.com
#    log to console    step5:ENV recovery
#    run keyword if    "${rollback_status}"=="FAIL"   Step3 Execute Rollback

#Step6 Check Site Status
#    [Documentation]    author: tingting.1.liu@nokia-sbell.com
#    log to console    step6:check site status
#    Check TMO Gnb Ready And All Cell On Air
#    ${enb_length}    Get Length    ${tl.enbs}
#    FOR    ${enb_id}    IN RANGE    ${enb_length}
#        Wait until keyword succeeds    2 min    20 sec    Verify Enb All Cell On Air    enb_index=${enb_id}
#    END

#Get Download Path From Target Value
#    [Documentation]    author: tingting.1.liu@nokia-sbell.com
#    @{target_result}    string.split string    string=${target_version}    separator=_
#    ${result5}     convert to string    @{target_result}[-5]
#    ${if_SBTS21B}     convert to string    @{target_result}[-3]
#    ${package_full_link}=   Run Keyword If   "${result5}"=="SBTS22R2" and "${if_SBTS21B}"=="9999"
#    ...   Set Variable     ${SBTS00_package_link}/${package_version_1525-CA}/${package_version_1525-CA}_release_BTSSM_downloadable_A54.zip
#    ...   ELSE IF    "${result5}"=="SBTS21B" and "${if_SBTS21B}"=="0000"
#    ...   Set Variable     ${SBTS21B_package_link}/${package_version_1525-CA}/${package_version_1525-CA}_release_BTSSM_downloadable_A54.zip
#    ...   ELSE IF    "${result5}"=="SBTS22R1" and "${if_SBTS21B}"=="0000"
#    ...   Set Variable     ${SBTS22R1_package_link}/${package_version_1525-CA}/${package_version_1525-CA}_release_BTSSM_downloadable_A54.zip
#    ...   ELSE IF    "${result5}"=="SBTS22R2" and "${if_SBTS21B}"=="0000"
#    ...   Set Variable     ${SBTS22R2_package_link}/${package_version_1525-CA}/${package_version_1525-CA}_release_BTSSM_downloadable_A54.zip
#    ...   ELSE IF    "${result5}"=="SBTS22R2" and "${if_SBTS21B}"=="9999"
#    ...   Set Variable     ${SBTS00_package_link}/${package_version_1525-CA}/${package_version_1525-CA}_release_BTSSM_downloadable_A54.zip
#    ...   ELSE    Set Variable     ${package_link}/${package_version_1525-CA}/AirScale-${package_version_1525-CA}.zip
#    [Return]      ${package_full_link}

#Download SW Build To VM
#    [Documentation]    author: tingting.1.liu@nokia-sbell.com
#    [Arguments]    ${package_full_link}
#    OperatingSystem.Empty Directory    ${SW_build_path}
#    ${current_version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
#    @{result}    string.split string    string=&{current_version}[Active]    separator=_
#    ${package_stream}     convert to string    @{result}[-5]
#    set suite variable     ${package_stream}
#    Run Keyword If
#    ...    "${package_stream}"=="SBTS21B" or "${package_stream}"=="SBTS22R1" or "${package_stream}"=="SBTS22R2" or "${package_stream}"=="SBTS22R3"
#    ...             Run And Return Rc And Output    wget --no-proxy ${package_full_link}.sha256 -P ${SW_build_path}
#    ...    ELSE     Run And Return Rc And Output    wget --no-proxy ${package_full_link}.md5 -P ${SW_build_path}
#    ${output}    OperatingSystem.List Directory    ${SW_build_path}    absolute=${TRUE}
#    ${md5_file}     set variable    @{output}[0]
#    ${md5_value}      OperatingSystem.get file    ${md5_file}
#    OperatingSystem.Empty Directory    ${SW_build_path}
#    Run And Return Rc And Output    wget --no-proxy ${package_full_link} -P ${SW_build_path}
#    ${output}    OperatingSystem.List Directory    ${SW_build_path}    absolute=${TRUE}
#    ${upgrade_package_path}     set variable    @{output}[0]
#    sleep    5min
#    wait until keyword succeeds    10min    10s    Check Download Completed Successfully    ${upgrade_package_path}     ${md5_value}
#    [Return]      ${upgrade_package_path}

#Check If SW Upgrade Success
#    [Documentation]    author: tingting.1.liu@nokia-sbell.com
#    ${update_result}    ${version}    run keyword and ignore error    Check Sw Version With External Package Value    check_version=Active
#    set suite variable    ${update_result}
#    ${result_2}    should match regexp    &{version}[Planned]    ${EMPTY}

#Check Sw Version With External Package Value
#    [Documentation]    this KW is to check the SW version when the download version is from the external value
#    [Arguments]     ${check_version}
#    run keyword and ignore error    selenium_coam.logout
#    selenium_coam.login
#    ...    url=https://${tl.gnbs[0].cu.oam_http_connection_details.addr}/    username=Nemuadmin    password=nemuuser
#    ${version}    wait until keyword succeeds    2min   15s    selenium_coam.check_current_software_version
#    @{result}    string.split string    string=&{version}[${check_version}]    separator=_
#    ${version_now}     convert to string    @{result}[-5]
#    ${SW_check}    convert to integer      @{result}[-1]
#    ${if_SBTS00}     convert to string    @{result}[-3]
#    @{result}    string.split string     string=${package_version_1525-CA}    separator=.
#    ${current_version}=   Run Keyword If   "${version_now}"=="SBTS22R2" and "${if_SBTS00}"=="9999"
#    ...    string.Replace String    &{version}[${check_version}]    22R2    00
#    ...    ELSE IF     "${version_now}"=="SBTS22R3" and "${if_SBTS00}"=="9999"
#    ...    string.Replace String    &{version}[${check_version}]    22R3    00
#    ...    ELSE IF    "${version_now}"=="SBTS21B" or "${version_now}"=="SBTS22R1" or "${version_now}"=="SBTS22R2" and "${if_SBTS00}"=="0000"
#    ...    Set Variable    ${version['${check_version}']}
#    Run Keyword If   "${version_now}"=="SBTS22R2" or "${version_now}"=="SBTS22R3" or "${version_now}"=="SBTS22R1"
#    ...    should be equal    "${current_version}"    "${package_version_1525-CA}"
#    ...    ELSE    should be equal    "${SW_check}"    "@{result}[-1]"
#    [Return]    ${version}
#
#Check if Airscal Upgrade Successfully
#    [Documentation]    author: tingting.1.liu@nokia-sbell.com
#    ${If_SBTS00}    Run Keyword and Ignore Error    should contain    ${package_version_1525-CA}    SBTS00
#    ${If_SBTS21B}    Run Keyword and Ignore Error    should contain    ${package_version_1525-CA}    SBTS21B
#    run keyword if     '${If_SBTS00[0]}' == 'PASS'       Check Common Load Version
#    ...    ELSE IF   '${If_SBTS21B[0]}' == 'PASS'        Check 21B Version
#    ...    ELSE      Check Normal Gnb Version
#    csn.reset_cache
#
#Check Common Load Version
#    [Documentation]    author: tingting.1.liu@nokia-sbell.com
#    csn.reset_cache
#    csn.Connect to    hostname=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
#    ...               username=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
#    ...               password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
#    ...               alias=asik
#    csn.send_command    command=ls /ffs/run/TargetBD*\.xml    connection=asik
#    ${result}     csn.read_output    connection=asik
#    ${str}=	    Remove String	    ${package_version_1525-CA}    SBTS00
#    should contain    ${result}    ${str}
#    csn.reset_cache
#
#Check 21B Version
#    [Documentation]    author: tingting.1.liu@nokia-sbell.com
#    csn.reset_cache
#    csn.Connect to    hostname=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
#    ...               username=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
#    ...               password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
#    ...               alias=asik
#    csn.send_command    command=ls /ffs/run/TargetBD*\.xml    connection=asik
#    ${result}     csn.read_output    connection=asik
#    should contain    ${result}    ${package_version_1525-CA}
#    csn.reset_cache

#check if rollback success
#    ${version}    wait until keyword succeeds    1min    10s    selenium_coam.check_current_software_version
#    ${output}    set variable    &{version}[Active]
#    should match regexp    ${output}    ${pre_passive_version_2}
#    sleep    5s
#    should match regexp    &{version}[Passive]    ${pre_active_version_2}
#    sleep    5s
#    should match regexp    &{version}[Planned]    ${EMPTY}
#    sleep    5s
