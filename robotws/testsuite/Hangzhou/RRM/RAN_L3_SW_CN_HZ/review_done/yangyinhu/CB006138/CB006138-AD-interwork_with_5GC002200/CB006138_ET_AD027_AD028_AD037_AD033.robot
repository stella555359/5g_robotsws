*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CXT    master_classicalbts_all    STATE_CONFIGURED
...               FR1    CN2    team-SG2    owner-cathy.mao    owner-dandan.chen    release-SBTS22R1
...               PRI-Medium    CB006138-AD    CLOUD_5G_I_BLLL_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD
Resource         ../../../../resources/DevHZ5_resource.robot


*** Variables ***
${TL_TYPE_PATH}    fddtdd_sansa_cmwv/L1B/4cell


@{PARAMS_IN_SCF}
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=${CA_SUPPORT_LIST}
...    NRBTS-1:actFdmEnhancedScheduling=true
...    NRBTS-1:actFdmScheduling=true
...    NRBTS-1:actLteNrDss=false
...    NRCELL:actPrachMultiplexing=true
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL:pucchF3ModulationScheme=pi2bpsk
...    NRCELL:pucchF3MaxCodeRate=zeroDot08
...    NRBTS-1/NRCELL-11:msg1FrequencyStart=12
...    NRBTS-1/NRCELL-11:pucchF3MaxCodeRate=zeroDot08
...    NRBTS-1/NRCELL-11:pucchModeSelect=longPucch
...    NRBTS-1/NRCELL-11:actPrachMultiplexing=true
...    NRBTS-1/NRCELL-11:pucchF3ModulationScheme=pi2bpsk
...    NRBTS-1/NRCELL-12:msg1FrequencyStart=13
...    NRBTS-1/NRCELL-12:pucchF3MaxCodeRate=zeroDot08
...    NRBTS-1/NRCELL-12:pucchModeSelect=longPucch
...    NRBTS-1/NRCELL-12:actPrachMultiplexing=true
...    NRBTS-1/NRCELL-12:pucchF3ModulationScheme=pi2bpsk
...    NRBTS-1/NRCELL-1:type0CoresetConfigurationIndex=10
...    NRBTS-1/NRCELL-1:type0SearchSpaceConfigurationIndex=5
...    NRBTS-1/NRCELL-1:actBeamforming=true
...    NRBTS-1/NRCELL-1:beamSet:basicBeamSet=beamSet_2
...    NRBTS-1/NRCELL-1:beamSet:leftEdgeAngle=60
...    NRBTS-1/NRCELL-1:beamSet:nrBtsBeamRefinementP2=false
...    NRBTS-1/NRCELL-1:beamSet:rightEdgeAngle=60
...    NRBTS-1/NRCELL-1:dlMimoMode=8x4 Closed Loop Spatial Multiplexing
...    NRBTS-1/NRCELL-1:nrCellType=8DL4UL
...    NRBTS-1/NRCELL-1:periodicCsiAcquisition:csirsPower=6
...    NRBTS-1/NRCELL-1:periodicCsiAcquisition:maxCsirsNumber=4
...    NRBTS-1/NRCELL-1:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=4
...    NRBTS-1/NRCELL-1:actAperCsi=true
...    NRBTS-1/NRCELL-1:actCDrx=true
...    NRBTS-1/NRCELL-1:drxProfile1:drxInactivityTimer=40ms
...    NRBTS-1/NRCELL-1:drxProfile1:drxLongCycle=80ms
...    NRBTS-1/NRCELL-1:drxProfile1:drxOnDurationTimer=20ms
...    NRBTS-1/NRCELL-1:drxProfile1:drxRetransTimerDl=16slot
...    NRBTS-1/NRCELL-1:drxProfile1:drxRetransTimerUl=16slot
...    NRBTS-1/NRCELL-1:pucchF3MaxCodeRate=zeroDot08
...    NRBTS-1/NRCELL-1:pucchModeSelect=longPucch
...    NRBTS-1/NRCELL-1:actPrachMultiplexing=true
...    NRBTS-1/NRCELL-1:pucchF3ModulationScheme=pi2bpsk
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=2 beams
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:lcrId=11
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:nrDcAllowed=false
...    NRCELL-1/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=1
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-2:lcrId=12
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:nrDcAllowed=false
...    NRCELL-1/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3

${CA_SUPPORT_LIST}    ca_Fr1Tdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fr1Tdd_Nsa,ca_Fdd_Fdd,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Nsa,ca_Fr1Tdd_Fdd_Sa



${FDD_SCELL1_FOR_NRCELL1}    NRCELL-11
${FDD_SCELL2_FOR_NRCELL1}    NRCELL-12


&{CELLS_SSBFREQ}
...     NRCELL-1=509790
...     NRCELL-2=527790
...     NRCELL-11=127950
...     NRCELL-12=125050


@{VALID_SCELL_ADD_AD033}
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=75
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=95
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-1:a2MeasSCellRelEnabled=rsrp


*** Test Cases ***
CB006138-ET-AD027_Pcell_is_downgrad_with_ACSI_enabled_on_Pcell_during_SCell_addition_with_UEcapa_CSIRS_is_not_enough
    [Documentation]
    ...    1. The purpose of this test case is to verify ACSI enabled on pcell, when it need downgrade during scell
    ...    addition with UE capa CSIRS NOT enough, the ACSI will be disable.
    ...    2. UE CAPA: band 41+ band71 +band 71
    ...                band 41: nr-rrc.supportedBandCombinationList_v1540->
    ...                         nr-rrc.maxNumberSimultaneousNZP_CSI_RS_ActBWP_AllCC=8
    ...                         totalnumberportsimultaneousNZP-CSI-RS-ActBWP-AllCC=64
    ...                         nr-rrc.csi_RS_IM_ReceptionForFeedback_element->
    ...                         nr-rrc.maxNumberSimultaneousNZP_CSI_RS_PerCC=8
    ...                         totalnumberportsimultaneousNZP-CSI-RS-perCC=64
    ...    Test Case Steps:
    ...         step1. setup CA TFF UE
    ...         Expected Results:
    ...                two FDD scells added, but ACSI on pcell disable.
    [Tags]    CB006138-AD027    Owner_dandchen
    [Timeout]    60 min
    Before_ue_attach_AD027
    UE Attach and L3 Normal Call    ue_id=81    pdu_gw_id=1
    Check Two Scell Added Successfully    ${FDD_SCELL1_FOR_NRCELL1}    ${FDD_SCELL2_FOR_NRCELL1}
    Verify Throuput on Pscell and Scell    ue_id=81    pdu_gw_id=1
    Release Ues    ue_type=all
    Check WireShark Log    ${CURDIR}${/}a2a_AD027${/}a2a.ini
    ...    wait_string=UEContextModificationResponse::14


CB006138-ET-AD028_only_one_scell_can_be_added_during_SCell_addition_with_UE_capability_CSIRS_is_not_enough
    [Documentation]
    ...    1. The purpose of this test case is to verify only one scell can be added as UE capa CSIRS NOT enough
    ...    2. UE CAPA: band 41+ band71 +band 71
    ...                band 41: nr-rrc.supportedBandCombinationList_v1540->
    ...                         nr-rrc.maxNumberSimultaneousNZP_CSI_RS_ActBWP_AllCC=2
    ...                         totalnumberportsimultaneousNZP-CSI-RS-ActBWP-AllCC=64
    ...                         nr-rrc.csi_RS_IM_ReceptionForFeedback_element->
    ...                         nr-rrc.maxNumberSimultaneousNZP_CSI_RS_PerCC=2
    ...                         totalnumberportsimultaneousNZP-CSI-RS-perCC=32
    ...    Test Case Steps:
    ...         step1. setup CA TFF UE
    ...         Expected Results:
    ...                only one FDD scell can added, another one FDD scell add failed as no radio resource
    [Tags]    CB006138-AD028    Owner_dandchen
    [Timeout]    60 min
    Before_ue_attach_AD028
    UE Attach and L3 Normal Call    ue_id=81    pdu_gw_id=2
    Check One Scell Added Successfully    ${FDD_SCELL1_FOR_NRCELL1}
    Verify Throuput on TF_CA    ue_id=81    pdu_gw_id=2
    Release Ues    ue_type=all
    Check WireShark Log    ${CURDIR}${/}a2a_AD028${/}a2a.ini
    ...    wait_string=UEContextModificationResponse::14

CB006138-ET-AD037_CNI70851-D_Support_3CC_CA_with_a_TDD_PCell_where_both_5GC002200_and_DRX_enabled_in_SA_mode_when_blind_scell_addtion_with_TFF
    [Documentation]
    ...    1. This user scenario validates the successful UE configuration in SA option 2 mode with 3CC CA
    ...    enabled in TDD PCell and 5GC002200 enabled in TDD PCell and DRX enabled in TDD PCell.
    ...    2. UE CAPA: band 41+ band71 +band 71
    ...                band 41: nr-rrc.supportedBandCombinationList_v1540->
    ...                         nr-rrc.maxNumberSimultaneousNZP_CSI_RS_ActBWP_AllCC=8
    ...                         totalnumberportsimultaneousNZP-CSI-RS-ActBWP-AllCC=256
    ...                         nr-rrc.csi_RS_IM_ReceptionForFeedback_element->
    ...                         nr-rrc.maxNumberSimultaneousNZP_CSI_RS_PerCC=8
    ...                         totalnumberportsimultaneousNZP-CSI-RS-perCC=64
    ...    2. Test Case Steps:
    ...         step1. UE register and PDU session setup
    ...         Expect result: UE attach sucessul and PDU session is ok
    ...         step2. UE add scell
    ...         Expect result: two scells can be added successful
    [Tags]    CB006138-AD037    Owner_jejing
    [Timeout]    60 min
    Before_ue_attach_AD037
    UE Attach and L3 Normal Call    ue_id=81    pdu_gw_id=3
    Check Two Scell Added Successfully    ${FDD_SCELL1_FOR_NRCELL1}    ${FDD_SCELL2_FOR_NRCELL1}
    Verify Throuput on Pscell and Scell    ue_id=81    pdu_gw_id=3
    Release Ues    ue_type=all
    Check WireShark Log    ${CURDIR}${/}a2a_AD037${/}a2a.ini
    ...    wait_string=UEContextModificationResponse::14

CB006138-ET-AD033_Pcell_CSI-RS_is_not_upgraded_after_FDD_SCell_is_released_TFF
    [Documentation]
    ...    1. This user scenario validates when TDD PCell enabled 5GC002200 and in SA mode, PScell's CSI-RS
    ...    configuration is not changed after one FDD Scell's release
    ...    2. UE CAPA: band 41+ band71 +band 71
    ...                band 41: nr-rrc.supportedBandCombinationList_v1540->
    ...                         nr-rrc.maxNumberSimultaneousNZP_CSI_RS_ActBWP_AllCC=4
    ...                         totalnumberportsimultaneousNZP-CSI-RS-ActBWP-AllCC=64
    ...                         nr-rrc.csi_RS_IM_ReceptionForFeedback_element->
    ...                         nr-rrc.maxNumberSimultaneousNZP_CSI_RS_PerCC=4
    ...                         totalnumberportsimultaneousNZP-CSI-RS-perCC=64
    ...    2. Test Case Steps:
    ...         step1. UE register and PDU session setup
    ...         Expect result: UE attach sucessul and PDU session is ok,CSI-RS resource is 4
    ...         step2. UE add scell
    ...         Expect result: two scells can be added successful,CSI-RS resource is 2
    ...         step3. scell release
    ...         Expect result: after one FDD scell release,CSI-RS is 2,after all scell release,CSI-RS is 4
    [Tags]    CB006138-AD033    Owner_Yang chunjian
    [Timeout]    60 min
    Before_ue_attach_AD033
    UE Attach and L3 Normal Call    ue_id=81    pdu_gw_id=4
    Triggered Scell Addition by A1    pcell=NRCELL-1
    Check Two Scell Added Successfully    ${FDD_SCELL1_FOR_NRCELL1}    ${FDD_SCELL2_FOR_NRCELL1}
    Start RRC Log    AD033_scell_release
    Verify Throuput on Pscell and Scell    ue_id=81    pdu_gw_id=4
    Triggered Scell Release by A2    scell=NRCELL-11    scell_id=1
    Triggered Scell Release by A2    scell=NRCELL-12    scell_id=2
    Check Two Scell Released Successfully
    Release Ues    ue_type=all
    Check WireShark Log    ${CURDIR}${/}a2a_AD033${/}a2a.ini
    ...    wait_string=UEContextModificationResponse::26

*** Keywords ***

Verify Throuput on Pscell and Scell
    [Arguments]    ${ue_id}    ${pdu_gw_id}
    builtin.sleep    15s
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > 100
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > 10
    ${scell2_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=ave
    Should Be True    ${scell2_tput}/1000 > 10
    Should Be True    ${scell0_tput}/1000+${scell1_tput}/1000+${scell2_tput}/1000 > 360
    Verify SA DL and UL Traffic    ${ue_id}    ${pdu_gw_id}

Verify Throuput on TF_CA
    [Arguments]    ${ue_id}    ${pdu_gw_id}
    builtin.sleep    15s
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > 100
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > 10
    Should Be True    ${scell0_tput}/1000+${scell1_tput}/1000 > 360
    Verify SA DL and UL Traffic    ${ue_id}    ${pdu_gw_id}

Verify SA DL and UL Traffic
    [Arguments]    ${ue_id}    ${pdu_gw_id}
    builtin.sleep    15s
    ${ul_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_gw_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throuput}/1000>9
    ${dl_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_gw_id}    qfi=1    direction=dl    rate_type=ave
    Should Be True    ${dl_throuput}/1000>100

Before_ue_attach_AD027
    ${final_uecap}    catenate    SEPARATOR=    E9A09000575F5A13160003C1A00B0498B800CE1E82813641873E618F28581C130080C470
    ...    0FB8D85181AC1184341020E90186D6C98AB1A1CF88E3D033EC09F1891C790E7D473E639F28581C0E1E0B801FF800E000BE0005800702A
    ...    0D883AC1184341020F1018656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD8000000B000E0551B1375823
    ...    08682041D2030C2D931544439F11C788E3D033EC09F18E7CC31E50B0381C3C17003FF001C00FFC000B000E0571F11B582308682041F28
    ...    0C2AB64C55850E7C471E300000000000000000000007809FC0000007F00000002C003801EF0F1340038820000042C040A83C28000E230
    ...    000010B02B0F11800388200000C2C0AC3C28000E208000010B02B0F13400388C0000042C0AC5C46000E20800710400002858158785000
    ...    1C4D00000C160562E2680071040038500000102C0AC5C4D000E23000711800001058158B850001C41000E230000020B02B170A0003882
    ...    001C41000004160562E26800710400388C0000082C0AC5C28000E23000711800001058158B89A001C46000E140000040B02B0F1180038
    ...    8C00000C2C0803808D00A2026C041074BB07C28913639F0E14489B1CF870A244D8E7C3851226C73E1C28913639F0E2448913639F0E140
    ...    81B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF810A040D8E7C
    ...    00170F18C6318C6318C6318C61E8260078005038280381803A01C0018090010180F824008000000040000080200000001000002008000
    ...    02004000018020000100100000A008004010040100000C0080000700400200000008000080040000480200000C010000140080000B004
    ...    002048120080000C0339535953582958195833582B594B5933580B581B58095811583B40D04000025949410000196525040000A594901
    ...    000039652404000125949010000596524040001A594901000079652404000225949010000996524040002A5949010000B965250400032
    ...    59490100003165240334AAAE955552A8BA55154162A82C55068AA531549A2A80C55028AA4D5541E28282F012A05028140A05028140A05
    ...    028140A05028140A0502800304040300601002004202004010080600C20100200404030060100C018202018030080600C201002004040
    ...    300601002004402018030080600C0201803040400802010020086A87C0004080C10181C282C30344044484C5060646C70747C8494989C
    ...    A0A4A8B4BD05060B40
    Execute Egate Command    ue_change_location id=81 enb=2 cell=1
    Execute Egate Command    ue_param id=81 ue_nr_capabilities=${final_uecap}
    Clear Counter Files
    Start RRC Log    AD027

Before_ue_attach_AD028
    ${final_uecap}    catenate    SEPARATOR=    E9A09000575F5A13160003C1A00B0498B800CE1E82813641873E618F28581C130080C470
    ...    0FB8D85181AC1184341020E90186D6C98AB1A1CF88E3D033EC09F1891C790E7D473E608F28581C0E1E0B801FF800E000BE0005800702A
    ...    0D883AC1184341020F1018656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD8000000B000E0551B1375823
    ...    08682041D2030C2D931544439F11C788E3D033EC09F18E7CC31E50B0381C3C17003FF001C00FFC000B000E0571F11B582308682041F28
    ...    0C2AB64C55850E7C471E300000000000000000000007809FC0000007F00000002C003801EF0F1340038820000042C040A83C28000E230
    ...    000010B02B0F11800388200000C2C0AC3C28000E208000010B02B0F13400388C0000042C0AC5C46000E20800710400002858158785000
    ...    1C4D00000C160562E2680071040038500000102C0AC5C4D000E23000711800001058158B850001C41000E230000020B02B170A0003882
    ...    001C41000004160562E26800710400388C0000082C0AC5C28000E23000711800001058158B89A001C46000E140000040B02B0F1180038
    ...    8C00000C2C0803808D00A2026C041074BB07C28913639F0E14489B1CF870A244D8E7C3851226C73E1C28913639F0E2448913639F0E140
    ...    81B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B04F811204081B1CF810A040D8E7C
    ...    00170F18C6318C6318C6318C61E8260078005038280381803A01C0018090010180F824008000000040000080200000001000002008000
    ...    02004000018020000100100000A008004010040100000C0080000700400200000008000080040000480200000C010000140080000B004
    ...    002048120080000C0339535953582958195833582B594B5933580B581B58095811583B40D04000025949410000196525040000A594901
    ...    000039652404000125949010000596524040001A594901000079652404000225949010000996524040002A5949010000B965250400032
    ...    59490100003165240334AAAE955552A8BA55154162A82C55068AA531549A2A80C55028AA4D5541E28282F012A05028140A05028140A05
    ...    028140A05028140A0502800304040300601002004202004010080600C20100200404030060100C018202018030080600C201002004040
    ...    300601002004402018030080600C0201803040400802010020086A87C0004080C10181C282C30344044484C5060646C70747C8494989C
    ...    A0A4A8B4BD05060B40
    Execute Egate Command    ue_change_location id=81 enb=2 cell=1
    Execute Egate Command    ue_param id=81 ue_nr_capabilities=${final_uecap}
    Clear Counter Files
    Start RRC Log    AD028

Before_ue_attach_AD037
    ${final_uecap}    catenate    SEPARATOR=    E9A09000575F5A13160003C1A00B0498B800CE1E82813641873E639F28581C130080C
    ...    4700FB8D85181AC1184341020E90186D6C98AB1A1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00058
    ...    00702A0D883AC1184341020F1018656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD8000000B000E055
    ...    1B137582308682041D2030C2D931544439F11C788E3D033EC09F18E7CC31E50B0381C3C17003FF001C00FFC000B000E0571F11B582
    ...    308682041F280C2AB64C55850E7C471E300000000000000000000007809FC0000007F00000002C003801EF0F1340038820000042C0
    ...    40A83C28000E230000010B02B0F11800388200000C2C0AC3C28000E208000010B02B0F13400388C0000042C0AC5C46000E20800710
    ...    4000028581587850001C4D00000C160562E2680071040038500000102C0AC5C4D000E23000711800001058158B850001C41000E230
    ...    000020B02B170A0003882001C41000004160562E26800710400388C0000082C0AC5C28000E23000711800001058158B89A001C4600
    ...    0E140000040B02B0F11800388C00000C2C0803808D00A2026C041074BB07C28913639F0E14489B1CF870A244D8E7C3851226C73E1C
    ...    28913639F0E2448913639F0E14081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF81120408
    ...    1B1FF811204081B1CF810A040D8E7C00170F18C6318C6318C6318C61E8260078005038280381803A01C0018090010180F824008000
    ...    00004000008020000000100000200800002004000018020000100100000A008004010040100000C008000070040020000000800008
    ...    0040000480200000C010000140080000B004002048120080000C0339535953582958195833582B594B5933580B581B58095811583B
    ...    40D04000025949410000196525040000A594901000039652404000125949010000596524040001A594901000079652404000225949
    ...    010000996524040002A5949010000B96525040003259490100003165240334AAAE955552A8BA55154162A82C55068AA531549A2A80
    ...    C55028AA4D5541E28282F012A05028140A05028140A05028140A05028140A0502800304040300601002004202004010080600C2010
    ...    0200404030060100C018202018030080600C201002004040300601002004402018030080600C0201803040400802010020086A87C0
    ...    004080C10181C282C30344044484C5060646C70747C8494989CA0A4A8B4BD05060B40
    Execute Egate Command    ue_change_location id=81 enb=2 cell=1
    Execute Egate Command    ue_param id=81 ue_nr_capabilities=${final_uecap}
    Clear Counter Files
    Start RRC Log    AD037

Before_ue_attach_AD033
    Delta Commission Parameters     ${VALID_SCELL_ADD_AD033}
    ${final_uecap}    catenate    SEPARATOR=    e9a09000575f5a13560003c1a00b0498b800ce1e82813641873e618f28581c130080c
    ...    4700fb8d85181ac1184341020e90186d6c98ab1a1cf88e3d033ec09f1891c790e7d473e619f28581c0e1e0b801ff800e000be00058
    ...    00702a0d883ac1184341020f1018656c98ab121cfb027c471e31238f21cfa8e7cc31e50b0381c3c27f6000001fd8000000b000e055
    ...    1b137582308682041d2030c2d931544439f11c788e3d033ec09f18e7cc31e50b0381c3c17003ff001c00ffc000b000e0571b11b582
    ...    308682041f280c2ab64c55850e7c471e300000000000000000000000009fff000007ffc000002c003801ef0f1340038820000042c0
    ...    40a83c28000e230000010b02b0f11800388200000c2c0ac3c28000e208000010b02b0f13400388c0000042c0ac5c46000e20800710
    ...    4000028581587850001c4d00000c160562e2680071040038500000102c0ac5c4d000e23000711800001058158b850001c41000e230
    ...    000020b02b170a0003882001c41000004160562e26800710400388c0000082c0ac5c28000e23000711800001058158b89a001c4600
    ...    0e140000040b02b0f11800388c00000c2c0803808d00a2026c041074bb07c28913639f0e14489b1cf870a244d8e7c3851226c73e1c
    ...    28913639f0e2448913639f0e14081b1cf811204081b1cf811204081b1cf811204081b1cf811204081b1cf811204081b1cf81120408
    ...    1b0ff811204081b1cf810a040d8e7c00170f18c6318c6318c6318c61e8260078005038280381803a01c0018090010180f824008000
    ...    00004000008020000000100000200800002004000018020000100100000a008004010040100000c008000070040020000000800008
    ...    0040000480200000c010000140080000b004002048120080000c0339535953582958195833582b594b5933580b581b58095811583b
    ...    40d04000025949410000196525040000a594901000039652404000125949010000596524040001a594901000079652404000225949
    ...    010000996524040002a5949010000b96525040003259490100003165240334aaae955552a8ba55154162a82c55068aa531549a2a80
    ...    c55028aa4d5541e28282f012a05028140a05028140a05028140a05028140a0502800304040300601002004202004010080600c2010
    ...    0200404030060100c018202018030080600c201002004040300601002004402018030080600c0201803040400802010020086a87c0
    ...    004080c10181c282c30344044484c5060646c70747c8494989ca0a4a8b4bd05060b40
    Execute Egate Command    ue_change_location id=81 enb=2 cell=1
    Execute Egate Command    ue_param id=81 ue_nr_capabilities=${final_uecap}
    Clear Counter Files
    Start RRC Log    AD033

Check Two Scell Added Successfully
    [Arguments]    ${scell1}    ${scell2}
    ${SCELL1_physCellId}    Get Scf Parameter Value    ${scell1}:physCellId
    ${SCELL2_physCellId}    Get Scf Parameter Value    ${scell2}:physCellId
    Rrc Should Contain    sCellToAddModList    physCellId ${SCELL1_physCellId}    physCellId ${SCELL2_physCellId}

Check Two Scell Released Successfully
    Rrc Should Contain    sCellToReleaseList    1    2


Check One Scell Added Successfully
    [Arguments]    ${scell}
    ${SCELL1_physCellId}    Get Scf Parameter Value    ${scell}:physCellId
    Rrc Should Contain    sCellToAddModList    physCellId ${SCELL1_physCellId}


UE Attach and L3 Normal Call
    [Arguments]    ${ue_id}    ${pdu_gw_id}
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    ue_register id=${ue_id}     pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_gw_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_gw_id} ue=${ue_id} nwslice=1 gw=${pdu_gw_id}
    ...                      pass_regexp=Initial Context Setup Successful
    Execute Egate Command    qosflow_disp
    Start Traffic    ${ue_id}    ${pdu_gw_id}

Start Traffic
    [Arguments]    ${ue_id}    ${pdu_gw_id}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_gw_id} qfi=1 dir=dl mbps=100 trf_id=2
    ...    pass_regexp=UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_gw_id} qfi=1 dir=dl mbps=100 trf_id=3
    ...    pass_regexp=UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_gw_id} qfi=1 dir=dl mbps=100 trf_id=4
    ...    pass_regexp=UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_gw_id} qfi=1 dir=dl mbps=100 trf_id=5
    ...    pass_regexp=UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_gw_id} qfi=1 dir=ul mbps=10
    ...    pass_regexp=UE ${ue_id}: UDP UL

Triggered Scell Addition by A1
    [Arguments]    ${pcell}    ${ue_id}=81    ${rsrp}=100    ${rsrq}=30    ${scell_num}=2
    Execute Egate Command    ue_disp
    ${pcell_ssbfreq}    Get From Dictionary    ${CELLS_SSBFREQ}    ${pcell}
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ${ue_id}    ${pcell_ssbfreq}    A1
    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${rsrp} srsrq_nr=${rsrq}
    ...    pass_regexp=SCellIndex ${scell_num} activated successfully

Triggered Scell Release by A2
    [Arguments]    ${scell}    ${scell_id}    ${ue_id}=81    ${scell_rsrp}=20    ${scell_rsrq}=20
    Execute Egate Command    ue_disp
    ${scell_ssbfreq}    Get From Dictionary    ${CELLS_SSBFREQ}    ${scell}
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ${ue_id}    ${scell_ssbfreq}    A2
    ${cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2
    ...    scell=${scell_id} scell_rsrp=${scell_rsrp} scell_rsrq=${scell_rsrq}
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete
