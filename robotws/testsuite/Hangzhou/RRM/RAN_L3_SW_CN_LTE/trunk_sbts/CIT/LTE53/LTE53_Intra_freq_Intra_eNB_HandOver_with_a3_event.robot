*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    4G_TDD    RAN_4G    RAN_4G_TDD    CIT    team-OAM2
...               CLOUD_R4LAPO_CUS    release-legacy   owner-rebecca.zhong    old-wenying.lu
Resource          ../../../resources/DevHZ5_resource.robot


*** Variable ***
${UE_EUTRA_CAPABILITIES}    C59FF43032CA50000578346200088120701000
@{PARAMS_IN_SCF}
...  LNCEL-1/LNCEL_TDD-0:earfcn=40940
...  LNCEL-2/LNCEL_TDD-0:earfcn=40940
...  LNCEL-1:enableBetterCellHo=true
...  LNCEL-1:a3Offset=6
...  LNCEL-1/LNHOIF-1:eutraCarrierInfo=40742

*** Test Case ***
Intra-fre_Intra-eNB_ HO_with_A3_event
    [Tags]
    UE attach to eNB1    ue_id=1     cell_id=1     ue_eutra_capab=${UE_EUTRA_CAPABILITIES}
    Trigger A3 Event    ue_id=1   pci=2

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs    ue_count=200
    Create UE Group Aliases    UE_GROUP    start_ue_id=1    stop_ue_id=100    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create MME Alias    MME_1    mme_id=1    id_type=wts
    Create CELL alias    alias=CELL_1    cell_id=1    cell_type=cus
    Create CELL alias    alias=CELL_2    cell_id=2    cell_type=cus
    
UE attach to eNB1
    [Arguments]    ${ue_id}   ${cell_id}     ${ue_eutra_capab}
    Execute Uex Command    ue_attach id=${ue_id} ue_eutra_capabilities=${ue_eutra_capab} cell=${cell_id}


Trigger A3 Event
    [Arguments]    ${ue_id}   ${pci}
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (handoverType contains (intraLTE is present))
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (measGapConfig contains (release is present))
    ...    alias=UE_HO_flow    overall_timeout=20
    Execute Uex Command    ue_measurement_send id=${ue_id} event=A3 srsrp=55 phycell_id=${pci} nrsrp=65 nrsrq=34
    Flow Occurred As Expected    alias=UE_HO_flow
