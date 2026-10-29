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
...    @{PARAMS_FOR_NRREL}
...    @{PARAMS_FREQ_FOR_CELL3}
...    @{PARAMS_FOR_9059}

@{PARAMS_FOR_9059}
...    NRBTS-1/NRDRB-10:cellAggrLevel=FR1 CA eligible
...    NRBTS-1/NRDRB-11:cellAggrLevel=FR1 CA eligible
...    NRBTS-1/NRDRB-12:cellAggrLevel=Not FR1 CA eligible
...    NRBTS-1/NRDRB-13:cellAggrLevel=FR1 CA eligible
...    NRBTS-1/NRDRB-14:cellAggrLevel=FR1 CA incompatible
...    NRBTS-1:actDrbProfileForCellAggrLevel=FR1_SA

@{PARAMS_FOR_NRREL}
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

@{5QI_SCELL_check}
...    Setup QosFlow with QFI:1 5QI:6
...    Setup QosFlow with QFI:2 5QI:7
...    Setup QosFlow with QFI:3 5QI:8
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone

@{check_no_scell}
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone

@{pass_pdu1}
...    Setup QosFlow with QFI:1 5QI:6
...    QoS Routing Table

@{pass_pdu2}
...    Setup QosFlow with QFI:1 5QI:7
...    Setup QosFlow with QFI:2 5QI:8
...    QoS Routing Table

@{pass_pdu1_QOS2}
...    Setup QosFlow with QFI:1 5QI:7
...    QoS Routing Table

@{pass_pdu1_QOS1_4}
...    Setup QosFlow with QFI:1 5QI:6
...    Setup QosFlow with QFI:2 5QI:9
...    QoS Routing Table

@{pass_pdu1_QOS4}
...    Setup QosFlow with QFI:1 5QI:9
...    QoS Routing Table

@{pass_pdu1_qos1_pdu2_qos4}
...    Setup QosFlow with QFI:1 5QI:6
...    Setup QosFlow with QFI:1 5QI:9
...    QoS Routing Table

@{pass_5QI7}
...    Setup QosFlow with QFI:1 5QI:7
...    QoS Routing Table

@{pass_5QI6}
...    Setup QosFlow with QFI:1 5QI:6
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone

@{pass_rel_pdu_5QI6}
...    sCellToReleaseList
...    Successfully released PDU Session with ID 2

@{pass_pdu1_5QI6}
...    Added QosFlow with QFI:2 fiveQI:6
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone

@{pass_rel_5QI6}
...    sCellToReleaseList
...    Ue 1 PduId 1 Removed FiveQi:Qfi mapping fiveQi 6 qfi 2

@{pass_rel_pdu1_5QI6}
...    sCellToReleaseList
...    Successfully released PDU Session with ID 1

@{PM_Counters_AB03}
...    NRCELL-2:${DL_RRC_FSCELL_REL_ATT_SA}=4
...    NRCELL-2:${DL_RRC_FSCELL_REL_SUC_SA}=4
...    NRCELL-2:${SCELL_ADDN_ALLOW_DRB_PRFL_CA}=4
...    NRCELL-2:${SCELL_ADDN_PREVENT_DRB_PRFL_CA}=0
...    NRCELL-2:${INCMP_DRB_STP_REL_SCELL_ATT_SA}=0
...    NRCELL-2:${INCMP_DRB_STP_REL_SCELL_SUC_SA}=0
...    NRCELL-2:${ELIGIBLE_DRB_REL_SCELL_ATT_SA}=8
...    NRCELL-2:${ELIGIBLE_DRB_REL_SCELL_SUC_SA}=8

@{PM_Counters_A003_A004}
...    NRCELL-2:${SCELL_ADDN_ALLOW_DRB_PRFL_CA}=2
...    NRCELL-2:${SCELL_ADDN_PREVENT_DRB_PRFL_CA}=0

@{PM_Counters_A005}
...    NRCELL-2:${SCELL_ADDN_ALLOW_DRB_PRFL_CA}=0
...    NRCELL-2:${SCELL_ADDN_PREVENT_DRB_PRFL_CA}=3

${DL_RRC_FSCELL_REL_ATT_SA}    M55118C00042    #The number of DL Full SCell Release attempts on PCell for SA
${DL_RRC_FSCELL_REL_SUC_SA}    M55118C00043    #The number of successful DL Full SCell Release attempts on PCell for SA
${SCELL_ADDN_ALLOW_DRB_PRFL_CA}    M55125C00039    #Number of times SCell addition is allowed for a UE due to DRB profile-based CA
${SCELL_ADDN_PREVENT_DRB_PRFL_CA}    M55125C00040    #Number of times SCell addition is prevented for a UE due to DRB profile-based CA
${INCMP_DRB_STP_REL_SCELL_ATT_SA}    M55118C00034    #Number of SCells to be released on PCell due to addition of CA-incompatible DRB for SA
${INCMP_DRB_STP_REL_SCELL_SUC_SA}    M55118C00035    #Number of SCells released on PCell due to addition of CA-incompatible DRB for SA
${ELIGIBLE_DRB_REL_SCELL_ATT_SA}    M55118C00036    #Number of SCells to be released on PCell due to release of the last CA-eligible DRB
${ELIGIBLE_DRB_REL_SCELL_SUC_SA}    M55118C00037    #Number of SCells released on PCell due to release of the last CA-eligible DRB

*** Test Cases ***
CB009059-ET-A003-A004_ICS_with_single_or_multiple_PDU_with_at_least_one_FR1_CA_eligible_DRB_and_no_FR1_CA_incompatible_DRB_blind_1T2F_CA
    [Documentation]
    ...    The purpose of this test case is to check following scenarios:
    ...    UE attaches to a cell during initial context setup (ICS) and at least one FR1 CA eligible DRB is established.
    ...    The gNB configures the UE with CA.
    ...    UE attaches to a cell during ICS and no FR1 CA eligible DRB is established. The gNB does not configure the UE with CA.
    ...    At least 3 NRBTS/NRDRB MOC instances are configured as non-GRB types:
    ...    NRDRB ID resType Value RLC Mode cellAggrLevel Value
    ...          1 non-GBR AM 0:FR1 CA eligible
    ...          2 non-GBR AM 1:Not FR1 CA eligible
    ...          3 non-GBR AM 0:FR1 CA eligible
    ...    2.Test Case Steps:
    ...         Step A. UE attaches to Cell-2 and the gNB establishes 1 PDU session with 3 DRBs(DRB-1, DRB-2, DRB-3 )
    ...                 during the UE context setup, Sent Throughput for all the non-GBR DRBs
    ...         Step B. UE deregister.
    ...         Step C. Multiple PDU sessions may be established during the UE ICS. DRB-1 are allocated in PDU session 1
    ...                 while DRB-2 and DRB-3 are allocated in PDU session 2
    ...         Step D. UE deregister.
    ...         Step E. UE attaches to Cell-2 and the gNB establishes 1 PDU session with DRB2 during the UE context setup,
    ...                 DL non-GBR-data transmission to the UE is initiated for the non-GBR DRB
    ...         Step F. UE deregister and check counters
    ...    3. Expected Results:
    ...         Step A: DRBs setup successfully, The gNB configures the UE with 3CC DL CA with Cell-1 and Cell-3 as SCells,
    ...                 DRB-1 and DRB-3 non-GBR DL data is scheduled on the PCell and SCells.
    ...                 DRB-2 DL non-GBR data is scheduled only on the PCell.
    ...         Step B: UE is released successfully
    ...         Step C: DRBs setup successfully, The gNB configures the UE with 3CC DL CA with Cell-1 and Cell-3 as SCells,
    ...                 DRB-1 and DRB-3 non-GBR DL data is scheduled on the PCell and SCells. DRB-2 DL non-GBR data is scheduled only on the PCell.
    ...         Step D: UE is released successfully
    ...         Step E: The gNB does not configure the UE with CA. All DL non-GBR data is scheduled on the PCell.
    ...         Step F. UE is released and check counters successful
    [Tags]    QC_322789    CA_LABLE-TFF(20MHz_TDD_n41+10MHz_FDD_n71+10MHz_FDD_n71)
    clear counter files    wait=${False}
    UE PDU Session Setup with Multi Qosflow
    Release UEs    ue_type=all
    UE PDU1 Setup with one Qosflow and PDU2 Setup with two Qosflow
    Release UEs    ue_type=all
    UE PDU Session Setup with Qosflow 2
    Sent Throughput and Verify Throughput only PCELL
    Release UEs    ue_type=all
    check counters    ${PM_Counters_A003_A004}

CB009059-ET-A005_ICS_with_single_PDU_with_at_leastFR1_CA_incompatible_DRB_blind_No_CA
    [Documentation]
    ...    The purpose of this test case is to check following scenarios:
    ...    UE attaches to a cell during ICS. At least one FR1 CA eligible DRB is established and at least one CA incompatible
    ...    DRB is established. The gNB does not configure the UE with CA.
    ...    At least 4 NRBTS/NRDRB MOC instances are configured as non-GRB types:
    ...    NRDRB ID resType Value RLC Mode cellAggrLevel Value
    ...          1 non-GBR AM 0:FR1 CA eligible
    ...          2 non-GBR AM 1:Not FR1 CA eligible
    ...          3 non-GBR AM 0:FR1 CA eligible
    ...          4 non-GBR AM 2:FR1 CA incompatible
    ...    2.Test Case Steps:
    ...         Step A. PDU session be established during the UE ICS. DRB-1 and DRB-4 are allocated in PDU session 1
    ...         Step B. UE deregister.
    ...         Step C. PDU session be established again during the UE ICS. DRB-4 are allocated in PDU session 1
    ...         Step D. release DRB.
    ...         Step E. 2 PDU sessions be established during the UE ICS . DRB-1 are allocated in PDU session 1,
    ...                 DRB-4 are allocated in PDU session 2
    ...         Step F. UE is released and check counters
    ...    3. Expected Results:
    ...         Step A: DRBs setup successful, The gNB does not configure the UE with CA.All DL data is scheduled on the PCell.
    ...         Step B: UE is released successful.
    ...         Step C: DRBs setup successful, The gNB does not configure the UE with CA.All DL data is scheduled on the PCell.
    ...         Step D: release DRB successful.
    ...         Step E: DRBs setup successful, The gNB does not configure the UE with CA.All DL data is scheduled on the PCell.
    ...         Step F: UE is released and check counters successful
    [Tags]    QC_322790    AP_REG
    Clear Counter Files    wait=${False}
    UE PDU Session Setup with Qosflow 1 and 4
    Release UEs    ue_type=all
    UE PDU Session Setup with Qosflow 4
    release pdu1
    UE PDU1 Setup with Qosflow 1 and PDU2 Setup with Qosflow 4
    Release UEs    ue_type=all
    check counters    ${PM_Counters_A005}

CB009059-ET-AB03_TFF_CA_release_when_No_CA_eligible_DRB_session_remains_by_PDU_Session_Release
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...    This user scenario validates that when no CA eligible DRBs remain, CA is released. After a PDU session
    ...    release procedure FR1 CA eligible DRB are removed for the UE and no CA eligible DRB session remains.
    ...    CA is released for the UE.
    ...    At least 3 NRBTS/NRDRB MOC instances are configured as non-GRB types:
    ...    NRDRB ID resType Value RLC Mode cellAggrLevel Value
    ...          1 non-GBR AM 0:FR1 CA eligible
    ...          2 non-GBR AM 1:Not FR1 CA eligible
    ...    2.Test Case Steps:
    ...         Step A. The UE attaches to Cell-1. No PDU session is established during the UE ICS,
    ...                AMF sends the NGAP: PDU SESSION RESOURCE SETUP REQUEST to setup NRDRB-2
    ...         Step B. AMF sends the NGAP: PDU SESSION RESOURCE SETUP REQUEST with NRDRB-1 in PDU session 2
    ...         Step C. AMF sends the NGAP: PDU SESSION RESOURCE RELEASE COMMAND for PDU session 2
    ...         Step D. AMF sends the NGAP: PDU SESSION RESOURCE Modify REQUEST to add NRDRB-1 to session1
    ...         Step E. AMF sends the NGAP: PDU SESSION RESOURCE Modify REQUEST to delete NRDRB-1
    ...         Step F. release UE.
    ...         Step G. UE attaches to Cell-1. No PDU session is established during the UE ICS,
    ...         Step H. AMF sends the NGAP: PDU SESSION RESOURCE RELEASE COMMAND for PDU session 1 of NRDRB-1 message
    ...         Step I. repeat step F-G and release UE
    ...         Step J. Check counters
    ...    3. Expected Results:
    ...         Step A. One Not FR1 CA eligible DRB is established.The UE is not in CA
    ...         Step B. One FR1 CA eligible DRB and one Not FR1 CA eligible DRB establish,
    ...                 The gNB configures the UE with 3CC DL CA with Cell-2 and Cell-3 as SCells.
    ...         Step C. The gNB releases all SCells as there is no CA eligible DRBs remain
    ...         Step D. One FR1 CA eligible DRB is established.The gNB configures the UE with CA
    ...         Step E. One FR1 CA eligible DRB is released.The gNB releases all SCells
    ...         Step F. UE is released successful
    ...         Step G. One FR1 CA eligible DRB establish,The gNB configures the UE with CA
    ...         Step H. as result of no DRB available, CA is also released.
    ...         Step I. repeat step F-G successful and UE is released successful
    ...         Step J. Check counters successful
    [Tags]    QC_326431    CA_LABLE-TFF(20MHz_TDD_n41+10MHz_FDD_n71+10MHz_FDD_n71)
    clear counter files    wait=${False}
    Not FR1 CA eligible DRB setup
    FR1 CA eligible DRB in UE PDU Session Setup and Release when Not FR1 CA eligible DRB remains
    FR1 CA eligible DRB in UE PDU Session Modify when Not FR1 CA eligible DRB remains
    Release UEs    ue_type=all
    Only one FR1 CA eligible DRB in UE PDU Session Setup and Release 1st
    Only one FR1 CA eligible DRB in UE PDU Session Setup and Release 2nd
    Release UEs    ue_type=all
    Check Counters    ${PM_Counters_AB03}

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

UE PDU Session Setup with Multi Qosflow
    [Arguments]    ${ue_id}=1    ${cell_id}=2
    ${cmd}    catenate    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Register
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=2,3
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ${cmd}    pass_regexp=${5QI_SCELL_check}
    Sent Throughput and Verify Throughput with DRB1
    Sent Throughput and Verify Throughput with DRB2
    Sent Throughput and Verify Throughput with DRB3

UE1 register
    [Arguments]    ${ue_id}=1    ${cell_id}=2
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Register
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal

UE PDU1 Setup with one Qosflow and PDU2 Setup with two Qosflow
    [Arguments]    ${ue_id}=1
    UE1 register
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    pass_regexp=${pass_pdu1}
    Execute Egate Command    qosflow_modify qos_flow=2 default=on
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=3
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=2 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=2 gw=1 nwslice=1    pass_regexp=${pass_pdu2}
    Sent Throughput and Verify Throughput with DRB1
    Sent Throughput and Verify Throughput with DRB2    pdu_id=2    qfi_id=1
    Sent Throughput and Verify Throughput with DRB3    pdu_id=2    qfi_id=2

Sent Throughput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl mbps=170 trf_id=1    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=ul mbps=100 trf_id=1    pass_regexp=Started Uplink
    sleep    15s    Wait For DL Transmission

Verify Throughput pcell and scells
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1    ${Tput_dl}=118    ${Tput_ul}=15    ${sleep_time}=15s
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


Verify Throughput pcell and no TP in scells
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1    ${Tput_dl}=118    ${Tput_ul}=27    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=current
    Should Be True    ${scell1_tput}/1000 == 0
    ${scell2_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=current
    Should Be True    ${scell2_tput}/1000 == 0

stop Throuput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu_id} trf_id=${qfi_id} dir=dl
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu_id} trf_id=${qfi_id} dir=ul

Sent Throughput and Verify Throughput with DRB1
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1
    Sent Throughput    ue_id=${ue_id}    pdu_id=${pdu_id}    qfi_id=${qfi_id}
    Verify Throughput pcell and scells    ue_id=${ue_id}    pdu_id=${pdu_id}    qfi_id=${qfi_id}
    stop Throuput    ue_id=${ue_id}    pdu_id=${pdu_id}    qfi_id=${qfi_id}

Sent Throughput and Verify Throughput with DRB2
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=2
    Sent Throughput    ue_id=${ue_id}    pdu_id=${pdu_id}    qfi_id=${qfi_id}
    Verify Throughput pcell and no TP in scells    ue_id=${ue_id}    pdu_id=${pdu_id}    qfi_id=${qfi_id}
    stop Throuput    ue_id=${ue_id}    pdu_id=${pdu_id}    qfi_id=${qfi_id}
    sleep    10s    #Wait for traffic to stop

Sent Throughput and Verify Throughput with DRB3
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=3
    Sent Throughput    ue_id=${ue_id}    pdu_id=${pdu_id}    qfi_id=${qfi_id}
    Verify Throughput pcell and scells    ue_id=${ue_id}    pdu_id=${pdu_id}    qfi_id=${qfi_id}
    stop Throuput    ue_id=${ue_id}    pdu_id=${pdu_id}    qfi_id=${qfi_id}

Verify Throughput only pcell
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1    ${Tput_dl}=60    ${Tput_ul}=15    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput1}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput1}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Sent Throughput and Verify Throughput only PCELL
    Sent Throughput
    Verify Throughput only pcell

Sent Throughput and Verify Throughput only PCELL for 2 qos
    Sent Throughput    ue_id=1    pdu_id=1    qfi_id=1
    Sent Throughput    ue_id=1    pdu_id=1    qfi_id=2
    Verify Throughput only pcell    ue_id=1    pdu_id=1    qfi_id=1
    Verify Throughput only pcell    ue_id=1    pdu_id=1    qfi_id=2

Sent Throughput and Verify Throughput only PCELL for 2 pdu
    Sent Throughput    ue_id=1    pdu_id=1    qfi_id=1
    Sent Throughput    ue_id=1    pdu_id=2    qfi_id=1
    Verify Throughput only pcell    ue_id=1    pdu_id=1    qfi_id=1
    Verify Throughput only pcell    ue_id=1    pdu_id=2    qfi_id=1

release pdu1
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=1 by=amf    pass_regexp=Successfully released PDU Session with ID 1

UE PDU Session Setup with Qosflow 2
    [Arguments]    ${ue_id}=1    ${cell_id}=2
    ${cmd}    catenate    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Register
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    qosflow_modify qos_flow=2 default=on
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ${cmd}    pass_regexp=${pass_pdu1_QOS2}    fail_regexp=${check_no_scell}


UE PDU Session Setup with Qosflow 1 and 4
    [Arguments]    ${ue_id}=1
    ${cmd}    catenate    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1
    UE1 register
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=4
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ${cmd}    pass_regexp=${pass_pdu1_QOS1_4}    fail_regexp=${check_no_scell}
    Sent Throughput and Verify Throughput only PCELL for 2 qos

UE PDU Session Setup with Qosflow 4
    [Arguments]    ${ue_id}=1    ${cell_id}=2
    ${cmd}    catenate    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Register
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    qosflow_modify qos_flow=4 default=on
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ${cmd}    pass_regexp=${pass_pdu1_QOS4}    fail_regexp=${check_no_scell}
    Sent Throughput and Verify Throughput only PCELL


UE PDU1 Setup with Qosflow 1 and PDU2 Setup with Qosflow 4
    [Arguments]    ${ue_id}=1
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    amf_ue_pdu_setup_param id=1 action=delay_till_next_pdu_setup
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=2 trf_type=internal
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1
    ...    pass_regexp=PDU Setup Request sending will be delayed till next PDU Establishment
    Execute Egate Command    qosflow_modify qos_flow=4 default=on
    ${cmd}    catenate    ue_pdu_session_setup ue=${ue_id} pdu=2 gw=1 nwslice=1
    Execute Egate Command    ${cmd}    pass_regexp=${pass_pdu1_qos1_pdu2_qos4}    fail_regexp=${check_no_scell}
    Sent Throughput and Verify Throughput only PCELL for 2 pdu

Not FR1 CA eligible DRB setup
    [Arguments]    ${ue_id}=1
    ${cmd}    catenate    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1
    UE1 register
    Execute Egate Command    amf_ue_pdu_setup_param id=1 reset
    Execute Egate Command    amf_param id=1 send_ics_registration=on
    Execute Egate Command    qosflow_modify qos_flow=2 default=on
    Execute Egate Command    ${cmd}    pass_regexp=${pass_5QI7}
    Sent Throughput
    Verify no Scell
    Stop Throughput

FR1 CA eligible DRB in UE PDU Session Setup and Release when Not FR1 CA eligible DRB remains
    [Arguments]    ${ue_id}=1
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=2 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=2 gw=1 nwslice=1    pass_regexp=${pass_5QI6}
    Sent Throughput and Verify Throughput with FR1 CA eligible DRB    1    2    1
    Sent Throughput and Verify Throughput with Not FR1 CA eligible DRB    1    1    1
    Execute Egate Command    ue_pdu_session_release ue=1 pdu=2 by=amf    pass_regexp=${pass_rel_pdu_5QI6}

FR1 CA eligible DRB in UE PDU Session Modify when Not FR1 CA eligible DRB remains
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=1 by=amf    pass_regexp=${pass_pdu1_5QI6}
    Sent Throughput and Verify Throughput with FR1 CA eligible DRB    1    1    2
    Sent Throughput and Verify Throughput with Not FR1 CA eligible DRB    1    1    1
    Execute Egate Command    ue_pdu_session_modify ue=1 pdu=1 qosflows_to_del=1 by=amf    pass_regexp=${pass_rel_5QI6}

Only one FR1 CA eligible DRB in UE PDU Session Setup and Release 1st
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Register
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    amf_ue_pdu_setup_param id=1 reset
    Execute Egate Command    amf_param id=1 send_ics_registration=on
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=2 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    pass_regexp=${pass_5QI6}
    Sent Throughput and Verify Throughput with FR1 CA eligible DRB    1    1    1
    Execute Egate Command    ue_pdu_session_release ue=1 pdu=1 by=amf    pass_regexp=${pass_rel_pdu1_5QI6}

Only one FR1 CA eligible DRB in UE PDU Session Setup and Release 2nd
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    pass_regexp=${pass_5QI6}
    Sent Throughput and Verify Throughput with FR1 CA eligible DRB    1    1    1
    Execute Egate Command    ue_pdu_session_release ue=1 pdu=1 by=amf    pass_regexp=${pass_rel_pdu1_5QI6}

Sent Throughput and Verify Throughput with FR1 CA eligible DRB
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1
    Sent Throughput    ue_id=${ue_id}    pdu_id=${pdu_id}    qfi_id=${qfi_id}
    Verify Throughput pcell and scells    ue_id=${ue_id}    pdu_id=${pdu_id}    qfi_id=${qfi_id}
    Stop Throughput    ue_id=${ue_id}    pdu_id=${pdu_id}    qfi_id=${qfi_id}
    Verify NO Throughput pcell and scells    ue_id=${ue_id}    pdu_id=${pdu_id}    qfi_id=${qfi_id}

Sent Throughput and Verify Throughput with Not FR1 CA eligible DRB
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=2
    Sent Throughput    ue_id=${ue_id}    pdu_id=${pdu_id}    qfi_id=${qfi_id}
    Verify Throughput pcell and no TP in scells    ue_id=${ue_id}    pdu_id=${pdu_id}    qfi_id=${qfi_id}
    Stop Throughput    ue_id=${ue_id}    pdu_id=${pdu_id}    qfi_id=${qfi_id}
    Verify NO Throughput pcell and scells    ue_id=${ue_id}    pdu_id=${pdu_id}    qfi_id=${qfi_id}

Verify NO Throughput pcell and scells
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1    ${Tput_dl}=118    ${Tput_ul}=15    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput1}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=dl    rate_type=ave
    ${ul_throughput1}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput1}/1000== 0
    Should Be True    ${ul_throughput1}/1000== 0

Verify no Scell
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi_id}=1    ${Tput_dl}=30    ${Tput_ul}=27    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi_id}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi_id}    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-[0] *0 *0 *0
    Should Not Match Regexp    ${scell_tput}    CellIndex-[1]
    Should Not Match Regexp    ${scell_tput}    CellIndex-[2]
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Stop Throughput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} trf_id=1 dir=dl
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} trf_id=1 dir=ul
