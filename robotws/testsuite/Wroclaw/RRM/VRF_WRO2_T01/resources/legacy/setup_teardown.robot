*** Settings ***
Documentation
...  contact:       pawel.1.wisniewski@nokia.com, wiktor.jarosinski@nokia.com
...  maintainer:    pawel.1.wisniewski@nokia.com, wiktor.jarosinski@nokia.com

Library    Collections
Library    OperatingSystem
Library    DateTime
Library    taf.analyzer.pdml
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Library    testsuite.Wroclaw.RRM.resources.webui.WebuiInterface  WITH NAME  WebUI
Library    taf.converters.pcaptopdml   WITH NAME   pcaptopdml
Library    taf.collectors.core        WITH NAME    core
Library    taf.analyzer.pdml          WITH NAME    pdml
Library    taf.collectors.btslog  WITH NAME   btslog
Library    ute_syslog
Library    taf.transport.ssh
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common.py
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/SWInstaller.py    WITH NAME   sw_installer
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/MCSharkInstaller.py   WITH NAME   mc_shark
Resource   testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common_kw.robot
Resource   testsuite/Wroclaw/RRM/resources/preconditions.robot
Resource   testsuite/Wroclaw/RRM/resources/connections.robot
Resource   testsuite/Wroclaw/RRM/resources/logs.robot

*** Variables ***
${DEFAULT_SCF_PATH}          ${OUTPUT DIR}/${SUITE NAME}
${DEFAULT_SCF_FILENAME}      default_gNB_scf.xml
${DEFAULT_ENB_SCF_FILENAME}  default_eNB_scf.xml
${MRBTS_5G_ID}               ${tl.gnbs[0].instance_id}
${default_syslog_alias}      test_syslog
${GNB_SCF_PATH}              ${EXECDIR}/${SUITE NAME}
${ENB_SCF_PATH}              ${EXECDIR}/${SUITE NAME}

*** Keywords ***
Prepare testline before test
    [Arguments]         ${required_config_type}=None
    Start syslog capture    log_dir=${OUTPUT DIR}/${SUITE_NAME}/    log_name=SETUP_SYSLOG.LOG
    ...                     alias=setup_syslog
    Get and upload default SCF  ${required_config_type}
    Check and install incompatible sw
    Verify if all cells are onair
    Upload gnbMirroring Script To ASIK    script_folder=testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/gnbMirroring
    Check alarms after startup
    [Teardown]   run keywords
    ...          Collect snapshot if setup failed  AND
    ...          Stop syslog capture    alias=setup_syslog

Check config type and upload required SCF
    [Arguments]         ${required_config_type}=None
    ${current_type}  Check config type
    Run keyword if      '${required_config_type}' != '${current_type}'
    ...     Run keywords
    ...     Log to console  Current SCF (${current_type}) does not meet the required TL type (${required_config_type})
    ...     AND             Get and upload default SCF  ${required_config_type}
    ...  ELSE  Log to console  Current SCF (${current_type}) meets the TC's requirement

Get and upload default SCF
    [Arguments]         ${config_type}=None
    Check if IWK4ALL for SBTS00
    ${scf_path}  Get test line SCF path  ${config_type}
    Log to console  Getting a default SCF from path: '${scf_path}'
    Upload scf and perform commissioning  ${scf_path}

Check if IWK4ALL for SBTS00
    ${is_release_equals_trunk}    Check if sw is SBTS00
    ${is_equal_iwk4all}           Check if test line is IWK4ALL
    Run Keyword If    '${is_release_equals_trunk}' == 'True' and '${is_equal_iwk4all}' == 'True'
    ...    Set global Variable  ${config_type}  IWK4ALL

Check if sw is SBTS00 in reservaton json file
    ${enb_build}    get sw from ute reservation    #/opt/ute/reservation.json
    ${part}         split string    ${enb_build}  _
    ${part}         Set Variable    ${part}[0]
    ${subpart}      Get Substring   ${part}  4
    ${is_subpart_equal_00}    Run Keyword If    '${subpart}' == '00'
    ...    Set Variable    True    ELSE
    ...    Set Variable    False
    [Return]        ${is_subpart_equal_00}

Check if sw is SBTS00
    [Documentation]  is_release_equals_trunk should be True if sbts00 is a current release on TL
    Connect with runtime release    get_release
    ${release}  coam.get_sw_version  connection=get_release
    ${is_release_equals_trunk}    Run Keyword And Return Status    Should Contain    ${release}    _9999_
    [Teardown]      coam.teardown  connection=get_release
    [Return]        ${is_release_equals_trunk}

Check if test line is IWK4ALL
    @{TL_IWK4ALL}  Set Variable    7_16_UTE5GSA5    7_16_UTE5GCLOUDT152
    ${tl_name}             Run Keyword    Evaluate    socket.gethostname().replace('-', '_')    modules=socket
    ${is_equal_iwk4all}    Run Keyword If    '${tl_name}' in ${TL_IWK4ALL}
    ...    Set Variable    True    ELSE
    ...    Set Variable    False
    [Return]    ${is_equal_iwk4all}


Set BTS and cell ids as suite variables
    Set suite variable    ${bts_id}       ${tl.gnbs[0].instance_id}
    ${cell_dists}   Get cells distname list
    Set suite variable    ${cell_dists}

Get BTS id and set as suite variable
    Set suite variable    ${bts_id}       ${tl.gnbs[0].instance_id}

Start BTSlog
    [Arguments]         ${name}=btslog
    btslog.Create btslog collector
    ...                         name=${name}
    ...                         log_dir=/tmp/btslog2
    btslog.Setup collectors     names=${name}
    btslog.Start collectors     names=${name}
    btslog.Set suite alias      btslog

Stop BTSlog
    [Arguments]         ${name}=btslog
    btslog.Stop collectors      names=${name}
    btslog.Collect collectors   names=${name}
    btslog.Teardown collectors  names=${name}

Start syslog capture
    [Arguments]   ${log_dir}=${OUTPUT DIR}/${SUITE_NAME}/${TEST_NAME}/  ${log_name}=SYSLOG.LOG
    ...           ${alias}=${default_syslog_alias}
    ute_syslog.start_syslog  log_dir=${log_dir}  log_name=${log_name}  alias=${alias}

Stop syslog capture
    [Arguments]   ${alias}=${default_syslog_alias}
    ute_syslog.collect_syslog_results  alias=${alias}
    ute_syslog.teardown_all_aliases_for_syslog

Download SCF
    [Arguments]  ${target_file}=${DEFAULT_SCF_FILENAME}
    Log to console      __Download SCF file from WebUI.
    Connect with runtime release    coam
    coam.get current scf file  connection=coam  local_dir_path=${DEFAULT_SCF_PATH}  file_name=${target_file}
    ...                        timeout=6min
    [Teardown]    coam.teardown  connection=coam

Replace swconfig
    [Arguments]     ${feature}=5GC000000
    ...             ${swconfig_remote_path}=/rom/swconfig.txt
    ...             ${asik_connection}=asik
    ${swconfig_local_path}  Set variable  testsuite/Wroclaw/RRM/VRF_WRO2_T01/${feature}/resources/swconfig.txt
    Log to console      __Swap swconfig.txt on ASIK.
    OperatingSystem.File should exist    ${swconfig_local_path}
    ${flags}    Run    cat ${swconfig_local_path}
    Connect to asik     ${asik_connection}
    ${ssh_command}    Set variable    echo "${flags}" > ${swconfig_remote_path}
    ssh.Execute     command=${ssh_command}    connection=${asik_connection}
    [Teardown]   ssh.Disconnect  connection=${asik_connection}

Remove tmp btslog dir
    [Arguments]     ${path}=/tmp/btslog2
    Remove directory    ${path}    recursive=${True}

Enable eirp trace
    [Arguments]         ${local_path}=testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/set_feature_traces.sh
    ...                 ${remote_path}=/home/set_feature_traces.sh
    ...                 ${alias}=ASIK
    [Documentation]     Enable eirp trace using .sh file and reset site
    ...                 local_path     |    path to set_feature_traces.sh file
    ...                 remote_path    |    path to ASIK's home
    ...                 alias          |    connection type
    ssh.Connect_to      hostname=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...                 username=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...                 password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ...                 alias=${alias}
    ssh.Upload_file     local_path=${local_path}    remote_path=${remote_path}    connection=${alias}
    ssh.Execute         chmod 755 ${remote_path}    connection=${alias}
    ${out}              ssh.Execute    ${remote_path}    connection=${alias}
    ${contains}         Evaluate   "level=DBG" in """${out}"""
    Run keyword if      ${contains}    Should contain    ${out}    L2.L2_PS.EIRP=1
    ...                 ELSE    Should contain    ${out}    Already Done
    Log to console      __Perform site reset to enable EIRP trace.
    coam.Connect_to     name=${alias}
    coam.Reset_site     connection=${alias}
    Verify if all cells are onair
    [Teardown]          Run keywords
    ...                 ssh.Disconnect     connection=${alias}    AND
    ...                 coam.Teardown      connection=${alias}

Recommission to default
    [Arguments]         ${alias}=coam_recommissioning
    ...                 ${timeout}=10min
    Log to console      __Perform recommissioning to default state.
    Connect with runtime release     ${alias}
    coam.Perform commissioning
    ...                 bts_id=${MRBTS_5G_ID}
    ...                 scf_file=${DEFAULT_SCF_PATH}/${DEFAULT_SCF_FILENAME}
    ...                 skip_parameter_relation_errors=${TRUE}
    ...                 should_activate=${TRUE}
    ...                 timeout=${timeout}
    ...                 connection=${alias}
    OperatingSystem.Remove file         path=${DEFAULT_SCF_FILENAME}
    Verify if all cells are onair
    [Teardown]          coam.Teardown  connection=${alias}

Collect snapshot
    [Arguments]         ${alias}=coam
    ...                 ${snap_coverage}=Full
    ...                 ${force}=${TRUE}
    ...                 ${timeout_value}=1800sec
    Log to console      __Collect snapshot.
    Connect with runtime release     ${alias}
    ${software_info}    coam.Get software info  connection=${alias}
    ${sw_version}       Set variable  ${software_info['Active SW version']}
    ${timestamp}        DateTime.Get Current Date  result_format=%Y%m%d-%H%M%S
    ${status}=   Run Keyword And Return Status   Variable should exist   ${TEST NAME}
    ${snapshot_path}=   Set variable if   ${status}==True
    ...   ${OUTPUT DIR}/${SUITE NAME}/${TEST NAME}/Snapshot_${sw_version}_${timestamp}.zip
    ...   ${OUTPUT DIR}/${SUITE NAME}/Snapshot_${sw_version}_${timestamp}.zip
    coam.Get snapshot   ${snapshot_path}
    ...                 ${snap_coverage}
    ...                 ${force}
    ...                 ${timeout_value}
    ...                 ${alias}
    [Teardown]          coam.Teardown  connection=${alias}

Collect snapshot from LTE site
    [Arguments]         ${lte_mplane}
    ...                 ${snap_coverage}=Full
    ...                 ${force}=${TRUE}
    ...                 ${timeout_value}=1800sec
    Log to console      __Collect snapshot.
    ${connection}       coam.connect to    bts_host=${lte_mplane}
    ${software_info}    coam.Get software info  connection=${connection}
    ${sw_version}       Set variable  ${software_info['Active SW version']}
    ${timestamp}        DateTime.Get Current Date  result_format=%Y%m%d-%H%M%S
    ${status}=   Run Keyword And Return Status   Variable should exist   ${TEST NAME}
    ${snapshot_path}=   Set variable if   ${status}==True
    ...   ${OUTPUT DIR}/${SUITE NAME}/${TEST NAME}/Snapshot_LTE_${sw_version}_${timestamp}.zip
    ...   ${OUTPUT DIR}/${SUITE NAME}/Snapshot_LTE_${sw_version}_${timestamp}.zip
    coam.Get snapshot   ${snapshot_path}
    ...                 ${snap_coverage}
    ...                 ${force}
    ...                 ${timeout_value}
    ...                 ${connection}
    [Teardown]          coam.Teardown  connection=${connection}

Collect snapshot if test failed
    run keyword if    '${TEST_STATUS}'=='FAIL'    setup_teardown.Collect snapshot

Collect snapshot if keyword failed
    run keyword if    '${KEYWORD_STATUS}'=='FAIL'    Collect snapshot

Collect snapshot with full recovery
    sleep    5m
    Collect snapshot

Collect snapshot if setup failed
    run keyword if    '${KEYWORD_STATUS}'=='FAIL'    Collect snapshot with full recovery

Suite cOAM Teradown
    Teardown cOAM session

Teardown cOAM session
    [Arguments]         ${alias}=default
    [Documentation]  Disconnects and destroy node.js daemon
    ...     alias:   AdminConnection object or if used, string name alias
    run keyword and ignore error        coam.teardown          connection=${alias}

Check and install incompatible sw
    Connect with runtime release    bts
    ${alarms}  coam.get alarms    connection=bts
    ${incompatible_sw}    set variable    23
    ${result}    common.check_fault_id    fault_id=${incompatible_sw}     alarms_list=${alarms}
    Run Keyword If  ${result}  log to console  FID:23 has been detected. Installing software for radios...
    Run Keyword If  ${result}  sw_installer.download and install
    [Teardown]    coam.teardown    connection=bts

Check radioMasterDN
    Log to console      __Check radioMasterDN
    WebUI.Create session
    ${content}          WebUI.Get current scf content
    ${status}   run keyword and return status   Should Contain 	 ${content}     radioMasterDN
    Set suite variable  ${RADIO_SHARED}   ${status}
    [Teardown]          WebUI.Teardown session

ENB mplane snapshot
    [Arguments]
    ...                 ${snap_coverage}=Full
    ...                 ${force}=${TRUE}
    ...                 ${timeout_value}=600sec
    Log to console      __Collect snapshot on ENB
    coam.connect_to     name=enb     bts_host=${tl.enbs[0].m.v4}
    ${software_info}    coam.Get software info   connection=enb
    ${sw_version}       Set variable  ${software_info['Active SW version']}
    ${timestamp}        DateTime.Get Current Date  result_format=%Y%m%d-%H%M%S
    ${snapshot_path}    Set variable  ${OUTPUT DIR}/${SUITE NAME}/${TEST NAME}/Snapshot_${sw_version}_${timestamp}.zip
    coam.Get snapshot   ${snapshot_path}
    ...                 ${snap_coverage}
    ...                 ${force}
    ...                 ${timeout_value}
    ...                 enb
    [Teardown]          coam.Teardown  connection=enb


Collect snapshot from enb
    Run keyword if   ${RADIO_SHARED}==True   ENB mplane snapshot

Check alarms after startup
    coam.connect to                                name=alarm_conn
    coam.add allowed alarm    faultId=61649        connection=alarm_conn
    coam.add allowed alarm    faultId=4681         connection=alarm_conn
    coam.add allowed alarm    faultId=4655         connection=alarm_conn
    coam.add allowed alarm    faultId=61524        connection=alarm_conn
    coam.add allowed alarm    faultId=4654         connection=alarm_conn
    coam.add allowed alarm    faultId=8150         connection=alarm_conn
    coam.add allowed alarm    faultId=61652        connection=alarm_conn
    coam.add allowed alarm    faultId=1898        connection=alarm_conn
    coam.assert_no_unexpected_active_alarms        connection=alarm_conn
    [Teardown]    coam.teardown                    connection=alarm_conn

Get allowed alarms and check rest
    [Arguments]  ${alarm_list}
    coam.connect to                                name=alarm_conn
    FOR  ${alarm}  IN  @{alarm_list}
        coam.add allowed alarm    faultId=${alarm}         connection=alarm_conn
    END
    coam.assert_no_unexpected_active_alarms        connection=alarm_conn
    [Teardown]    coam.teardown                    connection=alarm_conn

Prepare testline WPT PS6
    [Arguments]  ${scf_path}=testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB009235/resources/CB009235.xml
    Start syslog capture    log_dir=${OUTPUT DIR}/${SUITE_NAME}/    log_name=SETUP_SYSLOG.LOG
    ...                     alias=setup_syslog
    Upload scf and perform commissioning  ${scf_path}
    Check and install incompatible sw
    Verify if all cells are onair
    Check alarms after startup
    [Teardown]   run keywords
    ...          Collect snapshot if setup failed  AND
    ...          Stop syslog capture    alias=setup_syslog

Change to ute_ue
    [Documentation] Not working in runtime. It must be used befor target execution.
    log to console  Changing taf.ue library to ute_ue
    run  find testsuite/Wroclaw/RRM/VRF_WRO2_T01/ -type f -name "*.robot" -exec sed -i "s/taf.ue/ute_ue/g" {} +
    run  find testsuite/Wroclaw/RRM/VRF_WRO2_T01/ -type f -name "*.resource" -exec sed -i "s/taf.ue/ute_ue/g" {} +

Download SCF gNB
    [Arguments]
    ...    ${scf_save_path}=${EXECDIR}/${SUITE NAME}
    ...    ${scf_file_name}=default_gNB_scf

    Log to console      __Download SCF file from gNB WebUI.
    Connect with runtime release    gnb_scf
    coam.get current scf file    connection=gnb_scf
    ...                          local_dir_path=${scf_save_path}
    ...                          file_name=${scf_file_name}.xml
    ...                          timeout=6min

Download SCF eNB
    [Arguments]
    ...    ${scf_save_path}=${EXECDIR}/${SUITE NAME}
    ...    ${scf_file_name}=default_eNB_scf

    Log to console      __Download SCF file from eNB WebUI.
    coam.connect_to          name=enb_scf  bts_host=${ENB_M_PLANE}
    coam.get current scf file    connection=enb_scf
    ...                          local_dir_path=${scf_save_path}
    ...                          file_name=${scf_file_name}.xml
    ...                          timeout=6min

Download gNB and eNB SFCs
    [Arguments]
    ...    ${scf_save_path}=${EXECDIR}/${SUITE NAME}
    ...    ${gnb_scf_file_name}=default_gNB_scf
    ...    ${enb_scf_file_name}=default_eNB_scf

    Download SCF gNB    ${scf_save_path}    ${gnb_scf_file_name}
    Download SCF eNB    ${scf_save_path}    ${enb_scf_file_name}

Recommission gNB and eNB in background
    [Arguments]
    ...    ${gNB_scf_path}=${GNB_SCF_PATH}/${DEFAULT_SCF_FILENAME}
    ...    ${eNB_scf_path}=${ENB_SCF_PATH}/${DEFAULT_ENB_SCF_FILENAME}

    coam.Setup admin    # for gNB site
    coam.Setup admin    bts_host=${ENB_M_PLANE}    alias=background_eNB    # for eNB site

    ${task_1}    coam.Run Keyword In Background    Perform Commissioning
    ...                                            bts_id=${MRBTS_5G_ID}
    ...                                            scf_file=${gNB_scf_path}
    ...                                            skip_parameter_relation_errors=${True}
    ...                                            should_activate=${True}
    ...                                            timeout=360
    ...                                            connection=${GNB_CONNECTION_ALIAS}

    ${task_2}    coam.Run Keyword In Background    Perform Commissioning
    ...                                            bts_id=${MRBTS_4G_ID}
    ...                                            scf_file=${eNB_scf_path}
    ...                                            skip_parameter_relation_errors=${True}
    ...                                            should_activate=${True}
    ...                                            timeout=360
    ...                                            connection=${ENB_CONNECTION_ALIAS}
    ...                                            alias=background_eNB    # alias for 'run keyword in background'

    ${result_1}    coam.Collect Keyword Result     ${task_1}    1800
    ${result_2}    coam.Collect Keyword Result     ${task_2}    360

#    Log To Console    ${result_1}
#    Log To Console    ${result_2}

    [Teardown]    coam.teardown all aliases for admin
