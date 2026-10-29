*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-Beam    owner-Meredith.ma
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD    CRT    CB008124    release-SBTS23R3
...    STATE_CONFIGURED

Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}    fdd_sansa_cmwv/2cells

${cg2_UE_Capabilities}    SEPARATOR=
...    E9A09000577F0140503D09AB0041E19000B0024C5C00670F424026C830E7CC31E50B03826010188E02771B0A3035823
...    08682041D20901B5B262AC6873E238F40CFB027C62471E439F51CF9863CA1607038782E007FE0038002F800260301C00108018
...    0A83620EB04610D04083C412032B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E13FB000000FEC000000980C070
...    004200602A8D89BAC1184341020E90480C2D931544439F11C788E3D033EC09F18E7CC31E50B0381C3C17003FF001C00FFC0013
...    0180E0008400C0541B11B582308682041E2090195B262AC4873E238F604F8C48E3C873EA39F30C7942C0E070F09FFF000007FF
...    C000004C060380021003010000001201808400C007BC3C4D000E208000010B0102A0F0A000388C0000042C0AC3C46000E20800
...    0030B02B0F0A00038820000042C0AC3C4D000E230000010B02B17118003882001C4100000A160561E14000713400003058158B
...    89A001C41000E140000040B02B1713400388C001C46000004160562E14000710400388C0000082C0AC5C28000E208007104000
...    01058158B89A001C41000E230000020B02B170A000388C001C46000004160562E2680071180038500000102C0AC3C46000E230
...    000030B0200E0234028809B01043D02EC1F0A244D8E7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C38912244D8E7
...    C3850206C73E044810206C73E044810206C73E044810206C73E044810206C73E044810206C73E044810206C73E044810206C73
...    E0428103639F0005C3C6318C6318C6318C63187A09801E00140E0A00E0601280380030120020301F0480100000000800001004
...    0000000200000401000004008000030040000200200001401000802008020000180100000E0080040000001000010008000090
...    04000018020000280100001600800409024010000180672A6B2A6B052B032B066B056B296B266B016B036B012B022B07681A08
...    00004B29282000032CA4A0800014B29202000072CA480800024B292020000B2CA480800034B292020000F2CA480800044B2920
...    2000132CA480800054B29202000172CA4A0800064B29202000062CA480669555D2AAAA55174AA2A82C55058AA0D154A62A9345
...    5018AA051549AAA83C5090178095028140A05028140A05028140A05028140A0502814001820201803008010021010020080403
...    00610080100202018030080600C10100C018040300610080100202018030080100220100C01804030060100C01820200401008
...    010043543E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A

@{PARAMS_IN_SWCONFIG}
...    ${dynbetaoff}=2
${dynbetaoff}    0x5900D4
...    ${betaoffpsize}=2
${betaoffpsize}    0x580384
...    ${betaoffopt}=1
${betaoffopt}    0x580385
...    ${csiperi}=20
${csiperi}    0x5900BF

@{PARAMS_IN_SCF}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:timerXnDataFwdGuard=250
...    @{intragnbHO}
...    @{multidrbs}
...    @{8124_related_modification}

@{8124_related_modification}
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL-1:actUlCgType2=true
...    NRCELL-2:actUlCgType2=true
...    NRCELL-1:actAperCsi=true
...    NRCELL-2:actAperCsi=true
...    NRCELL:dlMimoMode=2x2 Closed Loop Spatial Multiplexing
...    NRBTS/NRDRB-11:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-1
...    NRBTS/NRDRB-13:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-1
...    NRBTS/NRDRB-14:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-2
...    NRBTS/NRULCG_PROFILE-1:grantedPacketSize=40
...    NRBTS/NRULCG_PROFILE-1:maxNumPrbs=20
...    NRBTS/NRULCG_PROFILE-1:periodicity=ms5
...    NRBTS/NRULCG_PROFILE-2:grantedPacketSize=80
...    NRBTS/NRULCG_PROFILE-2:maxNumPrbs=20
...    NRBTS/NRULCG_PROFILE-2:periodicity=ms20
...    NRCELL:maxGBRTrafficLimit=90
...    NRCELL:ulConfiguredGrantType2:ulCgMaxNumPrbs=20
...    NRCELL:ulConfiguredGrantType2:ulCgMaxNumUeUl=1
...    NRCELL:ulConfiguredGrantType2:ulCgPrbStartOffset=0

@{multidrbs}
...    NRDRB_5QI-10:fiveqiValueList=4
...    NRDRB_5QI-10:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-3
...    NRDRB-3:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-5
...    NRDRB-3:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-1
...    NRDRB-3:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRDRB-3:resType=GBR
...    NRDRB-3:rlcMode=RLC_AM
...    NRDRB-3:maxDataRateGbrDl=30720
...    NRDRB-3:maxDataRateGbrUl=30720
...    NRDRB-3:l2OHFactorDl=16
...    NRDRB-3:l2OHFactorUl=35
...    NRDRB-3:discardTimer=50ms
...    NRDRB-3:dlFlowControlAlgo=3gppFlowControl
...    NRDRB-3:maxRlcQueueingDelayGbr=20
...    NRDRB-3:maxTransferDelayGbr=20
...    NRDRB-3:queuingDelayDiscarding=Disabled
...    NRDRB-3:dscp=46
...    NRDRB_MAC-5:lcgid=5
...    NRDRB_MAC-5:delayTarget=50
...    NRDRB_MAC-5:schedulBSD=20ms
...    NRDRB_RLC_UM-1:dlTReassemblyUm=ms15
...    NRDRB_RLC_UM-1:ulTReassemblyUm=ms15
...    NRCELL-1:actNonVoNRGbrService=true
...    NRCELL-2:actNonVoNRGbrService=true
...    NRCELL-1:actGBRAdmissionControl=GBRService
...    NRCELL-2:actGBRAdmissionControl=GBRService

@{intragnbHO}
...    NRBTS:actIntraFreqHoSA=true
...    NRPMRNL-1:miNrRelReportCu=5min
...    NRCELL:a5MeasEnabled=rsrp
...    NRCELL:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL:a5MeasSsbRsrp:a5Threshold1SsbRsrp=50
...    NRCELL:a5MeasSsbRsrp:a5Threshold2SsbRsrp=50
...    NRCELL:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:lcrId=1
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3

*** Test Cases ***
CB008124_EUPD05_CG_A-CSI_enable_intra_Gnb_HO_target_A-CSI_enable
    [Documentation]
    ...    1. This user scenario describes the gNB behaviour for management of betaOffset for CSI reporting on PUSCH
    ...    (UCI on PUSCH) in the cell with Configured Grants Type 2 feature activated
    ...    2. Configuration
    ...    a.SA FDD cells are configured with frequency NRF1 with 20MHz bandwidths.
    ...    b.NRF1 cell has NRCELL-cellDepType set to SA or both
    ...    3. Test Case Steps:
    ...    a.Successful Setup of Configured UL Grants Type 2 configuration for the one or more bearers (associated with CG)
    ...    setup with Initial Context Request shall be followed
    ...    b.Intrafreq IntraDU HO and CG Type 2 setup for UE successful.
    ...    c.UE detach.
    [Tags]    QC_284971
    UE Attach To Target Cell ICS with more QoS flows    ue_id=1    cell_id=1
    SA Intragnb Intrafreq HO    ue_id=1
    UE Deregister From gNB    ue_id=1
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008124_EUPD05${/}a2a.ini    wait_string=UEContextReleaseComplete::4

CB008124_EUPD01_A-CSI_enable_multiUE_CG_Cap_FDD_PDU_Setup_and_modify
    [Documentation]
    ...    1. This user scenario describes the gNB behaviour for management of betaOffset for CSI reporting on PUSCH
    ...    (UCI on PUSCH) in the cell with Configured Grants Type 2 feature activated
    ...    2. Configuration
    ...    a.SA FDD cells are configured with frequency NRF1 with 20MHz bandwidths.
    ...    b.NRF1 cell has NRCELL-cellDepType set to SA or both
    ...    3. Test Case Steps:
    ...    a.Successful Setup of Configured UL Grants Type 2 configuration for the one or more bearers (associated with CG)
    ...    setup with Initial Context Request shall be followed
    ...    b.PDU modify to delete bearers and add another drb
    ...    c.UE detach.
    [Tags]    QC_284972
    UE Attach To Target Cell with more QoS flows    ue_id=1    cell_id=1
    PDU Modification to add another 5QI    ue_id=1
    Start traffic    ue_id=1
    Verify Multi drbs Throuput    ue_id=1
    UE Deregister From gNB    ue_id=1
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008124_EUPD01${/}a2a.ini    wait_string=UEContextReleaseComplete::4

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fdd_sansa_cmwv/2cells    ue_count=15

Modify Cfg
    Update Cfg    set_qosflow id=1 5qi=1
    Update Cfg    set_qosflow id=2 5qi=2 gfbr_ul=5000 gfbr_dl=10000 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=3 5qi=3 gfbr_ul=5000 gfbr_dl=10000 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=4 5qi=4 gfbr_ul=5000 gfbr_dl=10000 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=5 5qi=5
    Update Cfg    set_qosflow id=6 5qi=6
    Update Cfg    set_qosflow id=7 5qi=7
    Update Cfg    set_qosflow id=8 5qi=8 default=on
    Update Cfg    set_qosflow id=9 5qi=9
    Update Cfg    ue_param id=1 ue_nr_capabilities=${cg2_UE_Capabilities}
    Update Cfg    nwslice_set id=1 snssai=0x01:0xD143A5 default=on ue=all amf=1

UE Attach To Target Cell ICS with more QoS flows
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    QoS Routing Table
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=5    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=2 mbps=3    UE ${ue_id}: UDP UL

UE Attach To Target Cell with more QoS flows
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    amf_param id=1 send_ics_registration=on
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=7
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    QoS Routing Table
    Execute Egate Command    amf_param id=1 reset
    Execute Egate Command    smf_param id=1 reset

PDU Modification to add another 5QI
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=6 qosflows_to_del=8 by=amf    Added QosFlow with
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=5 by=amf    Added QosFlow with

Start traffic
    [Arguments]    ${ue_id}
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=2 dir=dl trf_id=1 mbps=5    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=2 dir=ul trf_id=2 mbps=3    UE ${ue_id}: UDP UL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=3 dir=dl trf_id=3 mbps=5    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=3 dir=ul trf_id=4 mbps=3    UE ${ue_id}: UDP UL
    Sleep    10s    sleep for Tput stable

Verify Multi drbs Throuput
    [Arguments]    ${ue_id}    ${Tput_dl}=4.5    ${Tput_ul}=2.7    ${sleep_time}=10s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput1}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=2    direction=dl    rate_type=ave
    ${ul_throughput1}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=2    direction=ul    rate_type=ave
    ${dl_throughput2}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=3    direction=dl    rate_type=ave
    ${ul_throughput2}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=3    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput1}/1000>${Tput_dl}
    Should Be True    ${ul_throughput1}/1000>${Tput_ul}
    Should Be True    ${dl_throughput2}/1000>${Tput_dl}
    Should Be True    ${ul_throughput2}/1000>${Tput_ul}

SA Intragnb Intrafreq HO
    [Arguments]    ${ue_id}    ${Tput_dl}=4.5    ${Tput_ul}=2.7
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=2 event=A5 srsrp_nr=40 srsrq_nr=40 phycell_id=61 nrsrp_nr=60 nrsrq_nr=60
    ...    Intra-eNB handover
    sleep    10s    sleep for Tput stable
    ${dl_throughput1}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput1}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput1}/1000>${Tput_dl}
    Should Be True    ${ul_throughput1}/1000>${Tput_ul}

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s
