*** Settings ***
Documentation     author: Bhanu Vamsi Krishna
...               contact: vamsi.gundlur@nokia.com
...               Description:

Resource          ../4CC_Common_Keywords.robot

Suite Setup       Suite Setup    feature_folder=CB012149

*** Variables ***
@{dl_tput_list}                        175    175    175    175    175
${NonCA_UL_tput}                       3
${CA_UL_tput}                          175
@{ul_tput_list}                        100    100    100
${Max_UL_tput}                         250
@{Non_CA_SA_UE_List}                   3
${single_ue_id}                        1
@{Single_CA_SA_UE_List}                1
@{SA_Scell_Index}                      0    1
@{logical_cell_list}                   1    2    3    4    5    6
${A1_carrier_freq}                     126990
@{CB012149_feature_activation_prints}  uplinkTxSwitchRequest-r16      uplinkTxSwitching-OptionSupport-r16 switchedUL
...                                    uplinkTxSwitchingOption-r16 switchedUL
${TC1_configs}                         ${CURDIR}/../Config_Files/10_CB012149_LOO_AP_LOO/TC1
${TC2_configs}                         ${CURDIR}/../Config_Files/10_CB012149_LOO_AP_LOO/TC2
${TC3_configs}                         ${CURDIR}/../Config_Files/10_CB012149_LOO_AP_LOO/TC3

*** Test Cases ***
CB012149-AB_TC_AB_004_Verify R16 UL Tx Switching single UE peak throughput with 256QAM_UL_Data - PUSCH mapping type B_TDD_as_PCell
    [Documentation]    Verify 2CC TDD UL CarrierAggregation and UL TX Switching - option 1 TDD as PCell
    ...      to verify single ue peak UL throughtput with 256 QAM
    [Tags]    AP_REG    CB012149_Loki_TC1    P1_REG
    [Setup]    Test Setup for 4CC_DL_2CC_UL    Gnb_Commissioning=False      dl_tput_list=@{dl_tput_list}
    ...    logical_cell_list=@{logical_cell_list}    custom_config_folder=${TC1_configs}    custom_config=True
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    UE Register and Start Traffic For SA Non CA Capable UEs    ${Non_CA_SA_UE_List}    ${NonCA_UL_tput}
    Perform SA UE Register for Blind ScellAddition and Bufferbased ScellActivation with CSI Override
    ...      ${Single_CA_SA_UE_List}      ${SA_Scell_Index}      csi_scell_index=0,1
    validate CB012149 feature activation    ${CB012149_feature_activation_prints}
    Start Uplink and Downlink traffic for 4CC_DL+2CC_UL    ${Single_CA_SA_UE_List}    ${dl_tput_list}      ${CA_UL_tput}
    ...      scell_index_list=${Single_CA_SA_UE_List}
    Sleep    90s
    Validate uplink and downlink cell throughput from UE stats and bearer stats for SA UEs    ${dl_tput_list}      ${CA_UL_tput}
    ...    ${Single_CA_SA_UE_List}    UL_Scell_Id=${SA_Scell_Index}    DL_Scell_Id=${SA_Scell_Index}      UL_Scell_Id_2=${SA_Scell_Index}
    Perform Stop Traffic and Detach SA UEs for Blind ScellAddition    ${Non_CA_SA_UE_List}
    Stop UE Traffic    ${single_ue_id}    pdu=3    dir=ul
    Verify scell is not deactivated for UEs   ${Single_CA_SA_UE_List}
    Stop UE Traffic    ${single_ue_id}    pdu=3    dir=dl
    Verify scell deactivated for SA UEs    ${Single_CA_SA_UE_List}    scell_list=${Single_CA_SA_UE_List}
    Detach SA UEs    ${Single_CA_SA_UE_List}
    [Teardown]    Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Single_CA_SA_UE_List}

CB012149-AB_TC_AB_005_Verify R16 UL Tx Switching single UE peak throughput with 256QAM_UL_Data - PUSCH mapping type A_TDD_as_SCell
    [Documentation]    Verify 2CC TDD UL CarrierAggregation and UL TX Switching - option 1 TDD as SCell with pusch type as A
    ...      to verify single ue peak UL throughtput with 256 QAM
    [Tags]    AP_REG    CB012149_Loki_TC2    P1_REG
    [Setup]    Test Setup for 4CC_DL_2CC_UL    Gnb_Commissioning=False      dl_tput_list=@{dl_tput_list}
    ...    logical_cell_list=@{logical_cell_list}    custom_config_folder=${TC2_configs}    custom_config=True
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    UE Register and Start Traffic For SA Non CA Capable UEs    ${Non_CA_SA_UE_List}    ${NonCA_UL_tput}
    Perform SA UE Register for Blind ScellAddition and Bufferbased ScellActivation with CSI Override
    ...      ${Single_CA_SA_UE_List}      ${SA_Scell_Index}      csi_scell_index=0,1
    validate CB012149 feature activation    ${CB012149_feature_activation_prints}
    Start Uplink and Downlink traffic for 4CC_DL+2CC_UL    ${Single_CA_SA_UE_List}    ${dl_tput_list}      ${CA_UL_tput}
    ...      scell_index_list=${Single_CA_SA_UE_List}
    Sleep    90s
    Validate uplink and downlink cell throughput from UE stats and bearer stats for SA UEs    ${dl_tput_list}      ${CA_UL_tput}
    ...    ${Single_CA_SA_UE_List}    UL_Scell_Id=${SA_Scell_Index}    DL_Scell_Id=${SA_Scell_Index}      UL_Scell_Id_2=${SA_Scell_Index}
    Perform Stop Traffic and Detach SA UEs for Blind ScellAddition    ${Non_CA_SA_UE_List}
    Stop UE Traffic    ${single_ue_id}    pdu=3    dir=ul
    Verify scell is not deactivated for UEs   ${Single_CA_SA_UE_List}
    Stop UE Traffic    ${single_ue_id}    pdu=3    dir=dl
    Verify scell deactivated for SA UEs    ${Single_CA_SA_UE_List}    scell_list=${Single_CA_SA_UE_List}
    Detach SA UEs    ${Single_CA_SA_UE_List}
    [Teardown]    Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Single_CA_SA_UE_List}

CB012149-BB_TC_01_Verify_R16_UL_TxSwitching_single_UE_peak_throughput_DL_UL_2CC-PUSCH_type_A_TDDCell
    [Documentation]    Verify DL & UL data scheduling with R16 UL Tx Switching for SCell activation/deactivation with FDD + TDD FR1
    [Tags]    AP_REG    CB012149_Loki_TC3    P1_REG
    [Setup]    Test Setup for 4CC_DL_2CC_UL    Gnb_Commissioning=False      dl_tput_list=@{dl_tput_list}
    ...    logical_cell_list=@{logical_cell_list}    custom_config_folder=${TC3_configs}    custom_config=True
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    UE Register and Start Traffic For SA Non CA Capable UEs    ${Non_CA_SA_UE_List}    ${NonCA_UL_tput}
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    3min    30s    Validate Pcell Throughput from UE stats and bearer stats for Non CA Capable UEs
    ...    expected_ul_tput=${NonCA_UL_tput}    expected_dl_tput=${NonCA_UL_tput}    UE_List=${Non_CA_SA_UE_List}
    Perform Stop Traffic and Detach SA UEs for Blind ScellAddition    ${Non_CA_SA_UE_List}
    Perform SA UE Register for Measurement based ScellAddition and Bufferbased ScellActivation with CSI Override
    ...    ${Single_CA_SA_UE_List}    ${A1_carrier_freq}    4CC=True    scell=${4CC_scell_index_1}    srsrp_nr=95
    validate CB012149 feature activation    ${CB012149_feature_activation_prints}
    Start Uplink and Downlink traffic    CA_SA_UE_List=${Single_CA_SA_UE_List}    CA_DL_tput_list=${dl_tput_list}
    ...    CA_UL_tput_list=${ul_tput_list}    scell_index_list=${Single_CA_SA_UE_List}
    sleep    30s
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    3min    30s    Validate uplink and downlink cell throughput from UE stats and bearer stats for SA UEs
    ...    ${dl_tput_list}      ${Max_UL_tput}    ${Single_CA_SA_UE_List}    UL_Scell_Id=${SA_Scell_Index}    DL_Scell_Id=${SA_Scell_Index}
    ...      UL_Scell_Id_2=${SA_Scell_Index}
    Stop UE Traffic    ${single_ue_id}    pdu=3    dir=ul
    Verify scell is not deactivated for UEs   ${Single_CA_SA_UE_List}
    Stop UE Traffic    ${single_ue_id}    pdu=3    dir=dl
    Detach SA UEs    ${Single_CA_SA_UE_List}
    Run keyword And Continue On Failure    wait until keyword succeeds    1min    5s    Verify scell deactivated for SA UEs
    ...    ${Single_CA_SA_UE_List}    scell_list=${Single_CA_SA_UE_List}
    [Teardown]    Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Single_CA_SA_UE_List}

*** Keywords ***
validate CB012149 feature activation
    [Arguments]    ${reg_list}=${CB012149_feature_activation_prints}
    FOR    ${regexp}    IN    @{reg_list}
        validate given expression in egate_console    ${regexp}
    END

validate given expression in egate_console
    [Arguments]    ${pass_regexp}=Pass
    Log To Console    checking given "${pass_regexp}" expression in egate_console.log...
    Run and return rc    grep "${pass_regexp}" /opt/wts/latest/egate_console.log

Verify scell is not deactivated for UEs
    [Arguments]    ${sa_ue_list}    ${scell_list}=${Single_CA_SA_UE_List}
    Execute Egate Command    cmd=sim_log_set flush    timeout=2s
    sleep    5s    reason=Waiting for egate console to be flushed
    FOR    ${ue_id}    IN    @{sa_ue_list}
        ${sa_scell_ue_id}    Evaluate    ${ue_id}-1
        Run Keyword And Expect Error      *not found in egate_console*      Verify scell deactivation for each scell index
        ...    ${sa_scell_ue_id}    scell_list=${scell_list}
    END
