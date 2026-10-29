*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN  QCP_RAN_ET  SBTS00  RAN_5G  RAN_5G_TDD  CRT  CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD  team-SG2
...               owner-junhui.he  release-5G21A
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{flagDisableCB005956}    MRBTS/NRBTS:actEnhancedX2LinkSupervision=false
@{flagEnableCB005956}    MRBTS/NRBTS:actEnhancedX2LinkSupervision=true
@{defaultX2LinkReestablTmr}    MRBTS/NRBTS:x2LinkReestabTmr=15
@{defaultShutdownNoX2TrafficTmr}    MRBTS/NRBTS:shutdownNoX2TrafficTmr=24
@{modifyMaxNumX2LinksTo1}    MRBTS/NRBTS:maxNumX2Links=1
@{modifyMaxNumX2LinksTo2}    MRBTS/NRBTS:maxNumX2Links=2
@{modifyMaxNumX2LinksTo128}    MRBTS/NRBTS:maxNumX2Links=128
@{modifyX2LinkReestabTmrTo1}   MRBTS/NRBTS:x2LinkReestabTmr=1
@{x2LinkLock}    MRBTS/NRBTS/LTEENB-1:x2LinkLock=locked
@{x2LinkUnLock}    MRBTS/NRBTS/LTEENB-1:x2LinkLock=unlocked
${ENB11_X2_UP}          ENB-11: X2AP Link with [EG]NB-2 \\((\\d+\\.){3}\\d+\\:\\d+\\[\\d\\]\\) is up
${ENB1_X2_Down}          ENB-1: Gnb X2AP Link with ENB-2 \\((\\d+\\.){3}\\d+\\:\\d+\\[\\d\\]\\)  is locked
@{CB005956_A_ET_A001_recover}
...    @{modifyMaxNumX2LinksTo128}
...    @{flagDisableCB005956}
...    @{defaultX2LinkReestablTmr}
...    @{defaultShutdownNoX2TrafficTmr}
${Update_Cfg_1}    set_enb id=11 plmn=311:489 s1=10.0.1.138 enb_id_macro=0x12347 daemon=10.0.2.1:22222 x2=10.0.1.127 x2u=10.0.1.137
...    type=simulated x2_peers=1
${Update_Cfg_2}    set_cell id=11 enb=11 eci=0x1234701 pci=7:2 tac=222 proxy=10.0.2.1:8887 earfcn=2000:20000 tdd_cell=on
...    mandatory_for_activation=off
${Update_Cfg_3}    enb_param id=11 drb_id_begin=3 endc_capable_qci=all
${Update_Cfg_4}    enb_endc_param id=11 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=1:7
${UE_ID}    11
@{FAULTS_EXCLUDED_CHECKING}
...    7300    7107

*** Test Cases ***
CB005956-A-ET-A001_Verify_fault_7324_should_raise_when_last_lteObjects_create
    [Documentation]    verify fault reported or not when feature on or off and contain maxNumX2link function
     ...   CB005956-A-ET-A005 NA for same function in this case
    [Tags]    QC_60991
	Fault 7324 Should Not Be Raised When Feature is off
	Fault 7324 Should Be Raised When Feature is on
	Modify Parameter MaxNumX2Links As 2
	Fault 7324 Should Not Be Raised
	Establish Second X2 link and Check X2 Status
	Fault 7324 Should Be Raised
	Fault 7324 Should Not Be Raised When Feature is on to off
	[Teardown]    Recover The ENV And Stop Capture Logs    ${CB005956_A_ET_A001_recover}

CB005956-A-ET-A004_Verify_unlocked_LTE_will_be_deleted_and_fault_7324_should_be_cancelled_as_exepected
    [Documentation]    verify fault raised or not when lock and unlock lteenb
    [Tags]    QC_60988	CB005956-A-ET-A004
	Enable Feature CB005956
	Modify Parameter MaxNumX2Links As 2
	Set x2LinkReestabTmr As 1 min
	Establish Second X2 link and Check X2 Status
	Fault 7324 Should Be Raised
	Lock Second X2 Link
	UnLock Second X2 Link
	Wait X2 Link Unlock And Alarm Clear
	Fault 7324 Should Not Be Raised
	Set x2LinkReestabTmr As Default
	[Teardown]    Recover The ENV And Stop Capture Logs    ${CB005956_A_ET_A001_recover}

CB005956-A-ET-A002_Verify_X2_failure_without_reestablished
    [Documentation]    fault should cancelled when UE Bulk Release
    [Tags]    QC_60989    CB005956-A-ET-A002
    Enable Feature CB005956 And Modify MaxNumX2Links And x2LinkReestabTmr
    Check Fault 7324 And Nsa Attach
	Enb Timer for stop X2 retry mechanism
	Start To Capture Wireshark Log    pcap_file_A001
	Shutdown X2 link
	X2 Status is UnAvaliable
	Wait X2 Ue Bulk Release
	Check Wireshark Log    ${CURDIR}${/}a2a_A002${/}a2a.ini    name=pcap_file_A001    wait_string=id-reset::1
	Wait Until Keyword Succeeds    2min    3s    Fault 7324 Should Not Be Raised
	UE Detach
	[Teardown]    Recover The ENV And Stop Capture Logs    ${CB005956_A_ET_A001_recover}
	
*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env  tl_type=tdd_sansa_cmwv/FS/2cells_ecpri    ue_count=1
    #Debug Enter Into Egate

Modify Cfg
    Update Cfg    ${Update_Cfg_1}
    Update Cfg    ${Update_Cfg_2}
    Update Cfg    ${Update_Cfg_3}
    Update Cfg    ${Update_Cfg_4}

Fault 7324 Should Not Be Raised When Feature is off
	Disable Feature CB005956
	Modify Parameter MaxNumX2Links As 1
	Fault 7324 Should Not Be Raised
	
Disable Feature CB005956
	Run Keyword And Ignore Error    Delta Commission Parameters    ${flagDisableCB005956}

Enable Feature CB005956
	Delta Commission Parameters    ${flagEnableCB005956}
	
Modify Parameter MaxNumX2Links As 1
	Run Keyword And Ignore Error    Delta Commission Parameters    ${modifyMaxNumX2LinksTo1}
	Object Should Exist    NRBTS-1:maxNumX2Links=1

Modify Parameter MaxNumX2Links As 2
	Delta Commission Parameters    ${modifyMaxNumX2LinksTo2}
	
Fault 7324 Should Not Be Raised
    ${fault}  Create List    fault_id=7324    severity=Minor    fault_name=Maximum of X2 links reached
	Fm Fault Should Be Cleared    ${fault}    30

Fault 7324 Should Be Raised
    ${fault}  Create List    fault_id=7324    severity=Minor    fault_name=Maximum of X2 links reached
	Fm Fault Should Be Raised    ${fault}    30
	
Fault 7324 Should Be Raised When Feature is on
	Enable Feature CB005956
	Fault 7324 Should Be Raised

Establish Second X2 link and Check X2 Status
	Establish Second X2 link
	Enb Timer for stop X2 retry mechanism
	X2 Status is Avaliable
	Second X2 Status is Avaliable
	
Establish Second X2 link
	Execute Egate Command    enb_x2_link_up enb=11 target=2    pass_regexp=${ENB11_X2_UP}    timeout=300    sleep_time=15

Enb Timer for stop X2 retry mechanism
	Execute Egate Command    enb_timer T_X2_SETUP_REPEATE=30m    timeout=300    sleep_time=15
	
X2 Status is Avaliable
	Object Should Exist    LTEENB-0:x2LinkStatus=available

Second X2 Status is Avaliable
	Object Should Exist    LTEENB-1:x2LinkStatus=available

Fault 7324 Should Not Be Raised When Feature is on to off
	Disable Feature CB005956
	Object Should Exist    NRBTS-1:actEnhancedX2LinkSupervision=false
	Fault 7324 Should Not Be Raised
	
Recover The ENV And Stop Capture Logs
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Common Test Teardown And Stop Capture Logs	

Set x2LinkReestabTmr As 1 min
	Delta Commission Parameters    ${modifyX2LinkReestabTmrTo1}

Lock Second X2 Link
	Delta Commission Parameters    ${x2LinkLock}

UnLock Second X2 Link
	Delta Commission Parameters    ${x2LinkUnLock}

Set x2LinkReestabTmr As Default
	Delta Commission Parameters    ${defaultX2LinkReestablTmr}
	
Nsa Attach Ue ${UE_ID}
	Execute Egate Command    ue_attach id=${UE_ID}    pass_regexp=UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${UE_ID} target_gnb=2 target_cells=1 bearer=2 type=split_scg
    ...    pass_regexp=reported successful RA

Shutdown X2 link
	Execute Egate Command    link_lock link=x2 at=enb:1 to=gnb:2    pass_regexp=${ENB1_X2_Down}    timeout=300    sleep_time=15

X2 Status is UnAvaliable
	Object Should Exist    LTEENB-0:x2LinkStatus=unavailable

UE Detach
    Execute Egate Command  ue_detach id=${UE_ID}    UE IS OFF

Wait X2 Link Unlock And Alarm Clear
    Sleep    70s    # wait x2 link unlock and alarm clear

Wait X2 Ue Bulk Release
    Sleep    120s    # wait x2 UE BULK release

Enable Feature CB005956 And Modify MaxNumX2Links And x2LinkReestabTmr
    Enable Feature CB005956
    Modify Parameter MaxNumX2Links As 1
    Set x2LinkReestabTmr As 1 min

Check Fault 7324 And Nsa Attach
    Fault 7324 Should Be Raised
	Nsa Attach Ue ${UE_ID}
