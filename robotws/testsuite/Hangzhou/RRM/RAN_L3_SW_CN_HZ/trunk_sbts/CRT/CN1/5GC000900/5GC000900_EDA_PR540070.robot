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
@{DELTA_PARAS}
...    MRBTS-1/NRBTS-1:actSACallProcessingDU=false
...    MRBTS-1/NRBTS-1/NRCELL-1:cellBarred=notBarred

*** Test Cases ***
5GC000900_5GSW_CP_EDA_PR540070_set_actSACallProcessingDU_false_with_both_cell
    [Documentation]
    ...    1.Purpose
    ...      This case is to verify both cell set actSACallProcessingDU to false, the cell will barred.
    ...    2. Test Case Steps:
    ...    Step 1. update actSACallProcessingDU parameter
    ...         2. wait cell barred message
    ...         3. NSA UE attach successful, SA UE attach failed
    [Tags]    QC_60980
    Delta Commission Parameters    ${DELTA_PARAS}
    wait until keyword succeeds    10min    40s    Check cell barred message
    Trigger SA UE attach fail for actSACallProcessingDU parameter
    Release UEs    ue_type=all

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Check cell barred message
    ${out}    execute egate command    ib_enb_cell_disp enb=2 cell=1    SIB5
    should contain    ${out}    MIB   40           0       yes
    should contain    ${out}    SIB1  80           0       yes
    should contain    ${out}    SIB2  80           0       no
    should contain    ${out}    SIB3  80           0       no
    should contain    ${out}    SIB4  80           0       no
    should contain    ${out}    SIB5  80           0       no

Trigger SA UE attach fail for actSACallProcessingDU parameter
    execute egate command    ue_register id=1    UE1: detached
    execute egate command    ue_attach id=31 profile=1    UE IS ACTIVE
    execute egate command    ue_dc_enb_start ue=31 target_gnb=2 target_cells=1 bearer=2 type=split_scg    reported successful RA
