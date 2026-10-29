*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LOOO    OPTION_RELATED_ARTIFACTS_5G   VARIANT_SANSA_FS_CPRI_CMWV_FDD
...             SBTS00   CONFIGURED   5G_RAN   RAN_5G   RAN_5G_FDD   5G_RAN_FDD   CRT

Documentation    :copyright: Nokia
...              :authors:sasv
...              :contact:sagarika.s_v@nokia.com
...              This user scenario describes the activation of a short Buffer Status Report (BSR) limit adaptation.
...              In 3GPP, short BSR index 31 in UL indicates any UE buffer value larger than 150000 bytes.
...              In legacy implementation, short BSR index 31 in UL is mapped to 85000000 bytes,
...              which introduces a drastic step increase for a UE buffer load, and, in turn, to a PRB demand estimation per cell.
...              Subsequently, this may lead to throughput oscillating behavior or the same throughput for cells with different load.
...              Such behavior is mitigated by a short BSR limit adaptation, setting short BSR index 31 to a
...              lower value and allowing more "smooth" buffer load indication.

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ./resources/CB009215_keyword.robot
Resource         ../resources/robot/Common_Keywords.robot
Resource         ../resources/NPS/SWENG/robot/SetConfig.robot
Resource         ../resources/NPS/SWENG/robot/Connect.robot
Resource         ../resources/NPS/SWENG/robot/Tools.robot
Resource          ../resources/NPS/SWENG/robot/WtsCfgConfig.robot
Resource          ../resources/NPS/SWENG/robot/Setup.robot
Resource          CB009215_AB_Different_Antenna.robot
Resource          CB009215-H_Enhancementfor_GBR_Non-GBR_load_estimation.robot


Library    taf.sbts.oam.coam.admin    WITH NAME    admin

Suite Setup   Run Keywords        admin.Setup Admin
...                 AND      admin.Get Current SCF File    ${CURDIR}    default_scf.xml   timeout=100s
...                 AND     admin.Teardown Admin


*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/basic_setup_FDD_G1_4cell.lua
${wts_cfg_file1}     ${CURDIR}/config/basic_setup_FDD_H1_3CELL.lua
${wts_cfg_file2}     ${CURDIR}/config/basic_setup_AB_6cells.cfg
${BTS_ADDRESS}    192.168.255.129
${BTS_PORT}       443
${USE_SSL}        True
${path}     /home/ute/sagu/CRT_G_VERIFICATION/
${configuration_directory}    ${LOG_PATH}
${epc_log_path}    /tmp/
${SCF_Path}    SCF_DU_Setup.xml
${maxNumLayerPrbL1Sp_DL}    636
${maxNumStreamPrbL1Sp_DL}    636
${maxNumLayerPrbL1Sp_UL}    318
${maxNumStreamPrbL1Sp_UL}    636
${maxNumWbStreamPrbL1Sp}     424
@{PCI_CELL1}  50
@{PCI_CELL2}  51
@{PCI_CELL3}  52
${r&d_parameter}     0x58012d=3;0x580758=0;0x580690=0;0x58057a=4;0x58057c=0x7800;0x58057e=0x100;0x580117=1
${r&d_parameter1}     0x58012d=3;0x580758=1;0x580690=1;0x58057a=4;0x58057c=0x7800;0x58057e=0x100;0x580117=1
${r&d_parameter2}     0x58012d=3;0x580758=0;0x580690=0;0x58057a=4;0x58057c=0x7800;0x58057e=0x100;0x580117=0

*** Test Cases ***
[1]CB009215_G1_Activation_of_a_short_Buffer_Status_Report_BSR_limit_adaptation_with_intra_L1_subpool_PRB_pooling
    [Tags]   TC01
    [Setup]    Run keywords        BuiltIn.Set Suite Variable     ${AP_XML}       ${CURDIR}/config/SCF/CB009215_G_4CELL_BSR_iphy_GMC.xml
     ...                AND        Suite setup from scratch
    ...                 AND    Perform SCF Delta Commissioning with CB009215_4CELL_H.json
    ...                 AND    sleep    100s
    ...                 AND    Perform SCF Delta Commissioning with CB009215_4CELL_G1.json
    ...                 AND    sleep    180s
    ...                 AND    Prepare TL with IPHY file change
    ...                 AND     Update GNB R&D Parameter   ${LOG_PATH}   ${r&d_parameter}
    ...                 AND     Download and Modify Vendor File and Perform Commissioning   ${LOG_PATH}
    ...   ${maxNumLayerPrbL1Sp_DL}   ${maxNumStreamPrbL1Sp_DL}   ${maxNumLayerPrbL1Sp_UL}   ${maxNumStreamPrbL1Sp_UL}   ${maxNumWbStreamPrbL1Sp}
    ...                 AND     sleep    300s
    ...                 AND     Add routes 3AMF
    ...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}
    Run CB009215_G1_Activation_of_a_short_Buffer_Status_Report_BSR_limit_adaptation_with_intra_L1_subpool_PRB_pooling
    [Teardown]    Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
        ...                 AND     Link SCOUT SCF to Configuration ID for Reporting
    ...                 AND     Run Keyword and Ignore Error    Get Snapshot
    ...     AND      BuiltIn.Set Test Variable    ${SCFC}    ${CURDIR}/default_scf.xml
    ...     AND      BuiltIn.Set Test Variable    ${AP_XML}    ${CURDIR}/config/default_iphy.xml
    ...     AND      Prepare TL with all config files



[1]CB009215-H1_Verify_GBR_and_Non-GBR_load_estimation_and_reporting_with_PRB_Pooling
    [Tags]   TC02
    [Setup]    Run keywords        BuiltIn.Set Suite Variable     ${AP_XML}       ${CURDIR}/config/SCF/CB009215_H_3Cell_A4_20Mhz_GMC_iphy.xml
    ...    AND    BuiltIn.Set Suite Variable     ${maxNumLayerPrbL1Sp_DL}    742
    ...    AND    BuiltIn.Set Suite Variable     ${maxNumStreamPrbL1Sp_DL}    742
    ...    AND    BuiltIn.Set Suite Variable     ${maxNumLayerPrbL1Sp_UL}    446
    ...    AND    BuiltIn.Set Suite Variable     ${maxNumStreamPrbL1Sp_UL}    742
    ...    AND    BuiltIn.Set Suite Variable     ${maxNumWbStreamPrbL1Sp}     424
    ...    AND    Suite setup from scratch
    ...                 AND    Perform SCF Delta Commissioning with CB009215_3CELL_H.json
    ...                 AND    sleep    180s
    ...                 AND    Perform SCF Delta Commissioning with CELL4_DEL.json
    ...                 AND    sleep    180s
    ...                 AND    Prepare TL with IPHY file change
    ...                 AND     Update GNB R&D Parameter   ${LOG_PATH}   ${r&d_parameter1}
    ...                 AND     Download and Modify Vendor File and Perform Commissioning   ${LOG_PATH}
    ...   ${maxNumLayerPrbL1Sp_DL}   ${maxNumStreamPrbL1Sp_DL}   ${maxNumLayerPrbL1Sp_UL}   ${maxNumStreamPrbL1Sp_UL}   ${maxNumWbStreamPrbL1Sp}
    ...                 AND     sleep    300s
    ...                 AND     Add routes 3AMF
    ...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file1}
    Run CB009215-H1_Verify_GBR_and_Non-GBR_load_estimation_and_reporting_with_PRB_Pooling
    [Teardown]    Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
    ...                 AND     Link SCOUT SCF to Configuration ID for Reporting
    ...                 AND     Run Keyword and Ignore Error    Get Snapshot
    ...     AND      BuiltIn.Set Test Variable    ${SCFC}    ${CURDIR}/default_scf.xml
    ...     AND      BuiltIn.Set Test Variable    ${AP_XML}    ${CURDIR}/config/default_iphy.xml
    ...     AND      Prepare TL with all config files


[1]CB009215-AB_Validate_Layer-PRB_capacity_consideration_during_stream_PRB_allocation_for_a_specific_mix_of_cells_with_different_number_of_antennas
    [Tags]   TC03
    [Setup]   Run keywords    BuiltIn.Set Suite Variable    ${SCFC}    ${CURDIR}/config/SCF/CB009215_AB_6Cell_A2_A4_20Mhz_DifferentAntenna_SCF.xml
    ...     AND    BuiltIn.Set Suite Variable     ${AP_XML}       ${CURDIR}/config/SCF/CB009215_AB_TC_Different_antenna_iphy.xml
    ...                 AND     Prepare TL with all config files
    ...                 AND     Run Keyword and Ignore Error      Suite setup from scratch
    ...                 AND     Update GNB R&D Parameter   ${LOG_PATH}   ${r&d_parameter2}
    ...                 AND     Download and Modify Vendor File and Perform Commissioning   ${LOG_PATH}
    ...     ${maxNumLayerPrbL1Sp_DL}   ${maxNumStreamPrbL1Sp_DL}   ${maxNumLayerPrbL1Sp_UL}   ${maxNumStreamPrbL1Sp_UL}   ${maxNumWbStreamPrbL1Sp}
    ...                 AND     sleep    300s
    ...                 AND     Add routes 3AMF
    ...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file2}
    ...                 AND     Check gNB Bulid
    sleep    60s   reason=waiting for mib sib update
    Set Suite Variable   @{PhysCellID}   50   52   54
    Run CB009215-AB_Validate_Layer-PRB_capacity_consideration_during_stream_PRB_allocation_for_a_specific_mix_of_cells_with_different_no_of_antennas
    [Teardown]   Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
    ...                 AND     Link SCOUT SCF to Configuration ID for Reporting
    ...                 AND     Run Keyword and Ignore Error    Get Snapshot

*** Keywords ***
Run CB009215_G1_Activation_of_a_short_Buffer_Status_Report_BSR_limit_adaptation_with_intra_L1_subpool_PRB_pooling
    [Documentation]   in this testcase verify that BSR
    log to console   Suite setup successful ...
    ${LOG_PATH}   Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Start Log   btslog
	Register and trigger NonGBR biDir UE Traffic in a Cell
	...   Start_UE=1    End_UE=1      UL_Rate=50    Traffic_rate=mbps
	Stop Log    btslog    test_scenario=Step1_cell1
	Register and trigger NonGBR biDir UE Traffic in a Cell
	...   Start_UE=21    End_UE=21      UL_Rate=160    Traffic_rate=mbps

    Sleep    15s
	Validate biDir NonGBR Traffic for MultiUE in a cell only UL
	...    Start_UE=1    End_UE=1      UL_Rate=50    Traffic_rate=mbps
    Collect TTI and Sherpa Logs   Test_Step=Step1_cell1   Duration=500ms
	Validate biDir NonGBR Traffic for MultiUE in a cell only UL
	...    Start_UE=21    End_UE=21       UL_Rate=160    Traffic_rate=mbps
	Collect TTI and Sherpa Logs   Test_Step=Step2_cell3   Duration=500ms

    Decode and Valiadate Prb Allocation from TTI Logs Only UL  Test_Step=Step1_cell1
    ...   CellId=@{PCI_CELL1}    UL_Threshold1=36    UL_Threshold2=80
    Decode and Valiadate Prb Allocation from TTI Logs Only UL  Test_Step=Step2_cell3
    ...   CellId=@{PCI_CELL3}    UL_Threshold1=60    UL_Threshold2=106
    Start Log   btslog
    Run Keyword And Continue On Failure    Register and trigger NonGBR biDir UE Traffic in a Cell
	...   Start_UE=6    End_UE=7       UL_Rate=25    Traffic_rate=mbps
	sleep    10s
    Run Keyword And Continue On Failure    Validate biDir NonGBR Traffic for MultiUE in a cell only UL
	...    Start_UE=6    End_UE=7      UL_Rate=25    Traffic_rate=mbps
    Collect TTI and Sherpa Logs   Test_Step=Step3_cell1   Duration=500ms
    Stop Log    btslog    test_scenario=Step3_cell1
    Decode and Valiadate Prb Allocation from TTI Logs Only UL  Test_Step=Step3_cell1
    ...   CellId=@{PCI_CELL1}    UL_Threshold1=36    UL_Threshold2=106

*** Keywords ***
Collect TTI and Sherpa Logs
    [Arguments]    ${Test_Step}  ${Duration}
    Start Log      ttitrace
    Sleep     ${Duration}
    ${tti_path}    Stop Log       ttitrace   test_scenario=${Test_Step}
    Sleep   5s
    #Start Log    sherpa
    #Sleep    ${Duration}
    #${sherp_path}    Stop Log     sherpa     test_scenario=${Test_Step}

    #log to console    ${sherp_path}
    #Decode Sherpa pcap    ${Test_Step}
    #Set Global Variable     ${sherpa_output_path}     ${sherp_path}[sherpa]
    #Copy Sherpa Files    ${sherpa_output_path}
    #log to console    ${sherpa_output_path}

Decode and Valiadate Prb Allocation from TTI Logs Only UL
    [Arguments]    ${Test_Step}   ${CellId}    ${UL_Threshold1}    ${UL_Threshold2}
    Decode TTI Trace UL   ${Test_Step}
    FOR  ${Cell}  IN  @{CellId}
         Validate cell prballocation from TTI traces multicell Only UL    ${LOG_PATH}/${TEST_NAME}/gNB/ttitrace/${Test_Step}    ${Cell}
         ...       ${UL_Threshold1}    ${UL_Threshold2}
    END
    Sleep    40s

Validate cell prballocation from TTI traces multicell Only UL
    [Arguments]   ${csv_file_path}  ${CellId}    ${UL_Threshold1}    ${UL_Threshold2}
    log to console   python123 ...
    ${UL_Check}   Verify cell ulprballocation multicell_G      ${csv_file_path}/output_ul_formated.csv      ${CellId}
    ...      ${UL_Threshold1}    ${UL_Threshold2}
    log to console   Debug123 ...
    run keyword and continue on failure   Run Keyword if   ${UL_Check}!=${True}   Fail   prb allocation failure

Decode TTI Trace UL
    [Arguments]    ${ttitrace_path}=${EMPTY}
    Dated Log                        converting ttitrace pcap to csv
    ${tti_path}      Set Variable     ${LOG_PATH}/${TEST_NAME}/gNB/ttitrace/${ttitrace_path}/
    Common Convert Ttitrace From Pcap To Excelcsv        ${tti_path}
    Common Format Tti In Stream Mode         ${tti_path}/output_ul.csv     ${tti_path}/output_ul_formated.csv

Register and trigger NonGBR biDir UE Traffic in a Cell
    [Arguments]   ${Start_UE}   ${End_UE}      ${UL_Rate}   ${Traffic_rate}=mbps
    MultiUE Register should be Successful    ${Start_UE}   ${End_UE}
    MultiUE Trigger UL Traffic for SA    ${Start_UE}   ${End_UE}    Traffic_rate=${Traffic_rate}     ul_rate=${UL_Rate}      trf_id=${TRF_ID}

Validate biDir NonGBR Traffic for MultiUE in a cell only UL
    [Arguments]   ${Start_UE}   ${End_UE}      ${UL_Rate}   ${Traffic_rate}=mbps
    Log to console   ${Traffic_rate}
    Validate UL Traffic For MultiUE for SA  ${Start_UE}   ${End_UE}   ${UL_Rate}
