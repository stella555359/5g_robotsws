*** Settings ***
Documentation     author: Bhanu Vamsi
...               contact: vamsi.gundlur@nokia.com
...               Description:

Resource                         ../CA_Common_Keywords.robot

Suite Setup       Suite Setup    feature_folder=CB008366

*** Variables ***
${NUMBER_OF_CELLS}               3
@{Single_dl_tput}                150    150    100    100
@{dl_tput_list}                  80    80    80
${ul_tput}                       3
@{Non_CA_SA_UE_List}             4
@{Single_CA_SA_UE_List}          1
@{Multi_CA_SA_UE_List}           1    2    3
@{SA_Scell_Index}                0    1    2
@{UL_Scell_Index}                0
${csi_scell}                     0,1,2
@{RLQ_Scell}                     1    2
${scell_deact}                   1,2
${3cc_1cc_HO_CA_SA_UE}           1
@{UE_List_IntraHO}               1    11    21
@{UE_List_HO_2cc_3cc}            1    4     21
@{2cc_3cc_HO_SA_CA_UE}           4
@{2cc_3cc_HO_SA_Non_CA_UE}       1     21
@{2cc_3cc_HO_Scell_Index}        0    1
@{Sim_Gnb_list_HO}               2    22    23
@{nrrel_profile_id_fdd}          6    7
${WTS_CFG_PATH}                  ${CURDIR}/../Config_Files/10_CB008366/wts
${WTS_FILE}                      basic_setup.lua
${WTS_BKUP_FILE}                 basic_setup_backup.lua
${EDAEMON_PORT}                  50000
${A1_carrier_freq}               156750
${A2_cf1}                        392170
${A2_cf2}                        426030
${A3_cf_inter}                   426000
@{Counter_List}                  M55118C05506    M55316C09000    M55310C01006    M55316C09001    M55118C06501

*** Test Cases ***
CB008366_TC1_Measurement Based CA and Non CA Activation with buffer based For SA Single UE
    [Documentation]    Verify 3CC SA FDD DL CarrierAggregation Measurement Based SCELL Addition and Buffer Based SCELL
    ...                Activation RLQ Based Deactivation SCELL Release
    [Tags]    AP_REG    CB008366_TC1_SUE
    [Setup]    Test Setup
    Perform UE Attach and Verify scell addition for SA UEs
    Start Traffic and validate scell activation for SA UEs
    Perform Scell Deactivation Stop Traffic And Detach for single SA UE
    Collect and Validate Gnb PM counters    SA_UE_List=${Single_CA_SA_UE_List}
    [Teardown]    Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Single_CA_SA_UE_List}

CB008366_TC2_Measurement Based CA and Non CA Activation with buffer based For SA Multiple UEs
    [Documentation]    Verify multiUE data transfer 3CC SA FDD CarrierAggregation Measurement Based SCELL Addition and
    ...                Buffer Based SCELL Activation RLQ Based Deactivation SCELL Release
    [Tags]    AP_REG    CB008366_TC2_MUE
    [Setup]    Test Setup
    UE Register and Start Traffic For SA Non CA Capable UEs    ${Non_CA_SA_UE_List}
    Perform SA UE Register for Measurement based ScellAddition and Bufferbased ScellActivation with CSI Override
    ...    ${Multi_CA_SA_UE_List}    ${A1_carrier_freq}    scell=${csi_scell}
    Start parallel traffic for all SA UEs    ${Multi_CA_SA_UE_List}    dl_tput=${dl_tput_list}    ul_tput=${ul_tput}
    Wait Until Keyword Succeeds    1 min    30sec
    ...    Verify scell activated for SA UEs    sa_ue_list=${Multi_CA_SA_UE_List}    scell_index_list=${RLQ_Scell}
    Validate Pcell Throughput from UE stats and bearer stats for Non CA Capable UEs    {expected_ul_tput=${ul_tput}    expected_dl_tput=${ul_tput}
    ...    UE_List=${Non_CA_SA_UE_List}
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    3min    30s    Validate throughput from UE stats for all CA UEs    ue_list=${Multi_CA_SA_UE_List}
    ...    expected_dl_tput=${dl_tput_list}    expected_ul_tput=${ul_tput}    dl_scell=${SA_Scell_Index}    ul_scell=${UL_Scell_Index}
    Activate testmode and verify scell deactivation    ue_list=${Multi_CA_SA_UE_List}    scell=${scell_deact}    scell_list=${RLQ_Scell}
    Stop Traffic and Detach SA UEs    ${Non_CA_SA_UE_List}
    Stop Traffic and Detach CA SA UEs    ${Multi_CA_SA_UE_List}    cf1=${A2_cf1}    cf2=${A2_cf2}
    Collect and Validate Gnb PM counters    SA_UE_List=${Multi_CA_SA_UE_List}
    [Teardown]    Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Multi_CA_SA_UE_List}

CB008366_TC3_IntraFrequency_IntergNB_FDD_CA_XNBased HO_for_SA_UE
    [Tags]    8366_TC3_INTRA_XNBased_HO    P3_REG
    [Setup]    Test Setup for handover scenario    Handover_Feature=CB008366    simulator_gnb_list=${Sim_Gnb_list_HO}
    Ensure NG Link is Up for sim gNB    gnb_id=22
    Ensure NG Link is Up for sim gNB    gnb_id=23
    Perform UE Attach and Verify scell addition for SA UEs
    Start Traffic and validate scell activation for SA UEs
    sleep    180s   reason=To stabilise xn link
    Trigger Intrafreq XN Based SA Forward handover    ue_id=${3cc_1cc_HO_CA_SA_UE}    carrier_frequency=${A1_carrier_freq}    primary_cell=3
    ...    phycell_id=57
    Validate Bearer Stats for multiple UEs    ue_list=${Single_CA_SA_UE_List}    expected_dl_tput=${Single_dl_tput}
    ...    expected_ul_tput=${ul_tput}    mode=SA
    Trigger Intrafreq XN Based SA Reverse handover    ue_id=${3cc_1cc_HO_CA_SA_UE}    carrier_frequency=${A1_carrier_freq}    hist_id=1
    ...    phycell_id=52    nrci=2    primary_cell=3
    Reset ri and trigger A1 Event
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    3min    30s    Validate throughput from UE stats for all CA UEs    ue_list=${Single_CA_SA_UE_List}
    ...    expected_dl_tput=${Single_dl_tput}    expected_ul_tput=${ul_tput}    dl_scell=${SA_Scell_Index}    ul_scell=${UL_Scell_Index}
    Perform Scell Deactivation Stop Traffic And Detach for single SA UE
    Collect and Validate Gnb PM counters    SA_UE_List=${Single_CA_SA_UE_List}
    [Teardown]    Test Teardown    sa_ue_list=${Single_CA_SA_UE_List}

CB008366_TC4_InterFrequency_IntergNB_FDD_CA_XNBased HO_for_SA_UE
    [Tags]    8366_TC4_INTER_XNBased_HO    P3_REG
    [Setup]    Test Setup for handover scenario    Handover_Feature=CB008366    simulator_gnb_list=${Sim_Gnb_list_HO}
    Perform UE Attach and Verify scell addition for SA UEs
    Start Traffic and validate scell activation for SA UEs
    Trigger Interfreq XN Based SA Forward handover    ue_id=${3cc_1cc_HO_CA_SA_UE}
    ...    A2_carrier_freq=${A1_carrier_freq}    A3_carrier_freq=${A3_cf_inter}    primary_cell=3    phycell_id=58
    Validate Bearer Stats for multiple UEs    ue_list=${Single_CA_SA_UE_List}    expected_dl_tput=${Single_dl_tput}
    ...    expected_ul_tput=${ul_tput}    mode=SA
    Trigger Interfreq XN Based SA Reverse handover    ue_id=${3cc_1cc_HO_CA_SA_UE}    A2_carrier_sim_freq=${A2_cf2}
    ...    A3_carrier_sim_freq=${A1_carrier_freq}    real_cell=3    nrci=7    phycell_id=52
    Reset ri and trigger A1 Event
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    3min    30s    Validate throughput from UE stats for all CA UEs    ue_list=${Single_CA_SA_UE_List}
    ...    expected_dl_tput=${Single_dl_tput}    expected_ul_tput=${ul_tput}    dl_scell=${SA_Scell_Index}    ul_scell=${UL_Scell_Index}
    Perform Scell Deactivation Stop Traffic And Detach for single SA UE
    Collect and Validate Gnb PM counters    SA_UE_List=${Single_CA_SA_UE_List}
    [Teardown]    Test Teardown    sa_ue_list=${Single_CA_SA_UE_List}

CB008366_TC5_IntraFrequency_IntergNB_FDD_CA_NGBased HO_for_SA_UE
    [Tags]    AP_REG    8366_TC5_INTRA_NGBased_HO
    [Setup]    Test Setup for handover scenario    Handover_Feature=CB008366    simulator_gnb_list=${Sim_Gnb_list_HO}    NGBased_HO=True
    Perform UE Attach and Verify scell addition for SA UEs
    Start Traffic and validate scell activation for SA UEs
    Trigger Intrafreq NG Based SA Forward handover    ue_id=${3cc_1cc_HO_CA_SA_UE}    carrier_frequency=${A1_carrier_freq}    phycell_id=57
    ...    primary_cell=3
    Validate Bearer Stats for multiple UEs    ue_list=${Single_CA_SA_UE_List}    expected_dl_tput=${Single_dl_tput}
    ...    expected_ul_tput=${ul_tput}    mode=SA
    Trigger Intrafreq NG Based SA Reverse handover    ue_id=${3cc_1cc_HO_CA_SA_UE}    carrier_frequency=${A1_carrier_freq}    nrci=2
    ...    phycell_id=52    real_cell=3
    Reset ri and trigger A1 Event
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    3min    30s    Validate throughput from UE stats for all CA UEs    ue_list=${Single_CA_SA_UE_List}
    ...    expected_dl_tput=${Single_dl_tput}    expected_ul_tput=${ul_tput}    dl_scell=${SA_Scell_Index}    ul_scell=${UL_Scell_Index}
    Perform Scell Deactivation Stop Traffic And Detach for single SA UE
    Collect and Validate Gnb PM counters    SA_UE_List=${Single_CA_SA_UE_List}
    [Teardown]    run keywords    Revert WTS and Gnb configuration    Handover_Feature=CB008366
    ...    AND    Test Teardown    sa_ue_list=${Single_CA_SA_UE_List}

CB008366_TC6_InterFrequency_IntergNB_FDD_CA_NGBased HO_for_SA_UE
    [Tags]    AP_REG    8366_TC6_INTER_NGBased_HO
    [Setup]    Test Setup for handover scenario    Handover_Feature=CB008366    simulator_gnb_list=${Sim_Gnb_list_HO}    NGBased_HO=True
    Perform UE Attach and Verify scell addition for SA UEs
    Start Traffic and validate scell activation for SA UEs
    Trigger Interfreq NG Based SA Forward handover    ue_id=${3cc_1cc_HO_CA_SA_UE}    primary_cell=3    phycell_id=58
    ...    A2_carrier_freq=${A1_carrier_freq}    A3_carrier_freq=${A3_cf_inter}
    Validate Bearer Stats for multiple UEs    ue_list=${Single_CA_SA_UE_List}    expected_dl_tput=${Single_dl_tput}
    ...    expected_ul_tput=${ul_tput}    mode=SA
    Trigger Interfreq NG Based SA Reverse handover    ue_id=${3cc_1cc_HO_CA_SA_UE}    real_cell=3    nrci=7    phycell_id=52
    ...    A2_carrier_sim_freq=${A2_cf2}    A3_carrier_sim_freq=${A1_carrier_freq}
    Reset ri and trigger A1 Event
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    3min    30s    Validate throughput from UE stats for all CA UEs    ue_list=${Single_CA_SA_UE_List}
    ...    expected_dl_tput=${Single_dl_tput}    expected_ul_tput=${ul_tput}    dl_scell=${SA_Scell_Index}    ul_scell=${UL_Scell_Index}
    Perform Scell Deactivation Stop Traffic And Detach for single SA UE
    Collect and Validate Gnb PM counters    SA_UE_List=${Single_CA_SA_UE_List}
    [Teardown]    run keywords    Revert WTS and Gnb configuration    Handover_Feature=CB008366
    ...    AND    Test Teardown    sa_ue_list=${Single_CA_SA_UE_List}

CB008366_TC7_IntraFrequency_IntergNB_FDD_CA_XNBased HO_for_SA_UE_with closed loop as dl_mimimode
    [Tags]    AP_REG    8366_TC7
    [Setup]    Test Setup for handover scenario    Handover_Feature=CB008366    simulator_gnb_list=${Sim_Gnb_list_HO}      closed_loop=True
    Perform UE Attach and Verify scell addition for SA UEs
    Start Traffic and validate scell activation for SA UEs
    Trigger Intrafreq XN Based SA Forward handover    ue_id=${3cc_1cc_HO_CA_SA_UE}    carrier_frequency=${A1_carrier_freq}    primary_cell=3
    ...    phycell_id=57
    Validate Bearer Stats for multiple UEs    ue_list=${Single_CA_SA_UE_List}    expected_dl_tput=${Single_dl_tput}
    ...    expected_ul_tput=${ul_tput}    mode=SA
    Trigger Intrafreq XN Based SA Reverse handover    ue_id=${3cc_1cc_HO_CA_SA_UE}    carrier_frequency=${A1_carrier_freq}    hist_id=1
    ...    phycell_id=52    nrci=2    primary_cell=3
    Reset ri and trigger A1 Event
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    3min    30s    Validate throughput from UE stats for all CA UEs    ue_list=${Single_CA_SA_UE_List}
    ...    expected_dl_tput=${Single_dl_tput}    expected_ul_tput=${ul_tput}    dl_scell=${SA_Scell_Index}    ul_scell=${UL_Scell_Index}
    Perform Scell Deactivation Stop Traffic And Detach for single SA UE
    Collect and Validate Gnb PM counters    SA_UE_List=${Single_CA_SA_UE_List}
    [Teardown]    run keywords    Revert WTS and Gnb configuration    Handover_Feature=CB008366_cl
    ...    AND    Test Teardown    sa_ue_list=${Single_CA_SA_UE_List}

CB008366_TC8_InterFrequency_IntergNB_FDD_CA_XNBased HO_for_SA_UE_with closed loop as dl_mimimode
    [Tags]    AP_REG    8366_TC8
    [Setup]    Test Setup for handover scenario    Handover_Feature=CB008366    simulator_gnb_list=${Sim_Gnb_list_HO}      closed_loop=True
    Perform UE Attach and Verify scell addition for SA UEs
    Start Traffic and validate scell activation for SA UEs
    Trigger Interfreq XN Based SA Forward handover    ue_id=${3cc_1cc_HO_CA_SA_UE}
    ...    A2_carrier_freq=${A1_carrier_freq}    A3_carrier_freq=${A3_cf_inter}    primary_cell=3    phycell_id=58
    Validate Bearer Stats for multiple UEs    ue_list=${Single_CA_SA_UE_List}    expected_dl_tput=${Single_dl_tput}
    ...    expected_ul_tput=${ul_tput}    mode=SA
    Trigger Interfreq XN Based SA Reverse handover    ue_id=${3cc_1cc_HO_CA_SA_UE}    A2_carrier_sim_freq=${A2_cf2}
    ...    A3_carrier_sim_freq=${A1_carrier_freq}    real_cell=3    nrci=7    phycell_id=52
    Reset ri and trigger A1 Event
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    3min    30s    Validate throughput from UE stats for all CA UEs    ue_list=${Single_CA_SA_UE_List}
    ...    expected_dl_tput=${Single_dl_tput}    expected_ul_tput=${ul_tput}    dl_scell=${SA_Scell_Index}    ul_scell=${UL_Scell_Index}
    Perform Scell Deactivation Stop Traffic And Detach for single SA UE
    Collect and Validate Gnb PM counters    SA_UE_List=${Single_CA_SA_UE_List}
    [Teardown]    run keywords    Revert WTS and Gnb configuration    Handover_Feature=CB008366_cl
    ...    AND    Test Teardown    sa_ue_list=${Single_CA_SA_UE_List}

*** Keywords ***
Perform UE Attach and Verify scell addition for SA UEs
    [Documentation]    Common keyword for UE register and validte scell addition for measurement based single UE
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
#    UE Register and Start Traffic For SA Non CA Capable UEs    ${Non_CA_SA_UE_List}
    Perform SA UE Register for Measurement based ScellAddition and Bufferbased ScellActivation with CSI Override
    ...    ${Single_CA_SA_UE_List}    ${A1_carrier_freq}    scell=${csi_scell}
    Verify scell addition for each scell index    ${SA_Scell_Index}

Start Traffic and validate scell activation for SA UEs
    [Documentation]    Common keyword to start trafic and validate traffic for measurement based single UE also to validate scell activation
    Start parallel traffic for all SA UEs    ${Single_CA_SA_UE_List}    dl_tput=${Single_dl_tput}    ul_tput=${ul_tput}
    Wait Until Keyword Succeeds    1 min    30sec
    ...    Verify scell activated for SA UEs    sa_ue_list=${Single_CA_SA_UE_List}    scell_index_list=${RLQ_Scell}
#    Run keyword And Continue On Failure
#    ...    wait until keyword succeeds    3min    30s    Validate Pcell Throughput from UE stats and bearer stats for Non CA Capable UEs
#    ...    {expected_ul_tput=${ul_tput}    expected_dl_tput=${ul_tput}    UE_List=${Non_CA_SA_UE_List}
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    3min    30s    Validate throughput from UE stats for all CA UEs    ue_list=${Single_CA_SA_UE_List}
    ...    expected_dl_tput=${Single_dl_tput}    expected_ul_tput=${ul_tput}    dl_scell=${SA_Scell_Index}    ul_scell=${UL_Scell_Index}

Perform Scell Deactivation Stop Traffic And Detach for single SA UE
    [Documentation]    Common keyword for scell deactivation, stop traffic and detach SA UEs
    Activate testmode and verify scell deactivation    ue_list=${Single_CA_SA_UE_List}    scell=${scell_deact}    scell_list=${RLQ_Scell}
#    Stop Traffic and Detach SA UEs    ${Non_CA_SA_UE_List}
    Stop Traffic and Detach CA SA UEs    ${Single_CA_SA_UE_List}    cf1=${A2_cf1}    cf2=${A2_cf2}

Reset RI and trigger A1 Event
    [Arguments]    ${csi_override_needed}=True    ${ue_id}=${3cc_1cc_HO_CA_SA_UE}    ${carrier_frequency}=${A1_carrier_freq}
    ...    ${phycell_id}=52    ${scell_index_list}=${RLQ_Scell}
    Run Keyword If    "${csi_override_needed}" == "True"
    ...    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    ${output_A1}    Trigger A1 Event measurement    ue_id=${ue_id}    pass_regexp=SCellIndex \\d+ activated successfully
    ...    carrier_frequency=${carrier_frequency}    srsrp_nr=40    phycell_id=${phycell_id}
    Wait Until Keyword Succeeds    1 min    30sec
    ...    Verify scell activated for SA UEs    sa_ue_list=${Single_CA_SA_UE_List}    scell_index_list=${scell_index_list}

Update WTS config file for CB008366
    [Documentation]    This keyword is used to take backup of wts file so that we can revert it back at test case teardown
    Run keyword And Ignore Error    Run And Return Rc And Output   cp ${WTS_INSTALL_PATH}/${WTS_FILE} ${WTS_INSTALL_PATH}/${WTS_BKUP_FILE}
    Copy File And Display Warning    ${CURDIR}/cfg/basic_setup_loki_ng.lua    /opt/wts/latest/
    Run keyword And Ignore Error    Run And Return Rc And Output   mv ${WTS_INSTALL_PATH}/basic_setup_loki_ng.lua ${WTS_INSTALL_PATH}/${WTS_FILE}
    [Teardown]    Run keyword And Ignore Error    Run And Return Rc And Output   cp ${WTS_INSTALL_PATH}/${WTS_FILE} ${testlog_path}

Update Gnb with closed loop dl mimomode for CB008366
    ${original_scf_path}    Download SCF file    local_dir_path=${testlog_path}    file_name=SCF_original.xml
    set test variable    ${original_scf_path}
    ${FDD_NRCELL1_DISTNAME}    admin_helper.get_distname_for_nrcell_using_logical_id    logical_cell_id=1
    set test variable    ${FDD_NRCELL1_DISTNAME}
    ${FDD_NRCELL2_DISTNAME}    admin_helper.get_distname_for_nrcell_using_logical_id    logical_cell_id=2
    set test variable    ${FDD_NRCELL2_DISTNAME}
    ${FDD_NRCELL3_DISTNAME}    admin_helper.get_distname_for_nrcell_using_logical_id    logical_cell_id=3
    set test variable    ${FDD_NRCELL3_DISTNAME}
    ${cl_param}    scf_helper.get_feature_paramters_from_scf    ${original_scf_path}     ${mimode_params}     ${FDD_NRCELL1_DISTNAME}
    set test variable    ${cl_param}
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    delta_store.update managed object and parameter to delta    dist_name=${FDD_NRCELL1_DISTNAME}    &{mimode_params}
    delta_store.update managed object and parameter to delta    dist_name=${FDD_NRCELL2_DISTNAME}    &{mimode_params}
    delta_store.update managed object and parameter to delta    dist_name=${FDD_NRCELL3_DISTNAME}    &{mimode_params}
    ${delta_store}    Collect Delta Store
    Recommission GNB With Delta    delta_file=${delta_store}    should_activate=${True}
    Set Test Variable    ${Gnb_Revert}    True
    Wait Until Keyword Succeeds     2min     30sec     Check if gNB is reachable    ${GNB_IP}

Update Gnb with NGBasedHO configuration for CB008366
    ${original_scf_path}    Download SCF file    local_dir_path=${testlog_path}    file_name=SCF_original.xml
    set test variable    ${original_scf_path}
    ${NRBTS_DISTNAME}    admin_helper.get_distname_for_nrbts
    set test variable    ${NRBTS_DISTNAME}
    ${FDD_NRCELL_DISTNAME}    admin_helper.get_distname_for_nrcell_using_logical_id    logical_cell_id=3
    set test variable    ${FDD_NRCELL_DISTNAME}
    Get original params from gnB
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    delta_store.update managed object and parameter to delta    dist_name=${NRBTS_DISTNAME}    &{NgHo_Inter_Intra_params}
    FOR    ${nrrel_id}    IN    @{nrrel_profile_id_fdd}
         delta_store.update managed object and parameter to delta    dist_name=${FDD_NRCELL_DISTNAME}/NRREL-${nrrel_id}    &{nrrel_params}
    END
    ${delta_store}    Collect Delta Store
    Recommission GNB With Delta    delta_file=${delta_store}    should_activate=${True}
    Set Test Variable    ${Gnb_Revert}    True
    Wait Until Keyword Succeeds     2min     30sec     Check if gNB is reachable    ${GNB_IP}

Get original params from gnB
    ${ng_ho_param}    scf_helper.get_feature_paramters_from_scf    ${original_scf_path}     ${NgHo_feature_param}     ${NRBTS_DISTNAME}
    &{nrrel_dict_fdd}     create dictionary
    FOR    ${nrrel_id}    IN    @{nrrel_profile_id_fdd}
         ${nrrel_distname}    set variable    ${FDD_NRCELL_DISTNAME}/NRREL-${nrrel_id}
         ${nrrel_param}    scf_helper.get_feature_paramters_from_scf    ${original_scf_path}     ${nrrel_params}    ${nrrel_distname}
         set to dictionary    ${nrrel_dict_fdd}    ${nrrel_distname}=${nrrel_param}
    END
    set test variable    ${ng_ho_param}
    set test variable    ${nrrel_dict_fdd}

Get Revert Delta Param for CB008366_cl
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    delta_store.update managed object and parameter to delta    dist_name=${FDD_NRCELL1_DISTNAME}    &{cl_param}
    delta_store.update managed object and parameter to delta    dist_name=${FDD_NRCELL2_DISTNAME}    &{cl_param}
    delta_store.update managed object and parameter to delta    dist_name=${FDD_NRCELL3_DISTNAME}    &{cl_param}
    ${delta_store}    Collect Delta Store
    [Return]    ${delta_store}

Get Revert Delta Param for CB008366
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    delta_store.update managed object and parameter to delta    dist_name=${NRBTS_DISTNAME}    &{ng_ho_param}
    FOR    ${nrrel_distname}    IN    @{nrrel_dict_fdd.keys()}
         delta_store.update managed object and parameter to delta    dist_name=${nrrel_distname}    &{nrrel_dict_fdd['${nrrel_distname}']}
    END
    ${delta_store}    Collect Delta Store
    [Return]    ${delta_store}

Ensure NG Link is Up for sim gNB
    [Arguments]    ${amf_id}=1    ${gnb_id}=2    ${type}=link_info
    Wait Until Keyword Succeeds    360s    60s    Execute Egate Command and wait for data    cmd=amf_disp id=${amf_id} type=${type} gnb=${gnb_id}
    ...    timeout=60s    pass_regexp=NG primary peer address.*up
