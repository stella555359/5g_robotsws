*** Settings ***
Documentation   author：Changsheng chen
Resource    ./../CUDU_L2/common_setup_teardown.robot
Resource           ./CB009854_resource.robot
Force Tags         CLOUD_5G_I_[LO][LO]_AP_[LOO]_SANSA_FS_ECPRI_CMWV_TDD

*** Variables ***
${SCF_PATH}                    ${CURDIR}/config/SCF
${LOG_PATH}                    ${OUTPUT DIR}
${LOCAL_WTS_DIR}               ${CURDIR}/config/WTS
${WTS_DIR}                     /opt/iphy/latest
${SCF_CA_2F2T_D021_1}           ${SCF_PATH}/SCF_CB009854_D021_1.xml
${SCF_CA_2F2T_D021_2}           ${SCF_PATH}/SCF_CB009854_D021_2.xml
${iphy_CB009854_021}          ${CURDIR}/config/IPHY/iphy_CB009854_D021.xml
${WTS_CFG_021}                 wts_CB009854_021.cfg
${UE2_ID}                      2
${2GNB_4CC_2F2T_SCELL}        ('1', '50', '77'), ('2', '51', '77'), ('3', '63', '28')
@{5CC_scell_index}            1    2    3    4
${egate_console_log}          /opt/wts/latest/egate_console.log
${Egatelog_path}              ${CURDIR}
@{dlonly_scell_index}         1    3    4
@{no_scell_index}             2
@{LOG_NAME_LIST}     btslog    egatelog
${force_reboot}      ${True}
${rd_flag}           0x58057a = 4;0x58057d = 2151677952
@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}


*** Test Cases ***
CB009854D-ET-021_F-3T_Inter_gNB_CA_with_pcsi_bunding_enable_on_Pcell
    [Documentation]
    ...    Precondition:
    ...    1.FDD on GNB1 and 3 TDD configuration.
    ...    TDD cell. FDD 20M as pcell  TDD with 1116 0ms  beam=4 and refine beam is disable
    ...    2.NRBTS.sCellActivationMethod=bufferAndRLQualityBased
    ...    3.sCellAdditionMethod = 1:covBasedA1
    ...    4. RREL sCellOperationalMode =Dlonly
    ...    NRDU.carrierAggregationSupportList=210
    ...    5.sCellDeactivationTimerGNB=1280ms
    ...    6.actConnectedModeMobilityCA = true
    ...    7.actInterNumerologyCa=true
    ...    8.NRBTS/NRDU.flexibleCAMode is set to 2:ConfigurationIndependent
    ...    9.NRBTS/NRCELL.dlMimoMode  (2x4 Closed Loop Spatial Multiplexing)
    ...    10.NRBTS/actFdmScheduling = TRUE      NBTS/NRCELL.actIncreasedFdmUsersPerSlot = TRUE
    ...    11.NRBTS/NRDRB_RLC_AM/ulTReassemblyIBCA=40ms
    ...    12.NRBTS/NRCELL.timingAdvanceOffset = n25600
    ...    13.NRBTS/NRCELL.maxNumSCellsDlFr1 = 4
    ...    14.nrBtsBeamRefinementP2 = TRUE
    ...    15.NRBTS.actBufferBasedSCellAddition= oneShot_Dl_Fr1
    ...    16. NRBTS/NRCELL.actK1Opt is set as intraAndInter-gNB for FDD and TDD FR1 cells
    ...    17.gNB-1 has been configured, via respective NRBTS/NRADJGNB MOC, with neighbor “gNB-2”, to which it connects over Xn link.

    ...    Test Steps:
    ...    1.UE attach to FDD cell as Pcell
    ...    2.UE report A1 to trigger scell additon
    ...    3.start big data on DL and UL
    ...    4.UE report A2  to trigger Tdd scell relasae one by one
    ...    5.UE repor A1 to add Tdd scell again.
    ...    6.Call release
    ...    Check Points:
    ...    1.Verify Scell addditon successfully.
    ...    2.Scell addition successfully. ucch_Config/setup/resourceSetToAddModList/[2].resourceList  ::= {19, 21, 23}
    ...    3.Data transfer on pcell and scell correctly for each
    ...    4.Verfiy UCI bit buding correct for FDD pcell
    ...    5.After step5 Scell release Pucch_Config/setup/resourceSetToAddModList/[2].resourceList  ::= {19}
    ...    6. After step6, scell add again.ucch_Config/setup/resourceSetToAddModList/[2].resourceList  ::= {19, 21, 23}
    ...    7.Call release.
    [Tags]    case_D21    TA_Yalsun    Mannual_Yalsun
    Import Testline Variables For 2 GNBs
    Create Suite Directory
    Backup And Update Iphy Swconfig File    ${iphy_CB009854_021}
    log to console    Send scf to gnb2...
    Full Commission SCF File Through Mplane With Admin    ${SCF_CA_2F2T_D021_2}    1    10.0.1.3
    log to console    Send scf to gnb1...
    Full Commission SCF File Through Mplane With Admin    ${SCF_CA_2F2T_D021_1}    1    10.0.1.2
    Reboot TL And Check Configured For 2 GNBs
    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}    wts_cfg_file=${WTS_CFG_021}
    Create Test Directory
    Start GNB AP Syslog    ${TEST_LOG_DIRECTORY}
    Suite Setup Start WTS And Check OnAir    log=${False}    gnb_num=2
    Sleep    60s    Wait for interGNB communication interface established stable
    #step1
    SA Single UE Attach    ${UE2_ID}
    #step2
    Send Measurement Report To Trigger A1 Scell Addition    ${UE2_ID}
    Start SA UE Big DL Traffic Internal    ${UE2_ID}    1000
    Start SA UE Big UL Traffic Internal    ${UE2_ID}    175
    Sleep    15s    reason=Wait for traffic stable
    Get And Check Scell Infos    ${2GNB_4CC_2F2T_SCELL}
    #step3
    Check UL And DL DTX From Ttitrace For 2GNB    log_id=1    duration=2
    Check NumOfUciCsiPart1Bits On Specific Scell    1    50    26
    Check NumOfUciCsiPart1Bits On Specific Scell    1    51    26
    Check NumOfUciCsiPart1Bits On Specific Scell    1    63    7
    Check ULchannel On Specific Scell    1    50    PUSCH
    Check ULchannel On Specific Scell    1    51    PUSCH
    Check ULchannel On Specific Scell    1    63    PUSCH
    #step4
    Trigger A2 Scell Release    ${UE2_ID}    1    20    50    2
    Check UL And DL DTX From Ttitrace For 2GNB    log_id=2    duration=2
    #step5
    Trigger A2 Scell Release    ${UE2_ID}    2    20    51    3
    Check UL And DL DTX From Ttitrace For 2GNB    log_id=3    duration=2
    #step6
    Trigger A2 Scell Release    ${UE2_ID}    3    20    63    4
    Check UL And DL DTX From Ttitrace For 2GNB    log_id=4    duration=2
    #step7
    Trigger A1 Scell Addition    ${UE2_ID}    120    60    5
    Check UL And DL DTX From Ttitrace For 2GNB    log_id=5    duration=2
    Check NumOfUciCsiPart1Bits On Specific Scell    1    50    26
    Check NumOfUciCsiPart1Bits On Specific Scell    1    51    26
    Check NumOfUciCsiPart1Bits On Specific Scell    1    63    7
    Check ULchannel On Specific Scell    1    50    PUSCH
    Check ULchannel On Specific Scell    1    51    PUSCH
    Check ULchannel On Specific Scell    1    63    PUSCH
    #step8
    SA Stop Data Traffic Internal    ${UE2_ID}    1    ul
    Check UL And DL DTX From Ttitrace For 2GNB    log_id=6    duration=2
    #step9
    SA 5G Detach    ${UE2_ID}
    [Teardown]    Common Test Teardown 2

*** Keywords ***

Suite Setup Start WTS And Check OnAir Without Workaround
    [Arguments]    ${log}=${True}    ${enb_id}=1    ${gnb_id}=2    ${wts_cfg_file}=${WTS_CFG}    ${gnb_num}=1    ${skip_X2}=${True}
    [Documentation]    This keyword is to modify vlan, start WTS, wait for onAir
    Modify UTE SCTP Timeout
    Modify AP SCTP Timeout
    Configure UTE ETH3
    Start UTE WTS    ${wts_cfg_file}
    Run Keyword If    '${GNBCUTYPE}'=='SANSA'    UE SIB Decoding Should Be Successful
    Run Keyword If    '${GNBCUTYPE}'=='SA'    UE SIB Decoding
    #Get NR Cell Number
    Run Keyword If    '${GNBCUTYPE}'=='NSA'    Setup X2 Connection    ${enb_id}    ${gnb_id}
    Verify Cell Setup    gnb_num=${gnb_num}
    Run Keyword If    '${GNBCUTYPE}'=='SANSA' or '${GNBCUTYPE}'=='SA'    Check All Cells Received SIB2
    Run Keyword If    '${GNBCUTYPE}'=='SANSA' and '${skip_X2}'=='${False}'    Setup X2 Connection    ${enb_id}    ${gnb_id}
    [Teardown]    Run Keyword If    "${log}"=="${True}"    common_log_capture.Stop Logs    ${LOG_NAME_SUITE_SETUP}    ${SUITE_LOG_DIRECTORY}

Send Measurement Report To Trigger A1 Scell Addition
    [Arguments]    ${UE_ID}
    ute_wtssim.Execute Egate Command    cmd=ue_measurement_send_nr id\=${UE_ID} meas_id=1 event=A1 srsrp_nr=120
    Sleep    2s

Check UL And DL DTX From Ttitrace For 2GNB
    [Arguments]    ${log_id}    ${duration}
    CUDU_L2 Capture And Decode TTitrace For 2GNB   ${log_id}    ${duration}
    CUDU_L2 Check DTXNACK Rate    ${log_id}
    CUDU_L2 Check UL DTXCRC Rate    ${log_id}

CUDU_L2 Capture And Decode TTitrace For 2GNB
    [Arguments]    ${log_id}=1    ${duration}=5
    Start Ttitrace With Streaming Mode For 2GNB
    Sleep    ${duration}s    reason=Wait for logs
    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/${log_id}
    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/${log_id}

Start Ttitrace With Streaming Mode For 2GNB
    [Arguments]    ${names}=l2stream3_ttitrace
    [Documentation]    This keyword is used to start ttitrace with streaming mode.
    ...    examples 1: catch all cells
    ...    Start Ttitrace With Streaming Mode
    log to console    setup admin for ttitrace...
    Run Keyword If    '${SW_BRANCH}'=='${EMPTY}'    Get Software Version
    ${executor}=  Create Dictionary
    ...  host=10.0.1.2
    ...  user=Nemuadmin
    ...  password=nemuuser
    ...  port=443
    ...  release=${SW_BRANCH}
    TCPDUMP.create tcpdump collector
    ...  name=tcpdump_ttitrace
    ...  options=-i eth3 udp and dst 10.0.1.1 and dst port 5678
    ...  sudo_password=ute
    L2STREAM3.create_sbts_l2stream_collector
    ...  name=${names}
    ...  destination_ip_addr=10.0.1.1
    ...  collector=tcpdump_ttitrace
    ...  l2_stream_configuration=${L2STREAM_COMPONENT_CONFIG}
    ...  webservice=${executor}
    ...  dscp=10
    L2STREAM3.Set Suite Alias
    ...  alias=${names}
    CORE.setup_collectors
    ...  names=${names}
   ${executor2}=  Create Dictionary
    ...  host=10.0.1.3
    ...  user=Nemuadmin
    ...  password=nemuuser
    ...  port=443
    ...  release=${SW_BRANCH}
    L2STREAM3.create_sbts_l2stream_collector
    ...  name=${names}
    ...  destination_ip_addr=10.0.1.1
    ...  collector=tcpdump_ttitrace
    ...  l2_stream_configuration=${L2STREAM_COMPONENT_CONFIG}
    ...  webservice=${executor2}
    ...  dscp=10
    L2STREAM3.Set Suite Alias
    ...  alias=${names}
    CORE.setup_collectors
    ...  names=${names}
    CORE.start_collectors
    ...  names=${names}
    log to console    finish admin process for ttitrace,start to catch ttitrace log...
