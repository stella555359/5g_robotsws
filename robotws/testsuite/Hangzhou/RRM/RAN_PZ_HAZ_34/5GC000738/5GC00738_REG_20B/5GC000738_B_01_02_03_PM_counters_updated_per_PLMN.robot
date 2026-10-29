# # #*** Settings ***
# # #Documentation
# # #...   author: Yishuang Wang
# # #...   contact: yishuang.wang@nokia-sbell.com
# # #...   squad group: SG_03
# # #...   feature : 5GC000738
# # #
# # #Force Tags    CA_5G_RRM
# # #...    PY36
# # #
# # #Suite Setup    Run Keywords
# # #...            Run Keyword And Ignore Error    Common Suite Setup for COAM    AND
# # ##...            Modify scf file for caseB01    AND
# # #...            Prepare the classical COAM BTS cell onair
# # #
# # #Suite Teardown    Run Keywords
# # #...               Run Keyword If Any Tests Failed
# # #...               Run Keyword And Ignore Error    Common Suite Teardown for COAM   AND
# # #...               Run Keyword And Ignore Error    Suite Recovery
# # #
# # #Resource    ../Resources/5GC000738_common_keywords.robot
# # #Resource    ../5GC00738_REG/Resources/5GC000738_REG_common_keywords.robot
# # #Variables    Resources/__init__.py
# # #
# # #*** Variables ***
# # #${s1log_B01}    738_B_01_S1.pcap
# # #${E1log_B01}    738_B_01_E1.pcap
# # #${s1log_B02}    738_B_02_S1.pcap
# # #${E1log_B02}    738_B_02_E1.pcap
# # #${s1log_B03}    738_B_03_S1.pcap
# # #${E1log_B03}    738_B_03_E1.pcap
# # ##${tl_scf_filename}    Configuration_scf_MRBTS-tl236-738.xml
# # #${tl_scf_filename}    gold_347_236_233.xml
# # #${tl_scf_dir_path}    /opt/workspace/SCF/
# # #${enbx2_dist}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNADJGNB-1
# # #${mcc}    ${tl.core.mcc}
# # #${mnc}    ${tl.core.mnc}
# # #
# # #*** Test Cases ***
# # #[1]5GC000738_B_01_PM_counters_updated_per_PLMN_when_NR_RAN_sharing_for_Cplane
# # #    [Documentation]
# # #    ...    The purpose of this test case is to verify the PM counters updated Per PLMN when RAN sharing enabled
# # #    [Tags]     Qualcomm    classical    CRT_22R2
# # #    [Timeout]    1 hour
# # #    [Setup]
# # #    RUN KEYWORD IF    '${cell_status}'=='FAIL'    Prepare the classical COAM BTS cell onair
# # #    should be equal    ${cell_status}    PASS
# # #    Prepare the atten for caseB01
# # #    Precondition for power UE    ue_type=${ue_type}
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
# # #    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# # #
# # #[1]5GC000738_B_02_PM_counters_updated_per_PLMN_when_NR_RAN_sharing_for_Uplane_DL
# # #    [Documentation]
# # #    ...    The purpose of this test case is to verify the PM counters updated Per PLMN when RAN sharing enabled
# # #    [Tags]     Qualcomm    classical    #CRT_22R2
# # #    [Timeout]    1 hour
# # #    [Setup]
# # #    RUN KEYWORD IF    '${cell_status}'=='FAIL'    Prepare the classical COAM BTS cell onair
# # #    should be equal    ${cell_status}    PASS
# # #    Precondition for power UE    ue_type=${ue_type}
# # #    Start Capture Classical enb x2 Logs    x2logname=${s1log_B02}
# # #    Start To Capture Wireshark Logs    filename=${E1log_B02}    connection=gnb    interface=any
# # #    Record the counter action timer
# # #    Attach and check power UE    ue_type=${ue_type}
# # #    sleep    10s
# # #    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_throughput}    duration=${dl_time}    iperf_port=${dl_port}
# # #    sleep    5s
# # #    Stop and download Logs    logname=${E1log_B02}   connection=gnb
# # #    Stop and Save classical enb x2 Logs    x2logname=${s1log_B02}
# # #    sleep    ${utc_left} min
# # #    sleep    6min
# # #    Check PM counter Result_B02
# # #    [Teardown]    Run Keywords
# # #    ...    Run Keyword And Ignore Error    Stop and Save classical enb x2 Logs    x2logname=${s1log_B02}    AND
# # #    ...    Run Keyword And Ignore Error    Stop and Save classical x2 Logs    x2logname=${E1log_B02}    AND
# # #    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# # #
# # #[1]5GC000738_B_03_PM_counters_updated_per_PLMN_when_NR_RAN_sharing_for_Uplane_UL
# # #    [Documentation]
# # #    ...    The purpose of this test case is to verify the PM counters updated Per PLMN when RAN sharing enabled.
# # #    [Tags]     Qualcomm    classical    CRT_22R2
# # #    [Timeout]    1 hour
# # #    [Setup]
# # #    RUN KEYWORD IF    '${cell_status}'=='FAIL'    Prepare the classical COAM BTS cell onair
# # #    should be equal    ${cell_status}    PASS
# # #    Precondition for power UE    ue_type=${ue_type}
# # #    Start Capture Classical enb x2 Logs    x2logname=${s1log_B03}
# # #    Start To Capture Wireshark Logs    filename=${E1log_B03}    connection=gnb    interface=any
# # #    Record the counter action timer
# # #    Attach and check power UE    ue_type=${ue_type}
# # #    sleep    10s
# # #    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_throughput}    duration=${ul_time}    iperf_port=${ul_port}
# # #    sleep    10s
# # #    Stop and download Logs    logname=${E1log_B03}   connection=gnb
# # #    Stop and Save classical enb x2 Logs    x2logname=${s1log_B03}
# # #    sleep    ${utc_left} min
# # #    sleep    6min
# # #    Check PM counter Result_B03
# # #    [Teardown]    Run Keywords
# # #    ...           Run Keyword And Ignore Error    Stop and Save classical enb x2 Logs    x2logname=${s1log_B03}    AND
# # #    ...           Run Keyword And Ignore Error    Tests Recovery    x2logname=${E1log_B03}    AND
# # #    ...           Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# # #
# # #
# # #*** Keywords ***
# # #Modify scf file for caseB01
# # #    run keyword and continue on failure     commissioning.Modify Scf    input_scf=${tl_scf_dir_path}${tl_scf_filename}
# # #    ...            output_scf=${epc_log_path}${tl_scf_filename}    parameters_lists=${PARAMS_TO_MODIFY_FEATURE_B001_19B}
# # #
# # #Perform full commission for COAM gnb
# # #    [Arguments]    ${scf}=${tl_scf_dir_path}${tl_scf_filename}
# # #    ...            ${gnb_ip}=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
# # #    Connect to gnb coam via ssl   bts_host=${gnb_ip}
# # #    COAM Commission with scf file    scf_file_path=${scf}    timeout=500    is_pdl_checking_needed=${False}
# # #    COAM Teardown gnb connections
# # #
# # #Prepare the atten for caseB01
# # #    Adjust the HBTE attenuation value    value=${15}
# # #
# # #Check PM counter Result_B01
# # #    wait until keyword succeeds    5min    1min    Check PM counter Result
# # #    ...    full_path=BTS/CELLS/NRCELL-1/MCC-${mcc}_MNC-${mnc}/NRANS    counter_id=M55145C00005
# # #    Check PM counter Result    full_path=BTS/CELLS/NRCELL-1/MCC-${mcc}_MNC-${mnc}/NRANS
# # #    ...    counter_id=M55145C00006
# # #
# # #Check PM counter Result
# # #    [Arguments]    ${counter_id}    ${full_path}
# # #    ${counter_result}    Get the Counter value from COAM    counter_id=${counter_id}    dic_path=${full_path}
# # #    ${counter_ready}    Set variable    ${0}
# # #    :For    ${i}    IN    @{counter_result}
# # #    \    ${res}=    run keyword and return status    should be true    ${i}>0
# # #    \    continue for loop if    ${res}==${False}
# # #    \    ${counter_ready}    Evaluate    ${counter_ready}+1
# # #    Should be true    ${counter_ready} >0    msg=all counter value not increase.
# # #
# # #Check PM counter Result_B02
# # #    wait until keyword succeeds    15min    5min    Check PM counter Result
# # #    ...    full_path=BTS/BTS/NRBTS-236/MCC-${mcc}_MNC-${mnc}/NRASU    counter_id=M55326C00001
# # #
# # #Check PM counter Result_B03
# # #    wait until keyword succeeds    5min    1min    Check PM counter Result
# # #    ...    full_path=BTS/BTS/NRBTS-236/MCC-${mcc}_MNC-${mnc}/NRASU   counter_id=M55326C00002
