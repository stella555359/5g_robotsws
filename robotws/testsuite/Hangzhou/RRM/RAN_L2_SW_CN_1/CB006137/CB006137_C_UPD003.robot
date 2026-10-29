*** Settings ***
Documentation    ...
#Resource    ./CB006137_resource.robot
#Resource    ./../CUDU_L2/common_setup_teardown.robot
#Resource    resources/6137_BO_lib.robot
#Resource    ./resources/CB006137_BB_resource.robot
#Suite Setup    Common Suite Setup
#Test Teardown    Common Test Teardown 2
#Suite Teardown    Common Suite Teardown 2
#Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    SBTS00    SBTS23R1    CN1_SG09_SM2
#...                RAN_5G    RAN_5G_TDD    CRT
#
#*** Variables ***
#${UE_ID}               1
#${PROFILE_ID}          1
#${GNB_ID}              2
#${CELL_ID}             1
#${BEARER_ID}           2
#${Egatelog_path}          ${CURDIR}
#${LOCAL_IPHY_DIR}         ${CURDIR}/config
#${SCF_DIR}                ${CURDIR}/config
#${IPHY}                   iphy_2T3F.xml
#${6137_UPD003_06_SCF}     ${SCF_DIR}/SCF_C_UPD003_06.xml
#${WTS_CFG_C_UPD003_06}    basic_setup_vonr.cfg
#${gnb_swconfig}           /home/ute/testline_init_results/configs/sm_swconfig.txt
#${2F2T_SCELLS}            ('1', '51', '25'), ('2', '60', '77'), ('3', '61', '41')
#${BIP_FILTER1}            dldata_pdcchsendreq&&!(3gpp.rnti == 65535)
#${BIP_FILTER2}            3gpp.dmrsScramblingSequenceInt
#${BIP_FILTER3}            itf_l2_ps_peerctrl_ScellDrxInactivityTimerStatusInd_t.sCellNrCellIdentity
#${6137_B6_COMMON_RD}      0x58067c=0x1;0x58057F=16;0x58057a=4;0x58057d=0x400000;0x580497=1;0x58062d=1
##0x58057F rdFeatureFlagBitmap4; bitmap;0 - RIM.COMMON, 1- RIM.RI, 2- RIM.RI_SELECTOR, 3- RIM.RS, 4- UL.INTERBAND_CA.POWER_SPLIT
##0x58057a rdFeatureFlagBitmapLevel; enum;0 - VIP, 1 - ERROR, 2 - WARNING, 3 - INFO, 4 - DEBUG, 5 - INVALID
##0x58067c 6137-C enabling
##0x58057d=0x400000 L2.L2_PS.INTERBAND_CA.ACT_DEACT
##0x580497=1 CB007737-A/-B's flag
##0x58062d=1 rdEnable6137Fr1CaDrxSolution
#
#*** Test Cases ***
#CB006137-ET-C-UPD003_06_DRX_setup_for_UE_having_Voice_over_NR_call_with_FDD-TDD-TDD-FDD_DL_and_UL_CA_configured_with_mutiple_DRB_ECPRI
#    [Documentation]
#    ...    Precondition:
#    ...      NRBTS/NRDU/flexibleCAMode = 3 (NumberCellAmount).
#    ...      sCellActivationMethod = “1:bufferBased”.
#    ...      sCellAdditionMethod = covBasedA1
#    ...      sCellDeactivationTimerGNB=1280
#    ...      NRBTS/NRCELL/actCDrx = true
#    ...      In FDD Cell: actCDrxVoNR = true.
#    ...      NRBTS/NRCELL/drxProfile1/drxLongCycle = 40ms, drxOnDurationTimer=10ms, drxInactivityTimer=3ms.
#    ...      NRBTS/NRCELL/drxProfile2/drxLongCycle = 40ms, drxOnDurationTimer=6ms, drxInactivityTimer=4ms.
#    ...      frame structure=1070
#    ...    rd parameter:
#    ...      0x58067c=0x1 #enable 6137-C
#    ...      0x58062d=1 #rdEnable6137Fr1CaDrxSolution
#    ...      0x580497=1 #CB007737 feature flag
#    ...    Test Steps:
#    ...      Step1: Attach UE-1 to the FDD NR cell.
#    ...      Step2: Send A1 report, scell is added
#    ...      Step3: Add  5QI1 and 5QI5
#    ...      Step4: Send VONR traffic bi-direction
#    ...      Step5: Send Non-GBR traffic bi-direction
#    ...      Step6: Release GBR bear(5QI1-5QI5)
#    ...      Step7: UE detach
#    ...    Check point：
#    ...      1.check 7737 is actived ,FDD 2 cells  have same emCoreId in TTI trace
#    ...      2.UE attach is ok , DRX configuration(DRX PROFILE1) is send in RRC message, UE is configued 4CC
#    ...      3.5QI1 DRB is added , DRX configuration(DRX PROFILE2) is reconfigued
#    ...      4.scell is not active,UE traffic is only through PCELL ,UE Throughput is ok,DL and UL no DTX on all cells ,
#    ...       UE go into DRX when no DL&UL schdule
#    ...      5.Scell is active,UE Throughput is ok,DL and UL no DTX on all cells ,UE go into DRX when no DL&UL schdule
#    ...      6.DRX configuration(DRX PROFILE1) is reconfigued,UE Throughput is ok,DL and UL no DTX on all cells ,
#    ...       UE go into DRX when no DL&UL schdule
#    ...      7.UE detached
#    [Tags]    caseUPD003_06    Manual_Coliu    TA_Coliu
#    [Setup]    Run Keywords    Setup TL For Each Case    ${6137_UPD003_06_SCF}    ${IPHY}    ${WTS_CFG_C_UPD003_06}
#    ...    AND    Verify Coam Site Is Ready
#    ...    AND    Start GNB AP Syslog    ${TEST_LOG_DIRECTORY}
#    ...    AND    Start UTE WTS And Check Cell Setup    ${WTS_CFG_C_UPD003_06}
#    Test Step For UPD003 06
#    #checkpoint1
#    Check 7737 Actived    ${TEST_LOG_DIRECTORY}/ttitrace/    UPD003_06
#    #checkpoint4 5
#    Check DL DTXNACK Rate    ${TEST_LOG_DIRECTORY}/ttitrace/
#    Check UL DTXCRC Rate    ${TEST_LOG_DIRECTORY}/ttitrace/
#    #checkpoint2 3 6
#    Check RRC Reconfig For DRX Configuration For CB006137-C-UPD003-6    ms3    2    ms4    1    ${TEST_LOG_DIRECTORY}
#    #checkpoint5
#    Get DMRSScramblingID From RRC    ${TEST_LOG_DIRECTORY}/egate_console-Drx.log
#    Check DRX InactivityTimer From BIP For CB006137-C-UPD003-6    ${scell2_DMRSScramblingID}    16395    02
#    Check DRX InactivityTimer From BIP For CB006137-C-UPD003-6    ${scell3_DMRSScramblingID}    16396    02
#    Check DRX InactivityTimer From BIP For CB006137-C-UPD003-6    ${scell2_DMRSScramblingID}    16395    01
#    Check DRX InactivityTimer From BIP For CB006137-C-UPD003-6    ${scell3_DMRSScramblingID}    16396    01
#
#*** Keywords ***
#Test Step For UPD003 06
#    #Step1 2
#    Basic Flow For Ue Attach And Pdu Setup
#    Trigger A1 Scell Addition    1
#    Sleep    2s    reason=Wait for log
#    Get And Check Scell Infos    ${2F2T_SCELLS}
#    #Step3
#    Trigger 5QI 5 Setup    ${UE_ID}
#    Trigger 5QI 1 Setup    ${UE_ID}
#    #Step4
#    Start SA VONR GBR DL And UL Traffic    ueId=${UE_ID}    qfi_id=3    dl_trf=10    ul_trf=10
#    #Step5
#    Start SA UE Big UL Traffic Internal    ${UE_ID}    mbps=30
#    Start SA UE Big DL Traffic Internal    ${UE_ID}    mbps=250
#    Start Ttitrace With Streaming Mode
#    Sleep    1s    reason=Wait for traffic
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/
#    Start Gnb BIP Log
#    Stop SA UE UL and DL Traffic Internal
#    Sleep    2s    reason=Wait for traffic
#    Stop Gnb BIP Log
#    OperatingSystem.Run
#    ...    mergecap -a -w ${OUTPUT_DIR}/5GBipL2L1_filtering_off02.pcap ${OUTPUT_DIR}/5GBipL2L1_filtering_off.pcap*
#    #Step6
#    Start SA UE Big UL Traffic Internal    ${UE_ID}    mbps=30
#    Start SA UE Big DL Traffic Internal    ${UE_ID}    mbps=250
#    Release 5QI 5 And 5QI 1
#    Start Gnb BIP Log
#    Stop SA UE UL and DL Traffic Internal
#    Sleep    2s    reason=Wait for traffic
#    Stop Gnb BIP Log
#    OperatingSystem.Run
#    ...    mergecap -a -w ${OUTPUT_DIR}/5GBipL2L1_filtering_off01.pcap ${OUTPUT_DIR}/5GBipL2L1_filtering_off.pcap*
#    #Step7
#    SA 5G Detach    ue_id=${UE_ID}
#
#Check RRC Reconfig For DRX Configuration For CB006137-C-UPD003-6
#    [Arguments]    ${profile1_timer}    ${times1}    ${profile2_timer}    ${times2}    ${log_dir}
#    Save Egate Log
#    OperatingSystem.Run    cp ${SUITE_LOG_DIRECTORY}/egate_console.log ${log_dir}/egate_console-Drx.log
#    ${egate_console_file}=    Set Variable    ${log_dir}/egate_console-Drx.log
#    ${Drx}=    Grep File    ${egate_console_file}    drx-InactivityTimer
#    Should Contain X Times    ${Drx}    drx-InactivityTimer ${profile1_timer},    ${times1}
#    Should Contain X Times    ${Drx}    drx-InactivityTimer ${profile2_timer},    ${times2}
#
#Release 5QI 5 And 5QI 1
#    ${cmd3}    Set Variable    ue_pdu_session_modify ue=1 pdu=1 qosflows_to_del=2,3
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
#    ...    ${cmd3}    pass_regexp=rrcReconfigurationComplete    timeout=3minutes
#
#Check 7737 Actived
#    [Arguments]    ${csv_file_path}    ${case_id}
#    A2A_Check_CSV_Table    ${CURDIR}/A2A/UPD003/${case_id}.ini    output_dl.csv    ${csv_file_path}
#
#Start nonGBR Traffic And Check Tput
#    [Arguments]    ${ue}    ${dl_trf}    ${ul_trf}    ${dl_peak_tput}    ${ul_peak_tput}
#    CB006137_BB_resource.Start SA DL Big Traffic Internal    ${ue}    ${dl_trf}
#    CB006137_BB_resource.Start SA UL Big Traffic Internal    ${ue}    ${ul_trf}
#	Wait Until Keyword Succeeds    30s    5s    SA UE Check Throughput    ${UE_ID}    ${dl_peak_tput}    ${ul_peak_tput}    qfi=1
#
#Check DRX InactivityTimer From BIP For CB006137-C-UPD003-6
#    [Arguments]    ${DMRSScramblingID}    ${cell_id}    ${drxprofile}
#    Log To Console    Check DRX InactivityTimer on SCell...
#    Convert BIP To CSV By MCShark For CB006137-C-UPD003-6    ${DMRSScramblingID}    ${cell_id}    ${drxprofile}
#    A2A_Check_CSV_Table    ${CURDIR}/A2A/UPD003/ttitrace_c_upd003_06_${drxprofile}.ini    ${OUTPUT_DIR}/csv_drx_${drxprofile}.csv
#
#Convert BIP To CSV By MCShark For CB006137-C-UPD003-6
#    [Arguments]    ${DMRSScramblingID}    ${cell_id}    ${drxprofile}
#    ${filter}=    Set Variable    (${BIP_FILTER1}&&(${BIP_FILTER2} == ${DMRSScramblingID})) || ((${BIP_FILTER3} == ${cell_id}))
#    @{csv_title_list}=    Create List    3gpp.sfn    3gpp.slot    itf_l2_ps_peerctrl_ScellDrxState_t.isInactivityTimerOn
#    ...    itf_l2_ps_peerctrl_ScellDrxInactivityTimerStatusInd_t.sCellNrCellIdentity
#    ${bip_names}    OperatingSystem.List Files In Directory    ${OUTPUT_DIR}   5GBipL2L1_filtering_off${drxprofile}.pcap*    ${True}
#    FOR    ${index}    ${name}    IN ENUMERATE    @{bip_names}
#         Convert BIP To CSV By MCShark   ${name}    ${OUTPUT_DIR}/csv_drx_${drxprofile}.csv    ${filter}    ${csv_title_list}
#    END
#
#Get DMRSScramblingID From RRC
#    [Arguments]    ${log_file}
#    ${egate_console_file}=    Set Variable    ${log_file}
#    ${DMRSScramblingID}=    Grep File    ${egate_console_file}    pdcch-DMRS-ScramblingID
#    ${regexp}    Catenate    SEPARATOR=    pdcch-DMRS-ScramblingID\\s+(?P<scell>\\d+)
#    ${scell_DMRSScramblingID_list}    String.Get Regexp Matches    ${DMRSScramblingID}    ${regexp}    scell
#    Set Test Variable    ${scell1_DMRSScramblingID}    @{scell_DMRSScramblingID_list}[0]
#    Set Test Variable    ${scell2_DMRSScramblingID}    @{scell_DMRSScramblingID_list}[1]
#    Set Test Variable    ${scell3_DMRSScramblingID}    @{scell_DMRSScramblingID_list}[2]
#
#Common Suite Setup
#    Suite Setup Update GNB    log=${False}
#    Modify UTE SCTP Timeout
#    Modify AP SCTP Timeout
#    Configure UTE ETH3
#    Send Swconfig for GNB    ${gnb_swconfig}
#
#Stop SA UE UL and DL Traffic Internal
#    ute_wtssim.Execute Egate Command    cmd=trf_data_stop ue\=${UE_ID} pdu\=1 dir\=ul trf_id\=1
#    ute_wtssim.Execute Egate Command    cmd=trf_data_stop ue\=${UE_ID} pdu\=1 dir\=dl trf_id\=1
#    ute_wtssim.Execute Egate Command    cmd=trf_data_stop ue\=${UE_ID} pdu\=1 dir\=dl trf_id\=2
#
#Setup TL For Each Case
#    [Arguments]    ${scf_file}    ${iphy_name}    ${wts_cfg_name}
#    Verify Coam Site Is Ready
#    Create Test Directory
#    Add RD Parameters To GNB Swconfig File    ${6137_B6_COMMON_RD}
#    Modify IPHY File And Send to Airphone    ${LOCAL_IPHY_DIR}/${iphy_name}
#    Full Commission With SCF File    ${scf_file}
#    Sleep    120S    wait gnb and airphone all reboot avaliable.
#    Reboot TL And Check Configured
#    Set WTS Files Name For Each Cases    ${wts_cfg_name}
#
#Start SA Internal Traffic
#    [Arguments]    ${ue_id}    ${pdu_id}    ${dir}    ${mbps}    ${trf_id}=1    ${seconds}=60
#    [Documentation]    This keyword is to start traffic on eGate.
#    ...    Expected output is: "UE IS ACTIVE" on eGate.
#    ...    | Input Parameters | Man. | Description |
#    ...    | ue_id | Yes | ue id |
#    ...    | bearer_id | Yes | bearer_id |
#    ...    | mbps | Yes | mbps |
#    ...    | trf_id | No | trf_id, default is 1 |
#    Log To Console    start Internal traffic...
#    ute_wtssim.Execute Egate Command
#    ...    cmd=trf_data_start ue\=${ue_id} pdu\=${pdu_id} dir\=${dir} mbps\=${mbps} trf_id\=${trf_id} seconds\=${seconds}
#    Sleep    5s    reason=wait traffic is stable
#
#Basic Flow For Ue Attach And Pdu Setup
#    [Arguments]    ${ue_id}=${UE_ID}
#    SA 5G Attach    ue_id=${ue_id}
#    SA Set Traffic Type To Internal    ue_id=${ue_id}    pdu_id=1
#    SA 5G PDU Session Setup    ue_id=${ue_id}
#
#Trigger A1 Scell Addition
#   [Arguments]    ${UE_ID}    ${meas_id}=1
#    ute_wtssim.Execute Egate Command
#    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=${meas_id} event=A1 srsrp_nr=120
#
#Start Gnb BIP Log
#    [Arguments]    ${duration}=600
#    Run Keyword If    "${SW_VERSION}"==""    Get Software Version
#    Run Keyword If    "${L1_TYPE}"==""    Get L1Bypass Type
#    Run Keyword If    "${FCT_BOARD_TYPE}"==""    Get Control Board Type    #${FCT_BOARD_TYPE}
#    Run Keyword If    "${SW_VERSION}"=="SBTS00" and '${L1_TYPE}'=='FS' and '${FCT_BOARD_TYPE}'!='ASOE' and '${FCT_BOARD_TYPE}'!='ASIM'
#    ...    Start GNB BIP By Admin Method    ${duration}
#    ...    ELSE IF    "${SW_VERSION}">="SBTS22R4" and '${L1_TYPE}'=='FS' and '${FCT_BOARD_TYPE}'!='ASOE' and '${FCT_BOARD_TYPE}'!='ASIM'
#    ...    Start GNB BIP By Admin Method    ${duration}
#    ...    ELSE    Start Gnb BIP Log By lfs-nw_switch-mirror-tool    ${duration}
#
#Stop Gnb BIP Log
#    [Arguments]    ${log_dir}=${OUTPUT_DIR}
#    Run Keyword If    "${SW_VERSION}"=="SBTS00" and '${L1_TYPE}'=='FS' and '${FCT_BOARD_TYPE}'!='ASOE' and '${FCT_BOARD_TYPE}'!='ASIM'
#    ...    Stop Gnb BIP By Admin Method    ${log_dir}
#    ...    ELSE IF    "${SW_VERSION}">="SBTS22R4" and '${L1_TYPE}'=='FS' and '${FCT_BOARD_TYPE}'!='ASOE' and '${FCT_BOARD_TYPE}'!='ASIM'
#    ...    Stop Gnb BIP By Admin Method    ${log_dir}
#    ...    ELSE    Stop Gnb BIP Log By lfs-nw_switch-mirror-tool    ${log_dir}
#
#Check DRX From BIP
#    [Arguments]    ${tc_id}
#    Log To Console    Check DRX on SCell...
#    Convert BIP To CSV By MCShark For CB006137-C-UPD003    ${tc_id}
#    A2A_Check_CSV_Table    ${CURDIR}/A2A/UPD003/ttitrace_c_upd003_${tc_id}.ini    ${OUTPUT_DIR}/csv_drx_upd003_${tc_id}.csv
#
#Convert BIP To CSV By MCShark
#    [Arguments]    ${bip_file}    ${output_file}    ${filter}    ${csv_title_list}
#    ${tashark_version}=    Get Tshark Version
#    ${mcshark_file}    Set Variable    ${MCSHARK_PLUGIN}/${tashark_version}/epan/mcshark-*buster.so
#    ${res}    Run Keyword And Return Status    OperatingSystem.Should Exist    ${mcshark_file}
#    Run Keyword If    '${res}'=='False'    Download MCShark To UTE
#    ${csv_title}=    Set Variable
#    FOR    ${column}   IN    @{csv_title_list}
#        ${csv_title}=    Set Variable    ${csv_title} -e ${column}
#    END
#    ${cmd}=    Catenate    tshark -r ${bip_file} -Y '${filter}' -T fields -e _ws.col.No. -e _ws.col.Info
#    ...    ${csv_title} -E header=y -E separator=, -E quote=d -E occurrence=a > ${output_file}
#    OperatingSystem.Run    ${cmd}
#    OperatingSystem.File Should Not Be Empty    ${output_file}    msg=No CSV file is converted! Please check whether filter message name is changed!
#
#A2A_Check_CSV_Table
#    [Arguments]    ${ini_file}    ${check_csv_file}    ${log_path}=${OUTPUT_DIR}
#    ${path_name}	${file_name}=    OperatingSystem.Split Path    ${check_csv_file}
#    ${backup_file}=    OperatingSystem.Join Path    ${path_name}    backup_${file_name}
#    OperatingSystem.Copy File    ${check_csv_file}    ${backup_file}
#    CSV_PRE_DEAL.Delete Blank Space For Mcshark Sencond Column    ${backup_file}
#    ...    ${check_csv_file}
#    ta_a2a.Check Log With Au2anlysis    ${ini_file}    i    ${check_csv_file}
#    ...    save_log_directory=${log_path}
