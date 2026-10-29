# # #*** Settings ***
# # #Force Tags    PY36
# # #Suite Setup       Suite Setup for 2199
# # #Suite Teardown    Modify Common parameter via Coam      input_list=${ENB_MODIFY_Parameter_recover}     gNB_ip=${enb_id}
# # #
# # #Documentation    author：Shanshan Zhang
# # #...              contact: shanshan.zhang@nokia-sbell.com
# # #...              squad group: mmw_SG_04
# # #
# # #
# # #Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# # #Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
# # #Resource            taf/rfrl/common_resources/robot/connection_alias_store.robot
# # #Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
# # #Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# # #Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/viavi_common_keyword.robot
# # #Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
# # #Resource            ../CB007608_B-573/Resources/5GC000573_common_keyword.robot
# # #Resource            ./Resources/5GC002199_common.robot
# # #Library             testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/Analysis_Viavi_Log.py
# # #Library             Analysis_Viavi_Log.Viavi_Log_analysis     WITH NAME    Viavi_Log_analysis
# # #Library             ../CB007608_B-573/Resources/5GC000573_common.py
# # #Library             ./Resources/5GC002199_common.py
# # #Library             ute_syslog
# # #Variables           ./Resources/5GC002199_modify_para.py
# # #Variables           ../CB007608_B-573/Resources/5GC000573_modify_para.py
# # #
# # #*** Variables ***
# # #${gNB_ip}                 ${tl.gnbs[0].dus[0].f1_m_ip_addr}
# # #${gNB2_ip}                ${tl.gnbs[1].dus[0].f1_m_ip_addr}
# # #${gNB_username}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
# # #${gNB_password}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
# # #${enb_id}                 ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
# # #${E500_SCRIPTS_BASE}      ${CURDIR}/E500_scripts_01
# # #${LOG_PATH}               ${OUTPUT_DIR}
# # #${port1}                  51000
# # #${port2}                  51003
# # #${eventA1}                    eventA1
# # #${eventA2}                    eventA2
# # #${eventA3}                    eventA3
# # #${eventA5}                    eventA5
# # #${rsrp}                       rsrp
# # #${TEST_PC_IP}                 ${tl.test_pc.default_ssh_connection_details.addr}
# # #${TEST_PC_USERNAME}           ${tl.test_pc.default_ssh_connection_details.username}
# # #${TEST_PC_PASSWORD}           ${tl.test_pc.default_ssh_connection_details.password}
# # #${ul_port}                   ${tl.ues[0].iperf_details.ssh_connection_details.port}
# # #${dl_port}                   ${tl.ues[0].iperf_details.port}
# # #${luashark_path}              /opt/ute/luashark/luashark_script/generated_luashark
# # #${filter_physCellId}          x2ap.procedureCode == 27 && x2ap.X2AP_PDU == 1
# # #${filter_002_2}               x2ap.procedureCode == 35
# # #${filter_002_3}               x2ap.procedureCode == 34 && x2ap.X2AP_PDU == 0
# # #${filter_002_4}               s1ap || x2ap || f1ap || e1ap || nr-rrc
# # #${filter_007_1}               x2ap.procedureCode == 30 && x2ap.X2AP_PDU == 0
# # #${filter_004_1}               x2ap.procedureCode == 34 && x2ap.X2AP_PDU == 2
# # #${filter_measurement}                  x2ap.procedureCode == 35 && x2ap.X2AP_PDU == 0
# # #${filter_modification}                 x2ap.procedureCode == 29 && x2ap.X2AP_PDU == 0
# # #${filter_modification_requeste}        f1ap.procedureCode == 7 && f1ap.F1AP_PDU == 0  && nr-rrc.ssb_RSRP == 36
# # #${filter_measIdToAddModList}           x2ap.procedureCode == 29 && x2ap.X2AP_PDU == 1 && nr-rrc.rrc_TransactionIdentifier == 2
# # #${filter_modification_Ackonwledge}      x2ap.procedureCode == 29 && x2ap.X2AP_PDU == 1
# # #${filter_measurement_005}            f1ap.procedureCode == 13 && f1ap.F1AP_PDU == 0
# # #${filter_Reconfiguration}            f1ap.procedureCode == 12 && f1ap.F1AP_PDU == 0
# # #
# # #*** Test Cases ***
# # #[1]CB007608-A-5GC002199_03_counters_M55112C0450X_related_to_interFreq_intergNB_HO_without_SRB3_on_mmW
# # #    [Tags]          CRT_22R2
# # #    Modify ENB and GNB parameter for Two GNB
# # #    ...      GNB1_MODIFY_Parameter=${GNB1_MODIFY_Parameter_003}     GNB2_MODIFY_Parameter=${GNB2_MODIFY_Parameter_003}
# # #    run keyword and continue on failure      5GC000573_common_keyword.kill IPSL process
# # #    Wait for counter to be gathered after guard peroid      interval=15
# # #    Precondition for attach with retry    e500_script_path=${CURDIR}/E500_scripts
# # #    Start tcpdump log attach UE    E500_SCRIPTS_BASE=${CURDIR}/E500_scripts     enb_tcpdump_attach=enb_tcpdump_attach
# # #    run keyword and continue on failure       Send measurement report and handover counter
# # #    ...     enb_tcpdump_attach=enb_tcpdump_attach    neigh_cell_pci=${52}
# # #    run keyword and continue on failure     Check BTS counter result
# # #    run keyword and continue on failure     Check interFreq_intergNB with A2 without_SRB3    enb_tcpdump_attach=enb_tcpdump_attach.pcap
# # #    ...     enb_tcpdump_A2=tcpdump_1_A2_50-52.pcap    enb_tcpdump_A3=tcpdump_1_A3_50-52.pcap
# # #    ...     cell1_number=${50}     cell2_number=${52}
# # #    Check wireshark log data equal value      command=grep physCellId |cut -d ':' -f 2|awk 'END {print}'
# # #    ...     pacp_filename=tcpdump_1_A3_52-50.pcap    txt_filename=physCellId3.txt    filter=${filter_physCellId}   check=${50}
# # #    [Teardown]    run keyword and ignore error        Case Teardown
# # #
# # #[1]CB007608-5G-A-5GC002199_05_removal_of_interFreq_A3A5_and_configuration_A2_after_receipt_A1_RSRPCombine_Measurement_report_with_SRB3
# # #    [Tags]           CRT_22R2
# # #    Modify ENB and GNB parameter for Two GNB    GNB1_MODIFY_Parameter=${GNB1_MODIFY_Parameter_005}
# # #    ...     GNB2_MODIFY_Parameter=${GNB2_MODIFY_Parameter_005}
# # #    run keyword and continue on failure      5GC000573_common_keyword.kill IPSL process
# # #    Precondition for attach with retry    e500_script_path=${CURDIR}/E500_scripts
# # #    Start tcpdump log attach UE    E500_SCRIPTS_BASE=${CURDIR}/E500_scripts     enb_tcpdump_attach=enb_tcpdump_attach
# # #    ...     gnb=${True}     rrc_count=${1}
# # #    Send measurement report and handover one times    enb_tcpdump_attach=enb_tcpdump_attach
# # #    sleep    10s
# # #    run keyword and continue on failure     Cobham UE detach
# # #    run keyword and continue on failure     Check interFreq_intergNB with A2 and A1 with SRB3
# # #    ...     enb_tcpdump_attach=enb_tcpdump_attach.pcap       enb_tcpdump_A2=tcpdump_1_A2_50-52.pcap
# # #    ...     cell1_number=${50}     cell2_number=${52}    Check_event=${eventA3}
# # #    run keyword and continue on failure      Check wireshark log data contain attach message with SRB3
# # #    ...    pacp_filename=tcpdump_1_A1_50-52.pcap     filter=${filter_002_4}
# # #    [Teardown]    run keyword and ignore error        Case Teardown
# # #
# # #[1]CB007608-5G-A-5GC002199_01_Robustness_pingpong_interFreq_intragNB_HO_ABIO_wih_SRB3
# # #    [Tags]          CRT_22R2
# # #    Modify ENB and GNB parameter        GNB_MODIFY_Parameter=${GNB1_MODIFY_Parameter_001}
# # #    run keyword and continue on failure      5GC000573_common_keyword.kill IPSL process
# # #    Precondition for attach with retry    e500_script_path=${CURDIR}/E500_scripts_01
# # #    Start tcpdump log attach UE      enb_tcpdump_attach=enb_tcpdump_attach   gnb=${True}  rrc_count=${1}
# # #    ${logs_path}     Send UL and DL traffic and start logging
# # #    run keyword and continue on failure       Send measurement report and handover two times      enb_tcpdump_attach=enb_tcpdump_attach
# # #    ...    gnb=${True}     neigh_cell_pci=${51}
# # #    Stop logging on cobham
# # #    Capture wireshark and detach UE      gnb=${True}
# # #    run keyword and continue on failure      5GC000573_common_keyword.Kill iperf process on ue side for UL
# # #    run keyword and continue on failure     Kill iperf process on app server     port=${dl_port}
# # #    run keyword and continue on failure     Check interFreq_IntraGnb with A2 with SRB3      enb_tcpdump_attach=enb_tcpdump_attach.pcap
# # #    ...     enb_tcpdump_A2=tcpdump_1_A2_50-51.pcap    enb_tcpdump_A3=tcpdump_1_A3_50-51.pcap
# # #    ...     cell1_number=${50}     cell2_number=${51}
# # #    sleep   2min
# # #    ${ute_path}    Download Viavi Log    logs_path=${logs_path}
# # #    run keyword and continue on failure      Check_TP_And_Bler_stable    dir_path=${ute_path}
# # #    ...    ul_max_tp=${45}   dl_max_tp=${90}    bler_value=${0.01}
# # #    [Teardown]    run keyword and ignore error        Case Teardown
# # #
# # #[1]CB007608-A-5GC002199_07_interFreq_FR2_FR2_intergNB_HO_A3_RSRP_and_RSRQ_without_SRB3
# # #    [Tags]          CRT_22R2
# # #    Modify ENB and GNB parameter for Two GNB
# # #    ...      GNB1_MODIFY_Parameter=${GNB1_MODIFY_Parameter_007}     GNB2_MODIFY_Parameter=${GNB2_MODIFY_Parameter_007}
# # #    run keyword and continue on failure      5GC000573_common_keyword.kill IPSL process
# # #    Precondition for attach with retry    e500_script_path=${CURDIR}/E500_scripts
# # #    Start tcpdump log attach UE    E500_SCRIPTS_BASE=${CURDIR}/E500_scripts     enb_tcpdump_attach=enb_tcpdump_attach
# # #    ${logs_path}     Send UL and DL traffic and start logging
# # #    run keyword and continue on failure       Send measurement report and handover     enb_tcpdump_attach=enb_tcpdump_attach
# # #    Stop logging on cobham
# # #    Detach UE and Stop iperf
# # #    run keyword and continue on failure    Check interFreq_intergNB with A2 without_SRB3 and A3 is rsrp
# # #    ...     enb_tcpdump_A2=tcpdump_1_A2_50-52.pcap    enb_tcpdump_A3=tcpdump_1_A3_50-52.pcap    enb_tcpdump_attach=enb_tcpdump_attach.pcap
# # #    ...     cell1_number=${50}     cell2_number=${52}
# # #    run keyword and continue on failure    Check wireshark log data equal value      command=grep physCellId |cut -d ':' -f 2|awk 'END {print}'
# # #    ...     pacp_filename=tcpdump_1_A3_52-50.pcap    txt_filename=physCellId3.txt    filter=${filter_physCellId}   check=${50}
# # #    sleep   2min
# # #    ${ute_path}    Download Viavi Log    logs_path=${logs_path}
# # #    run keyword and continue on failure      Check_TP_And_Bler_stable    dir_path=${ute_path}
# # #    ...    ul_max_tp=${45}   dl_max_tp=${90}    bler_value=${0.05}
# # #    [Teardown]    run keyword and ignore error        Case Teardown
# # #
# # #[1]CB007608-A-5GC002199_09_Test_2_PSCell_Change_Successfully_nCA_A3_RSRP_With_Data_Duplication
# # #    [Tags]            CRT_22R2
# # #    Modify ENB and GNB parameter for Two GNB
# # #    ...      GNB1_MODIFY_Parameter=${GNB1_MODIFY_Parameter_009}     GNB2_MODIFY_Parameter=${GNB2_MODIFY_Parameter_009}
# # #    run keyword and continue on failure      5GC000573_common_keyword.kill IPSL process
# # #    Precondition for attach with retry    e500_script_path=${CURDIR}/E500_scripts
# # #    Start tcpdump log attach UE    E500_SCRIPTS_BASE=${CURDIR}/E500_scripts     enb_tcpdump_attach=enb_tcpdump_attach
# # #    ${logs_path}     Send UL and DL traffic and start logging
# # #    run keyword and continue on failure       Send measurement report and handover     enb_tcpdump_attach=enb_tcpdump_attach
# # #    Stop logging on cobham
# # #    Detach UE and Stop iperf
# # #    run keyword and continue on failure     Check interFreq_intergNB with A2 without_SRB3    enb_tcpdump_attach=enb_tcpdump_attach.pcap
# # #    ...     enb_tcpdump_A2=tcpdump_1_A2_50-52.pcap    enb_tcpdump_A3=tcpdump_1_A3_50-52.pcap
# # #    ...     cell1_number=${50}     cell2_number=${52}
# # #    run keyword and continue on failure     Check wireshark log data equal value      command=grep physCellId |cut -d ':' -f 2|awk 'END {print}'
# # #    ...     pacp_filename=tcpdump_1_A3_52-50.pcap    txt_filename=physCellId3.txt    filter=${filter_physCellId}   check=${50}
# # #    sleep   2min
# # #    ${ute_path}    Download Viavi Log    logs_path=${logs_path}
# # #    run keyword and continue on failure      Check_TP_And_Bler_stable    dir_path=${ute_path}
# # #    ...    ul_max_tp=${45}   dl_max_tp=${90}    bler_value=${0.05}
# # #    [Teardown]    run keyword and ignore error        Case Teardown for 2199-09
# # 
# # 
# # #*** Keywords ***
# # #Suite Setup for 2199
# # #    Setup Commission SCF gNB1 and gNB2
# # #    Modify Common parameter via Coam      input_list=${ENB_MODIFY_Parameter}     gNB_ip=${enb_id}
# # #
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
# # #    [Arguments]      ${GNB_MODIFY_Parameter}
# # #    5GC000573_common_keyword.Modify Common parameter via Coam      input_list=${GNB_MODIFY_Parameter}     gNB_ip=${gNB_ip}
# # #
# # #Modify ENB and GNB parameter for Two GNB
# # #    [Arguments]      ${GNB1_MODIFY_Parameter}    ${GNB2_MODIFY_Parameter}
# # #    5GC000573_common_keyword.Modify Common parameter via Coam      input_list=${GNB1_MODIFY_Parameter}     gNB_ip=${gNB_ip}
# # #    5GC000573_common_keyword.Modify Common parameter via Coam      input_list=${GNB2_MODIFY_Parameter}     gNB_ip=${gNB2_ip}
# # #    Check cell on air for enb and gnb
# # #    [Teardown]    Run keyword and ignore error    coam.teardown      connection=GNB_OAM
# # #
# # #Get nrcellid from web UI
# # #    [Arguments]     ${bts_host1}=${gNB_ip}   ${bts_host2}=${gNB_ip}    ${lcrid1}=${1}      ${lcrid2}=${2}
# # #    ${nrCellId1}     COAM Get nrcellid with the lcrid    bts_host=${bts_host1}    lcrid=${lcrid1}
# # #    ${nrCellId2}     COAM Get nrcellid with the lcrid    bts_host=${bts_host2}    lcrid=${lcrid2}
# # #    [Return]   ${nrCellId1}   ${nrCellId2}
# # #
# # #Start tcpdump log attach UE
# # #    [Arguments]       ${enb_tcpdump_attach}    ${gnb}=${False}     ${rrc_count}=${2}   ${E500_SCRIPTS_BASE}=${E500_SCRIPTS_BASE}
# # #    5GC000573_common_keyword.Start wireshark capture from gNB or Enb      filename=${enb_tcpdump_attach}   gnb=${gnb}    alias=gnb1
# # #    log to console    start attach...
# # #    Cobham retry ue attach if failed    e500_script_path=${E500_SCRIPTS_BASE}     rrc_count=${rrc_count}
# # #    log to console    ue attach successful,sleep:2s
# # #    sleep    2s
# # #    ${log_wireshark_path}      Stop wireshark capture from gNB or Enb        filename=${enb_tcpdump_attach}   gnb=${gnb}    alias=gnb1
# # #
# # #Send UL and DL traffic and start logging
# # #    ${logs_path}     Start logging on cobham and Return Folder
# # #    run keyword and continue on failure     Iperf send UL traffic VIAVI     traffic_time=${600}
# # #    run keyword and continue on failure     Iperf send DL traffic with real epc     throughput=${100}    traffic_time=${600}    port=${dl_port}
# # #    [Return]  ${logs_path}
# # #
# # #Send measurement report and handover two times
# # #    [Arguments]  ${enb_tcpdump_attach}=enb_tcpdump_attach   ${enb_tcpdump_detach}=enb_tcpdump_detach
# # #    ...     ${gnb}=${True}      ${serving_cell_pci}=50     ${neigh_cell_pci}=52
# # ##    First time cell 50 to cell 51
# # #    Trigger A2 measurement report handover    measid_enb_tcpdump=${enb_tcpdump_attach}     enb_tcpdump=tcpdump_1_A2_50-51
# # #    ...       serving_cell_pci=${serving_cell_pci}      neigh_cell_pci=${neigh_cell_pci}    gnb=${gnb}
# # #    Trigger A3 measurement report handover    measid_enb_tcpdump=tcpdump_1_A2_50-51   enb_tcpdump=tcpdump_1_A3_50-51
# # #    ...     serving_cell_pci=${serving_cell_pci}      neigh_cell_pci=${neigh_cell_pci}    gnb=${gnb}
# # ##    First time cell 51 to cell 50
# # #    Trigger A2 measurement report handover    measid_enb_tcpdump=tcpdump_1_A3_50-51    enb_tcpdump=tcpdump_1_A2_51-50
# # #    ...     serving_cell_pci=${neigh_cell_pci}      neigh_cell_pci=${serving_cell_pci}    gnb=${gnb}     filter=${filter_Reconfiguration}
# # #    Trigger A3 measurement report handover    measid_enb_tcpdump=tcpdump_1_A2_51-50    enb_tcpdump=tcpdump_1_A3_51-50
# # #    ...     serving_cell_pci=${neigh_cell_pci}      neigh_cell_pci=${serving_cell_pci}    gnb=${gnb}
# # ##   Second time cell 50 to cell 51
# # #    Trigger A2 measurement report handover    measid_enb_tcpdump=tcpdump_1_A3_51-50    enb_tcpdump=tcpdump_2_A2_50-51
# # #    ...     serving_cell_pci=${serving_cell_pci}      neigh_cell_pci=${neigh_cell_pci}    gnb=${gnb}     filter=${filter_Reconfiguration}
# # #    Trigger A3 measurement report handover    measid_enb_tcpdump=tcpdump_2_A2_50-51   enb_tcpdump=tcpdump_2_A3_50-51
# # #    ...     serving_cell_pci=${serving_cell_pci}      neigh_cell_pci=${neigh_cell_pci}    gnb=${gnb}
# # ##    First time cell 51 to cell 50
# # #    Trigger A2 measurement report handover    measid_enb_tcpdump=tcpdump_2_A3_50-51    enb_tcpdump=tcpdump_2_A2_51-50
# # #    ...     serving_cell_pci=${neigh_cell_pci}      neigh_cell_pci=${serving_cell_pci}    gnb=${gnb}     filter=${filter_Reconfiguration}
# # #    Trigger A3 measurement report handover    measid_enb_tcpdump=tcpdump_2_A2_51-50    enb_tcpdump=tcpdump_2_A3_51-50
# # #    ...     serving_cell_pci=${neigh_cell_pci}      neigh_cell_pci=${serving_cell_pci}    gnb=${gnb}
# # #
# # #Send measurement report and handover one times
# # #    [Arguments]  ${enb_tcpdump_attach}   ${gnb}=${True}  ${serving_cell_pci}=50     ${neigh_cell_pci}=52
# # #    Trigger A2 measurement report handover    measid_enb_tcpdump=${enb_tcpdump_attach}     enb_tcpdump=tcpdump_1_A2_50-52
# # #    ...     filter=${filter_physCellId}   serving_cell_pci=${serving_cell_pci}      neigh_cell_pci=${neigh_cell_pci}    gnb=${gnb}
# # #    Trigger A1 measurement report handover    measid_enb_tcpdump=tcpdump_1_A2_50-52   gnb_tcpdump=tcpdump_1_A1_50-52    gnb=${gnb}
# # #    ...     serving_cell_pci=${serving_cell_pci}      neigh_cell_pci=${neigh_cell_pci}
# # #
# # #Send measurement report and handover
# # #    [Arguments]  ${enb_tcpdump_attach}=enb_tcpdump_attach   ${enb_tcpdump_detach}=enb_tcpdump_detach
# # #    ...     ${gnb}=${False}      ${serving_cell_pci}=50     ${neigh_cell_pci}=52
# # ##    First time cell 50 to cell 52
# # #    Trigger A2 measurement report handover    measid_enb_tcpdump=${enb_tcpdump_attach}     enb_tcpdump=tcpdump_1_A2_50-52
# # #    ...       serving_cell_pci=${serving_cell_pci}      neigh_cell_pci=${neigh_cell_pci}    gnb=${gnb}
# # #    Trigger A3 measurement report handover due to rsrp or rsrq    measid_enb_tcpdump=tcpdump_1_A2_50-52   enb_tcpdump=tcpdump_1_A3_50-52
# # #    ...     serving_cell_pci=${serving_cell_pci}      neigh_cell_pci=${neigh_cell_pci}    gnb=${gnb}
# # ##    First time cell 52 to cell 50
# # #    Trigger A2 measurement report handover    measid_enb_tcpdump=tcpdump_1_A3_50-52    enb_tcpdump=tcpdump_1_A2_52-50
# # #    ...     serving_cell_pci=${neigh_cell_pci}      neigh_cell_pci=${serving_cell_pci}    gnb=${gnb}
# # #    Trigger A3 measurement report handover due to rsrp or rsrq    measid_enb_tcpdump=tcpdump_1_A2_52-50    enb_tcpdump=tcpdump_1_A3_52-50
# # #    ...     serving_cell_pci=${neigh_cell_pci}      neigh_cell_pci=${serving_cell_pci}    gnb=${gnb}
# # #
# # #Send measurement report and handover counter
# # #    [Arguments]  ${enb_tcpdump_attach}=enb_tcpdump_attach   ${enb_tcpdump_detach}=enb_tcpdump_detach
# # #    ...     ${gnb}=${False}      ${serving_cell_pci}=50     ${neigh_cell_pci}=52
# # ##    First time cell 50 to cell 51
# # #    Trigger A2 measurement report handover    measid_enb_tcpdump=${enb_tcpdump_attach}     enb_tcpdump=tcpdump_1_A2_50-52
# # #    ...       serving_cell_pci=${serving_cell_pci}      neigh_cell_pci=${neigh_cell_pci}    gnb=${gnb}
# # #    Trigger A3 measurement report handover    measid_enb_tcpdump=tcpdump_1_A2_50-52   enb_tcpdump=tcpdump_1_A3_50-52
# # #    ...     serving_cell_pci=${serving_cell_pci}      neigh_cell_pci=${neigh_cell_pci}    gnb=${gnb}
# # ##    First time cell 51 to cell 50
# # #    Trigger A2 measurement report handover    measid_enb_tcpdump=tcpdump_1_A3_50-52    enb_tcpdump=tcpdump_1_A2_52-50
# # #    ...     serving_cell_pci=${neigh_cell_pci}      neigh_cell_pci=${serving_cell_pci}    gnb=${gnb}
# # #    Trigger A3 measurement report handover    measid_enb_tcpdump=tcpdump_1_A2_52-50    enb_tcpdump=tcpdump_1_A3_52-50
# # #    ...     serving_cell_pci=${neigh_cell_pci}      neigh_cell_pci=${serving_cell_pci}    gnb=${gnb}
# # ##   Second time cell 50 to cell 51
# # #    Trigger A2 measurement report handover    measid_enb_tcpdump=tcpdump_1_A3_52-50    enb_tcpdump=tcpdump_2_A2_50-52
# # #    ...     serving_cell_pci=${serving_cell_pci}      neigh_cell_pci=${neigh_cell_pci}    gnb=${gnb}
# # #    Trigger A3 measurement report handover    measid_enb_tcpdump=tcpdump_2_A2_50-52   enb_tcpdump=tcpdump_2_A3_50-52
# # #    ...     serving_cell_pci=${serving_cell_pci}      neigh_cell_pci=${neigh_cell_pci}    gnb=${gnb}
# # #
# # #Trigger A2 measurement report handover
# # #    [Arguments]  ${measid_enb_tcpdump}   ${enb_tcpdump}    ${filter}=${filter_physCellId}
# # #    ...     ${gnb}=${False}    ${serving_cell_pci}=50     ${neigh_cell_pci}=52
# # #    ${measid}      Get measId from wireshark log due to Event     pacp_filename=${measid_enb_tcpdump}.pcap
# # #    ...        txt_filename=${measid_enb_tcpdump}.txt    filter=${filter}     Event=${eventA2}
# # #    5GC000573_common_keyword.Start wireshark capture from gNB or Enb     filename=${enb_tcpdump}      gnb=${gnb}   alias=enb
# # #    sleep     5s
# # #    run keyword and continue on failure     Trigger A2 measurement report     a2_meas_id=${measId}
# # #    ...     serving_cell_pci=${serving_cell_pci}      neigh_cell_pci=${neigh_cell_pci}
# # #    sleep     20s
# # #    5GC000573_common_keyword.Stop wireshark capture from gNB or Enb      filename=${enb_tcpdump}    gnb=${gnb}    alias=enb
# # #
# # #Trigger A3 measurement report handover
# # #    [Arguments]  ${measid_enb_tcpdump}    ${enb_tcpdump}    ${filter}=${filter_modification_Ackonwledge}
# # #    ...     ${gnb}=${False}     ${serving_cell_pci}=50      ${neigh_cell_pci}=52
# # #    ${measid}      Get measId from wireshark log due to Event      pacp_filename=${measid_enb_tcpdump}.pcap    Event=${eventA3}
# # #    ...        txt_filename=${measid_enb_tcpdump}.txt    filter=${filter_modification_Ackonwledge}
# # #    5GC000573_common_keyword.Start wireshark capture from gNB or Enb     filename=${enb_tcpdump}   gnb=${gnb}    alias=enb
# # #    sleep     5s
# # #    run keyword and continue on failure     Trigger A3 measurement report for 002 case       a2_meas_id=${measid}
# # #    ...     serving_cell_pci=${serving_cell_pci}     neigh_cell_pci=${neigh_cell_pci}
# # #    sleep     20s
# # #    5GC000573_common_keyword.Stop wireshark capture from gNB or Enb          filename=${enb_tcpdump}    gnb=${gnb}   alias=enb
# # #
# # #Trigger A3 measurement report handover due to rsrp or rsrq
# # #    [Arguments]  ${measid_enb_tcpdump}    ${enb_tcpdump}    ${filter}=${filter_modification_Ackonwledge}
# # #    ...     ${gnb}=${False}     ${serving_cell_pci}=50      ${neigh_cell_pci}=52    ${RsrporRsrq}=${rsrp}
# # #    ${measid}      Get measId from wireshark log due to Event due to rsrp      pacp_filename=${measid_enb_tcpdump}.pcap    Event=${eventA3}
# # #    ...        txt_filename=${measid_enb_tcpdump}.txt    filter=${filter_modification_Ackonwledge}     RsrporRsrq=${RsrporRsrq}
# # #    5GC000573_common_keyword.Start wireshark capture from gNB or Enb     filename=${enb_tcpdump}   gnb=${gnb}    alias=enb
# # #    sleep     5s
# # #    run keyword and continue on failure     Trigger A3 measurement report for 002 case       a2_meas_id=${measid}
# # #    ...     serving_cell_pci=${serving_cell_pci}     neigh_cell_pci=${neigh_cell_pci}
# # #    sleep     20s
# # #    5GC000573_common_keyword.Stop wireshark capture from gNB or Enb          filename=${enb_tcpdump}    gnb=${gnb}   alias=enb
# # #
# # #Trigger A5 measurement report handover
# # #    [Arguments]  ${measid_enb_tcpdump}    ${gnb1_tcpdump}  ${gnb2_tcpdump}   ${filter}=${filter_modification_Ackonwledge}
# # #    ...     ${gnb}=${True}     ${serving_cell_pci}=50      ${neigh_cell_pci}=52
# # #    ${measid}      Get measId from wireshark log due to Event      pacp_filename=${measid_enb_tcpdump}.pcap    Event=${eventA5}
# # #    ...        txt_filename=${measid_enb_tcpdump}.txt    filter=${filter_modification_Ackonwledge}
# # #    5GC000573_common_keyword.Start wireshark capture from gNB or Enb     filename=${gnb1_tcpdump}   gnb=${gnb}    alias=gnb1
# # #    5GC000573_common_keyword.Start wireshark capture from gNB or Enb     filename=${gnb2_tcpdump}   gnb=${gnb}    alias=gnb2   index=${1}
# # #    sleep     3s
# # #    run keyword and continue on failure     Trigger A5 measurement report       a2_meas_id=${measid}
# # #    ...     serving_cell_pci=${serving_cell_pci}     neigh_cell_pci=${neigh_cell_pci}
# # #    sleep     10s
# # #    5GC000573_common_keyword.Stop wireshark capture from gNB or Enb          filename=${gnb1_tcpdump}    gnb=${gnb}   alias=gnb1
# # #    5GC000573_common_keyword.Stop wireshark capture from gNB or Enb          filename=${gnb2_tcpdump}    gnb=${gnb}   alias=gnb2   index=${1}
# # #
# # #Trigger A1 measurement report handover
# # #    [Arguments]  ${measid_enb_tcpdump}    ${gnb_tcpdump}   ${filter}=${filter_modification_Ackonwledge}
# # #    ...     ${gnb}=${False}     ${serving_cell_pci}=50      ${neigh_cell_pci}=52    ${RsrporRsrq}=${rsrp}
# # #    ${measid}      Get measId from wireshark log due to Event      pacp_filename=${measid_enb_tcpdump}.pcap    Event=${eventA1}
# # #    ...        txt_filename=${measid_enb_tcpdump}.txt    filter=${filter_modification_Ackonwledge}
# # #    5GC000573_common_keyword.Start wireshark capture from gNB or Enb     filename=${gnb_tcpdump}   gnb=${gnb}    alias=gnb1
# # #    sleep     5s
# # #    run keyword and continue on failure     Trigger A1 measurement report       a2_meas_id=${measid}
# # #    ...     serving_cell_pci=${serving_cell_pci}     neigh_cell_pci=${neigh_cell_pci}
# # #    sleep     10s
# # #    run keyword and continue on failure     Trigger A1 measurement report       a2_meas_id=${measid}     serving_cell_rsrq=${71}
# # #    ...     serving_cell_sinr=${71}       serving_cell_pci=${serving_cell_pci}     neigh_cell_pci=${neigh_cell_pci}
# # #    sleep     10s
# # #    5GC000573_common_keyword.Stop wireshark capture from gNB or Enb          filename=${gnb_tcpdump}    gnb=${gnb}   alias=gnb1
# # #
# # #Capture wireshark and detach UE
# # #    [Arguments]   ${enb_tcpdump_detach}=enb_tcpdump_detach     ${gnb}=${False}
# # #    5GC000573_common_keyword.Start wireshark capture from gNB or Enb     filename=${enb_tcpdump_detach}   gnb=${gnb}    alias=enb
# # #    sleep     3s
# # #    Cobham UE detach
# # #    sleep     5s
# # #    5GC000573_common_keyword.Stop wireshark capture from gNB or Enb          filename=${enb_tcpdump_detach}    gnb=${gnb}   alias=enb
# # #
# # #Detach UE and Stop iperf
# # #    run keyword and continue on failure      5GC000573_common_keyword.Kill iperf process on ue side for UL
# # #    run keyword and continue on failure     Kill iperf process on app server     port=${dl_port}
# # #    run keyword and continue on failure     Cobham UE detach
# # #    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=ute
# # #
# # #Check wireshark log data contain attach message with SRB3
# # #    [Arguments]   ${pacp_filename}    ${filter}    ${txt_filename}=attach_message.txt      ${connection}=ute
# # #    5GC000573_common_keyword.Connect to ENB with ssh    hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}
# # #    ...    password=${TEST_PC_PASSWORD}    alias=${connection}
# # #    sleep    1s
# # #    log to console    ${LOG_PATH}
# # #    log to console    ${pacp_filename}
# # #    5GC000573_common_keyword.Convert pcap to text   source=${LOG_PATH}/${pacp_filename}
# # #    ...  target=${LOG_PATH}/${txt_filename}   connection=${connection}    filter=${filter}
# # #    run keyword and continue on failure     5GC000573_common_keyword.Check wireshark log data contain message     mes
# ...sage='SgNBModificationRequire
# # d'
# # #    ...    txt_filename=${txt_filename}
# # #    run keyword and continue on failure     5GC000573_common_keyword.Check wireshark log data contain message     mes
# ...sage='SgNBModificationConfirm
# # '
# # #    ...    txt_filename=${txt_filename}
# # #
# # #Check interFreq_intergNB with A2 without_SRB3
# # #    [Arguments]   ${enb_tcpdump_attach}     ${enb_tcpdump_A2}    ${enb_tcpdump_A3}
# # #    ...         ${cell1_number}=${50}     ${cell2_number}=${51}     ${Check_event}=${eventA3}
# # #    run keyword and continue on failure    Check wireshark log data equal value      command=grep physCellId |cut -d ':' -f 2|awk 'END {print}'
# # #    ...     pacp_filename=${enb_tcpdump_attach}     txt_filename=physCellId1.txt    filter=${filter_physCellId}   check=${cell1_number}
# # #    #A2
# # #    ${meas_eventA2}      Get measId from wireshark log due to Event      pacp_filename=${enb_tcpdump_attach}
# # #    ...        txt_filename=measId1-1.txt    filter=${filter_physCellId}     Event=${eventA2}
# # #    ${measId1}      Get measId from wireshark log      command=grep measId |cut -d ':' -f 2|awk 'END {print}'
# # #    ...    pacp_filename=${enb_tcpdump_A2}     txt_filename=measId1-2.txt    filter=${filter_measurement}
# # #    run keyword and continue on failure    should be true     ${measId1}==${meas_eventA2}
# # #    Run Keyword And Continue On Failure     Check Add Event A1 and A3 event And Remove A2
# # #    ...    pacp_filename=${enb_tcpdump_A2}    txt_filename=measId1-3.txt     filter=${filter_modification_Ackonwledge}
# # #    ...    check_measid=${meas_eventA2}       Check_eventA3=${Check_event}
# # #    run keyword and continue on failure    Check wireshark log data not empty      command=grep 'gapPurpose: perUE (0)'
# # #    ...     pacp_filename=${enb_tcpdump_A2}     txt_filename=perUE.txt    filter=${filter_modification}
# # #    #A3
# # #    ${meas_eventA3}      Get measId from wireshark log due to Event      pacp_filename=${enb_tcpdump_A2}
# # #    ...        txt_filename=measId2-1.txt    filter=${filter_modification_Ackonwledge}    Event=${Check_event}
# # #    ${meas_eventA1}      Get measId from wireshark log due to Event      pacp_filename=${enb_tcpdump_A2}
# # #    ...        txt_filename=measId2-1.txt    filter=${filter_modification_Ackonwledge}    Event=${eventA1}
# # #    ${measId2}      Get measId from wireshark log      command=grep measId |cut -d ':' -f 2|awk 'END {print}'
# # #    ...    pacp_filename=${enb_tcpdump_A3}     txt_filename=measId2-2.txt    filter=${filter_measurement}
# # #    run keyword and continue on failure     Should Be True     ${measId2}==${meas_eventA3}
# # #    Run Keyword And Continue On Failure     Check Add Event A2 And Remove A1 and A3
# # #    ...    pacp_filename=${enb_tcpdump_A3}    txt_filename=measId2-3.txt      filter=${filter_physCellId}
# # #    ...    check_measid_A1=${meas_eventA1}   check_measid_A3=${meas_eventA3}
# # #    run keyword and continue on failure    Check wireshark log data equal value      command=grep physCellId |cut -d ':' -f 2|awk 'END {print}'
# # #    ...     pacp_filename=${enb_tcpdump_A3}     txt_filename=physCellId2.txt    filter=${filter_physCellId}   check=${cell2_number}
# # #   [Teardown]    run keyword and ignore error    csn.Disconnect    connection=ute
# # #
# # #Check interFreq_intergNB with A2 and A1 with SRB3
# # #    [Arguments]   ${enb_tcpdump_attach}     ${enb_tcpdump_A2}    ${gnb_tcpdump_A1}=tcpdump_1_A1_50-52.pcap
# # #    ...     ${gnb2_tcpdump_A5}=tcpdump_2_A5_50-52.pcap     ${cell1_number}=${50}     ${cell2_number}=${51}     ${Check_event}=${eventA3}
# # #    run keyword and continue on failure    Check wireshark log data equal value      command=grep physCellId |cut -d ':' -f 2|awk 'END {print}'
# # #    ...     pacp_filename=${enb_tcpdump_attach}     txt_filename=physCellId1.txt    filter=${filter_physCellId}   check=${cell1_number}
# # #    #A2
# # #    ${meas_eventA2}      Get measId from wireshark log due to Event      pacp_filename=${enb_tcpdump_attach}
# # #    ...        txt_filename=measId1-1.txt    filter=${filter_physCellId}     Event=${eventA2}
# # #    ${measId1}      Get measId from wireshark log      command=grep measId |cut -d ':' -f 2|awk 'END {print}'
# # #    ...    pacp_filename=${enb_tcpdump_A2}     txt_filename=measId1-2.txt    filter=${filter_measurement_005}
# # #    run keyword and continue on failure    should be true     ${measId1}==${meas_eventA2}
# # #    Run Keyword And Continue On Failure     Check Add Event A1 and A3 event And Remove A2
# # #    ...    pacp_filename=${enb_tcpdump_A2}    txt_filename=measId1-3.txt     filter=${filter_modification_Ackonwledge}
# # #    ...    check_measid=${meas_eventA2}       Check_eventA3=${Check_event}
# # #    run keyword and continue on failure    Check wireshark log data not empty      command=grep 'gapPurpose: perUE (0)'
# # #    ...     pacp_filename=${enb_tcpdump_A2}     txt_filename=perUE.txt    filter=${filter_modification}
# # #    #A3
# # #    ${meas_eventA3}      Get measId from wireshark log due to Event      pacp_filename=${enb_tcpdump_A2}
# # #    ...        txt_filename=measId2-1.txt    filter=${filter_modification_Ackonwledge}    Event=${Check_event}
# # #    ${meas_eventA1}      Get measId from wireshark log due to Event      pacp_filename=${enb_tcpdump_A2}
# # #    ...        txt_filename=measId2-1.txt    filter=${filter_modification_Ackonwledge}    Event=${eventA1}
# # #    ${measId2}      Get measId from wireshark log      command=grep measId |cut -d ':' -f 2|awk 'END {print}'
# # #    ...    pacp_filename=${gnb_tcpdump_A1}     txt_filename=measId2-2.txt    filter=${filter_measurement_005}
# # #    run keyword and continue on failure     Should Be True     ${measId2}==${meas_eventA1}
# # #    Run Keyword And Continue On Failure     Check Add Event A2 And Remove A1 and A3
# # #    ...    pacp_filename=${gnb_tcpdump_A1}    txt_filename=measId2-3.txt      filter=${filter_modification_Ackonwledge}
# # #    ...    check_measid_A1=${meas_eventA1}   check_measid_A3=${meas_eventA3}
# # #   [Teardown]    run keyword and ignore error    csn.Disconnect    connection=ute
# # #
# # #Check interFreq_intergNB with A2 without_SRB3 and A3 is rsrp
# # #    [Arguments]   ${enb_tcpdump_attach}     ${enb_tcpdump_A2}    ${enb_tcpdump_A3}
# # #    ...         ${cell1_number}=${50}     ${cell2_number}=${51}     ${Check_event}=${eventA3}
# # #    run keyword and continue on failure    Check wireshark log data equal value      command=grep physCellId |cut -d ':' -f 2|awk 'END {print}'
# # #    ...     pacp_filename=${enb_tcpdump_attach}     txt_filename=physCellId1.txt    filter=${filter_physCellId}   check=${cell1_number}
# # #    #A2
# # #    ${meas_eventA2}      Get measId from wireshark log due to Event      pacp_filename=${enb_tcpdump_attach}
# # #    ...        txt_filename=measId1-1.txt    filter=${filter_physCellId}     Event=${eventA2}
# # #    ${measId1}      Get measId from wireshark log      command=grep measId |cut -d ':' -f 2|awk 'END {print}'
# # #    ...    pacp_filename=${enb_tcpdump_A2}     txt_filename=measId1-2.txt    filter=${filter_measurement}
# # #    run keyword and continue on failure    should be true     ${measId1}==${meas_eventA2}
# # #    Run Keyword And Continue On Failure     Check Add Event A1 and A3 event And Remove A2
# # #    ...    pacp_filename=${enb_tcpdump_A2}    txt_filename=measId1-3.txt     filter=${filter_modification_Ackonwledge}
# # #    ...    check_measid=${meas_eventA2}       Check_eventA3=${Check_event}
# # #    run keyword and continue on failure    Check wireshark log data not empty      command=grep 'gapPurpose: perUE (0)'
# # #    ...     pacp_filename=${enb_tcpdump_A2}     txt_filename=perUE.txt    filter=${filter_modification}
# # #    #A3
# # #    ${measidA3}      Get measId from wireshark log due to Event due to rsrp      pacp_filename=${enb_tcpdump_A2}    Event=${eventA3}
# # #    ...        txt_filename=measId2-1.txt    filter=${filter_modification_Ackonwledge}     RsrporRsrq=${rsrp}
# # #    ${meas_eventA1}      Get measId from wireshark log due to Event      pacp_filename=${enb_tcpdump_A2}
# # #    ...        txt_filename=measId2-1.txt    filter=${filter_modification_Ackonwledge}    Event=${eventA1}
# # #    ${measId2}      Get measId from wireshark log      command=grep measId |cut -d ':' -f 2|awk 'END {print}'
# # #    ...    pacp_filename=${enb_tcpdump_A3}     txt_filename=measId2-2.txt    filter=${filter_measurement}
# # #    run keyword and continue on failure     Should Be True     ${measId2}==${measidA3}
# # #    Run Keyword And Continue On Failure     Check Add Event A2 And Remove A1 and A3
# # #    ...    pacp_filename=${enb_tcpdump_A3}    txt_filename=measId2-3.txt      filter=${filter_physCellId}
# # #    ...    check_measid_A1=${meas_eventA1}   check_measid_A3=${measidA3}
# # #    run keyword and continue on failure    Check wireshark log data equal value      command=grep physCellId |cut -d ':' -f 2|awk 'END {print}'
# # #    ...     pacp_filename=${enb_tcpdump_A3}     txt_filename=physCellId2.txt    filter=${filter_physCellId}   check=${cell2_number}
# # #   [Teardown]    run keyword and ignore error    csn.Disconnect    connection=ute
# # #
# # #Check interFreq_IntraGnb with A2 with SRB3
# # #    [Arguments]   ${enb_tcpdump_attach}     ${enb_tcpdump_A2}    ${enb_tcpdump_A3}
# # #    ...         ${cell1_number}=${50}     ${cell2_number}=${51}     ${Check_event}=${eventA3}
# # #    run keyword and continue on failure    Check wireshark log data equal value      command=grep physCellId |cut -d ':' -f 2|awk 'END {print}'
# # #    ...     pacp_filename=${enb_tcpdump_attach}     txt_filename=physCellId1.txt    filter=${filter_physCellId}   check=${cell1_number}
# # #    #A2
# # #    ${meas_eventA2}      Get measId from wireshark log due to Event      pacp_filename=${enb_tcpdump_attach}
# # #    ...        txt_filename=measId1-1.txt    filter=${filter_physCellId}     Event=${eventA2}
# # #    ${measId1}      Get measId from wireshark log      command=grep measId |cut -d ':' -f 2|awk 'END {print}'
# # #    ...    pacp_filename=${enb_tcpdump_A2}     txt_filename=measId1-2.txt    filter=${filter_measurement_005}
# # #    run keyword and continue on failure    should be true     ${measId1}==${meas_eventA2}
# # #    Run Keyword And Continue On Failure     Check Add Event A1 and A3 event And Remove A2
# # #    ...    pacp_filename=${enb_tcpdump_A2}    txt_filename=measId1-3.txt     filter=${filter_modification_Ackonwledge}
# # #    ...    check_measid=${meas_eventA2}       Check_eventA3=${Check_event}
# # #    run keyword and continue on failure    Check wireshark log data not empty      command=grep 'gapPurpose: perUE (0)'
# # #    ...     pacp_filename=${enb_tcpdump_A2}     txt_filename=perUE.txt    filter=${filter_modification}
# # #    #A3
# # #    ${meas_eventA3}      Get measId from wireshark log due to Event      pacp_filename=${enb_tcpdump_A2}
# # #    ...        txt_filename=measId2-1.txt    filter=${filter_modification_Ackonwledge}    Event=${Check_event}
# # #    ${meas_eventA1}      Get measId from wireshark log due to Event      pacp_filename=${enb_tcpdump_A2}
# # #    ...        txt_filename=measId2-1.txt    filter=${filter_modification_Ackonwledge}    Event=${eventA1}
# # #    ${measId2}      Get measId from wireshark log      command=grep measId |cut -d ':' -f 2|awk 'END {print}'
# # #    ...    pacp_filename=${enb_tcpdump_A3}     txt_filename=measId2-2.txt    filter=${filter_measurement_005}
# # #    run keyword and continue on failure     Should Be True     ${measId2}==${meas_eventA3}
# # #    Run Keyword And Continue On Failure     Check Add Event A2 And Remove A1 and A3
# # #    ...    pacp_filename=${enb_tcpdump_A3}    txt_filename=measId2-3.txt      filter=${filter_Reconfiguration}
# # #    ...    check_measid_A1=${meas_eventA1}   check_measid_A3=${meas_eventA3}
# # #    run keyword and continue on failure    Check wireshark log data equal value      command=grep physCellId |cut -d ':' -f 2|awk 'END {print}'
# # #    ...     pacp_filename=${enb_tcpdump_A3}     txt_filename=physCellId2.txt    filter=${filter_Reconfiguration}   check=${cell2_number}
# # #    run keyword and continue on failure    Check physCellId handover
# # #    run keyword and continue on failure    Check wireshark log data not empty      command=grep 'measGapConfig: release (0)'
# # #    ...     pacp_filename=tcpdump_1_A3_50-51.pcap     txt_filename=release.txt    filter=${filter_modification}
# # #    run keyword and continue on failure      Check wireshark log data contain attach message with SRB3
# # #    ...    pacp_filename=tcpdump_1_A3_50-51.pcap     filter=${filter_002_4}
# # #   [Teardown]    run keyword and ignore error    csn.Disconnect    connection=ute
# # #
# # #Check physCellId handover
# # #    run keyword and continue on failure    Check wireshark log data equal value      command=grep physCellId |cut -d ':' -f 2|awk 'END {print}'
# # #    ...     pacp_filename=tcpdump_1_A3_51-50.pcap    txt_filename=physCellId3.txt    filter=${filter_Reconfiguration}   check=${50}
# # #    run keyword and continue on failure    Check wireshark log data equal value      command=grep physCellId |cut -d ':' -f 2|awk 'END {print}'
# # #    ...     pacp_filename=tcpdump_2_A3_50-51.pcap    txt_filename=physCellId4.txt    filter=${filter_Reconfiguration}   check=${51}
# # #    run keyword and continue on failure    Check wireshark log data equal value      command=grep physCellId |cut -d ':' -f 2|awk 'END {print}'
# # #    ...     pacp_filename=tcpdump_2_A3_51-50.pcap    txt_filename=physCellId5.txt    filter=${filter_Reconfiguration}   check=${50}
# # #
# # #Check BTS counter result
# # #    Wait for counter to be gathered after guard peroid      interval=15
# # #    ${M55112C04501}    Check PM counter result    counter_id=M55112C04501
# # #    ${M55112C04502}    Check PM counter result    counter_id=M55112C04502
# # #    ${M55112C04503}    Check PM counter result    counter_id=M55112C04503
# # #    ${M55112C04501_sum}    Get length and Check sum counter value      list_input=${M55112C04501}
# # #    ${M55112C04502_sum}    Get length and Check sum counter value      list_input=${M55112C04502}
# # #    ${M55112C04503_sum}    Get length and Check sum counter value      list_input=${M55112C04503}
# # #    ${sum_counters}     Evaluate      ${M55112C04501_sum}+${M55112C04502_sum}
# # #    should not be equal as integers     ${sum_counters}     0
# # #    should be true    ${sum_counters}==${M55112C04503_sum}
# # #
# # #Get length and Check sum counter value
# # #    [Arguments]     ${list_input}
# # #    ${length}      Get Length       ${list_input}
# # #    ${counter_value_sum}       Set Variable          0
# # #    FOR   ${i}    IN RANGE    ${0}    ${length}     1
# # #        ${counter_value_sum}     Evaluate    ${counter_value_sum}+${list_input}[${i}]
# # #    END
# # #    [Return]   ${counter_value_sum}
# # #
# # #Case Teardown
# # #    run keyword and continue on failure     Cobham UE detach
# # #    run keyword and continue on failure     csn.Disconnect    connection=ute
# # #    run keyword and continue on failure     csn.Disconnect    connection=GNB_OAM
# # #    run keyword and continue on failure      5GC000573_common_keyword.Kill iperf process on ue side for UL
# # #    run keyword and continue on failure     Kill iperf process on app server     port=${dl_port}
# # #    CI_interface.Common Case Teardown
# # #
# # #Case Teardown for 2199-09
# # #    Modify ENB and GNB parameter for Two GNB
# # #    ...      GNB1_MODIFY_Parameter=${GNB1_MODIFY_Parameter_009_recover}     GNB2_MODIFY_Parameter=${GNB2_MODIFY_Parameter_009_recover}
# # #    Case Teardown