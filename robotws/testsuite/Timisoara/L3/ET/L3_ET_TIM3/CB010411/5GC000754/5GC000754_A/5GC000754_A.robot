*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    SBTS00    SBTS23R1    CONFIGURED    CRT
...             RAN_5G_TDD    RAN_5G    PY36
...             NoResUsage

Documentation    :copyright: Nokia
...              :authors: Andrei Maria
...              :contact: andrei.maria@nokia.com

Resource      ../../../resourcesKRK/krk3_common/main_vran.robot
Resource      ../../../resourcesKRK/krk3_common/aic/aic_common_resources.robot
Library       ta5g_tshark
Library       ta5g_ue_mobility
Library       ute_tshark
Variables     ta5g_global_var
Library       ta5g_pm_counters
Library       ute_reporting_portal
Variables     ./configs/variables.py

Suite Setup       Testline Setup    wts=${CURDIR}/configs/basic_setup.cfg
Suite Teardown    Testline Teardown
Test Teardown     Test Case Teardown     pod_logs=yes    oam_logs=yes

*** Variables ***
${RADIO_RESOURCES_NOT_AVAILABLE}=    ngap.radioNetwork == 22
${NGAP_PDU_SESSION_RESOURCE_MODIFY_RESPONSE}=    ngap.PDUSessionResourceModifyResponse_element
${PDU_MOD_FAIL_RADIO_RESOURCES_NOT_AVAILABLE}=    ${RADIO_RESOURCES_NOT_AVAILABLE} && ${NGAP_PDU_SESSION_RESOURCE_MODIFY_RESPONSE}
${delta_set_collecting_counters_to_five_minutes}=
    ...    /home/ute/test_repository/testsuite/Wroclaw/RRM/5G_SW_WRO/resources/config/SBTS22R2/delta_set_collecting_counters_to_five_minutes.json
@{PM_OBJECTS_LIST_VCU}           NNGCC

@{IP_ADDR_EXAMPLE}    eth3:10.0.12.100/24    eth3:10.0.11.100/24
&{CONFIG_EXAMPLE}     ip_addr=${IP_ADDR_EXAMPLE}   delta_vdu=${DELTA_VDU}
${DELTA_VDU}     ${CURDIR}/configs/delta_vdu.json
#${DEFAULT_DELTA_VDU}     ${CURDIR}/configs/default_delta_vdu.json
${CU_SCF}     /home/ute/Downloads/scfc_cu.xml
${DU_SCF}     /home/ute/Downloads/scfc_du.xml

*** Test Cases ***
5GC000754_A_Corner_Case_PDU_Session_Modification_Failure_one_or_more_nonGBR_QoS_Flows_couldnt_be_admitted_in_gNB_CU
    [Documentation]   This is Optimized TC, and covers following legacy scenarios:
    ...               5GC000754_A
    ...               Requirement ID:    config=&{CONFIG_EXAMPLE}

    [Setup]       Test Case Setup    reach_on_air=yes    reboot_after_config=no
#    ...           AND              Set Counter Collecting Interval To Five Minutes
    [Teardown]    ta5g_ue_mobility.Deregister Ue Without Confirmation    ue_id=1

    Log to console     Start Test

    Upload delta vdu    ${DELTA_VDU}

    Start tcpdump on remote interface aic
    ...   alias=tshark_testcase_aic
    ...   log_filename_prefix=anypcap
    ...   log_dirpath=${OUTPUT DIR}
    Sleep    10s

    Execute egate command    cmd=set_pdu_param ue=1 pdu=1 trf_type=internal
    Execute egate command    cmd=set_pdu_param ue=1 pdu=2 trf_type=internal
    ta5g_ue_mobility.Attach UE    ue_id=1
    ta5g_ue_mobility.Establish PDU Session    pdu_id=1    gw_id=1
    ta5g_ue_mobility.Establish PDU Session    pdu_id=2    gw_id=2
#    ta5g_iperf_traffic.Start Traffic And Check If Average Throughput Is Reached    pdu_gw_id=1    margin=10%
    Start Internal SA Downlink Traffic    ue_id=1    tput=1mbps    pdu_id=1
    Start Internal SA Uplink Traffic      ue_id=1    tput=1mbps    pdu_id=1
    Sleep     10s
    Verify SA UE Traffic Using Bearer Stats    ue_id=1     dl_tput=1mbps    ul_tput=1mbps
    Stop Internal SA Traffic    ue_id=1       pdu_id=1
#    ta5g_iperf_traffic.Stop All Traffics
    Execute Egate Command  cmd=send_hex source=amf:1 target=enb:2 hex=${HEX_SOURCE}
    Sleep   20s
    Verify tshark
    ...     alias=tshark_testcase_aic
    ...     packet_filter=${PDU_MOD_FAIL_RADIO_RESOURCES_NOT_AVAILABLE}
    ...     pass_criteria= >=1
    ...     pcap_file_path=${OUTPUT DIR}/anypcap.pcap
    Sleep   10
    Stop tcpdump on remote interface

#    Wait for Next vRAN PM Counters Interval    vcu_pm_objects_list=@{PM_OBJECTS_LIST_VCU}    timeout=3600

    ${dirpath}  Set Variable   ${OUTPUT DIR}/Logs/${TEST NAME}/
    Create Directory    ${dirpath}/vcu
    Create Directory    ${dirpath}/vdu
    &{pm_files_dict}    get_next_vran_unpacked_full_pm_counters_files    output_dirpath=${dirpath}     timeout=3600      expected_interval=5

    verify last counters in file
    ...  M55125C03503   1    NNGCC_PDUSESMODRSP_FAIL_SENT
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...  file_path=${pm_files_dict.vcu}
    ...  measurement_type=NNGCC

    Report pm counter    id=M55125C03503    value=1    result=Passed
#
#    Upload delta vdu    ${DEFAULT_DELTA_VDU}

*** Keywords ***
# Counters
Set Counter Collecting Interval To Five Minutes
    [Documentation]    Changes the interval for PM Counters to be collected.
    Upload delta vdu       ${delta_set_collecting_counters_to_five_minutes}
