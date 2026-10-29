*** Settings ***

Resource     ../resources/5G_SW_WRO_Keywords.robot
Resource     ../resources/admin.robot
#Resource     ../resources/scripts/script.robot

Library      ta5g_file_system
Library      ta5g_testline_management
Library      ta5g_iphy
Library      ta5g_enb
Library      ta5g_ue_measurements
Library      ta5g_delta
Library      taf.ul.ettf.setups
Library      ta5g_egate
Library      ../resources/python/keywords_ROHC.py


*** Variables ***
${custom_dir}    resources/custom-config/2_CELLS_SANSA_TDD_CA_87165
${custom-scf}    ${CURDIR}/../${custom_dir}/87165_gNB_scf_ASIL_ABIO_TDD_ECPRI_cmwv_SANSA_FS_2CC_CA_N41_N79.xml
${custom-iphy}   ${CURDIR}/../${custom_dir}/AP_iphy_AQHA_AZTA_ASIL_ABIO_TDD_ECPRI_cmwv_SANSA_FS_2CC_CA_N41_N79.xml


*** Keywords ***
Attach Ue And Establish PDU Session
    [Arguments]    ${ue_id}    ${pdu_id}    ${gw_id}    ${mbps}=3
#    Attach Ue    ue_id=${ue_id}
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    sleep    5
    Execute Egate Command    cmd=ue_register id=${ue_id}    #pass_regexp=UE now in NG RM Registered
    sleep    5
    #    Establish Pdu Session    ue_id=${ue_id}    pdu=${pdu_id}    gw_id=${gw_id}
    Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=1    #pass_regexp=QoS Routing Table
    sleep    5
#    Execute Egate Command    cmd=ue_register id=1    pass_regexp=UE now in NG RM Registered
#    Execute Egate Command    cmd=set_pdu_param ue=1 pdu=1 trf_type=internal
#    Execute Egate Command    cmd=ue_pdu_session_setup ue=1 pdu=1 gw=1 nwslice=1    pass_regexp=QoS Routing Table
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=${mbps} trf_id=1

    sleep    5

#    Execute Egate Command And Wait For Data
#    ...    cmd=ue_pdu_session_setup ue=2 pdu=2 nwslice=1 gw=2
#    ...    pass_regexp=UE2: Received RRC Release while in FIVE-GS-MM-REGISTERED state

Attach Ue And Establish PDU Session Cell1
    [Arguments]    ${ue_id}    ${pdu_id}    ${gw_id}    ${mbps}=3
#    Attach Ue    ue_id=${ue_id}
    Execute Egate Command    cmd=ue_change_location id=${ue_id} enb=2 cell=1
    sleep    5
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    sleep    5
    Execute Egate Command    cmd=ue_register id=${ue_id}    #pass_regexp=UE now in NG RM Registered
    sleep    5
    Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=1    #pass_regexp=QoS Routing Table
    sleep    5
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=${mbps} trf_id=1

Attach UE with traffic
    [Arguments]  ${ue_id}    ${pdu_id}    ${gw_id}    ${mbps}=3

    Attach Ue    ue_id=${ue_id}
    Establish Pdu Session With Traffic   ue_id=${ue_id}   pdu_id=${pdu_id}    gw_id=${gw_id}     throughput=${mbps}

Start Traffic
    [Arguments]    ${ue_id}    ${pdu_id}    ${dir}    ${mbps}    ${trf_id}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=${dir} mbps=${mbps} trf_id=${trf_id}

Check trafic
    [Arguments]    ${ue_id}    ${scell}    ${pdu_id}

    ${output1}    get average for given qfi    ue_id=${ue_id}    pdu_id=${pdu_id}    qfi_id=1      direction=dl
    log to console   Traffic for UE${ue_id}:${output1}
    ${out}    Evaluate   ${output1}
    Set test variable    ${out}

UE Deregister
    [Arguments]    ${ue_id}
    Execute Egate Command    cmd=ue_deregister id=${ue_id} ue_deregister_type=switch_off

UE Multiple Deregister
    [Arguments]  ${from}  ${to}
    FOR    ${i}    IN RANGE    ${from}    ${to}
        UE Deregister    ue_id=${i}
    END
