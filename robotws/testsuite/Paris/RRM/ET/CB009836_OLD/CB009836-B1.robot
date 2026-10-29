*** Settings ***
# https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=5GFTPARIS&title=ET+Coding+Rules
# --------------------------------------------------------------------------------------------------------------------------------------------------
Documentation     [SUITE PURPOSE]
...                  == CB09836-B1 Test suite ==
...                  - Requested topology : CLOUD_5G_O_E_AP_LOO_8DL8UL and VARIANT_SANSA_FS_ECPRI_CMWV_TDD
...                  == Prerequisite ==
...                  - cellBwpList used for BW 15MHz 9836 On
...                    - cellBwpId: '0'
...                      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-7'     initial BWP - 15MHZ, BWP#0
...                    - cellBwpId: '1'
...                      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-77'    default dedicated BWP - 15MHZ, BWP#1
...                  - cellBwpList used for BW 10MHz 9836 On
...                    - cellBwpId: '0'
...                      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-8'     initial BWP - 10MHZ, BWP#0
...                    - cellBwpId: '1'
...                      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-88'    default dedicated BWP - 10MHZ, BWP#1
...                  - cellBwpList used for BW 15MHz 9836 Off
...                    - cellBwpId: '0'
...                      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-700'     initial BWP - 15MHZ, BWP#0
...                    - cellBwpId: '1'
...                      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-701'    default dedicated BWP - 15MHZ, BWP#1
...                  - cellBwpList used for BW 10MHz 9836 Off
...                    - cellBwpId: '0'
...                      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-800'     initial BWP - 10MHZ, BWP#0
...                    - cellBwpId: '1'
...                      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-801'    default dedicated BWP - 10MHZ, BWP#1
...                  == Scope ==
...                  - call setup - nGBR traffic several Ues
...                  - Check Cell Specific CSI-RS Enhancement in CB009836
...                  - IWK with CB008278 : support of 10MHz TDD
...                  - IWK with CB009355 : support of 15MHz TDD
...                  == Info ==
...                  - Test Case Scenario author   : christophe.samson@nokia.com
...                  - Creation Date               : 04-19-2024
...                  - Modified Date               : 06-10-2024
...                  - Last Modified by            : christophe.samson@nokia.com
...                  - Version   Date                      Author                                   Notes
...                  - 0.1       06-21-2024[mm-dd-yyyy]    christophe.samson@nokia.com              Test Creation
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

${relative_json_path}                                               ${CURDIR}/CB009836_B_data_tests.json

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

[1]CB009836_B_01_USR1_IWK_CB010513_I_10MHz_FS_1116_3ms_Canada
    [Documentation]
    ...     Conditions:     it is based on the configuration ${C_Cell}
    ...     Actions:        based on dlTdSchedSubcellData,numAllocCellPrbDl , check prbstreamcapa as expected
    ...                      for subpool1 and subpoll2
    ...     Checks:
    ...     Verdict:        calls for multi ues and PRB pooling are passed
    [Tags]  CLOUD_5G_O_E_AP_LOO_8DL8UL     VARIANT_SANSA_FS_ECPRI_CMWV_TDD   10MHZ    AEHC   CB009836-B    CB009836-B1    CRT
    Set To Dictionary     ${C_Cell}    totalNbOfUe       6
    # CS : 09/01/25 : FS Canada is not supported anymore (see CNI-143799 - Phase out of CNI-110347) => change to FS TddLte_3
    # Set test Variable     ${LuaFileToUsed_path}          ${LuaFileToUsed_path_TddLte_3_Canada_ASOE_TC_B1_2}
    Set test Variable     ${LuaFileToUsed_path}          ${LuaFileToUsed_path_TddLte_3_ASOE_TC_B1_2}
    TC CB009836 4 Cells   ${C_Cell}    ${dictParam}    ${Vendor_IWK_CB8940-L_CB7113}    ${dict_settings_all_ues}    nrCell=4
    ...       Kw TestLine Preparation=TL_Preparation_CB009836_4Cells_CFG1_8DL_8UL
    ...       kw Set RAD Params=Set RAD Params Of 9836 ASOE
    ...       kw NIDD Set=Set CB009836 NIDD PARAMETERS with ulMUMIMO
    ...       kw NIDD Check=Check CB009836 NIDD PARAMETERS with ulMUMIMO
    # ...       kw Active Config=${EMPTY}
    # ...       kw Active Config=23_CB009836_B01_BW_10_4ssb_100_100_100_4ssb_5GC001116_3_Canada_ASOE
    ...       kw Active Config=23_CB009836_B01_BW_10_4ssb_100_100_100_4ssb_5GC001116_3_ASOE
    ...       kw Specific Set TestMode After Attach=Set UE CSI profile And SRS Beam Position for muMIMO UE pairing for all ${C_Cell.totalNbOfUe} Ues
    ...       NIDD_9836_PARAMS=${NIDD_9836_UL_MIMO_w_CB008940_CB007113_PARAMS_ASOE}
    ...       NIDD_9836_TEST_PARAMS=${EMPTY}
    ...       kw Specific Check=Check Trs and CsiRs Periodicity From l1l2 pcap
    ...       kw Specific Check Tti=Check Cell1 has ZAB privilege From TtiTraces
    ...       Json test configuration=${relative_json_path}
    ...       FrameStructure=5GC001116_3_Canada
    ...       skip=${True}

*** Keywords ***
# robocop: off=unused-argument
# robocop: off=possible-variable-overwriting

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

[1]CB009836_B1_1_IWK_with_CB0010513_Baseband_pooling_Extensions_for_FR1_TDD_15MHz_CB009355_ASOE
    [Documentation]
    ...     Conditions:     it is based on the configuration ${C_Cell}
    ...     Actions:        based on dlTdSchedSubcellData,numAllocCellPrbDl , check prbstreamcapa as expected
    ...                      for subpool1 and subpoll2
    ...     Checks:
    ...     Verdict:        calls for multi ues and PRB pooling are passed
    [Tags]  CLOUD_5G_O_E_AP_LOO_8DL8UL     VARIANT_SANSA_FS_ECPRI_CMWV_TDD   15MHZ    AEHC   CB009836-B    CB009836-B1-1
    Set To Dictionary     ${C_Cell}    totalNbOfUe       6
    Set test Variable     ${LuaFileToUsed_path}          ${LuaFileToUsed_path_TddLte_3_Canada_ASOE_TC_B1}
    TC CB009836 4 Cells   ${C_Cell}    ${dictParam}    ${Vendor_IWK_CB8940-L_CB7113}    ${dict_settings_all_ues}    nrCell=4
    ...       Kw TestLine Preparation=TL_Preparation_CB009836_4Cells_CFG1_8DL_8UL
    ...       kw Set RAD Params=Set RAD Params Of 9836 ASOE
    ...       kw NIDD Set=Set CB009836 NIDD PARAMETERS with ulMUMIMO
    ...       kw NIDD Check=Check CB009836 NIDD PARAMETERS with ulMUMIMO
    ...       kw Active Config=22_CB009836_B01_BW_15_4ssb_100_100_100_4ssb_5GC001116_3_Canada_ASOE
    ...       kw Specific Set TestMode After Attach=Set UE CSI profile And SRS Beam Position for muMIMO UE pairing for all ${C_Cell.totalNbOfUe} Ues
    ...       NIDD_9836_PARAMS=${NIDD_9836_UL_MIMO_w_CB008940_CB007113_PARAMS_ASOE}
    ...       NIDD_9836_TEST_PARAMS=${EMPTY}
    ...       kw Specific Check=Check Trs and CsiRs Periodicity From l1l2 pcap
    ...       Json test configuration=${relative_json_path}
    ...       FrameStructure=5GC001116_3_Canada

PRV_CB009836_B1_1_IWK_with_CB0010513_Baseband_pooling_Extensions_for_FR1_TDD_15MHz_CB009355_ASOE_9836_OFF
    [Documentation]
    ...     Conditions:     it is based on the configuration ${C_Cell}
    ...     Actions:        based on dlTdSchedSubcellData,numAllocCellPrbDl , check prbstreamcapa as expected
    ...                      for subpool1 and subpoll2
    ...     Checks:
    ...     Verdict:        calls for multi ues and PRB pooling are passed
    [Tags]  CLOUD_5G_O_E_AP_LOO_8DL8UL     VARIANT_SANSA_FS_ECPRI_CMWV_TDD   15MHZ    AEHC   CB009836-B    CB009836-B1-1
    Set To Dictionary     ${C_Cell}    totalNbOfUe       5
    Set test Variable     ${LuaFileToUsed_path}          ${LuaFileToUsed_path_TddLte_3_Canada_ASOE_TC_B1}
    TC CB009836 4 Cells   ${C_Cell}    ${dictParam}    ${Vendor_IWK_CB8940-L_CB7113}    ${dict_settings_all_ues}    nrCell=4
    ...       Kw TestLine Preparation=TL_Preparation_CB009836_4Cells_CFG1_8DL_8UL
    ...       kw Set RAD Params=Set RAD Params Of 9836 ASOE
    ...       kw NIDD Set=Set CB009836 NIDD PARAMETERS with ulMUMIMO
    ...       kw NIDD Check=Check CB009836 NIDD PARAMETERS with ulMUMIMO
    ...       kw Active Config=25_CB009836_B01_BW_15_4ssb_100_100_100_4ssb_5GC001116_3_Canada_ASOE_9836_OFF
    ...       kw Specific Set TestMode After Attach=Set UE CSI profile And SRS Beam Position for muMIMO UE pairing for all ${C_Cell.totalNbOfUe} Ues
    ...       NIDD_9836_PARAMS=${NIDD_9836_UL_MIMO_w_CB008940_CB007113_PARAMS_ASOE}
    ...       NIDD_9836_TEST_PARAMS=${EMPTY}
    ...       kw Specific Check=Check Trs and CsiRs Periodicity From l1l2 pcap
    ...       Json test configuration=${relative_json_path}
    ...       FrameStructure=5GC001116_3_Canada

[1]CB009836_B1_1_IWK_with_CB0010513_Baseband_pooling_Extensions_for_FR1_TDD_15MHz_CB009355_ASOE_Alter_sce
    [Documentation]
    ...     Conditions:     it is based on the configuration ${C_Cell}
    ...     Actions:        based on dlTdSchedSubcellData,numAllocCellPrbDl , check prbstreamcapa as expected
    ...                      for subpool1 and subpoll2
    ...     Checks:
    ...     Verdict:        calls for multi ues and PRB pooling are passed
    [Tags]  CLOUD_5G_O_E_AP_LOO_8DL8UL     VARIANT_SANSA_FS_ECPRI_CMWV_TDD   15MHZ    AEHC   CB009836-B    CB009836-B1-1
    Set To Dictionary     ${C_Cell}    totalNbOfUe       5
    Set test Variable     ${LuaFileToUsed_path}          ${LuaFileToUsed_path_TddLte_3_Canada_ASOE_TC_B1}
    TC CB009836 4 Cells   ${C_Cell}    ${dictParam}    ${Vendor_IWK_CB8940-L_CB7113}    ${dict_settings_all_ues}    nrCell=4
    ...       Kw TestLine Preparation=TL_Preparation_CB009836_4Cells_CFG1_8DL_8UL
    ...       kw Set RAD Params=Set RAD Params Of 9836 ASOE
    ...       kw NIDD Set=Set CB009836 NIDD PARAMETERS with ulMUMIMO
    ...       kw NIDD Check=Check CB009836 NIDD PARAMETERS with ulMUMIMO
    ...       kw Active Config=21_CB009836_B01_BW_15_4ssb_100_100_100_8ssb_5GC001116_3_Canada_ASOE
    ...       kw Specific Set TestMode After Attach=Set UE CSI profile And SRS Beam Position for muMIMO UE pairing for all ${C_Cell.totalNbOfUe} Ues
    ...       NIDD_9836_PARAMS=${NIDD_9836_UL_MIMO_w_CB008940_CB007113_PARAMS_ASOE}
    ...       NIDD_9836_TEST_PARAMS=${EMPTY}
    ...       kw Specific Check=Check Trs and CsiRs Periodicity From l1l2 pcap
    ...       Json test configuration=${relative_json_path}
    ...       FrameStructure=5GC001116_3_Canada
    ...       TypeCheck=CellsWithDiffSSB


PRV_CB009836_SR_B_01_USR1_IWK_CB010513_I_10MHz_FS_1116_3ms_Canada_Precheck3
    [Documentation]
    ...     Conditions:     it is based on the configuration ${C_Cell}
    ...     Actions:        based on dlTdSchedSubcellData,numAllocCellPrbDl , check prbstreamcapa as expected
    ...                      for subpool1 and subpoll2
    ...     Checks:
    ...     Verdict:        calls for multi ues and PRB pooling are passed
    [Tags]  CLOUD_5G_O_E_AP_LOO_8DL8UL     VARIANT_SANSA_FS_ECPRI_CMWV_TDD   10MHZ    AEHC   CB009836-B    CB009836-B1
    Set To Dictionary     ${C_Cell}    totalNbOfUe       6
    Set test Variable     ${LuaFileToUsed_path}          ${LuaFileToUsed_path_TddLte_3_Canada_ASOE_TC_B1_2}
    TC CB009836 4 Cells For Precheck3   ${C_Cell}    ${dictParam}    ${Vendor_IWK_CB8940-L_CB7113}    ${dict_settings_all_ues}    nrCell=4
    ...       Kw TestLine Preparation=TL_Preparation_CB009836_4Cells_CFG1_8DL_8UL
    ...       kw Set RAD Params=Set RAD Params Of 9836 ASOE For Precheck3
    ...       kw NIDD Set=Set CB009836 NIDD PARAMETERS with ulMUMIMO
    ...       kw NIDD Check=Check CB009836 NIDD PARAMETERS with ulMUMIMO
    # ...       kw Active Config=${EMPTY}
    ...       kw Active Config=23_CB009836_B01_BW_10_4ssb_100_100_100_4ssb_5GC001116_3_Canada_ASOE
    ...       kw Specific Set TestMode After Attach=Set UE CSI profile And SRS Beam Position for muMIMO UE pairing for all ${C_Cell.totalNbOfUe} Ues
    ...       NIDD_9836_PARAMS=${NIDD_9836_UL_MIMO_w_CB008940_CB007113_PARAMS_ASOE}
    ...       NIDD_9836_TEST_PARAMS=${EMPTY}
    ...       kw Specific Check=Check Trs and CsiRs Periodicity From l1l2 pcap
    ...       Json test configuration=${relative_json_path}
    ...       FrameStructure=5GC001116_3_Canada

PRV_CB009836_SR_B_01_USR1_IWK_CB010513_I_10MHz_FS_1116_3ms_Canada_Precheck3_Light
    [Documentation]
    ...     Conditions:     it is based on the configuration ${C_Cell}
    ...     Actions:        based on dlTdSchedSubcellData,numAllocCellPrbDl , check prbstreamcapa as expected
    ...                      for subpool1 and subpoll2
    ...     Checks:
    ...     Verdict:        calls for multi ues and PRB pooling are passed
    [Tags]  CLOUD_5G_O_E_AP_LOO_8DL8UL     VARIANT_SANSA_FS_ECPRI_CMWV_TDD   10MHZ    AEHC   CB009836-B    CB009836-B1
    Set To Dictionary     ${C_Cell}    totalNbOfUe       1
    Set test Variable     ${LuaFileToUsed_path}          ${LuaFileToUsed_path_TddLte_3_Canada_ASOE_TC_B1_2}
    TC CB009836 4 Cells For Precheck3 Light   ${C_Cell}    ${dictParam}    ${Vendor_IWK_CB8940-L_CB7113}    ${dict_settings_all_ues}    nrCell=4
    ...       Kw TestLine Preparation=TL_Preparation_CB009836_4Cells_CFG1_8DL_8UL
    ...       kw Set RAD Params=Set RAD Params Of 9836 ASOE For Precheck3
    ...       kw NIDD Set=Set CB009836 NIDD PARAMETERS with ulMUMIMO
    ...       kw NIDD Check=Check CB009836 NIDD PARAMETERS with ulMUMIMO
    # ...       kw Active Config=${EMPTY}
    ...       kw Active Config=23_CB009836_B01_BW_10_4ssb_100_100_100_4ssb_5GC001116_3_Canada_ASOE
    ...       kw Specific Set TestMode After Attach=Set UE CSI profile And SRS Beam Position for muMIMO UE pairing for all ${C_Cell.totalNbOfUe} Ues
    ...       NIDD_9836_PARAMS=${NIDD_9836_UL_MIMO_w_CB008940_CB007113_PARAMS_ASOE}
    ...       NIDD_9836_TEST_PARAMS=${EMPTY}
    ...       kw Specific Check=Check Trs and CsiRs Periodicity From l1l2 pcap
    ...       Json test configuration=${relative_json_path}
    ...       FrameStructure=5GC001116_3_Canada

PRV_CB009836_OFF_SR_B_01_USR1_IWK_CB010513_I_10MHz_FS_1116_3ms_Canada_Precheck3_Light
    [Documentation]
    ...     Conditions:     it is based on the configuration ${C_Cell}
    ...     Actions:        based on dlTdSchedSubcellData,numAllocCellPrbDl , check prbstreamcapa as expected
    ...                      for subpool1 and subpoll2
    ...     Checks:
    ...     Verdict:        calls for multi ues and PRB pooling are passed
    [Tags]  CLOUD_5G_O_E_AP_LOO_8DL8UL     VARIANT_SANSA_FS_ECPRI_CMWV_TDD   10MHZ    AEHC   CB009836-B    CB009836-B1
    Set To Dictionary     ${C_Cell}    totalNbOfUe       1
    Set test Variable     ${LuaFileToUsed_path}          ${LuaFileToUsed_path_TddLte_3_Canada_ASOE_TC_B1_2}
    TC CB009836 4 Cells For Precheck3 Light   ${C_Cell}    ${dictParam}    ${Vendor_IWK_CB8940-L_CB7113}    ${dict_settings_all_ues}    nrCell=4
    ...       Kw TestLine Preparation=TL_Preparation_CB009836_4Cells_CFG1_8DL_8UL
    ...       kw Set RAD Params=Set RAD Params Of 9836 ASOE For Precheck3
    ...       kw NIDD Set=Set CB009836 NIDD PARAMETERS with ulMUMIMO
    ...       kw NIDD Check=Check CB009836 NIDD PARAMETERS with ulMUMIMO
    # ...       kw Active Config=${EMPTY}
    # ...       kw Active Config=23_CB009836_B01_BW_10_4ssb_100_100_100_4ssb_5GC001116_3_Canada_ASOE
    ...       kw Active Config=24_CB009836_B01_BW_10_4ssb_100_100_100_4ssb_5GC001116_3_Canada_ASOE_2Symb_PDCCH
    ...       kw Specific Set TestMode After Attach=Set UE CSI profile And SRS Beam Position for muMIMO UE pairing for all ${C_Cell.totalNbOfUe} Ues
    ...       NIDD_9836_PARAMS=${NIDD_9836_UL_MIMO_w_CB008940_CB007113_PARAMS_ASOE}
    ...       NIDD_9836_TEST_PARAMS=${EMPTY}
    ...       kw Specific Check=Check Trs and CsiRs Periodicity From l1l2 pcap
    ...       Json test configuration=${relative_json_path}
    ...       FrameStructure=5GC001116_3_Canada

PRV_CB009836_SR_B_01_USR1_IWK_CB010513_I_10MHz_FS_1116_3ms_Canada_ASOE_9836_OFF
    [Documentation]
    ...     Conditions:     it is based on the configuration ${C_Cell}
    ...     Actions:        based on dlTdSchedSubcellData,numAllocCellPrbDl , check prbstreamcapa as expected
    ...                      for subpool1 and subpoll2
    ...     Checks:
    ...     Verdict:        calls for multi ues and PRB pooling are passed
    [Tags]  CLOUD_5G_O_E_AP_LOO_8DL8UL     VARIANT_SANSA_FS_ECPRI_CMWV_TDD   10MHZ    AEHC   CB009836-B    CB009836-B1
    Set To Dictionary     ${C_Cell}    totalNbOfUe       6
    Set test Variable     ${LuaFileToUsed_path}          ${LuaFileToUsed_path_TddLte_3_Canada_ASOE_TC_B1_2}
    TC CB009836 4 Cells   ${C_Cell}    ${dictParam}    ${Vendor_IWK_CB8940-L_CB7113}    ${dict_settings_all_ues}    nrCell=4
    ...       Kw TestLine Preparation=TL_Preparation_CB009836_4Cells_CFG1_8DL_8UL
    ...       kw Set RAD Params=Set RAD Params Of 9836 ASOE
    ...       kw NIDD Set=Set CB009836 NIDD PARAMETERS with ulMUMIMO
    ...       kw NIDD Check=Check CB009836 NIDD PARAMETERS with ulMUMIMO
    ...       kw Active Config=24_CB009836_B01_BW_10_4ssb_100_100_100_4ssb_5GC001116_3_Canada_ASOE_2Symb_PDCCH
    ...       kw Specific Set TestMode After Attach=Set UE CSI profile And SRS Beam Position for muMIMO UE pairing for all ${C_Cell.totalNbOfUe} Ues
    ...       NIDD_9836_PARAMS=${NIDD_9836_UL_MIMO_w_CB008940_CB007113_PARAMS_ASOE}
    ...       NIDD_9836_TEST_PARAMS=${EMPTY}
    ...       kw Specific Check=Check Trs and CsiRs Periodicity From l1l2 pcap
    ...       Json test configuration=${relative_json_path}
    ...       FrameStructure=5GC001116_3_Canada
