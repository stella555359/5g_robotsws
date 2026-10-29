*** Settings ***
Force Tags      CLOUD_5G_I_MP_AP_LOOO    OPTION_RELATED_ARTIFACTS_5G   VARIANT_SANSA_FS_CPRI_CMWV_FDD
...             SBTS00   CONFIGURED   5G_RAN   RAN_5G   RAN_5G_FDD   5G_RAN_FDD   CRT


Documentation    :copyright: Nokia
...              :authors: Meghana
...              :contact: Meghana.s@nokia.com
...              This user scenario describes the verification of UE behavior in MBSFN msg2 slot with DSS and enhanced PRB pooling.
...              In the past, a degradation of the NR CFRA RACH success rate with some UE types was observed,
...              when CSI-IM and CSI-RS for ACQ are located in msg2 slot with DSS enabled.

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
#Resource         ../resources/robot/WTS_Runner_BF_CA_HO_Keywords.robot
Resource         taf/rfrl/common_resources/robot/coam.robot
#Resource         ../resources/robot/Setup_Env.robot
#Resource         ../resources/robot/Airphone.robot
#Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ./resources/CB009215_keyword.robot
#Resource         ../resources/robot/common_log_collection.robot
#Resource         ../resources/robot/Common_Keywords.robot
#Resource         ../5GC000937/resources/5GC000937_Keywords.robot
#Library          ../../resources/python/CPRT_Capture.py
Library          ute_syslog
Resource         CB009215_C1_Activation_of_PRB_pooling_with_ZAB.robot


*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/ET_CB008983-B_DSS_NSA_N1_10MHz_UL_1Layer.lua
${wts_cfg_file3}     ${CURDIR}/config/basic_setup_B1_B3_4_cell_2AMF.lua
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}      1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${TRF_ID3}    3
${TRF_ID4}    4
${epc_log_path}    /tmp/
@{UEsList_CFRA}    UeId:21    UeId:22    UeId:23    UeId:24    UeId:25    UeId:26    UeId:27    UeId:28    UeId:29
...      UeId:30    UeId:31    UeId:32    UeId:33    UeId:34    UeId:35    UeId:36    UeId:37    UeId:38     UeId:39
#${maxNumLayerPrbL1Sp_DL}    392
#${maxNumStreamPrbL1Sp_DL}    392
#${maxNumLayerPrbL1Sp_UL}    196
#${maxNumStreamPrbL1Sp_UL}    392
#${maxNumWbStreamPrbL1Sp}     208
${maxNumLayerPrbL1Sp_DL}    636
${maxNumStreamPrbL1Sp_DL}    636
${maxNumLayerPrbL1Sp_UL}    318
${maxNumStreamPrbL1Sp_UL}    636
${maxNumWbStreamPrbL1Sp}     424
${SCFC}=   ${CURDIR}/config/SCF/CB009215_DSS_B4_scf_.xml
${AP_XML}=      ${CURDIR}/config/SCF/CB009215_DSS_B4_iphy.xml
${r&d_parameter}      0x580758=1;0x58057a=4;0x58057c=0x7800;0x58057e=0x100;0x580117=1
${r&d_parameter1}     0x58012d=3;0x580758=1;0x580690=1;0x58057a=4;0x58057c=0x7800;0x58057e=0x100;0x580117=1
@{PCI_list4}  50    51    52    53

*** Test Cases ***
[1][1.0] CB009215-B_Verification_of_UE_behavior_in_a_MBSFN_msg2_slot_with_DSS_and_enhanced_PRB_pooling_by_CFRA_based_attaching_multiple_NSA_Ues
    [Tags]   TC01
    [Setup]     Run keywords    Prepare TL with all config files
    ...                 AND     Run Keyword and Ignore Error      Suite setup from scratch
    ...                 AND     Update GNB R&D Parameter   ${LOG_PATH}   ${r&d_parameter}
    ...                 AND     Download and Modify Vendor File and Perform Commissioning   ${LOG_PATH}
    ...     ${maxNumLayerPrbL1Sp_DL}   ${maxNumStreamPrbL1Sp_DL}   ${maxNumLayerPrbL1Sp_UL}   ${maxNumStreamPrbL1Sp_UL}   ${maxNumWbStreamPrbL1Sp}
    ...                 AND     sleep    300s
    ...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}
    ...                 AND     sleep      20s
    ...                AND     Cell bringup DSS-Phase3
    ...                 AND     sleep    300s
    ...                 AND     Check gNB Bulid
    Run CB009215-B_Verification_of_UE_behavior_in_a_MBSFN_msg2_slot_with_DSS_and_enhanced_PRB_pooling_by_CFRA_based_attaching_multiple_NSA_Ues
    [Teardown]    Run keywords    Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
    ...                 AND     Link SCOUT SCF to Configuration ID for Reporting
    ...                 AND     Run Keyword and Ignore Error    Get Snapshot


[1]CB009215_C1_Activation_of_PRB_pooling_with_Zero-Allocation_symbol_Bypass_ZAB_functionality
    [Tags]   TC02
    [Setup]    Run keywords        BuiltIn.Set Suite Variable     ${AP_XML}       ${CURDIR}/config/SCF/CB009215_C1_4Cell_A4_20Mhz_GMC_iphy.xml
    #[Setup]    Run keywords        Suite setup from scratch
    ...                 AND        Suite setup from scratch
    ...                 AND    Perform SCF Delta Commissioning with CB009215_4CELL_C1.json
    ...                 AND    sleep    100s
    ...                 AND    Perform SCF Delta Commissioning with CB009215_4CELL_2AMF.json
    ...                 AND    sleep    180s
    ...                 AND    Prepare TL with IPHY file change
    ...                 AND     Update GNB R&D Parameter   ${LOG_PATH}   ${r&d_parameter1}
    ...                 AND     Download and Modify Vendor File and Perform Commissioning   ${LOG_PATH}
    ...       ${maxNumLayerPrbL1Sp_DL}   ${maxNumStreamPrbL1Sp_DL}   ${maxNumLayerPrbL1Sp_UL}   ${maxNumStreamPrbL1Sp_UL}   ${maxNumWbStreamPrbL1Sp}
    ...                 AND     sleep    300s
    ...                 AND     Add routes 3AMF
    ...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file3}
    Set Suite Variable   @{PhysCellID}      50    51    52    53
    Run CB009215_C1_Activation_of_PRB_pooling_with_Zero-Allocation_symbol_Bypass_ZAB_functionality
    [Teardown]    Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
    ...                 AND     Link SCOUT SCF to Configuration ID for Reporting
    ...                 AND     Run Keyword and Ignore Error    Get Snapshot

*** Keywords ***
Run CB009215-B_Verification_of_UE_behavior_in_a_MBSFN_msg2_slot_with_DSS_and_enhanced_PRB_pooling_by_CFRA_based_attaching_multiple_NSA_Ues
    [Documentation]   in this testcase verify the multiue NSA with DSS
    [Tags]    QC_323532      QCD_MN_RAN     QCP_RAN_ET
    Checking All cells are ONAIR
    Start Log      btslog
    Start AP Syslog    step1
    sleep    100s
    CFRA NSA call    CFRA_start_ue_id=21      CFRA_end_ue_id=40      dl_rate=16      ul_rate=9
    sleep    90s
    ${syslog}    Stop Log    btslog       test_scenario=syslog
    Stop And Collect AP Syslog    step1
    AP Syslog should contain CFRA RACH message     log_name=step1     UEsList=${UEsList_CFRA}
    AP Syslog should contain CFRA Attach message   log_name=step1     UEsList=${UEsList_CFRA}
    sleep    20s
    MultiUE Detach for NSA    start_ue_id=21     stop_ue_id=40

    MultiUE NSA call    start_ue_id=61    end_ue_id=61    DL_Rate=16    UL_Rate=9
    Sleep    20s
    Validate NSA Traffic    start_ue_id=61    end_ue_id=61    DL_Rate=16    UL_Rate=9
    MultiUE NSA call    start_ue_id=101    end_ue_id=101    DL_Rate=16    UL_Rate=9
    Sleep    20s
    Validate NSA Traffic    start_ue_id=101    end_ue_id=101    DL_Rate=16    UL_Rate=9
    MultiUE NSA call    start_ue_id=141    end_ue_id=141    DL_Rate=16    UL_Rate=9
    Sleep    20s
    Validate NSA Traffic    start_ue_id=141    end_ue_id=141    DL_Rate=16    UL_Rate=9

    Register and trigger GBR biDir Traffic 1UE per Cell      Start_UE=1   NumCells=4   DL_Rate=10  UL_Rate=10   Step_Size=40
    Sleep    20s
    Validate biDir GBR Traffic for 1UE per cell    Start_UE=1   NumCells=4   DL_Rate=10  UL_Rate=10   Step_Size=40

    Register and trigger NonGBR biDir Traffic 1UE per Cell    Start_UE=5   NumCells=4   DL_Rate=40   UL_Rate=10   Step_Size=40
    Sleep     20s
    Validate bidir SCH data 1UE per cell    Start_UE=5   NumCells=4   DL_Rate=40   UL_Rate=4   Step_Size=40

    Collect TTI Log   Test_Step=Step2_4Cell_Equal_FullLoad   Duration=500ms
    Decode and Valiadate Prb Allocation from TTI Logs  Test_Step=Step2_4Cell_Equal_FullLoad
    ...   CellId=${PCI_list4}   DL_Threshold1=40    DL_Threshold2=60   UL_Threshold1=30    UL_Threshold2=60
#    Start Log    sherpa
#    Sleep    1s
#    ${sherp_path_tti}    Stop Log     sherpa     test_scenario=Traffic_load_inc_L1SP1
#    log to console    ${sherp_path_tti}
#    Decode Sherpa pcap    Traffic_load_inc_L1SP1
#    Set Global Variable     ${sherpa_output_path}     ${sherp_path_tti}[sherpa]
#    Copy Sherpa Files    ${sherpa_output_path}
#    log to console    ${sherpa_output_path}
#    Calling Panda Extract Csv function    ${sherpa_output_path}
#    Run Keyword and continue on failure      Verify numallocatedStreamPRBsDL      ${sherpa_output_path}
#    Run Keyword and continue on failure      Verify numallocatedStreamPRBsUL      ${sherpa_output_path}

Collect TTI and Sherpa Logs
    [Arguments]    ${Test_Step}  ${Duration}
    Start Log      ttitrace
    Sleep     ${Duration}
    ${tti_path}    Stop Log       ttitrace   test_scenario=${Test_Step}
    Sleep   5s

Decode and Valiadate Prb Allocation from TTI Logs Only UL
    [Arguments]    ${Test_Step}   ${CellId}    ${DL_Threshold1}    ${DL_Threshold2}      ${UL_Threshold1}    ${UL_Threshold2}
    ${TEST_NAME}      replace string    ${TEST_NAME}      ${SPACE}      _
    Decode TTI Trace UL   ${Test_Step}
    FOR  ${Cell}  IN  @{CellId}
        ${TEST_NAME}      replace string    ${TEST_NAME}      ${SPACE}      _
         Validate cell prballocation from TTI traces multicell Only UL    ${LOG_PATH}/${TEST_NAME}/gNB/ttitrace/${Test_Step}    ${Cell}
         ...       ${DL_Threshold1}    ${DL_Threshold2}      ${UL_Threshold1}    ${UL_Threshold2}
    END
    Sleep    40s

Validate cell prballocation from TTI traces multicell Only UL
    [Arguments]   ${csv_file_path}  ${CellId}    ${DL_Threshold1}    ${DL_Threshold2}      ${UL_Threshold1}    ${UL_Threshold2}
    log to console   python123 ...
    ${UL_Check}   Verify cell ulprballocation multicell_G      ${csv_file_path}/output_ul_formated.csv      ${CellId}
    ...      ${DL_Threshold1}    ${DL_Threshold2}      ${UL_Threshold1}    ${UL_Threshold2}
    log to console   Debug123 ...
    run keyword and continue on failure   Run Keyword if   ${DL_Check}!=${True}   Fail   prb allocation failure
    run keyword and continue on failure   Run Keyword if   ${UL_Check}!=${True}   Fail   prb allocation failure

Decode TTI Trace UL
    [Arguments]    ${ttitrace_path}=${EMPTY}
    Dated Log                        converting ttitrace pcap to csv
    ${tti_path}      Set Variable     ${LOG_PATH}/${TEST_NAME}/gNB/ttitrace/${ttitrace_path}/
    Common Convert Ttitrace From Pcap To Excelcsv        ${tti_path}
    Common Format Tti In Stream Mode         ${tti_path}/output_ul.csv     ${tti_path}/output_ul_formated.csv

Start AP Syslog
    [Arguments]     ${log_name}     ${log_dir}=${OUTPUT_DIR}/AP_Syslog/
    Log to Console    Starting AP Syslog Collection
    ute_syslog.Start Syslog
    ...    log_dir=${log_dir}
    ...    log_name=AP_syslog_${log_name}.log
    ...    ip=192.168.200.126
    ...    alias=AP_syslog

Stop And Collect AP Syslog
    [Arguments]     ${log_name}     ${log_dir}=${OUTPUT_DIR}/AP_Syslog/
    Log to Console    Stopping AP Syslog Collection ${log_name} ${log_dir}
    ute_syslog.Collect Syslog Results    alias=AP_syslog


AP Syslog should contain CFRA RACH message
    [Arguments]      ${log_name}    ${UEsList}
    log to console     Verifying UE is connected with CFRA RACH  in AP syslog
   ${status}  run  command=sudo cat ${OUTPUT_DIR}/AP_Syslog/AP_syslog_${log_name}.log | grep 'UE State changed to CONNECTED with contention free RA'
    FOR   ${item}   IN    @{UEsList}
         Should Contain   ${status}     ${item}
    END

AP Syslog should contain CFRA Attach message
    [Arguments]      ${log_name}    ${UEsList}
    log to console     Verifying UE is connected with CFRA RACH  in AP syslog
    ${status} =   run    command=sudo cat ${OUTPUT_DIR}/AP_Syslog/AP_syslog_${log_name}.log | grep 'Attach OK'
    FOR   ${item}   IN    @{UEsList}
         Should Contain   ${status}     ${item}
    END

CFRA NSA call     #NSA
    [Arguments]    ${CFRA_start_ue_id}    ${CFRA_end_ue_id}     ${dl_rate}     ${ul_rate}
    [Documentation]    This keyword is used for running multiple NSA calls
    X2AP Link Should be UP
    FOR	    ${nsa_ue_idx}   IN RANGE    ${CFRA_start_ue_id}	  ${CFRA_end_ue_id}+1
    LTE Attach should be Successful    NSA_UE_ID=${nsa_ue_idx}
    CFRA NSA RACH Attach      ${nsa_ue_idx}
    Trigger DL Traffic for NSA    ue_id=${nsa_ue_idx}    Traffic_rate=mbps     dl_rate=${dl_rate}      trf_id=1
	Trigger UL Traffic for NSA    ue_id=${nsa_ue_idx}    Traffic_rate=mbps     ul_rate=${ul_rate}      trf_id=1
    END

Cell bringup DSS-Phase3
    wtsrunner.script   file=${CURDIR}/config/SCF/Script/DSS_CMNDS_cell1.lua
    Sleep    20s


Checking All cells are ONAIR
     wtsrunner.enb_cell_ib_disp    enb=2    cell=1
     wtsrunner.enb_cell_ib_disp    enb=2    cell=2
     wtsrunner.enb_cell_ib_disp    enb=2    cell=3
     wtsrunner.enb_cell_ib_disp    enb=2    cell=4


MultiUE NSA call     #NSA
    [Arguments]    ${start_ue_id}    ${end_ue_id}   ${DL_Rate}   ${UL_Rate}
    [Documentation]    This keyword is used for running multiple NSA calls
    X2AP Link Should be UP
    FOR	    ${nsa_ue_idx}   IN RANGE    ${start_ue_id}	  ${end_ue_id}+1
    LTE Attach should be Successful    NSA_UE_ID=${nsa_ue_idx}
    UE Attach should be Successful   NSA_UE_ID=${nsa_ue_idx}
    Trigger DL Traffic for NSA    ue_id=${nsa_ue_idx}    Traffic_rate=mbps     dl_rate=${dl_rate}      trf_id=1
	Trigger UL Traffic for NSA    ue_id=${nsa_ue_idx}    Traffic_rate=mbps     ul_rate=${ul_rate}      trf_id=1
    END

Validate NSA Traffic
    [Arguments]   ${start_ue_id}   ${end_ue_id}    ${DL_Rate}   ${UL_Rate}
	FOR  ${UE}   IN RANGE   ${start_ue_id}    ${end_ue_id}+1
		Run Keyword And Continue On Failure   Validate DL Traffic For NSA    ${UE}   ${DL_Rate}   id=2
		Run Keyword And Continue On Failure   Validate UL Traffic For NSA    ${UE}   ${UL_Rate}   id=2
	END


Register and trigger GBR biDir Traffic 1UE per Cell
    [Arguments]   ${Start_UE}   ${NumCells}   ${DL_Rate}   ${UL_Rate}  ${Step_Size}=10   ${Traffic_rate}=mbps
    FOR  ${UE}   IN RANGE   ${Start_UE}   (${NumCells}-1)*${Step_Size}+${Start_UE}+1   ${Step_Size}
        log to console     UEID: ${UE} :GBR call triggering now...
        UE Register should be Successful     ${UE}   gw_id=${UE}
        Run Keyword And Continue On Failure   UE PDU Modfication should be Successful  ${UE}   qosflows_to_add=2
        sleep   3s
        Run Keyword And Continue On Failure   UE PDU Modfication should be Successful  ${UE}   qosflows_to_add=3
        sleep   3s
        Run Keyword And Continue On Failure   UE PDU Modfication should be Successful  ${UE}   qosflows_to_add=4
        sleep   3s
        Run Keyword And Continue On Failure   Trigger VoNR DL Traffic for SA   ${UE}   qfi_id=3   rtp_codec=custom
        Run Keyword And Continue On Failure   Trigger VoNR UL Traffic for SA   ${UE}   qfi_id=3   rtp_codec=custom
        Run Keyword And Continue On Failure   Trigger DL Traffic for SA   ue_id=${UE}
        ...   Traffic_rate=${Traffic_rate}   dl_rate=${DL_Rate}   qfi_id=4
        Run Keyword And Continue On Failure   Trigger UL Non Bursty Data Traffic for SA   ue_id=${UE}
        ...   Traffic_rate=${Traffic_rate}   ul_rate=${UL_Rate}   qfi_id=4
        sleep   5s
        Run Keyword And Continue On Failure   Validate DL Traffic For SA   ue_id=${UE}   dl_rate=${DL_Rate}   qfi_id=4
        Run Keyword And Continue On Failure   Validate UL Traffic For SA   ue_id=${UE}   ul_rate=${UL_Rate}   qfi_id=4
     log to console   Ue${UE} ViNR call Successful
    END

Register and trigger NonGBR biDir Traffic 1UE per Cell
    [Arguments]   ${Start_UE}   ${NumCells}   ${DL_Rate}   ${UL_Rate}   ${Step_Size}=10   ${Traffic_rate}=mbps
              FOR  ${UE}   IN RANGE   ${Start_UE}   (${NumCells}-1)*${Step_Size}+${Start_UE}+1   ${Step_Size}
                  log to console    UEID: ${UE} :Non GBR call triggering now...
                  UE Register should be Successful    ${UE}   gw_id=${UE}
                  Trigger DL Data Traffic for SA    ue_id=${UE}    Traffic_rate=${Traffic_rate}     dl_rate=${DL_Rate}      trf_id=${TRF_ID}
                  Trigger UL Data Traffic for SA    ue_id=${UE}    Traffic_rate=${Traffic_rate}     ul_rate=${UL_Rate}      trf_id=${TRF_ID}
              END

Validate bidir SCH data 1UE per cell
     [Arguments]   ${Start_UE}   ${NumCells}   ${DL_Rate}   ${UL_Rate}   ${Step_Size}=10
     FOR  ${UE}   IN RANGE   ${Start_UE}   (${NumCells}-1)*${Step_Size}+${Start_UE}+1   ${Step_Size}
        ${pcell_dl_tput}=    WTS_Runner_BF_CA_HO_Keywords.Get AVG DL DATA TRAFFIC For Given CC   ue_id=${UE}  scell_idx=0  unit=Mbps
        Run Keyword And Continue On Failure   Should Be True    ${pcell_dl_tput} > ${DL_Rate}
        ${pcell_ul_tput}=    Get AVG UL DATA TRAFFIC For Given CC   ue_id=${UE}  scell_idx=0  unit=Mbps
        Run Keyword And Continue On Failure   Should Be True    ${pcell_ul_tput} > ${UL_Rate}
     END

Validate biDir GBR Traffic for 1UE per cell
    [Arguments]   ${Start_UE}   ${NumCells}   ${DL_Rate}   ${UL_Rate}   ${Step_Size}=10   ${Traffic_rate}=mbps
              Log to console     ${Traffic_rate}
              FOR  ${UE}   IN RANGE   ${Start_UE}   (${NumCells}-1)*${Step_Size}+${Start_UE}+1   ${Step_Size}
              Run Keyword And Continue On Failure       Validate DL Traffic For SA     ${UE}   dl_rate=${DL_Rate}   qfi_id=4
              Run Keyword And Continue On Failure       Validate UL Traffic For SA     ${UE}   ul_rate=${UL_Rate}   qfi_id=4
              END


Verify numallocatedStreamPRBsDL
    [Documentation]     print DL NumAllocStreamPrb in SP0 & SP1
    [Arguments]     ${sherpa_output_path}
    ${file_path_Dl_PrbPoolingAllocation_semicolon} =      set variable    ${sherpa_output_path}/tcpdump/Dl_PrbPoolingAllocationSubpool_45_.csv
    ${alloc_streamprb_Dl_SP0}=    Create List
    ${alloc_streamprb_Dl_SP1}=    Create List
    Retrieve PRB Pooling Reports Lines within defined range    file_name=${file_path_Dl_PrbPoolingAllocation_semicolon}
    ...                                                        First_Line=10     Last_line=20
    Dated Log New Line    Saved the PRB Requested values in ${file_path_Dl_PrbPoolingAllocation_semicolon}
    ${alloc_streamprb_Dl_SP0}     Get First Value in a Column against Specified Column In File    file=${file_path_Dl_PrbPoolingAllocation_semicolon}
    ...                                  column_name=NumAllocStreamPrb    regex_prereq=0     colum_prereq=SubPoolId
    ${alloc_streamprb_Dl_SP1}     Get First Value in a Column against Specified Column In File    file=${file_path_Dl_PrbPoolingAllocation_semicolon}
    ...                                  column_name=NumAllocStreamPrb    regex_prereq=1     colum_prereq=SubPoolId
    log to console    NumAllocStreamPrb_SP0= ${alloc_streamprb_Dl_SP0}
    log to console    NumAllocStreamPrb_SP1= ${alloc_streamprb_Dl_SP1}

Verify numallocatedStreamPRBsUL
    [Documentation]     print UL NumAllocStreamPrb in SP0 & SP1
    [Arguments]     ${sherpa_output_path}
    ${file_path_Ul_PrbPoolingAllocation_semicolon} =      set variable    ${sherpa_output_path}/tcpdump/Ul_PrbPoolingAllocationSubpool_45_.csv
    ${alloc_streamprb_Ul_SP0}=    Create List
    ${alloc_streamprb_Ul_SP1}=    Create List
    Retrieve PRB Pooling Reports Lines within defined range    file_name=${file_path_Ul_PrbPoolingAllocation_semicolon}
    ...                                                        First_Line=10     Last_line=20
    Dated Log New Line    Saved the PRB Requested values in ${file_path_Ul_PrbPoolingAllocation_semicolon}
    ${alloc_streamprb_Ul_SP0}     Get First Value in a Column against Specified Column In File    file=${file_path_Ul_PrbPoolingAllocation_semicolon}
    ...                                  column_name=NumAllocStreamPrb    regex_prereq=0     colum_prereq=SubPoolId
    ${alloc_streamprb_Ul_SP1}     Get First Value in a Column against Specified Column In File    file=${file_path_Ul_PrbPoolingAllocation_semicolon}
    ...                                  column_name=NumAllocStreamPrb    regex_prereq=1     colum_prereq=SubPoolId
    log to console    NumAllocStreamPrb_SP0= ${alloc_streamprb_Ul_SP0}
    log to console    NumAllocStreamPrb_SP1= ${alloc_streamprb_Ul_SP1}

MultiUE Detach for NSA
    [Arguments]    ${start_ue_id}    ${stop_ue_id}
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${stop_ue_id}+${1}
    UE Detach should be Successful   ${ue_id}
    END
