*** Settings ***
Documentation    Contains keywords related to 1729 feature
Resource        ../CA_Common_Keywords.robot

*** Variables ***
${WTS_CFG_PATH}        ${CURDIR}/cfg
@{Counter_List}        M55118C05506    M55316C09000    M55310C01006    M55316C09002    M55118C06501
@{nrrel_profile_id}    4    5    6    7
${interrat_gnb_delta_json}         ${WTS_CFG_PATH}/InterRAT_1729_delta.json
${anr_ir_gnb_delta_json}      ${WTS_CFG_PATH}/InterRAT_ANR_1729_delta.json

*** Keywords ***
Activate testmode
    [Arguments]    ${ue_list}    ${scell_id}
    Update CSI parameters    profile_id=5
    FOR    ${ue_id}    IN    @{ue_list}
        Enable UE to testmode    id=${ue_id}    profile_id=5    scell_index=${scell_id}[1]
        ...    pass_regex=SCellIndex \\d+ deactivated successfully
    END

Perform UE Register and Start Traffic For SA Non CA Capable UEs
    [Arguments]    ${sa_ue_list}    ${csi_override}=False    ${uplink_tput}=${ul_tput}
    FOR    ${ue_id}    IN    @{sa_ue_list}
        Ensure UE Register Is Successful    ue_id=${ue_id}
        Ensure Set PDU Param Is Successful    ue_id=${ue_id}    pdu_id=3    trf_type=internal
        Ensure UE PDU Session Setup Is Successful    ue_id=${ue_id}    pdu_id=3    gw_id=${ue_id}    nwslice=1
        Run Keyword If    "${csi_override}" == "True"
        ...    Associate UE to testmode    id=${ue_id}    testmode=csi_override     profile_id=2    action=activate    scell=0
        Log To Console    Going To Start Traffic for SA Non CA Capable UE: ${ue_id}
        Start Traffic    ue_id=${ue_id}    dir=ul    pdu=3    protocol=udp    mbps=${uplink_tput}
        Start Traffic    ue_id=${ue_id}    dir=dl    pdu=3    protocol=udp    mbps=${uplink_tput}
    END

Perform UE Register For SA Non CA Capable UEs
    [Arguments]    ${sa_ue_list}
    FOR    ${ue_id}    IN    @{sa_ue_list}
        Ensure UE Register Is Successful    ue_id=${ue_id}
        Ensure Set PDU Param Is Successful    ue_id=${ue_id}    pdu_id=3    trf_type=internal
        Ensure UE PDU Session Setup Is Successful    ue_id=${ue_id}    pdu_id=3    gw_id=${ue_id}    nwslice=1
        Associate UE to testmode    id=${ue_id}    testmode=csi_override     profile_id=2
        ...    action=activate    scell=0
    END

Perform UE Register and Start Traffic For Single SA UE
    [Arguments]    ${sa_ue_list}    ${carrier_frequency}    ${handover}=False    ${uplink_tput}=${ul_tput}
    FOR    ${ue_id}    IN    @{sa_ue_list}
        Ensure UE Register Is Successful    ue_id=${ue_id}
        Ensure Set PDU Param Is Successful    ue_id=${ue_id}    pdu_id=3    trf_type=internal
        Ensure UE PDU Session Setup Is Successful    ue_id=${ue_id}    pdu_id=3    gw_id=${ue_id}    nwslice=1
        Trigger A1 Event measurement    ue_id=${ue_id}    pass_regexp=measurementReport
        ...    carrier_frequency=${carrier_frequency}    phycell_id=50    srsrp_nr=40
        Validate Scell Addition    scell_index=${SA_Scell_Index}[1]
        Run Keyword If    "${handover}" == "False"    Associate UE to testmode    id=${ue_id}
        ...    testmode=csi_override     profile_id=2    action=activate    scell=0,1
        Log To Console    Going To Start Traffic for SA UE: ${ue_id}
        Start Traffic    ue_id=${ue_id}    dir=ul    pdu=3    mbps=${uplink_tput}
        Log To Console    Going To Check Scell Activation For SA UE: ${ue_id}
        Run Keyword If    "${handover}" == "False"
        ...    Start Traffic and Validate Scell Activation for SA    ${ue_id}    dl_tput_list=${dl_tput_list}
        ...    ELSE    Start Traffic and Validate Scell Activation for SA    ${ue_id}    dl_tput_list=@{dl_tput_HO_list}
    END

Start Traffic Keyword Selection for Cell Activation for SA
    [Arguments]    ${ue_id}    ${regex}    ${timeout}    ${trf_id}    ${dl_tput}
    ${status}    Run Keyword If    "${regex}" == "True"    Run Keyword And Return Status   Start Traffic With Regex Check
    ...    ue_id=${ue_id}    dir=dl    pass_regex=SCellIndex \\d+ activated successfully    timeout=${timeout}    pdu=3
    ...    trf_id=${trf_id}    mbps=${dl_tput}    ELSE    Run Keyword And Return Status   Start Traffic    ue_id=${ue_id}
    ...    dir=dl    pdu=3    trf_id=${trf_id}    mbps=${dl_tput}
    [return]    ${status}

Start Traffic Keyword Selection for Cell Activation for NSA
    [Arguments]    ${ue_id}    ${regex}    ${timeout}    ${trf_id}    ${bearer_id}    ${dl_tput}
    ${status}    Run Keyword If    "${regex}" == "True"    Run Keyword And Return Status   Start Traffic With Regex Check
    ...    ue_id=${ue_id}    dir=dl    pass_regex=SCellIndex \\d+ activated successfully    timeout=${timeout}
    ...    id=${bearer_id}    trf_id=${trf_id}    mbps=${dl_tput}    ELSE    Run Keyword And Return Status
    ...    Start Traffic    ue_id=${ue_id}    dir=dl    id=${bearer_id}    trf_id=${trf_id}    mbps=${dl_tput}
    [return]    ${status}

Start Traffic and Validate Scell Activation for SA
    [Arguments]    ${ue_id}    ${dl_tput_list}=${dl_tput_list}
    ${regex}    Set Variable    True
    Set Test Variable    ${CA_Activaiton_Flag}    False
    ${len_dl_tput_list}    Evaluate    len(${dl_tput_list})
    FOR    ${index}    ${dl_tput}    IN ENUMERATE    @{dl_tput_list}
        ${last_index_status}    Evaluate    ${len_dl_tput_list} == ${index} + 1
        ${timeout}    Set Variable If    ${last_index_status} and "${regex}" == "True"    900s     10s
        ${trf_id}=    Evaluate    ${index} + 1
        ${status}    Start Traffic Keyword Selection for Cell Activation for SA     ${ue_id}    ${regex}
        ...    ${timeout}    ${trf_id}    ${dl_tput}
        ${regex}    Set Variable If    "${status}" == "True"    False     True
        Run Keyword If    ${status} and "${regex}" == "False"    Set Test variable    ${CA_Activaiton_Flag}    True
    END
    Run Keyword If    "${CA_Activaiton_Flag}" == "False"    FAIL    msg=SCell Activation Message hasnot appeared.

Start Traffic and Validate Scell Activation for NSA
    [Arguments]    ${ue_id}    ${bearer_id}    ${dl_txput_list}=${dl_tput_list}
    ${regex}   Set Variable    True
    Set Test Variable    ${CA_Activaiton_Flag}    False
    ${len_dl_tput_list}    Evaluate    len(${dl_txput_list})
    FOR    ${index}    ${dl_tput}    IN ENUMERATE    @{dl_txput_list}
	${last_index_status}    Evaluate    ${len_dl_tput_list} == ${index} + 1
        ${timeout}    Set Variable If    ${last_index_status} and "${regex}" == "True"    900s     10s
        ${trf_id}=    Evaluate    ${index} + 1
        ${status}    Start Traffic Keyword Selection for Cell Activation for NSA     ${ue_id}    ${regex}
        ...    ${timeout}    ${trf_id}    ${bearer_id}    ${dl_tput}
        ${regex}    Set Variable If    "${status}" == "True"    False     True
		Run Keyword If    ${status} and "${regex}" == "False"    Set Test variable    ${CA_Activaiton_Flag}    True
    END
    Run Keyword If    "${CA_Activaiton_Flag}" == "False"    FAIL    msg=SCell Activation Message hasnot appeared.

Perform UE Register For Multi SA UEs
    [Arguments]    ${sa_ue_list}    ${carrier_frequency}=522270
    FOR    ${ue_id}    IN    @{sa_ue_list}
        Ensure UE Register Is Successful    ue_id=${ue_id}
        Ensure Set PDU Param Is Successful    ue_id=${ue_id}    pdu_id=3    trf_type=internal
        Ensure UE PDU Session Setup Is Successful    ue_id=${ue_id}    pdu_id=3    gw_id=${ue_id}    nwslice=1
        Trigger A1 Event measurement    ue_id=${ue_id}    pass_regexp=measurementReport
        ...    carrier_frequency=${carrier_frequency}    phycell_id=50    srsrp_nr=40
        Validate Scell Addition    scell_index=${SA_Scell_Index}[1]
        Associate UE to testmode    id=${ue_id}    testmode=csi_override     profile_id=2
        ...    action=activate    scell=0,1
    END

Validate Pcell and Scell Throughput For Multi SA UEs
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

Validate Pcell and Scell Throughput For Multi NSA UEs
    [Arguments]    ${expected_ul_tput}    ${expected_dl_tput}    ${UE_List}    ${Scell_Id}
    FOR    ${ue_id}    IN    @{UE_List}
        Log To Console    Going To Check Throughput for NSA UE: ${ue_id}
        ${pcell_tput}    Cell Specific Throughput Validation    ue_id=${ue_id}    scell=${Scell_Id}[0]
        ${scell_tput}    Cell Specific Throughput Validation    ue_id=${ue_id}    scell=${Scell_Id}[1]
        ${total_tput}    Evaluate    float(${pcell_tput})+float(${scell_tput})
        ${ul_tput}    Get Average Throughput from Bearer Stats For NSA    ue_id=${ue_id}    dir=ul
        ${dl_tput}    Get Average Throughput from Bearer Stats For NSA    ue_id=${ue_id}    dir=dl
        Total CA UE Throughput Verification   ${total_tput}    ${dl_tput}    ${expected_dl_tput}
        Run Keyword and Ignore Error    Average Throughput Should Be as Expected    ${ul_tput}
        ...    ${expected_ul_tput}
    END

Validate Pcell Throughput For Non CA Capable UEs
    [Arguments]    ${expected_ul_tput}    ${expected_dl_tput}    ${UE_List}
    FOR    ${ue_id}    IN    @{UE_List}
        Log To Console    Going To Check Throughput for Non CA Capable SA UE: ${ue_id}
        ${pcell_tput}    Cell Specific Throughput Validation    ue_id=${ue_id}    scell=0
        ${ul_tput}    Get Average Throughput from Bearer Stats For SA    ue_id=${ue_id}    dir=ul    pdu_id=3
        ${dl_tput}    Get Average Throughput from Bearer Stats For SA    ue_id=${ue_id}    dir=dl    pdu_id=3
        Total CA UE Throughput Verification   ${pcell_tput}    ${dl_tput}    ${expected_dl_tput}
        Run Keyword and Ignore Error    Average Throughput Should Be as Expected    ${ul_tput}
        ...    ${expected_ul_tput}
    END

Validate Pcell and Scell Throughput For Single SA UEs
    [Arguments]    ${expected_ul_tput}    ${expected_dl_tput}    ${UE_List}    ${Scell_Id}
    FOR    ${ue_id}    IN    @{UE_List}
        Log To Console    Going To Check Throughput for SA UE: ${ue_id}
        ${total_tput}    Get Throughput from all cells    ${ue_id}     ${Scell_Id}
        ${ul_tput}    Get Average Throughput from Bearer Stats For SA    ue_id=${ue_id}    dir=ul    pdu_id=3
        ${dl_tput}    Get Average Throughput from Bearer Stats For SA    ue_id=${ue_id}    dir=dl    pdu_id=3
        Total CA UE Throughput Verification   ${total_tput}    ${dl_tput}    ${expected_dl_tput}
        Run Keyword and Ignore Error    Average Throughput Should Be as Expected    ${ul_tput}
        ...    ${expected_ul_tput}
    END

Validate Pcell and Scell Throughput For Single NSA UEs
    [Arguments]    ${expected_ul_tput}    ${expected_dl_tput}    ${UE_List}    ${Scell_Id}
    FOR    ${ue_id}    IN    @{UE_List}
        Log To Console    Going To Check Throughput for NSA UE: ${ue_id}
        ${pcell_tput}    Cell Specific Throughput Validation    ue_id=${ue_id}    scell=${Scell_Id}[0]
        ${scell_tput}    Cell Specific Throughput Validation    ue_id=${ue_id}    scell=${Scell_Id}[1]
        ${total_tput}    Evaluate    float(${pcell_tput})+float(${scell_tput})
        ${ul_tput}    Get Average Throughput from Bearer Stats For NSA    ue_id=${ue_id}    dir=ul
        ${dl_tput}    Get Average Throughput from Bearer Stats For NSA    ue_id=${ue_id}    dir=dl
        Total CA UE Throughput Verification   ${total_tput}    ${dl_tput}    ${expected_dl_tput}
        Run Keyword and Ignore Error    Average Throughput Should Be as Expected    ${ul_tput}
        ...    ${expected_ul_tput}
    END

Perform Stop Traffic and Detach SA Non CA Capable UEs
    [Arguments]    ${sa_ue_list}
    FOR    ${ue_id}    IN    @{sa_ue_list}
        Log To Console    Going To Stop Traffic for SA Non CA Capable UE: ${ue_id}
        Stop UE Traffic    ue_id=${ue_id}    pdu=3    dir=ul
        Stop UE Traffic    ue_id=${ue_id}    pdu=3    dir=dl
        Ensure UE PDU Session Release Is Successful    ue_id=${ue_id}    pdu_id=3
        Ensure UE Deregister Is Successful    ue_id=${ue_id}    ue_deregister_type=switch_off    by=ue
    END

Perform Stop Traffic and Detach SA UEs
    [Arguments]    ${sa_ue_list}    ${carrier_frequency}=509790    ${anr}=False
    FOR    ${ue_id}    IN    @{sa_ue_list}
        Log To Console    Going To Stop Traffic for SA UE: ${ue_id}
        Stop UE Traffic    ue_id=${ue_id}
        run keyword if    $anr == 'False'    Trigger A2 Event and validate Scell release    ue_id=${ue_id}    carrier_frequency=${carrier_frequency}
        Ensure UE PDU Session Release Is Successful    ue_id=${ue_id}    pdu_id=3
        run keyword if    $anr == 'False'    Ensure UE Deregister Is Successful    ue_id=${ue_id}    ue_deregister_type=switch_off    by=ue
        ...   ELSE
        ...   Ensure UE Deregister Is Successful    ue_id=${ue_id}    pass_regexp=UE${ue_id}: detached    ue_deregister_type=switch_off    by=ue
    END

Validate Pcell and Scell Throughput For SA UEs
    [Arguments]    ${expected_ul_tput}    ${expected_dl_tput}    ${UE_List}    ${Scell_Id}
    ${expected_dl_value}    Evaluate    isinstance(${expected_dl_tput}, list) == True
    ${expected_total_dl_tput}    Run Keyword If    ${expected_dl_value}    Evaluate
    ...    sum([int(str(x).encode('ascii')) for x in @{expected_dl_tput}])    ELSE    Set Variable    ${expected_dl_tput}
    ${is_single_ue}    Evaluate    len(${UE_List}) == 1
    Run Keyword If    ${is_single_ue}    Validate Pcell and Scell Throughput For Single SA UEs    ${expected_ul_tput}
    ...    ${expected_total_dl_tput}    ${UE_List}    ${Scell_Id}
    Run Keyword If    not ${is_single_ue}    Validate Pcell and Scell Throughput For Multi SA UEs    ${expected_ul_tput}
    ...    ${expected_total_dl_tput}    ${UE_List}    ${Scell_Id}

Validate Pcell and Scell Throughput For NSA UEs
    [Arguments]    ${expected_ul_tput}    ${expected_dl_tput}    ${UE_List}    ${Scell_Id}
    ${expected_dl_value}    Evaluate    isinstance(${expected_dl_tput}, list) == True
    ${expected_total_dl_tput}    Run Keyword If    ${expected_dl_value}    Evaluate
    ...    sum([int(str(x).encode('ascii')) for x in @{expected_dl_tput}])    ELSE    Set Variable    ${expected_dl_tput}
    ${is_single_ue}    Evaluate    len(${UE_List}) == 1
    Run Keyword If    ${is_single_ue}    Validate Pcell and Scell Throughput For Single NSA UEs    ${expected_ul_tput}
    ...    ${expected_total_dl_tput}    ${UE_List}    ${Scell_Id}
    Run Keyword If    not ${is_single_ue}    Validate Pcell and Scell Throughput For Multi NSA UEs    ${expected_ul_tput}
    ...    ${expected_total_dl_tput}    ${UE_List}    ${Scell_Id}

Perform Stop Traffic and Detach NSA UEs
    [Arguments]    ${nsa_ue_list}    ${bearer_id}=2    ${carrier_frequency}=509790
    FOR    ${ue_id}    IN    @{nsa_ue_list}
        Log To Console    Going To Stop Traffic for NSA UE: ${ue_id}
        Stop UE Traffic    ue_id=${ue_id}
        Trigger A2 Event measurement    ue_id=${ue_id}    pass_regexp=rrcConnectionReconfigurationComplete
        ...    carrier_frequency=${carrier_frequency}    scell=${NSA_Scell_Index}[1]    scell_rsrp=30    phycell_id=51
        Validate Scell Release    scell_index=${NSA_Scell_Index}[1]
        Release ENDC Bearer    ue_id=${ue_id}    bearer=${bearer_id}    cause=MISC_CauseMisc_unspecified
        UE Detach    ue_id=${ue_id}
    END

Perform UE Attach and Start Traffic For Single NSA UE
    [Arguments]    ${nsa_ue_list}     ${carrier_frequency}=527790    ${profile_id}=1    ${target_gnb}=2    ${target_cells}=2
    ...    ${bearer_id}=2    ${handover}=False    ${inter}=False
    FOR    ${ue_id}    IN    @{nsa_ue_list}
        UE Attach    ue_id=${ue_id}    profile_id=${profile_id}
        Run Keyword If    "${inter}" == "True"    Update UE parameters for eNB    id=${ue_id}    drx_config=off    measurement_gap=gp0:20
        ...    gap_trigger=enb_and_gnb_triggered    mgta=ms0    gap_purpose=perUE
        Validate Scell Regsitration
        ${output}    SGNB Addition For Bearer    ue_id=${ue_id}    target_gnb=${target_gnb}    target_cells=${target_cells}
        ...    bearer=${bearer_id}
        Run Keyword If    "${inter}" == "True"    Validate meas gap config prints for inter cases    ${output}
        Trigger A1 Event measurement    ue_id=${ue_id}    pass_regexp=rrcConnectionReconfigurationComplete
        ...    carrier_frequency=${carrier_frequency}    phycell_id=50    srsrp_nr=40
        Validate Scell Addition    scell_index=${NSA_Scell_Index}[1]
        Run Keyword If    "${handover}" == "False"
        ...    Associate UE to testmode    id=${ue_id}    testmode=csi_override     profile_id=2
        ...    action=activate    scell=8,9
        Log To Console    Going To Start Traffic for NSA UE: ${ue_id}
        Start Traffic    ue_id=${ue_id}    dir=ul    id=${bearer_id}    mbps=${ul_tput}
        Log To Console    Going To Check Scell Activation For NSA UE: ${ue_id}
        Run Keyword If    "${handover}" == "False"
        ...    Start Traffic and Validate Scell Activation for NSA    ${ue_id}    ${bearer_id}    dl_txput_list=${dl_tput_list}
        ...    ELSE
        ...    Start Traffic and Validate Scell Activation for NSA    ${ue_id}    ${bearer_id}    dl_txput_list=${dl_tput_HO_list}
    END

Perform UE Attach For Multi NSA UEs
    [Arguments]    ${nsa_ue_list}    ${carrier_frequency}=522270    ${profile_id}=1    ${target_gnb}=2    ${target_cells}=2    ${bearer_id}=2
    FOR    ${ue_id}    IN    @{nsa_ue_list}
        UE Attach    ue_id=${ue_id}    profile_id=${profile_id}
        Validate Scell Regsitration
        SGNB Addition For Bearer    ue_id=${ue_id}    target_gnb=${target_gnb}    target_cells=${target_cells}
        ...    bearer=${bearer_id}
        Trigger A1 Event measurement    ue_id=${ue_id}    pass_regexp=rrcConnectionReconfigurationComplete
        ...    carrier_frequency=${carrier_frequency}    phycell_id=50    srsrp_nr=40
        Validate Scell Addition    scell_index=${NSA_Scell_Index}[1]
        Associate UE to testmode    id=${ue_id}    testmode=csi_override     profile_id=2
        ...    action=activate    scell=8,9
    END

Verify scell activated for all UEs
    sleep     30s    reason=Waiting for all Scells to be activated
    Execute Egate Command    cmd=sim_log_set flush    timeout=2s
    FOR    ${ue_id}    IN    @{Multi_CA_SA_UE_List}
        ${sa_scell_ue_id}    Evaluate    ${ue_id}-1
        Egate console log verification    UeId:${sa_scell_ue_id},SubcellId:[0-1].* SCellIndex 1 activated successfully
    END
    FOR    ${ue_id}    IN    @{Multi_CA_NSA_UE_List}
        ${nsa_scell_ue_id}    Evaluate    ${ue_id}-1
        Egate console log verification    UeId:${nsa_scell_ue_id},SubcellId:[0-1].* SCellIndex 9 activated successfully
    END

Start DL NSA Traffic for multi UE scenario
    [Arguments]    ${ue_id}    ${bearer_id}    ${last_nsa_multi_ue}    ${dl_tput_list}
    ${len_dl_tput_list}    Evaluate    len(${dl_tput_list})
    FOR    ${index}    ${dl_tput}    IN ENUMERATE    @{dl_tput_list}
        ${last_index_status}    Evaluate    ${len_dl_tput_list} == ${index} + 1
        ${timeout}    Set Variable If    ${last_index_status}    280s     10s
        ${trf_id}=    Evaluate    ${index} + 1
        Run Keyword If    ${last_nsa_multi_ue} != ${ue_id}    Start Traffic    ue_id=${ue_id}
        ...    dir=dl    id=${bearer_id}    trf_id=${trf_id}    mbps=${dl_tput}
        Run Keyword If    (${last_nsa_multi_ue} == ${ue_id}) and not(${last_index_status})
        ...     Start Traffic    ue_id=${ue_id}    dir=dl    id=${bearer_id}    trf_id=${trf_id}    mbps=${dl_tput}
        ${output}   Run Keyword If    (${last_nsa_multi_ue} == ${ue_id}) and ${last_index_status}
        ...     Start Traffic With Regex Check    ue_id=${ue_id}    dir=dl    pass_regex=SCellIndex \\d+ activated successfully
        ...    timeout=${timeout}    id=${bearer_id}    trf_id=${trf_id}    mbps=${dl_tput}
    END
    [Return]    ${output}

Start traffic for all UEs
    [Arguments]    ${bearer_id}=2    ${dl_tput_list}=${dl_tput_list}
    ${last_nsa_multi_ue}    Set Variable    ${Multi_CA_NSA_UE_List}[-1]
    FOR    ${ue_id}    IN    @{Non_CA_SA_UE_List}
        Log To Console    Going To Start Traffic for SA Non CA Capable UE: ${ue_id}
        Start Traffic    ue_id=${ue_id}    dir=ul    pdu=3    protocol=udp    mbps=${ul_tput}
        Start Traffic    ue_id=${ue_id}    dir=dl    pdu=3    protocol=udp    mbps=${ul_tput}
        sleep    1s
    END
    FOR    ${ue_id}    IN    @{Multi_CA_SA_UE_List}
        Log To Console    Going To Start Traffic for SA UE: ${ue_id}
        Start Traffic    ue_id=${ue_id}    dir=ul    pdu=3    mbps=${ul_tput}
        Start DL SA Traffic for multi UE scenario    ${ue_id}    ${dl_tput_list}
        sleep    1s
    END
    FOR    ${ue_id}    IN    @{Multi_CA_NSA_UE_List}
        Log To Console    Going To Start Traffic for NSA UE: ${ue_id}
        Start Traffic    ue_id=${ue_id}    dir=ul    id=${bearer_id}    mbps=${ul_tput}
        Start DL NSA Traffic for multi UE scenario    ${ue_id}    ${bearer_id}    ${last_nsa_multi_ue}    ${dl_tput_list}
    END
    sleep   10s

Trigger Intrafreq SA handover from Real gNB to Sim gNB
    [Arguments]    ${ue_id_list}    ${carrier_frequency}=522270
    log to console    SA forward handover from Real gNB2 cell2 to simulator gNB22 cell1 ...
    FOR    ${ue_id}    IN    @{ue_id_list}
        ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=PATH_SWITCH_REQUEST_ACK Received
        ...    carrier_frequency=${carrier_frequency}    srsrp_nr=10    srsrq_nr=5     ssinr_nr=10    phycell_id=381    nrsrp_nr=40
        ...    nrsrq_nr=40    nsinr_nr=50
        Log To Console    Validating SA forward handover...
        Validate success prints from command output    ${output}
        ...    pass_regex=*UE${ue_id}: Inter-eNB handover from EXT_ENB-2.2 to ENB-22.1 performed*
        Validate success prints from command output    ${output}    pass_regex=*PATH_SWITCH_REQUEST_ACK Received*
    END
    sleep    10s   reason=To stabilise traffic txput

Trigger Intrafreq NSA handover from Real gNB to Sim gNB
    [Arguments]    ${ue_id_list}    ${carrier_frequency}=522270
    log to console    NSA forward handover from Real gNB2 cell2 to simulator gNB24 cell1 ...
    FOR    ${ue_id}    IN    @{ue_id_list}
        ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=Bearer-type change from MCG to SCG-split is successful
        ...    carrier_frequency=${carrier_frequency}    srsrp_nr=10    srsrq_nr=5
        ...    ssinr_nr=10    phycell_id=384    nrsrp_nr=40    nrsrq_nr=40    nsinr_nr=50
        Log To Console    Validating NSA forward handover...
        Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: Sending SgNB Change Confirm*
        Validate success prints from command output    ${output}    pass_regex=*Bearer-type change from MCG to SCG-split is successful*
    END
    sleep    10s    reason=To stabilise traffic txput

Trigger Intrafreq SA handover from Sim gNB to Real gNB
    log to console    SA reverse handover from simulator gNB22 cell1 to real gNB2 cell2
    [Arguments]    ${ue_id}     ${scell_index}    ${carrier_frequency}=522270    ${csi_override_needed}=False
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=PATH SWITCH REQUEST ACK    carrier_frequency=${carrier_frequency}
    ...    srsrp_nr=11    srsrq_nr=11    phycell_id=51    nrsrp_nr=30    nrsrq_nr=30
    Log To Console    Validating SA reverse handover...
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: Inter-eNB handover from ENB-22.1 to EXT_ENB-2.2 performed*
    Validate success prints from command output    ${output}
    ...    pass_regex=*PATH SWITCH REQUEST ACK with RAN UE NGAP ID*
    Run Keyword If    "${csi_override_needed}" == "True"
    ...    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    ${output_A1}    Trigger A1 Event measurement    ue_id=${ue_id}    pass_regexp=SCellIndex \\d+ activated successfully
    ...    carrier_frequency=${carrier_frequency}    srsrp_nr=40    phycell_id=50
    Validate success prints from command output    ${output_A1}    pass_regex=*SCellIndex ${scell_index} activated successfully*
    sleep    10s   reason=To stabilise traffic txput

Trigger Intrafreq NSA handover from Sim gNB to Real gNB
    log to console    NSA reverse handover from simulator gNB24 cell1 to real gNB2 cell2
    [Arguments]    ${ue_id}     ${scell_index}    ${carrier_frequency}=522270    ${csi_override_needed}=False
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp= Inter Sgnb Handover is successful
    ...    carrier_frequency=${carrier_frequency}    srsrp_nr=11    srsrq_nr=11    phycell_id=51    nrsrp_nr=30    nrsrq_nr=30
    Log To Console    Validating NSA reverse handover...
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: Sending SgNB Change Confirm*
    Validate success prints from command output    ${output}    pass_regex=*GNB-24: UE${ue_id}: === Inter Sgnb Handover is successful*
    Run Keyword If    "${csi_override_needed}" == "True"
    ...    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    ${output_A1}    Trigger A1 Event measurement    ue_id=${ue_id}    pass_regexp=SCellIndex \\d+ activated successfully
    ...    carrier_frequency=${carrier_frequency}    srsrp_nr=40    phycell_id=50
    Validate success prints from command output    ${output_A1}    pass_regex=*SCellIndex ${scell_index} activated successfully*
    sleep    10s   reason=To stabilise traffic txput

Trigger Interfreq SA handover from Real gNB to Sim gNB
    [Arguments]    ${ue_id}    ${A2_carrier_freq}=522270    ${A3_carrier_freq}=505230
    log to console    SA forward handover from Real gNB2 cell2 to simulator gNB23 cell1 ...
    Trigger A2 Event measurement    ue_id=${ue_id}    pass_regexp=rrcReconfigurationComplete    carrier_frequency=${A2_carrier_freq}
    ...    srsrp_nr=7    srsrq_nr=7
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=PATH_SWITCH_REQUEST_ACK Received
    ...    carrier_frequency=${A3_carrier_freq}    srsrp_nr=10    srsrq_nr=5    ssinr_nr=10    phycell_id=382    nrsrp_nr=40
    ...    nrsrq_nr=40    nsinr_nr=50
    Log To Console    Validating SA forward handover...
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: Inter-eNB handover from EXT_ENB-2.2 to ENB-23.1 performed*
    Validate success prints from command output    ${output}    pass_regex=*PATH_SWITCH_REQUEST_ACK Received*
    sleep    10s   reason=To stabilise traffic txput

Trigger Interfreq SA handover from Real gNB to Sim gNB to validate HandoverPreparationFailure
    [Arguments]    ${ue_id}    ${A2_carrier_freq}=522270    ${A3_carrier_freq}=505230    ${nrsrp_nr}=40    ${nrsrq_nr}=40
    log to console    SA forward handover from Real gNB2 cell2 to simulator gNB23 cell1 ...
    Trigger A2 Event measurement    ue_id=${ue_id}    pass_regexp=rrcReconfigurationComplete    carrier_frequency=${A2_carrier_freq}
    ...    srsrp_nr=7    srsrq_nr=7
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}
	...    pass_regexp=HandoverPreparationFailure for XnHANDOVER_REQUEST with action FAILURE
    ...    carrier_frequency=${A3_carrier_freq}    srsrp_nr=10    srsrq_nr=5    ssinr_nr=10    phycell_id=382    nrsrp_nr=${nrsrp_nr}
    ...    nrsrq_nr=${nrsrq_nr}    nsinr_nr=50
    Log To Console    Validating SA forward handover failure...
    Validate success prints from command output    ${output}
	...    pass_regex=*HandoverPreparationFailure for XnHANDOVER_REQUEST with action FAILURE*

Trigger Interfreq NSA handover from Real gNB to Sim gNB
    [Arguments]    ${ue_id}    ${A2_carrier_freq}=522270    ${A3_carrier_freq}=505230
    log to console    NSA forward handover from Real gNB2 cell2 to simulator gNB25 cell1 ...
    Run Keyword If    'AP_LO' in '${TOPOLOGY}'
    ...    Trigger A2 Event measurement    ue_id=${ue_id}    pass_regexp=rrcConnectionReconfiguration    carrier_frequency=${A2_carrier_freq}
    ...    srsrp_nr=30    srsrq_nr=30    rs_type=ssb
    ...    ELSE
    ...    Trigger A2 Event measurement    ue_id=${ue_id}    pass_regexp=rrcConnectionReconfiguration    carrier_frequency=${A2_carrier_freq}
    ...    srsrp_nr=7    srsrq_nr=7
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=Bearer-type change from MCG to SCG-split is successful
    ...    carrier_frequency=${A3_carrier_freq}    srsrp_nr=10    srsrq_nr=5    ssinr_nr=10    phycell_id=385    nrsrp_nr=40
    ...    nrsrq_nr=40    nsinr_nr=50
    Log To Console    Validating NSA forward handover...
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: Sending SgNB Change Confirm*
    Validate success prints from command output    ${output}    pass_regex=*Bearer-type change from MCG to SCG-split is successful*
    sleep    10s   reason=To stabilise traffic txput

Trigger Interfreq SA handover from Sim gNB to Real gNB
    [Arguments]    ${ue_id}    ${scell_index}    ${A2_carrier_sim_freq}=505230    ${A3_carrier_sim_freq}=522270    ${A1_carrier_freq}=522270
    ...    ${csi_override_needed}=False
    log to console    SA reverse handover from simulator gNB23 cell1 to Real gNB2 cell2...
    Update UE History Information    id=1    cell_type=large    nrcgi=311:489|0x05
    ...    gnb_id=23    time_ue_stayed_in_cell=98    action=commit    ue_enb_param_id=${ue_id}
    Trigger A2 Event measurement    ue_id=${ue_id}    pass_regexp=rrcReconfigurationComplete    carrier_frequency=${A2_carrier_sim_freq}
    ...    srsrp_nr=7    srsrq_nr=7
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=XN Handover Successfully completed at Source
    ...    carrier_frequency=${A3_carrier_sim_freq}    srsrp_nr=11    srsrq_nr=11    phycell_id=51    nrsrp_nr=30    nrsrq_nr=30
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: CTRL_RACH_COMPLETE Received*
    Validate success prints from command output    ${output}    pass_regex=*Received PATH SWITCH REQUEST from GNB-2*
    Run Keyword If    "${csi_override_needed}" == "True"
    ...    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    ${output_A1}    Trigger A1 Event measurement    ue_id=${ue_id}    pass_regexp=SCellIndex \\d+ activated successfully
    ...    carrier_frequency=${A1_carrier_freq}    phycell_id=50   srsrp_nr=40
    Validate success prints from command output    ${output_A1}    pass_regex=*SCellIndex ${scell_index} activated successfully*
    sleep    10s   reason=To stabilise traffic txput

Check Interfreq SA handover after resetting Handover Preparation procedure parameters
    [Arguments]    ${ue_id}   ${A2_carrier_freq}=522270    ${A3_carrier_freq}=505230    ${A2_carrier_sim_freq}=505230
    ...    ${A3_carrier_sim_freq}=522270    ${nrsrp_nr}=40    ${nrsrq_nr}=40
	log to console    SA forward handover from Real gNB2 cell2 to simulator gNB23 cell1 ...
    Run Keyword If    '${nrsrp_nr}' != '45'    Trigger A2 Event measurement    ue_id=${ue_id}    pass_regexp=rrcReconfigurationComplete
    ...    carrier_frequency=${A2_carrier_freq}    srsrp_nr=7    srsrq_nr=7
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=XN Handover Successfully completed at Target
    ...    carrier_frequency=${A3_carrier_freq}    srsrp_nr=10    srsrq_nr=5    ssinr_nr=10    phycell_id=382    nrsrp_nr=${nrsrp_nr}
    ...    nrsrq_nr=${nrsrq_nr}    nsinr_nr=50
    Log To Console    Validating SA forward handover...
	Run keyword And Continue On Failure    Validate success prints from command output
    ...    ${output}    pass_regex=*UE${ue_id}: Inter-eNB handover from EXT_ENB-2.2 to ENB-23.1 performed*
	Run keyword And Continue On Failure    Validate success prints from command output
    ...    ${output}    pass_regex=*PATH_SWITCH_REQUEST_ACK Received*
    log to console    SA reverse handover from simulator gNB23 cell1 to Real gNB2 cell2...
    Trigger A2 Event measurement    ue_id=${ue_id}    pass_regexp=rrcReconfigurationComplete
    ...    carrier_frequency=${A2_carrier_sim_freq}    srsrp_nr=7    srsrq_nr=7
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=XN Handover Successfully completed at Source
    ...    carrier_frequency=${A3_carrier_sim_freq}    srsrp_nr=11    srsrq_nr=11    phycell_id=51    nrsrp_nr=${nrsrp_nr}
    ...    nrsrq_nr=${nrsrq_nr}
	Run keyword And Continue On Failure    Validate success prints from command output
    ...    ${output}    pass_regex=*Inter-eNB handover from ENB-23.1 to EXT_ENB-2.2 performed*
	Run keyword And Continue On Failure    Validate success prints from command output
    ...    ${output}    pass_regex=*UE${ue_id}: CTRL_RACH_COMPLETE Received*
	Run keyword And Continue On Failure    Validate success prints from command output
    ...    ${output}    pass_regex=*Received PATH SWITCH REQUEST from GNB-2*
	Run keyword And Continue On Failure    Validate success prints from command output
    ...    ${output}    pass_regex=*PATH SWITCH REQUEST ACK*

Trigger Interfreq NSA handover from Sim gNB to Real gNB
    [Arguments]    ${ue_id}     ${scell_index}    ${csi_override_needed}=False    ${A2_carrier_sim_freq}=505230    ${A3_carrier_sim_freq}=522270
    ...    ${A1_carrier_freq}=522270
    log to console    NSA reverse handover from simulator gNB25 cell1 to Real gNB2 cell2...
    Update UE History Information     id=2    cell_type=large    nrcgi=311:489|0x07
    ...    gnb_id=25    time_ue_stayed_in_cell=98    action=commit    ue_enb_param_id=${ue_id}
    Trigger A2 Event measurement    ue_id=${ue_id}    pass_regexp=rrcReconfigurationComplete    carrier_frequency=${A2_carrier_sim_freq}
    ...    srsrp_nr=7    srsrq_nr=7
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=Inter Sgnb Handover is successful
    ...    carrier_frequency=${A3_carrier_sim_freq}     srsrp_nr=11    srsrq_nr=11    phycell_id=51    nrsrp_nr=30    nrsrq_nr=30
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: === Inter Sgnb Handover is successful*
    Run Keyword If    "${csi_override_needed}" == "True"
    ...    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    ${output_A1}    Trigger A1 Event measurement    ue_id=${ue_id}    pass_regexp=SCellIndex \\d+ activated successfully
    ...    carrier_frequency=${A1_carrier_freq}    phycell_id=50   srsrp_nr=40
    Validate success prints from command output    ${output_A1}    pass_regex=*SCellIndex ${scell_index} activated successfully*
    sleep    10s   reason=To stabilise traffic txput

Validate throughput from UE stats and bearer stats for NSA UEs
    [Arguments]    ${expected_ul_tput}    ${expected_dl_tput}    ${UE_List}    ${Scell_Id}
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    3min    30s    Validate Pcell and Scell Throughput For NSA UEs
    ...    expected_ul_tput=${expected_ul_tput}    expected_dl_tput=${expected_dl_tput}    UE_List=${UE_List}    Scell_Id=${Scell_Id}

Validate throughput from UE stats and bearer stats for SA UEs
    [Arguments]    ${expected_ul_tput}    ${expected_dl_tput}    ${UE_List}    ${Scell_Id}
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    3min    30s    Validate Pcell and Scell Throughput For SA UEs
    ...    expected_ul_tput=${expected_ul_tput}    expected_dl_tput=${expected_dl_tput}     UE_List=${UE_List}    Scell_Id=${Scell_Id}

Update Gnb with NGBasedHO configuration for 5GC001729
    ${original_scf_path}    Download SCF file    local_dir_path=${testlog_path}    file_name=SCF_original.xml
    set test variable    ${original_scf_path}
    ${NRBTS_DISTNAME}    admin_helper.get_distname_for_nrbts
    set test variable    ${NRBTS_DISTNAME}
    ${NRCELL_DISTNAME}    admin_helper.get_distname_for_nrcell_using_logical_id    logical_cell_id=2
    set test variable    ${NRCELL_DISTNAME}
    1729_Keywords.Get original params from gnB
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    delta_store.update managed object and parameter to delta    dist_name=${NRBTS_DISTNAME}    &{NgHo_Inter_Intra_params}
    FOR    ${nrrel_id}    IN    @{nrrel_profile_id}
         delta_store.update managed object and parameter to delta    dist_name=${NRCELL_DISTNAME}/NRREL-${nrrel_id}    &{nrrel_params}
    END
    ${delta_store}    Collect Delta Store
    Recommission GNB With Delta    delta_file=${delta_store}    should_activate=${True}
    Set Test Variable    ${Gnb_Revert}    True
    Wait for gNB To Be Ready

Update WTS config file for 5GC001729
    Run keyword And Ignore Error    Run And Return Rc And Output   cp ${WTS_INSTALL_PATH}/basic_setup.cfg ${WTS_INSTALL_PATH}/basic_setup_backup.cfg
    wts_conf.load_wts_cfg    file_path=${WTS_INSTALL_PATH}/basic_setup.cfg
    wts_conf.modify    command=set_gnb id=2 type=external    modification=gnb_id=0x02
    wts_conf.modify    command=set_cell id=2 gnb=2    modification=nrci=0x02
    wts_conf.modify    command=gnb_param id=22   modification=xn_listening_socket=1 send_xn_setup=false measEvent=A2 measEvent=A3 sa_ho=ng_based
    wts_conf.modify    command=gnb_param id=23   modification=xn_listening_socket=1 send_xn_setup=false measEvent=A2 measEvent=A3 sa_ho=ng_based
    wts_conf.modify    command=gnb_param id=24   modification=xn_listening_socket=1 send_xn_setup=false measEvent=A2 measEvent=A3 sa_ho=ng_based
    wts_conf.modify    command=gnb_param id=25   modification=xn_listening_socket=1 send_xn_setup=false measEvent=A2 measEvent=A3 sa_ho=ng_based
    wts_conf.save_wts_cfg    file_path=${WTS_INSTALL_PATH}/basic_setup.cfg
    [Teardown]    Run keyword And Ignore Error    Run And Return Rc And Output   cp ${WTS_INSTALL_PATH}/basic_setup.cfg ${testlog_path}

Get original params from gnB
    ${ng_ho_param}    scf_helper.get_feature_paramters_from_scf    ${original_scf_path}     ${NgHo_feature_param}     ${NRBTS_DISTNAME}
    &{nrrel_dict}     create dictionary
    FOR    ${nrrel_id}    IN    @{nrrel_profile_id}
         ${nrrel_distname}    set variable    ${NRCELL_DISTNAME}/NRREL-${nrrel_id}
         ${nrrel_param}    scf_helper.get_feature_paramters_from_scf    ${original_scf_path}     ${nrrel_params}    ${nrrel_distname}
         set to dictionary    ${nrrel_dict}    ${nrrel_distname}=${nrrel_param}
    END
    set test variable    ${ng_ho_param}
    set test variable    ${nrrel_dict}

Get Revert Delta Param for 5GC001729
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    delta_store.update managed object and parameter to delta    dist_name=${NRBTS_DISTNAME}    &{ng_ho_param}
    FOR    ${nrrel_distname}    IN    @{nrrel_dict.keys()}
         delta_store.update managed object and parameter to delta    dist_name=${nrrel_distname}    &{nrrel_dict['${nrrel_distname}']}
    END
    ${delta_store}    Collect Delta Store
    [Return]    ${delta_store}

Trigger Intrafreq NG Based SA handover from Real gNB to Sim gNB
    [Arguments]    ${ue_id}    ${carrier_frequency}=522270
    log to console    SA forward handover from Real gNB2 cell2 to simulator gNB22 cell1 ...
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=Downlink packets from external network dropped by UPF
    ...    carrier_frequency=${carrier_frequency}    srsrp_nr=10    srsrq_nr=5     ssinr_nr=10
    ...    phycell_id=381    nrsrp_nr=40    nrsrq_nr=40    nsinr_nr=50
    Log To Console    Validating SA forward handover...
    Validate success prints from command output    ${output}
    ...    pass_regex=*UE${ue_id}: Inter-eNB handover from EXT_ENB-2.2 to ENB-22.1 performed*
    Validate NG based handover prints from command output    ${output}
    sleep    5s   reason=To stabilise traffic

Trigger Intrafreq NG Based NSA handover from Real gNB to Sim gNB
    [Arguments]    ${ue_id}    ${carrier_frequency}=522270
    log to console    NSA forward handover from Real gNB2 cell2 to simulator gNB24 cell1 ...
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=Bearer-type change from MCG to SCG-split is successful
    ...    carrier_frequency=${carrier_frequency}
    ...    srsrp_nr=10    srsrq_nr=5    ssinr_nr=10    phycell_id=384    nrsrp_nr=40    nrsrq_nr=40    nsinr_nr=50
    Log To Console    Validating NSA forward handover...
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: Sending SgNB Change Confirm*
    Validate success prints from command output    ${output}    pass_regex=*Bearer-type change from MCG to SCG-split is successful*
    Validate success prints from command output    ${output}    pass_regex=*Source-SgNB global ran id:*
    Validate success prints from command output    ${output}    pass_regex=*Target-SgNB global ran id:*
    sleep    5s    reason=To stabilise traffic txput

Trigger Intrafreq NG Based NSA handover from Sim gNB to Real gNB
    log to console    NSA reverse handover from simulator gNB24 cell1 to real gNB2 cell2
    [Arguments]    ${ue_id}     ${scell_index}    ${carrier_frequency}=522270
    Update UE History Information     id=2    cell_type=large    nrcgi=311:489|0x06
    ...    gnb_id=24    time_ue_stayed_in_cell=97    action=commit    ue_enb_param_id=${ue_id}
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp= Inter Sgnb Handover is successful
    ...    carrier_frequency=${carrier_frequency}    srsrp_nr=11    srsrq_nr=11    phycell_id=51    nrsrp_nr=30    nrsrq_nr=30
    Log To Console    Validating NSA reverse handover...
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: Sending SgNB Change Confirm*
    Validate success prints from command output    ${output}    pass_regex=*GNB-24: UE${ue_id}: === Inter Sgnb Handover is successful*
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    ${output_A1}    Trigger A1 Event measurement    ue_id=${ue_id}    pass_regexp=SCellIndex \\d+ activated successfully
    ...    carrier_frequency=${carrier_frequency}
    ...    srsrp_nr=40    phycell_id=50
    Validate success prints from command output    ${output_A1}    pass_regex=*SCellIndex ${scell_index} activated successfully*
    sleep    70s   reason=To stabilise traffic txput

Trigger Intrafreq NG Based SA handover from Sim gNB to Real gNB
    [Arguments]    ${ue_id}    ${scell_index}    ${carrier_frequency}=522270
    log to console    SA reverse handover from simulator gNB22 cell1 to real gNB2 cell2
    Update UE History Information    id=1    cell_type=large    nrcgi=311:489|0x04
    ...    gnb_id=22    time_ue_stayed_in_cell=97    action=commit    ue_enb_param_id=${ue_id}
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=Inter-eNB handover
    ...    carrier_frequency=${carrier_frequency}    srsrp_nr=11    srsrq_nr=11    phycell_id=51    nrsrp_nr=30    nrsrq_nr=30
    Log To Console    Validating NG based SA reverse handover...
    Validate success prints from command output    ${output}    pass_regex=*NgAPHANDOVER_REQUEST*
    Validate success prints from command output    ${output}    pass_regex=*HANDOVER REQUIRED: gNB=22, AMF_UE_NGAP_ID*
    Validate success prints from command output    ${output}    pass_regex=*HANDOVER REQUIRED: gNB=22, RAN_UE_NGAP_ID=2*
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: Inter-eNB handover from ENB-22.1 to EXT_ENB-2.2 performed*
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    ${output_A1}    Trigger A1 Event measurement    ue_id=${ue_id}    pass_regexp=SCellIndex \\d+ activated successfully
    ...    carrier_frequency=${carrier_frequency}    srsrp_nr=40    phycell_id=50
    Validate success prints from command output    ${output_A1}    pass_regex=*SCellIndex ${scell_index} activated successfully*
    sleep    10s   reason=To stabilise traffic txput

Trigger Interfreq NG Based SA handover from Real gNB to Sim gNB
    [Arguments]    ${ue_id}    ${A2_carrier_freq}=522270    ${A3_carrier_freq}=505230
    log to console    NG based SA forward handover from Real gNB2 cell2 to simulator gNB22 cell1 ...
    Trigger A2 Event measurement    ue_id=${ue_id}    pass_regexp=measurementReport
    ...    carrier_frequency=${A2_carrier_freq}    srsrp_nr=7    srsrq_nr=7
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=Downlink packets from external network dropped by UPF
    ...    carrier_frequency=${A3_carrier_freq}    srsrp_nr=10    srsrq_nr=5    ssinr_nr=10
    ...    phycell_id=382    nrsrp_nr=40    nrsrq_nr=40    nsinr_nr=50
    Log To Console    Validating SA forward handover...
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: Inter-eNB handover from EXT_ENB-2.2 to ENB-23.1 performed*
    Validate NG based handover prints from command output    ${output}
    sleep    10s   reason=To stabilise traffic txput

Trigger Interfreq NG NSA handover from Real gNB to Sim gNB
    [Arguments]    ${ue_id}    ${A2_carrier_freq}=522270    ${A3_carrier_freq}=505230
    log to console    NSA forward handover from Real gNB2 cell2 to simulator gNB25 cell1 ...
    Trigger A2 Event measurement    ue_id=${ue_id}    pass_regexp=rrcConnectionReconfiguration    carrier_frequency=${A2_carrier_freq}
    ...    srsrp_nr=30    srsrq_nr=30    rs_type=ssb
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=Bearer-type change from MCG to SCG-split is successful
    ...    carrier_frequency=${A3_carrier_freq}    srsrp_nr=10    srsrq_nr=5    ssinr_nr=10
    ...    phycell_id=385    nrsrp_nr=40    nrsrq_nr=40    nsinr_nr=50
    Log To Console    Validating NSA forward handover...
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: Sending SgNB Change Confirm*
    Validate success prints from command output    ${output}    pass_regex=*Bearer-type change from MCG to SCG-split is successful*
    sleep    10s   reason=To stabilise traffic txput

Trigger Interfreq NG Based SA handover from Sim gNB to Real gNB
    [Arguments]    ${ue_id}    ${scell_index}    ${A2_carrier_sim_freq}=505230    ${A3_carrier_sim_freq}=522270    ${A1_carrier_freq}=522270
    log to console    SA reverse handover from simulator gNB23 cell1 to Real gNB2 cell2...
    Update UE History Information    id=1    cell_type=large    nrcgi=311:489|0x05
    ...    gnb_id=23    time_ue_stayed_in_cell=98    action=commit    ue_enb_param_id=${ue_id}
    Trigger A2 Event measurement    ue_id=${ue_id}    pass_regexp=measurementReport    carrier_frequency=${A2_carrier_sim_freq}
    ...    srsrp_nr=7    srsrq_nr=7
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=Inter-eNB handover
    ...    carrier_frequency=${A3_carrier_sim_freq}    srsrp_nr=11    srsrq_nr=11    phycell_id=51    nrsrp_nr=30    nrsrq_nr=30
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: CTRL_RACH_COMPLETE Received*
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: Inter-eNB handover from ENB-23.1 to EXT_ENB-2.2 performed*
    Validate success prints from command output    ${output}    pass_regex=*HANDOVER REQUIRED: gNB=23, AMF_UE_NGAP_ID*
    Validate success prints from command output    ${output}    pass_regex=*HANDOVER REQUIRED: gNB=23, RAN_UE_NGAP_ID=2*
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    ${output_A1}    Trigger A1 Event measurement    ue_id=${ue_id}    pass_regexp=SCellIndex \\d+ activated successfully
    ...    carrier_frequency=${A1_carrier_freq}    srsrp_nr=40    phycell_id=50
    Validate success prints from command output    ${output_A1}    pass_regex=*SCellIndex ${scell_index} activated successfully*
    sleep    10s   reason=To stabilise traffic txput

Update WTS config file for InterRAT handover 5GC001729
    Run keyword And Ignore Error    run and return rc and output
    ...    cp ${WTS_INSTALL_PATH}/basic_setup.cfg ${WTS_INSTALL_PATH}/basic_setup_backup.cfg
    wts_conf.load_wts_cfg    file_path=${WTS_INSTALL_PATH}/basic_setup.cfg
    wts_conf.insert    command=set ENB2_S1_ADDR="10.0.1.140"   location=after    reference=set GNB_S1U_ADDR="10.0.1.112"
    wts_conf.modify    command=set_gnb id=2 type=external    modification=gnb_id=0x2 nssai=0x1:0xd143A5
    wts_conf.modify    command=set_cell id=2 gnb=2    modification=nrci=0x02 tdd_cell=on
    ${set_cell_2}     catenate
    ...     set_cell id=2 gnb=3 pci=3:2 earfcn=1400:19400 tac=200
    ...     proxy=$DAEMON_IP:9999|$DAEMON_IP:8888 nrci=0x8 tdd_cell=on bw=20MHz technology=lte mandatory_for_activation=off
    wts_conf.insert
    ...    command=set_gnb id=3 type=simulated plmn=311:489 ng=$ENB2_S1_ADDR daemon=$SERVER_IP:$EDAEMON_PORT gnb_id=012:28 nssai=0x01:0xD143A5
    ...    location=after    reference=set_cell id=1 gnb=25
    wts_conf.insert
    ...    command=${set_cell_2}    location=after    reference=set_gnb id=3 type=simulated
    wts_conf.save_wts_cfg    file_path=${WTS_INSTALL_PATH}/basic_setup.cfg
    [Teardown]    Run keyword And Ignore Error    Run And Return Rc And Output   cp ${WTS_INSTALL_PATH}/basic_setup.cfg ${testlog_path}

Update Gnb with InterRAT configuration for 5GC001729
    ${original_scf_path}    Download SCF file    local_dir_path=${testlog_path}    file_name=SCF_original.xml
    set test variable    ${original_scf_path}
    ${NRBTS_DISTNAME}    admin_helper.get_distname_for_nrbts
    set test variable    ${NRBTS_DISTNAME}
    Get original params from gnB for interrat handover
    Recommission GNB With Delta    delta_file=${interrat_gnb_delta_json}    should_activate=${True}
    Set Test Variable    ${Gnb_Revert}    True
    Wait for gNB To Be Ready

Get original params from gnB for interrat handover
    ${interrat_feature_param}    scf_helper.get_feature_paramters_from_scf    ${original_scf_path}     ${InterRAT_params}     ${NRBTS_DISTNAME}
    set test variable    ${interrat_feature_param}

Get Revert Delta Param for interrat handover 5GC001729
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    delta_store.update managed object and parameter to delta    dist_name=${NRBTS_DISTNAME}    &{interrat_feature_param}
    delta_store.delete_param_from_delta             dist_name=${NRBTS_DISTNAME}/NRCELL-2    param_name=nrhoirDNList
    delta_store.delete_managed_object_from_delta    dist_name=${NRBTS_DISTNAME}/NRADJECELL-1
    delta_store.delete_managed_object_from_delta    dist_name=${NRBTS_DISTNAME}/NRCELL-2/NRRELE-1
    delta_store.delete_managed_object_from_delta    dist_name=${NRBTS_DISTNAME}/NRHOIR-1
    delta_store.delete_managed_object_from_delta    dist_name=${NRBTS_DISTNAME}/XNLINK-8
    ${delta_store}    Collect Delta Store
    [Return]    ${delta_store}

Trigger InterRAT SA handover from Real gNB to Sim eNB
    [Arguments]    ${ue_id}    ${A2_carrier_freq}=522270
    log to console    InterRAT SA forward handover from 5GC(RealgNB-2.2) to LTE(SimENB-3.2)...
    Trigger A2 Event measurement    ue_id=${ue_id}    pass_regexp=measurementReport    carrier_frequency=${A2_carrier_freq}    srsrp_nr=11
    ...   srsrq_nr=11   srs_result=0:11:11:0    phycell_id=50    nrsrp_nr=30    nrsrq_nr=30    rs_type=ssb    index=0    nrs_result=30:30:0
    ${output}    Trigger B2 Event measurement    ue_id=${ue_id}    pass_regexp=IRAT Handover from NR to EUTRA completed
    ...    carrier_frequency=1400    eutra=True   srsrp_nr=11    srsrq_nr=11    srs_result=0:11:11:0
    ...    phycell_id=11    nrsrp_nr=30    nrsrq_nr=30    rs_type=ssb    index=0    nrs_result=30:30:0
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: Successful handover from EXT_ENB-2.2 to ENB-3.2*
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: IRAT Handover from NR to EUTRA completed*
    sleep    10s   reason=To stabilise traffic txput

Trigger InterRAT SA handover from Sim eNB to Real gNB
    [Arguments]    ${ue_id}    ${scell_index}=1    ${A1_carrier_freq}=522270
    log to console    InterRAT SA reverse handover from LTE(SimENB-3.2) to 5GC(RealgNB-2.2)...
    ${output}    Trigger eNB initiated inter-rat handover to 5g    ue_id=${ue_id}    target_gnb=2    target_cell=2
    ...    plmn=311:489    pass_regexp=Inter-eNB handover
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: Received IratFromEutraToNrHo with valid NAS Container*
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: Inter-eNB handover from ENB-3.2 to EXT_ENB-2.2 performed*
    sleep    5s   reason=To stabilise traffic txput
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    ${output_A1}    Trigger A1 Event measurement    ue_id=${ue_id}    pass_regexp=SCellIndex \\d+ activated successfully
    ...    carrier_frequency=${A1_carrier_freq}    phycell_id=50    srsrp_nr=40
    Validate success prints from command output    ${output_A1}    pass_regex=*SCellIndex ${scell_index} activated successfully*
    sleep    30s   reason=To stabilise traffic txput

Trigger A2 Event and validate Scell release
    [Arguments]    ${ue_id}    ${carrier_frequency}
    Trigger A2 Event measurement    ue_id=${ue_id}    pass_regexp=measurementReport    carrier_frequency=${carrier_frequency}
    ...    scell=${SA_Scell_Index}[1]    scell_rsrp=30    phycell_id=51
    Validate Scell Release    scell_index=${SA_Scell_Index}[1]

Update WTS config file for ANR InterRAT handover 5GC001729
    Run keyword And Ignore Error    run and return rc and output
    ...    cp ${WTS_INSTALL_PATH}/basic_setup.cfg ${WTS_INSTALL_PATH}/basic_setup_backup.cfg
    wts_conf.load_wts_cfg    file_path=${WTS_INSTALL_PATH}/basic_setup.cfg
    wts_conf.insert    command=set ENB2_S1_ADDR="10.0.1.138"   location=after    reference=set PDN_IP17="4.7.254.217"
    wts_conf.modify    command=ue_param id=3    modification=ue_eutra_capabilities=1E000030010312000000
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

Update Gnb with ANR InterRAT configuration for 5GC001729
    ${original_scf_path}    Download SCF file    local_dir_path=${testlog_path}    file_name=SCF_original.xml
    set test variable    ${original_scf_path}
    ${NRBTS_DISTNAME}    admin_helper.get_distname_for_nrbts
    set test variable    ${NRBTS_DISTNAME}
    run keyword and ignore error    Delete anr profile if present
    Get original params from gnB for ANR interrat handover
    Recommission GNB With Delta    delta_file=${anr_ir_gnb_delta_json}    should_activate=${True}
    Set Test Variable    ${Gnb_Revert}    True
    Wait for gNB To Be Ready

Get original params from gnB for ANR interrat handover
    ${anrIR_feature_param_original}    scf_helper.get_feature_paramters_from_scf    ${original_scf_path}     ${ANR_InterRAT_params}
    ...     ${NRBTS_DISTNAME}
    set test variable    ${anrIR_feature_param_original}

Get Revert Delta Param for ANR interrat handover 5GC001729
    Run keyword And Continue On Failure    Delete anr profile if present
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    delta_store.update managed object and parameter to delta    dist_name=${NRBTS_DISTNAME}    &{anrIR_feature_param_original}
    delta_store.delete_param_from_delta             dist_name=${NRBTS_DISTNAME}/NRCELL-2    param_name=nrhoirDNList
    delta_store.delete_managed_object_from_delta    dist_name=${NRBTS_DISTNAME}/NRHOIR-1
    delta_store.delete_managed_object_from_delta    dist_name=${NRBTS_DISTNAME}/NRANRPRE-1
    delta_store.delete_managed_object_from_delta    dist_name=${NRBTS_DISTNAME}/NRANR-1
    ${delta_store}    Collect Delta Store
    [Return]    ${delta_store}

Trigger ANR InterRAT SA handover from Real gNB to Sim eNB
    [Arguments]    ${ue_id}
    log to console    InterRAT SA forward handover from 5GC(RealgNB-2.2) to LTE(SimENB-3.1)...
    Trigger A2 Event measurement    ue_id=${ue_id}    pass_regexp=measurementReport    carrier_frequency=522270    srsrp_nr=11
    ...   srsrq_nr=11   srs_result=0:11:11:0
    ${output}    Trigger B2 Event measurement    ue_id=${ue_id}    pass_regexp=Completed handling UeContextReleaseComplete for Handover Type
    ...    carrier_frequency=2200    eutra=True   srsrp_nr=11    srsrq_nr=11    srs_result=0:11:11:0
    ...    phycell_id=30    nrsrp_nr=58    nrsrq_nr=30    rs_type=ssb    index=1    nrs_result=30:30:0
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: Successful handover from EXT_ENB-2.2 to ENB-3.1*
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: IRAT Handover from NR to EUTRA completed*
    Validate success prints from command output    ${output}    pass_regex=*Completed handling UeContextReleaseComplete for Handover Type:1*
    sleep    30s   reason=To stabilise traffic txput
