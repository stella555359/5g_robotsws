*** Settings ***
Documentation     author: Bhanu Vamsi Krishna Gundlur
...               contact: vamsi.gundlur@nokia.com
...               Description: CB006449 TDD FR1 UL CA up to 2 CCs, The feature introduces support of intra-band, contiguous and inter-band
...               carrier aggregation with two TDD FR1 component carriers in SA mode, served by the same gNB and DU. Further component carriers
...               (FDD and/or TDD) of the same gNB/DU are supported for downlink traffic as defined in related DL CA features. Intra-band
...               non-contiguous CA is not supported within this feature.

Resource    ./CB006449_Keywords.robot

Suite Setup       Suite Setup    feature_folder=CB006449

*** Variables ***
${NUMBER_OF_CELLS}               4
@{dl_tput_list}                  150    150    150
@{multi_dl_tput}                 125
${ul_tput}                       120
@{Single_CA_SA_UE_List}          1
@{Multi_CA_SA_UE_List}           1    2
@{ul_tput_list}                  150    150
${SA_UE_ID}                      1
@{scell_index_list}              1    2
@{DL_SA_Scell_Index}             0    1    2
@{UL_Scell_index}                0    1
${A1_carrier_frequency}          632736
${A2_carrier_frequency}          638688
${TC1_configs}                   ${CURDIR}/../Config_Files/22_CB006449/TC1
${TC2_configs}                   ${CURDIR}/../Config_Files/22_CB006449/TC2
${no_of_traffic_loops}           5

*** Test Cases ***
CB006449_TC1_Successful intra-band FR1 TDD-TDD UL CA configuration via blind SCell addition
    [Documentation]    CB006449 TDD FR1 UL CA up to 2 CCs for blind scell addition and activation
    [Tags]    CB006449_TC1    CA_Types    AP_REG    P2_REG
    [Setup]    Test Setup    custom_config=True    custom_config_folder=${TC1_configs}
    Perform SA UE Register and start traffic for Blind ScellAddition and Blind ScellActivation    ${Single_CA_SA_UE_List}
    ...    4CC=True    scell_index_list=${scell_index_list}
    Run keyword And Continue On Failure    Validate uplink and downlink cell throughput from UE stats and bearer stats for SA UEs
    ...    expected_dl_tput=${dl_tput_list}    expected_ul_tput=${ul_tput}    UE_List=${Single_CA_SA_UE_List}    UL_Scell_Id=${UL_Scell_index}
    ...    DL_Scell_Id=${DL_SA_Scell_Index}    UL_Scell_Id_2=${UL_Scell_index}
    Stop Traffic and Detach SA UEs    ${Single_CA_SA_UE_List}    pdu=3
    [Teardown]    Test Teardown    sa_ue_list=${Single_CA_SA_UE_List}

CB006449_TC2_Verify that single UE connection setup with T+T intra-band contiguous UL 2CCs CA with A2 MR based SCell release
    [Documentation]    CB006449 TDD FR1 UL CA up to 2 CCs for covBasedA1 scell addition and blind activation with A2 based scell release.
    [Tags]    CB006449_TC2    CA_Types    AP_REG    P2_REG
    [Setup]    Test Setup    custom_config=True    custom_config_folder=${TC2_configs}
    Perform SA UE Register for Measurement based ScellAddition and Blind ScellActivation    ${Single_CA_SA_UE_List}
    ...    carrier_frequency=${A1_carrier_frequency}    phycell_id=51    srsrp_nr=95
    Start parallel UL and DL traffic with multiple trf_id for all SA UEs    ${Single_CA_SA_UE_List}    ${dl_tput_list}    ${ul_tput_list}
    Run keyword And Continue On Failure    Validate uplink and downlink cell throughput from UE stats and bearer stats for SA UEs
    ...    expected_dl_tput=${dl_tput_list}    expected_ul_tput=${ul_tput_list}    UE_List=${Single_CA_SA_UE_List}    UL_Scell_Id=${UL_Scell_index}
    ...    DL_Scell_Id=${UL_Scell_index}    UL_Scell_Id_2=${UL_Scell_index}
    Stop UE Traffic    ue_id=${ue_id}    pdu=3    dir=bi
    Detach SA UEs for Measurement Based ScellAddition    sa_ue_list=${Single_CA_SA_UE_List}    carrier_frequency=${A2_carrier_frequency}
    ...    scell_rsrp=95
    [Teardown]    Test Teardown    sa_ue_list=${Single_CA_SA_UE_List}

CB006449_TC3_Verify that single UE connection setup with T+T intra-band contiguous UL 2CCs CA with scell activation and deactivation multiple times
    [Documentation]    CB006449 TDD FR1 UL CA up to 2 CCs for covBasedA1 scell addition and bufferBased activation with A2 based scell release
    ...    scell is activated and deactived multiple times by starting and stopping the traffic, this testcase uses custom configs from TC2
    ...    and perform delta-comissioing to have scell activation as buferBased.
    [Tags]    CB006449_TC3    CA_Types    AP_REG    P1_REG
    [Setup]    Test Setup for CB006449
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    Perform SA UE Register for Measurement based ScellAddition and Bufferbased ScellActivation with CSI Override    ${Single_CA_SA_UE_List}
    ...    ${A1_carrier_frequency}    srsrp_nr_2cc=95
    FOR    ${traffic_loop}    IN RANGE    ${no_of_traffic_loops}
        Start parallel UL and DL traffic with multiple trf_id for all SA UEs    ${Single_CA_SA_UE_List}    ${dl_tput_list}    ${ul_tput_list}
        Verify scell activation for each scell index    ${SA_UE_ID}    ${scell_act_index_list}
        Run keyword And Continue On Failure    Validate uplink and downlink cell throughput from UE stats and bearer stats for SA UEs
        ...    expected_dl_tput=${dl_tput_list}    expected_ul_tput=${ul_tput_list}    UE_List=${Single_CA_SA_UE_List}
        ...    UL_Scell_Id=${UL_Scell_index}    DL_Scell_Id=${UL_Scell_index}    UL_Scell_Id_2=${UL_Scell_index}
        Stop UE Traffic    ue_id=${ue_id}    pdu=3    dir=bi
        Verify scell deactivated for SA UEs    ${Single_CA_SA_UE_List}    scell_list=${scell_act_index_list}
    END
    Detach SA UEs for Measurement Based ScellAddition    sa_ue_list=${Single_CA_SA_UE_List}    carrier_frequency=${A2_carrier_frequency}
    ...    scell_rsrp=95
    [Teardown]    Test Teardown    sa_ue_list=${Single_CA_SA_UE_List}