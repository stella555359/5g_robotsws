*** Settings ***
#Force Tags      CLOUD_5G_I_LO_AP_LOOO    OPTION_RELATED_ARTIFACTS_5G   VARIANT_SANSA_FS_CPRI_CMWV_FDD
#...             SBTS00   CONFIGURED   5G_RAN   RAN_5G   RAN_5G_FDD   5G_RAN_FDD   CRT


Documentation    :copyright: Nokia
...              :authors: Meghana
...              :contact: Meghana.s@nokia.com
Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          ./resources/check_cell_expected_prballocation.py
#Resource         ../resources/robot/WTS_Runner_BF_CA_HO_Keywords.robot
#Resource         taf/rfrl/common_resources/robot/coam.robot
#Resource         ../resources/robot/Setup_Env.robot
#Resource         ../resources/robot/Airphone.robot
#Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ./resources/CB009215_keyword.robot
#Resource         ../resources/robot/common_log_collection.robot
#Resource         ../resources/robot/Common_Keywords.robot
Library          ./resources/check_layer_prballocation.py


*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/basic_setup_AB_6cells.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${TRF_ID3}    3
${TRF_ID4}    4
${epc_log_path}    /tmp/
${maxNumLayerPrbL1Sp_DL}    742
${maxNumStreamPrbL1Sp_DL}    742
${maxNumLayerPrbL1Sp_UL}    446
${maxNumStreamPrbL1Sp_UL}    742
${maxNumWbStreamPrbL1Sp}     424
${SCFC}=   ${CURDIR}/config/SCF/CB009215_AB_6Cell_A2_A4_20Mhz_DifferentAntenna_SCF.xml
${AP_XML}=      ${CURDIR}/config/SCF/CB009215_AB_TC_Different_antenna_iphy.xml
${r&d_parameter}     0x58012d=3;0x580758=0;0x580690=0;0x58057a=4;0x58057c=0x7800;0x58057e=0x100
@{PhysCellID}      50     52     54

*** Keywords ***
Run CB009215-AB_Validate_Layer-PRB_capacity_consideration_during_stream_PRB_allocation_for_a_specific_mix_of_cells_with_different_no_of_antennas
    [Documentation]   in this testcase verify that prb allocation for different antennas
    Start Log      syslog
    Register and trigger Multiple NonGBR biDir UE Traffic in a Cell    Start_UE=1    End_UE=6    DL_Rate=50    UL_Rate=50
    Register and trigger Multiple GBR biDir UE Traffic in a Cell    Start_UE=7    End_UE=12    DL_Rate=10    UL_Rate=10
    sleep    20s
    Run Keyword and continue on failure    Validate biDir NonGBR Traffic for MultiUE in a cell   Start_UE=1   End_UE=6   DL_Rate=50   UL_Rate=50

    Run Keyword and continue on failure     Validate GBR UL Traffic      Start_UE=7     End_UE=12      UL_Rate=10    Traffic_rate=mbps     qfi_id=4
    Run Keyword and continue on failure     Validate GBR DL Traffic      Start_UE=7     End_UE=12      DL_Rate=10    Traffic_rate=mbps     qfi_id=4

    ${syslog}    Stop Log     syslog     test_scenario=syslog
    MultiUE NSA call    start_ue_id=101    end_ue_id=106    DL_Rate=16    UL_Rate=9
    sleep    20s
    Run Keyword and continue on failure    Validate NSA Traffic    start_ue_id=101    end_ue_id=106    DL_Rate=16    UL_Rate=9

    Collect TTI and Sherpa Logs2   Test_Step     500ms
    Decode and Verify numallocatedStreamPRBs for different antennas in UL      Test_Step      PhycellidandminPRB



Collect TTI and Sherpa Logs2
    [Arguments]    ${Test_Step}  ${Duration}
    Start Log      ttitrace
    Sleep     ${Duration}
    ${tti_path}    Stop Log       ttitrace   test_scenario=${Test_Step}
    Sleep   5s

Decode and Verify numallocatedStreamPRBs for different antennas in UL
    [Arguments]    ${Test_Step}      ${PhycellidandminPRB}
    Decode TTI Trace UL   ${Test_Step}
    FOR  ${Cell}  IN  @{PhysCellID}
         Verify layer ulprballocation for subpool1    ${LOG_PATH}/${TEST_NAME}/gNB/ttitrace/${Test_Step}    ${PhycellidandminPRB}
    END
    Sleep    40s

Verify layer ulprballocation for subpool1
    [Arguments]   ${csv_file_path}  ${PhysCellID}
    log to console   PhysCellID ...
    log to console   python123 ...
    ${UL_Check}   Verify cell layer ulprballocation      ${csv_file_path}/output_ul_formated.csv      ${PhysCellID}
    log to console   Debug123 ...
    log to console   PhysCellID ...
    run keyword and continue on failure   Run Keyword if   ${UL_Check}!=${True}   Fail   prb allocation failure

Verify cell layer ulprballocation
    [Arguments]   ${csv_file_path}      ${PhysCellID}
    log to console   PhysCellID ...     ${PhysCellID}
    log to console   Debug123 ...
#    log to console   PhysCellID ...
    ${Result}      check_layer_prballocation.check_prballocation     ${csv_file_path}
    [Return]   ${Result}


MultiUE NSA call     #NSA
    [Arguments]    ${start_ue_id}    ${end_ue_id}   ${DL_Rate}   ${UL_Rate}
    [Documentation]    This keyword is used for running multiple NSA calls
    X2AP Link Should be UP
    FOR	    ${nsa_ue_idx}   IN RANGE    ${start_ue_id}	  ${end_ue_id}+1
    LTE Attach should be Successful    NSA_UE_ID=${nsa_ue_idx}
    UE Attach should be Successful   NSA_UE_ID=${nsa_ue_idx}
    Trigger DL Traffic for NSA    ue_id=${nsa_ue_idx}    Traffic_rate=mbps     dl_rate=${DL_Rate}      trf_id=1
	Trigger UL Traffic for NSA    ue_id=${nsa_ue_idx}    Traffic_rate=mbps     ul_rate=${UL_Rate}      trf_id=1
    END

Validate NSA Traffic
    [Arguments]   ${start_ue_id}   ${end_ue_id}    ${DL_Rate}   ${UL_Rate}
	FOR  ${UE}   IN RANGE   ${start_ue_id}    ${end_ue_id}+1
		Run Keyword and continue on failure   Validate DL Traffic For NSA    ${UE}   ${DL_Rate}   id=2
		Run Keyword and continue on failure   Validate UL Traffic For NSA    ${UE}   ${UL_Rate}   id=2
	END

Decode TTI Trace UL
    [Arguments]    ${ttitrace_path}=${EMPTY}
    Dated Log                        converting ttitrace pcap to csv
    ${tti_path}      Set Variable     ${LOG_PATH}/${TEST_NAME}/gNB/ttitrace/${ttitrace_path}/
    Common Convert Ttitrace From Pcap To Excelcsv        ${tti_path}
    Common Format Tti In Stream Mode         ${tti_path}/output_ul.csv     ${tti_path}/output_ul_formated.csv