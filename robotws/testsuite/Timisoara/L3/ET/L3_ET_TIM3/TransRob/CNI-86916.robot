*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO      VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

Documentation    :copyright: Nokia
...              :author: Alexandru Tancau
...              :contact: alexandru.tancau@nokia.com
...              Transversal Robustness test case added after creation of MNRCA-69880
...              Link: https://jiradc.ext.net.nokia.com/browse/MNRCA-69880

Resource     ../resources/5G_SW_WRO_Keywords.robot
Resource     TransRob_Variables_Keywords.robot

Suite Setup     Run Keywords    Start UTE eth3 interfaces
...             AND             Start Default Logging      output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...             AND             Prepare Preconditions
...             AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Test Setup        Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Test Teardown     Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs

*** Test Cases ***
TransRob_CNI-86916_MNRCA-69880_Successful_Inter-RAT_handover_from_NR_to_LTE_based_on_B2_measurements_with_data_forwarding
    [Documentation]    This case is designed to verify inter-RAT HO in interaction with feature CNI-86916.
    ...                1. Register UE, create and modify 2 pdu sessions and generate traffic for UE1.
    ...                2. UE HO from real gNB to simulated eNB.
    ...                3. Check if end marker is sent from gNB to UPF
    Execute Egate Command   cmd=set_pdu_param ue=1 pdu=1 trf_type=internal
    Execute Egate Command   cmd=set_pdu_param ue=1 pdu=2 trf_type=internal
    Attach Ue    ue_id=1     optional_parameters=nwslice=all
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    Execute Egate Command    cmd=ue_meas_cfg_disp id=1
    Modify PDU Session       ue_id=1    pdu_id=1    qos_to_add=2      by=amf     pass_regexp=Added QosFlow with QFI
    Modify PDU Session       ue_id=1    pdu_id=1    qos_to_add=3      by=amf     pass_regexp=Added QosFlow with QFI
    Establish Pdu Session    ue_id=1    pdu_id=2    gw_id=2
    Modify PDU Session       ue_id=1    pdu_id=2    qos_to_add=4      by=amf     pass_regexp=Added QosFlow with QFI
    Start data traffic on 2 PDU sessions
    Trigger inter-RAT Handover
    Stop data traffic on 2 PDU sessions
    Verify EndMarker received from gNB
