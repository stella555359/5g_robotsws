# # #*** Settings ***
# # #Force Tags    PY36
# # #Documentation     author: criscai
# # #...               contact: cris.cai@nokia-sbell.com
# # #...               squad group: SG_03
# # #...               feature : 5GC0002200-B
# # #
# # #Resource          ../5GC002481/Resources/5GC002481_common_keyword.robot
# # #Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
# # #
# # #Suite Setup       Run Keywords
# # #...               Run Keyword And Ignore Error    5GC002481_common_keyword.Check UE1 Exist    AND
# # #...               Run Keyword And Ignore Error    locked LTE cell    LNcell_id=${0}    AND
# # #...    Prepare gNB with cell on air status    gnb_index=${1}    2ndgnb_index=${0}    tl_scf_file_name=${tl_scf_file_name_gnb2}
# # #...    AND        Prepare gNB with cell on air status    gnb_index=${0}    2ndgnb_index=${1}    tl_scf_file_name=${tl_scf_file_name_gnb1}
# # #
# # #Suite Teardown    Run Keyword If Any Tests Failed    Run Keyword And Ignore Error
# # #...               5GC002481_common_keyword.Common Suite Teardown for COAM    gnb_index=${1}    2ndgnb_index=${0}
# # #
# # #*** Variables ***
# # #${epc_log_path}            /tmp/
# # #${tl_scf_dir_path}             /opt/workspace/CRT/Master/SCF_file/
# # #${tl_scf_file_name_gnb1}       golden_TDD.xml
# # #${tl_scf_file_name_gnb2}       golden_FDD.xml
# # #${interface}               any
# # #${dl_port}                 ${tl.ues[0].iperf_details.port}
# # #${ue_type}                 huawei
# # #${duration}                1500
# # #${gNB1_nglogname}          gNB1_2200.pcap
# # #${gNB2_nglogname}          gNB2_2200.pcap
# # #${gnb_path}                /tmp
# # #${tshark_path}             /usr/bin/tshark
# # #${asik1_addr}              ${tl.gnbs[0].cu.oam_http_connection_details.addr}
# # #${asik2_addr}              ${tl.gnbs[1].cu.oam_http_connection_details.addr}
# # #${dl_throughput}           100M
# # #${dl_expect_throughput}    10
# # #${command_template_with_Y}    {tshark_path} -r {pcap_file} -Y  \"f1ap\"  -T pdml
# # #
# # #*** Test Cases ***
# # #[1]5GC002200_B_025_Interworking_with_Intra_HO_when_feature_enable_with_1_resources_and_4_resource_NSA
# # #    [Documentation]    This user scenario describes the gNB behaviour with 2200, when a UE for which Inter-frequency A3
# # #    ...    measurements have been configured sends a Inter-frequency A3 measurement report and gNB
# # #    ...    performs handover based on the measurement report to a cell in the different gNB-DU with 2200 0n to off
# # #    ...    Note: "case title is just copyed from QC, actually the case is intergnb HO"
# # #    [Tags]    classical    5GC002200-B
# # #    [Setup]
# # ##    prepare InterFreq IntergNBHO
# # #    HBTE setting for trunk
# # #    Check intergNB HO process on wiresark
# # #    [Teardown]    run keyword and ignore error    Test recover
# # #
# # #*** Keywords ***
# # #Set nrcellid suit varaible
# # #    [Arguments]    ${cellid}    ${gnb_index}=${0}
# # #    ${nrcellid}    COAM Get nrcellid with the lcrid    lcrid=${cellid}    gnb_index=${gnb_index}
# # #    set suite variable    ${nrcellid}
# # #
# # #prepare InterFreq IntergNBHO
# # #    ${release_info}    Get sagnb release
# # #    set suite variable    ${release_info}
# # #    run keyword if    '${release_info}'=='5G21A_GNB_0011'    Topyoung setting for 21A
# # #    run keyword if    '${release_info}'=='SBTS22R1_ENB_0000'    Topyoung setting for 21A
# # #    run keyword if    '${release_info}'=='SBTS22R3_ENB_9999'    HBTE setting for trunk
# # #
# # #Get sagnb release
# # #    [Arguments]   ${host}=${asik_addr}   ${username}=${asik_username}   ${password}=${asik_password}
# # #    csn.Connect To   hostname=${host}   username=${username}   password=${password}   alias=release_info
# # #    ${info}   csn.Execute    command=ls /ffs/run/TargetBD*xml   connection=release_info
# # ##    ${release_info}     set variable    ${info.split('_')[1]}
# # #    ${release_info}    set variable    ${info.split('_')[1]}_${info.split('_')[2]}_${info.split('_')[3]}
# # #    [Return]    ${release_info}
# # #    [Teardown]   csn.Disconnect   connection=release_info
# # #
# # #Topyoung setting for 21A
# # #    5GC002481_common_keyword.Adjust eNB1_RU Attenuation to 120
# # #    5GC002481_common_keyword.Adjust gNB1_RU Attenuation to 5
# # #    5GC002481_common_keyword.Adjust gNB2_RU Attenuation to 14
# # #    sleep    10s
# # #    5GC002481_common_keyword.Prepare env with UEs
# # #    5GC002481_common_keyword.Start Capture Wireshark Logs on gNB    nglogname=${gNB1_nglogname}    interface=${interface}    gnb_index=${0}
# # #    5GC002481_common_keyword.786 UE attach    gnb_index=${0}    ue_index=${0}
# # #    #log to console    start traffic    ##print
# # #    sleep    10s
# # #    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_throughput}    duration=${duration}    ue_index=${0}
# # #    ...    iperf_port=${dl_port}
# # #    sleep    20s
# # #    power_ue.Check throughput    ue_type=${ue_type}    direction=dl
# # #    ...    throughput=${dl_expect_throughput}    gnb_index=${0}    #need enable swconfig flag
# # #    5GC002481_common_keyword.Adjust gNB2_RU Attenuation to 0
# # #    #5GC002481_common_keyword.Turn gNB1_TDDRU Attenuation to value    value=${10}
# # #    #5GC002481_common_keyword.Turn gNB1_TDDRU Attenuation to value    value=${15}
# # #    #5GC002481_common_keyword.Turn gNB1_TDDRU Attenuation to value    value=${20}
# # #    #5GC002481_common_keyword.Turn gNB1_TDDRU Attenuation to value    value=${25}
# # #    #Turn gNB1_TDDRU Attenuation to value
# # #    sleep    40s
# # #    power_ue.Check throughput    ue_type=${ue_type}    direction=dl
# # #    ...    throughput=${dl_expect_throughput}    gnb_index=${1}    ##second gnb still with traffic
# # #    5GC002481_common_keyword.Stop Capture Wireshark Logs on gNB    nglogname=${gNB1_nglogname}    gnb_index=${0}
# # #    [Teardown]    run keyword and ignore error     Test case recover
# # #
# # #HBTE setting for trunk
# # #    Set nrcellid suit varaible    cellid=1
# # #    5GC002481_common_keyword.Adjust eNB1_RU Attenuation to 120 for trunk  #120
# # #    5GC002481_common_keyword.Adjust gNB1_RU HBTE Attenuation to 5   #12910 55127127
# # #    5GC002481_common_keyword.Adjust gNB2_RU HBTE Attenuation to 127   #9101112 55 55 55 55
# # #    sleep    10s
# # #    5GC002481_common_keyword.Prepare env with UEs
# # #    5GC002481_common_keyword.Start Capture Wireshark Logs on gNB    nglogname=${gNB1_nglogname}    interface=${interface}    gnb_index=${0}
# # #    5GC002481_common_keyword.786 UE attach    gnb_index=${0}    ue_index=${0}  ##gnb1cell12200attachok
# # #    log to console    start traffic    ##print
# # #    sleep    30s
# # #    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_throughput}    duration=${duration}    ue_index=${0}
# # #    ...    iperf_port=${dl_port}
# # #    sleep    20s
# # #    power_ue.Check throughput    ue_type=${ue_type}    direction=dl
# # #    ...    throughput=${dl_expect_throughput}    gnb_index=${0}    cellid=${nrcellid}   #TP only around 13M may debug later, A: cellid
# # #    5GC002481_common_keyword.Adjust gNB1_RU HBTE Attenuation to 20
# # #    5GC002481_common_keyword.Adjust gNB2_RU HBTE Attenuation to 28
# # #    5GC002481_common_keyword.Adjust gNB2_RU HBTE Attenuation to 0   #9101112 5 5 5 5
# # #    #5GC002481_common_keyword.Adjust gNB1_RU HBTE Attenuation to 80    #12910 3535127127 to8080127127
# # #    sleep    40s
# # #    power_ue.Check throughput    ue_type=${ue_type}    direction=dl
# # #    ...    throughput=${dl_expect_throughput}    gnb_index=${1}    #target gnb still can check TP
# # #    5GC002481_common_keyword.Stop Capture Wireshark Logs on gNB    nglogname=${gNB1_nglogname}    gnb_index=${0}
# # #    [Teardown]    run keyword and ignore error     Test case recover
# # #
# # #Test case recover
# # #    5GC002481_common_keyword.Stop Capture Wireshark Logs on gNB    nglogname=${gNB1_nglogname}    gnb_index=${0}
# # #    power_ue.UE Detach    ue_type=huawei    ue_index=${0}
# # #    power_ue.UE Detach    ue_type=huawei    ue_index=${1}
# # #    run keyword and ignore error    coam.teardown    connection=gnb0
# # #    run keyword and ignore error    coam.teardown    connection=gnb1
# # #
# # #Test recover
# # #    run keyword and ignore error    5GC002481_common_keyword.Remove Xn Config
# # #    5GC002481_common_keyword.Adjust gNB1_RU HBTE Attenuation to 120
# # #    unlocked LTE cell     LNcell_id=${0}
# # #    power_ue.UE Detach    ue_type=huawei    ue_index=${0}
# # #    power_ue.UE Detach    ue_type=huawei    ue_index=${1}
# # #    5GC002481_common_keyword.Common Suite Teardown for COAM    gnb_index=${1}    2ndgnb_index=${0}
# # #    5GC002481_common_keyword.Common Suite Teardown for COAM    gnb_index=${0}    2ndgnb_index=${1}
# # #    run keyword and ignore error    coam.teardown    connection=gnb0
# # #    run keyword and ignore error    coam.teardown    connection=gnb1
# # #
# # #Check intergNB HO process on wiresark
# # #    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${gNB1_nglogname}    tshark_path=${tshark_path}
# # #    ...    command_template=${command_template_with_Y}
# # #    #${HO_req_filter}=     Catenate    xnap.procedureCode == 0 and ip.src == ${asik1_addr}   #这个是筛选条件,log没有也pass
# # #    #${HO_req_packets}=    parser.filter_packets_by_expression    filter_expression=${HO_req_filter}
# # #    #${HO_req}=     parser.get_field_value_by_xpath    pdml_list=${HO_req_packets}
# # #    #...                                                xpath=.//xnap.procedureCode    #上面的过滤出来后通过pdml筛选xpath得到值
# # #    #should contain    ${HO_req}    0
# # #    #${HO_res_filter}=     Catenate    xnap.procedureCode == 0 and ip.dst == ${asik1_addr}
# # #    #${HO_res_packets}=    parser.filter_packets_by_expression    filter_expression=${HO_res_filter}
# # #    #${HO_res}=     parser.get_field_value_by_xpath    pdml_list=${HO_res_packets}
# # #    #...                                                xpath=.//xnap.procedureCode
# # #    #should contain    ${HO_res}    0
# # #    ${filter_expression}=    Catenate
# # #    ...    f1ap.procedureCode == 12 && nr-rrc.eventId == 1 && nr-rrc.nrofPorts && nas_5gs.sm.message_type == 0xc2
# # #    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
# # #    ${nrofPorts}=    parser.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.nrofPorts
# # #    #should contain x times    ${nrofPorts}    3    4   ##huaweimate30proonlysupport2csirs 2represent 2ci
# # #    ${length}     get length    ${nrofPorts}
# # #    should contain any    int(${length})    2    4    6   ##huaweimate30proonlysupport2csirs 2represent 2ci 4 or 6ci
# # #    ${cdm_Type}=    parser.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.cdm_Type
# # #    should contain    ${cdm_Type}    2
# # #    ${density}=    parser.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.density
# # #    should contain    ${density}    1
# # #    ${n1-n2}=    parser.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.n1_n2
# # #    should contain    ${n1-n2}    1    #2_2
# # #    ${filter_expression}=    Catenate    f1ap.procedureCode == 7 and f1ap.F1AP_PDU == 0 and nr-rrc.criticalExtensions == 0
# # #    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
# # #    ${nrofPorts}=    parser.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.nrofPorts
# # #    should contain x times    ${nrofPorts}    1    1    #p2 value1 and 1times
# # #    ${cdm_Type}=    parser.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.cdm_Type
# # #    should contain    ${cdm_Type}    1    #fd-CDM2
# # #    ${density}=    parser.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.density
# # #    should contain    ${density}    1
# # #    ${SinglePanel_ri}=    parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
# # #    ...    xpath=.//nr-rrc.typeI_SinglePanel_ri_Restriction
# # #    should contain    ${SinglePanel_ri}    03    #11 two layer
