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

*** Test Cases ***

5GC000900_5GSW_CP_EDA_PR640540_reset_BBboard_wait_cell_onair_and_UEs_attach_successful
    [Documentation]
    ...    verify the BB board reset, then the cells can onair and UEs can attach successful.
    [Tags]    EDA_PR640540    QC_224885
    [Timeout]    3 hour
    Recovery reset BBboard and UEs attach successful

*** Keywords ***
Recovery reset BBboard and UEs attach successful
     FOR    ${index}    IN RANGE    0    3
         Reset BBMODs    1
         All cells on air
         UEs attach to 2 cells
         Release Ues    ue_type=all
         sleep    5s     # wait UE release successful
     END

Common Suite Setup And Setup Airphone Env
  Common Suite Setup
  Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Reset BBMODs
    [Arguments]    ${str_bbmods_list}=null
    ${bbmods_list}    string.split string    ${str_bbmods_list}
    ${coam_conn}    taf.sbts.oam.coam.admin.Connect To
    ${fbb_info}=    taf.sbts.oam.coam.admin.Get fbb info    connection=${coam_conn}
    FOR    ${fbb}    IN    @{fbb_info}
        taf.sbts.oam.coam.admin.Reset Unit    ${fbb['id']['internal']}    reset_type=Warm    timeout=${300}    connection=${coam_conn}
    END
   [Teardown]    taf.sbts.oam.coam.admin.Teardown    ${coam_conn}

UEs attach to 2 cells
   nsa ue attach successful    31    1
   sa ue attach successful    1    1    1
   nsa ue attach successful    32    2
   sa ue attach successful    2    2    1

All cells on air
    wait until keyword succeeds    16 min    10 sec    cells should be on air

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

Modify Cfg
    Update Cfg    set_pdu_gateway id=2 ue_nat_ip=72.23.0.2 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    ${set_ue1}    catenate    set_ue simulated id=2 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645401 mode=nr enb=2 cell=2
    Update Cfg    ${set_ue1}
