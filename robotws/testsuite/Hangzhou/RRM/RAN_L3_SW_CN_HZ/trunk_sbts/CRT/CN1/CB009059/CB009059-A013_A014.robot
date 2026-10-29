*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G    RAN_5G_FDD    SBTS00    CRT    CLOUD_5G_I_LO_AP_LOOO
...            owner-Tingjian.Mao    team-CN1ET    release-SBTS24R2
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_9059}
...    @{PARAMS_FOR_nrrel}

@{PARAMS_FOR_9059}
...    NRBTS-1/NRDRB-11:cellAggrLevel=FR1 CA eligible
...    NRBTS-1/NRDRB-12:cellAggrLevel=Not FR1 CA eligible
...    NRBTS-1/NRDRB-13:cellAggrLevel=FR1 CA eligible
...    NRBTS-1/NRDRB-14:cellAggrLevel=FR1 CA incompatible
...    NRBTS-1:actDrbProfileForCellAggrLevel=FR1_SA
...    NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd
...    NRBTS:sCellActivationMethod=blind
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRCELL:allowUnsuppBcOrBcs=complete BCS check
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:actInterNumerologyCa=true
...    NRCELL:msg1FrequencyStart=9

@{PARAMS_FOR_nrrel}
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:lcrId=4
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-3:gNbId=1
...    NRCELL-1/NRREL-3:lcrId=3
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL:actK1Opt=intra-gNB

@{qos_4_3}
...    Setup QosFlow with QFI:1 5QI:9
...    Setup QosFlow with QFI:1 5QI:8
...    QoS Routing Table
...    UE-1 PDU SESSION ID-1 setup/reestablishment complete
...    UE-1 PDU SESSION ID-2 setup/reestablishment complete

@{qos_1_2}
...    Setup QosFlow with QFI:1 5QI:6
...    Setup QosFlow with QFI:1 5QI:7
...    QoS Routing Table

@{qos_1_3}
...    Setup QosFlow with QFI:1 5QI:6
...    Setup QosFlow with QFI:1 5QI:8
...    QoS Routing Table

@{pass_check_3CC}
...    Successfully released PDU Session with ID
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone

@{pass_check_addqos}
...    Added QosFlow with QFI:3 fiveQI:9
...    Added QosFlow with QFI:2 fiveQI:8

@{pass_check_delqos}
...    Removed FiveQi:Qfi mapping fiveQi 9 qfi 3
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone

@{check_no_scell}
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone

@{PM_Counters_A013}
...    NRCELL-1:${SCELL_ADDN_ALLOW_DRB_PRFL_CA}=2
...    NRCELL-1:${SCELL_ADDN_PREVENT_DRB_PRFL_CA}=2

@{PM_Counters_A014}
...    NRCELL-1:${SCELL_ADDN_ALLOW_DRB_PRFL_CA}=2
...    NRCELL-1:${SCELL_ADDN_PREVENT_DRB_PRFL_CA}=0

${SCELL_ADDN_ALLOW_DRB_PRFL_CA}    M55125C00039    #Number of times SCell addition is allowed for a UE due to DRB profile-based CA
${SCELL_ADDN_PREVENT_DRB_PRFL_CA}    M55125C00040    #Number of times SCell addition is prevented for a UE due to DRB profile-based CA


@{A014_parameter_0}
...    NRCELL-3:maxNumOfSCellAlloc=0
...    NRCELL-4:maxNumOfSCellAlloc=0

@{A014_parameter_5}
...    NRCELL-3:maxNumOfSCellAlloc=5
...    NRCELL-4:maxNumOfSCellAlloc=5

*** Test Cases ***
CB009059-ET-A013_CA_configuration_after_PDU_session_or_DRB_release_blind_FFF_CA
    [Documentation]
    ...    1.The purpose of this test case is to check following scenarios:
    ...      UE is attached to the PCell with multiple PDU sessions. At least one FR1 CA eligible DRB is established and one
    ...      FR1 CA incompatible DRB is established. When the PDU session with the FR1 CA incompatible DRB is released,
    ...      the gNB triggers blind SCell Addition.
    ...      In this user scenario, the UE attaches during ICS. A PDU session is set-up with a with a Not FR1 CA eligible DRB.
    ...      A subsequent PDU session set-up procedure adds a CA eligible and an FR1 CA incompatible DRB. CA is not setup.
    ...      A PDU modification causes the CA incompatible DRB to be released. SCell Addition is triggered as there is no
    ...      FR1 CA incompatible DRB established.
    ...      This scenario is similar to: USCB009059-A#B9 PDU session setup after ICS, Case-2
    ...      At least 4 NRBTS/NRDRB MOC instances are configured as non-GRB types:
    ...    NRDRB ID resType Value RLC Mode cellAggrLevel Value
    ...          1 non-GBR AM 0:FR1 CA eligible
    ...          2 non-GBR AM 1:Not FR1 CA eligible
    ...          3 non-GBR AM 0:FR1 CA eligible
    ...          4 non-GBR AM 2:FR1 CA incompatible
    ...    2.Test Case Steps:
    ...         Step A. UE attaches to Cell-1 and 2 PDU sessions be established during the UE ICS
    ...                 DRB-4 are allocated in PDU session 1, DRB-3 are allocated in PDU session 2
    ...         Step B. Release DRB-4
    ...         Step C. UE deregister
    ...         Step D. UE attaches to Cell-1 and DRB-2 is established
    ...         Step E. Adding NRDRB-4 and NRDRB-3 message to the gNB-CU-CP
    ...         Step F. Release DRB-4
    ...         Step G. UE deregister and check counters
    ...    3. Expected Results:
    ...         Step A: DRBs setup successfully, The gNB does not configure the UE with CA. All DL non-GBR data is scheduled on the PCell.
    ...         Step B: DRB-4 released successful,The gNB configures the UE with 3CC
    ...         Step C: UE is released successful.
    ...         Step D: One Not FR1 CA eligible DRB is established.The UE is not in CA
    ...         Step E: DRBs setup successfully,The gNB does not configure the UE with CA
    ...         Step F. Release DRB-4 successful,trigger 3CC successful,DRB-2 non-GBR data is scheduled only on the PCell 
    ...                 DRB-3 non-GBR DL data is scheduled on the PCell and SCells
    ...         Step G. UE is released and check counters successful
    [Tags]    QC_323410    CA_LABLE-FFF(20MHz_FDD_n71+20MHz_FDD_n66+20MHz_FDD_n66)
    Clear Counter Files    ${False}
    UE multiple PDUs Setup with Qosflows success but no CA    flow_id_1=4    flow_id_2=3
    release one pdu and 3CC Set up
    Verify Throughput pcell and scells    pdu_id=2    qfi_id=1
    Release UEs    ue_type=all
    UE PDU Session Setup with qos2 Successfully but no CA
    UE ADD qos3 and qos4 but no CA
    UE DEL qos4 trigger 3CC
    check counters    ${PM_Counters_A013}
    Release UEs    ue_type=all

CB009059-ET-A014_CA_Failure_by_AC_multiple_PDUs_with_at_least_one_FR1_CA_eligible_DRB_and_then_one_PDU_release_bind_FFF_CA
    [Documentation]
    ...    1.The purpose of this test case is to check following scenarios:
    ...      UE is attached to the PCell with multiple DRBs established. At least one FR1 CA eligible DRB is established
    ...      but the UE is not in CA due to a previous SCell Addition admission control failure. After a subsequent DRB
    ...      reconfiguration, the gNB triggers blind SCell Addition if there is still at least one FR1 CA eligible DRB
    ...      established and no FR1 CA incompatible DRB is established.
    ...      At least 4 NRBTS/NRDRB MOC instances are configured as non-GRB types:
    ...    NRDRB ID resType Value RLC Mode cellAggrLevel Value
    ...          1 non-GBR AM 0:FR1 CA eligible
    ...          2 non-GBR AM 1:Not FR1 CA eligible
    ...          3 non-GBR AM 0:FR1 CA eligible
    ...          4 non-GBR AM 2:FR1 CA incompatible
    ...    2.Test Case Steps:
    ...         Step A. OnlineParamChange maxNumOfSCellAlloc then UE attaches to Cell-1 and 2 PDU sessions be established during the UE ICS
    ...                 DRB-1 are allocated in PDU session 1, DRB-2 are allocated in PDU session 2
    ...         Step B. OnlineParamChange maxNumOfSCellAlloc for 5
    ...         Step C. Release DRB-2
    ...         Step D. UE deregister
    ...         Step E. Repeat step A-D However, Change the value of QOS_ID in step A to 3
    ...         Step F. UE deregister and check counters
    ...    3. Expected Results:
    ...         Step A: Modified successfully,no PDL error,DRBs setup successfully, The gNB does not configure the UE
    ...                 with CA due maxNumOfSCellAlloc values 0
    ...         Step B: Modified successfully,no PDL error
    ...         Step C: Release DRB-2 successful,trigger 3CC successful
    ...         Step D: UE is released successfully
    ...         Step E: Procedure as expected
    ...         Step F. UE is released and check counters successful
    [Tags]    QC_323411    CA_LABLE-FFF(20MHz_FDD_n71+20MHz_FDD_n66+20MHz_FDD_n66)
    Clear Counter Files
    Verify CA failure due TAC then release Not FR1 CA eligible DRB and 3CC Set up
    Verify CA failure due TAC then release FR1 CA eligible DRB and 3CC Set up
    check counters    ${PM_Counters_A014}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fdd_sansa_cmwv/6cells

Modify Cfg
    Update Cfg    ue_param id=1 ue_nr_capabilities=${SA_Capa_perUE_Full} nr_usage_setting=voice_centric
    Update Cfg    ue_nr_capabilities id=1 voice_over_nr=on:on:off
    Update Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=2 5qi=7
    Update Cfg    set_qosflow id=3 5qi=8
    Update Cfg    set_qosflow id=4 5qi=9 default=off
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 qos_flows=1,2,3,4 qos_rules=1,2 default=on ue=1-6 amf=1

Verify CA failure due TAC then release Not FR1 CA eligible DRB and 3CC Set up
    OnlineParamChange    ${A014_parameter_0}
    UE multiple PDUs Setup with Qosflows success but no CA    flow_id_1=1    flow_id_2=2     pass_check_two_pdu=${qos_1_2}
    OnlineParamChange    ${A014_parameter_5}
    release one pdu and 3CC Set up    pdu_id=2
    Verify Throughput pcell and scells
    Release UEs    ue_type=all

Verify CA failure due TAC then release FR1 CA eligible DRB and 3CC Set up
    OnlineParamChange    ${A014_parameter_0}
    UE multiple PDUs Setup with Qosflows success but no CA    flow_id_1=1    flow_id_2=3     pass_check_two_pdu=${qos_1_3}
    OnlineParamChange    ${A014_parameter_5}
    release one pdu and 3CC Set up    pdu_id=2
    Verify Throughput pcell and scells
    Release UEs    ue_type=all

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir    check_sib=${False}

UE register
    [Arguments]    ${ue_id}=1    ${cell_id}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Register

PDUS Session Setup
    [Arguments]    ${ue_id}=1    ${flow_id_1}=4    ${flow_id_2}=3    ${pass_check_two_pdu}=${qos_4_3}    ${fail_regexp}=${check_no_scell}
    Execute Egate Command    amf_ue_pdu_setup_param id=1 action=delay_till_next_pdu_setup
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=2 trf_type=internal
    Execute Egate Command    qosflow_modify qos_flow=${flow_id_1} default=on
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1
    ...    pass_regexp=PDU Setup Request sending will be delayed till next PDU Establishment
    Execute Egate Command    qosflow_modify qos_flow=${flow_id_2} default=on
    ${cmd}    catenate    ue_pdu_session_setup ue=${ue_id} pdu=2 gw=1 nwslice=1
    Execute Egate Command    ${cmd}    pass_regexp=${pass_check_two_pdu}    fail_regexp=${check_no_scell}

UE multiple PDUs Setup with Qosflows success but no CA
    [Arguments]    ${flow_id_1}=4    ${flow_id_2}=3    ${pass_check_two_pdu}=${qos_4_3}
    UE register
    PDUS Session Setup    flow_id_1=${flow_id_1}    flow_id_2=${flow_id_2}    pass_check_two_pdu=${pass_check_two_pdu}
    Sent Throughput
    Sent Throughput    pdu_id=2
    Verify Throughput only pcell
    Verify Throughput only pcell    pdu_id=2

Sent Throughput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl mbps=170 trf_id=1    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=ul mbps=100 trf_id=1    pass_regexp=Started Uplink

stop Throuput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu_id} trf_id=${qfi_id} dir=dl
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu_id} trf_id=${qfi_id} dir=ul

Verify Throughput only pcell
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1    ${Tput_dl}=60    ${Tput_ul}=30    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput1}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput1}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Verify Throughput pcell and scells
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1    ${Tput_dl}=180    ${Tput_ul}=50    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000> 0
    Should Be True    ${ul_throughput}/1000>${Tput_ul}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > 0
    ${scell2_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=ave
    Should Be True    ${scell2_tput}/1000 > 0
    ${ue_dl_tput}    Evaluate    ${dl_throughput}+${scell1_tput}+${scell2_tput}
    Should Be True    ${ue_dl_tput}/1000 >${Tput_dl}

release one pdu and 3CC Set up
    [Arguments]    ${ue_id}=1    ${pdu_id}=1
    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=${pdu_id} by=amf    pass_regexp=${pass_check_3CC}

UE PDU Session Setup with qos2 Successfully but no CA
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${qos_id}=2
    UE register
    Execute Egate Command    qosflow_modify qos_flow=${qos_id} default=on
    Execute Egate Command    amf_ue_pdu_setup_param id=1 reset
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1
    ...    pass_regexp=QoS Routing Table    fail_regexp=${check_no_scell}
    Sent Throughput
    Verify Throughput only pcell    Tput_dl=120    Tput_ul=50

UE ADD qos3 and qos4 but no CA
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=3,4 by=amf
    ...    pass_regexp=${pass_check_addqos}    fail_regexp=${check_no_scell}

UE DEL qos4 trigger 3CC
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_del=4 by=amf
    ...    pass_regexp=${pass_check_delqos}
    Sent Throughput
    Verify Throughput only pcell
    stop Throuput
    Sent Throughput    ue_id=1    qfi_id=2
    Verify Throughput pcell and scells    ue_id=1    qfi_id=2










