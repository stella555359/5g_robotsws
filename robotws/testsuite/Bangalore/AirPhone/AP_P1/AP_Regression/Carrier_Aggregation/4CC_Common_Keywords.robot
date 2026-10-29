*** Settings ***
Documentation    Common resource file which contains 4CC feature keywords

Resource        CA_Common_Keywords.robot

*** Variables ***
@{Counter_List}                     M55326C00501    M55326C00502    M55310C01006    M55310C03006
${UE_CAPA_6137_InterRAT}    SEPARATOR=
...     E9A01000074F5A1302000201404824C5800260D40426C030E7CC31EF1F07826010188E09D41B13B582308682041F2804596C98AA1A1CF88E3D03
...     3EC09F18E7CC31EF1F0781C3C1700000001C00000000300E0541B137582308682041F2804596C98AA1A1CF88E3D033EC09F18E7CC31EF1F0781C
...     3C170004F001C0013C000300E0541F11B582308682041F2804496C98AA0A1CF88E3C639F30C7BC7C1E070F027F0000001FC0000000300E0541F1
...     07582308682041F2804496C98AA0A1CF88E3C639F30C7BC7C1E070F027F0000001FC0000000300E0741B0A303582308682041F2804596C98AA1A
...     1CF88E3D033EC09F18E7CC31EF1F0781C3C17003FF001C00FFC000300E0541F06F582308682041F2804496C98AA0A1CF88E3C639F30C7BC7C1E0
...     70F027F4000001FD0000000300E0541F063582308682041F2804496C98AA0A1CF88E3C639F30C7BC7C1E070F027F0000001FC0000000300E0541
...     F01B582308682041F2804496C98AA0A1CF88E3C639F30C7BC7C1E070F027F0000001FC0000000300E0541F00B582308682041F2804496C98AA0A
...     1CF88E3C639F30C7BC7C1E070F027F0000001FC0000000300E0541F007582308682041F2804496C98AA0A1CF88E3C639F30C7BC7C1E070F027F0
...     000001FC0000000300E0541F003582308682041F2804496C98AA0A1CF88E3C639F30C7BC7C1E070F027F6000001FD8000000300E0541B0BF5823
...     08682041F2804596C98AA1A1CF88E3D033EC09F18E7CC31EF1F0781C3C2700048001C00120000300E0541B09F582308682041F2804596C98AA1A
...     1CF88E3D033EC09F18E7CC31EF1F0781C3C2700009001C00024000300E0541B097582308682041F2804596C98AA1A1CF88E3D033EC09F18E7CC3
...     1EF1F0781C3C2700040001C00100000300E0541F04F582308682041F2804496C98AA0A1CF88E3C639F30C7BC7C1E070F027F0000001FC0000000
...     300E0541F037582308682041F2804496C98AA0A1CF88E3C639F30C7BC7C1E070F027C0000001F00000000300E0541F02F582308682041F280449
...     6C98AA0A1CF88E3C639F30C7BC7C1E070F027E0000001F80000000300E0541F01F582308682041F2804496C98AA0A1CF88E3C639F30C7BC7C1E0
...     70F027F0000001FC0000000300E0541F013582308682041F2804496C98AA0A1CF88E3C639F30C7BC7C1E070F027F0000001FC0000000300E0341
...     B13303582308682041F2804596C98AA1A1CF88E3D033EC09F18E7CC31EF1F0781C3C12FFCBFF0308389A00000160E14040001010750F850001C4
...     6000E2080071300000104810120080204A0A81583707C0FA37601400884070226C73E1C28913639F0E03078E7C7A0380F000A070101C0C00C038
...     060080A07C0A004000000020000040100000400800003004000020020000140100000C008000070040000400200002401000014053286F286B03
...     6B036B056B066B266B296B236B016B0268180800004B29202000032CA4A0800014B29202000072CA4A0800024B292820000B2CA4A0800034B292
...     820000F2CA4A0800028B29282000112CA4A080004CB29282000152CA4A080005CB292816A51174A36A81CD505DAA0DB54AB6E956D526DAA53B54
...     8F6A80ED502DA021D00AA050381C0E07028140A0703800100040080100080100230100200404018030100600C040080118A0302414246400
&{4CC_NgHo_params}          actIntraNrNgHo=sourceAndTarget    tNgRelocCancelN=2000    tNgRelocPrepN=2000
...                           tNgRelocOverallN=2000    tNgRelocExecDeltN=2000

*** Keywords ***
Verify scell activated for all SA UEs
    [Arguments]    ${sa_ue_list}    ${scell_index_list}=${4CC_scell_index}
    Execute Egate Command    cmd=sim_log_set flush    timeout=2s
    FOR    ${ue_id}    IN    @{sa_ue_list}
        Verify scell activation for each scell index    ${ue_id}    ${scell_index_list}
    END

Start traffic for all SA UEs
    [Arguments]     ${CA_SA_UE_List}    ${CA_DL_tput_list}    ${CA_UL_tput}    ${scell_index_list}=${4CC_scell_index}
    FOR    ${ue_id}    IN    @{CA_SA_UE_List}
        Log To Console    Going To Start Traffic UL for SA UE: ${ue_id}
        Start Traffic    ue_id=${ue_id}    dir=ul    pdu=3    mbps=${CA_UL_tput}
    END
    Start DL SA Traffic for each trf id in multi UE scenario    ${CA_SA_UE_List}    ${CA_DL_tput_list}
    sleep     10s    reason=Waiting for all Scells to be activated
    Wait Until Keyword Succeeds    3 min    30sec    Verify scell activated for all SA UEs    ${CA_SA_UE_List}    ${scell_index_list}

Start DL SA Traffic for each trf id in multi UE scenario
    [Arguments]    ${ue_id_list}    ${dl_tput_list}
    FOR    ${index}    ${dl_tput}    IN ENUMERATE    @{dl_tput_list}
        ${trf_id}=    Evaluate    ${index} + 1
        Start traffic for each trf id for all UEs    ${ue_id_list}    ${trf_id}    ${dl_tput}    dir=dl
    END

Start UL SA Traffic for each trf id in multi UE scenario
    [Arguments]    ${ue_id_list}    ${ul_tput_list}
    FOR    ${index}    ${ul_tput}    IN ENUMERATE    @{ul_tput_list}
        ${trf_id}=    Evaluate    ${index} + 1
        Start traffic for each trf id for all UEs    ${ue_id_list}    ${trf_id}    ${ul_tput}    dir=ul
    END

Start traffic for each trf id for all UEs
    [Arguments]    ${ue_id_list}    ${trf_id}    ${tput}    ${dir}=dl
    FOR    ${ue_id}    IN    @{ue_id_list}
         Start Traffic    ue_id=${ue_id}    dir=${dir}    pdu=3    trf_id=${trf_id}    mbps=${tput}
    END

Validate Pcell and Scell Throughput For SA UEs
    [Arguments]    ${expected_dl_tput}    ${UE_List}    ${Scell_Id}
    ${expected_dl_value}    Evaluate    isinstance(${expected_dl_tput}, list) == True
    ${expected_total_dl_tput}    Run Keyword If    ${expected_dl_value}    Evaluate
    ...    sum([int(str(x).encode('ascii')) for x in @{expected_dl_tput}])    ELSE    Set Variable    ${expected_dl_tput}
    FOR    ${ue_id}    IN    @{UE_List}
        Log To Console    Going To Check Throughput for SA UE: ${ue_id}
        sleep    10s
        ${total_tput}    Get Throughput from all cells    ${ue_id}     ${Scell_Id}
        Total CA UE Throughput Verification from cell stats   ${total_tput}    ${expected_total_dl_tput}
    END

Validate Pcell Throughput For Non CA Capable UEs
    [Arguments]    ${expected_dl_tput}    ${UE_List}
    FOR    ${ue_id}    IN    @{UE_List}
        Log To Console    Going To Check Throughput for Non CA Capable SA UE: ${ue_id}
        ${pcell_tput}    Cell Specific Throughput Validation    ue_id=${ue_id}    scell=0
        Total CA UE Throughput Verification from cell stats   ${pcell_tput}    ${expected_dl_tput}
    END

Perform Stop Traffic and Detach NSA UEs
    [Arguments]    ${nsa_ue_list}=${EMPTY}
    Log    ${nsa_ue_list}
    log to console    No NSA UE's to be detached

Perform Stop Traffic and Detach SA Non CA Capable UEs
    [Arguments]    ${sa_nonca_ue_list}
    Log    ${sa_nonca_ue_list}
    log to console    Dummy Keyword

Perform Stop Traffic and Detach SA UEs
    [Arguments]    ${sa_ue_list}
    Log    ${sa_ue_list}
    log to console    Dummy Keyword

Trigger Interfreq SA handover from Sim gNB to Real gNB for 4CC
    [Arguments]    ${ue_id}    ${scell_index}    ${A2_carrier_sim_freq}=527790    ${A3_carrier_sim_freq}=509790
    ...    ${csi_override_needed}=False    ${primary_cell}=2    ${phycell_id}=52    ${srsrp_nr}=100
    log to console    SA reverse handover from simulator gNB23 cell1 to Real gNB2 cell${primary_cell}...
    Trigger A2 Event measurement    ue_id=${ue_id}    pass_regexp=measurementReport    carrier_frequency=${A2_carrier_sim_freq}
    ...    srsrp_nr=7    srsrq_nr=7
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}
    ...    pass_regexp=UE${ue_id}: XN Handover Successfully completed at Source
    ...    carrier_frequency=${A3_carrier_sim_freq}    srsrp_nr=11    srsrq_nr=11    phycell_id=${phycell_id}    nrsrp_nr=30    nrsrq_nr=30
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: CTRL_RACH_COMPLETE Received*
    Validate success prints from command output    ${output}    pass_regex=*Received PATH SWITCH REQUEST from GNB-2*
    Run Keyword If    "${csi_override_needed}" == "True"
    ...    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    Trigger A1 Event measurement    ue_id=${ue_id}    pass_regexp=measurementReport
    ...    carrier_frequency=${A3_carrier_sim_freq}   srsrp_nr=${srsrp_nr}
    Verify scell activation for each scell index    ${ue_id}    ${scell_index}
    sleep    10s   reason=To stabilise traffic txput

Trigger Intrafreq NG Based SA handover from Sim gNB to Real gNB for 4CC
    [Arguments]    ${ue_id}    ${scell_index}    ${carrier_frequency}=507150    ${primary_cell}=2    ${phycell_id}=52    ${srsrp_nr}=100
    log to console    SA reverse handover from simulator gNB22 cell1 to real gNB2 cell${primary_cell}
    Update UE History Information    id=1    cell_type=large    nrcgi=311:489|0x06
    ...    gnb_id=22    time_ue_stayed_in_cell=97    action=commit    ue_enb_param_id=${ue_id}
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=Inter-eNB handover
    ...    carrier_frequency=${carrier_frequency}    srsrp_nr=11    srsrq_nr=11    phycell_id=${phycell_id}    nrsrp_nr=30    nrsrq_nr=30
    Log To Console    Validating NG based SA reverse handover...
    Validate success prints from command output    ${output}    pass_regex=*NgAPHANDOVER_REQUEST*
    Validate success prints from command output    ${output}    pass_regex=*HANDOVER REQUIRED: gNB=22, AMF_UE_NGAP_ID*
    Validate success prints from command output    ${output}    pass_regex=*HANDOVER REQUIRED: gNB=22, RAN_UE_NGAP_ID=2*
    Validate success prints from command output    ${output}
    ...    pass_regex=*UE${ue_id}: Inter-eNB handover from ENB-22.1 to EXT_ENB-2.${primary_cell} performed*
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    Trigger A1 Event measurement    ue_id=${ue_id}    pass_regexp=measurementReport
    ...    carrier_frequency=${A1_carrier_freq}   srsrp_nr=${srsrp_nr}
    Verify scell activation for each scell index    ${ue_id}    ${scell_index}
    sleep    10s   reason=To stabilise traffic txput

Update WTS config file for CB008532
    Run keyword And Ignore Error    Run And Return Rc And Output   cp ${WTS_INSTALL_PATH}/basic_setup.cfg ${WTS_INSTALL_PATH}/basic_setup_backup.cfg
    wts_conf.load_wts_cfg    file_path=${WTS_INSTALL_PATH}/basic_setup.cfg
    wts_conf.modify    command=set_gnb id=2 type=external    modification=gnb_id=0x01
    wts_conf.modify    command=set_cell id=1 gnb=2    modification=nrci=0x01
    wts_conf.modify    command=set_cell id=2 gnb=2    modification=nrci=0x02
    wts_conf.modify    command=set_cell id=3 gnb=2    modification=nrci=0x03
    wts_conf.modify    command=set_cell id=4 gnb=2    modification=nrci=0x04
    wts_conf.modify    command=gnb_param id=22   modification=xn_listening_socket=1 send_xn_setup=false measEvent=A2 measEvent=A3 sa_ho=ng_based
    wts_conf.modify    command=gnb_param id=23   modification=xn_listening_socket=1 send_xn_setup=false measEvent=A2 measEvent=A3 sa_ho=ng_based
    wts_conf.save_wts_cfg    file_path=${WTS_INSTALL_PATH}/basic_setup.cfg
    [Teardown]    Run keyword And Ignore Error    Run And Return Rc And Output   cp ${WTS_INSTALL_PATH}/basic_setup.cfg ${testlog_path}

Update WTS config file for CB008533
    Run keyword And Ignore Error    Run And Return Rc And Output   cp ${WTS_INSTALL_PATH}/basic_setup.cfg ${WTS_INSTALL_PATH}/basic_setup_backup.cfg
    wts_conf.load_wts_cfg    file_path=${WTS_INSTALL_PATH}/basic_setup.cfg
    wts_conf.modify    command=set_gnb id=2 type=external    modification=gnb_id=0x01
    wts_conf.modify    command=set_cell id=1 gnb=2    modification=nrci=0x01
    wts_conf.modify    command=set_cell id=2 gnb=2    modification=nrci=0x02
    wts_conf.modify    command=set_cell id=3 gnb=2    modification=nrci=0x03
    wts_conf.modify    command=set_cell id=4 gnb=2    modification=nrci=0x04
    wts_conf.modify    command=gnb_param id=22   modification=xn_listening_socket=1 send_xn_setup=false measEvent=A2 measEvent=A3 sa_ho=ng_based
    wts_conf.modify    command=gnb_param id=23   modification=xn_listening_socket=1 send_xn_setup=false measEvent=A2 measEvent=A3 sa_ho=ng_based
    wts_conf.save_wts_cfg    file_path=${WTS_INSTALL_PATH}/basic_setup.cfg
    [Teardown]    Run keyword And Ignore Error    Run And Return Rc And Output   cp ${WTS_INSTALL_PATH}/basic_setup.cfg ${testlog_path}

Update Gnb with NGBasedHO configuration for CB008532
    ${original_scf_path}    Download SCF file    local_dir_path=${testlog_path}    file_name=SCF_original.xml
    set test variable    ${original_scf_path}
    ${NRBTS_DISTNAME}    admin_helper.get_distname_for_nrbts
    set test variable    ${NRBTS_DISTNAME}
    ${NRCELL_DISTNAME}    admin_helper.get_distname_for_nrcell_using_logical_id    logical_cell_id=2
    set test variable    ${NRCELL_DISTNAME}
    Get original params from gnB
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    delta_store.update managed object and parameter to delta    dist_name=${NRBTS_DISTNAME}    &{4CC_NgHo_params}
    FOR    ${nrrel_id}    IN    @{nrrel_profile_id}
         delta_store.update managed object and parameter to delta    dist_name=${NRCELL_DISTNAME}/NRREL-${nrrel_id}    &{nrrel_params}
    END
    ${delta_store}    Collect Delta Store
    Recommission GNB With Delta    delta_file=${delta_store}    should_activate=${True}
    Set Test Variable    ${Gnb_Revert}    True
    Wait Until Keyword Succeeds     2min     30sec     Check if gNB is reachable    ${GNB_IP}

Update Gnb with NGBasedHO configuration for CB008533
    ${original_scf_path}    Download SCF file    local_dir_path=${testlog_path}    file_name=SCF_original.xml
    set test variable    ${original_scf_path}
    ${NRBTS_DISTNAME}    admin_helper.get_distname_for_nrbts
    set test variable    ${NRBTS_DISTNAME}
    ${NRCELL_DISTNAME}    admin_helper.get_distname_for_nrcell_using_logical_id    logical_cell_id=1
    set test variable    ${NRCELL_DISTNAME}
    Get original params from gnB
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    delta_store.update managed object and parameter to delta    dist_name=${NRBTS_DISTNAME}    &{4CC_NgHo_params}
    FOR    ${nrrel_id}    IN    @{nrrel_profile_id}
         delta_store.update managed object and parameter to delta    dist_name=${NRCELL_DISTNAME}/NRREL-${nrrel_id}    &{nrrel_params}
    END
    ${delta_store}    Collect Delta Store
    Recommission GNB With Delta    delta_file=${delta_store}    should_activate=${True}
    Set Test Variable    ${Gnb_Revert}    True
    Wait Until Keyword Succeeds     2min     30sec     Check if gNB is reachable    ${GNB_IP}

Get original params from gnB
    ${ng_ho_param}    scf_helper.get_feature_paramters_from_scf    ${original_scf_path}     ${4CC_NgHo_params}     ${NRBTS_DISTNAME}
    &{nrrel_dict}     create dictionary
    FOR    ${nrrel_id}    IN    @{nrrel_profile_id}
         ${nrrel_distname}    set variable    ${NRCELL_DISTNAME}/NRREL-${nrrel_id}
         ${nrrel_param}    scf_helper.get_feature_paramters_from_scf    ${original_scf_path}     ${nrrel_params}    ${nrrel_distname}
         set to dictionary    ${nrrel_dict}    ${nrrel_distname}=${nrrel_param}
    END
    set test variable    ${ng_ho_param}
    set test variable    ${nrrel_dict}

Trigger Interfreq NG Based SA handover from Sim gNB to Real gNB for 4CC
    [Arguments]    ${ue_id}    ${scell_index}    ${A2_carrier_sim_freq}=527790    ${A3_carrier_sim_freq}=509790    ${A1_carrier_freq}=509790
    ...    ${primary_cell}=2    ${phycell_id}=52    ${srsrp_nr}=100
    log to console    SA reverse handover from simulator gNB23 cell1 to Real gNB2 cell${primary_cell}...
    Update UE History Information    id=1    cell_type=large    nrcgi=311:489|0x07
    ...    gnb_id=23    time_ue_stayed_in_cell=98    action=commit    ue_enb_param_id=${ue_id}
    Trigger A2 Event measurement    ue_id=${ue_id}    pass_regexp=measurementReport    carrier_frequency=${A2_carrier_sim_freq}
    ...    srsrp_nr=7    srsrq_nr=7
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=Inter-eNB handover
    ...    carrier_frequency=${A3_carrier_sim_freq}    srsrp_nr=11    srsrq_nr=11    phycell_id=${phycell_id}    nrsrp_nr=30    nrsrq_nr=30
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: CTRL_RACH_COMPLETE Received*
    Validate success prints from command output    ${output}
    ...    pass_regex=*UE${ue_id}: Inter-eNB handover from ENB-23.1 to EXT_ENB-2.${primary_cell} performed*
    Validate success prints from command output    ${output}    pass_regex=*HANDOVER REQUIRED: gNB=23, AMF_UE_NGAP_ID*
    Validate success prints from command output    ${output}    pass_regex=*HANDOVER REQUIRED: gNB=23, RAN_UE_NGAP_ID=2*
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    Trigger A1 Event measurement    ue_id=${ue_id}    pass_regexp=measurementReport
    ...    carrier_frequency=${A1_carrier_freq}   srsrp_nr=${srsrp_nr}
    Verify scell activation for each scell index    ${ue_id}    ${scell_index}
    sleep    10s   reason=To stabilise traffic txput

Get Revert Delta Param for CB008532
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    delta_store.update managed object and parameter to delta    dist_name=${NRBTS_DISTNAME}    &{4CC_NgHo_params}
    FOR    ${nrrel_distname}    IN    @{nrrel_dict.keys()}
         delta_store.update managed object and parameter to delta    dist_name=${nrrel_distname}    &{nrrel_dict['${nrrel_distname}']}
    END
    ${delta_store}    Collect Delta Store
    [Return]    ${delta_store}

Get Revert Delta Param for CB008533
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    delta_store.update managed object and parameter to delta    dist_name=${NRBTS_DISTNAME}    &{ng_ho_param}
    FOR    ${nrrel_distname}    IN    @{nrrel_dict.keys()}
         delta_store.update managed object and parameter to delta    dist_name=${nrrel_distname}    &{nrrel_dict['${nrrel_distname}']}
    END
    ${delta_store}    Collect Delta Store
    [Return]    ${delta_store}

Trigger Intrafreq SA handover from Sim gNB to Real gNB for 4CC
    [Arguments]    ${ue_id}    ${scell_index}    ${A3_carrier_sim_freq}=${A1_real_gnb_carrier_freq_cell3}    ${primary_cell}=2
    ...    ${A1_carrier_freq}=${A1_real_gnb_carrier_freq_cell3}    ${csi_override_needed}=False    ${phycell_id}=52    ${srsrp_nr}=100
    log to console    SA reverse handover from simulator gNB22 cell1 to Real gNB2 cell${primary_cell}...
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}
    ...    pass_regexp=UE${ue_id}: XN Handover Successfully completed at Source
    ...    carrier_frequency=${A3_carrier_sim_freq}    srsrp_nr=11    srsrq_nr=11    phycell_id=${phycell_id}    nrsrp_nr=30    nrsrq_nr=30
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: CTRL_RACH_COMPLETE Received*
    Validate success prints from command output    ${output}    pass_regex=*Received PATH SWITCH REQUEST from GNB-2*
    Run Keyword If    "${csi_override_needed}" == "True"
    ...    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    Trigger A1 Event measurement    ue_id=${ue_id}    pass_regexp=measurementReport
    ...    carrier_frequency=${A1_carrier_freq}   srsrp_nr=${srsrp_nr}
    Verify scell activation for each scell index    ${ue_id}    ${scell_index}
    sleep    10s   reason=To stabilise traffic txput

Update WTS config file for InterRAT handover CB008532
    Run keyword And Ignore Error    Run And Return Rc And Output   cp ${WTS_INSTALL_PATH}/basic_setup.cfg ${WTS_INSTALL_PATH}/basic_setup_backup.cfg
    wts_conf.load_wts_cfg    file_path=${WTS_INSTALL_PATH}/basic_setup.cfg
    ${set_cell_2}     catenate
    ...       set_cell id=2 gnb=3 pci=3:2 earfcn=1400:19400 tac=200 proxy=$DAEMON_IP:9999|$DAEMON_IP:8888
    ...       nrci=0x8 tdd_cell=on bw=20MHz technology=lte mandatory_for_activation=off
    wts_conf.insert    command=set ENB2_S1_ADDR="10.0.1.140"   location=after    reference=set GNB_S1U_ADDR="10.0.1.112"
    wts_conf.modify    command=set_gnb id=2 type=external    modification=gnb_id=0x01
    wts_conf.modify    command=set_cell id=2 gnb=2    modification=nrci=0x02
    wts_conf.modify    command=set_cell id=3 gnb=2    modification=nrci=0x03
    wts_conf.modify    command=set_cell id=4 gnb=2    modification=nrci=0x04
    wts_conf.insert    set_gnb id=3 type=simulated plmn=311:489 ng=$ENB2_S1_ADDR daemon=$SERVER_IP:$EDAEMON_PORT gnb_id=012:28 nssai=0x01:0xD143A5
    ...                after    set_cell id=1 gnb=23
    wts_conf.insert    ${set_cell_2}
    ...                after    set_gnb id=3
    wts_conf.save_wts_cfg    file_path=${WTS_INSTALL_PATH}/basic_setup.cfg
    [Teardown]    Run keyword And Ignore Error    Run And Return Rc And Output   cp ${WTS_INSTALL_PATH}/basic_setup.cfg ${testlog_path}

Update WTS config file for InterRAT handover CB008533
    Run keyword And Ignore Error    Run And Return Rc And Output   cp ${WTS_INSTALL_PATH}/basic_setup.cfg ${WTS_INSTALL_PATH}/basic_setup_backup.cfg
    wts_conf.load_wts_cfg    file_path=${WTS_INSTALL_PATH}/basic_setup.cfg
    ${set_cell_2}     catenate
    ...       set_cell id=2 gnb=3 pci=3:2 earfcn=1400:19400 tac=200 proxy=$DAEMON_IP:9999|$DAEMON_IP:8888
    ...       nrci=0x8 tdd_cell=on bw=20MHz technology=lte mandatory_for_activation=off
    wts_conf.insert    command=set ENB2_S1_ADDR="10.0.1.139"   location=after    reference=set GNB_S1U_ADDR="10.0.1.112"
    wts_conf.modify    command=set_gnb id=2 type=external    modification=gnb_id=0x01
    wts_conf.modify    command=set_cell id=2 gnb=2    modification=nrci=0x02
    wts_conf.modify    command=set_cell id=3 gnb=2    modification=nrci=0x03
    wts_conf.modify    command=set_cell id=4 gnb=2    modification=nrci=0x04
    wts_conf.insert    set_gnb id=3 type=simulated plmn=311:489 ng=$ENB2_S1_ADDR daemon=$SERVER_IP:$EDAEMON_PORT gnb_id=012:28 nssai=0x01:0xD143A5
    ...                after    set_cell id=1 gnb=23
    wts_conf.insert    ${set_cell_2}
    ...                after    set_gnb id=3
    wts_conf.save_wts_cfg    file_path=${WTS_INSTALL_PATH}/basic_setup.cfg
    [Teardown]    Run keyword And Ignore Error    Run And Return Rc And Output   cp ${WTS_INSTALL_PATH}/basic_setup.cfg ${testlog_path}

Update Gnb with InterRAT configuration for CB008532
    ${original_scf_path}    Download SCF file    local_dir_path=${testlog_path}    file_name=SCF_original.xml
    set test variable    ${original_scf_path}
    ${NRBTS_DISTNAME}    admin_helper.get_distname_for_nrbts
    set test variable    ${NRBTS_DISTNAME}
    Get original params from gnB for interrat handover
    Recommission GNB With Delta    delta_file=${interrat_gnb_delta_json}    should_activate=${True}
    Set Test Variable    ${Gnb_Revert}    True
    Wait Until Keyword Succeeds     2min     30sec     Check if gNB is reachable    ${GNB_IP}

Update Gnb with InterRAT configuration for CB008533
    ${original_scf_path}    Download SCF file    local_dir_path=${testlog_path}    file_name=SCF_original.xml
    set test variable    ${original_scf_path}
    ${NRBTS_DISTNAME}    admin_helper.get_distname_for_nrbts
    set test variable    ${NRBTS_DISTNAME}
    Get original params from gnB for interrat handover
    Recommission GNB With Delta    delta_file=${interrat_gnb_delta_json}    should_activate=${True}
    Set Test Variable    ${Gnb_Revert}    True
    Wait Until Keyword Succeeds     2min     30sec     Check if gNB is reachable    ${GNB_IP}

Get original params from gnB for interrat handover
    ${interrat_feature_param}    scf_helper.get_feature_paramters_from_scf    ${original_scf_path}     ${InterRAT_params}     ${NRBTS_DISTNAME}
    set test variable    ${interrat_feature_param}

Get Revert Delta Param for interrat handover CB008532
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    delta_store.update managed object and parameter to delta    dist_name=${NRBTS_DISTNAME}    &{interrat_feature_param}
    delta_store.delete_param_from_delta             dist_name=${NRBTS_DISTNAME}/NRCELL-2    param_name=nrhoirDNList
    delta_store.delete_managed_object_from_delta    dist_name=${NRBTS_DISTNAME}/NRADJECELL-1
    delta_store.delete_managed_object_from_delta    dist_name=${NRBTS_DISTNAME}/NRCELL-2/NRRELE-1
    delta_store.delete_managed_object_from_delta    dist_name=${NRBTS_DISTNAME}/NRHOIR-1
    ${delta_store}    Collect Delta Store
    [Return]    ${delta_store}

Get Revert Delta Param for interrat handover CB008533
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    delta_store.update managed object and parameter to delta    dist_name=${NRBTS_DISTNAME}    &{interrat_feature_param}
    delta_store.delete_param_from_delta             dist_name=${NRBTS_DISTNAME}    param_name=tNgRelocExecDeltL
    delta_store.delete_param_from_delta             dist_name=${NRBTS_DISTNAME}/NRCELL-1    param_name=nrhoirDNList
    delta_store.delete_managed_object_from_delta    dist_name=${NRBTS_DISTNAME}/NRADJECELL-1
    delta_store.delete_managed_object_from_delta    dist_name=${NRBTS_DISTNAME}/NRCELL-1/NRRELE-1
    delta_store.delete_managed_object_from_delta    dist_name=${NRBTS_DISTNAME}/NRHOIR-1
    ${delta_store}    Collect Delta Store
    [Return]    ${delta_store}

Trigger InterRAT SA handover from Sim eNB to Real gNB
    [Arguments]    ${ue_id}    ${scell_index}    ${primary_cell}=2    ${A1_carrier_freq}=${A1_real_gnb_carrier_freq_cell3}
    ...    ${srsrp_nr}=100
    Trigger InterRAT SA Reverse Handover     ue_id=${ue_id}    primary_cell=${primary_cell}
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    Trigger A1 Event measurement    ue_id=${ue_id}    pass_regexp=measurementReport
    ...    carrier_frequency=${A1_carrier_freq}   srsrp_nr=${srsrp_nr}
    Verify scell activation for each scell index    ${ue_id}    ${scell_index}
    sleep    10s   reason=To stabilise traffic txput

## 4CC DL and 2CC UL keywords

Validate uplink and downlink cell throughput from UE stats and bearer stats for SA UEs
    [Arguments]    ${expected_dl_tput}    ${expected_ul_tput}    ${UE_List}    ${UL_Scell_Id}
    ...    ${DL_Scell_Id}    ${UL_Scell_Id_2}=${EMPTY}
    ${expected_dl_value}    Evaluate    isinstance(${expected_dl_tput}, list) == True
    ${expected_total_dl_tput}    Run Keyword If    ${expected_dl_value}    Evaluate
    ...    sum([int(str(x).encode('ascii')) for x in @{expected_dl_tput}])    ELSE    Set Variable    ${expected_dl_tput}
    ${expected_ul_value}    Evaluate    isinstance(${expected_ul_tput}, list) == True
    ${expected_total_ul_tput}    Run Keyword If    ${expected_ul_value}    Evaluate
    ...    sum([int(str(x).encode('ascii')) for x in @{expected_ul_tput}])    ELSE    Set Variable    ${expected_ul_tput}
    FOR    ${ue_id}    IN    @{UE_List}
        Log To Console    Going To Check Throughput for SA UE: ${ue_id}
        sleep    10s
        ${cell_stats_total_tput_UL}    ${bearer_stats_UL_tput}    Run Keyword If    '${ue_id}' == '3' or '${ue_id}' == '5'
        ...    Get throughput from ue stats and bearer stats     ${ue_id}    ${UL_Scell_Id}    dir=ul
        ...    ELSE    Get throughput from ue stats and bearer stats    ${ue_id}    ${UL_Scell_Id_2}    dir=ul
        ${cell_stats_total_tput_DL}    ${bearer_stats_DL_tput}    Get throughput from ue stats and bearer stats
        ...     ${ue_id}    ${DL_Scell_Id}    dir=dl
        Total CA UE Throughput Verification from cell stats   ${cell_stats_total_tput_DL}    ${expected_total_dl_tput}
        Total CA UE Throughput Verification from cell stats   ${cell_stats_total_tput_UL}    ${expected_total_ul_tput}
    END

Start Uplink and Downlink traffic for 4CC_DL+2CC_UL
    [Arguments]     ${CA_SA_UE_List}    ${CA_DL_tput_list}    ${CA_UL_tput}    ${scell_index_list}=${4CC_scell_index}
    Start DL SA Traffic for each trf id in multi UE scenario    ${CA_SA_UE_List}    ${CA_DL_tput_list}
    sleep     10s    reason=Waiting for all Scells to be activated
    Start traffic for each trf id for all UEs    ${CA_SA_UE_List}    trf_id=1    tput=${CA_UL_tput}    dir=ul
    Wait Until Keyword Succeeds    3 min    30sec    Verify scell activated for all SA UEs    ${CA_SA_UE_List}    ${scell_index_list}

Start Uplink and Downlink traffic
    [Arguments]     ${CA_SA_UE_List}    ${CA_DL_tput_list}    ${CA_UL_tput_list}    ${scell_index_list}=${4CC_scell_index}
    Start UL SA Traffic for each trf id in multi UE scenario    ${CA_SA_UE_List}    ${CA_UL_tput_list}
    Start DL SA Traffic for each trf id in multi UE scenario    ${CA_SA_UE_List}    ${CA_DL_tput_list}
    Wait Until Keyword Succeeds    3 min    30sec    Verify scell activated for all SA UEs    ${CA_SA_UE_List}    ${scell_index_list}

Update WTS config file for CB006137
    Run keyword And Ignore Error    Run And Return Rc And Output   cp ${WTS_INSTALL_PATH}/basic_setup.cfg ${WTS_INSTALL_PATH}/basic_setup_backup.cfg
    wts_conf.load_wts_cfg    file_path=${WTS_INSTALL_PATH}/basic_setup.cfg
    wts_conf.modify    command=set_gnb id=2 type=external    modification=gnb_id=0x01
    Run Keyword If    'BOO' in '${TOPOLOGY}'    wts_conf.modify    command=set_cell id=1 gnb=2    modification=nrci=0x01
    Run Keyword If    'BOO' in '${TOPOLOGY}'    wts_conf.modify    command=set_cell id=2 gnb=2    modification=nrci=0x02
    Run Keyword If    'BOO' in '${TOPOLOGY}'    wts_conf.modify    command=set_cell id=3 gnb=2    modification=nrci=0x03
    Run Keyword If    'BOO' in '${TOPOLOGY}'    wts_conf.modify    command=set_cell id=11 gnb=2    modification=nrci=0x11
    Run Keyword If    'BOO' in '${TOPOLOGY}'    wts_conf.modify    command=set_cell id=12 gnb=2    modification=nrci=0x12
    wts_conf.modify    command=gnb_param id=22   modification=xn_listening_socket=1 send_xn_setup=false measEvent=A2 measEvent=A3 sa_ho=ng_based
    wts_conf.modify    command=gnb_param id=23   modification=xn_listening_socket=1 send_xn_setup=false measEvent=A2 measEvent=A3 sa_ho=ng_based
    wts_conf.save_wts_cfg    file_path=${WTS_INSTALL_PATH}/basic_setup.cfg
    [Teardown]    Run keyword And Ignore Error    Run And Return Rc And Output   cp ${WTS_INSTALL_PATH}/basic_setup.cfg ${testlog_path}

Update Gnb with NGBasedHO configuration for CB006137
    ${original_scf_path}    Download SCF file    local_dir_path=${testlog_path}    file_name=SCF_original.xml
    set test variable    ${original_scf_path}
    ${NRBTS_DISTNAME}    admin_helper.get_distname_for_nrbts
    set test variable    ${NRBTS_DISTNAME}
    ${NRCELL_DISTNAME}    Run Keyword If    'AP_LO' in '${TOPOLOGY}'    admin_helper.get_distname_for_nrcell_using_logical_id    logical_cell_id=1
    ...    ELSE    admin_helper.get_distname_for_nrcell_using_logical_id    logical_cell_id=3
    set test variable    ${NRCELL_DISTNAME}
    Get original params from gnB
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    delta_store.update managed object and parameter to delta    dist_name=${NRBTS_DISTNAME}    &{4CC_NgHo_params}
    FOR    ${nrrel_id}    IN    @{nrrel_profile_id}
         delta_store.update managed object and parameter to delta    dist_name=${NRCELL_DISTNAME}/NRREL-${nrrel_id}    &{nrrel_params}
    END
    ${delta_store}    Collect Delta Store
    Recommission GNB With Delta    delta_file=${delta_store}    should_activate=${True}
    Set Test Variable    ${Gnb_Revert}    True
    Wait Until Keyword Succeeds     2min     30sec     Check if gNB is reachable    ${GNB_IP}

Get Revert Delta Param for CB006137
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    delta_store.update managed object and parameter to delta    dist_name=${NRBTS_DISTNAME}    &{ng_ho_param}
    FOR    ${nrrel_distname}    IN    @{nrrel_dict.keys()}
         delta_store.update managed object and parameter to delta    dist_name=${nrrel_distname}    &{nrrel_dict['${nrrel_distname}']}
    END
    ${delta_store}    Collect Delta Store
    [Return]    ${delta_store}

Update WTS config file for InterRAT handover CB006137
    Run keyword And Ignore Error    Run And Return Rc And Output   cp ${WTS_INSTALL_PATH}/basic_setup.cfg ${WTS_INSTALL_PATH}/basic_setup_backup.cfg
    wts_conf.load_wts_cfg    file_path=${WTS_INSTALL_PATH}/basic_setup.cfg
    ${set_cell_2}     catenate
    ...       set_cell id=2 gnb=3 pci=3:2 earfcn=1400:19400 tac=200 proxy=$DAEMON_IP:9999|$DAEMON_IP:8888
    ...       nrci=0x06 tdd_cell=on bw=20MHz technology=lte mandatory_for_activation=off
    Run Keyword If    'BOO' in '${TOPOLOGY}'    wts_conf.modify    command=set_cell id=1 gnb=2    modification=nrci=0x01
    Run Keyword If    'BOO' in '${TOPOLOGY}'    wts_conf.modify    command=set_cell id=2 gnb=2    modification=nrci=0x02
    Run Keyword If    'BOO' in '${TOPOLOGY}'    wts_conf.modify    command=set_cell id=3 gnb=2    modification=nrci=0x03
    Run Keyword If    'BOO' in '${TOPOLOGY}'    wts_conf.modify    command=set_cell id=11 gnb=2    modification=nrci=0x04
    Run Keyword If    'BOO' in '${TOPOLOGY}'    wts_conf.modify    command=set_cell id=12 gnb=2    modification=nrci=0x05
    Run Keyword If    'BOO' in '${TOPOLOGY}'    wts_conf.modify    command=ue_param id=3    modification=ue_nr_capabilities=${UE_CAPA_6137_InterRAT}
    wts_conf.insert    set_gnb id=3 type=simulated plmn=311:489 ng=$ENB2_S1_ADDR daemon=$SERVER_IP:$EDAEMON_PORT gnb_id=012:28 nssai=0x01:0xD143A5
    ...                after    set_cell id=1 gnb=23
    wts_conf.insert    ${set_cell_2}
    ...                after    set_gnb id=3
    wts_conf.save_wts_cfg    file_path=${WTS_INSTALL_PATH}/basic_setup.cfg
    [Teardown]    Run keyword And Ignore Error    Run And Return Rc And Output   cp ${WTS_INSTALL_PATH}/basic_setup.cfg ${testlog_path}
