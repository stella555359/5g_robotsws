*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CIT    CLOUD_R4xAPO_CUS    release-FL16
...               team-SG4    owner-zhiguo.li
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...  LNBTS-1:actDLCAggr=true
...  LNBTS-1:actAdvScellMeas=true
...  LNBTS-1:actFlexScellSelect=true
...  LNBTS-1:actAmbrModCaTrigger=false
...  LNBTS-1:actFlexCaMgmt=false
...  LNBTS-1:sCellActivationMethod=nonGBRBufferBasedStepWise
...  LNBTS-1/LNBTS_FDD-0:numTxWithHighNonGbr=50
...  LNCEL-1/CAREL-5:lcrId=5
...  LNCEL-1/CAREL-5:lnBtsId=1
...  LNCEL-1/CAREL-5:maxNumOfSuppMimoLayer=2-layer
...  LNCEL-1/CAREL-5:pcellSwapAllowed=allowed
...  LNCEL-1/CAREL-5:scellPrio=3
...  LNCEL-2/CAPR-1:sFreqPrio=3
...  LNCEL-2/CAREL-1:lcrId=1
...  LNCEL-2/CAREL-1:lnBtsId=1
...  LNCEL-2/CAREL-1:maxNumOfSuppMimoLayer=2-layer
...  LNCEL-2/CAREL-1:pcellSwapAllowed=allowed
...  LNCEL-2/CAREL-1:scellPrio=3
...  LNCEL-2/CAREL-5:lcrId=5
...  LNCEL-2/CAREL-5:lnBtsId=1
...  LNCEL-2/CAREL-5:maxNumOfSuppMimoLayer=2-layer
...  LNCEL-2/CAREL-5:pcellSwapAllowed=allowed
...  LNCEL-2/CAREL-5:scellPrio=3
...  LNCEL-1/LNCEL_FDD-0:dlChBw=5 MHz
...  LNCEL-1/LNCEL_FDD-0:ulChBw=5 MHz
...  LNCEL-2/LNCEL_FDD-0:dlChBw=5 MHz
...  LNCEL-2/LNCEL_FDD-0:ulChBw=5 MHz
...  LNCEL-5/LNCEL_FDD-0:dlChBw=5 MHz
...  LNCEL-5/LNCEL_FDD-0:ulChBw=5 MHz
...  LNCEL:actScellConfigForHiDemand=false
...  LNCEL:eTputFilterConfig=51
...  LNCEL:eTputInitMcs=20
...  LNCEL:actCaArchEnhImp=off
...  LNCEL:actFlowCtrlEnh=false
...  LNCEL:cqiAperEnable=false
...  LNCEL:actModulationSchemeDl=256QAM
...  LNCEL:actModulationSchemeUL=64QAM
...  LNCEL/LNCEL_FDD-0:maxNumUeDl=7
...  LNCEL/LNCEL_FDD-0:maxNumUeUl=7
...  LNCEL/LNCEL_FDD-0:actUciOnlyGrants=false
...  LNCEL:actInterFreqLB=false
...  LNCEL:actDrx=false
...  LNCEL-1/DRX-0:drxProfile2:drxOnDuratT=6
...  LNCEL:iFLBLoadThresholds:iFLBBearCheckTimer=1
...  LNCEL:iFLBLoadThresholds:iFLBHighLoadGBRDL=80
...  LNCEL:iFLBLoadThresholds:iFLBHighLoadNonGBRDL=10
...  LNCEL:iFLBLoadThresholds:iFLBHighLoadPdcch=10
...  LNCEL:iFLBLoadThresholds:iFLBRetryTimer=10
...  LNCEL:loadSettings:targetLoadNonGbrDl=10
...  LNCEL:loadSettings:targetLoadPdcch=10
...  delete:LNCEL-1/LNHOIF-4
...  @{Tput}
@{Tput}
...  LNCEL:actLdPdcch=true
...  LNCEL:adaptPdcchDwellTime=0
...  LNCEL:mbrSelector=ueCapability
...  LNCEL:actDl256QamChQualEst=false
...  LNCEL:dl256QamDeactChQualThr=13
...  LNCEL:dl256QamReactChQualThr=22
...  LNCEL:iniDl256QamChQualEst=1s
...  LNCEL:perDl256QamChQualEst=60s
...  LNCEL:actDlPwBackoff=true
...  LNCEL:dlPwBackoffStructure:dlPwBackoffApp=ALL
...  LNCEL:dlPwBackoffStructure:dlPwBackoffThreshold=50
...  LNCEL:dlPwBackoffStructure:maxDlPwBackoffValue1=0
...  LNCEL:dlPwBackoffStructure:maxDlPwBackoffValue2=1
...  LNCEL:dlPwBackoffStructure:usageOfMaxDlPwBackoffValue2=QAM256r1r2r3r4
...  LNCEL:dlTargetBler=100
...  LNBTS:pdcpProf2:snSize=15bit
...  LNBTS:rlcProf7:tReord=15ms
${ue_eutra_capabilities_64qam}
...  SEPARATOR=
...  D5B80485001040C20D850BF85FC2FE17F0BF85FFFFFFFFFC00801C1E40000000152A56E22307000000420003800000230001C00000120000E00
...  0000B60007080000420003840000230001C2000016C0006100002061000040E3000008C00071800005B00018C000101B6000105800000210010
...  800160000008400460005800000210016C000E00000084020B0000004600230002C000001180090000B00000046002D8001C000001180416100
...  0008400460005840000210016C00161000008C00460005840000230016C000E1000008C02070800024600038400012D8001C6000096C000E100
...  000800007180000400005840000200011800163000008000420003B60000200001DB0000108001630000080005B00230BF85FC2FE17F0BF85FC
...  2FE17F0BF85FC2FE17F0BF85FC2FE17F0BF85FC2FE17F0BF85FC2FE17F0BF85FC2FE17F0BF85FC2FE17F0BF85FC2FE17F282000003473E04F81
...  3E04F813F04F813E04F013C04FE13E04FC13C04F013E04F013C04F813E04FC13E04F813C04F813C04F813C04F013E04F813E04F813E04F813E0
...  4FC08A234610002A80010022950
${ue_eutra_capabilities_256qam}
...  SEPARATOR=
...  D598085001040C20D850BF85FC2FE17F0BF85FFFFFFFFFC00801C227FFFFFFFD52A5DA3E220460E000000840007000000460003800000240001
...  C0000016C000E1000008400070800004600038400002D8000C2000040C2000081C60000118000E300000B60003180002036C00020B000000420
...  0210002C00000108008C000B00000042002D8001C0000010804160000008C00460005800000230012000160000008C005B0003800000230082C
...  20000108008C000B08000042002D8002C20000118008C000B08000046002D8001C20000118040E1000048C00070800025B00038C00012D8001C
...  20000100000E30000080000B0800004000230002C60000100008400076C0000400003B60000210002C6000010000B6004617F0BF85FC2FE17F0
...  BF85FC2FE17F0BF85FC2FE17F0BF85FC2FE17F0BF85FC2FE17F0BF85FC2FE17F0BF85FC2FE17F0BF85FC2FE17F0BF85FC2FFFFFFFFFE68E7C09
...  F027C09F027E09F027C09E027809FC27C09F827809E027C09E027809F027C09F827C09F027809F027809F027809E027C09F027C09F027C09F02
...  7C09F81B4A080D194980605FFFB5EA0004008A540
${TTITRACE_FLAG}    ${True}
${CUS_PCAP_FLAG}    ${False}
${CUS_PCAP_OPTIONS}    -c 1 --sch --phy --payload 1
${CUS_LOG_LEVEL}    INFO    # DEBUG
${CUS_SYSLOG_MODE}    INFO    # DEBUG
${DEBUG_LOG_LEVEL}    2    # 0
${1A_ICS_FLOW}    measObjectToAddModList contains (carrierFreq eq 300)
${1A_ICS_DRX_FLOW}    measObjectToAddModList contains (carrierFreq eq 300) and drx-Config contains (onDurationTimer eq 'psf6')
${NO_SCELL_FLOW}    sCellToAddModList-r10 contains (sCellIndex-r10 eq 1)
${3A_OR_7A_FLOW}    SEPARATOR=${SPACE}
...    (sCellToAddModList-r10 contains ((sCellIndex-r10 eq 1) and (dl-CarrierFreq-r10 eq 1700))) or
...    (sCellToAddModList-r10 contains ((sCellIndex-r10 eq 1) and (dl-CarrierFreq-r10 eq 3000)))
${7A_OR_3A_FLOW}    SEPARATOR=${SPACE}
...    (sCellToAddModList-r10 contains ((sCellIndex-r10 eq 2) and (dl-CarrierFreq-r10 eq 3000))) or
...    (sCellToAddModList-r10 contains ((sCellIndex-r10 eq 2) and (dl-CarrierFreq-r10 eq 1700)))
${3A_HO_FLOW}    SEPARATOR=${SPACE}
...    (mobilityControlInfo contains ((targetPhysCellId eq 2) and (dl-CarrierFreq eq 1700))) and
...    (sCellToReleaseList-r10 contains (1, 2))
${1A_OR_7A_FLOW}    SEPARATOR=${SPACE}
...    (sCellToAddModList-r10 contains ((sCellIndex-r10 eq 1) and (dl-CarrierFreq-r10 eq 300))) or
...    (sCellToAddModList-r10 contains ((sCellIndex-r10 eq 1) and (dl-CarrierFreq-r10 eq 3000)))
${7A_OR_1A_FLOW}    SEPARATOR=${SPACE}
...    (sCellToAddModList-r10 contains ((sCellIndex-r10 eq 2) and (dl-CarrierFreq-r10 eq 3000))) or
...    (sCellToAddModList-r10 contains ((sCellIndex-r10 eq 2) and (dl-CarrierFreq-r10 eq 300)))
@{3A_AND_7A_FLOW}    ${3A_OR_7A_FLOW}    ${7A_OR_3A_FLOW}
${LB_DRX_GAP}    SEPARATOR=${SPACE}
...    reportConfigToAddModList contains (a4-Threshold contains (threshold-RSRP eq 0)) and
...    drx-Config contains (onDurationTimer eq 'psf4') and
...    measGapConfig contains (gapOffset is present)
${DECFG_DRX_3A_OR_7A_FLOW}    SEPARATOR=${SPACE}
...    ((sCellToAddModList-r10 contains ((sCellIndex-r10 eq 1) and (dl-CarrierFreq-r10 eq 1700))) or
...    (sCellToAddModList-r10 contains ((sCellIndex-r10 eq 1) and (dl-CarrierFreq-r10 eq 3000)))) or
...    ((measIdToRemoveList contains (31)) and
...    (drx-Config contains (onDurationTimer eq 'psf6')) and
...    (measGapConfig contains (release is present)) and
...    ((sCellToAddModList-r10 contains ((sCellIndex-r10 eq 1) and (dl-CarrierFreq-r10 eq 1700))) or
...    (sCellToAddModList-r10 contains ((sCellIndex-r10 eq 1) and (dl-CarrierFreq-r10 eq 3000)))))
${DECFG_DRX_7A_OR_3A_FLOW}    SEPARATOR=${SPACE}
...    ((sCellToAddModList-r10 contains ((sCellIndex-r10 eq 2) and (dl-CarrierFreq-r10 eq 3000))) or
...    (sCellToAddModList-r10 contains ((sCellIndex-r10 eq 2) and (dl-CarrierFreq-r10 eq 1700)))) or
...    ((measIdToRemoveList contains (31)) and
...    (drx-Config contains (onDurationTimer eq 'psf6')) and
...    (measGapConfig contains (release is present)) and
...    ((sCellToAddModList-r10 contains ((sCellIndex-r10 eq 2) and (dl-CarrierFreq-r10 eq 3000))) or
...    (sCellToAddModList-r10 contains ((sCellIndex-r10 eq 2) and (dl-CarrierFreq-r10 eq 1700)))))
@{3A_AND_7A_DRX_FLOW}    ${LB_DRX_GAP}    ${DECFG_DRX_3A_OR_7A_FLOW}    ${DECFG_DRX_7A_OR_3A_FLOW}
@{actDrxDuringMeasGap}
...  LNCEL-1:actDrxDuringMeasGap=true
...  LNCEL-1/DRX-0:drxProfile2:drxOnDuratT=4
...  LNBTS-1/LNBTS_FDD-0:numTxWithHighNonGbr=2
...  LNCEL-1:actInterFreqLB=true
...  LNCEL-1:actDrx=true
...  LNCEL-1:actServRlqInterFreqLB=false
...  LNCEL-1:iFLBA4ActLim=20
@{deactDrxDuringMeasGap}
...  LNCEL-1:actDrxDuringMeasGap=false
...  LNCEL-1/DRX-0:drxProfile2:drxOnDuratT=6
...  LNBTS-1/LNBTS_FDD-0:numTxWithHighNonGbr=50
...  LNCEL-1:actInterFreqLB=false
...  LNCEL-1:actDrx=false

*** Test Cases ***
LTE1541_V01_01_Addition_of_SCells_after_handover
    [Tags]    TC11
    Set Ue Capabilities Before Attach
    UE Attach To Pcell
    Increase Traffic To Add Scells
    Collect UE Realtime Total Traffic
    UE HO To One Of Scell
    Collect UE Realtime Total Traffic
    Detach Single UE

LTE1541_V04_02_DRX_setup_while_SCells_are_configured
    [Tags]    TC42
    Configure Enb
    Set Multi Ues Capabilities Before Attach
    Multi UEs Attach To Pcell
    Increase Traffic To Add Scells One Step
    Collect Multi UEs Realtime Total Traffic
    Detach Multi UEs
    [Teardown]    Recover Env

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=9CELLs_FDD
    Create UE Group Aliases    UE_GROUP    start_ue_id=1    stop_ue_id=30    id_type=cus
    Create Enb Alias    alias=ENB_1    enb_id=10.0.1.2    id_type=real
    Create MME Alias    MME_1    mme_id=1    id_type=wts
    Execute Egate Command    trace uec=1 mme=1 protocol=rrc,s1,x2 on
    # Comment    "turbo" truncates TCP traffic on pdcp in downlink but not document
    # Execute Uex Command    turbo_mode_l2 cell=1 mode=enable
    # Execute Uex Command    turbo_mode_l2 cell=2 mode=enable
    # Execute Uex Command    turbo_mode_l2 cell=5 mode=enable

Modify Yaml
    # Update Yaml    LOGS/CUS
    # ...    log_level: 'DEBUG'
    # ...    syslog_mode: 'DEBUG'
    # Update Yaml    LOGS/EPC
    # ...    log_level: 0
    # Update Yaml    EPC/WS/1    link_ctrl_param: {hb_period: 180, hb_retries: 10, app_type: sgw}
    # Update Yaml    EPC/SGW/1
    # ...    s1u_rcv_buff_size: 200000000
    # ...    s1u_snd_buff_size: 200000000
    # ...    s5u_rcv_buff_size: 200000000
    # ...    s5u_snd_buff_size: 200000000
    # ...    gtpu_read_packets_threshold: 20
    # Update Yaml    EPC/PGW/1
    # ...    sgi_rcv_buff_size: 200000000
    # ...    sgi_snd_buff_size: 200000000
    # ...    s5u_rcv_buff_size: 200000000
    # ...    s5u_snd_buff_size: 200000000
    # ...    sgi_read_packet_threshold: 20
    # ...    mtu: 2000
    FOR    ${ue_id}    IN RANGE    1    11
        Update Yaml    UEs/UE_sets/${ue_id}
        ...    'rohc': 16
        ...    'category': 12
        ...    'dl_256QAM_supported': 'on'
        ...    'ul_64QAM_supported': 'on'
        ...    'fgi': '1-32'
        ...    'fgi_r9': '33-64'
        ...    'fgi_r10': '101-132'
    END

Set Ue Capabilities Before Attach
    [Arguments]    ${ueid}=1    ${ue_eutra_capabilities}=${ue_eutra_capabilities_256qam}
    Execute Uex Command    ue_cqi_param id=${ueid} set=1 scell=0-7 rank=4 wb=15:15:15 ignore_codebook_subset_restriction=true
    Execute Uex Command    ue_cqi_param id=${ueid} set=2 scell=0-7 rank=4 wb=15:15:15 ignore_codebook_subset_restriction=true
    Execute Uex Command    ue_param id=${ueid} ue_eutra_capabilities=${ue_eutra_capabilities}

Set Multi Ues Capabilities Before Attach
    [Arguments]    ${start_ueid}=2    ${end_ueid}=3    ${ue_eutra_capabilities}=${ue_eutra_capabilities_256qam}
    FOR    ${ueid}    IN RANGE    ${start_ueid}    ${${end_ueid}+1}
        Execute Uex Command    ue_cqi_param id=${ueid} set=1 scell=0-7 rank=4 wb=15:15:15 ignore_codebook_subset_restriction=true
        Execute Uex Command    ue_cqi_param id=${ueid} set=2 scell=0-7 rank=4 wb=15:15:15 ignore_codebook_subset_restriction=true
        Execute Uex Command    ue_param id=${ueid} ue_eutra_capabilities=${ue_eutra_capabilities}
    END

UE Attach To Pcell
    [Arguments]    ${ueid}=1    ${cellid}=1    ${ICS_msg}=${1A_ICS_FLOW}    ${NO_SCELL_msg}=${NO_SCELL_FLOW}
    Expect Message Flow    UE_GROUP_${ueid}:RRC_RRCConnectionReconfiguration (${ICS_msg}) as ICS_msg
    ...    alias=ICS_flow    overall_timeout=20
    Expect Message Will Not Occur    UE_GROUP_${ueid}:RRC_RRCConnectionReconfiguration (${NO_SCELL_msg}) as NO_SCELL_msg
    ...    alias=NO_SCELL_flow    overall_timeout=20
    Execute Uex Command    ue_attach id=${ueid} cell=${cellid}
    Flow Occurred As Expected    alias=ICS_flow
    Flow Not Occurred For Message    alias=NO_SCELL_flow

Multi UEs Attach To Pcell
    [Arguments]    ${start_ueid}=2    ${end_ueid}=3    ${cellid}=1    ${ICS_msg}=${1A_ICS_DRX_FLOW}    ${NO_SCELL_msg}=${NO_SCELL_FLOW}
    FOR    ${ueid}    IN RANGE    ${start_ueid}    ${${end_ueid}+1}
        Expect Message Flow    UE_GROUP_${ueid}:RRC_RRCConnectionReconfiguration (${ICS_msg}) as ICS_msg
        ...    alias=ICS_flow    overall_timeout=20
        Expect Message Will Not Occur    UE_GROUP_${ueid}:RRC_RRCConnectionReconfiguration (${NO_SCELL_msg}) as NO_SCELL_msg
        ...    alias=NO_SCELL_flow    overall_timeout=20
        Execute Uex Command    ue_attach id=${ueid} cell=${cellid}
        Flow Occurred As Expected    alias=ICS_flow
        Flow Not Occurred For Message    alias=NO_SCELL_flow
    END

Increase Traffic To Add Scells
    [Arguments]    ${ueid}=1    ${SCELL1_msg}=${3A_OR_7A_FLOW}    ${SCELL2_msg}=${7A_OR_3A_FLOW}
    Expect Message Flow
    ...    UE_GROUP_${ueid}:RRC_RRCConnectionReconfiguration (${SCELL1_msg}) as SCELL1_msg
    ...    UE_GROUP_${ueid}:RRC_RRCConnectionReconfiguration (${SCELL2_msg}) as SCELL2_msg
    ...    alias=SCELL_flow    overall_timeout=60
    Log To Console    \nStart Traffic...
    Execute Uex Command    trf_data_start ue=${ueid} dir=dl_and_ul protocol=udp Mbps=10 trf_id=1
    Execute Uex Command    trf_data_start ue=${ueid} dir=dl_and_ul protocol=tcp Mbps=10 size=1500 trf_id=2
    Sleep    3
    FOR    ${trf}    IN RANGE    2    11
        Execute Uex Command    trf_data_start ue=${ueid} dir=dl protocol=udp Mbps=10 trf_id=${${${trf}*2}-1}
        # Execute Uex Command    trf_data_start ue=${ueid} dir=dl protocol=tcp Mbps=10 size=1500 trf_id=${${trf}*2}
        Sleep    3
    END
    Flow Occurred As Expected    alias=SCELL_flow

Increase Traffic To Add Scells One Step
    [Arguments]    ${first_ueid}=2    ${last_ueid}=3    ${first_ue_msg}=${3A_AND_7A_FLOW}    ${last_ue_msg}=${3A_AND_7A_DRX_FLOW}
    Expect Message Flow
    ...    UE_GROUP_${first_ueid}:RRC_RRCConnectionReconfiguration (${first_ue_msg[0]}) as first_ue_SCELL1_msg
    ...    UE_GROUP_${first_ueid}:RRC_RRCConnectionReconfiguration (${first_ue_msg[1]}) as first_ue_SCELL2_msg
    ...    UE_GROUP_${last_ueid}:RRC_RRCConnectionReconfiguration (${last_ue_msg[0]}) as last_ue_DRX_msg
    ...    UE_GROUP_${last_ueid}:RRC_RRCConnectionReconfiguration (${last_ue_msg[1]}) as last_ue_SCELL1_msg
    ...    UE_GROUP_${last_ueid}:RRC_RRCConnectionReconfiguration (${last_ue_msg[2]}) as last_ue_SCELL2_msg
    ...    alias=DRX_SCELL_flow    overall_timeout=60
    FOR    ${ueid}    IN RANGE    ${first_ueid}    ${${last_ueid}+1}
        Execute Uex Command    trf_data_start ue=${ueid} dir=dl protocol=udp Mbps=150 trf_id=1
        Execute Uex Command    trf_data_start ue=${ueid} dir=ul protocol=udp Mbps=10 trf_id=2
        Sleep    10s
    END
    Flow Occurred As Expected    alias=DRX_SCELL_flow

Collect UE Realtime Total Traffic
    [Arguments]    ${ueid}=1    ${target_dl}=10    ${target_ul}=5
    FOR    ${i}    IN RANGE    2
        ${Dl_Tp_Scells}    Get Throughput    ue_id=${ueid}    type=dl_mac
        ${Ul_Tp_Scells}    Get Throughput    ue_id=${ueid}    type=ul_mac    wait_time=5
        Log To Console    Dl_Tp_Scells: ${Dl_Tp_Scells}\nUl_Tp_Scells:${Ul_Tp_Scells}
        ${check_thp}    Catenate
        ...    (${Dl_Tp_Scells["UE"]["Overall"]["avg"]} >= ${target_dl} or ${Dl_Tp_Scells["UE"]["Overall"]["max"]} >= ${target_dl}) and
        ...    (${Ul_Tp_Scells["UE"]["Overall"]["avg"]} >= ${target_ul} or ${Ul_Tp_Scells["UE"]["Overall"]["max"]} >= ${target_ul})
        Should Be True    ${check_thp}
        Sleep    5
    END

Collect Multi UEs Realtime Total Traffic
    [Arguments]    ${start_ueid}=2    ${end_ueid}=3    ${target_dl}=0    ${target_ul}=0
    FOR    ${ueid}    IN RANGE    ${start_ueid}    ${${end_ueid}+1}
        ${Dl_Tp_Scells}    Get Throughput    ue_id=${ueid}    type=dl_mac
        ${Ul_Tp_Scells}    Get Throughput    ue_id=${ueid}    type=ul_mac    wait_time=5
        Log To Console    Dl_Tp_Scells: ${Dl_Tp_Scells}\nUl_Tp_Scells:${Ul_Tp_Scells}
        ${check_thp}    Catenate
        ...    (${Dl_Tp_Scells["UE"]["Overall"]["avg"]} >= ${target_dl} or ${Dl_Tp_Scells["UE"]["Overall"]["max"]} >= ${target_dl}) and
        ...    (${Ul_Tp_Scells["UE"]["Overall"]["avg"]} >= ${target_ul} or ${Ul_Tp_Scells["UE"]["Overall"]["max"]} >= ${target_ul})
        Should Be True    ${check_thp}
        Sleep    5
    END

UE HO To One Of Scell
    [Arguments]    ${ueid}=1    ${cellid}=2    ${HO_msg}=${3A_HO_FLOW}    ${SCELL1_msg}=${1A_OR_7A_FLOW}    ${SCELL2_msg}=${7A_OR_1A_FLOW}
    Expect Message Flow
    ...    UE_GROUP_${ueid}:RRC_RRCConnectionReconfiguration (${HO_msg}) as HO_msg
    ...    UE_GROUP_${ueid}:RRC_RRCConnectionReconfiguration (${SCELL1_msg}) as SCELL1_msg
    ...    UE_GROUP_${ueid}:RRC_RRCConnectionReconfiguration (${SCELL2_msg}) as SCELL2_msg
    ...    alias=HO_SCELL_flow    overall_timeout=20
    Execute Uex Command    ue_ho id=${ueid} enb=1 cell=${cellid}
    Flow Occurred As Expected    alias=HO_SCELL_flow

Detach Single UE
    [Arguments]    ${ueid}=1
    Execute Uex Command    trf_data_stop ue=${ueid}
    Execute Uex Command    ue_detach id=${ueid}

Detach Multi UEs
    [Arguments]    ${start_ueid}=2    ${end_ueid}=3
    FOR    ${ueid}    IN RANGE    ${start_ueid}    ${${end_ueid}+1}
        Execute Uex Command    trf_data_stop ue=${ueid}
        Execute Uex Command    ue_detach id=${ueid}
    END

Configure Enb
    [Arguments]    ${param}=${actDrxDuringMeasGap}
    Delta Commission Parameters    ${param}

Recover Env
    [Arguments]    ${param}=${deactDrxDuringMeasGap}
    Delta Commission Parameters    ${param}
    Common Test Teardown And Stop Capture Logs
