*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    RAN_5G_TDD    CLOUD_5G_I_BOO_AP_LOO
...    team-PZ3_6    owner-christine.chen    release-5G24R3     CB007103    CRT
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_beamforming}
...    @{PARAMS_FOR_NRCELL1}
...    @{PARAMS_FOR_NRCELL2}
...    @{7103_PARA}

@{PARAMS_FOR_beamforming}
...    NRCELL-1:beamSet:basicBeamSet=beamSet_2
...    NRCELL-2:beamSet:basicBeamSet=beamSet_2
...    NRCELL-3:beamSet:basicBeamSet=beamSet_2
...    NRCELL-4:beamSet:basicBeamSet=beamSet_2
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=2 beams
...    NRCELLGRP-2:numberOfTransmittedSsBlocks=2 beams
...    NRCELLGRP-6:numberOfTransmittedSsBlocks=2 beams
...    NRCELLGRP-7:numberOfTransmittedSsBlocks=2 beams
...    NRCELL:pucchF3ModulationScheme=pi2bpsk

@{PARAMS_FOR_NRCELL1}
...    NRCELL-1:maxNumScellsDlFr1=4
...    NRCELL-1/NRREL-14:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-14:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-14:gNbId=1
...    NRCELL-1/NRREL-14:gNbIdLength=22
...    NRCELL-1/NRREL-14:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-14:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-14:lcrId=14
...    NRCELL-1/NRREL-14:nrDcAllowed=false
...    NRCELL-1/NRREL-14:removeNotAllowed=false
...    NRCELL-1/NRREL-14:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-14:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-14:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-14:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-14:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-14:isRplCellForPSCell=true
...    NRCELL-1/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-12:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-13:sCellAdditionMethod=blind

@{PARAMS_FOR_NRCELL2}
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-1:handoverAllowedSARedCap=forbidden
...    NRCELL-2/NRREL-1:lcrId=1
...    NRCELL-2/NRREL-1:nrDcAllowed=false
...    NRCELL-2/NRREL-1:removeNotAllowed=false
...    NRCELL-2/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:isRplCellForPSCell=true
...    NRCELL-2/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-3:gNbId=1
...    NRCELL-2/NRREL-3:gNbIdLength=22
...    NRCELL-2/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-3:handoverAllowedSARedCap=forbidden
...    NRCELL-2/NRREL-3:lcrId=3
...    NRCELL-2/NRREL-3:nrDcAllowed=false
...    NRCELL-2/NRREL-3:removeNotAllowed=false
...    NRCELL-2/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-3:isRplCellForPSCell=true
...    NRCELL-2/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-11:gNbId=1
...    NRCELL-2/NRREL-11:gNbIdLength=22
...    NRCELL-2/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-11:handoverAllowedSARedCap=forbidden
...    NRCELL-2/NRREL-11:lcrId=11
...    NRCELL-2/NRREL-11:nrDcAllowed=false
...    NRCELL-2/NRREL-11:removeNotAllowed=false
...    NRCELL-2/NRREL-11:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-11:isRplCellForPSCell=true
...    NRCELL-2/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-12:gNbId=1
...    NRCELL-2/NRREL-12:gNbIdLength=22
...    NRCELL-2/NRREL-12:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-12:handoverAllowedSARedCap=forbidden
...    NRCELL-2/NRREL-12:lcrId=12
...    NRCELL-2/NRREL-12:nrDcAllowed=false
...    NRCELL-2/NRREL-12:removeNotAllowed=false
...    NRCELL-2/NRREL-12:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-12:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-12:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-12:isRplCellForPSCell=true
...    NRCELL-2/NRREL-13:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-13:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-13:gNbId=1
...    NRCELL-2/NRREL-13:gNbIdLength=22
...    NRCELL-2/NRREL-13:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-13:handoverAllowedSARedCap=forbidden
...    NRCELL-2/NRREL-13:lcrId=13
...    NRCELL-2/NRREL-13:nrDcAllowed=false
...    NRCELL-2/NRREL-13:removeNotAllowed=false
...    NRCELL-2/NRREL-13:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-13:sCellOperationalMode=dlAndUl
...    NRCELL-2/NRREL-13:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-13:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-13:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-13:isRplCellForPSCell=true
...    NRCELL-2:maxNumScellsDlFr1=5

@{7103_PARA}
...    NRCELL-2:pucchF3Rel16Pi2BpskAlwaysOn=false
...    NRCELL-2:ulTransPrecodeCtl:ulTransPrecodeOffSinrThresh=150
...    NRCELL-2:ulTransPrecodeCtl:ulTransPrecodeOnSinrThresh=130
...    NRCELL-2:ulTransPrecodeCtl:ulTransPrecodePi2Bpsk=true
...    NRCELL-2:ulTransPrecodeCtl:ulTransPrePi2BpskPwrBoost=true
...    NRCELL-2:actRel16DmrsForPucchF3=true
...    NRCELL-2:actRel16DmrsForPusch=true
...    NRCELL-2:actUlDftSOfdm=true
#...    NRCELL-2/NRREL-1:sCellAdditionMethod=covBasedA1
#...    NRCELL-2/NRREL-11:sCellAdditionMethod=covBasedA1
#...    NRCELL-2/NRREL-12:sCellAdditionMethod=covBasedA1
#...    NRCELL-2/NRREL-13:sCellAdditionMethod=covBasedA1
#...    NRCELL-2/NRREL-3:sCellAdditionMethod=covBasedA1
#...    NRCELL-2:maxNumScellsDlFr1=5

${ue_capa_6cc_7103}    SEPARATOR=
...    FFA0F200475F7A6B5F8382086000D0017700400404820F990406902600C7FFE000503E0300C07012A1F851BF30342A08A5965440D00BDFF9
...    81C81B7FFDBFFEDFFF6FFFB7FFDBFFEDFFF3FFFD3FFEF8FCFC3FE3FFDBFFEDFFF6FFFB7FFDBFFEDFFF6FFFA8C026FF3FF6FF3FF16A000280
...    15B300078003300078000150FC41DF981A150452CB2A206805EFFCC0E40DBFFEDFFF6FFFB7FFDBFFEDFFF6FFF9FFFE9FFF7C7E7E1FF1FFED
...    FFF6FFFB7FFDBFFEDFFF6FFFB7FFD460137F9FFB7F9FF8B50001400AD98003C00198003C0000A87E26EFCC0D0A82296595103602F7FE6072
...    06DFFF6FFFB7FFDBFFEDFFF6FFFB7FFCFFFF4FFFBE3F3F0FF8FFF6FFFB7FFDBFFEDFFF6FFFB7FFDBFFEA300030000C09BFCFFDBFCFFC5A80
...    00A0056CC001E000CC001E0000541F0637E606854114B2CA881A017BFF3039036FFFB7FFDBFFEDFFF6FFFB7FFDBFFE7FFFA7FFDF1F9F87FC
...    7FFB7FFDBFFEDFFF6FFFB7FFDBFFEDFFF51804DFE7FEDFE7FE2D40005002B66000F00066000F00002A0F88DBF30342A08A5965440D00B5FF
...    981C81B7FFDBFFEDFFF6FFFB7FFDBFFEDFFF3FFFD3FFEF8FCFC3FE3FFBBFFEDFFF6FFFB7FFDBFFEDFFF518026FF3FF6FF3FF16A00028015B
...    300078003300078000008A2F13400389A001C28000E20800710400388C000000ADF8000000010389A000007F80000000A2F060003882001C
...    41000E23000713400389A000008ADF80000000513850001C41000E23000713400303800032B27800050062026C046174002F02409F81FEBD
...    B813F03FD7B7027E07FAF6E041C0FF5ED8090418C631FBFFFFF0BC00F800F000C0705807800703F09801E001806BB82C02C00380D7705805
...    80070200100000008004000000DE00C88000001644000002A00B066F2A68064F000029659427800054B2CA1200004A5965490000352CB2A0
...    1A8345D2A8AA557541AE80650100400804010020100400804008010100200404008010008020065010020040400801010020040400801010
...    04008040100200480200500200600400C01002801000168250

@{PUD_setup_successful_for_7103D02}
...    format3 setup
...    pi2BPSK enabled
...    dmrs-UplinkTransformPrecoding-r16 setup
...    nrofHARQ-ProcessesForPDSCH n16
...    powerBoostPi2BPSK TRUE
...    pcid:51, scellIdx:0
...    QoS Routing Table
...    rrcReconfigurationComplete

@{5CC_added_for_7103D02}
...    pcid:50, scellIdx:1
...    pcid:52, scellIdx:2
...    pcid:60, scellIdx:3
...    pcid:61, scellIdx:4
...    pcid:62, scellIdx:5
...    pcid:51, scellIdx:0
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 3 activated successfully at airphone
...    SCellIndex 4 activated successfully at airphone
...    SCellIndex 5 activated successfully at airphone
...    rrcReconfigurationComplete

@{trigger_TP_successful}
...    dmrs-UplinkTransformPrecodingPUCCH-r16 enabled
...    transformPrecoder enabled
...    tp-pi2BPSK enabled
...    powerBoostPi2BPSK TRUE
...    rrcReconfigurationComplete

@{PM_Counters_Check_7103_D002}
...    NRCELL-2:${ACC_UE_CONF_DFT_R16_DMRS_PUSCH}>0
...    NRCELL-2:${ACC_UE_CONF_R16_DMRS_PUCCH_F3}>0
...    NRCELL-2:${DEN_1_SEC_UE_SAMPLE}>0
...    NRCELL-2:${PUSCH_SUC_ANY_TX_DFT_R16_DMRS}>0
...    NRCELL-2:${PUSCH_INI_TX_DFT_R16_DMRS}>0
...    NRCELL-2:${PUSCH_SUC_INI_TX_DFT_R16_DMRS}>0
...    NRCELL-2:${PUSCH_UNSUC_TX_DFT_R16_DMRS}=0
...    NRCELL-2:${PUCCH_F3_NON_DTX_R16_DMRS}>0
...    NRCELL-2:${PUCCH_F3_DTX_R16_DMRS}=0

${ACC_UE_CONF_DFT_R16_DMRS_PUSCH}    M55165C00036
#This counter provides the number of UEs configured with DFT-s-OFDM and Rel16 DMRS for a physical uplink shared channel (PUSCH).
${ACC_UE_CONF_R16_DMRS_PUCCH_F3}    M55165C00037
#This counter provides the number of UEs configured with Rel16 DMRS for physical uplink control channel (PUCCH) format 3.
${DEN_1_SEC_UE_SAMPLE}    M55165C00038
#This counter provides the denominator for the calculation of the average number of UEs.
${PUSCH_SUC_ANY_TX_DFT_R16_DMRS}    M55370C00032
#This counter provides the sum of physical uplink shared channel (PUSCH) CRC-OK detections made for any transmission attempt on a PUSCH with
#DFT-s-OFDM and Rel16 DMRS over the measurement period.
${PUSCH_INI_TX_DFT_R16_DMRS}    M55370C00034
#This counter provides the sum of initial transmissions on a physical uplink shared channel (PUSCH) with DFT-s-OFDM and Rel16 DMRS over the
#measurement period.
${PUSCH_SUC_INI_TX_DFT_R16_DMRS}    M55370C00035
#This counter provides the sum of physical uplink shared channel (PUSCH) CRC-OK detections made for the initial transmission attempt over a PUSCH
#with DFT-s-OFDM and Rel16 DMRS over the measurement period.
${PUSCH_UNSUC_TX_DFT_R16_DMRS}    M55370C00036
#This counter provides the sum of unsuccessful last retransmissions on a physical uplink shared channel (PUSCH) with DFT-s-OFDM and Rel16 DMRS over
#the measurement period.
${PUCCH_F3_NON_DTX_R16_DMRS}    M55370C00033
#This counter provides the sum of physical uplink control channel (PUCCH) non-DTX detections for PUCCH format 3 with Rel16 DMRS over the measurement
#period.
${PUCCH_F3_DTX_R16_DMRS}    M55370C00037
#This counter provides the sum of physical uplink control channel (PUCCH) DTX detections for PUCCH format 3 with Rel16 DMRS over the measurement
#period.

*** Test Cases ***
CB007103-ET-D002_Interaction_with_CB009855_Extended_Interband_FR1_TDD_FDD_DL_CA_up_to_5CC_TDD_as_Pcell
    [Documentation]
    ...    1. This user scenario describes operation of extended Inter band DL TDD + FDD FR1 CA up to 6CCs (TDD as PCell) with Rel16 DMRS used for
    ...    PUSCH and PUCCH F3.
    ...    2. Configuration
    ...    feature enabled: CB011080 CB008311
    ...    Transform Precoding NRCELL.actUlDftSOfdm is set to TRUE
    ...    Rel16 DMRS for PUSCH (NRCELL.actRel16DmrsForPusch) is set to TRUE
    ...    Rel16 DMRS for PUCCH F3 (NRCELL.actRel16DmrsForPucchF3) is set to TRUE
    ...    NIDD parameter: NRCELL.pucchF3Rel16Pi2BpskAlwaysOn is false
    ...    QPSK is configured in NIDD (NIDD NRCELL.pucchF3ModulationScheme = qpsk_4psk) for PUCCH F3
    ...    NRBTS.NRCELL.ulTransPrecodeCtl.ulTransPrecodePi2Bpsk =true, NRBTS.NRCELL.ulTransPrecodeCtl.ulTransPrePi2BpskPwrBoost= true
    ...    cell operating without Beamforming
    ...    2. Test Case Steps:
    ...    1). UE1 register to TDD CELL large BWP.
    ...    2). tirgger A1 MR for scell addition. and Large DL traffic trigger bufferbased scell addition.
    ...    3). trigger tranform precoding switching on for UE1
    ...    4). tirgger gNB signals to UE MCS 0 or 1 and PUSCH is not scheduled by fallback DCI (DCI 0_0)
    ...    5). trigger tranform precoding switching off for UE1
    ...    6). check counter.
    [Tags]    D002    CA_LABEL-TTFFF(100M_TDD_n41+100M_TDD_n77+10M_FDD_n66+10M_FDD_n66+10M_FDD_n71)    christine.chen    QC_46961
    Deactive Pathloss
    SA UE attach for 7103    ue_id=1    cell_id=2    pass_regexp=${PUD_setup_successful_for_7103D02}
    Send Traffic    ue_id=1    mbps_dl=170    mbps_ul=170
    Check Traffic for SA    ue_id=1    dl_tput=0    ul_tput=0
    Send A1 MR    ue_id=1    pass_regexp=${5CC_added_for_7103D02}
    Check Traffic for SA    ue_id=1    dl_tput=0    ul_tput=0
    Adjust Sinr Target Pathloss    1    110    pass_regexp=${trigger_TP_successful}
    Tigger MCS0_1 For Pusch    sinr_target_pathloss=138
    Check Traffic for SA    ue_id=1    dl_tput=0    ul_tput=0
    Deactive Pathloss    ue_id=1
    Check Traffic for SA    ue_id=1    dl_tput=0    ul_tput=0
    Check Counters    ${PM_Counters_Check_7103_D002}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/8cells_4T4F_2N78_2N41_2N66_N71_N25

Modify Cfg
    Update Cfg    set_qosflow id=2 5qi=7
    Update Cfg    set_qosflow id=3 5qi=8
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 qos_flows=1,2,3 qos_rules=1,2 default=on ue=1-6 amf=1

Deactive Pathloss
    [Arguments]    ${ue_id}=1    ${profile_id}=1
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=ul_sinr action=deactivate profile_id=${profile_id}
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=ul_sinr action=deactivate profile_id=2

Adjust Sinr Target Pathloss
    [Arguments]    ${ue_id}=1    ${sinr_target_pathloss}=130    ${pusch_type}=typeB    ${pass_regexp}=rrcReconfigurationComplete
    Execute Egate Command    ul_sinr_testmode_nr profile_id=2 sinr_target_pusch=-30
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=ul_sinr action=activate profile_id=2
    Execute Egate Command    ul_sinr_testmode_nr profile_id=1 pathloss=${sinr_target_pathloss}    pass_regexp=CTRL_AP_TEST_UL_SINR_NR
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=ul_sinr action=activate profile_id=1    pass_regexp=${pass_regexp}
    ...    timeout=180
    Execute Egate Command    ul_cell_noise_testmode_nr profile_id=1 noise_pusch=-800 noise_pucch=-800
    Execute Egate Command    cell_testmode_set_nr cell_id=2 gnb=2 testmode=ul_cell_noise profile_id=1 action=activate

Tigger MCS0_1 For Pusch
    [Arguments]    ${sinr_target_pathloss}=120
    Execute Egate Command    ul_sinr_testmode_nr profile_id=1 pathloss=${sinr_target_pathloss}     #sinr -0.xxx -1.xxx db
    Sleep    5s             # for uplink signal stable

SA UE attach for 7103
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${pdu_id}=1    ${pass_regexp}=${ue1_expect_regexp}
    Set UE Capability    ue_id=${ue_id}    UE_Capabilities=${ue_capa_6cc_7103}
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=2
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered state.
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_id} gw=${pdu_id} ue=${ue_id} nwslice=1    pass_regexp=${pass_regexp}

Send Traffic
    [Arguments]    ${ue_id}=1    ${mbps_dl}=170    ${mbps_ul}=170
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=${mbps_dl}    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=8 mbps=${mbps_ul}    UE ${ue_id}: UDP UL

Check Traffic for SA
    [Arguments]    ${ue_id}=31    ${dl_tput}=10    ${ul_tput}=10    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${dl_throughput}/1000 > ${dl_tput}
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput}/1000> ${ul_tput}
    
Set UE Capability
    [Arguments]    ${ue_id}=1    ${UE_Capabilities}=${ue_capa}    ${wait_timer}=0.5
    Execute Egate Command    ue_param id=${ue_id} ue_nr_capabilities=${UE_Capabilities}    sleep_time=${wait_timer}

Send A1 MR
    [Arguments]    ${ue_id}=1    ${carrierfreq}=635616    ${pass_regexp}=${A002_6CC_expect_regexp}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    ${cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=127 srsrq_nr=127
    Execute Egate Command    ${cmd}    ${pass_regexp}

