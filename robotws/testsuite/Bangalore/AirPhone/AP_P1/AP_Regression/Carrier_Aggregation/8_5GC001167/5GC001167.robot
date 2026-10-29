*** Settings ***
Documentation     author: Rakshitha
...               contact: rakshitha.r@nokia.com
...               Description:

Resource    ./1167_Keywords.robot

Suite Setup       Suite Setup    feature_folder=5GC001167

*** Variables ***
${NUMBER_OF_CELLS}               3
${Single_dl_tput}                125
@{dl_tput_list}                  80    80    80
${ul_tput}                       3
@{Non_CA_SA_UE_List}             11    21
@{Single_CA_SA_UE_List}          1
@{Multi_CA_SA_UE_List}           1    2    3
@{SA_Scell_Index}                0    1    2
@{RLQ_Scell}                     1    2
${non_ca_dl_tput}                10
${3cc_1cc_HO_CA_SA_UE}           1
@{UE_List_IntraHO}               1    11    21
@{UE_List_HO_2cc_3cc}            1    4     21
@{2cc_3cc_HO_SA_CA_UE}           4
@{2cc_3cc_HO_SA_Non_CA_UE}       1     21
@{2cc_3cc_HO_Scell_Index}        0    1
@{Sim_Gnb_list_HO_1167}          2    22    23


*** Test Cases ***
5GC001167_TC1_Measurement Based CA and Non CA Activation with buffer based For SA Single UE
    [Documentation]    Verify 3CC SA FDD DL CarrierAggregation Measurement Based SCELL Addition and Buffer Based SCELL
    ...                Activation RLQ Based Deactivation SCELL Release
    [Tags]    1167_TC1_SUE
    [Setup]    Test Setup
    Perform UE Register and Start Traffic For SA Non CA Capable UEs    ${Non_CA_SA_UE_List}
    Perform UE Register and Start Traffic For Single SA UE    ${Single_CA_SA_UE_List}
    Sleep    90s
    Validate Pcell Throughput For Non CA Capable UEs    expected_ul_tput=${ul_tput}    expected_dl_tput=${ul_tput}
    ...    UE_List=${Non_CA_SA_UE_List}
    Validate Pcell and Scell Throughput For SA UEs    expected_ul_tput=${ul_tput}    expected_dl_tput=${Single_dl_tput}
    ...    UE_List=${Single_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Scell Deactivation using RLQ testmode activation    ue_list=${Single_CA_SA_UE_List}    scell_index=${RLQ_Scell}
    Perform Stop Traffic and Detach SA Non CA Capable UEs    ${Non_CA_SA_UE_List}
    Perform Stop Traffic and Detach SA UEs    ${Single_CA_SA_UE_List}
    Run Keyword If    '${BIP_CAPTURE_NEEDED}' == 'True'    Run Keyword And Ignore Error    Stop L1L2bipLogs
    Log To Console    Sleeping for 5min before collecting PM Counters..
    Sleep    300s
    Run Keyword And Ignore Error    Collect Gnb PM Counters    target_dir=${testlog_path}    name=gnb_pm_counters
    Run Keyword And Ignore Error    Validate Gnb PM Counters    sa_ue_list=${Single_CA_SA_UE_List}    counters=${Counter_List}
    ...    counters_dir=${testlog_path}    name=gnb_pm_counters
    [Teardown]    Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Single_CA_SA_UE_List}

5GC001167_TC2_Measurement Based CA and Non CA Activation with buffer based For SA Multiple UEs
    [Documentation]    Verify multiUE data transfer 3CC SA FDD CarrierAggregation Measurement Based SCELL Addition and
    ...                Buffer Based SCELL Activation RLQ Based Deactivation SCELL Release
    [Tags]    1167_TC2_MUE
    [Setup]    Test Setup
    Perform UE Register For SA Non CA Capable UEs    ${Non_CA_SA_UE_List}
    Perform UE Register For SA CA UEs    ${Multi_CA_SA_UE_List}
    Start traffic for all UEs    CA_SA_UE_List=${Multi_CA_SA_UE_List}    Non_CA_SA_UE_List=${Non_CA_SA_UE_List}
    ...    CA_DL_txput=${dl_tput_list}[0]    non_CA_DL_txput=${non_ca_dl_tput}
    Sleep    90s
    Validate Pcell Throughput For Non CA Capable UEs    expected_ul_tput=${ul_tput}    expected_dl_tput=${non_ca_dl_tput}
    ...    UE_List=${Non_CA_SA_UE_List}
    Run keyword And Continue On Failure    Validate Pcell and Scell Throughput For SA UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${dl_tput_list}    UE_List=${Multi_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Validate throughput from UE stats and bearer stats for SA UEs    expected_ul_tput=${ul_tput}    expected_dl_tput=${dl_tput_list}
    ...    UE_List=${Multi_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Scell Deactivation using RLQ testmode activation    ue_list=${Multi_CA_SA_UE_List}    scell_index=${RLQ_Scell}
    Perform Stop Traffic and Detach SA Non CA Capable UEs    ${Non_CA_SA_UE_List}
    Perform Stop Traffic and Detach SA UEs    ${Multi_CA_SA_UE_List}
    Run Keyword If    '${BIP_CAPTURE_NEEDED}' == 'True'    Run Keyword And Ignore Error    Stop L1L2bipLogs
    Log To Console    Sleeping for 5min before collecting PM Counters..
    Sleep    300s
    Run Keyword And Ignore Error    Collect Gnb PM Counters    target_dir=${testlog_path}    name=gnb_pm_counters
    Run Keyword And Ignore Error    Validate Gnb PM Counters    sa_ue_list=${Multi_CA_SA_UE_List}    counters=${Counter_List}
    ...    counters_dir=${testlog_path}    name=gnb_pm_counters
    [Teardown]    Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Multi_CA_SA_UE_List}

5GC001167_TC3_A3_i_3CC_InterBand_CA_HO_From_PCell_To_SCell_Then_HO_To_Third_Cell_Reconfig_Of_3CC_CA
    [Tags]    AP_REG    1167_TC3_INTRA_HO_3CC
    [Setup]    Test Setup    handover=True
    Perform UE Register For SA CA UEs   ${Single_CA_SA_UE_List}
    Perform UE Register For SA Non CA Capable UEs    ${Non_CA_SA_UE_List}
    Start traffic for all UEs    CA_SA_UE_List=${Single_CA_SA_UE_List}    Non_CA_SA_UE_List=${Non_CA_SA_UE_List}
    ...     CA_DL_txput=${Single_dl_tput}    non_CA_DL_txput=${ul_tput}
    Validate Pcell Throughput For Non CA Capable UEs    expected_ul_tput=${ul_tput}    expected_dl_tput=${ul_tput}
    ...    UE_List=${Non_CA_SA_UE_List}
    Validate Pcell and Scell Throughput For SA UEs    expected_ul_tput=${ul_tput}    expected_dl_tput=${Single_dl_tput}
    ...    UE_List=${Single_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Trigger Intrafreq SA handover from Real gNB cell1 to real gNB cell3    ue_id=${3cc_1cc_HO_CA_SA_UE}
    Trigger Intrafreq SA handover from Real gNB cell3 to real gNB cell2    ue_id=${3cc_1cc_HO_CA_SA_UE}
    Validate Pcell Throughput For Non CA Capable UEs    expected_ul_tput=${ul_tput}    expected_dl_tput=${ul_tput}
    ...    UE_List=${Non_CA_SA_UE_List}
    Validate Pcell and Scell Throughput For SA UEs    expected_ul_tput=${ul_tput}    expected_dl_tput=${Single_dl_tput}
    ...    UE_List=${Single_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Perform Stop Traffic for all UEs    ${UE_List_IntraHO}
    Verify Scell Deactivated For All SA CA UEs    ${Single_CA_SA_UE_List}
    Detach all SA UEs     ${UE_List_IntraHO}
    [Teardown]    Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Single_CA_SA_UE_List}    handover=True

5GC001167_TC4_A3_i_Reconfiguration_From_2CC_To_3CC_After_HO_Interband_CA
    [Tags]    AP_REG    1167_TC4_INTRA_HO_2CC
    [Setup]    Test Setup    handover=True
    Delete Scell Addition Method in Gnb
    Perform UE Register For all SA UEs   ${UE_List_HO_2cc_3cc}
    Start traffic for all UEs    CA_SA_UE_List=${2cc_3cc_HO_SA_CA_UE}    Non_CA_SA_UE_List=${2cc_3cc_HO_SA_Non_CA_UE}
    ...     CA_DL_txput=${Single_dl_tput}    non_CA_DL_txput=${ul_tput}    2CC_3CC=True
    Validate Pcell Throughput For Non CA Capable UEs    expected_ul_tput=${ul_tput}    expected_dl_tput=${ul_tput}
    ...    UE_List=${2cc_3cc_HO_SA_Non_CA_UE}
    Validate Pcell and Scell Throughput For SA UEs    expected_ul_tput=${ul_tput}    expected_dl_tput=${Single_dl_tput}
    ...    UE_List=${2cc_3cc_HO_SA_CA_UE}    Scell_Id=${2cc_3cc_HO_Scell_Index}
    Trigger Intrafreq SA handover from Real gNB cell2 to real gNB cell1    sa_ue_list=${2cc_3cc_HO_SA_CA_UE}
    Trigger Scell Addition to activate Scell    sa_ue_list=${2cc_3cc_HO_SA_CA_UE}
    Validate Pcell Throughput For Non CA Capable UEs    expected_ul_tput=${ul_tput}    expected_dl_tput=${ul_tput}
    ...    UE_List=${2cc_3cc_HO_SA_Non_CA_UE}
    Validate throughput from UE stats and bearer stats for SA UEs    expected_ul_tput=${ul_tput}    expected_dl_tput=${Single_dl_tput}
    ...    UE_List=${2cc_3cc_HO_SA_CA_UE}    Scell_Id=${SA_Scell_Index}
    Perform Stop Traffic for all UEs    ${2cc_3cc_HO_SA_CA_UE}
    Perform Stop Traffic for all UEs    ${2cc_3cc_HO_SA_Non_CA_UE}
    Verify Scell Deactivated For All SA CA UEs    CA_SA_UE_List=${2cc_3cc_HO_SA_CA_UE}    2CC_3CC=True
    Detach all SA UEs     ${UE_List_HO_2cc_3cc}
    [Teardown]    Test Teardown    sa_nonca_ue_list=${2cc_3cc_HO_SA_Non_CA_UE}    sa_ue_list=${2cc_3cc_HO_SA_CA_UE}    handover=True

5GC001167_TC5_IntraFrequency_IntergNB_FDD_CA_NGBased HO_for_SA_UE
    [Tags]    AP_REG    1167_TC5_INTRA_NGBased_HO
    [Setup]    Test Setup for handover scenario    Handover_Feature=5GC001167    simulator_gnb_list=${Sim_Gnb_list_HO_1167}    NGBased_HO=True
    Perform UE Register and Start Traffic For Single SA UE    ${Single_CA_SA_UE_List}
    Sleep    30s
    Validate Pcell and Scell Throughput For SA UEs    expected_ul_tput=${ul_tput}    expected_dl_tput=${Single_dl_tput}
    ...    UE_List=${Single_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Trigger Intrafreq NG Based SA handover from Real gNB2 cell1 to sim gNB22 cell2    ue_id=${3cc_1cc_HO_CA_SA_UE}
    Validate throughput from bearer stats    ue_id=${3cc_1cc_HO_CA_SA_UE}    expected_dl_tput=${Single_dl_tput}
    ...    expected_ul_tput=${ul_tput}    mode=SA    pdu_id=3
    Trigger Intrafreq NG Based SA handover from sim gNB22 Cell2 to Real gNB2 Cell1    ue_id=${3cc_1cc_HO_CA_SA_UE}
    Trigger Scell Addition to activate Scell    sa_ue_list=${Single_CA_SA_UE_List}
    Validate throughput from UE stats and bearer stats for SA UEs    expected_ul_tput=${ul_tput}    expected_dl_tput=${Single_dl_tput}
    ...    UE_List=${Single_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Scell Deactivation using RLQ testmode activation    ue_list=${Single_CA_SA_UE_List}    scell_index=${RLQ_Scell}
    Perform Stop Traffic for all UEs    ${Single_CA_SA_UE_List}
    Detach all SA UEs    ${Single_CA_SA_UE_List}
    [Teardown]    run keywords    Revert WTS and Gnb configuration    Handover_Feature=5GC001167
    ...    AND   Test Teardown    sa_ue_list=${Single_CA_SA_UE_List}    handover=True

5GC001167_TC6_InterFrequency_IntergNB_FDD_CA_NGBased HO_for_SA_UE
    [Tags]    AP_REG    1167_TC6_INTER_NGBased_HO
    [Setup]    Test Setup for handover scenario    Handover_Feature=5GC001167    simulator_gnb_list=${Sim_Gnb_list_HO_1167}    NGBased_HO=True
    Perform UE Register and Start Traffic For Single SA UE    ${Single_CA_SA_UE_List}
    Sleep    30s
    Validate Pcell and Scell Throughput For SA UEs    expected_ul_tput=${ul_tput}    expected_dl_tput=${Single_dl_tput}
    ...    UE_List=${Single_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Trigger Interfreq NG Based SA handover from Real gNB2 cell1 to sim gNB22 cell2    ue_id=${3cc_1cc_HO_CA_SA_UE}
    Validate throughput from bearer stats    ue_id=${3cc_1cc_HO_CA_SA_UE}    expected_dl_tput=${Single_dl_tput}
    ...    expected_ul_tput=${ul_tput}    mode=SA    pdu_id=3
    Trigger Interfreq NG Based SA handover from sim gNB22 Cell2 to Real gNB2 Cell1    ue_id=${3cc_1cc_HO_CA_SA_UE}
    Trigger Scell Addition to activate Scell    sa_ue_list=${Single_CA_SA_UE_List}
    Validate throughput from UE stats and bearer stats for SA UEs    expected_ul_tput=${ul_tput}    expected_dl_tput=${Single_dl_tput}
    ...    UE_List=${Single_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Scell Deactivation using RLQ testmode activation    ue_list=${Single_CA_SA_UE_List}    scell_index=${RLQ_Scell}
    Perform Stop Traffic for all UEs    ${Single_CA_SA_UE_List}
    Detach all SA UEs    ${Single_CA_SA_UE_List}
    [Teardown]    run keywords    Revert WTS and Gnb configuration    Handover_Feature=5GC001167
    ...    AND   Test Teardown    sa_ue_list=${Single_CA_SA_UE_List}    handover=True
