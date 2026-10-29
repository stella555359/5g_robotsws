*** Settings ***
Library    taf.ul.ue.sim.env_setup
Library    OperatingSystem
Library    taf.transport.ssh    WITH NAME    SSH
Library    taf.sbts.oam.coam.admin
Library    ute_syslog
Library    ute_fsmaccess
Library    ta_uexgate
Library    ta_kiss_enb_ttitrace
Library    ute_pdu
Library    ute_wtssim
Library    Collections
Library    ta_a2a
Library    OperatingSystem
Library    String
Library    ta_messaging
Library    ${CURDIR}/../python/vendor_modify.py
Library    ${CURDIR}/../python/RT2_lib.py
Library    ${CURDIR}/../python/local_xml.py
Library    ${CURDIR}/../python/rt_parse_ttitrace.py
Resource    ${CURDIR}/../robot/SCFC_Configure_ABIO.robot
Resource    ${CURDIR}/../robot/4g_common_resource.robot

*** Variables ***
${KILL_BTSLOG}    timeout 5 sudo kill -9 $(ps -ef|grep btslog|grep -v grep|awk '{print $2}') 1>/dev/null 2>&1
${ENB_SWCONFIG_PATH}    ${CURDIR}/configuration_file/T111_R4BO9/swconfig_eNB.txt
${BTS_HOST}    192.168.255.1
${BTS_PORT}    443

*** Keywords ***
Start enb and cus syslog'${id}'
    ${stat}    ${ret}    run_keyword_and_ignore_error    stop_syslog    alias=enb
    ${stat}    ${ret}    run_keyword_and_ignore_error    stop_syslog    alias=cus
    Start syslog    log_dir=${TEST LOG DIRECTORY()}    log_name=enb_syslog_${id}.LOG    ip=192.168.255.126    alias=enb
    Start syslog    log_dir=${TEST LOG DIRECTORY()}    log_name=cus_syslog_${id}.LOG    ip=192.168.200.126    alias=cus

Stop and collect enb and cus syslog
    collect_syslog_results    alias=enb    destination=${TEST LOG DIRECTORY()}${/}syslog
    collect_syslog_results    alias=cus    destination=${TEST LOG DIRECTORY()}${/}cus_syslog

Start_capture_ttitrace'${id}'
    setup enb ttitrace    log_path=${TEST LOG DIRECTORY()}${/}ttitrace_${id}
    start enb ttitrace    node_type=ALL    cell_id=ALL    port=15003    filesize=200

Save_and_Decode_ttitrace_'${id}'
    @{dat_file}=    stop enb ttitrace
    FOR    ${item}    IN    @{dat_file}
        decode_enb_ttitrace    dat_file=${item}    nb=${False}
        Remove Files    ${item}    ${TEST LOG DIRECTORY()}${/}ttitrace_${id}${/}*.harq
    END
    teardown enb ttitrace

Collect procotol log '${id}' from egate
    iphy_setup    edamon_port=10000    egate_port=20000    alias=collect_egate
    iphy_get_egate_console_log    log_save_path=${TEST LOG DIRECTORY()}${/}procotol_${id}    alias=collect_egate
    iphy_teardown    alias=collect_egate

Ftp upload swconfig 
    [Arguments]    ${eNB_swconfig_path} 
    #run    curl -T ${CURDIR}/configuration_file/swconfig.txt ftp://192.168.255.1/ffs/run/ --user toor4nsn:oZPS0POrRieRtu  
    setup_enb_fsm_access    alias=enb1
    put_enb_file    ${eNB_swconfig_path}    /ffs/run/swconfig.txt    alias=enb1
    execute_command_on_enb    rm -rf /ffs/run/swconfig.txt.p7    alias=enb1
    execute_command_on_enb    crasign /ffs/run/swconfig.txt    alias=enb1
    teardown_enb_fsm_access    alias=enb1

Online change parameter delta commission via admin
    [Arguments]    ${filename}
    setup admin    bts_host=${bts_host}    bts_port=${bts_port}    use_ssl=True    alias=delta_commission
    perform_delta_recommissioning    delta_file=${CURDIR}/${filename}    skip_parameter_relation_errors=${True}    alias=delta_commission
    teardown admin    alias=delta_commission

Open debug log of log level'${parameter}'set'${value}'on'${direction}'for'${cell_id}'
    set_rad_parameter    setlog    ${direction}    ${cell_id}    ${parameter}    ${value}

Open debug log of rd parameter'${parameter}'set'${value}'on'${direction}'for'${cell_id}'
    set_rad_parameter    setrd    ${direction}    ${cell_id}    ${parameter}    ${value}

Attach assign number single_UE'${ue_id}' of category'${category}' into cell'${cell_id}'
    Run UEx command    ue_attach    id=${ue_id}    ue_eutra_capabilities=${category}    cell=${cell_id}

Get_cell_core_id
    [Arguments]    ${cell_id}    ${node}
    setup enb ttitrace    log_path=${TEST LOG DIRECTORY()}
    ${core_id}=    Get Intact Core Id    node_type=${node}    cell_id=${cell_id}
    teardown enb ttitrace
    Return From Keyword    ${core_id}