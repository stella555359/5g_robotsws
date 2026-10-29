*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LOOO    OPTION_RELATED_ARTIFACTS_5G   VARIANT_SANSA_FS_CPRI_CMWV_FDD
...             SBTS00   CONFIGURED   5G_RAN   RAN_5G   RAN_5G_FDD   5G_RAN_FDD   CRT

Documentation    :copyright: Nokia
...              :authors: Sunil T Kurian
...              :contact: sunil.t_kurian@nokia.com


Resource         ./resources/CB009215_keyword.robot
Library         ./resources/check_csirs_grp_id.py

Suite Setup         Run keywords   Run Keyword and Ignore Error    Suite setup from scratch
...                 AND            Prepare TL with all config files
...                 AND     Update GNB R&D Parameter   ${LOG_PATH}   ${r&d_parameter}
...                 AND     Add routes 3AMF
...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}

Test Teardown    Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Run Keyword and Ignore Error    Get Snapshot
...                 AND     Run Keyword and Ignore Error    Get Sos Report
...                 AND     Link SCOUT SCF to Configuration ID for Reporting

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/basic_setup_B4_6cell.lua
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${epc_log_path}    /tmp/
${SCFC}=        ${CURDIR}/config/SCF/CB009215_B4_6cell_A4_20Mhz_40Mhz_SCF.xml
${AP_XML}=      ${CURDIR}/config/SCF/CB009215_B4_6cell_A4_20Mhz_40Mhz_iphy.xml
${r&d_parameter}     0x58012d=3;0x580758=1;0x580690=0;0x58057a=4;0x58057c=0x7800;0x58057e=0x100;0x580117=1
@{PCI_list_20Mhz}  53  54    55
@{PCI_list_40Mhz}  50  51    52
*** Test Cases ***
[1]CB009215-B_Verification_of_a_new_CSI-RS_pooling_group_concept_by_adding_3_cells_of_A4_40MHz_type
    [Documentation]   This test scenario describes how the new CSI-RS pooling group concept is verified with inter-L1 subpool pooling algorithm.
    ...        In this test case we are bringing up 3 20Mhz cell and then adding 3 4Mhz cells and cehcking CSI-RS pooling is done properly.
    ...    TEST SET NAME   : CB009215_B_Verification_of_a_new_CSI_RS_pooling_group_concept_by_adding_3_cells_of_A4_40MHz_type
    ...    TESTING SPLIT   : CB009215-B
    ...  REFERENCES      :  CFAM
    X2AP Link Should be UP
    Start Log   btslog
    Delete 3 40 Mhz Cell via Delta
    Start Equal 1 GBR 1 Non GBR 1 NSA call in 3 20Mhz cells  DL_Rate_GBR=10   UL_Rate_GBR=10   DL_Rate_nonGBR=100   UL_Rate_nonGBR=60
    ...   NSAdl_Rate=15   NSAul_Rate=15
    Validate Equal 1 GBR 1 Non GBR 1 NSA call in 3 20Mhz cells    DL_Rate_GBR=10   UL_Rate_GBR=10   DL_Rate_nonGBR=100   UL_Rate_nonGBR=60
    ...   NSAdl_Rate=15   NSAul_Rate=15
    Collect TTI Log   Test_Step=Step4_3Cell_20Mhz    Duration=500ms
    Stop Log    btslog    test_scenario=Step4_3Cell_20Mhz
    Start Log   btslog
    #Add 3 40 Mhz Cell via Delta
    Add 3 40 Mhz Cell via full commisioning
    Start Equal 1 GBR 1 Non GBR 1 NSA call in 3 20Mhz cells  DL_Rate_GBR=10   UL_Rate_GBR=10   DL_Rate_nonGBR=100   UL_Rate_nonGBR=60
    ...   NSAdl_Rate=15   NSAul_Rate=15
    Start Equal 1 GBR 1 Non GBR 1 NSA call in 3 40Mhz cells  DL_Rate_GBR=10   UL_Rate_GBR=10   DL_Rate_nonGBR=150   UL_Rate_nonGBR=60
    ...   NSAdl_Rate=15   NSAul_Rate=15
    Collect TTI Log   Test_Step=Step7_3_40MhzCellAddition    Duration=500ms
    Stop Log    btslog    test_scenario=Step7_3_40MhzCellAddition
    Run Keyword And Continue On Failure    Decode and Valiadate Prb Allocation from TTI Logs  Test_Step=Step4_3Cell_20Mhz
    ...   CellId=${PCI_list_20Mhz}   DL_Threshold1=105    DL_Threshold2=107   UL_Threshold1=105    UL_Threshold2=107
    Run Keyword And Continue On Failure    Validate new_CSI-RS_pooling_group    Test_Step=Step4_3Cell_20Mhz    NumExp_cells=${1}
    Run Keyword And Continue On Failure    Decode and Valiadate Prb Allocation from TTI Logs  Test_Step=Step7_3_40MhzCellAddition
    ...   CellId=${PCI_list_20Mhz}   DL_Threshold1=90    DL_Threshold2=106   UL_Threshold1=60    UL_Threshold2=106
    Run Keyword And Continue On Failure    Valiadate Prb Allocation from TTI Logs    Test_Step=Step7_3_40MhzCellAddition
    ...   CellId=${PCI_list_40Mhz}   DL_Threshold1=100    DL_Threshold2=140   UL_Threshold1=55    UL_Threshold2=180
    Validate new_CSI-RS_pooling_group    Test_Step=Step7_3_40MhzCellAddition    NumExp_cells=${2}
*** Keywords ***
Add 3 40 Mhz Cell via Delta
     log to console    Adding 3 40Mhz Cells....
     Find Scfc And Send Delta Commissioning      scfc_filename=CB009215_B4_40MhzCell_Add.json
     sleep   300s
     Check MIB_SIB status of Active cell   Cell_Id=1
     Check MIB_SIB status of Active cell   Cell_Id=2
     Check MIB_SIB status of Active cell   Cell_Id=3
     Check MIB_SIB status of Active cell   Cell_Id=4
     Check MIB_SIB status of Active cell   Cell_Id=5
     Check MIB_SIB status of Active cell   Cell_Id=6
Delete 3 40 Mhz Cell via Delta
     log to console    Locking 3 40Mhz Cells....
     Oam.OAM Cell Lock  cell_id=1
     Oam.OAM Cell Lock  cell_id=2
     Oam.OAM Cell Lock  cell_id=3
     sleep    30s
     log to console    Deleting 3 40Mhz Cells....
     Find Scfc And Send Delta Commissioning      scfc_filename=CB009215_B4_40MhzCell_Delete.json
     sleep   90s
     Check MIB_SIB status of deleted cell   Cell_Id=1
     Check MIB_SIB status of deleted cell   Cell_Id=2
     Check MIB_SIB status of deleted cell   Cell_Id=3
     Check MIB_SIB status of Active cell    Cell_Id=4
     Check MIB_SIB status of Active cell    Cell_Id=5
     Check MIB_SIB status of Active cell    Cell_Id=6
Start Equal 1 GBR 1 Non GBR 1 NSA call in 3 20Mhz cells
    [Arguments]   ${DL_Rate_GBR}   ${UL_Rate_GBR}  ${DL_Rate_nonGBR}   ${UL_Rate_nonGBR}   ${NSAdl_Rate}   ${NSAul_Rate}
    Register and trigger Multiple GBR biDir UE Traffic in a Cell   Start_UE=31   End_UE=31   DL_Rate=${DL_Rate_GBR}  UL_Rate=${UL_Rate_GBR}
    Register and trigger Multiple GBR biDir UE Traffic in a Cell   Start_UE=41   End_UE=41   DL_Rate=${DL_Rate_GBR}  UL_Rate=${UL_Rate_GBR}
    Register and trigger Multiple GBR biDir UE Traffic in a Cell   Start_UE=51   End_UE=51   DL_Rate=${DL_Rate_GBR}  UL_Rate=${UL_Rate_GBR}
    Register and trigger Multiple NonGBR biDir UE Traffic in a Cell  Start_UE=35   End_UE=35   DL_Rate=${DL_Rate_nonGBR}  UL_Rate=${UL_Rate_nonGBR}
    Register and trigger Multiple NonGBR biDir UE Traffic in a Cell  Start_UE=45   End_UE=45   DL_Rate=${DL_Rate_nonGBR}  UL_Rate=${UL_Rate_nonGBR}
    Register and trigger Multiple NonGBR biDir UE Traffic in a Cell  Start_UE=55   End_UE=55   DL_Rate=${DL_Rate_nonGBR}  UL_Rate=${UL_Rate_nonGBR}
    LTE Attach should be Successful    NSA_UE_ID=64
    LTE Attach should be Successful    NSA_UE_ID=65
    LTE Attach should be Successful    NSA_UE_ID=66
    UE Attach should be Successful   NSA_UE_ID=64    Trgt_Cell=4
    UE Attach should be Successful   NSA_UE_ID=65    Trgt_Cell=5
    UE Attach should be Successful   NSA_UE_ID=66    Trgt_Cell=6
	Trigger DL Traffic for NSA    ue_id=64   Traffic_rate=mbps     dl_rate=${NSAdl_Rate}     id=2    trf_id=1
	Trigger UL Traffic for NSA    ue_id=64   Traffic_rate=mbps     ul_rate=${NSAul_Rate}     id=2    trf_id=1
	Trigger DL Traffic for NSA    ue_id=65   Traffic_rate=mbps     dl_rate=${NSAdl_Rate}     id=2    trf_id=1
	Trigger UL Traffic for NSA    ue_id=65   Traffic_rate=mbps     ul_rate=${NSAul_Rate}     id=2    trf_id=1
	Trigger DL Traffic for NSA    ue_id=66   Traffic_rate=mbps     dl_rate=${NSAdl_Rate}     id=2    trf_id=1
	Trigger UL Traffic for NSA    ue_id=66   Traffic_rate=mbps     ul_rate=${NSAul_Rate}     id=2    trf_id=1

Validate Equal 1 GBR 1 Non GBR 1 NSA call in 3 20Mhz cells
    [Arguments]   ${DL_Rate_GBR}   ${UL_Rate_GBR}  ${DL_Rate_nonGBR}   ${UL_Rate_nonGBR}   ${NSAdl_Rate}   ${NSAul_Rate}
    Validate bidir SCH data for MultiUE in a cell   Start_UE=31   End_UE=31   DL_Rate=${DL_Rate_GBR}  UL_Rate=${UL_Rate_GBR}
    Validate bidir SCH data for MultiUE in a cell   Start_UE=41   End_UE=41   DL_Rate=${DL_Rate_GBR}  UL_Rate=${UL_Rate_GBR}
    Validate bidir SCH data for MultiUE in a cell   Start_UE=51   End_UE=51   DL_Rate=${DL_Rate_GBR}  UL_Rate=${UL_Rate_GBR}
    Validate bidir SCH data for MultiUE in a cell   Start_UE=35   End_UE=35   DL_Rate=${DL_Rate_nonGBR}   UL_Rate=${UL_Rate_nonGBR}
    Validate bidir SCH data for MultiUE in a cell   Start_UE=45   End_UE=45   DL_Rate=${DL_Rate_nonGBR}   UL_Rate=${UL_Rate_nonGBR}
    Validate bidir SCH data for MultiUE in a cell   Start_UE=55   End_UE=55   DL_Rate=${DL_Rate_nonGBR}   UL_Rate=${UL_Rate_nonGBR}
    Validate DL Traffic For NSA    ue_id=64   dl_rate=${NSAdl_Rate}   id=2
	Validate UL Traffic For NSA    ue_id=64   ul_rate=${NSAul_Rate}   id=2
	Validate DL Traffic For NSA    ue_id=65   dl_rate=${NSAdl_Rate}   id=2
	Validate UL Traffic For NSA    ue_id=65   ul_rate=${NSAul_Rate}   id=2
	Validate DL Traffic For NSA    ue_id=66   dl_rate=${NSAdl_Rate}   id=2
	Validate UL Traffic For NSA    ue_id=66   ul_rate=${NSAul_Rate}   id=2

Start Equal 1 GBR 1 Non GBR 1 NSA call in 3 40Mhz cells
    [Arguments]   ${DL_Rate_GBR}   ${UL_Rate_GBR}  ${DL_Rate_nonGBR}   ${UL_Rate_nonGBR}   ${NSAdl_Rate}   ${NSAul_Rate}
    Register and trigger Multiple GBR biDir UE Traffic in a Cell   Start_UE=1   End_UE=1   DL_Rate=${DL_Rate_GBR}  UL_Rate=${UL_Rate_GBR}
    Register and trigger Multiple GBR biDir UE Traffic in a Cell   Start_UE=11   End_UE=11   DL_Rate=${DL_Rate_GBR}  UL_Rate=${UL_Rate_GBR}
    Register and trigger Multiple GBR biDir UE Traffic in a Cell   Start_UE=21   End_UE=21   DL_Rate=${DL_Rate_GBR}  UL_Rate=${UL_Rate_GBR}
    Register and trigger Multiple NonGBR biDir UE Traffic in a Cell  Start_UE=5   End_UE=5   DL_Rate=${DL_Rate_nonGBR}  UL_Rate=${UL_Rate_nonGBR}
    Register and trigger Multiple NonGBR biDir UE Traffic in a Cell  Start_UE=15   End_UE=15   DL_Rate=${DL_Rate_nonGBR}  UL_Rate=${UL_Rate_nonGBR}
    Register and trigger Multiple NonGBR biDir UE Traffic in a Cell  Start_UE=25   End_UE=25   DL_Rate=${DL_Rate_nonGBR}  UL_Rate=${UL_Rate_nonGBR}
    LTE Attach should be Successful    NSA_UE_ID=61
    LTE Attach should be Successful    NSA_UE_ID=62
    LTE Attach should be Successful    NSA_UE_ID=63
    UE Attach should be Successful   NSA_UE_ID=61    Trgt_Cell=1
    UE Attach should be Successful   NSA_UE_ID=62    Trgt_Cell=2
    UE Attach should be Successful   NSA_UE_ID=63    Trgt_Cell=3
	Trigger DL Traffic for NSA    ue_id=61   Traffic_rate=mbps     dl_rate=${NSAdl_Rate}     id=2    trf_id=1
	Trigger UL Traffic for NSA    ue_id=61   Traffic_rate=mbps     ul_rate=${NSAul_Rate}     id=2    trf_id=1
	Trigger DL Traffic for NSA    ue_id=62   Traffic_rate=mbps     dl_rate=${NSAdl_Rate}     id=2    trf_id=1
	Trigger UL Traffic for NSA    ue_id=62   Traffic_rate=mbps     ul_rate=${NSAul_Rate}     id=2    trf_id=1
	Trigger DL Traffic for NSA    ue_id=63   Traffic_rate=mbps     dl_rate=${NSAdl_Rate}     id=2    trf_id=1
	Trigger UL Traffic for NSA    ue_id=63   Traffic_rate=mbps     ul_rate=${NSAul_Rate}     id=2    trf_id=1

Validate Equal 1 GBR 1 Non GBR 1 NSA call in 3 40Mhz cells
    [Arguments]   ${DL_Rate_GBR}   ${UL_Rate_GBR}  ${DL_Rate_nonGBR}   ${UL_Rate_nonGBR}   ${NSAdl_Rate}   ${NSAul_Rate}
    Validate bidir SCH data for MultiUE in a cell   Start_UE=1   End_UE=1   DL_Rate=${DL_Rate_GBR}  UL_Rate=${UL_Rate_GBR}
    Validate bidir SCH data for MultiUE in a cell   Start_UE=11   End_UE=11   DL_Rate=${DL_Rate_GBR}  UL_Rate=${UL_Rate_GBR}
    Validate bidir SCH data for MultiUE in a cell   Start_UE=21   End_UE=21   DL_Rate=${DL_Rate_GBR}  UL_Rate=${UL_Rate_GBR}
    Validate bidir SCH data for MultiUE in a cell   Start_UE=5   End_UE=5   DL_Rate=${DL_Rate_nonGBR}   UL_Rate=${UL_Rate_nonGBR}
    Validate bidir SCH data for MultiUE in a cell   Start_UE=15   End_UE=15   DL_Rate=${DL_Rate_nonGBR}   UL_Rate=${UL_Rate_nonGBR}
    Validate bidir SCH data for MultiUE in a cell   Start_UE=25   End_UE=25   DL_Rate=${DL_Rate_nonGBR}   UL_Rate=${UL_Rate_nonGBR}
    Validate DL Traffic For NSA    ue_id=61   dl_rate=${NSAdl_Rate}   id=2
	Validate UL Traffic For NSA    ue_id=61   ul_rate=${NSAul_Rate}   id=2
	Validate DL Traffic For NSA    ue_id=62   dl_rate=${NSAdl_Rate}   id=2
	Validate UL Traffic For NSA    ue_id=62   ul_rate=${NSAul_Rate}   id=2
	Validate DL Traffic For NSA    ue_id=63   dl_rate=${NSAdl_Rate}   id=2
	Validate UL Traffic For NSA    ue_id=63   ul_rate=${NSAul_Rate}   id=2
Valiadate Prb Allocation from TTI Logs
    [Arguments]    ${Test_Step}   ${CellId}   ${DL_Threshold1}    ${DL_Threshold2}   ${UL_Threshold1}    ${UL_Threshold2}
      FOR  ${Cell}  IN  @{CellId}
         Validate cell prballocation from TTI traces multicell    ${LOG_PATH}/${TEST_NAME}/gNB/ttitrace/${Test_Step}    ${Cell}
         ...    ${DL_Threshold1}    ${DL_Threshold2}   ${UL_Threshold1}    ${UL_Threshold2}
    END
Add 3 40 Mhz Cell via full commisioning
    Kill WTS processes Using WTS_Runner
    Prepare TL with SCF change
    Start WTS Using WTS_Runner      ${wts_cfg_file}
    X2AP Link Should be UP
    sleep     30s
Validate new_CSI-RS_pooling_group
    [Arguments]    ${Test_Step}    ${NumExp_cells}
    ${Result}   check_csirs_grp_id.check_cells_in_csiRsPoolingGroup    ${LOG_PATH}/${TEST_NAME}/gNB/ttitrace/${Test_Step}/output_dl_formated.csv
    ...    ${NumExp_cells}
    Should Be True    ${Result} ==${True}
