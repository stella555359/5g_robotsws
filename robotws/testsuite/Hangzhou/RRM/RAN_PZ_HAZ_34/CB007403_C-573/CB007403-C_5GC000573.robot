# # #*** Settings ***
# # #Force Tags    PY36
# # #Suite Setup      Setup Commission SCF gNB1 and gNB2
# # #Suite Teardown
# # #
# # #Documentation    author：Shanshan Zhang
# # #...              contact: shanshan.zhang@nokia-sbell.com
# # #...              squad group: mmw_SG_04
# # #
# # #
# # #Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# # #Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/viavi_common_keyword.robot
# # #Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
# # #Resource          ../CB007608_B-573/Resources/5GC000573_common_keyword.robot
# # #Library           ../CB007608_B-573/Resources/5GC000573_common.py
# # #Library           ../CB007403_C-2199/Resources/5GC002199_common.py
# # #Library           ute_syslog
# # #Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/Analysis_Viavi_Log.py
# # #Library           Analysis_Viavi_Log.Viavi_Log_analysis     WITH NAME    Viavi_Log_analysis
# # #Variables         ../CB007608_B-573/Resources/5GC000573_modify_para.py
# # #
# # #
# # #*** Variables ***
# # #${gNB_ip}                 ${tl.gnbs[0].dus[0].f1_m_ip_addr}
# # #${gNB2_ip}                ${tl.gnbs[1].dus[0].f1_m_ip_addr}
# # #${gNB_username}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
# # #${gNB_password}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
# # #${enb_id}                 ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
# # #${E500_SCRIPTS_BASE}      ${CURDIR}/E500_scripts
# # #${LOG_PATH}               ${OUTPUT_DIR}
# # #${port1}                  51000
# # #${port2}                  51003
# # #${eventA2}                    eventA2
# # #${eventA3}                    eventA3
# # #${TEST_PC_IP}                 ${tl.test_pc.default_ssh_connection_details.addr}
# # #${TEST_PC_USERNAME}           ${tl.test_pc.default_ssh_connection_details.username}
# # #${TEST_PC_PASSWORD}           ${tl.test_pc.default_ssh_connection_details.password}
# # #${ul_port}                   ${tl.ues[0].iperf_details.ssh_connection_details.port}
# # #${dl_port}                   ${tl.ues[0].iperf_details.port}
# # #${luashark_path}              /opt/ute/luashark/luashark_script/generated_luashark
# # #${filter_002_1}               x2ap.procedureCode == 27 && x2ap.X2AP_PDU == 1
# # #${filter_002_2}               x2ap.procedureCode == 35
# # #${filter_002_3}               x2ap.procedureCode == 34 && x2ap.X2AP_PDU == 0
# # #${filter_002_4}               s1ap || x2ap || f1ap || e1ap || nr-rrc
# # #${filter_007_1}               x2ap.procedureCode == 30 && x2ap.X2AP_PDU == 0
# # #${filter_004_1}               x2ap.procedureCode == 34 && x2ap.X2AP_PDU == 2
# # #
# # #
# # #*** Test Cases ***
# # #CB007403-C_5GC000573_008_010_Counters_X2_SGNB_CHG_ADD_REQ_RECONF
# # #    [Documentation]       verify Counters_X2_SGNB CHG and ADD_REQ and RECONF
# # #    [Tags]
# # #    Modify ENB and GNB parameter
# # #    run keyword and continue on failure     kill IPSL process
# # #    ${vivia_log_path}      create list
# # #    Precondition for attach with retry    e500_script_path=${CURDIR}/E500_scripts
# # #    ${logs_path}     Start logging on cobham and Return Folder
# # #    Start tcpdump log attch UE and send DL traffic     enb_tcpdump_before=enb_tcpdump_attach
# # #    log to console       Check counter number on gNB1 and gNB2
# # #    run keyword and continue on failure      Check counter number on gNB1 and gNB2
# # #    run keyword and continue on failure    Check wireshark log data equal value      command=grep physCellId |cut -d ':' -f 2|awk 'END {print}'
# # #    ...     pacp_filename=enb_tcpdump_attach.pcap     txt_filename=physCellId1.txt    filter=${filter_002_1}   check=${50}
# # #    ${measId}      Get measId from wireshark log      command=grep measId |cut -d ':' -f 2|awk 'END {print}'
# # #    ...    pacp_filename=enb_tcpdump_attach.pcap    txt_filename=measId.txt    filter=${filter_002_1}
# # #    run keyword and continue on failure    Check EventA3 from wireshark log data     pacp_filename=enb_tcpdump_attach.pcap
# # #    ...    filter=${filter_002_1}     event=${eventA3}     MeasID=${measId}    txt_filename=EventA3.txt
# # #    FOR    ${NUM}    IN RANGE    ${1}    ${3}    1
# # #        Check wireshark log data contain attach message      pacp_filename=enb_tcpdump_handover_${NUM}.pcap    filter=${filter_002_4}
# # #        ...     txt_filename=attach_message_${NUM}.txt
# # #        run keyword and continue on failure    Check wireshark log data not empty
# # #        ...     command=grep 'radioNetwork: action-desirable-for-radio-reasons'
# # #        ...     pacp_filename=enb_tcpdump_handover_${NUM}.pcap     txt_filename=radioNetwork_${NUM}.txt    filter=${filter_002_3}
# # #        run keyword and continue on failure    Check wireshark log data equal value      command=grep physCellId |cut
# ... -d ':' -f 2|awk 'END {print}
# # '
# # #        ...     pacp_filename=enb_tcpdump_handover_${NUM}.pcap     txt_filename=physCellId2_${NUM}.txt    filter=${filter_002_1}   check=${52}
# # #    END
# # #    log to console    ${logs_path}
# # #    ${ute_path}    Download Viavi Log    logs_path=${logs_path}
# # #    Check_DL_TP_And_Bler_stable    dir_path=${ute_path}  dl_max_tp=${90}    bler_value=${0.01}
# # #    [Teardown]   run keyword and ignore error        Case Teardown
# # #
# # #[1]CB007403-C_5GC000573_008_Counters_X2_SGNB_CHG
# # #    [Tags]
# # #    Should Be Equal As Strings    ${PREV_TEST_STATUS}   PASS
# # #
# # #[1]CB007403-C_5GC000573_009_Counters_X2_SGNB_ADD_REQ
# # #    [Tags]
# # #    Should Be Equal As Strings    ${PREV_TEST_STATUS}   PASS
# # #
# # #[1]CB007403-C_5GC000573_010_Counters_X2_SGNB_RECONF
# # #    [Tags]
# # #    Should Be Equal As Strings    ${PREV_TEST_STATUS}   PASS
# # #
# # #[1]CB007403-C_5GC000573_004_Unuccessful_intra_Freq_inter_SgNB_PSCell_change_refused_by_MeNB
# # #    [Documentation]      verify Unuccessful_intra_Freq_inter_SgNB_PSCell_change_refused_by_MeNB
# # #    [Tags]
# # #    Modify ENB and GNB parameter for 004
# # #    run keyword and continue on failure    kill IPSL process
# # #    Precondition for attach with retry    e500_script_path=${CURDIR}/E500_scripts
# # #    Start tcpdump log and attch UE         enb_tcpdump_before=enb_tcpdump_attach_004         enb_tcpdump_after=enb_tcpdump_handover_004
# # #    run keyword and continue on failure    Check wireshark log data equal value      command=grep physCellId |cut -d ':' -f 2|awk 'END {print}'
# # #    ...     pacp_filename=enb_tcpdump_attach_004.pcap     txt_filename=physCellId1.txt    filter=${filter_002_1}   check=${50}
# # #    ${measid}      Get measId from wireshark log due to Event     pacp_filename=enb_tcpdump_attach_004.pcap
# # #    ...        txt_filename=enb_tcpdump_attach_004.txt    filter=${filter_002_1}     Event=${eventA3}
# # #    run keyword and continue on failure     should not be empty     ${measid}
# # #    run keyword and continue on failure    Check wireshark log data not empty      command=grep 'radioNetwork: action
# ...-desirable-for-radio-reasons'
# # #    ...     pacp_filename=enb_tcpdump_handover_004.pcap     txt_filename=enb_tcpdump_handover_004.txt    filter=${filter_002_3}
# # #    run keyword and continue on failure    Check wireshark log data not empty      command=grep 'SgNBChangeRefuse'
# # #    ...     pacp_filename=enb_tcpdump_handover_004.pcap     txt_filename=enb_tcpdump_handover_004.txt    filter=${filter_004_1}
# # #    run keyword and continue on failure    Check wireshark log data not empty      command=grep 'misc: unspecified (4)'
# # #    ...     pacp_filename=enb_tcpdump_handover_004.pcap     txt_filename=enb_tcpdump_handover_004.txt    filter=${filter_004_1}
# # #    [Teardown]    run keyword and ignore error        Case Teardown
# # #
# # #[1]CB007403-C_5GC000573_001_Successful_intra_freq_inter_SgNB_PSCell_change_with_DL_and_UL_with_enable_CDRX
# # #    [Tags]       CRT_Trunk     CRT_22R2    CRT_22R3
# # #    Modify ENB and GNB parameter
# # #    run keyword and continue on failure      5GC000573_common_keyword.kill IPSL process
# # #    Precondition for attach with retry    e500_script_path=${CURDIR}/E500_scripts
# # #    ${logs_path}     Start tcpdump log attch UE and send UL and DL traffic        enb_tcpdump_before=enb_tcpdump_attach
# # #    ...      enb_tcpdump_after=enb_tcpdump_handover     btslog_name=btslog_name.log
# # #    run keyword and continue on failure    Check wireshark log data equal value      command=grep physCellId |cut -d ':' -f 2|awk 'END {print}'
# # #    ...     pacp_filename=enb_tcpdump_attach.pcap     txt_filename=physCellId1.txt    filter=${filter_002_1}   check=${50}
# # #    ${measId}      Get measId from wireshark log      command=grep measId |cut -d ':' -f 2|awk 'END {print}'
# # #    ...    pacp_filename=enb_tcpdump_attach.pcap     txt_filename=measId.txt    filter=${filter_002_1}
# # #    run keyword and continue on failure    Check EventA3 from wireshark log data     pacp_filename=enb_tcpdump_attach.pcap
# # #    ...      txt_filename=EventA3.txt    filter=${filter_002_1}     event=${eventA3}     MeasID=${measId}
# # #    Check wireshark log data contain attach message      pacp_filename=enb_tcpdump_handover.pcap    filter=${filter_002_4}
# # #    run keyword and continue on failure    Check wireshark log data not empty      command=grep 'radioNetwork: action
# ...-desirable-for-radio-reasons'
# # #    ...     pacp_filename=enb_tcpdump_handover.pcap     txt_filename=enb_tcpdump_handover.txt    filter=${filter_002_3}
# # #    run keyword and continue on failure    Check wireshark log data not empty      command=grep 'drx-Config: setup'
# # #    ...     pacp_filename=enb_tcpdump_handover.pcap     txt_filename=enb_tcpdump_handover.txt    filter=${filter_007_1}
# # #    run keyword and continue on failure    Check wireshark log data equal value      command=grep physCellId |cut -d ':' -f 2|awk 'END {print}'
# # #    ...     pacp_filename=enb_tcpdump_handover.pcap     txt_filename=physCellId2.txt    filter=${filter_002_1}   check=${52}
# # #    ${ute_path}    Download Viavi Log    logs_path=${logs_path}
# # #    Check_TP_And_Bler_stable    dir_path=${ute_path}    ul_max_tp=${45}   dl_max_tp=${90}    bler_value=${0.01}
# # #    [Teardown]    run keyword and ignore error        Case Teardown
# # 
# # #*** Keywords ***
# # #Setup Commission SCF gNB1 and gNB2
# # #    5GC000573_common_keyword.Only Setup Commission SCF    gnbnumber=${0}    BTS_Host=${enb_ip}
# # #    5GC000573_common_keyword.Only Setup Commission SCF    gnbnumber=${1}    BTS_Host=${gNB_ip}
# # #    5GC000573_common_keyword.Only Setup Commission SCF    gnbnumber=${2}    BTS_Host=${gNB2_ip}
# # #    Wait Until Keyword Succeeds   16min   2min     Check cell on air for enb and gnb
# # #
# # #Check cell on air for enb and gnb
# # #    run keyword and continue on failure     Connect gnb and Check cell on air    BTS_Host=${enb_ip}
# # #    run keyword and continue on failure     Connect gnb and Check cell on air    BTS_Host=${gNB_ip}
# # #    run keyword and continue on failure     Connect gnb and Check cell on air    BTS_Host=${gNB2_ip}
# # #
# # #Modify ENB and GNB parameter
# # #    5GC000573_common_keyword.Modify Common parameter via Coam      input_list=${ENB_MODIFY_Parameter_7403}     gNB_ip=${enb_id}
# # #    5GC000573_common_keyword.Modify Common parameter via Coam      input_list=${GNB1_MODIFY_Parameter}     gNB_ip=${gNB_ip}
# # #    5GC000573_common_keyword.Modify Common parameter via Coam      input_list=${GNB2_MODIFY_Parameter}     gNB_ip=${gNB2_ip}
# # #
# # #Modify ENB and GNB parameter for 004
# # #    Modify Common parameter via Coam      input_list=${ENB_MODIFY_Parameter_7403_004}     gNB_ip=${enb_id}
# # #    Modify Common parameter via Coam      input_list=${GNB1_MODIFY_Parameter}     gNB_ip=${gNB_ip}
# # #    Modify Common parameter via Coam      input_list=${GNB2_MODIFY_Parameter}     gNB_ip=${gNB2_ip}
# # #
# # #Start tcpdump log attch UE and send UL and DL traffic
# # #    [Arguments]    ${btslog_name}     ${enb_tcpdump_before}    ${enb_tcpdump_after}     ${E500_SCRIPTS_BASE}=${E500_SCRIPTS_BASE}
# # #    5GC000573_common_keyword.Start wireshark capture from gNB or Enb      filename=${enb_tcpdump_before}    alias=enb1
# # #    log to console    start attach...
# # #    Cobham retry ue attach if failed    e500_script_path=${E500_SCRIPTS_BASE}     rrc_count=${2}
# # #    log to console    ue attach successful,sleep:2s
# # #    sleep    2s
# # #    5GC000573_common_keyword.Stop wireshark capture from gNB or Enb        filename=${enb_tcpdump_before}   alias=enb1
# # #    ${logs_path}     Start logging on cobham and Return Folder
# # #    5GC000573_common_keyword.Start wireshark capture from gNB or Enb     filename=${enb_tcpdump_after}    alias=enb2
# # #    sleep     5s
# # #    run keyword and continue on failure     Iperf send UL traffic VIAVI
# # #    run keyword and continue on failure     Iperf send DL traffic with real epc     throughput=${100}    traffic_time=${300}    port=${dl_port}
# # #    sleep     5s
# # #    start btslog capture on ute       btslog_name=${btslog_name}
# # #    sleep     5s
# # #    run keyword and continue on failure     Trigger A3 measurement report for 7403
# # #    sleep     2min
# # #    Stop logging on cobham
# # #    Stop syslog    alias=ute
# # #    5GC000573_common_keyword.Stop wireshark capture from gNB or Enb          filename=${enb_tcpdump_after}     alias=enb2
# # #    run keyword and continue on failure      5GC000573_common_keyword.Kill iperf process on ue side for UL
# # #    run keyword and continue on failure     Kill iperf process on app server     port=${dl_port}
# # #    5GC000573_common_keyword.Cobham UE detach TM500 detach
# # #    [Return]      ${logs_path}
# # #    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=ute
# # #
# # #Check wireshark log data contain attach message
# # #    [Arguments]   ${pacp_filename}    ${filter}    ${txt_filename}=attach_message.txt      ${connection}=ute
# # #    Connect to ENB with ssh    hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}     password=${TEST_PC_PASSWORD}    alias=${connection}
# # #    sleep    1s
# # #    log to console    ${LOG_PATH}
# # #    log to console    ${pacp_filename}
# # #    Convert pcap to text   source=${LOG_PATH}/${pacp_filename}
# # #    ...  target=${LOG_PATH}/${txt_filename}   connection=${connection}    filter=${filter}
# # #    run keyword and continue on failure     Check wireshark log data contain message     message='SgNBChangeRequired'
# # #    ...    txt_filename=${txt_filename}
# # #    run keyword and continue on failure     Check wireshark log data contain message     message='SgNBAdditionRequest'
# # #    ...    txt_filename=${txt_filename}
# # #    run keyword and continue on failure     Check wireshark log data contain message     message='SgNBAdditionRequestAcknowledge'
# # #    ...    txt_filename=${txt_filename}
# # #    run keyword and continue on failure     Check wireshark log data contain message     message='SgNBChangeConfirm'
# # #    ...    txt_filename=${txt_filename}
# # #    run keyword and continue on failure     Check wireshark log data contain message     message='SgNBReconfigurationComplete'
# # #    ...    txt_filename=${txt_filename}
# # #    run keyword and continue on failure     Check wireshark log data contain message     message='SNStatusTransfer'
# # #    ...    txt_filename=${txt_filename}
# # #    run keyword and continue on failure     Check wireshark log data contain message     message='E-RABModificationIndication'
# # #    ...    txt_filename=${txt_filename}
# # #    run keyword and continue on failure     Check wireshark log data contain message     message='E-RABModificationConfirm'
# # #    ...    txt_filename=${txt_filename}
# # #    run keyword and continue on failure     Check wireshark log data contain message     message='UEContextRelease'
# # #    ...    txt_filename=${txt_filename}
# # #    run keyword and continue on failure     Check wireshark log data contain message     message='SgNBModificationRequired'
# # #    ...    txt_filename=${txt_filename}
# # #    run keyword and continue on failure     Check wireshark log data contain message     message='SgNBModificationConfirm'
# # #    ...    txt_filename=${txt_filename}
# # #    [Teardown]    run keyword and ignore error    csn.Disconnect	connection=${connection}
# # #
# # #Check EventA3 from wireshark log data
# # #    [Arguments]      ${pacp_filename}   ${txt_filename}    ${filter}   ${event}   ${MeasID}   ${connection}=ute
# # #    Connect to ENB with ssh    hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}     password=${TEST_PC_PASSWORD}    alias=${connection}
# # #    Convert pcap to text   source=${LOG_PATH}/${pacp_filename}
# # #    ...  target=${LOG_PATH}/${txt_filename}   connection=${connection}    filter=${filter}
# # #    csn.Send Command  command=cat ${LOG_PATH}/${txt_filename} |awk '/measId: ${MeasID}/{p=5}p-->0'|head -3|tail -n 1|tr -cd "[0-9]"
# # #    ...    connection=${connection}
# # #    ${reportConfigId}    csn.Read Output    connection=${connection}
# # #    ${reportConfigId}    strip_string    ${reportConfigId}
# # #    csn.Send Command  command=cat ${LOG_PATH}/${txt_filename}|awk '/reportConfigId: ${reportConfigId}/{p=8}p-->0'|head -7|tail -n 1
# # #    ...    connection=${connection}
# # #    ${event1}    csn.Read Output    connection=${connection}
# # #    ${event1}    strip_string    ${event1}
# # #    should be equal as strings    ${event1}     ${event}
# # #    log to console    event:${event1}
# # #    [Teardown]    csn.Disconnect	connection=${connection}
# # #
# # #Get nrcellid from web UI
# # #    ${nrCellId1}     COAM Get nrcellid with the lcrid    bts_host=${gNB_ip}    lcrid=${1}
# # #    ${nrCellId2}     COAM Get nrcellid with the lcrid    bts_host=${gNB2_ip}   lcrid=${1}
# # #    [Return]   ${nrCellId1}   ${nrCellId2}
# # #
# # #Case Teardown
# # #    Cobham UE detach
# # #    csn.Disconnect    connection=ute
# # #    CI_interface.Common Case Teardown
# # #
# # #
# # #Trigger A3 measurement report for 7403
# # #    [Arguments]    ${a2_meas_id}=1    ${report_interval}=0    ${serving_cell_pci}=50    ${serving_cell_rsrp}=50
# # #    ...    ${serving_cell_rsrq}=55    ${serving_cell_sinr}=30    ${neigh_cell_pci}=52    ${neigh_cell_rsrp}=71    ${neigh_cell_rsrq}=77
# # #    ...    ${neigh_cell_sinr}=30    ${tm500_alias}=e500
# # #    log to console  Start to trigger A3 measurement report
# # #    ${cmd_a3_mr}    catenate
# # #    ...    forw mte NrRrcAptTriggerMeasReport ${a2_meas_id} 0 0 ${report_interval} 1
# # #    ...   {8 [${serving_cell_pci}] [[${serving_cell_rsrp}] [${serving_cell_rsrq}] [${serving_cell_sinr}]] [] [[1{0[[50] [55] [30]]}] []] [] []}
# # #    ...    [0(1{[${neigh_cell_pci}] [[${neigh_cell_rsrp}] [${neigh_cell_rsrq}] [${neigh_cell_sinr}]] [][ [1{0[[71] [77] [30]]}] [] ] })]
# # #    ${response}    tm500_remote.send_command    command=${cmd_a3_mr}    alias=${tm500_alias}
# # #    ${response}    tm500_remote.send_command    command=forw mte Activate -1    alias=${tm500_alias}
# # #    sleep    5s
# # #    Wait until keyword succeeds    10s    200ms    5GC000573_common_keyword.match pattern in response    response=${response}
# # #    ...    e500_alias=${tm500_alias}    pattern=Random Access Complete
# # #
# # #Trigger A3 measurement report for 7403 004
# # #    [Arguments]    ${a2_meas_id}=1    ${report_interval}=0    ${serving_cell_pci}=50    ${serving_cell_rsrp}=50
# # #    ...    ${serving_cell_rsrq}=55    ${serving_cell_sinr}=30    ${neigh_cell_pci}=52    ${neigh_cell_rsrp}=71    ${neigh_cell_rsrq}=77
# # #    ...    ${neigh_cell_sinr}=30    ${tm500_alias}=e500
# # #    log to console  Start to trigger A3 measurement report
# # #    ${cmd_a3_mr}    catenate
# # #    ...    forw mte NrRrcAptTriggerMeasReport ${a2_meas_id} 0 0 ${report_interval} 1
# # #    ...   {8 [${serving_cell_pci}] [[${serving_cell_rsrp}] [${serving_cell_rsrq}] [${serving_cell_sinr}]] [] [[1{0[[50] [55] [30]]}] []] [] []}
# # #    ...    [0(1{[${neigh_cell_pci}] [[${neigh_cell_rsrp}] [${neigh_cell_rsrq}] [${neigh_cell_sinr}]] [][ [1{0[[71] [77] [30]]}] [] ] })]
# # #    ${response}    tm500_remote.send_command    command=${cmd_a3_mr}    alias=${tm500_alias}
# # #    ${response}    tm500_remote.send_command    command=forw mte Activate -1    alias=${tm500_alias}
# # #    sleep    5s
# # #    Run Keyword And Expect Error    *String "Random Access Complete" is not found*       match pattern in response    response=${response}
# # #    ...    e500_alias=${tm500_alias}    pattern=Random Access Complete
# # #
# # #Start tcpdump log attch UE and send DL traffic
# # #    [Arguments]      ${enb_tcpdump_before}    ${E500_SCRIPTS_BASE}=${E500_SCRIPTS_BASE}
# # #    Start wireshark capture from gNB or Enb      filename=${enb_tcpdump_before}    alias=enb1
# # #    log to console    start attach...
# # #    Cobham retry ue attach if failed    e500_script_path=${E500_SCRIPTS_BASE}     rrc_count=${2}
# # #    log to console    ue attach successful,sleep:2s
# # #    sleep    2s
# # #    ${log_wireshark_path1}      Stop wireshark capture from gNB or Enb        filename=${enb_tcpdump_before}   alias=enb1
# # #    run keyword and continue on failure     Iperf send DL traffic with real epc     throughput=${100}    traffic_time=${300}    port=${dl_port}
# # #    sleep     5s
# # #    FOR    ${NUM}    IN RANGE    ${1}    ${3}    1
# # #        Start wireshark capture from gNB or Enb         filename=enb_tcpdump_handover_${NUM}     alias=enb1
# # #        run keyword and continue on failure     Trigger A3 measurement report for 7403
# # #        Stop wireshark capture from gNB or Enb          filename=enb_tcpdump_handover_${NUM}     alias=enb1
# # #        run keyword and continue on failure     Trigger A3 measurement report for 7403      serving_cell_pci=${52}    neigh_cell_pci=${50}
# # #    END
# # #    sleep     40s
# # #    Stop logging on cobham
# # #    run keyword and continue on failure     Kill iperf process on app server     port=${dl_port}
# # #    Cobham UE detach TM500 detach
# # #    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=ute
# # #
# # #Start tcpdump log and attch UE
# # #    [Arguments]       ${enb_tcpdump_before}    ${enb_tcpdump_after}     ${E500_SCRIPTS_BASE}=${E500_SCRIPTS_BASE}
# # #    Start wireshark capture from gNB or Enb      filename=${enb_tcpdump_before}    alias=enb1
# # #    log to console    start attach...
# # #    Cobham retry ue attach if failed    e500_script_path=${E500_SCRIPTS_BASE}     rrc_count=${2}
# # #    log to console    ue attach successful,sleep:2s
# # #    sleep    2s
# # #    ${log_wireshark_path1}      Stop wireshark capture from gNB or Enb        filename=${enb_tcpdump_before}   alias=enb1
# # #    Start wireshark capture from gNB or Enb     filename=${enb_tcpdump_after}    alias=enb2
# # #    sleep     5s
# # #    run keyword and continue on failure     Trigger A3 measurement report for 7403 004
# # #    sleep     10s
# # #    Stop wireshark capture from gNB or Enb          filename=${enb_tcpdump_after}     alias=enb2
# # #    Cobham UE detach TM500 detach
# # #    Cobham UE detach
# # #    [Teardown]    run keyword and ignore error      Case Teardown
# # #
# # #Check counter number on gNB1 and gNB2
# # #    Wait for counter to be gathered after guard peroid
# # #    ${M55112C02501}    Check PM counter result    counter_id=M55112C02501
# # #    ${M55112C02502}    Check PM counter result    counter_id=M55112C02502
# # #    ${M55112C02503}    Check PM counter result    counter_id=M55112C02503    index=${1}
# # #    ${M55112C02504}    Check PM counter result    counter_id=M55112C02504    index=${1}
# # #    ${M55112C02505}    Check PM counter result    counter_id=M55112C02505    index=${1}
# # #    ${M55112C02506}    Check PM counter result    counter_id=M55112C02506    index=${1}
# # #    run keyword and continue on failure     Get length and Check sum counter value      list_input=${M55112C02501}
# # #    run keyword and continue on failure     Get length and Check sum counter value      list_input=${M55112C02502}
# # #    run keyword and continue on failure     Get length and Check sum counter value      list_input=${M55112C02503}
# # #    run keyword and continue on failure     Get length and Check sum counter value      list_input=${M55112C02504}
# # #    run keyword and continue on failure     Get length and Check sum counter value      list_input=${M55112C02505}
# # #    run keyword and continue on failure     Get length and Check sum counter value      list_input=${M55112C02506}
# # #
# # #Get length and Check sum counter value
# # #    [Arguments]     ${list_input}
# # #    ${length}      Get Length       ${list_input}
# # #    ${counter_value_sum}       Set Variable          0
# # #    FOR   ${i}    IN RANGE    ${0}    ${length}     1
# # #        ${counter_value_sum}     Evaluate    ${counter_value_sum}+${list_input}[${i}]
# # #    END
# # #    should be true    ${counter_value_sum}==2
# # #
# # #Get measId from wireshark log due to Event
# # #    [Arguments]      ${pacp_filename}   ${txt_filename}    ${filter}   ${Event}   ${connection}=ute
# # #    5GC000573_common_keyword.Connect to ENB with ssh    hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}
# # #    ...     password=${TEST_PC_PASSWORD}    alias=${connection}
# # #    sleep    1s
# # #    5GC000573_common_keyword.Convert pcap to text   source=${LOG_PATH}/${pacp_filename}
# # #    ...  target=${LOG_PATH}/${txt_filename}   connection=${connection}    filter=${filter}
# # #    ${meas_event_list}      5GC002199_common.return_add_measId_and_Event_map      file_name=${LOG_PATH}/${txt_filename}
# # #    ${measid}      get from Dictionary   ${meas_event_list}    ${Event}
# # #    [Return]   ${measid}
# # #    [Teardown]    csn.Disconnect	connection=${connection}