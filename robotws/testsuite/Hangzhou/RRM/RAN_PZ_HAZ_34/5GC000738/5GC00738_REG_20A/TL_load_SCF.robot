# *** Settings ***
# Documentation
# ...    author: yue.1.gong
# ...    contact: yue.1.gong@nokia-sbell.com
# ...   squad group: SG_03
# ...   feature : 5GC000738
# 
# Force Tags    CA_5G_RRM
# ...    PY36
# 
# Suite Setup    Run Keywords
# ...            robot_common_operations.Common Suite Setup    AND
# ...            Run Keyword And Ignore Error    Common Suite Setup for COAM    AND
# ...            Load SCF for each TL
# 
# Suite Teardown    Run Keywords
# ...               robot_common_operations.Common Suite Teardown    AND
# ...               Run Keyword And Ignore Error    COAM Teardown gnb connections
# 
# #Resource    Resources/5GC000738_REG_common_keywords.robot
# Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC000738/5GC00738_REG/Resources/5GC000738_REG_common_keywords.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot
# #Variables    Resources/__init__.py
# Variables    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC000738/5GC00738_REG/Resources/__init__.py
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
# 
# 
# *** Variables ***
# ${5GRU2_ANT1}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[0].port_no}
# ${5GRU2_ANT2}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[1].port_no}
# ${s1log_B01}    738_B_01_S1.pcap
# ${E1log_B01}    738_B_01_E1.pcap
# ${s1log_B02}    738_B_02_S1.pcap
# ${E1log_B02}    738_B_02_E1.pcap
# ${s1log_B03}    738_B_03_S1.pcap
# ${E1log_B03}    738_B_03_E1.pcap
# ${tl_36011_scf_gnb1}    gy_36011_GNB1.xml
# ${tl_36012_scf_gnb2}    gy_36012_GNB2.xml
# ${tl_34711_scf_gnb1}    gy_34711_GNB1.xml
# ${tl_34712_scf_gnb2}    gy_34712_GNB2.xml
# ${tl_23311_scf_gnb1}    gy_23311_GNB1.xml
# ${tl_23312_scf_gnb2}    gy_23312_GNB2.xml
# ${T36021_SCF}           gy_36021_ENB1.xml
# ${T36022_SCF}           gy_36022_ENB2.xml
# ${T34721_SCF}           gy_34721_ENB1.xml
# ${T34722_SCF}           gy_34722_ENB2.xml
# ${T23321_SCF}           gy_23321_ENB1.xml
# ${T23322_SCF}           gy_23322_ENB2.xml
# ${enbx2_dist}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNADJGNB-1
# ${enb1_gnb2_x2_dist}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNADJGNB-2
# ${enb1_def_gnb_dist}     MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-1
# ${enb_def_cell_para}     defaultLnRelGnbCellId
# ${eNB_X2_ON_OFF}    administrativeState
# ${x2_lock}    locked
# ${x2_unloack}    unlocked
# @{BTSID}    36011    34711    23311
# ${epc_log_path}        /opt/workspace/CRT/Master/Case_Logs/
# @{value_counter_B01}    ${0}     ${0}
# ${dl_60M}    300M
# ${ul_60M}    10M
# ${dl_e}    140
# ${ul_e}    15
# ${gnb_instance}     ${tl.gnbs[0].instance_id}
# ${ue_type}    ${tl.ues[0].capabilities[0]}
# ${duration}    600
# ${enb_instance}     ${tl.enbs[0].instance_id}
# #@{gnb_ips}    ${bts_host0}    ${bts_host1}
# #${bts_host0}    ${tl.gnbs[0].cu.oam_http_connection_details.addr}
# #${bts_host1}    ${tl.gnbs[1].cu.oam_http_connection_details.addr}
# *** Test Cases ***
# [1]TL_load_SCF
#     [Documentation]
#     ...    The purpose of this test case is to verify the PM counters updated Per PLMN when RAN sharing enabled
#     [Tags]     Qualcomm    classical    CIT_TRUNK    CIT_22R4    CDRT    CIT_23R1    CIT_22R3
#     [Timeout]    1 hour
#     [Setup]
#     Run Keyword And Ignore Error    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}
#     ...    ui_version=S20UI2.5    power_reset=True
#     sleep    10s
#     Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#     Run Keyword And Ignore Error    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}
#     ...    ui_version=S20UI2.5    power_reset=True
#     sleep    10s
#     Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}
#     Run Keyword And Ignore Error    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${2}
#     ...    ui_version=S20UI2.5    power_reset=True
#     sleep    10s
#     Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${2}
# #    Run Keyword And Ignore Error    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${3}
# #    ...    ui_version=S20UI2.5    power_reset=True
# #    sleep    10s
# #    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${3}
#     [Teardown]    Run Keywords
#     ...    robot_common_operations.Common Case Teardown    AND
#     ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# 
# 
# *** Keywords ***
# Load SCF for each TL
#     Run Keyword If    '${gnb_instance}' == '@{BTSID}[0]'
#     ...    Common Case TestLine Setup    is_commission=True    is_commission_for_second_gnb=True
#     ...     golden_scf_name=${tl_36011_scf_gnb1}    golden_scf_name_gnb2=${tl_36012_scf_gnb2}
#     ...    Enb_commission=True   Enb_commission_For_ENB2=True    enb_scf=${T36021_SCF}    enb2_scf=${T36022_SCF}
#     Run Keyword If    '${gnb_instance}' == '@{BTSID}[1]'
#     ...    Common Case TestLine Setup    is_commission=True    is_commission_for_second_gnb=True
#     ...    Enb_commission=True   Enb_commission_For_ENB2=True    enb_scf=${T34721_SCF}    enb2_scf=${T34722_SCF}
#     ...     golden_scf_name=${tl_34711_scf_gnb1}    golden_scf_name_gnb2=${tl_34712_scf_gnb2}
#     Run Keyword If    '${gnb_instance}' == '@{BTSID}[2]'
#     ...    Common Case TestLine Setup    is_commission=True    is_commission_for_second_gnb=True
#     ...     golden_scf_name=${tl_23311_scf_gnb1}    golden_scf_name_gnb2=${tl_23312_scf_gnb2}
#     ...    Enb_commission=True   Enb_commission_For_ENB2=True    enb_scf=${T23321_SCF}    enb2_scf=${T23322_SCF}