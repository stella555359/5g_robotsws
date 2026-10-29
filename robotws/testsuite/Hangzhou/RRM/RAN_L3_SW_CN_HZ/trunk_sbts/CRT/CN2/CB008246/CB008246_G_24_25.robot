*** Settings ***
Documentation    Suite description
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-Beam    owner-chunlan.yang
...    CLOUD_5G_I_BOO_AP_LOO_SANSA_FS_ECPRI_CMWV_FDD+TDD    CRT    CB008246    release-SBTS23R3
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
...    NRCELL-1:dlMcsDowngradeForHr=disabled
...    NRCELL-1:ulMcsDowngradeForHr=disabled
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
...    NRBTS-1/NRDRB-11:nrPdschHRLaDN=MRBTS-1/NRBTS-1/NRPDSCHHRLA-1
...    NRBTS-1/NRDRB-12:nrPdschHRLaDN=MRBTS-1/NRBTS-1/NRPDSCHHRLA-2
...    NRBTS/NRDU-1:carrierAggregationSupportList=none
...    NRBTS-1/BWP_PROFILE-3/PDCCH-1:alSelection=static
...    NRBTS-1/BWP_PROFILE-4/PDCCH-1:alSelection=static

@{8246_G_related_modification}
...    NRBTS/NRPDSCHHRLA-1:dllaBlerTargetHR=5
...    NRBTS/NRPDSCHHRLA-1:scalFactorForHRGbrDl=200
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerOutageMcsThresh64qam=3
...    NRBTS/NRPDSCHHRLA-2:dllaBlerTargetHR=8
...    NRBTS/NRPDSCHHRLA-2:scalFactorForHRGbrDl=120
...    NRBTS/NRPMRNL-1:miNrUlHarqOne=5min
...    NRCELL-1:pdschHrLaConfig:dllaMcsMax64qamLowSERANK1HR=25
...    NRCELL-1:pdschHrLaConfig:dllaMcsMax64qamLowSERANK2HR=25
...    NRCELL-1:pdschHrLaConfig:dllaMcsMax64qamLowSERANK3HR=20
...    NRCELL-1:pdschHrLaConfig:dllaMcsMax64qamLowSERANK4HR=20
...    NRCELL-1:pdschHrLaConfig:dllaMcsMax64qamRANK1HR=25
...    NRCELL-1:pdschHrLaConfig:dllaMcsMax64qamRANK2HR=25
...    NRCELL-1:pdschHrLaConfig:dllaMcsMax64qamRANK3HR=20
...    NRCELL-1:pdschHrLaConfig:dllaMcsMax64qamRANK4HR=20

@{8246_G_5qi3_modification}
...    NRCELL-1:actNonVoNRGbrService=true
...    NRCELL-1:actGBRAdmissionControl=GBRService
...    NRCELL-1:maxGBRTrafficLimit=5
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
...    NRBTS/NRDRB-16:rlcMode=RLC_UM
...    NRBTS/NRDRB-16:schedulWeight=${EMPTY}
...    NRBTS/NRDRB-16:nrDrbRlcAmDN=${EMPTY}
...    NRBTS/NRDRB-16:nsaDrbParam=${EMPTY}
...    NRBTS/NRDRB-16:maxDataRateGbrDl=30720
...    NRBTS/NRDRB-16:maxDataRateGbrUl=30720
...    NRBTS/NRDRB-16:dlFlowControlAlgo=3gppFlowControl
...    NRBTS/NRDRB-16:cellAggrLevel=Not FR1 CA eligible
...    NRBTS/NRDRB_5QI-7:fiveqiValueList=3
...    NRBTS/NRDRB_5QI-7:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-16
...    NRBTS/NRDRB_MAC-3:delayTarget=50
...    NRBTS/NRDRB_MAC-5:delayTarget=50
...    NRBTS/NRDRB_MAC-5:lcgid=5
...    NRBTS/NRDRB_MAC-5:schedulBSD=100ms
...    NRBTS/NRDRB_MAC-5:schedulPrio=5
...    NRBTS-1/NRDRB-16:nrPdschHRLaDN=MRBTS-1/NRBTS-1/NRPDSCHHRLA-2

${UE_Capa_Support_HRLA}    SEPARATOR=
...    EDA09000575F5A13160003C320016093170019C3D09009B24C39F30C7942C0E098040623807DC6C28C0D608C21A08107482406D6C98AB1A1
...    CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00098000702A0D883AC1184341020F10480CAD931562439F604F
...    88E3C62471E439F51CF9863CA1607038784FEC000003FB000000260001C0AA3626EB04610D04083A412030B64C55110E7C471E238F40CFB0
...    27C639F30C7942C0E070F05C00FFC007003FF0004C000381506C46D608C21A0810788240656C98AB121CF88E3D813E31238F21CFA8E7CC31
...    E50B0381C3C27FFC00001FFF00000130000E007BC3C4D000E208000010B0102A0F0A000388C0000042C0AC3C46000E208000030B02B0F0A0
...    0038820000042C0AC3C4D000E230000010B02B17118003882001C4100000A160561E14000713400003058158B89A001C41000E140000040B
...    02B1713400388C001C46000004160562E14000710400388C0000082C0AC5C28000E20800710400001058158B89A001C41000E230000020B0
...    2B170A000388C001C46000004160562E2680071180038500000102C0AC3C46000E230000030B0200E0234028809B01043D02EC1F0A244D8E
...    7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C38912244D8E7C3850206C73E044810206C73E044810206C73E044810206C73E04
...    4810206C73E044810206C73E044810206C73E044810206C73E0428103639F0005C3C6318C6318C6318C63187A09801E00140E0A00E060128
...    03800301200203014000000000120040081F0480100000000800001004000000020000040100000400800003004000020020000140100080
...    2008020000180100000E008004000000100001000800009004000018020000280100001600800409024010000180672A6B2A6B052B032B06
...    6B056B296B266B016B036B012B022B07681A0800004B29282000032CA4A0800014B29202000072CA480800024B292020000B2CA480800034
...    B292020000F2CA480800044B29202000132CA480800054B29202000172CA4A0800064B29202000062CA480669555D2AAAA55174AA2A82C55
...    058AA0D154A62A93455018AA051549AAA83C5090178095028140A05028140A05028140A05028140A05028140018202018030080100210100
...    2008040300610080100202018030080600C10100C018040300610080100202018030080100220100C01804030060100C0182020040100801
...    0043543E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A0

*** Test Cases ***
CB008246_G_024_FR1_SA_TDD_Scheduling_5G_UE_with_multiple_nonGBR_one_GBR_HRDRBs_in_DL_new_addition_via_ICS_Non_Optimize
    [Documentation]
    ...    1.Description
    ...    This user scenario validates the gNB behaviour for the setup and release of one or more non-GBR High
    ...    Reliability DRBs and data transmission in DL.
    ...    2.Configuration
    ...      a.SA,TDD.
    ...      b.Configured Link Adaptation High Reliability feature: NRBTS/NRCELL.actLAForHiReliab=true.
    ...      c.Default drb 5QI6 & 5QI7 are associated with NRPDSCHHRLA profile.
    ...      d.UE support Dl-64QAM-MCS-TableAlt.
    ...    3.Test Steps
    ...      a.UE attach to target cell via ICS,5QI6&7 are setup via PDU.
    ...      b.online change
    ...      b.UE detach.
    ...    4.Check Points
    [Tags]    QC_302841    owner-chunlan.yang
    Update UE capa    ue_id=81    SA_Capa_perUE_Full=${UE_Capa_Support_HRLA}
    Change 5qi3 gfbr 2000
    UE Attach To Target Cell via ICS Non Optimize    ue_id=82    cell_id=1
    Send And Verify Throuput    ue_id=82    qfi=1    send_dl=3    sleep_time=5    pdu=1
    Add Qosflow 3
    Send And Verify Throuput    ue_id=82    qfi=2    send_dl=3    sleep_time=5    pdu=1
    Change 5qi3 gfbr 20000
    UE Attach To Target Cell via ICS Non Optimize    ue_id=81    cell_id=1
    Send And Verify Throuput    ue_id=81    qfi=1    send_dl=3     sleep_time=5    pdu=1
    sleep    5
    Add Qosflow 3 and 7
    Smf Param Reset After case finished
    UE Deregister From gNB    ue_id=82
    UE Deregister From gNB    ue_id=81
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008246_G_24${/}a2a.ini    wait_string=UEContextReleaseComplete::16

CB008246_G_025_FR1_SA_TDD_Scheduling_5G_UE_with_multiple_nonGBR_one_GBR_HRDRBs_in_DL_new_addition_via_ICS_normal_ue
    [Documentation]
    ...    1.Description
    ...    This user scenario validates the gNB behaviour for the setup and release of one or more non-GBR High
    ...    Reliability DRBs and data transmission in DL.
    ...    2.Configuration
    ...      a.SA,TDD.
    ...      b.Configured Link Adaptation High Reliability feature: NRBTS/NRCELL.actLAForHiReliab=true.
    ...      c.Default drb 5QI6 & 5QI7 are associated with NRPDSCHHRLA profile.
    ...      d.UE support Dl-64QAM-MCS-TableAlt.
    ...    3.Test Steps
    ...      a.UE attach to target cell via ICS,5QI6&7 are setup via PDU.
    ...      b.online change
    ...      b.UE detach.
    ...    4.Check Points
    [Tags]    QC_302840    owner-chunlan.yang
    UE Attach To Target Cell via ICS    ue_id=82    cell_id=1
    Send And Verify Throuput    ue_id=82    qfi=1    send_dl=3    sleep_time=5    pdu=1
    Change 5qi3 gfbr 2000
    Add Qosflow 3
    Send And Verify Throuput    ue_id=82    qfi=2    send_dl=3    sleep_time=5    pdu=1
    UE Attach To Target Cell via ICS    ue_id=81    cell_id=1
    Send And Verify Throuput    ue_id=81    qfi=1    send_dl=3     sleep_time=5    pdu=1
    Change 5qi3 gfbr 20000
    sleep   5
    Add Qosflow 3 and 7
    Smf Param Reset After case finished
    UE Deregister From gNB    ue_id=82
    UE Deregister From gNB    ue_id=81
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008246_G_25${/}a2a.ini    wait_string=UEContextReleaseComplete::8

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
    Update Cfg    set_qosflow id=5 5qi=5
    Update Cfg    set_qosflow id=6 5qi=6 default=on
    Update Cfg    set_qosflow id=7 5qi=7
    Update Cfg    set_qosflow id=8 5qi=8

Update UE capa
    [Arguments]    ${ue_id}    ${SA_Capa_perUE_Full}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

UE Attach To Target Cell via ICS Non Optimize
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    qosflow_modify default=on qos_flow=6 priority=1
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    amf_param empty_pdu_session_list=on id=1
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1    QoS Routing Table
    Execute Egate Command    ue_ng_ctx_release id=${ue_id} by=amf cause=RN_successful_handover    UE Context Release Complete
    Execute Egate Command    amf_ue_ics_param id=1 include_ue_capabilities=off
    Execute Egate Command    ue_im_exit id=${ue_id} by=ue    Initial Context Setup Successful

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

Send And Verify Throuput
    [Arguments]    ${ue_id}    ${qfi}    ${send_dl}    ${sleep_time}    ${pdu}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=dl mbps=${send_dl}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=ul mbps=1
    Verify Throuput    ${ue_id}    ${qfi}    ${send_dl}*0.9    ${sleep_time}    ${pdu}

Verify Throuput
    [Arguments]    ${ue_id}    ${qfi}    ${Tput_dl}    ${sleep_time}    ${pdu}
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=dl    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}

Smf Param Reset After case finished
    Execute Egate Command    smf_param id=1 reset

Add Qosflow 3
    Execute Egate Command    ue_pdu_session_modify ue=82 pdu=1 qosflows_to_add=3 by=amf
    ...    pass_regexp=Pdu Session Resource Modify Response Message

Add Qosflow 3 and 7
    Execute Egate Command    ue_pdu_session_modify ue=81 pdu=1 qosflows_to_add=3,7 by=amf
    ...    pass_regexp=Pdu Session Resource Modify Response Message

Change 5qi3 gfbr 2000
    Execute Egate Command    qosflow_modify qos_flow=3 gfbr_dl=2000

Change 5qi3 gfbr 20000
    Execute Egate Command    qosflow_modify qos_flow=3 gfbr_dl=20000
