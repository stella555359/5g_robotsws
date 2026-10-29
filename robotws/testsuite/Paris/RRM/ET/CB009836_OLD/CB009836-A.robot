*** Settings ***
# https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=5GFTPARIS&title=ET+Coding+Rules
# --------------------------------------------------------------------------------------------------------------------------------------------------
Documentation     [SUITE PURPOSE]
...                  == CB09836-A Test suite ==
...                  - Requested topology : CLOUD_5G_O_E_AP_LOO_8DL8UL   VARIANT_SANSA_FS_ECPRI_CMWV_TDD
...                  == Prerequisite ==
...                  - gNB configured with 4 Cells & RU detected. Physical cells id are 50, 51, etc.
...                  - CB008941 (UL Fragmentaion) is activated
...                  - cellBwpList used for BW 100MHz
...                    - cellBwpId: '0'
...                      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-2'     initial BWP - 100HZ, BWP#0
...                    - cellBwpId: '1'
...                      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-22'    default dedicated BWP - 100HZ, BWP#1
...                  - cellBwpList used for BW 60MHz
...                    - cellBwpId: '0'
...                      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-5'     initial BWP - 60MHZ, BWP#0
...                    - cellBwpId: '1'
...                      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-55'    default dedicated BWP - 60MHZ, BWP#1
...                  - cellBwpList used for BW 80MHz
...                    - cellBwpId: '0'
...                      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-4'     initial BWP - 80MHZ, BWP#0
...                    - cellBwpId: '1'
...                      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-44'    default dedicated BWP - 80MHZ, BWP#1
...                  == Scope ==
...                  - call setup - nGBR traffic several Ues
...                  - Check Cell Specific CSI-RS Enhancement in CB009836
...                  == Info ==
...                  - Test Case Scenario author   : christophe.samson@nokia.com
...                  - Creation Date               : 03-01-2024
...                  - Modified Date               : 03-01-2024
...                  - Last Modified by            : christophe.samson@nokia.com
...                  - Version   Date                      Author                                   Notes
...                  - 0.1       06-19-2024[mm-dd-yyyy]    christophe.samson@nokia.com              Test Creation
...                   -0.2       09-02-2025[mm-dd-yyyy]    christophe.samson@nokia.com              FS Canada is not supported anymore
...                                                                             (see CNI-143799 - Phase out of CNI-110347) => change to FS TddLte_3
# --------------------------------------------------------------------------------------------------------------------------------------------------

# Libraries
Library      taf.transport.ssh                                   WITH NAME          ssh
Library      taf.sbts.oam.coam.admin.interface
Library      taf.sbts.oam.coam.admin                             WITH NAME          coam
Library      taf.collectors.tcpdump                              WITH NAME          tcpdump
Library      taf.collectors.core                                 WITH NAME          core
Library      ute_wtssim
Library      taf.config.wts                                      WITH NAME          wts

# Libraries SWENG
Library      ../../../resources/SWENG/python/StringTool.py

# Libraries CB009836
Library      resources/python/Constants-CB009836.py              WITH NAME          MyConstants
Library      resources/python/tools.py                           WITH NAME          nps_9836_tools

# Resources taf
Resource      taf/ul/ettf/main.robot

# Resources CB009836
Resource     ./resources/robot/apUDPlog.robot
Resource     ./resources/robot/CB009836-Common-Keywords.robot
Resource     ./resources/robot/CB009836-Test-Suite-Setup-Resources.robot
Resource     ./resources/robot/CB009836-Keywords.robot
Resource     ./resources/robot/CB009836-TL-Preparation-Keywords.robot
Resource     ./resources/robot/CB009836-Test-Template-Keywords.robot
Resource     ./resources/robot/CB009836-A-Config-tests-Keywords.robot

# Variables taf
Variables     taf/ul/ettf/logging/policies.py
Variables     taf/ul/ettf/log_analysis/policies.py

# Variables CB009836
Variables    ./resources/python/Constants-CB009836.py
Variables    ./resources/python/logging_policy.py

# Suites and Tests setup and teardown
Suite Setup       Suite Setup CB009836-Common      test_dictParam=${dictParam}
Suite Teardown    Suite Teardown CB009836-Common
Test Setup        Test Setup for CB009836-Common
Test Teardown     Test Teardown for CB009836-Common

*** Variables ***

# from /home/ute/.pyenv/versions/3.9.14/lib/python3.9/site-packages/taf/ul/ettf/logging/policies.py
# NO_LOGS_POLICY
# LOGS_POLICY - with snapshot
# NO_TRAFFIC_LOGS_POLICY
# NO_TRAFFIC_NO_SNAPSHOT_NO_INFOMODEL_LOGS_POLICY
# LOGS_POLICY_CRT
# ${LOGGING_POLICY} is initialized by "Init Variables" Kw
${LOGGING_POLICY}=           NO_TRAFFIC_NO_SNAPSHOT_NO_INFOMODEL_LOGS_POLICY     # replace with LOGS_POLICY_CRT for CRT !!!
# ${LOGS_COMPRESSION} is initialized by "Init Variables" Kw
# ${LOGS_COMPRESSION}=         ${False}

${relative_json_path}                                               ${CURDIR}/CB009836_A_data_tests.json

${TestSharkTool}                                                    MC_SHARK

&{dictParam}                                                        w_Basic_Call_to_Setup_Wtsemu=${True}
...                                                                 w_enable_sherpa_Traces=False
...                                                                 w_check_9890_using_sherpa=False
...                                                                 w_GetTtiTrace=True
...                                                                 w_convert_TtiPcap_to_excelCsv=False
...                                                                 w_GetL1L2Bip=False
...                                                                 w_generic_capture=True
...                                                                 w_CaptureCORE=${False}
...                                                                 w_CaptureL1L2=${False}
...                                                                 w_CaptureCPRT=${True}
...                                                                 w_ue_detach=False
...                                                                 w_GetBtsLog=True
...                                                                 w_DISPLAY_ue_stats_nr_15min=False

# capture Time setting
&{CAPTURE}                                                          GetTtiTraceTime=1s
...                                                                 Getl1l2TraceTime=1s
...                                                                 GetSherpaTraceTime=1s
...                                                                 GetTtiTraceNumOfEvent=5000

&{dictExpectedValues}                                               expected_avg_total_prbs_spool1=546
...                                                                 expected_avg_total_prbs_spool2=78
...                                                                 expected_avg_total_prbsstream_spool1=2100
...                                                                 expected_avg_total_prbsstream_spool2=300

# tests settings
&{C_Cell}                                                           dir=DL
...                                                                 totalNbOfUe=6                 # total number of ue's to configure
...                                                                 totalNbOfCell=3               # total number of cell used for ue's dispatching
...                                                                 targetGnb=2                   # gnb target id
...                                                                 captureDuration=0             # capture duration during traffic starting phase
...                                                                 duration=3                    # traffic duration during declaration phase
...                                                                 deviation=10                  # allowed deviation for throughput

# ue's settings
&{dict_settings_ue_1}                                               originalCell=1                # original cell for call establishment
...                                                                 DL_throughput=150             # throughput nonGBR for ue or ${NO_THROUGHPUT}
...                                                                 DL_throughput_GBR=10          # throughput GBR is not supported
...                                                                 UL_throughput=0               # UL throughput nonGBR for ue or ${NO_THROUGHPUT}
...                                                                 protocol=udp
...                                                                 packet_size=1350
...                                                                 cqi=15
...                                                                 ri=3
...                                                                 ue_capa=None

&{dict_settings_ue_2}                                               originalCell=2
...                                                                 DL_throughput=100
...                                                                 DL_throughput_GBR=10
...                                                                 UL_throughput=0               # UL throughput nonGBR for ue or ${NO_THROUGHPUT}
...                                                                 protocol=udp
...                                                                 packet_size=1350
...                                                                 cqi=15
...                                                                 ri=3
...                                                                 ue_capa=None

&{dict_settings_ue_3}                                               originalCell=3
...                                                                 DL_throughput=100
...                                                                 DL_throughput_GBR=10
...                                                                 UL_throughput=0               # UL throughput nonGBR for ue or ${NO_THROUGHPUT}
...                                                                 protocol=udp
...                                                                 packet_size=1350
...                                                                 cqi=15
...                                                                 ri=3
...                                                                 ue_capa=None

&{dict_settings_ue_4}                                               originalCell=1                # original cell for call establishment
...                                                                 DL_throughput=150             # throughput nonGBR for ue or ${NO_THROUGHPUT}
...                                                                 DL_throughput_GBR=10          # throughput GBR is not supported
...                                                                 UL_throughput=0               # UL throughput nonGBR for ue or ${NO_THROUGHPUT}
...                                                                 protocol=udp
...                                                                 packet_size=1350
...                                                                 cqi=15
...                                                                 ri=3
...                                                                 ue_capa=None

&{dict_settings_ue_5}                                               originalCell=2
...                                                                 DL_throughput=100
...                                                                 DL_throughput_GBR=10
...                                                                 UL_throughput=0               # UL throughput nonGBR for ue or ${NO_THROUGHPUT}
...                                                                 protocol=udp
...                                                                 packet_size=1350
...                                                                 cqi=15
...                                                                 ri=3
...                                                                 ue_capa=None

&{dict_settings_ue_6}                                               originalCell=3
...                                                                 DL_throughput=100
...                                                                 DL_throughput_GBR=10
...                                                                 UL_throughput=0               # UL throughput nonGBR for ue or ${NO_THROUGHPUT}
...                                                                 protocol=udp
...                                                                 packet_size=1350
...                                                                 cqi=15
...                                                                 ri=3
...                                                                 ue_capa=None

&{dict_settings_ue_default}                                         originalCell=1
...                                                                 DL_throughput=900
...                                                                 DL_throughput_GBR=0           # throughput GBR is not supported
...                                                                 UL_throughput=0
...                                                                 protocol=udp
...                                                                 packet_size=1350
...                                                                 cqi=15
...                                                                 ri=3
...                                                                 ue_capa=None


@{dict_settings_3_ues}                                              ${dict_settings_ue_1}
...                                                                 ${dict_settings_ue_2}
...                                                                 ${dict_settings_ue_3}

@{dict_settings_all_ues}                                            ${dict_settings_ue_1}
...                                                                 ${dict_settings_ue_2}
...                                                                 ${dict_settings_ue_3}
...                                                                 ${dict_settings_ue_4}
...                                                                 ${dict_settings_ue_5}
...                                                                 ${dict_settings_ue_6}

&{dict_settings_cell_1}                                             Cell=1
...                                                                 nbrOfBlankedPRBsLowEdgeDL=0
...                                                                 nbrOfBlankedPRBsLowEdgeUL=0
...                                                                 nbrOfBlankedPRBsHighEdgeDL=0
...                                                                 nbrOfBlankedPRBsHighEdgeUL=0

&{dict_settings_cell_2}                                             Cell=2
...                                                                 nbrOfBlankedPRBsLowEdgeDL=0
...                                                                 nbrOfBlankedPRBsLowEdgeUL=0
...                                                                 nbrOfBlankedPRBsHighEdgeDL=0
...                                                                 nbrOfBlankedPRBsHighEdgeUL=0

&{dict_settings_cell_3}                                             Cell=3
...                                                                 nbrOfBlankedPRBsLowEdgeDL=0
...                                                                 nbrOfBlankedPRBsLowEdgeUL=0
...                                                                 nbrOfBlankedPRBsHighEdgeDL=0
...                                                                 nbrOfBlankedPRBsHighEdgeUL=0

&{dict_settings_cell_4}                                             Cell=4
...                                                                 nbrOfBlankedPRBsLowEdgeDL=0
...                                                                 nbrOfBlankedPRBsLowEdgeUL=0
...                                                                 nbrOfBlankedPRBsHighEdgeDL=0
...                                                                 nbrOfBlankedPRBsHighEdgeUL=0

&{dict_settings_cell_5}                                             Cell=5
...                                                                 nbrOfBlankedPRBsLowEdgeDL=0
...                                                                 nbrOfBlankedPRBsLowEdgeUL=0
...                                                                 nbrOfBlankedPRBsHighEdgeDL=0
...                                                                 nbrOfBlankedPRBsHighEdgeUL=0

&{dict_settings_cell_6}                                             Cell=6
...                                                                 nbrOfBlankedPRBsLowEdgeDL=0
...                                                                 nbrOfBlankedPRBsLowEdgeUL=0
...                                                                 nbrOfBlankedPRBsHighEdgeDL=0
...                                                                 nbrOfBlankedPRBsHighEdgeUL=0

@{dict_settings_all_cells}                                          ${dict_settings_cell_1}
...                                                                 ${dict_settings_cell_2}
...                                                                 ${dict_settings_cell_3}
...                                                                 ${dict_settings_cell_4}
...                                                                 ${dict_settings_cell_5}
...                                                                 ${dict_settings_cell_6}

# vendor's setting

# BB pool mode : Load-metric based
# bbL1SpPrbInitCapacity settings :
#	        <item>
#	          <p name="bbHwVariant">ABIO</p>
#	          <p name="csSize">48</p>
#	          <p name="direction">DL</p>
#	          <p name="l1PoolType">NR_L1_Loki_TDD_FR1_eCPRI_IQF_Asymm</p>
#	          <p name="maxNumLayerPrbL1Sp">1200</p>
#	          <p name="maxNumStreamPrbL1Sp">1200</p>
#	          <p name="maxNumWbStreamPrbL1Sp">600</p>
#	        </item>

&{Vendor_IWK_CB8940-L_CB7113}                                       bbHwVariant=ABIO
...                                                                 maxNumLayerPrbL1Sp=1200
...                                                                 maxNumStreamPrbL1Sp=1200
...                                                                 maxNumWbStreamPrbL1Sp=600
...                                                                 maxNumScheUePdschL1Pool=None
...                                                                 maxNumScheUePdschL1Sp=None
...                                                                 maxNumDlSubcellL1Pool=6
...                                                                 maxNumDlSubcellL1Sp=4
...                                                                 maxNumUlSubcellL1Pool=6
...                                                                 maxNumUlSubcellL1Sp=4
...                                                                 ul_maxNumLayerPrbL1Sp_csSize32=410
...                                                                 ul_maxNumStreamPrbL1Sp_csSize32=820
...                                                                 ul_maxNumWbStreamPrbL1Sp_csSize32=None
...                                                                 ul_maxNumLayerPrbL1Sp_csSize48=None
...                                                                 ul_maxNumStreamPrbL1Sp_csSize48=None
...                                                                 ul_maxNumWbStreamPrbL1Sp_csSize48=None
...                                                                 ul_maxNumLayerPrbL1Sp_csSize64=820
...                                                                 ul_maxNumStreamPrbL1Sp_csSize64=1640
...                                                                 ul_maxNumWbStreamPrbL1Sp_csSize64=None

*** Test Cases ***
### SA

[1]CB009836_A_05_tdLTE_1116_3ms_Canada_SANSA_Mixed_BW_and_CSIRS_ASOE_SSB_8
    [Documentation]
    ...     Conditions:     it is based on the configuration ${C_Cell}
    ...     Actions:        based on dlTdSchedSubcellData,numAllocCellPrbDl , check prbstreamcapa as expected
    ...                      for subpool1 and subpoll2
    ...     Checks:
    ...     Verdict:        calls for multi ues and PRB pooling are passed
    [Tags]  CLOUD_5G_O_E_AP_LOO_8DL8UL     VARIANT_SANSA_FS_ECPRI_CMWV_TDD   CB009836-A    CB009836-A-5    CRT
    ...      CLOUD_5G_O_E_AP_LOO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD
    Set To Dictionary       ${C_Cell}    totalNbOfUe       4
    IF  '${TOPOLOGY_LABEL}'=='CLOUD_5G_O_E_AP_LOO' and '${TOPOLOGY_VARIANT}'=='SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD'
        Set test Variable       ${LuaFileToUsed_path}          ${LuaFileToUsed_path_TddLte_3_Canada_ASOE_AP_LOO}
    ELSE
        # CS : 09/01/25 : FS Canada is not supported anymore (see CNI-143799 - Phase out of CNI-110347) => change to FS TddLte_3
        # Set test Variable       ${LuaFileToUsed_path}          ${LuaFileToUsed_path_TddLte_3_Canada_ASOE}
        Set test Variable       ${LuaFileToUsed_path}          ${LuaFileToUsed_path_TddLte_3_ASOE}
    END
    TC CB009836 4 Cells   ${C_Cell}    ${dictParam}    ${Vendor_IWK_CB8940-L_CB7113}    ${dict_settings_all_ues}    nrCell=4
    ...       Kw TestLine Preparation=TL_Preparation_CB009836_4Cells_CFG1_8DL_8UL
    ...       kw Set RAD Params=Set RAD Params Of 9836 ASOE
    ...       kw NIDD Set=Set CB009836 NIDD PARAMETERS with ulMUMIMO
    ...       kw NIDD Check=Check CB009836 NIDD PARAMETERS with ulMUMIMO
    # ...       kw Active Config=${EMPTY}
    # ...       kw Active Config=10_CB009836_A01_01_BW_100_80_60_100_5GC001116_3_Canada_8ssb_mix_csiReportPeriodicity_ASOE
    ...       kw Active Config=10_CB009836_A01_01_BW_100_80_60_100_5GC001116_3_8ssb_mix_csiReportPeriodicity_ASOE
    ...       kw Specific Set TestMode After Attach=Set UE CSI profile And SRS Beam Position for muMIMO UE pairing for all ${C_Cell.totalNbOfUe} Ues
    ...       NIDD_9836_PARAMS=${NIDD_9836_UL_MIMO_w_CB008940_CB007113_PARAMS_ASOE}
    ...       NIDD_9836_TEST_PARAMS=${EMPTY}
    ...       kw Specific Check=Check Trs and CsiRs Periodicity From l1l2 pcap
    ...       Json test configuration=${relative_json_path}
    ...       FrameStructure=5GC001116_3_Canada

[1]CB009836_A_11_ASOE_Robustness
    [Documentation]
    ...     Conditions:     it is based on the configuration ${C_Cell}
    ...     Actions:        based on dlTdSchedSubcellData,numAllocCellPrbDl , check prbstreamcapa as expected
    ...                      for subpool1 and subpoll2
    ...     Checks:
    ...     Verdict:        calls for multi ues and PRB pooling are passed
    [Tags]  CLOUD_5G_O_E_AP_LOO_8DL8UL     VARIANT_SANSA_FS_ECPRI_CMWV_TDD   CB009836-A    CB009836-A-11    Robustness    CRT
    [Timeout]    5 hours
    set test variable       ${GNB_PLATFORM_TYPE}    ASOE
    ${status_of_execution}    Create List
    ${execution_failed}       Create List
    set test variable     ${status_of_execution}
    set test variable     ${execution_failed}
    set test variable     ${EXCLUDE_LOGS_IF_FAIL}    1
    set test variable     ${COLLECT_LOGS}            0
    OperatingSystem.Run     command=ssh-keygen -f "/home/ute/.ssh/known_hosts" -R "10.0.1.2"
    # test setup, CellSetup and checking using config 11_CB009836_A01_01_BW_100_80_60_100_5GC001116_3_Canada_6ssb_320sl_ASOE
    Kw Test Setup Robustness
    # config list to test
    # set test variable   @{config}   10_CB009836_A01_01_BW_100_80_60_100_5GC001116_3_Canada_8ssb_mix_csiReportPeriodicity_ASOE
    # ...                             09_CB009836_A01_01_BW_100_80_60_100_5GC001116_3_Canada_4ssb_80sl_ASOE
    # ...                             11_CB009836_A01_01_BW_100_80_60_100_5GC001116_3_Canada_6ssb_320sl_ASOE
    # ...                             10_CB009836_A01_01_BW_100_80_60_100_5GC001116_3_Canada_8ssb_mix_csiReportPeriodicity_ASOE
    # ...                             09_CB009836_A01_01_BW_100_80_60_100_5GC001116_3_Canada_4ssb_80sl_ASOE
    # ...                             11_CB009836_A01_01_BW_100_80_60_100_5GC001116_3_Canada_6ssb_320sl_ASOE
    # ...                             10_CB009836_A01_01_BW_100_80_60_100_5GC001116_3_Canada_8ssb_mix_csiReportPeriodicity_ASOE
    # ...                             09_CB009836_A01_01_BW_100_80_60_100_5GC001116_3_Canada_4ssb_80sl_ASOE
    # ...                             11_CB009836_A01_01_BW_100_80_60_100_5GC001116_3_Canada_6ssb_320sl_ASOE
    set test variable   @{config}   10_CB009836_A01_01_BW_100_80_60_100_5GC001116_3_8ssb_mix_csiReportPeriodicity_ASOE
    ...                             09_CB009836_A01_01_BW_100_80_60_100_5GC001116_3_4ssb_80sl_ASOE
    ...                             11_CB009836_A01_01_BW_100_80_60_100_5GC001116_3_6ssb_320sl_ASOE
    ${ALL_ROBUSTNESS_RUN_TIMES}=  Get length   ${config}
    dated log      Nb Of max defined ROBUSTNESS_RUN_TIMES is ${ALL_ROBUSTNESS_RUN_TIMES}
    # ${NB_ROBUSTNESS_RUN_TIMES} is a global variable defined in Kw "Init Variables",
    #  can be forced with -v robot option (-v NB_ROBUSTNESS_RUN_TIMES:5)
    ${ROBUSTNESS_RUN_TIMES}=  Set Variable If   ${NB_ROBUSTNESS_RUN_TIMES} <= ${ALL_ROBUSTNESS_RUN_TIMES}    ${NB_ROBUSTNESS_RUN_TIMES}
    ...                                                                                                      ${2}
    dated log      requested ROBUSTNESS_RUN_TIMES is ${ROBUSTNESS_RUN_TIMES}
    FOR     ${i}      IN RANGE     ${ROBUSTNESS_RUN_TIMES}
        Log to console    =================================== RUN TEST ===================================
        ${nb_run}=    Evaluate     ${i} + ${1}
        Log to console      --------------> RUN i : ${nb_run}
        Run Keyword and continue on failure     Kw Run Robustness    index_run=${i}
        Append To File      ${resultFile}     \nROBUSTNESS_RUN${nb_run} ---> END\n
        Log to console    =================================== End Of RUN TEST ===================================
    END
    Run keyword and continue on failure    Check if one of executions fails    ${status_of_execution}
    BuiltIn.log    ${status_of_execution}    level=INFO
    ${number_fail}    count values in list    ${execution_failed}    Failed
    ${rob_status}    Run keyword and return status    Should be empty    ${execution_failed}
    # +1 to take into account also the result of Kw Test Setup Robustness
    log to console    Passed iteration: ${${ROBUSTNESS_RUN_TIMES}-${number_fail}+${1}}/${${ROBUSTNESS_RUN_TIMES}+${1}}
    ${levellog}=     Set Variable If     ${rob_status}      INFO    ERROR
    BuiltIn.log    Passed iteration: ${${ROBUSTNESS_RUN_TIMES}-${number_fail}+${1}}/${${ROBUSTNESS_RUN_TIMES}+${1}}    level=${levellog}
    IF                  not ${rob_status}
                            log to console    Failed iteration: ${number_fail}/${${ROBUSTNESS_RUN_TIMES}+${1}}    AND
                            Fail    ${execution_failed}
    END
    Produce Scout Data
    [teardown]    Run Keywords    CB009836-Keywords.Get Gnb Snapshot if TestCase Failed
    ...             AND           CB009836-Keywords.Get Sos Report if TestCase Failed


*** Keywords ***
# robocop: off=unused-argument
# robocop: off=possible-variable-overwriting

unitary_test
    # [setup]    Run Keywords      Create log path Folder
    # ...         AND              Create Test Suite Folder
    # ...         AND              set Suite Variable    ${testCaseDir}    None
    # ...         AND              Get testcase log directory
    # ...         AND              Prepare Test Name
    # IMPORTANT: do not forget to comment out the "*** Keywords ***" line
    Extract l2::ps::cell::CellSetupReq_t and CellSetupResp_t from Syslog    NbrCells=4    sysLogsDir=/home/ute/csamson/TRACES

Kw Test Setup Robustness
    [documentation]    to complete...
    # to stop and restart UDP AP traces started during test suite setup
    robot_extension.Run Keyword And Warn On Failure    apUDPlog.Stop Capture Iphy Udplog
    robot_extension.Run Keyword And Warn On Failure    apUDPlog.Start To Capture Iphy Udplog   tag=startup   target_dir=${testCaseDir}
    Prepare Logs Directory Path      subdir=ROBUSTNESS_TESTSETUP
    set test variable   ${test_status}    ${False}
    Set To Dictionary   ${C_Cell}    totalNbOfUe       4
    # CS : 09/02/25 : FS Canada is not supported anymore (see CNI-143799 - Phase out of CNI-110347) => change to FS TddLte_3
    Set test Variable   ${LuaFileToUsed_path}          ${LuaFileToUsed_path_TddLte_3_ASOE}
    TC CB009836 4 Cells Robustness Test Setup  ${C_Cell}    ${dictParam}    ${Vendor_IWK_CB8940-L_CB7113}    ${dict_settings_all_ues}    nrCell=4
    ...     kw Set RAD Params=Set RAD Params Of 9836 ASOE
    ...     kw NIDD Set=Set CB009836 NIDD PARAMETERS with ulMUMIMO
    ...     kw NIDD Check=Check CB009836 NIDD PARAMETERS with ulMUMIMO
    ...     kw Active Config=11_CB009836_A01_01_BW_100_80_60_100_5GC001116_3_6ssb_320sl_ASOE
    ...     NIDD_9836_PARAMS=${NIDD_9836_UL_MIMO_w_CB008940_CB007113_PARAMS_ASOE}
    ...     Kw TestLine Preparation=TL_Preparation_CB009836_4Cells_CFG1_8DL_8UL
    ...     Json test configuration=${relative_json_path}
    ...     FrameStructure=5GC001116_3
    ...     Step=Robustness_Step_TestSetup
    ${test_status}=    Check if one of acceptance criteria fails    ${Test Results List}    Robustness_Step_TestSetup
    [teardown]
        Run Keyword And Ignore Error    OperatingSystem.Run    mv ${testCaseDir}/*.json ${testCaseDir}/ROBUSTNESS_TESTSETUP/
        Append To List    ${status_of_execution}    ${test_status}
        IF    not ${test_status}
                            Append To List    ${execution_failed}    Failed
        END
        Set Test Variable    ${status_of_execution}
        Set Test Variable    ${execution_failed}
        robot_extension.Run Keyword And Warn On Failure    apUDPlog.Stop Capture Iphy Udplog
        robot_extension.Run Keyword And Warn On Failure    apUDPlog.Start To Capture Iphy Udplog    target_dir=${testCaseDir}/ap_udpsyslogs
        Dev_lib.analyze_logs    tag=startup    test_status=${test_status}

Kw Run Robustness
    [Documentation]
    ...     Conditions:     it is based on the configuration ${C_Cell}
    ...     Actions:        based on dlTdSchedSubcellData,numAllocCellPrbDl , check prbstreamcapa as expected
    ...                      for subpool1 and subpoll2
    ...     Checks:
    ...     Verdict:        calls for multi ues and PRB pooling are passed
    [arguments]    ${index_run}=${0}
    ${nb_run}=    Evaluate     ${index_run} + ${1}
    Prepare Logs Directory Path      subdir=ROBUSTNESS_RUN${nb_run}
    set test variable       ${test_status}    ${False}
    Set To Dictionary       ${C_Cell}    totalNbOfUe       4
    TC CB009836 4 Cells Robustness Core   ${C_Cell}    ${dictParam}    ${Vendor_IWK_CB8940-L_CB7113}    ${dict_settings_all_ues}    nrCell=4
    # ...       kw Active Config=${EMPTY}
    ...   kw Active Config=${config}[${index_run}]
    ...   NIDD_9836_PARAMS=${NIDD_9836_UL_MIMO_w_CB008940_CB007113_PARAMS_ASOE}
    ...   kw Specific Set TestMode After Attach=Set UE CSI profile And SRS Beam Position for muMIMO UE pairing for all ${C_Cell.totalNbOfUe} Ues
    ...   kw Specific Check=Check Trs and CsiRs Periodicity From l1l2 pcap
    ...   FrameStructure=5GC001116_3_Canada
    ...   Step=ROBUSTNESS_RUN${nb_run}
    ${test_status}=    Check if one of acceptance criteria fails    ${Test Results List}    ROBUSTNESS_RUN${nb_run}
    [teardown]
        Run Keywords
        ...    Run Keyword And Ignore Error    OperatingSystem.Run    mv ${testCaseDir}/*.json ${testCaseDir}/ROBUSTNESS_RUN${nb_run}/    AND
        ...    Run Keyword And Ignore Error    OperatingSystem.Run    mv ${testCaseDir}/TRS*.csv ${testCaseDir}/ROBUSTNESS_RUN${nb_run}/    AND
        ...    Append To List    ${status_of_execution}    ${test_status}    AND
        ...    Set Test Variable    ${status_of_execution}    AND
        ...    Set Test Variable    ${execution_failed}    AND
        ...    robot_extension.Run Keyword And Warn On Failure    btslog.Stop Btslog    target_dir=${testCaseDir}/ROBUSTNESS_RUN${nb_run}    AND
        ...    Dev_lib.analyze_logs    test_status=${test_status}
        IF    not ${test_status}
                            Append To List    ${execution_failed}    Failed
        END

Check if one of executions fails
    [Arguments]    ${status_of_execution}
    FOR    ${exec}    IN    @{status_of_execution}
        should not be equal as strings    '${exec}'    'False'
    END

Check if one of acceptance criteria fails
    [Arguments]    ${Test_Results_List}    ${StepName}
    ${state}=    Set Variable    ${True}
    FOR     ${Item}    IN    @{Test_Results_List}
        # dated log     Item=${Item}
        ${Type}      Get From Dictionary     ${Item}     Type
        ${Result}    Get From Dictionary     ${Item}     Result
        ${contains}=    Run Keyword And Return Status    Should Contain    ${Type}     ${StepName}
        Continue for loop If      not ${contains}
        ${cond}=    Evaluate     ${Result} == ${False}
        ${state}=    Set Variable If     ${contains} and ${cond}     ${False}    ${True}
        Exit For Loop If    ${contains} and ${cond}
    END
    [return]    ${state}

Set CB009836 NIDD PARAMETERS with ulMUMIMO
    [Arguments]    ${list}=${NIDD_9890_B_w_CB008940_CB007113_PARAMS_ASOE}
    ${kw_setOnLine_ListParam}=  Set Variable If   '${W_OnlineChange_deltaComm}'=='1'    Set_NIDD_OnlineChange_ListParam
    ...                                                                                 Set_NIDD_modification_ListParam
    ${KwOnlineParamChange}=      Set Variable If  '${W_OnlineChange_deltaComm}'=='1'    OnlineParamChange
    ...                                                                                 Update gNB OAM List Param
    Set NIDD PARAMETERS VERSION 4     ${list}
    ...                               kw_setOnLine_ListParam=${kw_setOnLine_ListParam}
    ...                               KwOnlineParamChange=${KwOnlineParamChange}
    # improvement : COAM Get SCF Kw is more fast than OAM Get SCF File kw!!!
    # ${test_scf_file}             OAM Get SCF File            dir=${LOG_PATH}      file=SCF.xml
    ${test_scf_file}               COAM Get SCF            local_dir_path=${LOG_PATH}      file=SCF.xml      alias=coam_gnb
    Set Suite Variable           ${test_scf_file}

Set CB009836 NIDD PARAMETERS
    [Arguments]    ${list}=${NIDD_9890_B_w_CB008940_CB007113_PARAMS_ASOE}
    ${kw_setOnLine_ListParam}=  Set Variable If   '${W_OnlineChange_deltaComm}'=='1'    Set_NIDD_OnlineChange_ListParam
    ...                                                                                 Set_NIDD_modification_ListParam
    ${KwOnlineParamChange}=      Set Variable If  '${W_OnlineChange_deltaComm}'=='1'    OnlineParamChange
    ...                                                                                 Update gNB OAM List Param
    Set NIDD PARAMETERS VERSION 4     ${list}
    ...                               kw_setOnLine_ListParam=${kw_setOnLine_ListParam}
    ...                               KwOnlineParamChange=${KwOnlineParamChange}
    # improvement : COAM Get SCF Kw is more fast than OAM Get SCF File kw!!!
    # ${test_scf_file}             OAM Get SCF File            dir=${LOG_PATH}      file=SCF.xml
    ${test_scf_file}               COAM Get SCF            local_dir_path=${LOG_PATH}      file=SCF.xml      alias=coam_gnb
    Set Suite Variable           ${test_scf_file}

Set CB009836 NIDD PARAMETERS with ulMUMIMO Version3
    [Arguments]    ${list}=${NIDD_9890_B_w_CB008940_CB007113_PARAMS_ASOE}
    Set CB009836 NIDD PARAMETERS VERSION 3     ${list}
    ${test_scf_file}             OAM Get SCF File            dir=${LOG_PATH}      file=SCF.xml
    Set Suite Variable           ${test_scf_file}

Check CB009836 NIDD PARAMETERS with ulMUMIMO
   [Arguments]    ${list}=${NIDD_9890_B_w_CB008940_CB007113_PARAMS}
   Check CB009836 NIDD PARAMETERS VERSION 3     ${list}

Check CB009836 NIDD PARAMETERS
   [Arguments]    ${list}=${NIDD_9890_B_w_CB008940_CB007113_PARAMS}
   Check CB009836 NIDD PARAMETERS VERSION 3     ${list}

Set CB009836 NIDD PARAMETERS with dlMUMIMO
    [Arguments]    ${list}=${NIDD_9890_B_w_CB008940_CB007113_PARAMS_ASOE}
    ${kw_setOnLine_ListParam}=  Set Variable If   '${W_OnlineChange_deltaComm}'=='1'    Set_NIDD_OnlineChange_ListParam
    ...                                                                                 Set_NIDD_modification_ListParam
    ${KwOnlineParamChange}=      Set Variable If  '${W_OnlineChange_deltaComm}'=='1'    OnlineParamChange
    ...                                                                                 Update gNB OAM List Param
    Set NIDD PARAMETERS VERSION 4     ${list}
    ...                               kw_setOnLine_ListParam=${kw_setOnLine_ListParam}
    ...                               KwOnlineParamChange=${KwOnlineParamChange}
    ${test_scf_file}               COAM Get SCF            local_dir_path=${LOG_PATH}      file=SCF.xml      alias=coam_gnb
    Set Suite Variable           ${test_scf_file}

Set CB009836 NIDD PARAMETERS with dlMUMIMO Version3
    [Arguments]    ${list}=${NIDD_9890_w_CB008940_CB007113_PARAMS}
    Set CB009836 NIDD PARAMETERS VERSION 3     ${list}
    ${test_scf_file}             OAM Get SCF File            dir=${LOG_PATH}      file=SCF.xml
    Set Suite Variable           ${test_scf_file}

Check CB009836 NIDD PARAMETERS with dlMUMIMO
   [Arguments]    ${list}=${NIDD_9890_w_CB008940_CB007113_PARAMS}
   Check CB009836 NIDD PARAMETERS VERSION 3     ${list}

Set CB009836-C NIDD PARAMETERS
    [Arguments]    ${list}=${NIDD_9915_PARAMS_TESTS}
    ${kw_setOnLine_ListParam}=  Set Variable If   '${W_OnlineChange_deltaComm}'=='1'    Set_NIDD_OnlineChange_ListParam
    ...                                                                                 Set_NIDD_modification_ListParam
    ${KwOnlineParamChange}=      Set Variable If  '${W_OnlineChange_deltaComm}'=='1'    OnlineParamChange
    ...                                                                                 Update gNB OAM List Param
    Set NIDD PARAMETERS VERSION 4     ${list}
    ...                               kw_setOnLine_ListParam=${kw_setOnLine_ListParam}
    ...                               KwOnlineParamChange=${KwOnlineParamChange}
    # improvement : COAM Get SCF Kw is more fast than OAM Get SCF File kw!!!
    # ${test_scf_file}             OAM Get SCF File            dir=${LOG_PATH}      file=SCF.xml
    ${test_scf_file}               COAM Get SCF            local_dir_path=${LOG_PATH}      file=SCF.xml      alias=coam_gnb
    Set Suite Variable           ${test_scf_file}

Set CB009836-C NIDD PARAMETERS Version3
    [Arguments]    ${list}=${NIDD_9915_PARAMS_TESTS}
    Set CB009836 NIDD PARAMETERS VERSION 3     ${list}
    # improvement : COAM Get SCF Kw is more fast than OAM Get SCF File kw!!!
    # ${test_scf_file}             OAM Get SCF File            dir=${LOG_PATH}      file=SCF.xml
    ${test_scf_file}               COAM Get SCF            local_dir_path=${LOG_PATH}      file=SCF.xml      alias=coam_gnb
    Set Suite Variable           ${test_scf_file}

Check CB009836-C NIDD PARAMETERS
   [Arguments]    ${list}=${NIDD_9915_PARAMS_TESTS}
   Check CB009836 NIDD PARAMETERS VERSION 3     ${list}

Create log path Folder
    ${LOG_PATH}     Set Variable        ${OUTPUT_DIR}
    set Suite Variable     ${LOG_PATH}

[1]CB009836_A_05_tdLTE_1116_3ms_Canada_SANSA_Mixed_BW_and_CSIRS_ASOE_SSB_8_3_Cells
    [Documentation]
    ...     Conditions:     it is based on the configuration ${C_Cell}
    ...     Actions:        based on dlTdSchedSubcellData,numAllocCellPrbDl , check prbstreamcapa as expected
    ...                      for subpool1 and subpoll2
    ...     Checks:
    ...     Verdict:        calls for multi ues and PRB pooling are passed
    [Tags]  CLOUD_5G_O_E_AP_LOO     VARIANT_SA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_RJIO_5_2   CB009836-A    CB009836-A-5
    Set To Dictionary       ${C_Cell}    totalNbOfUe       4
    Set test Variable       ${LuaFileToUsed_path}          ${LuaFileToUsed_path_TddLte_3_Canada_ASOE}
    TC CB009836 3 Cells   ${C_Cell}    ${dictParam}    ${Vendor_IWK_CB8940-L_CB7113}    ${dict_settings_all_ues}    nrCell=3
    ...       Kw TestLine Preparation=TL_Preparation_CB009836_3Cells_CFG1_8DL_8UL
    ...       kw Set RAD Params=Set RAD Params Of 9836 ASOE
    ...       kw NIDD Set=Set CB009836 NIDD PARAMETERS with ulMUMIMO
    ...       kw NIDD Check=Check CB009836 NIDD PARAMETERS with ulMUMIMO
    # ...       kw Active Config=${EMPTY}
    ...       kw Active Config=10_CB009836_A01_01_BW_100_80_60_100_5GC001116_3_Canada_8ssb_mix_csiReportPeriodicity_ASOE_3_Cells_RJIO
    ...       kw Specific Set TestMode After Attach=Set UE CSI profile And SRS Beam Position for muMIMO UE pairing for all ${C_Cell.totalNbOfUe} Ues
    ...       NIDD_9836_PARAMS=${NIDD_9836_UL_MIMO_w_CB008940_CB007113_PARAMS_ASOE_3_CELLS}
    ...       NIDD_9836_TEST_PARAMS=${EMPTY}
    ...       kw Specific Check=Check Trs and CsiRs Periodicity From l1l2 pcap
    ...       Json test configuration=${relative_json_path}
    ...       FrameStructure=5GC001116_3_Canada_3Cells
