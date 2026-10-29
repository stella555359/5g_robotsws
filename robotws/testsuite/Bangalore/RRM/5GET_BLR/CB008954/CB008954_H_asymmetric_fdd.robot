*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CIT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00     SBTS22R3    SBTS23R2    SBTS23R1    CONFIGURED

Documentation    :copyright: Nokia
...              :authors:Prasanta
...             CB008954 feature testing scenarios
...             INTRODUCTION:     This user scenario describes the gNB behavior with regards to cell setup and SA UE
...             addition when UE supporting gNB's different BWPs eg large, Medium, Small dedicated BWP are configured.
...             TEST SET NAME:    CB008954_C_B_1_1_Initial_Context_Setup_UE_configured_with_small_BWP_profile_TDD
...             TESTING SPLIT:    Refer CB008954 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008954 CFAM
...             RequirementID: 5G_RAN_USR_RRM_21488


Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          Collections
Library           ta5g_enb


Resource         ./CB008954_resource.robot

Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Prepare TL with all config files
#...                 AND     Modify IPHY File And Send to Airphone Custom     ${IPHY_FILE}
#...                 AND     Find Scfc And Fix And Send Full Commissioning
#...                         scfc_filename=asymmertric_fdd.xml
...                 AND     sleep    180s
...                 AND     gnb.Perform gNB reboot
...                 AND     sleep    10s
...                 AND     Load CFG Config updated     ${wts_cfg_file}
...                 AND     sleep    18s
...                 AND     Check gNB Bulid


Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

Test Setup       Start_capture_testcase_default_logging
Test Teardown    Run Keywords       Log To console   Teardown_started
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}
...                 AND     Run Keyword and Ignore Error    Stop Log     snapshot    sosreport

*** Variables ***
${SCFC}=        ${CURDIR}/config/SBTS24R2/asymmertric_fdd.xml
${AP_XML}=      ${CURDIR}/config/wts/asymmetric_iphy.xml

${wts_cfg_file}      ${CURDIR}/config/wts/basic_setup_Asymmetric.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${largebwp_id}   1
${smallbwp_id}   2
${psbwp_id}     3
${epc_log_path}    /tmp/
${TEST_NAME}            Cell_setup
#${IPHY_FILE}     ${CURDIR}/config/wts/asymmetric_iphy.xml
*** Test Cases ***
[1]CB008954_H_asymmetric_fdd
    [Documentation]   This scenario is to verify the cell setup with 3 dedicated BWPS 15,20,30 MHZ


    Log To console  TestCasestartedl
    Increase Buffer Size for VM and IPHY
    Wait until the next Measurement Period starts

    ${small_bwp_rnti}    MultiUE Register should be Successful     ${51}    ${52}
    MultiUE Trigger UL Traffic for SA    ${51}    ${52}  Traffic_rate=mbps     ul_rate=2   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${51}    ${52}  Traffic_rate=mbps     dl_rate=20   pdu_id=1   trf_id=1   qfi_id=1
    sleep    60s
    Validate UL Traffic For MultiUE for SA    51  52     2
    Validate DL Traffic For MultiUE for SA    51  52     20


    ${second_bwp_rnti}    MultiUE Register should be Successful     ${53}    ${54}
    MultiUE Trigger UL Traffic for SA    ${53}  ${54}  Traffic_rate=mbps     ul_rate=2   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${53}  ${54}  Traffic_rate=mbps     dl_rate=20   pdu_id=1   trf_id=1   qfi_id=1
    sleep    60s
    Validate UL Traffic For MultiUE for SA    53  54     2
    Validate DL Traffic For MultiUE for SA    53  54     20

    ${large_bwp_rnti}    MultiUE Register should be Successful     ${55}    ${56}
    MultiUE Trigger UL Traffic for SA    ${55}    ${56}  Traffic_rate=mbps     ul_rate=2   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${55}    ${56}  Traffic_rate=mbps     dl_rate=20   pdu_id=1   trf_id=1   qfi_id=1
    sleep    60s
    Validate UL Traffic For MultiUE for SA    55  56     2
    Validate DL Traffic For MultiUE for SA    55  56     20
    Wait until the current Measurement Period stops
    Collect PM Counter


    ${Counters}    Create Dictionary     ${MAX_UE_UL_SCH_SLOT_BWP1}=${2}
    ...       ${MAX_UE_UL_SCH_SLOT_BWP3}=${2}     ${MAX_UE_UL_SCH_SLOT_BWP2}=${2}
    ...       ${MAX_UE_DL_SCH_SLOT_BWP1}=${2}     ${MAX_UE_DL_SCH_SLOT_BWP2}=${2}
    ...       ${MAX_UE_DL_SCH_SLOT_BWP3}=${2}

    Verify Counters    ${Counters}
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting


