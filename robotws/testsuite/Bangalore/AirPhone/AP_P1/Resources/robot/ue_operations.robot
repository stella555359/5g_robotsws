*** Settings ***
Documentation    This contains basic UE related keywords which are needed to run the Airphone TC.
...              :author Sravani K

Library         OperatingSystem
Library         String
Library         ../../Resources/Python/measurement_id.py    WITH NAME    measurement_id
Library         taf.config.wts    WITH NAME    wts_conf
Resource        wts.robot


*** Variables ***
@{SA_Scell_Index}                0
@{NSA_Scell_Index}               8


*** Keywords ***
UE Register and Start Traffic For SA Non CA Capable UEs
    [Arguments]    ${sa_ue_list}    ${uplink_tput}=${ul_tput}    ${pdu}=3    ${csi_override}=False
    FOR    ${ue_id}    IN    @{sa_ue_list}
        Ensure UE Register Is Successful    ue_id=${ue_id}
        Ensure Set PDU Param Is Successful    ue_id=${ue_id}    pdu_id=${pdu}    trf_type=internal
        Ensure UE PDU Session Setup Is Successful    ue_id=${ue_id}    pdu_id=${pdu}    gw_id=${ue_id}    nwslice=1
        Run Keyword If    "${csi_override}" == "True"
        ...    Associate UE to testmode    id=${ue_id}    testmode=csi_override     profile_id=2    action=activate    scell=0
        Log To Console    Going To Start Traffic for SA Non CA Capable UE: ${ue_id}
        Start Traffic    ue_id=${ue_id}    dir=ul    pdu=${pdu}    protocol=udp    mbps=${uplink_tput}
        Start Traffic    ue_id=${ue_id}    dir=dl    pdu=${pdu}    protocol=udp    mbps=${uplink_tput}
    END

Register and Start Traffic For SA UEs
    [Arguments]    ${sa_ue_list}    ${uplink_tput}    ${downlink_tput}    ${csi_override}=False    ${pdu}=3
    ...    ${pass_regexp}=Initial Context Setup Successful
    ${is_list}    Evaluate    isinstance(${sa_ue_list}, list)
    ${sa_ue_list}    Run Keyword If    not ${is_list}    Create List    ${sa_ue_list}    ELSE    Set Variable    ${sa_ue_list}
    FOR    ${ue_id}    IN    @{sa_ue_list}
        Run Keyword And Ignore Error    Check pcap files in gNB
        Ensure UE Register Is Successful    ue_id=${ue_id}
        Ensure Set PDU Param Is Successful    ue_id=${ue_id}    pdu_id=${pdu}    trf_type=internal
        Ensure UE PDU Session Setup Is Successful    ue_id=${ue_id}    pdu_id=${pdu}    gw_id=${ue_id}    nwslice=1
        ...    pass_regexp=${pass_regexp}
        Run Keyword If    "${csi_override}" == "True"
        ...    Associate UE to testmode    id=${ue_id}    testmode=csi_override     profile_id=2    action=activate    scell=0
        Log To Console    Going To Start Traffic for SA UE: ${ue_id}
        Start Traffic    ue_id=${ue_id}    dir=ul    pdu=${pdu}    mbps=${uplink_tput}
        Start Traffic    ue_id=${ue_id}    dir=dl    pdu=${pdu}    mbps=${downlink_tput}
        Run Keyword And Ignore Error    Check pcap files in gNB
    END

Attach and Start Traffic For NSA UEs
    [Arguments]    ${nsa_ue_list}    ${uplink_tput}=${ul_tput}    ${downlink_tput}=${ul_tput}
    ...    ${pass_regexp}=reported successful RA    ${target_cells}=2
    FOR    ${ue_id}    IN    @{nsa_ue_list}
        UE Attach    ue_id=${ue_id}    profile_id=${profile_id}
        SGNB Addition For Bearer    ue_id=${ue_id}    target_gnb=${target_gnb}    target_cells=${target_cells}
        ...    bearer=${bearer_id}    pass_regexp=${pass_regexp}
        Log To Console    Going To Start Traffic for NSA UE: ${ue_id}
        Start Traffic    ue_id=${ue_id}    id=${bearer_id}    dir=ul    mbps=${uplink_tput}
        Start Traffic    ue_id=${ue_id}    id=${bearer_id}    dir=dl    mbps=${downlink_tput}
    END

Register For SA UEs
    [Arguments]    ${sa_ue_list}    ${pdu_id}=3
    ${is_list}    Evaluate    isinstance(${sa_ue_list}, list)
    ${sa_ue_list}    Run Keyword If    not ${is_list}    Create List    ${sa_ue_list}    ELSE    Set Variable    ${sa_ue_list}
    FOR    ${ue_id}    IN    @{sa_ue_list}
        Run Keyword And Ignore Error    Check pcap files in gNB
        Ensure UE Register Is Successful    ue_id=${ue_id}
        Ensure Set PDU Param Is Successful    ue_id=${ue_id}    pdu_id=${pdu_id}    trf_type=internal
        Ensure UE PDU Session Setup Is Successful    ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${ue_id}    nwslice=1
    END

Attach For NSA UEs
    [Arguments]    ${nsa_ue_list}    ${pass_regexp}=reported successful RA    ${target_cells}=2
    FOR    ${ue_id}    IN    @{nsa_ue_list}
        UE Attach    ue_id=${ue_id}    profile_id=${profile_id}
        SGNB Addition For Bearer    ue_id=${ue_id}    target_gnb=${target_gnb}    target_cells=${target_cells}
        ...    bearer=${bearer_id}    pass_regexp=${pass_regexp}
    END

Start Traffic for multiple NSA UEs
    [Arguments]    ${ue_list}    ${uplink_tput}=${ul_tput}    ${downlink_tput}=${ul_tput}
    ${is_list}    Evaluate    isinstance(${ue_list}, list)
    ${ue_list}    Run Keyword If    not ${is_list}    Create List    ${ue_list}    ELSE    Set Variable    ${ue_list}
    FOR    ${ue_id}    IN    @{ue_list}
        Log To Console    Going To Start Traffic for UE: ${ue_id}
        Start Traffic    ue_id=${ue_id}    id=${bearer_id}    dir=ul    mbps=${uplink_tput}
        Start Traffic    ue_id=${ue_id}    id=${bearer_id}    dir=dl    mbps=${downlink_tput}
    END

Start Traffic for multiple SA UEs
    [Arguments]    ${ue_list}    ${uplink_tput}=${ul_tput}    ${downlink_tput}=${ul_tput}    ${pdu_id}=3
    ${is_list}    Evaluate    isinstance(${ue_list}, list)
    ${ue_list}    Run Keyword If    not ${is_list}    Create List    ${ue_list}    ELSE    Set Variable    ${ue_list}
    ${is_dl_tput_list}    Evaluate    isinstance(${downlink_tput}, list) == True
    ${req_dl_tput}    Run Keyword If    ${is_dl_tput_list}    Evaluate
    ...    sum([int(str(x).encode('ascii')) for x in @{downlink_tput}])    ELSE    Set Variable    ${downlink_tput}
    FOR    ${ue_id}    IN    @{ue_list}
        Log To Console    Going To Start Traffic for UE: ${ue_id}
        Start Traffic    ue_id=${ue_id}    dir=ul    pdu=${pdu_id}    mbps=${uplink_tput}
        Start Traffic    ue_id=${ue_id}    dir=dl    pdu=${pdu_id}    mbps=${req_dl_tput}
    END

Stop Traffic and Detach SA UEs
    [Arguments]    ${sa_ue_list}    ${pdu}=3     ${pass_regexp_for_pdu_release}=rrcReconfigurationComplete
    ${is_list}    Evaluate    isinstance(${sa_ue_list}, list)
    ${sa_ue_list}    Run Keyword If    not ${is_list}    Create List    ${sa_ue_list}    ELSE    Set Variable    ${sa_ue_list}
    FOR    ${ue_id}    IN    @{sa_ue_list}
        Log To Console    Going To Stop Traffic for SA UE: ${ue_id}
        Stop UE Traffic    ue_id=${ue_id}    pdu=${pdu}    dir=ul
        Stop UE Traffic    ue_id=${ue_id}    pdu=${pdu}    dir=dl
    END
    Detach SA UEs    ${sa_ue_list}    ${pdu}     ${pass_regexp_for_pdu_release}

Detach SA UEs
    [Arguments]    ${sa_ue_list}    ${pdu}=3     ${pass_regexp_for_pdu_release}=rrcReconfigurationComplete
    FOR    ${ue_id}    IN    @{sa_ue_list}
        Log To Console    Going To release SA UE: ${ue_id}
        Ensure UE PDU Session Release Is Successful    ue_id=${ue_id}    pdu_id=${pdu}     pass_regexp=${pass_regexp_for_pdu_release}
        Ensure UE Deregister Is Successful    ue_id=${ue_id}    ue_deregister_type=switch_off    by=ue
    END

Stop Traffic and Detach NSA UEs
    [Arguments]    ${nsa_ue_list}    ${bearer_id}=2
    FOR    ${ue_id}    IN    @{nsa_ue_list}
        Log To Console    Going To Stop Traffic for NSA UE: ${ue_id}
        Stop UE Traffic    ue_id=${ue_id}
    END
    Detach NSA UEs    ${nsa_ue_list}    ${bearer_id}

Detach NSA UEs
    [Arguments]    ${nsa_ue_list}    ${bearer_id}=2
    FOR    ${ue_id}    IN    @{nsa_ue_list}
        Log To Console    Going To release NSA UE: ${ue_id}
        Release ENDC Bearer    ue_id=${ue_id}    bearer=${bearer_id}    cause=MISC_CauseMisc_unspecified
        UE Detach    ue_id=${ue_id}
    END

Trigger Simple Intrafreq XN Based SA Forward handover
    [Arguments]    ${ue_id}    ${carrier_frequency}    ${primary_cell}=1    ${sim_gnb_id}=2    ${sim_cell}=1    ${phycell_id}=50
    log to console    SA forward handover from Real gNB3 cell${primary_cell} to simulator gNB${sim_gnb_id} cell${sim_cell} ...
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=PATH SWITCH REQUEST ACK
    ...    carrier_frequency=${carrier_frequency}    srsrp_nr=10    srsrq_nr=10
    ...    phycell_id=${phycell_id}    nrsrp_nr=30    nrsrq_nr=20
    Log To Console    Validating SA forward handover...
    Validate success prints from command output    ${output}
    ...    pass_regex=*UE${ue_id}: Inter-eNB handover from ENB-3.${primary_cell} to EXT_ENB-${sim_gnb_id}.${sim_cell} performed*
    Validate success prints from command output    ${output}    pass_regex=*PATH SWITCH REQUEST ACK*
    sleep    5s   reason=To stabilise traffic

Trigger Intrafreq XN Based SA Forward handover
    [Arguments]    ${ue_id}    ${carrier_frequency}    ${primary_cell}=2    ${sim_gnb_id}=22    ${sim_cell}=1    ${phycell_id}=381
    log to console    SA forward handover from Real gNB2 cell${primary_cell} to simulator gNB${sim_gnb_id} cell${sim_cell} ...
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=PATH_SWITCH_REQUEST_ACK Received
    ...    carrier_frequency=${carrier_frequency}    srsrp_nr=10    srsrq_nr=5     ssinr_nr=10
    ...    phycell_id=${phycell_id}    nrsrp_nr=40    nrsrq_nr=40    nsinr_nr=50
    Log To Console    Validating SA forward handover...
    Validate success prints from command output    ${output}
    ...    pass_regex=*UE${ue_id}: Inter-eNB handover from EXT_ENB-2.${primary_cell} to ENB-${sim_gnb_id}.${sim_cell} performed*
    Validate success prints from command output    ${output}    pass_regex=*PATH_SWITCH_REQUEST_ACK Received*
    sleep    5s   reason=To stabilise traffic

Trigger Intrafreq XN Based NSA Forward handover
    [Arguments]    ${ue_id}    ${carrier_frequency}=636576    ${primary_cell}=1    ${sim_gnb_id}=24    ${sim_cell}=1    ${phycell_id}=67
    log to console    NSA forward handover from Real gNB2 cell${primary_cell} to simulator gNB${sim_gnb_id} cell${sim_cell} ...
        ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=Bearer-type change from MCG to SCG-split is successful
        ...    carrier_frequency=${carrier_frequency}    srsrp_nr=10    srsrq_nr=5
        ...    ssinr_nr=10    phycell_id=${phycell_id}    nrsrp_nr=40    nrsrq_nr=40    nsinr_nr=50
        Log To Console    Validating NSA forward handover...
        Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: Sending SgNB Change Confirm*
        Validate success prints from command output    ${output}    pass_regex=*Bearer-type change from MCG to SCG-split is successful*
    sleep    10s    reason=To stabilise traffic txput

Trigger Intrafreq XN Based SA Reverse handover
    [Arguments]    ${ue_id}    ${carrier_frequency}    ${sim_gnb_id}=22    ${sim_cell}=1    ${phycell_id}=51    ${primary_cell}=2    ${hist_id}=1
    ...    ${nrci}=4
    log to console    SA reverse handover from simulator gNB${sim_gnb_id} cell${sim_cell} to real gNB2 cell${primary_cell}
    Update UE History Information    id=${hist_id}    cell_type=large    nrcgi=311:489|0x0${nrci}
    ...    gnb_id=${sim_gnb_id}    time_ue_stayed_in_cell=97    action=commit    ue_enb_param_id=${ue_id}
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=UE${ue_id}: XN Handover Successfully completed at Source
    ...    carrier_frequency=${carrier_frequency}    srsrp_nr=11    srsrq_nr=11    phycell_id=${phycell_id}    nrsrp_nr=30    nrsrq_nr=30
    Log To Console    Validating SA reverse handover...
    Validate success prints from command output    ${output}
    ...    pass_regex=*UE${ue_id}: Inter-eNB handover from ENB-${sim_gnb_id}.${sim_cell} to EXT_ENB-2.${primary_cell} performed*
    Validate success prints from command output    ${output}
    ...    pass_regex=*PATH SWITCH REQUEST ACK with RAN UE NGAP ID*
    sleep    10s   reason=To stabilise traffic txput

Trigger Intrafreq XN Based NSA Reverse handover
    [Arguments]    ${ue_id}    ${carrier_frequency}=636576    ${phycell_id}=50    ${sim_gnb_id}=24    ${real_cell}=1
    log to console    NSA reverse handover from simulator gNB${sim_gnb_id} cell1 to real gNB2 cell${real_cell}
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp= Inter Sgnb Handover is successful
    ...    carrier_frequency=${carrier_frequency}    srsrp_nr=11    srsrq_nr=11    phycell_id=${phycell_id}    nrsrp_nr=30    nrsrq_nr=30
    Log To Console    Validating NSA reverse handover...
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: Sending SgNB Change Confirm*
    Validate success prints from command output    ${output}    pass_regex=*GNB-${sim_gnb_id}: UE${ue_id}: === Inter Sgnb Handover is successful*
    sleep    10s   reason=To stabilise traffic txput

Trigger Interfreq XN Based SA Forward handover
    [Arguments]    ${ue_id}    ${A2_carrier_freq}    ${A3_carrier_freq}    ${primary_cell}=2    ${sim_gnb_id}=23    ${sim_cell}=1
    ...    ${phycell_id}=382
    log to console    XN based SA forward handover from Real gNB2 cell${primary_cell} to simulator gNB${sim_gnb_id} cell${sim_cell} ...
    Trigger A2 Event measurement    ue_id=${ue_id}    pass_regexp=measurementReport
    ...    carrier_frequency=${A2_carrier_freq}    srsrp_nr=7    srsrq_nr=7
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=PATH_SWITCH_REQUEST_ACK Received
    ...    carrier_frequency=${A3_carrier_freq}    srsrp_nr=10    srsrq_nr=5    ssinr_nr=10
    ...    phycell_id=${phycell_id}    nrsrp_nr=40    nrsrq_nr=40    nsinr_nr=50
    Log To Console    Validating SA forward handover...
    Validate success prints from command output    ${output}
    ...    pass_regex=*UE${ue_id}: Inter-eNB handover from EXT_ENB-2.${primary_cell} to ENB-${sim_gnb_id}.${sim_cell} performed*
    Validate success prints from command output    ${output}    pass_regex=*PATH_SWITCH_REQUEST_ACK Received*
    sleep    10s   reason=To stabilise traffic txput

Trigger Interfreq XN Based NSA Forward handover
    [Arguments]    ${ue_id}    ${A2_carrier_freq}=636576    ${A3_carrier_freq}=629952    ${primary_cell}=1    ${sim_gnb_id}=25    ${sim_cell}=1
    ...    ${phycell_id}=69
    log to console    NSA inter-freq forward handover from Real gNB2 cell${primary_cell} to simulator gNB${sim_gnb_id} cell${sim_cell} ...
    Update UE parameters for eNB    id=${ue_id}    drx_config=off    measurement_gap=gp0:20
    ...    gap_trigger=gnb_triggered    mgta=ms0    gap_purpose=perUE
    ${output}    Trigger A2 Event measurement    ue_id=${ue_id}    pass_regexp=rrcConnectionReconfigurationComplete
    ...    carrier_frequency=${A2_carrier_freq}    srsrp_nr=30    srsrq_nr=30    rs_type=ssb
    Validate success prints from command output    ${output}    pass_regex=*gapOffset gp0 : 20*
    Update UE parameters for eNB    id=${ue_id}     measurement_gap=off
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=Bearer-type change from MCG to SCG-split is successful
    ...    carrier_frequency=${A3_carrier_freq}    srsrp_nr=10    srsrq_nr=5    ssinr_nr=10    phycell_id=${phycell_id}    nrsrp_nr=40
    ...    nrsrq_nr=40    nsinr_nr=50
    Log To Console    Validating NSA forward handover...
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: Sending SgNB Change Confirm*
    Validate success prints from command output    ${output}    pass_regex=*Bearer-type change from MCG to SCG-split is successful*
    sleep    10s   reason=To stabilise traffic txput

Trigger Interfreq XN Based SA Reverse handover
    [Arguments]    ${ue_id}    ${A2_carrier_sim_freq}    ${A3_carrier_sim_freq}    ${real_cell}=2    ${sim_gnb_id}=23    ${sim_cell}=1
    ...    ${hist_id}=1    ${nrci}=5    ${phycell_id}=51
    log to console    SA reverse handover from simulator gNB${sim_gnb_id} cell${sim_cell} to Real gNB2 cell${real_cell}...
    Update UE History Information    id=${hist_id}    cell_type=large    nrcgi=311:489|0x0${nrci}
    ...    gnb_id=${sim_gnb_id}    time_ue_stayed_in_cell=98    action=commit    ue_enb_param_id=${ue_id}
    Trigger A2 Event measurement    ue_id=${ue_id}    pass_regexp=measurementReport    carrier_frequency=${A2_carrier_sim_freq}
    ...    srsrp_nr=7    srsrq_nr=7
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=UE${ue_id}: XN Handover Successfully completed at Source
    ...    carrier_frequency=${A3_carrier_sim_freq}    srsrp_nr=11    srsrq_nr=11    phycell_id=${phycell_id}    nrsrp_nr=30    nrsrq_nr=30
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: CTRL_RACH_COMPLETE Received*
    Validate success prints from command output    ${output}
    ...    pass_regex=*UE${ue_id}: Inter-eNB handover from ENB-${sim_gnb_id}.${sim_cell} to EXT_ENB-2.${real_cell} performed*
    Validate success prints from command output    ${output}    pass_regex=*Received PATH SWITCH REQUEST from GNB-2*
    sleep    10s   reason=To stabilise traffic txput

Trigger Interfreq XN Based NSA Reverse handover
    [Arguments]    ${ue_id}    ${A2_carrier_sim_freq}=629952    ${A3_carrier_sim_freq}=636576    ${real_cell}=1    ${sim_gnb_id}=25    ${sim_cell}=1
    ...    ${hist_id}=3    ${nrci}=5    ${phycell_id}=50
    log to console    NSA reverse handover from simulator gNB${sim_gnb_id} cell${sim_cell} to Real gNB2 cell${real_cell}...
    Update UE History Information     id=${hist_id}    cell_type=large    nrcgi=311:489|0x0${nrci}
    ...    gnb_id=${sim_gnb_id}    time_ue_stayed_in_cell=98    action=commit    ue_enb_param_id=${ue_id}
    Update UE parameters for eNB    id=${ue_id}    drx_config=off    measurement_gap=gp0:20
    ...    gap_trigger=gnb_triggered    mgta=ms0    gap_purpose=perUE
    ${output}    Trigger A2 Event measurement    ue_id=${ue_id}    pass_regexp=ReconfigurationComplete    carrier_frequency=${A2_carrier_sim_freq}
    ...    srsrp_nr=7    srsrq_nr=7    rs_type=ssb
    Validate success prints from command output    ${output}    pass_regex=*gapOffset 0*
    Validate success prints from command output    ${output}    pass_regex=*mgrp ms20*
    Update UE parameters for eNB    id=${ue_id}     measurement_gap=off
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=Inter Sgnb Handover is successful
    ...    carrier_frequency=${A3_carrier_sim_freq}     srsrp_nr=11    srsrq_nr=11    phycell_id=${phycell_id}    nrsrp_nr=30    nrsrq_nr=30
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: === Inter Sgnb Handover is successful*
    sleep    10s   reason=To stabilise traffic txput

Trigger Intrafreq NG Based SA Forward handover
    [Arguments]    ${ue_id}    ${carrier_frequency}=522270    ${primary_cell}=2    ${sim_gnb_id}=22    ${sim_cell}=1    ${phycell_id}=381
    log to console    SA forward handover from Real gNB2 cell${primary_cell} to simulator gNB${sim_gnb_id} cell${sim_cell} ...
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=Downlink packets from external network dropped by UPF
    ...    carrier_frequency=${carrier_frequency}    srsrp_nr=10    srsrq_nr=5     ssinr_nr=10
    ...    phycell_id=${phycell_id}    nrsrp_nr=40    nrsrq_nr=40    nsinr_nr=50
    Log To Console    Validating SA forward handover...
    Validate success prints from command output    ${output}
    ...    pass_regex=*UE${ue_id}: Inter-eNB handover from EXT_ENB-2.${primary_cell} to ENB-${sim_gnb_id}.${sim_cell} performed*
    Validate NG based handover prints from command output    ${output}
    sleep    5s   reason=To stabilise traffic

Trigger Intrafreq NG Based NSA Forward handover
    [Arguments]    ${ue_id}    ${carrier_frequency}=636576    ${primary_cell}=1    ${sim_gnb_id}=24    ${sim_cell}=1    ${phycell_id}=67
    log to console    NSA forward handover from Real gNB cell${primary_cell} to simulator gNB${sim_gnb_id} cell${sim_cell} ...
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=Bearer-type change from MCG to SCG-split is successful
    ...    carrier_frequency=${carrier_frequency}    srsrp_nr=10    srsrq_nr=5    ssinr_nr=10    phycell_id=${phycell_id}    nrsrp_nr=40
    ...    nrsrq_nr=40    nsinr_nr=50
    Log To Console    Validating NSA forward handover...
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: Sending SgNB Change Confirm*
    Validate success prints from command output    ${output}    pass_regex=*Bearer-type change from MCG to SCG-split is successful*
    Validate success prints from command output    ${output}    pass_regex=*Source-SgNB global ran id:*
    Validate success prints from command output    ${output}    pass_regex=*Target-SgNB global ran id:*
    sleep    5s    reason=To stabilise traffic txput

Trigger Intrafreq NG Based SA Reverse handover
    [Arguments]    ${ue_id}    ${carrier_frequency}=522270    ${sim_gnb_id}=22    ${real_cell}=2    ${sim_cell}=1    ${phycell_id}=51
    ...    ${hist_id}=1    ${nrci}=4
    log to console    intra-freq SA reverse handover from simulator gNB${sim_gnb_id} cell${sim_cell} to real gNB2 cell${real_cell}
    Update UE History Information    id=${hist_id}    cell_type=large    nrcgi=311:489|0x0${nrci}
    ...    gnb_id=${sim_gnb_id}    time_ue_stayed_in_cell=97    action=commit    ue_enb_param_id=${ue_id}
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=Inter-eNB handover
    ...    carrier_frequency=${carrier_frequency}    srsrp_nr=11    srsrq_nr=11    phycell_id=${phycell_id}    nrsrp_nr=30    nrsrq_nr=30
    Log To Console    Validating NG based SA reverse handover...
    Validate success prints from command output    ${output}    pass_regex=*NgAPHANDOVER_REQUEST*
    Validate success prints from command output    ${output}    pass_regex=*HANDOVER REQUIRED: gNB=${sim_gnb_id}, AMF_UE_NGAP_ID*
    Validate success prints from command output    ${output}    pass_regex=*HANDOVER REQUIRED: gNB=${sim_gnb_id}, RAN_UE_NGAP_ID=*
    Validate success prints from command output    ${output}
    ...    pass_regex=*UE${ue_id}: Inter-eNB handover from ENB-${sim_gnb_id}.${sim_cell} to EXT_ENB-2.${real_cell} performed*
    sleep    10s   reason=To stabilise traffic txput

Trigger Intrafreq NG Based NSA Reverse handover
    [Arguments]    ${ue_id}     ${carrier_frequency}=636576    ${sim_gnb_id}=24    ${real_cell}=1    ${sim_cell}=1    ${phycell_id}=50
    ...    ${hist_id}=3    ${nrci}=3
    log to console    intra-freq NSA reverse handover from simulator gNB${sim_gnb_id} cell${sim_cell} to real gNB cell${real_cell}
    Update UE History Information    id=${hist_id}    cell_type=large    nrcgi=311:489|0x0${nrci}
    ...    gnb_id=${sim_gnb_id}    time_ue_stayed_in_cell=97    action=commit    ue_enb_param_id=${ue_id}
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=Inter Sgnb Handover is successful
    ...    carrier_frequency=${carrier_frequency}    srsrp_nr=11    srsrq_nr=11    phycell_id=${phycell_id}    nrsrp_nr=30    nrsrq_nr=30
    Log To Console    Validating NSA reverse handover...
    Validate success prints from command output    ${output}    pass_regex=*CTRL_ADD_MOD_RB received for UeId ${ue_id}*
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: Sending SgNB Change Confirm*
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: === Inter Sgnb Handover is successful ===*
    sleep    10s   reason=To stabilise traffic txput

Trigger Interfreq NG Based SA Forward handover
    [Arguments]    ${ue_id}    ${A2_carrier_freq}=522270    ${A3_carrier_freq}=505230    ${primary_cell}=2    ${sim_gnb_id}=23    ${sim_cell}=1
    ...    ${phycell_id}=382
    log to console    inter-freq SA forward handover from Real gNB2 cell${primary_cell} to simulator gNB${sim_gnb_id} cell${sim_cell} ...
    Trigger A2 Event measurement    ue_id=${ue_id}    pass_regexp=measurementReport
    ...    carrier_frequency=${A2_carrier_freq}    srsrp_nr=7    srsrq_nr=7
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=Downlink packets from external network dropped by UPF
    ...    carrier_frequency=${A3_carrier_freq}    srsrp_nr=10    srsrq_nr=5    ssinr_nr=10
    ...    phycell_id=${phycell_id}    nrsrp_nr=40    nrsrq_nr=40    nsinr_nr=50
    Log To Console    Validating SA forward handover...
    Validate success prints from command output    ${output}
    ...    pass_regex=*UE${ue_id}: Inter-eNB handover from EXT_ENB-2.${primary_cell} to ENB-${sim_gnb_id}.${sim_cell} performed*
    Validate NG based handover prints from command output    ${output}
    sleep    10s   reason=To stabilise traffic txput

Trigger Interfreq NG Based NSA Forward handover
    [Arguments]    ${ue_id}    ${A2_carrier_freq}=636576    ${A3_carrier_freq}=629952    ${primary_cell}=1    ${sim_gnb_id}=25    ${sim_cell}=1
    ...    ${phycell_id}=69
    log to console    inter-freq NSA forward handover from Real gNB2 cell${primary_cell} to simulator gNB${sim_gnb_id} cell${sim_cell} ...
    Update UE parameters for eNB    id=${ue_id}    drx_config=off    measurement_gap=gp0:20
    ...    gap_trigger=gnb_triggered    mgta=ms0    gap_purpose=perUE
    ${output}    Trigger A2 Event measurement    ue_id=${ue_id}    pass_regexp=rrcConnectionReconfigurationComplete
    ...    carrier_frequency=${A2_carrier_freq}    srsrp_nr=30    srsrq_nr=30    rs_type=ssb
    Validate success prints from command output    ${output}    pass_regex=*gapOffset gp0 : 20*
    Update UE parameters for eNB    id=${ue_id}     measurement_gap=off
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=Bearer-type change from MCG to SCG-split is successful
    ...    carrier_frequency=${A3_carrier_freq}    srsrp_nr=10    srsrq_nr=5    ssinr_nr=10    phycell_id=${phycell_id}    nrsrp_nr=40
    ...    nrsrq_nr=40    nsinr_nr=50
    Log To Console    Validating NSA forward handover...
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: Sending SgNB Change Confirm*
    Validate success prints from command output    ${output}    pass_regex=*Bearer-type change from MCG to SCG-split is successful*
    sleep    10s   reason=To stabilise traffic txput

Trigger Interfreq NG Based SA Reverse handover
    [Arguments]    ${ue_id}    ${A2_carrier_sim_freq}=505230    ${A3_carrier_sim_freq}=522270    ${real_cell}=2    ${sim_gnb_id}=23
    ...    ${sim_cell}=1    ${hist_id}=1    ${nrci}=5    ${phycell_id}=51
    log to console    inter-freq SA reverse handover from simulator gNB${sim_gnb_id} cell${sim_cell} to Real gNB2 cell${real_cell}...
    Update UE History Information    id=${hist_id}    cell_type=large    nrcgi=311:489|0x0${nrci}
    ...    gnb_id=${sim_gnb_id}    time_ue_stayed_in_cell=98    action=commit    ue_enb_param_id=${ue_id}
    Trigger A2 Event measurement    ue_id=${ue_id}    pass_regexp=measurementReport    carrier_frequency=${A2_carrier_sim_freq}
    ...    srsrp_nr=7    srsrq_nr=7
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=Inter-eNB handover
    ...    carrier_frequency=${A3_carrier_sim_freq}    srsrp_nr=11    srsrq_nr=11    phycell_id=${phycell_id}    nrsrp_nr=30    nrsrq_nr=30
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: CTRL_RACH_COMPLETE Received*
    Validate success prints from command output    ${output}
    ...    pass_regex=*UE${ue_id}: Inter-eNB handover from ENB-${sim_gnb_id}.${sim_cell} to EXT_ENB-2.${real_cell} performed*
    Validate success prints from command output    ${output}    pass_regex=*HANDOVER REQUIRED: gNB=${sim_gnb_id}, AMF_UE_NGAP_ID*
    Validate success prints from command output    ${output}    pass_regex=*HANDOVER REQUIRED: gNB=${sim_gnb_id}, RAN_UE_NGAP_ID=*
    sleep    10s   reason=To stabilise traffic txput

Trigger Interfreq NG Based NSA Reverse handover
    [Arguments]    ${ue_id}    ${A2_carrier_freq}=124570    ${A3_carrier_freq}=636576    ${real_cell}=1    ${sim_gnb_id}=25
    ...    ${sim_cell}=1    ${hist_id}=3    ${nrci}=5    ${phycell_id}=50
    log to console    inter-freq NSA reverse handover from simulator gNB${sim_gnb_id} cell${sim_cell} to Real gNB cell${real_cell}...
    Update UE History Information     id=${hist_id}    cell_type=large    nrcgi=311:489|0x0${nrci}
    ...    gnb_id=${sim_gnb_id}    time_ue_stayed_in_cell=97    action=commit    ue_enb_param_id=${ue_id}
    Update UE parameters for eNB    id=${ue_id}     drx_config=off    measurement_gap=gp0:20     gap_trigger=gnb_triggered
    ...    mgta=ms0    gap_purpose=perUE
    ${output}    Trigger A2 Event measurement    ue_id=${ue_id}    pass_regexp=ReconfigurationComplete
    ...    carrier_frequency=${A2_carrier_freq}    srsrp_nr=7    srsrq_nr=7
    Validate success prints from command output    ${output}    pass_regex=*gapOffset 0*
    Validate success prints from command output    ${output}    pass_regex=*mgrp ms20*
    Update UE parameters for eNB    id=${ue_id}     measurement_gap=off
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=Inter Sgnb Handover is successful
    ...    carrier_frequency=${A3_carrier_freq}     srsrp_nr=11    srsrq_nr=11    phycell_id=${phycell_id}    nrsrp_nr=30    nrsrq_nr=30
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: === Inter Sgnb Handover is successful*
    sleep    10s   reason=To stabilise traffic txput

Trigger InterRAT SA Forward Handover
    [Arguments]    ${ue_id}    ${A2_carrier_freq}    ${phycell_id}=50    ${primary_cell}=2    ${sim_enb_id}=3    ${sim_cell}=2
    ...    ${B2_carrier_freq}=1400    ${sim_phycell_id}=11
    log to console    InterRAT SA forward handover from 5GC(RealgNB-2.${primary_cell}) to LTE(SimENB-${sim_enb_id}.${sim_cell})...
    Trigger A2 Event measurement    ue_id=${ue_id}    pass_regexp=measurementReport    carrier_frequency=${A2_carrier_freq}    srsrp_nr=11
    ...    srsrq_nr=11   srs_result=0:11:11:0    phycell_id=${phycell_id}    nrsrp_nr=30    nrsrq_nr=30    rs_type=ssb
    ...    index=0    nrs_result=30:30:0
    ${output}    Trigger B2 Event measurement    ue_id=${ue_id}    pass_regexp=IRAT Handover from NR to EUTRA completed
    ...    carrier_frequency=${B2_carrier_freq}    eutra=True   srsrp_nr=11    srsrq_nr=11    srs_result=0:11:11:0
    ...    phycell_id=${sim_phycell_id}    nrsrp_nr=30    nrsrq_nr=30    rs_type=ssb    index=0    nrs_result=30:30:0
    Validate success prints from command output    ${output}
    ...    pass_regex=*UE${ue_id}: Successful handover from EXT_ENB-2.${primary_cell} to ENB-${sim_enb_id}.${sim_cell}*
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: IRAT Handover from NR to EUTRA completed*
    sleep    10s   reason=To stabilise traffic txput

Trigger InterRAT SA Reverse Handover
    [Arguments]    ${ue_id}    ${primary_cell}=2    ${sim_enb_id}=3    ${sim_cell}=2
    log to console    InterRAT SA reverse handover from LTE(SimENB-${sim_enb_id}.${sim_cell}) to 5GC(RealgNB-2.${primary_cell})...
    ${output}    Trigger eNB initiated inter-rat handover to 5g    ue_id=${ue_id}    target_gnb=2    target_cell=${primary_cell}
    ...    plmn=311:489    pass_regexp=Inter-eNB handover
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: Received IratFromEutraToNrHo with valid NAS Container*
    Validate success prints from command output    ${output}
    ...    pass_regex=*UE${ue_id}: Inter-eNB handover from ENB-${sim_enb_id}.${sim_cell} to EXT_ENB-2.${primary_cell} performed*
    sleep    10s   reason=To stabilise traffic txput

Trigger Intra gNB Interfreq SA Forward HO
    [Arguments]    ${ue_id}    ${A2_freq}=636576    ${A3_freq}=649920    ${primary_cell}=1    ${secondary_cell}=2
    ...    ${pcell_id}=50    ${scell_id}=51
    log to console    Intra gNB Interfreq SA forward HO from cell${primary_cell} to cell${secondary_cell} ...
    Trigger A2 Event measurement    ue_id=${ue_id}    pass_regexp=measurementReport
    ...    carrier_frequency=${A2_freq}    srsrp_nr=7    srsrq_nr=7    phycell_id=${pcell_id}
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=rrcReconfigurationComplete
    ...    carrier_frequency=${A3_freq}    srsrp_nr=10    srsrq_nr=5    ssinr_nr=10
    ...    phycell_id=${scell_id}    nrsrp_nr=45    nrsrq_nr=45    nsinr_nr=50
    Log To Console    Validating SA forward handover...
    Validate success prints from command output    ${output}
    ...    pass_regex=*UE${ue_id}: reconfigurationWithSync with physCellId ${scell_id} is present in masterCellGroup*
    Validate success prints from command output    ${output}    pass_regex=*Handover will be triggered using CBRA*
    Validate success prints from command output    ${output}
    ...    pass_regex=*UE${ue_id}: Intra-eNB handover from EXT_ENB-2.${primary_cell} to EXT_ENB-2.${secondary_cell} performed*
    sleep    10s   reason=To stabilise traffic txput

Trigger Intra gNB Interfreq SA Reverse HO
    [Arguments]    ${ue_id}    ${A2_freq}=649920    ${A3_freq}=636576    ${primary_cell}=2    ${secondary_cell}=1
    ...    ${pcell_id}=51    ${scell_id}=50
    log to console    Intra gNB Interfreq SA reverse HO from cell${primary_cell} to cell${secondary_cell} ...
    Trigger A2 Event measurement    ue_id=${ue_id}    pass_regexp=measurementReport
    ...    carrier_frequency=${A2_freq}    srsrp_nr=7    srsrq_nr=7    phycell_id=${pcell_id}
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=rrcReconfigurationComplete
    ...    carrier_frequency=${A3_freq}    srsrp_nr=10    srsrq_nr=5    ssinr_nr=10
    ...    phycell_id=${scell_id}    nrsrp_nr=45    nrsrq_nr=45    nsinr_nr=50
    Log To Console    Validating SA reverse handover...
    Validate success prints from command output    ${output}
    ...    pass_regex=*UE${ue_id}: reconfigurationWithSync with physCellId ${scell_id} is present in masterCellGroup*
    Validate success prints from command output    ${output}    pass_regex=*Handover will be triggered using CBRA*
    Validate success prints from command output    ${output}
    ...    pass_regex=*UE${ue_id}: Intra-eNB handover from EXT_ENB-2.${primary_cell} to EXT_ENB-2.${secondary_cell} performed*
    sleep    10s   reason=To stabilise traffic txput

Establish X2 link for simulator Gnb
    [Arguments]     ${enb_id}     ${simulator_gnb_list}
    FOR     ${gnb_id}     IN    @{simulator_gnb_list}
        Establish X2 link    enb_id=${enb_id}    gnb_id=${gnb_id}
    END

Update CSI parameters
    [Arguments]    ${profile_id}
    ${output}    Update CSI Override parameters    profile_id=${profile_id}   cqi=1    cqi_mode=fixed
    ...    cqi_min=0    cqi_max=15

Enable UE to testmode
    [Arguments]    ${id}    ${profile_id}    ${scell_index}    ${pass_regex}    ${testmode}=csi_override    ${action}=activate
    ${output}    Associate UE to testmode    id=${id}    testmode=${testmode}
    ...    profile_id=${profile_id}    pass_regex=${pass_regex}    action=${action}    scell=${scell_index}

Perform UL mimo SRS Beam profile mode and associate UE to testmode
    [Arguments]    ${ue_id}    ${profile_id}    ${testmode}=ul_mimo_srs_beam_pos    ${action}=activate    &{kwargs}
    Create UL mimo SRS Beam profile mode    ${profile_id}    &{kwargs}
    Associate UE to testmode    id=${ue_id}    testmode=${testmode}    profile_id=${profile_id}    action=${action}

Perform Beam control profile mode and associate UE to testmode
    [Arguments]    ${ue_id}    ${profile_id}    ${ssbeam_bestbeam}    ${testmode}=beam_control    ${action}=activate
    ...    ${beamaction}=attach    &{kwargs}
    Create Beam Control profile mode    profile_id=${profile_id}    ssbeam_bestbeam=${ssbeam_bestbeam}    &{kwargs}
    Associate UE to testmode    id=${ue_id}    testmode=${testmode}    profile_id=${profile_id}    action=${action}    beamaction=${beamaction}

Perform Beam action switch
    [Arguments]    ${ue_list}    ${switch_profile_list}    ${testmode}=beam_control    ${action}=activate    ${beamaction}=switch    ${scell}=0
    FOR    ${ue_id}    ${profile_id}    IN ZIP    ${ue_list}    ${switch_profile_list}
        Log To Console    Performing Beamswitch for UE: ${ue_id}
        Associate UE to testmode    id=${ue_id}    testmode=${testmode}    profile_id=${profile_id}    action=${action}
        ...    beamaction=${beamaction}    scell=${scell}
    END

Perform Beam action recovery
    [Arguments]    ${ue_list}    ${recovery_profile_list}    ${testmode}=beam_control    ${action}=activate    ${beamaction}=recovery    ${scell}=0
    FOR    ${ue_id}    ${profile_id}    IN ZIP    ${ue_list}    ${recovery_profile_list}
        Log To Console    Performing Beamrecovery for UE: ${ue_id}
        Associate UE to testmode    id=${ue_id}    testmode=${testmode}    profile_id=${profile_id}    action=${action}
        ...    beamaction=${beamaction}    scell=${scell}
        sleep    2s
        Log To Console    Validating beamrecovery...
        ${IdofUE}    Evaluate    ${ue_id}-1
        Run keyword And Continue On Failure
        ...    Egate console log verification    \\[UeId\\:${IdofUE}\\,BwpId\\:1\\, pcid\\:50\\, scellIdx\\:${scell}\\] configure_0_1
    END

Get measurement id
    [Arguments]    ${ue_id}    ${event}    ${carrier_frequency}    ${eutra}=False
    ${meas_config_output}    Get Measurement Configuration    ${ue_id}    meas_obj_type=nr
    ${meas_id}   measurement_id.get_measurement_id_based_on_carrier_freq_and_event    ${meas_config_output}    ${ue_id}
    ...    ${carrier_frequency}    ${event}    ${eutra}
    [Return]    ${meas_id}

Trigger A2 Event measurement
    [Arguments]    ${ue_id}    ${pass_regexp}=measurementReport    ${carrier_frequency}=127450    &{kwargs}
    ${meas_id}    Get measurement id    ue_id=${ue_id}    event=EventA2    carrier_frequency=${carrier_frequency}
    log to console    Triggering A2 Event measurement ...
    ${output}    Send Ue Measurements    ue_id=${ue_id}    meas_id=${meas_id}    pass_regexp=${pass_regexp}
    ...    event=A2    &{kwargs}
    [Return]    ${output}

Trigger A3 Event measurement
    [Arguments]    ${ue_id}    ${pass_regexp}=measurementReport    ${carrier_frequency}=127450    &{kwargs}
    ${meas_id}    Get measurement id    ue_id=${ue_id}    event=EventA3    carrier_frequency=${carrier_frequency}
    log to console    Triggering A3 Event measurement ...
    ${output}    Send Ue Measurements    ue_id=${ue_id}    meas_id=${meas_id}    pass_regexp=${pass_regexp}
    ...    event=A3     &{kwargs}
    [Return]    ${output}

Trigger B2 Event measurement
    [Arguments]    ${ue_id}    ${pass_regexp}=measurementReport    ${carrier_frequency}=${EMPTY}    ${eutra}=True   &{kwargs}
    ${meas_id}    Get measurement id    ue_id=${ue_id}    event=EventB2    carrier_frequency=${carrier_frequency}    eutra=${eutra}
    log to console    Triggering B2 Event measurement ...
    ${output}    Send Ue Measurements    ue_id=${ue_id}    meas_id=${meas_id}    pass_regexp=${pass_regexp}
    ...    event=B2     &{kwargs}
    [Return]    ${output}

Validate success prints from command output
    [Arguments]    ${egate_console_output}    ${pass_regex}
    ${match}    string.Get Lines Matching Pattern    ${egate_console_output}    ${pass_regex}
    log to console    ${match}
    should not be empty    ${match}    msg=Unable to find ${pass_regex} in console output

Trigger A1 Event measurement
    [Arguments]    ${ue_id}    ${pass_regexp}=measurementReport    ${carrier_frequency}=${EMPTY}    &{kwargs}
    ${meas_id}    Get measurement id    ue_id=${ue_id}    event=EventA1    carrier_frequency=${carrier_frequency}
    log to console    Triggering A1 Event measurement ...
    ${output}    Send Ue Measurements    ue_id=${ue_id}    meas_id=${meas_id}    pass_regexp=${pass_regexp}
    ...    event=A1     &{kwargs}
    [Return]    ${output}

Average Throughput Should Be as Expected
    [Arguments]    ${bearer_stats_tput}    ${expected_tput}
    ${exp_tput_bytes}    Evaluate    int(${expected_tput} * 1000000)
    ${result_stats}    Evaluate    int(${exp_tput_bytes} * 1.2) > int(${bearer_stats_tput}[0]) > int(${exp_tput_bytes} * 0.9)
    Run Keyword If    not ${result_stats}    FAIL
    ...    msg = Total TPut is not as expected. Expected: ${exp_tput_bytes} and Achieved: ${bearer_stats_tput}[0]

Get Average Throughput from Bearer Stats For SA
    [Arguments]    ${ue_id}    ${dir}    ${pdu_id}
    ${bearer_stats}    Capture Bearer Stats    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    dir=${dir}
    ${output}         Get Regexp Matches    ${bearer_stats}    Average data rate +(\\d+)    1
    [Return]    ${output}

Get Average Throughput from Bearer Stats For NSA
    [Arguments]    ${ue_id}    ${dir}    ${bearer_id}=2
    ${bearer_stats}    Capture Bearer Stats    ue_id=${ue_id}    id=${bearer_id}    dir=${dir}
    ${output}         Get Regexp Matches    ${bearer_stats}    Average data rate +(\\d+)    1
    [Return]    ${output}

Validate bearer stats output
    [Arguments]    ${ue_id}    ${expected_dl_tput}    ${expected_ul_tput}    ${mode}    ${pdu_id}=3
    ${expected_dl_value}    Evaluate    isinstance(${expected_dl_tput}, list) == True
    ${expected_total_dl_tput}    Run Keyword If    ${expected_dl_value}    Evaluate
    ...    sum([int(str(x).encode('ascii')) for x in @{expected_dl_tput}])    ELSE    Set Variable    ${expected_dl_tput}
    ${dl_tput}    run keyword if    '${mode}' == 'SA'
    ...    Get Average Throughput from Bearer Stats For SA    ue_id=${ue_id}    dir=dl    pdu_id=${pdu_id}
    ...    ELSE    Get Average Throughput from Bearer Stats For NSA    ue_id=${ue_id}    dir=dl
    Average Throughput Should Be as Expected     ${dl_tput}    ${expected_total_dl_tput}
    ${ul_tput}    run keyword if    '${mode}' == 'SA'
    ...    Get Average Throughput from Bearer Stats For SA    ue_id=${ue_id}    dir=ul    pdu_id=${pdu_id}
    ...    ELSE    Get Average Throughput from Bearer Stats For NSA    ue_id=${ue_id}    dir=ul
    Run keyword And Continue On Failure    Average Throughput Should Be as Expected     ${ul_tput}    ${expected_ul_tput}

Update UE History Information
    [Arguments]    ${id}    ${cell_type}    ${nrcgi}    ${gnb_id}    ${time_ue_stayed_in_cell}    ${action}    ${ue_enb_param_id}
    Add NGRAN item to UE History Information list    id=${id}    cell_type=${cell_type}    nrcgi=${nrcgi}
    ...    gnb_id=${gnb_id}    time_ue_stayed_in_cell=${time_ue_stayed_in_cell}
    Update UE History Information lists    ${id}    ${action}
    Update UE parameters for eNB    id=${ue_enb_param_id}    ue_history_list=${id}

Validate throughput from bearer stats
    [Arguments]    ${ue_id}     ${expected_dl_tput}    ${expected_ul_tput}    ${mode}    ${pdu_id}=3
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    3min    30s
    ...    Validate bearer stats output    ue_id=${ue_id}    expected_dl_tput=${expected_dl_tput}
    ...    expected_ul_tput=${expected_ul_tput}    mode=${mode}    pdu_id=${pdu_id}

Validate NG based handover prints from command output
    [Arguments]    ${command_output}=${EMPTY}
    Validate success prints from command output    ${command_output}
    ...    pass_regex=*by UPF from source gNb through the forwarding tunnel*
    Validate success prints from command output    ${command_output}
    ...    pass_regex=*Forwarded by UPF to target gNb upon reception at forwarding tunnel*
    Validate success prints from command output    ${command_output}
    ...    pass_regex=*Downlink packets from external network dropped by UPF after end marker was sent to source gNb*

Validate throughput from bearer stats for all UEs
    [Arguments]    ${ue_list}    ${expected_dl_tput}    ${expected_ul_tput}    ${mode}    ${pdu_id}=3
    FOR    ${ue_id}    IN    @{ue_list}
        Validate bearer stats output    ue_id=${ue_id}    expected_dl_tput=${expected_dl_tput}
        ...    expected_ul_tput=${expected_ul_tput}    mode=${mode}    pdu_id=${pdu_id}
    END

Validate Bearer Stats for multiple UEs
    [Arguments]    ${ue_list}    ${expected_dl_tput}    ${expected_ul_tput}    ${mode}    ${pdu_id}=3
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    3min    30s
    ...    Validate throughput from bearer stats for all UEs    ${ue_list}    ${expected_dl_tput}
    ...    ${expected_ul_tput}    ${mode}    ${pdu_id}

Validate throughput from bearer stats for SA and NSA UEs
    [Arguments]    ${sa_ue_list}    ${nsa_ue_id}    ${dl_tput}=25    ${ul_tput}=10
    Validate Bearer Stats for multiple UEs    ue_list=${SA_UE_List}    expected_dl_tput=${dl_tput}
    ...    expected_ul_tput=${ul_tput}    mode=SA
    Validate Bearer Stats for multiple UEs    ue_list=${NSA_UE_ID}    expected_dl_tput=${dl_tput}
    ...    expected_ul_tput=${ul_tput}    mode=NSA

Get Throughput from all cells
    [Arguments]     ${ue_id}     ${scell}    ${type}=pdsch
    @{cell_tput}    Create List
    ${ue_stats_output}    Capture UE Stats    ue_id=${ue_id}    type=${type}    scell=primary,secondary
    FOR    ${scell}    IN    @{scell}
        ${tput}    Get Regexp Matches    ${ue_stats_output}
        ...    CellIndex-${scell}\\s*(?:(?:(?:\\d+\\.\\d+|\\d+)\\s(?:Mbps|Kbps)?\\s*){3}(?:((?:\\d+\\.\\d+|\\d+)\\s(?:Mbps|Kbps)?)\\s*))*    1
        ${tput}    Evaluate    '${tput}[-1]'.strip()
        ${tput_average}    Run Keyword If    'Mbps' in '${tput}'    Evaluate    ['${tput}'.split(' Mbps')[0]]
        ...    ELSE IF    'Kbps' in '${tput}'    Evaluate    ['{:.4f}'.format(float(('${tput}'.split(' Kbps'))[0])/1000)]
        ...    ELSE    Fail    Average Tput for scell ${scell} is ${tput} which is not expected
        ${tput_average}    Evaluate    ${tput_average}[-1]
        Log To Console    Cell ${scell} Tput : ${tput_average}
        Append To List    ${cell_tput}    ${tput_average}
    END
    ${total_tput}    Evaluate    float(sum(${cell_tput}))
    [Return]    ${total_tput}

Average UE stats throughput Should Be as Expected
    [Arguments]    ${cell_total}    ${expected_tput}
    ${result_cell}    Evaluate    int(${expected_tput} * 1.1) >= int(${cell_total}) >= int(${expected_tput} * 0.9)
    Run Keyword If    not ${result_cell}    FAIL
    ...    msg = Total TPut is not as expected. cell: ${result_cell}

Validate throughput from UE stats for all UEs
    [Arguments]    ${ue_list}    ${expected_dl_tput}    ${expected_ul_tput}    ${scell}
    FOR    ${ue_id}    IN    @{ue_list}
        Log To Console    Going To Check UE stats for  UE: ${ue_id}
        ${dl_tput}    Get Throughput from all cells    ${ue_id}    scell=${scell}    type=pdsch
        ${ul_tput}    Get Throughput from all cells    ${ue_id}    scell=${scell}    type=pusch
        Average UE stats throughput Should Be as Expected    ${dl_tput}    ${expected_dl_tput}
        Average UE stats throughput Should Be as Expected    ${ul_tput}    ${expected_ul_tput}
    END

Validate UE stats for multiple UEs
    [Arguments]    ${ue_list}    ${expected_dl_tput}    ${expected_ul_tput}    ${scell}
    ${is_list}    Evaluate    isinstance(${ue_list}, list)
    ${ue_list}    Run Keyword If    not ${is_list}    Create List    ${ue_list}    ELSE    Set Variable    ${ue_list}
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    3min    30s
    ...    Validate throughput from UE stats for all UEs    ${ue_list}    ${expected_dl_tput}
    ...    ${expected_ul_tput}    ${scell}

Validate throughput from UE stats for NON CA SA and NSA UEs
    [Arguments]    ${sa_ue_list}    ${nsa_ue_id}    ${dl_tput}=20    ${ul_tput}=10
    Validate UE stats for multiple UEs    ue_list=${sa_ue_list}    expected_dl_tput=${dl_tput}
    ...    expected_ul_tput=${ul_tput}    scell=${SA_Scell_Index}
    Validate UE stats for multiple UEs    ue_list=${nsa_ue_id}    expected_dl_tput=${dl_tput}
    ...    expected_ul_tput=${ul_tput}    scell=${NSA_Scell_Index}

Collect and Validate Gnb PM counters
    [Arguments]    ${SA_UE_List}=${EMPTY}    ${NSA_UE_List}=${EMPTY}    ${target_dir}=${testlog_path}
    ...    ${name}=gnb_pm_counters    ${counters_dir}=${testlog_path}
    log To Console    Sleeping for 5min before collecting PM Counters ...
    sleep    300s
    Run Keyword And Ignore Error    Collect Gnb PM Counters    target_dir=${target_dir}    name=${name}
    Run Keyword And Ignore Error    Validate Gnb PM Counters    sa_ue_list=${SA_UE_List}
    ...    counters=${Counter_List}    counters_dir=${counters_dir}    name=${name}    nsa_ue_list=${NSA_UE_List}

Update WTS config file for NSA MUEs
    [Arguments]    ${ue_id}=13    ${no_of_ues}=${9}
    ${nsa_ue_ids_list}=  utilities.generate_list_of_ue_ids    start_ue_id=${ue_id}
    ...    number_of_ues=${no_of_ues}
    ${pdn}=      wts_conf.get_parameter     set    PDN_IP102
    ${imsi}=     wts_conf.get_parameter     set_ue simulated id=${${ue_id}-${1}}  imsi
    FOR    ${ue}    IN    @{nsa_ue_ids_list}
        ${new_ip}    utilities.obtain_new_ip    ${ue}    ${pdn}
        ${new_imsi}    utilities.obtain_new_imsi    ${ue}    ${imsi}
        wts_conf.clone_and_modify    set_ue simulated id=${ue-1}      id=${ue} imsi=${new_imsi}  after  ue_param id=${ue-1}
        wts_conf.clone_and_modify    ue_param id=${ue-1}              id=${ue}                   after  set_ue simulated id=${ue}
        wts_conf.clone_and_modify    set_bearer id=2 ue=${ue-1}       ue=${ue} ip=${new_ip}      before  uec_param id=1
    END

Update WTS config file for SA MUEs
    [Arguments]    ${ue_id}    ${no_of_ues}
    ${sa_ue_ids_list}=  utilities.generate_list_of_ue_ids    start_ue_id=${ue_id}
    ...    number_of_ues=${no_of_ues}
    ${ue_nat_ip}=     wts_conf.get_parameter     set_pdu_gateway id=1  ue_nat_ip
    ${suci}=     wts_conf.get_parameter    set_ue simulated id=1    suci
    FOR  ${ue}  IN  @{sa_ue_ids_list}
        ${new_ip}=  utilities.obtain_new_ip  ${ue}  ${ue_nat_ip}
        ${new_suci}=  utilities.obtain_new_suci    ${ue}    ${suci}
        wts_conf.clone_and_modify    set_ue simulated id=1      id=${ue} suci=${new_suci}         after   ue_param id=${ue-1}
        wts_conf.clone_and_modify    ue_param id=1              id=${ue}                          after   set_ue simulated id=${ue}
        wts_conf.clone_and_modify    set_pdu_gateway id=1       id=${ue} ue_nat_ip=${new_ip}      after   set_pdu_gateway id=${ue-1}
    END

Attach Multi NSA UEs with different Cells
    [Arguments]    ${nsa_ue_list}    ${target_NSA_cells_list}    ${pass_regexp}=reported successful RA
    FOR    ${ue_id}    ${target_cells}    IN ZIP    ${nsa_ue_list}    ${target_NSA_cells_list}
        UE Attach    ue_id=${ue_id}    profile_id=${profile_id}
        SGNB Addition For Bearer    ue_id=${ue_id}    target_gnb=${target_gnb}    target_cells=${target_cells}
        ...    bearer=${bearer_id}    pass_regexp=${pass_regexp}
    END

Establish XP link
    Execute Egate Command    cmd=sim_trace enb=1 protocol=xp on
    Execute Egate Command    cmd=sim_trace enb=1 protocol=xpu off
    Execute Egate Command    cmd=enb_xp_param id=1 xp_listening_socket=on ignore_xp=off
    Execute Egate Command    cmd=enb_xp_param id=1 xp_peers=2
    Execute Egate Command    cmd=enb_xp_link_up enb=1 target=2
    ...   pass_regexp=ENB-1: XpAP Link with GNB-2.*is up    timeout=100    sleep_time=10s

Check for cell setup complete msg
    [Arguments]    ${list_of_cells}=${logical_cell_list}
    sleep     5s    reason=Waiting for cell setup to complete
    Execute Egate Command    cmd=sim_log_set flush    timeout=2s
    FOR    ${cell_id}    IN    @{list_of_cells}
        ${cell_setup_string}=    Catenate    Cell Setup completed     for \\[CELL_ID:${cell_id}\\]
        ${rc}    ${output}=    Run And Return Rc And Output
        ...    grep -i "${cell_setup_string}" /opt/wts/latest/egate_console.log
        Should be Equal as Integers     ${rc}    0    msg=Cell Setup Failed for cell:${cell_id}.
    END

Validate bearer stats output for DL
    [Arguments]    ${ue_id}    ${expected_dl_tput}    ${mode}    ${pdu_id}=3
    ${expected_dl_value}    Evaluate    isinstance(${expected_dl_tput}, list) == True
    ${expected_total_dl_tput}    Run Keyword If    ${expected_dl_value}    Evaluate
    ...    sum([int(str(x).encode('ascii')) for x in @{expected_dl_tput}])    ELSE    Set Variable    ${expected_dl_tput}
    ${dl_tput}    run keyword if    '${mode}' == 'SA'
    ...    Get Average Throughput from Bearer Stats For SA    ue_id=${ue_id}    dir=dl    pdu_id=${pdu_id}
    ...    ELSE    Get Average Throughput from Bearer Stats For NSA    ue_id=${ue_id}    dir=dl
    Average Throughput Should Be as Expected     ${dl_tput}    ${expected_total_dl_tput}

Validate bearer stats output for UL
    [Arguments]    ${ue_id}    ${expected_ul_tput}    ${mode}    ${pdu_id}=3
    ${ul_tput}    run keyword if    '${mode}' == 'SA'
    ...    Get Average Throughput from Bearer Stats For SA    ue_id=${ue_id}    dir=ul    pdu_id=${pdu_id}
    ...    ELSE    Get Average Throughput from Bearer Stats For NSA    ue_id=${ue_id}    dir=ul
    Run keyword And Continue On Failure    Average Throughput Should Be as Expected     ${ul_tput}    ${expected_ul_tput}

Validate throughput from bearer stats for all UEs in DL only
    [Arguments]    ${ue_list}    ${expected_dl_tput}    ${mode}    ${pdu_id}=3
    FOR    ${ue_id}    IN    @{ue_list}
        Validate bearer stats output for DL    ue_id=${ue_id}    expected_dl_tput=${expected_dl_tput}
        ...    mode=${mode}    pdu_id=${pdu_id}
    END

Validate throughput from bearer stats for all UEs in UL only
    [Arguments]    ${ue_list}    ${expected_ul_tput}    ${mode}    ${pdu_id}=3
    FOR    ${ue_id}    IN    @{ue_list}
        Validate bearer stats output for UL    ue_id=${ue_id}
        ...    expected_ul_tput=${expected_ul_tput}    mode=${mode}    pdu_id=${pdu_id}
    END