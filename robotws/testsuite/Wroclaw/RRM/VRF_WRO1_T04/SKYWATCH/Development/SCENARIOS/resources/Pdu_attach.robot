*** Settings ***
Documentation    :copyright: Nokia
...              :authors: Mateusz Bilewicz
...              :contact: mateusz.bilewicz@nokia.com

*** Keywords ***
Modify Rrc Setup Cause
    [Arguments]    ${ue_id}    ${cause}
    Execute Egate Command
    ...    cmd=ue_nr_rrc_setup_param id=${ue_id} establishment_cause=${cause}


Attach And Pdu Session For Ues
    [Arguments]    ${ues}    ${pass_regex}
    FOR    ${index1}    IN RANGE    0    ${ues}
        ${pdu_index}=    Evaluate    ${index1}%${15}+${1}
        ${ue_id}=    Evaluate    ${index1}+${1}
        Execute Egate Command   cmd=set_pdu_param ue=${ue_id} pdu=${pdu_index} trf_type=internal
        Attach Ue    ue_id=${ue_id}
        Execute Egate Command And Wait For Data
        ...    cmd=ue_pdu_session_setup pdu=${pdu_index} ue=${ue_id} nwslice=1 gw=${ue_id}
        ...    pass_regexp=${pass_regex}
    END


Attach Ue With Trf Type
    [Arguments]    ${ue}    ${pdu_list}
#    ${pdu_index}=    Evaluate    ${ue}%${15}+${1}
#    ${ue_id}=    Evaluate    ${ue}+${1}
    FOR    ${pdu}    IN    @{pdu_list}
    Execute Egate Command   cmd=set_pdu_param ue=${ue} pdu=${pdu} trf_type=internal
    END
    Attach Ue    ue_id=${ue}


Attach For Ues
    [Arguments]    ${ues}
    FOR    ${index1}    IN RANGE    0    ${ues}
        ${pdu_index}=    Evaluate    ${index1}%${15}+${1}
        ${ue_id}=    Evaluate    ${index1}+${1}
        Execute Egate Command   cmd=set_pdu_param ue=${ue_id} pdu=${pdu_index} trf_type=internal
        Attach Ue    ue_id=${ue_id}
    END


Attach For NSA Ues
    [Arguments]    ${first_ue}    ${last_ue}
    FOR    ${index1}    IN RANGE    ${first_ue}-1    ${last_ue}
        ${pdu_index}=    Evaluate    ${index1}%${15}+${1}
        ${ue_id}=    Evaluate    ${index1}+${1}
        Execute Egate Command   cmd=set_pdu_param ue=${ue_id} pdu=2 trf_type=internal
        Execute Egate Command And Wait For Data
        ...    cmd=ue_attach id=${ue_id}
        ...    pass_regexp=UE${ue_id}: UE performed EPS_ATTACH
        Execute Egate Command And Wait For Data
        ...    cmd=ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=1 bearer=2 type=split_scg
        ...    pass_regexp=UE${ue_id}: Successfully reconfigured dual connectivity
    END

Pdu Session For Ues
    [Arguments]    ${ues}    ${pass_regex}
    FOR    ${index1}    IN RANGE    0    ${ues}
        ${pdu_index}=    Evaluate    ${index1}%${15}+${1}
        ${ue_id}=    Evaluate    ${index1}+${1}
        Execute Egate Command And Wait For Data
        ...    cmd=ue_pdu_session_setup pdu=${pdu_index} ue=${ue_id} nwslice=1 gw=${ue_id}
        ...    pass_regexp=${pass_regex}
    END

Deregister ${ues} UEs
    FOR    ${dereg}    IN RANGE    1    ${ues}+1
        Execute Egate Command And Wait For Data    cmd=ue_deregister id=${dereg} ue_deregister_type=switch_off
    END

