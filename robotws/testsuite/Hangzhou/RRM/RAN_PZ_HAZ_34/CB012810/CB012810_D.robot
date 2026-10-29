*** Settings ***
Documentation      Author:qingqing.zhang@nokia-sbell.com
...                squad group: SG_03
...                feature : CB012810_D

Resource         ./Resources/CB012810_case_step.robot


Suite Setup         Run Keyword     CB012810_suite_setup    If_swconfig=True    reset_site=True    swconfig_modify=${TTI_capture_swconfig}

Suite Teardown      CB012810_suite_teardown

*** Variables ***
${TS_LOG_PATH_BASE}         /home/ute/test_results/
${target_dir}               /home/ute/test_results/
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
    [Tags]
    [Setup]
    CB012810_case_setup
    ...                    online_ModifySCF=True
    ...                    Modify_Para_Online=${Online_Modify_WK3_001}
    UE_and_PA_prepare    gnb_cell1_value=${0}
    Multi UE attach and collect log    tcpdump_filename=${two_UEs_attach}    S22=True    S23=True
    Make a VoNR call and collect log    tcpdump_filename=${VONR_log1}    is_need_TTI=True
     FOR    ${index}    IN RANGE    2    6
         Make a VoNR call and collect log    tcpdump_filename=${VONR_log${index}}
     END
    [Teardown]     Run Keywords    Run Keyword And Ignore Error    IWK3_001_case_recovery
    ...    AND    CB012810_case_teardown

[1]CB012810-D#WK8_003_SgNB_addition_with_multiple_non-GBR_DRBs_with_DRB_priority_PUG_with_NSA_3x_UE_PScell_change
    [Documentation]
    ...    drb PUG HO test
    [Tags]
    [Setup]
    CB012810_case_setup
    ...                    online_ModifySCF=True
    ...                    Modify_Para_Online=${Online_Modify_WK8_003}
    ...                    Delete_Para_Online=${Online_Delete_WK8_003}
    ...                    Add_Para_Online=${Online_Add_WK8_003}
    UE_and_PA_prepare    gnb_cell1_value=${0}
    Multi UE attach and collect log    tcpdump_filename=${S22_attach}    S21=True
    Power UE Start UL traffic    ue_type=${ue_type_samsung}
    ...    ul_throughput=${Send_Tput_UL}    ue_index=${3}
    Trigger HO and collect log    tcpdump_filename=${log_HO}    TTI_name=TTI_HO_1    nr_phy_cell_ids=2
    ...    gnb_cell1_value_HO=${25}    gnb_cell3_value_HO=${0}
    Trigger HO and collect log    tcpdump_filename=${log1_HO}    TTI_name=TTI_HO_2    nr_phy_cell_ids=51
    ...    gnb_cell1_value_HO=${0}    gnb_cell3_value_HO=${25}
    ### check target cell use lowpug
    Analysis tti for ulProGrantType    names=TTI_HO_1    drb_pug=False
    Analysis tti for ulFdSchedData.rrmBufferedDataUlLcg_bytes    names=TTI_HO_1    bufferSize=[0, 0, 0, 0, 0, 0, 0, 64]
    ...    grant=NONSKIPPABLE
    ### check target cell use drbpug
    Analysis tti for ulProGrantType    names=TTI_HO_2
    Analysis tti for ulFdSchedData.rrmBufferedDataUlLcg_bytes    names=TTI_HO_2
#    Analysis tti for SFN same    names=TTI_HO_2
    [Teardown]    Run Keywords    power_ue.UE Detach    ue_type=${ue_type_samsung}    ue_index=${3}
    ...    AND    Run Keyword And Ignore Error    IWK3_001_case_recovery
    ...    AND    CB012810_case_teardown

[1]CB012810-D#B3_001_Online_change_DRB_priority_Proactive_UL_Grant_parameters_for_non-VoNR_UEs_with_UL_tx_skip_capability
    [Documentation]
    ...    drb PUG
    [Tags]
    [Setup]
    CB012810_case_setup
    ...                    online_ModifySCF=True
    ...                    Modify_Para_Online=${Online_Modify_B3_001}
    ...                    Add_Para_Online=${Online_Add_B3_001}
    UE_and_PA_prepare    gnb_cell1_value=${0}
    UE attach and collect TTI    tcpdump_filename=${S22_attach1}    S22=True    TTI_name=TTI_S22_attach
    power_ue.UE Detach    ue_type=${ue_type_samsung}    ue_index=${2}
    UE attach and collect TTI    tcpdump_filename=${MTP_attach}    MTP=True    TTI_name=TTI_MTP_attach_1
    ### check UE1 use lowpug and  UE2 use drbpug
    Analysis tti for ulProGrantType    names=TTI_S22_attach    drb_pug=False
    Analysis tti for ulProGrantType    names=TTI_MTP_attach_1    DrbGrantType=DRBPRIOPUGSKIPPABLEDYNAMIC
    Analysis tti for ulFdSchedData.rrmBufferedDataUlLcg_bytes    names=TTI_MTP_attach_1
    ...    bufferSize=[0, 1500, 0, 0, 0, 0, 0, 0]    grant=DRBPRIOPUGSKIPPABLEDYNAMIC
    ### detech UE2 and UE1 turn on mobile data
    Modify Parameters for Cases   gnb_index=${0}    Modify_Para_Online=${Online_Modify_B3_001_1}
    UE attach and collect TTI    tcpdump_filename=${MTP_attach1}    MTP=True    TTI_name=TTI_MTP_attach_2
    Analysis tti for ulProGrantType    names=TTI_MTP_attach_2    DrbGrantType=DRBPRIOPUGSKIPPABLEDYNAMIC
    Analysis tti for ulFdSchedData.rrmBufferedDataUlLcg_bytes    names=TTI_MTP_attach_2
    ...    bufferSize=[0, 500, 0, 0, 0, 0, 0, 0]    grant=DRBPRIOPUGSKIPPABLEDYNAMIC
#    Analysis tti for SFN same    names=TTI_MTP_data_on    grant=DRBPRIOPUGSKIPPABLEDYNAMIC
    [Teardown]    Run Keywords    power_ue.UE Detach    ue_type=${ue_type_samsung}    ue_index=${2}
    ...    AND    power_ue.UE Detach    ue_type=${ue_type_0}    ue_index=${0}
    ...    AND    CB012810_case_teardown

[1]CB012810-E#IWK2_02_DRB_priority_PUG_interworking_with_UL_split_mode_actProactGrantsUlLteOnlyMode_true_actProactUlSchedulingEnh_true
    [Documentation]
    ...    NSA mode
    [Tags]
    [Setup]
    CB012810_case_setup
    ...                    online_ModifySCF=True
    ...                    Modify_Para_Online=${Online_Modify_IWK2_002_cloud}
    UE_and_PA_prepare    gnb_cell1_value=${0}    enb_cell1_value=${0}
    Prepare with PM counter time to caculate    period=start
    UE NSA attach and collect log    tcpdump_filename=${S23_attach_gnb}    tcpdump_filename_enb=${S23_attach_enb}
    ...    ue_index=${3}
    Samsung start DLUL and collect TTI    TTI_name=TTI_NR_traffic    ue_index=${3}    nr_phy_cell_ids=51
    Wait until keyword succeeds    5 min    10s    Check Counter for DRBPUG
    Prepare with PM counter time to caculate    period=start
    Trigger UL split and collect TTI    TTI_name=TTI_LTE_traffic    nr_phy_cell_ids=51
    Prepare with PM counter time to caculate    period=end
    Wait until keyword succeeds    10 min    10s    Check Counter for DRBPUG    DRBPUG=False
    ###check TTI have drb pug when NSA attach
    Analysis tti for ulProGrantType    names=TTI_NR_traffic
    Analysis tti for ulFdSchedData.rrmBufferedDataUlLcg_bytes    names=TTI_NR_traffic    bufferSize=[0, 100, 0, 0, 0, 0, 0, 0]
    ###check TTI have low pug when UL split to LTE because actProactGrantsUlLteOnlyMode=true
    Analysis tti for ulProGrantType    names=TTI_LTE_traffic    drb_pug=False
    Analysis tti for ulFdSchedData.rrmBufferedDataUlLcg_bytes    names=TTI_LTE_traffic    bufferSize=[0, 0, 0, 0, 0, 0, 0, 64]
    ...    grant=NONSKIPPABLE
    Samsung stop DLUL and detech    ue_index=${3}
    Modify Parameters for Cases   gnb_index=${0}
    ...                    Modify_Para_Online=${Online_Modify_IWK2_002_1}
    Adjust the HBTE attenuation value for 12810    gnb_cell1_value=${0}    enb_cell1_value=${0}
    UE NSA attach and collect log    tcpdump_filename=${S23_attach_gnb_1}    tcpdump_filename_enb=${S23_attach_enb_1}
    ...    ue_index=${3}
    Samsung start DLUL and collect TTI    TTI_name=TTI1_NR_traffic    ue_index=${3}        nr_phy_cell_ids=51
    Trigger UL split and collect TTI    TTI_name=TTI1_LTE_traffic    nr_phy_cell_ids=51
    ###check TTI have drb pug when NSA attach
    Analysis tti for ulProGrantType    names=TTI1_NR_traffic
    ###check TTI have no drbpug and lowpug when UL split to LTE because actProactGrantsUlLteOnlyMode=false
    Analysis tti for ulProGrantType no drbpug and lowpug    names=TTI1_LTE_traffic
    [Teardown]     Run Keywords    Run Keyword And Ignore Error    IWK2_002_case_recovery
    ...    Modify_Para_Online=${Online_Modify_IWK2_002_cloud_recover}    ue_index=${3}
    ...    AND    CB012810_case_teardown
