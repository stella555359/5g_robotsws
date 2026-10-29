*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G_FDD    SBTS00    team-SG02    owner-yige.g.zhang
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    release-SBTS22R1
...    STATE_CONFIGURED    RAN_5G

Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{EDA_01782659}

@{LOCK_CELLS_PARAMTER}
...    NRCELL-1:administrativeState=Locked
...    NRCELL-2:administrativeState=Locked

@{UNLOCK_CELLS_PARAMTER}
...    NRCELL-1:administrativeState=Unlocked
...    NRCELL-2:administrativeState=Unlocked

@{EDA_01782659}
...    MRBTS-1/NRBTS-1:tmpActFeat1=1
...    MRBTS-1/NRBTS-1/SNSSAI-2:sd=13714347
...    MRBTS-1/NRBTS-1/SNSSAI-2:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SNSSAI-2:sst=1
...    MRBTS-1/NRBTS-1/SNSSAI-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/TRACKINGAREA-300:fiveGsTac=100
...    MRBTS-1/NRBTS-1/TRACKINGAREA-300:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2

*** Test Cases ***
5GC000900_5GSW_CP_EDA_01782659_when_NgRANConfigUpdateFailure_then_both_cell_on_air
    [Documentation]
    ...    1.Purpose
    ...      This case is to verify BTS fails to activate SANSA cell after cell unlock when NgRANConfigUpdateFailure is raised
    ...    & MeNBX2-C is available
    ...    2. Test Case Steps:
    ...    Step 1. lock cell
    ...         2. TRACKINGAREA from valid to invalid
    ...         3. unlock cell
    ...         4. check cell barred
    ...         5. lock cell
    ...         6. TRACKINGAREA from invalid to valid
    ...         7. unlock cell
    ...         8. UEs attach successful
    [Tags]    QC_284305
    Lock Cells
    TRACKINGAREA from valid to invalid
    Unlock Cells
    Check cell is barred
    Lock Cells
    TRACKINGAREA from invalid to valid
    Unlock Cells
    Cells on air
    UEs attach to 2 cells
    Release Ues    ue_type=all
    check wireshark log    ${CURDIR}${/}a2a_EDA_0178${/}a2a_0178.ini    wait_string=UEContextReleaseComplete::12

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Check cell barred message
    ${out}    execute egate command    ib_enb_cell_disp enb=2 cell=1    SIB1
    should contain    ${out}    MIB    40    0    yes
    should contain    ${out}    SIB1    80    0    no

TRACKINGAREA from valid to invalid
     Delta Commission Parameters    NRCELL-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-300

TRACKINGAREA from invalid to valid
    Delta Commission Parameters    NRCELL-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200

Check cell is barred
    Object Should Exist    MRBTS-1/NRBTS-1/NRCELL-1:operationalState=enabled
    Object Should Exist    MRBTS-1/NRBTS-1/NRCELL-1:barringStatus=barred
    Check cell barred message

Lock Cells
    Delta Commission Parameters    ${LOCK_CELLS_PARAMTER}
    Cell Should Be Locked    1
    Cell Should Be Locked    2

Unlock Cells
    Delta Commission Parameters    ${UNLOCK_CELLS_PARAMTER}
    Cell Should Be Unlocked    1
    sleep   30s
    Cell Should Be Unlocked    2

UEs attach to 2 cells
   nsa ue attach successful    31    1
   sa ue attach successful    1    1    1
   nsa ue attach successful    32    2
   sa ue attach successful    2    2    1

sa ue attach successful
    [Arguments]    ${id}    ${pdu}=1    ${nwslice}=1    ${cmd_regexp}=NG RM Registered
    ...    ${cmd_pdu_regexp}=QoS Routing Table
    Execute Egate Command    ue_register id=${id}    ${cmd_regexp}
    Execute Egate Command    set_pdu_param ue=${id} pdu=${pdu} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${id} pdu=${pdu} nwslice=${nwslice} gw=${id}    ${cmd_pdu_regexp}
    traffic should be ok    ue_id=${id}    pdu=${pdu}    type=SA

nsa ue attach successful
    [Arguments]    ${id}    ${target_cells}=1    ${cmd_regexp}=reported successful RA
    Execute Egate Command    ue_attach id=${id}    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg    ${cmd_regexp}
    traffic should be ok    ue_id=${id}    type=NSA

Cells on air
    wait until keyword succeeds    16 min    10 sec    cells should be on air
