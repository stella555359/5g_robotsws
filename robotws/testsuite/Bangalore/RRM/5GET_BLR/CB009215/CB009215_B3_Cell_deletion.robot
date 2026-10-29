*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LOOO    OPTION_RELATED_ARTIFACTS_5G   VARIANT_SANSA_FS_CPRI_CMWV_FDD
...             SBTS00   CONFIGURED    RAN_5G_FDD  CRT    TOOLS_PROFILE_TTI_LEGACY

Documentation    :copyright: Nokia
...              :authors: Sunil T Kurian
...              :contact: sunil.t_kurian@nokia.com

Resource         ./resources/CB009215_keyword.robot

Suite Setup         Run keywords    Prepare TL with all config files
...                 AND     Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Update GNB R&D Parameter   ${LOG_PATH}   ${r&d_parameter}
...                 AND     Download and Modify Vendor File and Perform Commissioning   ${LOG_PATH}
...          ${maxNumLayerPrbL1Sp_DL}   ${maxNumStreamPrbL1Sp_DL}   ${maxNumLayerPrbL1Sp_UL}   ${maxNumStreamPrbL1Sp_UL}   ${maxNumWbStreamPrbL1Sp}
...                 AND     sleep    300s
...                 AND     Add routes 3AMF
...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}

Test Teardown    Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Run Keyword and Ignore Error    Get Snapshot
...                 AND     Run Keyword and Ignore Error    Get Sos Report
...                 AND     Link SCOUT SCF to Configuration ID for Reporting

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/basic_setup_B1_B3_4_cell_2AMF.lua
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${epc_log_path}    /tmp/
${maxNumLayerPrbL1Sp_DL}   636
${maxNumStreamPrbL1Sp_DL}   636
${maxNumLayerPrbL1Sp_UL}   318
${maxNumStreamPrbL1Sp_UL}   636
${maxNumWbStreamPrbL1Sp}     424
@{PCI_listSP0}  50  52
@{PCI_listSP1}  51  53
@{PCI_list3}  51  52  53
@{PCI_list4}  50  51  52  53
${SCFC}=        ${CURDIR}/config/SCF/CB009215_B1_B3_4Cell_A4_20Mhz_SCF.xml
${AP_XML}=      ${CURDIR}/config/SCF/CB009215_B1_B3_4Cell_A4_20Mhz_iphy.xml
${r&d_parameter}     0x58012d=3;0x580758=1;0x580690=0;0x58057a=4;0x58057c=0x7800;0x58057e=0x100;0x580117=1

*** Test Cases ***
[1]CB009215-B_Cell_deletion_in_SP1_with_inter-L1_subpool_PRB_pooling_with_load-based_algorithm
    [Documentation]   This testcase verify that Cell_deletion_in_SP1_with_inter-L1_subpool_PRB_pooling_with_load-based_algorithm
	...   This test scenario describes cell deletion when inter-L1 subpool PRB pooling is activated.
	...   Deleting cell(s) shall decrease the total minimum PRB allocation.
	...   Freed resources shall be shared between L1 subpools.
	...   It may impact running GBR and non-GBR traffic on other existing cells by inter-L1 subpool pooling algorithm.

    Start Log   btslog
    Start Equal 3 GBR and 3 Non GBR call in all 4 Cells  DL_Rate_GBR=9   UL_Rate_GBR=9   DL_Rate_nonGBR=70   UL_Rate_nonGBR=45
    Run Keyword And Continue On Failure    Validate Equal 3 GBR and 3 Non GBR call in all 4 Cells
    ...  DL_Rate_GBR=8   UL_Rate_GBR=8   DL_Rate_nonGBR=60   UL_Rate_nonGBR=35
    Collect TTI Log   Test_Step=Step2_4Cell_Equal_FullLoad   Duration=500ms
    Stop Log    btslog    test_scenario=Step2_4Cell_Equal_FullLoad
    Verify PM Counter Total PRBs Used is less than AVAL for all 4 Cells
    ...  PM_counter1=M55308C10001  PM_counter2=M55308C10005   CapacityThreshold=111400000
    Start Log   btslog
    Release 2GBR and 2 NonGBR UEs from all SP0 Cells
    Collect TTI Log   Test_Step=Step3_ReduceLoad_SP0   Duration=500ms
    Stop Log    btslog    test_scenario=Step3_ReduceLoad_SP0
    Start Log   btslog
    Delete Cell 1 via Delta for 4 cell config   Scfc_Filename=Cell1Delete_FDD.json
    Collect TTI Log   Test_Step=Step7_1_SP0_CellDelete   Duration=500ms
    Run Keyword And Continue On Failure    Validate GBR and non GBR call after CellDelete
    ...  DL_Rate_GBR=8   UL_Rate_GBR=8   DL_Rate_nonGBR=60   UL_Rate_nonGBR=35
    Verify PM Counter for PRBs AVAL for PDSCH after 1st Cell Deletion
    ...  PM_counter=M55308C10005   Expected_Value=27424000
	Stop Log    btslog    test_scenario=Step7_1_SP0_CellDelete
    Decode and Valiadate Prb Allocation from TTI Logs  Test_Step=Step2_4Cell_Equal_FullLoad
    ...   CellId=${PCI_list4}   DL_Threshold1=65    DL_Threshold2=90   UL_Threshold1=75    UL_Threshold2=85
    Decode and Valiadate Prb Allocation from TTI Logs  Test_Step=Step3_ReduceLoad_SP0
    ...   CellId=${PCI_listSP1}   DL_Threshold1=80    DL_Threshold2=106  UL_Threshold1=90    UL_Threshold2=106
    Decode and Valiadate Prb Allocation from TTI Logs  Test_Step=Step7_1_SP0_CellDelete
    ...   CellId=${PCI_list3}   DL_Threshold1=106    DL_Threshold2=106  UL_Threshold1=106    UL_Threshold2=106



*** Keywords ***

Delete Cell 1 via Delta for 4 cell config
     [Arguments]   ${Scfc_Filename}
     log to console    Deleting 1st Cell....
     Find Scfc And Send Delta Commissioning      scfc_filename=${Scfc_Filename}
     sleep   90s
     Check MIB_SIB status of deleted cell   Cell_Id=1
     Check MIB_SIB status of Active cell    Cell_Id=2
     Check MIB_SIB status of Active cell    Cell_Id=3
     Check MIB_SIB status of Active cell    Cell_Id=4

Start Equal 3 GBR and 3 Non GBR call in all 4 Cells
    [Arguments]   ${DL_Rate_GBR}   ${UL_Rate_GBR}  ${DL_Rate_nonGBR}   ${UL_Rate_nonGBR}
    Register and trigger GBR biDir Traffic 1UE per Cell  Start_UE=1   NumCells=4   DL_Rate=${DL_Rate_GBR}  UL_Rate=${UL_Rate_GBR}
    Register and trigger GBR biDir Traffic 1UE per Cell  Start_UE=2   NumCells=4   DL_Rate=${DL_Rate_GBR}  UL_Rate=${UL_Rate_GBR}
    Register and trigger GBR biDir Traffic 1UE per Cell  Start_UE=3   NumCells=4   DL_Rate=${DL_Rate_GBR}  UL_Rate=${UL_Rate_GBR}
    Register and trigger NonGBR biDir Traffic 1UE per Cell  Start_UE=6   NumCells=4   DL_Rate=${DL_Rate_nonGBR}  UL_Rate=${UL_Rate_nonGBR}
    Register and trigger NonGBR biDir Traffic 1UE per Cell  Start_UE=7   NumCells=4   DL_Rate=${DL_Rate_nonGBR}  UL_Rate=${UL_Rate_nonGBR}
    Register and trigger NonGBR biDir Traffic 1UE per Cell  Start_UE=8   NumCells=4   DL_Rate=${DL_Rate_nonGBR}  UL_Rate=${UL_Rate_nonGBR}

Validate Equal 3 GBR and 3 Non GBR call in all 4 Cells
    [Arguments]   ${DL_Rate_GBR}   ${UL_Rate_GBR}  ${DL_Rate_nonGBR}   ${UL_Rate_nonGBR}
    Validate bidir SCH data 1UE per cell   Start_UE=1   NumCells=4   DL_Rate=${DL_Rate_GBR}  UL_Rate=${UL_Rate_GBR}
    Validate bidir SCH data 1UE per cell   Start_UE=2   NumCells=4   DL_Rate=${DL_Rate_GBR}  UL_Rate=${UL_Rate_GBR}
    Validate bidir SCH data 1UE per cell   Start_UE=3   NumCells=4   DL_Rate=${DL_Rate_GBR}  UL_Rate=${UL_Rate_GBR}
    Validate bidir SCH data 1UE per cell   Start_UE=6   NumCells=4   DL_Rate=${DL_Rate_nonGBR}   UL_Rate=${UL_Rate_nonGBR}
    Validate bidir SCH data 1UE per cell   Start_UE=7   NumCells=4   DL_Rate=${DL_Rate_nonGBR}   UL_Rate=${UL_Rate_nonGBR}
    Validate bidir SCH data 1UE per cell   Start_UE=8   NumCells=4   DL_Rate=${DL_Rate_nonGBR}   UL_Rate=${UL_Rate_nonGBR}

Validate GBR and non GBR call after CellDelete
    [Arguments]   ${DL_Rate_GBR}   ${UL_Rate_GBR}  ${DL_Rate_nonGBR}   ${UL_Rate_nonGBR}
    Validate bidir SCH data for MultiUE in a cell   Start_UE=11   End_UE=13   DL_Rate=${DL_Rate_GBR}  UL_Rate=${UL_Rate_GBR}
    Validate bidir SCH data for MultiUE in a cell   Start_UE=21   End_UE=21   DL_Rate=${DL_Rate_GBR}  UL_Rate=${UL_Rate_GBR}
    Validate bidir SCH data for MultiUE in a cell   Start_UE=31   End_UE=33   DL_Rate=${DL_Rate_GBR}  UL_Rate=${UL_Rate_GBR}
    Validate bidir SCH data for MultiUE in a cell   Start_UE=16   End_UE=18   DL_Rate=${DL_Rate_nonGBR}   UL_Rate=${UL_Rate_nonGBR}
    Validate bidir SCH data for MultiUE in a cell   Start_UE=26   End_UE=26   DL_Rate=${DL_Rate_nonGBR}   UL_Rate=${UL_Rate_nonGBR}
    Validate bidir SCH data for MultiUE in a cell   Start_UE=36   End_UE=38   DL_Rate=${DL_Rate_nonGBR}   UL_Rate=${UL_Rate_nonGBR}

Release 2GBR and 2 NonGBR UEs from all SP0 Cells
    MultiUE Deregister should be Successful   2   3
    MultiUE Deregister should be Successful   6   7
    MultiUE Deregister should be Successful   22   23
    MultiUE Deregister should be Successful   27   28
