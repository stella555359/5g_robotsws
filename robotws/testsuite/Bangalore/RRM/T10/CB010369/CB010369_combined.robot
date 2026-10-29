*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO
...             SBTS23R4    CONFIGURED

Documentation    USCB010369-B#B03_7_Successful UE Context Release due to expiration of RFSP based Inactivity timer Single Bearer without 8225
...				 USCB010369-B#B02_4_Successful RFSP based Inactivity timer configuration during Bearer Context Modification with RRCInactive
...				 Notificationlevel=UE
...
...             author:     padmashree.b@nokia.com
...             maintainer: padmashree.b@nokia.com
...
...             INTRODUCTION:This test scenario describes the behavior when Successful
...     UE Context Release due to expiration of RFSP based Inactivity timer Single Bearer without 8225
...                          This test scenario describes the behavior when Successful RFSP based Inactivity timer configuration during
...							Bearer Context Modification with RRCInactive , Notificationlevel=UE
...             TEST SET NAME:USCB010369-B#B03_7_Successful UE Context Release due to
...         expiration of RFSP based Inactivity timer Single Bearer without 8225
...							  USCB010369-B#B02_4_Successful RFSP based Inactivity timer configuration during Bearer Context Modification
...			with RRCInactive , Notificationlevel=UE
...             TESTING SPLIT:USCB010369-B#B03 and USCB010369-B#B02
...             CONTACTS:    RAN_L2_SW_BLR_1
...             REFERENCES: CB010769 CFAM
...             Requirement ID: 5G_RAN_USR_RRM_23641 and 5G_RAN_USR_RRM_23657

Resource         ./resources/CB010369_resource.robot
Resource         ./resources/CB013396_resource.robot
Library          ./resources/admin_cli.py
Library        SSHLibrary

Suite Teardown      Run Keywords
...                 Log To console  Suite_teardown
#...                 AND     Link SCOUT SCF to Configuration ID for Reporting
...                 AND     Run Keyword and Ignore Error     Stop Log      btslog     cprt
#...                 AND     Run Keyword and Ignore Error    wts_sim_keywords.Clean edaemon and egate

*** Variables ***
#${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_fdd_tdd_aeqe.cfg
#${gbr_cfg_file}     ${CURDIR}/config/wts/basic_setup_LO_AP_LO_TDD_FDD_HO_Slice.cfg
#${wts_cfg_file_ab03}		${CURDIR}/config/wts/basic_setup_fdd_tdd_aeqe1.cfg
${wts_cfg_file_ab03}       ${CURDIR}/config/wts/basic_setup_slice_tmo1.cfg
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_tmo.cfg
${gbr_cfg_file}     ${CURDIR}/config/wts/basic_setup_slice_tmo.cfg
${wts_cfg_13396}        ${CURDIR}/config/wts/tmo_basic_setup_multi_upf.cfg
${wts_cfg_nsa_13396}        ${CURDIR}/config/wts/tmo_nsa.cfg
${wts_cfg_sa_nsa_13396}        ${CURDIR}/config/wts/tmo_sa_nsa.cfg
${eNB_ID}               ${1}
${eNB_target}           ${2}
${NOKIA_LOGIN}    toor4nsn
${NOKIA_PASS}     oZPS0POrRieRtu
&{WTS}         Ip=127.0.0.1       Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TEST_NAME}        test_case
${start_ue_id}    ${1}
${end_ue_id}      ${1}
${Traffic_rate}		mbps
${ul_rate} 			1
${dl_rate}			1
${delta}       30
${indexToRSFP}		51
${srbinactintimer}	500
${rfsp_timer}	400
${drbrrc_timer}     460

${start_ue_id_ab03}    ${121}
${end_ue_id_ab03}      ${121}
${drb_ue_id}       ${101}
${spid}         ${1}
${Target_Cells}     ${2}
${Target_gNB}   ${2}
${Bearer_ID}    ${2}

# GFBR and MFBR profile <qos flow id>_gfbr_<dir>=speed
&{gfbr_mfbr_profile}                6_gfbr_ul=10   6_gfbr_dl=20    6_mfbr_ul=40     6_mfbr_dl=50
...                                 7_gfbr_ul=10   7_gfbr_dl=20    7_mfbr_ul=40     7_mfbr_dl=50
...                                 3_gfbr_ul=10   3_gfbr_dl=20    3_mfbr_ul=40     3_mfbr_dl=50
${spidinactivity_timer}      100
${spidinactivity_timer1}      300
${nsainactivity_timer}       200

@{Pdu_session_ID_b101}       1   2   3
${end_ue_id_b101}      ${3}

@{indexToRSFP_b101}		128		129		None
${rfsprrctimer}    130
${rfsptimer_1}    100
${drbrrctimer_1}     120

${monitortimerforcelldisable}       60
${pathRecoveryWaitTimer}            300
${pathRecoveryWaitTimer2}           900
${toplogy}      SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_TMO_65
${default_scf}     /home/ute/testline_init_results/execution/configs/topology_configs/node_1/${toplogy}/scfc.xml

*** Test Cases ***
[1][1.0] USCB010369-B#B03_7_Successful UE Context Release due to expiration of RFSP based Inactivity timer Single Bearer without 8225
	[Setup]		Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
	...                 AND     Perform SCF Delta Commissioning with Delta_json_B_B03_fdd_tdd_aeqe.json
	...                 AND     sleep    60
	...                 AND     gnb.Perform gNB reboot
	...                 AND     sleep    120
	...                 AND     Load CFG and verify cell status   ${wts_cfg_file}   1   1
    Start Log      btslog     cprt
   ${ics_param_cmd}    SET VARIABLE    amf_ue_ics_param id=1 ue=${start_ue_id} indexToRFSP=${indexToRSFP}
	Execute Egate Command    ${ics_param_cmd}    timeout=${EGATE_COMMAND_TIMEOUT}
	UE Register should be Successful	${UE_ID}     pdu_id=${Pdu_session_ID}     nw_id=${nwslice_ID}      gw_id=${gw_ID}
    Trigger DL Data Traffic for SA		${UE_ID}     ${Traffic_rate}     ${dl_rate}       pdu_id=${Pdu_session_ID}     trf_id=${TRF_ID}
	Trigger UL Data Traffic for SA		${UE_ID}     ${Traffic_rate}     ${ul_rate}       pdu_id=${Pdu_session_ID}     trf_id=${TRF_ID}

	${trf_stop_cmd}     SET VARIABLE    trf_data_stop ue=${UE_ID} pdu=${Pdu_session_ID}
	${datastop_time}      Get Time
    ${output}       Execute Egate Command And Wait For Data   ${trf_stop_cmd}
    ...     pass_regexp=Received UE Context Release Complete   timeout=520
	${release_time}     Get Time
    ${scen1}     Stop Log      btslog     cprt
	Should Contain  ${output}   Received RRC Release
	Verify Timer	${datastop_time}	${release_time}		${srbinactintimer}
	Verify Pcap messages bearersetup		${scen1}[cprt]/NODECPRT_GNB.pcap		${start_ue_id}		${indexToRSFP}


    Builtin.Log     [1]USCB010369-B#B02_4_Successful RFSP based Inactivity timer configuration during Bearer Context Modification
    Comment         verify with 8225 with bearer context modification Notificationlevel=UE

    Enable GBR Configuration
    Start Log      btslog     cprt
    Set ICS with cnai       ${UE_ID}
    UE Register should be Successful    ${UE_ID}     pdu_id=${Pdu_session_ID}     nw_id=${nwslice_ID}      gw_id=${gw_ID}
    Modify Ue context with RFSPID       ${UE_ID}    ${indexToRSFP}
    Modify PDU Session      ${UE_ID}    5
    Trigger DL Data Traffic for SA      ${UE_ID}     ${Traffic_rate}     ${dl_rate}       pdu_id=${Pdu_session_ID}     trf_id=${TRF_ID}
    Trigger UL Data Traffic for SA      ${UE_ID}     ${Traffic_rate}     ${ul_rate}       pdu_id=${Pdu_session_ID}     trf_id=${TRF_ID}
    ${trf_stop_cmd}     SET VARIABLE    trf_data_stop ue=${UE_ID} pdu=${Pdu_session_ID}
    ${datastop_time}      Get Time
    ${output}       Execute Egate Command And Wait For Data   ${trf_stop_cmd}    pass_regexp=Is INACTIVE   timeout=520
    ${release_time}     Get Time
    ${scen1}     Stop Log      btslog     cprt
    Verify Timer    ${datastop_time}    ${release_time}     ${srbinactintimer}
    Verify Pcap messages bearermodify        ${scen1}[cprt]/NODECPRT_GNB.pcap        ${start_ue_id}      ${indexToRSFP}
    [Teardown]    Run Keywords
	...                 Log To console  Testteardown
	...                 AND     Link SCOUT SCF to Configuration ID for Reporting
	...                 AND     Run Keyword and Ignore Error     Stop Log      btslog     cprt
	...                 AND     Run Keyword and Ignore Error    wts_sim_keywords.Clean edaemon and egate

[1][1.0] USCB010369-A#B03_4_Successful SgNB Release due to expiration of SPID based Inactivity timer single bearer
	[Setup]		Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
	...                 AND     Perform SCF Delta Commissioning with Delta_json_A_B03_fdd_tdd_aeqe.json
	...                 AND     sleep    60
    ...                 AND     Update bsr package_TMO_65
    ...                 AND     Sleep   60s
	...                 AND     gnb.Perform gNB reboot
	...                 AND     sleep    120
	...                 AND     Load CFG and verify cell status   ${wts_cfg_file_ab03}   1   1
    Start Log      btslog     cprt

	NSA LTE Attach should be Successful		${start_ue_id_ab03}
	${enb_param_cmd}    SET VARIABLE    ue_enb_param id=${start_ue_id_ab03} spid=${spid}
    Execute Egate Command    ${enb_param_cmd}    timeout=${EGATE_COMMAND_TIMEOUT}
    NSA X2AP Link Should be UP      eNB_ID=1   eNB_target=2
	NSA UE Attach should be Successful	${start_ue_id_ab03}	${Target_Cells}

	Trigger DL Traffic for NSA      ${start_ue_id_ab03}        Traffic_rate=mbps     dl_rate=1       id=${Bearer_ID}    trf_id=${TRF_ID}
    Trigger UL Traffic for NSA      ${start_ue_id_ab03}        Traffic_rate=mbps     ul_rate=1       id=${Bearer_ID}    trf_id=${TRF_ID}


    ${trf_stop_cmd}     SET VARIABLE    trf_data_stop ue=${start_ue_id_ab03}
	${datastop_time}      Get Time
    ${output}       Execute Egate Command And Wait For Data   ${trf_stop_cmd}
    ...     pass_regexp=Bearer-type change from SCG-split to MCG is successful   timeout=120
	${release_time}     Get Time
    ${scen1}     Stop Log      btslog     cprt


#    Should Contain  ${output}   SgNBReleaseRequired
#    Should Contain  ${output}   radioNetwork : user-inactivity
    Should Contain  ${output}   SgNBReleaseConfirm
	Verify Timer	${datastop_time}	${release_time}		${spidinactivity_timer}
	Verify Pcap msgs ue		${scen1}[cprt]/NODECPRT_GNB.pcap		${spid}		${start_ue_id_ab03}

    BuiltIn.Log    [1]CB010369_A_B02_3_Successful SPID based Inactivity config during BearerContextModication nsaactivitynotificationlevel=drb
    Comment         Verify with notification level drb


    Modify NIDD parameters      nsaActivityNotificationLevel      drb        update      MRBTS-1/NRBTS-1
    Modify NIDD parameters      nsaInactivityTimer      200        update      MRBTS-1/NRBTS-1
    Modify NIDD parameters      spidInactivityTimer      300        update      MRBTS-1/NRBTS-1/NRSPID_PROFILE-1

    Start Log      btslog     cprt
    NSA LTE Attach should be Successful     ${drb_ue_id}
    NSA X2AP Link Should be UP      eNB_ID=1   eNB_target=2
    NSA UE Attach should be Successful  ${drb_ue_id}  ${Target_Cells}
    Sgnb beareradd and modify   ${drb_ue_id}      ${spid}
    Trigger DL Traffic for NSA      ${drb_ue_id}        Traffic_rate=mbps     dl_rate=1       id=${Bearer_ID}    trf_id=${TRF_ID}
    Trigger UL Traffic for NSA      ${drb_ue_id}        Traffic_rate=mbps     ul_rate=1       id=${Bearer_ID}    trf_id=${TRF_ID}
    ${trf_stop_cmd}     SET VARIABLE    trf_data_stop ue=${drb_ue_id}
    ${datastop_time}      Get Time
    ${output}       Execute Egate Command And Wait For Data   ${trf_stop_cmd}
    ...     pass_regexp=Bearer-type change from SCG-split to MCG is successful   timeout=320
    ${release_time}     Get Time
    ${scen2}     Stop Log      btslog     cprt

    Should Contain  ${output}   SgNBReleaseConfirm
    Verify Timer    ${datastop_time}    ${release_time}     ${spidinactivity_timer1}
    Verify Pcap msgs drb    ${scen2}[cprt]/NODECPRT_GNB.pcap    ${spid}     ${drb_ue_id}    ${spidinactivity_timer1}     ${nsainactivity_timer}
    [Teardown]    Run Keywords
	...                 Log To console  Testteardown
	...                 AND     Link SCOUT SCF to Configuration ID for Reporting
	...                 AND     Run Keyword and Ignore Error     Stop Log      btslog     cprt
	...                 AND     Run Keyword and Ignore Error    wts_sim_keywords.Clean edaemon and egate

[1][1.0] CB010369-B-B101_B04-1_Successful transition of UE from RRC_Connected to RRC_Inactive state due to expiration of RFSP based Inactivity timer
	[Setup]		Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
	...                 AND     Perform SCF Delta Commissioning with Delta_json_B_B04_fdd_tdd_aeqe.json
	...                 AND     sleep    60
	...                 AND     gnb.Perform gNB reboot
	...                 AND     sleep    120
	...                 AND     Load CFG and verify cell status   ${wts_cfg_file}   1   1

    Comment     #### ue1 with rfsp 128 and cnai on ####
	Start Log      btslog     cprt
	Set ICS with index to RFSP		1		${indexToRSFP_b101}[0]
	UE Register should be Successful	1     pdu_id=${Pdu_session_ID_b101}[0]     nw_id=${nwslice_ID}      gw_id=${gw_ID}
	Trigger data	1     ul		pdu_id=${Pdu_session_ID_b101}[0]     trf_id=1		qfi=1  Traffic_unit=mbps		traffic_rate=1
	Trigger data	1     dl		pdu_id=${Pdu_session_ID_b101}[0]     trf_id=1		qfi=1  Traffic_unit=mbps		traffic_rate=1
	${trf_stop_cmd}     SET VARIABLE    trf_data_stop ue=1 pdu=${Pdu_session_ID_b101}[0]
	${datastop_time}      Get Time
    ${output}       Execute Egate Command And Wait For Data   ${trf_stop_cmd}    pass_regexp=UE1\: Is INACTIVE   timeout=150
	${release_time}     Get Time
    ${ue1_log}     Stop Log      btslog     cprt    test_scenario=ue1
    Run Keyword and Continue on Failure		Verify Timer	${datastop_time}	${release_time}		${rfsprrctimer}

	Comment     #### ue2 with rfsp 129 and cnai off ####
	Start Log      btslog     cprt
	Set ICS with index to RFSP		2		${indexToRSFP_b101}[1]
	UE Register should be Successful	2     pdu_id=${Pdu_session_ID_b101}[1]     nw_id=${nwslice_ID}      gw_id=${gw_ID}
	Trigger data	2     dl		pdu_id=${Pdu_session_ID_b101}[1]     trf_id=1		qfi=1  Traffic_unit=mbps		traffic_rate=1
	${trf_stop_cmd}     SET VARIABLE    trf_data_stop ue=2 pdu=${Pdu_session_ID_b101}[1]
	${datastop_time}      Get Time
    ${output}       Run keyword and continue on failure     Execute Egate Command And Wait For Data   ${trf_stop_cmd}
    ...     pass_regexp=UE2\: IS IDLE   timeout=150
	${release_time}     Get Time
    ${ue2_log}     Stop Log      btslog     cprt    test_scenario=ue2
    Run Keyword and Continue on Failure		Verify Timer	${datastop_time}	${release_time}		${rfsprrctimer}

	Comment     #### ue3 with rfsp None and cnai off ####
	Start Log      btslog     cprt
	Set ICS with index to RFSP		3		${indexToRSFP_b101}[2]
	UE Register should be Successful	3     pdu_id=${Pdu_session_ID_b101}[2]     nw_id=${nwslice_ID}      gw_id=${gw_ID}
	Trigger data	3     dl		pdu_id=${Pdu_session_ID_b101}[2]     trf_id=1		qfi=1  Traffic_unit=mbps		traffic_rate=1
	${trf_stop_cmd}     SET VARIABLE    trf_data_stop ue=3 pdu=${Pdu_session_ID_b101}[2]
	${datastop_time}      Get Time
    ${output}       Run keyword and continue on failure     Execute Egate Command And Wait For Data   ${trf_stop_cmd}
    ...     pass_regexp=UE3\: IS IDLE   timeout=150
	${release_time}     Get Time
    ${ue3_log}     Stop Log      btslog     cprt    test_scenario=ue3
    OperatingSystem.Run    cp /opt/wts/latest/egate_console.log /home/ute/Logs/
    Run Keyword and Continue on Failure		Verify Timer	${datastop_time}	${release_time}		${drbrrctimer_1}
    ${timers}   Create List     ${rfsptimer}    ${rfsprrctimer}     ${rfsprrctimer}     ${drbrrctimer_1}
    ${id}   Create List     dummy       128     129     None
    FOR     ${i}   IN RANGE    ${start_ue_id}    ${end_ue_id_b101}+1
    Verify Pcap messages    ${ue${i}_log}[cprt]/NODECPRT_GNB.pcap       ${i}    ${timers}[${i}]     ${id}[${i}]
    END
    [Teardown]    Run Keywords
	...                 Log To console  Testteardown
	...                 AND     Link SCOUT SCF to Configuration ID for Reporting
	...                 AND     Run Keyword and Ignore Error     Stop Log      btslog     cprt
	...                 AND     Run Keyword and Ignore Error    wts_sim_keywords.Clean edaemon and egate

[1]CB013396-B_B1_TC5_Alternative_5_SA_cell_disabled_when_failed_paths_count_above_minFailedPathNumNgCellDisable
    [Documentation]     The purpose of this TC is to verify the behaviour when all supervised NG-U GTP-U paths are failed, and the failed NG-U
    ...				path amount is bigger than or equal to 4 defined by NIDD parameter NRBTS/NRGTPU.minFailedPathNumNGCellDisable, gNB shall
    ...				start a timer defined by NRBTS/NRGTPU.monitorTimerForCellDisable. No NG-U path is recovered and failed NG-U path amount
    ...				is still bigger than or equal to 4 duriNG the monitor time period
    ...
    ...             author:     padmashree.b@nokia.com
    ...             maintainer: padmashree.b@nokia.com
    ...             TESTING SPLIT:CB013396_B101
    ...             CONTACTS:    VRF_BLR1
    ...             REFERENCES: CB013396 CFAM
    ...             Requirement ID: 5G_RAN_USR_RRM_29165
    [Setup]         Run keywords    Suite setup from scratch
    ...                 AND     Perform SCF Delta Commissioning with delta_combined_tmo.json
    ...                 AND     sleep    10
    ...                 AND     Update bsr package_TMO_65
    ...                 AND     Sleep   60s
    ...                 AND     gnb.Perform gNB reboot
    ...                 AND     sleep    120
    ...                 AND     Configure additional UTE ETH3 IPs
    ...                 AND     sleep    60
    ...                 AND     Load CFG and verify cell status   ${wts_cfg_13396}   1   1
    Start Log      btslog
    Multi UE Register should be Successful with upfid And send traffic     1     5    1     1      1     1
    Multi UE Register should be Successful with upfid And send traffic     6     10    1     1      1     2
    Multi UE Register should be Successful with upfid And send traffic     11     15    1     1      1     3
    Run Keyword and Ignore Error    Link SCOUT SCF to Configuration ID for Reporting
    sleep       10s
    Trigger gtpu path failure for 3 paths upf1
    sleep       62s
    Check If fault not Appeared     7706        Critical
    Trigger gtpu path failure for 3 paths upf2
    sleep     5s
    ${major_alarm_time}    ${major_alarm_info}   Check If fault 7706 Appeared and failed paths info      Major
    sleep     140s
    ${crit_alarm_time}  ${crit_alarm_info}      Check If fault 7706 Appeared and failed paths info      Critical
    Should Contain      ${crit_alarm_info['alarmAttribute'][0]['attributeValue']}  NR:all
    Check Availability and operational State of all cells        failed       disabled
    Comment         ............ B_B2_TC1 verify cell enable ...................
    Comment         sleep to verify cell enable after path recovery timer expires
    Sleep     300s
    Check operational State of all cells        enabled
    ${status}       Run keyword and return status       Check If fault 7706 Appeared and failed paths info      Critical
    ${status}       Convert To String    ${status}
    Should Match Regexp     ${status}    False
    ${syslogpath}   Stop Log      btslog
    Recover gtpu path failure for 6 paths
    ${ue_dereg_cmd}    SET VARIABLE    ue_deregister id=1-15 ue_deregister_type=switch_off by=ue
    Execute Egate Command    ${ue_dereg_cmd}    timeout=${EGATE_COMMAND_TIMEOUT}
	Sleep	30s
	Start Log      btslog
    Multi UE Register should be Successful with upfid And send traffic     1     5    1     1      1     1
    Multi UE Register should be Successful with upfid And send traffic     6     10    1     1      1     2
    Multi UE Register should be Successful with upfid And send traffic     11     15    1     1      1     3
    sleep       10s
    Trigger gtpu path failure for 6 paths
    sleep       5s
	${major_alarm_time}    ${major_alarm_info}   Check If fault 7706 Appeared and failed paths info      Major
	sleep		30s
	Recover gtpu path failure for 4 paths
	sleep		32s
    Check operational State of all cells        enabled
    Check If fault not Appeared     7706        Critical
	${syslogpath_2}   Stop Log      btslog
    [Teardown]      Run Keywords
    ...                 Log To console  Testteardown
    ...                 AND     Run Keyword and Ignore Error     Stop Log      btslog
    ...                 AND     Run Keyword and Ignore Error        Stop Log    Snapshot    sosreport
    ...                 AND     Run Keyword and Ignore Error    wts_sim_keywords.Clean edaemon and egate


[1]CB013396-A_B1_TC9_Alternative_8_NSA_cell_disabled_when_failed_paths_count_above_minFailedPathNumS1CellDisable_and_ok_path_released
   [Documentation]     The purpose of this TC is to verify the behaviour when all supervised S1-U GTP-U paths are failed, and the failed S1-U
    ...				path amount is bigger than or equal to 4 defined by NIDD parameter NRBTS/NRGTPU.minFailedPathNumS1CellDisable, gNB
    ...				shall start a timer defined by NRBTS/NRGTPU.monitorTimerForCellDisable.
    ...
    ...             author:     megha.dm@nokia.com
    ...             maintainer: megha.dm@nokia.com
    ...             TESTING SPLIT:CB013396_A_B1
    ...             CONTACTS:    VRF_BLR1
    ...             REFERENCES: CB013396 CFAM
    ...             Requirement ID:
    [Setup]         Run keywords    Suite setup from scratch
    ...                 AND     BuiltIn.Set Suite Variable      ${SCFC}         ${default_scf}
    ...                 AND     Prepare TL with SCF change
    ...                 AND     sleep   300
    ...                 AND     Perform SCF Delta Commissioning with delta_combined_tmo_nsa.json
    ...                 AND     sleep    100
    ...                 AND     Perform SCF Delta Commissioning with Multi_enb.json
    ...                 AND    Add RadParam to swconfig     "0x6601EE=1"    "0x6601E0=1"      IP=192.168.255.129
    ...                 AND     gnb.Perform gNB reboot
    ...                 AND     sleep    120
    ...                 AND     Configure additional UTE ETH3 IPs
    ...                 AND     sleep    60
    ...                 AND     OperatingSystem.Run    sudo ip addr add 10.0.1.151/24 dev eth3
    ...                 AND     OperatingSystem.Run    sudo ip addr add 10.0.1.152/24 dev eth3
    ...                 AND     OperatingSystem.Run    sudo ip addr add 10.0.1.171/24 dev eth3
    ...                 AND     OperatingSystem.Run    sudo ip addr add 10.0.1.172/24 dev eth3
    ...                 AND     OperatingSystem.Run    sudo ip addr add 10.0.1.122/24 dev eth3
    ...                 AND     OperatingSystem.Run    sudo ip addr add 10.0.1.141/24 dev eth3
    ...                 AND     Load CFG and verify cell status   ${wts_cfg_nsa_13396}   3    3
    Start Log      btslog
    ute_wtssim.Execute Egate Command   cmd=enb_x2_link_up enb=3 target=2    timeout=${EGATE_COMMAND_TIMEOUT}
    ute_wtssim.Execute Egate Command   cmd=enb_x2_link_up enb=10 target=2    timeout=${EGATE_COMMAND_TIMEOUT}
    sleep   10s
	Run Keyword and Ignore Error    Link SCOUT SCF to Configuration ID for Reporting
	${crnti_list1}=      NSA Multi UE Attach should be Successful Custom      101      103    1      1
    ${crnti_list1}=      NSA Multi UE Attach should be Successful Custom     104      106    1      2
    ${crnti_list1}=      NSA Multi UE Attach should be Successful Custom     107      109    1      3
    MultiUE Trigger DL Traffic for NSA    101     109    Traffic_rate=mbps    dl_rate=${1}
    MultiUE Trigger UL Traffic for NSA     101      109    Traffic_rate=mbps    ul_rate=${5}
    sleep       10s
    Trigger gtpu path failure for 3 path sgw1
    sleep       102s
    Check If fault not Appeared     7706        Critical
    Trigger gtpu path failure for 3 path sgw2
    sleep     5s
    ${major_alarm_time}    ${major_alarm_info}   Check If fault 7706 Appeared and failed paths info      Major
    sleep     102s
    ${crit_alarm_time}  ${crit_alarm_info}      Check If fault 7706 Appeared and failed paths info      Critical
    Should Contain      ${crit_alarm_info['alarmAttribute'][1]['attributeValue']}  NR:1,2,5,6
    Check Only Cells Are Disabled
    ...    failed
    ...    disabled
    ...    MRBTS-1/NRBTS-1/NRCELL-1
    ...    MRBTS-1/NRBTS-1/NRCELL-2
    ...    MRBTS-1/NRBTS-1/NRCELL-5
    ...    MRBTS-1/NRBTS-1/NRCELL-6
    Comment         ............. Introducing A_iwk1 scenario of x2-c link down
    ${link_lock3}    SET VARIABLE    link_lock at=enb:3 link=x2 to=gnb:2
    ${link_lock10}  SET VARIABLE    link_lock at=enb:10 link=x2 to=gnb:2
    ute_wtssim.Execute Egate Command   ${link_lock3}    timeout=${EGATE_COMMAND_TIMEOUT}
    ute_wtssim.Execute Egate Command   ${link_lock10}    timeout=${EGATE_COMMAND_TIMEOUT}
    Sleep       200s
    COAM.Setup Admin    bts_host=192.168.255.129
    @{alarm_history}=    COAM.Get Active Alarms
    COAM.Teardown Admin
    Check Alarm Exists With Attributes  ${alarm_history}    7308    MRBTS-1/NRBTS-1/LTEENB-0    MRBTS-1/NRBTS-1/LTEENB-1    attr_name=configuration
    ${status}   Run keyword and return Status       Check Alarm Exists With Attributes     ${alarm_history}    7107    NR:1    NR:2     NR:5    NR:6
    Should Be Equal As Strings      ${status}       False
    Comment         ............  verify cell enable ...................
    ${link_unlock3}    SET VARIABLE    link_unlock at=enb:3 link=x2 to=gnb:2
    ${link_unlock10}  SET VARIABLE    link_unlock at=enb:10 link=x2 to=gnb:2
    ute_wtssim.Execute Egate Command   ${link_unlock3}    timeout=${EGATE_COMMAND_TIMEOUT}
    ute_wtssim.Execute Egate Command   ${link_unlock10}    timeout=${EGATE_COMMAND_TIMEOUT}

    Comment         sleep to verify cell enable after path recovery timer expires
    Sleep     120s
    Check Only Cells Are In Enabled State
    ...    enabled
    ...    MRBTS-1/NRBTS-1/NRCELL-1
    ...    MRBTS-1/NRBTS-1/NRCELL-2
    ...    MRBTS-1/NRBTS-1/NRCELL-5
    ...    MRBTS-1/NRBTS-1/NRCELL-6
    ${syslogpath}   Stop Log      btslog
    Recover s1 gtpu path failure for 6 path

    ${ue_detach_cmd}    SET VARIABLE    ue_detach id=101-109
    ute_wtssim.Execute Egate Command    ${ue_detach_cmd}    timeout=${EGATE_COMMAND_TIMEOUT}
	Sleep	30s
	Start Log      btslog
	${crnti_list1}=      NSA Multi UE Attach should be Successful Custom      101      103    1      1
    ${crnti_list1}=      NSA Multi UE Attach should be Successful Custom     104      106    1      2
    ${crnti_list1}=      NSA Multi UE Attach should be Successful Custom     107      109    1      3
	MultiUE Trigger DL Traffic for NSA    101      109    Traffic_rate=mbps    dl_rate=${1}
    MultiUE Trigger UL Traffic for NSA     101      109    Traffic_rate=mbps    ul_rate=${5}
    ${link_lock10}  SET VARIABLE    link_lock at=enb:10 link=x2 to=gnb:2
    ute_wtssim.Execute Egate Command   ${link_lock10}    timeout=${EGATE_COMMAND_TIMEOUT}
    Sleep   180s
    Trigger s1 gtpu path failure for 6 path
    sleep       5s
	${major_alarm_time}    ${major_alarm_info}   Check If fault 7706 Appeared and failed paths info      Major
    sleep       102s
    ${crit_alarm_time}  ${crit_alarm_info}      Check If fault 7706 Appeared and failed paths info      Critical
    Should Contain      ${crit_alarm_info['alarmAttribute'][1]['attributeValue']}  NR:1,2
    Check Only Cells Are Disabled
    ...    failed
    ...    disabled
    ...    MRBTS-1/NRBTS-1/NRCELL-1
    ...    MRBTS-1/NRBTS-1/NRCELL-2
    COAM.Setup Admin    bts_host=192.168.255.129
    @{alarm_history}=    COAM.Get Active Alarms
    COAM.Teardown Admin
    Run Keyword and Continue on Failure     Check Alarm Exists With Attributes     ${alarm_history}    7107    NR:5    NR:6
    ${status_7107}       Run keyword and Return Status       Check Alarm Exists With Attributes     ${alarm_history}        7107    NR:1    NR:2
    Should Be Equal As Strings      ${status_7107}       False
	sleep		30s
    Recover S1 Gtpu Path Failure For 1 Path
	sleep		62s
    Check Only Cells Are In Enabled State
    ...    enabled
    ...    MRBTS-1/NRBTS-1/NRCELL-1
    ...    MRBTS-1/NRBTS-1/NRCELL-2
    Run Keyword and Continue on Failure     Check Alarm Exists With Attributes     ${alarm_history}    7107    NR:5    NR:6
    ${syslogpath_2}   Stop Log      btslog
    [Teardown]      Run Keywords
    ...                 Log To console  Testteardown
    ...             AND     ute_wtssim.Execute Egate Command   ${link_unlock3}    timeout=${EGATE_COMMAND_TIMEOUT}
    ...         AND         ute_wtssim.Execute Egate Command   ${link_unlock10}    timeout=${EGATE_COMMAND_TIMEOUT}

    ...                 AND     Run Keyword and Ignore Error     Stop Log      btslog
    ...                 AND     Run Keyword and Ignore Error        Stop Log    Snapshot    sosreport
    ...                 AND     Run Keyword and Ignore Error    wts_sim_keywords.Clean edaemon and egate

[1]CB013396-A_B4_TC1_NSA_only_and_SA_only_Cells_disable_enable_based_on_supervision_result
    [Documentation]     The purpose of this TC is to verify the behavior of the gNB when enabling or disabling SA-only and NSA-only
    ...                 cells based on GTP-U path supervision result
    ...             author:     akhil.k_p@nokia.com
    ...             maintainer: akhil.k_p@nokia.com
    ...             TESTING SPLIT:CB013396_A-B401,CB013396-A-B201
    ...             CONTACTS:    VRF_BLR1
    ...             REFERENCES: CB013396 CFAM
    ...             Requirement ID: 11262381,11262367
    [Setup]         Run keywords    Suite setup from scratch
    ...                 AND     BuiltIn.Set Suite Variable      ${SCFC}         ${default_scf}
    ...                 AND     Prepare TL with SCF change
    ...                 AND     sleep   300
    ...                 AND     Perform SCF Delta Commissioning with delta_combined_tmo_sa_nsa.json
    ...                 AND     sleep    60
    ...                 AND     Perform SCF Delta Commissioning with delta_combined_tmo_sa_nsa_2.json
    ...                 AND     sleep    10
    ...                 AND     Add RadParam to swconfig     "0x6601EE=1"    "0x6601E0=1"      IP=192.168.255.129
    ...                 AND     gnb.Perform gNB reboot
    ...                 AND     sleep    220
    ...                 AND     Configure additional UTE ETH3 IPs
    ...                 AND     sleep    60
    ...                 AND     OperatingSystem.Run    sudo ip addr add 10.0.1.151/24 dev eth3
    ...                 AND     OperatingSystem.Run    sudo ip addr add 10.0.1.152/24 dev eth3
    ...                 AND     OperatingSystem.Run    sudo ip addr add 10.0.1.171/24 dev eth3
    ...                 AND     OperatingSystem.Run    sudo ip addr add 10.0.1.172/24 dev eth3
    ...                 AND     Load CFG and verify cell status   ${wts_cfg_sa_nsa_13396}   7   7
    Start Log      btslog
    NSA X2AP Link Should be UP     ${eNB_ID}		${eNB_target}
    Attach sa ues and send traffic
    Run Keyword and Ignore Error    Link SCOUT SCF to Configuration ID for Reporting
    sleep       10s
    Trigger gtpu path failure for 3 paths upf1
    sleep       62s
    Check If fault not Appeared     7706        Critical
    Trigger gtpu path failure for 3 paths sa
    sleep     120s
    ${major_alarm_time}    ${major_alarm_info}   Check If fault 7706 Appeared and failed paths info      Major
    sleep     92s
    ${crit_alarm_time}  ${crit_alarm_info}      Check If fault 7706 Appeared and failed paths info      Critical
    Should Contain      ${crit_alarm_info['alarmAttribute'][0]['attributeValue']}  NR:10,11,12,3,4,7,8,9
    sleep       30s
    Verify sa cells are disabled and nsa cells are in enabled state
    Attach nsa ues and send traffic
    sleep       10s
    Trigger gtpu path failure for 3 path sgw1
    sleep       102s
    ${crit_alarm_time}  ${crit_alarm_info}      Check If fault 7706 Appeared and failed paths info      Critical
    Should not contain      ${crit_alarm_info['alarmAttribute'][0]['attributeValue']}  NR:1,2,5,6
    Trigger gtpu path failure for 3 path sgw2
    sleep     5s
    ${major_alarm_time}    ${major_alarm_info}   Check If fault 7706 Appeared and failed paths info      Major
    sleep     102s
    ${crit_alarm_time}  ${crit_alarm_info}  Check If fault 7706 Appeared and failed paths info     Critical
    sleep    30s
    Should contain      ${crit_alarm_info['alarmAttribute'][0]['attributeValue']}  NR:all
    Verify nsa cells are disabled
    Comment         sleep to verify cell enable after path recovery timer expires
    Sleep     1200s
    Check operational State of all cells        enabled
    ${status}       Run keyword and return status       Check If fault 7706 Appeared and failed paths info      Critical
    ${status}       Convert To String    ${status}
    Should Match Regexp     ${status}    False
    ${syslogpath}   Stop Log      btslog
    Recover gtpu path failure for 6 paths sa
    ${ue_dereg_cmd}    SET VARIABLE    ue_deregister id=51-65 ue_deregister_type=switch_off by=ue
    ute_wtssim.Execute Egate Command    ${ue_dereg_cmd}    timeout=${EGATE_COMMAND_TIMEOUT}
    Recover s1 gtpu path failure for 6 path
    ${ue_detach_cmd}    SET VARIABLE    ue_detach id=101-109
    ute_wtssim.Execute Egate Command    ${ue_detach_cmd}    timeout=${EGATE_COMMAND_TIMEOUT}
	Sleep	30s

	Start Log      btslog
    Attach sa ues and send traffic
    sleep       10s
    Trigger gtpu path failure for 6 paths sa
    sleep       70s
    ${major_alarm_time}    ${major_alarm_info}   Check If fault 7706 Appeared and failed paths info      Major
    sleep     65s
    ${crit_alarm_time}  ${crit_alarm_info}      Check If fault 7706 Appeared and failed paths info      Critical
    Should Contain      ${crit_alarm_info['alarmAttribute'][0]['attributeValue']}  NR:10,11,12,3,4,7,8,9
    sleep    30s
    Verify sa cells are disabled
    Attach nsa ues and send traffic
    Trigger s1 gtpu path failure for 6 path
    sleep       70s
	${major_alarm_time}    ${major_alarm_info}   Check If fault 7706 Appeared and failed paths info      Major
    sleep       90s
    ${crit_alarm_time}  ${crit_alarm_info}      Check If fault 7706 Appeared and failed paths info      Critical
    Should Contain      ${crit_alarm_info['alarmAttribute'][0]['attributeValue']}  NR:all
    Verify nsa cells are disabled
	Recover gtpu path failure for 1 paths sa
	sleep		60s
    Verify sa cells are enabled
    sleep		10s
    Recover S1 Gtpu Path Failure For 1 Path
	sleep		60s
    Verify nsa cells are enabled
    Check If fault not Appeared     7706        Critical
	${syslogpath_2}   Stop Log      btslog

    Start Log      btslog
    ute_wtssim.Execute Egate Command  cmd=upf_param id=3 skip_echo_req=10.0.1.5,10.0.1.2,150
    sleep   95s
    Verify sa cells are disabled
    ${crit_alarm_time}  ${crit_alarm_info}      Check If fault 7706 Appeared and failed paths info      Critical
    Should Contain      ${crit_alarm_info['alarmAttribute'][0]['attributeValue']}  NR:10,11,12,3,4,7,8,9
    Perform SCF Delta Commissioning with feature_disabled.json
    Verify sa cells are enabled
    Check If fault not Appeared     7706        Critical

    Perform SCF Delta Commissioning with feature_enabled.json
    ute_wtssim.Execute Egate Command  cmd=sgw_trigger id=2 skip_echo_req=10.0.1.151,10.0.1.13,150
    sleep   95s
    Verify nsa cells are disabled
    Run Keyword and Ignore Error     Verify sa cells are disabled
    ${crit_alarm_time}  ${crit_alarm_info}      Check If fault 7706 Appeared and failed paths info      Critical
    Should Contain      ${crit_alarm_info['alarmAttribute'][0]['attributeValue']}  NR:all
    Perform SCF Delta Commissioning with feature_disabled.json
    sleep   180s
    Verify sa cells are enabled
    Verify nsa cells are enabled
    Check If fault not Appeared     7706        Critical
    ${syslogpath_3}   Stop Log      btslog

    [Teardown]      Run Keywords
    ...                 Log To console  Testteardown
    ...                 AND     Run Keyword and Ignore Error     Stop Log      btslog
    ...                 AND     Run Keyword and Ignore Error        Stop Log    Snapshot    #sosreport
    ...                 AND     Run Keyword and Ignore Error    wts_sim_keywords.Clean edaemon and egate

[1]CB013396-A_IWK3_TC2_Alt_2_behaviour_when_all_NSA_cells_are_disabled_due_to_energysaving
    [Documentation]    The purpose of this TC is to verify the behaviour when CB013396 is
    ...      enabled and NSA cells are disabled due to energy saving and NG-U path failure
    ...             author:   megha.dm@nokia.com
    ...             maintainer: megha.dm@nokia.com
    ...             TESTING SPLIT:CB013396_A302
    ...             CONTACTS:    VRF_BLR1
    ...             REFERENCES: CB013396 CFAM
    ...             Requirement ID:
   [Setup]         Run keywords    Suite setup from scratch
    ...                 AND     BuiltIn.Set Suite Variable      ${SCFC}         ${default_scf}
    ...                 AND     Prepare TL with SCF change
    ...                 AND     sleep    300
    ...                 AND     Perform SCF Delta Commissioning with energy_saving_nsa.json
    ...                 AND     sleep    300
    ...                 AND     Perform SCF Delta Commissioning with energy_saving_nsa_2.json
    ...                 AND     sleep    10
    ...                 AND     Add RadParam to swconfig     "0x6601EE=1"    "0x6601E0=1"      IP=192.168.255.129
    ...                 AND     gnb.Perform gNB reboot
    ...                 AND     sleep    220
    ...                 AND     Configure additional UTE ETH3 IPs
    ...                 AND     sleep    60
    ...                 AND     OperatingSystem.Run    sudo ip addr add 10.0.1.151/24 dev eth3
    ...                 AND     OperatingSystem.Run    sudo ip addr add 10.0.1.152/24 dev eth3
    ...                 AND     OperatingSystem.Run    sudo ip addr add 10.0.1.171/24 dev eth3
    ...                 AND     OperatingSystem.Run    sudo ip addr add 10.0.1.172/24 dev eth3
    ...                 AND     Load CFG and verify cell status   ${wts_cfg_sa_nsa_13396}   7   7

    Start Log      btslog
    NSA X2AP Link Should be UP     ${eNB_ID}        ${eNB_target}

    Wait 10s for [1,2,5,6] esState change to [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]
    Wait 430s for [1,2,5,6] esState change to [energySaving,energySaving,notEnergySaving,notEnergySaving]
    Run Keyword and Ignore Error    Link SCOUT SCF to Configuration ID for Reporting
    ${crnti_list1}=      NSA Multi UE Attach should be Successful Custom      101      103   3      1
    ${crnti_list1}=      NSA Multi UE Attach should be Successful Custom     104      106    3      2
    ${crnti_list1}=      NSA Multi UE Attach should be Successful Custom     107      109    3      3
    MultiUE Trigger DL Traffic for NSA    101     109    Traffic_rate=mbps    dl_rate=${1}
    MultiUE Trigger UL Traffic for NSA     101      109    Traffic_rate=mbps    ul_rate=${5}
    sleep       10s
    Trigger s1 gtpu path failure for 6 path
    sleep     102s
    ${major_alarm_time}    ${major_alarm_info}   Check If fault 7706 Appeared and failed paths info      Major
    sleep     102s
    ${crit_alarm_time}  ${crit_alarm_info}      Check If fault 7706 Appeared and failed paths info      Critical
    Should Contain      ${crit_alarm_info['alarmAttribute'][0]['attributeValue']}  NR:10,11,12,2,3,4,5,6

    Wait 10s for [1,2,5,6] esState change to [energySaving,notEnergySaving,notEnergySaving,notEnergySaving]
    Run Keyword and Ignore Error    Check Only Cell 1 Are Disabled with ES      offline    disabled
    Perform SCF Delta Commissioning with energy_saving_disable.json
    sleep   30s
    ${crit_alarm_time}  ${crit_alarm_info}      Check If fault 7706 Appeared and failed paths info      Critical
    Should Contain      ${crit_alarm_info['alarmAttribute'][0]['attributeValue']}  NR:1,10,11,12,2,3,4,5,6
    Wait 10s for [1,2,5,6] esState change to [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]
    Recover s1 gtpu path failure for 6 path
    sleep   20s
    Check operational State of all cells    enabled
    ute_wtssim.Execute Egate Command  cmd=ue_detach id=101-109
    sleep       100s
    Perform SCF Delta Commissioning with energy_saving_enabled.json
    sleep   30s

    Wait 1080s for [1,2,5,6] esState change to [energySaving,energySaving,energySaving,energySaving]
    ${crnti_list1}=      NSA Multi UE Attach should be Successful Custom      101      103    3      1
    ${crnti_list1}=      NSA Multi UE Attach should be Successful Custom     104      106    3      2
    ${crnti_list1}=      NSA Multi UE Attach should be Successful Custom     107      109    3      3
    MultiUE Trigger DL Traffic for NSA    101     109    Traffic_rate=mbps    dl_rate=${1}
    MultiUE Trigger UL Traffic for NSA     101      109    Traffic_rate=mbps    ul_rate=${5}
    sleep       10s
    Trigger s1 gtpu path failure for 6 path
    sleep     102s
    ${major_alarm_time}    ${major_alarm_info}   Check If fault 7706 Appeared and failed paths info      Major
    sleep     102s
    ${crit_alarm_time}  ${crit_alarm_info}      Check If fault 7706 Appeared and failed paths info      Critical
    Should Contain      ${crit_alarm_info['alarmAttribute'][0]['attributeValue']}  NR:10,11,12,3
    Wait 10s for [1,2,5,6] esState change to [energySaving,energySaving,energySaving,energySaving]
    ute_wtssim.Execute Egate Command  cmd=ue_detach id=101-109
    ${syslogpath_3}   Stop Log      btslog
    [Teardown]      Run Keywords
    ...                 Log To console  Testteardown
    ...                 AND     Run Keyword and Ignore Error     Stop Log      btslog
    ...                 AND     Run Keyword and Ignore Error        Stop Log    Snapshot    #sosreport
    ...                 AND     Run Keyword and Ignore Error    wts_sim_keywords.Clean edaemon and egate

[1]CB013396-E_B1_TC1_NSA_mode_cell_disable_enable_based_on_S1U_path_supervision_in_SA+NSA
    [Documentation]    The purpose of this TC is to verify the behaviour when CB013396 is
    ...     enabled and NSA mode of NSA only cell, SA mode of SA only cell and SA+NSA cells are disabled and degraded due to S1-U NG-U path failure
    ...             author:   megha.dm@nokia.com
    ...             maintainer: megha.dm@nokia.com
    ...             TESTING SPLIT:CB013396_E101_E201_E301
    ...             CONTACTS:    VRF_BLR1
    ...             REFERENCES: CB013396 CFAM
    ...             Requirement ID:
   [Setup]         Run keywords    Suite setup from scratch
    ...                 AND     BuiltIn.Set Suite Variable      ${SCFC}         ${default_scf}
    ...                 AND     Prepare TL with SCF change
    ...                 AND     sleep    300
    ...                 AND     Perform SCF Delta Commissioning with sa_nsa_sansa.json
    ...                 AND     sleep    300
    ...                 AND     Perform SCF Delta Commissioning with etws_sa.json
    ...                 AND     sleep    300
    ...                 AND     Perform SCF Delta Commissioning with sa_nsa_feature_enable.json
    ...                 AND     sleep    10
    ...                 AND     Add RadParam to swconfig     "0x6601EE=1"    "0x6601E0=1"    "0x8900C3=1"    IP=192.168.255.129
    ...                 AND     gnb.Perform gNB reboot
    ...                 AND     sleep    220
    ...                 AND     Configure additional UTE ETH3 IPs
    ...                 AND     sleep    60
    ...                 AND     OperatingSystem.Run    sudo ip addr add 10.0.1.151/24 dev eth3
    ...                 AND     OperatingSystem.Run    sudo ip addr add 10.0.1.152/24 dev eth3
    ...                 AND     OperatingSystem.Run    sudo ip addr add 10.0.1.171/24 dev eth3
    ...                 AND     OperatingSystem.Run    sudo ip addr add 10.0.1.172/24 dev eth3
    ...                 AND     Load CFG and verify cell status   ${wts_cfg_sa_nsa_13396}   7   7

    Start Log      btslog
    NSA X2AP Link Should be UP     ${eNB_ID}        ${eNB_target}
    sleep   30s
    Run Keyword and Ignore Error    Link SCOUT SCF to Configuration ID for Reporting
    ${crnti_list1}=      NSA Multi UE Attach should be Successful Custom      101      103   3      1
    ${crnti_list1}=      NSA Multi UE Attach should be Successful Custom     104      106    3      2
    ${crnti_list1}=      NSA Multi UE Attach should be Successful Custom     107      109    3      3
    MultiUE Trigger DL Traffic for NSA    101     109    Traffic_rate=mbps    dl_rate=${1}
    MultiUE Trigger UL Traffic for NSA     101      109    Traffic_rate=mbps    ul_rate=${5}
    sleep       10s
    Trigger s1 gtpu path failure for 6 path
    sleep     102s

    ${major_alarm_time}    ${major_alarm_info}   Check If fault 7706 Appeared and failed paths info      Major
    sleep     102s
    ${crit_alarm_time}  ${crit_alarm_info}      Check If fault 7706 Appeared and failed paths info      Critical
    ${exp_degraded}=    Create List    1    10    11    12    2    5    6
    ${exp_faulty}=      Create List    3    4
    Validate Fault Cell Info    ${crit_alarm_info}    ${exp_degraded}    ${exp_faulty}
    sleep    10s
    ute_wtssim.Execute Egate Command  cmd=sgw_trigger id=2 skip_echo_req=10.0.1.151,10.0.1.13,0
    Verify nsa cells are enabled
    sleep   10s
    Recover s1 gtpu path failure for 6 path
    ${ue_detach_cmd}    SET VARIABLE    ue_detach id=101-109
    ute_wtssim.Execute Egate Command    ${ue_detach_cmd}    timeout=${EGATE_COMMAND_TIMEOUT}
    Sleep   30s
    ${syslogpath_1}   Stop Log      btslog

    Start Log      btslog
    Attach sa ues and send traffic
    sleep       10s
    Trigger gtpu path failure for 6 paths sa
    sleep       70s
    ${major_alarm_time}    ${major_alarm_info}   Check If fault 7706 Appeared and failed paths info      Major
    sleep     102s
    ${crit_alarm_time}  ${crit_alarm_info}      Check If fault 7706 Appeared and failed paths info      Critical

    ${exp_degraded}=    Create List    1    10    11    12    2    5    6
    ${exp_faulty}=      Create List    7     8     9
    Validate Fault Cell Info    ${crit_alarm_info}    ${exp_degraded}    ${exp_faulty}
    sleep    10s
    ute_wtssim.Execute Egate Command  cmd=upf_param id=3 skip_echo_req=10.0.1.5,10.0.1.2,0
    sleep   10s
    Verify sa cells are enabled
    Recover gtpu path failure for 6 paths sa
    ${ue_dereg_cmd}    SET VARIABLE    ue_deregister id=51-65 ue_deregister_type=switch_off by=ue
    ute_wtssim.Execute Egate Command    ${ue_dereg_cmd}    timeout=${EGATE_COMMAND_TIMEOUT}
    ${syslogpath_2}   Stop Log      btslog
    sleep   30s

    Start Log      btslog
    Attach sa ues and send traffic
    sleep       30s
    ${crnti_list1}=      NSA Multi UE Attach should be Successful Custom      101      103   3      1
    ${crnti_list1}=      NSA Multi UE Attach should be Successful Custom     104      106    3      2
    ${crnti_list1}=      NSA Multi UE Attach should be Successful Custom     107      109    3      3
    MultiUE Trigger DL Traffic for NSA    101     109    Traffic_rate=mbps    dl_rate=${1}
    MultiUE Trigger UL Traffic for NSA     101      109    Traffic_rate=mbps    ul_rate=${5}
    sleep       10s
    Trigger s1 gtpu path failure for 6 path
    sleep       5s
    Trigger gtpu path failure for 6 paths sa
    sleep       70s

    ${major_alarm_time}    ${major_alarm_info}   Check If fault 7706 Appeared and failed paths info      Major
    sleep     102s
    ${crit_alarm_time}  ${crit_alarm_info}      Check If fault 7706 Appeared and failed paths info      Critical
    Should Contain      ${crit_alarm_info['alarmAttribute'][0]['attributeValue']}  NR:all

    ute_wtssim.Execute Egate Command  cmd=sgw_trigger id=2 skip_echo_req=10.0.1.151,10.0.1.13,0
    sleep   30s
    Verify nsa cells are enabled
    ${crit_alarm_time}  ${crit_alarm_info}      Check If fault 7706 Appeared and failed paths info      Critical
    ${exp_degraded}=    Create List    1    10    11    12    2    5    6
    ${exp_faulty}=      Create List    7    8     9
    Validate Fault Cell Info    ${crit_alarm_info}    ${exp_degraded}    ${exp_faulty}

    ute_wtssim.Execute Egate Command  cmd=upf_param id=3 skip_echo_req=10.0.1.5,10.0.1.2,0
    sleep   30s
    Verify sa cells are enabled
    Check If fault not Appeared     7706        Critical
    sleep   10s
    ${ue_dereg_cmd}    SET VARIABLE    ue_deregister id=51-65 ue_deregister_type=switch_off by=ue
    ute_wtssim.Execute Egate Command    ${ue_dereg_cmd}    timeout=${EGATE_COMMAND_TIMEOUT}
    sleep   10s
    ${ue_detach_cmd}    SET VARIABLE    ue_detach id=101-109
    ute_wtssim.Execute Egate Command    ${ue_detach_cmd}    timeout=${EGATE_COMMAND_TIMEOUT}

    Recover gtpu path failure for 6 paths sa
    sleep   10s
    Recover s1 gtpu path failure for 6 path
    sleep   10s

    Attach sa ues and send traffic
    sleep       10s
    Trigger ETWS
    Trigger gtpu path failure for 6 paths sa
    sleep       70s
    ${major_alarm_time}    ${major_alarm_info}   Check If fault 7706 Appeared and failed paths info      Major
    sleep     102s
    Check If fault not Appeared     7706        Critical
    Check Barred State of All Cells     barred
    Stop ETWS
    Recover gtpu path failure for 6 paths sa
    ${ue_dereg_cmd}    SET VARIABLE    ue_deregister id=51-65 ue_deregister_type=switch_off by=ue
    ute_wtssim.Execute Egate Command    ${ue_dereg_cmd}    timeout=${EGATE_COMMAND_TIMEOUT}
    sleep   30s

    Attach sa ues and send traffic
    sleep       10s
    Trigger ETWS
    Trigger gtpu path failure for 6 paths sa
    sleep       70s
    ${major_alarm_time}    ${major_alarm_info}   Check If fault 7706 Appeared and failed paths info      Major
    sleep     102s
    Check If fault not Appeared     7706        Critical
    Check Barred State of All Cells     barred
    Recover gtpu path failure for 6 paths sa
    sleep   20s
    Check Barred State of All Cells     unbarred
    Stop ETWS
    ${ue_dereg_cmd}    SET VARIABLE    ue_deregister id=51-65 ue_deregister_type=switch_off by=ue
    ute_wtssim.Execute Egate Command    ${ue_dereg_cmd}    timeout=${EGATE_COMMAND_TIMEOUT}
    sleep   30s

    Attach sa ues and send traffic
    sleep       10s
    Trigger gtpu path failure for 6 paths sa
    Trigger CMAS
    sleep       70s
    ${major_alarm_time}    ${major_alarm_info}   Check If fault 7706 Appeared and failed paths info      Major
    sleep     102s
    Check If fault not Appeared     7706        Critical
    Check Barred State of All Cells     barred
    ${ue_dereg_cmd}    SET VARIABLE    ue_deregister id=51-65 ue_deregister_type=switch_off by=ue
    ute_wtssim.Execute Egate Command    ${ue_dereg_cmd}    timeout=${EGATE_COMMAND_TIMEOUT}
    ${syslogpath_3}   Stop Log      btslog

    [Teardown]      Run Keywords
    ...                 Log To console  Testteardown
    ...                 AND     Run Keyword and Ignore Error     Stop Log      btslog
    ...                 AND     Run Keyword and Ignore Error        Stop Log    Snapshot    #sosreport
    ...                 AND     Run Keyword and Ignore Error    wts_sim_keywords.Clean edaemon and egate

[1]CB013396-E_IWK2_TC32_alt_3_4_d_NGC_link_recoverey_when_failure_was_on_S1U_X2C_NGU_NGC
    [Documentation]    The purpose of this TC is to verify NGC link recoverey when failure is on S1U X2C NGU NGC
    ...             author:   megha.dm@nokia.com
    ...             maintainer: megha.dm@nokia.com
    ...             TESTING SPLIT:CB013396_E101_E201_E301
    ...             CONTACTS:    VRF_BLR1
    ...             REFERENCES: CB013396 CFAM
    ...             Requirement ID:
   [Setup]         Run keywords    Suite setup from scratch
    ...                 AND     Update bsr package_TMO_65
    ...                 AND     BuiltIn.Set Suite Variable      ${SCFC}         ${default_scf}
    ...                 AND     Prepare TL with SCF change
    ...                 AND     sleep    300
    ...                 AND     Perform SCF Delta Commissioning with sa_nsa_sansa.json
    ...                 AND     sleep    300
    ...                 AND     Perform SCF Delta Commissioning with sa_nsa_feature_enable.json
    ...                 AND     sleep    10
    ...                 AND     Add RadParam to swconfig     "0x6601EE=1"    "0x6601E0=1"    "0x8900C3=1"    IP=192.168.255.129
    ...                 AND     gnb.Perform gNB reboot
    ...                 AND     sleep    220
    ...                 AND     Configure additional UTE ETH3 IPs
    ...                 AND     sleep    60
    ...                 AND     OperatingSystem.Run    sudo ip addr add 10.0.1.151/24 dev eth3
    ...                 AND     OperatingSystem.Run    sudo ip addr add 10.0.1.152/24 dev eth3
    ...                 AND     OperatingSystem.Run    sudo ip addr add 10.0.1.171/24 dev eth3
    ...                 AND     OperatingSystem.Run    sudo ip addr add 10.0.1.172/24 dev eth3
    ...                 AND     Load CFG and verify cell status   ${wts_cfg_sa_nsa_13396}   7   7

    Start Log      btslog
    NSA X2AP Link Should be UP     ${eNB_ID}        ${eNB_target}
    sleep   30s
    Run Keyword and Ignore Error    Link SCOUT SCF to Configuration ID for Reporting
    ${crnti_list1}=      NSA Multi UE Attach should be Successful Custom      101      103   3      1
    ${crnti_list1}=      NSA Multi UE Attach should be Successful Custom     104      106    3      2
    ${crnti_list1}=      NSA Multi UE Attach should be Successful Custom     107      109    3      3
    MultiUE Trigger DL Traffic for NSA    101     109    Traffic_rate=mbps    dl_rate=${1}
    MultiUE Trigger UL Traffic for NSA     101      109    Traffic_rate=mbps    ul_rate=${5}
    sleep       10s
    Trigger s1 gtpu path failure for 6 path
    sleep     102s

    ${major_alarm_time}    ${major_alarm_info}   Check If fault 7706 Appeared and failed paths info      Major
    sleep     102s
    ${crit_alarm_time}  ${crit_alarm_info}      Check If fault 7706 Appeared and failed paths info      Critical
    ${exp_degraded}=    Create List    1    10    11    12    2    5    6
    ${exp_faulty}=      Create List    3    4
    Validate Fault Cell Info    ${crit_alarm_info}    ${exp_degraded}    ${exp_faulty}
    sleep    10s

    ${syslogpath_1}   Stop Log      btslog

	Start Log      btslog
	${link_lock3}    SET VARIABLE    link_lock at=enb:3 link=x2 to=gnb:2
	ute_wtssim.Execute Egate Command   ${link_lock3}    timeout=${EGATE_COMMAND_TIMEOUT}
	Check if fault 7107 is not raised
	${link_unlock3}    SET VARIABLE    link_unlock at=enb:3 link=x2 to=gnb:2
	ute_wtssim.Execute Egate Command   ${link_unlock3}    timeout=${EGATE_COMMAND_TIMEOUT}
	${syslogpath_2}   Stop Log      btslog

    Start Log      btslog
    Attach sa ues and send traffic
    sleep       10s
    Trigger gtpu path failure for 6 paths sa
    sleep       70s
    ${major_alarm_time}    ${major_alarm_info}   Check If fault 7706 Appeared and failed paths info      Major
    sleep     62s
    ${crit_alarm_time}  ${crit_alarm_info}      Check If fault 7706 Appeared and failed paths info      Critical
    Should Contain      ${crit_alarm_info['alarmAttribute'][0]['attributeValue']}  NR:all
    Check Availability and operational State of all cells        failed       disabled
    sleep    10s
    ${syslogpath_3}   Stop Log      btslog
    sleep   30s


	Start Log      btslog
    ${output}=     Run    sshpass -p oZPS0POrRieRtu ssh -q toor4nsn@192.168.255.129 iptables -A INPUT -p sctp --dport 38412 -j DROP
    Sleep   60s
    Check Availability and operational State of all cells        failed       disabled
	${crit_alarm_time}  ${crit_alarm_info}      Check If fault 7706 Appeared and failed paths info      Critical
    Check if fault 7107 is not raised
    ${syslogpath_4}   Stop Log      btslog

	${output}=     Run    sshpass -p oZPS0POrRieRtu ssh -q toor4nsn@192.168.255.129 iptables -D INPUT -p sctp --dport 38412 -j DROP
    Sleep   60s
	Check Availability and operational State of all cells        failed       disabled
	${crit_alarm_time}  ${crit_alarm_info}      Check If fault 7706 Appeared and failed paths info      Critical
    Check if fault 7107 is not raised


    Recover s1 gtpu path failure for 6 path
    sleep		20s
    ${crit_alarm_time}  ${crit_alarm_info}      Check If fault 7706 Appeared and failed paths info      Critical
    Should Contain      ${crit_alarm_info['alarmAttribute'][0]['attributeValue']}  NR:1,10,11,12,2,5,6

    Recover gtpu path failure for 6 paths sa
    sleep		60s
    Check if fault 7706 is not raised
    sleep		60s
    Verify sa cells are enabled
	sleep		60s
    ${ue_dereg_cmd}    SET VARIABLE    ue_deregister id=51-65 ue_deregister_type=switch_off by=ue
    ute_wtssim.Execute Egate Command    ${ue_dereg_cmd}    timeout=${EGATE_COMMAND_TIMEOUT}
    ${ue_dereg_cmd}    SET VARIABLE    ue_detach id=101-109
    ute_wtssim.Execute Egate Command    ${ue_dereg_cmd}    timeout=${EGATE_COMMAND_TIMEOUT}
    sleep    5s
	Start Log      btslog
    Attach sa ues and send traffic
    ${crnti_list1}=      NSA Multi UE Attach should be Successful Custom      101      103   3      1
    ${crnti_list1}=      NSA Multi UE Attach should be Successful Custom     104      106    3      2
    ${crnti_list1}=      NSA Multi UE Attach should be Successful Custom     107      109    3      3
    sleep       10s
    Trigger gtpu path failure for 6 paths sa
    sleep       70s
    ${major_alarm_time}    ${major_alarm_info}   Check If fault 7706 Appeared and failed paths info      Major
    sleep     65s
    ${crit_alarm_time}  ${crit_alarm_info}      Check If fault 7706 Appeared and failed paths info      Critical
    Should Contain      ${crit_alarm_info['alarmAttribute'][0]['attributeValue']}  NR:1,10,11,12,2,5,6
    sleep    30s
    Verify all sa cells are disabled


    [Teardown]      Run Keywords
    ...                 Log To console  Testteardown
    ...                 AND     Run Keyword and Ignore Error     Stop Log      btslog
    ...                 AND     Run Keyword and Ignore Error        Stop Log    Snapshot    #sosreport
    ...                 AND     Run Keyword and Ignore Error    wts_sim_keywords.Clean edaemon and egate

[1]CB013396-E_IWK6_SANSA_Cell_disable_and_enable_based_on_NG-U_and_S1-U_GTP-U_path_supervision_and_energysaving
    [Documentation]    The purpose of this TC is to verify the behaviour when CB013396 is
    ...     enabled and SANSA mode of SA only, NSA only cells and SA+NSA cells are disabled and degraded due to S1-U NG-U path failure
    ...     and energy saving
    ...             author:   megha.dm@nokia.com
    ...             maintainer: megha.dm@nokia.com
    ...             TESTING SPLIT:CB013396_IWK6
    ...             CONTACTS:    VRF_BLR1
    ...             REFERENCES: CB013396 CFAM
    ...             Requirement ID:
   [Setup]         Run keywords    Suite setup from scratch
    ...                 AND     BuiltIn.Set Suite Variable      ${SCFC}         ${default_scf}
    ...                 AND     Prepare TL with SCF change
    ...                 AND     sleep    300
    ...                 AND     Perform SCF Delta Commissioning with sa_nsa_sansa.json
    ...                 AND     sleep    300
    ...                 AND     Perform SCF Delta Commissioning with etws_sa.json
    ...                 AND     sleep    300
    ...                 AND     Perform SCF Delta Commissioning with sa_nsa_feature_enable1.json
    ...                 AND     sleep    30
    ...                 AND     Perform SCF Delta Commissioning with energy_saving_sansa.json
    ...                 AND     sleep    10
    ...                 AND     Add RadParam to swconfig     "0x6601EE=1"    "0x6601E0=1"    "0x8900C3=1"    IP=192.168.255.129
    ...                 AND     gnb.Perform gNB reboot
    ...                 AND     sleep    220
    ...                 AND     Configure additional UTE ETH3 IPs
    ...                 AND     sleep    60
    ...                 AND     OperatingSystem.Run    sudo ip addr add 10.0.1.151/24 dev eth3
    ...                 AND     OperatingSystem.Run    sudo ip addr add 10.0.1.152/24 dev eth3
    ...                 AND     OperatingSystem.Run    sudo ip addr add 10.0.1.171/24 dev eth3
    ...                 AND     OperatingSystem.Run    sudo ip addr add 10.0.1.172/24 dev eth3
    ...                 AND     Load CFG and verify cell status   ${wts_cfg_sa_nsa_13396}   7   7

    Start Log      btslog
    NSA X2AP Link Should be UP     ${eNB_ID}        ${eNB_target}
    sleep   30s
    Run Keyword and Ignore Error    Link SCOUT SCF to Configuration ID for Reporting

    Wait 10s for [1,2,3,7] esState change to [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]
    Wait 330s for [1,2,3,7] esState change to [energySaving,notEnergySaving,notEnergySaving,notEnergySaving]
    Run Keyword and Ignore Error    Link SCOUT SCF to Configuration ID for Reporting
	Multi UE Register should be Successful with upfid And send traffic     71     73    1     1      1     1
    Multi UE Register should be Successful with upfid And send traffic     74     76    1     1      1     2
    Multi UE Register should be Successful with upfid And send traffic     77     79    1     1      1     3
    sleep       10s
    Trigger gtpu path failure for 6 paths
    sleep     102s

    ${major_alarm_time}    ${major_alarm_info}   Check If fault 7706 Appeared and failed paths info      Major
    sleep     102s
    ${crit_alarm_time}  ${crit_alarm_info}      Check If fault 7706 Appeared and failed paths info      Critical
    ${exp_degraded}=    Create List    1    10    11    12    2    5    6
    ${exp_faulty}=      Create List    7    8	 9
    Validate Fault Cell Info    ${crit_alarm_info}    ${exp_degraded}    ${exp_faulty}
    sleep    10s
    Verify sa only cells are disabled and sa mode of sansa cells are in degraded state

    sleep   30s
    Recover gtpu path failure for 1 paths sa
    sleep       60s
    Verify all cells are enabled

#NSA Only
    Wait 10s for [1,2,3,7] esState change to [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]
    Wait 330s for [1,2,3,7] esState change to [energySaving,notEnergySaving,notEnergySaving,notEnergySaving]

    ${crnti_list1}=      NSA Multi UE Attach should be Successful Custom      101      103   3      1
    ${crnti_list1}=      NSA Multi UE Attach should be Successful Custom     104      106    3      2
    ${crnti_list1}=      NSA Multi UE Attach should be Successful Custom     107      109    3      3
    MultiUE Trigger DL Traffic for NSA    101     109    Traffic_rate=mbps    dl_rate=${1}
    MultiUE Trigger UL Traffic for NSA     101      109    Traffic_rate=mbps    ul_rate=${5}
    sleep       10s
    Trigger s1 gtpu path failure for 6 path
    sleep     102s

    ${major_alarm_time}    ${major_alarm_info}   Check If fault 7706 Appeared and failed paths info      Major
    sleep     102s
    ${crit_alarm_time}  ${crit_alarm_info}      Check If fault 7706 Appeared and failed paths info      Critical
    sleep    30s
    ${exp_degraded}=    Create List    1    10    11    12    2    5    6
    ${exp_faulty}=      Create List   3     4
    Validate Fault Cell Info    ${crit_alarm_info}    ${exp_degraded}    ${exp_faulty}
    sleep    10s
    Verify nsa only cells are disabled and nsa mode of sansa cells are in degraded state

    sleep   1s
    Recover S1 Gtpu Path Failure For 1 Path
    sleep   30s
    Verify all cells are enabled
    Wait 10s for [1,2,3,7] esState change to [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]
    sleep   10s
    ute_wtssim.Execute Egate Command  cmd=ue_detach id=101-109
    sleep       50s
	ute_wtssim.Execute Egate Command  cmd=ue_deregister id=71-79
    sleep       50s

#SA Only NSA Only
    Wait 1230s for [1,2,3,7] esState change to [energySaving,energySaving,energySaving,energySaving]

    Multi UE Register should be Successful with upfid And send traffic     71     73    1     1      1     1
    Multi UE Register should be Successful with upfid And send traffic     74     76    1     1      1     2
    Multi UE Register should be Successful with upfid And send traffic     77     79    1     1      1     3
    sleep       10s
    Trigger gtpu path failure for 6 paths
    sleep     102s

   ${major_alarm_time}    ${major_alarm_info}   Check If fault 7706 Appeared and failed paths info      Major
    sleep     102s
    ${crit_alarm_time}  ${crit_alarm_info}      Check If fault 7706 Appeared and failed paths info      Critical
    ${exp_degraded}=    Create List    10    11    12   5    6
    ${exp_faulty}=      Create List    8	 9
    Validate Fault Cell Info    ${crit_alarm_info}    ${exp_degraded}    ${exp_faulty}
    sleep    10s
#cell status
    Wait 10s for [1,2,3,7] esState change to [energySaving,energySaving,energySaving,energySaving]

    ${crnti_list1}=      NSA Multi UE Attach should be Successful Custom      101      103   4      1
    ${crnti_list1}=      NSA Multi UE Attach should be Successful Custom     104      106    4      2
    ${crnti_list1}=      NSA Multi UE Attach should be Successful Custom     107      109    4      3
    MultiUE Trigger DL Traffic for NSA    101     109    Traffic_rate=mbps    dl_rate=${1}
    MultiUE Trigger UL Traffic for NSA     101      109    Traffic_rate=mbps    ul_rate=${5}
    sleep       10s
    Trigger s1 gtpu path failure for 6 path
    sleep     102s

    ${crit_alarm_time}  ${crit_alarm_info}      Check If fault 7706 Appeared and failed paths info      Critical
    Should Contain      ${crit_alarm_info['alarmAttribute'][0]['attributeValue']}   NR:10,11,12,4,5,6,8,9

    Perform SCF Delta Commissioning with feature_disabled.json
    sleep   60s
    Check if fault 7706 is not raised
    sleep   30s
    Wait 10s for [1,2,3,7] esState change to [energySaving,energySaving,energySaving,energySaving]
    Perform SCF Delta Commissioning with energy_saving_disable.json
    Wait 10s for [1,2,3,7] esState change to [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]

   [Teardown]      Run Keywords
    ...                 Log To console  Testteardown
    ...                 AND     Run Keyword and Ignore Error     Stop Log      btslog
    ...                 AND     Run Keyword and Ignore Error        Stop Log    Snapshot    #sosreport
    ...                 AND     Run Keyword and Ignore Error    wts_sim_keywords.Clean edaemon and egate

[1]CB013396-E_IWK3_TC1_alt1_SA_mode_enable_failure_due_to_configuration_update_procedure_then_NGU_path_failure
    [Documentation]    The purpose of this TC is to verify NGC link recoverey when failure is on S1U X2C NGU NGC
    ...             author:   megha.dm@nokia.com
    ...             maintainer: megha.dm@nokia.com
    ...             TESTING SPLIT:CB013396_E101_E201_E301
    ...             CONTACTS:    VRF_BLR1
    ...             REFERENCES: CB013396 CFAM
    ...             Requirement ID:
   [Setup]         Run keywords    Suite setup from scratch
    ...                 AND     Update bsr package_TMO_65
    ...                 AND     BuiltIn.Set Suite Variable      ${SCFC}         ${default_scf}
    ...                 AND     Prepare TL with SCF change
    ...                 AND     sleep    300
    ...                 AND     Perform SCF Delta Commissioning with sa_nsa_sansa.json
    ...                 AND     sleep    300
    ...                 AND     Perform SCF Delta Commissioning with sa_nsa_feature_enable.json
    ...                 AND     sleep    10
	...                 AND     Perform SCF Delta Commissioning with reattempt.json
    ...                 AND     sleep    10
    ...                 AND     Add RadParam to swconfig     "0x6601EE=1"    "0x6601E0=1"    "0x8900C3=1"    IP=192.168.255.129
    ...                 AND     gnb.Perform gNB reboot
    ...                 AND     sleep    220
    ...                 AND     Configure additional UTE ETH3 IPs
    ...                 AND     sleep    60
    ...                 AND     OperatingSystem.Run    sudo ip addr add 10.0.1.151/24 dev eth3
    ...                 AND     OperatingSystem.Run    sudo ip addr add 10.0.1.152/24 dev eth3
    ...                 AND     OperatingSystem.Run    sudo ip addr add 10.0.1.171/24 dev eth3
    ...                 AND     OperatingSystem.Run    sudo ip addr add 10.0.1.172/24 dev eth3
    ...                 AND     Load CFG and verify cell status   ${wts_cfg_sa_nsa_13396}   7   7

    Start Log      btslog
    NSA X2AP Link Should be UP     ${eNB_ID}        ${eNB_target}
    sleep   30s
    Run Keyword and Ignore Error    Link SCOUT SCF to Configuration ID for Reporting
    sleep       10s
	${syslogpath_1}   Stop Log      btslog
    Start Log      btslog
    Sleep   5s
    Perform SCF Delta Commissioning with cell_deletion.json
    execute egate command    cmd=link_x2_management_abnormal_cases id=1 endc_cfg_update_rsp=no_rsp partner=2
    Sleep   5s
    execute egate command    cmd=amf_ran_config_update_param id=1 gnb=2 action=ignore ntimes=30
    Sleep   5s
    Perform SCF Delta Commissioning with cell_addition.json
    Sleep   900s
#    Check Fault Exist In Current Alarm    7101
    Check Fault Exist In Current Alarm    7101    12    True
	Sleep   5s
##3for nrcell5 and 6 chk severity

    ${crnti_list1}=      NSA Multi UE Attach should be Successful Custom      101      103   3      1
    ${crnti_list1}=      NSA Multi UE Attach should be Successful Custom     104      106    3      2
    ${crnti_list1}=      NSA Multi UE Attach should be Successful Custom     107      109    3      3
    MultiUE Trigger DL Traffic for NSA    101     109    Traffic_rate=mbps    dl_rate=${1}
    MultiUE Trigger UL Traffic for NSA     101      109    Traffic_rate=mbps    ul_rate=${5}
    sleep       10s
    Attach sa ues and send traffic
    Trigger s1 gtpu path failure for 6 path
    sleep     102s

    ${major_alarm_time}    ${major_alarm_info}   Check If fault 7706 Appeared and failed paths info      Major
    sleep     102s
    ${crit_alarm_time}  ${crit_alarm_info}      Check If fault 7706 Appeared and failed paths info      Critical
    ${exp_degraded}=    Create List    1    10    11    2    5    6
    ${exp_faulty}=      Create List    12	 3    4
    Validate Fault Cell Info    ${crit_alarm_info}    ${exp_degraded}    ${exp_faulty}
	${syslogpath_4}   Stop Log      btslog
    sleep    10s


	Start Log      btslog
    Trigger gtpu path failure for 6 paths sa
    sleep       120s
    ${major_alarm_time}    ${major_alarm_info}   Check If fault 7706 Appeared and failed paths info      Major
    sleep     62s
    ${crit_alarm_time}  ${crit_alarm_info}      Check If fault 7706 Appeared and failed paths info      Critical
#    Should Contain      ${crit_alarm_info['alarmAttribute'][0]['attributeValue']}  NR:1,10,11,2,3,4,5,6
    Should Contain      ${crit_alarm_info['alarmAttribute'][0]['attributeValue']}  NR:all

    Check Fault Exist In Current Alarm    7101    12    True
#	Check Fault Exist In Current Alarm    7101      True
    sleep     62s
    Check Availability and operational State of all cells        failed       disabled
    sleep    10s
    ${syslogpath_5}   Stop Log      btslog
    sleep   30s

    Recover s1 gtpu path failure for 6 path
    sleep		240s
    ${crit_alarm_time}  ${crit_alarm_info}      Check If fault 7706 Appeared and failed paths info      Critical
    Should Contain      ${crit_alarm_info['alarmAttribute'][0]['attributeValue']}  NR:1,10,11,2,5,6,7,8,9

    Recover gtpu path failure for 6 paths sa
    sleep		300s
    Check if fault 7706 is not raised
    sleep		60s
    Check Fault raised for other cells     7101     True
    [Teardown]      Run Keywords
    ...                 Log To console  Testteardown
    ...                 AND     Run Keyword and Ignore Error     Stop Log      btslog
    ...                 AND     Run Keyword and Ignore Error        Stop Log    Snapshot    #sosreport
    ...                 AND     Run Keyword and Ignore Error    wts_sim_keywords.Clean edaemon and egate


[1]CB013396-E_IWK2_BEP_CRT_enhancement
    [Documentation]    The purpose of this TC is to verify NGC link recoverey when failure is on S1U X2C NGU NGC
    ...             author:   megha.dm@nokia.com
    ...             maintainer: megha.dm@nokia.com
    ...             TESTING SPLIT:CB013396_E101_E201_E301
    ...             CONTACTS:    VRF_BLR1
    ...             REFERENCES: CB013396 CFAM
    ...             Requirement ID:
   [Setup]         Run keywords    Suite setup from scratch
    ...                 AND     Update bsr package_TMO_65
    ...                 AND     BuiltIn.Set Suite Variable      ${SCFC}         ${default_scf}
    ...                 AND     Prepare TL with SCF change
    ...                 AND     sleep    300
    ...                 AND     Perform SCF Delta Commissioning with sa_nsa_sansa.json
    ...                 AND     sleep    300
    ...                 AND     Perform SCF Delta Commissioning with sa_nsa_feature_enable.json
    ...                 AND     sleep    10
	...                 AND     Perform SCF Delta Commissioning with reattempt.json
    ...                 AND     sleep    10
    ...                 AND     Add RadParam to swconfig     "0x6601EE=1"    "0x6601E0=1"    "0x8900C3=1"    IP=192.168.255.129
    ...                 AND     gnb.Perform gNB reboot
    ...                 AND     sleep    220
    ...                 AND     Configure additional UTE ETH3 IPs
    ...                 AND     sleep    60
    ...                 AND     OperatingSystem.Run    sudo ip addr add 10.0.1.151/24 dev eth3
    ...                 AND     OperatingSystem.Run    sudo ip addr add 10.0.1.152/24 dev eth3
    ...                 AND     OperatingSystem.Run    sudo ip addr add 10.0.1.171/24 dev eth3
    ...                 AND     OperatingSystem.Run    sudo ip addr add 10.0.1.172/24 dev eth3
    ...                 AND     Load CFG and verify cell status   ${wts_cfg_sa_nsa_13396}   7   7

    Start Log      btslog
    NSA X2AP Link Should be UP     ${eNB_ID}        ${eNB_target}
    sleep   30s
    Run Keyword and Ignore Error    Link SCOUT SCF to Configuration ID for Reporting
    sleep       10s
	${syslogpath_1}   Stop Log      btslog
    Start Log      btslog
    Sleep   5s
   # Perform SCF Delta Commissioning with cell_deletion.json
    execute egate command    cmd=link_x2_management_abnormal_cases id=1 endc_cfg_update_rsp=no_rsp partner=2
    Sleep   5s
	Cell Block Or Unblock    12    True
    Sleep   15s
    Cell Block Or Unblock   12   False
	Sleep   120s
    Check Fault Exist In Current Alarm    7101    12    True
    Sleep   5s
###major 7101 nsa
    Attach sa ues and send traffic
	Trigger gtpu path failure for 6 paths sa
    sleep       120s
#degraded_cells:	NR:1,10,11,2,5,6
#faulty_cells:	NR:12,7,8,9
#critical 7101
    ${major_alarm_time}    ${major_alarm_info}   Check If fault 7706 Appeared and failed paths info      Major
    sleep     62s
    ${crit_alarm_time}  ${crit_alarm_info}      Check If fault 7706 Appeared and failed paths info      Critical
    Should Contain      ${crit_alarm_info['alarmAttribute'][0]['attributeValue']}  NR:1,10,11,2,5,6

	${syslogpath_2}   Stop Log      btslog
    sleep    10s
	Check Fault Exist In Current Alarm    7101    12    True  ####critical 7101 nsa
	Sleep   5s
	execute egate command    cmd=link_x2_management_abnormal_cases id=1 endc_cfg_update_rsp=normal_rsp partner=2
    Sleep   5s
	Cell Block Or Unblock    12    True
    Sleep   15s
    Cell Block Or Unblock   12   False
	Sleep   120s
	Check Fault Exist In Current Alarm    7101    12    False
	Sleep   5s
    Recover gtpu path failure for 6 paths sa
    sleep		300s
	Verify sa cells are enabled
	sleep		60s

	Perform SCF Delta Commissioning with cell_deletion.json
	Sleep   5s
    execute egate command    cmd=amf_ran_config_update_param id=1 gnb=2 action=ignore ntimes=30
    Sleep   5s
    Perform SCF Delta Commissioning with cell_addition.json
    Sleep   900s
    Check Fault Exist In Current Alarm    7101    12    True    #major sa
	sleep       10s
	${crnti_list1}=      NSA Multi UE Attach should be Successful Custom      101      103   3      1
    ${crnti_list1}=      NSA Multi UE Attach should be Successful Custom     104      106    3      2
    ${crnti_list1}=      NSA Multi UE Attach should be Successful Custom     107      109    3      3
    MultiUE Trigger DL Traffic for NSA    101     109    Traffic_rate=mbps    dl_rate=${1}
    MultiUE Trigger UL Traffic for NSA     101      109    Traffic_rate=mbps    ul_rate=${5}
    sleep       10s

    Trigger s1 gtpu path failure for 6 path
    sleep     180s

	#degraded_cells:	NR:1,10,11,2,5,6
    #faulty_cells:	NR:12,3,4
    ${major_alarm_time}    ${major_alarm_info}   Check If fault 7706 Appeared and failed paths info      Major
    sleep     102s
    ${crit_alarm_time}  ${crit_alarm_info}      Check If fault 7706 Appeared and failed paths info      Critical
    ${exp_degraded}=    Create List    1    10    11	 2    5    6
    ${exp_faulty}=      Create List    12	 3    4
    Validate Fault Cell Info    ${crit_alarm_info}    ${exp_degraded}    ${exp_faulty}

    Check Fault Exist In Current Alarm    7101    12    True
    Sleep   120s

    execute egate command    cmd=amf_ran_config_update_param id=1 gnb=2 action=none_action
	Sleep   5s
	Cell Block Or Unblock    12    True
    Sleep   15s
    Cell Block Or Unblock   12   False
	Sleep   120s
	Check Fault Exist In Current Alarm    7101    12    False
    Recover s1 gtpu path failure for 6 path
    sleep		240s
    Check if fault 7706 is not raised
    sleep		60s
    Verify sa cells are enabled
	sleep		60s
	[Teardown]      Run Keywords
    ...                 Log To console  Testteardown
    ...                 AND     Run Keyword and Ignore Error     Stop Log      btslog
    ...                 AND     Run Keyword and Ignore Error        Stop Log    Snapshot    #sosreport
    ...                 AND     Run Keyword and Ignore Error    wts_sim_keywords.Clean edaemon and egate



*** Keywords ***
Attach nsa ues and send traffic
    ${crnti_list1}=      NSA Multi UE Attach should be Successful Custom      101      103    1      1
    ${crnti_list1}=      NSA Multi UE Attach should be Successful Custom     104      106    1      2
    ${crnti_list1}=      NSA Multi UE Attach should be Successful Custom     107      109    1      3
    MultiUE Trigger DL Traffic for NSA    101     109    Traffic_rate=mbps    dl_rate=${1}
    MultiUE Trigger UL Traffic for NSA     101      109    Traffic_rate=mbps    ul_rate=${5}
Attach sa ues and send traffic
    Multi UE Register should be Successful with upfid And send traffic     51     55    1     1      1     1
    Multi UE Register should be Successful with upfid And send traffic     56     60    1     1      1     2
    Multi UE Register should be Successful with upfid And send traffic     61     65    1     1      1     3
Do syslog verification
    [Arguments]         ${syslogpath}
    Run Keyword and Continue on Failure    Verify monitorTimerForCellDisable       ${syslogpath}[btslog]       ${monitortimerforcelldisable}
    Run Keyword and Continue on Failure    Verify number of S1 path failed is greater minFailedPath        ${syslogpath}[btslog]
    Run Keyword and Continue on Failure    Verify number of NG path failed is greater minFailedPath        ${syslogpath}[btslog]
    Run Keyword and Continue on Failure    Verify pathRecoveryWaitTimer        ${syslogpath}[btslog]       ${pathRecoveryWaitTimer2}
Verify nsa cells are enabled
    Check Only Cells Are In Enabled State
        ...    enabled
        ...    MRBTS-1/NRBTS-1/NRCELL-1
        ...    MRBTS-1/NRBTS-1/NRCELL-2
        ...    MRBTS-1/NRBTS-1/NRCELL-5
        ...    MRBTS-1/NRBTS-1/NRCELL-6
Verify sa cells are enabled
    Check Only Cells Are In Enabled State
        ...    enabled
        ...    MRBTS-1/NRBTS-1/NRCELL-10
        ...    MRBTS-1/NRBTS-1/NRCELL-11
        ...    MRBTS-1/NRBTS-1/NRCELL-12
        ...    MRBTS-1/NRBTS-1/NRCELL-3
        ...    MRBTS-1/NRBTS-1/NRCELL-4
        ...    MRBTS-1/NRBTS-1/NRCELL-7
        ...    MRBTS-1/NRBTS-1/NRCELL-8
        ...    MRBTS-1/NRBTS-1/NRCELL-9
Verify sa cells are disabled
    Check Only Cells Are Disabled
        ...    failed
        ...    disabled
        ...    MRBTS-1/NRBTS-1/NRCELL-10
        ...    MRBTS-1/NRBTS-1/NRCELL-11
        ...    MRBTS-1/NRBTS-1/NRCELL-12
        ...    MRBTS-1/NRBTS-1/NRCELL-3
        ...    MRBTS-1/NRBTS-1/NRCELL-4
        ...    MRBTS-1/NRBTS-1/NRCELL-7
        ...    MRBTS-1/NRBTS-1/NRCELL-8
        ...    MRBTS-1/NRBTS-1/NRCELL-9
Verify all sa cells are disabled
    Check Only Cells Are Disabled
        ...    failed
        ...    disabled
#        ...    MRBTS-1/NRBTS-1/NRCELL-10
#        ...    MRBTS-1/NRBTS-1/NRCELL-11
#        ...    MRBTS-1/NRBTS-1/NRCELL-12
#        ...    MRBTS-1/NRBTS-1/NRCELL-3
#        ...    MRBTS-1/NRBTS-1/NRCELL-4
        ...    MRBTS-1/NRBTS-1/NRCELL-7
        ...    MRBTS-1/NRBTS-1/NRCELL-8
        ...    MRBTS-1/NRBTS-1/NRCELL-9
Verify nsa cells are disabled
    Check Only Cells Are Disabled
        ...    failed
        ...    disabled
        ...    MRBTS-1/NRBTS-1/NRCELL-1
        ...    MRBTS-1/NRBTS-1/NRCELL-2
        ...    MRBTS-1/NRBTS-1/NRCELL-5
        ...    MRBTS-1/NRBTS-1/NRCELL-6
Verify sa cells are disabled and nsa cells are in enabled state
    Check Only Cells Are Disabled
        ...    failed
        ...    disabled
        ...    MRBTS-1/NRBTS-1/NRCELL-10
        ...    MRBTS-1/NRBTS-1/NRCELL-11
        ...    MRBTS-1/NRBTS-1/NRCELL-12
        ...    MRBTS-1/NRBTS-1/NRCELL-3
        ...    MRBTS-1/NRBTS-1/NRCELL-4
        ...    MRBTS-1/NRBTS-1/NRCELL-7
        ...    MRBTS-1/NRBTS-1/NRCELL-8
        ...    MRBTS-1/NRBTS-1/NRCELL-9
    Check Only Cells Are In Enabled State
        ...    enabled
        ...    MRBTS-1/NRBTS-1/NRCELL-1
        ...    MRBTS-1/NRBTS-1/NRCELL-2
        ...    MRBTS-1/NRBTS-1/NRCELL-5
        ...    MRBTS-1/NRBTS-1/NRCELL-6
Verify Timer
	[Arguments]		${time1}	${time2}	${timer}
	${datastop_time}    Split String    ${time1}
    ${release_time}     Split String    ${time2}
    ${time_diff}    DateTime.Subtract time from time     ${release_time}[${1}]        ${datastop_time}[${1}]
    ${result}         Evaluate    (${timer} + 4.0) >= ${time_diff} >= (${timer} - 4.0)
    Should Be True    ${result}

Verify Pcap messages bearersetup
	[Arguments]         ${pcap_file}    ${idx}		${rfspid}
	${packet}        set variable	e1ap || f1ap || ngap
    ${pdmlFile}=   Fetch filtered PDML file from pcap    ${pcap_file}         filterExp=${packet}       filterName=UE_${idx}
	${inicontext_packet}      analyzer.get_shownames     pdmlFile=${pdmlFile}
    ...                                                packetName=ngap.InitialContextSetupRequest_element
    ...                                                path=ngap.IndexToRFSP
    ...                                                 endPacket=-${1}
    Should Contain Match          ${inicontext_packet}     IndexToRFSP: ${rfspid}
	${bearercontext_packet}      analyzer.get_shownames        pdmlFile=${pdmlFile}
    ...                                                packetName=e1ap.BearerContextSetupRequest_element
    ...                                                path=e1ap.Inactivity_Timer
    ...                                                endPacket=-${1}
    Should Contain Match          ${bearercontext_packet}         Inactivity-Timer: ${rfsp_timer}s
	${path_count}      analyzer.count_path     pdmlFile=${pdmlFile}
    ...                                                packetName=e1ap.BearerContextInactivityNotification_element
    ...                                                path=e1ap.BearerContextInactivityNotification_element$
    Should Be Equal As Numbers     ${path_count}   1
    ${path_count}      analyzer.count_path     pdmlFile=${pdmlFile}
    ...                                                packetName=f1ap.UEContextReleaseComplete_element
    ...                                                path=f1ap.UEContextReleaseComplete_element$
    Should Be Equal As Numbers     ${path_count}   1
	${bearerinact_packet}      analyzer.get_shownames     pdmlFile=${pdmlFile}
    ...                                                packetName=e1ap.BearerContextInactivityNotification_element
    ...                                                path=e1ap.uE_Activity
    ...                                                 endPacket=-${1}
    Should Contain Match          ${bearerinact_packet}     uE-Activity: not-active (1)

Set ICS with cnai
    [Arguments]     ${ueid}
    ${ics_rfsp}    SET VARIABLE    amf_ue_ics_param id=1 ue=${ueid}
    ${ics_cnai}    SET VARIABLE     core_network_assistance_info=
    ${cnaiprm}   SET VARIABLE    on ue_identity_index_value=1 ue_specific_drx=64 periodic_registration_update_timer=5:1min
    ${plmntac}  SET VARIABLE    plmn_id=311:489 tac_id=200
    Run keyword If  ${ueid}==1  Execute Egate Command    ${ics_rfsp} ${ics_cnai}${cnaiprm} ${plmntac}    ELSE
    ...    Execute Egate Command     ${ics_rfsp} ${ics_cnai}off

Modify Ue context with RFSPID
    [Arguments]     ${UE_ID}    ${indexToRSFP}
    ${ue_ctx_cmd}   SET VARIABLE    ue_ctx_ng_mod id=${UE_ID} indexToRFSP=${indexToRSFP}
    Execute Egate Command    ${ue_ctx_cmd}    timeout=${EGATE_COMMAND_TIMEOUT}

Modify PDU Session
    [Arguments]     ${UE_ID}    ${qosflow}
    ${ue_pdu_cmd}       SET VARIABLE    ue_pdu_session_modify ue=${UE_ID} pdu=1 qosflows_to_add=${qosflow} by=amf
    Execute Egate Command    ${ue_pdu_cmd}    timeout=${EGATE_COMMAND_TIMEOUT}

Verify Pcap messages bearermodify
    [Arguments]         ${pcap_file}    ${idx}      ${rfspid}
    ${packet}        set variable   e1ap || f1ap || ngap
    ${pdmlFile}=   Fetch filtered PDML file from pcap    ${pcap_file}         filterExp=${packet}       filterName=UE_${idx}
    ${uecontext_packet}      analyzer.get_shownames     pdmlFile=${pdmlFile}
    ...                                                packetName=ngap.UEContextModificationRequest_element
    ...                                                path=ngap.IndexToRFSP
    ...                                                 endPacket=-${1}
    Should Contain Match          ${uecontext_packet}     IndexToRFSP: ${rfspid}
    ${bearercontext_packet}      analyzer.get_shownames        pdmlFile=${pdmlFile}
    ...                                                packetName=e1ap.BearerContextSetupRequest_element
    ...                                                path=e1ap.Inactivity_Timer
    ...                                                endPacket=-${1}
    Should Contain Match          ${bearercontext_packet}         Inactivity-Timer: ${drbrrc_timer}s
    ${path_count}      analyzer.count_path     pdmlFile=${pdmlFile}
    ...                                                packetName=ngap.PDUSessionResourceModifyResponse_element
    ...                                                path=ngap.PDUSessionResourceModifyResponse_element$
    Should Be Equal As Numbers     ${path_count}   1
    ${path_count}      analyzer.count_path     pdmlFile=${pdmlFile}
    ...                                                packetName=f1ap.UEContextReleaseComplete_element
    ...                                                path=f1ap.UEContextReleaseComplete_element$
    Should Be Equal As Numbers     ${path_count}   1
    ${bearerinact_packet}      analyzer.get_shownames     pdmlFile=${pdmlFile}
    ...                                                packetName=e1ap.BearerContextInactivityNotification_element
    ...                                                path=e1ap.uE_Activity
    ...                                                 endPacket=-${1}
    Should Contain Match          ${bearerinact_packet}     uE-Activity: not-active (1)

Enable GBR Configuration
    wts_sim_keywords.Clean edaemon and egate
#    Perform SCF Delta Commissioning with Delta_Configuration_1CC_TDD_GBR_MultiUE_with_8379.json
#    Sleep   60
    Perform SCF Delta Commissioning with Delta_json_B_B02_fdd_tdd_aeqe.json
    sleep    60
    gnb.Perform gNB reboot
    sleep	120
    Load CFG and verify cell status   ${gbr_cfg_file}   1  1

Verify Pcap msgs ue
	[Arguments]         ${pcap_file}    ${spid}		${idx}
	${packet}        set variable	e1ap || x2ap
    ${pdmlFile}=   Fetch filtered PDML file from pcap    ${pcap_file}         filterExp=${packet}       filterName=UE_${idx}
    BuiltIn.Log     ${spid}
#	${spid_packet}      analyzer.get_shownames        pdmlFile=${pdmlFile}
#    ...                                                packetName=x2ap.SgNBAdditionRequest_element
#    ...                                                path=x2ap.SubscriberProfileIDforRFP
#    ...                                                endPacket=-${1}
#    Should Contain Match           ${spid_packet}         SubscriberProfileIDforRFP: ${spid}
#	${path_count}      analyzer.count_path     pdmlFile=${pdmlFile}
#    ...                                                packetName=x2ap.SgNBAdditionRequest_element
#    ...                                                path=x2ap.SgNBAdditionRequest_element$
#    Should Be Equal As Numbers     ${path_count}   1
	${path_count}      analyzer.count_path     pdmlFile=${pdmlFile}
    ...                                                packetName=x2ap.SgNBAdditionRequestAcknowledge_element
    ...                                                path=x2ap.SgNBAdditionRequestAcknowledge_element$
    Should Be Equal As Numbers     ${path_count}   1
	${path_count}      analyzer.count_path     pdmlFile=${pdmlFile}
    ...                                                packetName=x2ap.SgNBReleaseConfirm_element
    ...                                                path=x2ap.SgNBReleaseConfirm_element$
    Should Be Equal As Numbers          ${path_count}   1
	${path_count}      analyzer.count_path     pdmlFile=${pdmlFile}
    ...                                                packetName=x2ap.SgNBReleaseRequired_element
    ...                                                path=x2ap.SgNBReleaseRequired_element$
    Should Be Equal As Numbers     ${path_count}   1
	${path_count}      analyzer.count_path     pdmlFile=${pdmlFile}
    ...                                                packetName=e1ap.BearerContextInactivityNotification_element
    ...                                                path=e1ap.BearerContextInactivityNotification_element$
    Should Not Be Equal As Numbers     ${path_count}   0
    ${bearerinact_packet}      analyzer.get_shownames     pdmlFile=${pdmlFile}
    ...                                                packetName=e1ap.BearerContextInactivityNotification_element
    ...                                                path=e1ap.uE_Activity
    ...                                                 endPacket=-${1}
    Should Contain Match          ${bearerinact_packet}     uE-Activity: not-active (1)


Sgnb beareradd and modify
    [Arguments]     ${start_ue_id}      ${spid}
    ${bearer_add_cmd}   SET VARIABLE    bearer_add ue=${start_ue_id} id=3 filter=0 precedence=0
    Execute Egate Command    ${bearer_add_cmd}    timeout=${EGATE_COMMAND_TIMEOUT}
    ${brrmod}    SET VARIABLE    enb_ue_dc_modify ue=${start_ue_id} bearer_to_add=3 by=enb cause=RN_load_balancing type=split_scg spid=${spid}
    Execute Egate Command    ${brrmod}    timeout=${EGATE_COMMAND_TIMEOUT}

Verify Pcap msgs drb
    [Arguments]         ${pcap_file}    ${spid}     ${idx}  ${spidtimer}    ${nsa_timer}
    ${packet}        set variable   e1ap || x2ap
    ${pdmlFile}=   Fetch filtered PDML file from pcap    ${pcap_file}         filterExp=${packet}       filterName=UE_${idx}
    ${spid_packet}      analyzer.get_shownames        pdmlFile=${pdmlFile}
    ...                                                packetName=x2ap.SgNBModificationRequest_element
    ...                                                path=x2ap.SubscriberProfileIDforRFP
    ...                                                endPacket=-${1}
    Should Contain Match           ${spid_packet}         SubscriberProfileIDforRFP: ${spid}
    ${bearercontext_packet}      analyzer.get_shownames        pdmlFile=${pdmlFile}
    ...                                                packetName=e1ap.BearerContextSetupRequest_element
    ...                                                path=e1ap.dRB_Inactivity_Timer
    ...                                                endPacket=-${1}
    Should Contain           ${bearercontext_packet}         dRB-Inactivity-Timer: ${nsa_timer}s
    ${bearermodify_packet}      analyzer.get_shownames        pdmlFile=${pdmlFile}
    ...                                                packetName=e1ap.BearerContextModificationRequest_element
    ...                                                path=e1ap.dRB_Inactivity_Timer
    ...                                                endPacket=-${1}
    Should Contain           ${bearermodify_packet}         dRB-Inactivity-Timer: ${spidtimer}s
    ${bearerinact_packet}      analyzer.get_shownames     pdmlFile=${pdmlFile}
    ...                                                packetName=e1ap.BearerContextInactivityNotification_element
    ...                                                path=e1ap.DRB_Activity_Item_element
    ...                                                 endPacket=-${1}
    Should Contain Match          ${bearerinact_packet}     dRB-Activity: not-active (1)
    ${path_count}      analyzer.count_path     pdmlFile=${pdmlFile}
    ...                                                packetName=x2ap.SgNBReleaseConfirm_element
    ...                                                path=x2ap.SgNBReleaseConfirm_element$
    Should Be Equal As Numbers          ${path_count}   1
    ${path_count}      analyzer.count_path     pdmlFile=${pdmlFile}
    ...                                                packetName=x2ap.SgNBReleaseRequired_element
    ...                                                path=x2ap.SgNBReleaseRequired_element$
    Should Be Equal As Numbers     ${path_count}   1

Set ICS with index to RFSP
	[Arguments]		${ueid}		${indexRSFP}
	${ics_rfsp}    SET VARIABLE    amf_ue_ics_param id=1 ue=${ueid} indexToRFSP=${indexRSFP}
	${ics_cnai}	   SET VARIABLE 	core_network_assistance_info=
	${cnai_prm}    SET VARIABLE    on ue_identity_index_value=1 ue_specific_drx=64 periodic_registration_update_timer=5:1min plmn_id=311:489 tac_id=2
	Run keyword If	${ueid}==1	ute_wtssim.Execute Egate Command	${ics_rfsp} ${ics_cnai}${cnai_prm} 		ELSE
	...    ute_wtssim.Execute Egate Command		${ics_rfsp} ${ics_cnai}off

Verify Pcap for multiple UE
	[Arguments]    ${start_ue_id}   ${end_ue_id}
    ${timers}   Create List     ${rfsptimer}    ${rfsprrctimer}     ${rfsprrctimer}     ${drbrrctimer}
	FOR     ${i}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
	Verify Pcap messages	${ue${i}_log}[cprt]/NODECPRT_GNB.pcap		${i}	${timers}${i}
	END

Verify Pcap messages
	[Arguments]         ${pcap_file}    ${idx}		${timer}    ${rfsp_id}
    BuiltIn.Log     ${rfsp_id}
	${packet}        set variable	e1ap || f1ap || ngap
    ${pdmlFile}=   Fetch filtered PDML file from pcap    ${pcap_file}         filterExp=${packet}       filterName=UE_${idx}
	${bearercontext_packet}      analyzer.get_shownames        pdmlFile=${pdmlFile}
    ...                                                packetName=e1ap.BearerContextSetupRequest_element
    ...                                                path=e1ap.Inactivity_Timer
    ...                                                endPacket=-${1}
    Should Contain Match          ${bearercontext_packet}         Inactivity-Timer: ${timer}s
	${path_count}      analyzer.count_path     pdmlFile=${pdmlFile}
    ...                                                packetName=e1ap.BearerContextInactivityNotification_element
    ...                                                path=e1ap.BearerContextInactivityNotification_element$
    Should Be Equal As Numbers     ${path_count}   1
	${bearerinact_packet}      analyzer.get_shownames     pdmlFile=${pdmlFile}
    ...                                                packetName=e1ap.BearerContextInactivityNotification_element
    ...                                                path=e1ap.uE_Activity
	...													endPacket=-${1}
    Should Contain Match          ${bearerinact_packet}		uE-Activity: not-active (1)

Update bsr package
    Run     mkdir ${CURDIR}/BSR
    ${dllink}   Set Variable     https://artifactory-espoo1.ext.net.nokia.com:443/artifactory/mnpute-rotta-local/BSR
    ${filename}    Set variable     BSR_AQQJ_4_H4_ALN30_ARP30_P00_6TO4_60_00421_00001.zip
    Run     sudo wget ${dllink}/${filename} --user=dheerajn --password=AP33ZXKC1P9cgS4SsiuoeE23c8C -P ${CURDIR}/BSR
    coam.setup admin
    ${ret}     coam.Update Software      ${CURDIR}/BSR/BSR_AQQJ_4_H4_ALN30_ARP30_P00_6TO4_60_00421_00001.zip
    coam.teardown admin

Check If fault Appeared
    [Documentation]    This keyword checks if an  fault ID 7107 appeared and fetches additional information.
    [Arguments]     ${fault_id}   ${severity}       ${alarm_info}       ${alarm_history}
    ${alarm_found}    Set Variable    ${False}
    ${matched} =    Set Variable    False
    FOR  ${alarm}  IN  @{alarm_history}
        ${afault_id}=    Get From Dictionary    ${alarm}    faultId
        ${aseverity}=      Get From Dictionary    ${alarm}    faultSeverity
        Run Keyword If    '${afault_id}' != '${fault_id}'    Continue For Loop

        Run Keyword If
        ...   '${afault_id}'=='${fault_id}' and '${aseverity}'=='${severity}' and '${alarm['alarmAttribute'][0]['attributeValue']}'=='${alarm_info}'
        ...    Set Variable    ${matched}    True
        ...    Exit For Loop
    END
    Should Be Equal As Strings    ${matched}    True    No item matched the condition!

Check Alarm Exists With Attributes
    [Arguments]    ${alarms}    ${fault_id}    @{values}    ${attr_name}=${EMPTY}
    # ${attr_name} is optional; if empty, we'll check cellName key

    ${matched}=    Set Variable    False
    FOR    ${alarm}    IN    @{alarms}
        # Check faultId match
        ${alarm_fault_id}=    Get From Dictionary    ${alarm}    faultId
        Run Keyword If    '${alarm_fault_id}' != '${fault_id}'    Continue For Loop

        # Check attribute values if attr_name is provided
        ${matched}      Run Keyword If    '${attr_name}' != ''    Check Attribute Value In Alarm    ${alarm}    ${attr_name}    @{values}
        ${cell_name1}=   Run Keyword If    '${attr_name}' == ''     Set Variable    ${alarm['alarmAttribute'][0]['attributeValue']}
        ${cell_name2}    Run Keyword If  '${attr_name}' == 'configuration'     Set Variable      ${alarm['alarmingObjectIds'][0]['configuration']}
            FOR    ${val}    IN    @{values}
                ${matched}    Run Keyword If    '${cell_name1}' == '${val}' or '${cell_name2}' == '${val}'    Set Variable      True
            END
        Run Keyword If    ${matched}    Exit For Loop
    END

    Should Be True    ${matched}    No alarm found with faultId ${fault_id} and attribute/cell values ${values}.


Check Attribute Value In Alarm
    [Arguments]    ${alarm}    ${attr_name}    @{values}
    ${matched_attr}=    Set Variable    False
    ${attr_list}=    Get From Dictionary    ${alarm}    alarmAttribute
    FOR    ${attr}    IN    @{attr_list}
        ${name}=    Get From Dictionary    ${attr}    attributeName
        ${value}=    Get From Dictionary    ${attr}    attributeValue
        ${matched_attr}        Run Keyword If
        ...    '${name}' == '${attr_name}' and '${value}'.lower() in [v.lower() for v in @{values}]    Set Variable    True
        Run Keyword If    ${matched_attr}    Exit For Loop
    END
    [Return]    ${matched_attr}

Check Only Cell 1 Are Disabled with ES
    [Arguments]    ${expected_avail_state}    ${expected_oper_state}
    coam.setup admin    bts_host=10.0.1.2
    @{target_cells}=    Create List    MRBTS-1/NRBTS-1/NRCELL-1
    ${nr_cells}=    coam.get_cells_info
    FOR    ${nr_cell}    IN    @{nr_cells}
        ${nr_cell_dn}=    Set Variable    ${nr_cell["id"]["configuration"]}
        ${is_target_cell}=    Run Keyword And Return Status    Should Contain    @{target_cells}    ${nr_cell_dn}
        Run Keyword Unless    ${is_target_cell}    Continue For Loop

        # --- process only target cell (NRCELL-1) ---
        ${status_dict}=    Collections.Get From Dictionary    ${nr_cell}    status
        # your next steps...
    END
    Log to Console      ${expected_avail_state}    ${expected_oper_state}
    [Teardown]    coam.teardown admin

Wait ${timeout}s for [${cells_ids}] esState change to ${expected_states}
    Wait Until Keyword Succeeds  ${timeout}s  5s
    ...  Check for cells [${cells_ids}] if energySavingState equals ${expected_states}

Validate Fault Cell Info
    [Arguments]    ${crit_alarm_info}    ${expected_degraded}    ${expected_faulty}

    ${actual_degraded}=    Set Variable    ${crit_alarm_info['alarmAttribute'][0]['attributeValue'].replace('NR:', '')}
    ${actual_faulty}=      Set Variable    ${crit_alarm_info['alarmAttribute'][1]['attributeValue'].replace('NR:', '')}

    @{actual_deg_list}=    Split String    ${actual_degraded}    ,
    @{actual_fault_list}=  Split String    ${actual_faulty}      ,

    Log To Console    Degraded Cells Received: ${actual_deg_list}
    Log To Console    Faulty Cells Received: ${actual_fault_list}

    FOR    ${cell}    IN    @{expected_degraded}
        Should Contain    ${actual_deg_list}    ${cell}    Missing/Incorrect degraded cell: ${cell}
    END

    FOR    ${cell}    IN    @{expected_faulty}
        Should Contain    ${actual_fault_list}    ${cell}    Missing/Incorrect faulty cell: ${cell}
    END

Check Barred State of All Cells
    [Arguments]    ${expected_barred_state}
    coam.setup admin    bts_host=10.0.1.2

    @{all_cell_dn_list}    Create List
    ${nr_cells}    coam.get_cells_info

    FOR    ${nr_cell}    IN    @{nr_cells}
        ${nr_cell_dn}    Set Variable    ${nr_cell["id"]["configuration"]}
        Append To List    ${all_cell_dn_list}    ${nr_cell_dn}

        Run Keyword If    '${nr_cell_dn}'=='MRBTS-1/NRBTS-1/NRCELL-3' or '${nr_cell_dn}'=='MRBTS-1/NRBTS-1/NRCELL-4'    Continue For Loop

        ${status_dict}    Collections.Get From Dictionary    ${nr_cell}    status
        ${BarredStatus}   Collections.Get From Dictionary    ${status_dict}    barringStatus

        ${BarredStatus}   Convert To Lowercase    ${BarredStatus}
        ${expected_barred_state}    Convert To Lowercase    ${expected_barred_state}

        Should Be True    '${BarredStatus}' == '${expected_barred_state}'
    END

Trigger ETWS
    ${etws_primary}    SET VARIABLE     cbs_broadcast_start amf=1 etws_warn_type=0 type=etws_prim tai=all warning_msg=test repetition=15
    ${etws_secondary}   SET VARIABLE     cbs_broadcast_start amf=1 etws_warn_type=1 type=etws_sec tai=all warning_msg=test repetition=15
    ute_wtssim.Execute Egate Command    ${etws_primary}     pass_regexp=sib6     timeout=${EGATE_COMMAND_TIMEOUT}
    sleep   5s
    ute_wtssim.Execute Egate Command    ${etws_secondary}   pass_regexp=sib7     timeout=${EGATE_COMMAND_TIMEOUT}

Trigger CMAS
    ${cmas}    SET VARIABLE     cbs_broadcast_start amf=1 type=cmas concurrent=true tai=all warning_msg=test repetition=10
    ute_wtssim.Execute Egate Command    ${cmas}     pass_regexp=sib8    timeout=${EGATE_COMMAND_TIMEOUT}

Stop ETWS
     ${etws_stop}    SET VARIABLE     cbs_broadcast_stop amf=1
    ute_wtssim.Execute Egate Command    ${etws_stop}     timeout=${EGATE_COMMAND_TIMEOUT}

Check if fault 7107 is not raised
    ${status_7107}       Run keyword and Return Status       Check If fault not Appeared     7107        Critical
    ${status_7107}      Convert to string   ${status_7107}
    Should Match Regexp    ${status_7107}    False

Check if fault 7706 is not raised
    ${status_7706}       Run keyword and Return Status       Check If fault not Appeared     7706        Critical
    ${status_7706}      Convert to string   ${status_7706}
    Should Match Regexp    ${status_7706}    False

Verify sa only cells are disabled and sa mode of sansa cells are in degraded state
     Check Only Cells Are In Enabled State
        ...    enabled
        ...    MRBTS-1/NRBTS-1/NRCELL-3
        ...    MRBTS-1/NRBTS-1/NRCELL-4
    Check Only Cells Are Disabled
        ...    failed
        ...    disabled
        ...    MRBTS-1/NRBTS-1/NRCELL-7
        ...    MRBTS-1/NRBTS-1/NRCELL-8
        ...    MRBTS-1/NRBTS-1/NRCELL-9
    Check Only Cells Are In Degraded State
        ...    degraded
        ...    MRBTS-1/NRBTS-1/NRCELL-1
        ...    MRBTS-1/NRBTS-1/NRCELL-2
        ...    MRBTS-1/NRBTS-1/NRCELL-5
        ...    MRBTS-1/NRBTS-1/NRCELL-6
        ...    MRBTS-1/NRBTS-1/NRCELL-10
        ...    MRBTS-1/NRBTS-1/NRCELL-11
        ...    MRBTS-1/NRBTS-1/NRCELL-12
Verify nsa only cells are disabled and nsa mode of sansa cells are in degraded state
     Check Only Cells Are In Enabled State
        ...    enabled
        ...    MRBTS-1/NRBTS-1/NRCELL-7
        ...    MRBTS-1/NRBTS-1/NRCELL-8
        ...    MRBTS-1/NRBTS-1/NRCELL-9

    Check Only Cells Are Disabled
        ...    failed
        ...    disabled
        ...    MRBTS-1/NRBTS-1/NRCELL-3
        ...    MRBTS-1/NRBTS-1/NRCELL-4
    Check Only Cells Are In Degraded State
        ...    degraded
        ...    MRBTS-1/NRBTS-1/NRCELL-1
        ...    MRBTS-1/NRBTS-1/NRCELL-2
        ...    MRBTS-1/NRBTS-1/NRCELL-5
        ...    MRBTS-1/NRBTS-1/NRCELL-6
        ...    MRBTS-1/NRBTS-1/NRCELL-10
        ...    MRBTS-1/NRBTS-1/NRCELL-11
        ...    MRBTS-1/NRBTS-1/NRCELL-12

Verify all cells are enabled
    Check Only Cells Are In Enabled State
        ...    enabled
        ...    MRBTS-1/NRBTS-1/NRCELL-10
        ...    MRBTS-1/NRBTS-1/NRCELL-11
        ...    MRBTS-1/NRBTS-1/NRCELL-12
        ...    MRBTS-1/NRBTS-1/NRCELL-3
        ...    MRBTS-1/NRBTS-1/NRCELL-4
        ...    MRBTS-1/NRBTS-1/NRCELL-7
        ...    MRBTS-1/NRBTS-1/NRCELL-8
        ...    MRBTS-1/NRBTS-1/NRCELL-9
        ...    MRBTS-1/NRBTS-1/NRCELL-2
        ...    MRBTS-1/NRBTS-1/NRCELL-1
        ...    MRBTS-1/NRBTS-1/NRCELL-5
        ...    MRBTS-1/NRBTS-1/NRCELL-6

Check Only Cells Are In Degraded State
    [Arguments]    ${expected_avail_state}    @{expected_cells}
    coam.setup admin    bts_host=10.0.1.2
    ${nr_cells}=    coam.get_cells_info
    FOR    ${nr_cell}    IN    @{nr_cells}
        ${nr_cell_dn}=    Set Variable    ${nr_cell["id"]["configuration"]}
        ${is_target_cell}=    Evaluate
        ...    '${nr_cell_dn}' in ${expected_cells}
        IF    ${is_target_cell}
            ${status_dict}=    Get From Dictionary    ${nr_cell}    status
            Dictionary Should Contain Key
            ...    ${status_dict}    availabilityStatus
            ${availabilityState}=    Get From Dictionary
            ...    ${status_dict}    availabilityStatus
            Should Be Equal
            ...    ${availabilityState}    ${expected_avail_state}
        END
    END
    [Teardown]    coam.teardown admin

Get Alarm By Details
    [Documentation]    Getting Alarm details of GNB List of Fault Ids Active at GNB
    @{alarms}    Get GNB Alarms
    @{Alarm_Fault_Id}    Create List

    FOR    ${alarm}    IN    @{alarms}
        ${current_alarm_info}          Get From Dictionary    ${alarm}    alarmInformation
        ${current_additional_info}     Get From Dictionary    ${current_alarm_info}    alarmAdditionalInfo
        ${severity}                   Get From Dictionary    ${alarm}    severity

        ${AlarmObjectList}            Get From Dictionary    ${alarm}    alarmingObjectIds
        ${AlarmObject}                Get From List          ${AlarmObjectList}    0
        ${AlarmObjConf}               Get From Dictionary    ${AlarmObject}    configuration

        ${current_additional_fault_id}    Get From Dictionary    ${current_additional_info}    additionalFaultID

        ${row}    Create List
        ...    ${current_additional_fault_id}
        ...    ${severity}
        ...    ${AlarmObjConf}

        Append To List    ${Alarm_Fault_Id}    ${row}
    END

    [Return]    ${Alarm_Fault_Id}


#Check Fault Exist In Current Alarm
#    [Documentation]    Check Expected Alarm/Fault Exist In Current Active Alarm
#    [Arguments]    ${fault}    ${cellid}    ${Should_Exist}=True
#
#    ${Fault_id}    Evaluate    int(${fault})
#    @{Alarm_Tuples}    Get Alarm By Details
#
#    @{Found_Tuples}    Create List
#
#    FOR    ${tuple}    IN    @{Alarm_Tuples}
#        ${tuple_fault_id}    Get From List    ${tuple}    0
#        ${tuple_cell}    Get From List    ${tuple}    2
#        IF    ${tuple_fault_id} == ${Fault_id}
#            Should Be equal     ${tuple_cell}   MRBTS-1/NRBTS-1/NRCELL-${cellid}
#            Log to console      ${tuple_fault_id} is active on ${tuple_cell}
#            Append To List    ${Found_Tuples}    ${tuple}
#        END
#    END
#
#    ${Found_Count}    Get Length    ${Found_Tuples}
#
#    IF    ${Should_Exist}
#        Should Be True    ${Found_Count} > 0
#
#        Log To Console    ${Fault_id} Alarm is Active on ${Found_Count} object(s)
#    ELSE
#        Should Be Equal As Integers    ${Found_Count}    0
#        Log To Console    ${Fault_id} Alarm is not Active
#    END
#
#    [Return]    @{Found_Tuples}

Check Fault Exist In Current Alarm
    [Documentation]    Check Expected Alarm/Fault Exist In Current Active Alarm
    [Arguments]    ${fault}    ${cellid}    ${Should_Exist}=True

    ${Fault_id}    Evaluate    int(${fault})
    @{Alarm_Tuples}    Get Alarm By Details

    @{Found_Tuples}    Create List

    FOR    ${tuple}    IN    @{Alarm_Tuples}
        ${tuple_fault_id}    Get From List    ${tuple}    0
        ${tuple_severity}    Get From List    ${tuple}    1
        ${tuple_cell}        Get From List    ${tuple}    2

        IF    ${tuple_fault_id} == ${Fault_id}
            Should Be Equal     ${tuple_cell}   MRBTS-1/NRBTS-1/NRCELL-${cellid}

            Log To Console      ${tuple_fault_id} is active on ${tuple_cell}

            # ?? Show + validate severity for 7101 (no failure)
            IF    ${tuple_fault_id} == 7101
                Log To Console    Severity of 7101 is: ${tuple_severity}

                IF    '${tuple_severity}' == 'CRITICAL'
                    Log To Console    7101 severity is CRITICAL
                ELSE IF    '${tuple_severity}' == 'MAJOR'
                    Log To Console     7101 severity is MAJOR
                ELSE
                    Log To Console    7101 severity is ${tuple_severity}
                END
            END

            Append To List    ${Found_Tuples}    ${tuple}
        END
    END

    ${Found_Count}    Get Length    ${Found_Tuples}

    IF    ${Should_Exist}
        Should Be True    ${Found_Count} > 0
        Log To Console    ${Fault_id} Alarm is Active on ${Found_Count} object(s)
    ELSE
        Should Be Equal As Integers    ${Found_Count}    0
        Log To Console    ${Fault_id} Alarm is not Active
    END

    [Return]    @{Found_Tuples}

Check Fault raised for other cells
    [Documentation]    Check Expected Alarm/Fault Exist In Current Active Alarm
    [Arguments]    ${fault}    ${Should_Exist}=True

    ${Fault_id}    Evaluate    int(${fault})
    @{Alarm_Tuples}    Get Alarm By Details

    @{Found_Tuples}    Create List

    FOR    ${tuple}    IN    @{Alarm_Tuples}
        ${tuple_fault_id}    Get From List    ${tuple}    0

        IF    ${tuple_fault_id} == ${Fault_id}
            Log To Console    ${tuple_fault_id} is active
            Append To List    ${Found_Tuples}    ${tuple}
        END
    END

    ${Found_Count}    Get Length    ${Found_Tuples}

    IF    ${Should_Exist}
        Should Be True    ${Found_Count} > 0
        Log To Console    ${Fault_id} Alarm is Active (${Found_Count} occurrence(s))
    ELSE
        Should Be Equal As Integers    ${Found_Count}    0
        Log To Console    ${Fault_id} Alarm is not Active
    END

    RETURN    @{Found_Tuples}

Get GNB Alarms
    [Documentation]     This keyword is to check current alarms on gnB and return list of alarms.
    taf.sbts.oam.coam.admin.Setup Admin
    ${alarms}      	taf.sbts.oam.coam.admin.Get Alarms
    [Return]       ${alarms}
    [Teardown]     	taf.sbts.oam.coam.admin.Teardown Admin


Get GNB history Alarms
    [Documentation]     This keyword is to check current alarms on gnB and return list of alarms.
    taf.sbts.oam.coam.admin.Setup Admin
    ${alarms}      	taf.sbts.oam.coam.admin.Get Historic Alarms     severity=Major
    log to console    ${alarms}
    [Return]       ${alarms}
    [Teardown]     	taf.sbts.oam.coam.admin.Teardown Admin

Cell Block Or Unblock
    [Documentation]    This keyword is used for Either Block or Unblock
    ...        in Arguments CellId = 1 (The Cell Which we want to Block/Unblock)
    ...        block = True if you want to Block the Cell block=False if you want UnblockCell
    ...        For Usage block Ex.    Cell Block Or Unblock    CellId=5    block=True
    ...        For Usage unblock Ex.  Cell Block Or Unblock    CellId=5    block=False
    [Arguments]    ${CellId}=1    ${block}=True
    taf.sbts.oam.coam.admin.Setup Admin
    IF    ${block}
        taf.sbts.oam.coam.admin.Block Cell    MRBTS-1/NRBTS-1/NRCELL-${CellId}
    ELSE
        taf.sbts.oam.coam.admin.Unblock Cell    MRBTS-1/NRBTS-1/NRCELL-${CellId}
    END
    Sleep    2s
    taf.sbts.oam.coam.admin.Teardown Admin
