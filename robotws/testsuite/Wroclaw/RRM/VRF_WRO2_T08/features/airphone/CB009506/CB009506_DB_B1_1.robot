*** Settings ***
Force Tags    RAN_5G    RAN_5G_FDD    PY310    CONFIGURED    CLOUD_5G_I_LO_AP_LO
...           SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE    SBTS00    SBTS23R4    NoResUsage    RF50

Documentation    :copyright: Nokia
...              :authors: Bartosz Wlodowski, Piotr Bartkowski
...              :contact: bartosz.wlodowski@nokia.com piotr.bartkowski@nokia.com

Resource    CB009506_Keywords_And_Variables.robot
Library     ta5g_ue_measurements
Library     ta5g_pm_counters

Suite Setup      Run Keywords    Backup Scf Send Delta and Reset Testline
...              AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}
...              AND             Start Multiple Vm Ethernet Interfaces With Different Ips
...                              if_name_with_ip_list=[eth3:gNB3_NG, 10.0.1.30/24], [eth3:gNB3_XN, 10.44.76.28/24],
...              AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_CB009506_DB_B1_1.lua

Suite Teardown   Run Keywords    Roll Delta Back
...                              initial_scf_filename=${CURDIR}/config/backup/initial_commissioning.xml
...                              delta_scf_filename=delta_CB009506_DB_B1_1.json
...              AND             Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${DEFAULT_XN_S1_ALIAS}=     default_s1_x2

*** Test Cases ***
CB009506_DB_B1_New_Security_Policy_In_Bearer_Context_Modify_Request
    Wait For Next Full Pm Interval
    Attach Ue    ue_id=1

    Configure SMF To Include Preferred Security Indication Ie
    Start Traffic On Registered Ue
    Trigger Xn Handover From Real Gnb To Simulated Gnb

    Configure SMF To Include Required Security Indication Ie
    Establish Pdu Session With Traffic     ue_id=1    pdu_id=2    nwslice=1    gw_id=2    direction=both    throughput=1mbps
    Trigger Xn Handover From Simulated Gnb To Real Gnb

    Verify That RRC Reconfiguration To Ue Contains Correct Radio Bearer Config Ie

    Verify That NGAP Path Switch Request And Acknowledge To Gnb-2 Contains Correct Security Indication Ie
    Verify Traffic After Xn Ho
    Verify Pm Counters Values
    Deregister Ue    ue_id=1
    Add Scout External Execution ID To Reporting Portal

*** Keywords ***
Start Traffic On Registered Ue
    Establish Pdu Session With Traffic    ue_id=1    pdu_id=1    nwslice=1    gw_id=1    direction=both    throughput=1mbps
    Wait For Throughput
    Expected Throughput For Ue Should Be Reached    ue_id=1    throughput=1
    ...    direction=ul    selection_type=average    retry=10    layer=physical    margin=0.15
    Expected Throughput For Ue Should Be Reached    ue_id=1    throughput=1
    ...    direction=dl    selection_type=average    retry=10    layer=physical    margin=0.15

Verify Traffic After Xn Ho
    Wait For Throughput
    Expected Throughput For Ue Should Be Reached    ue_id=1    throughput=2
    ...    direction=ul    selection_type=average    retry=10    layer=physical    margin=0.15
    Expected Throughput For Ue Should Be Reached    ue_id=1    throughput=2
    ...    direction=dl    selection_type=average    retry=10    layer=physical    margin=0.15

Verify Pm Counters Values
    Wait For Next Full Pm Interval
    ${PM_COUNTER_FILE}=    Get Latest Unpacked Full Pm Counters File
    Verify Pm Counters Values For Req Send    pm_counter_file=${PM_COUNTER_FILE}
    Verify Pm Counters Values For Req Recd    pm_counter_file=${PM_COUNTER_FILE}

Verify Pm Counters Values For Req Send
    [Arguments]    ${pm_counter_file}
    Verify Any Counters In File
    ...    M55135C00505    +7    NE1CS_CTXT_MOD_REQ_SENT
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
    ...    file_path=${pm_counter_file}
    ...    report_pm_counter=True

Verify Pm Counters Values For Req Recd
    [Arguments]    ${pm_counter_file}
    Verify Any Counters In File
    ...    M55133C01004    +7    NE1US_CTXT_MOD_REQ_RECD
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCUUP-1
    ...    file_path=${pm_counter_file}
    ...    report_pm_counter=True


Trigger Xn Handover From Real Gnb To Simulated Gnb
    Perform Action And Wait For Given Tshark Message Number
    ...    alias=${DEFAULT_XN_S1_ALIAS}
    ...    packet_filter=(xnap.XnAP_PDU == 1) && (xnap.procedureCode == 0)
    ...    action=Trigger Xn Handover    ue_id=1    meas_id=2    phycell_id=54

Trigger Xn Handover From Simulated Gnb To Real Gnb
    Perform Action And Wait For Given Tshark Message Number
    ...    alias=${DEFAULT_XN_S1_ALIAS}
    ...    packet_filter=(xnap.XnAP_PDU == 1) && (xnap.procedureCode == 0)
    ...    action=Trigger Xn Handover    ue_id=1    meas_id=3    phycell_id=52

Trigger Xn Handover
    [Arguments]      ${ue_id}    ${meas_id}    ${phycell_id}
    Execute Egate Command    cmd=ue_meas_cfg_disp id=${ue_id}
    Execute Egate Command    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A5 srsrp_nr=18 phycell_id=${phycell_id} nrsrp_nr=100

Configure SMF To Include Required Security Indication Ie
    Execute Egate Command    cmd=smf_param id=1 security_indication=pdu_session_setup,path_switch:required:required max_data_rate=5mbps

Configure SMF To Include Preferred Security Indication Ie
    Execute Egate Command    cmd=smf_param id=1 security_indication=pdu_session_setup,path_switch:preferred:preferred max_data_rate=5mbps

Verify That NGAP Path Switch Request And Acknowledge To Gnb-2 Contains Correct Security Indication Ie
	Verify Tshark For At Least Given Number Of Messages
	...     alias=${DEFAULT_XN_S1_ALIAS}
	...     packet_filter=ngap.confidentialityProtectionIndication == 0 && ngap.NGAP_PDU == 1 && ip.dst == 10.0.1.2
	...     number_of_messages=1
	Verify Tshark For At Least Given Number Of Messages
	...     alias=${DEFAULT_XN_S1_ALIAS}
	...     packet_filter=ngap.confidentialityProtectionIndication == 1 && ngap.NGAP_PDU == 0 && ip.src == 10.0.1.2
	...     number_of_messages=1

Verify That RRC Reconfiguration To Ue Contains Correct Radio Bearer Config Ie
    Verify Tcpdump Log
    ...    packet_filter=nr-rrc.drb_ToAddModList == 1 && nr-rrc.drb_ToReleaseList == 1
    ...    number_of_messages=1
    Verify Tcpdump Log
    ...    packet_filter=nr-rrc.cipheringAlgorithm == 2 && nr-rrc.integrityProtAlgorithm == 2
    ...    number_of_messages=3

Backup Scf Send Delta and Reset Testline
    Get Scfc File    output_filepath=${CURDIR}/config/backup/initial_commissioning.xml
    Find Scfc And Send Delta Commissioning    scfc_filename=delta_CB009506_DB_B1_1.json
    Trigger Site Reset
    Check Radios Availability

