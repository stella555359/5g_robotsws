*** Settings ***
Documentation     [SUITE PURPOSE]  TCs and KWs of CB008662 step A
...
...               Test Case Scenario author   : yann.ah.herve@nokia.com
...               Test Case Scenario contact  : yann.ah.herve@nokia.com
...               Test Case automation author : yann.ah.herve@nokia.com
...               Test Case automation contact: yann.ah.herve@nokia.com
...               Creation Date               : 29-August-2022
...               Modified Date               :
...               Last Modified by            :
...               Modification:
...                       29-August-2022      |     Creation
...                       27-September-2022   |     Remove counter check (done inside AA_13)

Resource                         ./CB008662_keywords.robot
Resource                         ../../../resources/common/TtiTrace/ttitrace.robot
Resource                         ../../../../../resources/SWENG/robot/WtsXmlConfig.robot
Resource                         ../../../../../resources/SWENG/robot/WtsCfgConfig.robot
Library                          ../../../../../resources/SWENG/python/CoamParameter.py      WITH NAME     coam_parameter
Library                          taf.sbts.oam.coam.admin           WITH NAME   sbts_coam
Library                          ../python/CB008662_CheckTTITraceDL.py


*** Variables ***
${DL_trace_duration_A_08}             10
# 40 Mbps to use all slots but not max throughput to have a various number of PRB
# Because there are 3 retransmission systematically, throughput is divided by 4.
# Moreover MCS is set by CQI to ~22 => Max throughput if ~400 / 4 = 100 Mbps
${DL_troughput_A_08}                  40

${gnb_alias_A_08}                     gnb_under_test
${ps_bwp_delta_file_A_08}             testsuite/Paris/RRM/ET/CB008662/config/Delta_Configuration_scf_Enable_Adaptive_ReTx.json

# Disable HARQ incremental redundancy DL
${RD_DisableDlIR_A_08}                0x580001

# Defines the maximum number of NACKs received at gNB for a HARQ process,
# after which the next retransmission shall use the PRB/MCS of initial transmission
${RD_AdaptiveReTxNackCountAddr_A_08}      0x580678
${RD_AdaptiveReTxNackCountValue_A_08}     0x20

${MaxAdaptiveReTxErrorRatio_A_08}         4



*** Keywords ***

CB008662 CellSetup
    [Documentation]               Dedicated KW to add adaptive retransmission configuration
    ...                           by using a delta JSON file.
    ...                           !!! Dist names are hardcoded inside JSON file. To be improved ???

    # Enable IR which is disabled by default
    ${radp_EnableIR}                Create Dictionary    field=${RD_DisableDlIR_A_08}    value=0

    # Disable NACK count,rdAdaptiveReTxNackCount, which is enable set to 2
    ${radp_AdaptiveReTxNackCount}   Create Dictionary       field=${RD_AdaptiveReTxNackCountAddr_A_08}
    ...                                                     value=${RD_AdaptiveReTxNackCountValue_A_08}
    ${list_rad_param}               Create List          ${radp_EnableIR}    ${radp_AdaptiveReTxNackCount}
    Set Fields in swconfig DU       param_list=${list_rad_param}

    # Open connection towards cOAM
    sbts_coam.connect_to          name=${gnb_alias_A_08}
    Run Keywords                  coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${ps_bwp_delta_file_A_08}
    ...                           connection=${gnb_alias_A_08}

    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    sbts_coam.teardown            connection=${gnb_alias_A_08}

    Dated Log new line            ${trcColor}--- Restart TL ${defColor}
    Restart TL
    Dated Log new line            ${trcColor}--- WTS setup SA ${defColor}
    Setup Wtsemu SA               nbUe=1       nbSaUe=1     shouldUseLua=${True}

CB008662_TC_A_08_DL_HARQ_Retrans_When_multiple_NACK_Are_Received
    [Documentation]                 The aim of this test is to check that reserved MCS is used
    ...                             for retransmission if the number of available resources in slot is below
    ...                             or above resrouces in initial transmission
    ...                             On the contraty, initial MCS should be used in case the same REs
    ...                             are available inside retransmission slot.

    # Customise SCF, restart TL and perform cell setup
    CB008662_A_keywords.CB008662 CellSetup

    # Cellsetup is now done, Sherpa can be enabled if needed
    # As TTI and Sherpa are captured in the same way, it is not possible to start Sherpa now as TTI trace are used later
    #Run Keyword If                  ${enable_sherpa} == ${True}           Activate Sherpa

    UE Register                     ue=${BASIC_UE_SA.ue}
    Launch PDU Session              ue=${BASIC_UE_SA.ue}    pdu=${BASIC_UE_SA.ue}    gw=${BASIC_UE_SA.ue}

    # TTI capture configuration
    ${TTIdir}                       Get TTI Trace Path                 dir_suffix=A_08

    # Enable PDSCH decoding for SSB and TRS
    wtsemu.ue_testmode_decode_muxphychan         decode_mux_phy_chan=decode_PDSCH

    # BLER profile to have systematic NACK for RV=0, 2, 3 and ACK for RV=1
    wtsemu.bler_testmode_nr                      profile_id=1
    ...                                          num_harq_nack=3

    # Set CQI value to have a predfinied MCS (~22)
    wtsemu.csi_override_testmode_nr              profile_id=1
    ...                                          cqi=10
    ...                                          ri=0

    ${timeStartTraffic}             Get Current Date
    Dated Log New Line              ${trcColor}=== Start packets sending at ${timeStartTraffic} ${defColor}
    Traffic UE DL                   ueSetting=${BASIC_UE_SA}
    ...                             throughput=${DL_troughput_A_08}
    ...                             shouldBeStop=False
    ...                             shouldBeCheck=False
    ...                             duration=20s
    ...                             deviation=5

    # Enable DL BLER and CQI test modes
    wtsemu.ue_testmode_set_nr       id=${BASIC_UE_SA.ue}
    ...                             testmode=csi_override
    ...                             profile_id=1
    ...                             action=activate
    wtsemu.ue_testmode_set_nr       id=${BASIC_UE_SA.ue}
    ...                             testmode=bler
    ...                             profile_id=1
    ...                             action=activate

    Traced Sleep                    5 seconds

    # start TTI capture
    Dated Log New Line            ${trcColor}=== Start TTI traces capture ${defColor}

    Start TTI Traces in Streaming mode    src_ip=10.0.1.2

    Traced Sleep                  ${DL_trace_duration_A_08} seconds               msg=DL traffic capture

    # stop TTI capture
    ${TTIpcap}                    Stop TTI Traces in Streaming mode
    ...                           tti_trace_path=${TTIdir}
    ...                           tti_trace_filename=TTITrace_A_08

    Dated Log New Line            ${trcColor}=== Convert TTItrace to json and csv ${defColor}
    ${TTIjson}                    Convert TTItrace from pcap to others
    ...                           input_file_path=${TTIpcap}

    Dated Log New Line            ${trcColor}=== Check retransmission PRB and adaptive MCS in TTI trace ${defColor}
    ${checksResults}              checkAdaptiveTDDDL                    jsonPathName=${TTIjson}
    ...                                                                 rdAdaptiveReTxNackCount=${RD_AdaptiveReTxNackCountValue_A_08}

    # BLER profile deactivation
    # Deactivate BLER by steps
    wtsemu.bler_testmode_nr       profile_id=1
    ...                           num_harq_nack=2
    Traced Sleep                  2 seconds

    wtsemu.bler_testmode_nr       profile_id=1
    ...                           num_harq_nack=1
    Traced Sleep                  2 seconds

    wtsemu.ue_testmode_set_nr     id=${BASIC_UE_SA.ue}
    ...                           testmode=bler
    ...                           profile_id=1
    ...                           action=deactivate

    # CQI test mode deactivation
    wtsemu.ue_testmode_set_nr     id=${BASIC_UE_SA.ue}
    ...                           testmode=csi_override
    ...                           profile_id=1
    ...                           action=deactivate
    ${timeStopTraffic}            Get Current Date
    Dated Log New Line            ${trcColor}=== Stop packets sending and detach UE at ${timeStopTraffic} ${defColor}
    Traffic Stop                  ueSetting=${UE_SIMPLE}             dir=dl

    UE Deregister                 id=${BASIC_UE_SA.ue}

    # Max 3 % error
    Dated Log New Line            Error percentage is ${checksResults}[ErrorRatio] % < ${MaxAdaptiveReTxErrorRatio_A_08}

    Dated log                     Reserved MCS detected: ${checksResults}[reservedMcsDetected]
    Dated Log                     Unexpected MCS detected: ${checksResults}[unexpectedMcsDetected]
    Dated Log                     Unexpected PRB detected: ${checksResults}[unexpectedPRBDetected]
    Dated Log                     Unexpected RBG detected: ${checksResults}[unexpectedRBGDetected]

    Dated Log                     Number of checks with more ressources: ${checksResults}[moreResourceChecks]
    Dated Log                     Number of checks with less ressources: ${checksResults}[lessResourceChecks]
    Dated Log                     Number of checks with same ressources: ${checksResults}[sameResourceChecks]

    Should Be True                ${checksResults}[ErrorRatio] < ${MaxAdaptiveReTxErrorRatio_A_08}

