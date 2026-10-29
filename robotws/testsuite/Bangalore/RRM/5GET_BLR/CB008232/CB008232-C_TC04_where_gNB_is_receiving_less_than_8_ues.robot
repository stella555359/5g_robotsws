*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO      OPTION_RELATED_ARTIFACTS_5G    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    CONFIGURED    AP_REG

Documentation    :copyright: Nokia
...              :authors: Nowami
...              :contact: nowami.muktapuram@nokia.com
...         The aim of the CB008232 covers this functional gap providing dedicated resources to priority access calls
...         discarding paging record according to received priorities. Additionally, priority access and emergency call
...         back prioritization are supported within CB008232.
...         CB008232 will also allow Multimedia Priority Service (MPS) RACH attempts to use bigger power ramp up step.
...         Another new functionality of CB008232 is related to UE redirection.
...         The scope of the feature is limited to FR1 TDD for UEs in SA mode.
...         This CB008232 allows Priority Access (PA) users obtain and maintain radio resources with priority, also during congestion.
...         This is realized by: Paging prioritization, Priority Access and Emergency Call back,
...         Recognition and handling of priority access RRC connections and QoS flow setups, and PRACH prioritization.
...         fraction of the large BWP bandwidth size.
...         In BLR 5G ET as part of this feature, we are owning/testing CB008232-C sub-feature.
...         5GC000937 - UE power saving: Dynamic bandwidth part adaptation for TDD FR1
...         Paging Priority is a functionality that allows the AMF to include an indication
...         in the NGAP: Paging message sent to gNB that the UE be paged with priority.
...         The decision by the AMF whether to include Paging Priority in the Paging message is based on the ARP value
...         in the message received from the SMF for an IP packet waiting to be delivered in the UPF.
...         If the ARP value is associated with select priority services (e.g. MPS), the AMF includes Paging Priority in the Paging message.
...         The mapping of ARP values to Paging Priority level (or levels) is configured by operator policy in the AMF and in NG-RAN.
...         When the gNB receives a NGAP: Paging message with Paging Priority (optional IE), it may handle this Paging with priority.
...         Paging records (PR) with a higher Paging Priority (lowest PrioLevel) are preferred over paging records
...         with a lower priority during assignment of resources for paging transmission over air interface.
...         Records without Paging Priority IE are handled at the end of the resource assignment procedure.

Resource         resources/CB008232_Keywords.robot
Resource         ../5GC000937/resources/5GC000937_Keywords.robot
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/WTS_Runner_BF_CA_HO_Keywords.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Resource         ../resources/robot/common_log_collection.robot
Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Library          OperatingSystem
Library          ../resources/python/avg_dl_data.py
Library          taf.analyzer.pdml     WITH NAME    taf_pdml_analyser
Library          taf.sw.scout    WITH NAME     scout

Suite Setup         Run keywords   Run Keyword and Ignore Error   Suite setup from scratch
...                 AND    Start Default Logging  output_dirpath=${LOG_PATH}
...                 AND    Perform SCF Delta Commissioning with Delta_Configuration_CB008232_Enabled_Both_Cells12_TMOconfig.json
...                 AND    Check and active the BTS l2ps DBG log    feature_flag=CB008232
...                 AND    gnb.Perform gNB reboot
...                 AND    sleep   350s
...                 AND    log to console   loading cfg file....
...                 AND    Configure UTE ETH3 IPs
...                 AND    Start WTS Using WTS_Runner   ${wts_cfg_file}
...                 AND    Check gNB Bulid

Suite Teardown      Run Keywords   Run Keyword and Ignore Error   Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging   output_dirpath=${LOG_PATH}
...                 AND     Run Keyword and Ignore Error    Get Snapshot
...                 AND     Run Keyword and Ignore Error    Get Sos Report
...                 AND     Run Keyword and Ignore Error    Stop Default Processes And Gather Logs And Compress Logs

Test Teardown       Link SCOUT SCF to Configuration ID for Reporting

*** Variables ***
${DELTA_FILE}          Delta_Configuration_CB008232_Enabled_Both_Cells12_TMOconfig.json
${wts_cfg_file}        ${CURDIR}/config/basic_setup_8232-4_TMOUS.cfg
#${wts_cfg_file}        /opt/iphy/latest/basic_setup.cfg
${WTS_DIR}             /opt/iphy/latest
&{WTS}                 Ip=127.0.0.1        Username=ute         Connection=Wts
${UE_ID}               1
${nwslice_ID}          1
${gw_ID}               1
${Pdu_session_ID}      1
${qfi_id}              1
${Q_O_ADD}             1
${RTP_COD}             1
${epc_log_path}        /tmp/
${start_ue_id}          21
${end_ue_id}            24
${Timeout_SA}          40
${disp_idle}           IDLE
${disp_active}         ACTIVE
${RD_PARAM}                SEPARATOR=${EMPTY}    0x590072=1;0x1003F=1;0x10040=1;0x10041=1;
${pagingprio1_value}        PagingPriority: priolevel1 (0)
${pagingprio2_value}        PagingPriority: priolevel2 (1)
${pagingprio3_value}        PagingPriority: priolevel3 (2)
${pagingprio4_value}        PagingPriority: priolevel4 (3)
${pagingprio5_value}        PagingPriority: priolevel5 (4)
${pagingprio6_value}        PagingPriority: priolevel6 (5)
${pagingprio7_value}        PagingPriority: priolevel7 (6)
${parameter}        PrioLevel1 ueid=23 ueid=24
${TMSIs}        1024,2048,3072,4096,5120,6144,7168,8192,9216,10240
@{NGAP_fiveg_tmsi}          1024    2048
@{F1AP_fiveg_s_tmsi_prio}        00:82:00:00:04:00   00:82:00:00:08:00
@{F1AP_fiveg_s_tmsi_NOprio}        00:82:00:00:0c:00   00:82:00:00:10:00
${NOpagingprio_value}        PagingPriority
@{syslog_paging_callback_list}     'Insert high priority paging record to callback list'   'Modify high priority paging record in callback list'
...     'Remove high priority paging record from callback list'
@{syslog_paging_records}     'Number of records: 8 nrCellId:'    'PdschPayloadTBSendReq with RRC Paging content has been sent'
#@{Paged_S_TMSI}     0x10   0x0c   0x08   0x04
@{Paged_S_TMSI}     0x10   0xc   0x8   0x4
@{Active_UEs}          21    22    23    24

*** Test Cases ***
[1][1.0] CB008232-C_TC04_where_gNB_is_receiving_less_than_8UEs_to_page_with_and_without_priority_when_all_Cells_are_enabled_for_PA
    set test variable   ${LOG_PATH}
    Configure TMSI Values for MultiUEs   ${TMSIs}
    log to console   UEs Registartion trigerring now...
    ${crnti_list}=   MultiUE Register should be Successful   ${start_ue_id}   ${end_ue_id}
    set test variable   ${crnti_list}
    MultiUE Trigger DL Traffic for SA   ${start_ue_id}   ${end_ue_id}   Traffic_rate=kbps   dl_rate=20   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger UL Traffic for SA   ${start_ue_id}   ${end_ue_id}  Traffic_rate=kbps   ul_rate=20   pdu_id=1   trf_id=1   qfi_id=1
    sleep  10s    reason=Data stability
    Validate DL Traffic For MultiUE for SA   ${start_ue_id}   ${end_ue_id}   dl_rate=0.020   pdu_id=1   qfi_id=1
    Validate UL Traffic For MultiUE for SA   ${start_ue_id}   ${end_ue_id}   ul_rate=0.020   pdu_id=1   qfi_id=1
    Stop MultiUE Data Traffic for SA    ${start_ue_id}   ${end_ue_id}
    sleep    10
    Move MultiUEs to RRC_Idle_State    ${start_ue_id}   ${end_ue_id}
    Start Collecting Syslog     NAME=gnb_paging
    MultiUE RRC_State_Display_Idle   ${start_ue_id}   ${end_ue_id}
    Start CPRT Trace Capturing
    Start L2 BIP Trace Capturing
    MultiUE Trigger AMF Paging       ${parameter}
    sleep   120
    Stop L1L2 capture  ${CaptureL1L2}
    Stop CPRT capture   ${CaptureCPRT}
    MultiUE RRC_State_Active     ${Active_UEs}
    Stop Collecting Syslog       NAME=gnb_paging
    Run Keyword And Ignore Error    Move File    ${LOG_PATH}/L1L2_GNB_FS_LO.pcap    ${LOG_PATH}/GNB_L1L2_BIP.pcap
    Run Keyword And Ignore Error    Move File    ${LOG_PATH}/NODECPRT_GNB.pcap   ${LOG_PATH}/GNB_CPRT.pcap
    Run Keyword And Ignore Error    Syslog should contain paging record in callback list    NAME=gnb_paging
    ...     paging_callback_list=${syslog_paging_callback_list}
    Run Keyword And Ignore Error    Syslog Validate paging records in PdschPayloadTBSendReq      NAME=gnb_paging
    ...     syslog_paging_records=${syslog_paging_records}
    FOR     ${fiveg_tmsi}      IN      @{NGAP_fiveg_tmsi}
        Verify NGAP PagingPriority for UE       ${LOG_PATH}/GNB_CPRT.pcap      ngap.fiveG_TMSI == ${fiveg_tmsi}     ${pagingprio1_value}
    END

    FOR     ${fiveg_S_tmsi}      IN      @{F1AP_fiveg_s_tmsi_prio}
        Verify F1AP PagingPriority for UE       ${LOG_PATH}/GNB_CPRT.pcap      f1ap.fiveG_S_TMSI == ${fiveg_S_tmsi}    ${pagingprio1_value}
    END

    FOR     ${fiveg_S_tmsi}      IN      @{F1AP_fiveg_s_tmsi_NOprio}
        Verify F1AP NO PagingPriority for UE       ${LOG_PATH}/GNB_CPRT.pcap      f1ap.fiveG_S_TMSI == ${fiveg_S_tmsi}    ${NOpagingprio_value}
    END
    MultiUE Deregister should be Successful   ${start_ue_id}   ${end_ue_id}

*** Keywords ***
MultiUE Trigger AMF Paging
    [Arguments]     ${parameter1}
    wtsrunner.ue_nr_rrc_setup_param    id=22   pagingdelay=300
    wtsrunner.ue_nr_rrc_setup_param    id=23   pagingdelay=600
    wtsrunner.ue_nr_rrc_setup_param    id=24   pagingdelay=900
    wtsrunner.amf_paging_param   id=1   default_drx=64
    wtsrunner.amf_paging_start   id=1   ueid=21-22  priority=${parameter1}
    ${output}       Wait Until Keyword Succeeds  1 min   2 sec   Get Paging-Message
    [Return]          ${output}

Get Paging-Message
    ${output}       wtsrunner.read_wtsemu_output_until_prompt   timeout=5
    Log to Console    ${output}
    ${status}    should contain    ${output}    pagingRecordList
    Log to Console    ${status}
    Run Keyword If    '${status}' == 'None'    Get Paged-S-TMSI

Get Paged-S-TMSI
    ${output1}      wtsrunner.read_wtsemu_output_until    expected=pagingRecordList    timeout=10
    Log to Console    ${output1}
    Validate Paged-S-TMSI    ${output1}
    [Return]          ${output1}

Validate Paged-S-TMSI
    [Arguments]     ${output1}
    FOR  ${i}    IN    @{Paged_S_TMSI}
         Log to Console    ${i}
        Should Contain   ${output1}    5G-S-TMSI = 0x0x8200:0x0:${i}
    END
