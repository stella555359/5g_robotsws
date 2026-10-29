*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env Aic 4Du
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters Aic
Test Setup    Common Test Setup And Start To Capture Logs Aic
Test Teardown    Common Test Teardown And Stop Capture Logs Aic
Force Tags    QCD_MN_RAN    QCP_RAN_ET    vDUCNF00    RAN_Aic    RAN_5G    CRT    CLOUD_5GC_dRNIC_4vDU_P_AP_LOO_MassiveVlan
...    VARIANT_SA_FS_ECPRI_CMWV_TDD_4CPIF_RanSharing    team-CN3ET    owner-tinan.huang    release-SBTS24R2
Resource    ../../../../../resources_aic/DevHZ5_resource_aic.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/4du/8cells_du1_2T_du2_2T_du3_2T_du4_2T_4cpif_ransharing
${MULTI_CPIF_FLAG}    True
${RANSHARING_FLAG}    True
${REDUNDANT_MODE_CU_FLAG}    True
${SOS_REPORT_FLAG}    pass:False,fail:False
#@{PARAMS_IN_SCF_CU}    @{6AMFs}    @{6PLMN}
#@{PARAMS_IN_SCF_DU1}    @{DU_CELL1}    @{6AMFs}    @{6PLMN}
#@{PARAMS_IN_SCF_DU2}    @{DU_CELL2}    @{6AMFs}    @{6PLMN}
#@{PARAMS_IN_SCF_DU3}    @{DU_CELL3}    @{6AMFs}    @{6PLMN}
#@{PARAMS_IN_SCF_DU4}    @{DU_CELL4}    @{6AMFs}    @{6PLMN}

${PLMN1}    311:489
${PLMN2}    312:489
${PLMN3}    313:489
${PLMN4}    314:489

@{FAULTS_EXCLUDED_CHECKING}    4405


*** Test Cases ***
CB009021-CR-D-B3_ET_01_RAN sharing with NG dedicated IP configuration in multi-CP-IF
    [Documentation]
    ...    Precondition:
    ...        vCU deployed with 4 CPIF + SA RANSharing
    ...        CPIF connected with DU1-Cell1
    ...        CPIFA1 connected with DU2-Cell2
    ...        CPIFA2 connected with DU3-Cell3
    ...        CPIFA3 connected with DU4-Cell4
    ...        UE1/UE2/UE3/UE4 ICS via different PLMN
    ...    Test Case Steps:
    ...        UE1/UE2/UE3/UE4 ICS to Cell1/Cell2/Cell3/Cell4 with different PLMN
    ...    Expected result:
    ...        UE1/UE2/UE3/UE4 ICS successfully
    [Tags]
    Register For Normal Call and create PDU Successfully    ue_id=1
    Register For Normal Call and create PDU Successfully    ue_id=2
    Register For Normal Call and create PDU Successfully    ue_id=3
    Register For Normal Call and create PDU Successfully    ue_id=4
    Check WireShark Log Aic  a2a_ini_file=${CURDIR}${/}A2A_BB-B6_16${/}a2a_UE1.ini  wait_string=UEContextModificationResponse::4
    Check WireShark Log Aic  a2a_ini_file=${CURDIR}${/}A2A_BB-B6_16${/}a2a_UE2.ini  wait_string=UEContextModificationResponse::4  pod_name_cu=cpifa1 
    Check WireShark Log Aic  a2a_ini_file=${CURDIR}${/}A2A_BB-B6_16${/}a2a_UE3.ini  wait_string=UEContextModificationResponse::4  pod_name_cu=cpifa2
    Check WireShark Log Aic  a2a_ini_file=${CURDIR}${/}A2A_BB-B6_16${/}a2a_UE4.ini  wait_string=UEContextModificationResponse::4  pod_name_cu=cpifa3
    Release Ues    ue_type=all
    
*** Keywords ***
Modify Cfg Aic
    ${UE1_PLMN}    catenate
    ...    set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g 
    ...    sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:${PLMN4}:0000:0:0:021645400 enb=2 mode=nr cell=1
    ${UE2_PLMN}    catenate
    ...    set_ue simulated id=2 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g
    ...    sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:${PLMN3}:0000:0:0:021645401 enb=2 mode=nr cell=2
    ${UE3_PLMN}    catenate
    ...    set_ue simulated id=3 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g
    ...    sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:${PLMN2}:0000:0:0:021645402 enb=2 mode=nr cell=3
    ${UE4_PLMN}    catenate
    ...    set_ue simulated id=4 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g
    ...    sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:${PLMN1}:0000:0:0:021645403 enb=2 mode=nr cell=4
    Update Cfg Aic    ${UE1_PLMN}
    Update Cfg Aic    ${UE2_PLMN}
    Update Cfg Aic    ${UE3_PLMN}
    Update Cfg Aic    ${UE4_PLMN}

UE Register To GNB
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Regist

UE PDU Session setup
    [Arguments]    ${pdu}=1    ${ueid}=1    ${nwslice}=1    ${gw}=1    
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu} ue=${ue_id} nwslice=${nwslice} gw=${gw}    QoS Routing Table

Register For Normal Call and create PDU Successfully 
    [Arguments]    ${ue_id}
    UE Register To GNB    ${ue_id}
    UE PDU Session setup    pdu=1    ueid=${ue_id}    nwslice=1    gw=${ue_id}
