*** Settings ***
Documentation
...    maintainer: Beata Kapusta, Marcin Trebunia
...    author: Mateusz Pajor, Mateusz Lesniak
...    contact: I_CD_ET_TESTERS@internal.nsn.com
...    description: CB008746-A SPID based NSA slicing for FR1, CB008746-C Interaction with MU-MIMO

Resource    CB008746_A_C_resources/common_keywords.robot
Resource    ../resources/common_configuration.robot

Suite Setup         Suite Setup

Test Setup          Test Setup
Test Teardown    Run Keywords    Send Configuration ID To Scout
    ...    AND    Test Teardown

*** Test Cases ***
CB008746-A-IWK701_005_SPID_based_slicing_for_NSA_and_SA_SPID_based_slicing_with_CA_interworking_TDD
    [Tags]    CRT    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
    [Setup]    Test Setup
    ...    delta_path=${DELTA_TC05}
    ...    nr_ue_caps=${UE_CAP_TC05}
    ...    mrdc_ue_caps=${MRDC_UE_CAPS_TC05}
    ...    target_number_of_nsa_ues=2
    ...    target_number_of_sa_ues=1
    ...    arfcn_gscn_change=${True}
    ...    net_arch=NSA
    ...    sib_reception_dict=${CA_CELL_SIB_RECEPTION_DICT}
    ...    syscom_validation_path=${SYSCOM_VALIDATION_TC05}
    ...    carrier_aggregation=${True}
    ...    gscn_value={'2': '7950'}
    Attach Sa Ues To According Nwslices
    ...    sa_ues=(1,)
    ...    nwslices=(1,)
    Attach Nsa Ues With Spid Parameter
    ...    nsa_ues=(101,102)
    ...    spids=(22,22)
    Perform Traffic On Different Times For Ues
    ...    sa_ues=(1,)
    ...    qfi_sa=(1,)
    ...    nsa_ues=(101,102)
    ...    traffic_bearers=(2,2)
    ...    dl_tput=175
    ...    traffics_per_bearer=8
    ...    traffics_per_qfi=8
    Collect TTI Traces Sample
    ...    cell_ids=${CELL_IDS_1_2}
    Wait For PM Counters From Full Period With Traffic To Appear In WebEM
    Verify Scell Addition Counters
    ...    scell_addition_ues=2
    Validate CA Syslog Prints
    pm_counters.Validate Slice Scheduler Counters
    ...    resource_groups_nsa_sa={'NSA': (1,), 'SA': (2,)}
    ...    nrresourcegroup_values={'1':(1,2)}
    [Teardown]    Test Teardown
    ...    carrier_aggregation=${True}

CB008746-A-B410_017_combination_of_NRSPIDGRPs_NRRESOURCEGROUPs_online_changes
    [Tags]    CDRT    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
    [Setup]    Test Setup
    ...    delta_path=${DELTA_TC17}
    ...    target_number_of_nsa_ues=7
    ...    target_number_of_sa_ues=3
    ...    snssai=('0x02', '0x03')
    ...    reconfigure_sa_ue_to_second_plmn=(52,53)
    ...    reconfigure_nsa_ue_to_second_plmn=(154,155,157)
    ...    plmn=312:490
    ...    sib_reception_dict=${ALL_CELLS_SIB_RECEPTION_DICT}
    ...    syscom_validation_path=${SYSCOM_VALIDATION_TC17}
    ...    cell_id=52
    Attach Sa Ues To According Nwslices
    ...    sa_ues=(51,52,53)
    ...    nwslices=(1,2,3)
    ...    local_cell=3
    Attach Nsa Ues With Spid Parameter
    ...    nsa_ues=(151,152,153,154)
    ...    spids=(1,1,41,61)
    ...    second_plmn_ues=(154,)
    ...    target_cells=3
    Perform Traffic On Different Times For Ues
    ...    sa_ues=(51,52,53)
    ...    qfi_sa=(1,1,1)
    ...    nsa_ues=(151,152,153,154)
    ...    traffic_bearers=(2,2,2,2)
    ...    dl_tput=90
    ...    traffics_per_bearer=1
    Collect TTI Traces Sample
    ...    cell_ids=${CELL_IDS_3}
    Wait For PM Counters From Full Period With Traffic To Appear In WebEM
    pm_counters.Validate Slice Scheduler Counters
    ...    resource_groups_nsa_sa={'NSA': (1,2,3), 'SA': (5,6,7)}
    ...    nrresourcegroup_values={'1':(1,2,3,5,6,7)}
    ...    cell=3
    Perform Online Parameter Change
    Attach Nsa Ues With Spid Parameter
    ...    nsa_ues=(155,156,157)
    ...    spids=(11,1,None)
    ...    second_plmn_ues=(155,157)
    ...    target_cells=3
    Perform Traffic On Different Times For Ues
    ...    nsa_ues=(155,156,157)
    ...    traffic_bearers=(2,2,2)
    ...    traffics_per_bearer=1
    ...    dl_tput=90
    Collect TTI Traces Sample
    ...    cell_ids=${CELL_IDS_3}
    ...    filename=tti_after_online_change.pcap
    Wait For PM Counters From Full Period With Traffic To Appear In WebEM
    pm_counters.Validate Slice Scheduler Counters
    ...    resource_groups_nsa_sa={'NSA': (2,3,4), 'SA': (5,6,7)}
    ...    nrresourcegroup_values={'1':(2,3,4,5,6,7)}
    ...    cell=3

CB008746-C-B101_020_Interaction_with_MU-MIMO_and_nonGBR_UEs_TDD
    [Tags]    CDRT    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
    [Setup]    Test Setup
    ...    delta_path=${DELTA_TC20}
    ...    target_number_of_nsa_ues=7
    ...    plmn=${MU_MIMO_SECOND_PLMN_MCC_MNC}
    ...    bearers=${MU_MIMO_NSA_BEARER}
    ...    reconfigure_nsa_ue_to_second_plmn=(105,106,107)
    ...    mu_mimo=${True}
    ...    remove_cell=(2,3,4)
    ...    sib_reception_dict=${NSA_ONLY_SIB_RECEPTION_DICT}
    ...    syscom_validation_path=${SYSCOM_VALIDATION_TC20}
    Attach Nsa Ues With Spid Parameter
    ...    nsa_ues=(101,102,104,105,106,103,107)
    ...    spids=(21,21,61,41,41)
    ...    second_plmn_ues=(105,106,107)
    ...    bearers=(2,3)
    ...    ues_with_additional_bearer=(101,102,103,104,105,106,107)
    Perform Individual Traffic For Ues
    ...    specific_traffic_params=${MU_MIMO_TRAFFIC_PARAMS_TC20}
    Collect TTI Traces Sample
    Wait For PM Counters From Full Period With Traffic To Appear In WebEM
    Validate Enh MU MIMO Counters
    Validate PDSCH Transmissions
    pm_counters.Validate Slice Scheduler Counters
    ...    resource_groups_nsa_sa={'NSA': (1,2,3)}
    ...    nrresourcegroup_values={'1':(1,2,3)}
    [Teardown]    Test Teardown
    ...    mu_mimo=${True}

CB008746-C-B103_022_Interaction_with_MU-MIMO_and_CA_TDD
    [Tags]    CLOUD_5G_I_BOO_AP_LOO    VARIANT_NSA_ECPRI_CMWV_TDD_2CC_MU_MIMO
    [Setup]    Test Setup
    ...    sib_reception_dict=${NSA_ONLY_SIB_RECEPTION_DICT}
    ...    syscom_validation_path=${SYSCOM_VALIDATION_TC22}
    ...    TC22=${True}
    Activate Advanced Srs For Ues
    Attach Nsa Ues With Spid Parameter
    ...    nsa_ues=(101,102,103,104,105,106)
    ...    spids=(21,21,21,86,86,86)
    ...    second_plmn_ues=(104,105,106)
    Perform Individual Traffic For Ues
    ...    specific_traffic_params=${MU_MIMO_TRAFFIC_PARAMS_TC22}
    Collect TTI Traces Sample
    ...    cell_ids=${CELL_IDS_1_2}
    Wait For PM Counters From Full Period With Traffic To Appear In WebEM
    Validate Enh MU MIMO Counters
    ...    nr_layers=8
    Validate PDSCH Transmissions
    ...    rank_adaptation=${True}
    Verify Scell Addition Counters
    Validate CA Syslog Prints
    pm_counters.Validate Slice Scheduler Counters
    ...    resource_groups_nsa_sa={'NSA': (1,2)}
    ...    nrresourcegroup_values={'0':(1,2)}
    pm_counters.Validate Slice Scheduler Counters
    ...    resource_groups_nsa_sa={'NSA': (1,2)}
    ...    nrresourcegroup_values={'0':(1,2)}
    ...    cell=2
