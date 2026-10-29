*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO, VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...             RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_RAN     SBTS00   CONFIGURED

Documentation
...
...             author       : navin.kumar_ray@nokia.com
...             maintainer   : navin.kumar_ray@nokia.com
...             Test Set Name: CB010686 PDU Session detected GTP Error at source gNB with ongoing inter-gNB mobility
...             Testing Split: A#B5
...             Contacts     : I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             Requirement ID  : 5G_RAN_USR_RRM_26508
Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          Collections
Library           ta5g_enb
Library		      OperatingSystem


Resource         ./CB010686_resource.robot



Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Perform SCF Delta Commissioning with A_B7.json
...                 AND     Update bsr package
...                 AND     sleep    60


Suite Teardown      Run Keywords
...                 Log To console  Suiteteardown
...                 AND     Run Keyword and Ignore Error     Stop Log      btslog     cprt
...                 AND     Run Keyword and Ignore Error    Get Snapshot


*** Variables ***
#update the path of the cfg file & also change the cfg file name
${wts_cfg_file_default}    ${CURDIR}/config/wts/basic_setup.cfg
${wts_cfg_file}    ${CURDIR}/config/wts/basic_setup_b7.cfg
${wts_cfg_file1}    ${CURDIR}/config/wts/basic_setup_a_b_5_copy.cfg
${wts_cfg_file2}    ${CURDIR}/config/wts/basic_setup_AB51.cfg
${end_cell}         4
${WTS_DIR}          /opt/iphy/latest
${start_ue_id}        1
${end_ue_id}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${epc_log_path}    /tmp/
${TEST_NAME}            Cell_setup
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${nw_id}    1
${ue_id}    1
${start_cell}       1

*** Test Cases ***
[1.0] CB010686 PDU Session detected GTP error with ongoing intra-gNB mobility
     gnb.Perform gNB reboot
     sleep    180
     OperatingSystem.Run    sudo ip addr add 10.0.1.3/24 dev eth3
     sleep    60
     OperatingSystem.Run    sudo ip addr add 10.0.1.4/24 dev eth3
     sleep    60
     Load CFG and verify cell status   ${wts_cfg_file}   1   1
#     Load CFG and verify cell status   ${wts_cfg_file_default}   1   1


     Start Log      btslog     cprt
     ${crnti}    MultiUE Register should be Successful     ${1}    ${5}

     sleep   5s

     ADD Multi PDU Session      2       2

#     MultiUE Trigger UL Traffic for SA    ${1}  ${5}  Traffic_rate=mbps     ul_rate=70   pdu_id=1   trf_id=1   qfi_id=1
#     MultiUE Trigger DL Traffic for SA    ${1}  ${5}  Traffic_rate=mbps     dl_rate=150   pdu_id=1   trf_id=1   qfi_id=1
     sleep   5s
     Multi PDU Traffic      1       2       20      100

     Intra_gnb_Handover    1
	 sleep   5s

#     ${status}       Run keyword and Return Status   Inject PDU Error   ${1}    ${5}    1
     ${status}       Run keyword and Return Status       Inject Multiple PDU Error     1     2
#     Should Contain            ${status}                FAIL
     Should Be Equal As Strings          ${status}                True
     sleep   5s
     UE state should be active   ${1}    ${5}
     MultiUE Deregister should be Successful   ${1}    ${5}
     ${scen1}     Stop Log      btslog     cprt
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting

[1]CB010686-A-B5 PDU Session detected GTP Error at source gNB with ongoing inter-gNB mobility.
     Perform SCF Delta Commissioning with A_B5.json
     sleep    60
     gnb.Perform gNB reboot
     sleep    180
     OperatingSystem.Run    sudo ip addr add 10.0.1.3/24 dev eth3
     sleep    60
     OperatingSystem.Run    sudo ip addr add 10.0.1.4/24 dev eth3
     sleep    60
     Load CFG and verify cell status   ${wts_cfg_file1}   1   1
#     Load CFG and verify cell status   ${wts_cfg_file_default}   1   1

     Start Log      btslog     cprt
     ${crnti}    MultiUE Register should be Successful     ${1}    ${5}
     sleep   5s
     ADD Multi PDU Session      2       2
#     MultiUE Trigger UL Traffic for SA    ${1}  ${1}  Traffic_rate=mbps     ul_rate=70   pdu_id=1   trf_id=1   qfi_id=1
#     MultiUE Trigger DL Traffic for SA    ${1}  ${1}  Traffic_rate=mbps     dl_rate=150   pdu_id=1   trf_id=1   qfi_id=1
     sleep   5s
     Multi PDU Traffic      1       2       20      100
     Trigger_Xn_Handover    1   52   3
     sleep   5s
#     ${status}       Run keyword and Return Status   Inject PDU Error   ${1}    ${1}    1
     ${status}       Run keyword and Return Status       Inject Multiple PDU Error     1     2
     Should Be Equal As Strings          ${status}                False
     sleep   5s
     UE state should be active   ${1}    ${5}
     MultiUE Deregister should be Successful   ${1}    ${5}
     ${scen1}     Stop Log      btslog     cprt

    Start Log      btslog     cprt
    Change UE location      1    2   3
    ${crnti}    MultiUE Register should be Successful     ${1}    ${5}
    ADD Multi PDU Session      2     2
    Multi PDU Traffic    1     2     5     10
    UE History  ${1}
    ${output}   Trigger_Xn_Handover    1    50    1
    sleep   5s
    sleep   5s
    Inject PDU Error   ${1}    ${1}    1
    sleep   1s
    Inject PDU Error   ${1}    ${1}    2
    sleep   1s
    UE state should be active   ${1}    ${5}
    MultiUE Deregister should be Successful   ${1}    ${5}
    ${scen2}     Stop Log      btslog     cprt

    Start Log      btslog     cprt
    Change UE location      3    1   3
    Set Global Variable  ${start_ue_id}      3
    Set Global Variable  ${endue_id}     3
    ${crnti}    MultiUE Register should be Successful     ${3}    ${3}
    ADD Multi PDU Session      2     2
    Execute Egate Command   cmd=upf_param id=3 end_markers_delay=30s gtpu_error_during_xn_handover=on
    sleep   1s
    Execute Egate Command   cmd=ue_nr_rrc_reconf_param id=3 if_contains=any action=drop delay=1m meas_type=A3
    sleep   1s
    ${output}   Trigger_Xn_Handover    3    50   1
    Should Contain    ${output}     XnAP::HandoverPreparation is received. Handover canceled
    MultiUE Deregister should be Successful   ${3}    ${3}
    ${scen3}     Stop Log      btslog     cprt
#    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting
#    [Teardown]    Run Keywords    Run Keyword and Ignore Error     Kill WTS processes Using WTS_Runner
#    ...        AND     Run Keyword and Ignore Error    Get Snapshot
#    ...        AND        Stop Default Logging    output_dirpath=${LOG_PATH}
#    ...        AND   Link SCOUT SCF to Configuration ID for Reporting

    [Teardown]    Run Keywords    Run Keyword and Ignore Error     Get Snapshot
    ...        AND        Stop Default Logging    output_dirpath=${LOG_PATH}
    ...        AND   Link SCOUT SCF to Configuration ID for Reporting

[1.0] CB010686 Source GNB detected GTP error during inter-gNB mobility Preparation phase
     Perform SCF Delta Commissioning with A_B5.json
     sleep    60
     gnb.Perform gNB reboot
     sleep    180
     OperatingSystem.Run    sudo ip addr add 10.0.1.3/24 dev eth3
     sleep    60
     OperatingSystem.Run    sudo ip addr add 10.0.1.4/24 dev eth3
     sleep    60
     Load CFG and verify cell status   ${wts_cfg_file1}   1   1
#     Load CFG and verify cell status   ${wts_cfg_file_default}   1   1
     Start Log      btslog     cprt
     ${crnti}    MultiUE Register should be Successful     ${start_ue_id}    ${1}
     sleep   5s
     MultiUE Trigger UL Traffic for SA    ${1}  ${1}  Traffic_rate=mbps     ul_rate=70   pdu_id=1   trf_id=1   qfi_id=1
     MultiUE Trigger DL Traffic for SA    ${1}  ${1}  Traffic_rate=mbps     dl_rate=150   pdu_id=1   trf_id=1   qfi_id=1
     sleep   5s
     Trigger Xn HO and HO Prepration Timeout    ${1}      3      3
     Inject PDU Error   ${1}    ${1}    1
     sleep   1s
     UE state should be active   ${1}    ${1}
     MultiUE Deregister should be Successful   ${1}    ${1}
     ${scen1}     Stop Log      btslog     cprt
     [Teardown]    Link SCOUT SCF to Configuration ID for Reporting



*** Keywords ***

Intra_gnb_Handover
    [Arguments]   ${ue_id}
    ${cmd}   set variable   ue_measurement_send_nr id=${ue_id} meas_id=1 event=A3 srsrp_nr=1 srsrq_nr=1 phycell_id=51 nrsrp_nr=30 nrsrq_nr=20
    Execute Egate Command    ${cmd}
    sleep   3s
Trigger_Xn_Handover
    [Arguments]   ${ue_id}  ${phycell_id}   ${meas_id}
    ${cmd}   set variable   ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=19 phycell_id=${phycell_id} nrsrp_nr=100
    ${output}    Execute Egate Command And Wait For Data   ${cmd}
    sleep   1s
    [Return]    ${output}

Change UE location
    [Arguments]    ${ue_id}   ${ue_cell_id}   ${enb_id}
    Execute Egate Command   cmd=ue_change_location id=${ue_id} enb=${enb_id} cell=${ue_cell_id}

UE History
    [Arguments]     ${ue_id}
    Execute Egate Command   cmd=ue_history_information_list_add_ngran id=${ue_id} cell_type=medium nrcgi=311:489|0x03 gnb_id=3
    ...     time_ue_stayed_in_cell=100
    ${cmd}   set variable   ue_history_information_list_add_ngran id=${ue_id} cell_type=medium nrcgi=311:489|0x03 gnb_id=3 time_ue_stayed_in_cell=100
    Execute Egate Command    ${cmd}
    sleep   1s
    Execute Egate Command   cmd=ue_history_information_list id=${ue_id} action=commit
    sleep   1s
    Execute Egate Command   cmd=ue_enb_param id=${ue_id} ue_history_list=1
    sleep   1s

Update bsr package
    Run     mkdir ${CURDIR}/BSR
    ${dllink}   Set Variable     https://artifactory-espoo1.ext.net.nokia.com:443/artifactory/mnpute-rotta-local/BSR
    ${filename}    Set variable     BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471.zip
    Run     sudo wget ${dllink}/${filename} --user=dheerajn --password=AP33ZXKC1P9cgTCGJmyvY3bv5NA -P ${CURDIR}/BSR
    coam.setup admin    bts_host=192.168.255.129
    ${ret}     coam.Update Software      ${CURDIR}/BSR/BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471.zip
    coam.teardown admin
