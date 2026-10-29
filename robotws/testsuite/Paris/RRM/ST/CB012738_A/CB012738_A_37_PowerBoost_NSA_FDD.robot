*** Settings ***
Documentation   CB012738 feature, PDCCH power boosting, enhances network efficiency and capacity in FR1 by reducing PDCCH blocking.
...    It increases transmit power at lower Aggregation Levels (AL4 from AL8, AL2 from AL4) and uses a 3dB power boost when downgrading AL levels.
...    The feature is controlled via O&M settings per cell.
...
...    Key Features:
...
...	    Enhances network efficiency in FR1 by reducing PDCCH blocking
...	    Increases transmit power at lower Aggregation Levels (AL4 from AL8, AL2 from AL4)
...	    Uses 3dB power boost when downgrading AL levels
...
...    Configuration Parameters:
...
...	    NRCELL-actPdcchPowerBoost
...	    NRBTS/NRDRB-allowedPdcchPowerBoostALDueCce
...	    NRBTS/NRDRB-allowedPdcchPowerBoostALDueCfg
...
...    Prerequisites and Limitations:
...
...	    Only works in FR1
...	    Requires 5GC000791 (dynamic PDCCH AL control)
...	    rdStaticPdcchPowerOffset must be 0
...	    No support for SIB1/SI/Paging/RACH messages
...	    Only supports AL2/AL4 boosting
...	    Cell-level licensing with SWEM formula
...
...    Operation:
...
...	    Prioritizes legacy PDCCH allocation first
...	    Applies power boosting for blocked allocations
...	    Compatible with PDSCH shared symbol (CB008370) and dynamic PDCCH symbol usage (CB008367)
...	    Controlled via O&M settings per cel
...
...    Test Case for PDCCH Power Boosting Configuration
...              FR1, NSA, FDD, 20M, 96 PRBs Configuration
...
...     CONTACT: VRF_NPS_T02
...     AUTHOR: Abderrahmane NEZROUK

Suite Setup       CB012738 Test Suite Setup
Suite Teardown    CB012738 Test Suite Teardown

Library         BuiltIn
Library	        OperatingSystem
Library	        taf.ue                                 WITH NAME    taf_ue
Library	        taf.transport.ssh          		        WITH NAME    ssh
Library	        taf.collectors.btslog      		        WITH NAME    btslog
Library	        taf.collectors.core        		        WITH NAME    core
Library         taf.analyzer.iperf_throughput           WITH NAME    tput
Library         taf.sbts.oam.coam.admin                  WITH NAME  coam_admin
Library         taf.selenium.sbts                        WITH NAME  selenium_sbts
Library         taf.hw.pdu                               WITH NAME  pdu
Library			ArchiveLibrary
Library			DateTime
Library			Collections
Library			String
Library         Process
Library         json
Library         taf.sw.reporting_portal
Library         taf.rfrl.utilities.tl_config                             WITH NAME  tl_config

Library         ../resources/vrf_nps_2/python/utilities.py
Library         ../resources/vrf_nps_2/python/radParams_handler.py           WITH NAME  radParams
Library         ../resources/vrf_nps_2/python/useful_keywords.py             WITH NAME  useful_keywords
Library         ../../../resources/ST/python/scout_utils.py                  WITH NAME  scout_utils
Library         ../resources/vrf_nps_2/python/files_operations.py            WITH NAME  files_operations
Library         ../resources/vrf_nps_2/python/bts_utilities.py               WITH NAME  bts_utilities
Library         ../resources/vrf_nps_2/python/tti_trace_collector.py         WITH NAME  tti_trace_collector
Library         ../resources/vrf_nps_2/python/tti_trace_tool_installer.py    WITH NAME  tti_tool_installer



Resource        taf/rfrl/common_resources/common_step/interface.robot
Resource        taf/rfrl/bts/robot/common/gnb_alarm.robot
Resource        taf/rfrl/bts/robot/common/gnb_bbu.robot
Resource        taf/rfrl/bts/robot/common/gnb_cell.robot
Resource        taf/rfrl/bts/robot/common/gnb_ru.robot
Resource        taf/rfrl/bts/robot/common/gnb_log.robot
Resource        taf/rfrl/bts/robot/common/gnb_scf.robot
Resource        taf/rfrl/common_resources/robot/coam.robot

Resource        ./resourses/common_keywords_CB012738.robot
Resource        ../resources/vrf_nps_2/robot/Test_Suite_Preparation.robot
Resource        ../resources/vrf_nps_2/robot/var_test_suite.robot
Resource        ../resources/vrf_nps_2/robot/logs_collector.robot
Resource        ../resources/vrf_nps_2/robot/scf_utilities.robot
Resource        ../resources/vrf_nps_2/robot/common_useful_keywords.robot
Resource        ../resources/vrf_nps_2/robot/dcap.robot

*** Variables ***
&{bts_info}      alias=gnb_dcap    host=192.168.255.129    username=Nemuadmin    password=nemuuser
    ...     port=443    bts_id=${tl.gnbs[0].global_bts_id}
@{gnb_custom_profile}         cp_5g    bip_interface_mirroring    L2Ps_Component    condor5gSyslog
@{bts_custom_profile}
@{l1_trace}
${feature_activation_plan}    CB012738_activation_plan.json
${MaxAttenuation}             93.5
${UE1}=                       UE_1
${UE1_CAPABILITIE}=           REAL_ANDROID_UE_2
${protocol}                   udp
${direction}=                 DL
${tput_duration}              120s
${DL_TPUT}                    80 Mbits/sec
${UL_TPUT}                    20 Mbits/sec
${qci_dl}                     9
${qci_ul}                     9
${qci_ul_gbr}                 3
${Packet_Size}                1350
${udp_buffer}                 20m
${buffer_client}              20m
${buffer_server}              20m
${deviation}                  8%
${CMD_TIMEOUT}                60
${trace_name}
${alarms_list}                ${EMPTY}
@{ALLOWED_ALARMS}=            8000
...                           4592
...                           61524
...                           61649
...							  61652
...                           4334
...                           4340
...                           4654
...                           4655
...                           4681
...                           61524
@{custom_patterns}=           critical
...                           err\\/\\|error
...                           wrn\\/\\|warning
...                           unknown
@{custom_msg_to_skip}=        INF
${CPTY_UNIT_ID}=             1
*** Test Cases ***
CB012738-A_37_ParamReconfig_allowedPdcchPowerBoostALDueCfg_newUser_NSA_FDD
    [Documentation]    Verify PDCCH power boosting under different configurations
    ...               of allowedPdcchPowerBoostALDueCfg parameter
    ...               in FR1 NSA FDD mode
    [Tags]    CB012738    PDCCH    Power Boosting    FR1    NSA    FDD
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    Run Keyword And Continue On Failure  gnb_log.Start Collecting gNB Btslog
    Modify NRBTS Parameter    MRBTS-23174/NRBTS-23174/NRDRB-14    allowedPdcchPowerBoostALDueCfg    AL4
    Modify NRBTS Parameter    MRBTS-23174/NRBTS-23174/NRDRB-42    allowedPdcchPowerBoostALDueCfg    None
    # ********************** Step 1: Initial Connection and DL Data ***************************************
    Connect UE    ${UE1}
    Get UE Infos    ${UE1}
    Start DL Transmission    ${UE1}    ${DL_TPUT}
    Verify PDCCH Power Boosting    Step1    ${CPTY_UNIT_ID}    duration=10s    expected=True
    # ********************** Step 2: Modify Power Boost Config **********************************************
    Modify NRBTS Parameter    MRBTS-23174/NRBTS-23174/NRDRB-14    allowedPdcchPowerBoostALDueCfg    None
    Verify PDCCH Power Boosting    Step2    ${CPTY_UNIT_ID}    duration=10s    expected=True
    # ********************** Step 3: Reconnection Test ******************************************************
    Stop DL Transmission    ${UE1}
    Release UE    ${UE1}
    Connect UE    ${UE1}
    Start DL Transmission    ${UE1}    ${DL_TPUT}
    Verify PDCCH Power Boosting    Step3    ${CPTY_UNIT_ID}    duration=10s    expected=False
    # ********************** Step 4: Modify to AL2_AL4 ******************************************************
    Modify NRBTS Parameter    MRBTS-23174/NRBTS-23174/NRDRB-14    allowedPdcchPowerBoostALDueCfg    AL2_AL4
    Verify PDCCH Power Boosting    Step4    ${CPTY_UNIT_ID}    duration=10s    expected=False
    # ********************** Step 5: Reconnection Test with AL2_AL4 *****************************************
    Stop DL Transmission    ${UE1}
    Release UE    ${UE1}
    Connect UE    ${UE1}
    Start DL Transmission    ${UE1}    ${DL_TPUT}
    Verify PDCCH Power Boosting    Step5    ${CPTY_UNIT_ID}    duration=10s    expected=True
    # ********************** Step 6: Modify to AL2***************** *****************************************
    Modify NRBTS Parameter    MRBTS-23174/NRBTS-23174/NRDRB-14    allowedPdcchPowerBoostALDueCfg    AL2
    Verify PDCCH Power Boosting    Step6    ${CPTY_UNIT_ID}    duration=10s    expected=True
    # *******************************************************************************************************
    Stop DL Transmission    ${UE1}
    # *********** waiting till Traffic Scenario finish *******************
    ${result}    ${syslog_path}    Run Keyword And Ignore Error  gnb_log.Stop Collecting gNB Btslog  log_dir=${res_path}
    Set Suite Variable    ${syslog_path}
    Run Keyword And Ignore Error  Collect IMS File  ${res_path}/IMS2/
    Run Keyword And Ignore Error  Verify Average Throughput With Deviation   dt_name=dt_${alias_1}   tput=${tput_DL}
    ...                                  deviation=${deviation}

