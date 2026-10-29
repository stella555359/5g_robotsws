*** Settings ***
Documentation
...   author: winnie he
...   contact: winnie.he@nokia-sbell.com
...   Description: this is one reference case template, purpose for unified style.

# Resource           ../Resources/common_resource.robot
# Resource           ../../Resources/Common/Airphone.robot

# # Resource          ../Resources/top50_resource.robot
# Suite Setup       Common MultiBTS Suite Setup For RRM
# # Suite Setup       Common Suite Setup For RRM
# # Test Setup            Common MultiBTS Test Setup For RRM
# # Test Setup          Common Test Setup For RRM
# # Test Teardown     Common MultiBTS Test Teardown For RRM
# # Test Teardown    Common Test Teardown For RRM
# Suite Teardown    Common MutliBTS Suite Teardown For RRM
# # Suite Teardown    Common Suite Teardown For RRM
# Force Tags        CRT/CIT/CDRT     #Tag Item
# # ...   PY27
# ...      RAN_5G                    #Product [RAN_5G]
# # ...      CLOUD_5G_CLASSICAL_2xANDROID_ASIBL_ABIAB1_ASIBR_ABILB1_AEQE_ENB   #TLtype, it is for auto trigger by ute cloud
# ...      SBTS00/SBTS21B           # it is for auto trigger by ute cloud with the release
# # ...      STATE_SKIP_AGENT         # it is for auto trigger by ute cloud with gnb state
# ...      RAN_PZ_HAZ_1             #Competence Area
# ...      RAN_PZ_HAZ1_SG07_ST_RRM  #Organization
# ...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]


# Test Timeout    120 minutes

# *** Variables ***
# #reduce global paramter as possilbe and automatically got from gNB or __init__
# @{Ohter_Allow_Alarms}
# ${APC_Index}    -1
# ${PA_MinValue}           ${0}
# ${PA_MaxValue}           ${93}
# ${DEBUG_MODE}            ${TRUE}
# # ${REMOTE_MODE}           ${TRUE}
# ${PATH}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L2_SW_CN_3/5GC001729/config/SBTS24R2
# ${PATH2}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T03/CB008126/Airphone
# ${AIRPHONE_NAME}    IPHY_2AEQE_case50_LOAP.xml
# ${SAVE_EGATE_AFTER_DOWN}    ${True}
# *** Test Cases ***
# # Kw Egate set
# #     # Commissioning Full SCF    scf_file=${PATH}/SCF/SCFC_case50_2AEQE_APLO.xml
# #     # Airphone Change Iphy Xml    ${PATH}/WTS/IPHY_2AEQE_case50_LOAP.xml
# #     Airphone Edaemon Egate Teardown
# #     Airphone Edaemon Egate Setup
# #     # # Airphone Change Iphy Xml   ${PATH}/WTS/IPHY_2AEQE_case50_LOAP.xml
# #     Setup Ap Env    local_wts_dir=${PATH}/WTS/WTS_2AEQE_case50_LOAP.cfg
# #     ...    iphy_path=${PATH}/WTS/IPHY_2AEQE_case50_LOAP.xml
# #     ...    scf_file_path=${PATH}/SCF/SCFC_case50_2AEQE_APLO.xml
# #     ...    call_type=sansa
# #     # test start
# #     # COAM_Admin.Login
# #     # COAM_Admin.ResetSite
# #     # Sleep    120s
# #     # Wait Unit Bts Configured
# #     # Wait Until RRU Configured
# #     # Airphone Suite Setup
# #     # Airphone Edaemon Egate Setup    wts_cfg_name=${PATH}/WTS/WTS_2AEQE_case50_LOAP.cfg
# #     # ...    cell_type=sansa
# #     # Airphone Edaemon Egate Start
# #     Airphone Attach    ue_id=1    call_type=SA
# #     # Airphone Attach    ue_id=11    call_type=NSA    gnb_id=2    bearer_id=2
# #     # ...    cell_id=1
# #     # test end
# #     Airphone Start Traffic    mbps=100m
# #     Sleep    10s
# #     Airphone Stop Traffic
# #     Airphone Get Average Throughput
# #     # Airphone Edaemon Egate Teardown

# # Kw Egate set MP
# #     Airphone Edaemon Egate Teardown
# #     Airphone Edaemon Egate Setup
# #     Setup Ap Env    local_wts_dir=${PATH2}/SA_TDD_2c_1gNBSim.lua
# #     ...    iphy_path=${PATH2}/iphy.xml
# #     ...    scf_file_path=${PATH2}/SCFC.xml
# #     ...    call_type=sa
# #     Airphone Attach    ue_id=1    call_type=SA

# KW Egate setup
#     [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim
#     ...    base_path=${CURDIR}/Airphone
#     Airphone Attach    ue_id=1    call_type=SA
#     # CB008126 AP PDU modify
#     Airphone Start Traffic    mbps=450m
#     Airphone Start Traffic    mbps=450m    dir=ul
#     Sleep    10s
#     Airphone Stop Traffic
#     Airphone Get Average Throughput

# KW Egate setup2
#     [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_FDD_4c_1gNBSim
#     ...    base_path=${CURDIR}/Airphone
#     Airphone Attach    ue_id=1    call_type=SA

# # KW Egate test for case1
# #     [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim
# #     ...    base_path=${CURDIR}/Airphone
# #     Airphone Attach    ue_id=1    call_type=SA
# #     airphone_pdu_session_setup    ue_id=1   pdu_id=1   nwslice_id=1   gw_id=1
# #     ${ret}    airphone_pdu_session_modify    ue_id=1
# #     ...    pdu_id=1
# #     ...    qosflows_to_add=1
# #     ...    by=amf
# #     ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID
# #     airphone_pdu_session_setup    ue_id=1   pdu_id=2   nwslice_id=1   gw_id=1
# #     ${ret}    airphone_pdu_session_modify    ue_id=1
# #     ...    pdu_id=2
# #     ...    qosflows_to_add=3
# #     ...    by=amf
# #     # ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID

# # KW Egate test for case2
# #     [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim
# #     ...    base_path=${CURDIR}/Airphone
# #     Airphone Qosflow Modify    qos_flow=15     5qi=8
# #     ...    qos_flow_type=non-gbr    priority=14
# #     Airphone Qosflow Modify    qos_flow=13     5qi=9
# #     ...    qos_flow_type=non-gbr    priority=13
# #     Airphone Qosflow Modify    qos_flow=1     gfbr_dl=6100
# #     ...    gfbr_ul=6100
# #     ...    priority=8
# #     Airphone Qosflow Modify    qos_flow=3     gfbr_dl=6200
# #     ...    gfbr_ul=6200
# #     ...    priority=12
# #     ${ret}    airphone_pdu_session_modify    ue_id=1
# #     ...    pdu_id=1;2
# #     ...    qosflows_to_modify=1,15;3,13
# #     ...    switch_ul_tunnel_endpoint=ip_teid;ip_teid by=amf
# #     ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID
# #     # Airphone Start Traffic    mbps=100m
# #     # Airphone Start Traffic    mbps=100m    dir=ul
# #     # Sleep    10s
# #     # Airphone Stop Traffic
# #     # Airphone Get Average Throughput
# Kw For AP Operation
#    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim
#     ...    base_path=${CURDIR}/Airphone
#     COAM_Admin.Login
#     ${cell_info}    COAM_Admin.getcellinfo    cell_type=nr
#     ${traffic_info_dic}    Create Dictionary    call_type=SA    ue_id=1    pdu_id=1    profile_id=1
#     ...                                         gnb_id=${None}    cell_id=${None}    bearer_id=${None}
#     Wait Until Keyword Succeeds     3x    1min    Airphone Operation    operation=attach
#     ...                   product_type=gnb
#     ...                   traffic_info_dic=${traffic_info_dic}
#     ...                   timeout=30s
#     Airphone Operation    operation=aplog
#     ...                   product_type=gnb
#     ...                   timeout=30s
#     ${psy_cellid_list}    Create List    ${50}    ${51}
#     FOR    ${psy_id}    IN    @{psy_cellid_list}
#         ${scell_status}    ${scellidx}    Run Keyword And Ignore Error    Get ScellIdx With UE Id From Egate Log    ${0}    ${psy_id}
#         Exit For Loop If    '${scell_status}'=='PASS'
#     END
#     ${traffic_info_dic}    Create Dictionary    call_type=SA    ue_id=1
#     Airphone Operation    operation=detach
#     ...                   product_type=gnb
#     ...                   traffic_info_dic=${traffic_info_dic}
#     ...                   timeout=30s
#     ${traffic_info_dic}    Create Dictionary    call_type=SA    ue_id=1    bearer_id=2    dir=dl
#     ...                                         pdu_id=1    time_len=5s    trf_id=1    mbps_dl=200m
#     ...                                         qfi_id=1    time=999    type=l3    profile_id=1
#     ...                                         gnb_id=0    cell_id=1    protocol=udp
#     ${Tput_dict}    Airphone Operation    operation=start_traffic
#     ...                                   product_type=gnb
#     ...                                   traffic_info_dic=${traffic_info_dic}
#     ...                                   timeout=600s
#     Sleep    30s
#     ${min_tput}    ${max_tput}    ${avg_tput}
#     ...    Airphone Get Detail Throughput For Per Scell    scell_index=${scellidx}
#     ${Tput_dict}    Airphone Operation    operation=stop_traffic
#     ...                                   product_type=gnb
#     ...                                   traffic_info_dic=${traffic_info_dic}
#     ...                                   timeout=600s
# Kw For CUS Test
#     # setup_for_ap
#     Create Enb Alias    ENB_1    enb_id=1    id_type=wts

# KW For Emil
#     Start Capture Emil Log By VM dcap    bts_index=${0}
#     # to do something
#     Sleep    1min
#     ${log_path}    Stop Emil Log Collection    bts_index=${0}
#     ${filter}    Create List    ITF_L2_HI_CU_USER_BEARERMODIFYREQ_ID    ECAUSE_MOBILITYRESUME
#     Analysis Emil Log    ${log_path}    ${filter}

# Kw For TTI
#     Start Capture Tti Log By VM dcap    cell_index=31,32
#     AT.Prepare UE    ue_index=${0}
#     AT.UE Attach
#     AT Operation    operation=start_traffic    IperfOptions=-u -i 1 -t 300 -b 10M -p 50001
#     ...    direction=ul
#     AT Operation    operation=start_traffic    IperfOptions=-u -i 1 -t 300 -b 10M -p 50002
#     ...    direction=dl
#     sleep    1 min
#     AT Operation    operation=stop_traffic    direction=ul
#     AT Operation    operation=stop_traffic    direction=dl
#     ${all_tti_csv_logs}    Stop Tti Log Collection
#     FOR    ${csv}     IN    @{all_tti_csv_logs}
#         Continue For Loop If    "_ul" not in '${csv}'
#         csv_analysis.prepare_csv_parser    filepath=${csv}
#         ${filter_values}    Create List    1    4
#         ${rows}    csv_analysis.filter_content_by_parameters    filter_parameter=ulPduDemuxData.rcvdBearers[0].lcId
#         ...    filter_value=${filter_values}    parameter=ulPduDemuxData.rcvdBearers[0].rcvdBytes
#     END
# Kw For TTI test
#     csv_analysis.prepare_csv_parser
#     ...   filepath=/home/ute/test_results
#     ${filter_values}    Create List    1    4
#     ${rows}    csv_analysis.filter_content_by_parameters    filter_parameter=ulPduDemuxData.rcvdBearers[0].lcId
#     ...    filter_value=${filter_values}    parameter=ulPduDemuxData.rcvdBearers[0].rcvdBytes
#     # AT.UE Attach
#     # sleep    10s
#     # ${dl_server1}    Connect To IperfServer From Appservers
#     # Start DL traffic By Iperf    time=999    traffic=500.00M    dl_server=${dl_server1}
#     # ...    index_of_yaml=${2}
#     # Sleep    30s
#     # Stop DL traffic By Iperf
