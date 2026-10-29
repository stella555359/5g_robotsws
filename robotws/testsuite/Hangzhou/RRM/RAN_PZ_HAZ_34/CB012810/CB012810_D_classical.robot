*** Settings ***
Documentation      Author:qingqing.zhang@nokia-sbell.com
...                squad group: SG_03
...                feature : CB012810_D

Resource         ./Resources/CB012810_case_step.robot


Suite Setup    Run Keywords
...            robot_common_operations.Common Suite Setup
...            AND    Common Suite Setup for COAM
...            AND    Common Case TestLine Setup with gnb and enb

Suite Teardown      Run Keywords
...               robot_common_operations.Common Suite Teardown
...               AND    Common Case TestLine Recover
...               AND    Run Keyword And Ignore Error    Common Suite Teardown for COAM
...               AND    Run Keyword And Ignore Error    COAM Teardown gnb connections

*** Variables ***
${epc_log_path}        /opt/workspace/CRT/Master/Case_Logs
${TS_LOG_PATH_BASE}         /opt/workspace/CRT/Master/Case_Logs/
${Send_Tput_UL}    100K
${Send_Tput_DL}    200M
${expected_tput_dl}    5
${expected_tput_ul}    0.05
${12810_allow_fault_list}     7107    4681
${two_UEs_attach}    sansung_two_UEs_attach.pcap
${VONR_log1}    VONR_log_setup_and_release1.pcap
${VONR_log2}    VONR_log_setup_and_release2.pcap
${VONR_log3}    VONR_log_setup_and_release3.pcap
${VONR_log4}    VONR_log_setup_and_release4.pcap
${VONR_log5}    VONR_log_setup_and_release5.pcap
${S22_attach}    WK8_003_S22_attach.pcap
${S22_attach1}    B3_001_S22_attach.pcap
${MTP_attach}    B3_001_qualcomm_attach.pcap
${MTP_attach1}    B3_001_qualcomm_attach1.pcap
${log_HO}   WK8_003_cell2_HO_to_cell4.pcap
${log1_HO}   WK8_003_cell4_HO_to_cell2.pcap
${S23_attach_gnb}    IWK2_02_S23_attach_gnb.pcap
${S23_attach_gnb_1}    IWK2_02_S23_attach_gnb_1.pcap
${S23_attach_enb}    IWK2_02_S23_attach_enb.pcap
${S23_attach_enb_1}    IWK2_02_S23_attach_enb_1.pcap

*** Test Cases ***
[1]CB012810-D#WK3_001_UEs_with_VoNR_DRB_do_not_get_DRB_priority_proactive_grants
    [Documentation]
    ...    cover 5GC002056_AGAT
    [Tags]    D#WK3_001
    [Setup]
    robot_common_operations.Common Case Setup    allowed_faults_ids=7311,7107,7523
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_TL233}
    Modify Parameters for Cases   gnb_index=${0}
    ...                    Modify_Para_Online=${Online_Modify_WK3_001}
    UE_and_PA_prepare_classical_gnb    gnb_cell1_value=${0}
    Multi UE attach and collect log    tcpdump_filename=${two_UEs_attach}    S22=True    S23=True
    ...    target_dir=${epc_log_path}
    Make a VoNR call and collect log    tcpdump_filename=${VONR_log1}    is_need_TTI=True    phone_number=13100007898
    ...    nr_phy_cell_ids=31    target_dir=${epc_log_path}
     FOR    ${index}    IN RANGE    2    6
         Make a VoNR call and collect log    tcpdump_filename=${VONR_log${index}}    phone_number=13100007898
         ...    target_dir=${epc_log_path}
     END
    [Teardown]     Run Keywords    Run Keyword And Ignore Error    IWK3_001_case_recovery
    ...    AND    CB012810_case_teardown

[1]CB012810-D#WK8_003_SgNB_addition_with_multiple_non-GBR_DRBs_with_DRB_priority_PUG_with_NSA_3x_UE_PScell_change
    [Documentation]
    ...    drb PUG HO test
    [Tags]    D#WK8_003
    [Setup]
    robot_common_operations.Common Case Setup    allowed_faults_ids=7311,7107,7523
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_TL233}
    Modify Parameters for Cases   gnb_index=${0}
    ...                    Modify_Para_Online=${Online_Modify_WK8_003_classical}
    ...                    Delete_Para_Online=${Online_Delete_WK8_003_classical}
    ...                    Add_Para_Online=${Online_Add_WK8_003}
    UE_and_PA_prepare_classical_gnb    gnb_cell1_value=${0}
    Multi UE attach and collect log    tcpdump_filename=${S22_attach}    S22=True    target_dir=${epc_log_path}
    Power UE Start UL traffic    ue_type=${ue_type_samsung}
    ...    ul_throughput=${Send_Tput_UL}    ue_index=${2}
    Trigger HO and collect log    tcpdump_filename=${log_HO}    TTI_name=TTI_HO_1    nr_phy_cell_ids=32
    ...    gnb_cell1_value_HO=${25}    gnb_cell3_value_HO=${0}    target_dir=${epc_log_path}
    Trigger HO and collect log    tcpdump_filename=${log1_HO}    TTI_name=TTI_HO_2    nr_phy_cell_ids=31
    ...    gnb_cell1_value_HO=${0}    gnb_cell3_value_HO=${25}    target_dir=${epc_log_path}
    ### check target cell use lowpug
    Analysis tti for ulProGrantType    names=TTI_HO_1    drb_pug=False    target_dir=${epc_log_path}
    Analysis tti for ulFdSchedData.rrmBufferedDataUlLcg_bytes    names=TTI_HO_1    bufferSize=[0, 0, 0, 0, 0, 0, 0, 64]
    ...    grant=NONSKIPPABLE    target_dir=${epc_log_path}
    ### check target cell use drbpug
    Analysis tti for ulProGrantType    names=TTI_HO_2    target_dir=${epc_log_path}
    Analysis tti for ulFdSchedData.rrmBufferedDataUlLcg_bytes    names=TTI_HO_2    target_dir=${epc_log_path}
#    Analysis tti for SFN same    names=TTI_HO_2
    [Teardown]    Run Keywords    power_ue.UE Detach    ue_type=${ue_type_samsung}    ue_index=${2}
    ...    AND    Run Keyword And Ignore Error    IWK3_001_case_recovery
    ...    AND    CB012810_case_teardown

[1]CB012810-D#B3_001_Online_change_DRB_priority_Proactive_UL_Grant_parameters_for_non-VoNR_UEs_with_UL_tx_skip_capability
    [Documentation]
    ...    drb PUG
    [Tags]    D#B3_001
    [Setup]
    robot_common_operations.Common Case Setup    allowed_faults_ids=7311,7107,7523
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_TL233}
    Modify Parameters for Cases   gnb_index=${0}
    ...                    Modify_Para_Online=${Online_Modify_B3_001}
    ...                    Add_Para_Online=${Online_Add_B3_001}
    UE_and_PA_prepare_classical_gnb    gnb_cell1_value=${0}
    UE attach and collect TTI    tcpdump_filename=${S22_attach1}    S22=True    TTI_name=TTI_S22_attach
    ...    nr_phy_cell_ids=31    target_dir=${epc_log_path}
    power_ue.UE Detach    ue_type=${ue_type_samsung}    ue_index=${2}
    UE attach and collect TTI    tcpdump_filename=${MTP_attach}    MTP_TL233=True    TTI_name=TTI_MTP_attach_1
    ...    nr_phy_cell_ids=31    target_dir=${epc_log_path}
    ### check UE1 use lowpug and  UE2 use drbpug
    Analysis tti for ulProGrantType    names=TTI_S22_attach    drb_pug=False    target_dir=${epc_log_path}
    Analysis tti for ulProGrantType    names=TTI_MTP_attach_1    DrbGrantType=DRBPRIOPUGSKIPPABLEDYNAMICENHANCED    target_dir=${epc_log_path}
    Analysis tti for ulFdSchedData.rrmBufferedDataUlLcg_bytes    names=TTI_MTP_attach_1
    ...    bufferSize=[0, 1500, 0, 0, 0, 0, 0, 0]    grant=DRBPRIOPUGSKIPPABLEDYNAMICENHANCED    target_dir=${epc_log_path}
    ### detech UE2 and UE1 turn on mobile data
    Modify Parameters for Cases   gnb_index=${0}    Modify_Para_Online=${Online_Modify_B3_001_1}
    UE attach and collect TTI    tcpdump_filename=${MTP_attach1}    MTP_TL233=True    TTI_name=TTI_MTP_attach_2
    ...    nr_phy_cell_ids=31    target_dir=${epc_log_path}
    Analysis tti for ulProGrantType    names=TTI_MTP_attach_2    DrbGrantType=DRBPRIOPUGSKIPPABLEDYNAMICENHANCED    target_dir=${epc_log_path}
    Analysis tti for ulFdSchedData.rrmBufferedDataUlLcg_bytes    names=TTI_MTP_attach_2
    ...    bufferSize=[0, 500, 0, 0, 0, 0, 0, 0]    grant=DRBPRIOPUGSKIPPABLEDYNAMICENHANCED    target_dir=${epc_log_path}
#    Analysis tti for SFN same    names=TTI_MTP_data_on    grant=DRBPRIOPUGSKIPPABLEDYNAMIC
    [Teardown]    Run Keywords    power_ue.UE Detach    ue_type=${ue_type_samsung}    ue_index=${2}
    ...    AND    power_ue.UE Detach    ue_type=${ue_type_MTP}    ue_index=${3}
    ...    AND    CB012810_case_teardown

[1]CB012810-E#IWK2_02_DRB_priority_PUG_interworking_with_UL_split_mode_actProactGrantsUlLteOnlyMode_true_actProactUlSchedulingEnh_true
    [Documentation]
    ...    NSA mode
    [Tags]    E#IWK2_02
    [Setup]
    robot_common_operations.Common Case Setup    allowed_faults_ids=7311,7107,7523
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_TL233}
    Modify Parameters for Cases   gnb_index=${0}
    ...                    Modify_Para_Online=${Online_Modify_IWK2_002}
    UE_and_PA_prepare_classical_gnb    gnb_cell1_value=${0}    enb_cell1_value=${0}
    Prepare with PM counter time to caculate    period=start
    UE NSA attach and collect log    tcpdump_filename=${S23_attach_gnb}    tcpdump_filename_enb=${S23_attach_enb}
    ...    target_dir=${epc_log_path}
    Samsung start DLUL and collect TTI    TTI_name=TTI_NR_traffic    target_dir=${epc_log_path}
    Wait until keyword succeeds    5 min    10s    Check Counter for DRBPUG
    Prepare with PM counter time to caculate    period=start
    Trigger UL split and collect TTI    TTI_name=TTI_LTE_traffic    target_dir=${epc_log_path}
    Prepare with PM counter time to caculate    period=end
    Wait until keyword succeeds    10 min    10s    Check Counter for DRBPUG    DRBPUG=False
    ###check TTI have drb pug when NSA attach
    Analysis tti for ulProGrantType    names=TTI_NR_traffic    target_dir=${epc_log_path}
    Analysis tti for ulFdSchedData.rrmBufferedDataUlLcg_bytes    names=TTI_NR_traffic    bufferSize=[0, 100, 0, 0, 0, 0, 0, 0]
    ...    target_dir=${epc_log_path}
    ###check TTI have low pug when UL split to LTE because actProactGrantsUlLteOnlyMode=true
    Analysis tti for ulProGrantType    names=TTI_LTE_traffic    drb_pug=False    target_dir=${epc_log_path}
    Analysis tti for ulFdSchedData.rrmBufferedDataUlLcg_bytes    names=TTI_LTE_traffic    bufferSize=[0, 0, 0, 0, 0, 0, 0, 64]
    ...    grant=NONSKIPPABLE    target_dir=${epc_log_path}
    Samsung stop DLUL and detech
    Modify Parameters for Cases   gnb_index=${0}
    ...                    Modify_Para_Online=${Online_Modify_IWK2_002_1}
    Adjust the HBTE attenuation value for TL233    gnb_cell1_value=${0}    enb_cell1_value=${0}
    UE NSA attach and collect log    tcpdump_filename=${S23_attach_gnb_1}    tcpdump_filename_enb=${S23_attach_enb_1}
    ...    target_dir=${epc_log_path}
    Samsung start DLUL and collect TTI    TTI_name=TTI1_NR_traffic    target_dir=${epc_log_path}
    Trigger UL split and collect TTI    TTI_name=TTI1_LTE_traffic    target_dir=${epc_log_path}
    ###check TTI have drb pug when NSA attach
    Analysis tti for ulProGrantType    names=TTI1_NR_traffic    target_dir=${epc_log_path}
    ###check TTI have no drbpug and lowpug when UL split to LTE because actProactGrantsUlLteOnlyMode=false
    Analysis tti for ulProGrantType no drbpug and lowpug    names=TTI1_LTE_traffic     target_dir=${epc_log_path}
    [Teardown]     Run Keywords    Run Keyword And Ignore Error    IWK2_002_case_recovery
    ...    AND    CB012810_case_teardown

*** Keywords ***
Common Case TestLine Setup with gnb and enb
    ${release_info}    Get sagnb release title
    set suite variable    ${release_info}
    Common Case TestLine Setup    Is_Swconfig=True
    ...                           swconfig_file=/opt/workspace/SCF/swconfig.txt
    ...                           swconfig_modify=${TTI_capture_swconfig}
    ...                           is_commission=True
    ...                           golden_scf_name=MRBTS_${MRBTS_ID}_${release_info}.xml
    ...                           Is_Swconfig_for_GNB2=True
    ...                           golden_scf_name_gnb2=MRBTS_${MRBTS_ID2}_${release_info}.xml
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${MRBTS_ID_enb}/LNBTS-${MRBTS_ID_enb}/LNCEL-1    parameter=defaultLnRelGnbCellId     value=1

Common Case TestLine Recover
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${MRBTS_ID_enb}/LNBTS-${MRBTS_ID_enb}/LNCEL-1    parameter=defaultLnRelGnbCellId     value=3
