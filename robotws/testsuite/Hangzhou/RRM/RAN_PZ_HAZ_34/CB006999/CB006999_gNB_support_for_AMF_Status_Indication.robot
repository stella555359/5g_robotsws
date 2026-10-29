# *** Settings ***
# Force Tags    PY36
# Documentation     author: yuegong
# ...               contact: yue.1.gong@nokia-sbell.com
# ...               squad group: SG_03
# ...               feature : CB006999_A
# 
# Resource          ./Resources/CB006999_common_kw.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
# Variables         Resources/__init__.py
# 
# 
# Suite Setup    Run Keywords
# ...            Run Keyword And Ignore Error    Common Suite Setup for COAM    AND
# ...            Load SCF for each TL
# 
# 
# Suite Teardown    Run Keywords
# ...               Run Keyword And Ignore Error
# ...               Common Suite Teardown for COAM    gnb_index=${1}   AND
# ...               Run Keyword And Ignore Error    COAM Teardown gnb connections   AND
# ...               Common Suite Teardown for AMF ZHOU
# 
# 
# *** Variables ***
# #${epc_log_path}            /tmp/
# #${tl_scf_dir_path}         /opt/workspace/SCF/
# #${tl_scf_filename}         CB006999_A.xml
# #${tl_scf_filename}         gy-CB006999_A.xml
# ${interface}               any
# ${duration}                1500
# ${gNB1_nglogname}          gNB_6999_active.pcap
# ${nglogname_2}             gNB_6999_deactive.pcap
# ${timer_nglogname}         gNB_6999_timer.pcap
# ${idle_nglogname}          gNB_6999_idle.pcap
# #${gnb_path}                /tmp
# ${tshark_path}             /usr/bin/tshark
# ${asik_addr}               ${tl.gnbs[0].cu.oam_http_connection_details.addr}
# ${command_template_with_Y}    {tshark_path} -r {pcap_file} -Y  \"ngap\"  -T pdml
# #${value_counter_6999_A003}    ${1}     ${0}    ${1}    ${1}     ${0}    ${1}
# #${value_counter_6999_A003}    ${0}     ${0}    ${0}    ${0}     ${0}    ${0}
# *** Test Cases ***
# [1]CB006999_A_003_gnb_trigger_reselection_immediately_after_receive_ASI_with_actAmfPlannedRemoval_set_ true_ with_amfPlannedRemovalTimer_0
#     [Documentation]    Purpose of this case is to validate when feature flag is activated,
#     ...    NRBTS/amfPlannedRemovalTimer = 0 indicating that the GUAMIs= unavailable need to be retired immediately.
#     [Tags]    classical    CB006999-A_003    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_22R4
#     [Timeout]    1 hour
#     [Setup]
#     robot_common_operations.Common Case Setup
#     Prepare the atten for each TL
#     Online modify NIDD on gnb1 and gnb2    Modify_Para_Online_GNB2=${gnb2_Lock_AMF1_Unlock_AMF2}
#     ...    ModifySCF_Aftercommission_for_GNB2=True
#     power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
#     Start capture gNB log on master    filename=${gNB1_nglogname}   gNB_index=${1}
#     Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${1}
#     sleep    10s
#     power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_throughput}    duration=${duration}
#     ...    ue_index=${0}    iperf_port=${dl_port}
#     Online modify NIDD on gnb1 and gnb2    Modify_Para_Online_GNB2=${gnb2_Unlock_AMF3}
#     ...    ModifySCF_Aftercommission_for_GNB2=True
#     power_ue.Check throughput    ue_type=${ue_type}    direction=dl
#     ...    throughput=${dl_expect_throughput}    gnb_index=${1}
#     make amf-zhou maitain on amf account and alarm 7115 will be raised    status=@{gumistatus}[1]
#     trigger ul behaviour for each TL
#     sleep    10s
#     power_ue.Check throughput    ue_type=${ue_type}    direction=dl
#     ...    throughput=${dl_expect_throughput}    gnb_index=${1}
#     Stop UL DL data transfer    ue_index=${0}    dl_port=${DL_PORT}    ul_port=${UL_PORT}
#     power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#     Stop and download the Logs    filename=${gNB1_nglogname}   gNB_index=${1}
#     wait until keyword succeeds    5min    20s    Check the 6999 counters A003
#     [Teardown]    Run Keywords
#     ...    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}    AND
#     ...    check hanging resource for per UE on gnb    gnb_ips=@{gnb_ips}    UE_Type_Index=${0}    AND
#     ...    Test recover
# 
# 
# [1]CB006999_A_005_handover_after_gnb_receive_ASI_with_actAmfPlannedRemoval_ true _with_amfPlannedRemovalTimer_not_equal_0
#     [Documentation]    Purpose of this case is to validate when feature flag NRBTS.actAmfPlannedRemoval is deactivated
#     ...    upon startup or plan file update, when gnb revieve ASI message, gnb right send ERROR INDICATION to AMF1
#     ...    gumi status show available
#     [Tags]    classical    CB006999-A_002    CRT_22R2    CRT_22R3    CRT_22R4
#     [Timeout]    1 hour
#     [Setup]
#     robot_common_operations.Common Case Setup
#     Prepare the atten for each TL
#     Online modify NIDD on gnb1 and gnb2    Modify_Para_Online_GNB2=${gnb2_Lock_AMF1_Unlock_AMF2_OFF}
#     ...    ModifySCF_Aftercommission_for_GNB2=True
#     power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
#     Start capture gNB log on master    filename=${nglogname_2}   gNB_index=${1}
#     Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${1}
#     sleep    10s
#     power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_throughput}    duration=${duration}
#     ...    ue_index=${0}    iperf_port=${dl_port}
#     power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_throughput}    duration=${duration}
#     ...    ue_index=${0}    iperf_port=${dl_port}
#     Online modify NIDD on gnb1 and gnb2    Modify_Para_Online_GNB2=${gnb2_Unlock_AMF3}
#     ...    ModifySCF_Aftercommission_for_GNB2=True
#     power_ue.Check throughput    ue_type=${ue_type}    direction=ul
#     ...    throughput=${ul_expect_throughput}    gnb_index=${1}
#     power_ue.Check throughput    ue_type=${ue_type}    direction=dl
#     ...    throughput=${dl_expect_throughput}    gnb_index=${1}
#     make amf-zhou maitain on amf account and alarm 7115 will be raised    status=@{gumistatus}[0]
#     power_ue.Check throughput    ue_type=${ue_type}    direction=ul
#     ...    throughput=${ul_expect_throughput}    gnb_index=${1}
#     power_ue.Check throughput    ue_type=${ue_type}    direction=dl
#     ...    throughput=${dl_expect_throughput}    gnb_index=${1}
#     Stop UL DL data transfer    ue_index=${0}    dl_port=${DL_PORT}    ul_port=${UL_PORT}
#     power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#     Stop and download the Logs    filename=${nglogname_2}   gNB_index=${1}
#     check IE for deactive    #reply ERROR INDICATION message
#     [Teardown]    Run Keywords
#     ...    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}    AND
#     ...    check hanging resource for per UE on gnb    gnb_ips=@{gnb_ips}    UE_Type_Index=${0}    AND
#     ...    Test recover
# 
# 
# *** Keywords ***
# Set nrcellid suit varaible
#     [Arguments]    ${cellid}    ${gnb_index}=${0}
#     ${nrcellid}    COAM Get nrcellid with the lcrid    lcrid=${cellid}    gnb_index=${gnb_index}
#     set suite variable    ${nrcellid}
# 
# Get sagnb release
#     [Arguments]   ${host}=${asik_addr}   ${username}=${asik_username}   ${password}=${asik_password}
#     csn.Connect To   hostname=${host}   username=${username}   password=${password}   alias=release_info
#     ${info}   csn.Execute    command=ls /ffs/run/TargetBD*xml   connection=release_info
# #    ${release_info}     set variable    ${info.split('_')[1]}
#     ${release_info}    set variable    ${info.split('_')[1]}_${info.split('_')[2]}_${info.split('_')[3]}
#     [Return]    ${release_info}
#     [Teardown]   csn.Disconnect   connection=release_info
# 
# Check the 6999 counters A003
#     Check the PM counter should be matached
#     ...    gnb_index=${1}    counter_id=${counter_id_6999_A003}
#     ...    dic_path=${counter_dic_path_6999_A003}    value=${value_counter_6999_A003}
# 
# Test recover
#     wait until keyword succeeds    10 min    5 sec    Connect to AMF-ZHOU account    alias=UTE
#     csn.execute    command=cmm amfGuamiStatusAdmin modify AMF5-zhou --maintenanceTimer 0 --guamiStatus supported
#     ...    connection=UTE    #turn on amf account
#     run keyword and ignore error    coam.teardown    connection=ASIK
#     run keyword and ignore error    Stop and download the Logs    filename=${gNB1_nglogname}    gNB_index=${1}
#     run keyword and ignore error    Online modify NIDD on gnb1 and gnb2    Modify_Para_Online_GNB2=${gnb2_recover_AMF}
#     ...    ModifySCF_Aftercommission_for_GNB2=True
#     Run Keyword And Ignore Error    Hanging resource test
#     Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# 
# Hanging resource test
#     [Arguments]    ${gnb_ips}=@{gnb_ips}    ${ue_index}=${0}
#     [Documentation]    hanging resource test
#     [Timeout]    1hour
#     Check hanging resource for gnb    gnb_ips=${gnb_ips}    ue_index=${ue_index}
