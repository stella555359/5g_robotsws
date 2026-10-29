*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G_TDD    SBTS00    team-Rock_SGT&A    owner-liupei.fang
...    CLOUD_5G_I_LO_AP_LO_NSA_FS_ECPRI_MMWV_TDD    CRT    CNI-88819_5GC001866    release-5G23R2
...    STATE_CONFIGURED    RAN_5G
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    NRBTS-1/NRCELL:actDl256Qam=false
...    NRBTS-1/NRCELL:actIncreasedFdmUsersPerSlot=false


@{OnlineParamChange_F001}
...    NRBTS-1:actCustomBsr=true
...    NRBTS-1/NRCELL-1:actBeamforming=true
...    NRCELL-1:beamSet:nrBtsBeamRefinementP2=false
...    NRCELL-1:beamSet:customBeamSetName=BSR_AEUD_32_H6H6H4_2P_ALN90_ARP90_ETN3_EBP37_CAPACITY_00001_00001
...    NRBTS-1/NRCELLGRP-0:numberOfTransmittedSsBlocks=32 beams
...    NRBTS-1/NRCELLGRP-0:ssBurstSetPeriod=20


${BSR_file}    BSR_AEUD_32_H6H6H4_2P_ALN90_ARP90_ETN3_EBP37_CAPACITY_00001_00001


*** Test Cases ***
5GC001866-ET-F001_Verify_L3_call_is_ok_after_BSR_file_is_successfully_downloaded_to_classical_gNB_with_gen4_eCPRI_mmwave
    [Documentation]
    ...    CNI-88819_5GC001866-ET-F001_Verify_L3_call_is_ok_after_BSR_file_is_successfully_downloaded_to_classical_gNB_with_gen4_eCPRI_mmwave
    ...    1. This user scenario is Verify successful mmwave BSR file downloaded to classical gnb 
    ...    2. Configuration:
    ...        cell-1:band 257, FR2 with chbw:100MHz
    ...        cell-2:band 257, FR2 with chbw:100MHz
    ...    2. Test Case Steps:
    ...         a. cell is on air with RU type AEUD and 1866 feature disabled
    ...         b. Installed AEUD BSR pacakge via webEM 
    ...            Expected result:Install BSR package should successflly.
    ...         c. Enable feature 1866 and used new installed custombeamset file :BSR_AEUD_32_H6H6H4_2P_ALN90_ARP90_ETN3_EBP37_CAPACITY_00001_00001
    ...         d. cheked new custombeamset file is used 
    ...         e. UE attach should be succssfully with new Beamset file 
    ...         f. check NSA throuput should be fine 
    [Tags]    owner-liupei.fang    F001
    Install eNB Package via WEBEM
    Enable feature 1866 and use custombeamset
    Check inuesed BSR
    UE Attach To Target Cell NSA    ue_id=11
    Send And Verify Nsa Throuput    ue_id=11
    

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_nsa_mmwv/FS/2cells_ecpri    cfg=wts.cfg    
    
    
UE Attach To Target Cell NSA
    [Arguments]    ${cell_id}=1    ${ue_id}=11
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${cell_id} bearer=2 type=split_scg
    ...    reported successful RA


Verify Throuput
    [Arguments]    ${ue_id}    ${sleep_time}
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=dl    dc_cell_group=all    rate_type=ave
    ${ul_throughput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${dl_throughput}/1000>9
    Should Be True    ${ul_throughput}/1000>9

Send And Verify Nsa Throuput
    [Arguments]    ${ue_id}=11    ${sleep_time}=10s
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=10    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=ul mbps=10    UE ${ue_id}: UDP UL
    Verify Throuput    ${ue_id}    ${sleep_time}



Enable feature 1866 and use custombeamset
   Delta Commission Parameters    ${OnlineParamChange_F001}
   

Check inuesed BSR 
    ${beamSetInstall}    Get Scf Parameter Value    MRBTS-1/NRBTS-1/NRCELL-1:beamSet:beamSetInUse
    Should Be Equal    ${beamSetInstall}    ${BSR_file}



Install eNB Package via WEBEM
    [Arguments]    ${bsr_path}=/home/ute/bsr_package   
    ...    ${bsr_name}=BSR_AEUD_32_H6H6H4_2P_ALN90_ARP90_ETN3_EBP37_CAPACITY_00001_00001.zip
    Execute Cmd On Pc    mkdir ${bsr_path}
    Execute Cmd On Pc    git clone https://wrgitlab.ext.net.nokia.com/y165zhan/bsr_package ${bsr_path}
    update_software    sw_package=${bsr_path}/${bsr_name}    timeout=20
    
    
    
 









