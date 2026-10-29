*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO
...             CIT    CDRT   RAN_5G_TDD    RAN_5G    5G_RAN_FDD    5G_RAN     SBTS00

Documentation

...             author:           Ashutosh
...             maintainer:       ashutosh.k.jaiswal@nokia.com
...
...             INTRODUCTION:     This user scenario describes the gNB behaviour for the successful setup of
...                               Non GBR QoS Flow with configured DL/UL Nominal Bit Rate in DRB profile which
...								  is triggered by Initial Context Setup Request procedure when actRanSharing enable
...             TEST SET NAME:    CB008227
...             TESTING SPLIT:    Refer CB008227 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008227 CFAM
...             Requirement ID:   xxxxx




Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         ../resources/robot/PM_Counters.robot
Resource         CB008227_Resource.robot
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py


Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Modify IPHY File And Send to Airphone Custom    ${IPHY_FILE}
...                 AND     Find Scfc And Fix And Send Full Commissioning
...                           scfc_filename=CB008227_FR1_FDD_TC8.xml
...                 AND     Load CFG Config And Verify cell setup in Capture CPRT Traces      ${wts_cfg_file}   ${no_of_cells}
...                 AND     Check gNB Bulid

Suite Teardown      Run Keywords
...                 Log To console  Suiteteardown
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts_AHLOA.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${sa_ue_id1}      ${1}
${sa_ue_id2}      ${2}
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${TRF_ID}     1
${QFI_ID}     1
${TEST_NAME}     TC8
${epc_log_path}    /tmp/
${IPHY_FILE}                    ${CURDIR}/config/iphy_AHLOA.xml
${no_of_cells}   2

*** Test Cases ***

CB008227-A#B1_TC8_Scheduling_of_5G_UEs_with_non-GBR_bearers_with_respect_to_5QI_and_PLMNID_for_SA_mode_when_actRanSharing_True Downlink only FDD
    [Documentation]  This user scenario describes the gNB behaviour for the successful setup of
     ...                  Non GBR QoS Flow with configured DL/UL Nominal Bit Rate in DRB profile which
     ... 				 is triggered by Initial Context Setup Request procedure when actRanSharing enable
    log to console   TC8 Verifying feature activation in Full recommissioning
     Wait until the next Measurement Period starts
    Verify actNbrForNonGbrBearers In CellSetupReq
    log to console   UE attach trigerring now...
    Start Log    btslog   cprt   bip
    UE Register with ICS+PDU should be Successful   ${sa_ue_id1}
    UE Register with ICS+PDU should be Successful   ${sa_ue_id2}
    sleep     5s
    ${path1}    Stop Log    cprt   test_scenario=bearersetup
    Verify nbrDrbSpecificParams In BearerSetupReq    ${path1}[cprt]/NODECPRT_GNB.pcap    sctp    10000   10000
    MultiUE Trigger DL Traffic for SA    ${sa_ue_id1}  ${sa_ue_id1}   Traffic_rate=mbps     dl_rate=50        pdu_id=1     trf_id=1     qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${sa_ue_id2}  ${sa_ue_id2}   Traffic_rate=mbps     dl_rate=50        pdu_id=1     trf_id=1     qfi_id=1
    sleep     5s
    Validate DL Traffic For MultiUE for SA   ${sa_ue_id1}  ${sa_ue_id1}   dl_rate=50   pdu_id=1   qfi_id=1
    sleep     5s
    Validate DL Traffic For MultiUE for SA   ${sa_ue_id2}  ${sa_ue_id2}   dl_rate=50   pdu_id=1   qfi_id=1
    sleep     5s
    Wait until the current Measurement Period stops
    ${pm_files}     Collect and Store PM Counter Files
    Validate SA_DU_DRB_NBR_DL Counter     ${pm_files}
    Stop MultiUE Data Traffic for SA     ${sa_ue_id1}    ${sa_ue_id1}
    Stop MultiUE Data Traffic for SA     ${sa_ue_id2}    ${sa_ue_id2}
    MultiUE Deregister should be Successful   ${sa_ue_id1}    ${sa_ue_id1}
    MultiUE Deregister should be Successful   ${sa_ue_id2}    ${sa_ue_id2}
    Stop Log   btslog   bip
    [Teardown]  Link SCOUT SCF to Configuration ID for Reporting
