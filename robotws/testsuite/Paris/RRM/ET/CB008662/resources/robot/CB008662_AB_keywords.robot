*** Settings ***
Documentation     [SUITE PURPOSE]  TCs and KWs of CB008662 step AB
...
...               Test Case Scenario author   : yann.ah.herve@nokia.com
...               Test Case Scenario contact  : yann.ah.herve@nokia.com
...               Test Case automation author : yann.ah.herve@nokia.com
...               Test Case automation contact: yann.ah.herve@nokia.com
...               Creation Date               : 03-October-2022
...               Modified Date               : 
...               Last Modified by            : 
...               Modification:
...                       02-October-2022      |     Creation

Resource                         ./CB008662_keywords.robot
Resource                         ../../../resources/common/TtiTrace/ttitrace.robot
Resource                         ../../../../../resources/SWENG/robot/WtsXmlConfig.robot
Resource                         ../../../../../resources/SWENG/robot/WtsCfgConfig.robot
Resource                         ../../../../../resources/SWENG/robot/Counters.robot
Resource                         ../../../../../resources/SWENG/robot/KPIs.robot
Library                          ../../../../../resources/SWENG/python/CoamParameter.py      WITH NAME     coam_parameter
Library                          taf.sbts.oam.coam.admin           WITH NAME   sbts_coam


*** Variables ***
${DL_troughput_AB}                  175

${gnb_alias_AB}                     gnb_under_test
${ps_bwp_delta_file_AB}             testsuite/Paris/RRM/ET/CB008662/config/Delta_Configuration_scf_Enable_Adaptive_ReTx.json
${CONSTRAINTS_FILE_AB}              testsuite/Paris/RRM/ET/CB008662/config/CB008662_AB_02_Constraints.csv

# Disable HARQ incremental redundancy DL
${RD_DisableDlIR_AB}                0x580001

# Defines the maximum number of NACKs received at gNB for a HARQ process,
# after which the next retransmission shall use the PRB/MCS of initial transmission
${RD_AdaptiveReTxNackCountAddr_AB}      0x580678
${RD_AdaptiveReTxNackCountValue_AB}     6

*** Keywords ***

CB008662 CellSetup
    [Documentation]               Dedicated KW to add adaptive retransmission configuration
    ...                           by using a delta JSON file.
    ...                           !!! Dist names are hardcoded inside JSON file. To be improved ???

    # Enable IR which is disabled by default
    ${radp_EnableIR}                Create Dictionary    field=${RD_DisableDlIR_AB}    value=0

    # Disable NACK count,rdAdaptiveReTxNackCount, which is enable set to 2
    ${radp_AdaptiveReTxNackCount}   Create Dictionary       field=${RD_AdaptiveReTxNackCountAddr_AB}
    ...                                                     value=${RD_AdaptiveReTxNackCountValue_AB}

    ${list_rad_param}               Create List          ${radp_EnableIR}    ${radp_AdaptiveReTxNackCount} 
    Set Fields in swconfig DU       param_list=${list_rad_param}
	
    # Open connection towards cOAM
    sbts_coam.connect_to          name=${gnb_alias_AB}

    Run Keywords                  coam_parameter.perform_scf_delta_commission     
    ...                           delta_file=${ps_bwp_delta_file_AB}
    ...                           connection=${gnb_alias_AB}
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    sbts_coam.teardown            connection=${gnb_alias_AB}

    Dated Log new line            ${trcColor}--- Restart TL ${defColor}
    Restart TL
    Dated Log new line            ${trcColor}--- WTS setup SA ${defColor}
    Setup Wtsemu SA               nbUe=1       nbSaUe=1     shouldUseLua=${True}

CB008662_TC_AB_02_Check_DL_64QAM_Counters_MCS_30
    [Documentation]                 The aim of this test is to check newsome of the counters 
    ...                             introduced for CB008662:
    ...                             M55314C03006    Downlink data volume received over F1-U - QoS Group 6
    ...                             => Depends on data rate.
    ...
    ...                             M55300C02030    Successful PDSCH transmissions by any transmission with 64QAM MCS table
    ...                             => Represents the number of successful transmission by any transmission with MCS30.
    ...                             As BLER test mode is used with 100,100,100,50 profile, it means that all NACKed 1st 
    ...                             transmissions (10 % of 1st tranmissions) will reach RV1.
    ...                             Only retransmission 50 % of retransmission from RV1 will be successful.
    ...                             The idea was to be able to forecast the number of successful transmission with MCS30/
    ...                             However, it's not possible to forecast this value as
    ...                             we don't know which kind of slot may be used and if it will lead to the use of MCS30
    ...                             or initial MCS. So, value was determined expirimentally and a high interval
    ...                             constraint was set (between 700 and 2200 fot both M55300C02030/M55300C03030) as it
    ...                             may vary a lot between runs.
    ...
    ...                             M55300C03030    Unsuccessful PDSCH transmissions by last HARQ reTx with 64QAM MCS table
    ...                             => Same comment as for M55300C02030
    ...
    ...                             M55304C02030    Initial and retransmission volume on PDSCH with 64QAM MCS table
    ...                             => Also difficult to forecast as the use of reserved MCS vs initial MCS depends
    ...                             on which kind of slot retransmission is done. Value was determined expirimentally...
    ...
    ...                             M55301C01030    PDSCH transmissions in Rank 2 with 64QAM MCS table
    ...                             => Also difficult to forecast as the use of reserved MCS vs initial MCS depends
    ...                             on which kind of slot retransmission is done. Value was determined expirimentally...
    ...
    ...                             About DL data rate: it must be high enough to NOT trigger MCS downgrade.
    ...                             Otherwise, retransmission will NOT be done with MCS30 and counters will be wrong.

    # Customise SCF, restart TL and perform cell setup
    CB008662_AB_keywords.CB008662 CellSetup

    # Cellsetup is now done, Sherpa can be enabled if needed
    Run Keyword If                  ${enable_sherpa} == ${True}           Activate Sherpa

    UE Register                     ue=${BASIC_UE_SA.ue}
    Launch PDU Session              ue=${BASIC_UE_SA.ue}    pdu=${BASIC_UE_SA.ue}    gw=${BASIC_UE_SA.ue}

    # Enable PDSCH decoding for SSB and TRS
    wtsemu.ue_testmode_decode_muxphychan         decode_mux_phy_chan=decode_PDSCH

    # BLER profile to have NACK for RV=0, 2, 3 and hald of ACK/NACK for RV=1 in order
    # to trigger M55300C02031/M55300C03031
    wtsemu.bler_testmode_nr                      profile_id=1
    ...                                          dl_bler=100,100,100,50

    # Set CQI value to have a predefined MCS (~12) and RANK2 for counter check
    wtsemu.csi_override_testmode_nr              profile_id=1
    ...                                          cqi=7
    ...                                          ri=1

    ${timeStartTraffic}             Get Current Date
    Dated Log New Line              ${trcColor}=== Start packets sending at ${timeStartTraffic} ${defColor}
    Traffic UE DL                   ueSetting=${BASIC_UE_SA}
    ...                             throughput=${DL_troughput_AB}
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

    ${zoi}                        ZOI Start

    Dated log New Line            ${trcColor}=== Starting collecting PM ${defColor}
    ZOI Wait End                  zoi=${zoi}
    ${pm_path}                    Counters.Collect PM files from BTS    ${LOG_PATH}/PM

    # BLER profile deactivation
    # Deactivate BLER
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

    KPI Evaluate                  pmFile=${pm_path}
    ...                           constraintsFile=${CONSTRAINTS_FILE_AB}
    ...                           failOnError=${True}

