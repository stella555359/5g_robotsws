*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    4G_FDD    RAN_4G    RAN_4G_FDD    CRT    team-DevHZ5_SG3
...               CLOUD_R4LAPO_CUS    release-xL19    owner-menghuan.fang
Resource          ../../../resources/DevHZ5_resource.robot

*** Variable ***
@{PARAMS_IN_SCF}
...    LNBTS-1/LNADJ-1:cPlaneIpAddr=10.0.1.32
...    LNBTS-1/LNADJG-1:arfcnValueGeran=512
...    LNBTS-1/LNADJG-1:mcc=262
...    LNBTS-1/LNADJG-1:mnc=3
...    LNBTS-1/LNADJ-1/LNADJL-1:fDlEarfcn=1850
...    LNBTS-1/LNADJ-1/LNADJL-1:ecgiLcrId=1
...    LNBTS-1/LNADJ-1/LNADJL-1:phyCellId=9
...    LNBTS-1/LNADJ-1/LNADJL-1:tac=33
...    LNBTS-1/LNADJG-1:networkColourCode=0
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=1850
...    LNCEL-1/LNHOIF-1:measQuantInterFreq=rsrp
...    LNCEL-1/LNHOG-1:arfcnValueListGERAN=512
...    LNCEL-1/LNHOG-1:nccperm=1
...    LNCEL-1/LNRELG-1:eNACCAllowed=allowed
...    LNCEL-1/LNRELG-1:srvccAllowed=allowed
...    LNBTS-1/MODPR-0:autoAdapt=true
...    LNBTS-1:actIfHo=enabled
...    LNBTS-1:acteNACCtoGSM=true
...    LNCEL:threshold2GERAN=55
...    LNCEL:threshold2GERANQci1=55
...    LNCEL-1:threshold2InterFreq=75
...    LNCEL:threshold2InterFreqQci1=75
...    LNCEL:threshold1=85
...    LNCEL:threshold2a=80
...    LNCEL:threshold2aQci1=80
...    LNCEL:threshold2InterFreqHpue=68
...    LNCEL:hysThreshold2GERAN=0
...    LNCEL:hysThreshold2InterFreq=0
...    @{PARAMS_LTE3443_off}
...    @{PARAMS_Q-c}
@{PARAMS_Q-c}
...    LNBTS-1/VOLTEQUALPR-1:badQualityDLGapThres=1
...    LNBTS-1/VOLTEQUALPR-1:badQualityULGapThres=1
...    LNBTS-1/VOLTEQUALPR-1:goodQualityGapThres=1
...    LNBTS-1/PMRNL-1/PMCCP-1:maxVBreakDistThresh=5
...    delete:LNBTS-1/VOLTEQUALPR-1:badQualityRBlerThres
...    delete:LNBTS-1/VOLTEQUALPR-1:goodQualityRBlerThres
...    delete:LNBTS-1/VOLTEQUALPR-1:rBlerCondTimeToTrigger
@{PARAMS_LTE3443_off}
...    LNBTS-1:actVoLTEQualSRVCCtoGsm=false
...    LNBTS-1/LNBTS_FDD-0:actSrvccToGsm=true
...    LNBTS-1/LNBTS_FDD-0:actConvVoice=true
...    LNBTS-1/LNBTS_FDD-0:actSrvccToWcdma=false
...    LNBTS-1:actMultBearers=true
...    LNCEL:assignedVoLteQualProfile=1
...    LNBTS-1:actVoLTEQualInterFreqMobility=false
@{PARAMS_IN_SWCONFIG}
...    0x1002a=1
...    0x1002b=0x4F3F
...    0x1005a=1
...    0xA01bb = 0x6
...    0xA0172 = 528678912
...    0xA0173 = 528678933
@{PM_COUNTERS}
...    LNCEL-1:${DL_VB_PERIOD_BIN1}>0
...    LNCEL-1:${UL_VB_PERIOD_BIN1}>0
${DL_VB_PERIOD_BIN1}    M8067C0
${UL_VB_PERIOD_BIN1}    M8067C11

*** Test Case ***
CNI30644_01_01_pm counter update_FDD
    [Tags]
    clear counter files    wait=False
    100 UEs attach to eNB and with Voice call
    Voice gap changed between good and bad On DL and UL
    Check Counters    ${PM_COUNTERS}

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD    ue_count=200
    Create UE Group Aliases    UE_GROUP    start_ue_id=1    stop_ue_id=100    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create MME Alias    MME_1    mme_id=1    id_type=wts

Modify Yaml
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...     - {qci: 5, default: on, pdn: 1}
    ...     - {qci: 1, mbr_ul: 30, gbr_dl: 30, gbr_ul: 31, mbr_dl: 31, pdn: 1}
    FOR    ${ue_id}    IN RANGE    1    101
        Update Yaml    UEs/UE_sets/${ue_id}    bearer: bearer_set_2
    END
    Add Yaml    BASE_STATIONS
    ...    - id: 2
    ...    type: simulated
    ...    plmn: '262:03'
    ...    s1: 10.0.1.32
    ...    x2: 10.0.1.32
    ...    cells:
    ...       - {id: 21, technology: lte, tac: 33, pci: '3:0', earfcn: '1850:19850', bw: 20}
    ...       - {id: 22, technology: lte, tac: 33, pci: '3:1', earfcn: '1400:19400', bw: 20}
    ...       - {id: 23, technology: lte, tac: 33, pci: '3:2', earfcn: '1400:19400', bw: 20}

100 UEs attach to eNB and with Voice call
    [Arguments]    ${cell_id}=1
    Execute Uex Command    ue_attach id=1-100 cell=${cell_id}
    Execute Uex Command    bearer_add ue=1-100 qci=1 mbr_ul=31 mbr_dl=31 gbr_ul=30 gbr_dl=30


Voice gap changed between good and bad On DL and UL
    DL VQ status into bad
    DL VQ status change to good
    UL VQ status into bad
    UL VQ status change to good
    all UE detach

DL VQ status into bad
    Execute Uex Command    trf_data_start ue=1-100 protocol=udp qci=1 dir=dl Mbps=1 trf_id=1
    Execute Uex Command    trf_data_start ue=1-100 protocol=udp qci=5 dir=dl Mbps=1 trf_id=1
    FOR    ${ue_id}    IN RANGE    1    101
        Expect Message Will Not Occur
        ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (measIdToAddModList contains (measId eq 14))
        ...    alias=UE${ue_id}_no_a3_flow    overall_timeout=30
    END
    Execute Uex Command    ue_harq_error cell=current id=1-100 tb1_err_ratio=0-7:100:70:0
    FOR    ${ue_id}    IN RANGE    1    101
        Flow Not Occurred For Message    alias=UE${ue_id}_no_a3_flow
    END

DL VQ status change to good
    Execute Uex Command    trf_data_start ue=1-100 protocol=udp qci=1 dir=dl kbps=5 trf_id=2
    Execute Uex Command    trf_data_start ue=1-100 protocol=udp qci=5 dir=dl kbps=5 trf_id=2
    FOR    ${ue_id}    IN RANGE    1    101
        Expect Message Will Not Occur
        ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (measIdToRemoveList is present)
        ...    alias=UE${ue_id}_remove_flow    overall_timeout=30
    END
    Execute Uex Command    ue_harq_error cell=current id=1-100 tb1_err_ratio=0-7:1000:0:1
    FOR    ${ue_id}    IN RANGE    1    101
        Flow Not Occurred For Message    alias=UE${ue_id}_remove_flow
    END

UL VQ status into bad
    Execute Uex Command    trf_data_start ue=1-100 protocol=udp qci=1 dir=ul Mbps=1 trf_id=1
    FOR    ${ue_id}    IN RANGE    1    101
        Expect Message Will Not Occur
        ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (measIdToAddModList contains (measId eq 14))
        ...    alias=UE${ue_id}_no_a3_flow    overall_timeout=30
    END
    Execute Egate Command    ue_param id=1-100 pdcp_sn_discard=1:2000
    FOR    ${ue_id}    IN RANGE    1    101
        Flow Not Occurred For Message    alias=UE${ue_id}_no_a3_flow
    END

UL VQ status change to good
    Execute Uex Command    trf_data_start ue=1-100 protocol=udp qci=1 dir=ul kbps=5 trf_id=2
    FOR    ${ue_id}    IN RANGE    1    101
        Expect Message Will Not Occur
        ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (measIdToRemoveList is present)
        ...    alias=UE${ue_id}_remove_flow    overall_timeout=30
    END
    Execute Egate Command    ue_param id=1-100 pdcp_sn_discard=0:0
    FOR    ${ue_id}    IN RANGE    1    101
        Flow Not Occurred For Message    alias=UE${ue_id}_remove_flow
    END


all UE detach
    Execute Uex Command    ue_detach id=1-100