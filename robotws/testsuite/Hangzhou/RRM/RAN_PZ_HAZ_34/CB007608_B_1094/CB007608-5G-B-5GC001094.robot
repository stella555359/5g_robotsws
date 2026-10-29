# # #*** Settings ***
# # #Force Tags    PY36
# # #Documentation
# # #...   author: pengliang.wu@nokia-sbell.com
# # #...   contact: Wu Pengliang
# # #
# # #Suite Setup     env parpare
# # #Suite Teardown
# # #
# # #Resource       ./Resources/5GC001094_comm_keyword.robot
# # #Library        ./Resources/5GC001094_comm_keyword.py
# # #Variables      ./Resources/5GC001094_modify_para.py
# # #
# # #
# # #*** Variables ***
# # #${E500_SCRIPTS_BASE}     ${CURDIR}/Resources/E500_scripts
# # #${filter_c_plane}        x2ap || nr-rrc || f1ap
# # #${case1_pcap_log}        wireshark_pcap_case1
# # #${case2_pcap_log}        wireshark_pcap_case2
# # #${case3_pcap_log}        wireshark_pcap_case3
# # #${case1_btslog_name}     btslog1.log
# # #${case2_btslog_name}     btslog2.log
# # #${case3_btslog_name}     btslog3.log
# # #
# # #*** Test Cases ***
# # 
# # #[1]CB007608-5G-B-5GC001094_PSCell_change_with_initial_Blacklisting_configuration
# # #    [Documentation]     Verify PSCell change with initial Blacklisting configuration
# # #    [Tags]    CRT_TRUNK       CRT_22R2       CRT_22R3
# # #    Modify Parameters for 001
# # #    run keyword and continue on failure    kill IPSL process
# # #    log to console    start viavi preparation and attach
# # #    Precondition for attach with retry    e500_script_path=${E500_SCRIPTS_BASE}
# # #    #************attach and ho*********************
# # #    Start wireshark capture from gNB or Enb      filename=${case1_pcap_log}.pcap    alias=enb1
# # #    Cobham retry ue attach if failed    e500_script_path=${E500_SCRIPTS_BASE}    rrc_count=${2}
# # #    Run Keyword And Continue On Failure    Start BTSlog     log_name=${case1_btslog_name}
# # #    sleep   10s
# # #    Trigger NR measurement report   meas_id=1   handover_type=A3rsrp   isHandoverOK=nok
# # #    ...         serving_cell_pci=50     serving_cell_rsrp=50
# # #    ...         neigh_cell_pci=51   neigh_cell_rsrp=71
# # #    Stop wireshark capture from gNB or Enb      filename=${case1_pcap_log}.pcap    alias=enb1
# # ##   Bts log check
# # #    Run Keyword And Continue On Failure    Stop BTSlog and check Message
# # #    ...         regexp=No target cell available, Intra-freq HO will not start
# # #    #**********convert wireshark to txt*************
# # #    Convert pcap to text    source=${LOG_PATH}/${case1_pcap_log}.pcap    target=${LOG_PATH}/${case1_pcap_log}.txt    filter=${filter_c_plane}
# # #    #check measid
# # #    ${measConfigDic}    Get MeasConfig From Txt N     txt_file_path=${OUTPUT_DIR}/${case1_pcap_log}.txt
# # #    Check measid    txt_filename=${case1_pcap_log}.txt    para1=report    para2=eventId    expect=eventA3
# # #    ...         measConfigDic=${measConfigDic}    mr_n=1    mc_n=1
# # #    Check measid    txt_filename=${case1_pcap_log}.txt    para1=report    para2=ho_method    expect=rsrp
# # #    ...         measConfigDic=${measConfigDic}    mr_n=1    mc_n=1
# # ##   check parameters
# # #    ${val_result}    Check Wireshark Parameter From Txt    txt_file_path=${LOG_PATH}/${case1_pcap_log}.txt    parameters=${parameter_dic_case1}
# # #    @{val_list}     set variable    ${val_result}[resultList]
# # #    FOR    ${val1}    IN    @{val_list}
# # #        Run Keyword And Continue On Failure    should be equal    ${val1}    ${True}
# # #    END
# # ##   check message flow
# # #    ${val}    Check Wireshark Message Flow From Txt        txt_file_path=${LOG_PATH}/${case1_pcap_log}.txt    message_dict=${message_flow_case1}
# # #    Run Keyword And Continue On Failure    should be equal    ${val}    ${True}
# # #    [Teardown]    Run Keyword And Ignore error    Case1 Teardown
# # #
# # #
# # #[1]CB007608-5G-B-5GC001094_spillover from 5GC001094_G_205_PSCell_change_A3_SSB_ RSRP_RSRQ_Combined_enable_with_SRB3
# # #    [Documentation]     Verify PSCell change with A3 RSRPCombined with SRB3
# # #    [Tags]
# # #    Modify Parameters for 002
# # #    run keyword and continue on failure    kill IPSL process
# # #    log to console    start viavi preparation and attach
# # #    Precondition for attach with retry    e500_script_path=${E500_SCRIPTS_BASE}
# # #    Start wireshark capture from gNB or Enb      filename=${case2_pcap_log}.pcap    alias=gnb1      gnb=True
# # #    Cobham retry ue attach if failed    e500_script_path=${E500_SCRIPTS_BASE}    rrc_count=${1}
# # #    ${logs_path}    Start logging on cobham and Return Folder
# # #    Start traffic    ul_throughput=70    dl_throughput=100    traffic_time=${400}
# # #    Run Keyword And Continue On Failure    Start BTSlog     log_name=${case2_btslog_name}
# # #    sleep    40s
# # #    Trigger NR measurement report   meas_id=1   handover_type=A3rsrpCombined_only_rsrp   isHandoverOK=nok
# # #    ...         serving_cell_pci=50     serving_cell_rsrp=50    serving_cell_rsrq=51
# # #    ...         neigh_cell_pci=51   neigh_cell_rsrp=71    neigh_cell_rsrq=54
# # #    Trigger NR measurement report   meas_id=1   handover_type=A3rsrpCombined_rsrp_rsrq   isHandoverOK=ok
# # #    ...         serving_cell_pci=50     serving_cell_rsrp=50    serving_cell_rsrq=54
# # #    ...         neigh_cell_pci=51   neigh_cell_rsrp=71    neigh_cell_rsrq=76
# # #    sleep    30s
# # #    Stop logging on cobham
# # #    Stop wireshark capture from gNB or Enb      filename=${case2_pcap_log}.pcap    alias=gnb1    gnb=True
# # #    Kill iperf process on app server    port=${dl_ports}
# # ##   Bts log check
# # #    Run Keyword And Continue On Failure    Stop BTSlog and check Message
# # #    ...         regexp=Update UE context after intra-DU handover for gnbDuUeF1APId
# # #    #**********convert wireshark to txt*************
# # #    Convert pcap to text    source=${LOG_PATH}/${case2_pcap_log}.pcap    target=${LOG_PATH}/${case2_pcap_log}.txt    filter=${filter_c_plane}
# # ##    check measid
# # #    ${measConfigDic}    Get MeasConfig From Txt N     txt_file_path=${OUTPUT_DIR}/${case2_pcap_log}.txt
# # #    Check measid    txt_filename=${case2_pcap_log}.txt    para1=report    para2=eventId    expect=eventA3
# # #    ...         measConfigDic=${measConfigDic}    mr_n=1    mc_n=1
# # #    Check measid    txt_filename=${case2_pcap_log}.txt    para1=report    para2=ho_method    expect=rsrp
# # #    ...         measConfigDic=${measConfigDic}    mr_n=2    mc_n=1
# # ##   check parameters
# # #    ${val_result}    Check Wireshark Parameter From Txt    txt_file_path=${LOG_PATH}/${case2_pcap_log}.txt
# # #    ...         parameters=${parameter_dic_case2}
# # #    @{val_list}     set variable    ${val_result}[resultList]
# # #    FOR    ${val1}    IN    @{val_list}
# # #        Run Keyword And Continue On Failure    should be equal    ${val1}    ${True}
# # #    END
# # ##   check message flow
# # #    ${val}    Check Wireshark Message Flow From Txt        txt_file_path=${LOG_PATH}/${case2_pcap_log}.txt
# # #    ...         message_dict=${message_flow_case2}
# # #    Run Keyword And Continue On Failure    should be equal    ${val}    ${True}
# # ##   check traffic
# # #    ${ute_path}    Download Viavi Log    logs_path=${logs_path}
# # #    Check_TP_And_Bler    dir_path=${ute_path}    ul_min_tp=${10}    ul_max_tp=${50}   dl_min_tp=${10}    dl_max_tp=${90}
# # #    ...    bler_value=${0.01}    row=${10}
# # #    [Teardown]    Run Keyword And Ignore error    Case Teardown
# # #
# # #
# # #[1]CB007608-5G-B-5GC001094_spillover_from_5GC001094_G_213_PSCell_change_A3_and_A5_with_SRB3
# # #    [Documentation]     Verify PSCell change with A3 rsrq and A5 rsrp with SRB3
# # #    [Tags]
# # #    Modify Parameters for 003
# # #    run keyword and continue on failure    kill IPSL process
# # #    log to console    start viavi preparation and attach
# # #    Precondition for attach with retry    e500_script_path=${E500_SCRIPTS_BASE}
# # #    Start wireshark capture from gNB or Enb      filename=${case3_pcap_log}.pcap    alias=gnb1      gnb=True
# # #    Cobham retry ue attach if failed    e500_script_path=${E500_SCRIPTS_BASE}    rrc_count=${1}
# # #    ${logs_path}    Start logging on cobham and Return Folder
# # #    Start traffic    ul_throughput=70    dl_throughput=100    traffic_time=${400}
# # #    sleep    40s
# # #    Run Keyword And Continue On Failure    Start BTSlog     log_name=${case3_btslog_name}
# # #    Trigger NR measurement report   meas_id=1   handover_type=A3rsrq   isHandoverOK=ok
# # #    ...         serving_cell_pci=50     serving_cell_rsrq=54
# # #    ...         neigh_cell_pci=51   neigh_cell_rsrq=76
# # ##   Bts log check 1st time
# # #    Run Keyword And Continue On Failure    Stop BTSlog and check Message
# # #    ...         regexp=Update UE context after intra-DU handover for gnbDuUeF1APId
# # #    sleep    30s
# # #    Run Keyword And Continue On Failure    Start BTSlog     log_name=${case3_btslog_name}
# # #    Trigger NR measurement report   meas_id=2   handover_type=A5rsrp   isHandoverOK=ok
# # #    ...         serving_cell_pci=51     serving_cell_rsrp=55
# # #    ...         neigh_cell_pci=50   neigh_cell_rsrp=70
# # ##   Bts log check 2nd time
# # #    Run Keyword And Continue On Failure    Stop BTSlog and check Message
# # #    ...         regexp=Update UE context after intra-DU handover for gnbDuUeF1APId
# # #    sleep    30s
# # #    Stop logging on cobham
# # #    Stop wireshark capture from gNB or Enb      filename=${case3_pcap_log}.pcap    alias=gnb1    gnb=True
# # #    Kill iperf process on app server    port=${dl_ports}
# # #    #**********convert wireshark to txt*************
# # #    Convert pcap to text    source=${LOG_PATH}/${case3_pcap_log}.pcap    target=${LOG_PATH}/${case3_pcap_log}.txt    filter=${filter_c_plane}
# # #    #check measid
# # #    ${measConfigDic}    Get MeasConfig From Txt N     txt_file_path=${OUTPUT_DIR}/${case3_pcap_log}.txt
# # #    Check measid    txt_filename=${case3_pcap_log}.txt    para1=report    para2=eventId    expect=eventA3
# # #    ...         measConfigDic=${measConfigDic}    mr_n=1    mc_n=1
# # #    Check measid    txt_filename=${case3_pcap_log}.txt    para1=report    para2=ho_method    expect=rsrq
# # #    ...         measConfigDic=${measConfigDic}    mr_n=1    mc_n=1
# # #    Check measid    txt_filename=${case3_pcap_log}.txt    para1=report    para2=eventId    expect=eventA5
# # #    ...         measConfigDic=${measConfigDic}    mr_n=2    mc_n=3
# # #    Check measid    txt_filename=${case3_pcap_log}.txt    para1=report    para2=ho_method    expect=rsrp
# # #    ...         measConfigDic=${measConfigDic}    mr_n=2    mc_n=3
# # #    #check parameters
# # #    ${val_result}    Check Wireshark Parameter From Txt    txt_file_path=${LOG_PATH}/${case3_pcap_log}.txt    parameters=${parameter_dic_case3}
# # #    @{val_list}     set variable    ${val_result}[resultList]
# # #    FOR    ${val1}    IN    @{val_list}
# # #        Run Keyword And Continue On Failure    should be equal    ${val1}    ${True}
# # #    END
# # #    #check message flow
# # #    ${val}    Check Wireshark Message Flow From Txt        txt_file_path=${LOG_PATH}/${case3_pcap_log}.txt
# # #    ...         message_dict=${message_flow_case3}
# # #    Run Keyword And Continue On Failure    should be equal    ${val}    ${True}
# # ##   check traffic
# # #    ${ute_path}    Download Viavi Log    logs_path=${logs_path}
# # #    Check_TP_And_Bler    dir_path=${ute_path}    ul_min_tp=${10}    ul_max_tp=${50}   dl_min_tp=${10}    dl_max_tp=${90}
# # #    ...    bler_value=${0.01}    row=${10}
# # #    [Teardown]    Run Keyword And Ignore error    Case Teardown
