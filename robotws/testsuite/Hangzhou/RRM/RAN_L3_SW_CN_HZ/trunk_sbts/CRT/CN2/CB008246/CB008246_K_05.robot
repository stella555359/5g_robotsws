*** Settings ***
Documentation    Suite description
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-Beam    owner-chunlan.yang
...    CLOUD_5G_I_BOO_AP_LOO_SANSA_FS_ECPRI_CMWV_FDD+TDD    CB008246    release-SBTS24R1
...    STATE_CONFIGURED
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${SYSCOM_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    NRBTS:actFullPlmnList=true
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    @{8246_related_modification}
...    @{8246_G_related_modification}
...    @{8246_G_5qi3_modification}
...    @{ca_relation}
...    @{A1_scell_Addition}

@{8246_related_modification}
...    NRCELL-1:cellDepType=SA
...    delete:NRCELL-1:configuredEpsTac
...    NRCELL-1:actLAForHiReliab=true
...    NRBTS-1/BWP_PROFILE-3/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRBTS-1/BWP_PROFILE-4/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRCELL-1:actCceSplit=false
...    NRCELL-1:pdschHrLaConfig:dllaCqiOffsetHR=0
...    NRCELL-1:pdschHrLaConfig:dllaDeltaCqiMaxHR=150
...    NRCELL-1:pdschHrLaConfig:dllaDeltaCqiMinHR=-150
...    NRCELL-1:pdschHrLaConfig:dllaDeltaCqiStepdownHR=20
...    NRCELL-1:pdschHrLaConfig:dllaIniDeltaCqiHR=-50
...    NRCELL-1:pdschHrLaConfig:dllaIniMcsHR=3
...    NRCELL-1:scalingStepdownHREnabled=true
...    NRCELL-11:scalingStepdownHREnabled=true
...    NRCELL-13:scalingStepdownHREnabled=true
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerOutageMcsThresh64qam=3
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerOutageMcsThresh64qamLowSE=2
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerOutagePercentage=50
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerOutagePeriod=20
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerRecoverMcsThresh64qam=5
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerRecoverMcsThresh64qamLowSE=5
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerRecoverPercentage=60
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerRecoverPeriod=20
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerOutageMcsThresh64qam=3
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerOutageMcsThresh64qamLowSE=2
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerOutagePercentage=50
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerOutagePeriod=20
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerRecoverMcsThresh64qam=5
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerRecoverMcsThresh64qamLowSE=5
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerRecoverPercentage=60
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerRecoverPeriod=20
...    NRBTS/NRPDCCHHRLA-1:pdcchHRBlerOutagePercentage=50
...    NRBTS/NRPUSCHHRLA-1:scalFactorForHRGbrUl=110
...    NRBTS/NRPUSCHHRLA-2:scalFactorForHRGbrUl=110
...    NRBTS/NRDRB-10:nrPdschHRLaDN=MRBTS-1/NRBTS-1/NRPDSCHHRLA-1
...    NRBTS/NRDRB-11:nrPdschHRLaDN=MRBTS-1/NRBTS-1/NRPDSCHHRLA-2
...    NRBTS/NRDRB-11:nrPdcchHRLaDN=MRBTS-1/NRBTS-1/NRPDCCHHRLA-1
...    NRBTS/NRDRB-11:nrPuschHRLaDN=MRBTS-1/NRBTS-1/NRPUSCHHRLA-2
...    NRBTS/NRDRB-12:nrPdschHRLaDN=MRBTS-1/NRBTS-1/NRPDSCHHRLA-2
...    NRBTS/NRDRB-12:nrPdcchHRLaDN=MRBTS-1/NRBTS-1/NRPDCCHHRLA-1
...    NRBTS/NRDRB-12:nrPuschHRLaDN=MRBTS-1/NRBTS-1/NRPUSCHHRLA-2
...    NRBTS/NRDU-1:carrierAggregationSupportList=none
...    NRBTS-1/BWP_PROFILE-3/PDCCH-1:alSelection=static
...    NRBTS-1/BWP_PROFILE-4/PDCCH-1:alSelection=static

@{8246_G_related_modification}
...    NRBTS/NRPDSCHHRLA-1:dllaBlerTargetHR=5
...    NRBTS/NRPDSCHHRLA-1:scalFactorForHRGbrDl=110
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerOutageMcsThresh64qam=3
...    NRBTS/NRPDSCHHRLA-2:dllaBlerTargetHR=4
...    NRBTS/NRPDSCHHRLA-2:scalFactorForHRGbrDl=200
...    NRBTS/NRPMRNL-1:miNrUlHarqOne=5min
...    NRCELL-1:pdschHrLaConfig:dllaMcsMax64qamLowSERANK1HR=25
...    NRCELL-1:pdschHrLaConfig:dllaMcsMax64qamLowSERANK2HR=25
...    NRCELL-1:pdschHrLaConfig:dllaMcsMax64qamLowSERANK3HR=20
...    NRCELL-1:pdschHrLaConfig:dllaMcsMax64qamLowSERANK4HR=20
...    NRCELL-1:pdschHrLaConfig:dllaMcsMax64qamRANK1HR=25
...    NRCELL-1:pdschHrLaConfig:dllaMcsMax64qamRANK2HR=25
...    NRCELL-1:pdschHrLaConfig:dllaMcsMax64qamRANK3HR=20
...    NRCELL-1:pdschHrLaConfig:dllaMcsMax64qamRANK4HR=20
...    NRCELL-1:puschHrLaConfig:iniDeltaSinrHR=-50

@{8246_G_5qi3_modification}
...    NRCELL-1:actNonVoNRGbrService=true
...    NRCELL-1:actGBRAdmissionControl=GBRService
...    NRCELL-1:maxGBRTrafficLimit=6
...    NRBTS/NRDRB-16:discardTimer=100ms
...    NRBTS/NRDRB-16:dscp=46
...    NRBTS/NRDRB-16:l2OHFactorDl=16
...    NRBTS/NRDRB-16:l2OHFactorUl=33
...    NRBTS/NRDRB-16:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-16:maxTransferDelayGbr=20
...    NRBTS/NRDRB-16:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-5
...    NRBTS/NRDRB-16:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-3
...    NRBTS/NRDRB-16:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-16:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-16:resType=GBR
...    NRBTS/NRDRB-16:cellAggrLevel=FR1 CA incompatible
...    NRBTS/NRDRB-16:rlcMode=RLC_UM
...    NRBTS/NRDRB-16:schedulWeight=${EMPTY}
...    NRBTS/NRDRB-16:nrDrbRlcAmDN=${EMPTY}
...    NRBTS/NRDRB-16:nsaDrbParam=${EMPTY}
...    NRBTS/NRDRB-16:maxDataRateGbrDl=30720
...    NRBTS/NRDRB-16:maxDataRateGbrUl=30720
...    NRBTS/NRDRB-16:dlFlowControlAlgo=3gppFlowControl
...    NRBTS/NRDRB_5QI-7:fiveqiValueList=3
...    NRBTS/NRDRB_5QI-7:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-16
...    NRBTS/NRDRB_MAC-3:delayTarget=50
...    NRBTS/NRDRB_MAC-5:delayTarget=50
...    NRBTS/NRDRB_MAC-5:lcgid=5
...    NRBTS/NRDRB_MAC-5:schedulBSD=100ms
...    NRBTS/NRDRB_MAC-5:schedulPrio=5
...    NRBTS/NRDRB-16:nrPdschHRLaDN=MRBTS-1/NRBTS-1/NRPDSCHHRLA-1
...    NRBTS/NRDRB-16:nrPdcchHRLaDN=MRBTS-1/NRBTS-1/NRPDCCHHRLA-1
...    NRBTS/NRDRB-16:nrPuschHRLaDN=MRBTS-1/NRBTS-1/NRPUSCHHRLA-1

@{ca_relation}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:sCellActivationMethod=bufferBased
...    NRCELL-1:actK1Opt=intra-gNB
...    NRCELL-11:actK1Opt=intra-gNB
...    NRCELL-13:actK1Opt=intra-gNB
...    NRBTS/BWP_PROFILE-1/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRBTS/BWP_PROFILE-2/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRCELL-11:actCceSplit=false
...    NRCELL-11:actLAForHiReliab=true
...    NRCELL-11:pdschHrLaConfig:dllaCqiOffsetHR=0
...    NRCELL-11:puschHrLaConfig:iniDeltaSinrHR=-50
...    NRCELL-13:actCceSplit=false
...    NRCELL-13:actLAForHiReliab=true
...    NRCELL-13:pdschHrLaConfig:dllaCqiOffsetHR=0
...    NRCELL-13:puschHrLaConfig:iniDeltaSinrHR=-50
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:lcrId=11
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:gNbId=1
...    NRCELL-1/NRREL-2:lcrId=13
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRBTS/NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS/NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Any_Sa

@{A1_scell_Addition}
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=40
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=50
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=0ms

${UE_Capa_not_Support_HRLA}    SEPARATOR=
...    E9A09000575F5A13160003C1A00B0498B800CE1E82813641873E618F28581C130080C4700FB8D85181AC1184341020E90186D6C98AB1A1CF8
...    8E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE0005800702A0D883AC1184341020F1018656C98AB121CFB027C471E3
...    1238F21CFA8E7CC31E50B0381C3C27F6000001FD8000000B000E0551B137582308682041D2030C2D931544439F11C788E3D033EC09F18E7CC
...    31E50B0381C3C17003FF001C00FFC000B000E0541B11B582308682041E2030CAD931562439F11C7B027C62471E439F51CF9863CA160703878
...    4FFF800003FFE0000016001C00F78789A001C4100000216020541E14000711800000858158788C001C41000006160561E1400071040000085
...    8158789A001C46000002160562E2300071040038820000142C0AC3C28000E268000060B02B17134003882001C28000008160562E268007118
...    00388C0000082C0AC5C28000E20800711800001058158B850001C41000E208000020B02B17134003882001C46000004160562E14000711800
...    388C0000082C0AC5C4D000E2300070A000002058158788C001C46000006160401C0468051013602083A5D83E14489B1CF870A244D8E7C3851
...    226C73E1C28913639F0E14489B1CF871224489B1CF870A040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C0890204
...    0D8E7C08902040D8E7C08902040D8E7C0850206C73E000B878C6318C6318C6318C630F413003C00281C1401C0C01D00E000C0480080C07C12
...    0040000000200000401000000008000010040000100200000C010000080080000500400200802008000060040000380200100000004000040
...    02000024010000060080000A004000058020010240900400006019CA9ACA9AC14AC0CAC19AC15ACA5AC99AC05AC0DAC04AC08AC1DA0682000
...    012CA4A080000CB29282000052CA48080001CB29202000092CA48080002CB292020000D2CA48080003CB29202000112CA48080004CB292020
...    00152CA48080005CB29282000192CA480800018B292019A55574AAAA9545D2A8AA0B154162A83455298AA4D154062A8145526AAA0F1414178
...    095028140A05028140A05028140A05028140A050281400182020180300801002101002008040300610080100202018030080600C10100C018
...    040300610080100202018030080100220100C01804030060100C01820200401008010043543E00020406080C0E1416181A202224262830323
...    6383A3E424A4C4E5052545A5E828305A

@{expected_for_UE81}
...    sCellIndex 1
...    physCellId 60
...    sCellIndex 2
...    physCellId 62

*** Test Cases ***
CB008246_K05_SA_A1_Scell_Addition_TFF_FAF_Activated_Pcell_Scells_After_nonGBR_HRDRB_Setup_Alt4
    [Documentation]
    ...    1.Description
    ...    This user scenario validates the high reliability DRBs interworking with Carrier aggregation in DL for SA UE.
    ...    While UE is configured with at least one HR nonGBR DRB (regardless of other DRBs), gNB may configure UE with
    ...    CA, but will add only SCells, which support HR. gNB will transmit the HR nonGBR DRB data with high reliability
    ...    over the PCell and SCells.
    ...    2.Configuration
    ...      a.SA,pcell TDD, scell FDD.
    ...      b.Configured both pcell and scells Link Adaptation High Reliability feature: NRBTS/NRCELL.actLAForHiReliab=true.
    ...      c.Default drb 5QI6 & 5QI7 are associated with NRPDSCHHRLA profile.
    ...      d.UE not support Dl-64QAM-MCS-TableAlt.
    ...    3.Test Steps
    ...      a.UE attach to target cell via ICS, HR DRB 5QI6 is setup via PDU.
    ...      b.trigger A1 to add scell.
    ...      c.Send and verify throughput.
    ...      d.UE detach.
    ...    4.Check Points
    ...      a.HR DRB shall be setup on PCell, mcstable absent in rrc reconfiguration.
    ...      b.SCell addition trigger and CELL11,CELL13 shall be selected as candidate SCell.
    ...      c.64qam is set in msctable for scells in l2_ps_user_UserSetupReq.
    [Tags]    QC_324085    owner-chunlan.yang
    Update UE capa    ue_id=81    SA_Capa_perUE_Full=${UE_Capa_not_Support_HRLA}
    UE Attach To Target Cell via ICS    ue_id=81    cell_id=1
    trigger A1 MR to add scell    rsrp=80    rsrq=80    ue_id=81    ssbfreq=518910
    Add Qosflow
    Send And Verify Throuput    ue_id=81    sleep_time=10s
    Smf Param Reset After case finished
    UE Deregister From gNB    ue_id=81
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008246_K_05${/}a2a.ini    wait_string=UEContextReleaseComplete::4

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F

Modify Cfg
    Delete Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=1 5qi=1
    Update Cfg    set_qosflow id=2 5qi=2 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=3 5qi=3 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=4 5qi=4 gfbr_ul=4000 gfbr_dl=10000 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=5 5qi=5 default=on
    Update Cfg    set_qosflow id=6 5qi=6
    Update Cfg    set_qosflow id=7 5qi=7
    Update Cfg    set_qosflow id=8 5qi=8

Update UE capa
    [Arguments]    ${ue_id}    ${SA_Capa_perUE_Full}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}


UE Attach To Target Cell via ICS
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    qosflow_modify default=on qos_flow=6 priority=1
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    QoS Routing Table

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Smf Param Reset After case finished
    Execute Egate Command    smf_param id=1 reset

Send And Verify Throuput
    [Arguments]    ${ue_id}    ${sleep_time}
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=10    UE ${ue_id}: UDP UL
    sleep    ${sleep_time}    wait for verify tput
    Verify Throuput on Pscell and Scell    ue_id=${ue_id}

Verify Throuput on Pscell and Scell
    [Arguments]    ${ue_id}
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000>10
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000>10
    ${scell2_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=ave
    Should Be True    ${scell2_tput}/1000>10
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>40
    Should Be True    ${ul_throughput}/1000>8

trigger A1 MR to add scell
    [Arguments]    ${rsrp}=80    ${rsrq}=80    ${ue_id}=81    ${ssbfreq}=518910
    ${meas_id}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${ssbfreq}    event_type=A1
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrq_nr=${rsrq} srsrp_nr=${rsrp}
    ...    pass_regexp=${expected_for_UE81}    timeout=20s

Add Qosflow
    Execute Egate Command    ue_pdu_session_modify ue=81 pdu=1 qosflows_to_add=8 by=amf
    ...    pass_regexp=Pdu Session Resource Modify Response Message
