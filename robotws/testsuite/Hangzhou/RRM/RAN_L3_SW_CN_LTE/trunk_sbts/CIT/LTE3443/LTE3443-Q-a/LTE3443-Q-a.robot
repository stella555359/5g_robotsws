*** Setting ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    4G_TDD    RAN_4G    RAN_4G_TDD    CIT
...               CLOUD_R4LAPO_CUS    team-DevHZ5_SG5    owner-Jianping.Ying    owner-eric.jiang    release-L18
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variable ***
@{PARAMS_IN_SCF}
...    LNBTS:actVoLTEQualSRVCCtoGsm=true
...    LNBTS/LNBTS_TDD-0:actSrvccToGsm=true
...    LNBTS/LNADJG-1:arfcnValueGeran=512
...    LNBTS/LNADJG-1:mcc=262
...    LNBTS/LNADJG-1:mnc=3
...    LNBTS/LNADJG-1:networkColourCode=0
...    LNCEL-1/LNHOG-1:arfcnValueListGERAN=512
...    LNCEL-1/LNHOG-1:nccperm=1
...    LNBTS/MODPR-0:autoAdapt=true
...    LNCEL-1:threshold2GERAN=70
...    LNCEL-1:threshold2GERANQci1=70
...    LNCEL-1:threshold2a=89
...    LNCEL-1:threshold2aQci1=89
...    LNCEL-1:threshold2aHpue=70
...    LNCEL-1:threshold2aHpue=70
...    LNCEL:assignedVoLteQualProfile=1
...    LNBTS:actHOtoWcdma=true
...    LNBTS/LNBTS_TDD-0:actSrvccToWcdma=true
@{PARAMS_Q-a-01-07}
...    LNBTS/VOLTEQUALPR-1:badQualityDLGapThres=40
...    LNBTS/VOLTEQUALPR-1:badQualityULGapThres=40
...    LNBTS/VOLTEQUALPR-1:goodQualityGapThres=50
...    LNBTS/VOLTEQUALPR-1:badQualityRBlerThres=5
...    LNBTS/VOLTEQUALPR-1:goodQualityRBlerThres=4
...    LNBTS/VOLTEQUALPR-1:rBlerCondTimeToTrigger=6
${eutra_cap_1}
...    SEPARATOR=
...    91800200008206102860E2048A163069022489942A58B983268D9C3A7870F4AA000037FFEFF9477C0110C8531D0952D8D8384858689
...    8A73E02060A1E222E32363A3CA00443214C74254A8008418828C39049459869C7A08A49A8A9500108310518720928B30D38F4114935
...    1500
${eutra_cap_2}    CD9FF4F9B2E7500010610102912464D0312040E07FFFFFFFFCA18800182008295020022A0060B3FFFFFFFE014FFFFFFFFC
${geran_cs_cap}    33035758A6601404EF6513B8878D2F28

*** Test Case ***
LTE3443-Q-a-01-07_UE Deact B1-GSM when the last QCI1 bearer releases
    [Tags]
    Delta Commission Parameters    ${PARAMS_Q-a-01-07}
    UE Trigger VOLTE Call
    UE Trigger VQ Status Into Bad And B1 Act
    UE Trigger VQ Status Into Good And B1 Deact B2 Act
    UE Trigger VQ Status Change To Bad And B1 Act
    UE Release The QCI1 Bearer And B1 Deact

*** Keyword ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs    ue_count=5
    Execute Egate Command    mb_mdt_plmn_list id=1 plmn=262:03 plmn=262:04
    Execute Egate Command    mb_mdt_plmn_list id=2 plmn=262:03
    Execute Egate Command    mb_mdt_plmn_list id=2 plmn=262:04
    Execute Egate Command    mb_mdt_plmn_list id=2 plmn=262:05
    execute egate command    trace_sim on mme=1 protocol=s1
    execute egate command    trace uec=1 mme=1 protocol=rrc,nr_rrc,s1,x2 on
    Execute Egate Command    proxy_log GEN=debug
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create Enb Alias    alias=ENB_1    enb_id=1    id_type=wts
    Create MME Alias    MME_1    mme_id=1    id_type=wts


Modify Yaml
    Add Yaml    EPC/PGW
        ...    - id: 3
        ...    type: 'simulated'
        ...    apn: 'emergency.nsn.com'
        ...    emergency: 'on'
    Add Yaml    EPC/MME_POOL_AREA
    ...    - id: 2
    ...      plmn: '262:04'
    ...      mmegi: 2
    ...      tac_list: 33
    Update Yaml    EPC/MME/1    pool: ['1:3']
    Add Yaml    UEs/bearer_sets/bearer_set_2
    ...    - {qci: 1, preemption: on, vulnerability: on, gbr_ul: 30, gbr_dl: 30, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    ...    - {qci: 2, preemption: on, vulnerability: on, gbr_ul: 500, gbr_dl: 10000, mbr_ul: 510, mbr_dl: 11000, pdn: 1}
    ...    - {qci: 3, preemption: on, vulnerability: on, gbr_ul: 500, gbr_dl: 10000, mbr_ul: 510, mbr_dl: 11000, pdn: 1}
    ...    - {qci: 4, preemption: on, vulnerability: on, gbr_ul: 500, gbr_dl: 10000, mbr_ul: 510, mbr_dl: 11000, pdn: 1}
    ...    - {qci: 5, default: on, trf_type: external, pdn: 1}
    ...    - {qci: 6, default: off, pdn: 1}
    ...    - {qci: 7, default: off, pdn: 1}
    ...    - {qci: 8, default: off, pdn: 1}
    ...    - {qci: 5, default: on, trf_type: external, pdn: 3}
    ...    - {qci: 1, preemption: on, vulnerability: off, gbr_ul: 30, gbr_dl: 30, mbr_ul: 31, mbr_dl: 31, pdn: 3}
    Update Yaml    UEs/UE_sets/1    bearer: bearer_set_2

UE Trigger VOLTE Call
    Expect Message Flow
    ...    UE_1:RRC_RRCConnectionRequest (rrcConnectionRequest contains (establishmentCause eq "mo-Signalling"))
    ...    MME_1:S1AP_InitialContextSetupRequest (E-RABToBeSetupListCtxtSUReq contains (e-RAB-ID eq 5 and qCI eq 5))
    ...    MME_1:S1AP_UECapabilityInfoIndication
    ...    alias=UE1_Attach    overall_timeout=20
    Expect Message Flow
    ...    MME_1:S1AP_E-RABSetupRequest (E-RABToBeSetupItemBearerSUReq contains (e-RAB-ID eq 6 and qCI eq 1))
    ...    MME_1:S1AP_E-RABSetupRequest (E-RABToBeSetupItemBearerSUReq contains (e-RAB-ID eq 7 and qCI eq 7))
    ...    alias=UE1_Add_Bearers    overall_timeout=20
    Execute Uex Command    ue_param id=1 csfb_rat=utran_geran voice_domain_preference=cs_preferred srvcc=on
    Execute Egate Command    ue_mme_param id=1 srvcc_operation_possible=yes
    Execute Uex Command    ue_attach id=1 enb=1 cell=1 ue_eutra_capabilities=${eutra_cap_2} ue_geran_cs_capabilities=${geran_cs_cap}
    Flow Occurred As Expected    alias=UE1_Attach
    Execute Uex Command    bearer_add ue=1 qci=1 gbr_ul=30 gbr_dl=30 mbr_ul=31 mbr_dl=31
    Execute Uex Command    bearer_add ue=1 qci=7
    Flow Occurred As Expected    alias=UE1_Add_Bearers

UE Trigger VQ Status Into Bad And B1 Act
    ${rrc_reconfig}=    Catenate
    ...    RRC_RRCConnectionReconfiguration (measObjectToAddModList contains (measObjectId eq 2 and
    ...    carrierFreqs contains (startingARFCN eq 512)) and
    ...    reportConfigToAddModList contains (reportConfigId eq 5 and eventB1 contains (b1-Threshold contains (b1-ThresholdGERAN eq 15)))
    ...    and measIdToAddModList contains (measId eq 14 and measObjectId eq 2 and reportConfigId eq 5) and
    ...    measGapConfig contains (setup is present))
    Expect Message Flow
    ...    UE_1:${rrc_reconfig}
    ...    UE_1:RRC_RRCConnectionReconfigurationComplete
    ...    alias=bad_B1_Flow    overall_timeout=20
    Execute Uex Command    trf_data_start ue=1 qci=1 dir=ul kbps=100 protocol=udp
    Execute Uex Command    ue_harq_error id=1 cell=current ul_err=0-7:6 ul_err_ratio=0-7:10:9:0
    Flow Occurred As Expected    alias=bad_B1_Flow

UE Trigger VQ Status Into Good And B1 Deact B2 Act
    Expect Message Flow
    ...    UE_1:RRC_RRCConnectionReconfiguration (measIdToRemoveList contains (14) and measGapConfig contains (release is present))
    ...    UE_1:RRC_RRCConnectionReconfigurationComplete
    ...    alias=good_B2_Flow    overall_timeout=20
    Execute Uex Command    ue_harq_error id=1 cell=current ul_err=0-7:10 ul_err_ratio=0-7:10:1:0
    Flow Occurred As Expected    alias=good_B2_Flow

UE Trigger VQ Status Change To Bad And B1 Act
    ${rrc_reconfig}=    Catenate
    ...    RRC_RRCConnectionReconfiguration (measIdToAddModList contains (measId eq 14 and measObjectId eq 2 and reportConfigId eq 5)
    ...    and measGapConfig contains (setup is present))
    Expect Message Flow
    ...    UE_1:${rrc_reconfig}
    ...    UE_1:RRC_RRCConnectionReconfigurationComplete
    ...    alias=bad_B1_Flow    overall_timeout=20
    Execute Uex Command    ue_harq_error id=1 cell=current ul_err=0-7:6 ul_err_ratio=0-7:10:9:0
    Flow Occurred As Expected    alias=bad_B1_Flow

UE Release The QCI1 Bearer And B1 Deact
    Expect Message Flow
    ...    MME_1:S1AP_E-RABReleaseCommand(E-RABList contains (e-RAB-ID eq 6))
    ...    UE_1:RRC_RRCConnectionReconfiguration (measIdToRemoveList contains (14))
    ...    UE_1:RRC_RRCConnectionReconfigurationComplete
    ...    alias=Release_QCI1_Flow    overall_timeout=20
    Execute Uex Command    bearer_del ue=1 qci=1
    Flow Occurred As Expected    alias=Release_QCI1_Flow
