*** Settings ***
Force Tags    CONFIGURED   CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_[MP][MP]_AP_[LOOO]

Documentation   :copyright: Nokia
...             :authors: Magdalena Rakiej
...             :contact: magdalena.rakiej@nokia.com

Resource            ../resources/feature_keywords.robot
Resource            ../../resources/testing_env.robot
Resource            ../../keywords/traffic.robot
Library             testsuite/Wroclaw/RRM/resources/scout_report.py

Library             ta5g_pm_counters
Library             ../resources/multignb_variables.py
Library             ../resources/KeywordsCB008490.py
Library             ../resources/syslog_collector.py
Variables           ../resources/custom_policy.py
Variables           ../resources/feature_variables.py

Suite Setup        Run Keywords
...                Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}
...    AND         Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}    remote_host=${REMOTE_HOST_1_IP}
...    AND         Enable C-Plane Debug Logs       with_reboot=${false}
...    AND         Update And Put Iphy Xml         input_filepath=${IPHY}
...    AND         Find Scfc And Fix And Send Full Commissioning
...                scfc_filename=${SCFC_GNB_SN}
...                remote_host=${REMOTE_HOST_1_IP}
...    AND         Find Scfc And Fix And Send Full Commissioning
...                scfc_filename=${SCFC_GNB_MN}
...    AND         With Simulator Configuration    config=${cfg}    remote_hosts=${REMOTE_HOSTS}

Test Setup         Run Keywords
...                  Enable Tshark Verification
...    AND           Setup multigNB devices aliases
...    AND           Start Collecting Syslog From Gnbs

*** Variables ***
${LOGGING_POLICY}=          BASIC_POLICY
${SCFC_GNB_MN}=             MN_real_scfc_LC.xml
${SCFC_GNB_SN}=             SN_real_scfc_LC.xml
${IPHY}=                    ${CURDIR}/config/iphy_MN_AEQE_SN_AWEUB_8CC.xml
${cfg}=                     ${CURDIR}/config/cfg_n77A_n257M_8CC_MN_SN_real.cfg
${ue_id}=                   1
${amf_id}=                  1
${pdu_id}=                  1
@{FAULT_IDS_LIST}=           6450    4383

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

    Attach UE1 And Establish PDU Session On GNB2 With 2 Qos Flow/s
    Send Command To Not Send SNodeModificationConfirm Message
    Set expected message flow for A4 meas based inter-gNB PSCell Addition on SN side For UE1 GNB3
    Wait 2s For Measurement To Configure
    UE1 sends A4 measurement ID eq 1 for inter-gNB NR-DC PSCell ID eq 52 addition
    Wait 2s For NRDC To Establish
    Verify expected message flow for A4 meas based inter-gNB PSCell Addition on SN side For UE1 GNB3
    Verify XNAP Snode Release Required
#    Verify PM counters on MN gNB and SN gNB sides

    [Teardown]     Run Keywords
     ...           Deregister UE    ue_id=${ue_id}
     ...    AND    Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}
     ...    AND    Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}    remote_host=${REMOTE_HOST_1_IP}
     ...    AND    Add Scout Scf Id To Test Data

*** Keywords ***
Attach UE${ue_id:\d+} And Establish PDU Session On GNB${gnb_id:\d+} With 2 Qos Flow/s
    ta5g_ue_mobility.attach_ue    ue_id=${ue_id}    enb=${gnb_id}    cell=1
    Set Internal Traffic Type To UE    ue_id=${ue_id}    pdu_id=1
    Establish Pdu Session        ue_id=${ue_id}    timeout=30
    Trigger PDU Session Modify Procedure For UE${ue_id} and QoS Flow ID eq 2

Trigger PDU Session Modify Procedure For UE${ue_id:\d+} and QoS Flow ID eq ${qosflows:\d+}
    Execute Egate Command And Wait For Data
    ...     cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qosflows}
    ...     pass_regexp=message c1 : rrcReconfigurationComplete

UE${ue_id:\d+} sends A4 measurement ID eq ${meas_id:\d+} for inter-gNB NR-DC PSCell ID eq ${phycell_id:\d+} addition
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} phycell_id=${phycell_id} nrsrp_nr=60 report_type=event_triggered event=A4
    ...    pass_regexp=SCellIndex 3 activated successfully at airphone

Verify XNAP Snode Release Required
    Verify Tcpdump Log       ${XNAP_SNODE_RELEASE_REQUIRED}     pcap_file_path=/home/ute/test_logs/tshark/gnb_F1_E1_RRC.pcap

#Verify PM counters on MN gNB and SN gNB sides
#    ${pm_counter_file_after_test_MN}=     Get Next Unpacked Raw Pm Counters File
#    Verify Any Counters In File
#    ...    M55116C00031   2    NRDC_FLOW_SN_INIT_TKBCK     #PCell on MN gNB side
#    ...    M55116C00034   2    NRDC_FLOW_SN_INIT_TKBC_A    #PCell on MN gNB side
#    ...    M55116C00056   1    IE_NRDC_MN_CU_REL_REQD      #PCell on MN gNB side
#    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-2/NRCELL-1   #MN gNB side
#    ...    file_path=${pm_counter_file_after_test_MN}
#    ...    report_pm_counter=True
#    Wait For Next Full Pm Interval   ${REMOTE_HOST_1_IP}   #on SN-gNB side
#    ${pm_counter_file_after_test_SN}=     Get Next Unpacked Raw Pm Counters File      remote_host=${REMOTE_HOST_1_IP}
#    Verify Any Counters In File                            #def get_next_unpacked_full_pm_counters_file(output_dirpath=None, remote_host=None)
#    ...    M55116C00058   2    NRDC_FLOW_SN_INIT_TKB_SN    #PSCell on SN gNB side
#    ...    local_moid=PLMN-PLMN/MRBTS-3/NRBTS-3/NRCELL-2   #SN gNB side
#    ...    file_path=${pm_counter_file_after_test_SN}
#    ...    report_pm_counter=True
