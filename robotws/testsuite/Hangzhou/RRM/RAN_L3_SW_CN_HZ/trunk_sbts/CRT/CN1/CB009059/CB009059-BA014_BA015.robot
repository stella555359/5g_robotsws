*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G    RAN_5G_TDD    SBTS00    CRT    CLOUD_5G_I_BOO_AP_LOO
...            owner-Tingjian.Mao    team-CN1ET    release-SBTS24R2
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}
@{FAULTS_EXCLUDED_CHECKING}    4452
@{PARAMS_IN_SCF}
...    @{NRCELL_11_NRREL}
...    @{PARAMS_FOR_9059}
...    @{PARAMS_FOR_CA}

@{PARAMS_FOR_9059}
...    NRBTS-1/NRDRB-11:cellAggrLevel=FR1 CA eligible
...    NRBTS-1/NRDRB-12:cellAggrLevel=Not FR1 CA eligible
...    NRBTS-1/NRDRB-13:cellAggrLevel=FR1 CA incompatible
...    NRBTS-1/NRDRB-14:cellAggrLevel=FR1 CA eligible
...    NRBTS-1/NRDRB-18:cellAggrLevel=Not FR1 CA eligible
...    NRBTS-1/NRDRB-19:cellAggrLevel=Not FR1 CA eligible
...    NRBTS-1:actDrbProfileForCellAggrLevel=FR1_SA

@{PARAMS_FOR_CA}
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRCELL:maxNumScellsDlFr1=4
...    NRBTS/NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Any_Sa
...    NRCELL:actCDrx=false
...    NRCELL:actAperCsi=false
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRCELL:pucchModeSelect=longPucch
...    NRBTS:actFdmScheduling=true
...    NRBTS:actFdmEnhancedScheduling=true
...    NRBTS:sCellActivationMethod=bufferBased
...    NRCELL:sCellDeactivationTimerGNB=infinity

@{NRCELL_11_NRREL}
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL-11:a1MeasSCellAddEnabled=rsrp
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:handoverAllowedSARedCap=forbidden
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:nrDcAllowed=false
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:gNbId=1
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-2:handoverAllowedSARedCap=forbidden
...    NRCELL-11/NRREL-2:lcrId=2
...    NRCELL-11/NRREL-2:nrDcAllowed=false
...    NRCELL-11/NRREL-2:removeNotAllowed=false
...    NRCELL-11/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3

@{NRDRB-4_incompatible}
...    NRBTS-1/NRDRB-14:cellAggrLevel=FR1 CA incompatible

@{NRDRB-4_re}
...    NRBTS-1/NRDRB-14:cellAggrLevel=FR1 CA eligible

@{actDrbProfileForCellAggrLevel_disabled}
...    NRBTS-1:actDrbProfileForCellAggrLevel=disabled

@{actDrbProfileForCellAggrLevel_FR1_SA}
...    NRBTS-1:actDrbProfileForCellAggrLevel=FR1_SA

@{PM_Counters_BA014}
...    NRCELL-11:${SCELL_ADDN_ALLOW_DRB_PRFL_CA}=3
...    NRCELL-11:${SCELL_ADDN_PREVENT_DRB_PRFL_CA}=2
...    NRCELL-11:${INCMP_DRB_STP_REL_SCELL_ATT_SA}=0
...    NRCELL-11:${INCMP_DRB_STP_REL_SCELL_SUC_SA}=0
...    NRCELL-11:${ELIGIBLE_DRB_REL_SCELL_ATT_SA}=0
...    NRCELL-11:${ELIGIBLE_DRB_REL_SCELL_SUC_SA}=0
...    NRCELL-11:${DL_RRC_FSCELL_REL_ATT_SA}=0
...    NRCELL-11:${DL_RRC_FSCELL_REL_SUC_SA}=0
...    NRCELL-11:${DL_RRC_1SCELL_REL_ATT_SA}=0
...    NRCELL-11:${DL_RRC_1SCELL_REL_SUC_SA}=0
...    NRCELL-11:${DL_RRC_1EXTSCELL_REL_ATT_SA}=0
...    NRCELL-11:${DL_RRC_1EXTSCELL_REL_SUC_SA}=0
...    NRCELL-11:${DL_RRC_FEXTSCELL_REL_ATT_SA}=0
...    NRCELL-11:${DL_RRC_FEXTSCELL_REL_SUC_SA}=0

@{PM_Counters_BA015}
...    NRCELL-11:${SCELL_ADDN_ALLOW_DRB_PRFL_CA}=3
...    NRCELL-11:${SCELL_ADDN_PREVENT_DRB_PRFL_CA}=1

@{check_add_DRB4}
...    Added QosFlow with QFI:2 fiveQI:9
...    QoS Routing Table

@{add2_del1_3}
...    Adding QosFlow with QFI:3 5QI:7
...    Deleting QosFlow with QFI:1 5QI:6
...    Deleting QosFlow with QFI:2 5QI:8
...    QoS Routing Table

@{add1_del2}
...    Adding QosFlow with QFI:2 5QI:6
...    Deleting QosFlow with QFI:3 5QI:7
...    QoS Routing Table

@{del3}
...    Deleting QosFlow with QFI:2 5QI:8
...    QoS Routing Table

@{check_A1}
...    reportConfigToAddModList
...    eventId eventA1
...    a1-Threshold
...    QoS Routing Table

${SCELL_ADDN_ALLOW_DRB_PRFL_CA}    M55125C00039
#This counter shows the number of times SCell addition is allowed for a UE due to data radio bearer (DRB) profile-based Carrier Aggregation.
${SCELL_ADDN_PREVENT_DRB_PRFL_CA}    M55125C00040
#This counter shows the number of times SCell addition is prevented for a UE due to data radio bearer (DRB) profile-based Carrier Aggregation.
${INCMP_DRB_STP_REL_SCELL_ATT_SA}    M55118C00034
# This counter measures the number of SCells to be released due to the addition of a CA-incompatible data radio bearer (DRB) in the PCell for SA.
${INCMP_DRB_STP_REL_SCELL_SUC_SA}    M55118C00035
#This counter measures the number of SCells released due to the addition of a CA-incompatible data radio bearer (DRB) in the PCell for SA.
${DL_RRC_FSCELL_REL_ATT_SA}    M55118C00042
#This counter measures the number of full SCell release attempts in DL in the PCell for SA. It considers only full SCell
#releases, partial SCell releases aren't counted. It considers both local SCells and ext-SCells.
${DL_RRC_FSCELL_REL_SUC_SA}    M55118C00043
#This counter measures the number of successful full SCell release attempts in DL in the PCell for SA. It considers only full
#SCell releases, partial SCell releases aren't counted. It considers both local SCells and ext-SCells.
${ELIGIBLE_DRB_REL_SCELL_ATT_SA}    M55118C00036
#This counter measures the number of SCells to be released due to the release of the last CA-eligible data radio bearer (DRB) in the PCell for SA.
${ELIGIBLE_DRB_REL_SCELL_SUC_SA}    M55118C00037
#This counter measures the number of SCells released due to the release of the last CA-eligible data radio bearer (DRB) in the PCell for SA.
${DL_RRC_1SCELL_REL_ATT_SA}    M55118C10503
#The number of DL 1 SCell Release attempts on PCell for SA
${DL_RRC_1SCELL_REL_SUC_SA}    M55118C10504
#The number of successful DL 1 SCell Release attempts on PCell for SA
${DL_RRC_1EXTSCELL_REL_ATT_SA}    M55118C10507
#The number of DL 1 ext-SCell Release attempts on PCell for SA
${DL_RRC_1EXTSCELL_REL_SUC_SA}    M55118C10508
#The number of successful DL 1 ext-SCell Release attempts on PCell for SA
${DL_RRC_FEXTSCELL_REL_ATT_SA}    M55118C00044
#The number of DL Full ext-SCell Release attempts on PCell for SA
${DL_RRC_FEXTSCELL_REL_SUC_SA}    M55118C00045
#he number of successful DL Full ext-SCell Release attempts on PCell for SA

${SA_Capa_3T3F}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4700FB8D85181AC1184341020E9068036B64C558D
...    0E7C471E819F604F8C48E3C873EA39F30C7942C0FFFFF05C00FFC0070005F0005C0000E0541B107582308682041E20D00656C98AB121CFB0
...    27C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD800000170000381546C4CD608C21A0810748340185B2ABB08873E238F11C7A06
...    7D813E31CF9863CA1607FFFF82E007FE003801FF8002E0000702B8F88DAC1184341020F941A00AAD931561439F11C78C0000000000000000
...    0040E1E027FFC00001FFF000001700003802CF0F1300038820000042C040A83C28000E230000010B02B0F11800388200000C2C0AC3C28000
...    E208000010B02B0F13000388C0000042C0AC5C46000E208007104000028581587850001C4C00000C160562E2600071040038500000102C0A
...    C5C4C000E23000711800001058158B850001C41000E230000020B02B170A0003882001C41000004160562E26000710400388C0000082C0AC
...    5C28000E23000711800001058158B898001C46000E140000040B02B0F11800388C00000C2C0AC9C28000E14000710400388C001C4C00000E
...    1617593850001C28000E20800710400389800001C2C3F593850001C41000E2080071180038980000202C0BC1C28000012160205E0E208000
...    0A0B0102F07118000050580817838980000242C040803808D00A202640411740101150B428913639F0E14489B1CF870A244D8E7C3851226C
...    73E1C28913639F0E2448913639F0E14081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081
...    B1CF811204081B1CF810A040D8E7C09502040810206CB5E1C8810204081B2D78722040810206CB5E1C089B1CF870206C00004081B0000102
...    06C0000001F1618C6318C6318C6318C6318C6318DE82E003C00281C1401C0C02500700060240040603E09002000000010000020080000000
...    400000802000008010000060080000400400002802001004010040000300200001C010008000000200002001000012008000030040000500
...    200002C01000812048020000300CE54D654D60A5606560CD60AD652D64CD602D606D6025604560ED03410000096524040000659494100002
...    96525040000E594901000049652404000165949010000696524040001E594901000089652404000265949010000A96524040002E59494100
...    00C96524040000C594900CD2A8BA55554AAAE95455058AA0B1541A2A94C55268AA031540A2A93555078A160178095028140A05028140A050
...    28140A05028140A050281400282020180300801002101002008040300610080100202018030080600C10100C018040300610080100202018
...    030080100220100C01804030060100C018202004010080100440100200404008010100C018040300601002004802004008080600C0201803
...    0080600C020040080040080300080600C3543E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828705A0

*** Test Cases ***
CB009059-ET-BA014_On_line_parameter_modification_covBasedA1_SCell_Addition_Method
    [Documentation]
    ...    1.The purpose of this test case is to check following scenarios:
    ...      UE is attached to the PCell and A1 measurement for SCell Addition is activated at the UE. If CB009059 is deactivated,
    ...      or if an NRDRB instance is changed such that CA is no longer allowed, the change does not take effect on this UE
    ...      unless the DRB is released and reestablished.
    ...    At least 4 NRBTS/NRDRB MOC instances are configured as non-GRB types:
    ...    NRDRB ID resType Value RLC Mode cellAggrLevel Value
    ...          1 non-GBR AM 0:FR1 CA eligible
    ...          2 non-GBR AM 1:Not FR1 CA eligible
    ...          3 non-GBR AM 2:FR1 CA incompatible
    ...          4 non-GBR AM 0:FR1 CA eligible
    ...    2.Test Case Steps:
    ...         Step A. UE81 attaches to Cell-11 and PDU session be established during the UE ICS. DRB-1 is allocated in PDU session 1
    ...         Step B. UE81 add DRB-4 then Change the NRDRB-4 FR1 CA eligible to FR1 CA incompatible
    ...         Step C. UE81 Release DRB-4 and setup DRB-4 again then recover the NRDRB-4 cellAggrLevel to FR1 CA eligible
    ...                 UE81 Release DRB-4 and setup DRB-4 again
    ...         Step D. UE82 attaches to Cell-11 and PDU session be established during the UE ICS. DRB-1 is allocated in PDU session 1
    ...         Step F. UE82 Add DRB-4 then online sets NRBTS.actDrbProfileForCellAggrLevel = disabled
    ...         Step G. UE82 Add DRB-3 then online sets NRBTS.actDrbProfileForCellAggrLevel = FR1_SA
    ...         Step H. UE82 Release DRB-3 and setup DRB-3 again
    ...    3. Expected Results:
    ...         Step A: UE81 is configured with A1 measurement for SCell Addition
    ...         Step B: DRB-4 Setup successfully,online change successful no pdl error
    ...         Step C: UE81 Release DRB-4 successfully,no A1 change then DRB-4 Setup successfully releases the event A1
    ...                 online change successful no pdl error,UE81 is configured with A1 measurement for SCell Addition
    ...                 after Released DRB-4
    ...         Step D. UE82 is configured with A1 measurement for SCell Addition
    ...         Step F. UE82 DRB-4 Setup successfully,,online change successful no pdl error
    ...         Step G. UE82 DRB-3 Setup successfully,event A1 remain,online change successful no pdl error
    ...         Step H. UE82 DRB-3 reestablishment successfully,releases the event A1
    [Tags]    QC_344364    CA_LABEL-FTT(10Mhz_FDD_n71+60Mhz_TDD_n41+60Mhz_TDD_n41)
    clear counter files    false
    UE PDU Session Setup with Qosflow    ue_id=81
    OnlineParamChange    ${NRDRB-4_incompatible}
    Verify UE measurement after reestablishment DRB    ue_id=81    qos_id=4
    OnlineParamChange    ${NRDRB-4_re}
    Verify UE A1 configured after reestablishment DRB    ue_id=81    qos_id=4
    UE PDU Session Setup with Qosflow    ue_id=82    gw_id=2
    Verify UE measurement after ADD DRB online change actDrbProfileForCellAggrLevel
    Release UEs    ue_type=all
    Check Wireshark Log    ${CURDIR}${/}A2A_BA014${/}a2a.ini    wait_string=UEContextReleaseComplete::6
    check counters    pm_counters_expression=${PM_Counters_BA014}

CB009059-ET-BA015_On_line_feature_activation_covBasedA1_SCell_Addition_Method
    [Documentation]
    ...    1.The purpose of this test case is to check following scenarios:
    ...      UE is attached to the PCell and A1 measurement for SCell Addition is activated at the UE with CB009059 deactivated.
    ...      If CB009059 is activated while the UE is connected to the cell, the change does not impact the CA eligiblity of
    ...      already established DRB. The change also does not impact the A1 measurement configuration for this UE until a
    ...      DRB is released or a new DRB is established.
    ...    At least 4 NRBTS/NRDRB MOC instances are configured as non-GRB types:
    ...    NRDRB ID resType Value RLC Mode cellAggrLevel Value
    ...          1 non-GBR AM 0:FR1 CA eligible
    ...          2 non-GBR AM 1:Not FR1 CA eligible
    ...          3 non-GBR AM 2:FR1 CA incompatible
    ...          4 non-GBR AM 0:FR1 CA eligible
    ...          NRBTS.actDrbProfileForCellAggrLevel = disabled
    ...    2.Test Case Steps:
    ...         Step A. UE81 attaches to Cell-11 and PDU session be established during the UE ICS. DRB-1 and DRB-3 is allocated in PDU session 1
    ...         Step B. UE82 attaches to Cell-11 and PDU session be established during the UE ICS. DRB-1 and DRB-3 is allocated in PDU session 1
    ...         Step C. online sets NRBTS.actDrbProfileForCellAggrLevel = FR1_SA
    ...         Step D. UE81 Release DRB-3 and setup DRB-3 again
    ...         Step F. UE82 Release DRB-3 DRB-1 and setup DRB-2
    ...         Step G. UE82 Release DRB-2 and setup DRB-1
    ...         Step H. UE81 Release DRB-3
    ...    3. Expected Results:
    ...         Step A: UE81 is configured with A1 measurement for SCell Addition
    ...         Step B: UE82 is configured with A1 measurement for SCell Addition
    ...         Step C: online change successful no pdl error
    ...         Step D. UE81 Release DRB-3 A1 measconfig no change and setup DRB-3 successfully,The gNB releases the A1
    ...         Step F. UE82 Release DRB-3 DRB-1 and setup DRB-2 successfully,The gNB releases the event A1 measurement
    ...         Step G. UE82 Release DRB-2 and setup DRB-1 successfully UE82 is configured with A1 measurement for SCell
    ...                 Addition
    ...         Step H. UE81 Release DRB-3 successfully UE81 is configured with A1 measurement for SCell
    ...                 Addition
    [Tags]    QC_344363    CA_LABEL-FTT(10Mhz_FDD_n71+60Mhz_TDD_n41+60Mhz_TDD_n41)
    clear counter files
    OnlineParamChange    ${actDrbProfileForCellAggrLevel_disabled}
    UE PDU Session Setup with multiple Qosflows    ue_id=81
    UE PDU Session Setup with multiple Qosflows    ue_id=82
    OnlineParamChange    ${actDrbProfileForCellAggrLevel_FR1_SA}
    UE DRB reconnect and Verify UE event A1    ue_id=81    qos_add=3    qos_del=3
    UE DRB Modification and Verify UE event A1    ue_id=82    qos_add=2    qos_del=1,3    pass_regexp=${add2_del1_3}
    UE DRB Modification and Verify UE event A1    ue_id=82    qos_add=1    qos_del=2    pass_regexp=${add1_del2}
    UE DEL DRB and Verify UE event A1    ue_id=81    qos_del=3    pass_regexp=${del3}
    Release UEs    ue_type=all
    Check Wireshark Log    ${CURDIR}${/}A2A_BA015${/}a2a.ini    wait_string=UEContextReleaseComplete::6
    check counters    pm_counters_expression=${PM_Counters_BA015}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/7cells_3T4F_8pipes

Modify Cfg
    Update Cfg    ue_param id=81,82 ue_nr_capabilities=${SA_Capa_3T3F} nr_usage_setting=voice_centric
    Update Cfg    amf_param id=1 full_nas_auth=on nia=null+aes nea=null+aes ims_voice_3gpp=on
    Update Cfg    ue_nr_capabilities id=81 voice_over_nr=on:on:off
    Update Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=2 5qi=7
    Update Cfg    set_qosflow id=3 5qi=8
    Update Cfg    set_qosflow id=4 5qi=9
    Update Cfg    set_qosflow id=5 5qi=71 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 qos_flows=1,2,3,4,5 qos_rules=1,2 default=on ue=1-6 amf=1

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir    check_sib=${False}

UE PDU Session Setup with Qosflow
    [Arguments]    ${ue_id}=81    ${cell_id}=11    ${qos_id}=1    ${gw_id}=1     ${qos_add}=4    ${pass_regexp}=${check_A1}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    qosflow_modify qos_flow=${qos_id} default=on
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${gw_id} nwslice=1    pass_regexp=${pass_regexp}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=${qos_add} by=amf
    ...    pass_regexp=${check_add_DRB4}

UE DRB reconnect and Verify UE event A1
    [Arguments]    ${ue_id}=81    ${cellfreq}=127450    ${qos_add}=4    ${qos_del}=1    ${qfi_id}=1    ${pass_regexp}=QoS Routing Table
    ${ScellAdd_A1_1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_del=${qos_del} by=amf
    ...    pass_regexp=rrcReconfigurationComplete
    ${ScellAdd_A1_2}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    Should Be Equal    ${ScellAdd_A1_1}    ${ScellAdd_A1_2}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=${qos_add} by=amf
    ...    pass_regexp=${pass_regexp}

UE DRB Modification and Verify UE event A1
    [Arguments]    ${ue_id}=81    ${qos_add}=4    ${qos_del}=1    ${pass_regexp}=QoS Routing Table
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=${qos_add} qosflows_to_del=${qos_del} by=amf
    ...    pass_regexp=${pass_regexp}

UE DEL DRB and Verify UE event A1
    [Arguments]    ${ue_id}=81    ${qos_del}=1    ${pass_regexp}=QoS Routing Table
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_del=${qos_del} by=amf
    ...    pass_regexp=${pass_regexp}

UE ADD DRB
    [Arguments]    ${ue_id}=81    ${qos_add}=4    ${pass_regexp}=QoS Routing Table
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=${qos_add} by=amf
    ...    pass_regexp=${pass_regexp}

Verify UE measurement after reestablishment DRB
    [Arguments]    ${ue_id}=81    ${cellfreq}=127450    ${qos_id}=4    ${pdu_id}=1    ${pass_regexp}=${check_add_DRB4}
    ${ScellAdd_A1_1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_del=${qos_id} by=amf
    ...    pass_regexp=QoS Routing Table
    ${ScellAdd_A1_2}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    Should Be Equal    ${ScellAdd_A1_1}    ${ScellAdd_A1_2}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=${qos_id} by=amf
    ...    pass_regexp=${pass_regexp}

Verify UE A1 configured after reestablishment DRB
    [Arguments]    ${ue_id}=81    ${cellfreq}=127450    ${qos_id}=4    ${pdu_id}=1    ${pass_regexp}=${check_A1}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_del=${qos_id} by=amf
    ...    pass_regexp=${pass_regexp}
    ${ScellAdd_A1_1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=${qos_id} by=amf
    ...    pass_regexp=Added QosFlow with QFI:2 fiveQI:9
    ${ScellAdd_A1_2}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    Should Be Equal    ${ScellAdd_A1_1}    ${ScellAdd_A1_2}

Verify UE measurement after ADD DRB online change actDrbProfileForCellAggrLevel
    [Arguments]    ${ue_id}=82    ${cellfreq}=127450    ${qos_add}=3
    OnlineParamChange    ${actDrbProfileForCellAggrLevel_disabled}
    ${ScellAdd_A1_1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    UE ADD DRB    ue_id=${ue_id}    qos_add=${qos_add}
    ${ScellAdd_A1_2}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    Should Be Equal    ${ScellAdd_A1_1}    ${ScellAdd_A1_2}
    OnlineParamChange    ${actDrbProfileForCellAggrLevel_FR1_SA}
    Verify UE measurement after reestablishment DRB    ue_id=82    qos_id=3    pass_regexp=Added QosFlow with QFI:3 fiveQI:8

UE PDU Session Setup with multiple Qosflows
    [Arguments]    ${ue_id}=81    ${cell_id}=11    ${qos_id}=3
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=${qos_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1    pass_regexp=${check_A1}
