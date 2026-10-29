*** Settings ***
Documentation    :copyright: Nokia
...             :authors: I_MN_RAN_RD_VRF_WRO2_6
...             :contact: I_MN_RAN_RD_VRF_WRO2_6

Resource    taf/rfrl/common_resources/robot/libraries_instances.robot
Resource    testsuite/Wroclaw/RRM/resources/airphone/wro_2/keywords/tshark_verifying.robot
Resource    testsuite/Wroclaw/RRM/resources/airphone/wro_2/keywords/messaging.robot
Resource    testsuite/Wroclaw/RRM/resources/airphone/wro_2/keywords/verify_ta_messaging/verify_messages_flow/ta_messaging_flow.robot
Resource    verify_ta_messaging/verify_common_keywords.robot
Resource    verify_ta_messaging/verify_UECapabilityEnquiry.robot
Resource    verify_ta_messaging/verify_InitialContextSetup.robot
Resource    verify_ta_messaging/verify_UEContextSetup.robot
Resource    verify_ta_messaging/verify_UEContextRelease.robot
Resource    verify_ta_messaging/verify_UEContextModification.robot
Resource    verify_ta_messaging/verify_BearerContext.robot
Resource    verify_ta_messaging/verify_RRC.robot
Resource    verify_ta_messaging/verify_PDUSessionResourceModify.robot
Resource    taf/rfrl/bts/robot/common/gnb_cell.robot
Resource    ta_messaging/flow.robot


Resource    testsuite/Wroclaw/RRM/resources/airphone/wro_2/keywords/logging.robot
Resource    testsuite/Wroclaw/RRM/resources/airphone/wro_2/keywords/tshark_verifying.robot
Resource    feature_keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T06/resources/keywords.robot
Resource    testsuite/Wroclaw/RRM/resources/airphone/wro_2/keywords/traffic.robot
Resource    testsuite/Wroclaw/RRM/resources/airphone/wro_2/keywords/L3_Call.robot


Library     taf.hw.pdu
Library     OperatingSystem
Library     DateTime
Library     Telnet
Library     ute_wtssim
Library     ute_fsmaccess
Library     ta5g_aashell
Library     ta5g_throughput
Library     ta5g_ue_mobility
Library     ta5g_cell_operations
Library     ta5g_enb
Library     ta5g_iphy
Library     ta5g_egate
Library     ta5g_tshark
Library     ta5g_iperf_traffic
Library     ta5g_testline_management
Library     ta5g_commissioning
Library     ta5g_file_system
Library     ta_messaging
Library     taf.sbts.oam.coam.admin     WITH NAME   admin
Library     taf.transport.ssh     WITH NAME   ssh
Library     ./resources/mock_stop_egate.py

Variables    feature_variables.py

*** Variables ***
${WTS_DIR}                      /opt/wts/latest
${PDU_MODEL}=                   ${tl.pdus[0].__class__.__name__}
${PDU_IP}=                      ${tl.pdus[0].addr}
${PDU_PORT_AP}=                 ${tl.ues[0].l1.common_units[0].pdu_port.port_no}
${GNB_PDU_PORT}                 ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}
@{swconfig_8717_rdFlag}=        0x890057=0 # rdActNrDualConnectivity - Parameter set to 0 implies intraGnb NR-DC enabled in all cells
${rdMergedMeasGapSetupAndDrxRelease}=        0x890046=1 # rdMergedMeasGapSetupAndDrxRelease
${rdPreventOverloadActivationBeforeUeTresholdIsReached}=        0x89008e=0 # rdPreventOverloadActivationBeforeUeTresholdIsReached
@{8717_SWCONFIG_FLAGS}=    ${rdMergedMeasGapSetupAndDrxRelease}    @{swconfig_8717_rdFlag}
@{8717_SWCONFIG_FLAGS_overload}=    ${rdMergedMeasGapSetupAndDrxRelease}    @{swconfig_8717_rdFlag}
...    ${rdPreventOverloadActivationBeforeUeTresholdIsReached}

*** Keywords ***
Prepare Test Setup For One Real Gnb And Enable Tshark Verification CB008717
    [Arguments]    ${tc_id}    ${iphy}=IPHY    ${scfc}=SCFC    ${cfg}=cfg
    ${iphy}=    Create Config File Path Variable Name     filetype=${iphy}    name=${tc_id}
    ${scfc}=    Create Config File Path Variable Name     filetype=${scfc}    name=${tc_id}
    ${cfg}=     Create Config File Path Variable Name     filetype=${cfg}     name=${tc_id}

    ${iphy_filename}=    Get Variable Value    ${iphy}
    ${scfc_filename}=    Get Variable Value    ${scfc}
    ${cfg_filename}=     Get Variable Value    ${cfg}
    Run Keywords
    ...                Update And Put Iphy Xml         input_filepath=${iphy_filename}
    ...    AND         Find Scfc And Fix And Send Full Commissioning    scfc_filename=${scfc_filename}    skip_relation_errors=True
    ...    AND         Reset Wts
    ...    AND         Check Radios Availability

Prepare Test Configuration
    Update And Put Iphy Xml    input_filepath=${iphy_xml}
    Enable C-Plane Debug Logs    with_reboot=${FALSE}
    Find Scfc And Fix And Send Full Commissioning    scfc_filename=${scfc}
    Wait For Environment And Trigger Site Reset

Create GNB alias
    Create GNB device with alias 'gNB' identified by ip=10.0.1.2
    Enable internal mirroring for alias    gNB

Create gNB And UEs Aliases
    Create Ues Alias    alias=UE    id_type=wts_5g
    feature_keywords.Create GNB alias

Create AMF gNB and UEs Aliases
    Create gNB And UEs Aliases
    Create AMF device with alias 'AMF' identified by ip=10.0.1.1

Setup devices aliases
    Create UEs alias    alias=UE   id_type=wts_5g
    Create GNB device with alias 'gNB2' identified by ip=10.0.1.2
    Enable internal mirroring for alias  gNB2
    Create AMF device with alias 'AMF1' identified by ip=10.0.1.1

Get Sw Release
    ${CLI_BUILD_DICT}=  Set variable
    ssh.connect_to  alias=ssh_connection
    ...    hostname=192.168.255.1
    ...    username=toor4nsn
    ...    password=oZPS0POrRieRtu
    ${hash_build}=    ssh.execute    ls /ffs/run | grep HashContainerSignature.*.p7   connection=ssh_connection
    ${hash_build}=    remove string    ${hash_build}    HashContainerSignature_
    ${hash_build}=    fetch from left    ${hash_build}    _
    [Return]    ${CLI_BUILD_DICT}
    [Teardown]    ssh.Disconnect  connection=ssh_connection

Unlock Radio
    [Arguments]     ${rmod_id}=1
    ${CLI_BUILD_DICT}=    Get Sw Release
    admin.connect_to    name=rmod_unlock    release=${CLI_BUILD_DICT}
    admin.unlock  /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/RMOD_R-${rmod_id}
    ...    connection=rmod_unlock
    ...    timeout=60
    [Teardown]  admin.teardown_admin    connection=rmod_unlock

Check if gNB is pingable
    ${output}=       	Run       	ping -c 1 -W 10 192.168.255.1
    Should contain      ${output}   1 packets transmitted, 1 received

Switch Off Ap Via Pdu
    Setup Pdu    model=${PDU_MODEL}    host=${PDU_IP}    alias=testline_pdu
    Power Off    port=${PDU_PORT_AP}    pdu_device=testline_pdu

Switch On Ap Via Pdu
    Setup Pdu    model=${PDU_MODEL}    host=${PDU_IP}    alias=testline_pdu
    Power On    port=${PDU_PORT_AP}    pdu_device=testline_pdu

Check If Flow occurred as expected
    [Arguments]    ${scenario}
    Flow occurred as expected    alias=NR_DC_FlOW_${scenario}

Verify Mibs and Sib after Reached Onair
    Wait For Mib Reception
    Wait For Sib1 Reception

Waiting For Cell Configuring
    Sleep    60s

Waiting For FR1 SA Cell Configuring
    Wait For Cell To Be Configured    cell_id=1    timeout=150

Wait For Cell To Be Enabled
    [Arguments]    ${cell_id}
    Wait For Cell To Be Not Locked    cell_id=${cell_id}    timeout=200

Wait For Environment To Be Ready
    Sleep    300s

Wait For Environment And Trigger Site Reset
    Wait For Environment To Be Ready
    Trigger Site Reset
    Wait For Testline Icmp Echo Replies And Ssh Services

Prepare Test Setup for -GA_B1a Scenario
    Enable C-Plane Debug Logs    with_reboot=${FALSE}
    Trigger Site Reset
    Wait Until Keyword Succeeds    120s    1s    Check if gNB is pingable
    Start Default Logging    output_dirpath=${OUTPUT_DIR}
    Create AMF gNB and UEs Aliases
    Expect F1 E1 Setup Messages
    Wait Until Keyword Succeeds    3x    1s    Check Radios Availability

Expect F1 E1 Setup Messages
    EXPECT FLOW[timeout=500]: gNB E1AP gNB-CU-UP-E1Setup
    EXPECT FLOW[timeout=500]: gNB F1AP f1Setup

Check If F1 E1 Setup and gNBDUConfigurationUpdates Occured
    PASS FLOW[timeout=500]: gNB E1AP gNB-CU-UP-E1Setup
    PASS FLOW[timeout=500]: gNB F1AP f1Setup
    Verify F1AP gNBDuConfigurationUpdate For FR2 Cells
    Verify Tcpdump Log    ${F1AP_SERVED_CELLS_TO_ADD_LIST_IN_GNBDUCONFIGURATIONUPDATE}    number_of_messages=8

Expect NGAP Setup
    EXPECT FLOW[timeout=600]: AMF NGAP nGSetup

Verify NGAP Setup After Reached OnAir
    PASS FLOW[timeout=600]: AMF NGAP nGSetup

Verify F1AP gNBDuConfigurationUpdate For FR2 Cells
    Verify Tcpdump Log    ${F1AP_SERVED_CELLS_TO_ADD_LIST_IN_GNBDUCONFIGURATIONUPDATE}    number_of_messages=8
    Verify Tcpdump Log    ${F1AP_GNB_CONFIGURATION_UPDATE_ACKNOWLEDGE}                    number_of_messages=8

Verify F1AP gNBDuConfigurationUpdate For FR2 8 Cells
    Verify Tcpdump Log    ${F1AP_SERVED_CELLS_TO_ADD_LIST_IN_GNBDUCONFIGURATIONUPDATE}    number_of_messages=8
    Verify Tcpdump Log    ${F1AP_GNB_CONFIGURATION_UPDATE_ACKNOWLEDGE}                    number_of_messages=18

Verify If All Cells Are In Service State
    Verify Tcpdump Log    ${F1AP_GNBDUCONFIGURTIONUPDATE_WITH_SERVICE_STATE_IN_SERVICE}   number_of_messages=9
    Verify Tcpdump Log    ${F1AP_GNB_CONFIGURATION_UPDATE_ACKNOWLEDGE}                    number_of_messages=17

Verify If Cells To Be Activated List Contains 8 FR2 Cells And PCell
   Verify Tcpdump Log     ${F1AP_CELLS_TO_BE_ACTIVATED_LIST_FOR_8_CELLS}                  number_of_messages=1
   Verify Tcpdump Log     ${F1AP_GNBDUCONFIGURTIONUPDATE_WITH_PCELL_ACTIVATION}           number_of_messages=1

Verify If SIBs Are Not Present On FR2 Cells
    Verify Uu Messages    ${UU_SIBS_NOT_PRESENT_ON_FR2_CELLS}                             number_of_messages=0

Verify that UE was not released for 60 seconds
    [Arguments]    ${ue_id}=${ue_id}
    Wait Before UE Release
    Deregister UE    ue_id=${ue_id}

Wait Before UE Release
    Sleep    60s

On failure
    [Documentation]     Accepts only keyword without kwargs
    [Arguments]     @{keyword_name_with_args}
    ${if_on_failure}=   get variable value        ${ON_FAILURE}         CONTINUE

    Run Keyword if  '${if_on_failure}' == 'CONTINUE'
    ...         Run Keyword And Continue On Failure
    ...         @{keyword_name_with_args}

    Run Keyword if  '${if_on_failure}' == 'IGNORE'
    ...         Run Keyword and ignore error
    ...         @{keyword_name_with_args}

Preparation of gNB for testing
    Trigger Site Reset
    Check Radios Availability

Preparation of environment for retesting
    Setup egate  egate_port=20000  alias=default
    On failure    Deregister UE    all

Run Setup
    Log To Console    Setup started

    # Launch the retest with "-v RESET_EGATE:false" flag to speed up the retest - by not starting the egate session from scratch
    ${reset_egate}    Get variable value      ${RESET_EGATE}    True

    Run Keyword if  '${reset_egate}' == 'True'
    ...    Reach onAir state    ${reset_egate}
    Run Keyword if  '${reset_egate}' != 'True'
    ...    Preparation of environment for retesting

Reach onAir state
    [Arguments]    ${reset_egate}
    # Launch the test with "-v CONFIG_DISABLED:True" flag to skip iphy && gNB configuration setup
    ${config_disabled}    Get variable value      ${CONFIG_DISABLED}    False

    Run Keyword if  ('${config_disabled}' == 'True') and ('${reset_egate}' == 'True')
    ...   Preparation of gNB for testing

    Log To Console    Before Reach OnAir
    Reach OnAir       lua_cfg=${cfg}
    Log To Console    After Reach OnAir

    Do not stop egate and daemon

Unlock FR2 Radio
    [Arguments]     ${rmod_id}=2
    ${CLI_BUILD_DICT}=    Get Sw Release
    admin.connect_to    name=rmod_unlock    release=${CLI_BUILD_DICT}
    admin.unlock  /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/RMOD_R-${rmod_id}
    ...    connection=rmod_unlock
    ...    timeout=60
    [Teardown]  admin.teardown_admin    connection=rmod_unlock

Unlock FR1 SA Cell
    Find Scfc and Send Delta Commissioning    scfc_filename=${delta}

Unlock NRDC Cell
    Find Scfc and Send Delta Commissioning    scfc_filename=${delta}

Verify If Proper Cells Are In Service State
    Verify Tcpdump Log    ${F1AP_GNBDUCONFIGURTIONUPDATE_WITH_SERVICE_STATE_IN_SERVICE}   number_of_messages=3
    Verify Tcpdump Log    ${F1AP_GNB_CONFIGURATION_UPDATE_ACKNOWLEDGE}                    number_of_messages=5

Verify If 9 Cells Are In Service State
    Verify Tcpdump Log    ${F1AP_GNBDUCONFIGURTIONUPDATE_WITH_SERVICE_STATE_IN_SERVICE}   number_of_messages=9
    Verify Tcpdump Log    ${F1AP_GNB_CONFIGURATION_UPDATE_ACKNOWLEDGE}                    number_of_messages=18

Reach Configured State With Second Radio Locked
    Prepare Test Configuration
    Start Default Logging    output_dirpath=${OUTPUT_DIR}
    Prepare Flow Check For G_B81a Scenario
    Wait Until Keyword Succeeds    3x    1s    Check Radios Availability

Trigger Site Reset And Reach Onair
    [Arguments]    ${egate}    ${retries}=2
    With Retry Context    ${retries}
    ...                Trigger Site Reset
    ...    AND         Check Radios Availability
    ...    AND         Enable Tshark Verification
    ...    AND         With Simulator Configuration    config=${egate}

Configure Test Environment
    [Arguments]    ${iphy}    ${scfc}    ${egate}    ${retries}=2
    Run Keywords       Enable C-Plane Debug Logs    with_reboot=${false}
    ...    AND         Update And Put Iphy Xml        input_filepath=${iphy}
    ...    AND         With Gnb Configuration          commissioning=${scfc}
    ...    AND         Wait For Testline Icmp Echo Replies And Ssh Services
    ...    AND         Wait For Environment To Be Ready
    ...    AND         Trigger Site Reset And Reach Onair    egate=${egate}    retries=${retries}

Verify If Proper Cells Are In Service State For NR-DC-SN Cell Activation In RAN Sharing Scenario
    Verify Tcpdump Log    ${F1AP_GNBDUCONFIGURTIONUPDATE_WITH_SERVICE_STATE_IN_SERVICE}   number_of_messages=4
    Verify Tcpdump Log    ${F1AP_GNB_CONFIGURATION_UPDATE_ACKNOWLEDGE}                    number_of_messages=7


Reach Configured State With Second Radio Locked For NR-DC-SN Cell Activation In RAN Sharing Scenario
    Prepare Test Configuration
    Start Default Logging    output_dirpath=${OUTPUT_DIR}
    Prepare Flow Check For NR-DC-SN Cell Activation In RAN Sharing Scenario
    Wait Until Keyword Succeeds    3x    1s    Check Radios Availability

Establish PDU Session With Attache UE
    [Arguments]    ${ue_id}     ${pdu_id}    ${gw_id}    ${check_timestamps}=${True}
    Attach Ue    ue_id=${ue_id}
    Set Internal Traffic Type To UE    ue_id=${ue_id}    pdu_id=${pdu_id}
    Set Scg UL Dist Percent    id=${uec_id}    scg_ul_dist_percent=50
    Establish Pdu Session With Traffic
    ...    ue_id=${ue_id}
    ...    pdu_id=${pdu_id}
    ...    gw_id=${gw_id}
    ...    check_timestamps=${check_timestamps}

Send Data Traffic and Verify Throughput
    [Arguments]    ${ue_id}     ${pdu_id}
    Send Data Traffic In Direction    ue_id=${ue_id}   pdu_id=${pdu_id}    dir=dl    mbps=160
    Send Data Traffic In Direction    ue_id=${ue_id}   pdu_id=${pdu_id}    dir=ul    mbps=28
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}    expected_throughput=10     cell_index_min=0
        ...       direction=dl    cell_group=MCG    selection_type=minimum    margin=10%
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}    expected_throughput=10     cell_index_min=0
        ...       direction=ul    cell_group=MCG    selection_type=minimum    margin=10%
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}    expected_throughput=10     cell_index_min=1
        ...    cell_index_max=1    direction=dl    cell_group=SCG    selection_type=minimum
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}    expected_throughput=10    cell_index_min=1
        ...    cell_index_max=1    direction=ul    cell_group=SCG    selection_type=minimum

Register UE and establish PDU session with one QoS flow
    Set expected messages flows for ICS of UE1 with 1 QoS flow for gNB2, AMF1
    Attach Ue    ue_id=${ue_id}
    Set Scg UL Dist Percent
    Set Internal Traffic Type To UE    ue_id=${ue_id}    pdu_id=${pdu_id}
    Establish PDU Session    ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Verify expected messages flows for ICS of UE1 with 1 QoS flow for gNB2, AMF1

Send A4 measurement and verify NR-DC is established
    [Arguments]    ${meas_id}    ${rrc_id}    ${rrc_all}
    Set expected A4 measurement based PSCell addition messages flows for UE1 gNB2
    UE1 sends A4 measurement id=${meas_id} for NR-DC PSCell addition
    Verify expected A4 measurement based PSCell addition messages flows for UE1 gNB2
    Verify that RRCReconfigurationComplete_${rrc_id} out of ${rrc_all} for UE1 that message contains nr-SCG response

Send A4 measurement and verify NR-DC is established after FR1 CA SCell Release
    [Arguments]    ${meas_id}    ${rrc_id}    ${rrc_all}
    Set expected A4 measurement based PSCell addition messages flows for UE1 gNB2 after FR1 CA Release
    UE1 sends A4 measurement id=${meas_id} for NR-DC PSCell addition
    Verify expected A4 measurement based PSCell addition messages flows for UE1 gNB2 after FR1 CA Release
    Verify that RRCReconfigurationComplete_${rrc_id} out of ${rrc_all} for UE1 that message contains nr-SCG response

UE1 sends A1 measurement report id=1 for SCellAddition with RSRP value lower than FDD threshold
    EXPECT FLOW[timeout=20]: UE_1 NR-RRC MeasurementReport
    Execute egate command    cmd=ue_measurement_send_nr id=1 meas_id=1 srsrp_nr=75 event=A1
    PASS FLOW[timeout=20]: UE_1 NR-RRC MeasurementReport
    Verify that MeasurementReport contains A1 measurement results for UE1 and measId=1

Waiting For PDU Session Establishment
    Sleep    2s

Waiting For Message Flow To Set Up
    [Arguments]    ${waiting_time}=2s
    Sleep    ${waiting_time}

Ignore RRCReconfiguration Message
    Execute Egate Command     cmd=ue_nr_rrc_reconf_param id=1 if_contains=any action=drop

Send Data Traffic In Both Direction For Buffer Overflow
    [Arguments]    ${ue_id}=1    ${pdu_id}=1   ${dir}=dl    ${mbps}=125
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 trf_id=1 dir=${dir} mbps=${mbps} size=1350
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 trf_id=2 dir=${dir} mbps=${mbps} size=1350
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 trf_id=1 dir=ul mbps=75 size=1350

UE1 Sends A4 Meas Id=2 And Immediately Sends A2 Meas Id=6 To Cell Id7
    Execute Egate Command    cmd=ue_measurement_send_nr id=1 meas_id=2 phycell_id=52 nrsrp_nr=60 event=A4
    Execute Egate Command    cmd=ue_measurement_send_nr id=1 meas_id=6 phycell_id=57 srsrp_nr=25 event=A2

UE Sends A4 NRDC Measurement Just After A2 SCell Release Measurement
    Execute Egate Command    cmd=ue_measurement_send_nr id=1 meas_id=6 event=A2 scell=1 scell_rsrp=5
    Execute Egate Command    cmd=ue_measurement_send_nr id=1 meas_id=2 phycell_id=52 nrsrp_nr=60 event=A4

UE1 Sends A1 Measurement Report id=1 For SCellAddition With RSRP And SRSRP Value Lower Than FDD Threshold
    EXPECT FLOW[timeout=20]: UE_1 NR-RRC MeasurementReport
    Execute egate command    cmd=ue_measurement_send_nr id=1 meas_id=1 event=A1 srsrp_nr=75 srsrq_nr=50
    PASS FLOW[timeout=20]: UE_1 NR-RRC MeasurementReport
    Verify that MeasurementReport contains A1 measurement results for UE1 and measId=1

UE1 Sends A4 NRDC Measurement Just After A1 SCell Change With RSRP Value Higher Than FDD Threshold
    Execute egate command    cmd=ue_measurement_send_nr id=1 meas_id=6 event=A1 srsrp_nr=85 srsrq_nr=50
    Execute egate command    cmd=ue_measurement_send_nr id=1 meas_id=2 phycell_id=52 nrsrp_nr=60 event=A4

Delay RRCReconfigurationComplete message
    [Arguments]    ${ue_id}    ${if_contains}    ${delay}
    Execute Egate Command     cmd=ue_nr_rrc_reconf_param id=${ue_id} if_contains=${if_contains} delay=${delay}

Trigger Radio Link Failure
    [Arguments]    ${ue_id}=1    ${gnb_id}=2   ${cause}=otherFailure    ${cell_id}=1
    Execute Egate Command     cmd=ue_rrc_reestablish id=${ue_id} gnb=${gnb_id} cell=${cell_id} cause=${cause}
