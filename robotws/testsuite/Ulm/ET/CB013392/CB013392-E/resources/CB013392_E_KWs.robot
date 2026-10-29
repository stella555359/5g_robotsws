*** Settings ***
Documentation    Specific Test Cases for subfeature CB013392-E
Library    ./../../libraries/CB013392_tools.py                WITH NAME  CB013392
Library    ./../configurations/CB013392_E_profile.py          WITH NAME  CB013392_E_PROFILE
Resource   ./../../../../resources/Common/coam_ulm.robot
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]


*** Variables ***


${target_bler}           100,95,90,50,30,10,5,1,0,0,0,0,0,0,0



*** Keywords ***

BLER_Setup
    wts_ue . Configure NR BLER testmode  profile_id=10    target_mcs=27  target_bler=${target_bler}  mcs_table=qam64
    FOR   ${ue_id}  IN   @{non_attached_ues_list}
        wts_ue . Associate UEs to testmode    ue_id=${ue_id}      profile_id=10      action=activate    testmode=bler
    END


set AMF param indexToRFSP
    [Arguments]      ${ue_id}=1  ${indexToRFSP}=none
    Log To Console    execute on wts: amf_ue_ics_param id=1 indexToRFSP=${indexToRFSP}
    sleep     5s
    ute_wtssim.execute egate command     cmd=amf_ue_ics_param id=1 indexToRFSP=${indexToRFSP}  ue=${ue_id}    alias=ap_egate


Trigger Traffic
    #--- Start Traffic UE1 ----------------------------------------------------------------------------------------------------------[150 characters]
    FOR   ${ue_id}  IN   @{non_attached_ues_list}
        Start Traffic In UL    ue_id=${ue_id}    qfi_id=1    trf_id=2    mbps=2    seconds=910
        Start Traffic In DL    ue_id=${ue_id}    qfi_id=1    trf_id=4    mbps=10    seconds=910
        ${output}   wts_ue . Send Egate Command And Verify Output   cmd=ue_nr_stats id=${ue_id} type=pdsch,pusch scell=0,1
        Log    ${output}    console=yes
    END
    Sleep  910s


Deregister UEs and change location
    FOR   ${ue_id}  IN   @{non_attached_ues_list}
        wts_ue . UE Deregister    ue_id=${ue_id}
        ${output}   wts_ue . Send Egate Command and verify output   cmd=ue_change_location id=${ue_id} cell=11
        Log    ${output}    console=yes
    END



E B1 Loop Test Steps
    CB013392 . initialize_egate
    ${LOOP_COUNT}=    CB013392_E_PROFILE . get_tc_loop_count
    FOR    ${loop_ctr}    IN RANGE    1    ${LOOP_COUNT}    1
        Log to console  Loop Count: ${loop_ctr}
        E B1 MUE Test Steps
        sleep  10s
    END


E B1 MUE Test Steps
    Get Not Attached UEs
    CB013392 . register_multiple_ue_with_amf    ${non_attached_ues_list}
    ${ho_ue_list}=    CB013392_E_PROFILE . get_ue_to_be_ho
    CB013392 . get_ue_meas_disp_kpi    ${ho_ue_list}
    FOR   ${ue_id}  IN   @{ho_ue_list}
        CB013392 . trigger_ho_kpi    ue_id=${ue_id}    a3_meas_id=6
    END
    ${non_ho_ue_list}=    CB013392_E_PROFILE . get_non_ho_ue
    CB013392 . get_ue_meas_disp_kpi    ${non_ho_ue_list}
    Trigger Traffic
    Deregister UEs and change location


Get Not Attached UEs
    ${non_attached_ues_dict}=  Get Attach List    scenario_name=${scenario_name}    ue_type=sa    with_auto_attach=${FALSE}
    @{non_attached_ues_list}=   get dictionary keys  ${non_attached_ues_dict}
    Set Suite Variable    @{non_attached_ues_list}


Start Traffic in DL
    [Arguments]  ${ue_id}  ${qfi_id}  ${trf_id}  ${mbps}  ${seconds}
    &{kwargs}=    create dictionary    mbps=${mbps}    pdu=2    qfi=${qfi_id}    seconds=${seconds}
    wts_ue . Start data traffic in egate    ue_id=${ue_id}
    ...                                     direction=dl
    ...                                     protocol=udp
    ...                                     ack_mode=off
    ...                                     trf_id=${trf_id}
    ...                                     cl_trf_stats=on
    ...                                     &{kwargs}


Start Traffic in UL
    [Arguments]  ${ue_id}  ${qfi_id}  ${trf_id}  ${mbps}  ${seconds}
    &{kwargs}=    create dictionary    mbps=${mbps}    pdu=2    qfi=${qfi_id}    seconds=${seconds}
    wts_ue . Start data traffic in egate    ue_id=${ue_id}
    ...                                     direction=ul
    ...                                     protocol=udp
    ...                                     ack_mode=off
    ...                                     trf_id=${trf_id}
    ...                                     cl_trf_stats=on
    ...                                     &{kwargs}
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
