*** Settings ***
Force Tags    CLOUD_5G_I_LPQ_AP_LOO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC    CONFIGURED    RAN_5G_TDD    RAN_5G
...           CRT    SBTS00    NoResUsage    PY310    RF50

Documentation    :copyright: Nokia
...              :authors: Tomasz Niedzwiedzki
...              :contact: tomasz.niedzwiedzki@nokia.com

Resource    CB011041_Keywords_And_Variables.robot

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/../initial_commissioning.xml
...            AND             Start Vm Ethernet Interfaces
...            AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_CB011041_common.json
...            AND             Check Radios Availability
...            AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/scfc_after_delta.xml
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_CB011041_common.lua
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords    Stop Vm Ethernet Interfaces
...               AND             Stop Default Processes And Gather Logs And Compress Logs
...               AND             Sleep    5s    reason=Wait for BTS to be able to process delta
...               AND             Roll Delta Back
...                               initial_scf_filename=${OUTPUT_DIR}/../initial_commissioning.xml
...                               delta_scf_filename=delta_CB011041_common.json

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Test Teardown    Run Keywords    Add Scout External Execution ID To Reporting Portal
...              AND             Deregister UE Without Confirmation    ue_id=all
...              AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Test Cases ***
CB011041_B1_ALT_3_eDRX_RAN_Paging_DL_Data_UPF_Paging_Repetition_Strategy
    [Documentation]    This user scenario describes the gNB behaviour for UE in RRC_INACTIVE state that is successfully
    ...                transitioned to RRC_CONNECTED state due to RAN Paging with repetition triggered due to DL user
    ...                plane data arrival from UPF
    ...                5G_PM_1893; 5G_RAN_USR_RRM_25409

    Wait For Next Full PM Interval
    Removal Restriction Modification Of MIB Cell Barred Status
    Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request With eDRX    ue_id=17
    Set Internal Traffic Type For Ue    ue=17    pdu=1
    Attach UE    ue_id=17
    Establish PDU Session    ue_id=17    pdu_id=1    gw_id=1
    Set Delay Paging For Ue    ue_id=17    pagingdelay=3s
    Wait For Release RRC Inactive Conditions Met
    Verify Traces For Successful Transition To RRC INACTIVE
    Start Data Traffic    ues=17    direction=dl    pdu=1    throughput=1mbps
    Verify Paging Repetition
    Verify RRC Setup Complete With eDRX Support
    Verify Traces For Successful Transition To RRC CONNECTED By MT Access
    Verify CNAI With Paging eDRX Information Extended And Hashed UE Index Values
    Verify Exact Value Of Latest Pm Counter

CB011041_B1_ALT_2_RedCap_RAN_Paging_DL_Data_UPF_Paging_Repetition_Strategy
    [Documentation]    This user scenario describes the gNB behaviour for UE in RRC_INACTIVE state that is successfully
    ...                transitioned to RRC_CONNECTED state due to RAN Paging with repetition triggered due to DL user
    ...                plane data arrival from UPF
    ...                5G_PM_1893; 5G_RAN_USR_RRM_25409

    Wait For Next Full PM Interval
    Removal Restriction Modification Of MIB Cell Barred Status
    Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request    ue_id=13    tac_id=788
    Set Internal Traffic Type For Ue    ue=13    pdu=1
    Attach UE    ue_id=13
    Establish PDU Session    ue_id=13    pdu_id=1    gw_id=2
    Set Delay Paging For Ue    ue_id=13    pagingdelay=3400
    Wait For Release RRC Inactive Conditions Met
    Verify Traces For Successful Transition To RRC INACTIVE
    Start Data Traffic    ues=13    direction=dl    pdu=1    throughput=1mbps
    Verify Paging Repetition
    Verify RedCap Messages
    Verify Traces For Successful Transition To RRC CONNECTED By MT Access
    Verify Exact Value Of Latest Pm Counter

CB011041_B2_RAN_Paging_DL_AMF_Signaling_Paging_Repetition_Strategy
    [Documentation]    This user scenario describes the gNB behaviour for UE in RRC_INACTIVE state that is successfully
    ...                transitioned to RRC_CONNECTED state due to RAN Paging with repetition triggered due to DL AMF signalling arrival.
    ...                5G_PM_1894;5G_RAN_USR_RRM_25414

    Wait For Next Full PM Interval
    Removal Restriction Modification Of MIB Cell Barred Status
    Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request    ue_id=1    tac_id=788
    Attach UE    ue_id=1
    Establish PDU Session    ue_id=1    pdu_id=1    gw_id=3
    Set Delay Paging For Ue    ue_id=1    pagingdelay=3400
    Wait For Release RRC Inactive Conditions Met
    Verify Traces For Successful Transition To RRC INACTIVE
    Modify PDU Session    ue_id=1    pdu_id=1    qos_to_add=3    pass_regexp=Added QosFlow with QFI:2 5QI:6
    Verify Paging Repetition
    Verify Traces For Successful Transition To RRC CONNECTED By MT Access
    Verify Exact Value Of Latest Pm Counter

