*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CLOUD_5G_I_BOO_AP_LOO    team-CN1ET
...    owner-delun.li    release-SBTS24R2    CRT
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_beam_relate}
...    @{PARAMS_FOR_A2_disable}
...    @{PARAMS_FOR_measurement_relate}
...    @{PARAMS_FOR_other}

@{PARAMS_FOR_CA}
...    NRBTS:caConfigurationSupportFr2SA=8CCDL_4CCUL
...    NRBTS/NRDU-1:carrierAggregationSupportList=none
...    NRBTS:actCarrierAggregationFr2SA=true
...    NRBTS:maxNumScellsDlFr2SA=7
...    NRBTS:maxNumScellsUlFr2SA=3
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRCELL-1:sCellOnlyFr2Sa=false
...    NRCELL-2:actProactUlScheduling=true
...    NRCELL-3:actProactUlScheduling=true
...    NRCELL-4:actProactUlScheduling=true
...    NRCELL-5:actProactUlScheduling=false
...    NRCELL-6:actProactUlScheduling=false
...    NRCELL-7:actProactUlScheduling=false
...    NRCELL-8:actProactUlScheduling=false
...    NRBTS:sCellActivationMethod=blind
...    NRCELL:sCellDeactivationTimerGNB=infinity

@{PARAMS_FOR_beam_relate}
...    NRCELL:actBeamforming=true
...    NRCELL-1:actRrcReconfigAtBeamSwitch=false
...    NRSYSINFO_PROFILE-1/NRIRFIM-1:numberOfTransmittedSsBlocks=32 beams
...    NRCELLGRP-1:numberOfTransmittedSsBlocks=32 beams
...    NRCELL:beamSet:basicBeamSet=beamSetAbf_32A

@{PARAMS_FOR_A2_disable}
...    NRCELL:a2MeashoEnabledSA=none
...    NRCELL-1:a2MeasRedirectEnabled=${EMPTY}

@{PARAMS_FOR_measurement_relate}
...    NRBTS/NRPMRNL-1:miNrCaCu=5min
...    NRBTS/NRPMRNL-1:miNrRSACU=5min
...    NRBTS/NRPMRNL-1:miNrRSADU=5min
...    NRBTS/NRPMRNL-1:miNrRacCu=5min
...    NRBTS/NRPMRNL-1:miNrRacDu=5min
...    NRBTS/NRPMRNL-1:miNrCaDu=5min
...    NRBTS/NRPMRNL-1:miNrLowRlcReport=5min
...    NRBTS/NRPMRNL-1:miNrHighRlcCell=5min

@{PARAMS_FOR_other}
...    NRBTS:cipherPrefL:nea0=1
...    NRCELL:type0SearchSpaceConfigurationIndex=2
...    NRBTS:actIpThpt=true
...    NRBTS:actMacUserThpt=true

@{A001_parameter_update}
...    NRBTS:actCarrierAggregationFr2SA=false

@{A002_parameter_update}
...    NRBTS:actCarrierAggregationFr2SA=true
...    NRCELL:maxNumOf5To8CCUsersFr2SA=5

@{A003_parameter_recover}
...    NRBTS:actCarrierAggregationFr2SA=true
...    NRCELL:maxNumOf5To8CCUsersFr2SA=${EMPTY}

@{A008_parameter_update}
...    NRCELL:maxNumOf5To8CCUsersFr2SA=0

@{A008_parameter_recover}
...    NRCELL:maxNumOf5To8CCUsersFr2SA=${EMPTY}

@{A008_expect_regexp}
...    pcid:51, scellIdx:1] configure_0_1
...    pcid:53, scellIdx:3] configure_0_1
...    pcid:50, scellIdx:0] configure_0_1
...    pcid:52, scellIdx:2] configure_0_1
...    pcid:51, scellIdx:1] configure_1_1
...    pcid:53, scellIdx:3] configure_1_1
...    pcid:50, scellIdx:0] configure_1_1
...    pcid:52, scellIdx:2] configure_1_1
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 3 activated successfully at airphone

@{8CCDL_4CCUL_regexp}
...    pcid:51, scellIdx:1] configure_0_1
...    pcid:53, scellIdx:3] configure_0_1
...    pcid:50, scellIdx:0] configure_0_1
...    pcid:52, scellIdx:2] configure_0_1
...    pcid:55, scellIdx:5] configure_1_1
...    pcid:57, scellIdx:7] configure_1_1
...    pcid:51, scellIdx:1] configure_1_1
...    pcid:53, scellIdx:3] configure_1_1
...    pcid:50, scellIdx:0] configure_1_1
...    pcid:52, scellIdx:2] configure_1_1
...    pcid:54, scellIdx:4] configure_1_1
...    pcid:56, scellIdx:6] configure_1_1
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 3 activated successfully at airphone
...    SCellIndex 4 activated successfully at airphone
...    SCellIndex 5 activated successfully at airphone
...    SCellIndex 6 activated successfully at airphone
...    SCellIndex 7 activated successfully at airphone

@{4CCDL_2CCUL_regexp}
...    pcid:50, scellIdx:0] configure_0_1
...    pcid:51, scellIdx:1] configure_0_1
...    pcid:50, scellIdx:0] configure_1_1
...    pcid:51, scellIdx:1] configure_1_1
...    pcid:52, scellIdx:2] configure_1_1
...    pcid:53, scellIdx:3] configure_1_1
...    PhysCellId: 51] SCellIndex 1 activated successfully
...    PhysCellId: 52] SCellIndex 2 activated successfully
...    PhysCellId: 53] SCellIndex 3 activated successfully

@{2CCDL_2CCUL_regexp}
...    pcid:50, scellIdx:0] configure_0_1
...    pcid:51, scellIdx:1] configure_0_1
...    pcid:50, scellIdx:0] configure_1_1
...    pcid:51, scellIdx:1] configure_1_1
...    PhysCellId: 51] SCellIndex 1 activated successfully

@{6CCDL_3CCUL_regexp}
...    pcid:50, scellIdx:0] configure_0_1
...    pcid:51, scellIdx:1] configure_0_1
...    pcid:52, scellIdx:2] configure_0_1
...    pcid:50, scellIdx:0] configure_1_1
...    pcid:51, scellIdx:1] configure_1_1
...    pcid:52, scellIdx:2] configure_1_1
...    pcid:53, scellIdx:3] configure_1_1
...    pcid:54, scellIdx:4] configure_1_1
...    pcid:55, scellIdx:5] configure_1_1
...    PhysCellId: 51] SCellIndex 1 activated successfully
...    PhysCellId: 52] SCellIndex 2 activated successfully
...    PhysCellId: 53] SCellIndex 3 activated successfully
...    PhysCellId: 54] SCellIndex 4 activated successfully
...    PhysCellId: 55] SCellIndex 5 activated successfully

@{unexpect_regexp}
...    SCellIndex 1 activated successfully at airphone

@{A017_parameter_update}
...    NRCELL:maxNumOf5To8CCUsersFr2SA=1
...    NRCELL:maxNumOf3To4CCUsersFr2SA=1
...    NRCELL:maxNumOf2CCUsersFr2SA=1

@{A017_parameter_recover}
...    NRCELL:maxNumOf5To8CCUsersFr2SA=${EMPTY}
...    NRCELL:maxNumOf3To4CCUsersFr2SA=${EMPTY}
...    NRCELL:maxNumOf2CCUsersFr2SA=${EMPTY}

@{A017_expect_regexp}
...    pcid:51, scellIdx:1] configure_0_1
...    pcid:50, scellIdx:0] configure_0_1
...    pcid:51, scellIdx:1] configure_1_1
...    pcid:50, scellIdx:0] configure_1_1
...    SCellIndex 1 activated successfully at airphone

@{A019_parameter_update}
...    NRBTS:caConfigurationSupportFr2SA=8CCDL_4CCUL
...    NRBTS:maxNumScellsDlFr2SA=5
...    NRBTS:maxNumScellsUlFr2SA=2

@{A018_parameter_recover}
...    NRBTS:caConfigurationSupportFr2SA=8CCDL_4CCUL
...    NRBTS:maxNumScellsDlFr2SA=7
...    NRBTS:maxNumScellsUlFr2SA=3

@{A003_PM_Counters_Check}
...    NRCELL-1:RSADU:${GNB_DU_SCELL_7_ADMI_REQ_SA}=2
...    NRCELL-1:RSADU:${GNB_DU_SCELL_7_ADMI_SUCC_SA}=2
...    NRCELL-1:NCAC:${RRC_RECONF_ADD7DLSCELL_ATT_SA}=2
...    NRCELL-1:NCAC:${RRC_RECONF_ADD7DLSCELL_SUCC_SA}=2
...    NRCELL-1:NCAC:${UE_PCELL_7_CONF_SCELL_DL_SA}>0
...    NRCELL-1:RSACU:${GNB_SCELL_7_ADMI_REQ_SA}=2
...    NRCELL-1:RSACU:${GNB_SCELL_7_ADMI_SUCC_SA}=2
...    NRCELL-1:CUCM:${MAX_UE_PCELL_3_CONF_SCEL_UL_SA}>1
...    NRCELL-1:CUCM:${MAX_UE_PCELL_7_CONF_SCEL_DL_SA}>1
...    NRCELL-2:NCAC:${UE_SCELL_3_CONF_SCELL_UL_SA}>0
...    NRCELL-3:NCAC:${UE_SCELL_3_CONF_SCELL_UL_SA}>0
...    NRCELL-4:NCAC:${UE_SCELL_3_CONF_SCELL_UL_SA}>0
...    NRCELL-2:NCAC:${UE_SCELL_7_CONF_SCELL_DL_SA}>0
...    NRCELL-3:NCAC:${UE_SCELL_7_CONF_SCELL_DL_SA}>0
...    NRCELL-4:NCAC:${UE_SCELL_7_CONF_SCELL_DL_SA}>0
...    NRCELL-5:NCAC:${UE_SCELL_7_CONF_SCELL_DL_SA}>0
...    NRCELL-6:NCAC:${UE_SCELL_7_CONF_SCELL_DL_SA}>0
...    NRCELL-7:NCAC:${UE_SCELL_7_CONF_SCELL_DL_SA}>0
...    NRCELL-8:NCAC:${UE_SCELL_7_CONF_SCELL_DL_SA}>0

@{A008_PM_Counters_Check}
...    NRCELL-1:NCAC:${RRC_RECONF_ADD3DLSCELL_ATT_SA}=1
...    NRCELL-1:NCAC:${RRC_RECONF_ADD3DLSCELL_SUCC_SA}=1
...    NRCELL-1:NCAC:${UE_PCELL_3_CONF_SCELL_DL_SA}>0
...    NRCELL-1:RSADU:${GNB_DU_SCELL_3_ADMI_REQ_SA}=1
...    NRCELL-1:RSADU:${GNB_DU_SCELL_3_ADMI_SUCC_SA}=1
...    NRCELL-1:RSACU:${GNB_SCELL_3_ADMI_SUCC_SA}=1
...    NRCELL-2:NCAC:${UE_SCELL_3_CONF_SCELL_DL_SA}>0
...    NRCELL-3:NCAC:${UE_SCELL_3_CONF_SCELL_DL_SA}>0
...    NRCELL-4:NCAC:${UE_SCELL_3_CONF_SCELL_DL_SA}>0

...    NRCELL-1:NCAC:${UE_PCELL_3_CONF_SCELL_UL_SA}>0
...    NRCELL-1:RSACU:${GNB_SCELL_7_ADMI_REQ_SA}=1
...    NRCELL-1:CUCM:${MAX_UE_PCELL_3_CONF_SCEL_UL_SA}>0
...    NRCELL-1:CUCM:${MAX_UE_PCELL_3_CONF_SCEL_DL_SA}>0
...    NRCELL-2:NCAC:${UE_SCELL_3_CONF_SCELL_UL_SA}>0
...    NRCELL-3:NCAC:${UE_SCELL_3_CONF_SCELL_UL_SA}>0
...    NRCELL-4:NCAC:${UE_SCELL_3_CONF_SCELL_UL_SA}>0

@{A017_PM_Counters_Check}
#for 2CC
...    NRCELL-1:NCAC:${RRC_RECONF_ADD1DLSCELL_ATT_SA}=1
...    NRCELL-1:NCAC:${RRC_RECONF_ADD1DLSCELL_SUCC_SA}=1
...    NRCELL-1:NCAC:${UE_PCELL_1_CONF_SCELL_DL_SA}>0
...    NRCELL-1:NCAC:${UE_PCELL_1_CONF_SCELL_UL_SA}>0
...    NRCELL-1:CUCM:${MAX_UE_PCELL_1_CONF_SCEL_UL_SA}>0
...    NRCELL-1:RSACU:${GNB_SCELL_1_ADMI_REQ_SA}=0
...    NRCELL-1:RSACU:${GNB_SCELL_1_ADMI_SUCC_SA}=1
...    NRCELL-1:RSADU:${GNB_DU_SCELL_1_ADMI_REQ_SA}=1
...    NRCELL-1:RSADU:${GNB_DU_SCELL_1_ADMI_SUCC_SA}=1
...    NRCELL-2:NCAC:${UE_SCELL_1_CONF_SCELL_DL_SA}>0
...    NRCELL-2:NCAC:${UE_SCELL_1_CONF_SCELL_UL_SA}>0
#for 4CC
...    NRCELL-1:NCAC:${RRC_RECONF_ADD3DLSCELL_ATT_SA}=1
...    NRCELL-1:NCAC:${RRC_RECONF_ADD3DLSCELL_SUCC_SA}=1
...    NRCELL-1:NCAC:${UE_PCELL_3_CONF_SCELL_DL_SA}>0
...    NRCELL-1:RSADU:${GNB_DU_SCELL_3_ADMI_REQ_SA}=1
...    NRCELL-1:RSADU:${GNB_DU_SCELL_3_ADMI_SUCC_SA}=1
...    NRCELL-1:RSACU:${GNB_SCELL_3_ADMI_REQ_SA}=0
...    NRCELL-1:RSACU:${GNB_SCELL_3_ADMI_SUCC_SA}=1
...    NRCELL-2:NCAC:${UE_SCELL_3_CONF_SCELL_DL_SA}>0
...    NRCELL-3:NCAC:${UE_SCELL_3_CONF_SCELL_DL_SA}>0
...    NRCELL-4:NCAC:${UE_SCELL_3_CONF_SCELL_DL_SA}>0

...    NRCELL-1:CUCM:${MAX_UE_PCELL_1_CONF_SCEL_DL_SA}>0
...    NRCELL-1:NCAC:${UE_PCELL_3_CONF_SCELL_UL_SA}>0
...    NRCELL-1:CUCM:${MAX_UE_PCELL_3_CONF_SCEL_UL_SA}>1
...    NRCELL-1:CUCM:${MAX_UE_PCELL_3_CONF_SCEL_DL_SA}>0
...    NRCELL-1:NCAC:${RRC_RECONF_ADD7DLSCELL_ATT_SA}=1
...    NRCELL-1:NCAC:${RRC_RECONF_ADD7DLSCELL_SUCC_SA}=1
...    NRCELL-1:NCAC:${UE_PCELL_7_CONF_SCELL_DL_SA}>0
...    NRCELL-1:RSACU:${GNB_SCELL_7_ADMI_REQ_SA}=4
...    NRCELL-1:RSACU:${GNB_SCELL_7_ADMI_SUCC_SA}=1
...    NRCELL-1:CUCM:${MAX_UE_PCELL_7_CONF_SCEL_DL_SA}>0
...    NRCELL-1:RSADU:${GNB_DU_SCELL_7_ADMI_REQ_SA}=1
...    NRCELL-1:RSADU:${GNB_DU_SCELL_7_ADMI_SUCC_SA}=1
...    NRCELL-2:NCAC:${UE_SCELL_3_CONF_SCELL_UL_SA}>0
...    NRCELL-3:NCAC:${UE_SCELL_3_CONF_SCELL_UL_SA}>0
...    NRCELL-4:NCAC:${UE_SCELL_3_CONF_SCELL_UL_SA}>0
...    NRCELL-2:NCAC:${UE_SCELL_7_CONF_SCELL_DL_SA}>0
...    NRCELL-3:NCAC:${UE_SCELL_7_CONF_SCELL_DL_SA}>0
...    NRCELL-4:NCAC:${UE_SCELL_7_CONF_SCELL_DL_SA}>0
...    NRCELL-5:NCAC:${UE_SCELL_7_CONF_SCELL_DL_SA}>0
...    NRCELL-6:NCAC:${UE_SCELL_7_CONF_SCELL_DL_SA}>0
...    NRCELL-7:NCAC:${UE_SCELL_7_CONF_SCELL_DL_SA}>0
...    NRCELL-8:NCAC:${UE_SCELL_7_CONF_SCELL_DL_SA}>0

@{A018_PM_Counters_Check}
#for 2CCDL_2CCUL and 4CCDL_2CCUL
...    NRCELL-1:NCAC:${RRC_RECONF_ADD1DLSCELL_ATT_SA}=1
...    NRCELL-1:NCAC:${RRC_RECONF_ADD1DLSCELL_SUCC_SA}=1
...    NRCELL-1:NCAC:${UE_PCELL_1_CONF_SCELL_DL_SA}>0
...    NRCELL-1:NCAC:${UE_PCELL_1_CONF_SCELL_UL_SA}>0
...    NRCELL-1:RSACU:${GNB_SCELL_1_ADMI_REQ_SA}=1
...    NRCELL-1:RSACU:${GNB_SCELL_1_ADMI_SUCC_SA}=1
...    NRCELL-1:RSADU:${GNB_DU_SCELL_1_ADMI_REQ_SA}=1
...    NRCELL-1:RSADU:${GNB_DU_SCELL_1_ADMI_SUCC_SA}=1
...    NRCELL-1:NCAC:${RRC_RECONF_ADD1ULSCELL_ATT_SA}=2
...    NRCELL-1:NCAC:${RRC_RECONF_ADD1ULSCELL_SUCC_SA}=2
...    NRCELL-2:NCAC:${UE_SCELL_1_CONF_SCELL_DL_SA}>0
...    NRCELL-2:NCAC:${UE_SCELL_1_CONF_SCELL_UL_SA}>0
...    NRCELL-1:NCAC:${RRC_RECONF_ADD3DLSCELL_ATT_SA}=1
...    NRCELL-1:NCAC:${RRC_RECONF_ADD3DLSCELL_SUCC_SA}=1
...    NRCELL-1:NCAC:${UE_PCELL_3_CONF_SCELL_DL_SA}>0
...    NRCELL-1:RSADU:${GNB_DU_SCELL_3_ADMI_REQ_SA}=1
...    NRCELL-1:RSADU:${GNB_DU_SCELL_3_ADMI_SUCC_SA}=1
...    NRCELL-1:RSACU:${GNB_SCELL_3_ADMI_REQ_SA}=1
...    NRCELL-1:RSACU:${GNB_SCELL_3_ADMI_SUCC_SA}=1
...    NRCELL-2:NCAC:${UE_SCELL_3_CONF_SCELL_DL_SA}>0
...    NRCELL-3:NCAC:${UE_SCELL_3_CONF_SCELL_DL_SA}>0
...    NRCELL-4:NCAC:${UE_SCELL_3_CONF_SCELL_DL_SA}>0

#for 8CCDL_4CCUL
...    NRCELL-1:RSADU:${GNB_DU_SCELL_7_ADMI_REQ_SA}=1
...    NRCELL-1:RSADU:${GNB_DU_SCELL_7_ADMI_SUCC_SA}=1
...    NRCELL-1:NCAC:${RRC_RECONF_ADD7DLSCELL_ATT_SA}=1
...    NRCELL-1:NCAC:${RRC_RECONF_ADD7DLSCELL_SUCC_SA}=1
...    NRCELL-1:NCAC:${UE_PCELL_7_CONF_SCELL_DL_SA}>0
...    NRCELL-1:NCAC:${UE_PCELL_3_CONF_SCELL_UL_SA}>0
...    NRCELL-1:RSACU:${GNB_SCELL_7_ADMI_REQ_SA}=1
...    NRCELL-1:RSACU:${GNB_SCELL_7_ADMI_SUCC_SA}=1
...    NRCELL-1:CUCM:${MAX_UE_PCELL_3_CONF_SCEL_UL_SA}>1
...    NRCELL-1:CUCM:${MAX_UE_PCELL_7_CONF_SCEL_DL_SA}>1
...    NRCELL-2:NCAC:${UE_SCELL_3_CONF_SCELL_UL_SA}>0
...    NRCELL-3:NCAC:${UE_SCELL_3_CONF_SCELL_UL_SA}>0
...    NRCELL-4:NCAC:${UE_SCELL_3_CONF_SCELL_UL_SA}>0
...    NRCELL-2:NCAC:${UE_SCELL_7_CONF_SCELL_DL_SA}>0
...    NRCELL-3:NCAC:${UE_SCELL_7_CONF_SCELL_DL_SA}>0
...    NRCELL-4:NCAC:${UE_SCELL_7_CONF_SCELL_DL_SA}>0
...    NRCELL-5:NCAC:${UE_SCELL_7_CONF_SCELL_DL_SA}>0
...    NRCELL-6:NCAC:${UE_SCELL_7_CONF_SCELL_DL_SA}>0
...    NRCELL-7:NCAC:${UE_SCELL_7_CONF_SCELL_DL_SA}>0
...    NRCELL-8:NCAC:${UE_SCELL_7_CONF_SCELL_DL_SA}>0
#for 6CCDL_3CCUL
...    NRCELL-1:NCAC:${RRC_RECONF_ADD5DLSCELL_ATT_SA}=1
...    NRCELL-1:NCAC:${RRC_RECONF_ADD5DLSCELL_SUCC_SA}=1
...    NRCELL-1:NCAC:${RRC_RECONF_ADD2ULSCELL_ATT_SA}=1
...    NRCELL-1:NCAC:${RRC_RECONF_ADD2ULSCELL_SUCC_SA}=1
...    NRCELL-1:NCAC:${UE_PCELL_2_CONF_SCELL_UL_SA}>0
...    NRCELL-1:NCAC:${UE_PCELL_5_CONF_SCELL_DL_SA}>0
...    NRCELL-1:CUCM:${MAX_UE_PCELL_2_CONF_SCEL_UL_SA}>0
...    NRCELL-1:CUCM:${MAX_UE_PCELL_5_CONF_SCEL_DL_SA}>0
...    NRCELL-1:RSACU:${GNB_SCELL_5_ADMI_REQ_SA}=1
...    NRCELL-1:RSACU:${GNB_SCELL_5_ADMI_SUCC_SA}=1
...    NRCELL-1:RSADU:${GNB_DU_SCELL_5_ADMI_REQ_SA}=1
...    NRCELL-1:RSADU:${GNB_DU_SCELL_5_ADMI_SUCC_SA}=1
...    NRCELL-2:NCAC:${UE_SCELL_2_CONF_SCELL_UL_SA}>0
...    NRCELL-2:NCAC:${UE_SCELL_5_CONF_SCELL_DL_SA}>0
...    NRCELL-3:NCAC:${UE_SCELL_2_CONF_SCELL_UL_SA}>0
...    NRCELL-3:NCAC:${UE_SCELL_5_CONF_SCELL_DL_SA}>0
...    NRCELL-4:NCAC:${UE_SCELL_5_CONF_SCELL_DL_SA}>0
...    NRCELL-5:NCAC:${UE_SCELL_5_CONF_SCELL_DL_SA}>0
...    NRCELL-6:NCAC:${UE_SCELL_5_CONF_SCELL_DL_SA}>0

${GNB_DU_SCELL_1_ADMI_REQ_SA}    M55139C01003
#This counter indicates the number of radio admission requests for exactly 1 SCell before the CA configuration on RRC.
#It's measured in PCell in SA mode in DU only.
${GNB_DU_SCELL_1_ADMI_SUCC_SA}    M55139C01004
#This counter indicates the number of successful radio admission requests for exactly 1 SCell before the CA
#configuration on RRC. It's measured in PCell in SA mode in DU only.
${UE_SCELL_1_CONF_SCELL_DL_SA}    M55118C05508
#This counter indicates the sum of samples for the total number of CA UEs in the current cell configured as an SCell
#with 1 configured SCell in DL in SA mode. The counter is pegged in the secondary cell.
${UE_SCELL_1_CONF_SCELL_UL_SA}    M55118C10006
#This counter shows the sum of samples for the total number of CA UEs in the current cell configured as UL SCell,
#while pegged in the secondary cell, which have 1 configured UL SCell in UL.
${GNB_SCELL_1_ADMI_REQ_SA}    M55138C01501
#This counter indicates the number of radio admission requests for exactly 1 SCell before the CA configuration on RRC.
#It's measured in PCell in SA mode only.
${GNB_SCELL_1_ADMI_SUCC_SA}    M55138C01502
#This counter indicates the number of successful radio admission requests for exactly 1 SCell before the CA
#configuration on RRC. It's measured in PCell in SA mode only.
${MAX_UE_PCELL_1_CONF_SCEL_UL_SA}    M55156C10007
#This counter shows the maximum of samples for total number of CA UEs in the current cell configured as a PCell,
#which have 1 configured SCell in UL.
${MAX_UE_PCELL_1_CONF_SCEL_DL_SA}    M55156C00023
#This counter shows the maximum of samples for total number of CA UEs in the current cell configured as a PCell,
#which have 1 configured SCell in DL.
${UE_PCELL_1_CONF_SCELL_UL_SA}    M55118C10005
#This counter shows the sum of samples for total number of CA UEs in the current cell configured as a PCell, which have
#1 configured SCell in UL.
${UE_PCELL_1_CONF_SCELL_DL_SA}    M55118C05507
#This counter indicates the sum of samples for the total number of CA UEs in the current cell configured as a PCell
# with 1 configured SCell in DL.
${RRC_RECONF_ADD1DLSCELL_ATT_SA}    M55118C05505
#This counter indicates the total number of RRC reconfiguration attempts for 1 SCell addition in DL in SA mode.
${RRC_RECONF_ADD1DLSCELL_SUCC_SA}    M55118C05506
#This counter indicates the total number of successful RRC reconfiguration attempts for 1 SCell addition in DL in SA mode.
${RRC_RECONF_ADD7DLSCELL_ATT_SA}    M55118C00003
#This counter indicates the total number of RRC Reconfiguration attempts for 7 SCells Addition in DL for SA mode.
${RRC_RECONF_ADD7DLSCELL_SUCC_SA}    M55118C00006
#This counter indicates the total number of successful RRC Reconfiguration attempts for 7 SCells Addition in DL for SA mode.
${UE_PCELL_7_CONF_SCELL_DL_SA}    M55118C00015
#The total number of CA UEs in the current cell configured as a PCell that have exactly 7 configured SCells in DL in
#SA mode. This is a sample-type counter. The instantaneous value in the "sample interval" is taken, and the sum of the
#instantaneous values over the reporting period is reported.
${GNB_DU_SCELL_7_ADMI_REQ_SA}    M55139C03005
#This counter describes the number of radio admission requests for exactly 7 SCells before the CA configuration on RRC.
#It's measured in PCell in SA mode in DU only.
${GNB_DU_SCELL_7_ADMI_SUCC_SA}    M55139C03008
#This counter describes the number of successful radio admission requests for exactly 7 SCells before the CA
#configuration on RRC. It's measured in PCell in SA mode in DU only.
${GNB_SCELL_7_ADMI_REQ_SA}    M55138C03506
#This counter describes the number of radio admission requests for exactly 7 SCells before the CA configuration on RRC.
#It's measured in PCell in SA mode only.
${GNB_SCELL_7_ADMI_SUCC_SA}    M55138C03509
#This counter describes the number of successful radio admission requests for exactly 7 SCells before the CA
#configuration on RRC. It's measured in PCell in SA mode only.
${MAX_UE_PCELL_7_CONF_SCEL_DL_SA}    M55156C00029
#This counter shows the maximum of samples for total number of CA UEs in the current cell configured as a PCell,
#which have 7 configured SCells in DL.
${UE_SCELL_7_CONF_SCELL_DL_SA}    M55118C00020
#The sum of samples for the total number of CA UEs in the current cell configured as an SCell while pegged in the
#secondary cell that has seven configured SCells in DL in SA mode.
${RRC_RECONF_ADD3DLSCELL_ATT_SA}    M55118C09503
#The total number of SA-initiated RRC reconfiguration messages configuring UE with 3 SCells in DL.
${RRC_RECONF_ADD3DLSCELL_SUCC_SA}    M55118C09502
#The total number of successful RRC reconfiguration procedures in SA mode configuring UE with 3 SCells in DL.
${UE_PCELL_3_CONF_SCELL_DL_SA}    M55118C09501
#This counter indicates the total number of CA UEs in the current cell configured as a
#PCell with exactly 3 configured SCells in DL in SA mode.
${UE_PCELL_3_CONF_SCELL_UL_SA}    M55118C00012
#This counter shows the sum of samples for the total number of CA UEs in the current cell
#configured as a PCell, which have 3 configured SCells in UL.
${GNB_DU_SCELL_3_ADMI_REQ_SA}    M55139C03001
#This counter indicates the number of radio admission requests for exactly 3 SCells before
#the CA configuration on RRC. It's measured in the PCell in SA mode in DU only.
${GNB_DU_SCELL_3_ADMI_SUCC_SA}    M55139C03002
#This counter indicates the number of successful radio admission requests for exactly 3
#SCells before the CA configuration on RRC. It's measured in the PCell in SA mode in DU only.
${GNB_SCELL_3_ADMI_REQ_SA}    M55138C03001
#This counter indicates the number of radio admission requests for exactly 3 SCells before
#the CA configuration on RRC. It's measured in the PCell in SA mode only.
${GNB_SCELL_3_ADMI_SUCC_SA}    M55138C03002
#This counter indicates the number of successful radio admission requests for exactly 3
#SCells before the CA configuration on RRC. It's measured in the PCell in SA mode only.
${MAX_UE_PCELL_3_CONF_SCEL_UL_SA}    M55156C00022
#This counter shows the maximum of samples for the total number of CA UEs in the
#current cell configured as a PCell, which have 3 configured SCells in UL.
${MAX_UE_PCELL_3_CONF_SCEL_DL_SA}    M55156C00025
#This counter shows the maximum of samples for the total number of CA UEs in the
#current cell configured as a PCell, which have 3 configured SCells in DL.
${UE_SCELL_3_CONF_SCELL_UL_SA}    M55118C00017
#This counter shows the sum of samples for the total number of CA UEs in the current
#cell configured as a UL SCell while pegged in the secondary cell, which have 3 configured SCells in UL.
${UE_SCELL_3_CONF_SCELL_DL_SA}    M55118C11009
#The sum of samples for total number of CA UEs in the current cell configured as an
#SCell while pegged in the secondary cell, which have three configured SCells in DL in SA mode.
${RRC_RECONF_ADD1ULSCELL_ATT_SA}    M55118C10001
#This counter indicates the total number of RRC Reconfiguration attempts for 1 SCell Addition in UL for SA mode.
${RRC_RECONF_ADD1ULSCELL_SUCC_SA}    M55118C10002
#This counter indicates the total number of successful RRC Reconfiguration attempts for 1 SCell Addition in UL for SA mode.
${RRC_RECONF_ADD5DLSCELL_ATT_SA}    M55118C00001
#This counter indicates the total number of RRC Reconfiguration attempts for 5 SCells Addition in DL for SA mode.
${RRC_RECONF_ADD5DLSCELL_SUCC_SA}    M55118C00004
#This counter indicates the total number of successful RRC Reconfiguration attempts for 5 SCells Addition in DL for SA mode.
${RRC_RECONF_ADD2ULSCELL_ATT_SA}    M55118C00007
#This counter indicates the total number of RRC Reconfiguration attempts for 2 SCells Addition in UL for SA mode.
${RRC_RECONF_ADD2ULSCELL_SUCC_SA}    M55118C00009
#This counter indicates the total number of successful RRC Reconfiguration attempts for 2 SCells Addition in UL for SA mode.
${UE_PCELL_2_CONF_SCELL_UL_SA}    M55118C00011
#This counter shows the sum of samples for the total number of CA UEs in the current cell configured as a PCell, which
#have 2 configured SCells in UL.
${UE_PCELL_5_CONF_SCELL_DL_SA}    M55118C00013
#This counter provides the total number of CA UEs in the current cell configured as a PCell with exactly 5 configured
#SCells in DL in SA mode.
${MAX_UE_PCELL_2_CONF_SCEL_UL_SA}    M55156C00021
#This counter shows the maximum of samples for the total number of CA UEs in the current cell configured as a PCell,
#which have 2 configured SCells in UL.
${MAX_UE_PCELL_5_CONF_SCEL_DL_SA}    M55156C00027
#This counter shows the maximum of samples for the total number of CA UEs in the current cell configured as a
#PCell with 5 configured SCells in DL.
${GNB_SCELL_5_ADMI_REQ_SA}    M55138C03504
#This counter describes the number of radio admission requests for exactly 5 SCells before the CA configuration on RRC.
#It's measured in the PCell in SA mode only.
${GNB_SCELL_5_ADMI_SUCC_SA}    M55138C03507
#This counter describes the number of successful radio admission requests for exactly 5 SCells before
#the CA configuration on RRC. It's measured in the PCell in SA mode only.
${GNB_DU_SCELL_5_ADMI_REQ_SA}    M55139C03003
#This counter describes the number of radio admission requests for exactly 5 SCells before the CA configuration on RRC.
#It's measured in the PCell in SA mode in DU only.
${GNB_DU_SCELL_5_ADMI_SUCC_SA}    M55139C03006
#This counter describes the number of successful radio admission requests for exactly 5 SCells before the
#CA configuration on RRC. It's measured in the PCell in SA mode in DU only.
${UE_SCELL_2_CONF_SCELL_UL_SA}    M55118C00016
#This counter shows the sum of samples for the total number of CA UEs in the current cell configured as a
#UL SCell while pegged in the secondary cell, which have 2 configured SCells in UL.
${UE_SCELL_5_CONF_SCELL_DL_SA}     M55118C00018
#This counter provides the sum of samples for the total number of CA UEs in the current cell configured as
#an SCell while pegged in the secondary cell with 5 configured SCells in DL in SA mode.

*** Test Cases ***
CB008294-ET-A003-B3_UE_intra-band_CA_in_mmW_band_8DL_and_4UL_contiguous_component_carriers_Pcell_frequency_in_lowest
    [Documentation]
    ...    1. This User Scenario shall validate asymmetric CA functionality with Analog Beamforming in mmW bands (FR2)
    ...       for multi 5G-UE scenario considering UE capabilities. when Pcell use frequency in lowest 8CC will be blind
    ...       added successfully.
    ...    2. Configuration
    ...         gNBs host following cells:
    ...                                 Cell-1    Cell-2    Cell-3    Cell-4    Cell-5    Cell-6    cell-7     cell-8
    ...    Technology                    TDD      TDD      TDD        TDD        TDD       TDD       TDD       TDD
    ...          Band                    n257     n257     n257       n257       n257      n257      n257      n257
    ...           Pci                     50       51       52         53         54       55         56       57
    ...     Bandwidth                    100      100      100        100        100       100       100       100
    ...            BF                    Yes      Yes      Yes        Yes        Yes       Yes       Yes       Yes
    ...         Arfcn              2071591    2073257    2074923    2076589    2078255    2079921    2081587    2083253
    ...    maxNumOfUsersPerNRCell        275      275      275        275        275       275       275       275
    ...    maxNumOfSCellAlloc            250      250      250        250        250       250       250       250
    ...        LCELNR                   DL/UL    DL/UL    DL/UL      DL/UL      DL         DL        DL        DL
    ...    weightForSCellSelection    all cells are 50
    ...    3. Test Case Steps:
    ...           a. Modify actCarrierAggregationFr2SA to false.
    ...           b. UE1 attach to cell-1, setup PDU session and then start traffic.
    ...           c. Modify actCarrierAggregationFr2SA to true.
    ...           d. UE1 release.
    ...           e. UE1 attach to cell-1, setup PDU session.
    ...           f. Start UE1 traffic.
    ...           g. UE2 attach to cell-1, setup PDU session.
    ...           h. Start traffic.
    ...           i. UE3 attach to cell-1
    ...           j. Modify actCarrierAggregationFr2SA to false.
    ...           k. Release all UEs
    ...           l. UE1 attach to cell-1, setup PDU session and then start traffic.
    ...           m. UE2 attach to cell-1, setup PDU session and then start traffic.
    ...           n. Release all UEs.
    ...    4. Expected Results:
    ...           a. Parameter modify successfully.
    ...           b. Setup PDU session successfully and no CA scell added, traffic is on going as expect.
    ...           c. UE1 is not impacted, traffic is still on going as expect.
    ...           d. UE1 release successfully.
    ...           e. UE1 8Dl/4UL CA setup successfully.
    ...           f. UE1 traffic is ok as expect.
    ...           e. UE2 8Dl/4UL CA setup successfully.
    ...           f. UE2 traffic is ok as expect.
    ...           i. UE3 attach to cell-1 successfully.
    ...           j. Modify actCarrierAggregationFr2SA to false successfully.
    ...           k. Release all UEs successfully.
    ...           l. UE1 setup PDU session successfully and no CA scell added.
    ...           m. UE2 setup PDU session successfully and no CA scell added.
    ...           n. Release all UEs successfully.
    [Tags]    QC_321769    A003    CA_LABEL-8T(100Mhz_TDD_n257)
    Clear Counter files    False
    OnlineParamChange    ${A001_parameter_update}
    UE with nonCA UE1 capability Scelladd     ue_id=1
    OnlineParamChange to true    ${A002_parameter_update}    ue_id=1
    Release UE
    UE with UE1 capability Scelladd     ue_id=1    dl_cc_num=8    ul_cc_num=4    expect_regexp=${8CCDL_4CCUL_regexp}
    ...    min_dltput=410    min_ultput=160
    UE with UE1 capability Scelladd     ue_id=2    dl_cc_num=8    ul_cc_num=4    expect_regexp=${8CCDL_4CCUL_regexp}
    ...    min_dltput=410    min_ultput=160
    Sa CA UE Register     ue_id=3
    OnlineParamChange to false    ${A001_parameter_update}    ue_id=1
    Release UE    ue_id=1-3
    UE with nonCA UE1 capability Scelladd     ue_id=1
    UE with nonCA UE2 capability Scelladd     ue_id=2
    Release UE    ue_id=1-2
    Check WireShark Log    ${CURDIR}${/}A2A_A003${/}a2a.ini    wait_string=UEContextReleaseComplete::24
    Check Counters    ${A003_PM_Counters_Check}
    [Teardown]    Teardown for A003

CB008294-ET-A008-B3_UE_intra-band_CA_in_mmW_band_4DL4UL_contiguous_component_carriers_as_maxNumOf5To8CCUsersFr2Sa_set_0
    [Documentation]
    ...    1. This User Scenario shall validate asymmetric CA functionality with Analog Beamforming in mmW bands (FR2)
    ...       for multi 5G-UE scenario considering UE capabilities. when maxNumOf5To8CCUsersFr2Sa is set to "0", only
    ...       4CC will be blind added successfully.
    ...    2. Configuration
    ...         gNBs host following cells:
    ...                                 Cell-1    Cell-2    Cell-3    Cell-4    Cell-5    Cell-6    cell-7     cell-8
    ...    Technology                    TDD      TDD      TDD        TDD        TDD       TDD       TDD       TDD
    ...          Band                    n257     n257     n257       n257       n257      n257      n257      n257
    ...           Pci                     50       51       52         53         54       55         56       57
    ...     Bandwidth                    100      100      100        100        100       100       100       100
    ...            BF                    Yes      Yes      Yes        Yes        Yes       Yes       Yes       Yes
    ...         Arfcn               2071591    2073257    2074923    2076589    2078255    2079921    2081587    2083253
    ...    maxNumOfUsersPerNRCell        275      275      275        275        275       275       275       275
    ...    maxNumOfSCellAlloc            250      250      250        250        250       250       250       250
    ...        LCELNR                   DL/UL    DL/UL    DL/UL      DL/UL      DL         DL         DL        DL
    ...    weightForSCellSelection    all cells are 50
    ...    3. Test Case Steps:
    ...           a. Set maxNumOf5To8CCUsersFr2SA to 0
    ...           b. UE1 attach to cell-1.
    ...           c. Setup PDU session.
    ...           d. Start traffic.
    ...           e. UE1 release.
    ...    4. Expected Results:
    ...           a. Parameter modify successfully.
    ...           b. UE1 is attch to cell-1 as PScell successfully.
    ...           c. Setup PDU session and then scell blind add (CA_cell-1, cell-2, cell-3 and cell-4) successfully.
    ...           d. Traffic is ok as expect on PScell and Scell.
    ...           e. UE1 release successfully.
    [Tags]    QC_321770    A008    CA_LABEL-4T(100Mhz_TDD_n257)
    Clear Counter files    True
    OnlineParamChange    ${A008_parameter_update}
    UE with UE1 capability Scelladd     ue_id=1    dl_cc_num=4    ul_cc_num=4    expect_regexp=${A008_expect_regexp}
    ...    min_dltput=410    min_ultput=160
    Release UE
    Check WireShark Log    ${CURDIR}${/}A2A_A008${/}a2a.ini    wait_string=UEContextReleaseComplete::4
    Check Counters    ${A008_PM_Counters_Check}
    [Teardown]    Teardown for A008

CB008294-ET-A017-B3_mutli-UE_intra-band_CA_in_mmW_band_with_8CCs_DL_and_4CCs_UL_contiguous_component_carriers
    [Documentation]
    ...    1. This User Scenario shall validate asymmetric CA functionality with Analog Beamforming in mmW bands (FR2)
    ...       for multi 5G-UE scenario considering UE capabilities. when Pcell use frequency in lowest 8CC will be blind
    ...       added successfully. The number of scells addition is depended on the value of maxNumOf5To8CCUsersFr2SA,
    ...       maxNumOf3To4CCUsersFr2SA and maxNumOf2CCUsersFr2SA.
    ...    2. Configuration
    ...         gNBs host following cells:
    ...                                 Cell-1    Cell-2    Cell-3    Cell-4    Cell-5    Cell-6    cell-7     cell-8
    ...    Technology                    TDD      TDD      TDD        TDD        TDD       TDD       TDD       TDD
    ...          Band                    n257     n257     n257       n257       n257      n257      n257      n257
    ...           Pci                     50       51       52         53         54       55         56       57
    ...     Bandwidth                    100      100      100        100        100       100       100       100
    ...            BF                    Yes      Yes      Yes        Yes        Yes       Yes       Yes       Yes
    ...         Arfcn              2071591    2073257    2074923    2076589    2078255    2079921    2081587    2083253
    ...    maxNumOfUsersPerNRCell        275      275      275        275        275       275       275       275
    ...    maxNumOfSCellAlloc            250      250      250        250        250       250       250       250
    ...        LCELNR                   DL/UL    DL/UL    DL/UL      DL/UL      DL         DL        DL        DL
    ...    weightForSCellSelection    all cells are 50
    ...    3. Test Case Steps:
    ...           a. Modify maxNumOf5To8CCUsersFr2SA, maxNumOf3To4CCUsersFr2SA and maxNumOf2CCUsersFr2SA value to 1
    ...           b. UE1 attach to cell-1, setup PDU session.
    ...           c. Start traffic.
    ...           d. UE2 attach to cell-1, setup PDU session.
    ...           e. Start traffic.
    ...           f. UE3 attach to cell-1, setup PDU session.
    ...           g. Start traffic.
    ...           h. UE4 attach to cell-1, setup PDU session.
    ...           i. Start traffic.
    ...           j. Release all UEs.
    ...    4. Expected Results:
    ...           a. Parameter modify successfully.
    ...           b. UE1 8DL/4UL CA setup successfully.
    ...           c. UE1 traffic is ok as expect.
    ...           d. UE2 4DL/4UL CA setup successfully.
    ...           e. UE2 traffic is ok as expect.
    ...           f. UE3 2DL/2UL CA setup successfully.
    ...           g. UE3 traffic is ok as expect.
    ...           h. UE4 non-CA setup successfully.
    ...           i. UE4 traffic is ok as expect.
    ...           j. Release all UEs successfully.
    [Tags]     QC_321788    A017    CA_LABEL-8T(100Mhz_TDD_n257)
    Clear Counter files    True
    OnlineParamChange    ${A017_parameter_update}
    UE with UE1 capability Scelladd     ue_id=1    dl_cc_num=8    ul_cc_num=4    expect_regexp=${8CCDL_4CCUL_regexp}
    ...    min_dltput=410    min_ultput=160
    UE with UE1 capability Scelladd     ue_id=2    dl_cc_num=4    ul_cc_num=4    expect_regexp=${A008_expect_regexp}
    ...    min_dltput=410    min_ultput=160
    UE with UE1 capability Scelladd     ue_id=3    dl_cc_num=2    ul_cc_num=2    expect_regexp=${A017_expect_regexp}
    ...    min_dltput=380    min_ultput=150
    UE with nonCA UE4 capability Scelladd     ue_id=4
    Release UE    ue_id=1-4
    Check WireShark Log    ${CURDIR}${/}A2A_A017${/}a2a.ini    wait_string=UEContextReleaseComplete::16
    Check Counters    ${A017_PM_Counters_Check}
    [Teardown]    Teardown for A017

CB008294-ET-A018_online_modify_parameter_caConfigurationSupportFr2SA_maxNumScellsDlFr2SA_and_maxNumScellsUlFr2SA
    [Documentation]
    ...    1. This User Scenario shall validate asymmetric CA functionality with Analog Beamforming in mmW bands (FR2) for multi 5G-UE scenario
    ...       considering UE capabilities. when caConfigurationSupportFr2SA is set to "4CCDL_2CCUL", only 4CC DL 2CC UL CA will be blind added
    ...       successfully, when it is set to "2CCDL_2CCUL", only 2CC DL 2CC UL CA will be successful, CC number alse determined by paramerter
    ...       'maxNumScellsDlFr2SA' and 'maxNumScellsUlFr2SA'.
    ...    2. Configuration
    ...         gNBs host following cells:
    ...                                 Cell-1    Cell-2    Cell-3    Cell-4    Cell-5    Cell-6    cell-7     cell-8
    ...    Technology                    TDD      TDD      TDD        TDD        TDD       TDD       TDD       TDD
    ...          Band                    n257     n257     n257       n257       n257      n257      n257      n257
    ...           Pci                     50       51       52         53         54       55         56       57
    ...     Bandwidth                    100      100      100        100        100       100       100       100
    ...            BF                    Yes      Yes      Yes        Yes        Yes       Yes       Yes       Yes
    ...         Arfcn               2071591    2073257    2074923    2076589    2078255    2079921    2081587    2083253
    ...    maxNumOfUsersPerNRCell        275      275      275        275        275       275       275       275
    ...    maxNumOfSCellAlloc            250      250      250        250        250       250       250       250
    ...        LCELNR                   DL/UL    DL/UL    DL/UL      DL/UL        DL       DL        DL        DL
    ...    weightForSCellSelection    all cells are 50
    ...    3. Test Case Steps:
    ...           a. UE1 attach to cell-1, PDU setup and trigger scell addition
    ...           b. start DL,UL traffic and check traffic
    ...           c. Set caConfigurationSupportFr2SA to 4CCDL_2CCUL
    ...           d. UE2 attach to cell-1, repeat step b
    ...           e. Set caConfigurationSupportFr2SA to 2CCDL_2CCUL
    ...           f. UE3 attach to cell-1, repeat step b
    ...           g. Set caConfigurationSupportFr2SA to 8CCDL_4CCUL and maxNumScellsDlFr2SA=5 maxNumScellsUlFr2SA=2
    ...           h. UE4 attach to cell-1, repeat step b
    ...           i. release all UEs.
    ...    4. Expected Results:
    ...           a. UE1 is configured with 8CC(cell1+cell2,cell3,cell4,cell5,cell6,cell7,cell8) dl 4CC(cell1+cell2,cell3,cell4) ul
    ...           b. DL/UL traffic is ok
    ...           c. Parameter modify successfully.
    ...           d. UE2 is configured with 4CC(cell1+cell2,cell3,cell4) dl 2CC(cell1+cell2) ul, DL/UL traffic is ok
    ...           e. Parameter modify successfully.
    ...           f. UE3 is configured with 2CC(cell1+cell2) dl 2CC(cell1+cell2) ul, DL/UL traffic is ok
    ...           g. Parameter modify successfully.
    ...           h. UE4 is configured with 6CC(cell1+cell2,cell3,cell4,cell5,cell6) dl 3CC(cell1+cell2,cell3) ul, DL/UL traffic is ok
    ...           i. UE1-4 release successfully.
    [Tags]    QC_321787    A018_19    CA_LABEL-8T(100Mhz_TDD_n257)    CA_LABEL-6T(100Mhz_TDD_n257)
    ...    CA_LABEL-4T(100Mhz_TDD_n257)    CA_LABEL-2T(100Mhz_TDD_n257)
    Clear Counter files    True
    UE register and blind CA successful    ue_id=1    PDU_regexp=${8CCDL_4CCUL_regexp}    DLCC_num=8    ULCC_num=4    dltput=270    ultput=90
    OnlineParamChange    NRBTS:caConfigurationSupportFr2SA=4CCDL_2CCUL
    UE register and blind CA successful    ue_id=2    PDU_regexp=${4CCDL_2CCUL_regexp}    DLCC_num=4    ULCC_num=2    dltput=270    ultput=90
    OnlineParamChange    NRBTS:caConfigurationSupportFr2SA=2CCDL_2CCUL
    UE register and blind CA successful    ue_id=3    PDU_regexp=${2CCDL_2CCUL_regexp}    DLCC_num=2    ULCC_num=2    dltput=270    ultput=90
    OnlineParamChange    ${A019_parameter_update}
    UE register and blind CA successful    ue_id=4    PDU_regexp=${6CCDL_3CCUL_regexp}    DLCC_num=6    ULCC_num=3    dltput=180    ultput=70
    Check UEs traffic
    Release UE and check counter and logs
    [Teardown]    Teardown for A018

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sa_mmwv/FS/8cells_8T_8DL_4UL_ecpri

Teardown for A003
    OnlineParamChange    ${A003_parameter_recover}
    Common Test Teardown And Stop Capture Logs

Teardown for A008
    OnlineParamChange    ${A008_parameter_recover}
    Common Test Teardown And Stop Capture Logs

Teardown for A017
    OnlineParamChange    ${A017_parameter_recover}
    Common Test Teardown And Stop Capture Logs

UE with UE1 capability Scelladd
    [Arguments]    ${ue_id}=1    ${dl_cc_num}=2    ${ul_cc_num}=2    ${expect_regexp}=${EMPTY}    ${min_dltput}=410    ${min_ultput}=160
    Set UE Capability    ue_id=${ue_id}    UE_Capabilities=${CAPA_CB008294_A_8CC_n257}
    SA CA UE Setup PDU Session And Check CA Addition Successfully    ue_id=${ue_id}    expect_regexp=${expect_regexp}
    Traffic Send    ue_id=${ue_id}
    Throughput Check    ue_id=${ue_id}    min_ultput=${min_ultput}    min_dltput=${min_dltput}    dl_cc_num=${dl_cc_num}    ul_cc_num=${ul_cc_num}
    Scell Throughput Check    ue_id=${ue_id}    dl_cc_num=${dl_cc_num}

UE with nonCA UE1 capability Scelladd
    [Arguments]    ${ue_id}=1
    Set UE Capability    ue_id=${ue_id}    UE_Capabilities=${CAPA_CB008294_A_8CC_n257}
    SA nonCA UE Setup PDU Session And Check nonCA Addition Successfully    ue_id=${ue_id}
    Traffic Send    ue_id=${ue_id}
    sleep    15s    #wait for UE4 taffic stable.
    Throughput Check on Target Cell with MultiUEs    type=pdsch    min_tput=410    ue_start=1    ue_stop=1
    Throughput Check on Target Cell with MultiUEs    type=pusch    min_tput=108    ue_start=1    ue_stop=1

UE with nonCA UE2 capability Scelladd
    [Arguments]    ${ue_id}=2
    Set UE Capability    ue_id=${ue_id}    UE_Capabilities=${CAPA_CB008294_A_8CC_n257}
    SA nonCA UE Setup PDU Session And Check nonCA Addition Successfully    ue_id=${ue_id}
    Traffic Send    ue_id=${ue_id}
    sleep    15s    #wait for UE4 taffic stable.
    Throughput Check on Target Cell with MultiUEs     type=pdsch    min_tput=205    ue_start=2    ue_stop=2
    Throughput Check on Target Cell with MultiUEs     type=pusch    min_tput=54    ue_start=2    ue_stop=2

UE with nonCA UE4 capability Scelladd
    [Arguments]    ${ue_id}=1
    Set UE Capability    ue_id=${ue_id}    UE_Capabilities=${CAPA_CB008294_A_8CC_n257}
    SA nonCA UE Setup PDU Session And Check nonCA Addition Successfully    ue_id=${ue_id}
    Traffic Send    ue_id=${ue_id}
    sleep    15s    #wait for UE4 taffic stable.
    Throughput Check on Target Cell with MultiUEs     type=pdsch    min_tput=0    ue_start=4    ue_stop=4
    Throughput Check on Target Cell with MultiUEs     type=pusch    min_tput=0    ue_start=4    ue_stop=4
    Throughput Check on Target Cell with MultiUEs     type=pdsch    min_tput=400    ue_start=1    ue_stop=4
    Throughput Check on Target Cell with MultiUEs     type=pusch    min_tput=108    ue_start=1    ue_stop=4

Release UE
    [Arguments]    ${ue_id}=1
    Release Ues    ue_type=sa    ue_id=${ue_id}

Sa CA UE Register
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${gnb_id}=2
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=${gnb_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered

SA CA UE Setup PDU Session And Check CA Addition Successfully
    [Arguments]    ${ue_id}=1    ${expect_regexp}=${EMPTY}
    Sa CA UE Register    ue_id=${ue_id}    gnb_id=2    cell_id=1
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    sim_debug_log level=4
    Execute Egate Command    uec_l2_testmode_params fixed_csi_report=true
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    pass_regexp=${expect_regexp}

SA nonCA UE Setup PDU Session And Check nonCA Addition Successfully
    [Arguments]    ${ue_id}=1
    Sa CA UE Register    ue_id=${ue_id}    gnb_id=2    cell_id=1
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    sim_debug_log level=4
    Execute Egate Command    uec_l2_testmode_params fixed_csi_report=true
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    fail_regexp=${unexpect_regexp}

Traffic Send
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=2 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=3 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=8 mbps=175    UE ${ue_id}: UDP UL

Throughput Check
    [Arguments]    ${ue_id}=1    ${dl_cc_num}=7    ${ul_cc_num}=4    ${min_ultput}=160    ${min_dltput}=410    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    Throughput Check with Type    ue_id=${ue_id}    type=pusch    CC_num=${ul_cc_num}      min_tput=${min_ultput}
    Throughput Check with Type    ue_id=${ue_id}    type=pdsch    CC_num=${dl_cc_num}      min_tput=${min_dltput}

Throughput Check with Type
    [Arguments]    ${ue_id}=1    ${type}=pdsch    ${CC_num}=4    ${min_tput}=410
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-${CC_num} type=${type}    pass_regexp=Average
    ${all_tput}    set variable    0
    FOR    ${id}    IN RANGE    0    ${CC_num}
        ${sid}    convert to string    ${id}
        ${scell_tput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=${sid}    type=${type}    rate_type=ave
        ${all_tput}    Evaluate    ${all_tput}+${scell_tput}
    END
    Should Be True    ${all_tput}/1000 > ${min_tput}

Set UE Capability
    [Arguments]    ${ue_id}=1    ${UE_Capabilities}=${SA_Capa_perUE_Full}
    Execute Egate Command    ue_param id=${ue_id} ue_nr_capabilities=${UE_Capabilities}

OnlineParamChange to true
    [Arguments]    ${Online_Param}    ${ue_id}=1
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${False}
    Throughput Check on Target Cell with MultiUEs     type=pdsch    min_tput=405    ue_start=1    ue_stop=1
    Throughput Check on Target Cell with MultiUEs     type=pusch    min_tput=108    ue_start=1    ue_stop=1

Throughput Check on Target Cell with MultiUEs
    [Arguments]    ${type}=pdsch    ${scell_id}=0    ${min_tput}=410    ${ue_start}=1    ${ue_stop}=5
    ${all_tput}    set variable    0
    FOR    ${id}    IN RANGE    ${ue_start}    ${${ue_stop}+1}
        ${ue_index}    convert to string    ${id}
        ${scell_tput}    Ap Get Throuput On Specific Scell     ue_id=${ue_index}    scell_id=${scell_id}    type=${type}    rate_type=ave
        Should Be True    ${scell_tput}/1000 > 0
        ${all_tput}    Evaluate    ${all_tput}+${scell_tput}
    END
    Should Be True    ${all_tput}/1000 > ${min_tput}

OnlineParamChange to false
    [Arguments]    ${Online_Param}    ${ue_id}=1
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${False}
    Traffic Send    ue_id=${ue_id}
    Throughput Check    ue_id=${ue_id}    dl_cc_num=8    ul_cc_num=4    min_dltput=410    min_ultput=160
    Traffic Send    ue_id=2
    Throughput Check    ue_id=2    dl_cc_num=8    ul_cc_num=4    min_dltput=410    min_ultput=160
    Execute Egate Command    set_pdu_param ue=3 pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=3 pdu=1 nwslice=1 gw=1    fail_regexp=${unexpect_regexp}
    Traffic Send    ue_id=3
    Throughput Check    ue_id=3    dl_cc_num=1    ul_cc_num=1    min_dltput=390    min_ultput=100

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${False}

Scell Throughput Check
    [Arguments]    ${ue_id}=1    ${dl_cc_num}=2
    [Return]    ${scell_tput}
    FOR    ${id}    IN RANGE    0    ${dl_cc_num}
        ${id}=    convert to string    ${id}
        ${scell_tput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=${id}    type=pdsch    rate_type=ave
        Should Be True    ${scell_tput}/1000 > 0
    END

UE register and blind CA successful
    [Arguments]    ${ue_id}=1    ${PDU_regexp}=activated    ${DLCC_num}=8    ${ULCC_num}=4    ${dltput}=270    ${ultput}=90
    SA CA UE Setup PDU Session And Check CA Addition Successfully    ue_id=${ue_id}    expect_regexp=${PDU_regexp}
    Start traffic    ue_id=${ue_id}
    DL UL Throughput Check    ue_id=${ue_id}    dl_cc_num=${DLCC_num}    ul_cc_num=${ULCC_num}    min_dltput=${dltput}    min_ultput=${ultput}

Check UEs traffic
    DL UL Throughput Check    ue_id=3    dl_cc_num=2    ul_cc_num=2    min_dltput=150    min_ultput=70
    DL UL Throughput Check    ue_id=2    dl_cc_num=4    ul_cc_num=2    min_dltput=150    min_ultput=70
    DL UL Throughput Check    ue_id=1    dl_cc_num=8    ul_cc_num=4    min_dltput=150    min_ultput=70

Release UE and check counter and logs
    Release UEs    ue_type=all
    Check WireShark Log    ${CURDIR}${/}A2A_A018${/}a2a.ini    wait_string=UEContextReleaseComplete::16
    Check Counters    ${A018_PM_Counters_Check}

Start traffic
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=2 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=8 mbps=100    UE ${ue_id}: UDP UL

DL UL Throughput Check
    [Arguments]    ${ue_id}=1    ${dl_cc_num}=7    ${ul_cc_num}=4    ${min_ultput}=160    ${min_dltput}=410    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    Check Pcell and Scell Throughput    ue_id=${ue_id}    type=pdsch    CC_num=${dl_cc_num}    min_tput=${min_dltput}
    Check Pcell and Scell Throughput    ue_id=${ue_id}    type=pusch    CC_num=${ul_cc_num}    min_tput=${min_ultput}

Check Pcell and Scell Throughput
    [Arguments]    ${ue_id}=1    ${type}=pdsch    ${CC_num}=4    ${min_tput}=410
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-${CC_num} type=${type}    pass_regexp=Average
    ${all_tput}    set variable    0
    FOR    ${id}    IN RANGE    0    ${CC_num}
        ${sid}    convert to string    ${id}
        ${scell_tput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=${sid}    type=${type}    rate_type=ave
        Should Be True    ${scell_tput}/1000 > 0
        ${all_tput}    Evaluate    ${all_tput}+${scell_tput}
    END
    Should Be True    ${all_tput}/1000 > ${min_tput}

Teardown for A018
    OnlineParamChange    ${A018_parameter_recover}
    Common Test Teardown And Stop Capture Logs

