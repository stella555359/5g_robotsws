#*** Settings ***
#Force Tags    PY36
#Documentation     author: qingqing.zhang
#...                 contact: qingqing.zhang@nokia-sbell.com
#...                 squad group: SG_03
#...                 feature : CB010701-AA
#
#Resource    ./Resources/CB010701_common_keywords.robot
#Variables    ./Resources/CB010701_variables.py
#
#
#Suite Setup    Run Keywords    Common Suite Setup for COAM
#...            AND    Common Case TestLine Setup    is_commission=True    scf_path=${scf_path}
#...            golden_scf_name=${tl_scf}
#
#Suite Teardown    Run Keyword And Ignore Error    Common Suite Teardown for COAM
#
#*** Variables ***
#${gnb_path}    /tmp
#${scf_path}    /opt/workspace/SCF/
#${epc_log_path}    /opt/workspace/CRT/Master/Case_Logs/
#${tl_scf}    CB010701_SCF.xml
#${interface1}    br1
#${expected_tput_ul_F}    105
#${expected_tput_ul_T}    212
#${expected_tput_dl_F}   30
#${expected_tput_dl_T}   300
#${expected_tput_ul_grant}    40
#${expected_tput_dl_grant}   55
#${logname_B3_001_attach_2TX}    AA_B3_001_attach_1208_2TX.pcap
#${logname_B3_001_attach}    AA_B3_001_attach_1208_3TX.pcap
#*** Test Cases ***
#[1]CB010701_ET_AA_B3_001_SingleUE_peak_TP_for_FT_UL_CA_2CCs_with_3Tx_PUSCH_typeA_1208_ABIP_256QAM
#    [Documentation]
#    ...    his user scenario describes the single UE peak throughput when FDD cell is configured with PUSCH mapping
#    ...    type A with feature enabled for FDD + TDD FR1 scenario.
#    [Tags]    classical
#    [Setup]    robot_common_operations.Common Case Setup
#    MTK UE reboot
#    MTK prepare UE    ue_type=${ue_type}    ue_index=${0}
#    Modify Parameters for Cases   gnb_index=${0}    Modify_Para_Online=${PARAMETERS_ONLINE_MODIFY_GNB1_AA_B3_001}
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}    gnb1_cell2_value1=${18}
#    bollinger attach and collect log    logname=${logname_B3_001_attach_2TX}
#    Check wireshark log for 3TX    logname=${logname_B3_001_attach_2TX}    TDD_MIMO_Layers=1    TDD_SRS_Ports=0
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#    Modify Parameters for Cases   gnb_index=${0}    Modify_Para_Online=${Modify_Para_Online_CB010701_open}
#    bollinger attach and collect log    logname=${logname_B3_001_attach}    counter_id=${counter_id_AA_B3_001_attach}
#    ...    dic_path=${dic_path_AA_B3_001_Pcell_attach}
#    Check wireshark log for 3TX    logname=${logname_B3_001_attach}
#    Start DLUL traffic and check throughput   logname=${logname_B3_001_attach}
#    ...    scellid=1    pcellid=3    tput_dl_pcell=${expected_tput_dl_F}    tput_dl_scell=${expected_tput_dl_T}
#    ...    tput_ul_pcell=${expected_tput_ul_F}    tput_ul_scell=${expected_tput_ul_T}    duration=300s
#    ...    counter_id=${counter_id_AA_B3_001_with_traffic}    dic_path_T=${dic_path_AA_B3_001_with_traffic_TDD}
#    ...    dic_path_F=${dic_path_AA_B3_001_with_traffic_FDD}
#    Stop UE DLUL traffic    ue_index=${0}
#    [Teardown]    run keywords
#    ...    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}    AND
#    ...    Run Keyword And Ignore Error    Case Teardown
#
#*** Keywords ***
#Check wireshark log for 3TX
#    [Arguments]    ${logname}    ${TDD_MIMO_Layers}=2    ${TDD_SRS_Ports}=1
#    Check wireshark log for 2CC    logname=${logname}
#   Check wireshark log for 3TX capability    logname=${logname}    TDD_MIMO_Layers=${TDD_MIMO_Layers}    TDD_SRS_Ports=${TDD_SRS_Ports}
