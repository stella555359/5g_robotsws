*** Settings ***
Documentation    ...
#Resource    ./5GC002329_resource.robot
#Resource    ./../CUDU_L2/common_setup_teardown.robot
#Resource    ./../CUDU_L2/common_dss_command.robot
#Suite Setup    Common Suite Setup
#Test Setup    Common Test Setup 2
#Test Teardown    Common Test Teardown 2
#Suite Teardown    Common Suite Teardown 2
#Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    SBTS00    SBTS23R1    SBTS22R4    alice_chen    CN1_SQ
#...                RAN_5G    RAN_5G_TDD    CRT
#*** Variables ***
#${UE_ID}               1
#${PROFILE_ID}          1
#${GNB_ID}              2
#${CELL_ID}             1
#${BEARER_ID}           2
#${SCF_PATH}    ${CURDIR}/config
#${LOCAL_WTS_DIR}    ${CURDIR}/config
#${ALLOC_SUBFRAME_10M_20M_50_50}    0010000010-0111001110-0011001110-0111000110-0011001010-0111001000-0010000000-0110000110
#${iphy}    ${LOCAL_WTS_DIR}/iphy_DSS.xml
#${WTS_AP_XML}    DSS.xml
#${WTS_CFG}    basic_wts_dss.cfg
#${wts_lua_cfg}    ${LOCAL_WTS_DIR}/${WTS_CFG}
#${wts_ap_config}    ${LOCAL_WTS_DIR}/DSS.xml
#${2329_scf}    ${LOCAL_WTS_DIR}/SCF_DSS.xml
#${WTS_DIR}    /opt/iphy/latest
#*** Test Cases ***
#5GC002329-ET-ACB1002-Verify FR1 TDD + FDD DL CA interworking with DSS with A1 Scell addition
#    Start UTE WTS FOR DSS
#    Log To Console    ${WTS_CFG}
#    Load Cfg File    ${WTS_CFG}
#    Setup XP    ${ALLOC_SUBFRAME_10M_20M_50_50}    1,50    30    70    30    70
#    Attach SA UE and Get Throughput    UE_ID=${UE_ID}    dl_tp_set=175    ul_tp_set=175    dl_tp_threshold=50    ul_tp_threshold=10
#
#*** Keywords ***
#Common Suite Setup
#    Suite Setup Update GNB    log=${False}
#    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    Modify IPHY File And Send to Airphone    ${iphy}
#    Full Commission With SCF File    ${2329_scf}
#    Reboot TL And Check Configured
#    Get All Testline Information And Set Suite Variable
#    Modify UTE SCTP Timeout
#    Modify AP SCTP Timeout
#    Configure UTE ETH3 For DSS CA
#
#Attach SA UE and Get Throughput
#    [Arguments]    ${UE_ID}=1    ${dl_tp_set}=175    ${ul_tp_set}=175    ${dl_tp_threshold}=100    ${ul_tp_threshold}=20
#    SA 5G Attach    ue_id=${UE_ID}
#    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
#    SA 5G PDU Session Setup    ue_id=${UE_ID}
#    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=2
#    SA Start UL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${ul_tp_set}    trf_id=1
#    ${dl_tp}=    SA Get UE Average Traffic Internal    ue_id=${UE_ID}    pdu_id=1    dir=dl
#    ${ul_tp}=    SA Get UE Average Traffic Internal    ue_id=${UE_ID}    pdu_id=1    dir=ul
#    log    DL Troughput is ${dl_tp}    console=True
#    log    UL Troughput is ${ul_tp}    console=True
#    SA Stop Data Traffic Internal    ${UE_ID}    pdu_id=1
#    [Teardown]    SA 5G Detach    ue_id=${UE_ID}
#
#Setup XP
#    [Arguments]    ${nor_subframe}    ${prb_list}    ${min_dss_ratio}    ${max_dss_ratio}    ${min_prb_ratio}=30    ${max_prb_ratio}=70
#    Setup XP LINK
#    Set LTE NR DSS Mode
#    Setup CA DSS Link
#    Set DL RESOURCE Cell Reservation    ${min_dss_ratio}    ${max_dss_ratio}
#    CA Cell Resource Coordination
#    CA UL Resource Cell Reservation    ${min_prb_ratio}    ${max_prb_ratio}
#    CA Cell Allocation    nor_subframe=${nor_subframe}    prb_list=${prb_list}
#
#Load Cfg File
#    [Arguments]    ${cfg_file}
#    Log To Console    ${cfg_file}
#    ute_wtssim.Execute Egate Command    cfg file\=${cfg_file}    pass_regexp=NG link is Up    timeout=360
#	ute_wtssim.Execute Egate Command    enb_x2_link_up enb\=2 target\=1
#
#Configure UTE ETH3 For DSS CA
#    Log To Console    configure VM interfaces...
#    OperatingSystem.Run    sudo ip addr add 10.0.1.200/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.2.1/24 dev eth4
#    OperatingSystem.Run    sudo ip addr add 10.0.1.1/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.2.121/24 dev eth4
#    OperatingSystem.Run    sudo ip addr add 10.0.1.9/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.10/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.11/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.12/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.13/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.2.90/24 dev eth4
#    OperatingSystem.Run    sudo ip addr add 10.0.2.91/24 dev eth4
#    OperatingSystem.Run    sudo ip addr add 10.0.2.92/24 dev eth4
#    OperatingSystem.Run    sudo ip addr add 10.0.1.122/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.123/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.124/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.125/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.102/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.103/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.104/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.105/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.106/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.131/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.132/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.133/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.134/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.135/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.136/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.99/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.2.99/24 dev eth4
#    OperatingSystem.Run    sudo ip addr add 10.0.1.121/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.137/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.3.151/32 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.3.153/32 dev eth1
#    OperatingSystem.Run    sudo ip addr add 192.168.6.252/32 dev eth4
