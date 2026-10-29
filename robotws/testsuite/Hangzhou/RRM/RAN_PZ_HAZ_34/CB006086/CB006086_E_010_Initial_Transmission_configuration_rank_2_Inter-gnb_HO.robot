# # #*** Settings ***
# # #Force Tags    PY36
# # #Documentation
# # #...    author: Rebecca.Liu
# # #...    contact: jia-rebecca.liu@nokia-sbell.com
# # #...    squad group: SG_03
# # #...    feature : CB006086_E
# # #
# # #
# # #Suite Setup    Run Keyword And Ignore Error    Common Suite Setup for COAM 6086
# # #
# # #Suite Teardown    Run Keyword And Ignore Error    Common Suite Teardown for COAM 6086
# # #
# # #Resource      Resources/CB006086_coam_common_keywords.robot
# # #Variables     Resources/BTS_parameter.py
# # #Variables     Resources/Stream_parameter.py
# # #
# # #*** Variables ***
# # #${localFilePath}          /opt/workspace/swconfig/6086/swconfig.txt
# # #${tl_scf_filename_E010_gnb1}    SA_6086_E010_gnb1.xml     ##TL343,TL382,TL367, gnb2_scf
# # #${tl_scf_filename_E010_gnb2}    SA_6086_E010_gnb2.xml     ##TL343,TL382,TL367, gnb1_scf
# # #${dl_throughput}         50M
# # #${ul_throughput}         40M
# # #${Expect_DOWNLINK}       10
# # #${Expect_UPLINK}         2
# # #${Expect_DOWNLINK_1}       1
# # #${Expect_UPLINK_1}         1
# # #${S1log_E010_1}      6086_E010_S1_1.pcap
# # #${S1log_E010_2}      6086_E010_S1_2.pcap
# # #${S1log_E010_3}      6086_E010_S1_3.pcap
# # ##${logname_biplogE010_1}    6086_E010_Bip_1.pcap
# # ##${logname_biplogE010_2}    6086_E010_Bip_2.pcap
# # ##${logname_biplogE010_3}    6086_E010_Bip_3.pcap
# # #@{att_value_21A}      ${0}    ${120}    ${0}    ${45}    ${30}     #TL343
# # #@{att_value_trunk}    ${0}    ${120}    ${20}   ${55}              #TL382
# # #@{att_value_20B}      ${0}    ${120}    ${0}    ${50}              #TL367
# # ##${CMD_puschreceivereq}      {tshark_path} -r {input_file} -X lua_script:{luashark_path} -Y  \"uldata_puschreceivereq\" -T pdml > {output_file}
# # ##${f1ap}     {tshark_path} -r {input_file} -Y  \"f1ap\"  -T pdml > {output_file}
# # #${CMD_puschreceivereq}      {tshark_path} -r {pcap_file} -X lua_script:{luashark_path} -Y  \"uldata_puschreceivereq\" -T pdml
# # #${f1ap}     {tshark_path} -r {pcap_file} -Y  \"f1ap\"  -T pdml
# # ###PA
# # #${5GRU0_ANT9}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[0].port_no}    #int
# # #${5GRU0_ANT10}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[1].port_no}    #int
# # #${5GRU0_ANT11}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}    #int
# # #${5GRU0_ANT12}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}    #int
# # #@{PA_value}    ${35}    ${50}    ${30}    ${0}    #int list
# # #${att_ipaddr}               ${tl.attenuator[0].ip_addr}
# # #${att_api_port}             ${tl.attenuator[0].port}
# # #@{att_connection_port}      ${5GRU0_ANT9}    ${5GRU0_ANT10}     #int list
# # #${att_ipaddr2}               ${tl.attenuator[1].ip_addr}
# # #${att_api_port2}             ${tl.attenuator[1].port}
# # #@{att_connection_port2}      ${5GRU0_ANT11}    ${5GRU0_ANT12}     #int list
# # #${HBTE_max_value}           ${120}
# # #${vendor}                    ${tl.attenuator[0].vendor}
# # #
# # #${script_path}       /opt/workspace/CIT/Master/bip_scripts/
# # #${script_path_gnb2}       /opt/workspace/CIT/Master/bip_scripts_gnb2/
# # #*** Test Cases ***
# # #[1]CB006086_E_010_Initial_Transmission_configuration_rank_2_Inter-gnb_HO
# # #    [Documentation]
# # #    ...    This case verify UE initial Transmission configuration with inter-gNB HO with UL rank2.
# # #    [Tags]    9.1800    HUAWEI    classical     CRT_22R2
# # #    [Timeout]    1 hour
# # #    [Setup]     Case variable set for 6086_E010
# # #    run keyword if    '${release_info}' == 'SBTS22R1_ENB_0000'    Connect and Modify the parameter on enblte     dist_name=${enbcell_dist_TL343}
# # #    ...    parameter=administrativeState     value=locked
# # #    ...    ELSE    Connect and Modify the parameter on enblte     dist_name=${enbcell_dist}    parameter=administrativeState     value=locked
# # #    Adjust the attenuation value    value_1=@{${att_value}}[1]    value_2=@{${att_value}}[1]
# # #    RUN KEYWORD IF    '${release_info}' == 'SBTS22R1_ENB_0000'    Adjust the attenuation value gnb1Ru2
# # #    ...    value_1=@{${att_value}}[1]    value_2=@{${att_value}}[1]
# # #    Prepare SA GNB onair with scf and swconfig     localFilePath=${localFilePath}     tl_scf_dir_path=${scf_log_path}
# # #    ...        tl_scf_filename=${tl_scf_filename_E010_gnb1}    gnb_index=${${gnb_index_gnb1}}    bts_host=${${gnb_BTS_host_gnb1}}    #gnb2
# # #    Prepare SA GNB onair with scf and swconfig     localFilePath=${localFilePath}     tl_scf_dir_path=${scf_log_path}
# # #    ...        tl_scf_filename=${tl_scf_filename_E010_gnb2}    gnb_index=${${gnb_index_gnb2}}    bts_host=${${gnb_BTS_host_gnb2}}    #gnb1
# # #    Precondition for power UE    ue_type=huawei
# # #    wait until keyword succeeds    2min    10s    Start To Capture Wireshark Logs    filename=${S1log_E010_1}    connection=gnb    interface=any
# # #    ...    asik_addr=${${asib_addr_gnb2}}    asik_username=${asib_username}    asik_password=${asib_password}      #gnb1
# # #    Wait until keyword succeeds    4X    5s    Attach and check power UE    ue_type=huawei    4g_check=false     gnb_index=${${gnb_index_gnb2}}
# # #    Stop and download Logs    logname=${S1log_E010_1}    connection=gnb    asik_addr=${${asib_addr_gnb2}}    asik_username=${asib_username}
# # #    ...    asik_password=${asib_password}       #gnb1
# # #    Start power UE dlul traffic and check throughput    dl_throughput=${dl_throughput}    ul_throughput=${ul_throughput}
# # #    ...    Expect_DOWNLINK=${Expect_DOWNLINK}    Expect_UPLINK=${Expect_UPLINK}    gnb_index=${${gnb_index_gnb2}}       #gnb1
# # ##    Catch Bip log on ASIB    biplog=${logname_biplogE010_1}    bip_time=${1}    gnb_index=${${gnb_index_gnb2}}    hw_slot=${${hwslot}}    #gnb1
# # ##    run keyword if    '${release_info}' == 'SBTS21B_ENB_0000'    Catch Bip log on 21B    script_path=${script_path}
# # ##    ...    ELSE    Catch Bip log on trunk    script_path=${script_path}     #gnb1 cell1
# # #    Catch Bip log on trunk    script_path=${script_path}     #gnb1 cell1
# # #    ${logname_biplogE010_1}=    Download BIP Logs From ASIK To TestPC and rename it    log_path=${epc_log_path}
# # #    wait until keyword succeeds    2min    10s    Start To Capture Wireshark Logs    filename=${S1log_E010_2}    connection=gnb    interface=any
# # #    ...    asik_addr=${${asib_addr_gnb1}}    asik_username=${asib_username}    asik_password=${asib_password}       #gnb2
# # #    RUN KEYWORD IF    '${release_info}' == 'SBTS22R1_ENB_0000'    Adjust the attenuation value
# # #                                                                  ...     value_1=@{${att_value}}[2]    value_2=@{${att_value}}[2]
# # #    ...    ELSE    Adjust the attenuation value    value_1=@{${att_value}}[2]     value_2=@{${att_value}}[2]
# # #    sleep    2s
# # #    run keyword if    '${release_info}' == 'SBTS22R1_ENB_0000'    Lock gnb cell    parameters=${MODIFY_LOCKG_01}    bts_host=${gnb0_BTS_host}
# # #    Lock gnb cell     parameters=${${PARAMS_TO_MODIFY_LOCKG_gnb2}}    bts_host=${${block_BTS_host_gnb2}}      #lock gnb1
# # #    sleep    2s
# # #    RUN KEYWORD IF    '${release_info}' == 'SBTS22R2_ENB_0000'    Adjust the attenuation value
# # #                                                                  ...    value_1=@{${att_value}}[3]    value_2=@{${att_value}}[3]
# # #    sleep    2s
# # #    RUN KEYWORD IF    '${release_info}' == 'SBTS22R2_ENB_0000'    Adjust the attenuation value
# # #                                                                  ...    value_1=@{${att_value}}[0]    value_2=@{${att_value}}[0]
# # #    sleep    2s
# # #    Stop and download Logs    logname=${S1log_E010_2}    connection=gnb    asik_addr=${${asib_addr_gnb1}}    asik_username=${asib_username}
# # #    ...    asik_password=${asib_password}       #gnb2
# # ##    Catch Bip log on ASIB    biplog=${logname_biplogE010_2}    bip_time=${1}    gnb_index=${${gnb_index_gnb1}}    hw_slot=${${hwslot}}
# # ##    run keyword if    '${release_info}' == 'SBTS21B_ENB_0000'    Catch Bip log on 21B    script_path=${script_path}     gnb_index=${1}
# # ##    ...    ELSE    Catch Bip log on trunk    script_path=${script_path}     gnb_index=${1}    #gnb2 cell1
# # #    Catch Bip log on trunk    script_path=${script_path_gnb2}    gnb_index=${1}    #gnb2 cell1
# # #    ${logname_biplogE010_2}=    Download BIP Logs From ASIK To TestPC and rename it    log_path=${epc_log_path}
# # #    Check ul and dl throughput    Expect_DOWNLINK=${Expect_DOWNLINK_1}    Expect_UPLINK=${Expect_UPLINK_1}     gnb_index=${${gnb_index_gnb1}}
# # #    sleep    2s
# # #    Check ul and dl throughput    Expect_DOWNLINK=${Expect_DOWNLINK_1}    Expect_UPLINK=${Expect_UPLINK_1}     gnb_index=${${gnb_index_gnb1}}
# # #    sleep    2s
# # #    wait until keyword succeeds    2min    10s    Start To Capture Wireshark Logs    filename=${S1log_E010_3}    connection=gnb    interface=any
# # #    ...    asik_addr=${${asib_addr_gnb1}}    asik_username=${asib_username}    asik_password=${asib_password}        #gnb2
# # #    RUN KEYWORD IF    '${release_info}' == 'SBTS22R1_ENB_0000'    Adjust the attenuation value
# # #                                                                  ...    value_1=@{${att_value}}[3]    value_2=@{${att_value}}[3]
# # #    ...    ELSE    Adjust the attenuation value    value_1=@{${att_value}}[3]     value_2=@{${att_value}}[3]
# # #    sleep    2s
# # #    Stop and download Logs    logname=${S1log_E010_3}    connection=gnb    asik_addr=${${asib_addr_gnb1}}    asik_username=${asib_username}
# # #    ...    asik_password=${asib_password}            #gnb2
# # ##    Catch Bip log on ASIB    biplog=${logname_biplogE010_3}    bip_time=${1}    gnb_index=${${gnb_index_gnb1}}    hw_slot=${${hwslot}}
# # ##    run keyword if    '${release_info}' == 'SBTS21B_ENB_0000'    Catch Bip log on 21B    script_path=${script_path}     gnb_index=${1}
# # ##    ...    ELSE    Catch Bip log on trunk    script_path=${script_path}     gnb_index=${1}    #gnb2 cell1
# # #    Catch Bip log on trunk    script_path=${script_path_gnb2}    gnb_index=${1}    #gnb2 cell1
# # #    ${logname_biplogE010_3}=    Download BIP Logs From ASIK To TestPC and rename it    log_path=${epc_log_path}
# # #    Check ul and dl throughput    Expect_DOWNLINK=${Expect_DOWNLINK_1}    Expect_UPLINK=${Expect_UPLINK_1}    gnb_index=${${gnb_index_gnb1}}
# # #    sleep    2s
# # #    Run Keyword And Ignore Error    Stop power UE uldl traffic and detach    ue_type=huawei    dl_port=${DL_PORT}    ul_port=${UL_PORT}
# # ##    Download GNB port15 Logs ASIB     logname=${logname_biplogE010_1}     gnb_index=${${gnb_index_gnb2}}    hw_slot=${${hwslot}}
# # ##    Download GNB port15 Logs ASIB     logname=${logname_biplogE010_2}     gnb_index=${${gnb_index_gnb1}}    hw_slot=${${hwslot}}
# # ##    Download GNB port15 Logs ASIB     logname=${logname_biplogE010_3}     gnb_index=${${gnb_index_gnb1}}    hw_slot=${${hwslot}}
# # #    Analysis S1AP log_E010_1
# # #    Analysis S1AP log_E010_2
# # #    Analysis S1AP log_E010_3
# # #    Analysis BIP biplogE010_1 trunk    BIP_log=${logname_biplogE010_1[0]}
# # #    Analysis BIP biplogE010_2 trunk    BIP_log=${logname_biplogE010_2[0]}
# # #    Analysis BIP biplogE010_3 trunk    BIP_log=${logname_biplogE010_3[0]}
# # ###    run keyword if    '${release_info}' == 'SBTS22R1_ENB_0000'     Analysis BIP biplogE010_1
# # ###    ...     ELSE     Analysis BIP biplogE010_1 trunk
# # ###    run keyword if    '${release_info}' == 'SBTS22R1_ENB_0000'    Analysis BIP biplogE010_2
# # ###    ...     ELSE     Analysis BIP biplogE010_2 trunk
# # ###    run keyword if    '${release_info}' == 'SBTS22R1_ENB_0000'    Analysis BIP biplogE010_3
# # ###    ...     ELSE     Analysis BIP biplogE010_3 trunk
# # #    [Teardown]    Run Keyword And Ignore Error    Tests Recover E010 fit trunk
# # #
# # #
# # #*** Keywords ***
# # #Catch Bip log on 21B
# # #    [Arguments]    ${script_path}    ${capturing_time_seconds}=3    ${gnb_index}=${0}
# # #    Connect to Classical Common Unit Master gnb    gnb_index=${gnb_index}
# # #    Precondition for bip capture with gnbMirroring scripts    script_path=${script_path}
# # #    Bip Capture with gnbMirroring scripts 1856 21B    gnb_index=${gnb_index}    capturing_time_seconds=${capturing_time_seconds}
# # #
# # #Catch Bip log on trunk
# # #    [Arguments]    ${script_path}    ${capturing_time_seconds}=3    ${gnb_index}=${0}
# # #    Connect to Classical Common Unit Master gnb    gnb_index=${gnb_index}
# # #    Precondition for bip capture with gnbMirroring scripts    script_path=${script_path}
# # #    Bip Capture with gnbMirroring scripts 1856    gnb_index=${gnb_index}    capturing_time_seconds=${capturing_time_seconds}
# # #
# # #Bip Capture with gnbMirroring scripts 1856
# # #    [Arguments]    ${gnb_index}=${0}    ${connection}=ASIK Master    ${gnb_mirroring}=gnbMirroring.sh
# # #    ...            ${capturing_time_seconds}=infinite
# # #    Connect to Classical Common Unit Master gnb    gnb_index=${gnb_index}
# # #    ${cmd_local}    catenate    sh /ffs/run/config/scripts/${gnb_mirroring} --capturing_time_seconds=${capturing_time_seconds}
# # #    csn.send_command    command=${cmd_local}    connection=${connection}
# # ##    csn.send_command
# # ##    ...    command=cd ${AT_script_path} && python ATcommand.py -p com${COM_port} -c "${command}"
# # ##    ...    connection=cygwin${ue_index}
# # #    ${output}    csn.Read Output    connection=${connection}
# # #    sleep    3s
# # #    should contain    ${output}    Dump files in /tmp/ folder
# # #
# # #Bip Capture with gnbMirroring scripts 1856 21B
# # #    [Arguments]    ${gnb_index}=${0}    ${connection}=ASIK Master    ${gnb_mirroring}=gnbMirroring.sh
# # #    ...            ${capturing_time_seconds}=infinite
# # #    Connect to Classical Common Unit Master gnb    gnb_index=${gnb_index}
# # #    ${cmd_local}    catenate    sh /ffs/run/config/scripts/${gnb_mirroring} --capturing_time_seconds=${capturing_time_seconds}
# # #    csn.send_command    command=${cmd_local}    connection=${connection}
# # ##    csn.send_command
# # ##    ...    command=cd ${AT_script_path} && python ATcommand.py -p com${COM_port} -c "${command}"
# # ##    ...    connection=cygwin${ue_index}
# # #    ${output}    csn.Read Output    connection=${connection}
# # #    sleep    3s
# # #    should contain    ${output}    pcap0
# # #
# # #Analysis S1AP log_E010_1
# # #    ${all_packets}=    CAP.load_pcap_file    pcap_file=${epc_log_path}${S1log_E010_1}    tshark_path=${tshark_path}
# # #    ...    command_template=${f1ap}    alias=test6
# # #    ${filter_expression}=    Catenate    (nr-rrc.pusch_Config == 1) && (f1ap.procedureCode == 8)
# # #    ${filtered_packets}=    CAP.filter_packets_by_expression    filter_expression=${filter_expression}    pcap_parser=test6
# # #    ${maxrank}=    CAP.get_field_value_by_xpath    xpath=.//nr-rrc.maxRank    pcap_parser=test6
# # #    Should contain any    ${maxrank}    1    2
# # #    ${nrofSRS-Ports}=    CAP.get_field_value_by_xpath    xpath=.//nr-rrc.nrofSRS_Ports    pcap_parser=test6
# # #    Should contain any    ${nrofSRS-Ports}    0    1
# # #
# # #Analysis S1AP log_E010_2
# # #    ${all_packets}=    CAP.load_pcap_file    pcap_file=${epc_log_path}${S1log_E010_2}    tshark_path=${tshark_path}
# # #    ...    command_template=${f1ap}    alias=test6
# # #    ${filter_expression}=    Catenate    nr-rrc.pusch_Config == 1
# # #    ${filtered_packets}=    CAP.filter_packets_by_expression    filter_expression=${filter_expression}    pcap_parser=test6
# # #    ${maxrank}=    CAP.get_field_value_by_xpath    xpath=.//nr-rrc.maxRank    pcap_parser=test6
# # #    Should contain    ${maxrank}    2
# # #    ${nrofSRS-Ports}=    CAP.get_field_value_by_xpath    xpath=.//nr-rrc.nrofSRS_Ports    pcap_parser=test6
# # #    Should contain    ${nrofSRS-Ports}    1
# # #
# # #Analysis S1AP log_E010_3
# # #    ${all_packets}=    CAP.load_pcap_file    pcap_file=${epc_log_path}${S1log_E010_3}    tshark_path=${tshark_path}
# # #    ...   command_template=${f1ap}    alias=test6
# # #    ${filter_expression}=    Catenate    (nr-rrc.pusch_Config == 1) && (f1ap.procedureCode == 8)
# # #    ${filtered_packets}=    CAP.filter_packets_by_expression    filter_expression=${filter_expression}    pcap_parser=test6
# # #    ${maxrank}=    CAP.get_field_value_by_xpath    xpath=.//nr-rrc.maxRank    pcap_parser=test6
# # #    Should contain    ${maxrank}    1
# # #    ${nrofSRS-Ports}=    CAP.get_field_value_by_xpath    xpath=.//nr-rrc.nrofSRS_Ports    pcap_parser=test6
# # #    Should contain    ${nrofSRS-Ports}    0
# # #
# # #Analysis BIP biplogE010_1
# # #    ${all_packets}=    CAP.load_pcap_file    pcap_file=${epc_log_path}${logname_biplogE010_1}    tshark_path=${tshark_path}
# # #    ...    luashark_path=${LUA_SCRIPT_PATH}    command_template=${CMD_puschreceivereq}    alias=test6
# # #    ${filter_expression}=    Catenate    uldata_puschreceivereq
# # #    ${filtered_packets}=    CAP.filter_packets_by_expression    filter_expression=${filter_expression}    pcap_parser=test6
# # #    ${numOfLayers}=    CAP.get_field_value_by_xpath    xpath=.//UlData_PuschReceiveReq.grants_item_15.numOfLayers    pcap_parser=test6
# # #    should contain any    ${numOfLayers}    0x00000002    0x00000001
# # #
# # #Analysis BIP biplogE010_1 trunk
# # #    [Arguments]     ${BIP_log}
# # ##    ${all_packets}=    CAP.load_pcap_file    pcap_file=${epc_log_path}${logname_biplogE010_1}    tshark_path=${tshark_path}
# # ##    ...    luashark_path=${LUA_SCRIPT_PATH}    command_template=${CMD_puschreceivereq}
# # #    ${all_packets}=    CAP.load_pcap_file    pcap_file=${BIP_log}    tshark_path=${tshark_path}
# # #    ...    luashark_path=${LUA_SCRIPT_PATH}    command_template=${CMD_puschreceivereq}    alias=test6
# # #
# # #
# # #    ${filter_expression}=    Catenate    uldata_puschreceivereq
# # #    ${filtered_packets}=    CAP.filter_packets_by_expression    filter_expression=${filter_expression}    pcap_parser=test6
# # #    ${numOfLayers}=    CAP.get_field_value_by_xpath    xpath=.//UlData_PuschReceiveReq.grants_item_0.numOfLayers    pcap_parser=test6
# # #    should contain    ${numOfLayers}    0x00000002
# # #
# # #Analysis BIP biplogE010_2
# # #    ${all_packets}=    CAP.load_pcap_file    pcap_file=${epc_log_path}${logname_biplogE010_2}    tshark_path=${tshark_path}
# # #    ...    luashark_path=${LUA_SCRIPT_PATH}    command_template=${CMD_puschreceivereq}    alias=test6
# # #    ${filter_expression}=    Catenate    uldata_puschreceivereq
# # #    ${filtered_packets}=    CAP.filter_packets_by_expression    filter_expression=${filter_expression}    pcap_parser=test6
# # #    ${numOfLayers}=    CAP.get_field_value_by_xpath    xpath=.//UlData_PuschReceiveReq.grants_item_15.numOfLayers    pcap_parser=test6
# # #    should contain    ${numOfLayers}    0x00000002
# # #
# # #Analysis BIP biplogE010_2 trunk
# # #    [Arguments]     ${BIP_log}
# # ##    ${all_packets}=    CAP.load_pcap_file    pcap_file=${epc_log_path}${logname_biplogE010_2}    tshark_path=${tshark_path}
# # ##    ...    luashark_path=${LUA_SCRIPT_PATH}    command_template=${CMD_puschreceivereq}
# # #    ${all_packets}=    CAP.load_pcap_file    pcap_file=${BIP_log}    tshark_path=${tshark_path}
# # #    ...    luashark_path=${LUA_SCRIPT_PATH}    command_template=${CMD_puschreceivereq}    alias=test6
# # #    ${filter_expression}=    Catenate    uldata_puschreceivereq
# # #    ${filtered_packets}=    CAP.filter_packets_by_expression    filter_expression=${filter_expression}    pcap_parser=test6
# # #    ${numOfLayers}=    CAP.get_field_value_by_xpath    xpath=.//UlData_PuschReceiveReq.grants_item_0.numOfLayers    pcap_parser=test6
# # #    should contain    ${numOfLayers}    0x00000002
# # #
# # #Analysis BIP biplogE010_3
# # #    ${all_packets}=    CAP.load_pcap_file    pcap_file=${epc_log_path}${logname_biplogE010_3}    tshark_path=${tshark_path}
# # #    ...    luashark_path=${LUA_SCRIPT_PATH}    command_template=${CMD_puschreceivereq}    alias=test6
# # #    ${filter_expression}=    Catenate    uldata_puschreceivereq
# # #    ${filtered_packets}=    CAP.filter_packets_by_expression    filter_expression=${filter_expression}    pcap_parser=test6
# # #    ${numOfLayers}=    CAP.get_field_value_by_xpath    xpath=.//UlData_PuschReceiveReq.grants_item_15.numOfLayers    pcap_parser=test6
# # #    should contain    ${numOfLayers}    0x00000001
# # #
# # #Analysis BIP biplogE010_3 trunk
# # #    [Arguments]     ${BIP_log}
# # ##    ${all_packets}=    CAP.load_pcap_file    pcap_file=${epc_log_path}${logname_biplogE010_3}    tshark_path=${tshark_path}
# # ##    ...    luashark_path=${LUA_SCRIPT_PATH}    command_template=${CMD_puschreceivereq}
# # #    ${all_packets}=    CAP.load_pcap_file    pcap_file=${BIP_log}    tshark_path=${tshark_path}
# # #    ...    luashark_path=${LUA_SCRIPT_PATH}    command_template=${CMD_puschreceivereq}    alias=test6
# # #    ${filter_expression}=    Catenate    uldata_puschreceivereq
# # #    ${filtered_packets}=    CAP.filter_packets_by_expression    filter_expression=${filter_expression}    pcap_parser=test6
# # #    ${numOfLayers}=    CAP.get_field_value_by_xpath    xpath=.//UlData_PuschReceiveReq.grants_item_0.numOfLayers    pcap_parser=test6
# # #    should contain    ${numOfLayers}    0x00000001
# # #
# # #Tests Recover E010 fit trunk
# # #    [Arguments]
# # #    Adjust the attenuation value    value_1=@{${att_value}}[0]    value_2=@{${att_value}}[0]
# # #    RUN KEYWORD IF    '${release_info}' == 'SBTS22R1_ENB_0000'    Adjust the attenuation value gnb1Ru2
# # #    ...    value_1=@{${att_value}}[4]    value_2=@{${att_value}}[4]
# # #    Lock gnb cell     parameters=${${PARAMS_TO_MODIFY_UNLOCKG_gnb2}}    bts_host=${${block_BTS_host_gnb2}}
# # #    ...    username=${gnb_BTS_username}    password=${gnb_BTS_password}
# # #    Lock gnb cell     parameters=${${PARAMS_TO_MODIFY_UNLOCKG_gnb1}}    bts_host=${${block_BTS_host_gnb1}}
# # #    ...    username=${gnb_BTS_username}    password=${gnb_BTS_password}
# # #    run keyword if    '${release_info}' == 'SBTS22R1_ENB_0000'    Lock gnb cell    parameters=${MODIFY_UNLOCKG_01}    bts_host=${gnb0_BTS_host}
# # #    Stop wireshark Logs teardown     connection=gnb    asik_addr=${${asib_addr_gnb1}}    asik_username=${asib_username}
# # #    ...    asik_password=${asib_password}
# # #    Stop wireshark Logs teardown     connection=gnb    asik_addr=${${asib_addr_gnb2}}    asik_username=${asib_username}
# # #    ...    asik_password=${asib_password}
# # #    run keyword if    '${release_info}' == 'SBTS22R1_ENB_0000'    Connect and Modify the parameter on enblte     dist_name=${enbcell_dist_TL343}
# # #    ...    parameter=administrativeState     value=unlocked
# # #    ...    ELSE    Connect and Modify the parameter on enblte     dist_name=${enbcell_dist}    parameter=administrativeState     value=unlocked
# # #    sleep     5s
# # #    Connect to EPC APP
# # #    Get product brand
# # #    Stop power UE uldl traffic and detach    ue_type=huawei    dl_port=${DL_PORT}    ul_port=${UL_PORT}
# # #    sleep     3s
# # #    disconect all connections
# # #
# # ###PA##
# # #Adjust the attenuation value
# # #    [Arguments]      ${value_1}=${value_1}    ${value_2}=${value_2}
# # #    [Documentation]    Auther:cris.cai@nokia-sbell.com
# # #    ...                modify HBTE PA 4 port value default value[0-63db] if not set the max_attenuation value below
# # #    ...                for value and not default port 1234, plz set in your case level. setup connection only port1
# # #    ...                if connect on local plz disconnect firstly
# # #    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
# # #    ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${HBTE_max_value}    vendor=${vendor}
# # #    att.set_attenuation     port=${5GRU0_ANT9}    value=${value_1}
# # #    att.set_attenuation     port=${5GRU0_ANT10}    value=${value_1}
# # #    ${value_port1}    att.read_attenuation    port=${5GRU0_ANT9}
# # #    should be equal    ${value_port1}    ${value_1}
# # #    ${value_port2}    att.read_attenuation    port=${5GRU0_ANT10}
# # #    should be equal    ${value_port2}    ${value_1}
# # #
# # #Adjust the attenuation value gnb1Ru2
# # #    [Arguments]      ${value_1}=${value_1}    ${value_2}=${value_2}
# # #    [Documentation]    Auther:cris.cai@nokia-sbell.com
# # #    ...                modify HBTE PA 4 port value default value[0-63db] if not set the max_attenuation value below
# # #    ...                for value and not default port 1234, plz set in your case level. setup connection only port1
# # #    ...                if connect on local plz disconnect firstly
# # #    att.setup_attenuator    ip_addr=${att_ipaddr2}    port=${att_api_port2}
# # #    ...    attenuation_port_numbers=${att_connection_port2}    max_attenuation=${HBTE_max_value}    vendor=${vendor}
# # #    att.set_attenuation     port=${5GRU0_ANT11}    value=${value_1}
# # #    att.set_attenuation     port=${5GRU0_ANT12}    value=${value_1}
# # #    ${value_port1}    att.read_attenuation    port=${5GRU0_ANT11}
# # #    should be equal    ${value_port1}    ${value_1}
# # #    ${value_port2}    att.read_attenuation    port=${5GRU0_ANT12}
# # #    should be equal    ${value_port2}    ${value_1}
