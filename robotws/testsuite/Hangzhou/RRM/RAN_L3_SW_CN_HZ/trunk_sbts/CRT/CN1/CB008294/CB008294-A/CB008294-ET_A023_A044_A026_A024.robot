*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CLOUD_5G_I_BOO_AP_LOO    team-CN1ET
...    owner-dandan.chen    release-SBTS24R2    CRT
Resource    ../../../../../resources/DevHZ5_resource.robot

Documentation    Suite description
...   author:      Yuhua Zhu
...   contact:     yuhua.zhu@nokia-sbell.com
...   squad group: MMW_SG7
...   Feature:     CB0012207

*** Variables ***
${DEBUG_LOG_LEVEL}    4
#${SYSCOM_FLAG}    ${True}
${GNB_BIP_FLAG}    ${True}
${SOS_REPORT_FLAG}    pass:True,fail:True

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_other}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_A2_disable}
...    @{PARAMS_FOR_measurement_relate}
...    @{PARAMS_FOR_beam_relate}
...    @{PARAMS_FOR_csirs_use_dataSlot_firstly}

@{PARAMS_FOR_other}
...    NRBTS:actIpThpt=true
...    NRBTS:actMacUserThpt=true
...    NRBTS:actCsiReportsMuxOnPucch=false
...    TNL-1/ETHSVC-1/ETHLK-1:l2IngressRate=10000000
...    MRBTS-1/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1/BRGPRT-1:l2ShaperRate=10000000
...    NRCELL:type0SearchSpaceConfigurationIndex=2
...    NRCELL:actCDrx=false
...    NRBTS:cipherPrefL:nea0=1

@{PARAMS_FOR_csirs_use_dataSlot_firstly}
...    NRCELL:actPciBasedCsiImRandomization=true

@{PARAMS_FOR_beam_relate}
...    NRCELL:actBeamforming=true
...    NRCELL-1:actRrcReconfigAtBeamSwitch=false
...    NRSYSINFO_PROFILE-1/NRIRFIM-1:numberOfTransmittedSsBlocks=32 beams
...    NRCELLGRP-1:numberOfTransmittedSsBlocks=32 beams
...    NRCELL:beamSet:basicBeamSet=beamSetAbf_32A

@{PARAMS_FOR_CA}
...    NRBTS/NRDU-1:carrierAggregationSupportList=none
...    NRBTS:caConfigurationSupportFr2SA=8CCDL_4CCUL
...    NRBTS:actCarrierAggregationFr2SA=true
...    NRBTS:maxNumScellsDlFr2SA=7
...    NRBTS:maxNumScellsUlFr2SA=3
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRCELL-1:sCellOnlyFr2Sa=false
...    NRCELL-2:actProactUlSchedulingEnh=allUes
...    NRCELL-3:actProactUlSchedulingEnh=allUes
...    NRCELL-4:actProactUlSchedulingEnh=allUes
...    NRCELL-5:actProactUlSchedulingEnh=disabled
...    NRCELL-6:actProactUlSchedulingEnh=disabled
...    NRCELL-7:actProactUlSchedulingEnh=disabled
...    NRCELL-8:actProactUlSchedulingEnh=disabled
...    NRBTS:sCellActivationMethod=blind
...    NRCELL:sCellDeactivationTimerGNB=infinity

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

@{A023_parameter_update}
...    NRBTS:maxNumScellsDlFr2SA=7
...    NRBTS:maxNumScellsUlFr2SA=3
...    NRBTS:actCarrierAggregationFr2SA=true
...    NRBTS:actCsiReportsMuxOnPucch=true
...    NRCELLGRP-1:pucchF2MaxCodeRate=zeroDot25
...    NRCELL-1:periodicCsiAcquisition:csiReportPeriodicity=slots320
...    NRCELL:maxNumOf5To8CCUsersFr2SA=10

@{A023_parameter_update_recover}
...    NRBTS:actCsiReportsMuxOnPucch=false

@{A026_parameter_update}
...    NRBTS:maxNumScellsDlFr2SA=3
...    NRBTS:maxNumScellsUlFr2SA=3
...    NRBTS:actCarrierAggregationFr2SA=true
...    NRBTS:actCsiReportsMuxOnPucch=true
...    NRCELLGRP-1:pucchF2MaxCodeRate=zeroDot25
...    NRCELL-1:periodicCsiAcquisition:csiReportPeriodicity=slots320
...    NRCELL:maxNumOf5To8CCUsersFr2SA=10

@{A026_parameter_update_recover}
...    NRBTS:maxNumScellsDlFr2SA=7
...    NRBTS:actCsiReportsMuxOnPucch=false

@{A026_actCsiReportsMuxOnPucch_false}
...    NRBTS:actCsiReportsMuxOnPucch=false

@{A024_parameter_update}
...    NRBTS:maxNumScellsDlFr2SA=7
...    NRBTS:maxNumScellsUlFr2SA=3
...    NRBTS:actCarrierAggregationFr2SA=true
...    NRBTS:actCsiReportsMuxOnPucch=true
...    NRCELLGRP-1:pucchF2MaxCodeRate=zeroDot15
...    NRCELL-1:periodicCsiAcquisition:csiReportPeriodicity=slots320
...    NRCELL:maxNumOf5To8CCUsersFr2SA=10
...    NRCELL:actBeamforming=false
...    NRCELL-1:actRrcReconfigAtBeamSwitch=false
...    NRCELLGRP-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL:beamSet:basicBeamSet=beamSetAbf_1A


@{A024_parameter_update_recover}
...    @{PARAMS_FOR_beam_relate}
...    NRCELLGRP-1:pucchF2MaxCodeRate=zeroDot25

#8CC UEcapa with percc 5 allcc5 n257_maxconfigureResourceallcc_256
${SA_Capa_8T_percc_5_allcc5_n257_maxconfigureResourceallcc_256}    SEPARATOR=
#...    E1A25000574F7603564803C4280058084400090020C008120C7A023D801E099321CF916BD055EC12F40CFB027C0F1E238F20020301262C01
#...    1306E41280634DA0004040140601CCE00F42B4070378E3087000A8F3F1436011FB660AA40078F0021C4106115028FDFC8106400340C00580
#...    38FC71689003000804020068029150AD00DE38C21C002A3CFC50D8047ED982A9001E3C008710418414123F7F20419000D03001600E3F1C5A
#...    2400C0020100801A00A401081D001430000A81D003080021004004101170001501403678F2E01B3C7801FB410000BD00F8009000C0026810
#...    168240500603009401800180F80324A00C0000000000392500E008020080200802008021802DE2B74A008200800000000082018020080200
#...    80000802AF54576A05A01F00340A00028400530022002000089000004000000480000200000000010008010020010040082A14A20B0C6E74
#...    1B300480

...    E1A25000574F7603564803C5280016021100024008300204831E808F60078264C873E45AF4157B04BD033EC09F03C788E3C80080C0498B00
...    44C1B905A00C69B40008080280C0399C01E85680E06F1C610E00151E7E288C008FDB30552003C78010E208308A8147EFE40832001A06002C
...    01C7E38D4480060010080400D00522A15A01BC718438005479F8A230023F6CC154800F1E00438820C20A091FFF9020C800681800B0071F8E
...    3512001800402010034014802103A002860001503A006100042008008202360000A80A01B3C79700D9E3C00FDA080007E801F00120018004
...    D0202D0480A00C06012803000301F0064940180000000000724A01C010040100401004010043005BC56E9401040100000000010403004010
...    0401000010055EA8AED40F400F801A050001420029801100100004480000200000024000010000000000800400801000802004150A510586
...    373A0D980240


#8CC UEcapa with percc 5 allcc8
${SA_Capa_8T_percc_5_allcc8}    SEPARATOR=
...    E1A25000574F7603564803C4280058084400090020C008120C7A023D801E099321CF916BD055EC12F40CFB027C0F1E238F20020301262C01
...    1306E41280634DA0004040140601CCE00F42B4070378E3087000A8F3F1436011FB660AA40078F0021C4106115028FDFC8106400340C00580
...    38FC71689003000804020068029150AD00DE38C21C002A3CFC50D8047ED982A9001E3C008710418414123F7F20419000D03001600E3F1C5A
...    2400C0020100801A00A401081D001430000A81D003080021004004101170001501403678F2E01B3C7861FB410000BD00F8009000C0026810
...    168240500603009401800180F80324A00C0000000000392500E008020080200802008021802DE2B74A008200800000000082018020080200
...    80000802AF54576A05A01F00340A00028400530022002000089000004000000480000200000000010008010020010040082A14A20B0C6E74
...    1B300480



#8CC UEcapa with percc 5 allcc10
${SA_Capa_8T_percc_5_allcc10}    SEPARATOR=
...    E1A25000574F7603564803C4280058084400090020C008120C7A023D801E099321CF916BD055EC12F40CFB027C0F1E238F20020301262C01
...    1306E41280634DA0004040140601CCE00F42B4070378E3087000A8F3F1436011FB660AA40078F0021C4106115028FDFC8106400340C00580
...    38FC71689003000804020068029150AD00DE38C21C002A3CFC50D8047ED982A9001E3C008710418414123F7F20419000D03001600E3F1C5A
...    2400C0020100801A00A401081D001430000A81D003080021004004101170001501403678F2E01B3C78A1FB410000BD00F8009000C0026810
...    168240500603009401800180F80324A00C0000000000392500E008020080200802008021802DE2B74A008200800000000082018020080200
...    80000802AF54576A05A01F00340A00028400530022002000089000004000000480000200000000010008010020010040082A14A20B0C6E74
...    1B300480

@{4DL4UL_expect_regexp}
...    pcid:50, scellIdx:0] configure_0_1
...    pcid:51, scellIdx:1] configure_0_1
...    pcid:52, scellIdx:2] configure_0_1
...    pcid:53, scellIdx:3] configure_0_1
...    pcid:50, scellIdx:0] configure_1_1
...    pcid:51, scellIdx:1] configure_1_1
...    pcid:52, scellIdx:2] configure_1_1
...    pcid:53, scellIdx:3] configure_1_1
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 3 activated successfully at airphone

@{8DL4UL_expect_regexp}
...    pcid:50, scellIdx:0] configure_0_1
...    pcid:51, scellIdx:1] configure_0_1
...    pcid:52, scellIdx:2] configure_0_1
...    pcid:53, scellIdx:3] configure_0_1
...    pcid:50, scellIdx:0] configure_1_1
...    pcid:51, scellIdx:1] configure_1_1
...    pcid:52, scellIdx:2] configure_1_1
...    pcid:53, scellIdx:3] configure_1_1
...    pcid:54, scellIdx:4] configure_1_1
...    pcid:55, scellIdx:5] configure_1_1
...    pcid:56, scellIdx:6] configure_1_1
...    pcid:57, scellIdx:7] configure_1_1
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 3 activated successfully at airphone
...    SCellIndex 4 activated successfully at airphone
...    SCellIndex 5 activated successfully at airphone
...    SCellIndex 6 activated successfully at airphone
...    SCellIndex 7 activated successfully at airphone

@{Beamswitch_expect_regexp}
...    pcid:50, scellIdx:0] configure_0_1
...    pcid:51, scellIdx:1] configure_0_1
...    pcid:52, scellIdx:2] configure_0_1
...    pcid:53, scellIdx:3] configure_0_1
...    pcid:50, scellIdx:0] configure_1_1
...    pcid:51, scellIdx:1] configure_1_1
...    pcid:52, scellIdx:2] configure_1_1
...    pcid:53, scellIdx:3] configure_1_1
...    pcid:54, scellIdx:4] configure_1_1
...    pcid:55, scellIdx:5] configure_1_1
...    pcid:56, scellIdx:6] configure_1_1
...    pcid:57, scellIdx:7] configure_1_1


@{A023_PM_Counters_Check}
...    NRCELL-1:RSADU:${GNB_DU_SCELL_7_ADMI_REQ_SA}=2
...    NRCELL-1:RSADU:${GNB_DU_SCELL_7_ADMI_SUCC_SA}=2
...    NRCELL-1:NCAC:${RRC_RECONF_ADD7DLSCELL_ATT_SA}=2
...    NRCELL-1:NCAC:${RRC_RECONF_ADD7DLSCELL_SUCC_SA}=2
...    NRCELL-1:NCAC:${UE_PCELL_7_CONF_SCELL_DL_SA}>0
...    NRCELL-1:RSACU:${GNB_SCELL_7_ADMI_REQ_SA}=2
...    NRCELL-1:RSACU:${GNB_SCELL_7_ADMI_SUCC_SA}=2
...    NRCELL-1:CUCM:${MAX_UE_PCELL_3_CONF_SCEL_UL_SA}>=1
...    NRCELL-1:CUCM:${MAX_UE_PCELL_7_CONF_SCEL_DL_SA}>=1
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

@{A024_PM_Counters_Check}
...    NRCELL-1:RSADU:${GNB_DU_SCELL_7_ADMI_REQ_SA}=1
...    NRCELL-1:RSADU:${GNB_DU_SCELL_7_ADMI_SUCC_SA}=1
...    NRCELL-1:NCAC:${RRC_RECONF_ADD7DLSCELL_ATT_SA}=1
...    NRCELL-1:NCAC:${RRC_RECONF_ADD7DLSCELL_SUCC_SA}=1
...    NRCELL-1:NCAC:${UE_PCELL_7_CONF_SCELL_DL_SA}>0
...    NRCELL-1:RSACU:${GNB_SCELL_7_ADMI_REQ_SA}=1
...    NRCELL-1:RSACU:${GNB_SCELL_7_ADMI_SUCC_SA}=1
...    NRCELL-1:CUCM:${MAX_UE_PCELL_3_CONF_SCEL_UL_SA}>=1
...    NRCELL-1:CUCM:${MAX_UE_PCELL_7_CONF_SCEL_DL_SA}>=1
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

@{A026_PM_Counters_Check}
...    NRCELL-1:NCAC:${RRC_RECONF_ADD3DLSCELL_ATT_SA}=2
...    NRCELL-1:NCAC:${RRC_RECONF_ADD3DLSCELL_SUCC_SA}=2
...    NRCELL-1:NCAC:${UE_PCELL_3_CONF_SCELL_DL_SA}>0
...    NRCELL-1:RSADU:${GNB_DU_SCELL_3_ADMI_REQ_SA}=2
...    NRCELL-1:RSADU:${GNB_DU_SCELL_3_ADMI_SUCC_SA}=2
...    NRCELL-1:RSACU:${GNB_SCELL_3_ADMI_SUCC_SA}=2
...    NRCELL-2:NCAC:${UE_SCELL_3_CONF_SCELL_DL_SA}>0
...    NRCELL-3:NCAC:${UE_SCELL_3_CONF_SCELL_DL_SA}>0
...    NRCELL-4:NCAC:${UE_SCELL_3_CONF_SCELL_DL_SA}>0

...    NRCELL-1:NCAC:${UE_PCELL_3_CONF_SCELL_UL_SA}>0
...    NRCELL-1:RSACU:${GNB_SCELL_7_ADMI_REQ_SA}=0
...    NRCELL-1:CUCM:${MAX_UE_PCELL_3_CONF_SCEL_UL_SA}>=1
...    NRCELL-1:CUCM:${MAX_UE_PCELL_3_CONF_SCEL_DL_SA}>=1
...    NRCELL-2:NCAC:${UE_SCELL_3_CONF_SCELL_UL_SA}>0
...    NRCELL-3:NCAC:${UE_SCELL_3_CONF_SCELL_UL_SA}>0
...    NRCELL-4:NCAC:${UE_SCELL_3_CONF_SCELL_UL_SA}>0

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
${GNB_SCELL_3_ADMI_SUCC_SA}    M55138C03002
#This counter indicates the number of successful radio admission requests for exactly 3
#SCells before the CA configuration on RRC. It's measured in the PCell in SA mode only.
${MAX_UE_PCELL_3_CONF_SCEL_UL_SA}    M55156C00022
#This counter shows the maximum of samples for the total number of CA UEs in the
#current cell configured as a PCell, which have 3 configured SCells in UL.
${MAX_UE_PCELL_3_CONF_SCEL_DL_SA}    M55156C00025
#This counter shows the maximum of samples for the total number of CA UEs in the current cell configured as a PCell,
#which have 3 configured SCells in DL.
${UE_SCELL_3_CONF_SCELL_UL_SA}    M55118C00017
#This counter shows the sum of samples for the total number of CA UEs in the current
#cell configured as a UL SCell while pegged in the secondary cell, which have 3 configured SCells in UL.
${UE_SCELL_3_CONF_SCELL_DL_SA}    M55118C11009
#The sum of samples for total number of CA UEs in the current cell configured as an
#SCell while pegged in the secondary cell, which have three configured SCells in DL in SA mode.

*** Test Cases ***
CB008294-ET-A023_A030_A044-CSIRSreport_multiplexing_BM_true_csireport_320slot_32ssb_simuCSI-ReportsAllCC_maxcoderate_zeroDot25_DL8cc_UL4cc
    [Documentation]
    ...    1. This User Scenario shall validate CSI Report multiplexing functionality for SA CA configured UEs
    ...    Till there is enough capacity to carry additional Report, the UE CSI Reports are configured in the same PUCCH
    ...    resource. As soon as the remained free capacity is not enough for the additional CSI-Report, a new PUCCH resource is allocated.
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
    ...    2. Test Case Steps:
    ...           a. UE_SA_Capa_8T_percc_5_allcc10 attach to cell-1, setup PDU session and then start traffic.
    ...           UE is configured with 8CC(cell1+cell2,cell3,cell4,cell5,cell6,cell7,cell8) dl 4CC(cell1+cell2,cell3,cell4) ul
    ...           CQI reports: one for pcell cqi+beam+ scellcqi (uci:7+21+7+1=36), one for other 6scells cqi(uci: 6*7=42)
    ...           But IE can not show pucchresource number as scell id is not fixed. only check use pucch reource ID=10 and
    ...           pcell CQI report and ssb report use same reportslot.
    ...           b. Beamgroup switch.
    ...           c. UE release.
    ...           a. UE_SA_Capa_8T_percc_5_allcc5 attach to cell-1, setup PDU session and then start traffic.
    ...           UE is configured with 8CC(cell1+cell2,cell3,cell4,cell5,cell6,cell7,cell8) dl 4CC(cell1+cell2,cell3,cell4) ul
    ...           CQI reports: one for pcell cqi+beam+ 2scellcqi (uci:7+21+7+1+7=43), one for other 5scells cqi(uci: 5*7=35)
    ...           But IE can not show pucchresource number as scell id is not fixed. only check use pucch reource ID=10 and
    ...           pcell CQI report and ssb report use same reportslot.
    ...           b. Beamgroup switch.
    ...           c. UE release.
    [Tags]    QC_321766    A023    CA_LABEL-8T(100Mhz_TDD_n257)
    OnlineParamChange    ${A023_parameter_update}
    Clear Counter files    ${False}
    UE attach and Scell added blindly     ue_id=1    CC_num=8    UE_Capabilities=${SA_Capa_8T_percc_5_allcc10}
	UE Beamgroup Change    ue_id=1
    Release UE    ue_id=1
    UE attach and Scell added blindly     ue_id=2    CC_num=8    UE_Capabilities=${SA_Capa_8T_percc_5_allcc5_n257_maxconfigureResourceallcc_256}
	UE Beamgroup Change UE2    ue_id=2
    Release UE    ue_id=2
    Check WireShark Log    ${CURDIR}${/}A2A_A023${/}a2a.ini    wait_string=UEContextReleaseComplete::8
    Check Counters    ${A023_PM_Counters_Check}
    check report bundle is as expected    packet_id=0    expect_v1=3    expect_v2=6
    check report bundle is as expected    packet_id=5    expect_v1=4    expect_v2=5
    [Teardown]    Teardown for CB008294    Restore_params=${A023_parameter_update_recover}

CB008294-ET-A026-CSIRS_report_multiplexing_32ssb_simultaneousCSI-ReportsAllCC_8_maxcoderate_zeroDot25_DL4cc_UL4cc_one_CQI_report
    [Documentation]
    ...    1. This User Scenario shall validate CSI Report multiplexing functionality for SA CA configured UEs
    ...    Till there is enough capacity to carry additional Report, the UE CSI Reports are configured in the same PUCCH
    ...    resource. As soon as the remained free capacity is not enough for the additional CSI-Report, a new PUCCH resource is allocated.
    ...    2. Configuration: same as above case
    ...    2. Test Case Steps:
    ...           a. UE attach to cell-1, setup PDU session and then start traffic.
    ...              IE: check 5 csirsreport for pcell and 3 scells use pucch resource and same slot.
    ...           UE is configured with 4CC(cell1+cell2,cell3,cell4) dl 4CC(cell1+cell2,cell3,cell4) ul
    ...           zeroDot25 can support maxu UCI:52. now the UCI: 7+21+1+7+7+7=50 < 52. so one CQI report is enough.
    ...           b. UE release.
    ...           c. online modify actCsiReportsMuxOnPucch_false
    ...           d. UE attach to cell-1, setup PDU session and then start traffic.
     ...           UE is configured with 4CC(cell1+cell2,cell3,cell4) dl 4CC(cell1+cell2,cell3,cell4) ul
   ...              IE: check 5 csirsreport for pcell and 3 scells use different pucch resource.
    ...           e. UE release.
    [Tags]    QC_321763    A026    CA_LABEL-4T(100Mhz_TDD_n257)
    OnlineParamChange    ${A026_parameter_update}
    Clear Counter files    True
    UE attach and Scell added blindly     ue_id=1    CC_num=4    UE_Capabilities=${SA_Capa_8T_percc_5_allcc8}
    ...    expect_regexp=${4DL4UL_expect_regexp}
    Release UE    ue_id=1
    OnlineParamChange    ${A026_actCsiReportsMuxOnPucch_false}
    UE attach and Scell added blindly     ue_id=1    CC_num=4    UE_Capabilities=${SA_Capa_8T_percc_5_allcc8}
    ...    expect_regexp=${4DL4UL_expect_regexp}
    Release UE    ue_id=1
    Check WireShark Log    ${CURDIR}${/}A2A_A026${/}a2a.ini    wait_string=UEContextReleaseComplete::8
    Check Counters    ${A026_PM_Counters_Check}
    [Teardown]    Teardown for CB008294    Restore_params=${A026_parameter_update_recover}

CB008294-ET-A024-CSIRS_report_multiplexing_BM_false_simultaneousCSI-ReportsAllCC_10_maxcoderate_zeroDot15_DL8cc_UL4cc
    [Documentation]
    ...    1. This User Scenario shall validate CSI Report multiplexing functionality for SA CA configured UEs
    ...    Till there is enough capacity to carry additional Report, the UE CSI Reports are configured in the same PUCCH
    ...    resource. As soon as the remained free capacity is not enough for the additional CSI-Report, a new PUCCH resource is allocated.
    ...    2. Configuration: same as above case, Beamform is disable.
    ...    2. Test Case Steps:
    ...           a. UE attach to cell-1, setup PDU session and then start traffic.
    ...              UE is configured with 8CC(cell1+cell2,cell3,cell4,cell5,cell6,cell7,cell8) dl 4CC(cell1+cell2,cell3,cell4) ul
    ...              UCI bits: CsirReport for CQ1, Pcell+ one Scell(7+1+7)=15,
    ...              CsiReport for CQI2, three scells (7+7+7)=21, CsirReport for CQI3 three scells(7+7+7)=21
    ...              as scell index is not fix, so only check used pucch reource=10
    ...           b. UE release.
    [Tags]    QC_321765    A024    CA_LABEL-8T(100Mhz_TDD_n257)
    OnlineParamChange    ${A024_parameter_update}
    Clear Counter files    True
    UE attach and Scell added blindly     ue_id=1    CC_num=8    UE_Capabilities=${SA_Capa_8T_percc_5_allcc10}
    Release UE    ue_id=1
    Check WireShark Log    ${CURDIR}${/}A2A_A024${/}a2a.ini    wait_string=UEContextReleaseComplete::4
    Check Counters    ${A024_PM_Counters_Check}
    [Teardown]    Teardown for CB008294    Restore_params=${A024_parameter_update_recover}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sa_mmwv/FS/8cells_8T_8DL_4UL_ecpri

Teardown for CB008294
    [Arguments]    ${Restore_params}
    OnlineParamChange    ${Restore_params}
    Common Test Teardown And Stop Capture Logs

check report bundle is as expected
    [Arguments]    ${packet_id}=0    ${expect_v1}=3    ${expect_v2}=6
    ${slots320_values}    get wireshark field value
    ...    ${SAVE LOG DIRECTORY}${/}wireshark.pcap
    ...    csi-ReportConfigToAddModList/slots320
    ...    nr-rrc.csi_ReportConfigToAddModList == 9
    ...    packet=${packet_id}
    ${unique_values}    Evaluate    list(set(${slots320_values}))
    ${value0_number}    count values in list    ${slots320_values}    ${unique_values[0]}
    ${value1_number}    count values in list    ${slots320_values}    ${unique_values[1]}
    should be true  ${value0_number}+${value1_number}==9
    should be true  ${value0_number}==${expect_v1} or ${value0_number}==${expect_v2}

UE attach and Scell added blindly
    [Arguments]    ${ue_id}=1    ${CC_num}=8    ${UE_Capabilities}=${SA_Capa_8T_percc_5_allcc10}    ${expect_regexp}=${8DL4UL_expect_regexp}
    Set UE Capability    ue_id=${ue_id}    UE_Capabilities=${UE_Capabilities}
    ${Last_RAN_UE_NGAP_ID}    SA CA UE Setup PDU Session And Check CA Addition Successfully    ue_id=${ue_id}    expect_regexp=${expect_regexp}
    Set Test Variable    \${Last_RAN_UE_NGAP_ID}
    Traffic Send    ue_id=${ue_id}
    sleep    60s    sleep for Tput stable
    Check Throughput with Type    ue_id=${ue_id}    Tput_expect=810    CC_num=${CC_num}    type=pdsch
    Check Throughput with Type    ue_id=${ue_id}    Tput_expect=310    CC_num=4    type=pusch

Release UE
    [Arguments]    ${ue_id}=1
    Release Ues    ue_type=sa    ue_id=${ue_id}

Sa CA UE Register
    [Arguments]    ${ue_id}=1    ${wait_timer}=0.5    ${cell_id}=1    ${gnb_id}=2
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=${gnb_id}
    Execute Egate Command    ue_register id=${ue_id}    sleep_time=${wait_timer}    pass_regexp=NG RM Registered

SA CA UE Setup PDU Session And Check CA Addition Successfully
    [Arguments]    ${ue_id}=1    ${wait_timer}=0.5    ${expect_regexp}=${EMPTY}
    [Return]    ${RAN_UE_NGAP_ID[0]}
    Sa CA UE Register    ue_id=${ue_id}    gnb_id=2    cell_id=1
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal    sleep_time=${wait_timer}
    ${output}    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    pass_regexp=${expect_regexp}
    ${RAN_UE_NGAP_ID}    Get Regexp Matches    ${output}    RAN_UE_NGAP_ID\=(\\d+)    1

Traffic Send
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=2 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=3 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=4 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=5 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=6 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=8 mbps=175    UE ${ue_id}: UDP UL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=9 mbps=175    UE ${ue_id}: UDP UL

Check Throughput with Type
    [Arguments]    ${ue_id}=1    ${Tput_expect}=80    ${CC_num}=2    ${type}=pdsch
    ${ret0}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=${type}    pass_regexp=Average
    ${all_tput}    set variable    0
    FOR    ${id}    IN RANGE    0    ${CC_num}
        ${id}=    convert to string    ${id}
        ${cell_tput}    Scell Throughput Check    ${ue_id}    ${id}    ${type}
        ${all_tput}    Evaluate    ${all_tput}+${cell_tput}
    END
    Should Be True    ${all_tput}/1000 > ${Tput_expect}

Scell Throughput Check
    [Arguments]    ${ue_id}=1    ${scell_id}=0    ${type}=pdsch
    [Return]    ${scell_tput}
    ${scell_tput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=${scell_id}    type=${type}    rate_type=ave
    Should Be True    ${scell_tput}/1000 > 0

Set UE Capability
    [Arguments]    ${ue_id}=1    ${UE_Capabilities}=${SA_Capa_perUE_Full}    ${wait_timer}=0.5
    Execute Egate Command    ue_param id=${ue_id} ue_nr_capabilities=${UE_Capabilities}    sleep_time=${wait_timer}

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${False}

UE Beamgroup Change
    [Arguments]    ${ue_id}=1
    Execute Egate Command    csi_override_testmode_nr profile_id=1 cqi_mode=fixed cqi=15 ri_mode=fixed ri=1 pmi_mode=fixed pmi=1
    Execute Egate Command    ue_testmode_set_nr id=1 testmode=csi_override action=activate profile_id=1 scell=0-7
    Beamgroup Change Trigger Active    ue_id=${ue_id}
    sleep    80s    sleep for Tput stable
	Check Throughput with Type    ue_id=${ue_id}    Tput_expect=700    CC_num=8    type=pdsch
	Check Throughput with Type    ue_id=${ue_id}    Tput_expect=180    CC_num=4    type=pusch
    Beamgroup Change Trigger Deactive    ue_id=${ue_id}
    sleep    5s    sleep for Tput stable
	Check Throughput with Type    ue_id=${ue_id}    Tput_expect=700    CC_num=8    type=pdsch
	Check Throughput with Type    ue_id=${ue_id}    Tput_expect=180    CC_num=4    type=pusch

Beamgroup Change Trigger Active
    [Arguments]    ${ue_id}=1
    Beam Testmod Set    ue_id=${ue_id}    profile_id=2    Initial=0,1,2,3,7,8,9,10    bestbeam=0    beamaction=attach
	sleep    60s
    Beam Testmod Set    ue_id=${ue_id}    profile_id=3    Initial=0    bestbeam=12    beamaction=switch    expect_regexp=${Beamswitch_expect_regexp}
    Beam Testmod Set    ue_id=${ue_id}    profile_id=4    Initial=10    bestbeam=23    beamaction=switch    expect_regexp=${Beamswitch_expect_regexp}

UE Beamgroup Change UE2
    [Arguments]    ${ue_id}=1
    Execute Egate Command    csi_override_testmode_nr profile_id=1 cqi_mode=fixed cqi=15 ri_mode=fixed ri=1 pmi_mode=fixed pmi=1
    Execute Egate Command    ue_testmode_set_nr id=1 testmode=csi_override action=activate profile_id=1 scell=0-7
    Beamgroup Change Trigger Active UE2    ue_id=${ue_id}
    sleep    5s    sleep for Tput stable
	Check Throughput with Type    ue_id=${ue_id}    Tput_expect=700    CC_num=8    type=pdsch
	Check Throughput with Type    ue_id=${ue_id}    Tput_expect=180    CC_num=4    type=pusch
    Beamgroup Change Trigger Deactive    ue_id=${ue_id}
    sleep    5s    sleep for Tput stable
	Check Throughput with Type    ue_id=${ue_id}    Tput_expect=700    CC_num=8    type=pdsch
	Check Throughput with Type    ue_id=${ue_id}    Tput_expect=180    CC_num=4    type=pusch

Beamgroup Change Trigger Active UE2
    [Arguments]    ${ue_id}=1
    Beam Testmod Set    ue_id=${ue_id}    profile_id=3    Initial=0    bestbeam=12    beamaction=switch    expect_regexp=${Beamswitch_expect_regexp}

Beamgroup Change Trigger Deactive
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=beam_control profile_id=2 action=deactivate
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=beam_control profile_id=3 action=deactivate
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=beam_control profile_id=4 action=deactivate

Beam Testmod Set
    [Arguments]    ${ue_id}=1    ${profile_id}=1    ${Initial}=0    ${bestbeam}=0    ${beamaction}=attach    ${expect_regexp}=${EMPTY}
    ${cmd}    catenate    beam_control_testmode_nr profile_id=${profile_id} beamType=Analog ueBeamIndexInitial=${Initial} ssbeam_bestbeam=${bestbeam}
    ...    ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50
    Execute Egate Command    ${cmd}
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=beam_control profile_id=${profile_id} action=activate beamaction=${beamaction}
    ...    pass_regexp=${expect_regexp}
