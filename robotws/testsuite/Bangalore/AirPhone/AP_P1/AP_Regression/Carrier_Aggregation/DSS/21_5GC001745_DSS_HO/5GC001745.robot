*** Settings ***
Documentation     author: Rakshitha
...               contact: rakshitha.r@nokia.com
...               Description:

Resource        ../../DSS_Common_Keywords.robot

Suite Setup       Suite Setup    feature_folder=DSS_HO

*** Variables ***
${WTS_FILE}                      basic_setup.lua
${WTS_CFG_PATH}                  ${CURDIR}/../../Config_Files/21_5GC001745_DSS_HO/wts
${dl_tput}                       20
${ul_tput}                       20
@{SA_UE_List}                    1    81
@{NSA_UE_List}                   11    91
@{SA_Scell_Index}                0
${EDAEMON_PORT}                  50000
@{DSS_SA_UE}                     41
@{DSS_NSA_UE}                    51
@{DSS_SA_UE_List}                1    81    41
@{DSS_NSA_UE_List}               11    91    51
@{nsa_ue_list1}                  11
@{nsa_ue_list2}                  91

*** Test Cases ***
5GC001745_TC1 SA_DSS_HO Verify Intra gnb HO from DSS to Non DSS and vice_versa and also DSS to DSS
    [Documentation]    Verify Intra gnb HO SA from Non DSS to DSS and vice_versa and also DSS to DSS
    [Tags]    AP_REG    1745_TC1_SA_DSS    AP_P1
    [Setup]    Run Keywords    Copy custom config files
    ...    AND    Test setup for DSS    ${noofcells}    ${WTS_FILE}    ${EDAEMON_PORT}
    Register and Start Traffic For SA UEs    ${SA_UE_List}    uplink_tput=${ul_tput}    downlink_tput=${dl_tput}
    Validate Bearer Stats for multiple UEs    ue_list=${SA_UE_List}    expected_dl_tput=${dl_tput}    expected_ul_tput=${ul_tput}    mode=SA
    Validate UE stats for multiple UEs    ${SA_UE_List}    ${dl_tput}    ${ul_tput}    scell=${SA_Scell_Index}
    Log To Console    UE-1 Intra-gNB HO from Non-DSS to DSS
    Trigger Intrafreq Based SA Forward handover    ue_id=1
    Validate throughput from bearer stats    ue_id=1    expected_dl_tput=${dl_tput}    expected_ul_tput=${ul_tput}    mode=SA
    Log To Console    Intra-gNB Reverse HO from DSS to Non-DSS
    Trigger Intrafreq Based SA Reverse handover    ue_id=1
    Validate throughput from bearer stats    ue_id=1    expected_dl_tput=${dl_tput}    expected_ul_tput=${ul_tput}    mode=SA
    Log To Console    UE-81 Intra-gNB HO from DSS to Non-DSS
    Trigger Intrafreq Based SA Forward handover    ue_id=81    primary_cell=3    sim_cell=1    phycell_id=50
    Validate throughput from bearer stats    ue_id=81    expected_dl_tput=${dl_tput}    expected_ul_tput=${ul_tput}    mode=SA
    Log To Console    Intra-gNB Reverse HO from Non-DSS to DSS
    Trigger Intrafreq Based SA Reverse handover    ue_id=81    sim_cell=1    primary_cell=3     phycell_id=52
    Validate throughput from bearer stats    ue_id=81    expected_dl_tput=${dl_tput}    expected_ul_tput=${ul_tput}    mode=SA
    Stop Traffic and Detach SA UEs    ${SA_UE_List}
    Log To Console    DSS to DSS scenario
    Register and Start Traffic For SA UEs    ${DSS_SA_UE}    uplink_tput=${ul_tput}    downlink_tput=${dl_tput}
    Validate throughput from bearer stats    ue_id=41    expected_dl_tput=${dl_tput}    expected_ul_tput=${ul_tput}    mode=SA
    Validate UE stats for multiple UEs    ${DSS_SA_UE}    ${dl_tput}    ${ul_tput}    scell=${SA_Scell_Index}
    Log To Console    UE-41 Intra-gNB HO from DSS to DSS
    Trigger Intrafreq Based SA Forward handover    ue_id=41    sim_cell=1    primary_cell=2    phycell_id=50
    Validate throughput from bearer stats    ue_id=41    expected_dl_tput=${dl_tput}    expected_ul_tput=${ul_tput}    mode=SA
    Log To Console    Intra-gNB Reverse HO
    Trigger Intrafreq Based SA Reverse handover    ue_id=41    sim_cell=1    primary_cell=2    phycell_id=51
    Validate throughput from bearer stats    ue_id=41    expected_dl_tput=${dl_tput}    expected_ul_tput=${ul_tput}    mode=SA
    Stop Traffic and Detach SA UEs    ${DSS_SA_UE}
    Run Keyword And Ignore Error    Collect and Validate Gnb PM counters    ${SA_UE_List}
    [Teardown]    Test Teardown    ${DSS_SA_UE_List}    handover=True

5GC001745_TC2 NSA_DSS_HO Verify Intra gnb HO from DSS to Non DSS and vice_versa and also DSS to DSS
    [Documentation]    Verify Intra gnb HO NSA from Non DSS to DSS and vice_versa and also DSS to DSS
    [Tags]    AP_REG    1745_TC2_NSA_DSS
    [Setup]    Test setup for DSS    ${noofcells}    ${WTS_FILE}    ${EDAEMON_PORT}
    Attach and Start Traffic For NSA UEs    nsa_ue_list=${nsa_ue_list1}    uplink_tput=${ul_tput}    downlink_tput=${dl_tput}    target_cells=1
    Attach and Start Traffic For NSA UEs    nsa_ue_list=${nsa_ue_list2}    uplink_tput=${ul_tput}    downlink_tput=${dl_tput}    target_cells=3
    Validate Bearer Stats for multiple UEs    ue_list=${NSA_UE_List}    expected_dl_tput=${dl_tput}    expected_ul_tput=${ul_tput}    mode=NSA
    Log To Console    UE-11 Intra-gNB forward HO from Non-DSS to DSS
    Trigger Intrafreq Based NSA Forward handover    ue_id=11
    Validate throughput from bearer stats    ue_id=11    expected_dl_tput=${dl_tput}    expected_ul_tput=${ul_tput}    mode=NSA
    Log To Console    Intra-gNB Reverse HO from DSS to Non-DSS
    Trigger Intrafreq Based NSA Reverse handover    ue_id=11
    Validate throughput from bearer stats    ue_id=11    expected_dl_tput=${dl_tput}    expected_ul_tput=${ul_tput}    mode=NSA
    Log To Console    UE-91 Intra-gNB HO from DSS to Non-DSS
    Trigger Intrafreq Based NSA Forward handover    ue_id=91    primary_cell=3    sim_cell=1    phycell_id=50
    Validate throughput from bearer stats    ue_id=91    expected_dl_tput=${dl_tput}    expected_ul_tput=${ul_tput}    mode=NSA
    Log To Console    Intra-gNB Reverse HO from Non-DSS to DSS
    Trigger Intrafreq Based NSA Reverse handover    ue_id=91    sim_cell=1    primary_cell=3     phycell_id=52
    Validate throughput from bearer stats    ue_id=91    expected_dl_tput=${dl_tput}    expected_ul_tput=${ul_tput}    mode=NSA
    Stop Traffic and Detach NSA UEs    ${NSA_UE_List}
    Log To Console    DSS to DSS scenario
    Attach and Start Traffic For NSA UEs    ${DSS_NSA_UE}    uplink_tput=${ul_tput}    downlink_tput=${dl_tput}
    Validate throughput from bearer stats    ue_id=51    expected_dl_tput=${dl_tput}    expected_ul_tput=${ul_tput}    mode=NSA
    Log To Console    UE-51 Intra-gNB HO from DSS to DSS
    Trigger Intrafreq Based NSA Forward handover    ue_id=51    sim_cell=1    primary_cell=2    phycell_id=50
    Validate throughput from bearer stats    ue_id=51    expected_dl_tput=${dl_tput}    expected_ul_tput=${ul_tput}    mode=NSA
    Log To Console    Intra-gNB Reverse HO
    Trigger Intrafreq Based NSA Reverse handover    ue_id=51    sim_cell=1    primary_cell=2    phycell_id=51
    Validate throughput from bearer stats    ue_id=51    expected_dl_tput=${dl_tput}    expected_ul_tput=${ul_tput}    mode=NSA
    Stop Traffic and Detach NSA UEs    ${DSS_NSA_UE}
    Run Keyword And Ignore Error    Collect and Validate Gnb PM counters    ${NSA_UE_List}
    [Teardown]    Test Teardown    nsa_ue_list=${DSS_NSA_UE_List}    handover=True