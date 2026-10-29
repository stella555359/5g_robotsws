*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CRT    owner-wen.y.xu    team-SG2    release-SBTS23R4
...    CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD
Resource          ../../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}    fddtdd_sansa_cmwv/6cells_4T2F

@{PARAMS_IN_SCF}
...    @{CB010217_HO_other}    @{5GC000749}    @{CA_Common_Config}    @{event_A2A3}
...    @{PARAMS_FOR_5QI9}    @{PARAMS_FOR_5QI5}    @{PARAMS_FOR_5QI1}
...    @{XN_NRADJGNB_NRADJNRCELL}    @{NRREL}

@{CB010217_HO_other}
...    NRBTS:actVoiceFallbackDuringHOPrep=voiceFallbackDuringXnHOPrep
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS:actIncXn=true
...    NRBTS:actConflictConfiguration=true
...    NRCELL-12:actVoNR=true
...    NRPMRNL-1:miNrRelReportCu=5min
...    NRBTS-1:drbInactivityTimerSA=6000
...    NRBTS:timerXnUeProcGuard=6000
...    NRBTS:timerHOGuard=6000
...    NRCELL:cellDepType=SA
...    delete:NRBTS/NRCELL:configuredEpsTac

@{5GC000749}
...    NRBTS:actNormVCFallback=true
...    NRBTS:actRedirect=true
...    NRCELL-1:voiceFBMode=disabled
...    NRCELL-2:voiceFBMode=disabled
...    NRCELL-3:voiceFBMode=disabled
...    NRCELL-4:voiceFBMode=disabled
...    NRCELL-11:voiceFBMode=disabled
...    NRCELL-12:voiceFBMode=redirection
...    NRCELL-12/NRREDRT-1:redirPrio=1
...    NRCELL-12/NRREDRT-1:redirFreqEutra=38100
...    NRCELL-12/NRREDRT-1:redirRat=eutra
...    NRCELL-12:actCDrx=true
...    delete:NRCELL-12/NRREDRT-1:redirSsbScs
...    delete:NRCELL-12/NRREDRT-1:redirFreqNr

@{CA_Common_Config}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:actConflictConfiguration=true
...    NRBTS:sCellActivationMethod=blind
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fr1Tdd_Sa
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS:caConfigurationSupport=2CCDL_2CCUL

@{PARAMS_FOR_5QI9}
...    NRBTS/NRDRB_5QI-5:fiveqiValueList=9
...    NRBTS/NRDRB_5QI-5:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-14
...    NRBTS/NRDRB-14:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-2
...    NRBTS/NRDRB-14:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRBTS/NRDRB-14:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2
...    NRBTS/NRDRB-14:resType=nonGBR
...    NRBTS/NRDRB-14:rlcMode=RLC_AM
...    NRBTS/NRDRB_MAC-2:lcgid=2
...    NRBTS/NRDRB_MAC-2:schedulPrio=5
...    NRBTS/NRDRB_PDCP-2:cuFlowControlProfId=1
...    NRBTS/NRDRB_RLC_AM-2:duFlowControlProfId=1

@{PARAMS_FOR_5QI5}
...    NRBTS/NRDRB_5QI-1:fiveqiValueList=5
...    NRBTS/NRDRB_5QI-1:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-10
...    NRBTS/NRDRB-10:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...    NRBTS/NRDRB-10:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRBTS/NRDRB-10:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2
...    NRBTS/NRDRB-10:resType=nonGBR_Signaling
...    NRBTS/NRDRB-10:rlcMode=RLC_AM
...    NRBTS/NRDRB_MAC-3:lcgid=0
...    NRBTS/NRDRB_MAC-3:schedulPrio=4

@{PARAMS_FOR_5QI1}
...    NRBTS/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    NRBTS/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRBTS/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-3
...    NRBTS/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS/NRDRB-15:dscp=46
...    NRBTS/NRDRB-15:maxDddsPeriodCpuOvld=40
...    NRBTS/NRDRB-15:numSduDiscard=1
...    NRBTS/NRDRB-15:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-15:queuingDelaySduDiscardThreshold=200
...    NRBTS/NRDRB-15:resType=GBR
...    NRBTS/NRDRB-15:rlcMode=RLC_UM
...    NRBTS/NRDRB-15:schedulWeight=1
...    NRBTS/NRDRB-15:sduDiscardIntervalTmr=100
...    NRBTS/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS/NRDRB-15:maxDataRateGbrUl=1000
...    NRBTS/NRDRB-15:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-15:maxTransferDelayGbr=20
...    NRBTS/NRDRB-15:discardTimer=1500ms
...    NRBTS/NRDRB_MAC-4:lcgid=4
...    NRBTS/NRDRB_MAC-4:schedulPrio=4
...    NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    NRBTS/NRDRB_RLC_UM-1:ulTReassemblyUm=ms40
...    NRBTS/NRDRB_PDCP-3:tReorderingDl=ms300
...    NRBTS/NRDRB_PDCP-3:tReorderingUl=ms300
...    NRBTS/NRDRB_PDCP-3:pdcpBufDiscardEnabled=false

@{event_A2A3}
...    NRCELL:a2MeasRedirectEnabled=none
...    NRCELL:a2MeasRedirectSsbRsrp:a2HysteresisRedirectSsbRsrp=0
...    NRCELL:a2MeasRedirectSsbRsrp:a2ThresholdRedirectSsbRsrp=45
...    NRCELL:a2MeasRedirectSsbRsrp:a2TimeToTriggerRedirectSsbRsrp=ms480
...    NRCELL:a2MeasRedirectSsbRsrq:a2HysteresisRedirectSsbRsrq=0
...    NRCELL:a2MeasRedirectSsbRsrq:a2ThresholdRedirectSsbRsrq=49
...    NRCELL:a2MeasRedirectSsbRsrq:a2TimeToTriggerRedirectSsbRsrq=ms480
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:sMeasConfigSsbRsrp=1
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=15
...    NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRCELL:measGapSelectionSA=favourUeThroughput

@{XN_NRADJGNB_NRADJNRCELL}
...    XNLINK-1:cPlaneIpAddr=10.0.1.124
#sim gnb4
...    NRBTS-1/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS-1/NRADJGNB-1:gNbIdLength=22
...    NRBTS-1/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS-1/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS-1/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS-1/NRADJGNB-1:gNodeBId=36
...    NRBTS-1/NRADJGNB-1:xnLinkRef=1
...    NRBTS-1/NRADJNRCELL-1:cellDepType=SA
...    NRBTS-1/NRADJNRCELL-1:fiveGsTac=0
...    NRBTS-1/NRADJNRCELL-1:freqBandIndicatorNR=71
...    NRBTS-1/NRADJNRCELL-1:gNbId=36
...    NRBTS-1/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS-1/NRADJNRCELL-1:lcrId=1
...    NRBTS-1/NRADJNRCELL-1:nrarfcn=126900
...    NRBTS-1/NRADJNRCELL-1:physCellId=382
...    NRBTS-1/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS-1/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS-1/NRADJNRCELL-1:gnbPlmn:mncLength=3

@{NRREL}
#real gnb cell3
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-1:gNbId=1
...    NRCELL-12/NRREL-1:gNbIdLength=22
...    NRCELL-12/NRREL-1:lcrId=3
...    NRCELL-12/NRREL-1:removeNotAllowed=false
...    NRCELL-12/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-1:gnbPlmn:mncLength=3
#sim gnb4 cell1
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-2:gNbId=36
...    NRCELL-12/NRREL-2:gNbIdLength=22
...    NRCELL-12/NRREL-2:lcrId=1
...    NRCELL-12/NRREL-2:removeNotAllowed=false
...    NRCELL-12/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-2:gnbPlmn:mncLength=3

@{PM_Counters_Check}
...    NRCELL-12:${XN_HO_CANCEL_SENT}=0
...    NRCELL-12:${FAIL_HO_NRREL_PREP}=0
...    NRCELL-12:${NG_FLOW_STP_FAIL_FALBACK_5QI1}=0
...    NRCELL-12:${NRRCC_RRC_RELEASE_REDIR_LTE}=0
...    NRCELL-12:${XN_HO_PREP_CNC_SRC_EPSFB}=0
...    NRCELL-12:${NG_FLOW_STP_FAIL_HO_5QI1}=5
...    ${NRRCC_RRC_RELEASE_SENT}=0
#    ...    ${NRRCD_RRC_RELEASE_SENT}=0

${XN_HO_CANCEL_SENT}    M55143C00003    #Number of outgoing Handover Cancel sent to Target gNB
${FAIL_HO_NRREL_PREP}    M55153C00003    #HO Prep failures for Intra-gNB Intra/Inter-DU and Inter-gNB Xn HO for SA per NRREL
${NG_FLOW_STP_FAIL_FALBACK_5QI1}    M55125C09519    #Number of 5QI-1 QoS Flows setup failure due to Fallback
${NRRCC_RRC_RELEASE_REDIR_LTE}    M55124C01502    #Number of RRC Releases with LTE frequency redirection information
${XN_HO_PREP_CNC_SRC_EPSFB}    M55143C00012    #Number of Xn handover preparations canceled due to EPS fallback
${NG_FLOW_STP_FAIL_HO_5QI1}    M55125C00035    #Number of 5QI-1 QoS Flow setup failures due to ongoing Xn handover
${NRRCC_RRC_RELEASE_SENT}    M55124C00001    #Number of RRC RELEASE messages sent (CU counter)
${NRRCD_RRC_RELEASE_SENT}    M55127C01001    #Number of RRC RELEASE messages sent (DU counter)

@{scell_add}
...    Setup QosFlow with QFI:1 fiveQI:5
...    pcid:52, scellIdx:1
...    SCellIndex 1 activated successfully at airphone

@{5qi1_fail_HO_success}
...    Adding QosFlow with QFI:2 5QI:1
...    PDU Session Resource Modify Unsuccessful Transfer
...    Inter-eNB handover

@{HO_success}
...    Inter-eNB handover
...    pcid:52, scellIdx:1
...    SCellIndex 1 activated successfully at airphone

@{UE81_UE83_UE84}    81    83    84
@{UE82_UE85}    82    85

${SA_Capa_perUE_Full_no_VONR}    SEPARATOR=
...    E9A09000575F5A13160003C0A02C1262E003387A0609B20C39F30C7942C0E098040623807DC6C28C0D608C21A0810748046D6C98AB1A1CF88E3D033
...    EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE000280381506C41D608C21A081078804656C98AB121CFB027C471E31238F21CFA8E7C
...    C31E50B0381C3C27F6000001FD8000000500702A8D89BAC1184341020E9008C2D931544439F11C788E3D033EC09F18E7CC31E50B0381C3C17003FF0
...    01C00FFC000500702B8F88DAC1184341020F94022AB64C55850E7C471E300000000000000000010387809FFF000007FFC000001401C00F78789A001
...    C4100000216020541E14000711800000858158788C001C41000006160561E14000710400000858158789A001C46000002160562E230007104003882
...    0000142C0AC3C28000E268000060B02B17134003882001C28000008160562E26800711800388C0000082C0AC5C28000E20800711800001058158B85
...    0001C41000E208000020B02B17134003882001C46000004160562E14000711800388C0000082C0AC5C4D000E2300070A000002058158788C001C460
...    00006160401C0468051013602082ABB07C28913639F0E14489B1CF870A244D8E7C3851226C73E1C28913639F0E2448913639F0E14081B1CF8112040
...    81B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF810A040D8E7C00170F18C6318C6318C6318
...    C61E81601E00140E0601C0C01501C0018090010180F82400800000004000008020000000100000200800002004000018020000100100000A0080040
...    10040100000C0080000700400200000008000080040000480200000C010000140080000B004002048120080000C0339535953582958195833582B59
...    4B5933580B581B58095811583B40D04000025949410000196525040000A594901000039652404000125949010000596524040001A59490100007965
...    2404000225949010000996524040002A5949010000B96525040003259490100003165240334AAAE955552A8BA55154162A82C55068AA531549A2A80
...    C55028AA4D5541E2808BC04A8140A05028140A05028140A05028140A05028140A000C10100C018040080108080100402018030804008010100C0180
...    40300608080600C02018030804008010100C018040080110080600C02018030080600C10100200804008021AA1F000102030406070A0B0C0D101112
...    131418191B1C1D1F2125262728292A2D2F4141824

${SA_Capa_perUE_Full}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623807DC6C28C0D608C21A08107482406D6C98AB1A1CF88E3D
...    033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00088000E0541B107582308682041E2090195B262AC4873EC09F11C78C48E3C873
...    EA39F30C7942C0E070F09FD8000007F600000044000702A8D89BAC1184341020E90480C2D931544439F11C788E3D033EC09F18E7CC31E50B0381C3C
...    17003FF001C00FFC00110001C0AE3E236B04610D04083E50480AAD931561439F11C78C00000000000000000040E1E027FFC00001FFF00000110001C
...    00F78789A001C4100000216020541E14000711800000858158788C001C41000006160561E14000710400000858158789A001C46000002160562E230
...    0071040038820000142C0AC3C28000E268000060B02B17134003882001C28000008160562E26800711800388C0000082C0AC5C28000E20800711800
...    001058158B850001C41000E208000020B02B17134003882001C46000004160562E14000711800388C0000082C0AC5C4D000E2300070A00000205815
...    8788C001C46000006160401C0468051013602086A0BB07C28913639F0E14489B1CF870A244D8E7C3851226C73E1C28913639F0E2448913639F0E140
...    81B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF810A040D8E7C00170F18C6
...    318C6318C6318C61E8260078005038280381804A00E000C0480080C07C120040000000200000401000000008000010040000100200000C010000080
...    08000050040020080200800006004000038020010000000400004002000024010000060080000A004000058020010240900400006019CA9ACA9AC14
...    AC0CAC19AC15ACA5AC99AC05AC0DAC04AC08AC1DA0682000012CA4A080000CB29282000052CA48080001CB29202000092CA48080002CB292020000D
...    2CA48080003CB29202000112CA48080004CB29202000152CA48080005CB29282000192CA480800018B292019A55574AAAA9545D2A8AA0B154162A83
...    455298AA4D154062A8145526AAA0F142405E02540A05028140A05028140A05028140A05028140A05000608080600C02004008404008020100C01840
...    2004008080600C02018030404030060100C018402004008080600C02004008804030060100C018040300608080100402004010D50F8000810182030
...    385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C168

*** Test Cases ***
CB010217-ET-A003_Verify_Configure_voiceFBMode_CA_blind_scell_rejection_of_Voice_Service_during_XN_HO_Preparation_and_Execution_Phase
    [Documentation]
    ...    1. This user scenario verifies that during the XN-HO preparation and execution phase, after triggering the event 5QI-1,
    ...       where the condition for triggering EPS fallback is not satisfied
    ...    2. pre-condition
    ...         CA : FDD +TDD
    ...         UE81/UE82 no VoNR capability (5QI9_5QI5)
    ...         UE83/UE84/UE85 has VoNR capability (5QI9_5QI5_5QI1)
    ...    3. Test Case Steps:
    ...         a. setup XN link
    ...         b. SA UE Register And PDU Setup With Blind 1 Scell Addition
    ...         c. Trigger Rejection during XN HO Preparation:
    ...            1) Trigger XN Handover Complete delay 5s
    ...            2) Trigger UE HO from real-gNB Pcell-12(127230)+Scell-3 to sim-gNB4 cell-1(127230)
    ...            3) PDU Session Resource Modify to VoNR Call -> add 5QI1 failed and HO successful
    ...            4) Trigger UE HO from sim-gNB4 to real-gNB
    ...         d. Trigger Rejection during XN HO Execution
    ...            1) Trigger RRC Reconfiguration Complete delay 5s
    ...            2) Trigger UE HO from real-gNB cell-12(127230)+Scell-3 to sim-gNB4 cell-1(127230)
    ...            3) PDU Session Resource Modify to VoNR Call -> add 5QI1 failed and HO successful
    ...            4) Trigger UE HO from sim-gNB4 to real-gNB
    ...         e. online modify CELL-12:actVoNR=false
    ...         f. repeat step-b and step-d
    ...         g. check counter
    [Tags]    A003
    Check XN Links up and Add UEs History Information List
    SA UE Register And PDU Setup With Blind 1 Scell Addition    ${UE81_UE83_UE84}
    Trigger Rejection during XN HO Preparation    ue_id=83
    Trigger Rejection during XN HO Execution    ue_id=81
    Trigger Rejection during XN HO Execution    ue_id=84
    Delta Commission Parameters    NRCELL-12:actVoNR=false
    SA UE Register And PDU Setup With Blind 1 Scell Addition    ${UE82_UE85}
    Trigger Rejection during XN HO Execution    ue_id=82
    Trigger Rejection during XN HO Execution    ue_id=85
    Check Counters    ${PM_Counters_Check}
    Release UEs    ue_type=all

*** Keywords ***
Modify Cfg
    Update Cfg Param    set_cell id=1 gnb=4 nr_arfcn=136100:126900 gscn=1584
    Update Cfg Param    amf_param id=1 ims_voice_3gpp=on voice_fallback=on
    Update Cfg Param    set_ue simulated id=81 enb=2 cell=12
    Update Cfg Param    set_ue simulated id=82 enb=2 cell=12
    Update Cfg Param    set_ue simulated id=83 enb=2 cell=12
    Update Cfg Param    set_ue simulated id=84 enb=2 cell=12
    Update Cfg Param    set_ue simulated id=85 enb=2 cell=12
    Update Cfg Param    ue_param id=81 ue_nr_capabilities=${SA_Capa_perUE_Full_no_VONR}    #no VoNR
    Update Cfg Param    ue_param id=82 ue_nr_capabilities=${SA_Capa_perUE_Full_no_VONR}    #no VoNR
    Update Cfg Param    ue_param id=83 ue_nr_capabilities=${SA_Capa_perUE_Full}    #has VoNR
    Update Cfg Param    ue_param id=84 ue_nr_capabilities=${SA_Capa_perUE_Full}    #has VoNR
    Update Cfg Param    ue_param id=85 ue_nr_capabilities=${SA_Capa_perUE_Full}    #has VoNR
    Update Cfg    ue_nr_capabilities id=83-85 voice_over_nr=on:on:off
    Update Cfg    set_qosflow id=1 5qi=5 default=on
    Update Cfg    set_qosflow id=2 5qi=1
    Update Cfg    set_qosflow id=3 5qi=9
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_qosrule id=3 proto=udp qos_flow=3
    Update Cfg Param    set_nwslice id=1 default=on ue=all qos_flows=1,2,3 qos_rules=1,2,3

Add UEs History Information List
    Execute Egate Command    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=97
    Execute Egate Command    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=4 time_ue_stayed_in_cell=98
    Execute Egate Command    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=99
    Execute Egate Command    ue_history_information_list id=1 action=commit
    Execute Egate Command    ue_enb_param id=81-85 ue_history_list=1

SA UE Register And PDU Setup With Blind 1 Scell Addition
    [Arguments]    ${ue_list}=1
    FOR    ${ue_id}    IN    @{ue_list}
        Execute Egate Command    ue_register id=${ue_id}    NG RM Registered
        Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
        Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1    ${scell_add}
    END

Trigger UE HO from real-gNB to sim-gNB4
    [Arguments]    ${ue_id}=1    ${pass_regexp}=None
    ${A3_measid}    get nr meas id for specific type and frequency    ue_id=${ue_id}    carrierfreq=126750    event_type=A3
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${A3_measid} event=A3 srsrp_nr=30 phycell_id=382 nrsrp_nr=85
    ...    ${pass_regexp}    sleep_time=2

Trigger UE HO from sim-gNB4 to real-gNB
    [Arguments]    ${ue_id}=1
    ${A3_measid}    get nr meas id for specific type and frequency    ue_id=${ue_id}    carrierfreq=126750    event_type=A3
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${A3_measid} event=A3 srsrp_nr=30 phycell_id=61 nrsrp_nr=85    ${HO_success}

PDU Session Resource Modify to VoNR Call
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=2 by=amf    ${5qi1_fail_HO_success}

Check XN Links up and Add UEs History Information List
    object should exist    XNLINK-1:xnLinkStatus=available
    Add UEs History Information List

Trigger Rejection during XN HO Preparation
    [Arguments]    ${ue_id}=1
    Execute Egate Command    gnb_xn_handover_preparation_param id=4 action=delayed_rsp time_to_wait=v5s    #Trigger XN Handover Complete delay
    Trigger UE HO from real-gNB to sim-gNB4    ${ue_id}    SNStatusTransfer in WAIT HANDOVER REQUEST
    PDU Session Resource Modify to VoNR Call    ${ue_id}
    Trigger UE HO from sim-gNB4 to real-gNB    ${ue_id}
    Execute Egate Command    gnb_xn_handover_preparation_param id=4 reset

Trigger Rejection during XN HO Execution
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_nr_rrc_reconf_param id=${ue_id} if_contains=any delay=5000    #Trigger RRC Reconfiguration Complete delay
    Trigger UE HO from real-gNB to sim-gNB4    ${ue_id}    Hit on error cases presence=any action=delay
    PDU Session Resource Modify to VoNR Call    ${ue_id}
    Trigger UE HO from sim-gNB4 to real-gNB    ${ue_id}
    Execute Egate Command    ue_nr_rrc_reconf_param id=${ue_id} reset
