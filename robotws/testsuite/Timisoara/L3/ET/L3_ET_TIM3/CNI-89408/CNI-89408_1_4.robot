*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO   VARIANT_SANSA_FS_CPRI_CMWV_FDD_TEMP   PY36    CONFIGURED
...           CRT    RAN_5G    SBTS00
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Alexandru Tancau, Denisa Gogu
...              :contact: alexandru.tancau@nokia.com, denisa.gogu@nokia.com

Resource     ../resources/5G_SW_WRO_Keywords.robot
Resource     CNI-89408_Keywords.robot

Suite Setup    Run Keywords    Setup Custom IPHY   iphy=${custom-iphy}
...            AND             Setup Custom SCF    scf=${custom-scf}
...            AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/suite_setup_logs/
...            AND             Start Default Simulated SANSA Interfaces
...            AND             Reach Onair DSS Configuration
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/suite_setup_logs/

Test Setup        Start Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
Test Teardown     Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Suite Teardown  Run Keywords     Perform Parameter Commissioning    parameter=lteNrDssMode    value=none    dist_name=MRBTS-1/NRBTS-1/NRCELL-2
...             AND              Stop Default Processes And Gather Logs And Compress Logs

*** Test Cases ***

CNI-89408_1_M55112C08002_Incremented_Due_To_UE_Not_Supporting_DSS_On_NSA_DSS_Cell
    [Documentation]    This test case describes counter SgNB ADDITION REQUEST REJECT
    ...                5G_PM_892
    ...                Test case checks:
    ...                - if counters SgNB ADDITION REQUEST REJECT is incremented properly
    ...                author:    Alexandru Tancau, Denisa Gogu
    ...                contact: alexandru.tancau@nokia.com, denisa.gogu@nokia.com
    Attach Ue To Enb And Start Gnb Addition   ue_id=11  target_cell=1  target_gnb=1
    Attach Ue To Enb And Start Gnb Addition   ue_id=12  target_cell=1  target_gnb=1
    Attach Ue To Enb And Start Gnb Addition   ue_id=13  target_cell=2  target_gnb=1
    Attach Ue To Enb And Start Gnb Addition   ue_id=14  target_cell=2  target_gnb=1
    Verify Tcpdump Log    packet_filter=${X2AP_SGNB_ADDITION_REQUEST_ACKNOWLEDGE}  number_of_messages=4
    Wait For Next Full Pm Interval
    Attach noneDSS NSA UE   ue_id=15  target_cell=1  target_gnb=1
    Attach noneDSS NSA UE   ue_id=16  target_cell=1  target_gnb=1
    Attach noneDSS NSA UE   ue_id=17  target_cell=2  target_gnb=1
    Attach noneDSS NSA UE   ue_id=18  target_cell=2  target_gnb=1
    Verify Tcpdump Log    packet_filter=${X2AP_SGNB_ADDITION_REQUEST_REJECT}  number_of_messages=4
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55112C08002     +2    X2_SGNB_ADD_REQ_REJ_DSS_SENT
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTERS}
    Verify Any Counters In File
    ...    M55112C08002     +2    X2_SGNB_ADD_REQ_REJ_DSS_SENT
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    file_path=${PM_COUNTERS}

CNI-89408_4_M55125C13026_Incremented_Due_To_UE_Not_Supporting_DSS_On_SA_DSS_Cell
    [Documentation]    This test case describes counter Initial Context Setup Failure
    ...                5G_PM_893
    ...                Test case checks:
    ...                - if counters NGAP: Initial Context Setup Failure is incremented properly
    ...                author:    Alexandru Tancau, Denisa Gogu
    ...                contact: alexandru.tancau@nokia.com, denisa.gogu@nokia.com
    Wait For Next Full Pm Interval
    Attach Multiple UEs    first_ue_id=1    last_ue_id=7
    Establish Pdu Session With Traffic   ue_id=1    pdu_id=1    gw_id=1     throughput=3mbps
    Establish Pdu Session With Traffic   ue_id=2    pdu_id=2    gw_id=2     throughput=3mbps
    Establish Pdu Session With Traffic   ue_id=3    pdu_id=3    gw_id=3     throughput=3mbps
    Establish Pdu Session    ue_id=4    pdu_id=4    gw_id=4  pass_regexp=Initial Context Setup Failure for UE
    Establish Pdu Session    ue_id=5    pdu_id=5    gw_id=5  pass_regexp=Initial Context Setup Failure for UE
    Establish Pdu Session    ue_id=6    pdu_id=6    gw_id=6  pass_regexp=Initial Context Setup Failure for UE
    Establish Pdu Session    ue_id=7    pdu_id=7    gw_id=7  pass_regexp=Initial Context Setup Failure for UE
    Verify Ngap Messages    packet_filter=${NGAP_INITIAL_CONTEX_SETUP_FAILURE}  number_of_messages=4
    Verify Ngap Messages    packet_filter=${NGAP_INITIAL_CONTEXT_SETUP_RESPONSE}  number_of_messages=3
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55125C13026     +2    NNGCC_CTXT_STP_FAIL_DSS_SENT
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTERS}
    Verify Any Counters In File
    ...    M55125C13026     +2    NNGCC_CTXT_STP_FAIL_DSS_SENT
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    file_path=${PM_COUNTERS}
    Deregister Ue Without Confirmation    ue_id=1-7
