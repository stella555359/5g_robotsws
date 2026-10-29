# # #*** Settings ***
# # #Documentation
# # #...    author: yuegong     #cris cai
# # #...    contact: yue.1.gong@nokia-sbell.com
# # #...   squad group: SG_03
# # #...   feature : 5GC000738
# # #
# # #Force Tags    CA_5G_RRM
# # #...    PY36
# # #
# # #Suite Setup    Run Keywords
# # #...            Run Keyword And Ignore Error    Common Suite Setup for COAM    AND
# # ##...            Set default cell    enb_index=${1}    value=${1}    AND
# # #...            Prepare with COMA gNB classical BTS cell onair
# # #
# # #Suite Teardown    Run Keywords
# # #...               Run Keyword If Any Tests Failed
# # #...               Run Keyword And Ignore Error    Common Suite Teardown for COAM   AND
# # ##...               Run Keyword And Ignore Error    Set default cell    enb_index=${1}    value=${0}    AND
# # #...               Run Keyword And Ignore Error    Suite Recovery
# # #
# # #Resource    ../Resources/5GC000738_common_keywords.robot
# # #Resource    ../5GC00738_REG/Resources/5GC000738_REG_common_keywords.robot
# # #Resource    Resources/5GC000738_REG_20A_common_keywords.robot
# # #
# # #
# # #*** Variables ***
# # #${s1log_B01}    738_B_01_S1.pcap
# # #${E1log_B01}    738_B_01_E1.pcap
# # #${s1log_B02}    738_B_02_S1.pcap
# # #${E1log_B02}    738_B_02_E1.pcap
# # #${s1log_B03}    738_B_03_S1.pcap
# # #${E1log_B03}    738_B_03_E1.pcap
# # ##${tl_scf_filename}    TL33_738_SCF.xml
# # #${tl_scf_dir_path}    /opt/workspace/SCF/
# # #${tl_scf_filename}    gold_347_236_233.xml
# # #${enbx2_dist}    MRBTS-${enb2_instance}/LNBTS-${enb2_instance}/LNADJGNB-1
# # #${enb_default_dist}    MRBTS-${enb2_instance}/LNBTS-${enb2_instance}/LNCEL-1
# # #${ue_type}    ${tl.ues[0].capabilities[1]}
# # #${gnb_id}    ${tl.gnbs[0].instance_id}
# # #${mcc}    ${tl.core.mcc}
# # #${mnc}    ${tl.core.mnc}
# # #${M55145C00005_path}    CELLS/NRCELL-1/MCC-${mcc}_MNC-${mnc}/NRANS/RA_UE_NSA_PLMN
# # #${M55145C00006_path}    CELLS/NRCELL-1/MCC-${mcc}_MNC-${mnc}/NRANS/RA_NGBR_DRB_NSA_PLMN
# # ##${M55326C00001_path}    [HZ_TL_${gnb_id}] BTS/NRBTS-${gnb_id}/MCC-${mcc}_MNC-${mnc}/NRASU/PDCP_SDU_USDAT_VOL_DL_NSA_PLMN
# # #${M55326C00001_path}    [HZ_TL_347_gy_v2] BTS/NRBTS-${gnb_id}/MCC-${mcc}_MNC-${mnc}/NRASU/PDCP_SDU_USDAT_VOL_DL_NSA_PLMN
# # #${M55326C00002_path}    [HZ_TL_347_gy_v2] BTS/NRBTS-${gnb_id}/MCC-${mcc}_MNC-${mnc}/NRASU/PDCP_SDU_USDAT_VOL_UL_NSA_PLMN
# # #
# # #${dl_port}     ${tl.ues[0].iperf_details.port}
# # #${ul_port}    ${tl.appserver.iperf_details.port}
# # #${ul_time}    600
# # #${ul_length}    1024B
# # #${ul_throughput}     10M
# # #${dl_time}    600
# # #${dl_length}    1024B
# # #${dl_throughput}    300M
# # #${ul_tp_expect}    1
# # #${dl_tp_expect}    5
# # #${5GRU1_ANT1}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
# # #${5GRU1_ANT2}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
# # #${5GRU1_ANT3}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
# # #${5GRU1_ANT4}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}
# # #
# # #*** Test Cases ***
# # #[1]5GC000738_B_01_PM_counters_updated_per_PLMN_when_NR_RAN_sharing_for_Cplane
# # #    [Documentation]
# # #    ...    The purpose of this test case is to verify the PM counters updated Per PLMN when RAN sharing enabled
# # #    [Tags]     huawei    classical    CRT_22R1    CIT_22R3
# # #    [Timeout]    1 hour
# # #    [Setup]
# # #    Precondition for power UE    ue_type=${ue_type}
# # #    Run Keyword And Ignore Error    Prepare the atten for 20A Qualcomm Env
# # #    Start Capture Classical enb x2 Logs    x2logname=${s1log_B01}
# # #    Start To Capture Wireshark Logs    filename=${E1log_B01}    connection=gnb    interface=any
# # #    Record the counter action timer
# # #    Attach and check power UE    ue_type=${ue_type}
# # #    sleep    10s
# # #    Stop and download Logs    logname=${E1log_B01}   connection=gnb
# # #    Stop and Save classical enb x2 Logs    x2logname=${s1log_B01}
# # #    sleep    ${utc_left} min
# # #    sleep    6min
# # #    Check PM counter Result_B01
# # #    [Teardown]    Run Keywords
# # #    ...    Run Keyword And Ignore Error    Stop and Save classical enb x2 Logs    x2logname=${s1log_B01}    AND
# # #    ...    Run Keyword And Ignore Error    Stop and Save classical x2 Logs    x2logname=${E1log_B01}    AND
# # #    ...    Run Keyword And Ignore Error    disconnect gnd and enb
# # #
# # #
# # #[1]5GC000738_B_02_PM_counters_updated_per_PLMN_when_NR_RAN_sharing_for_Uplane_DL
# # #    [Documentation]
# # #    ...    The purpose of this test case is to verify the PM counters updated Per PLMN when RAN sharing enabled
# # #    [Tags]     9.1800    huawei    classical
# # #    [Timeout]    1 hour
# # #    [Setup]    Check the COAM gnb cell status onair
# # #    sleep    60s
# # #    Precondition for power UE    ue_type=${ue_type}
# # #    Start Capture Classical enb x2 Logs    x2logname=${s1log_B02}
# # #    Start To Capture Wireshark Logs    filename=${E1log_B02}    connection=gnb    interface=any
# # #    Record the counter action timer
# # #    Attach and check power UE    ue_type=${ue_type}
# # #    sleep    10s
# # #    power_ue.Start traffic     ue_type=${ue_type}     direction=dl     throughput=${dl_throughput}
# # #    ...     duration=${dl_time}     iperf_port=${dl_port}
# # #    Wait Until Keyword Succeeds    8min    30sec    power_ue.Check throughput     ue_type=${ue_type}
# # #    ...    direction=dl    throughput=${dl_tp_expect}
# # #    sleep    5s
# # #    Stop and download Logs    logname=${E1log_B02}   connection=gnb
# # #    Stop and Save classical enb x2 Logs    x2logname=${s1log_B02}
# # #    sleep    ${utc_left} min
# # #    sleep    6min
# # #    Check PM counter Result_B02
# # #    [Teardown]    Run Keywords
# # #    ...    Run Keyword And Ignore Error    Stop and Save classical enb x2 Logs    x2logname=${s1log_B02}    AND
# # #    ...    Run Keyword And Ignore Error    Stop and Save classical x2 Logs    x2logname=${E1log_B02}    AND
# # #    ...    Run Keyword And Ignore Error    disconnect gnd and enb
# # #
# # #[1]5GC000738_B_03_PM_counters_updated_per_PLMN_when_NR_RAN_sharing_for_Uplane_UL
# # #    [Documentation]
# # #    ...    The purpose of this test case is to verify the PM counters updated Per PLMN when RAN sharing enabled.
# # #    [Tags]     9.1800    huawei    classical    CRT_22R1    CRT_22R3
# # #    [Timeout]    1 hour
# # #    [Setup]    Check the COAM gnb cell status onair
# # #    sleep    60s
# # #    Precondition for power UE    ue_type=${ue_type}
# # #    Start Capture Classical enb x2 Logs    x2logname=${s1log_B03}
# # #    Start To Capture Wireshark Logs    filename=${E1log_B03}    connection=gnb    interface=any
# # #    Record the counter action timer
# # #    Attach and check power UE    ue_type=${ue_type}
# # #    sleep    10s
# # #    power_ue.Start traffic     ue_type=${ue_type}     direction=ul     throughput=${ul_throughput}
# # #    ...     duration=${ul_time}     iperf_port=${ul_port}
# # #    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    8min    30sec    power_ue.Check throughput     ue_type=${ue_type}
# # #    ...    direction=ul    throughput=${ul_tp_expect}
# # #    sleep    10s
# # #    Stop and download Logs    logname=${E1log_B03}   connection=gnb
# # #    Stop and Save classical enb x2 Logs    x2logname=${s1log_B03}
# # #    sleep    ${utc_left} min
# # #    sleep    6min
# # #    Check PM counter Result_B03
# # #    [Teardown]    Run Keywords
# # #    ...    Run Keyword And Ignore Error    Stop and Save classical enb x2 Logs    x2logname=${s1log_B03}    AND
# # #    ...    Run Keyword And Ignore Error    Tests Recovery    x2logname=${E1log_B03}    AND
# # #    ...    Run Keyword And Ignore Error    disconnect gnd and enb
# # #
# # #
# # #*** Keywords ***
# # #Modify scf file for caseB01
# # #    run keyword and continue on failure     commissioning.Modify Scf    input_scf=${tl_scf_dir_path}${tl_scf_filename}
# # #    ...            output_scf=${epc_log_path}${tl_scf_filename}    parameters_lists=${PARAMS_TO_MODIFY_FEATURE_B001}
# # #
# # #Perform full commission for COAM gnb
# # #    [Arguments]    ${scf}=${epc_log_path}${tl_scf_filename}
# # #    ...            ${gnb_ip}=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
# # #    Connect to gnb coam via ssl   bts_host=${gnb_ip}
# # #    COAM Commission with scf file    scf_file_path=${scf}    timeout=500    is_pdl_checking_needed=${False}
# # #    COAM Teardown gnb connections
# # #
# # #Prepare the atten for caseB01
# # #    Adjust RU1 Attenuation to ${40}
# # #    Adjust RU2 Attenuation to ${100}
# # #
# # #Check PM counter Result_B01
# # #    selenium_coam.enable_virtual_display
# # #    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
# # #    wait until keyword succeeds    7min    1min    Check the bts counter M55145C00005 from ${M55145C00005_path} as 1
# # #    wait until keyword succeeds    7min    1min    Check the bts counter M55145C00006 from ${M55145C00006_path} as 1
# # #    sleep    5s
# # #    [Teardown]    Run keyword and ignore error   selenium_coam.logout
# # #
# # #
# # #Check PM counter Result_B02
# # #    selenium_coam.enable_virtual_display
# # #    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
# # #    wait until keyword succeeds    7min    1min    Check the bts counter M55326C00001 from ${M55326C00001_path} as 1
# # #    sleep    5s
# # #    [Teardown]    Run keyword and ignore error   selenium_coam.logout
# # #
# # #Check PM counter Result_B03
# # #    selenium_coam.enable_virtual_display
# # #    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
# # #    wait until keyword succeeds    7min    1min    Check the bts counter M55326C00002 from ${M55326C00002_path} as 1
# # #    sleep    5s
# # #    [Teardown]    Run keyword and ignore error   selenium_coam.logout
# # #
# # #disconnect gnd and enb
# # #    csn.disconnect    connection=enb
# # #    csn.disconnect    connection=gnb
