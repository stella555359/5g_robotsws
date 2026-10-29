*** Settings ***
Documentation
...   Author: shuangfeng.f.sun@nokia-sbell.com
...   Contact: shuangfeng.f.sun@nokia-sbell.com
...   Description: The user scenario related to AirPhone operation.


Suite Setup       Common Suite Setup For RRM
#Suite Teardown    Common Suite Teardown For RRM

Force Tags
...      CRT             #Tag Item
...      RAN_PZ_HAZ_1             #Competence Area
...      RAN_PZ_HAZ1_SG03_ST_RRM  #Organization
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]

Test Timeout    600 minutes

Resource          ../../Resources/Classical/RRM_Common_Resource.robot
Library             taf.sw.scout                                           WITH NAME    scout
#C:\robotws\testsuite\Hangzhou\RRM\RAN_PZ_HAZ_1\Resources\Common\python\tak_airphone\tak_airphone\interface.py
#C:\robotws\testsuite\Hangzhou\RRM\RAN_PZ_HAZ_1\Resources\Common\Airphone.robot
#Library          ../../Resources/Common/python/airphone.py
# CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
# tdd_sansa_cmwv_2cells_ecpri
*** Variables ***
@{pass_regexp_ANR}
#...    Adding QosFlow with QFI:2 5QI:1
#...    PDU Session Resource Modify Unsuccessful Transfer
...    Inter-eNB handover from EXT_ENB-2.2 to ENB-3.1 performed

@{pass_regexp_HO_CELL2_SIMCELL1}
...    Inter-eNB handover from EXT_ENB-2.* to ENB-3.* performed

${counter1}    M55125C00035

@{Setup_5QI1_Success}
...    Added QosFlow with QFI:2 fiveQI:1
...    QoS Routing Table
...    Unexpected XnAP: SNStatusTransfer in WAIT HANDOVER REQUEST

@{Add_5QI1_Success}
...    Added QosFlow with QFI:2 fiveQI:1
...    rrcReconfigurationComplete
...    QoS Routing Table

@{HO_Success}
...    Inter-eNB handover from EXT_ENB-2.* to ENB-3.1 performed
...    Setup QosFlow with QFI:1
...    PATH SWITCH REQUEST ACK

@{Add_5QI1_failed_and_HO_Success}
...    Adding QosFlow with QFI:* 5QI:1
...    PDU Session Resource Modify Unsuccessful Transfer
...    PDU SESSION RESOURCE MODIFY RESPONSE Modify Item with cause 33
...    Deleted Unsuccessful QosFlow QFI:2
...    @{HO_Success}

${SA_UE_VoNR_Capabilities}    SEPARATOR=
...    E1A00000074E5A031E000380A03C1260C80008780818806804C020301C032A36146B04050D012CB2898087AD8202020E1DE38720C3
...    8002064F1F570004F001C0013C002A36266B04050D012CB2898087AD8202020E1DE38720C38002064F1F570004F001C0013C002A36
...    26EB04050D012CB2898087AD8202020E1DE38720C38002064F1F570004F001C0013C002A36276B04050D012CB2898087AD8202020E
...    1DE38720C38002064F1F55000005000000108389A00000000404D0301C020227B058060005038080E0600B00E000D07C0000000000
...    001CA9A0002000012CB2A00695550103800580000002004008D58980008101820283038405880889098C909293139425389B40

${UE_Capabilities_with_ANR_VONR}    SEPARATOR=
...    E1A00000074E5A031E00038420007824C1900010F09003100D00980C0301C032A36146B04050D012CB28986801EB608080838778E1C830E000
...    8193C7D5C0013C0070004F000A8D899AC10143404B2CA261A007AD8202020E1DE38720C38002064F1F570004F001C0013C002A3626EB04050D
...    012CB28986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D89DAC10143404B2CA261A007AD8202020E1DE38720C380020
...    64F1F55000005000000108389A00000000404D1700007008089EC2E003E00281C1401C0C026007000683E0000000000000E54D000100000965
...    950034AAA85800E001600000008010023562600020406080A0C0E10162022242632424A4C4E5094E26D0

${UE_Capabilities_with_ANR_NoVoNR}    SEPARATOR=
...    E1A00000074E5A031E000380A03C1260C8000878180C4034026010180E01951B0A3582028680965944C043D6C10101070EF1C39061C0010327
...    8FAB80027800E0009E00151B133582028680965944C043D6C10101070EF1C39061C00103278FAB80027800E0009E00151B1375820286809659
...    44C043D6C10101070EF1C39061C00103278FAB80027800E0009E00151B13B582028680965944C043D6C10101070EF1C39061C00103278FAA80
...    00028000000841C4D00000000202682807008089EC1601B00140E0601C0C01601C001A0F8000000000000395340004000025965400D2AAA020
...    7000B000000040080118B130001020304050607080B101112131921252627284A0

@{RejectRequest_and_HOSuccess_DuringHOPrepare}
...    Received UE Context Modification Failure from GNB-2 with cause RAN xn handover triggered
...    Inter-eNB handover from EXT_ENB-2.* to ENB-3.1 performed
...    Setup QosFlow with QFI:1
...    PATH SWITCH REQUEST ACK
${nsetapx_plugin_addr}
...   https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/NSETAP_X/nsetapx-1.12.6/nsetapx-4.0-0.6.1-1.12.6+buster.so
${plugin_folder}   /usr/lib/x86_64-linux-gnu/wireshark/plugins
${tshark_path}      /usr/bin/tshark

*** Test Cases ***
CB012209_01_Prioritizing_Voice_Service_during_XN-HO_Preparation
    [Tags]    CRT    CB012209_01
    [Documentation]
    ...    Precondition:
    ...         real gnb-2: cell-1: TDD, pci: 50, ssbFrequency=633216
    ...                     cell-2: TDD, pci: 51, ssbFrequency=633408
    ...         sim gnb-3: cell-1: TDD, pci: 381, ssbFrequency=633408
    ...         location on cell1 (Enable VONR): UE 5,6,7,10,11
    ...         UE with VONR Capability:          UE 2,3,4,6,7
    [Setup]    Case Precondition
    Trigger Xn links is Up
    UE Attach    ue_id=7
    Reset Xn Handover Preparation Param
    Delay Response to Xn Handover Preparation
    Concurrent PDU Modification during HO Preparation Based Feature Enabled    ue_id=7
    sleep    10s
    Check PM Counters for CB012209_01
    [Teardown]    Case Postcondition

CB012209_ET_001_verify_Rejecting_request_setup_Voice_Service_during_ANR-PCI_resolution_phase
    [Tags]    CRT    CB012209_001
    [Documentation]
    ...    Precondition:
    ...          CELL2_UE22: ANR
    ...          CELL1_UE23: VONR
    ...          CELL2_UE24: VONR+ANR
    ...         real gnb-2: cell-1: TDD, pci: 50, ssbFrequency=633216
    ...                     cell-2: TDD, pci: 51, ssbFrequency=633408
    ...         sim gnb-3: cell-1: TDD, pci: 381, ssbFrequency=633408
    ...         location on cell2 (Enable VONR): UE 24
    ...         UE with VONR+ANR Capability:          UE 24
    ...         UEs Trigger Inter-gNB Intra-FreqANR HO And Inter-Freq HO.
    ...             d.1 UE24 Set PCI-ANR resolution time delay of 100ms to wait for pdu session modification to add 5QI1event.
    ...             d.2 UE24 trigger inter-gNB intra-freq HO from real gnb cell2 HO sim gnb cell1.
    [Setup]    Case Precondition
    Trigger Xn links is Up
    UE Attach    ue_id=24
    Trigger intraFreANR with the concurrency
    Check Counter for CB012209_001
    Intra fre Handover Return
    Delete NRREL
    Delete before PM counter file
    Trigger intraFreANR with the concurrency2    ue_id=24
    Check Counter for CB012209_001
    [Teardown]    Case Postcondition

CB012209_ET_002_Rejecting_the_request_to_setup_Voice_Service_during_XN-HO_Execution_Phase
    [Tags]    CRT    CB012209_002
    [Documentation]
    ...    Precondition:
    ...         real gnb-2: cell-1: TDD, pci: 50, ssbFrequency=633216
    ...                     cell-2: TDD, pci: 51, ssbFrequency=633408
    ...         sim gnb-3: cell-1: TDD, pci: 381, ssbFrequency=633408
    ...         location on cell1 (Enable VONR): UE 5,6,7,10,11
    ...         UE with VONR Capability:          UE 2,3,4,6,7
    ...         ho from gnb2.1 to simgnb 3.1
    [Setup]    Case Precondition
    Trigger Xn links is Up
    UE Attach    ue_id=7
    Concurrent PDU Modification during HO Execution Based Feature Enabled    ue_id=7
    Check PM Counters for CB012209_002
    [Teardown]    Case Postcondition

CB012209_03_Rejection_of_Voice_Service_during_XN-HO_Preparation
    [Tags]    CRT    CB012209_03
    [Documentation]
    ...    Precondition:
    ...         real gnb-2: cell-1: TDD, pci: 50, ssbFrequency=633216
    ...                     cell-2: TDD, pci: 51, ssbFrequency=633408
    ...         sim gnb-3: cell-1: TDD, pci: 381, ssbFrequency=633408
    ...         location on cell1 (Enable VONR): UE 5,6,7,10,11
    ...         UE not with VONR Capability:          UE 1,22
    [Setup]    Case Precondition
    Trigger Xn links is Up
    UE Attach    ue_id=1
    Reset Xn Handover Preparation Param
    Delay Response to Xn Handover Preparation
    Rejection of Voice Service during XN-HO Preparation    ue_id=1
    Check Counter for CB012209_03
    [Teardown]    Case Postcondition

CB012209_07_Monitoring_PCMD_content_related_to_CB012209_with_XnAPSourceHO_Record
    [Tags]    CRT    CB012209_07
    [Documentation]
    ...    Precondition:
    ...         real gnb-2: cell-1: TDD, pci: 50, ssbFrequency=633216
    ...                     cell-2: TDD, pci: 51, ssbFrequency=633408
    ...         sim gnb-3: cell-1: TDD, pci: 381, ssbFrequency=633408
    ...         location on cell1 (Enable VONR): UE 5,6,7,10,11
    ...         UE with VONR Capability:          UE 2,3,4,6,7
    [Setup]    Case Precondition CB012209_07
    Open DCAP
    Trigger Xn links is Up
    Download wireshark plugin
    Start Tcpdump Log
    UE Attach    ue_id=7
    Reset Xn Handover Preparation Param
    Delay Response to Xn Handover Preparation
    Concurrent PDU Modification during HO Preparation Based Feature and PCMD Enabled    ue_id=7
    sleep    10s
    Stop Tcpdump Log
    sleep    10s
    Check tcpdump log
    [Teardown]    Case Postcondition

*** Keywords ***
Case Precondition
    log to console    Case Precondition
    Common Test Setup For RRM
    Airphone Common Setup    local_wts_dir=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/TL_Airphone/config/wts.cfg
    ...                      iphy_path=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/TL_Airphone/config/iphy.xml
    ...                      scf_file_path=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/TL_Airphone/config/scf.xml
    Airphone Execute Egate Command    cmd=set_log flush
    Airphone Execute Egate Command    cmd=state_sim_disp
    Start Btslog Collect    names=btslog1

Case Precondition CB012209_07
    log to console    Case Precondition
    Common Test Setup For RRM
    Airphone Common Setup    local_wts_dir=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/TL_Airphone/config/wts.cfg
    ...                      iphy_path=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/TL_Airphone/config/iphy.xml
    ...                      scf_file_path=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/TL_Airphone/config/scf_07.xml
    Airphone Execute Egate Command    cmd=set_log flush
    Airphone Execute Egate Command    cmd=state_sim_disp
    Start Btslog Collect    names=btslog1

Case Postcondition
    log to console    Case Postcondition
    ${btslog_name1}    Stop Btslog Collect    names=btslog1
    Airphone Common Teardown
#    Run Keyword If Test Failed    Run Keyword And Ignore Error    Collect Coam Snapshot
    Run Keyword If Test Failed    Run Keyword And Ignore Error    Save Coam Snapshot
    ${DATE}=    Get Current Date    result_format=%Y%m%d_%H%M
    Wait Until Keyword Succeeds    3x    1min    COAM_Admin.Login    alias=SCF_backup
    Run Keyword And Ignore Error    COAM_Admin.BackupSCF    local_dir=${TEST_LOG_DIRECTORY}    file_name=SCF_${DATE}.xml
    ...    connection=SCF_backup
    Run Keyword And Ignore Error    COAM_Admin.Logout    connection=SCF_backup
    Get SCF Internal Id By Scout    no_ute=False

Prepare UE History Information
    Airphone Execute Egate Command    cmd=ue_change_location id=1-2 cell=1
    Airphone Execute Egate Command    cmd=ue_change_location id=3 cell=2
    Airphone Execute Egate Command    cmd=state_sim_disp
    Airphone Execute Egate Command    cmd=gnb_param id=3 xn_listening_socket=1 send_xn_setup=true measEvent=A3

Preconditions for UE HO Back
    Airphone Execute Egate Command    cmd=ue_reauth id=1 nr_sec_cap=aes|aes
    Airphone Execute Egate Command    cmd=amf_path_switch_param id=1 include_ue_sec_cap=on
    Airphone Execute Egate Command    cmd=smf_param id=1 security_indication=path_switch:preferred:preferred max_data_rate=20mbps

Trigger Xn links is Up
    [Arguments]    ${pass_regexp}=XnAP Link with GNB-2 .* is up
    sleep    120s
    ${cmd1}    Catenate    gnb_param id=3 xn_listening_socket=1 send_xn_setup=true sib1_period=160ms
    Airphone Execute Egate Command    cmd=${cmd1}
    ${cmd2}    Catenate    gnb_xn_link_up gnb=3 target=2
    Airphone Execute Egate Command    cmd=${cmd2}    pass_regexp=${pass_regexp}
    sleep    5s

Delay Response to Xn Handover Preparation
    Airphone Execute Egate Command    cmd=gnb_xn_handover_preparation_param id=3 action=delayed_rsp time_to_wait=v5s

Reset Xn Handover Preparation Param
    Airphone Execute Egate Command    cmd=gnb_xn_handover_preparation_param id=3 reset

UE Attach
    [Arguments]    ${ue_id}=7    ${pass_regexp}=QoS Routing Table
#    sleep    120s
    Airphone Execute Egate Command    cmd=ue_register id=${ue_id}
    sleep    5s
    Airphone Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    sleep    5s
    Airphone Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1    pass_regexp=${pass_regexp}
    sleep    1min

Trigger intraFreANR with the concurrency
    [Arguments]    ${ue_id}=24    ${target_cell}=381    ${action}=send_nas_pdu_session_modify

    ${CGI_cmd}    Catenate    ue_nr_rrc_reconf_param id=${ue_id} if_contains=report_cgi anr_cgi_delay=100ms
    ...                      action=${action} pduSessionInfo=1:24:1:1:1:0 qosflows_to_add=2
    Airphone Execute Egate Command    cmd=${CGI_cmd}
    ${HO_cmd}    Catenate  ue_measurement_send_nr id=${ue_id} meas_id=3 event=A3 srsrp_nr=5 srsrq_nr=5
    ...               phycell_id=${target_cell} nrsrp_nr=100 nrsrq_nr=100
     Airphone Execute Egate Command    cmd=${HO_cmd}
#     ...    timeout=120    pass_regexp=${pass_regexp_ANR}
    sleep    2min

Trigger intraFreANR with the concurrency2
    [Arguments]    ${ue_id}=24    ${target_cell}=381    ${action}=send_nas_pdu_session_modify

    ${CGI_cmd}    Catenate    ue_nr_rrc_reconf_param id=${ue_id} if_contains=report_cgi anr_cgi_delay=100ms
    ...                      action=${action} pduSessionInfo=1:24:1:1:1:0 qosflows_to_add=2
    Airphone Execute Egate Command    cmd=${CGI_cmd}
    ${HO_cmd}    Catenate  ue_measurement_send_nr id=${ue_id} meas_id=7 event=A3 srsrp_nr=5 srsrq_nr=5
    ...               phycell_id=${target_cell} nrsrp_nr=100 nrsrq_nr=100
     Airphone Execute Egate Command    cmd=${HO_cmd}
#     ...    timeout=120    pass_regexp=${pass_regexp_ANR}
    sleep    2min

UEs Trigger Inter-gNB Intra-FreqANR HO
    [Arguments]    ${ue_id1}=24
    Trigger Inter-gNB Intra-FreqANR HO Concurrency With PDU Session Mofication    ${ue_id1}

Trigger Inter-gNB Intra-FreqANR HO Concurrency With PDU Session Mofication
    [Arguments]    ${ue_id}=24    ${target_cell}=381    ${action}=send_nas_pdu_session_modify
    Set PCI-ANR resolution time delay    ${ue_id}    ${action}
    ${cmd1}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=7 event=A3 srsrp_nr=5 srsrq_nr=5
    ${cmd2}    Catenate   phycell_id=${target_cell} nrsrp_nr=100 nrsrq_nr=100
    ${HO_cmd}    Catenate    ${cmd1}    ${cmd2}
    Airphone Execute Egate Command    cmd=${HO_cmd}

Set PCI-ANR resolution time delay
    [Arguments]    ${ue_id}    ${action}=send_nas_pdu_session_modify
    ${cmd_action}=    Catenate    action=${action} pduSessionInfo=1:${ue_id}:1:1:1:0 qosflows_to_add=2
    Airphone Execute Egate Command    cmd=ue_nr_rrc_reconf_param id=${ue_id} if_contains=report_cgi anr_cgi_delay=500ms ${cmd_action}

Intra fre Handover Return
    [Arguments]    ${ue_id}=24
    Airphone Execute Egate Command    cmd=ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    ${ho_cmd}    Catenate    ue_measurement_send_nr id=24 meas_id=3 event=A3 srsrp_nr=11 phycell_id=51 nrsrp_nr=85
    Airphone Execute Egate Command    cmd=${ho_cmd}

Delete NRREL
    ${rm_ob_list}    Create List
    ${rm_ob_name}    Set Variable    MRBTS-1/NRBTS-1/NRCELL-2/NRREL-256
    Wait Until Keyword Succeeds    3m    1m    COAM_Admin.Login
    ${ret}    ${value}     Run Keyword And Ignore Error
    ...    coam.get_parameters   dist_name=MRBTS-1/NRBTS-1/NRCELL-2/NRREL-256
    ...    connection=COAM
    Run Keyword If   '${ret}'=='Fail'    Fail    NRREL-256 doesn't deleted
    coam_admin.perform_object_recommissioning    dist_name=${rm_ob_name}    parameter_delta_list=${rm_ob_list}
    ...    operation=delete    connection=COAM
    [Teardown]    COAM_Admin.Logout

Concurrent PDU Modification during HO Preparation Based Feature Enabled
    [Arguments]    ${ue_id}=7    ${A2_meas_id}=1   ${A3_meas_id}=5    ${pass_regexp}=Added QosFlow with QFI:2 fiveQI:1
    Airphone Execute Egate Command    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${A2_meas_id} event=A2 srsrp_nr=7 srsrq_nr=7
    ...    pass_regexp=rrcReconfigurationComplete
    sleep    5s
    ${ho_cmd}  Catenate  ue_measurement_send_nr id=${ue_id} meas_id=${A3_meas_id} event=A3 srsrp_nr=11 phycell_id=381 nrsrp_nr=85
    Airphone Execute Egate Command    cmd=${ho_cmd}
    Airphone Execute Egate Command    cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=2 by=amf
    ...    pass_regexp=${pass_regexp}
    sleep    5s
    Airphone Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=2 trf_id=1 mbps=5 dir=dl protocol=tcp
    sleep    5s
    #Airphone Execute Egate Command    cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=3 by=amf
    #sleep    5s
    #Airphone Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=3 trf_id=1 mbps=5 dir=dl
    #sleep    5s

Concurrent PDU Modification during HO Preparation Based Feature and PCMD Enabled
    [Arguments]    ${ue_id}=7    ${A2_meas_id}=1   ${A3_meas_id}=6    ${pass_regexp}=Added QosFlow with QFI:2 fiveQI:1
    Airphone Execute Egate Command    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${A2_meas_id} event=A2 srsrp_nr=7 srsrq_nr=7
    ...    pass_regexp=rrcReconfigurationComplete
    sleep    5s
    ${ho_cmd}  Catenate  ue_measurement_send_nr id=${ue_id} meas_id=${A3_meas_id} event=A3 srsrp_nr=11 phycell_id=381 nrsrp_nr=85
    Airphone Execute Egate Command    cmd=${ho_cmd}
    Airphone Execute Egate Command    cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=2 by=amf
    ...    pass_regexp=${pass_regexp}
    sleep    5s
    Airphone Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=2 trf_id=1 mbps=5 dir=dl protocol=tcp
    sleep    5s

Rejection of Voice Service during XN-HO Preparation
    [Arguments]    ${ue_id}=1    ${A2_meas_id}=1   ${A3_meas_id}=5
    Airphone Execute Egate Command    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${A2_meas_id} event=A2 srsrp_nr=7 srsrq_nr=7
    ...    pass_regexp=rrcReconfigurationComplete
    sleep    5s
    ${ho_cmd}  Catenate  ue_measurement_send_nr id=${ue_id} meas_id=${A3_meas_id} event=A3 srsrp_nr=11 phycell_id=381 nrsrp_nr=85
    Airphone Execute Egate Command    cmd=${ho_cmd}
    Airphone Execute Egate Command    cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=2 by=amf
    sleep    5s
    Airphone Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=2 trf_id=1 mbps=5 dir=dl protocol=tcp
    sleep    5s
    Airphone Execute Egate Command    cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=3 by=amf
    sleep    5s
    Airphone Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=3 trf_id=1 mbps=5 dir=dl
    sleep    5s

Concurrent PDU Modification during HO Execution Based Feature Enabled
#    [Arguments]    ${ue_id}=7    ${timeout}=150    ${pass_regexp}=${Add_5QI1_failed_and_HO_Success}
    [Arguments]    ${ue_id}=7
    sleep    5s
    Airphone Execute Egate Command    cmd=ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    Airphone Execute Egate Command    cmd=ue_measurement_send_nr id=${ue_id} meas_id=1 event=A2 srsrp_nr=7 srsrq_nr=7
    ...    pass_regexp=rrcReconfigurationComplete
    sleep    5s
    Airphone Execute Egate Command    cmd=ue_nr_rrc_reconf_param id=${ue_id} reset
    Airphone Execute Egate Command    cmd=ue_nr_rrc_reconf_param id=${ue_id} if_contains=any delay=1000
    Airphone Execute Egate Command    cmd=ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    ${ho_cmd}  Catenate  ue_measurement_send_nr id=${ue_id} meas_id=5 event=A3 srsrp_nr=11 phycell_id=381 nrsrp_nr=85
    Airphone Execute Egate Command    cmd=${ho_cmd}
    Airphone Execute Egate Command    cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=2 by=amf
#    Airphone Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=2 trf_id=1 mbps=5 dir=dl protocol=tcp
#    ...    timeout=${timeout}    pass_regexp=${pass_regexp}
#    Airphone Execute Egate Command    cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=3 by=amf
#    Airphone Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=3 trf_id=1 mbps=5 dir=dl

Check Counter for CB012209_001
    Sleep   500s
	${pi_list}=  Create List    M55125C00035    M55147C01001    M55124C05002    M55153C00001    M55153C00002    M55125C09517
    ${expect_value}    Set Variable    0
    FOR  ${counter_ID}  IN  @{pi_list}
           ${counter_id_value_list}    Check counter value   counter_ID=${counter_ID}
           ...                                               expect_value=${expect_value}
    END

Check Counter for CB012209_03
    Sleep   500s
	${pi_list}=  Create List    M55125C00035    M55147C00024    M55124C02002    M55125C09517
    ${expect_value}    Set Variable    0
    FOR  ${counter_ID}  IN  @{pi_list}
           ${counter_id_value_list}    Check counter value   counter_ID=${counter_ID}
           ...                                               expect_value=${expect_value}
    END
	${counter_values_list2}    Check counter value equal expect value1    counter_ID=M55143C00003    expect_value=0

Sum Counter Value Of Pi Value List
    [Arguments]    ${pi_list}    ${counter}    ${dn}=${None}
    ${counter_info_list}    Create List
    FOR    ${time_counter_infos}    IN    @{pi_list}
        ${counter_info}    Get Dictionary Values    ${time_counter_infos}
        ${counter_info_list}     Combine Lists    ${counter_info_list}    ${counter_info}
    END
    ${all counter values}    Create List
    FOR    ${counter_info}    IN    @{counter_info_list}
        ${is_contain}    Run Keyword And Return Status    Dictionary Should Contain Key
        ...    ${counter_info}    ${counter}
        Continue For Loop If    ${is_contain}==${False}
        ${is_contain_dn}    Run Keyword And Return Status    Dictionary Should Contain Key
        ...    ${counter_info}[${counter}]    ${dn}
        ${counter values}     Run Keyword If    '${is_contain_dn}'=='${True}'
        ...    Create List    ${counter_info}[${counter}][${dn}]
        ...    ELSE    Get Dictionary Values    ${counter_info}[${counter}]
        ${all counter values}    Combine Lists    ${counter values}    ${all counter values}
    END
    ${length}    Get Length    ${all counter values}
    ${sum_value}    Set Variable If    ${length}!=${0}    ${0}    ${None}
    FOR    ${i}    IN    @{all counter values}
        ${value}    Convert To Integer     ${i}
        ${sum_value}    evaluate    ${sum_value}+${value}
    END
    [Return]    ${sum_value}

Check PM Counters for CB012209_01
    Sleep   500s
    ${pi_list}    Create List    M55308C23002    M55308C32000    M55125C09031    M55143C00003    M55143C01504
    ${expect_value}    Set Variable    0
    FOR  ${counter_ID}  IN  @{pi_list}
           ${counter_id_value_list}    Check counter value   counter_ID=${counter_ID}
           ...                                               expect_value=${expect_value}
    END

Check PM Counters for CB012209_002
    Sleep   500s
    ${pi_list}    Create List    M55125C00035    M55125C09517    M55147C00024    M55124C02002
    ${expect_value}    Set Variable    0
    FOR  ${counter_ID}  IN  @{pi_list}
           ${counter_id_value_list}    Check counter value   counter_ID=${counter_ID}
           ...                                               expect_value=${expect_value}
    END
	${counter_values_list2}    Check counter value equal expect value1    counter_ID=M55143C00003    expect_value=0
 	${counter_values_list2}    Check counter value equal expect value1    counter_ID=M55143C01504    expect_value=0

Download wireshark plugin
    ${ver}   Run   ls ${plugin_folder}/
    ${exist}   Run   cd ${plugin_folder}/${ver}/epan;ls nsetapx*
    Run Keyword If   ${exist.count('No such file or directory')}>0   Run
    ...   cd ${plugin_folder}/${ver}/epan;sudo wget ${nsetapx_plugin_addr}

Start Tcpdump Log
    Log To Console    start tcpdump
    ${tcpdump_log_name}=    Start tcpdump in SBTS
    Set Suite Variable    ${tcpdump_log_name}

Stop Tcpdump Log
    Log To Console    stop tcpdump
    ${capture_file_path}    ${input_file}=    Stop Tcpdump in SBTS
    set test variable    ${capture_file_path}

Decode tcpdump
    [Arguments]    ${input_file}=${capture_file_path}    ${filter_expression}=nsetapx.result == 2
    ${tshark_comd}  catenate    tshark -r ${input_file} -o ntrstr.defragment:TRUE  -d tcp.port==49151,ntrstr
    ...  -d tcp.port==49148,ntrstr -d tcp.port==15000-15500,ntrstr -Y ${filter_expression}
    ${filtered_packets}    Run    ${tshark_comd}
    [Return]    ${filtered_packets}

Check tcpdump log
    Log To Console    check tcpdump log
    Decode tcpdump    input_file=${capture_file_path}   filter_expression=nsetapx.result == 2

Open DCAP
    OperatingSystem.Run    DCAP_Basic_controller start


