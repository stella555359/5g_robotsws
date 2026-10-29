*** Settings ***
Documentation     Author: zhaoyang.xu@nokia-sbell.com
...
...               QC case full name:
...               CNI-110347_07_IWK_With_5GC000937_Power_Saving_BWP

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown
Force Tags        CLOUD_5G_I_LO_AP_LO    CRT    SBTS00    OPTION_RELATED_ARTIFACTS_5G    VARIANT_SANSA_FS_ECPRI_CMWV_TDD_TEMP
Test Timeout      60 minutes
Resource    ../../resources/KISS/robot/common_resource.robot
Resource    ../../resources/sg10/internal_resource/internal_resource.robot
Library          ${CURDIR}/log_check/Check_CNI110347_function.py

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}      110347_07scfc.xml
${AIRPHONE_NAME}    CNI-110347_07_IPHY_AEQE_1CELL_APLO.xml
${WTS_NAME}    CNI-110347_07_SA_NSA.cfg

${pattern}    CA_P2_8x4_t2r4_n2

*** Test Cases ***
CNI-110347_07_IWK_With_5GC000937_Power_Saving_BWP
    Step1:Commission the above configuration on WebUI
    Step2:Attach a UE with TAS SRS and powerSaving capability
    Step3:Start Big DL Data Transfer and Check Switch To Large BWP
	Step4:Check CNI110347 function in TTItrace
    Step5:Stop Data Traffic And Check Switch To Power Saving BWP
    Step6:ReStart Big DL Data Transfer and Check Switch To Large BWP
    Step7:Detach UE

*** Keywords ***
Step1:Commission the above configuration on WebUI
    Get and Update BSR File    par_of_bsr_name=BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    Prepare gnb onair

Step2:Attach a UE with TAS SRS and powerSaving capability
    Start Collect GNB and AP Syslog in 'Step2_attach_UE' File
    #Start GNB BIP Log
	Airphone Set Traffic Type    1    1    internal
    ${TAS_t2r4_n2}    Obtain Ue Capability    ${pattern}
    Airphone Sa Attach    ue_id=1    ue_capability=${TAS_t2r4_n2}
    Airphone Pdu Session Setup    ue_id=1    pdu_id=1    nwslice_id=1    gw_id=1
	...     pass_regexp=Bwp Switched from bwpId 1 to 2
    #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach_UE${/}
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach_UE' File

Step3:Start Big DL Data Transfer and Check Switch To Large BWP
    Start Collect GNB and AP Syslog in 'Step3_inject_buffer' File
    #Start GNB BIP Log
	Airphone Csi Override Testmode Nr    profile_id=1    cqi=15    ri=1    cri=1    li=1    pmi=500
	Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=1
    Airphone SA Start Data Traffic    1    DL    170M    trf_id=1    pdu_id=1    duration=${3600}
    Airphone SA Start Data Traffic    1    UL    170M    trf_id=1    pdu_id=1    duration=${3600}	
	Wait Throughput Timer    10
    #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}
	Start GNB Ttitrace With Streaming Mode
    Wait Throughput Timer    3
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}tti
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step3_inject_buffer' File

Step4:Check CNI110347 function in TTItrace
	#DL slot6,7,16,17 no data used in PDSCH 
	#DL slot5,15 have data used in PDSCH
	#UL slot8,9 and 18 have data used in PUSCH
    ${dl_ttitrace_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}tti_dl.csv
	${ul_ttitrace_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}tti_ul.csv  
	${CNI110347_DL_check_point}    Check_Slot6_7_And_Slot16_17_PDSCH_no_used_data    ${dl_ttitrace_path}
	${CNI110347_UL_check_point}    Check_Slot8_9_And_Slot18_PUSCH_Used_data    ${ul_ttitrace_path}	
	log    ${CNI110347_DL_check_point}
	log    ${CNI110347_UL_check_point}
	run keyword and continue on failure    should_be_true    ${CNI110347_DL_check_point}
	run keyword and continue on failure    should_be_true    ${CNI110347_UL_check_point}


Step5:Stop Data Traffic And Check Switch To Power Saving BWP
    Start Collect GNB and AP Syslog in 'Step5_stop_data' File
    #Start GNB BIP Log
    Airphone Sa Stop Data Traffic    ue_id=1    direction=dl    pdu_id=1    qfi_id=1
    Airphone Sa Stop Data Traffic    ue_id=1    direction=ul    pdu_id=1    qfi_id=1	
    Wait Throughput Timer    10
    #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step5_stop_data${/}
	Start GNB Ttitrace With Streaming Mode
    Wait Throughput Timer    3
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step5_stop_data${/}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step5_stop_data${/}tti	
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step5_stop_data' File

Step6:ReStart Big DL Data Transfer and Check Switch To Large BWP
    Start Collect GNB and AP Syslog in 'Step6_inject_buffer' File
    #Start GNB BIP Log
    Airphone SA Start Data Traffic    1    DL    150M    trf_id=1    pdu_id=1    duration=${3600}
	Wait Throughput Timer    10
    #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step6_inject_buffer${/}
	Start GNB Ttitrace With Streaming Mode
    Wait Throughput Timer    3
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step6_inject_buffer${/}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step6_inject_buffer${/}tti
	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step6_inject_buffer${/}   unzip=TRUE
	check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/bwp_switch.ini    log_need_to_check=u
	...    save_log_directory=${TEST_LOG_DIRECTORY()}${/}Step6_inject_buffer${/}
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step6_inject_buffer' File

Step7:Detach UE
    Start Collect GNB and AP Syslog in 'Step7_detach_UE' File
    #Start GNB BIP Log
	Airphone Sa Detach    ue_id=1
    #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step7_detach_UE${/}
	[Teardown]    Stop Collect GNB and AP Syslog in 'Step7_detach_UE' File
