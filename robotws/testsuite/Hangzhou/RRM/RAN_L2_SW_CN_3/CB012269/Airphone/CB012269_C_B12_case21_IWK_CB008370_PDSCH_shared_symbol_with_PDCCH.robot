*** Settings ***
Documentation
...

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown
Force Tags        CLOUD_5G_I_MP_AP_LOOO    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_wdw
Test Timeout      90 minutes
Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot
#Resource          ../../resources/KISS/robot/common_resource.robot
#Resource          ../../resources/sg10/internal_resource/internal_resource.robot
Library     taf.transport.ssh    WITH NAME    TAF_SSH
Library           ta_a2a

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}   SCF_MG_case24.xml
${AIRPHONE_NAME}    iphy_AEQY_6cell_8D4U_MG_case24.xml
${WTS_NAME}    basic_setup_6cell_MG_case24.cfg
@{LOG_NAME_LIST}        gnb_snapshot    egatelog

${actPdcchSharingWithPdsch}                    text|true|//*[@name\="actPdcchSharingWithPdsch"]
${actTddCsiRsOpt}                              text|true|//*[@name\="actTddCsiRsOpt"]

${filter_1}    (dldata_csirssendreq||dldata_pdschsendreq) && !(3gpp.rnti == 65535) 
@{title_1}     3gpp.sfn   3gpp.slot   3gpp.rnti
...   DlData_CsiRsSendReq_t.csiRsResources.Length	DlData_CsiRsResource_t.csiRsConfig	  DlData_CsiRsResource_t.startSymbol
...   DlData_CsiRsResource_t.density	DlData_CsiRsResource_t.trsInfo   DlData_CsiRsResource_t.csiRsScramblingSequenceInt
...   DlData_CsiRsResource_t.startPrb   DlData_CsiRsResource_t.numOfPrb   DlData_PdschGrant.startSymbol
...   3gpp.dmrsScramblingSequenceInt	DlData_PdschGrant.numOfPdschSymbols
...   DlData_PdschGrant.numOfPrb   DlData_PdschGrant.rateMatchingOption   DlData_PdschGrant.symbolRateMatchingPositions


*** Test Cases ***
CB012269_C_B12_case21_IWK_CB008370_PDSCH_shared_symbol_with_PDCCH
    Step1:Commission the above configuration on WebUI
	Step2:Attach UE and start buffer
	step3:Detach UE


*** Keywords ***
Step1:Commission the above configuration on WebUI
    Start Capture GNB and AP Syslog in 'Step1_before_onair' File
    ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
    change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}WTS${/}${AIRPHONE_NAME}
    modify_swconfig    ${CONFIG_DIR_PATH}${/}SCF${/}${SCFC_NAME}
    ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}SCF${/}scfc.xml
    copy_file    ${CONFIG_DIR_PATH}${/}SCF${/}${SCFC_NAME}    ${scfc_path}
    ${modify_list}    create list
	...      ${actTddCsiRsOpt}    ${actPdcchSharingWithPdsch}
    modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
    Modify TL VM And AP SCTP Configuration
	Get and Update BSR File    par_of_bsr_name=AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
	Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}WTS${/}${WTS_NAME}    reset_after_commission=${False}
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step1_before_onair
    [Teardown]    Stop Capture GNB and AP Syslog in 'Step1_before_onair' File

modify_swconfig
    comment     https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=AirPhoneWTS&title=AirPhone+Alignment+to+gNB+L1L2+Interface
    [Arguments]    ${scfc_file}
	${local_save_path}=     Download All Common Config Files From Golden Server
	${path_gnb}=            Find Match GNB swconfig Golden Files    ${scfc_file}    ${local_save_path}
	${path_ap}=             Find Match AP swconfig Golden Files    ${scfc_file}     ${local_save_path}
    setup_txt    src_file=${path_gnb}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
	add_txt_node    0x9D0000:5         #as PM counter period update to 15/15=1min
    teardown_txt
	setup_txt    src_file=${path_ap}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
    teardown_txt
    GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
    airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt

Step2:Attach UE and start buffer
    Start Collect GNB and AP Syslog in 'Step2_attach' File
	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
	Start GNB BIP Log
	Attach SA ue with capability to 5g cell    1    CA_P2_8x4_t2r4_n2
    Wait '5s' for stable running
    SA send multiple trf data    1    DL    175M    6
    SA send multiple trf data    1    UL    175M    2
    Wait Throughput Timer    15
    Capture ttitrace    3s    ${save_log}    tti
    Stop Gnb BIP Log    log_dir=${save_log}
	airphone_collect_egate_log_files      ${save_log}   unzip=TRUE
    run keyword and continue on failure   Convert BIP To CSV    ${save_log}/tcpdump_L2L1_bip_filtering_off.pcap0
	...    ${save_log}/startSymbol.csv    ${filter_1}    ${title_1}
    run keyword and continue on failure
	...    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/C12_case21_check_bip.ini    log_need_to_check=i
    ...    save_log_directory=${save_log}
	run keyword and continue on failure    check_log_with_au2anlysis
    ...    ini_path=${CURDIR}/ini/tti_dl_no_bler.ini    log_need_to_check=i    save_log_directory=${save_log}
	[Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File

step3:Detach UE	
    airphone_sa_detach    ue_id=1

Capture ttitrace
    [Arguments]    ${time}    ${save_log}     ${file_tag}
    Start GNB Ttitrace With Streaming Mode
    sleep    ${time}
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/${file_tag}
