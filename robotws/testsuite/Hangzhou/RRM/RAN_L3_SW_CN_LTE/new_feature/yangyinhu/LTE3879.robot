*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_TDD    CRT    CLOUD_R4LAPO_CUS
...               team-SG2    owner-Allen.ge    release-SBTS20A
Resource          ../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    LNBTS:mcc=262

*** Test Cases ***
LTE3879
    [Documentation]
    [Tags]    QC_
    Cells Should Be OnAir

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env    tl_type=4CELLs_TDD_B41_8PIPES
    Set UE parameters before ENDC setup
    Create Alias

Set UE parameters before ENDC setup
    Execute Egate Command    trace uec=1 mme=1 protocol=rrc,nr_rrc,s1,x2 on
    Execute Egate Command    trace_sim enb=2 protocol=x2,s1 on
    Config UE1 to UE10
    Config gnb7

Config UE1 to UE10
    FOR    ${ue_id}    IN RANGE    1    10
        Execute Uex Command    ue_param id=${ue_id} dual_conn=eutra_nr pdcp_sn_extension=18bit
        Execute Uex Command    ue_param id=${ue_id} type=nr release=15 nr_supported_bands=7
        Execute Uex Command    ue_param id=${ue_id} type=nr release=15 supported_bands=7
        Execute Uex Command    ue_param id=${ue_id} type=nr release=15 supported_bands=77
        Execute Uex Command    ue_param id=${ue_id} type=nr release=15 supported_bands=78
        Execute Uex Command    ue_param id=${ue_id} type=nr release=15 supported_bands=79
        Execute Egate Command    ue_enb_param id=${ue_id} ue_config_release_r9=rel15
    END

Config gnb7
    Execute Egate Command    gnb_endc_param id=7 use_nr_ran_cont=true
    Execute Egate Command    gnb_endc_param id=7 scg_dl_dist_percent=0
    Execute Egate Command    gnb_endc_param id=7 include_reestablish_pdcp=on
    Execute Egate Command    gnb_endc_param id=7 selected_band_combination_nr=1:1
    Execute Egate Command    enb_param id=7 endc_capable_qci=6,7,8
    Execute Egate Command    enb_x2_link_up enb=7 target=1    X2 link with eNB-1 is activated already
    Execute Egate Command    enb_x2_link_up enb=2 target=1    X2 link with eNB-1 is activated already
    Execute Egate Command    enb_x2_link_up enb=2 target=7    is up
    Execute Egate Command    enb_timer T_SN_STATUS_TRANSFER=5000ms
    Execute Egate Command    enb_timer T_DC_Overall=5000ms

Create Alias
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create UE Alias    UE_2    ue_id=2    id_type=cus
    Create UE Alias    UE_3    ue_id=3    id_type=cus
    Create UE Alias    UE_4    ue_id=4    id_type=cus
    Create UE Alias    UE_5    ue_id=5    id_type=cus
    Create UE Alias    UE_9    ue_id=9    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create Enb Alias    GNB_7    enb_id=7    id_type=wts
    Create Enb Alias    GNB_8    enb_id=8    id_type=wts
    Create MME Alias    alias=MME_1    mme_id=1    id_type=wts
