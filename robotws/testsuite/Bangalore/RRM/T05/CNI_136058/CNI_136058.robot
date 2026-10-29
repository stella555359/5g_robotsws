*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00      SBTS23R1    CONFIGURED
Documentation    :copyright: Nokia
...              :authors: Divyanshi
...              :contact: divyanshi.gupta@nokia.com

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         ../../5GET_BLR/5GC000937/resources/5GC000937_Keywords.robot
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../../5GET_BLR/resources/robot/Setup_Env.robot
Resource         ../../5GET_BLR/resources/robot/Airphone.robot
Resource         ../../5GET_BLR/resources/robot/WTS_Runner_Keywords.robot
Library      	 taf.collectors.tshark        WITH NAME    tshark
Library          OperatingSystem
Library          ta5g_pm_counters
Library          taf.sbts.oam.coam.admin
Resource         ../../5GET_BLR/resources/robot/common_log_collection.robot


Suite Setup         Run keywords    Suite setup from scratch
...                 AND     Enable_syslog_debug
...					AND		Update bsr package
...                 AND    Start Default Logging  output_dirpath=${LOG_PATH}
...                 AND    log to console   loading cfg now...
...                 AND    Start WTS Using WTS_Runner      ${wts_cfg_file}
...                 AND    Run Keyword and Ignore Error    Check gNB Bulid

Test Teardown       Link SCOUT SCF to Configuration ID for Reporting

Suite Teardown      Run Keywords   Run Keyword and Ignore Error   Kill WTS processes Using WTS_Runner
...                 AND    Stop Default Logging   output_dirpath=${LOG_PATH}
...                 AND    Run Keyword and Ignore Error   Get Snapshot
...                 AND    Run Keyword and Ignore Error   Get Sos Report

*** Variables ***
${wts_cfg_file}        /opt/iphy/latest/basic_setup.cfg
${iphy_file_path}      ${CURDIR}/config/iphy_CNI_136058.xml
${scf_file}            ${CURDIR}/config/scf/CNI_136058_RJIO.json
${WTS_DIR}             /opt/iphy/latest
${BTS_IP}              192.168.255.129
&{WTS}                 Ip=127.0.0.1        Username=ute         Connection=Wts
${UE_ID}               1
${nwslice_ID}          1
${gw_ID}               1
${Pdu_session_ID}      1
${qfi_id}              1
${epc_log_path}        /tmp/
${st_ue_id}            1
${en_ue_id}            1
@{PS_BWP}              2
@{Large_BWP}  		   1
${rtp_codec}		   custom
${bsr_package}			BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471.zip

*** Test Cases ***
Verification_of_BWP_switching_while_VONR_call_is_ongoing_with_MultiDRB_data
    [Documentation]     The purpose of this testcase is to verify BWP switching while VONR call is ongoing with MultiDRB data
	[Tags]   QC_54824     QCD_MN_RAN      QCP_RAN_VRF
	ta5g_commissioning.Send Delta Commissioning       ${scf_file}
	ta5g_pm_counters.Wait_For_Next_Full_Pm_Interval
	Start pcap collection in gNB CU		name=PS_BWP_SWITCH
	wait until keyword succeeds 	2times	5	UE Registration
	WTS_Runner_Keywords.Read WTS Output Until Pattern Matches	Bwp switch received from bwpId 1 to 2		100
	Start VONR Call
	Sleep	100s
	Capture TTI Traces and Validate UE bwpid   ${LOG_PATH}   PS_BWP   ${crnti_list}   ${PS_BWP}   ${Branch_22R1}
	wtsrunner.csi_override_testmode_nr	profile_id=1	cqi=5	cqi_mode=fixed
	wtsrunner.ue_testmode_set_nr	id=1	testmode=csi_override	profile_id=1	action=activate
	Run keyword and continue on failure		WTS_Runner_Keywords.Read WTS Output Until Pattern Matches	Bwp switch received from bwpId 2 to 1		30
	Capture TTI Traces and Validate UE bwpid   ${LOG_PATH}   Large_BWP   ${crnti_list}   ${Large_BWP}   ${Branch_22R1}
	wtsrunner.ue_testmode_set_nr	id=1	testmode=csi_override	profile_id=1	action=deactivate
	wtsrunner.ue_deregister	id=1	ue_deregister_type=switch_off
	#ta5g_pm_counters.Wait_For_Next_Full_Pm_Interval
    Sleep	100s
	${pm_counter_file}	ta5g_pm_counters.Get_Latest_Unpacked_Full_Pm_Counters_File
	verify_any_counters_in_file
    ...     M55351C00001    1    MAX_UE_ACTIVE_PWR_SAVING_BWP
    ...     M55351C00002    1    AVG_UE_ACTIVE_PWR_SAVING_BWP
    ...     M55351C01001    1    MAX_UE_CONFIG_2BWP
    ...     M55351C01002    1    AVG_UE_CONFIG_2BWP
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-1
    ...     file_path=${pm_counter_file}
    [Teardown]      Run keywords	Stop pcap collection in gNB		PS_BWP_SWITCH		${Log_Path}
	...				AND		configuration_id.Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***
UE Registration
    Run keyword and ignore error    wtsrunner.ue_deregister	id=1	ue_deregister_type=switch_off
    ${crnti_list}=   MultiUE Register should be Successful   ${st_ue_id}   ${en_ue_id}
    set test variable   ${crnti_list}

Start VONR Call
	MultiUE PDU Modfication should be Successful   1   1   pdu_id=1   qosflows_to_add=2
	Run keyword and ignore error	WTS_Runner_Keywords.Read WTS Output Until Pattern Matches	Added QosFlow with QFI:2 fiveQI:5	10
	MultiUE PDU Modfication should be Successful   1   1   pdu_id=1   qosflows_to_add=3
	Run keyword and ignore error	WTS_Runner_Keywords.Read WTS Output Until Pattern Matches	Added QosFlow with QFI:3 fiveQI:1	10
	Trigger MultiUE VoNR DL Traffic for SA   ${st_ue_id}   ${en_ue_id}		pdu_id=1   trf_id=1   qfi_id=3		rtp_codec=${rtp_codec}
    Trigger MultiUE VoNR UL Traffic for SA   ${st_ue_id}   ${en_ue_id}		pdu_id=1   trf_id=1   qfi_id=3		rtp_codec=${rtp_codec}

Start pcap collection in gNB CU
    [Arguments]    ${name}=gnbTcpdump    ${options}=-f sctp -i any -s0    ${gnb_id}=0
    ${executor_oam_vm}=  Create Dictionary
    ...  host=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.addr}
    ...  user=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.username}
    ...  password=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.password}
    tcpdump.create_tcpdump_collector
    ...     name=${name}
    ...     options=${options}
    ...     executor=${executor_oam_vm}
    core.setup_collectors    names=${name}
    core.start_collectors    names=${name}
    tcpdump.set_test_alias    ${name}

Stop pcap collection in gNB
    [Arguments]     ${name}   ${Log_Path}
    core.stop_collectors    names=${name}
    core.collect_collectors    names=${name}    target_dir=${Log_Path}
    core.teardown_collectors    names=${name}

Enable_syslog_debug
	taf.sbts.oam.coam.admin.setup_admin	bts_host=${BTS_IP}		alias=debug
	&{rad_parameter_0}    create dictionary   name=rdFeatureFlagBitmapLevel    value=4
    &{rad_parameter_1}    create dictionary   name=rdFeatureFlagBitmap0    value=2097152
    @{rad_parameters}   Create List   ${rad_parameter_0}  ${rad_parameter_1}
    taf.sbts.oam.coam.admin.set_multiple_rad_debug_parameters
    ...    domain=L2PS
    ...    persistency=NotPersistent
    ...    rad_parameters=${rad_parameters}
    ...    connection=debug
	[Teardown]			taf.sbts.oam.coam.admin.teardown_admin	connection=debug

Update bsr package
	Log to console	Updating BSR package
    Run     mkdir ${CURDIR}/BSR
    ${dllink}   Set Variable     https://artifactory-espoo1.ext.net.nokia.com:443/artifactory/mnpute-rotta-local/BSR
    Run     sudo wget ${dllink}/${bsr_package} --user=app1 --password=AP2ert23WFmnMEDhDkxLs2ojjok -P ${CURDIR}/BSR
    coam.setup admin    bts_host=${BTS_IP}
    ${ret}     coam.Update Software      ${CURDIR}/BSR/${bsr_package}
	Sleep	30s
	Log to console	BSR package update completed
    [Teardown]	coam.teardown admin