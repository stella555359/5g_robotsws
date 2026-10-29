*** Settings ***
Documentation    \\eseefsn50.emea.nsn-net.net\rotta4internal\ATF\juvirtan
#Resource    ./CB008311_resource.robot
Resource    ./../CUDU_L2/common_setup_teardown.robot
Suite Setup       Run Keywords    Suite Setup Update GNB    #scf_file=${DELTA_FILE}    skip_reboot=${False}
...               AND    Suite Setup Copy WTS Config Files From QT
...               AND    Suite Setup Start WTS And Check OnAir
Suite Teardown    Common Suite Teardown    debug
Test Setup        Common Test Setup
Test Teardown     Run Keyword And Ignore Error    Common Test Teardown    debug
Force Tags    CLOUD_5G_I_BOO_AP_LOO
*** Variables ***
${SCF_PATH}    ${CURDIR}/config/SCF
@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}
*** Test Cases ***
CB008311_ET_A_B301_2CC_TF_SA_Verify_Buffer_based_one_shot_Scell_addition_with_blind_activated_with_PDU_session_established_during_UE_ICS
    [Documentation]
    ...    This user scenario describes that gNB activates DL buffer monitoring after the UE attaches to the cell in SA mode and a
    ...    PDU session with non-GBR DRB is established during the initial context setup. Sufficient DL non-GBR data volume is received
    ...    such that a DL buffer overflow triggers occurs at the gNB. The gNB configures CA to the UE.
    ...    Note: the buffer overflow notification is triggered by DL non-GBR status, the procedure is independent of UL traffic.
    ...    button:
    ...    NRBTS.actBufferBasedSCellAddition=oneShot_Dl_Fr1
    ...    Test Steps:
    ...    Step 1: UE attaches to the TDD cell.
    ...    Step 2: The gNB-CU sends a private unacknowledged F1AP message to the gNB-DU to activate DL data buffer monitoring.
    ...    Step 3: High DL non-GBR data rate starts (e.g. large file download), thus the DL buffer overflows and cannot
    ...        be drained by the serving cell
    ...    Step 4: The gNB-DU sends private unacknowledged F1AP message to the gNB-CU to inform the gNB-CU of the DL buffer
    ...        overflow condition. The gNB-DU stops DL data buffer monitoring.
    ...    Step 5: gNB configures FDD SCell to the UE.
    ...    Check point:
    ...    scell add: start DL TP.
    ...    DL: 70M: SCellIndex 1 activated successfully at airphone.
    ...    DL: 30M: SCellIndex 1 deactivated successfully at airphone.
    ${json_file}=    Change Delta XML File To Delta Json File    ${SCF_PATH}/delta_A_B301.xml
    Delta Commission With SCF File    ${json_file}
    Attach UE And Start Traffic    1    100    10    800

*** Keywords ***
Attach UE And Start Traffic
    [Arguments]    ${UE_ID}    ${activate_mbps}    ${deactivate_mbps}    ${max_dl_tp}
    SA 5G Attach    ue_id=${UE_ID}
    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
    SA 5G PDU Session Setup    ue_id=${UE_ID}
    # Check Scell activated
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue\=${UE_ID} pdu=1 dir=dl mbps\=${activate_mbps} trf_id=1
    ...    pass_regexp=SCellIndex 1 activated successfully at airphone    timeout=3minutes
    Run Keyword And Continue On Failure    Check RRC rrcReconfiguration Message    ${output}
    # Check Scell deactivated
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue\=${UE_ID} pdu=1 dir=dl mbps\=${deactivate_mbps} trf_id=1
    ...    pass_regexp=SCellIndex 1 deactivated successfully at airphone    timeout=3minutes
    # Check max DL TP
    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${max_dl_tp}    trf_id=1
    ${tp_syslog}=    Get Cell Throughput From Btslog    10s
    Check Cell Throughput Quality From Btslog    ${tp_syslog}    16385    dl    60
    Check Cell Throughput Quality From Btslog    ${tp_syslog}    16387    dl    360
    Check DTXNACK Rate From Ttitrace

Check RRC rrcReconfiguration Message
    [Arguments]    ${content}
    Create File    ${OUTPUT_DIR}/AB301/egate_console.log    ${content}
    A2A_Check_RRC_Log    ${CURDIR}/A2A/rrcReconfiguration/rrc_scell_add.ini    save_log_directory=${OUTPUT_DIR}/AB301/

Attach UE And Start Traffic For B_B102
    [Arguments]    ${UE_ID}    ${activate_mbps}    ${deactivate_mbps}    ${max_dl_tp}
    [documentation]
    ...    ue_measurement_send_nr id=1 meas_id=1 event=A1 srsrp_nr=95
    ...    ue_measurement_send_nr id=1 meas_id=1 event=A1 srsrp_nr=75
    SA 5G Attach    ue_id=${UE_ID}
    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
    SA 5G PDU Session Setup    ue_id=${UE_ID}
    # Check Scell activated
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue\=${UE_ID} pdu=1 dir=dl mbps\=${activate_mbps} trf_id=1
    ...    pass_regexp=SCellIndex 1 activated successfully at airphone    timeout=3minutes
    Check RRC rrcReconfiguration Message    ${output}
    # Check Scell deactivated
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue\=${UE_ID} pdu=1 dir=dl mbps\=${deactivate_mbps} trf_id=1
    ...    pass_regexp=SCellIndex 1 deactivated successfully at airphone    timeout=3minutes
    # Check max DL TP
    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${max_dl_tp}    trf_id=1
    ${tp_syslog}=    Get Cell Throughput From Btslog    10s
    Check Cell Throughput Quality From Btslog    ${tp_syslog}    16385    dl    60
    Check Cell Throughput Quality From Btslog    ${tp_syslog}    16387    dl    360
    Check DTXNACK Rate From Ttitrace
