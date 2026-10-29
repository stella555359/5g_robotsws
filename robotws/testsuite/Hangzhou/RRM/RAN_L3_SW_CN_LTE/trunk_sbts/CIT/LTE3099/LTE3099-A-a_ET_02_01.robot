*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CIT    CLOUD_R4LAPO_CUS
...               team-SG4    release-SBTS20A    owner-yili.chen
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_Normal_UE}

@{PARAMS_FOR_Normal_UE}
...    LNCEL:inactivityTimer=75
...    LNCEL-1:inactivityTimerQci5Sign=150
...    LNCEL:qci1ProtectionTimer=100
...    LNBTS:qciTab5:schedulType=SIGNALLING
...    LNBTS:qciTab5:lcgid=0
...    LNBTS:actMultBearers=true
...    LNBTS/LNBTS_FDD-0:actConvVoice=true
...    LNBTS:actRrcConnNoActivity=true
...    LNBTS:actDLCAggr=false
...    LNBTS:actEnhAcAndGbrServices=true
...    LNBTS:actMultGbrBearers=true
...    LNCEL-1/LNCEL_FDD-0:maxNumActUE=265
...    LNCEL-1/LNCEL_FDD-0:maxNumActDrb=265
...    LNCEL-1/LNCEL_FDD-0/MPUCCH_FDD-0:maxNumRrc=270
...    LNCEL-1/LNCEL_FDD-0/MPUCCH_FDD-0:maxNumRrcEmergency=300
...    LNCEL-1/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrcNoDrb=5
...    LNCEL-1/LNCEL_FDD-0/MPUCCH_FDD-0:minNumRrcNoDrb=5
...    LNCEL-1/LNCEL_FDD-0/APUCCH_FDD-0:aPucchAddAUeRrHo=10
...    LNCEL-1/LNCEL_FDD-0/APUCCH_FDD-0:aPucchAddAUeTcHo=15
...    LNCEL-1/LNCEL_FDD-0:maxNumCaConfUeDc=0
...    LNCEL-1/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrc=0
...    LNCEL-1/LNCEL_FDD-0:maxNumCaConfUe=0
...    LNCEL-1/LNCEL_FDD-0:maxNumCaConfUe3c=0
...    LNCEL-1:maxGbrTrafficLimit=30
...    LNBTS:actOperatorQCI=true
...    LNBTS:actOperatorQCIGBR=true
...    LNBTS:qciTab2:gbrOverbookingFactor=0
...    LNBTS:qciTab3:gbrOverbookingFactor=0
...    LNBTS:qciTab4:gbrOverbookingFactor=0
...    LNBTS:qciTabOperator:gbrOverbookingFactor=10
...    LNBTS:qciTabOperator:qci=128
...    LNBTS:qciTabOperator:resType=GBR
...    LNBTS:qciTabOperator:lcgid=2

*** Test Cases ***
LTE3099-A-a_ET_02_01_ Overbooking for operator-specific GBR QCI 128 when it is setup during initial context setup
    [Tags]    RAN_4G    RAN_4G_FDD    CDRT
    Preset parameters
    CUS multiple attach UE1 to UE20 and data transmission successful
    CUS multiple attach UE21 to UE35 and data transmission lead some UEs Overbooking
    Stop 35 UEs traffic successfully
    Detach 35 UEs successfully

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD    ue_count=100
    Create Alias

Create Alias
    FOR    ${ue_id}    IN RANGE    1    36
        Create UE Alias    UE_${ue_id}    ue_id=${ue_id}    id_type=cus
    END
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create MME Alias    alias=MME_1    mme_id=1    id_type=wts

Modify Yaml
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...      - {pdn: 1, qci: 8, default: on, preprovisioned: off, priority: 1}
    ...      - {pdn: 1, qci: 2, default: off, preprovisioned: on, priority: 2, filter: 2, precedence: 2, 
    ...        mbr_ul: 144, gbr_dl: 144, gbr_ul: 144, mbr_dl: 144, preemption: on, vulnerability: on}
    ...      - {pdn: 1, qci: 3, default: off, preprovisioned: on, priority: 3, filter: 3, precedence: 3, 
    ...        mbr_ul: 64, gbr_dl: 128, gbr_ul: 64, mbr_dl: 128, preemption: off, vulnerability: off}
    ...      - {pdn: 1, qci: 128, default: off, preprovisioned: on, priority: 4, filter: 4, precedence: 4, 
    ...        mbr_ul: 31, gbr_dl: 31, gbr_ul: 31, mbr_dl: 31, preemption: off, vulnerability: off, delay: 100}
    ...      - {pdn: 1, qci: 1, default: off, preprovisioned: off, mbr_ul: 31, gbr_dl: 31, gbr_ul: 31, mbr_dl: 31}
    ...      - {pdn: 1, qci: 4, default: off, preprovisioned: off, mbr_ul: 31, gbr_dl: 320, gbr_ul: 31, mbr_dl: 320}
    ...      - {pdn: 1, qci: 6, default: off, preprovisioned: off}
    ...      - {pdn: 1, qci: 7, default: off, preprovisioned: off}
    ...      - {pdn: 1, qci: 9, default: off, preprovisioned: off}
    FOR    ${ue_id}     IN RANGE    1    36
        Update Yaml    UEs/UE_sets/${ue_id}     bearer: bearer_set_2
    END

Preset parameters
    Execute Egate Command    mme_timer T_S1APInitialContextSetup=8000ms
    Execute Egate Command    mme_timer T3460=10000

CUS multiple attach UE1 to UE20 and data transmission successful
    [Arguments]    ${start_ue_id}=1    ${end_ue_id}=20
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${${end_ue_id}+1}
        Execute Uex Command    ue_attach id=${ue_id} enb=1 cell=1
        Execute Uex Command    trf_data_start ue=${ue_id} qci=2 Mbps=175 dir=dl protocol=udp trf_id=1
        Execute Uex Command    trf_data_start ue=${ue_id} qci=3 Mbps=175 dir=dl protocol=udp trf_id=1
        Execute UEx Command    trf_data_start ue=${ue_id} qci=128 Mbps=175 dir=dl protocol=udp trf_id=1
    END

CUS multiple attach UE21 to UE35 and data transmission lead some UEs Overbooking
    [Arguments]    ${start_ue_id}=21    ${end_ue_id}=35
    Expect Message Flow
    ...    MME_1:S1AP_InitialContextSetupRequest
    ...    MME_1:S1AP_InitialContextSetupResponse ( cause contains ( radioNetwork eq "radio-resources-not-available" ) )
    ...    alias=Attach_35_UEs    overall_timeout=100
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${${end_ue_id}+1}
        Execute Uex Command    ue_attach id=${ue_id} enb=1 cell=1
        Run Keyword And Ignore Error    Execute Uex Command    trf_data_start ue=${ue_id} qci=2 Mbps=175 dir=dl protocol=udp trf_id=1
        Run Keyword And Ignore Error    Execute Uex Command    trf_data_start ue=${ue_id} qci=3 Mbps=175 dir=dl protocol=udp trf_id=1
        Run Keyword And Ignore Error    Execute UEx Command    trf_data_start ue=${ue_id} qci=128 Mbps=175 dir=dl protocol=udp trf_id=1
    END
    flow occurred as expected    alias=Attach_35_UEs

Stop 35 UEs traffic successfully
    [Arguments]    ${start_ue_id}=1    ${end_ue_id}=35
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${${end_ue_id}+1}
        Execute Uex Command    trf_data_stop ue=${ue_id}
    END

Detach 35 UEs successfully
    [Arguments]    ${start_ue_id}=1    ${end_ue_id}=35
     FOR    ${local_ue_id}    IN RANGE    ${start_ue_id}    ${end_ue_id} + 1
        Execute Uex Command    ue_detach id=${local_ue_id}
     END
