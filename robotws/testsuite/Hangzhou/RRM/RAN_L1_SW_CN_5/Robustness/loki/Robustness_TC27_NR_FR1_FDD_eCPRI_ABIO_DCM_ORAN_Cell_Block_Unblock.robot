*** Settings ***
Documentation
...    Author:  Kong Liang
...    Contact: liang.kong@nokia-sbell.com
...    Feature: Robustness
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    5G_RAN_TDD    RAN_5G    CLOUD_5G_I_LO_AP_LOOO
...    SBTS00    CRT    QL3    QCD_MN_RAN    QCP_RAN_RF
Resource    ../../resources/Airphone/Airphone_resource.robot

*** Variables ***
@{ALLOWED_FAULT}    49
${repeat_number}    10

*** Test Cases ***
Robustness_TC27_NR_FR1_FDD_eCPRI_ABIO_DCM_ORAN_Cell_Block_Unblock
    [Tags]    ABIO    SMAwave    Robustness    CellBlock    Trunk    QL3
    Wait Until Keyword Succeeds    10 min    30 sec    Check If All Cells Are OnAir
    ${cell_id_dict}    Get id From NR Cells
    ${cell_global_cell_id_list}    Get Dictionary Keys    ${cell_id_dict}
    Set Test Variable    ${cell_global_cell_id_list}
    FOR    ${item}    IN RANGE    ${repeat_number}
        Perform NR Cell block ${cell_global_cell_id_list} via AdminCLI
        sleep    60s
        Perform NR Cell unblock ${cell_global_cell_id_list} via AdminCLI
        Wait Until Keyword Succeeds    5 min    30 sec    Check If All Cells Are OnAir
        Ue Attach to cell and data traffic
    END

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup for Airphone
    Setup Airphone Env    tl_type=AP_LOOO/fdd_sansa_cmwv/FS/DCM_ecpri_FDD    cfg=wts.cfg    withCommission=True

Ue Attach to cell and data traffic
    Log To Console     \start L3 call
    Airphone L3 call    call_type=sa    cell_id=1    ue_id=1    bearer_id=2
    ...    dl_mbps=200    ul_mbps=100    level=ue_stats_nr
