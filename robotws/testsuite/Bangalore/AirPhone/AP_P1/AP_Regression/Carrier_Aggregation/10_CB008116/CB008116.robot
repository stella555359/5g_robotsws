*** Settings ***
Documentation       author: Sudha V
...                 contact: sudha.v@nokia.com
...                 Description:

Resource            ../14_CB007922/CB007922_Keywords.robot
Resource            ./CB008116_Keywords.robot
Resource            ../4CC_Common_Keywords.robot

Suite Setup         Suite Setup    feature_folder=CB008116


*** Variables ***
${NUMBER_OF_CELLS}                          2
@{dl_tput_list}                             150    150    150
@{multi_dl_tput}                            125
${ul_tput}                                  3
@{Non_CA_SA_UE_List}                        1
@{Single_CA_SA_UE_List}                     3
@{Single_CA_NSA_UE_List}                    11
${Single_CA_SA_HO_UE}                       3
${Single_CA_NSA_HO_UE}                      11
${A1_real_gnb_carrier_freq_APoABIO}         650016
${A2_real_gnb_carrier_freq_APoABIO}         636576
@{dl_tput_list_Blind_BufferBased_RLQ}       175    175    175    175

*** Test Cases ***
CB008116_TC1_Validation of Integrity protection of UP data in SA UEs during L3 Call and HO scenarios
    [Documentation]    Verify IntraFrequency_IntergNB_TDD_-_FR1_TDD_CA_HO_for_SA_NSA_UE
    ...    gNB-2(TDD-1+ FR1TDD),gNB-2x(TDD-2)
    [Tags]    ap_reg    cb008116_tc1    ca_ho
    [Setup]    Test Setup for handover scenario    Handover_Feature=CB008116
    ...    A1_carrier_freq=${A1_real_gnb_carrier_freq_APoABIO}    A2_carrier_freq=${A2_real_gnb_carrier_freq_APoABIO}
    ...    dl_tput_list=@{dl_tput_list_Blind_BufferBased_RLQ}
    Change SMF Security Indication
    FOR    ${index}    IN RANGE    2
        Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
        Perform UE Register and Start Traffic For SA Non CA Capable UEs and verify SMFsecurityIndication
        ...    ${Non_CA_SA_UE_List}
        ...    csi_override=True
        Perform SA UE Register for Measurement base ScellAddition and Bufferbase ScellActivation CSI Override and verifySMFsecurityIndication
        ...    ${Single_CA_SA_UE_List}
        ...    ${A1_carrier_freq}
        Start Traffic and Validate Scell Activation for SA UE    ue_id_list=${Single_CA_SA_UE_List}
        Perform NSA UE Attach for Measurement based ScellAddition and Bufferbased ScellActivation with CSI Override
        ...    ${Single_CA_NSA_UE_List}
        ...    ${A1_carrier_freq}
        Start Traffic and Validate Scell Activation for NSA UE    ue_id_list=${Single_CA_NSA_UE_List}
        Sleep    90s
        Run keyword And Continue On Failure
        ...    4CC_Common_Keywords.Validate Pcell Throughput For Non CA Capable UEs
        ...    expected_dl_tput=${ul_tput}
        ...    UE_List=${Non_CA_SA_UE_List}
        Run keyword And Continue On Failure
        ...    4CC_Common_Keywords.Validate Pcell and Scell Throughput For SA UEs
        ...    expected_dl_tput=${dl_tput_list}
        ...    UE_List=${Single_CA_SA_UE_List}
        ...    Scell_Id=${SA_Scell_Index}
        Run keyword And Continue On Failure
        ...    CB008116_Keywords.Validate Pcell and Scell Throughput For NSA UEs
        ...    expected_dl_tput=${dl_tput_list}
        ...    UE_List=${Single_CA_NSA_UE_List}
        ...    Scell_Id=${NSA_Scell_Index}
        Trigger Intrafreq SA handover from Real gNB to Sim gNB
        ...    ue_id_list=${Single_CA_SA_UE_List}
        ...    carrier_frequency=${A1_carrier_freq}
        Run keyword And Continue On Failure    Validate throughput from bearer stats    ue_id=${Single_CA_SA_HO_UE}
        ...    expected_dl_tput=${dl_tput_list}    expected_ul_tput=${ul_tput}    mode=SA
        Trigger Intrafreq NSA handover from Real gNB to Sim gNB
        ...    ue_id_list=${Single_CA_NSA_UE_List}
        ...    carrier_frequency=${A1_carrier_freq}
        Run keyword And Continue On Failure    Validate throughput from bearer stats    ue_id=${Single_CA_NSA_HO_UE}
        ...    expected_dl_tput=${dl_tput_list}    expected_ul_tput=${ul_tput}    mode=NSA
        Update UE History Information    id=1    cell_type=large    nrcgi=311:489|0x04
        ...    gnb_id=22    time_ue_stayed_in_cell=97    action=commit    ue_enb_param_id=${Single_CA_SA_HO_UE}
        Trigger Intrafreq SA handover from Sim gNB to Real gNB and verify SMF security Indication
        ...    ue_id=${Single_CA_SA_HO_UE}
        ...    scell_index=1
        ...    carrier_frequency=${A1_carrier_freq}
        ...    csi_override_needed=True
        Update UE History Information    id=2    cell_type=large    nrcgi=311:489|0x06
        ...    gnb_id=24    time_ue_stayed_in_cell=97    action=commit    ue_enb_param_id=${Single_CA_NSA_HO_UE}
        Trigger Intrafreq NSA handover from Sim gNB to Real gNB    ue_id=${Single_CA_NSA_HO_UE}    scell_index=9
        ...    carrier_frequency=${A1_carrier_freq}    csi_override_needed=True
        Run keyword And Continue On Failure
        ...    wait until keyword succeeds
        ...    3min
        ...    30s
        ...    4CC_Common_Keywords.Validate Pcell and Scell Throughput For SA UEs
        ...    expected_dl_tput=${dl_tput_list}
        ...    UE_List=${Single_CA_SA_UE_List}
        ...    Scell_Id=${SA_Scell_Index}
        Run keyword And Continue On Failure
        ...    wait until keyword succeeds
        ...    3min
        ...    30s
        ...    CB008116_Keywords.Validate Pcell and Scell Throughput For NSA UEs
        ...    expected_dl_tput=${dl_tput_list}
        ...    UE_List=${Single_CA_NSA_UE_List}
        ...    Scell_Id=${NSA_Scell_Index}
        Update CSI Override parameters    profile_id=5    cqi=1    cqi_max=15    cqi_min=0    cqi_mode=fixed
        Associate UE to testmode    id=${Single_CA_SA_HO_UE}    testmode=csi_override    profile_id=5
        ...    action=activate    scell=1    pass_regex=SCellIndex \\d+ deactivated successfully
        Associate UE to testmode    id=${Single_CA_NSA_HO_UE}    testmode=csi_override    profile_id=5
        ...    action=activate    scell=9    pass_regex=SCellIndex \\d+ deactivated successfully
        1729_Keywords.Perform Stop Traffic and Detach SA Non CA Capable UEs    ${Non_CA_SA_UE_List}
        Stop Traffic and Detach SA UEs for MeasurementBased ScellAddition and Buffer+RLQ ScellActivation
        ...    ${Single_CA_SA_UE_List}    ${A2_carrier_freq}
        Stop Traffic and Detach NSA UEs for MeasurementBased ScellAddition and Buffer+RLQ ScellActivation
        ...    ${Single_CA_NSA_UE_List}    ${A2_carrier_freq}
    END
	[Teardown]    Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Single_CA_SA_UE_List}
    ...    nsa_ue_list=${Single_CA_NSA_UE_List}
