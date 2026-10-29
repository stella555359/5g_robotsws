*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env Aic
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters Aic
Test Setup    Common Test Setup And Start To Capture Logs Aic
Test Teardown    Common Test Teardown And Stop Capture Logs Aic
Force Tags    QCD_MN_RAN    QCP_RAN_ET    master_vDU    RAN_5G    RAN_Aic    CRT
...    CLOUD_5GC_dRNIC_1vDU_P_AP_LO_DC    SANSA_FS_ECPRI_CMWV_TDD_CPRI_CMWV_FDD    RAN_5G_TDD    vDUCNF00

Resource    ../../../../resources_aic/DevHZ5_resource_aic.robot

*** Variables ***
${TL_TYPE_PATH}    tddfdd_sansa_cmwv/FS/1du/4cells_2T2F
${NSA_UE_ID}    31
${SA_UE_ID}    1


###counter
${SAMPLES_CELL_AVAIL}    M55601C00002   #number of samples when the cell is available
@{PM_Counters_Check_900}
...    NRCELL-1:NCAV:${SAMPLES_CELL_AVAIL}>0


*** Test Cases ***
CB009444-ET_5GC000900_Verify_Cloud_NSA_And_SA_TDD_cmWave_L3_call_setup_on_NSA_And_SA_cell_is_successful
    [Documentation]
    ...    1. The purpose of this test case is to check SA UE L3 call and NSA L3 call can be concurrently successful
    ...    2. Test Case Steps:
    ...         a. make a NSA UE L3 call
    ...         b. make a SA UE L3 call
    ...    3. Expected Results:
    ...         Step a: NSA UE attach successfully and traffic should be OK
    ...         Step b: SA UE attach successfully and traffic should be OK
    ...         check counter M55601C00002>0
    [Tags]    QC_278712
    Clear Counter Files Cu Aic
    Start To Capture Wireshark Log Aic    NSA_SA_UE_attach
    Repeated NSA and SA L3 Call    repeat_times=5
    Check WireShark Log Aic    a2a_ini_file=${CURDIR}/a2a_900/a2a_UE_attach.ini    name=NSA_SA_UE_attach    wait_string=UEContextReleaseComplete::30
    Check Counters Cu Aic    ${PM_Counters_Check_900}

*** Keywords ***
Modify Cfg Aic
    Update Cfg Aic    ue_param id=${SA_UE_ID} ue_nr_capabilities=${SA_Capa_perUE_Full}

NSA UE Attach and Traffic
    [Arguments]    ${ue_id}=11    ${cmd_regexp}=UE IS ACTIVE    ${cmd_endc_regexp}=reported successful RA
    Execute Egate Command    ue_attach id=${ue_id}    ${cmd_regexp}
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=1 bearer=2 type=split_scg    ${cmd_endc_regexp}
    traffic should be ok    ue_id=${ue_id}    type=NSA

SA UE Attach and Traffic
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${gw_id}=1    ${nwslice}=1
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=${nwslice}    QoS Routing Table
    traffic should be ok    ue_id=${ue_id}    type=SA

Repeated NSA and SA L3 Call
    [Arguments]    ${repeat_times}=5
    FOR    ${times}    IN RANGE    0    ${repeat_times}
        NSA UE Attach and Traffic    ue_id=${NSA_UE_ID}
        SA UE Attach and Traffic    ue_id=${SA_UE_ID}
        Release Ues  ue_type=all
        sleep    5s
	END
