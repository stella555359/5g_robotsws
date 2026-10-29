*** Settings ***
Suite Setup  Common Suite Setup And Setup Airphone Env
Suite Teardown  Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup  Common Test Setup And Start To Capture Logs
Test Teardown  Common Test Teardown And Stop Capture Logs
Force Tags  QCD_MN_RAN  QCP_RAN_ET  SBTS00    RAN_5G    RAN_5G_FDD    CIT  team-SG2   
...    owner-y33chen    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CDRT  release-SBTS22R1

Resource  ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{parameters_related_to_both_celldeptype}

@{parameters_related_to_both_celldeptype}
...  MRBTS-1/NRBTS-1/NRCELL-1:cellDepType=SA+NSA
...  MRBTS-1/NRBTS-1/NRCELL-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...  MRBTS-1/NRBTS-1/NRCELL-1:configuredEpsTac=4580

@{counters_dict_cit005}
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1:${SAMPLES_CELL_AVAIL}>0    #M55124C04002==1
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2:${SAMPLES_CELL_AVAIL}>0

${SAMPLES_CELL_AVAIL}    M55601C00002    #Number of samples when the cell is available.

${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2cells_ecpri  
${SETUP_X2_BEFORE_NG}    ${True}
${ue_id}    1
${ue_id2}    31
*** Test Cases ***
5GSW-CP-CIT005_Verify_Classical_NSA_And_SA_TDD_cmWave_L3_call_setup_on_NSA_And_SA_cell_is_successful
  [Tags]  QC_61702
  [Documentation]
    ...    1.Purpose  
    ...    Verify the cell setup when cell is configured for both (SA and NSA) access.
    ...    2. Test Case Steps
    ...    Step a. X2 starts first and ng starts later
    ...         b. attach NSA call and SA call
    ...         c. re-run five times

   Trigger NSA Call and SA Call by Five Times
   Check Counters    ${counters_dict_cit005}
*** Keywords ***

Modify Cfg
    Update Cfg    set_pdu_gateway id=2 ue_nat_ip=72.23.0.2 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=3 ue_nat_ip=72.23.0.3 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=4 ue_nat_ip=72.23.0.4 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=5 ue_nat_ip=72.23.0.5 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=6 ue_nat_ip=72.23.0.6 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1

Trigger NSA Call and SA Call by Five Times
    start to capture wireshark log    multi_call
    FOR    ${num}    IN RANGE    0    5
       LOOP Five Times
    END

LOOP Five Times
    FOR    ${index}    IN RANGE    0    5
        ${ue1}    Evaluate    ${ue_id}+${index}
        sa ue register and pdu setup    ${ue1}
        traffic should be ok    ue_id=${ue1}    type=SA
        ${ue2}    Evaluate    ${ue_id2}+${index}
        nsa ue attach successful    ${ue2}
        traffic should be ok    ${ue2}    type=NSA
        Detach UEs    ${ue2}    ${ue1}
    END
sa ue register and pdu setup
    [Arguments]    ${id}    ${pdu}=1    ${nwslice}=1    ${cmd_regexp}=NG RM Registered
    ...    ${cmd_pdu_regexp}=QoS Routing Table
    Execute Egate Command    ue_register id=${id}    ${cmd_regexp}
    Execute Egate Command    set_pdu_param ue=${id} pdu=${pdu} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${id} pdu=${pdu} nwslice=${nwslice} gw=${id}    ${cmd_pdu_regexp}

nsa ue attach successful
    [Arguments]    ${id}    ${target_cells}=1    ${nwslice}=1    ${cmd_regexp}=reported successful RA
    Execute Egate Command    ue_attach id=${id}    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg    ${cmd_regexp}

Detach UEs
    [Arguments]    ${id2}    ${id}
    Execute Egate Command    ue_deregister id=${id} ue_deregister_type=switch_off    Received UE Context Release Complete
    Execute Egate Command    ue_detach id=${id2}    UE IS OFF
    sleep    5s