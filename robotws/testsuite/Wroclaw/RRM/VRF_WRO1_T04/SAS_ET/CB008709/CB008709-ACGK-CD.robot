*** Settings ***
Documentation
...              author: Damian Zak
...              maintainer: Damian Zak, Beata Kapusta
...              contact: damian.zak@nokia.com, beata.kapusta@nokia.com
...              description:CB008709-A Single RG per UE for UL SAS
...                          CB008709-C Multiple RGs per UE for UL SAS
...                          CB008709-G Interaction with GBR services
...                          CB008709-K Online RG reconfiguration
...              topology: CLOUD_5G_I_LO_AP_LO
...              variant: SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

Resource         resources/ET_common_keywords.robot
Resource         ../resources/common_configuration.robot
Variables        resources/variables.py

Suite Setup      Suite Environment Preparation
Test Teardown    Run Keywords    Send Configuration ID To Scout
    ...    AND    Test Environment Teardown

*** Test Cases ***
CB008709-A-B121_004_Many_RGs_and_VoNR_GBR_traffic_FDD_SA
    [Setup]    Common Test Environment Preparation    sas_configuration_data=${SAS_DELTA_A_004}
    ...    test_delta=${CB008709_A_TC004_DELTA}    wts_config=${TC004_A_WTS_CONFIG_CD}
    Perform 5G SA Attach
    ...    ue_ids=(51,52,53,54,55,56,57,58,59,60)
    ...    slices=(1,1,2,2,1,1,1,1,1,1)
    ...    qosflows=((2,3),None,(2,3,4),None,(2,3),(2,3),(2,3),(2,3),(2,3),(2,3))
    ...    cell=3
    ...    vonr_support=${True}
    Start SA Traffic
    ...    ue_ids=(52,53,53)
    ...    mbps=(110,60,60)
    ...    qfi=(1,1,4)
    ...    first_trf_id=(1,31,32)
    Start VoNR Traffic
    ...    ue_ids=(51,53,55,56,57,58,59,60)
    ...    qfi=3
    Wait For SAS PM Counters And Collect TTI
    Validate Data Volume Per 5qi
    ...    qos_groups_expected_values={1:144000, 6: ">0", 7: ">0"}
    Validate Target Shares    sas_delta=${SAS_DELTA_A_004}
    Start SA Traffic
    ...    ue_ids=(53,53,54)
    ...    mbps=(40,40,40)
    ...    qfi=(1,4,1)
    ...    first_trf_id=(31,32,1)
    ta5g_pm_counters.Wait For Next Full Pm Interval
    Validate Data Volume Per 5qi
    ...    qos_groups_expected_values={1:144000, 6: ">0", 7: ">0"}
    Validate Target Shares    sas_delta=${SAS_DELTA_A_004}

CB008709-G-EC201_011_UL_SAS_with_excessive_GBR_load_TDD_SANSA
    [Setup]    Common Test Environment Preparation    sas_configuration_data=${SAS_DELTA_G_011}
    ...        wts_config=${TC011_G_WTS_CONFIG_CD}    test_delta=${CB008709_G_TC011_DELTA}
    Setup X2 Link And Wait For Mib Reception
    Perform 5G SA Attach
    ...    ue_ids=(1,2,3,4,5,6,7,8,9,10,11,12)
    ...    slices=(1,1,2,2,2,3,3,4,4,5,3,3)
    ...    qosflows=(None,None,None,None,None,(2,3),(4,),None,None,None,(4,),(4,))
    ...    cell=1
    ...    vonr_support=${True}
    Perform 5G NSA Attach
    ...    ue_ids=(101,102,103,104,105)
    ...    spids=(1,2,15,15,25)
    ...    plmn=('311:489','311:489','312:490','312:490','312:490')
    ...    cell=1
    Start VoNR Traffic
    ...    ue_ids=(6,)
    ...    qfi=3
    Start SA Traffic
    ...    ue_ids=(1,2,3,4,5,6,7,8,9,10)
    ...    mbps=(5,5,5,5,5,5,5,30,30,30)
    ...    first_trf_id=(1,1,1,1,1,31,1,1,1,1)
    Start SA Traffic
    ...    ue_ids=(7,11,12)
    ...    mbps=(30,30,20)
    ...    qfi=(2,2,2)
    ...    first_trf_id=(2,2,2)
    Start NSA Traffic
    ...    ue_ids=(101,102,103,104,105)
    ...    mbps=(30,25,5,5,20)
    Wait For SAS PM Counters And Collect TTI
    Validate Target Shares    sas_delta=${SAS_DELTA_G_011}
    ...     excessive_gbr_groups=(2,)
    ...     excessive_gbr=True
    ...     custom_expected_ts=${CUSTOM_RG_TS_011}
    Validate Data Volume Per 5qi
    ...    qos_groups_expected_values={6: ">0", 9: ">0"}
    ...    plmn_id=1
    Validate Data Volume Per 5qi
    ...    qos_groups_expected_values={1: 18000, 2: 200000, 6: ">0", 9: ">0"}
    ...    plmn_id=2

CB008709-K-B104_014_UL_RGs_resources_changed_online_NRSPIDGRP_under_RG_TDD_NSA
    [Setup]    Common Test Environment Preparation    sas_configuration_data=${SAS_DELTA_K_014}
    ...     sib_reception_dict=${NSA_SIB_RECEPTION_DICT}
    Setup X2 Link And Wait For Mib Reception
    Perform 5G NSA Attach
    ...    ue_ids=(101,102,103,104,105,106)
    ...    spids=(21,41,61,81,101,None)
    ...    plmn=('311:489','311:489','312:490','312:490','312:490','312:490')
    ...    cell=1
    Start NSA Traffic
    ...    ue_ids=(101,102,103,104,105,106)
    ...    mbps=(40,40,40,45,65,40)
    Wait For SAS PM Counters And Collect TTI
    Validate Target Shares    sas_delta=${SAS_DELTA_K_014}
    Perform Webem Online Parameter Change    delta=${CB008709_K_TC014_ONLINE_CHANGE_DELTA}
    Perform 5G NSA Attach
    ...    ue_ids=(107,108,109,110)
    ...    spids=(101,61,None,None)
    ...    plmn=312:490
    ...    cell=1
    Start NSA Traffic
    ...    ue_ids=(107,108,109,110)
    ...    mbps=(40,40,40,40)
    Wait For SAS PM Counters And Collect TTI
    Validate Target Shares    sas_delta=${SAS_DELTA_K_014}

CB008709-K-B104_015_UL_RGs_resources_changed_online_SNSSAI_NRSPIDGRP_under_RG_FDD_SANSA
    [Setup]    Common Test Environment Preparation    sas_configuration_data=${SAS_DELTA_K_015}
    ...    wts_config=${TC015_K_WTS_CONFIG_CD}
    Setup X2 Link And Wait For Mib Reception
    Perform 5G SA Attach
    ...    ue_ids=(51,52,53,54,55,56,57,58)
    ...    slices=(1,2,3,4,5,6,7,7)
    ...    cell=3
    Perform 5G NSA Attach
    ...    ue_ids=(151,152,153,154,155,156,157,158)
    ...    spids=(21,41,61,81,101,121,None,None)
    ...    plmn=('311:489','311:489','311:489','312:490','312:490','312:490','312:490','312:490')
    ...    cell=3
    Start SA Traffic
    ...    ue_ids=(51,52,53,54,55,56,57,58)
    ...    mbps=(50,50,50,50,100,100,100,100)
    Start NSA Traffic
    ...    ue_ids=(151,152,153,154,155,156,157,158)
    ...    mbps=(50,50,50,50,100,100,100,100)
    Wait For SAS PM Counters And Collect TTI
    Validate Target Shares    sas_delta=${SAS_DELTA_K_015}
    Perform Webem Online Parameter Change    delta=${CB008709_K_TC015_ONLINE_CHANGE_DELTA}
    Perform 5G SA Attach
    ...    ue_ids=(59,60)
    ...    slices=(3,6)
    ...    cell=3
    Perform 5G NSA Attach
    ...    ue_ids=(159,160)
    ...    spids=(61,121)
    ...    plmn=('311:489','312:490')
    ...    cell=3
    Start SA Traffic
    ...    ue_ids=(59,60)
    ...    mbps=(100,50)
    Start NSA Traffic
    ...    ue_ids=(159,160)
    ...    mbps=(50,50)
    Wait For SAS PM Counters And Collect TTI
    Validate Target Shares    sas_delta=${SAS_DELTA_K_015}

CB008709-K-B107_024_Online_change_default_RG_per_PLMN_TDD_SANSA
    [Setup]    Common Test Environment Preparation    sas_configuration_data=${SAS_DELTA_K_024}
    ...    wts_config=${TC024_K_WTS_CONFIG_CD}
    Setup X2 Link And Wait For Mib Reception
    Perform 5G SA Attach
    ...    ue_ids=(1,2,3,4,5,6)
    ...    slices=(1,2,3,4,5,6)
    ...    cell=1
    Perform 5G NSA Attach
    ...    ue_ids=(101,102,103,104,105,106,107)
    ...    spids=(21,41,None,61,81,101,None)
    ...    plmn=('311:489','311:489','311:489','312:490','312:490','312:490','312:490')
    ...    cell=1
    Start SA Traffic
    ...    ue_ids=(1,2,3,4,5,6)
    ...    mbps=(50,50,50,50,50,50)
    Start NSA Traffic
    ...    ue_ids=(101,102,103,104,105,106,107)
    ...    mbps=(50,50,50,50,50,50,50)
    Wait For SAS PM Counters And Collect TTI
    Validate Target Shares    sas_delta=${SAS_DELTA_K_024}
    Perform Webem Online Parameter Change    delta=${CB008709_K_TC024_ONLINE_CHANGE_DELTA}
    Perform 5G SA Attach
    ...    ue_ids=(7,8)
    ...    slices=(5,6)
    ...    cell=1
    Perform 5G NSA Attach
    ...    ue_ids=(108,109)
    ...    spids=(None,None)
    ...    plmn=('311:489','312:490')
    ...    cell=1
    Start SA Traffic
    ...    ue_ids=(7,8)
    ...    mbps=(50,50)
    Start NSA Traffic
    ...    ue_ids=(108,109)
    ...    mbps=(50,50)
    Wait For SAS PM Counters And Collect TTI
    Validate Target Shares    sas_delta=${SAS_DELTA_K_024}

CB008709-K-B201_031_DL_and_UL_SAS_with_RG_configuration_change_via_online_modification_NSA_FDD
    [Setup]    Common Test Environment Preparation    sas_configuration_data=${SAS_DELTA_K_031}
    ...     sib_reception_dict=${NSA_SIB_RECEPTION_DICT}    wts_config=${TC031_K_WTS_CONFIG_CD}
    Setup X2 Link And Wait For Mib Reception
    Perform 5G NSA Attach
    ...    ue_ids=(151,152,153,154,155,156,157,158,159)
    ...    spids=(21,41,61,81,None,101,121,141,None)
    ...    plmn=('311:489','311:489','311:489','311:489','311:489','312:490','312:490','312:490','312:490')
    ...    cell=3
    Start NSA Traffic
    ...    ue_ids=(151,152,153,154,155,156,157,158,159)
    ...    mbps=(40,15,20,30,15,40,40,40,40)
    ...    direction=ul
    Start NSA Traffic
    ...    ue_ids=(151,152,153,154,155,156,157,158,159)
    ...    mbps=(30,20,20,30,20,30,30,40,40)
    ...    direction=dl
    Wait For SAS PM Counters And Collect TTI
    Validate Target Shares    sas_delta=${SAS_DELTA_K_031}    traffic_dir=ul
    Validate Target Shares    sas_delta=${SAS_DELTA_K_031}    traffic_dir=dl
    Perform Webem Online Parameter Change    delta=${CB008709_K_TC031_1_ONLINE_CHANGE_DELTA}
    Perform 5G NSA Attach
    ...    ue_ids=(160,161)
    ...    spids=(61,81)
    ...    plmn=311:489
    ...    cell=3
    Start NSA Traffic
    ...    ue_ids=(160,161,153,154)
    ...    mbps=(20,10,10,20)
    ...    direction=ul
    Start NSA Traffic
    ...    ue_ids=(160,161,153,154)
    ...    mbps=(20,10,10,20)
    ...    direction=dl
    Wait For SAS PM Counters And Collect TTI
    Validate Target Shares    sas_delta=${SAS_DELTA_K_031}    traffic_dir=ul
    Validate Target Shares    sas_delta=${SAS_DELTA_K_031}    traffic_dir=dl
    Perform Webem Online Parameter Change    delta=${CB008709_K_TC031_2_ONLINE_CHANGE_DELTA}
    Perform 5G NSA Attach
    ...    ue_ids=(162,163,164,165)
    ...    spids=(21,21,101,101)
    ...    plmn=('311:489','312:490','311:489','312:490')
    ...    cell=3
    Start NSA Traffic
    ...    ue_ids=(162,163,164,165,152,151,156,158,159)
    ...    mbps=(20,20,20,35,20,20,20,35,35)
    ...    direction=ul
    Start NSA Traffic
    ...    ue_ids=(162,163,164,165,152,151,156,158,159)
    ...    mbps=(20,20,20,35,20,20,20,35,35)
    ...    direction=dl
    Wait For SAS PM Counters And Collect TTI
    Validate Target Shares    sas_delta=${SAS_DELTA_K_031}    traffic_dir=ul
    Validate Target Shares    sas_delta=${SAS_DELTA_K_031}    traffic_dir=dl
    Perform Webem Online Parameter Change    delta=${CB008709_K_TC031_3_ONLINE_CHANGE_DELTA}
    Perform 5G NSA Attach
    ...    ue_ids=(166,167,168,169)
    ...    spids=(161,161,181,181)
    ...    plmn=('312:490','311:489','312:490','311:489')
    ...    cell=3
    Start NSA Traffic
    ...    ue_ids=(166,167,168,169,158,159,165,162,152)
    ...    mbps=(20,15,15,10,20,20,20,10,10)
    ...    direction=ul
    Start NSA Traffic
    ...    ue_ids=(166,167,168,169,158,159,165,162,152)
    ...    mbps=(20,15,15,10,20,20,20,10,10)
    ...    direction=dl
    Wait For SAS PM Counters And Collect TTI
    Validate Target Shares    sas_delta=${ONLINE_CHANGE_3_SAS_DELTA_K_031}    traffic_dir=ul
    Validate Target Shares    sas_delta=${ONLINE_CHANGE_3_SAS_DELTA_K_031}    traffic_dir=dl
    Perform Webem Online Parameter Change    delta=${CB008709_K_TC031_4_ONLINE_CHANGE_DELTA}
    Perform 5G NSA Attach
    ...    ue_ids=(170,171,172)
    ...    spids=(201,None,121)
    ...    plmn=312:490
    ...    cell=3
    Start NSA Traffic
    ...    ue_ids=(170,171,172,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169)
    ...    mbps=(5,5,5,13,7,7,13,7,13,5,70,5,13,7,7,13,13,5,5,13,13,7)
    ...    direction=ul
    Start NSA Traffic
    ...    ue_ids=(170,171,172,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169)
    ...    mbps=(4,4,4,12,6,6,12,6,12,4,64,4,12,6,6,12,12,4,4,12,12,6)
    ...    direction=dl
    Wait For SAS PM Counters And Collect TTI
    Validate Target Shares    sas_delta=${ONLINE_CHANGE_4_SAS_DELTA_K_031}    traffic_dir=ul    margin=4
    Validate Target Shares    sas_delta=${ONLINE_CHANGE_4_SAS_DELTA_K_031}    traffic_dir=dl    margin=4
