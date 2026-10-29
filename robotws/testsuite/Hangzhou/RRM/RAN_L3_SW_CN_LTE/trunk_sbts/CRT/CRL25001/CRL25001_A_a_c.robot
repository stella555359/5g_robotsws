*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    4G_FDD    RAN_4G    RAN_4G_FDD    CRT    team-DevHZ5_SG6
...               CLOUD_R4LAPO_CUS    release-xL18A    owner-yili chen
Resource          ../../../resources/DevHZ5_resource.robot
*** Variables ***
@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CATM}
...    @{PARAMS_FOR_CATM_Volte}
@{PARAMS_FOR_CATM}
...    LNCEL-1/LNCEL_FDD-0:actCatM=true
...    LNCEL-1/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-1/LNCEL_FDD-0:catMProfId=1
...    LNCEL-1/SIB-0:siWindowLen=40ms
...    LNCEL-1/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=InnerLowerEdge
...    LNCEL-1:inactivityTimer=30
...    LNCEL-1/SIB-0:threshServingLowQR9=0
...    LNCEL-2/LNCEL_FDD-0:actCatM=true
...    LNCEL-2/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-2/LNCEL_FDD-0:catMProfId=1
...    LNCEL-2/SIB-0:siWindowLen=40ms
...    LNCEL-2/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=InnerLowerEdge
...    LNCEL-2:inactivityTimer=30
...    LNCEL-2/SIB-0:threshServingLowQR9=0
...    LNCEL-2/SIB-0:cellSelectionInfoV920:qQualMinOffsetR9=1
...    LNCEL-2/SIB-0:cellSelectionInfoV920:qQualMinR9=-34
@{PARAMS_FOR_CATM_Volte}
...    LNCEL-1/CATMCEL-0:actConvVoiceCatM=true
...    LNCEL-2/CATMCEL-0:actConvVoiceCatM=true
...    LNCEL-1/CATMCEL-0:actIntraFreqHoCatM=true
...    LNCEL-2/CATMCEL-0:actIntraFreqHoCatM=true
...    LNBTS-1/CATMPR-1:inactivityTimerCatM=60
...    LNBTS-1/CATMPR-1:maxNumQci1DrbCatM=10
...    LNBTS-1/CATMPR-1:qciForVoLTECatM=255
...    LNBTS-1/CATMPR-1:catMVoLTETab:dlMaxHarqTxQci1CatM=2
...    LNBTS-1/CATMPR-1:catMVoLTETab:maxGbrDlQci1CatM=80
...    LNBTS-1/CATMPR-1:catMVoLTETab:maxGbrUlQci1CatM=80
...    LNBTS-1/CATMPR-1:catMVoLTETab:qci1ProtectionTimerCatM=80
...    LNBTS-1/CATMPR-1:catMVoLTETab:tDiscardPdcpQci1CatM=infinity
...    LNBTS-1/CATMPR-1:catMVoLTETab:tDiscardPdcpQci5CatM=300ms
...    LNBTS-1/CATMPR-1:catMVoLTETab:ulMaxHarqTxQci1CatM=2
...    LNBTS-1:actMultBearers=true
...    LNBTS-1:qciTab5:lcgid=0|schedulType=SIGNALLING
...    LNBTS-1/LNBTS_FDD-0:actConvVoice=true
...    LNBTS-1/CATMPR-1:srbInactivityTimerCatM=40
...    LNBTS-1/CATMPR-1:cpInactivityTimerCatM=20
${MAX_UE_VOLTE_CAPABLE_LTEM}    M8061C216
${MAX_UE_NON_VOLTE_CAPABLE_LTEM}    M8061C217
${SIGN_CONN_ESTAB_ATT_LTEM}    M8061C24
${SIGN_CONN_ESTAB_SUCC_LTEM}    M8100C53
@{pm_counters_A_a_01}
...    LNCEL-1/MCC-262/MNC-03:${MAX_UE_VOLTE_CAPABLE_LTEM}=1
...    LNCEL-1/MCC-262/MNC-03:${MAX_UE_NON_VOLTE_CAPABLE_LTEM}=3
@{pm_counters_A_c_01}
...    LNCEL-1/MCC-262/MNC-03:${MAX_UE_VOLTE_CAPABLE_LTEM}=3
...    LNCEL-1/MCC-262/MNC-03:${MAX_UE_NON_VOLTE_CAPABLE_LTEM}=6
...    LNCEL-1/MCC-262/MNC-03:${SIGN_CONN_ESTAB_ATT_LTEM}=12
...    LNCEL-1/MCC-262/MNC-03:${SIGN_CONN_ESTAB_SUCC_LTEM}=12
${UE_EUTRA_CAPABILITIES_CATM1}    D61FF000800055555D55001000804510021200055C041900    #type1 CATM FGI3=1,7=1
${UE_EUTRA_CAPABILITIES_CATM2}    D61FF000800045555D55001000804510021200055C041900    #type2 CATM FGI3=0,7=1
${UE_EUTRA_CAPABILITIES_CATM3}    D61FF000800044555D55001000804510021200055C041900    #type3 CATM FGI3=0,7=0
${UE_EUTRA_CAPABILITIES_CATM4}    D61FF000800054555D55001000804510021200055C041900    #type4 CATM FGI3=1,7=0
${UE_EUTRA_CAPABILITIES_CATM1_A_b}
...    SEPARATOR=
...    D41800C325C1851E044A34A9D9B79A60CFFF8CFFF8CFFF8CFFF8CFFF8CFFF8CFFF8CFFF8CFFF8CFFF8CFFF8CFFF8CFFFF702880100100382C0
...    0000000004500000000590200424000AB8087214541955555500
#type1 CATM FGI3=1,7=1
${UE_EUTRA_CAPABILITIES_CATM2_A_b}
...    SEPARATOR=
...    D41800C325C1851E044A34A9D9B79A60CFFF8CFFF8CFFF8CFFF8CFFF8CFFF8CFFF8CFFF8CFFF8CFFF8CFFF8CFFF8CFFFE702880100100382C0
...    0000000004500000000590200424000AB8087214541955555500
#type2 CATM FGI3=0,7=1
${UE_EUTRA_CAPABILITIES_CATM3_A_b}
...    SEPARATOR=
...    D41800C325C1851E044A34A9D9B79A60CFFF8CFFF8CFFF8CFFF8CFFF8CFFF8CFFF8CFFF8CFFF8CFFF8CFFF8CFFF8CFFFE602880100100382C0
...    0000000004500000000590200424000AB8087214541955555500
#type3 CATM FGI3=0,7=0
${UE_EUTRA_CAPABILITIES_CATM4_A_b}
...    SEPARATOR=
...    D41800C325C1851E044A34A9D9B79A60CFFF8CFFF8CFFF8CFFF8CFFF8CFFF8CFFF8CFFF8CFFF8CFFF8CFFF8CFFF8CFFFF602880100100382C0
...    0000000004500000000590200424000AB8087214541955555500
#type4 CATM FGI3=1,7=0
${UE_EUTRA_CAPABILITIES_NORMAL}    CA1FF43A33E6850007FFFFFFFC008006217FFFFFFF80



*** Test Cases ***
CRL25001_A_c_01_ICS test for VolteCatMUePmCounter and nonVolteCatMUePmCounter
    [Tags]
    Attach 3 Volte Cat-M UEs With QCI1 to Cell1
    Attach 3 Non-Volte Cat-M UEs With QCI1 to Cell1    4    5    6    ${UE_EUTRA_CAPABILITIES_CATM2}    ${UE_EUTRA_CAPABILITIES_CATM3}
    ...  ${UE_EUTRA_CAPABILITIES_CATM4}
    Attach 1 legacy UE    ue_id=7  cell_id=1  UE_EUTRA_CAPABILITIES_NORMAL=${UE_EUTRA_CAPABILITIES_NORMAL}
    release all ues
    attach 3type non-Volte catm UE twice    ue_id_start=8    ue_id_stop_add_1=14
    Attach 1 legacy UE    ue_id=14  cell_id=1  UE_EUTRA_CAPABILITIES_NORMAL=${UE_EUTRA_CAPABILITIES_NORMAL}
    release all ues
    check counters    ${pm_counters_A_c_01}

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD    ue_count=200
    Create UE Group Aliases    UE_GROUP    start_ue_id=1    stop_ue_id=100    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create MME Alias    MME_1    mme_id=1    id_type=wts
    Create CELL alias    alias=CELL_1    cell_id=1    cell_type=cus

Modify Yaml
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...     - {qci: 8, default: on, pdn: 1}
    ...     - {qci: 1, preprovisioned: on, gbr_ul: 25, gbr_dl: 25, mbr_ul: 25, mbr_dl: 25, filter: 1, precedence: 1, pdn: 1}
    ...     - {qci: 5, preprovisioned: on, filter: 5, precedence: 5, pdn: 1}
    FOR    ${ue_id}    IN RANGE    1    20
        Update Yaml    UEs/UE_sets/${ue_id}    bearer: bearer_set_2
    END

Attach 3 Volte Cat-M UEs With QCI1 to Cell1
     Attach 1 support Volte catm UE to cell 1   ue_id=12    UE_EUTRA_CAPABILITIES_CATM=${UE_EUTRA_CAPABILITIES_CATM1}    cell_id=1
     Attach 1 support Volte catm UE to cell 1   ue_id=13    UE_EUTRA_CAPABILITIES_CATM=${UE_EUTRA_CAPABILITIES_CATM1}    cell_id=1
     Attach 1 support Volte catm UE to cell 1   ue_id=14    UE_EUTRA_CAPABILITIES_CATM=${UE_EUTRA_CAPABILITIES_CATM1}    cell_id=1

Attach 1 support Volte catm UE to cell 1
    [Arguments]    ${ue_id}   ${UE_EUTRA_CAPABILITIES_CATM}  ${cell_id}
    Execute Uex Command    ue_attach id=${ue_id} ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES_CATM1} enb=1 cell=${cell_id}


Attach 3 Non-Volte Cat-M UEs With QCI1 to Cell1
    [Arguments]    ${ue_id_CATM2}    ${ue_id_CATM3}    ${ue_id_CATM4}    ${UE_EUTRA_CAPABILITIES_CATM2}    ${UE_EUTRA_CAPABILITIES_CATM3}
    ...    ${UE_EUTRA_CAPABILITIES_CATM4}
    ${message}=    catenate
    ...    E-RABToBeSetupListCtxtSUReq contains ((
    ...    (e-RAB-ID eq 5) and (qCI eq 8)),((e-RAB-ID eq 6) and (qCI eq 1)),((e-RAB-ID eq 7) and (qCI eq 5))
    ...    )
    Expect Message Flow
    ...    MME_1:S1AP_InitialContextSetupRequest (${message})
    ...    alias=UE_CATM2_Attach_Flow    overall_timeout=20
    Execute Uex Command    ue_attach id=${ue_id_CATM2} ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES_CATM2} enb=1 cell=1
    Flow Occurred As Expected    alias=UE_CATM2_Attach_Flow
    Expect Message Flow
    ...    MME_1:S1AP_InitialContextSetupRequest (${message})
    ...    alias=UE_CATM3_Attach_Flow    overall_timeout=20
    Execute Uex Command    ue_attach id=${ue_id_CATM3} ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES_CATM3} enb=1 cell=1
    Flow Occurred As Expected    alias=UE_CATM3_Attach_Flow
    Expect Message Flow
    ...    MME_1:S1AP_InitialContextSetupRequest (${message})
    ...    alias=UE_CATM4_Attach_Flow    overall_timeout=20
    Execute Uex Command    ue_attach id=${ue_id_CATM4} ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES_CATM4} enb=1 cell=1
    Flow Occurred As Expected    alias=UE_CATM4_Attach_Flow

Attach 1 legacy UE
    [Arguments]    ${ue_id}  ${cell_id}  ${UE_EUTRA_CAPABILITIES_NORMAL}
    Execute Uex Command    ue_attach id=${ue_id} ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES_NORMAL} enb=1 cell=${cell_id}

attach 3type non-Volte catm UE twice
    [Arguments]    ${ue_id_start}=8    ${ue_id_stop_add_1}=14
    ${message}=    catenate
    ...    E-RABToBeSetupListCtxtSUReq contains ((
    ...    (e-RAB-ID eq 5) and (qCI eq 8)),((e-RAB-ID eq 6) and (qCI eq 1)),((e-RAB-ID eq 7) and (qCI eq 5))
    ...    )
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${ue_id_stop_add_1}
        Expect Message Flow
        ...    MME_1:S1AP_InitialContextSetupRequest (${message})
        ...    alias=UE${ue_id}_attach_flow    overall_timeout=30
    END
    Execute Uex Command    ue_attach id=8 ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES_CATM2} enb=1 cell=1
    Execute Uex Command    ue_attach id=9 ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES_CATM3} enb=1 cell=1
    Execute Uex Command    ue_attach id=10 ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES_CATM4} enb=1 cell=1
    Execute Uex Command    ue_attach id=11 ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES_CATM2} enb=1 cell=1
    Execute Uex Command    ue_attach id=12 ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES_CATM3} enb=1 cell=1
    Execute Uex Command    ue_attach id=13 ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES_CATM4} enb=1 cell=1
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${ue_id_stop_add_1}
        Flow Occurred As Expected    alias=UE${ue_id}_attach_flow
    END

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir