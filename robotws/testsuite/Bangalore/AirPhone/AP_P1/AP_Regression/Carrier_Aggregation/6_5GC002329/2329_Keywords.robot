*** Settings ***
Documentation   Contains keywords related to 2329 feature
Resource        ../CA_Common_Keywords.robot
Resource        ../5_5GC001390/1390_Keywords.robot

*** Variables ***
${anr_ir_gnb_delta_json}      ${WTS_CFG_PATH}/InterRAT_ANR_2329_delta.json
${ue_nr_capabilities}    SEPARATOR=
...                     E9A01000074F5A13020002054004824C5800260D41C04D8061CF9863CA160704C020311C12A836276B04610D04083E5
...                     038165B262A86873E238F40CFB027C639F30C7942C0E070F05C00000007000000003C000E0541B137582308682041F2
...                     81C0B2D931543439F11C7A067D813E31CF9863CA1607038782E0009E003800278001E000702A0F88DAC1184341020F9
...                     40E0496C98AA0A1CF88E3C639F30C7942C0E070F027F0000001FC0000000F000381507C41D608C21A08107CA07024B6
...                     4C55050E7C471E31CF9863CA16070387813F8000000FE000000078001C0E83614606B04610D04083E5038165B262A86
...                     873E238F40CFB027C639F30C7942C0E070F05C0012C0070004B0003C000E0541F06F582308682041F281C092D931541
...                     439F11C78C73E618F28581C0E1E04FE8000003FA0000001E000702A0F831AC1184341020F940E0496C98AA0A1CF88E3
...                     C639F30C7942C0E070F027F0000001FC0000000F000381507C06D608C21A08107CA07024B64C55050E7C471E31CF986
...                     3CA16070387813F8000000FE000000078001C0A83E016B04610D04083E5038125B262A82873E238F18E7CC31E50B038
...                     1C3C09FC0000007F00000003C000E0541F007582308682041F281C092D931541439F11C78C73E618F28581C0E1E04FE
...                     0000003F80000001E000702A0F801AC1184341020F940E0496C98AA0A1CF88E3C639F30C7942C0E070F027F6000001F
...                     D8000000F000381506C2FD608C21A08107CA0702CB64C550D0E7C471E819F604F8C73E618F28581C0E1E1380024000E
...                     0009000078001C0A83613EB04610D04083E5038165B262A86873E238F40CFB027C639F30C7942C0E070F09C00024007
...                     000090003C000E0541B097582308682041F281C0B2D931543439F11C7A067D813E31CF9863CA1607038784E00080003
...                     800200001E000702A0F827AC1184341020F940E0496C98AA0A1CF88E3C639F30C7942C0E070F027F0000001FC000000
...                     0F000381507C0DD608C21A08107CA07024B64C55050E7C471E31CF9863CA16070387813E0000000F8000000078001C0
...                     A83E05EB04610D04083E5038125B262A82873E238F18E7CC31E50B0381C3C09F80000007E00000003C000E0541F01F5
...                     82308682041F281C092D931541439F11C78C73E618F28581C0E1E04FE0000003F80000001E000702A0F809AC1184341
...                     020F940E0496C98AA0A1CF88E3C639F30C7942C0E070F027F0000001FC0000000F00038006107134000002C1C280000
...                     02020EA0F0A000388C000008240809004010250540AC1B83E07D1BB00A02D02101C089B1CF870A74ED8E7C380C1FF83
...                     0070318C7E826007C005038280301804800E0180A00A07C0A0040000000200000401000004008000030040000200200
...                     00140100000C0080000700400004002000024010000140532A6F2A6B032B036B282B286B266B296B236B012B0228180
...                     800004B29282000032CA4A0800014B29282000072CA480800024B292020000B2CA480800034B292020000F2CA480800
...                     028B29202000112CA48080004CB29202000152CA48080005CB292016A55574AAAA81D5528ABA11554AA2E95455268AA
...                     531548E2A80C55028A1201D00AA050381C0E07028140A07038001000400801000801002101002004040180318A0502414246030940

*** Keywords ***
Perform UE Register and Start Traffic For Single SA UEs
    [Arguments]    ${sa_ue_list}    ${ul_tput}    ${carrier_frequency}
    FOR    ${ue_id}    IN    @{sa_ue_list}
        Ensure UE Register Is Successful    ue_id=${ue_id}
        Ensure Set PDU Param Is Successful    ue_id=${ue_id}    pdu_id=3    trf_type=internal
        Ensure UE PDU Session Setup Is Successful    ue_id=${ue_id}    pdu_id=3    gw_id=${ue_id}    nwslice=1
        Trigger A1 Event measurement    ue_id=${ue_id}    pass_regexp=measurementReport
        ...    carrier_frequency=${carrier_frequency}    phycell_id=50    srsrp_nr=40
        Validate Scell Addition    scell_index=${SA_Scell_Index}[1]
        Log To Console    Going To Start Traffic for SA UE: ${ue_id}
        Start Traffic    ue_id=${ue_id}    dir=ul    pdu=3    mbps=${ul_tput}
        Log To Console    Going To Check Scell Activation For SA UE: ${ue_id}
        Start Traffic    ue_id=${ue_id}    dir=dl    pdu=3    trf_id=1    mbps=${dl_tput_list}[0]
        Start Traffic    ue_id=${ue_id}    dir=dl    pdu=3    trf_id=2    mbps=${dl_tput_list}[1]
        Start Traffic With Regex Check    ue_id=${ue_id}    dir=dl
        ...    pass_regex=SCellIndex \\d+ activated successfully    pdu=3    trf_id=3    mbps=${dl_tput_list}[2]
    END

Perform UE Register and Traffic For Multi SA UEs
    [Arguments]    ${sa_ue_list}    ${carrier_frequency}
    ${last_multi_ue}    Set Variable    ${sa_ue_list}[-1]
    FOR    ${ue_id}    IN    @{sa_ue_list}
        Ensure UE Register Is Successful    ue_id=${ue_id}
        Ensure Set PDU Param Is Successful    ue_id=${ue_id}    pdu_id=3    trf_type=internal
        Ensure UE PDU Session Setup Is Successful    ue_id=${ue_id}    pdu_id=3    gw_id=${ue_id}    nwslice=1
        Trigger A1 Event measurement    ue_id=${ue_id}    pass_regexp=measurementReport
        ...    carrier_frequency=${carrier_frequency}    phycell_id=50    srsrp_nr=40
        Validate Scell Addition    scell_index=${SA_Scell_Index}[1]
        Log To Console    Going To Start Traffic for SA UE: ${ue_id}
        Start Traffic    ue_id=${ue_id}    dir=ul    pdu=3    mbps=${ul_tput}
        Run Keyword If    ${last_multi_ue} != ${ue_id}    Start Traffic    ue_id=${ue_id}    dir=dl    pdu=3
        ...    trf_id=1    mbps=${dl_tput_list}[0]
    END
    Start Traffic With Regex Check    ue_id=${ue_id}    dir=dl
    ...    pass_regex=SCellIndex \\d+ activated successfully    pdu=3    trf_id=3    mbps=${dl_tput_list}[2]

Validate Pcell and Scell Throughput For Multi SA UEs
    [Arguments]    ${expected_ul_tput}    ${expected_dl_tput_list}    ${UE_List}    ${Scell_Id}
    FOR    ${ue_id}    ${expected_dl_tput}    IN ZIP    ${UE_List}    ${expected_dl_tput_list}
        Log To Console    Going To Check Throughput for SA UE: ${ue_id}
        ${pcell_tput}    Cell Specific Throughput Validation    ue_id=${ue_id}    scell=${Scell_Id}[0]
        ${scell_tput}    Cell Specific Throughput Validation    ue_id=${ue_id}    scell=${Scell_Id}[1]
        ${total_tput}    Evaluate    float(${pcell_tput})+float(${scell_tput})
        ${ul_tput}    Get Average Throughput from Bearer Stats For SA    ue_id=${ue_id}    dir=ul    pdu_id=3
        ${dl_tput}    Get Average Throughput from Bearer Stats For SA    ue_id=${ue_id}    dir=dl    pdu_id=3
        Total CA UE Throughput Verification   ${total_tput}    ${dl_tput}    ${expected_dl_tput}
        Run Keyword and Ignore Error    Average Throughput Should Be as Expected    ${ul_tput}
        ...    ${expected_ul_tput}
    END

Validate Pcell and Scell Throughput For Single SA UEs
    [Arguments]    ${expected_ul_tput}    ${expected_dl_tput}    ${UE_List}    ${Scell_Id}
    FOR    ${ue_id}    IN    @{UE_List}
        Log To Console    Going To Check Throughput for SA UE: ${ue_id}
        ${pcell_tput}    Cell Specific Throughput Validation    ue_id=${ue_id}    scell=${Scell_Id}[0]
        ${scell_tput}    Cell Specific Throughput Validation    ue_id=${ue_id}    scell=${Scell_Id}[1]
        ${total_tput}    Evaluate    float(${pcell_tput})+float(${scell_tput})
        ${ul_tput}    Get Average Throughput from Bearer Stats For SA    ue_id=${ue_id}    dir=ul    pdu_id=3
        ${dl_tput}    Get Average Throughput from Bearer Stats For SA    ue_id=${ue_id}    dir=dl    pdu_id=3
        Total CA UE Throughput Verification   ${total_tput}    ${dl_tput}    ${expected_dl_tput}
        Run Keyword and Ignore Error    Average Throughput Should Be as Expected    ${ul_tput}
        ...    ${expected_ul_tput}
    END

Perform Stop Traffic with UE Measurements and Detach SA UEs
    [Arguments]    ${sa_ue_list}
    ${first_multi_ue}    Set Variable    ${sa_ue_list}[0]
    FOR    ${ue_id}    IN    @{sa_ue_list}
        Log To Console    Going To Stop Traffic for SA UE: ${ue_id}
        Stop UE Traffic    ue_id=${ue_id}    pdu=3    dir=ul
        Log To Console    Going To Check Scell Dectivation For SA UE: ${ue_id}
        Run Keyword If    '${ue_id}' == '${first_multi_ue}'    Stop UE Traffic With Regex Check
        ...    ue_id=${ue_id}    pdu=3   dir=dl    pass_regex=SCellIndex \\d+ deactivated successfully
        Run keyword If    '${ue_id}' != '${first_multi_ue}'    Stop UE Traffic    ue_id=${ue_id}    pdu=3   dir=dl
        Trigger A2 Event measurement    ue_id=${ue_id}    pass_regexp=measurementReport    carrier_frequency=518910
        ...    scell=1    scell_rsrp=30    phycell_id=51
        Validate Scell Release    scell_index=${SA_Scell_Index}[1]
        Ensure UE PDU Session Release Is Successful    ue_id=${ue_id}    pdu_id=3
        Ensure UE Deregister Is Successful    ue_id=${ue_id}    ue_deregister_type=switch_off    by=ue
    END

Perform Stop Traffic and Detach SA UEs ANR
    [Arguments]    ${sa_ue_list}
    FOR    ${ue_id}    IN    @{sa_ue_list}
        Log To Console    Going To Stop Traffic for SA UE: ${ue_id}
        Stop UE Traffic    ue_id=${ue_id}    pdu=${ue_id}    dir=ul
        Log To Console    Going To Check Scell Dectivation For SA UE: ${ue_id}
        Stop UE Traffic    ue_id=${ue_id}    pdu=3    dir=dl
        Ensure UE PDU Session Release Is Successful    ue_id=${ue_id}    pdu_id=3
        Ensure UE Deregister Is Successful    ue_id=${ue_id}    pass_regexp=UE${ue_id}: detached    ue_deregister_type=switch_off    by=ue
        Run Keyword And Ignore Error    Check pcap files in gNB
    END

Validate Pcell and Scell Throughput For Single and Multiple SA UEs
    [Arguments]    ${expected_ul_tput}    ${expected_dl_tput}    ${UE_List}    ${Scell_Id}
    ${expected_total_dl_tput}    Evaluate    sum([int(str(x).encode('ascii')) for x in @{expected_dl_tput}])
    ${is_single_ue}    Evaluate    len(${UE_List}) == 1
    Run Keyword If    ${is_single_ue}    Validate Pcell and Scell Throughput For Single SA UEs    ${expected_ul_tput}
    ...    ${expected_total_dl_tput}    ${UE_List}    ${Scell_Id}
    Run Keyword If    not ${is_single_ue}    Validate Pcell and Scell Throughput For Multi SA UEs    ${expected_ul_tput}
    ...    ${expected_dl_tput}    ${UE_List}    ${Scell_Id}

Perform Register and Start Traffic For SA UEs
    [Arguments]    ${sa_ue_list}    ${uplink_tput}=${ul_tput}
    ${is_single_ue}    Evaluate    len(${sa_ue_list}) == 1
    Run Keyword If    ${is_single_ue}    Perform UE Register and Start Traffic For Single SA UEs    ${sa_ue_list}    ${uplink_tput}
    ...    carrier_frequency=518910
    Run Keyword If    not ${is_single_ue}    Perform UE Register and Traffic For Multi SA UEs    ${sa_ue_list}    carrier_frequency=518910

Trigger Intrafreq SA handover from Real gNB to Sim gNB FR2329
    [Arguments]    ${ue_id_list}
    log to console    SA forward handover from Real gNB cell2 to simulator gNBcell1 ...
    FOR    ${ue_id}    IN    @{ue_id_list}
        ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=PATH_SWITCH_REQUEST_ACK Received    carrier_frequency=518910
        ...    srsrp_nr=10    srsrq_nr=5     ssinr_nr=10    phycell_id=63    nrsrp_nr=40    nrsrq_nr=40    nsinr_nr=50
        Log To Console    Validating SA forward handover...
        Validate success prints from command output    ${output}
        ...    pass_regex=*UE${ue_id}: Inter-eNB handover from EXT_ENB-2.1 to ENB-22.2 performed*
        Validate success prints from command output    ${output}    pass_regex=*PATH_SWITCH_REQUEST_ACK Received*
    END
    sleep    60s    reason=To stabilise traffic txput

Trigger Intrafreq SA handover from Sim gNB to Real gNB FR2329
    log to console    SA reverse handover from simulator gNB cell1 to real gNB cell2
    [Arguments]    ${ue_id}     ${scell_index}
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=PATH SWITCH REQUEST ACK    carrier_frequency=518910
    ...    srsrp_nr=11    srsrq_nr=11    phycell_id=50    nrsrp_nr=30    nrsrq_nr=30
    Log To Console    Validating SA reverse handover...
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: CTRL_RACH_COMPLETE Received*
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: Inter-eNB handover from ENB-22.2 to EXT_ENB-2.1 performed*
    Validate success prints from command output    ${output}    pass_regex=*PATH SWITCH REQUEST ACK*
    ${output}    Trigger A1 Event measurement    ue_id=${ue_id}    pass_regexp=SCellIndex \\d+ activated successfully
        ...    carrier_frequency=518910    phycell_id=50    srsrp_nr=40
    Validate success prints from command output    ${output}    pass_regex=*SCellIndex ${scell_index} activated successfully*
    sleep    60s   reason=To stabilise traffic txput

Trigger Interfreq SA handover from Real gNB to Sim gNB FR2329
    [Arguments]    ${ue_id}
    log to console    SA forward handover from Real gNB cell2 to simulator gNBcell1 ...
    Trigger A2 Event measurement    ue_id=${ue_id}    pass_regexp=measurementReport    carrier_frequency=518910    srsrp_nr=7    srsrq_nr=7
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=PATH_SWITCH_REQUEST_ACK Received    carrier_frequency=517180
    ...    srsrp_nr=10    srsrq_nr=5    ssinr_nr=10    phycell_id=64    nrsrp_nr=40    nrsrq_nr=40    nsinr_nr=50
    Log To Console    Validating SA forward handover...
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: Inter-eNB handover from EXT_ENB-2.1 to ENB-23.2 performed*
    Validate success prints from command output    ${output}    pass_regex=*PATH_SWITCH_REQUEST_ACK Received*
    sleep    60s   reason=To stabilise traffic txput

Trigger Interfreq SA handover from Sim gNB to Real gNB FR2329
    [Arguments]    ${ue_id}    ${scell_index}
    log to console    SA reverse handover from simulator gNBcell1 to Real gNB cell2...
    Trigger A2 Event measurement    ue_id=${ue_id}    pass_regexp=measurementReport    carrier_frequency=517230    srsrp_nr=7    srsrq_nr=7
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=PATH SWITCH REQUEST ACK
    ...    carrier_frequency=518910    srsrp_nr=11    srsrq_nr=11    phycell_id=50    nrsrp_nr=30    nrsrq_nr=30
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: CTRL_RACH_COMPLETE Received*
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: Inter-eNB handover from ENB-23.2 to EXT_ENB-2.1 performed*
    Validate success prints from command output    ${output}    pass_regex=*Received PATH SWITCH REQUEST from GNB-2*
    ${output}    Trigger A1 Event measurement    ue_id=${ue_id}    pass_regexp=SCellIndex \\d+ activated successfully
        ...    carrier_frequency=518910    phycell_id=50    srsrp_nr=40
    Validate success prints from command output    ${output}    pass_regex=*SCellIndex ${scell_index} activated successfully*
    sleep    60s   reason=To stabilise traffic txput

Update Gnb with NGBasedHO configuration for 5GC002329
    ${original_scf_path}    Download SCF file    local_dir_path=${testlog_path}    file_name=SCF_original.xml
    set test variable    ${original_scf_path}
    2329_Keywords.Get original params from gnB
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    delta_store.update managed object and parameter to delta    dist_name=${NRBTS_DISTNAME}    &{NgHo_Inter_Intra_params}
    delta_store.update managed object and parameter to delta    dist_name=${NRCELL_DISTNAME}/NRREL-15    &{nrrel_params}
    delta_store.update managed object and parameter to delta    dist_name=${NRCELL_DISTNAME}/NRREL-16    &{nrrel_params}
    ${delta_store}    Collect Delta Store
    Recommission GNB With Delta    delta_file=${delta_store}    should_activate=${True}
    Set Test Variable    ${Gnb_Revert}    True
    Wait for gNB To Be Ready

Update WTS config file for 5GC002329
    Run keyword And Ignore Error    Run And Return Rc And Output   cp ${WTS_INSTALL_PATH}/basic_setup.cfg ${WTS_INSTALL_PATH}/basic_setup_backup.cfg
    wts_conf.load_wts_cfg    file_path=${WTS_INSTALL_PATH}/basic_setup.cfg
    wts_conf.modify    command=set_gnb id=2 type=external    modification=gnb_id=0x01
    wts_conf.modify    command=gnb_param id=22   modification=xn_listening_socket=1 send_xn_setup=false measEvent=A2 measEvent=A3 sa_ho=ng_based
    wts_conf.modify    command=gnb_param id=23   modification=xn_listening_socket=1 send_xn_setup=false measEvent=A2 measEvent=A3 sa_ho=ng_based
    wts_conf.save_wts_cfg    file_path=${WTS_INSTALL_PATH}/basic_setup.cfg
    [Teardown]    Run keyword And Ignore Error    Run And Return Rc And Output   cp ${WTS_INSTALL_PATH}/basic_setup.cfg ${testlog_path}

Trigger Intrafreq NG Based SA handover from Real gNB2 cell1 to sim gNB22 cell2
    [Arguments]    ${ue_id}
    log to console    NG based forward handover from Real gNB2 cell1(primary cell) to sim gNB22 cell2(secondary cell) ...
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=Downlink packets from external network dropped by UPF
    ...    carrier_frequency=518910    srsrp_nr=10    srsrq_nr=5    ssinr_nr=10    phycell_id=63    nrsrp_nr=40    nrsrq_nr=40    nsinr_nr=50
    Log To Console    Validating SA forward handover...
    Validate success prints from command output    ${output}
    ...    pass_regex=*UE${ue_id}: Inter-eNB handover from EXT_ENB-2.1 to ENB-22.2 performed*
    Validate NG based handover prints from command output    ${output}
    sleep    5s    reason=To stabilise

Trigger Intrafreq NG Based SA handover from sim gNB22 Cell2 to Real gNB2 Cell1
    [Arguments]    ${ue_id}
    log to console    NG based reverse handover from sim gNB22 Cell2(secondary cell) to Real gNB2 Cell1(primary cell) ...
    Update UE History Information    id=1    cell_type=large    nrcgi=311:489|0x08
    ...    gnb_id=22    time_ue_stayed_in_cell=97    action=commit    ue_enb_param_id=${ue_id}
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=Inter-eNB handover from ENB-22.2 to EXT_ENB-2.1
    ...   carrier_frequency=518910    srsrp_nr=11    srsrq_nr=11    phycell_id=50    nrsrp_nr=30    nrsrq_nr=30
    Log To Console    Validating SA reverse handover...
    Validate success prints from command output    ${output}
    ...    pass_regex=*GNB-22: NgAPHANDOVER_REQUEST isbwpIdUlFullPwrTxPresent is 0*
    Validate success prints from command output    ${output}    pass_regex=*GNB-22: Sending DRX Config setup*
    Validate success prints from command output    ${output}    pass_regex=*AMF-1: HANDOVER REQUIRED: gNB=22, AMF_UE_NGAP_ID*
    Validate success prints from command output    ${output}    pass_regex=*AMF-1: HANDOVER REQUIRED: gNB=22, RAN_UE_NGAP_ID*
    Validate success prints from command output    ${output}
    ...    pass_regex=*UE${ue_id}: Inter-eNB handover from ENB-22.2 to EXT_ENB-2.1 performed*
    sleep    5s   reason=To stabilise

Verify scell activated for all UEs
    [Arguments]     ${CA_SA_UE_List}
    Execute Egate Command    cmd=sim_log_set flush    timeout=2s
    FOR    ${ue_id}    IN    @{CA_SA_UE_List}
        ${sa_scell_ue_id}    Evaluate    ${ue_id}-1
        Egate console log verification
        ...    UeId:${sa_scell_ue_id},SubcellId:32.* SCellIndex 1 activated successfully
    END

Trigger Scell Addition to activate Scell
    [Arguments]    ${sa_ue_list}
    FOR    ${ue_id}    IN    @{sa_ue_list}
        Trigger A1 Event measurement    ue_id=${ue_id}    pass_regexp=measurementReport    carrier_frequency=518910    srsrp_nr=40    phycell_id=50
    END
    Log To Console    Validating scell activation...
    wait until keyword succeeds    2min    30s    Verify scell activated for all UEs    ${sa_ue_list}

Trigger Interfreq NG Based SA handover from Real gNB2 cell1 to sim gNB23 cell2
    [Arguments]    ${ue_id}
    log to console    Interfreq NG based forward handover from Real gNB2 cell1 to sim gNB23 cell2...
    Trigger A2 Event measurement     ue_id=${ue_id}    pass_regexp=measurementReport
    ...   carrier_frequency=518910    srsrp_nr=7    srsrq_nr=7
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=Downlink packets from external network dropped by UPF
    ...    carrier_frequency=517180    srsrp_nr=10    srsrq_nr=5    ssinr_nr=10    phycell_id=64    nrsrp_nr=40    nrsrq_nr=40    nsinr_nr=50
    Log To Console    Validating SA forward handover...
    Validate success prints from command output    ${output}
    ...    pass_regex=*UE${ue_id}: Inter-eNB handover from EXT_ENB-2.1 to ENB-23.2 performed*
    Validate NG based handover prints from command output    ${output}
    sleep    5s   reason=To stabilise

Trigger Interfreq NG Based SA handover from sim gNB23 Cell2 to Real gNB2 Cell1
    [Arguments]    ${ue_id}
    log to console    Interfrequency NG based reverse handover from sim gNB23 Cell2 to Real gNB2 Cell1...
    Update UE History Information     id=1    cell_type=large    nrcgi=311:489|0x09
    ...    gnb_id=23    time_ue_stayed_in_cell=98    action=commit    ue_enb_param_id=${ue_id}
    Trigger A2 Event measurement     ue_id=${ue_id}    pass_regexp=measurementReport
    ...   carrier_frequency=517230    srsrp_nr=7    srsrq_nr=7
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=Inter-eNB handover from ENB-23.2 to EXT_ENB-2.1 performed
    ...   carrier_frequency=518910    srsrp_nr=11    srsrq_nr=11    phycell_id=50    nrsrp_nr=30    nrsrq_nr=30
    Log To Console    Validating SA reverse handover...
    Validate success prints from command output    ${output}    pass_regex=*NgAPHANDOVER_REQUEST isbwpIdUlFullPwrTxPresent is 0*
    Validate success prints from command output    ${output}
    ...    pass_regex=*UE${ue_id}: Inter-eNB handover from ENB-23.2 to EXT_ENB-2.1 performed*
    Validate success prints from command output    ${output}    pass_regex=*HANDOVER REQUIRED: gNB=23, AMF_UE_NGAP_ID*
    Validate success prints from command output    ${output}    pass_regex=*HANDOVER REQUIRED: gNB=23, RAN_UE_NGAP_ID*
    sleep    5s   reason=To stabilise

Get original params from gnB
    ${ng_ho_param}       scf_helper.get_feature_paramters_from_scf    ${original_scf_path}     ${NgHo_feature_param}     ${NRBTS_DISTNAME}
    ${nrrel_15_param}    scf_helper.get_feature_paramters_from_scf    ${original_scf_path}     ${nrrel_params}     ${NRCELL_DISTNAME}/NRREL-15
    ${nrrel_16_param}    scf_helper.get_feature_paramters_from_scf    ${original_scf_path}     ${nrrel_params}     ${NRCELL_DISTNAME}/NRREL-16
    set test variable    ${ng_ho_param}
    set test variable    ${nrrel_15_param}
    set test variable    ${nrrel_16_param}

Get Revert Delta Param for 5GC002329
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    delta_store.update managed object and parameter to delta    dist_name=${NRBTS_DISTNAME}              &{ng_ho_param}
    delta_store.update managed object and parameter to delta    dist_name=${NRCELL_DISTNAME}/NRREL-15    &{nrrel_15_param}
    delta_store.update managed object and parameter to delta    dist_name=${NRCELL_DISTNAME}/NRREL-16    &{nrrel_16_param}
    ${delta_store}    Collect Delta Store
    [Return]    ${delta_store}

Update WTS config file for InterRAT handover 5GC002329
    Run keyword And Ignore Error    run and return rc and output
    ...    cp ${WTS_INSTALL_PATH}/basic_setup.cfg ${WTS_INSTALL_PATH}/basic_setup_backup.cfg
    wts_conf.load_wts_cfg    file_path=${WTS_INSTALL_PATH}/basic_setup.cfg
    wts_conf.insert    command=set DAEMON_IP8="10.0.2.9"   location=after    reference=set DAEMON_IP7="10.0.2.8"
    wts_conf.insert    command=set ENB2_S1_ADDR="10.0.1.139"   location=after    reference=set ENB1_S1_ADDR="10.0.1.136"
    wts_conf.insert    command=set ENB3_S1_ADDR="10.0.1.142"   location=after    reference=set ENB2_S1_ADDR="10.0.1.139"
    ${set_cell_1}     catenate
    ...     set_cell id=1 gnb=3 pci=3:2 earfcn=1400:19400 tac=200
    ...     proxy=$DAEMON_IP:9999|$DAEMON_IP:8888 nrci=0x6 tdd_cell=on bw=20MHz technology=lte
    ${set_cell_2}     catenate
    ...     set_cell id=2 gnb=4 pci=4:2 earfcn=1600:19600 tac=200
    ...     proxy=$DAEMON_IP8:9999|$DAEMON_IP8:8888 nrci=0x5 tdd_cell=off bw=10MHz technology=lte
    wts_conf.insert
    ...    command=set_gnb id=3 type=simulated plmn=311:489 ng=$ENB2_S1_ADDR daemon=$SERVER_IP:$EDAEMON_PORT gnb_id=0x12:28 nssai=0x01:0xD143A5
    ...    location=after    reference=set_cell id=1 gnb=25
    wts_conf.insert    command=${set_cell_1}    location=after    reference=set_gnb id=3 type=simulated
    wts_conf.insert
    ...    command=set_gnb id=4 type=simulated plmn=311:489 ng=$ENB3_S1_ADDR daemon=$SERVER_IP:$EDAEMON_PORT gnb_id=0x13:28 nssai=0x01:0xD143A5
    ...    location=after    reference=set_cell id=1 gnb=3
    wts_conf.insert    command=${set_cell_2}    location=after    reference=set_gnb id=4 type=simulated
    wts_conf.save_wts_cfg    file_path=${WTS_INSTALL_PATH}/basic_setup.cfg
    [Teardown]    Run keyword And Ignore Error    Run And Return Rc And Output   cp ${WTS_INSTALL_PATH}/basic_setup.cfg ${testlog_path}

Update Gnb with InterRAT configuration for 5GC002329
    ${original_scf_path}    Download SCF file    local_dir_path=${testlog_path}    file_name=SCF_original.xml
    set test variable    ${original_scf_path}
    2329_Keywords.Get original params from gnB for interrat handover
    Recommission GNB With Delta    delta_file=${interrat_gnb_delta_json}    should_activate=${True}
    Set Test Variable    ${Gnb_Revert}    True
    Wait for gNB To Be Ready

Get original params from gnB for interrat handover
    ${interrat_feature_param}    scf_helper.get_feature_paramters_from_scf    ${original_scf_path}     ${InterRAT_params}     ${NRBTS_DISTNAME}
    set test variable    ${interrat_feature_param}

Get Revert Delta Param for interrat handover 5GC002329
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    delta_store.update managed object and parameter to delta    dist_name=${NRBTS_DISTNAME}    &{interrat_feature_param}
    delta_store.delete_param_from_delta             dist_name=${NRBTS_DISTNAME}/NRCELL-1    param_name=nrhoirDNList
    delta_store.delete_param_from_delta             dist_name=${NRBTS_DISTNAME}/NRCELL-2    param_name=nrhoirDNList
    delta_store.delete_managed_object_from_delta    dist_name=${NRBTS_DISTNAME}/NRADJECELL-1
    delta_store.delete_managed_object_from_delta    dist_name=${NRBTS_DISTNAME}/NRADJECELL-2
    delta_store.delete_managed_object_from_delta    dist_name=${NRBTS_DISTNAME}/NRCELL-1/NRRELE-1
    delta_store.delete_managed_object_from_delta    dist_name=${NRBTS_DISTNAME}/NRCELL-2/NRRELE-2
    delta_store.delete_managed_object_from_delta    dist_name=${NRBTS_DISTNAME}/NRHOIR-1
    delta_store.delete_managed_object_from_delta    dist_name=${NRBTS_DISTNAME}/NRHOIR-2
    delta_store.delete_managed_object_from_delta    dist_name=${NRBTS_DISTNAME}/XNLINK-5
    delta_store.delete_managed_object_from_delta    dist_name=${NRBTS_DISTNAME}/XNLINK-6
    ${delta_store}    Collect Delta Store
    [Return]    ${delta_store}

Trigger InterRAT SA handover from Real gNB to Sim eNB
    [Arguments]    ${ue_id}
    log to console    InterRAT SA forward handover from 5GC(RealgNB-2.1) to LTE(SimENB-3.1)...
    Trigger A2 Event measurement    ue_id=${ue_id}    pass_regexp=measurementReport    carrier_frequency=518910
    ...    srsrp_nr=11    srsrq_nr=11    srs_result=0:11:11:0    phycell_id=50    nrsrp_nr=30
    ...    nrsrq_nr=30     rs_type=ssb    index=0    nrs_result=30:30:0
    ${output}    Trigger B2 Event measurement    ue_id=${ue_id}    pass_regexp=IRAT Handover from NR to EUTRA completed
    ...    carrier_frequency=1400    eutra=True    srsrp_nr=11    srsrq_nr=11    srs_result=0:11:11:0     phycell_id=11
    ...    nrsrp_nr=30    nrsrq_nr=30    rs_type=ssb    index=0     nrs_result=30:30:0
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: Successful handover from EXT_ENB-2.1 to ENB-3.1*
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: IRAT Handover from NR to EUTRA completed*
    sleep    10s   reason=To stabilise traffic txput

Trigger InterRAT SA handover from Sim eNB to Real gNB
    [Arguments]    ${ue_id}    ${scell_index}=${scell_index_sa}
    log to console    InterRAT SA reverse handover from LTE(SimENB-4.2) to 5GC(RealgNB-2.2)...
    ${output}    Trigger eNB initiated inter-rat handover to 5g    ue_id=${ue_id}    target_gnb=2    target_cell=1
    ...    plmn=${plmn}    pass_regexp=Inter-eNB handover from
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: Received IratFromEutraToNrHo with valid NAS Container*
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: Inter-eNB handover from ENB-3.1 to EXT_ENB-2.1 performed*
    ${output}    Trigger A1 Event measurement    ue_id=${ue_id}    pass_regexp=SCellIndex \\d+ activated successfully
    ...        carrier_frequency=518910    phycell_id=50    srsrp_nr=40
    Validate success prints from command output    ${output}    pass_regex=*SCellIndex ${scell_index} activated successfully*
    sleep    10s   reason=To stabilise traffic txput

Update WTS config file for ANR InterRAT handover 5GC002329
    Run keyword And Ignore Error    run and return rc and output
    ...    cp ${WTS_INSTALL_PATH}/basic_setup.cfg ${WTS_INSTALL_PATH}/basic_setup_backup.cfg
    wts_conf.load_wts_cfg    file_path=${WTS_INSTALL_PATH}/basic_setup.cfg
    wts_conf.insert    command=set ENB2_S1_ADDR="10.0.1.138"   location=after    reference=set SGW_S11_ADDR="10.0.1.134"
    wts_conf.modify    command=ue_param id=20    modification=ue_nr_capabilities=${ue_nr_capabilities} ue_eutra_capabilities=1E000030010312000000
    ${set_cell_1}     catenate
    ...     set_cell id=1 gnb=3 pci=10:0 eci=0x7432101 earfcn=2200:20200 mapped_earfcn=4400:22400
    ...     tac=200 proxy=$SERVER_IP:12218 nrci=0x01 tdd_cell=off bw=20MHz technology=lte mandatory_for_activation=off
    wts_conf.insert
    ...    command=set_gnb id=3 type=simulated plmn=311:489 ng=$ENB2_S1_ADDR daemon=$SERVER_IP:$DAEMON_PORT gnb_id=0x74321:28 nssai=0x01:0xD143A5
    ...    location=after    reference=set_pgw id=1
    wts_conf.insert
    ...    command=${set_cell_1}    location=after    reference=set_gnb id=3 type=simulated
    wts_conf.insert
    ...    command=gnb_cell_param id=1 gnb=3 enable_drx_profile_for_anr=on
    ...    location=after    reference=set_cell id=1 gnb=3
    wts_conf.insert
    ...    command=gnb_param id=3 xn_listening_socket=off sib1_period=20000
    ...    location=after    reference=gnb_cell_param
    wts_conf.save_wts_cfg    file_path=${WTS_INSTALL_PATH}/basic_setup.cfg
    [Teardown]    Run keyword And Ignore Error    Run And Return Rc And Output   cp ${WTS_INSTALL_PATH}/basic_setup.cfg ${testlog_path}

Update Gnb with ANR InterRAT configuration for 5GC002329
    [Arguments]    ${feature_id}=5GC002329
    ${original_scf_path}    Download SCF file    local_dir_path=${testlog_path}    file_name=SCF_original.xml
    set test variable    ${original_scf_path}
    Get original params from gnB for ANR interrat handover
    run keyword and ignore error    Delete anr profile if present    ${feature_id}
    Recommission GNB With Delta    delta_file=${anr_ir_gnb_delta_json}    should_activate=${True}
    Set Test Variable    ${Gnb_Revert}    True
    Wait for gNB To Be Ready

Get Revert Delta Param for ANR interrat handover 5GC002329
    [Arguments]    ${feature_id}=5GC002329
    ${anr_status}    ${anr_error}    Run keyword And Ignore Error    Delete anr profile if present    ${feature_id}
    Run Keyword If    "${anr_status}"=="PASS"    Log    ANR profile was already present and its deleted   level=WARN
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    delta_store.update managed object and parameter to delta    dist_name=${NRBTS_DISTNAME}    &{anrIR_feature_param_original}
    delta_store.delete_param_from_delta             dist_name=${NRBTS_DISTNAME}/NRCELL-1    param_name=nrhoirDNList
    delta_store.delete_managed_object_from_delta    dist_name=${NRBTS_DISTNAME}/NRHOIR-1
    delta_store.delete_managed_object_from_delta    dist_name=${NRBTS_DISTNAME}/NRANRPRE-1
    delta_store.delete_managed_object_from_delta    dist_name=${NRBTS_DISTNAME}/NRANR-1
    ${delta_store}    Collect Delta Store
    [Return]    ${delta_store}

Trigger ANR InterRAT SA handover from Real gNB to Sim eNB
    [Arguments]    ${ue_id}
    log to console    InterRAT SA forward handover from 5GC(RealgNB-2.1) to LTE(SimENB-3.1)...
    Trigger A2 Event measurement    ue_id=${ue_id}    pass_regexp=measurementReport    carrier_frequency=518910    srsrp_nr=11
    ...   srsrq_nr=11   srs_result=0:11:11:0    phycell_id=50    nrsrp_nr=30    nrsrq_nr=30    rs_type=ssb    index=0    nrs_result=30:30:0
    sleep    2s
    ${output}    Trigger B2 Event measurement    ue_id=${ue_id}    pass_regexp=IRAT Handover from NR to EUTRA completed
    ...    carrier_frequency=2200    eutra=True   srsrp_nr=11    srsrq_nr=11    srs_result=0:11:11:0
    ...    phycell_id=30    nrsrp_nr=58    nrsrq_nr=30    rs_type=ssb    index=0    nrs_result=30:30:0
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: Successful handover from EXT_ENB-2.1 to ENB-3.1*
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: IRAT Handover from NR to EUTRA completed*
    sleep    10s   reason=To stabilise traffic txput
