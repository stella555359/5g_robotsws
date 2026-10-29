# *** Settings ***
# Documentation     1836 features.
# Suite Setup       Common suite_setup
# Suite Teardown    Common suite teardown
# Test Setup        Common test_setup
# Test Teardown     Common test_teardown
# Force Tags        CRT    CLOUD_FCC_CUS    SBTS00    RAN_4G    RAN_4G_TDD    RAN_4G_FDD
# Resource          ../../resources/KISS/robot/4g_common_resource.robot
# 
# 
# 
# *** Variables ***
# ${UE_CAPA}    DD80040A00007F068C4F001401828AA5640400FC440000E8080208100003FF0000016E280034452601803B5FC0A000CC00198003280010033C90000200001080
# ${INPUT_SCFC_PATH}    ${CURDIR}${/}config_file${/}SCFC_CB010781_FSMF_case3.xml
# ${INPUT_CUS_yaml_PATH}    ${CURDIR}${/}config_file${/}CUS_10781_FSMF_case3.yaml
# ${CUS_IP}         192.168.200.1
# ${FCT_IP}         192.168.255.1
# ${FTM_IP}         192.168.255.129
# ${cell_onair}     ${EMPTY}
# ${DL_THROUGHPUT_LOWER_THRESHOLD2cc}    100000
# ${DL_THROUGHPUT_LOWER_THRESHOLD3cc}    200000
# ${UE_INDEX_1}     1
# ${UE_INDEX_2}     2
# @{swconfig}         0x340000:15   0x10041:5
# 
# *** Test Cases ***
# CB010781_A_case03_interworking_with_TTIB_that_UE_in_TTIB_mode_tries_to_set_up_a_QCI-67_bearer  
#     #Start aatrace
# 	Add RD
# 	Prepare Enb Onair   ${INPUT_SCFC_PATH}    ${INPUT_CUS_yaml_PATH}
#     Attach UE
#     Start data traffic
#     run keyword and continue on failure    Verify throughput
# 	iphy_cleanup_egate_console_log
#     Add UL bler
# #    Wait '5s' for stabible
#     setup_enb_ttitrace    log_path=${TEST LOG DIRECTORY()}/macps_ttitrace    alias=enb1_ttitrace
#     start_enb_ttitrace    node_type=ALL    cell_id=ALL    alias=enb1_ttitrace
#     stop_and_decode_enb_ttitrace    alias=enb1_ttitrace
# 	run keyword and continue on failure    Check ttitrace
# 	run keyword and ignore error    Add bear6967 fail
#     Iphy Get Egate Console Log                           log_save_path=${TEST_LOG_DIRECTORY()}/AddBearer67
# 
#     Stop UL bler
# #    Add bear6967
# 	
# 	Stop data traffic
#     Detach UE
# 	
# 	onlinechange blockTtiBundling to false
# 	
# 	Attach UE
#     Start data traffic
# 	Add bear6967
# 	Add UL bler
# #    Wait '5s' for stabible
#     setup_enb_ttitrace    log_path=${TEST LOG DIRECTORY()}/macps_ttitrace1    alias=enb1_ttitrace1
#     start_enb_ttitrace    node_type=ALL    cell_id=ALL    alias=enb1_ttitrace1
#     stop_and_decode_enb_ttitrace    alias=enb1_ttitrace1
# 	run keyword and continue on failure    Check ttitrace1
# 	
# 	Stop data traffic
#     Detach UE
# 	
#     teardown_all_alias_for_enb_ttitrace
# 
# *** Keywords ***
# Add RD
#     ${enb_swconfig_modified_file}    Add ENB Swconfig    @{swconfig}
#     Set Suite Variable    ${enb_swconfig_file}    ${enb_swconfig_modified_file}
#     ENB Upload Swconfig    ${enb_swconfig_file}
# 	
# onlinechange blockTtiBundling to false
# 	setup admin                          bts_host=192.168.255.129       bts_port=443        use_ssl=True           alias=delta_commission
# 	perform_delta_recommissioning    delta_file=${CURDIR}/config_file/delta_10781_case3.json    skip_parameter_relation_errors=true    
# 	...    alias=delta_commission
# 	teardown admin                       alias=delta_commission
# 	sleep     20s
# 
# Check ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/case3_tti_ul_bundling.ini    log_need_to_check=i    
# 	...    save_log_directory=${TEST LOG DIRECTORY()}/macps_ttitrace
# #${TEST_LOG_DIRECTORY()}/All
# 
# Check ttitrace1
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/case3_tti_ul_bundling.ini    log_need_to_check=i    
# 	...    save_log_directory=${TEST LOG DIRECTORY()}/macps_ttitrace1
# #${TEST_LOG_DIRECTORY()}/All
# 
# 
# Check UExlog
#     run    mkdir ${TEST LOG DIRECTORY()}/uex_logs
#     run    cp -rf /home/cus/logs/uex/latest/* \ ${TEST LOG DIRECTORY()}/uex_logs/
#     ${cmd}    Set Variable    uesim-dump ${TEST LOG DIRECTORY()}/uex_logs/cell-11.log > ${TEST LOG DIRECTORY()}/uex_logs/cell-11_decode.log
#     OperatingSystem.Run    ${cmd}
# 
# 
# Attach UE
#     Comment    CUS Attach    1,3...7,9    1
#     sleep    20
#     Comment    CUS Attach    1    11
#     CUS Attach    ${UE_INDEX_1}    11    ue_eutra_capabilities=${UE_CAPA}
# 	Add bearer qci1
# 	
# Add bear6967
# #    Run UEx command  bearer_add ue=1 qci=69
# #    Expect Message Flow
# #    ...  MME_1:S1AP_E-RABSetupRequest contains ((qCI eq "67") and (e-RAB-ID eq 7))
# #    ...  MME_1:S1AP_E-RABSetupResponse contains (e-RAB-ID eq 7)
# #    ...  alias=UE_1_flow    overall_timeout=20
#     Run UEx command  bearer_add ue=1 qci=67 mbr_dl=31 mbr_ul=31 gbr_dl=31 gbr_ul=31
# #    Flow Occurred As Expected    alias=UE_1_flow
# 	
# Add bear6967 fail
#     Run keyword and continue on failure    Run UEx command  bearer_add ue=1 qci=67 mbr_dl=31 mbr_ul=31 gbr_dl=31 gbr_ul=31
# #    Expect Message Flow
# #    ...  MME_1:S1AP_E-RABSetupResponse contains (Cause eq "RAN interaction with other procedure")
# #    ...  alias=UE_1_flow    overall_timeout=20
# 
# Add bearer qci1
# #	Run UEx command  bearer_add ue=1 qci=69
# #    Expect Message Flow
# #    ...  MME_1:S1AP_E-RABSetupRequest contains ((qCI eq "65") and (e-RAB-ID eq 7))
# #    ...  MME_1:S1AP_E-RABSetupResponse contains (e-RAB-ID eq 7)
# #    ...  alias=UE_1_flow    overall_timeout=20
#     Run UEx command  bearer_add ue=1 qci=1 mbr_dl=31 mbr_ul=31 gbr_dl=31 gbr_ul=31
# #    Flow Occurred As Expected    alias=UE_1_flow
# 
# Start data traffic
#     Comment    CUS Start UL Udp Data Traffic    4...6    30    bearer=5
#     Comment    CUS Start DL Udp Data Traffic    7,9    5M
#     CUS Start UL Udp Data Traffic    1    20M    bearer=5
#     CUS Start DL Udp Data Traffic    1    200M    bearer=5
#     Sleep    10
# 	
# Override PHR
#     Run UEx command  ue_ul_power_control id=1 phr_operation=permanent phr_value_override=1 pathloss=115
# 	
# Add UL bler
# 	Run UEx command  ue_ul_power_control id=1 pathloss=114
# 	Run UEx command  ue_harq_error id=1 scell=primary ul_err_ratio=1-7:1000:550:0
# 
# Stop UL bler
#     Run UEx command  ue_ul_power_control id=1 pathloss=0
#     Run UEx command  ue_harq_error id=1 scell=primary ul_err_ratio=1-7:1000:0:0
# 
# Verify throughput
#     Comment    ${ul_tput_ave}=    CUS Get UL Throughput Ave    1    dl_mac
#     ${dl_tput_ave}=    CUS Get DL Throughput Ave    1    dl_mac
#     ${dl_throughput_pcell}    CUS Get Throughput On Specific Scell    1    dl_mac    scell_id=0    tput_type=avg
#     should_be_true    ${dl_tput_ave}>100000
#     should_be_true    ${dl_throughput_pcell}>100000
# 
# Stop data traffic
#     CUS Stop UL Udp Data Traffic    1    bearer=5
#     CUS Stop DL Udp Data Traffic    1    bearer=5
# 
# Detach UE
# #    CUS Detach    1
#     CUS All Detach
# 
# get testline info
#     Log To Console    ===get testline info===
#     ${testline_ip}    run    sudo ifconfig eth0 | grep -w inet | awk '{ print $2}'
#     Log    ${testline_ip}
#     Log    TestLineIpAddress\=${testline_ip}    console=True
#     ${testline_hostname}    run    hostname
#     Log    TestLineHostName\=${testline_hostname}    console=True
#     ${python_version}    run    python -V;
#     Log    ${python_version}    console=True
# 
# Get TA Library Version
#     ${output}=    run    pip list
#     log    ${output}
# 
# get enb information
#     Setup Enb Fsm Access    alias=enb1
#     execute_command_on_enb    cd /ffs/run/config;rm -rf hwf.bin.gz    alias=enb1
#     Get Enb Sw Version
#     Get Enb Hw Version
#     Get BBU Type
#     Get Smod Position
#     Teardown Enb Fsm Access    alias=enb1
# 
# Get BBU Type
#     ${BBU_TYPE}    ta_kiss_bts.Get Bbu Type
#     Log    ${BBU_TYPE}    console=True
#     Set Suite Variable    ${BBU_TYPE}
# 
# Get Smod Position
#     taf.sbts.oam.coam.admin.Setup Admin    bts_host=192.168.255.1    bts_port=443    use_ssl=True    alias=enb1
#     ${RACK_POSITION}    taf.sbts.oam.coam.admin.Get Smod Position    alias=enb1
#     Log    ${RACK_POSITION}    console=True
#     Set Suite Variable    ${RACK_POSITION}
#     taf.sbts.oam.coam.admin.teardown_admin    alias=enb1
# 
# CUS config update
#     CUS Execute CUS Command    config update ${INPUT_CUS_yaml_PATH}    finished successfully    ${True}
#     CUS Execute CUS Command    config remote update
# 
# VM1_upload_configuration_file_to_eNB
#     Migrate Scfc And Put Related File To Enb And Iphy    input_scfc_path=${INPUT_SCFC_PATH}    output_scfc_path=${CURDIR}${/}SCFC_adaption_F.xml
#     ...    sutool_log_path=${CURDIR}    do_commission=True
# 
# Power on enb and iphy
#     power_on_enb    pdu=${tl.fsm[1].pdu}    timeout=20
#     power_on_iphy    pdu=${tl.iphy[1].pdu}    timeout=20
# 
# Power off enb and iphy
#     power_off_enb    pdu=${tl.fsm[1].pdu}    timeout=20
#     power_off_iphy    pdu=${tl.iphy[1].pdu}    timeout=20
# 
# Save snapshot
#     taf.sbts.oam.coam.admin.Setup admin
#     taf.sbts.oam.coam.admin.Collect Snapshot    ${TEST LOG DIRECTORY()}/enb_snapshot.zip
#     taf.sbts.oam.coam.admin.Teardown admin
# 
# Get Enb Sw Version
#     ${ENB_SW_VERSION}    ute_fsmaccess . Get Enb Sw Version    alias=enb1
#     Log    ${ENB_SW_VERSION}    console=True
#     Set Suite Variable    ${ENB_SW_VERSION}
# 
# Get Enb Hw Version
#     ${ENB_HW_VERSION}    ute_fsmaccess . Get Enb Hw Version    alias=enb1
#     Log    ${ENB_HW_VERSION}    console=True
#     Set Suite Variable    ${ENB_HW_VERSION}
# 
# clear uex logs
#     run    cd /home/cus/logs/uex/;rm -rf *
# 
# Get CUS Info
#     Setup Wts Fsm Access    fallback_prompt=#
#     ${wts_hw_version}    Get Wts Hw Version
#     log    cus_hw_version=${wts_hw_version}    console=True
#     ${wts_sw_version}    Get Wts Sw Version
#     log    cus_sw_version=CUS${wts_sw_version.split("CUS")[-1]}    level=WARN
# 
# Make Sure eNB CUS SSH OK
#     Wait For All Hosts    ${FTM_IP}    ${FCT_IP}    timeout=300
#     Run Keyword And Ignore Error    Wait For Host Ssh    ${FCT_IP}    timeout=180
#     Run Keyword And Ignore Error    Wait For Host Ssh    ${CUS_IP}    timeout=180
# 
# Copy Config Files To Log Dir
#     run    mkdir -p ${TEST LOG DIRECTORY()}/config
#     run    cp -f /tmp/config.ini ${TEST LOG DIRECTORY()}/config
#     run    cp -f /tmp/config.cfg ${TEST LOG DIRECTORY()}/config
#     run    cp -f /tmp/UEDB.db ${TEST LOG DIRECTORY()}/config
#     run    cp -f /home/cus/test/ue_capabilities/* ${TEST LOG DIRECTORY()}/config
#     taf.sbts.oam.coam.admin.Setup admin
#     Get Current Scf File    local_dir_path=${TEST LOG DIRECTORY()}/config    file_name=scf_after_test.xml    
# 	...    export_type=configurationAndRuntimeObjects
#     taf.sbts.oam.coam.admin.Teardown admin
# 
# reboot site and wts
#     reset eNB
#     Comment    Setup Enb Fsm Access    alias=enb1
#     Comment    run keyword and continue on failure    execute_command_on_enb    reboot    alias=enb1
#     Comment    Teardown Enb Fsm Access    alias=enb1
#     Setup WTS Fsm Access    alias=iphy1
#     run keyword and continue on failure    execute_command_on_wts    reboot    alias=iphy1
#     Teardown WTS Fsm Access    alias=iphy1
# 
# ute_fsmaccess_debug
#     Setup Enb Fsm Access    alias=enb1
#     run keyword and continue on failure    get_enb_scfc_file    destination=${TEST LOG DIRECTORY()}/config    partition=active    alias=enb1
#     run keyword and continue on failure    get_enb_swconfig_file    destination=${TEST LOG DIRECTORY()}/config    partition=active    alias=enb1
#     run keyword and continue on failure    get_enb_targetbd_file    destination=${TEST LOG DIRECTORY()}/config    partition=active    alias=enb1
#     Teardown Enb Fsm Access    alias=enb1
# 
# reset eNB
#     taf.sbts.oam.coam.admin.Setup admin    alias=enb1
#     reset_site    timeout=300    connection=None    wait_for_reconnection=True    detailed_output=False    alias=enb1
#     taf.sbts.oam.coam.admin.Teardown admin    alias=enb1
# 
# wait_for_on_air
#     ${cell_onair_check}    cell_should_be_onair    timeout=600
#     Set Suite Variable    ${cell_onair}    ${cell_onair_check}
# 
# lua_and_on_air_again
#     reboot site and wts
#     Make Sure eNB CUS SSH OK
#     cell_should_be_onair    timeout=600
# 
# collect macps_ttitrace
#     setup_enb_ttitrace    log_path=${TEST LOG DIRECTORY()}/macps_ttitrace    alias=enb1_ttitrace
#     start_enb_ttitrace    node_type=ALL    cell_id=ALL    alias=enb1_ttitrace
#     sleep    5
#     stop_and_decode_enb_ttitrace    alias=enb1_ttitrace
#     teardown_all_alias_for_enb_ttitrace
# 
# Start aatrace
#     ta_aatrace.Start_AAtrace    ${TEST LOG DIRECTORY()}/enb1_LTE1836.bin    ${CURDIR}${/}enb1_LTE1836.bts    file_limit=100000000    
# 	...    alias=enb1_aatrace
# 
# Set R&D parameter
#     runkeyword and continue on failure    Set Rad Parameter    setlog    ALL    ALL    FID_DL_CA    DEBUG
#     ...    hw_ver=fsmr4
#     runkeyword and continue on failure    Set Rad Parameter    setlog    ALL    ALL    FID_UL_CA    DEBUG
#     ...    hw_ver=fsmr4
#     runkeyword and continue on failure    Set Rad Parameter    setlog    ALL    ALL    FID_DL_BSR    DEBUG
#     ...    hw_ver=fsmr4
# 
# check err log
#     ${enb1_btslog_error_check1}=    run_process_and_get_output    grep -w "ERR/TDDPS" ${TEST LOG DIRECTORY()}enb1_btslog* | wc -l
#     should_be_true    ${enb1_btslog_error_check1}<=2
#     ${enb1_btslog_WRN_check1}=    run_process_and_get_output    grep -w "WRN/TDDPS" ${TEST LOG DIRECTORY()}enb1_btslog* | wc -l
#     should_be_true    ${enb1_btslog_WRN_check1}<=5
#     Comment    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/wrn_err_log.ini    log_need_to_check=u    
# 	...    save_log_directory=${TEST LOG DIRECTORY()}
# 
# run_process_and_get_output
#     [Arguments]    ${command}
#     ${result}    run_process    ${command}    shell=True
#     [Return]    ${result.stdout}
# 
# Start UE2 data traffic
#     CUS Start UL Udp Data Traffic    2    10M    bearer=5
#     CUS Start DL Udp Data Traffic    2    150M
#     Sleep    10
# 
# Verify throughput for two UEs
#     Get and verify DL and UL throughput average per ue    ${UE_INDEX_1}    ${DL_THROUGHPUT_LOWER_THRESHOLD3cc}
#     Get and verify DL and UL throughput average per ue    ${UE_INDEX_2}    ${DL_THROUGHPUT_LOWER_THRESHOLD2cc}
# 
# Get and verify DL and UL throughput average per ue
#     [Arguments]    ${ue_id}    ${dl_tput}
#     ${ul_tput_ave}=    CUS Get UL Throughput Ave    ${ue_id}    ul_rlc
#     ${dl_tput_ave}=    CUS Get DL Throughput Ave    ${ue_id}    dl_mac
#     should_be_true    ${dl_tput_ave}>${dl_tput}
