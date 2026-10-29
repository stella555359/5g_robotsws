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
#

Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Perform SCF Delta Commissioning with A_B5.json
...                 AND     sleep    60
...                 AND     gnb.Perform gNB reboot
...                 AND     sleep    180
...                 AND     OperatingSystem.Run    sudo ip addr add 10.0.1.3/24 dev eth3
...                 AND     sleep    60
...                 AND     OperatingSystem.Run    sudo ip addr add 10.0.1.4/24 dev eth3
...                 AND     sleep    60
...                 AND     Load CFG and verify cell status   ${wts_cfg_file}   1   1

Suite Teardown      Run Keywords
...                 Log To console  Suiteteardown
...                 AND     Run Keyword and Ignore Error     Stop Log      btslog     cprt
...                 AND     Run Keyword and Ignore Error    Get Snapshot

*** Variables ***

${wts_cfg_file}    ${CURDIR}/config/wts/basic_setup_a_b_5.cfg
${WTS_DIR}          /opt/iphy/latest
${start_ue_id}        1
${endue_id}        1
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
*** Test Cases ***
[1]CB010686-A-B5 PDU Session detected GTP Error at source gNB with ongoing inter-gNB mobility.

     Start Log      btslog     cprt
     ${crnti}    MultiUE Register should be Successful     ${1}    ${1}
     sleep   5s
     MultiUE Trigger UL Traffic for SA    ${1}  ${1}  Traffic_rate=mbps     ul_rate=70   pdu_id=1   trf_id=1   qfi_id=1
     MultiUE Trigger DL Traffic for SA    ${1}  ${1}  Traffic_rate=mbps     dl_rate=150   pdu_id=1   trf_id=1   qfi_id=1
     sleep   5s
     Trigger_Xn_Handover    1	52
	 sleep   5s
     ${status}       Run keyword and Return Status   Inject PDU Error   ${1}    ${1}    1
     Should Be Equal As Strings          ${status}                False
     sleep   5s
     UE state should be active   ${1}    ${1}
     MultiUE Deregister should be Successful   ${1}    ${1}
     ${scen1}     Stop Log      btslog     cprt

	Start Log      btslog     cprt
	Change UE location  	1	 2	 3
 	${crnti}    MultiUE Register should be Successful     ${1}    ${1}
	ADD Multi PDU Session      2     2
    Multi PDU Traffic    1     2     5     10
	UE History 	${1}
	${output}	Trigger_Xn_Handover    1	50
	sleep	5s
	sleep	5s
	Inject PDU Error   ${1}    ${1}    1
	sleep	1s
	Inject PDU Error   ${1}    ${1}    2
	sleep	1s
	UE state should be active   ${1}    ${1}
    MultiUE Deregister should be Successful   ${1}    ${1}
	${scen2}     Stop Log      btslog     cprt

	Start Log      btslog     cprt
	Change UE location  	3	 2	 3
    Set Global Variable  ${start_ue_id}      3
    Set Global Variable  ${endue_id}     3
 	${crnti}    MultiUE Register should be Successful     ${3}    ${3}
	ADD Multi PDU Session      2     2
	ute_wtssim.Execute Egate Command   cmd=upf_param id=3 end_markers_delay=30s gtpu_error_during_xn_handover=on
	sleep	1s
	ute_wtssim.Execute Egate Command   cmd=ue_nr_rrc_reconf_param id=3 if_contains=any action=drop delay=1m meas_type=A3
	sleep	1s
	${output}	Trigger_Xn_Handover    3	50
	Should Contain	  ${output}	XnAP::HandoverPreparation is received. Handover canceled
	MultiUE Deregister should be Successful   ${3}    ${3}
	${scen3}     Stop Log      btslog     cprt
	[Teardown]    Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***

Trigger_Xn_Handover
    [Arguments]   ${ue_id}	${phycell_id}
    ${cmd}   set variable   ue_measurement_send_nr id=${ue_id} meas_id=1 event=A3 srsrp_nr=19 phycell_id=${phycell_id} nrsrp_nr=100
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data   ${cmd}
    sleep   1s
	[Return]	${output}

Change UE location
    [Arguments]    ${ue_id}   ${ue_cell_id}   ${enb_id}
    ute_wtssim.Execute Egate Command   cmd=ue_change_location id=${ue_id} enb=${enb_id} cell=${ue_cell_id}

UE History
	[Arguments]		${ue_id}
	ute_wtssim.Execute Egate Command   cmd=ue_history_information_list_add_ngran id=${ue_id} cell_type=medium nrcgi=311:489|0x03 gnb_id=3
    ... 	time_ue_stayed_in_cell=100
    ${cmd}   set variable   ue_history_information_list_add_ngran id=${ue_id} cell_type=medium nrcgi=311:489|0x03 gnb_id=3 time_ue_stayed_in_cell=100
    ute_wtssim.Execute Egate Command    ${cmd}
	sleep	1s
	ute_wtssim.Execute Egate Command   cmd=ue_history_information_list id=${ue_id} action=commit
	sleep	1s
	ute_wtssim.Execute Egate Command   cmd=ue_enb_param id=${ue_id} ue_history_list=1
	sleep	1s
