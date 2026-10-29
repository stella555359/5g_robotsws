*** Settings ***
Documentation
...    author: meng.yan
...    contact: meng.yan@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_2_SG
...    Feature CB007539_5GC002001

Library    String
Library    OperatingSystem
Library    Collections
Library    BuiltIn
Library    DateTime
Library    taf.transport.ssh    WITH NAME    csn
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    taf.rfrl.common_resources.python.ssh_common_commands    WITH NAME    ssh_common_commands
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/common/siso_cloud_coam_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/rrm_log_check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/container_log_capturing.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/operate_cell_and_check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Library    taf.collectors.l1l2bip    WITH NAME    l1l2bip
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library    taf.collectors.core    WITH NAME    core

*** Variables ***
${tmp_lua_dir}    /home/ute/wireshark/plugins/luashark.lua
${du_web_addr}    https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${host_addr}    ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${du_web_usr}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${du_web_pwd}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
${CU_addr}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${CU_username}    ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${CU_password}    ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${mcshark_log_dir}    /tmp/mcshark_log
${MIRROT_PATH}    /home/ute/MN/UTE/robotws/commissionings/HGZ/7_5_UTE5G402T159
${DU_PATH}       /usr/bin/
*** Keywords ***

#*********
SISO Coam Suite Setup for CLOUD UTE
    [Arguments]    ${enb_flag}=${True}    ${gnb_index}=0
    robot_common_operations.Common Suite Setup
    log to console    \n*** SISO Coam Suite Setup***
    run keyword and ignore error    clear vm pid before run case
    set suite variable    ${suite_setup_fail_flag}    ${True}
    run keyword if     ${if_commissioning}    CI_interface.Common Suite Setup    gnb_index=${gnb_index}
    ${connection}    set variable if    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${Active_SW_version}    Get Active SW Version    connection=${connection}
    set suite variable      ${Active_SW_version}
    ${Golden_SCF_Path}    Get Golden SCF Path    gnb_index=${gnb_index}
    set suite variable      ${Golden_SCF_Path}
    ${gNb_CuType}   Get gNB CU type    connection=${connection}
    set suite variable      ${gNb_CuType}
    run keyword if     ${if_update_swconfig}    update swconfig for gNB    connection=${connection}
    Generate suite log path
    set suite variable      ${SAVE LOG DIRECTORY}    ${SUITE_LOG_PATH}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ...    connection=${connection}    gnb_index=${gnb_index}
    ${scf_path}    Download SCF Download Via Rest Api    scf_dir_path=${SAVE LOG DIRECTORY}    connection=${connection}
    set suite variable    ${scf_path}
    ${mrbtsID}    ${nrbtsID}   Get mrbtsID and nrbtsID via SCF for gNB    scf_path=${scf_path}
    log to console  MRBTS_ID:${mrbtsID}, NRBTS_ID:${nrbtsID}
    set suite variable  ${mrbtsID}
    set suite variable  ${nrbtsID}
    run keyword if     '${ru_type_init}'=='AEQN'    remove fault 4687 from allowed fault list
    run keyword if     '${testline_name}' == 'null'    add fault to the allowed fault list    faultId=${4681}
    run keyword if    '${gNb_CuType}'=='NSA' and '${enb_flag}'=='${True}' or '${gNb_CuType}'=='SA+NSA' and '${enb_flag}'=='${True}'
    ...    Run Keyword And Ignore Error    get eNB active version
    set suite variable    ${suite_setup_fail_flag}    ${False}


Suite_Setup_5GC002001
    SISO Coam Suite Setup for CLOUD UTE    enb_flag=${False}
    log to console     Mcshark preparation
    # Mcshark preparation for bip analysis
    prepare mirror script for BIP collection

Suite_Teardown_5GC002001
    SISO Coam Suite Teardown

case_Teardown_5GC002001
    Log To Console    \n *** Case teardown
    Run Keyword And Ignore Error    delete file
    Run keyword and continue on failure    Step7: UE Detach    ${ue_index}
    Run Keyword And Ignore Error    Stop BIP Capture On ASOE
    robot_common_operations.Common Case Teardown


Set mute beams
    [Arguments]   ${beamsMuted}    ${connection}=COAM
    Conect to DU COAM   connection=${connection}
    ${dict_beamSet}=  create dictionary       basicBeamSet=beamSetFR2_6_6_4_2P
    ...                                       beamsMuted=${beamsMuted}
    ...                                       leftEdgeAngle=${90}
    ...                                       lowerEdgeAngle=${127}
    ...                                       rightEdgeAngle=${90}
    ...                                       upperEdgeAngle=${87}
    ${list_beamSet} =  create list  ${dict_beamSet}
    Change Configuration Parameter    dist_name=MRBTS-159/NRBTS-159/NRCELL-1
    ...    parameter=beamSet
    ...    value=${list_beamSet}
    ...    connection=${connection}

    [Teardown]    admin_cli.Teardown    connection=${connection}

Change Configuration Parameter
    [Arguments]    ${dist_name}
    ...            ${parameter}
    ...            ${value}
    ...            ${connection}=${connection}

    admin_cli.perform_parameter_recommissioning    dist_name=${dist_name}
    ...                                               parameter=${parameter}
    ...                                               operation=update
    ...                                               value=${value}
    ...                                               skip_parameter_relation_errors=True
    ...                                              connection=${connection}

TL159 Validate Ssb Exclusion
   # [Arguments]    ${bip_log_path}
    TL159 Connect to TestPC
    ${tshark_command}=    Catenate    tshark -r ${bip_log_path} -Y "dldata_ssblocksendreq"
    ...    -T fields -e DlData_SsBlockSendReq.SsBlockSendReq.slot
    ...    -e DlData_SsBlockSendReq.SsBlockSendReq.activeSsBlocks -e DlData_SsBlockSendReq.patternId.patternId_item_0
    ...    -e DlData_SsBlockSendReq.patternId.patternId_item_1 -e DlData_SsBlockSendReq.patternId.patternId_item_2
    ...    -e DlData_SsBlockSendReq.patternId.patternId_item_3 -X lua_script:/home/ute/generated_luashark/luashark.lua >
    ...    /home/ute/result
    csn.Execute    command=${tshark_command}    connection=TESTPC
    validate ssb blocks and pattern ids
    [Teardown]    csn.Disconnect    connection=TESTPC

TL159 Validate Ssb Exclusion1
   # [Arguments]    ${bip_log_path}
    TL159 Connect to TestPC
    ${tshark_command}=    Catenate    tshark -r ${bip_log_path} -Y "dldata_ssblocksendreq"
    ...    -T fields -e 3gpp.slot
    ...    -e DlData_SsBlockSendReq_t.activeSsBlocks
    #...    -e DlData_SsBlockSendReq_t.patternId_item -e DlData_SsBlockSendReq_t.patternId_item
    ...    -e DlData_SsBlockSendReq_t.patternId_item  > /home/ute/result
    csn.Execute    command=${tshark_command}    connection=TESTPC
    validate ssb blocks and pattern ids
    [Teardown]    csn.Disconnect    connection=TESTPC

Get current sw build version
    coam.connect to    bts_host=${host_addr}
    ${sw_info}=      coam.get_sw_version     connection=default
    ${sw_list}=    Split String    string=${sw_info}    separator=_
    ${status}    Run Keyword And Return Status    Should Be True    ${sw_list[2]}==9999
    ${sw_build_version}=    Run Keyword If    '${status}'=='True'
    ...    set variable    SBTS00_${sw_list[1]}_${sw_list[2]}_${sw_list[3]}_${sw_list[4]}
    ...    ELSE    set variable    ${sw_info}
    Set Suite Variable    ${sw_build_version}
    [Teardown]    coam.teardown    connection=default

Mcshark preparation for bip analysis1
    Get current sw build version
    ${wget_cmd}=    Set Variable
    ...    wget -r -np -nH https://artifactory-hz1.int.net.nokia.com/artifactory/mcshark-local/${sw_build_version}/
    Run    cd ${mcshark_log_dir};${wget_cmd}
    ${MCShark}=    Run    ls ${mcshark_log_dir}/artifactory/mcshark-local/${sw_build_version}/mcshark-3.6-*buster.so
    Run    sudo rm /usr/lib/x86_64-linux-gnu/wireshark/plugins/3.6/epan/mcshark-*buster.so
    Run    sudo cp ${MCShark} /usr/lib/x86_64-linux-gnu/wireshark/plugins/3.6/epan/

Mcshark preparation for bip analysis
    Get current sw build version
    ${wget_cmd}=    Set Variable
    ...    wget -r -np -nH https://artifactory-hz1.int.net.nokia.com/artifactory/mcshark-local/${sw_build_version}/
    Run    ${wget_cmd}
    ${MCShark}=    Run    ls artifactory/mcshark-local/${sw_build_version}/mcshark-3.6-*buster.so
    Run    sudo rm /usr/lib/x86_64-linux-gnu/wireshark/plugins/3.6/epan/mcshark-*buster.so
    Run    sudo cp ${MCShark} /usr/lib/x86_64-linux-gnu/wireshark/plugins/3.6/epan/

Connect to ASOE
    csn.connect_to    hostname=${CU_addr}    username=${CU_username}    password=${CU_password}    alias=ASOE

prepare mirror script for BIP collection
    ${scp_command}=    Set Variable    sshpass -p ${CU_password} scp ${MIRROT_PATH}/lfs-nw_switch-mirror-tool.sh ${CU_username}@${CU_addr}:${DU_PATH}
    Run    ${scp_command}
    Connect to ASOE
    ${status}=    csn.Execute    command=chmod 777 /usr/bin/lfs-nw_switch-mirror-tool.sh   connection=ASOE
    Run Keyword And Ignore Error    csn.Disconnect    connection=ASOE

mv file1
    TL159 Connect to TestPC
    ${tshark_command}=    Catenate    mv /home/ute/ym/logs/5GC002001/
    ...    [1]5GC002001_A_11_SSB_exclusion_on_the_cell_with_predefined_beamset_and_GoB_on_Air_SS_PBCH_Scheduling_FR2/
    ...    Genericl1l2bip/tcpdump.pcap /home/ute/ym
    csn.Execute    command=${tshark_command}    connection=TESTPC
    [Teardown]    csn.Disconnect    connection=TESTPC

mv file2
    TL159 Connect to TestPC
    ${tshark_command}=    Catenate    mv /home/ute/ym/logs/5GC002001/
    ...    [1]5GC002001_A_19_UE_operates_in_the_cell_with_excluded_SSB_Data_Transmission_check_single_cell_FR2/
    ...    Genericl1l2bip/tcpdump.pcap /home/ute/ym
    csn.Execute    command=${tshark_command}    connection=TESTPC
    [Teardown]    csn.Disconnect    connection=TESTPC

delete file
    TL159 Connect to TestPC
    ${tshark_command}=    Catenate    rm -rf /home/ute/ym/Genericl1l2bip/tcpdump.pcap
    csn.Execute    command=${tshark_command}    connection=TESTPC
    [Teardown]    csn.Disconnect    connection=TESTPC

TL159 Connect to TestPC
    [Documentation]  1.connect to testpc
    [Arguments]  ${hostname}=${tl.test_pc.default_ssh_connection_details.addr}
    ...    ${username}=${tl.test_pc.default_ssh_connection_details.username}
    ...    ${password}=${tl.test_pc.default_ssh_connection_details.password}    ${alias}=TESTPC
    ${connection}    csn.Connect to     hostname=${hostname}    username=${username}    password=${password}
    ...    alias=${alias}
    [Return]   ${connection}

TL159 Validate dldata pdschsendreq muted beams
    [Arguments]    ${muted_beams}
	#TL159 Connect to TestPC
	#${tshark_command}=    Catenate    tshark -r ${bip_log_path}
	#...    -Y "dldata_pdschsendreq"
    #...    -T fields -e DlData_PdschGrant.patternId_item
    #...    -X lua_script:/home/ute/generated_luashark/luashark.lua > /home/ute/result
    #csn.Execute    command=${tshark_command}    connection=TESTPC
    validate muted beams    ${muted_beams}
    [Teardown]    #csn.Disconnect    connection=TESTPC

TL159 Validate dldata pdcchsendreq muted beams
    [Arguments]    ${muted_beams}
	TL159 Connect to TestPC
    ${tshark_command}=    Catenate    tshark -r ${bip_log_path}
	...    -Y "dldata_pdcchsendreq" -T fields -e DlData_PdcchSendReq_t.beamId
    ...    -X lua_script:/home/ute/generated_luashark/luashark.lua > /home/ute/result
    csn.Execute    command=${tshark_command}    connection=TESTPC
    validate muted beams    ${muted_beams}
    [Teardown]    csn.Disconnect    connection=TESTPC

TL159 Validate uldata pucchreceivereq muted beams
    [Arguments]    ${muted_beams}
	TL159 Connect to TestPC
    ${tshark_command}=    Catenate    tshark -r ${bip_log_path}
	...    -Y "uldata_pucchreceivereq"
    ...    -T fields -e UlData_PucchReceiveReq.patternId.patternId_item_0
    ...    -X lua_script:/home/ute/generated_luashark/luashark.lua > /home/ute/result
    csn.Execute    command=${tshark_command}    connection=TESTPC
    validate muted beams    ${muted_beams}
    [Teardown]    csn.Disconnect    connection=TESTPC

TL159 Validate uldata puschreceivereq muted beams
    [Arguments]    ${muted_beams}
	TL159 Connect to TestPC
    ${tshark_command}=    Catenate    tshark -r ${bip_log_path}
    ...    -Y "uldata_puschreceivereq" -T fields -e UlData_PuschReceiveReq.patternId.patternId_item_0
    ...    -X lua_script:/home/ute/generated_luashark/luashark.lua > /home/ute/result
    csn.Execute    command=${tshark_command}    connection=TESTPC
    validate muted beams    ${muted_beams}
    [Teardown]    csn.Disconnect    connection=TESTPC

Conect to DU COAM
    [Arguments]    ${connection}=COAM
    admin_cli.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
                  ...      username=${WEBUI_USER}
                  ...      password=${WEBUI_PASSWORD}
                  ...      name=${connection}

2001_Check all cells status
    Connect to gnb coam via ssl
    All cells in specified cell group should be onair    cell_group=NRCELLGRP-0
    All cells in specified cell group should be Blocked    cell_group=NRCELLGRP-1
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections

All cells in specified cell group should be onair
    [Arguments]    ${cell_group}  ${connection}=GNB_OAM
    Log to console    Verify specified cells are on air
    ${cell_info}   coam.get_subcells_status   timeout=20    connection=${connection}
    ${cell_from_cellgrp}    Get from Dictionary    ${cell_info}    ${cell_group}
    All cells in cell group should be onair    ${cell_from_cellgrp}

All cells in specified cell group should be Blocked
    [Arguments]    ${cell_group}  ${connection}=GNB_OAM
    ${sw_version}     coam.get_sw_version    connection=${connection}
    ${result}    run keyword and return status    should contain any
    ...    ${sw_version}
    ...    12.400    14.400    22R1    22R2    21B
    ${Blocked}    Set Variable If    ${result}    blocked    Blocked
    ${disabled}    Set Variable If    ${result}    Disabled    disabled
    ${cell_info}   coam.get_subcells_status   timeout=20    connection=${connection}
    ${cell_from_cellgrp}    Get from Dictionary    ${cell_info}    ${cell_group}
    ${cell_list}    Get Dictionary Keys    ${cell_from_cellgrp}
    FOR  ${cell}  IN   @{cell_list}
        ${eachcell}    Get from Dictionary    ${cell_from_cellgrp}    ${cell}
        Run keyword and continue on failure    Should Be Equal As Strings    ${eachcell['NRCELL_R']['blockingState']}
        ...    ${Blocked}
        Run keyword and continue on failure    Should Be Equal As Strings    ${eachcell['NRCELL_R']['operationalState']}
        ...    ${disabled}
    END

   
  #******UE*****\
step1: Prepare UE
    [Documentation]    Author: zhao nana
    ...                This keyword is prepare UE
    [Arguments]    ${ue_index}=${0}
    log to console      step1: Prepare UE
    #power_ue.Prepare UE    ue_index=${ue_index}    ue_type=${ue_type}    ui_version=S21UI4.0
    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=${ue_type}

Step2: UE Attach
    [Documentation]    Author: zhao nana
    ...                This keyword is attach UE
    [Arguments]    ${ue_index}=${0}
    log to console      Step2: UE Attach
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${ue_type}    log_type=Aasyslog
    power_ue.Verify attach    ue_type=${ue_type}   5Grach_ed=${5Grach_ed_0}    4G_check=False
    #Preparation and execution for Commercial UE Attach    ue_index=${ue_index}
    #Log    click Airplane mode switch to disable its function so that make UE attach

Step3: Start traffic
    [Documentation]    Author: zhao nana
    ...                This keyword is start traffic
    [Arguments]   ${ul_throughput}=100M    ${dl_throughput}=50M    ${protocol}=udp    ${ue_index}=${0}
    log to console      Step5: Start traffic
    power_ue.Start traffic    ue_index=${ue_index}    direction=ul    throughput=${ul_throughput}    duration=1200
    ...    ue_type=${ue_type}
  	...    iperf_type=via_command
    ...    protocol=${protocol}
    sleep    1s
    power_ue.Start traffic    ue_index=${ue_index}    direction=dl    throughput=${dl_throughput}    duration=1200
    ...    ue_type=${ue_type}
  	...    protocol=${protocol}    buffer_size=1400B    process_num=${3}    seg_size=1350    window=16M
    sleep    2s

Step4: Check throughput
    [Documentation]    Author: zhao nana
    ...                This keyword is check troughput
    [Arguments]    ${traffic_time}=90s
    log to console      Step6: Check throughput
    Login via Web
    ${cell_number}    selenium_coam.get_number_of_cells
    Run Keyword And Ignore Error    Logout via Web
    AAsys log captrue    stop_aasys_flag=${False}
    sleep      ${traffic_time}
    ${cell_id}    Get nrcellid from aasys log
    ${dl_traffic_data}    ${ul_traffic_data}    Get traffic data from aasys log
    ${dl_peak_tp}    ${dl_average_tp}    ${dl_minimum_tp}    Calculate Throughput and retrun result in gnb
    ...    data=${dl_traffic_data}
    ...    cell_numbers=${cell_number}
    ${ul_peak_tp}    ${ul_average_tp}    ${ul_minimum_tp}    Calculate Throughput and retrun result in gnb
    ...    data=${ul_traffic_data}
    ...    cell_numbers=${cell_number}
    [Return]    ${dl_peak_tp}    ${dl_average_tp}    ${dl_minimum_tp}    ${ul_peak_tp}    ${ul_average_tp}
    ...    ${ul_minimum_tp}


Step6: Stop traffic
    [Documentation]    Author: zhao nana
    ...                This keyword is Stop traffic
    [Arguments]    ${ue_index}=${0}
    log to console      Step7: Stop traffic
    power_ue.Stop traffic    direction=ul    ue_index=${ue_index}    ue_type=${ue_type}    iperf_type=via_command
    power_ue.Stop traffic    direction=dl    ue_index=${ue_index}    ue_type=${ue_type}

Step7: UE Detach
    [Documentation]    Author: zhao nana
    ...                This keyword is UE Detach
    [Arguments]    ${ue_index}=${0}
    log to console      Step7: UE Detach
    power_ue.UE Detach    ue_index=${ue_index}    ue_type=${ue_type}

  #******BIP on ASOE(use in case)*****\

Collect BIP on ASOE
    [Arguments]    ${target_dir}
#Get L1_L2_UL and L1_L2_DL ABIO traffic to ASIB cpu
    ${asib}=  Create Dictionary
    ...    host=10.108.135.32
    ...    user=toor4nsn
    ...    password=oZPS0POrRieRtu
    tcpdump.create_tcpdump_collector
    ...    name=tcpdump
    ...    options=-v -i nac_eth2
    ...    executor=${asib}
    ${asib_commands}=    Create List
    ...    /usr/bin/lfs-nw_switch-mirror-tool.sh -S 1010 -f L1_L2_LOKIA_SNF -d 2
    ...    sleep 1
    ...    /usr/bin/lfs-nw_switch-mirror-tool.sh -L || echo avoid_non_zero_exit_code
    ...    sleep 1
   # ...    ncp_portmirror -p xgmac96 -r
   # ...    ncp_portmirror -d netdriver -p xgmac96
   l1l2bip.create_generic_l1l2bip_collector
    ...    name=Genericl1l2bip
    ...    collector=tcpdump
    ...    executor=${asib}
    ...    setup_commands=${asib_commands}
    core.setup_collectors    names=Genericl1l2bip
    core.start_collectors    names=Genericl1l2bip
    sleep    10s
    core.stop_collectors    names=Genericl1l2bip
    core.collect_collectors    names=Genericl1l2bip     target_dir=${target_dir}
    core.teardown_collectors    names=Genericl1l2bip

#******no use in case************
Start BIP Capture On ASOE
    [Documentation]    Start BIP Capture On ASOE.
    ...                Author: meng.yan
    ...                Contact: meng.yan@nokia-sbell.com
    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA.
    ...                :param timeout: bip captrue timeout in backgroud.'s'for seconds,'m' for minutes,'h'for hours or
    ...    'd'for days
    [Arguments]    ${gnb_index}=0    ${du_index}=0
    ...    ${host}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    csn.Connect To     hostname=${host}    username=${username}    password=${password}    alias=ASIK_Master
    csn.Execute    command=rm -rf /tmp/asod_bip_*.pcap*    connection=ASIK_Master
    ${status1}    csn.Execute    command=sh /usr/bin/lfs-nw_switch-mirror-tool.sh -S 1010 -f L1_L2_LOKIA_SNF -d 2
    ...    connection=ASIK_Master
    should contain    ${status1}      mirror_group=14 sport=1010 dport=2
    ${status2}    csn.Execute    command=sh /usr/bin/lfs-nw_switch-mirror-tool.sh -L  connection=ASIK_Master
    should contain    ${status2}       L1_L2_LOKIA_SNF 0
    ${output}    csn.execute    command=ps -ef | grep tcpdump | grep -v grep |awk '{print $2}' |xargs kill -9
    ...    connection=ASIK_Master
    #Should be empty    ${output}
    ${cmd}    Set Variable    tcpdump -i nac_eth2 -c 5000 -w /tmp/asod_bip_test.pcap
    #${cmd}=tcpdump -i nac_eth2 -w /tmp/asod_bip_test.pcap
    csn.send command    command=${cmd}    connection=ASIK_Master
    ${output}    csn.execute    command=ps -ef | grep tcpdump | grep -v grep | tail -n 1 |awk '{print $2}'
    ...    connection=ASIK_Master
    Should not be empty    ${output}
    [Teardown]   Run Keyword And Ignore Error    csn.disconnect    connection=ASIK_Master

Stop BIP Capture On ASOE
    [Documentation]    Stop BIP Capture On ASOE.
    ...                Author: meng.yan
    ...                Contact: meng.yan@nokia-sbell.com
    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA.
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${connection}=ASIK_Master
    ...    ${host}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    csn.Connect To     hostname=${host}    username=${username}    password=${password}    alias=ASIK_Master
    ${output}    csn.execute    command=ps -ef | grep tcpdump | grep -v grep | tail -n 1 |awk '{print $2}'
    ...    connection=ASIK_Master
    #${output}    csn.execute    command=ps -ef | grep tcpdump | grep -v grep |awk '{print $2}'    connection=ASIK_Master
    #Should not be empty    ${output}
    ${output}    csn.execute    command=ps -ef | grep tcpdump | grep -v grep | tail -n 1 |awk '{print $2}'|xargs kill -9
    ...    connection=ASIK_Master
    #Should be empty    ${output}
    [Teardown]   Run Keyword And Ignore Error    csn.disconnect    connection=ASIK_Master

Download ASOE BIP Logs To TestPC
    [Documentation]    Download ASOE BIP Logs To TestPC.
    ...                Author: meng.yan
    ...                Contact: meng.yan.rao@nokia-sbell.com
    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA.
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${connection}=ASIK_Master    ${log_path}=${output_dir}
    ...    ${sample}=1
    ...    ${host}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    csn.Connect To     hostname=${host}    username=${username}    password=${password}    alias=ASIK_Master
    ${list_log_path_local}    Create List
    ${files}    csn.execute    command=ls -l /tmp/asod_bip_*.pcap* |awk '{print $9}'    connection=ASIK_Master
    ${files}    Split To Lines    ${files}
    ${length}=    get length     ${files}
    FOR    ${i}    IN RANGE    0    ${length}    ${sample}
        csn.Download file    remote_path=${files[${i}]}    local_path=${log_path}/${files[${i}].split("/")[2]}
        ...    connection=ASIK_Master
        Append to list    ${list_log_path_local}    ${log_path}/${files[${i}].split("/")[2]}
    END
    FOR    ${file}    IN    @{files}
        csn.execute    command=rm -rf ${file}     connection=ASIK_Master
    END
    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK_Master
    [Return]    ${list_log_path_local}

BIP log capture and download_ASOE
    [Documentation]    BIP log capture and download,return the log path.
    ...                Author: shenrao
    ...                Contact: shengrong.rao@nokia-sbell.com
    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA.
    ...                :param file_size_mbytes: size of file create, tcpdump -C.
    ...                :param number_of_files: number of files created, tcpdump -W.
    ...                :param save_time_interval: The saving time interval of capture message.
    ...                :param filter: filter message by message id.E.G ether[0x18:2]==0x133 or ether[0x18:2]==0x249 or
    ...    ether[0x18:2]==0x135
    ...                :param sleep_time: capture bip log time, default is 30s
    ...                :param timeout: bip captrue timeout in backgroud.'s'for seconds,'m' for minutes,'h' for
    ...    hours,default is 15m
    [Arguments]    ${gnb_index}=0    ${du_index}=0
    #Precondition For ASOE Bip Capture    gnb_index=${gnb_index}    du_index=${du_index}
    Start BIP Capture On ASOE    gnb_index=${gnb_index}    du_index=${du_index}
    sleep    4s
    Stop BIP Capture On ASOE    gnb_index=${gnb_index}    du_index=${du_index}
    ${log_path}    Download ASOE BIP Logs To TestPC    gnb_index=${gnb_index}    du_index=${du_index}
    [Return]    ${log_path}

