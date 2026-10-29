*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_TDD    CRT    CLOUD_R4LAPO_CUS    release-Legacy
...               team-RT1    owner-fei.he    owner-rebecca.zhong
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
${UE_EUTRA_CAPABILITIES}    919FF43A33E6CB0007FFFFFFFC00
@{PARAMS_IN_SCF}
...    @{Related_Feature_Switch}
...    @{LTE_IF_Neighbor_Param}
@{Related_Feature_Switch}
...    LNBTS-1:actMBMS=false
...    LNBTS-1:actLTES1Ho=true
...    LNBTS-1:actIfHo=enabled
...    LNBTS-1/LNBTS_TDD-0:actConvVoice=true
...    LNCEL-1/LNCEL_TDD-0:earfcn=40940
...    LNBTS-1:actSelMobPrf=false
@{LTE_IF_Neighbor_Param}
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=40742
...    LNCEL-1:blacklistHoL:blacklistTopo=onlyX2
...    LNCEL-1:blacklistHoL:freqEutra=40742
...    LNCEL-1:blacklistHoL:phyCellIdStart=0
...    LNCEL-1:blacklistHoL:phyCellIdRange=n504
...    MODPR-0:freqLayListLte=40742
...    MOPR-1:freqLayListLte=40742
@{pm_counters}
...    LNCEL-1:${INTER_ENB_S1_HO_QCI1_PREP}=1
...    LNCEL-1:${INTER_ENB_S1_HO_QCI1_ATT}=1
...    LNCEL-1:${INTER_ENB_S1_HO_QCI1_SUCC}=1
...    LNCEL-1:${INTER_ENB_X2_HO_QCI1_ATT}=0
...    LNCEL-1:${HO_INTFREQ_QCI1_ATT}=1
...    LNCEL-1:${HO_INTFREQ_QCI1_SUCC}=1
...    LNCEL-1:${INTER_ENB_S1_HO_PREP}=1
...    LNCEL-1:${INTER_ENB_S1_HO_ATT}=1
...    LNCEL-1:${HO_INTFREQ_ATT}=1
...    LNCEL-1:${HO_INTFREQ_GAP_ATT}=1
...    LNCEL-1:${HO_INTFREQ_SUCC}=1
${INTER_ENB_S1_HO_QCI1_PREP}    M8014C22
${INTER_ENB_S1_HO_QCI1_ATT}    M8014C23
${INTER_ENB_S1_HO_QCI1_SUCC}    M8014C24
${INTER_ENB_X2_HO_QCI1_ATT}    M8014C26
${HO_INTFREQ_QCI1_ATT}    M8021C39
${HO_INTFREQ_QCI1_SUCC}    M8021C40
${INTER_ENB_S1_HO_PREP}    M8014C14
${INTER_ENB_S1_HO_ATT}    M8014C18
${HO_INTFREQ_ATT}    M8021C0
${HO_INTFREQ_GAP_ATT}    M8021C1
${HO_INTFREQ_SUCC}    M8021C2
@{Recovery_Blacklist_Param}
...  LNCEL-1:blacklistHoL:blacklistTopo=allEqual
...  LNCEL-1:blacklistHoL:freqEutra=65535
...  LNCEL-1:blacklistHoL:phyCellIdStart=499
...  LNCEL-1:blacklistHoL:phyCellIdRange=n4


*** Test Cases ***
LTE2446-A-a_01_01_Inter-Freq_S1 HO_Execution_Success
    [Tags]
    UE Attach to eNB1 CELL1    ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES}
    Trigger S1HO to simENB
    Check Counters    pm_counters_expression=${pm_counters}
    Recovery Blacklist parameters
    release all ues

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs    ue_count=100
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create MME Alias    alias=MME_1    mme_id=1    id_type=wts

Modify Yaml
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...     - {qci: 8, default: on, pdn: 1}
    ...     - {qci: 1, mbr_ul: 25, gbr_dl: 25, gbr_ul: 25, mbr_dl: 25, preprovisioned: on, filter: 1, precedence: 1, pdn: 1}
    Update Yaml    UEs/UE_sets/1    bearer: bearer_set_2
    # add sim enb2
    Add Yaml    BASE_STATIONS
    ...    - id: 2
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1: 10.0.1.3
    ...      x2: 10.0.1.3
    ...      cells:
    ...        - {'id': 21, technology: lte, tdd_cell: yes, duplex_mode: TDD, tac: 33, pci: '10:0', earfcn: '40742:40742', bw: 20}
    ...        - {'id': 22, technology: lte, tdd_cell: yes, duplex_mode: TDD, tac: 33, pci: '10:1', earfcn: '40742:40742', bw: 20}
    ...        - {'id': 23, technology: lte, tdd_cell: yes, duplex_mode: TDD, tac: 33, pci: '10:2', earfcn: '40742:40742', bw: 20}

UE Attach to eNB1 CELL1
    [Arguments]    ${ue_eutra_capabilities}    ${cell_id}=1
    Execute Uex Command    ue_attach id=1 ue_eutra_capabilities=${ue_eutra_capabilities} cell=${cell_id}


Trigger S1HO to simENB
    Execute Uex Command    ue_ho id=1 enb=2 cell=21

Recovery Blacklist parameters
    Delta Commission Parameters              ${Recovery_Blacklist_Param}
