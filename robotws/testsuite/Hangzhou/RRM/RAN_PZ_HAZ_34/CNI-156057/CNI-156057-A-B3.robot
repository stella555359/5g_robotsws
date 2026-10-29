*** Settings ***
Documentation
...    author: Zhang Yin
...    contact: yin.zhang@nokia-sbell.com
...    squal group: SG03
...    feature: CNI-156057

Force Tags    CA_5G_RRM    tl-7_5_UTE5G402T2405    release-SBTS26R2
Suite Setup    Suite Setup

Suite Teardown     robot_common_operations.Common Suite Teardown
Test Setup    Case Setup
Test Teardown    Case Teardown

Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CNI-156057/Resources/CNI156057_common_keywords.robot


*** Variables ***
${ue_type_qcom}    ${tl.ues[2].capabilities[0]}
${home}    82
${DEBUG}    False

*** Test Cases ***
[1]CNI-156057-A#B3_006_PDU_Session_Resource_Modify_with_RAC_Rejection_redirect_to_LTE
    adjust_pa_all_ports_max_value
    adjust_pa_for_cell    cell_id=21    value=0
    power_ue.Prepare UE    ue_type=${ue_type_qcom}    ue_index=${2}

    log to console    case:CNI-156057_A#B3_006_PDU_Session_Resource_Modify_with_RAC_Rejection_redirect_to_LTE
    AB3_006 Prerequisite
    UE2 Attach
    adjust_pa_for_cell    cell_id=33    value=0
    UE2 Make Emergency Call
    UE2 Hangup Emergency Call
    AB3_006 Check EC fallback to LTE Successfully from wirewhark
    UE2 Detach

    log to console    case:CNI-156057_A#B3_007_PDU_Session_Resource_Modify_with_RAC_Rejection_B1measurement_to_LTE
    AB3_007 Prerequisite
    UE2 Attach
    adjust_pa_for_cell    cell_id=33    value=0
    UE2 Make Emergency Call
    UE2 Hangup Emergency Call
    AB3_007 Check EC fallback to LTE Successfully from wirewhark
    UE2 Detach

    log to console    case:CNI-156057_A#B3_009_PDU_Session_Resource_Modify_with_online_modify_actIgnoreAmfVoiceEpsFbEc
    AB3_009 Prerequisite
    UE2 Attach
    Online Disable CNI156057
    adjust_pa_for_cell    cell_id=33    value=0
    UE2 Make Emergency Call    # EC fallback failed, but EC performed in LTE successfully
    UE2 Hangup Emergency Call
    AB3_009 Check EC fallback failed
    UE2 Detach

*** Keywords ***
AB3_006 Prerequisite
    Start capture gNB log on master    filename=wireshark_ab3_006.pcap
    Online modify parmeters     parameters_to_update=${PARAMS_156057_AB3_006}    skip_parameter_relation_errors=False
    COAM Wait for gnb ready and cell setup
    adjust_pa_for_cell    cell_id=33    value=127

AB3_007 Prerequisite
    Start capture gNB log on master    filename=wireshark_ab3_007.pcap
    Online modify parmeters     parameters_to_update=${PARAMS_156057_AB3_007}    skip_parameter_relation_errors=False
    adjust_pa_for_cell    cell_id=33    value=127

AB3_009 Prerequisite
    Start capture gNB log on master    filename=wireshark_ab3_009.pcap
    Online modify parmeters     parameters_to_update=${PARAMS_156057_AB3_009}    skip_parameter_relation_errors=False
    adjust_pa_for_cell    cell_id=33    value=127

Online Disable CNI156057
    Online modify parmeters     parameters_to_update=${PARAMS_156057_DISABLED}    skip_parameter_relation_errors=False

UE2 Attach
    Check UE device exist    ue_index=${2}
    Attach and check power UE    ue_type=${ue_type_qcom}    ue_index=${2}

UE2 Make Emergency Call
    make emc voice call with 911    ue_index=${2}    home_button=${home}
    sleep    10s

UE2 Hangup Emergency Call
    hang up emc voice call    ue_index=${2}

UE2 Detach
    power_ue.UE Detach    ue_type=${ue_type_qcom}     ue_index=${2}

check EC fallback to LTE from wireshark
    [Arguments]    ${wireshark_file_under_check}
    log   AMF receive NGAP: PDU Session Resource Modify Response with 'ims-voice-eps-fallback-or-rat-fallback-triggered'
    check_wireshark_fields    pcap_file=${wireshark_file_under_check}
    ...                       filter=(ngap.procedureCode == 26) && (ngap.radioNetwork == 36)
    ...                       check_fields=cause/radioNetwork=ims-voice-eps-fallback-or-rat-fallback-triggered
    ...                       packet_num=-1

    log    gNB-CU-CP sends F1AP: DLRRCMessageTransfer for RRCRelease with redirection to gNB-DU
    log    ....gNB-DU sends RRCRelease with redirectedCarrierInfo to UE
    Run Keyword And Continue On Failure    check_wireshark_fields
    ...                       pcap_file=${wireshark_file_under_check}
    ...                       filter=((f1ap.procedureCode == 12) && (nr-rrc.redirectedCarrierInfo == 1))
    ...                       check_fields=rrcRelease/redirectedCarrierInfo/eutra/eutraFrequency=1025

    log    UE Redirected to LTE Cell
    Run Keyword And Continue On Failure    check_wireshark_fields
    ...                       pcap_file=${wireshark_file_under_check}
    ...                       filter=(s1ap.procedureCode == 13) && (nas-eps.nas_msg_esm_type == 0xc6)
    ...                       check_fields=NAS EPS session management messages=Activate dedicated EPS bearer context accept

    log    NGAP:UEContextReleaseComplete
    Run Keyword And Continue On Failure    check_wireshark_fields
    ...                       pcap_file=${wireshark_file_under_check}
    ...                       filter=(ngap.procedureCode == 41) && (ngap.id == 60)
    ...                       check_fields=PDUSessionResourceListCxtRelCpl=3 items

    log    E1AP:BearerContextReleaseComplete
    Run Keyword And Continue On Failure    check_wireshark_fields
    ...                       pcap_file=${wireshark_file_under_check}
    ...                       filter=e1ap.procedureCode == 11
    ...                       check_fields=BearerContextReleaseComplete/protocolIEs=[RE].*
    ...                       packet_num=-1

    log    F1AP:UEContextReleaseComplete
    Run Keyword And Continue On Failure    check_wireshark_fields
    ...                       pcap_file=${wireshark_file_under_check}
    ...                       filter=f1ap.procedureCode == 6
    ...                       check_fields=UEContextReleaseComplete/protocolIEs=[RE].*
    ...                       packet_num=-1

AB3_006 Check EC fallback to LTE Successfully from wirewhark
    Stop and download Logs on gNB on master    filename=wireshark_ab3_006.pcap
    check EC fallback to LTE from wireshark    ${epc_log_path}/wireshark_ab3_006.pcap

AB3_007 Check EC fallback to LTE Successfully from wirewhark
    Stop and download Logs on gNB on master    filename=wireshark_ab3_007.pcap
    check EC fallback to LTE from wireshark    ${epc_log_path}/wireshark_ab3_007.pcap
    log    B1 measurement config`uration and report
    Run Keyword And Continue On Failure    check_wireshark_fields
    ...                       pcap_file=${epc_log_path}/wireshark_ab3_007.pcap
    ...                       filter=(nr-rrc.criticalExtensions == 0) && (nr-rrc.eventId == 0)
    ...                       check_fields=measObjectEUTRA/carrierFreq=1025
    Run Keyword And Continue On Failure    check_wireshark_fields
    ...                       pcap_file=${epc_log_path}/wireshark_ab3_007.pcap
    ...                       filter=(nr-rrc.criticalExtensions == 0) && (nr-rrc.eutra_PhysCellId == 248)
    ...                       check_fields=MeasResultEUTRA/eutra-PhysCellId=248

AB3_009 Check EC fallback failed
    Stop and download Logs on gNB on master    filename=wireshark_ab3_009.pcap
    log    AMF receive NGAP: PDU Session Resource Modify Response with 'radio-resources-not-available'
    check_wireshark_fields    pcap_file=${epc_log_path}/wireshark_ab3_009.pcap
    ...                       filter=((ngap.procedureCode == 26)) && (ngap.radioNetwork == 22)
    ...                       check_fields=cause/radioNetwork=radio-resources-not-available
    ...                       packet_num=-1

    log    gNB-CU-CP sends F1AP:DLRRCMessageTransfer or UEContextReleaseCommand for RRCRelease without redirectedCarrierInfo to gNB-DU
    Run Keyword And Continue On Failure    check_wireshark_fields
    ...                       pcap_file=${epc_log_path}/wireshark_ab3_009.pcap
    ...                       filter=nr-rrc.c1 == 2
    ...                       check_fields=rrcRelease/redirectedCarrierInfo=not_existing
    ...                       packet_num=-1

    log    NGAP:UEContextReleaseComplete
    Run Keyword And Continue On Failure    check_wireshark_fields
    ...                       pcap_file=${epc_log_path}/wireshark_ab3_009.pcap
    ...                       filter=(ngap.procedureCode == 41) && (ngap.id == 60)
    ...                       check_fields=PDUSessionResourceListCxtRelCpl=3 items

    log    E1AP:BearerContextReleaseComplete
    Run Keyword And Continue On Failure    check_wireshark_fields
    ...                       pcap_file=${epc_log_path}/wireshark_ab3_009.pcap
    ...                       filter=e1ap.procedureCode == 11
    ...                       check_fields=BearerContextReleaseComplete/protocolIEs=[RE].*
    ...                       packet_num=-1

    log    F1AP:UEContextReleaseComplete
    Run Keyword And Continue On Failure    check_wireshark_fields
    ...                       pcap_file=${epc_log_path}/wireshark_ab3_009.pcap
    ...                       filter=f1ap.procedureCode == 6
    ...                       check_fields=UEContextReleaseComplete/protocolIEs=[RE].*
    ...                       packet_num=-1

Suite Setup
    Common Suite Setup for COAM
    Import Suite Variables
    Return From Keyword If    ${DEBUG}
    ${config_path}    Get Config Files Path
    Common Case TestLine Setup
    ...    is_commission=True    scf_path=${config_path}    golden_scf_name=SCFC_1_SANSA.xml
    ...    Is_Swconfig=True    swconfig_file=${config_path}/swconfig.txt

Case setup
    robot_common_operations.Common Case Setup    allowed_faults_ids=49
#    put btslog_ini file to ute
#    ...    server_ip=${appserver_addr}    server_username=${appserver_username}    server_password=${appserver_password}
#    ...    btslog_ini_path=/home/${appserver_username}/
#    Start capture syslog via btslog on ute
    Check UE device status with adb recover    ue_index=${2}

Case Teardown
    robot_common_operations.Common Case Teardown
#    Stop capture syslog via btslog on ute
    power_ue.UE Detach    ue_type=${ue_type_qcom}     ue_index=${2}
    Run keyword if    '${TEST STATUS}' == 'FAIL' and not ${DEBUG}    COAM Save snapshot
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
