*** Settings ***
Force Tags    CLOUD_5G_I_[MP][MP]_AP_[LOOO]
...           NoResUsage

Documentation   :copyright: Nokia
...             :authors: Magdalena Rakiej, Katarzyna Wisniewska
...             :contact: magdalena.rakiej@nokia.com, katarzyna.wisniewska@nokia.com
...             :topology: CLOUD_5G_I_[MP][MP]_AP_[LOOO]
...             :variant: custom configs

Resource     ../CB008490_Keywords_And_Variables.robot

Suite Setup        Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs    remote_host=${REMOTE_HOST_1_IP}
...                AND             Get Iphy Xml File    output_filepath=${OUTPUT_DIR}/iphy.xml
...                AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/SN_initial_commissioning.xml    remote_host=${REMOTE_HOST_1_IP}
...                AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/MN_initial_commissioning.xml
...                AND             Update And Put Iphy Xml         input_filepath=${IPHY}
...                AND             Find Scfc And Fix And Send Full Commissioning
...                                scfc_filename=${SCFC_GNB_SN}
...                                remote_host=${REMOTE_HOST_1_IP}
...                AND             Find Scfc And Fix And Send Full Commissioning
...                                scfc_filename=${SCFC_GNB_MN}
...                AND             Reach Onair    lua_cfg=${cfg}    remote_hosts=${REMOTE_HOSTS}
...                AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown     Run Keywords    Update And Put Iphy Xml         input_filepath=${OUTPUT_DIR}/iphy.xml
...                AND             Send Full Commissioning
...                                input_filepath=${OUTPUT_DIR}/SN_initial_commissioning.xml   remote_host=${REMOTE_HOST_1_IP}
...                AND             Send Full Commissioning    input_filepath=${OUTPUT_DIR}/MN_initial_commissioning.xml
...                AND             Wait For Testline Icmp Echo Replies And Ssh Services
...                AND             Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${SCFC_GNB_MN}=             MN_real_scfc_LC.xml
${SCFC_GNB_SN}=             SN_real_scfc_LC.xml
${IPHY}=                    ${CURDIR}/config/iphy_MN_AEQE_SN_AWEUB_8CC.xml
${cfg}=                     ${CURDIR}/config/cfg_n77A_n257M_8CC_MN_SN_real.cfg
${ue_id}=                   1
${amf_id}=                  1
${pdu_id}=                  1

*** Test Cases ***
CB008490-LC_B1_XnAP_SNodeModification_Procedure_Counters_On_MN_And_SN_Side_Exception2
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...    This scenario measures SN initiated S-Node Modification procedure;
    ...    this procedure is used by Secondary Node to modify the SCG configuration
    ...    of the UE. An Operator should be able to inspect the number of sent the
    ...    unsuccessful XnAP:SNodeModification procedure.
    ...    2.Test Case Steps:
    ...         a. SA UE1 attach to CELL, setup and modify PDU session.
    ...         b. Send A4 measurement to trigger PSCell Addition.
    ...         c. Do not send XNAPSnodeModificationConfirm
    ...         d. Verify XNAP:SNodeReleaseRequired with cause tXnDCoverall-expiry
    ...    3. Expected Results:
    ...         a. XnAP:SNodeModificationConfirm is not received by SN gNB-CU-CP
    ...         b. NRBTS/timerXnDcOverall expires
    ...         c. There are some legacy and new counters
    ...    4. Verify counters:
    ...         a. on MN gNB side at the PCell:  NRDC_FLOW_SN_INIT_TKBCK, NRDC_FLOW_SN_INIT_TKBC_A and IE_NRDC_MN_CU_REL_REQD
    ...         b. on SN gNB side at the PSCell: NRDC_FLOW_SN_INIT_TKB_SN
    ...    Message XnAP SNode Modification Confirm should appear only once, just after SNodeReleaseRequired.

    [Setup]    Start Default Logging And Mark New Test    remote_host=${REMOTE_HOST_1_IP}    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        test_name=${TEST_NAME}

    Attach UE1 And Establish PDU Session On GNB2 With 2 Qos Flow/s
    Send Command To Not Send SNodeModificationConfirm Message
    UE1 sends A4 measurement ID eq 1 for inter-gNB NR-DC PSCell ID eq 52 addition
    Verify PM counters on MN gNB and SN gNB sides
    Verify Tcpdump Log    packet_filter=${E1AP_BEARER_CONTEXT_SETUP_REQUEST}
    Verify Tcpdump Log    packet_filter=${E1AP_BEARER_CONTEXT_SETUP_RESPONSE}
    Verify Tcpdump Log    packet_filter=${E1AP_BEARER_CONTEXT_MODIFICATION_REQUEST}    number_of_messages=7    relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${E1AP_BEARER_CONTEXT_MODIFICATION_RESPONSE}    number_of_messages=7    relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_SETUP_REQUEST}
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_SETUP_RESPONSE}
    Verify Tcpdump Log    packet_filter=${XNAP_SNODE_ADDITION_REQUEST}
    Verify Tcpdump Log    packet_filter=${XNAP_SNODE_ADDITION_REQUEST_ACKNOWLEDGE}
    Verify Tcpdump Log    packet_filter=${XNAP_XNU_ADDRESS_INDICATION}
    Verify Tcpdump Log    packet_filter=${XNAP_SNODE_RELEASE_REQUIRED}
    Verify Tcpdump Log    packet_filter=${XNAP_SNODE_MODIFICATION_CONFIRM}        relation_symbol= <=

   [Teardown]    Run Keywords       Deregister UE    ue_id=${ue_id}
    ...          AND                Add Scout Scf Id To Test Data
    ...          AND                Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Keywords ***
Verify PM counters on MN gNB and SN gNB sides
    Wait For Next Full Pm Interval Classical
    ${output_MN}=     Set Variable  ${OUTPUT_DIR}/${TEST_NAME}/pmlogs/MN
    ${output_SN}=     Set Variable  ${OUTPUT_DIR}/${TEST_NAME}/pmlogs/SN
    Get All Unpacked Full PM Counters Files Classical    output_dirpath=${output_MN}
    Get All Unpacked Full PM Counters Files Classical    output_dirpath=${output_SN}    remote_host=${REMOTE_HOST_1_IP}
    Verify Any Counters In All Files
    ...    M55116C00031   2    NRDC_FLOW_SN_INIT_TKBCK     #PCell on MN gNB side
    ...    M55116C00034   2    NRDC_FLOW_SN_INIT_TKBC_A    #PCell on MN gNB side
    ...    M55116C00056   1    IE_NRDC_MN_CU_REL_REQD      #PCell on MN gNB side
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-2/NRCELL-1   #MN gNB side
    ...    files_path=${output_MN}
    ...    report_pm_counter=True
    Verify Any Counters In All Files
    ...    M55116C00058   2    NRDC_FLOW_SN_INIT_TKB_SN    #PSCell on SN gNB side
    ...    local_moid=PLMN-PLMN/MRBTS-3/NRBTS-3/NRCELL-2   #SN gNB side
    ...    files_path=${output_SN}
    ...    report_pm_counter=True

