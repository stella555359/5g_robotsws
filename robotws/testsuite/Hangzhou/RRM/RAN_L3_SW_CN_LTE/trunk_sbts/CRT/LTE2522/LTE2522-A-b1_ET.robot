*** Settings ***
Suite Setup       Common Suite Setup and Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    4G_FDD    RAN_4G    RAN_4G_FDD    CIT    CLOUD_R4LAPO_CUS
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...  @{modulation}
...  @{LTE2522}
...  @{Closed_Loop_MIMO}
@{modulation}
...  LNCEL:actModulationSchemeDl=64QAM
...  LNCEL:actLdPdcch=true
...  LNCEL/LNCEL_FDD-0:maxNrSymPdcch=3
...  LNCEL:adaptPdcchDwellTime=0
...  LNCEL:mbrSelector=ueCapability
...  LNCEL-4:inactivityTimer=1000
@{PARAMS_IN_SWCONFIG}
...  0x00130060 = 1
@{LTE2522}
...  LNBTS:actTM9Block=true
...  LNBTS-1/IMEIBASEDPRF-0
...  LNBTS-1/IMEIBASEDPRF-0/TM9BLOCKLIST-0:imeisvFilter:svnStart=0|imeisvTac=1
...  LNBTS-1/IMEIBASEDPRF-0/TM9BLOCKLIST-0:imeisvFilter:svnStop=0|imeisvTac=1
...  LNBTS-1/IMEIBASEDPRF-0/TM9BLOCKLIST-0:imeisvFilter:svnStart=0|imeisvTac=99999999
...  LNBTS-1/IMEIBASEDPRF-0/TM9BLOCKLIST-0:imeisvFilter:svnStop=0|imeisvTac=99999999
${ue_eutra_capabilities}
...  SEPARATOR=
...  CDA8030408308009C2130000026000004C000009800001300000FFFFFFFFCA080220022190030208589807A020041B304140083CE100414909
...  20630401040C2080209000000000
@{OnlineChangeList}
...  LNBTS:actTM9Block=false
@{Closed_Loop_MIMO}
...  LNCEL-2/LNCEL_FDD-0:dlMimoMode=Closed Loop MIMO (4x2)
...  LNCEL-3/LNCEL_FDD-0:dlMimoMode=Closed Loop MIMO (4x2)
...  LNCEL-4/LNCEL_FDD-0:dlMimoMode=Closed Loop MIMO (4x4)
...  LNCEL-4/LNCEL_FDD-0:activatedMimoTM=TM9_maxLayer

${UE_mask_imeisv}    E-RABToBeSetupItemCtxtSUReq contains (e-RAB-ID eq 6 and qCI eq 6 )
...    and value contains ("Masked-IMEISV")
*** Test Cases ***
LTE2522-A-b_ET_01_02_TM9 Suppression for ICS with dlMimoMode 4x2 FDD
    [Tags]
    Set IMEISV parameters before UE attach
    4UE attach to cell2 with flag on
    onlinechange
    detach all UE
    4UE attach to cell2 with flag off
    All UE start DL traffic

*** Keywords ***
Common Suite Setup and Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=4CELLs_FDD_2Band3_2Band7
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create UE Alias    UE_2    ue_id=2    id_type=cus
    Create UE Alias    UE_3    ue_id=3    id_type=cus
    Create UE Alias    UE_4    ue_id=4    id_type=cus
    create enb alias    ENB_1    enb_id=1    id_type=wts
    Create MME Alias    MME_1    mme_id=1    id_type=wts


Modify Yaml
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...      - { qci: 8, default: on, pdn: 1, trf_type: external}
    ...      - { qci: 6, preprovisioned: on, default: off, filter: 6, precedence: 6, preemption: off, vulnerability: off, pdn: 1}
    Update Yaml    UEs/UE_sets/1    bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/2    bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/3    bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/4    bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/1    rohc: 16    sec_key: 0102030405060708090A0B0C0D0E1001
    ...    imsi: '666:652:405001001'    category: 4   release: 15    eea: null    eia: null    imeisv: '00000001:123456:02'
    Update Yaml    UEs/UE_sets/2    rohc: 16    sec_key: 0102030405060708090A0B0C0D0E1002
    ...    imsi: '666:652:405001002'    category: 4   release: 15    eea: null    eia: null    imeisv: '00000002:123456:00'
    Update Yaml    UEs/UE_sets/3   rohc: 16    sec_key: 0102030405060708090A0B0C0D0E1003
    ...    imsi: '666:652:405001003'    category: 4   release: 15    eea: null    eia: null    imeisv: '00000001:123456:00'
    Update Yaml    UEs/UE_sets/4    rohc: 16    sec_key: 0102030405060708090A0B0C0D0E1004
    ...    imsi: '666:652:405001004'    category: 4   release: 15    eea: null    eia: null    imei: '00000001:123456:0'

4UE attach to cell2 with flag on
    expect message flow
    ...    UE_1:RRC_RRCConnectionSetup (transmissionMode eq "tm4")
    ...    MME_1:S1AP_InitialContextSetupRequest (${UE_mask_imeisv})
    ...    UE_1:RRC_RRCConnectionReconfiguration (transmissionMode-r10 contains ("tm9-v1020"))
    ...    alias=ue1_tm9    overall_timeout=20
    execute uex command    ue_attach id=1 ue_eutra_capabilities=${ue_eutra_capabilities} cell=2
    flow occurred as expected    alias=ue1_tm9
    expect message flow
    ...    UE_2:RRC_RRCConnectionSetup (transmissionMode eq "tm4")
    ...    MME_1:S1AP_InitialContextSetupRequest (${UE_mask_imeisv})
    ...    UE_2:RRC_RRCConnectionReconfiguration (transmissionMode-r10 contains ("tm9-v1020"))
    ...    alias=ue2_tm9    overall_timeout=20
    execute uex command    ue_attach id=2 ue_eutra_capabilities=${ue_eutra_capabilities} cell=2
    flow occurred as expected    alias=ue2_tm9
    expect message flow
    ...    UE_3:RRC_RRCConnectionSetup (transmissionMode eq "tm4")
    ...    MME_1:S1AP_InitialContextSetupRequest (${UE_mask_imeisv})
    ...    UE_3:RRC_RRCConnectionReconfiguration (transmissionMode-r10 contains ("tm4"))
    ...    alias=ue3_tm4    overall_timeout=20
    execute uex command    ue_attach id=3 ue_eutra_capabilities=${ue_eutra_capabilities} cell=2
    flow occurred as expected    alias=ue3_tm4
    expect message flow
    ...    UE_4:RRC_RRCConnectionSetup (transmissionMode eq "tm4")
    ...    MME_1:S1AP_InitialContextSetupRequest (${UE_mask_imeisv})
    ...    UE_4:RRC_RRCConnectionReconfiguration (transmissionMode-r10 contains ("tm9-v1020"))
    ...    alias=ue4_tm9    overall_timeout=20
    execute uex command    ue_attach id=4 ue_eutra_capabilities=${ue_eutra_capabilities} cell=2
    flow occurred as expected    alias=ue4_tm9

onlinechange
    Delta Commission Parameters    ${OnlineChangeList}
    Cells Should Be OnAir

detach all UE
    execute uex command    ue_detach id=1-4

All UE start DL traffic
    execute uex command    trf_data_start ue=1-4 dir=dl protocol=udp kbps=125

4UE attach to cell2 with flag off
    expect message flow
    ...    UE_1:RRC_RRCConnectionSetup (transmissionMode eq "tm4")
    ...    MME_1:S1AP_InitialContextSetupRequest (${UE_mask_imeisv})
    ...    UE_1:RRC_RRCConnectionReconfiguration (transmissionMode-r10 contains ("tm9-v1020"))
    ...    alias=ue1_tm9    overall_timeout=20
    execute uex command    ue_attach id=1 ue_eutra_capabilities=${ue_eutra_capabilities} cell=2
    flow occurred as expected    alias=ue1_tm9
    expect message flow
    ...    UE_2:RRC_RRCConnectionSetup (transmissionMode eq "tm4")
    ...    MME_1:S1AP_InitialContextSetupRequest (${UE_mask_imeisv})
    ...    UE_2:RRC_RRCConnectionReconfiguration (transmissionMode-r10 contains ("tm9-v1020"))
    ...    alias=ue2_tm9    overall_timeout=20
    execute uex command    ue_attach id=2 ue_eutra_capabilities=${ue_eutra_capabilities} cell=2
    flow occurred as expected    alias=ue2_tm9
    expect message flow
    ...    UE_3:RRC_RRCConnectionSetup (transmissionMode eq "tm4")
    ...    MME_1:S1AP_InitialContextSetupRequest (${UE_mask_imeisv})
    ...    UE_3:RRC_RRCConnectionReconfiguration (transmissionMode-r10 contains ("tm9-v1020"))
    ...    alias=ue3_tm9    overall_timeout=20
    execute uex command    ue_attach id=3 ue_eutra_capabilities=${ue_eutra_capabilities} cell=2
    flow occurred as expected    alias=ue3_tm9
    expect message flow
    ...    UE_4:RRC_RRCConnectionSetup (transmissionMode eq "tm4")
    ...    MME_1:S1AP_InitialContextSetupRequest (${UE_mask_imeisv})
    ...    UE_4:RRC_RRCConnectionReconfiguration (transmissionMode-r10 contains ("tm9-v1020"))
    ...    alias=ue4_tm9    overall_timeout=20
    execute uex command    ue_attach id=4 ue_eutra_capabilities=${ue_eutra_capabilities} cell=2
    flow occurred as expected    alias=ue4_tm9


Set IMEISV parameters before UE attach
    execute egate command    ue_mme_param id=1-3 identity_type=imeisv include_masked_imeisv=on imeisv_request=requested
    execute egate command    ue_mme_param id=4 identity_type=imei
