*** Settings ***
Documentation   CIT regression

Force Tags    CA_5G_RRM   STATE_SW_UPLOADED   RAN_5G   RAN_5G_FDD   RAN_5G_FDD_MP   RAN_5G_MP   RAN_5G_FDD_MP_CUSTOMER
...           CIT   CLOUD_5G_CLASSICAL_SA_ANDROID_ASIB_ABIO_3xAHLOA_ENB
...           SBTS00

Resource        taf/rfrl/common_resources/common_step/interface.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/5GC002481/AGBL/E/resources/keywords_1796_EB.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_CB008238/D/resources/keywords_8238_D.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB007564/resources/keywords_7564_AB.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/5GC000774/A/resources/keywords_774_A.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_CB008238/B/resources/keywords_8238_B.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/reports/reporting_portal.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB008116/resources/keywords_8116.robot
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/btslog.py          WITH NAME    t166_cit_btslog
Library         testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.testline_preparation    WITH NAME    testline_preparation
Library         taf.ccs.aashell
Library         testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.hanging_resources.ResourceUsage     ${False}

Suite Setup       Run keywords   initialise_attenuator

Suite Teardown    Run keyword and ignore error   interface.Common step trigger


*** Test Cases ***
5GC000774_A_01_Successful_setup_of_Voice_over_NR_call_with_ROHC_enabled_FDD
    [Documentation]   This TC verifies whether VoNR with ROHC enabled is established correctly. FDD
    [Tags]   SBTS22R3   SBTS22R4   SBTS23R1
    [Setup]       Run Keywords
    ...           nullify_attenuation_on_all_ports
    5GC000774_A_01_Successful_setup_of_Voice_over_NR_call_with_ROHC_enabled_FDD
    [Teardown]   Run Keywords
    ...           Detach UE    UE_1                                AND
    ...           Detach UE    UE_2                                AND
    ...           AdminUtils.Unlock All Cells                     AND
    ...           774_A_btslog.teardown_btslog                      AND
    ...           Run Keyword and Ignore Error    Add scout external execution id to the reporting portal

CB007564-B_3_NG_FLOW_REL_GNB_UE_INACTIVITY_incrementation_with_UE_Context_released_due_to_DRB_inactivity
    [Documentation]   This test case verifies incrementation of counter provided to measure number QoS Flow release
     ...              when gNB initiated Ue Context Release due to DRB inactivity.
    [Tags]   SBTS22R3   SBTS22R4   SBTS23R1
    [Setup]       Run Keywords
     ...           nullify_attenuation_on_all_ports                 AND
     ...           t166_cit_btslog.start_btslog_on_local_machine
    CB007564-B_3_NG_FLOW_REL_GNB_UE_INACTIVITY_incrementation_with_UE_Context_released_due_to_DRB_inactivity
    [Teardown]    Run Keywords
     ...           t166_cit_btslog.teardown_btslog                  AND
     ...           nullify_attenuation_on_all_ports  AND
    ...         Run Keyword and Ignore Error    Add scout external execution id to the reporting portal

5GC001796_EB_TC46_UL_LA_64QAM-table_PTRS-ON_from_Near_to_Edge_Cell_radio_condition_SingleTX_BW-20MHz_SA
    [Documentation]    Check good table mapping
    [Tags]   SBTS22R3   SBTS22R4   SBTS23R1
    [Setup]      Run Keywords
    ...          nullify_attenuation_on_all_ports                 AND
    ...          t166_cit_btslog.start_btslog_on_local_machine
    5GC002481_AGBL_5GC001796_EB_TC46_UL_LA_64QAM-table_PTRS-ON_from_Near_to_Edge_Cell_radio_condition_SingleTX_BW-20MHz_SA
    [Teardown]   Run Keywords
    ...          Detach UE    UE_1                                AND
    ...          t166_cit_btslog.teardown_btslog                  AND
    ...          teardown_tti_traces_in_streaming_mode            AND
    ...          nullify_attenuation_on_all_ports  AND
    ...         Run Keyword and Ignore Error    Add scout external execution id to the reporting portal

CB008238-5G-B_2_Multi-UE_SA_DTX_interactions_with_non_GBR_traffic
    [Documentation]   This TC shall verify optimized DTX for mutli UE scenario
    [Tags]   CDRT    SBTS22R4   SBTS23R1
    keywords_8238_B.CB008238-5G-B_2_Multi-UE_SA_DTX_interactions_with_non_GBR_traffic
    [Teardown]  Run Keywords
    ...         keywords_8238_B.TC_teardown_B_2  AND
    ...         Run Keyword and Ignore Error    Add scout external execution id to the reporting portal

CB008238-5G-D_01_DTX_Scheduler_Enabling_Disabling_Based_On_Ues_In_C1_List
    [Documentation]  This TC verifies whether rdDtxCS1SizeThreshold can be reached for 2 UEs
    [Tags]   CDRT    SBTS22R4
    keywords_8238_D.CB008238-5G-D_01_DTX_Scheduler_Enabling_Disabling_Based_On_Ues_In_C1_List
    [Teardown]  Run Keywords
    ...         keywords_8238_D.TC_teardown_D_1   AND
    ...         Run Keyword and Ignore Error    Add scout external execution id to the reporting portal

CB008238-5G-B_4_Multi-UE_interactions_with_delay_sensitive_data_(VoNR)
    [Documentation]   This TC shall verify optimized DTX for mutli UE scenario with VoNr data flow
    keywords_8238_B.CB008238-5G-B_4_Multi-UE_interactions_with_delay_sensitive_data_(VoNR)
    [Tags]   SBTS22R4
    [Teardown]   Run Keywords
    ...         keywords_8238_B.TC_teardown_B_4  AND
    ...         Run Keyword and Ignore Error    Add scout external execution id to the reporting portal

CB008116-A_1_Integrity_Protection_in_DL_with_AES_IP_algorithm_ASIB_ABIO
    [Documentation]   This test case describes the behavior of Nokia gNB in SA mode for the successful setup
     ...              and operation of integrity protection for user plane traffic at any data rate,
     ...              up to and including, the highest data rate supported by the 5G-UE in DL direction and AES IP algorithm.
    CB008116-A_1_Integrity_Protection_in_DL_with_AES_IP_algorithm_ASIB_ABIO
