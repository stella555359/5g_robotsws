*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-Beam    owner-qianqian.guo
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD    CRT    CB008246    release-SBTS23R4
...    STATE_CONFIGURED
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${SYSCOM_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRCELL-1:actNonVoNRGbrService=true
...    NRCELL-1:actUl256Qam=false
...    NRCELL-1:actDl256Qam=false
...    @{5qi3_related_modification}
...    @{8246_related}
...    @{enable_Redcap}

@{8246_related}
...    @{bwp_profile}
...    @{PDSCHHRLA_PUSCHHRLA}
...    @{8246_cell_configuration}

@{enable_Redcap}
...    NRCELL-1:actRedCapUeSupport=true
...    NRCELL-1:maxNumOfRrcSARedCap=200

@{bwp_profile}
...    NRBTS/BWP_PROFILE-1/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRBTS/BWP_PROFILE-5/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRBTS/BWP_PROFILE-14/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRBTS/BWP_PROFILE-54/PDCCH-1:dciDedicatedAggregationLevelHR=AL4

@{PDSCHHRLA_PUSCHHRLA}
#5qi=6
...    NRBTS/NRDRB-11:nrPuschHRLaDN=MRBTS-1/NRBTS-1/NRPUSCHHRLA-1
...    NRBTS/NRDRB-11:nrPdschHRLaDN=MRBTS-1/NRBTS-1/NRPDSCHHRLA-1

...    NRBTS/NRPUSCHHRLA-1:scalFactorForHRGbrUl=105
...    NRBTS/NRPUSCHHRLA-1:ullaBlerTargetHR=1
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerOutagePercentage=50
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerOutagePeriod=20
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerOutageTbsThresh=808
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerOutageTbsThresh64qam=1000
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerRecoverPercentage=60
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerRecoverPeriod=30
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerRecoverTbsThresh=10000
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerRecoverTbsThresh64qam=7000
...    NRBTS/NRPUSCHHRLA-2:scalFactorForHRGbrUl=200
...    NRBTS/NRPUSCHHRLA-2:ullaBlerTargetHR=6
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerOutagePercentage=50
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerOutagePeriod=20
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerOutageTbsThresh=808
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerOutageTbsThresh64qam=1000
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerRecoverPercentage=60
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerRecoverPeriod=30
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerRecoverTbsThresh=10000
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerRecoverTbsThresh64qam=7000
#5QI-3
...    NRBTS/NRDRB-19:nrPdschHRLaDN=MRBTS-1/NRBTS-1/NRPDSCHHRLA-2
...    NRBTS/NRDRB-19:nrPuschHRLaDN=MRBTS-1/NRBTS-1/NRPUSCHHRLA-2

...    NRBTS/NRPDSCHHRLA-1:dlHRBlerOutageMcsThresh64qam=3
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerOutageMcsThresh64qamLowSE=2
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerOutagePercentage=50
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerOutagePeriod=20
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerRecoverMcsThresh64qam=5
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerRecoverMcsThresh64qamLowSE=10
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerRecoverPercentage=60
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerRecoverPeriod=30
...    NRBTS/NRPDSCHHRLA-1:dllaBlerTargetHR=1
...    NRBTS/NRPDSCHHRLA-1:scalFactorForHRGbrDl=101
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerOutageMcsThresh64qam=3
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerOutageMcsThresh64qamLowSE=2
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerOutagePercentage=50
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerOutagePeriod=20
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerRecoverMcsThresh64qam=5
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerRecoverMcsThresh64qamLowSE=10
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerRecoverPercentage=60
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerRecoverPeriod=30
...    NRBTS/NRPDSCHHRLA-2:dllaBlerTargetHR=1
...    NRBTS/NRPDSCHHRLA-2:scalFactorForHRGbrDl=180

@{5qi3_related_modification}
...    NRBTS/NRDRB-19:actDddsReduction=false
...    NRBTS/NRDRB-19:actDlTxResumeOnPdcpStatRep=false
...    NRBTS/NRDRB-19:actLostPduFastRetx=false
...    NRBTS/NRDRB-19:cellAggrLevel=Not FR1 CA eligible
...    NRBTS/NRDRB-19:discardTimer=100ms
...    NRBTS/NRDRB-19:dlAllowMinDelayLinkXxCalib=false
...    NRBTS/NRDRB-19:dlFlowControlAlgo=none
...    NRBTS/NRDRB-19:dscp=46
...    NRBTS/NRDRB-19:durationThresDiscardDl=40
...    NRBTS/NRDRB-19:durationThresDiscardUl=20
...    NRBTS/NRDRB-19:endMarkerTimer=2000
...    NRBTS/NRDRB-19:maxDataRateGbrDl=30720
...    NRBTS/NRDRB-19:maxDataRateGbrUl=30720
...    NRBTS/NRDRB-19:maxDddsPeriodCpuOvld=40
...    NRBTS/NRDRB-19:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-19:maxTransferDelayGbr=20
...    NRBTS/NRDRB-19:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-6
...    NRBTS/NRDRB-19:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-4
...    NRBTS/NRDRB-19:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-19:nrDrbRlcAmDN=${EMPTY}
...    NRBTS/NRDRB-19:numSduDiscard=1
...    NRBTS/NRDRB-19:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-19:queuingDelaySduDiscardThreshold=750
...    NRBTS/NRDRB-19:resType=GBR
...    NRBTS/NRDRB-19:rlcMode=RLC_UM
...    NRBTS/NRDRB-19:schedulWeight=1
...    NRBTS/NRDRB-19:sduDiscardIntervalTmr=500
...    NRBTS/NRDRB-19:volThresDiscardDl=8000
...    NRBTS/NRDRB-19:volThresDiscardUl=800
...    NRBTS/NRDRB-19:l2OHFactorDl=16
...    NRBTS/NRDRB-19:l2OHFactorUl=35
...    NRBTS/NRDRB-19:nsaDrbParam:actPrioritizeX2AfterInactivity=true
...    NRBTS/NRDRB-19:nsaDrbParam:actX2DuplicateTxNSA3x=false
...    NRBTS/NRDRB-19:nsaDrbParam:dlDataSplitBufferBuildUpThreshold=5
...    NRBTS/NRDRB-19:nsaDrbParam:dlDataSplitBufferBuildUpThresholdPrioritizeX2=5
...    NRBTS/NRDRB-19:nsaDrbParam:dlDataSplitGainThreshold=5
...    NRBTS/NRDRB-19:nsaDrbParam:dlDataSplitMode=dlOverF1U
...    NRBTS/NRDRB-19:nsaDrbParam:dlNumOfCongOrGainDdds=2
...    NRBTS/NRDRB-19:nsaDrbParam:inactivityThresholdForPrioritizeX2=300
...    NRBTS/NRDRB-19:nsaDrbParam:inactivityThresholdForRestartPrioritizeX2=100
...    NRBTS/NRDRB-19:nsaDrbParam:inactPeriodX2PdcpDuplication=300
...    NRBTS/NRDRB-19:nsaDrbParam:initialDLTrafficRouting=initDLoverX2U
...    NRBTS/NRDRB-19:nsaDrbParam:nsa3xBearerAllowed=true
...    NRBTS/NRDRB-19:nsaDrbParam:prioritizeX2Period=500
...    NRBTS/NRDRB-19:nsaDrbParam:ulDataPath=ulOverNr
...    NRBTS/NRDRB-19:nsaDrbParam:ulDataSplitThreshold=infinity
...    NRBTS/NRDRB_5QI-9:fiveqiValueList=3
...    NRBTS/NRDRB_5QI-9:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-19
...    NRBTS/NRDRB_MAC-6:delayTarget=50
...    NRBTS/NRDRB_MAC-6:lcgid=5
...    NRBTS/NRDRB_MAC-6:prioritisedBitRate=16kBps
...    NRBTS/NRDRB_MAC-6:schedulBSD=100ms
...    NRBTS/NRDRB_MAC-6:schedulPrio=5
...    NRBTS/NRDRB_PDCP-4:cuFlowControlProfId=1
...    NRBTS/NRDRB_PDCP-4:pdcpBufDiscardEnabled=false
...    NRBTS/NRDRB_PDCP-4:pdcpBufDiscardThreshold=20000
...    NRBTS/NRDRB_PDCP-4:pdcpDelayThreshRetxMode=disabled
...    NRBTS/NRDRB_PDCP-4:tReorderingDl=ms8
...    NRBTS/NRDRB_PDCP-4:tReorderingUl=ms8
...    NRBTS/NRDRB_PDCP-4:xxFlowControlProfForCuIdx=1
...    NRBTS/NRDRB_RLC_AM-4:dlMaxRetxThreshold=t16
...    NRBTS/NRDRB_RLC_AM-4:dlPollByte=kB500
...    NRBTS/NRDRB_RLC_AM-4:dlPollPDU=p64
...    NRBTS/NRDRB_RLC_AM-4:dlTPollRetr=ms100
...    NRBTS/NRDRB_RLC_AM-4:dlTProhib=ms15
...    NRBTS/NRDRB_RLC_AM-4:dlTReassembly=ms15
...    NRBTS/NRDRB_RLC_AM-4:dlTReassemblyIBCA=30
...    NRBTS/NRDRB_RLC_AM-4:duFlowControlProfId=1
...    NRBTS/NRDRB_RLC_AM-4:ulMaxRetxThreshold=t32
...    NRBTS/NRDRB_RLC_AM-4:ulPollByte=kB500
...    NRBTS/NRDRB_RLC_AM-4:ulPollPDU=p64
...    NRBTS/NRDRB_RLC_AM-4:ulTPollRetr=ms45
...    NRBTS/NRDRB_RLC_AM-4:ulTProhib=ms15
...    NRBTS/NRDRB_RLC_AM-4:ulTReassembly=ms15
...    NRBTS/NRDRB_RLC_AM-4:ulTReassemblyIBCA=${EMPTY}
...    NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms50
...    NRBTS/NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm12bitSN
...    NRBTS/NRDRB_RLC_UM-1:ulTReassemblyUm=ms50

@{8246_cell_configuration}
...    NRCELL-1:actCceSplit=false
...    NRCELL-1:actLAForHiReliab=true
...    NRCELL-1:scalingStepdownHREnabled=true

...    NRCELL-1:puschHrLaConfig:iniDeltaSinrHR=-50
...    NRCELL-1:puschHrLaConfig:ullaDeltaSinrMaxHR=150
...    NRCELL-1:puschHrLaConfig:ullaDeltaSinrMinHR=-300
...    NRCELL-1:puschHrLaConfig:ullaDeltaSinrStepdownHR=20
...    NRCELL-1:puschHrLaConfig:ullaIniMcsHR=0
...    NRCELL-1:puschHrLaConfig:ullaMcsMax64qamLowSERANK1HR=25
...    NRCELL-1:puschHrLaConfig:ullaMcsMax64qamLowSERANK2HR=25
...    NRCELL-1:puschHrLaConfig:ullaMcsMax64qamRANK1HR=25
...    NRCELL-1:puschHrLaConfig:ullaMcsMax64qamRANK2HR=25
...    NRCELL-1:puschHrLaConfig:ullaSinrOffsetHR=20

...    NRCELL-1:pdschHrLaConfig:dllaCqiOffsetHR=0
...    NRCELL-1:pdschHrLaConfig:dllaDeltaCqiMaxHR=150
...    NRCELL-1:pdschHrLaConfig:dllaDeltaCqiMinHR=-150
...    NRCELL-1:pdschHrLaConfig:dllaDeltaCqiStepdownHR=20
...    NRCELL-1:pdschHrLaConfig:dllaIniDeltaCqiHR=-50
...    NRCELL-1:pdschHrLaConfig:dllaIniMcsHR=3
...    NRCELL-1:pdschHrLaConfig:dllaMcsMax64qamLowSERANK1HR=25
...    NRCELL-1:pdschHrLaConfig:dllaMcsMax64qamLowSERANK2HR=25
...    NRCELL-1:pdschHrLaConfig:dllaMcsMax64qamLowSERANK3HR=20
...    NRCELL-1:pdschHrLaConfig:dllaMcsMax64qamLowSERANK4HR=20
...    NRCELL-1:pdschHrLaConfig:dllaMcsMax64qamRANK1HR=25
...    NRCELL-1:pdschHrLaConfig:dllaMcsMax64qamRANK2HR=25
...    NRCELL-1:pdschHrLaConfig:dllaMcsMax64qamRANK3HR=20
...    NRCELL-1:pdschHrLaConfig:dllaMcsMax64qamRANK4HR=20

${UE_Capa_Support_Redcap}    SEPARATOR=
...    E1A5100000280C0481406013D780C0B0008250001208367130F850B004D8041FF9863CA160704C060188A0300A63000A0F88DAC31B47498A8
...    23F96524CA0F0020B64C1203063C63FF30C7942C0E070F0137B0EC37B0EC01000C000000001C4600000000420C046E4D0F807208000005208
...    00001520800002524A000034C016065E46D0141000009652404000065949010000296524040000E594941000049652424000154B292003A07
...    1748E286800F00340201000000000004008010A052800004940800060

*** Test Cases ***
CB008246_L_01_High_reliability_DRB_IWK_with_RedCap_UE_ATTACH
    [Documentation]
    ...    1.Description
    ...    To validate Link adaptation for High reliability DRB feature interworking with RedCap UE
    ...    2.Configuration
    ...      a.SA,FDD.
    ...      b.Configured Link Adaptation High Reliability feature: NRBTS/NRCELL.actLAForHiReliab=true.
    ...      c.UE with RedCap.
    ...      d.UE doesn't support Ul-64QAM-MCS-TableAlt and Dl-64QAM-MCS-TableAlt.
    ...    3.Test Steps
    ...      a.UE attach to target cell w default DRB 5QI6 and DRB 5qi3.
    ...      b.delete DRB 5qi3.
    ...      c.add DRB 5qi3.
    ...      c.UE detach.
    ...    4.Check Points
    ...      4.1 for step a:no mcs-Table parameter in PDSCH-Config and PUSCH-Config
    ...      4.2 for step b:check RRC RECONFIGURATION message, no mcs-Table parameter of PUSCH-Config and PUSCH-Config
    ...      4.3 for step c:check RRC RECONFIGURATION message, no mcs-Table parameter of PUSCH-Config and PUSCH-Config
    [Tags]    QC_320725    owner-qianqian.guo
    UE Attach To Target Cell 2DRB    ue_id=1    cell_id=1    default_qos=6    fail_regexp=mcs-Table qam64LowSE
    Send And Verify Throuput    ue_id=1    qfi=1    pdu=1    send_dl=5    send_ul=3    sleep_time=10s
    Send And Verify Throuput    ue_id=1    qfi=2    pdu=1    send_dl=5    send_ul=3    sleep_time=10s
    Del DRB 5qi3    ue_id=1
    Verify Throuput    ue_id=1    qfi=1    pdu=1    Tput_dl=5*0.9    Tput_ul=3*0.9    sleep_time=10s
    Add DRB 5qi3    ue_id=1    fail_regexp=mcs-Table qam64LowSE
    Verify Throuput    ue_id=1    qfi=1    pdu=1    Tput_dl=5*0.9    Tput_ul=3*0.9    sleep_time=10s
    Send And Verify Throuput    ue_id=1    qfi=2    pdu=1    send_dl=5    send_ul=3    sleep_time=10s
    UE Deregister From gNB    ue_id=1
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008246_L_01${/}a2a.ini    wait_string=UEContextReleaseComplete::4

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/2cells_1T1F    ue_count=15

Modify Cfg
    Delete Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=1 5qi=1
    Update Cfg    set_qosflow id=2 5qi=2 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=3 5qi=3 gfbr_ul=30720 gfbr_dl=2000 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=4 5qi=4 gfbr_ul=2000 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=5 5qi=5
    Update Cfg    set_qosflow id=6 5qi=6 default=on
    ${AutoVariable_1}    catenate
    ...    set_ue simulated id=1 uec=1 red_cap=true release=17 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+zuc nea=null sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645400 mode=nr enb=2 cell=1
    Update Cfg    ${AutoVariable_1}
    Update Cfg    ue_param id=1 ue_nr_capabilities=${UE_Capa_Support_Redcap}

UE Attach To Target Cell 2DRB
    [Arguments]    ${ue_id}    ${cell_id}    ${default_qos}    ${fail_regexp}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=3
    ${retvalue}    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${ue_id} nwslice=1    fail_regexp=${fail_regexp}
    should contain    ${retvalue}    supportOfRedCap-r17 supported
    should contain    ${retvalue}    Setup QosFlow with QFI:1 5QI:6
    should contain    ${retvalue}    Setup QosFlow with QFI:2 5QI:3

Del DRB 5qi3
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_del=3 by=amf
    ...    pass_regexp=Removed FiveQi:Qfi mapping fiveQi 3 qfi 2

Add DRB 5qi3
    [Arguments]    ${ue_id}    ${fail_regexp}
    ${retvalue}    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=3 by=amf
    ...    fail_regexp=${fail_regexp}
    should contain    ${retvalue}    Added QosFlow with QFI:2 5QI:3

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Verify Throuput
    [Arguments]    ${ue_id}    ${qfi}    ${pdu}    ${Tput_dl}    ${Tput_ul}    ${sleep_time}
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Send And Verify Throuput
    [Arguments]    ${ue_id}=1    ${qfi}=1    ${pdu}=1    ${send_dl}=30    ${send_ul}=10    ${sleep_time}=10s
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=dl mbps=${send_dl}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=ul mbps=${send_ul}
    Verify Throuput    ${ue_id}    ${qfi}    ${pdu}    ${send_dl}*0.9    ${send_ul}*0.9    ${sleep_time}
