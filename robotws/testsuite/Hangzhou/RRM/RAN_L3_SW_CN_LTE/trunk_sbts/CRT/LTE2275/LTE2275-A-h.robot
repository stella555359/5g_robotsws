*** Settings ***
Documentation
...      INTRODUCTION:  The purpose of this test is to verify correct behaviour of eNodeB,
...                     when Pcell Swap feature is active and maximum HOs rate for PCell swap is set to smaller value
...                     than number of UEs that should be swapped
...
...      TESTING SPLIT:  There are only CIT test from the feature LTE2275. Subfeatures : LTE2275-A, LTE2275-A-h
...
...      CONTACTS:  Jakub Drabina jakub.drabina@nokia.com , I_CRT_SUPPORT_TEAM_KRA_GMS
...                 Witold Irlik witold.irlik@nokia.com
...
...      REFERENCES:  HOME/LTE_System/CFAM/LTE/LTE2200-2399/CFAM_LTE2275_RRM
...                   https://gates.nsn-net.net/view/4017b9fe29051a61-0001fe69#o=0
...
...      HISTORY:  <Approval at QC level> - After aproving commit number should be stored at QC


Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CIT    CLOUD_R4MAQN_CUS
...               team-SG4    release-SBTS23R4    owner-Kowalczyk Jakub
Resource          ../../../resources/DevHZ5_resource.robot

Library    LTE2275_resource/LTE2275_A_h.py
Library    LTE2275_resource/LAA/ca_managment.py
Library    LTE2275_resource/common/common.py

*** Variables ***
@{LTE2275_pcellswap}
...    LNCEL-1:pcellSwapConfig:numCaUeThreshold=0

*** Test Cases ***
[1]C-Pln_LTE2275-A-h_TC1_UE_canditate_selection-pcellSwapMaxHoRate
    [Documentation]
    ...  DESCRIPTION:  The purpose of this test is to verify correct behaviour of eNodeB,
    ...                when Pcell Swap feature is active and maximum HOs rate for PCell swap is set to smaller value
    ...                than number of UEs that should be swapped.
    ...
    ...  TESTING TOOLS:  UE, EGATE, EMSS, UTE / TA libraries: <See imported libraries>
    ...
    ...  REQUIRED LOGS:  Robot LOG
    ...
    ...  CONTACTS:  Jakub Drabina jakub.drabina@nokia.com , I_CRT_SUPPORT_TEAM_KRA_GMS
    ...             Witold Irlik witold.irlik@nokia.com
    ...
    ...  REFERENCES:  [CFAM] US080: LTE2275-A-h UE canditate selection - full functionality
    ...               Requirements: LTE-CCPM.21626;RRM_LTE_SFS_RRM_URSC.1078
    ...
    ...  HISTORY:  V.0.1 27.08.2015 Witold Irlik

    [Tags]    RAN_4G    RAN_4G_FDD    CRT    TC5    Author-Kowalczyk Jakub
    Prepare enviroment for test
    Attach 30 CA capable UEs on cell 1 with small UL traffic
    Attach 1 non CA capable UE on cell 1 with UL traffic
    Observe for RRCConnectionReconfiguration messages with sCells release and sCells addition for 60 seconds
    Change numCaUeThreshold to 0
    Verify if during 5 seconds period at least one and no more than 22 UEs were swapped

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env    tl_type=LTE2275_3CELLs_FDD_B2_B4_B5    ue_count=200    cfg=cus.yaml
    Create Alias

Create Alias
    FOR    ${ue_id}    IN RANGE    1    130
        Create UE Alias    UE_${ue_id}    ue_id=${ue_id}    id_type=cus
    END
    Create UE Group Aliases    UE_GROUP    start_ue_id=1    stop_ue_id=130    id_type=cus
    Create MME Alias    alias=MME_1    mme_id=1    id_type=wts
    Create CELL alias    alias=CELL_1    cell_id=1    cell_type=cus
    Create ENB alias    alias=MeNB    enb_id=1    id_type=wts

Set test LTE2275-A-h preconditions
    Run WTS command    mme_timer    T_S1APInitialContextSetup=80s
	
Prepare enviroment for test
    Set test LTE2275-A-h preconditions
	Prepare test environment

Prepare test environment
    ${ues_alias_list}=    Create 1 to 30 UEs Alias list
    Set Suite Variable    ${ues_alias_list}

Create ${ue_from} to ${ue_to} UEs Alias list
    ${ue_to}=    Evaluate    ${ue_to}+1
    ${ue_alist}=  Create List
    FOR    ${ue_id}    IN RANGE    ${ue_from}    ${ue_to}
        Append To List    ${ue_alist}  UE_${ue_id}
    END
    [Return]    ${ue_alist}

Attach 30 CA capable UEs on cell 1 with small UL traffic
    Ue Attach    interval=500    id=1..30    cell=1
    Sleep    2
    Trf Data Start    protocol=udp    dir=ul    kbps=1    size=200    interval=500    ue=1..30
    Sleep    5

Attach 1 non CA capable UE on cell 1 with UL traffic
    Ue Attach    id=50    cell=1
    Sleep    1
    Trf Data Start    protocol=udp    dir=ul    Mbps=8    ue=50

Change numCaUeThreshold to 0	
	Delta Commission Parameters    ${LTE2275_pcellswap}
	Cells Should Be OnAir

Verify if during 5 seconds period at least one and no more than ${ue_swapped:\d+} UEs were swapped
    ${result}=    check number of swapped ue in 5 seconds period    ${ues_alias_list}
    Should be true    ${result} <= ${ue_swapped}    Swapped too many UEs, ${result} swapped instead of less or equal ${ue_swapped} during 5s
