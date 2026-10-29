*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    4G_FDD    RAN_4G    RAN_4G_FDD    CIT
...               CLOUD_R4LAPO_CUS    release-xL18    owner-fei.he    team-DEVHZ5_FT2
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CATM}
...    @{PARAMS_FOR_MBMS}
...    @{PARAMS_FOR_OTDOA}
...    @{PARAMS_FOR_LVRB}
...    @{PARAMS_FOR_CELL_CONFIG}
...    @{PARAMS_FOR_DISABLE_OTHER_FEATURE_FLAG}
...    @{PARAMS_FOR_LTE2085}
@{PARAMS_FOR_CATM}
...    LNCEL-1/LNCEL_FDD-0:actCatM=true
...    LNCEL-1/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-1/LNCEL_FDD-0:catMProfId=1
...    LNCEL-1/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=InnerLowerEdge
...    LNCEL-1/CATMCEL-0:actSf9InvalidLVRBCatM=true
...    LNCEL-1:pagingNb=oneT
...    LNCEL-1/CATMCEL-0:numCELevelCatM=1
...    LNBTS-1/CATMPR-1:mpdcchMaxNumRepRaCatM=n2
...    LNBTS-1/CATMPR-1:mpdcchMaxNumRepCatM=n2
...    LNBTS-1/CATMPR-1:raPreGrCSizeCatM=7
...    LNBTS-1/CATMPR-1:siWindowLenCatM=40ms
...    LNCEL-2/LNCEL_FDD-0:actCatM=true
...    LNCEL-2/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-2/LNCEL_FDD-0:catMProfId=1
...    LNCEL-2/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=InnerLowerEdge
...    LNCEL-2/CATMCEL-0:actSf9InvalidLVRBCatM=true
...    LNCEL-2:pagingNb=oneT
...    LNCEL-2/CATMCEL-0:numCELevelCatM=1
...    LNCEL-3/LNCEL_FDD-0:actCatM=false
...    LNCEL-3/CATMCEL-0:actSf9InvalidLVRBCatM=false
...    LNCEL-3/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNBTS-1/LNBTS_FDD-0:actIMSEmerSessR9=true
...    LNCEL-1/CATMCEL-0:actConvVoiceCatM=true
...    LNCEL-2/CATMCEL-0:actConvVoiceCatM=true
...    LNCEL-1/CATMCEL-0:actIMSEmerSessCatM=true
...    LNCEL-2/CATMCEL-0:actIMSEmerSessCatM=true
...    LNBTS-1/CATMPR-1:inactivityTimerCatM=150
...    LNBTS-1/CATMPR-1:catMVoLTETab:qci1ProtectionTimerCatM=180
...    LNCEL-3/CATMCEL-0:actConvVoiceCatM=false
...    LNCEL-3/CATMCEL-0:actIMSEmerSessCatM=false
...    delete:LNCEL-3/CATMCEL-0
...    LNCEL-1/SIB-0:threshServingLowQR9=0
...    LNCEL-1/SIB-0:cellSelectionInfoV920:qQualMinR9=-34|qQualMinOffsetR9=1
...    LNCEL-2/SIB-0:threshServingLowQR9=0
...    LNCEL-2/SIB-0:cellSelectionInfoV920:qQualMinR9=-34|qQualMinOffsetR9=1
...    LNCEL-3/SIB-0:threshServingLowQR9=0
...    LNCEL-3/SIB-0:cellSelectionInfoV920:qQualMinR9=-34|qQualMinOffsetR9=1
@{PARAMS_FOR_MBMS}
...    LNBTS-1:actMBMS=false
...    LNBTS-1:actETWS=true
...    LNBTS-1:actDynMBMSRes=false
...    LNBTS-1/LNMCE-0/MBSFNSYNCAREA_FDD-0:mbsfnEarfcn=1400
...    LNBTS-1/LNMCE-0/MBSFNSYNCAREA_FDD-0:mbsfnChBw=10 MHz
...    MRBTS-1/LNBTS-1/LNCEL-1/CATMCEL-0:acbPrimaryPlmnProfileIdCatM=0
...    MRBTS-1/LNBTS-1/LNCEL-2/CATMCEL-0:acbPrimaryPlmnProfileIdCatM=0
...    MRBTS-1/LNBTS-1/LNCEL-3/CATMCEL-0:acbPrimaryPlmnProfileIdCatM=0
...    MRBTS-1/LNBTS-1/LNCEL-2:acbPrimaryPlmnProfileId=0
...    MRBTS-1/LNBTS-1/LNCEL-3:acbPrimaryPlmnProfileId=0
...    LNBTS-1/LNMCE-0/MBSFNSYNCAREA_FDD-0:maxSyncSubfrPShare=25.000%
...    LNBTS-1/LNMCE-0/MBSFNSYNCAREA_FDD-0:syncAreaId=0
...    LNBTS-1/LNMCE-0/MBSFNSYNCAREA_FDD-0:mbsfnOverlapAllowed=false
...    LNBTS-1/LNMCE-0/MBSFNSYNCAREA_FDD-0/MBSFN_FDD-0:mbsfnAreaId=1
...    LNBTS-1/LNMCE-0/MBSFNSYNCAREA_FDD-0/MBSFN_FDD-0:maxSubfrPShare=25.000%
...    LNBTS-1/LNMCE-0/MBSFNSYNCAREA_FDD-0/MBSFN_FDD-0:mchInfo:qci=1
...    LNBTS-1/LNMCE-0/MBSFNSYNCAREA_FDD-0/MBSFN_FDD-0:mbmsSaiList=1
...    LNBTS-1/LNMCE-0/MBSFNSYNCAREA_FDD-0/MBSFN_FDD-0:mbsfnStartingSF=0
...    LNBTS-1/M1SYNC-0:mbmsSyncRef:integralSecs=0
...    LNBTS-1/LNMCE-0:m3TimeRef=UTC
...    LNBTS-1/M1SYNC-0:m1TimeRef=GregorianUTC
...    LNBTS-1/M1SYNC-0:mbmsSyncPeriod=100
...    LNBTS-1/LNMCE-0:servAreaCharacteristics:servAreaMaxBitRate=1|servAreaId=1
...    LNBTS-1/LNMCE-0:servAreaCharacteristics:servAreaMaxSessionBitRate=1|servAreaId=1
...    LNCEL-1/SIB-0:sibSchedulingList:siMessageSibType=SIB13|siMessagePeriodicity=160ms
...    LNCEL-2/SIB-0:sibSchedulingList:siMessageSibType=SIB13|siMessagePeriodicity=160ms
...    LNCEL-3/SIB-0:sibSchedulingList:siMessageSibType=SIB13|siMessagePeriodicity=160ms
...    LNCEL-1/SIB-0:sibSchedulingList:siMessageSibType=SIB10|siMessagePeriodicity=320ms
...    LNCEL-2/SIB-0:sibSchedulingList:siMessageSibType=SIB10|siMessagePeriodicity=320ms
...    LNCEL-3/SIB-0:sibSchedulingList:siMessageSibType=SIB10|siMessagePeriodicity=320ms
...    LNCEL-1/SIB-0:sibSchedulingList:siMessageSibType=SIB11|siMessagePeriodicity=640ms
...    LNCEL-2/SIB-0:sibSchedulingList:siMessageSibType=SIB11|siMessagePeriodicity=640ms
...    LNCEL-3/SIB-0:sibSchedulingList:siMessageSibType=SIB11|siMessagePeriodicity=640ms
...    LNCEL-1/MBSFNCEL-0:mbsfnAreaInUseList=1
...    LNCEL-1/SIB-0:mbmsNeighCellConfigIntraF=01
...    delete:LNCEL-3/MBSFNCEL-0
...    delete:LNCEL-3/CATMCEL-0
...    MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/MCAPP-1:ipIfDN=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1
...    LNBTS-1/LNMCE-0/LNM3-0:m3ipAddrPrim=10.0.1.1
...    LNBTS-1/M1SYNC-0:mbmsSyncRef:fractionalSecs=841813590
@{PARAMS_FOR_OTDOA}
...    LNCEL-1:actOtdoa=true
...    LNCEL-1/LNCEL_FDD-0:prsConfigurationIndex=151
...    LNCEL-1/LNCEL_FDD-0:prsNumDlFrames=1
...    LNCEL-1:prsBandwidth=50 PRB
...    LNCEL-2:actOtdoa=true
...    LNCEL-2:prsBandwidth=50 PRB
...    LNCEL-2/LNCEL_FDD-0:prsConfigurationIndex=151
...    LNCEL-2/LNCEL_FDD-0:prsNumDlFrames=1
...    LNCEL-3:actOtdoa=true
...    LNCEL-3/LNCEL_FDD-0:prsConfigurationIndex=151
...    LNCEL-3/LNCEL_FDD-0:prsNumDlFrames=1
...    LNCEL-3:prsBandwidth=50 PRB
@{PARAMS_FOR_LVRB}
...    LNCEL-1:dlsDciCch=DCI format 1A
...    LNCEL-2:dlsDciCch=DCI format 1A
@{PARAMS_FOR_LTE2085}
...    LNCEL-1/SIB-0:sib2xTransmit=false
...    LNCEL-2/SIB-0:sib2xTransmit=false
...    LNCEL-3/SIB-0:sib2xTransmit=false
@{PARAMS_FOR_CELL_CONFIG}
...    LNCEL-1/LNCEL_FDD-0:dlChBw=10 MHz
...    LNCEL-1/LNCEL_FDD-0:ulChBw=10 MHz
...    LNCEL-2/LNCEL_FDD-0:dlChBw=10 MHz
...    LNCEL-2/LNCEL_FDD-0:ulChBw=10 MHz
...    LNCEL-3/LNCEL_FDD-0:dlChBw=10 MHz
...    LNCEL-3/LNCEL_FDD-0:ulChBw=10 MHz
...    LNCEL-1/SIB-0:siWindowLen=20ms
...    LNCEL-2/SIB-0:siWindowLen=20ms
...    LNCEL-3/SIB-0:siWindowLen=20ms
...    LNCEL-1/DRX-0:drxProfile2:drxRetransT=16
...    LNCEL-1/DRX-0:drxProfile3:drxRetransT=16
...    LNCEL-1:drxProfile101:drxRetransT=16
...    LNCEL-1/SDRX-0:drxSmartProfile2:drxRetransT=16
...    LNCEL-1/SDRX-0:drxSmartProfile3:drxRetransT=16
...    LNCEL-2/DRX-0:drxProfile2:drxRetransT=16
...    LNCEL-2/DRX-0:drxProfile3:drxRetransT=16
...    LNCEL-2/SDRX-0:drxSmartProfile2:drxRetransT=16
...    LNCEL-2/SDRX-0:drxSmartProfile3:drxRetransT=16
...    LNCEL-2:drxProfile101:drxRetransT=16
...    LNCEL-3/DRX-0:drxProfile2:drxRetransT=16
...    LNCEL-3/DRX-0:drxProfile3:drxRetransT=16
...    LNCEL-3/SDRX-0:drxSmartProfile2:drxRetransT=16
...    LNCEL-3/SDRX-0:drxSmartProfile3:drxRetransT=16
...    LNCEL-3:drxProfile101:drxRetransT=16
@{PARAMS_FOR_DISABLE_OTHER_FEATURE_FLAG}
...    LNCEL-1:actEicic=false
...    LNCEL-2:actEicic=false
...    LNCEL-3:actEicic=false
...    LNCEL-1/LNCEL_FDD-0:actLiquidCell=false
...    LNCEL-2/LNCEL_FDD-0:actLiquidCell=false
...    LNCEL-3/LNCEL_FDD-0:actLiquidCell=false
...    LNCEL-1:nbIoTMode=disabled
...    LNCEL-2:nbIoTMode=disabled
...    LNCEL-3:nbIoTMode=disabled
...    LNBTS-1:actCMAS=false
${UE_EUTRA_CAPABILITIES_CATM}    D61FF000800055555D55001000804510021200055C041900    # CATM FGI3,7,20 set as 1,enable ROHC
${UE_EUTRA_CAPABILITIES_NORMAL}    CD9FF459B2E750081810381FFFFFFFFF2862000608020A5408008A80182CFFFFFFFF8053FFFFFFFF    # add FDD band3
${TIMER_WAIT_SIB_update_FINISH}    60
${EXPECTED_mpdcchStartSfCssCatM_2.5}    sf2dot5
${EXPECTED_mpdcchStartSfUessCatM_2.5}    v2dot5
${EXPECTED_mpdcchStartSfCssCatM_2}    sf2
${EXPECTED_mpdcchStartSfUessCatM_2}    v2
@{delta_para_otdoa_false}
...    LNCEL-1:actOtdoa=false
@{delta_para_mbms}
...    LNBTS-1:actMBMS=true
...    LNCEL:drxProfile104:drxOnDuratT=10

*** Test Cases ***
LTE4495-B_ET_01_02 Cat-M SI and wideband SI modification caused by MBMS pattern online change_actMBMS_actOtdoa
    [Tags]    owner-xu.wang
    Check SIB and Bitmap from RRC after Cell Setup
    Check Whether Gfactor=2    ${EXPECTED_mpdcchStartSfCssCatM_2}    ${EXPECTED_mpdcchStartSfUessCatM_2}
    UE1-UE4 attach and do data transfer
    Bitmap change and CatM UE release after enable MBMS
    Check Whether Gfactor=2.5    ${EXPECTED_mpdcchStartSfCssCatM_2.5}    ${EXPECTED_mpdcchStartSfUessCatM_2.5}
    Start MBMS Session and start MBMS data
    Execute Command On Enb    /opt/trs/bin/vtc iwf lte show-mcast-tbl
    Stop MBMS Session
    Bitmap change and CatM UE release after change OTDOA to false
    Check Whether Gfactor=2    ${EXPECTED_mpdcchStartSfCssCatM_2}    ${EXPECTED_mpdcchStartSfUessCatM_2}
    Start MBMS Session and start MBMS data
    Check Start MBMS session don't impact the SIB1-BR: bitmap
    Stop MBMS Session

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD
    Execute Egate Command    uec_set id=1 gtpu=on addr=11.7.255.254/16 peer=10.0.2.1:2152 retries=unlimited mbms_tun=1.2.4.254/24
    Execute Egate Command    mbms_param sync_ref=0:0
    Create UE Group Aliases    UE_GROUP    start_ue_id=1    stop_ue_id=4    id_type=cus
    Create CELL alias    alias=CELL_1    cell_id=1    cell_type=cus
    Create MME Alias    MME_1    mme_id=1    id_type=wts

Modify Yaml
    Update Yaml    EPC/MME/1    id: '1'    type: 'simulated'    ip: '127.0.0.1:10000'    pool: ['1:3']    s1: '10.0.1.1:36412'
    ...    m3: '10.0.1.1:36444'    sm: '127.0.1.1:0'
#set_mme id=1 ip=:10000 s1=10.0.1.1:36412 mmegi=1 mmec=3 supported_plmn=262:03 m3=10.0.1.1:36444 sm=127.0.0.1:0

    Add Yaml    EPC/MCE
        ...    - id: 1
        ...    m3: '10.0.1.2:36444'

    Add Yaml    EPC/MBMSGW
        ...    - id: 1
        ...    type: 'simulated'
        ...    daemon: '127.0.0.1:10000'
        ...    igmp_support: 'on'
        ...    m1: '10.0.1.1:2154'
        ...    sm: '127.0.1.1:0'
        ...    trf_interface: '1.2.3.254/24'
#set_mbmsgw id=1 type=simulated daemon=127.0.0.1:10000 sm=127.0.0.1:0 m1=10.0.1.1:2154 trf_interface=1.2.3.254/24

    Add Yaml    EPC/PGW
        ...    - id: 3
        ...    type: 'simulated'
        ...    apn: 'emergency.nsn.com'
        ...    emergency: 'on'

    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...      - {qci: 8, default: on, pdn: 1, trf_type: external}
    ...      - {qci: 1, gbr_ul: 25, gbr_dl: 25, mbr_ul: 25, mbr_dl: 25, pdn: 1}
    ...      - {qci: 6, pdn: 1}
     ...     - {qci: 5, default: on, pdn: 3, priority: 1}
    ...      - {qci: 1, pdn: 3, priority: 1, gbr_ul: 25, gbr_dl: 25, mbr_ul: 25, mbr_dl: 25}

    FOR    ${ue_id}    IN RANGE    1    5
        Update Yaml    UEs/UE_sets/${ue_id}    bearer: bearer_set_2
    END

Start MBMS Session and start MBMS data
    Execute Egate Command    mbms_param time_ref=UTC
    ${V_1}    catenate
    ...    mbms_session_start tmgi=1:262:03 qci=1 gbr=1000 sai=1 m1_dst_addr=232.0.0.1 m1_teid=1 mbmsgw_trf_tun_ip=1.2.3.1 dst_ip=1.2.4.254
    ...    dst_port=50001 max_delay=50 trf_adapt_scheme=buffering sync_seq=1 sync_period=100 time_correction_period=1 trf_start_delay=1
    Execute Egate Command    ${V_1}    MbmsSession with MME 1 has been successfuly started.
    Execute Cmd On Pc    iperf -s -B 1.2.4.254 -u -p 50001 2>&1 &
    Execute Cmd On Pc    iperf -c 1.2.3.1 -p 50001 -u -t 9999 -b 10k -l 200 2>&1 &
    sleep    20    #wait data stable
    Execute Uex Command    get_cell_stats area_id=1 type=mbms id=1

Stop MBMS Session
    Execute Egate Command    mbms_session_stop tmgi=1:262:03    MbmsSessionStopResponse

Check Whether Gfactor=2.5
    [Arguments]    ${expect_mpdcchStartSfCssCatM_2.5}    ${expect_mpdcchStartSfUessCatM_2.5}
    ${G_factor}    Create List
    ...    LNCEL-1/CATMCEL-0:mpdcchStartSfCssCatM=${expect_mpdcchStartSfCssCatM_2.5}
    ...    LNCEL-1/CATMCEL-0:mpdcchStartSfUessCatM=${expect_mpdcchStartSfUessCatM_2.5}
    Object Should Exist    ${G_factor}

Check SIB and Bitmap from RRC after Cell Setup
    Expect Message Flow
    ...    CELL_1:RRC_SystemInformationBlockType1-BR-r13 (subframePattern40-r13 eq '0b1111111110111111111011111111101011111110')
    ...    alias=sib1_br    overall_timeout=5
    Flow Occurred As Expected    alias=sib1_br

UE1-UE4 attach and do data transfer
    UE1 attach and do data transfer
    UE2 attach and do data transfer
    UE3 attach and do data transfer
    UE4 attach and do data transfer

UE1 attach and do data transfer
    Expect Message Flow
    ...    UE_GROUP_1:RRC_RRCConnectionSetup (ce-Mode-r13 contains ( setup eq 'ce-ModeA'))
    ...    MME_1:S1AP_InitialContextSetupRequest (E-RABToBeSetupListCtxtSUReq contains ( qCI eq 8 and priorityLevel eq 'no-priority' ))
    ...    alias=ue1    overall_timeout=30
    Execute Uex Command    ue_attach id=1 ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES_CATM} cell=1 enb=1
    Flow Occurred As Expected    alias=ue1
    execute uex command    trf_data_start ue=1 qci=8 dir=dl kbps=10 protocol=udp

UE2 attach and do data transfer
    Expect Message Flow
    ...    UE_GROUP_2:RRC_RRCConnectionSetup (ce-Mode-r13 contains ( setup eq 'ce-ModeA'))
    ...    MME_1:S1AP_InitialContextSetupRequest (E-RABToBeSetupListCtxtSUReq contains ( qCI eq 5 and priorityLevel eq 'highest' ))
    ...    alias=ue2    overall_timeout=30
    Execute Uex Command    ue_attach id=2 ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES_CATM} cell=1 enb=1 emergency=on
    Flow Occurred As Expected    alias=ue2
    execute uex command    trf_data_start ue=2 qci=5 dir=dl kbps=10 protocol=udp

UE3 attach and do data transfer
    Expect Message Flow
    ...    UE_GROUP_3:RRC_RRCConnectionSetup (ce-Mode-r13 is not present)
    ...    MME_1:S1AP_InitialContextSetupRequest (E-RABToBeSetupListCtxtSUReq contains ( qCI eq 8 and priorityLevel eq 'no-priority' ))
    ...    alias=ue3    overall_timeout=30
    Execute Uex Command    ue_attach id=3 ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES_NORMAL} cell=1 enb=1
    Flow Occurred As Expected    alias=ue3
    execute uex command    trf_data_start ue=3 qci=8 dir=dl kbps=10 protocol=udp

UE4 attach and do data transfer
    Expect Message Flow
    ...    UE_GROUP_4:RRC_RRCConnectionSetup (ce-Mode-r13 is not present)
    ...    MME_1:S1AP_InitialContextSetupRequest (E-RABToBeSetupListCtxtSUReq contains ( qCI eq 5 and priorityLevel eq 'highest' ))
    ...    alias=ue4    overall_timeout=30
    Execute Uex Command    ue_attach id=4 ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES_NORMAL} cell=1 enb=1 emergency=on
    Flow Occurred As Expected    alias=ue4
    execute uex command    trf_data_start ue=4 qci=5 dir=dl kbps=10 protocol=udp

Bitmap change and CatM UE release after enable MBMS
    ${mbsfn-SubframeConfigList}    catenate
    ...    mbsfn-SubframeConfigList contains
    ...    (subframeAllocation contains (fourFrames eq '0b010011100010010010001011'))

    Expect Message Flow
    ...    UE_GROUP_1:RRC_RRCConnectionRelease
    ...    MME_1:S1AP_InitialUEMessage (RRC-Establishment-Cause eq 'mt-Access')
    ...    UE_GROUP_1:RRC_RRCConnectionReconfiguration
    ...    alias=ue1    overall_timeout=60

    Expect Message Flow
    ...    UE_GROUP_2:RRC_RRCConnectionRelease
    ...    MME_1:S1AP_InitialUEMessage (RRC-Establishment-Cause eq 'mt-Access')
    ...    UE_GROUP_2:RRC_RRCConnectionReconfiguration
    ...    alias=ue2    overall_timeout=60

    Expect Message Will Not Occur
    ...    UE_GROUP_3:RRC_RRCConnectionRelease
    ...    alias=ue3    overall_timeout=60

    Expect Message Will Not Occur
    ...    UE_GROUP_4:RRC_RRCConnectionRelease
    ...    alias=ue4    overall_timeout=60

    expect message flow
    ...    CELL_1:RRC_SystemInformationBlockType1 (schedulingInfoList contains (sib-MappingInfo contains ('sibType13-v920')))
    ...    CELL_1:RRC_SystemInformationBlockType2 (${mbsfn-SubframeConfigList})
    ...    CELL_1:RRC_SystemInformationBlockType3 (neighCellConfig eq '0b01')
    ...    CELL_1:RRC_SystemInformationBlockType13-r9 (mbsfn-AreaInfoList-r9 contains (mbsfn-AreaId-r9 eq 1))
    ...    CELL_1:RRC_SystemInformationBlockType1-BR-r13 (subframePattern40-r13 eq '0b1101111000101111101011011110101010111000')
    ...    CELL_1:RRC_SystemInformationBlockType2-BR-r13 (mpdcch-startSF-CSS-RA-r13 contains (fdd-r13 eq '${EXPECTED_mpdcchStartSfUessCatM_2.5}'))
    ...    alias=SI    overall_timeout=60

    Delta Commission Parameters    ${delta_para_mbms}

    Flow Occurred As Expected    alias=ue1
    Flow Occurred As Expected    alias=ue2
    Flow Not Occurred For Message    alias=ue3
    Flow Not Occurred For Message    alias=ue4
    Flow Occurred As Expected    alias=SI

Bitmap change and CatM UE release after change OTDOA to false
    ${mbsfn-SubframeConfigList}    catenate
    ...    mbsfn-SubframeConfigList contains
    ...    (subframeAllocation contains (fourFrames eq '0b011000101001011000101001'))

    ${subframePattern40-r13}    catenate
    ...    0b1100111110101011110011001111101010111100

    Expect Message Flow
    ...    UE_GROUP_1:RRC_RRCConnectionRelease
    ...    MME_1:S1AP_InitialUEMessage (RRC-Establishment-Cause eq 'mt-Access')
    ...    UE_GROUP_1:RRC_RRCConnectionReconfiguration
    ...    alias=ue1    overall_timeout=60

    Expect Message Flow
    ...    UE_GROUP_2:RRC_RRCConnectionRelease
    ...    MME_1:S1AP_InitialUEMessage (RRC-Establishment-Cause eq 'mt-Access')
    ...    UE_GROUP_2:RRC_RRCConnectionReconfiguration
    ...    alias=ue2    overall_timeout=60

    Expect Message Will Not Occur
    ...    UE_GROUP_3:RRC_RRCConnectionRelease
    ...    alias=ue3    overall_timeout=60

    Expect Message Will Not Occur
    ...    UE_GROUP_4:RRC_RRCConnectionRelease
    ...    alias=ue4    overall_timeout=60

    expect message flow
    ...    CELL_1:RRC_SystemInformationBlockType1 (schedulingInfoList contains (sib-MappingInfo contains ('sibType13-v920')))
    ...    CELL_1:RRC_SystemInformationBlockType2 (${mbsfn-SubframeConfigList})
    ...    CELL_1:RRC_SystemInformationBlockType3 (neighCellConfig eq '0b01')
    ...    CELL_1:RRC_SystemInformationBlockType13-r9 (mbsfn-AreaInfoList-r9 contains (mbsfn-AreaId-r9 eq 1))
    ...    CELL_1:RRC_SystemInformationBlockType1-BR-r13 (subframePattern40-r13 eq '${subframePattern40-r13}')
    ...    CELL_1:RRC_SystemInformationBlockType2-BR-r13 (mpdcch-startSF-CSS-RA-r13 contains (fdd-r13 eq '${EXPECTED_mpdcchStartSfUessCatM_2}'))
    ...    alias=SI    overall_timeout=60

    Delta Commission Parameters    ${delta_para_otdoa_false}

    Flow Occurred As Expected    alias=ue1
    Flow Occurred As Expected    alias=ue2
    Flow Not Occurred For Message    alias=ue3
    Flow Not Occurred For Message    alias=ue4
    Flow Occurred As Expected    alias=SI

Check Start MBMS session don't impact the SIB1-BR: bitmap
    Expect Message Flow
    ...    CELL_1:RRC_SystemInformationBlockType1-BR-r13 (subframePattern40-r13 eq '0b1100111110101011110011001111101010111100')
    ...    alias=sib1_br    overall_timeout=5
    Flow Occurred As Expected    alias=sib1_br

Check Whether Gfactor=2
    [Arguments]    ${expect_mpdcchStartSfCssCatM_2}    ${expect_mpdcchStartSfUessCatM_2}
    ${G_factor}    Create List
    ...    LNCEL-1/CATMCEL-0:mpdcchStartSfCssCatM=${expect_mpdcchStartSfCssCatM_2}
    ...    LNCEL-1/CATMCEL-0:mpdcchStartSfUessCatM=${expect_mpdcchStartSfUessCatM_2}
    Object Should Exist    ${G_factor}
