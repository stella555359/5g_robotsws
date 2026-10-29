*** Settings ***
Force Tags    CLOUD_R4LAPO_CUS    CRT    RAN_4G    RAN_4G_FDD    SBTS00
    ...    PY39

Library      ute_wtssim
Resource     resources/CNI_144125_keywords.robot
Library      ta5g_commissioning
Library      ute_fsmaccess
Library      ta5g_pm_counters
Library      taf.collectors.tcpdump    WITH NAME    tcpdump
Library      taf.collectors.core    WITH NAME    core

Documentation
...              :authors: Divyanshi
...              :contact: divyanshi.gupta@nokia.com

Suite Setup       Prepare test environment for suite

*** Variables ***
${SCFC}=        scfc_CNI_144125.xml
${cus_yaml}=    ${CURDIR}/config/yaml/cus_CNI_144125.yaml
${CMAS_prep}	${CURDIR}/config/yaml/CMAS_prep.yaml
${ETWS_prep}	${CURDIR}/config/yaml/ETWS_prep.yaml
${SCF1}			${CURDIR}/config/SBTS/Create_Cell_3.json
${SCF2}			${CURDIR}/config/SBTS/Delete_Cell_3.json
${host}			192.168.255.129
${username}		toor4nsn
${password}		oZPS0POrRieRtu

*** Test Cases ***
CNI_144125_CMAS_ETWS
	[Tags]		With_writereplace	QC_220151     QCD_MN_RAN      QCP_RAN_VRF
	Run Keyword And Continue On Failure	CMAS_with_writereplace
	Run Keyword And Continue On Failure	ETWS_with_writereplace

CNI_144125_CMAS_Without_Writereplace
	[Tags]		Without_writereplace	QC_220150     QCD_MN_RAN      QCP_RAN_VRF
	Run Keyword And Continue On Failure	CMAS_Without_writereplacewarning
	Run Keyword And Continue On Failure	ETWS_Without_writereplacewarning

*** Keywords ***
CMAS_with_writereplace
    Prepare cell trace
	Log To Console		Enable CMAS
	Configure Enb		${CMAS_prep}
	Log To Console		Lock cell-2 and delete cell-3
	ta5g_commissioning.Send Delta Commissioning		${SCF2}
	ta5g_pm_counters.Wait_For_Next_Full_Pm_Interval
	Start pcap collection     name=CMAS_with_writereplace
	EXPECT FLOW: MME_1 S1AP writeReplaceWarning
	Trigger MME_1 to send WriteReplaceWarningRequest with MessageId 4381 for CMAS for Emergency Area 1
    PASS FLOW: MME_1 S1AP writeReplaceWarning
	Cell trace start
	EXPECT FLOW[timeout=120]: MME_1 S1AP pWSFailureIndication
	Lock cell-1
	Run Keyword And Continue On Failure		PASS FLOW[timeout=120]: MME_1 S1AP pWSFailureIndication
	Run Keyword And Continue On Failure		Verify that PWSFailureIndication sent to MME_1 contained PWSfailedECGIList with data of cell-1 present
	Run Keyword And Continue On Failure
	...		Verify that PWSFailureIndication sent to MME_1 contained Global-ENB-ID and PLMNidentity equal to 1 and 0x42F480
    Run Keyword And Continue On Failure		Verify that PWSFailureIndication was present in cell trace
	EXPECT FLOW: MME_2 S1AP writeReplaceWarning
	Trigger MME_2 to send WriteReplaceWarningRequest with MessageId 4382 for CMAS for Emergency Area 3
    PASS FLOW: MME_2 S1AP writeReplaceWarning
	EXPECT FLOW[timeout=120]: MME_2 S1AP pWSRestartIndication
	Log To Console		configure cell-3 and unlock cell-2
	ta5g_commissioning.Send Delta Commissioning		${SCF1}
	sleep	30
    Run Keyword And Continue On Failure		PASS FLOW[timeout=120]: MME_2 S1AP pWSRestartIndication
	Run Keyword And Continue On Failure
	...		CNI_144125_keywords.Verify that PWSRestartIndication sent to MME_2 contained ECGIListForRestart with data of cell-2 present
	#Run Keyword And Continue On Failure
	#...		CNI_144125_keywords.Verify that PWSRestartIndication sent to MME_2 contained ECGIListForRestart with data of cell-3 present
    Run Keyword And Continue On Failure
	...		Verify that PWSRestartIndication sent to MME_2 contained Global-ENB-ID and PLMNidentity equal to 1 and 0x42F480
    Run Keyword And Continue On Failure		Verify that PWSRestartIndication sent to MME_2 contained TAIListForRestart with 123 present
    Run Keyword And Continue On Failure		Verify that PWSRestartIndication was present in cell trace
    Run Keyword And Continue On Failure		Cell trace stop
	Stop pcap collection    CMAS_with_writereplace    ${OUTPUT_DIR}
	CMAS_with_writereplace Verification
	ta5g_pm_counters.Wait_For_Next_Full_Pm_Interval
	${pm_counter_file}	ta5g_pm_counters.Get_Latest_Unpacked_Full_Pm_Counters_File
	verify_any_counters_in_file
    ...     M8000C50    4    S1AP_PWS_RESTART_IND
    ...     M8000C51    2    S1AP_PWS_FAILURE_IND
    ...     local_moid=MRBTS-1/LNBTS-1
    ...     file_path=${pm_counter_file}
    [Teardown]    Run keywords		Deconfigure all    enb_id=1
	...				AND		configuration_id.Link SCOUT SCF to Configuration ID for Reporting
	...				AND		Sleep	60

ETWS_with_writereplace
	Log To Console		Enable ETWS
	Configure Enb		${ETWS_prep}
	Log To Console		Lock cell-2 and delete cell-3
	ta5g_commissioning.Send Delta Commissioning		${SCF2}
	ta5g_pm_counters.Wait_For_Next_Full_Pm_Interval
	Start pcap collection     name=ETWS_with_writereplace
    EXPECT FLOW: MME_1 S1AP writeReplaceWarning
	Trigger MME_1 to send WriteReplaceWarningRequest with MessageId 4352 for ETWS for Emergency Area 1
    PASS FLOW: MME_1 S1AP writeReplaceWarning
    Cell trace start
	EXPECT FLOW[timeout=120]: MME_1 S1AP pWSFailureIndication
	Lock cell-1
	PASS FLOW[timeout=120]: MME_1 S1AP pWSFailureIndication
	Run Keyword And Continue On Failure		Verify that PWSFailureIndication sent to MME_1 contained PWSfailedECGIList with data of cell-1 present
    Run Keyword And Continue On Failure
	...		Verify that PWSFailureIndication sent to MME_1 contained Global-ENB-ID and PLMNidentity equal to 1 and 0x42F480
    Run Keyword And Continue On Failure		Verify that PWSFailureIndication was present in cell trace
	EXPECT FLOW: MME_2 S1AP writeReplaceWarning
	Trigger MME_2 to send WriteReplaceWarningRequest with MessageId 4353 for ETWS for Emergency Area 2
    PASS FLOW: MME_2 S1AP writeReplaceWarning
	EXPECT FLOW[timeout=120]: MME_2 S1AP pWSRestartIndication
	Log To Console		configure cell-3 and unlock cell-2
	ta5g_commissioning.Send Delta Commissioning		${SCF1}
	sleep	30
	Run Keyword And Continue On Failure		PASS FLOW[timeout=120]: MME_2 S1AP pWSRestartIndication
	Run Keyword And Continue On Failure
	...		CNI_144125_keywords.Verify that PWSRestartIndication sent to MME_2 contained ECGIListForRestart with data of cell-2 present
	#Run Keyword And Continue On Failure
	#...		CNI_144125_keywords.Verify that PWSRestartIndication sent to MME_2 contained ECGIListForRestart with data of cell-3 present
    Run Keyword And Continue On Failure
	...		Verify that PWSRestartIndication sent to MME_2 contained Global-ENB-ID and PLMNidentity equal to 1 and 0x42F480
    Run Keyword And Continue On Failure		Verify that PWSRestartIndication sent to MME_2 contained TAIListForRestart with 123 present
    Run Keyword And Continue On Failure		Verify that PWSRestartIndication was present in cell trace
    Run Keyword And Continue On Failure		Cell trace stop
	Stop pcap collection    ETWS_with_writereplace    ${OUTPUT_DIR}
	ETWS_with_writereplace Verification
	ta5g_pm_counters.Wait_For_Next_Full_Pm_Interval
	${pm_counter_file}	ta5g_pm_counters.Get_Latest_Unpacked_Full_Pm_Counters_File
	verify_any_counters_in_file
    ...     M8000C50    4    S1AP_PWS_RESTART_IND
    ...     M8000C51    2    S1AP_PWS_FAILURE_IND
    ...     local_moid=MRBTS-1/LNBTS-1
    ...     file_path=${pm_counter_file}
    [Teardown]    Run keywords		Deconfigure all    enb_id=1
	...				AND		configuration_id.Link SCOUT SCF to Configuration ID for Reporting
	...				AND		Sleep	60

ETWS_Without_writereplacewarning
	Log To Console		Enable ETWS
	Configure Enb		${ETWS_prep}
	Log To Console		Lock cell-2 and delete cell-3
	ta5g_commissioning.Send Delta Commissioning		${SCF2}
	ta5g_pm_counters.Wait_For_Next_Full_Pm_Interval
	Start pcap collection     name=ETWS_Without_writereplacewarning
	Lock cell-1
    Sleep    5
	Cell trace start
	EXPECT FLOW[timeout=120]: MME_1 S1AP pWSRestartIndication
	Log To Console		configure cell-3 and unlock cell-2
	ta5g_commissioning.Send Delta Commissioning		${SCF1}
	sleep	30
	Run Keyword And Continue On Failure		PASS FLOW[timeout=120]: MME_1 S1AP pWSRestartIndication
	Run Keyword And Continue On Failure
	...		CNI_144125_keywords.Verify that PWSRestartIndication sent to MME_1 contained ECGIListForRestart with data of cell-3 present
    Run Keyword And Continue On Failure
	...		Verify that PWSRestartIndication sent to MME_1 contained Global-ENB-ID and PLMNidentity equal to 1 and 0x42F480
    Run Keyword And Continue On Failure		Verify that PWSRestartIndication sent to MME_1 contained TAIListForRestart with 123 present
    Run Keyword And ignore error			Verify that PWSRestartIndication was present in cell trace
    Run Keyword And Continue On Failure		Cell trace stop
	Stop pcap collection    ETWS_Without_writereplacewarning    ${OUTPUT_DIR}
	ETWS_Without_writereplacewarning Verification
	ta5g_pm_counters.Wait_For_Next_Full_Pm_Interval
	${pm_counter_file}	ta5g_pm_counters.Get_Latest_Unpacked_Full_Pm_Counters_File
	verify_any_counters_in_file
    ...     M8000C50    2    S1AP_PWS_RESTART_IND
    ...     M8000C51    0    S1AP_PWS_FAILURE_IND
    ...     local_moid=MRBTS-1/LNBTS-1
    ...     file_path=${pm_counter_file}
    [Teardown]    Run keywords		Deconfigure all    enb_id=1
	...				AND		configuration_id.Link SCOUT SCF to Configuration ID for Reporting
	...				AND		Sleep	60

CMAS_Without_writereplacewarning
	Log To Console		Enable CMAS
	Configure Enb		${CMAS_prep}
	Log To Console		Lock cell-2 and delete cell-3
	ta5g_commissioning.Send Delta Commissioning		${SCF2}
	ta5g_pm_counters.Wait_For_Next_Full_Pm_Interval
	Start pcap collection     name=CMAS_Without_writereplacewarning
	Lock cell-1
    Sleep    5
	Cell trace start
	EXPECT FLOW[timeout=120]: MME_1 S1AP pWSRestartIndication
	Log To Console		configure cell-3 and unlock cell-2
	ta5g_commissioning.Send Delta Commissioning		${SCF1}
	sleep	30
	Run Keyword And Continue On Failure		PASS FLOW[timeout=120]: MME_1 S1AP pWSRestartIndication
	Run Keyword And Continue On Failure
	...		CNI_144125_keywords.Verify that PWSRestartIndication sent to MME_1 contained ECGIListForRestart with data of cell-3 present
    Run Keyword And Continue On Failure
	...		Verify that PWSRestartIndication sent to MME_1 contained Global-ENB-ID and PLMNidentity equal to 1 and 0x42F480
    Run Keyword And Continue On Failure		Verify that PWSRestartIndication sent to MME_1 contained TAIListForRestart with 123 present
    Run Keyword And ignore error			Verify that PWSRestartIndication was present in cell trace
    Run Keyword And Continue On Failure		Cell trace stop
	Stop pcap collection    CMAS_Without_writereplacewarning    ${OUTPUT_DIR}
	CMAS_Without_writereplacewarning Verification
	ta5g_pm_counters.Wait_For_Next_Full_Pm_Interval
	${pm_counter_file}	ta5g_pm_counters.Get_Latest_Unpacked_Full_Pm_Counters_File
	verify_any_counters_in_file
    ...     M8000C50    2    S1AP_PWS_RESTART_IND
    ...     M8000C51    0    S1AP_PWS_FAILURE_IND
    ...     local_moid=MRBTS-1/LNBTS-1
    ...     file_path=${pm_counter_file}
    [Teardown]    Run keywords		Deconfigure all    enb_id=1
	...				AND		configuration_id.Link SCOUT SCF to Configuration ID for Reporting
	...				AND		Sleep	60

Start pcap collection
    [Arguments]    ${name}=gnbTcpdump    ${options}=-i any
    ${executor_oam_vm}=  Create Dictionary
    ...  host=${host}
    ...  user=${username}
    ...  password=${password}
    tcpdump.create_tcpdump_collector
    ...     name=${name}
    ...     options=${options}
    ...     executor=${executor_oam_vm}
    core.setup_collectors    names=${name}
    core.start_collectors    names=${name}
    tcpdump.set_test_alias    ${name}

Stop pcap collection
    [Arguments]     ${name}   ${Log_Path}
    core.stop_collectors    names=${name}
    core.collect_collectors    names=${name}    target_dir=${Log_Path}
    core.teardown_collectors    names=${name}

Verify PCAP
    [Arguments]   ${pcap_file_path}        ${filter}       ${field}     ${value}
    ${val}    Get Fields from Pcap     ${pcap_file_path}        ${filter}      ${field}
    Should contain    ${val}    ${value}

CMAS_with_writereplace Verification
	Run Keyword And Continue On Failure
	...		Verify PCAP    ${OUTPUT_DIR}/CMAS_with_writereplace/CMAS_with_writereplace.pcap
	...    s1ap.CellIdentity == 0x00000102 && s1ap.procedureCode == 49 && ip.dst == 10.0.1.1    ip.src    10.0.1.2
	Run Keyword And Continue On Failure
	...		Verify PCAP    ${OUTPUT_DIR}/CMAS_with_writereplace/CMAS_with_writereplace.pcap
	...    s1ap.CellIdentity == 0x00000102 && s1ap.procedureCode == 49 && ip.dst == 10.0.1.11    ip.src    10.0.1.2
	Run Keyword And Continue On Failure
	...		Verify PCAP    ${OUTPUT_DIR}/CMAS_with_writereplace/CMAS_with_writereplace.pcap
	...    s1ap.CellIdentity == 0x00000103 && s1ap.procedureCode == 49 && ip.dst == 10.0.1.1    ip.src    10.0.1.2
	Run Keyword And Continue On Failure
	...		Verify PCAP    ${OUTPUT_DIR}/CMAS_with_writereplace/CMAS_with_writereplace.pcap
	...    s1ap.CellIdentity == 0x00000103 && s1ap.procedureCode == 49 && ip.dst == 10.0.1.11    ip.src    10.0.1.2
	Run Keyword And Continue On Failure
	...		Verify PCAP    ${OUTPUT_DIR}/CMAS_with_writereplace/CMAS_with_writereplace.pcap
	...    s1ap.CellIdentity == 0x00000101 && s1ap.procedureCode == 51 && ip.dst == 10.0.1.1    ip.src    10.0.1.2
	Run Keyword And Continue On Failure
	...		Verify PCAP    ${OUTPUT_DIR}/CMAS_with_writereplace/CMAS_with_writereplace.pcap
	...    s1ap.CellIdentity == 0x00000101 && s1ap.procedureCode == 51 && ip.dst == 10.0.1.11    ip.src    10.0.1.2
	Run Keyword And Continue On Failure
	...		Verify PCAP    ${OUTPUT_DIR}/CMAS_with_writereplace/CMAS_with_writereplace.pcap
	...    s1ap.procedureCode == 36 && ip.src == 10.0.1.1    ip.dst    10.0.1.2
	Run Keyword And Continue On Failure
	...		Verify PCAP    ${OUTPUT_DIR}/CMAS_with_writereplace/CMAS_with_writereplace.pcap
	...    s1ap.procedureCode == 36 && ip.src == 10.0.1.11    ip.dst    10.0.1.2

ETWS_with_writereplace Verification
	Run Keyword And Continue On Failure
	...		Verify PCAP    ${OUTPUT_DIR}/ETWS_with_writereplace/ETWS_with_writereplace.pcap
	...    s1ap.CellIdentity == 0x00000102 && s1ap.procedureCode == 49 && ip.dst == 10.0.1.1    ip.src    10.0.1.2
	Run Keyword And Continue On Failure
	...		Verify PCAP    ${OUTPUT_DIR}/ETWS_with_writereplace/ETWS_with_writereplace.pcap
	...    s1ap.CellIdentity == 0x00000102 && s1ap.procedureCode == 49 && ip.dst == 10.0.1.11    ip.src    10.0.1.2
	Run Keyword And Continue On Failure
	...		Verify PCAP    ${OUTPUT_DIR}/ETWS_with_writereplace/ETWS_with_writereplace.pcap
	...    s1ap.CellIdentity == 0x00000103 && s1ap.procedureCode == 49 && ip.dst == 10.0.1.1    ip.src    10.0.1.2
	Run Keyword And Continue On Failure
	...		Verify PCAP    ${OUTPUT_DIR}/ETWS_with_writereplace/ETWS_with_writereplace.pcap
	...    s1ap.CellIdentity == 0x00000103 && s1ap.procedureCode == 49 && ip.dst == 10.0.1.11    ip.src    10.0.1.2
	Run Keyword And Continue On Failure
	...		Verify PCAP    ${OUTPUT_DIR}/ETWS_with_writereplace/ETWS_with_writereplace.pcap
	...    s1ap.CellIdentity == 0x00000101 && s1ap.procedureCode == 51 && ip.dst == 10.0.1.1    ip.src    10.0.1.2
	Run Keyword And Continue On Failure
	...		Verify PCAP    ${OUTPUT_DIR}/ETWS_with_writereplace/ETWS_with_writereplace.pcap
	...    s1ap.CellIdentity == 0x00000101 && s1ap.procedureCode == 51 && ip.dst == 10.0.1.11   ip.src    10.0.1.2
	Run Keyword And Continue On Failure
	...		Verify PCAP    ${OUTPUT_DIR}/CMAS_with_writereplace/CMAS_with_writereplace.pcap
	...    s1ap.procedureCode == 36 && ip.src == 10.0.1.1    ip.dst    10.0.1.2
	Run Keyword And Continue On Failure
	...		Verify PCAP    ${OUTPUT_DIR}/CMAS_with_writereplace/CMAS_with_writereplace.pcap
	...    s1ap.procedureCode == 36 && ip.src == 10.0.1.11    ip.dst    10.0.1.2

ETWS_Without_writereplacewarning Verification
	Run Keyword And Continue On Failure
	...		Verify PCAP    ${OUTPUT_DIR}/ETWS_Without_writereplacewarning/ETWS_Without_writereplacewarning.pcap
	...    s1ap.CellIdentity == 0x00000103 && s1ap.procedureCode == 49 && ip.dst == 10.0.1.1    ip.src    10.0.1.2
	Run Keyword And Continue On Failure
	...		Verify PCAP    ${OUTPUT_DIR}/ETWS_Without_writereplacewarning/ETWS_Without_writereplacewarning.pcap
	...    s1ap.CellIdentity == 0x00000103 && s1ap.procedureCode == 49 && ip.dst == 10.0.1.11    ip.src    10.0.1.2
	${status}	Run Keyword And return status
	...		Verify PCAP    ${OUTPUT_DIR}/ETWS_Without_writereplacewarning/ETWS_Without_writereplacewarning.pcap
	...    s1ap.procedureCode == 36 && ip.src == 10.0.1.1    ip.dst    10.0.1.2
	Should Not Be True		${status}
	${status}	Run Keyword And return status
	...		Verify PCAP    ${OUTPUT_DIR}/ETWS_Without_writereplacewarning/ETWS_Without_writereplacewarning.pcap
	...    s1ap.procedureCode == 36 && ip.src == 10.0.1.11    ip.dst    10.0.1.2
	Should Not Be True		${status}

CMAS_Without_writereplacewarning Verification
	Run Keyword And Continue On Failure
	...		Verify PCAP    ${OUTPUT_DIR}/CMAS_Without_writereplacewarning/CMAS_Without_writereplacewarning.pcap
	...    s1ap.CellIdentity == 0x00000103 && s1ap.procedureCode == 49 && ip.dst == 10.0.1.1    ip.src    10.0.1.2
	Run Keyword And Continue On Failure
	...		Verify PCAP    ${OUTPUT_DIR}/CMAS_Without_writereplacewarning/CMAS_Without_writereplacewarning.pcap
	...    s1ap.CellIdentity == 0x00000103 && s1ap.procedureCode == 49 && ip.dst == 10.0.1.11    ip.src    10.0.1.2
		${status}	Run Keyword And return status
	...		Verify PCAP    ${OUTPUT_DIR}/CMAS_Without_writereplacewarning/CMAS_Without_writereplacewarning.pcap
	...    s1ap.procedureCode == 36 && ip.src == 10.0.1.1    ip.dst    10.0.1.2
	Should Not Be True		${status}
	${status}	Run Keyword And return status
	...		Verify PCAP    ${OUTPUT_DIR}/CMAS_Without_writereplacewarning/CMAS_Without_writereplacewarning.pcap
	...    s1ap.procedureCode == 36 && ip.src == 10.0.1.11    ip.dst    10.0.1.2
	Should Not Be True		${status}