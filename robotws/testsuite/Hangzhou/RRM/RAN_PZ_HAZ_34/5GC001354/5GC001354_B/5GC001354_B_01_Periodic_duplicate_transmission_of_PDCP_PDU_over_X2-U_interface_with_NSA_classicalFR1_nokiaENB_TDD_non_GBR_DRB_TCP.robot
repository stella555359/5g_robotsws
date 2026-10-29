# *** Settings ***
# Documentation     author: jack.zeng
# ...                 contact: jack.zeng@nokia-sbell.com
# ...                 squad group: SG_03
# ...                 feature : 5GC001354
# 
# 
# #Force Tags    CA_5G_RRM
# #...    PY36
# #Resource     ./../Resources/5GC001354_common_keyword.robot
# #Variables    ./../Resources/variables.py
# #
# #Suite Setup    Case preparaton for 1354_B01
# #
# #Suite Teardown    Run Keyword If Any Tests Failed    Run Keyword And Ignore Error
# #...               Suite Teardown for COAM    gnb_index=${gnb_index}
# #
# #*** Variables ***
# #${enb_golden_scf}     eNB_SCF_FGCR_8315.xml
# #${expect_counter_value}    100
# #${DATA_TP}            5M    #send TP
# #${DATA_TP_Peak}       1200M    #send TP
# #${protocol_TCP}    tcp
# #${protocol_UDP}    udp
# #${window_size}    100k
# #${seg_size}    536
# #${expect_dl_tput}              185    #for case2    Ave=213*0.95    Min=213*0.85
# #${expect_dl_tput_Peak}              750    #for case2    Ave=213*0.95    Min=213*0.85
# #${golden_scf_name}    golden_TDD.xml
# #${golden_scf_name_gnb2}    golden_FDD.xml
# 
# *** Test Cases ***
# #[1]5GC001354_5G_B_001_Periodic_duplicate_transmission_of_PDCP_PDU_over_X2-U_interface_with_NSA_classicalFR1_nokiaENB_TDD_non_GBR_DRB_TCP
# #    [Documentation]
# #    [Tags]    CRT_TRUNK    CRT_22R2    5GC001354-B    CRT_22R3    CRT_22R4    CRT_23R1
# #    [Setup]    Common Suite Setup for COAM and Create log directory_gNB    gnb_index=${gnb_index}
# #    [Timeout]    2 hour
# #    Precondition for attn    gnb_index=${gnb_index}
# #    ###check TP and have counter(M55355C04007 M55355C05007 ==0) when actX2DuplicateTxNSA3x disabled. With TCP
# #    Modify parameters online for cases    parameters_to_update=${PARAMETERS_TO_UPDATE_B02}      WEBUI_COAM=${WEBUI_COAM}
# #    UE attach and make calls successful
# #    Start DL transmission    dl_data_transfer=${DATA_TP}    seg_size=${seg_size}    window=${window_size}    protocol=${protocol_TCP}
# #    Check DL TP    dl_expect_throughput=${expect_dl_tput}    cellid=${1}        gnb_index=${gnb_index}
# #    wait until keyword succeeds    5min    30s
# #    ...  Check counters @{CT_1354_B}[0] in @{CT_Bvalues}[0] and @{CT_Bvalues}[0] and @{CT_1354_B}[1] in @{CT_Bvalues}[0] and @{CT_Bvalues}[0]
# #    ###check TP and have counter(M55355C04007 M55355C05007 200~1000) when actX2DuplicateTxNSA3x enabled. With TCP
# #    Modify parameters online for cases    parameters_to_update=${PARAMETERS_TO_UPDATE_B01}      WEBUI_COAM=${WEBUI_COAM}
# #    ##Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
# #    UE attach and make calls successful
# #    Start DL transmission    dl_data_transfer=${DATA_TP}    seg_size=${seg_size}    window=${window_size}    protocol=${protocol_TCP}
# #    Check DL TP    dl_expect_throughput=${expect_dl_tput}    cellid=${1}        gnb_index=${gnb_index}
# #    wait until keyword succeeds    5min    30s
# #    ...  Check counters @{CT_1354_B}[0] in @{CT_Bvalues}[2] and @{CT_Bvalues}[3] and @{CT_1354_B}[1] in @{CT_Bvalues}[4] and @{CT_Bvalues}[5]
# #    ###check Peak UDP TP and have counter(M55355C04007 M55355C05007 ==0) when actX2DuplicateTxNSA3x enabled. With UDP
# #    ##Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
# #    UE attach and make calls successful
# #    Start DL transmission    dl_data_transfer=${DATA_TP_Peak}    seg_size=${seg_size}    window=${window_size}    protocol=${protocol_UDP}
# #    Check DL TP    dl_expect_throughput=${expect_dl_tput_Peak}    cellid=${1}        gnb_index=${gnb_index}
# #    wait until keyword succeeds    5min    30s
# #    ...  Check counters @{CT_1354_B}[0] in @{CT_Bvalues}[0] and @{CT_Bvalues}[1] and @{CT_1354_B}[1] in @{CT_Bvalues}[0] and @{CT_Bvalues}[1]
# #    #[Teardown]    Test recover
# 
# *** Keywords ***
# Restore SCF to eNB
#     Upload SCF to eNB    scf_file=${enb_golden_scf}    tl_scf_dir_path=${tl_scf_dir_path}
# 
# Unlock AMF
#     Modify parameters online for cases    parameters_to_update=${PARAMETERS_TO_UPDATE_AMF}      WEBUI_COAM=${WEBUI_COAM}
# 
# Test recover
#     ##Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#     Run Keyword if    '${tl.gnbs[0].instance_id}' == '24211'     Restore SCF to eNB
#     Run Keyword if    '${tl.gnbs[0].instance_id}' == '24211'     Prepare the gNB cells onair status    gnb_index=${gnb_index}
#     ...     tl_scf_file_name=${golden_scf_name}
#     Run Keyword if    '${tl.gnbs[0].instance_id}' == '34111'     Prepare the gNB cells onair status    gnb_index=${gnb_index}
#     ...     tl_scf_file_name=${golden_scf_name}
#     Run Keyword And Ignore Error    Close the iperf process on APPserver    port=${DL_PORT}
# 	Run Keyword And Ignore Error    COAM Teardown gnb connections
