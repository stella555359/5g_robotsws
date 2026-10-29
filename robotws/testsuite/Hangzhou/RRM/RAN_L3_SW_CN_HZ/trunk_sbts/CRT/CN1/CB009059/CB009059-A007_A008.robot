*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G    RAN_5G_TDD    SBTS00    CRT    CLOUD_5G_I_LO_AP_LO
...            owner-Tingjian.Mao    team-CN1ET    release-SBTS24R2
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_nrrel}
...    @{PARAMS_FREQ_FOR_CELL3}
...    @{PARAMS_FOR_9059}

@{PARAMS_FOR_9059}
...    NRBTS-1/NRDRB-11:cellAggrLevel=FR1 CA eligible
...    NRBTS-1/NRDRB-12:cellAggrLevel=Not FR1 CA eligible
...    NRBTS-1/NRDRB-13:cellAggrLevel=FR1 CA eligible
...    NRBTS-1/NRDRB-14:cellAggrLevel=FR1 CA incompatible
...    NRBTS-1:actDrbProfileForCellAggrLevel=FR1_SA

@{PARAMS_FOR_nrrel}
...    NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:lcrId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-3:gNbId=1
...    NRCELL-2/NRREL-3:lcrId=3
...    NRCELL-2/NRREL-3:gNbIdLength=22
...    NRCELL-2/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL:actK1Opt=intra-gNB

@{PARAMS_FREQ_FOR_CELL3}
...    NRCELL-3/NRCELL_FDD-1:nrarfcnDl=124580
...    NRCELL-3/NRCELL_FDD-1:nrarfcnUl=133780
...    NRCELL-3:gscnOrSsPbchArfcn=1555
...    NRCELL-3:type0CoresetConfigurationIndex=0

@{5QI6_SCELL_check}
...    Setup QosFlow with QFI:1 5QI:6
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone

@{pass_DRB3_3CC}
...    Added QosFlow with QFI:2 fiveQI:8
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone

@{pass_DRB3_DRB4}
...    Added QosFlow with QFI:3 5QI:9
...    Added QosFlow with QFI:2 5QI:8
...    QoS Routing Table

@{pass_check_two_pdu_qos2}
...    Setup QosFlow with QFI:1 5QI:9
...    Setup QosFlow with QFI:1 5QI:7
...    QoS Routing Table

@{pass_check_two_pdu_qos3}
...    Setup QosFlow with QFI:1 5QI:9
...    Setup QosFlow with QFI:1 5QI:8
...    QoS Routing Table

@{check_no_scell}
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone

@{pass_check_two_pdu_qos2}
...    Setup QosFlow with QFI:1 5QI:9
...    Setup QosFlow with QFI:1 5QI:7
...    QoS Routing Table

@{PM_Counters_A007}
...    NRCELL-2:${SCELL_ADDN_ALLOW_DRB_PRFL_CA}=1
...    NRCELL-2:${SCELL_ADDN_PREVENT_DRB_PRFL_CA}=2

@{PM_Counters_A008}
...    NRCELL-2:${SCELL_ADDN_ALLOW_DRB_PRFL_CA}=1
...    NRCELL-2:${SCELL_ADDN_PREVENT_DRB_PRFL_CA}=1

${SCELL_ADDN_ALLOW_DRB_PRFL_CA}    M55125C00039    #Number of times SCell addition is allowed for a UE due to DRB profile-based CA
${SCELL_ADDN_PREVENT_DRB_PRFL_CA}    M55125C00040    #Number of times SCell addition is prevented for a UE due to DRB profile-based CA

@{A007_parameter_update1}
...    NRCELL-2:maxNumOfNonGBRBearersSA=1

@{A007_parameter_update2}
...    NRCELL-2:maxNumOfNonGBRBearersSA=550
...    NRCELL-1:maxNumOfSCellAlloc=1
...    NRCELL-3:maxNumOfSCellAlloc=1

@{A007_parameter_recover}
...    NRCELL-1:maxNumOfSCellAlloc=250
...    NRCELL-3:maxNumOfSCellAlloc=250

*** Test Cases ***
CB009059-ET-A007_ICS_no_PDU_and_PDU_setup_failure_with_at_least_one_FR1_CA_eligible_DRB_and_no_FR1_CA_incompatible_DRB_blind_No_CA
    [Documentation]
    ...    The purpose of this test case is to check following scenarios:
    ...    In this user scenario, the UE attaches but no PDU session is established. A subsequent PDU session set-up procedure
    ...    adds an FR1 CA eligible DRB. SCell Addition is triggered only if there is no FR1 CA incompatible DRB established.
    ...    At least 4 NRBTS/NRDRB MOC instances are configured as non-GRB types:
    ...    NRDRB ID resType Value RLC Mode cellAggrLevel Value
    ...          1 non-GBR AM 0:FR1 CA eligible
    ...          2 non-GBR AM 1:Not FR1 CA eligible
    ...          3 non-GBR AM 0:FR1 CA eligible
    ...          4 non-GBR AM 2:FR1 CA incompatible
    ...    2.Test Case Steps:
    ...         Step A. The UE1 attaches to Cell-2. PDU Session Resource Setup with NRDRB-3
    ...         Step B. Online change cell2.maxNumOfNonGBRBearersSA=1
    ...         Step C. The UE2 attaches to Cell-2.No PDU session is established during the UE ICS
    ...         Step D. UE2 PDU Session Resource Setup with NRDRB-3
    ...         Step E. UE2 deregister,online change cell2.maxNumOfNonGBRBearersSA=500,cell1.maxNumOfSCellAlloc=1,cell3.maxNumOfSCellAlloc=1,
    ...         Step F. The UE2 attaches to Cell-2.PDU Session Resource Setup with NRDRB-2 then UE2 deregister
    ...         Step G. The UE2 attaches to Cell-2 PDU1 Setup with Qosflow4 and PDU2 Setup with Qosflow3 then UE2 deregister
    ...         Step H. The UE2 attaches to Cell-2 PDU1 Setup with Qosflow4 and PDU2 Setup with Qosflow2 then UE2 deregister
    ...         Step I. check counters
    ...    3. Expected Results:
    ...         Step A: UE1 attached successful,One FR1 CA eligible DRB is established,3CC successfully
    ...         Step B: Online change successfully
    ...         Step C: UE2 attached successful
    ...         Step D: UE2 PDU failed due to RAC(cell2.maxNumOfNonGBRBearersSA=1),the gNB does not trigger SCell Addition.
    ...         Step E. release UE2 successfully,online change successfully.
    ...         Step F: UE2 attached successful,PDU Session Resource Setup with One not FR1 CA eligible DRB but no CA,release UE2 successfully
    ...         Step G. UE2 PDU1 Setup with Qosflow4 and PDU2 Setup with Qosflow3 success but no ca then release UE2 successfully
    ...         Step H. UE2 PDU1 Setup with Qosflow4 and PDU2 Setup with Qosflow2 success but no ca then release UEs successfully
    ...         Step I. check counters successfully
    [Tags]    QC_323293    CA_LABLE-TFF(20MHz_TDD_n41+10MHz_FDD_n71+10MHz_FDD_n71)
    Clear Counter Files    ${False}
    UE1 PDU Session Setup with Qosflow1 and 3CC successfully
    OnlineParamChange    ${A007_parameter_update1}
    UE2 PDU Session Setup with qos3 but failed
    OnlineParamChange    ${A007_parameter_update2}
    UE2 PDU Session Setup with qos2 Successfully but no CA
    UE2 PDU1 Setup with Qosflow4 and PDU2 Setup with other Qosflow success but no ca    pdu2_qos_flow=3
    UE2 PDU1 Setup with Qosflow4 and PDU2 Setup with other Qosflow success but no ca    pdu2_qos_flow=2    two_pdu=${pass_check_two_pdu_qos2}
    check counters    ${PM_Counters_A007}
    [Teardown]    A007_Teardown

CB009059-ET-A008_Non_CA_PDU_DRB_and_then_New_PDU_setup_with_at_least_one_FR1_CA_eligible_DRB_and_incompatible_DRB_blind_1T2F_CA
    [Documentation]
    ...    The purpose of this test case is to check following scenarios:
    ...    In this user scenario, the UE attaches during ICS. A PDU session is set-up with a Not FR1 CA eligible DRB. A
    ...    subsequent PDU session set-up procedure adds an FR1 CA eligible DRB. SCell Addition is triggered only if there
    ...    is no FR1 CA incompatible DRB established.
    ...    At least 4 NRBTS/NRDRB MOC instances are configured as non-GRB types:
    ...    NRDRB ID resType Value RLC Mode cellAggrLevel Value
    ...          1 non-GBR AM 0:FR1 CA eligible
    ...          2 non-GBR AM 1:Not FR1 CA eligible
    ...          3 non-GBR AM 0:FR1 CA eligible
    ...          4 non-GBR AM 2:FR1 CA incompatible
    ...    2.Test Case Steps:
    ...         Step A. The UE attaches to Cell-2. No PDU session is established during the UE ICS
    ...         Step B. PDU Session Resource Setup with NRDRB-2
    ...         Step C. ADD NRDRB-3 in PDU
    ...         Step D. UE deregister
    ...         Step E. Repeat step a b and ADD NRDRB-3 NRDRB-4 in PDU
    ...         Step F. UE deregister and check counters
    ...    3. Expected Results:
    ...         Step A: The UE attaches but no PDU session is established
    ...         Step B: PDU Session Resource Setup successfully,The UE no CA. All DL non-GBR data is scheduled on the PCell.
    ...         Step C: The gNB configures the UE with 3CC,DL non-GBR data for DRB-3 is scheduled on the PCell and the SCells
    ...                 DRB-2 is scheduled on the PCell.
    ...         Step D: Release UE successfully
    ...         Step E. The UE is not in CA. All DL non-GBR data is scheduled on the PCell.
    ...         Step F. Release UE and check counters successfully
    [Tags]    QC_323294    CA_LABLE-TFF(20MHz_TDD_n41+10MHz_FDD_n71+10MHz_FDD_n71)
    Clear Counter Files
    UE PDU Session Setup with Qosflow2 and no CA
    ADD NRDRB-3 in PDU
    Release UEs    ue_type=all
    UE PDU Session Setup with Qosflow2 and no CA
    ADD NRDRB-3 and NRDRB-4 in PDU
    Release UEs    ue_type=all
    check counters    ${PM_Counters_A008}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/3cells_1T2F

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

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir    check_sib=${False}

A007_Teardown
    Execute Egate Command    amf_ue_pdu_setup_param id=1 reset
    OnlineParamChange    ${A007_parameter_recover}
    Common Test Teardown And Stop Capture Logs

UE1 PDU Session Setup with Qosflow1 and 3CC successfully
    UE register
    PDU Session Setup    ue_id=1    pdu=1    qos_flow=1    pass_regexp=${5QI6_SCELL_check}
    Sent Throughput    ue_id=1    qfi_id=1
    Verify Throughput pcell and scells    ue_id=1    qfi_id=1

UE2 PDU Session Setup with qos3 but failed
    UE register    ue_id=2
    PDU Session Setup    ue_id=2    pdu=1    qos_flow=3    pass_regexp=Successfully released PDU Session    fail_regexp=${check_no_scell}
    Release UEs    ue_id=2

UE2 PDU Session Setup with qos2 Successfully but no CA
    UE register    ue_id=2
    PDU Session Setup    ue_id=2    pdu=1    qos_flow=2    fail_regexp=${check_no_scell}
    Sent Throughput    ue_id=2
    Verify Throughput only pcell    ue_id=2    Tput_dl=60    Tput_ul=15
    Release UEs    ue_id=2

UE2 PDU1 Setup with Qosflow4 and PDU2 Setup with other Qosflow success but no ca
    [Arguments]    ${pdu2_qos_flow}=3    ${two_pdu}=${pass_check_two_pdu_qos3}
    UE register    ue_id=2
    Execute Egate Command    amf_ue_pdu_setup_param id=1 action=delay_till_next_pdu_setup
    PDU Session Setup    ue_id=2    pdu=1    qos_flow=4    pass_regexp=PDU Setup Request sending will be delayed
    PDU Session Setup    ue_id=2    pdu=2    qos_flow=${pdu2_qos_flow}    pass_regexp=${two_pdu}    fail_regexp=${check_no_scell}
    Sent Throughput    ue_id=2
    Sent Throughput    ue_id=2    pdu_id=2
    Verify Throughput only pcell    ue_id=2    Tput_dl=30    Tput_ul=10
    Verify Throughput only pcell    ue_id=2    pdu_id=2    Tput_dl=30    Tput_ul=10
    Release UEs    ue_id=2

UE register
    [Arguments]    ${ue_id}=1    ${cell_id}=2
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    amf_ue_pdu_setup_param id=1 reset
    Execute Egate Command    amf_param id=1 send_ics_registration=on    #Set ICS without PDU
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register

UE PDU Session Setup with Qosflow2 and no CA
    UE register    ue_id=1
    PDU Session Setup    ue_id=1    pdu=1    qos_flow=2    pass_regexp=Setup QosFlow with QFI:1 5QI:7
    ...    fail_regexp=${check_no_scell}
    Sent Throughput
    Verify Throughput only pcell

PDU Session Setup
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qos_flow}=1    ${pass_regexp}=QoS Routing Table    ${fail_regexp}=None
    Execute Egate Command    qosflow_modify qos_flow=${qos_flow} default=on
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu} gw=1 nwslice=1    pass_regexp=${pass_regexp}
    ...    fail_regexp=${fail_regexp}

ADD NRDRB-3 in PDU
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=3 by=amf    pass_regexp=${pass_DRB3_3CC}
    Sent Throughput    qfi_id=2
    Verify Throughput pcell and scells    qfi_id=2    Tput_ul=15

ADD NRDRB-3 and NRDRB-4 in PDU
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=3,4 by=amf    pass_regexp=${pass_DRB3_DRB4}
    ...    fail_regexp=${check_no_scell}
    Sent Throughput    qfi_id=2
    Sent Throughput    qfi_id=3
    Verify Throughput only pcell    qfi_id=2    Tput_dl=30    Tput_ul=10
    Verify Throughput only pcell    qfi_id=3    Tput_dl=30    Tput_ul=10

Sent Throughput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl mbps=170 trf_id=1    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=ul mbps=100 trf_id=1    pass_regexp=Started Uplink


Verify Throughput pcell and scells
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1    ${Tput_dl}=153    ${Tput_ul}=31    ${sleep_time}=15s
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

Verify Throughput only pcell
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1    ${Tput_dl}=130    ${Tput_ul}=27    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput1}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput1}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}
