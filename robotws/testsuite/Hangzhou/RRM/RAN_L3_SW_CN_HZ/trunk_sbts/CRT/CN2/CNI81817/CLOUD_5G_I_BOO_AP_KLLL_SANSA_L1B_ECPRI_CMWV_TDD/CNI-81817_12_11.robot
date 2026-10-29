*** Settings ***
Documentation    Suite description
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-Beam    owner-kexin.bao
...    CLOUD_5G_I_BOO_AP_LOO_SANSA_FS_ECPRI_CMWV_FDD+TDD   CRT    CNI-81817    release-SBTS22R4
...    STATE_CONFIGURED
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{basic_modification}
...    @{case_12_modification}

@{basic_modification}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-5:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/ANTL-3
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-5:resourceDN=${empty}
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-6:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/ANTL-3
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-6:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-6:resourceDN=${empty}
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-7:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/ANTL-4
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-7:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-7:resourceDN=${empty}
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-8:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/ANTL-4
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-8:resourceDN=${empty}
...    MRBTS-1/NRBTS-1/NRCELL-11:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    MRBTS-1/NRBTS-1/NRCELL-11:freqBandIndicatorNR=25
...    MRBTS-1/NRBTS-1/NRCELL-11:gscnOrSsPbchArfcn=4931
...    MRBTS-1/NRBTS-1/NRCELL-11:nrCellType=4DL4UL
...    MRBTS-1/NRBTS-1/NRCELL-11/NRCELL_FDD-1:nrarfcnDl=394480
...    MRBTS-1/NRBTS-1/NRCELL-11/NRCELL_FDD-1:nrarfcnUl=376500
...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:chBwDl=20MHz
...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:chBwUl=20MHz
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-5:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-3
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-5:resourceDN=${empty}
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-6:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-3
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-6:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-6:resourceDN=${empty}
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-7:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-4
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-7:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-7:resourceDN=${empty}
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-8:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-4
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-8:resourceDN=${empty}
...    MRBTS-1/NRBTS-1/NRCELL-13:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    MRBTS-1/NRBTS-1/NRCELL-13:nrCellType=4DL4UL
...    MRBTS-1/NRBTS-1/NRCELL-13/NRCELL_FDD-1:chBwDl=15MHz
...    MRBTS-1/NRBTS-1/NRCELL-13/NRCELL_FDD-1:chBwUl=15MHz

@{case_12_modification}
...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS-1:actIntraFreqHoSA=true
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRelReportCu=15min
...    MRBTS-1/NRBTS-1/NRCELL:actK1Opt=intra-gNB
...    NRBTS:actAllowedBcListMrdcPrioBcSel=true

...    NRBTS:actHighestEstNrTputBcSel=true
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:actCarrierAggregation=true
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:sCellActivationMethod=blind
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRBTS/NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS/NRDU-1:carrierAggregationSupportList=${CA_Support_List}
...    NRCELL:maxNumScellsDlFr1=3
...    NRCELL-11:a1MeasSCellAddEnabled=rsrp
...    NRCELL-11:maxNumScellsDlFr1=3
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=50
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=80
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=0ms
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:lcrId=12
...    NRCELL-11/NRREL-1:nrDcAllowed=false
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:gNbId=1
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-2:lcrId=13
...    NRCELL-11/NRREL-2:nrDcAllowed=false
...    NRCELL-11/NRREL-2:removeNotAllowed=false
...    NRCELL-11/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3

${CA_Support_List}    ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Any_Sa,ca_Fr1Tdd_Any_Sa

${UE_Capa_For_Case12}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623809DC6C28C0D608C21A08107482406D6C98AB1
...    A1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00098000702A0D883AC1184341020F10480CAD931562439F
...    604F88E3C62471E439F51CF9863CA1607038784FEC000003FB000000260001C0AA3626EB04610D04083A412030B64C55110E7C471E238F
...    40CFB027C639F30C7942C0E070F05C00FFC007003FF0004C000381506C46D608C21A0810788240656C98AB121CF88E3D813E31238F21CF
...    A8E7CC31E50B0381C3C27FFC00001FFF00000130000E0541B063582308680000220900A502008400000000000001FD8AAAAA7F62AAAA84
...    C0003001EF17060003882001C4600000216020543E0C00070A0003850001C46000004160563E0C00070A0003882001C4D000006160563E
...    0C00070A0003882001C46000008160561E14000713400003058158B88C001C41000E208000050B02B0F13400389A0000182C0AC5C4D000
...    E2080070A000000858158B89A001C46000E230000010B02B170A0003882001C46000002160562E1400071040038820000042C0AC5C4D00
...    0E20800711800000858158B850001C46000E230000010B02B1713400388C001C28000002160561E230007118000000581009011A014404
...    D808300603D02EC1F0A244D8E7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C38912244D8E7C3850206C73E044810206C73E0
...    44810206C73E044810206C73E044810206C73E044810206C73E044810206C73E044810206C73E0428103639F0005C3C6318C6318C6318C
...    63187A09801E00140E0A00E0601280380030120020301F0480100000000800001004000010020000140100000400800003004000020020
...    0001C0100001000800009004000050020010000000400004002000024010000060080000A004000058020010240900400006019CA9BCA8
...    BC99AC0DAC0CBCA1ACA5AC18AC05ACA4ACA1AC08AC1DA0682000012CA4A080000CB29282000052CA4A080001CB29282000092CA4A08000
...    2CB292820000D2CA4A080003CB29282000112CA4A080004CB29282000152CA4A080005CB29282000192CA4A0800018B292819A55774AAE
...    6935DD28BAA0B7540EEA835D506BAA03754A6EA945D501BAA4D742405E02540A05028140A05028140A05028140A05028140A0500060808
...    01004020180308240400880700D00C01A01C03404809090100220180340380680700D012024240380680700D00E01A0180340480918380
...    801101002201C034048090700200A008014018038030060E0080140080280400900600C1C0380680700D00E01A024048C1C04008808011
...    00C01A018030380200500400A00801401803070100220180340300680600C0E0080140100280200500400860E0200440380680700D00C0
...    181C01002804009008012010020380801100E01A018034038060700E01A0180340380680700C20100C01804030060100C01820202C0580
...    80B0163543E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A

@{OnlineParam_for_11}
...    NRCELL-11/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-2:sCellAdditionMethod=blind

*** Test Cases ***
CNI-81817_12_SA_UE_FR1_CA_A1_based_SCell_Addition_in_FDD_PCell_F_F_F
    [Documentation]
    ...    1. This user scenario purpose is to enhance band combination selection algorithm used for FR1 cell attached UEs.
    ...    2. Configuration
    ...    configuration on BTS:F1 FDD cell in n25,4L DL MIMO,10 MHz;F2 FDD cell in n66,4L DL MIMO,15 MHz;F3 FDD cell in n71,2L DL MIMO,20 MHz
    ...    F1 has F2, F3 configured as SCells
    ...    CA was enabled
    ...    All gNB cells configured as SCell via NRREL object have scellAdditionMethod set to '1'(covBasedA1)
    ...    3. Test Case Steps:
    ...    a.UE register,check (BC, FSEI).
    ...    b.send A1 measurement,check (BC, FSEI).
    ...    c.UE deregister.
    [Tags]    QC_198600    owner-kexin.bao
    Update UE capa    ue_id=82    SA_Capa_perUE_Full=${UE_Capa_For_Case12}
    UE Attach To Target Cell    ue_id=82    cell_id=11
    Trigger A1 Event    ue_id=82    carrierfreq=394570
    UE Deregister From gNB    ue_id=82
    Check Wireshark Log    ${CURDIR}${/}a2a_CNI81817_12${/}a2a.ini    wait_string=UEContextReleaseComplete::4

CNI-81817_11_SA_UE_FR1_CA_SCell_Addition_in_FDD_PCell_F_F_F
    [Documentation]
    ...    1. This user scenario purpose is to enhance band combination selection algorithm used for FR1 cell attached UEs.
    ...    2. Configuration
    ...    configuration on BTS:F1 FDD cell in n25,4L DL MIMO,10 MHz;F2 FDD cell in n66,4L DL MIMO,15 MHz;F3 FDD cell in n71,2L DL MIMO,20 MHz
    ...    F1 has F2, F3 configured as SCells
    ...    CA was enabled
    ...    All gNB cells configured as SCell via NRREL object have scellAdditionMethod set to blind
    ...    3. Test Case Steps:
    ...    a.UE register, check (BC, FSEI), then deregister.
    ...    b.set actAllowedBcListMrdcPrioBcSel to false.
    ...    c.UE register, check (BC, FSEI), then deregister.
    [Tags]    QC_196025    owner-kexin.bao
    OnlineParamChange    ${OnlineParam_for_11}
    UE Attach To Target Cell    ue_id=82    cell_id=11
    UE Deregister From gNB    ue_id=82
    OnlineParamChange    MRBTS-1/NRBTS-1:actAllowedBcListMrdcPrioBcSel=false
    UE Attach To Target Cell    ue_id=82    cell_id=11
    UE Deregister From gNB    ue_id=82
    Check Wireshark Log    ${CURDIR}${/}a2a_CNI81817_11${/}a2a.ini    wait_string=UEContextReleaseComplete::8

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F

Update UE capa
    [Arguments]    ${ue_id}    ${SA_Capa_perUE_Full}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

UE Attach To Target Cell
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    QoS Routing Table
    Send And Verify Throuput

Verify Throuput
    [Arguments]    ${ue_id}    ${Tput_dl}    ${Tput_ul}    ${sleep_time}
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Send And Verify Throuput
    [Arguments]    ${ue_id}=82    ${send_dl}=70    ${send_ul}=10    ${sleep_time}=10s
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=${send_dl}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=${send_ul}
    Verify Throuput    ${ue_id}    ${send_dl}*0.9    ${send_ul}*0.9    ${sleep_time}

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Trigger A1 Event
    [Arguments]    ${ue_id}    ${carrierfreq}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    ${cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=120 srsrq_nr=120
    Execute Egate Command    ${cmd}
    Send And Verify Throuput
