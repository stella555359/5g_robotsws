*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CLOUD_5G_I_BOO_AP_LOO    team-CN1ET
...    owner-jolin.fan    release-SBTS24R2    CRT
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_A2_disable}
...    @{PARAMS_FOR_measurement_relate}
...    @{PARAMS_FOR_beam_relate}
...    @{PARAMS_FOR_others}

@{PARAMS_FOR_CA}
...    NRBTS:actFr2Sa=true
...    NRBTS:actCarrierAggregationFr2SA=true
...    NRBTS:caConfigurationSupportFr2SA=8CCDL_4CCUL
...    NRBTS:actIpThpt=true
...    NRBTS:actMacUserThpt=true
...    NRBTS:maxNumScellsDlFr2SA=7
...    NRBTS:maxNumScellsUlFr2SA=3
...    NRCELL-2:actProactUlScheduling=true
...    NRCELL-3:actProactUlScheduling=true
...    NRCELL-4:actProactUlScheduling=true
...    NRCELL-5:actProactUlScheduling=false
...    NRCELL-6:actProactUlScheduling=false
...    NRCELL-7:actProactUlScheduling=false
...    NRCELL-8:actProactUlScheduling=false
...    NRCELL-1:sCellOnlyFr2Sa=false
...    NRCELL-2:sCellOnlyFr2Sa=true
...    NRCELL-3:sCellOnlyFr2Sa=true
...    NRCELL-4:sCellOnlyFr2Sa=true
...    NRCELL-5:sCellOnlyFr2Sa=true
...    NRCELL-6:sCellOnlyFr2Sa=true
...    NRCELL-7:sCellOnlyFr2Sa=true
...    NRCELL-8:sCellOnlyFr2Sa=true
...    NRBTS:sCellActivationMethod=blind
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRCELL-4:nrarfcn=2086631
...    NRCELL-7:nrarfcn=2083253
...    NRCELL-8:nrarfcn=2090247
...    NRCELL-4:gscnOrSsPbchArfcn=22498
...    NRCELL-7:gscnOrSsPbchArfcn=22488
...    NRCELL-8:gscnOrSsPbchArfcn=22512
...    NRCELL-8:type0CoresetConfigurationIndex=1
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRCELL:type0SearchSpaceConfigurationIndex=2

@{PARAMS_FOR_A2_disable}
...    NRCELL:a2MeashoEnabledSA=none
...    NRCELL-1:a2MeasRedirectEnabled=${EMPTY}

@{PARAMS_FOR_measurement_relate}
...    NRBTS/NRPMRNL-1:miNrHighRlcCell=5min

@{PARAMS_FOR_beam_relate}
...    NRCELL:actBeamforming=true
...    NRCELL-1:actRrcReconfigAtBeamSwitch=false
...    NRSYSINFO_PROFILE-1/NRIRFIM-1:numberOfTransmittedSsBlocks=32 beams
...    NRCELLGRP-1:numberOfTransmittedSsBlocks=32 beams
...    NRCELL:beamSet:basicBeamSet=beamSetAbf_32A

@{PARAMS_FOR_others}
...    NRBTS:integrityProtPrefL:nia2_128=4
...    NRBTS:integrityProtPrefL:nia3_128=2
...    TNL-1/ETHSVC-1/ETHLK-1:l2IngressRate=10000000
...    MRBTS-1/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1/BRGPRT-1:l2ShaperRate=10000000
...    NRBTS:cipherPrefL:nea0=1
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRCELL:actCDrx=false
...    NRCELL:actAperCsi=false
...    NRCELL:actCceSplit=true

${Capa_Non-contiguous_8CC}    SEPARATOR=
...    E1A25000574F7603564803C4280058084400090020C008120C7A023D801E099321CF916BD055EC12F40CFB027C0F1E238F20020301262C011306E41280634DA00040401406
...    01CCE00F42B4070378E3087000A8F3F1436011FB660AA40078F0021C4106115028FDFC8106400340C0058038FC71689003000804020068029150AD00DE38C21C002A3CFC50
...    D8047ED982A9001E3C0087104184540A3F7F20419000D03001600E3F1C5A2400C0020100801A00A401881D001430000A81D00308002100504E800E3F40061BA00001D00000
...    E800000050800082022E0003E03806CF1E5C03678F2E4001B3C7963F68200017A01F00120018004D0202D0480A00C06012803000301F014494018000000000312500E00802
...    008020080200802C4940100200802C41400002C4940080200B1250060080200802C016F15BA501410040000000004100C01004010040000410080100401000010400004000
...    0410040100400004100C0100401004000040157AA2BB502D00F801A05000142002980110010000448000020000002400001000000000280040080100080200410100600C04
...    0280510080500A02010020080400840100600C040200401008010040200401008010802018030080500A020100200804008020100205429441618DCE83660090

${Capa_Non-contiguous_7CC}    SEPARATOR=
...    E1A25000574F7603564803C4280058084400090020C008120C7A023D801E099321CF916BD055EC12F40CFB027C0F1E238F20020301262C011306E41280634DA0004040140
...    601CCE00F42B4070378E3087000A8F3F1436011FB660AA40078F0021C4106115028FDFC8106400340C0058038FC71689003000804020068029150AD00DE38C21C002A3CFC
...    50D8047ED982A9001E3C0087104184540A3F7F20419000D03001600E3F1C5A2400C0020100801A00A401881D001430000A81D00308002100503E80104740061BA00001D00
...    00000A1000104045C0007C0700D9E3CB806CF1E5C600D9E3CB07ED040002F403E00240030009A0405A090140180C025006000603E028928030000000000624A01C0100401
...    00401004010058928020040100588280000589280100401624A00C0100401005802DE2B74A028200800000000082018020080200800008201002008020000208000080000
...    820080200800008201802008020080000802AF54576A05A01F00340A000284005300220020000890000040000004800002000000000500080100200100400820200C01808
...    0500A20100A014040200401008010602010020080400802010020080400830100C01804028050100801004020040A852882C31B9D06CC012

${Capa_Non-contiguous_5CC}    SEPARATOR=
...    E1A25000574F7603564803C4280058084400090020C008120C7A023D801E099321CF916BD055EC12F40CFB027C0F1E238F20020301262C011306E41280634DA0004040140
...    601CCE00F42B4070378E3087000A8F3F1436011FB660AA40078F0021C4106115028FDFC8106400340C0058038FC71689003000804020068029150AD00DE38C21C002A3CFC
...    50D8047ED982A9001E3C0087104184540A3F7F20419000D03001600E3F1C5A2400C0020100801A00A401881D001430000A81D00308002100541E800E3F400618010401001
...    04045C000740700D9E3CB806CF1E5C20D9E3CB7ED040002F403E00240030009A0405A090140180C025006000603E028928030000000000624A01C01004010040100401005
...    8928020040100588280000589280100401624A00C0100401005802DE2B74A0282008000000000820180200802008000082010020080200002080000800008200802008000
...    08201802008020080000802AF54576A05A01F00340A000284005300220020000890000040000004800002000000000500080100200100400820200C018080500A20100A01
...    4040200401008010602010020080400802010020080400830100C01804028050100801004020040A852882C31B9D06CC0120
#   bandList {
#     nr : {
#       bandNR 257,
#       ca-BandwidthClassDL-NR h,
#       ca-BandwidthClassUL-NR h
#      },
#     nr : {
#       bandNR 257,
#       ca-BandwidthClassDL-NR g,
#       ca-BandwidthClassUL-NR g

@{8CC_regexp}
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
...    PhysCellId: 51] SCellIndex 1 activated successfully at airphone
...    PhysCellId: 52] SCellIndex 2 activated successfully at airphone
...    PhysCellId: 53] SCellIndex 3 activated successfully at airphone
...    PhysCellId: 54] SCellIndex 4 activated successfully at airphone
...    PhysCellId: 55] SCellIndex 5 activated successfully at airphone
...    PhysCellId: 56] SCellIndex 6 activated successfully at airphone
...    PhysCellId: 57] SCellIndex 7 activated successfully at airphone

@{7CC_regexp}
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
...    PhysCellId: 51] SCellIndex 1 activated successfully at airphone
...    PhysCellId: 52] SCellIndex 2 activated successfully at airphone
...    PhysCellId: 53] SCellIndex 3 activated successfully at airphone
...    PhysCellId: 54] SCellIndex 4 activated successfully at airphone
...    PhysCellId: 55] SCellIndex 5 activated successfully at airphone
...    PhysCellId: 56] SCellIndex 6 activated successfully at airphone

@{5CC_regexp}
...    pcid:50, scellIdx:0] configure_0_1
...    pcid:51, scellIdx:1] configure_0_1
...    pcid:52, scellIdx:2] configure_0_1
...    pcid:50, scellIdx:0] configure_1_1
...    pcid:51, scellIdx:1] configure_1_1
...    pcid:52, scellIdx:2] configure_1_1
...    pcid:54, scellIdx:3] configure_1_1
...    pcid:55, scellIdx:4] configure_1_1
...    PhysCellId: 51] SCellIndex 1 activated successfully at airphone
...    PhysCellId: 52] SCellIndex 2 activated successfully at airphone
...    PhysCellId: 54] SCellIndex 3 activated successfully at airphone
...    PhysCellId: 55] SCellIndex 4 activated successfully at airphone

@{PM_Counters_Check}
#8CCDL_4CCUL_Counters_Check
...    NRCELL-1:RSADU:${GNB_DU_SCELL_7_ADMI_REQ_SA}=1
...    NRCELL-1:RSADU:${GNB_DU_SCELL_7_ADMI_SUCC_SA}=1
...    NRCELL-1:NCAC:${RRC_RECONF_ADD7DLSCELL_ATT_SA}=1
...    NRCELL-1:NCAC:${RRC_RECONF_ADD7DLSCELL_SUCC_SA}=1
...    NRCELL-1:NCAC:${UE_PCELL_7_CONF_SCELL_DL_SA}>0
...    NRCELL-1:RSACU:${GNB_SCELL_7_ADMI_REQ_SA}=3
...    NRCELL-1:RSACU:${GNB_SCELL_7_ADMI_SUCC_SA}=1
...    NRCELL-1:CUCM:${MAX_UE_PCELL_7_CONF_SCEL_DL_SA}>0
...    NRCELL-1:NCAC:${UE_PCELL_3_CONF_SCELL_UL_SA}>0
...    NRCELL-1:CUCM:${MAX_UE_PCELL_3_CONF_SCEL_UL_SA}>1
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

#7CCDL_Counters_Check
...    NRCELL-1:RSADU:${GNB_DU_SCELL_6_ADMI_SUCC_SA}=1
...    NRCELL-1:NCAC:${RRC_RECONF_ADD6DLSCELL_ATT_SA}=1
...    NRCELL-1:NCAC:${RRC_RECONF_ADD6DLSCELL_SUCC_SA}=1
...    NRCELL-1:NCAC:${UE_PCELL_6_CONF_SCELL_DL_SA}>1
...    NRCELL-1:RSACU:${GNB_SCELL_6_ADMI_SUCC_SA}=1
...    NRCELL-1:CUCM:${MAX_UE_PCELL_6_CONF_SCEL_DL_SA}>0
...    NRCELL-2:NCAC:${UE_SCELL_6_CONF_SCELL_DL_SA}>0
...    NRCELL-3:NCAC:${UE_SCELL_6_CONF_SCELL_DL_SA}>0
...    NRCELL-4:NCAC:${UE_SCELL_6_CONF_SCELL_DL_SA}>0
...    NRCELL-5:NCAC:${UE_SCELL_6_CONF_SCELL_DL_SA}>0
...    NRCELL-6:NCAC:${UE_SCELL_6_CONF_SCELL_DL_SA}>0
...    NRCELL-7:NCAC:${UE_SCELL_6_CONF_SCELL_DL_SA}>0

#3CCUL_Counters_Check
...    NRCELL-1:NCAC:${UE_PCELL_2_CONF_SCELL_UL_SA}>0
...    NRCELL-1:CUCM:${MAX_UE_PCELL_2_CONF_SCEL_UL_SA}>0
...    NRCELL-2:NCAC:${UE_SCELL_2_CONF_SCELL_UL_SA}>0
...    NRCELL-3:NCAC:${UE_SCELL_2_CONF_SCELL_UL_SA}>0

#5CCDL_PM_Counters_Check
...    NRCELL-1:RSACU:${GNB_SCELL_4_ADMI_SUCC_SA}=1
...    NRCELL-1:NCAC:${UE_PCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-2:NCAC:${UE_SCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-3:NCAC:${UE_SCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-5:NCAC:${UE_SCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-6:NCAC:${UE_SCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-1:RSADU:${GNB_DU_SCELL_4_ADMI_REQ_SA}=1
...    NRCELL-1:RSADU:${GNB_DU_SCELL_4_ADMI_SUCC_SA}=1
...    NRCELL-1:NCAC:${RRC_RECONF_ADD4DLSCELL_ATT_SA}=1
...    NRCELL-1:NCAC:${RRC_RECONF_ADD4DLSCELL_SUCC_SA}=1

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
${MAX_UE_PCELL_3_CONF_SCEL_UL_SA}    M55156C00022
#This counter shows the maximum of samples for the total number of CA UEs in the
#current cell configured as a PCell, which have 3 configured SCells in UL.
${UE_SCELL_3_CONF_SCELL_UL_SA}    M55118C00017
#This counter shows the sum of samples for the total number of CA UEs in the current
#cell configured as a UL SCell while pegged in the secondary cell, which have 3 configured SCells in UL.
${UE_SCELL_7_CONF_SCELL_DL_SA}    M55118C00020
#The sum of samples for the total number of CA UEs in the current cell configured as an SCell while pegged in the
#secondary cell that has seven configured SCells in DL in SA mode.
${UE_PCELL_3_CONF_SCELL_UL_SA}    M55118C00012
#This counter is updated with the current number of PCell UEs with 3 configured SCells in UL when the sample timer expires.
${GNB_DU_SCELL_6_ADMI_SUCC_SA}    M55139C03007
#This counter describes the number of successful radio admission requests for exactly 6 SCells before the CA configuration on RRC.
#It's measured in the PCell in SA mode in DU only.
${RRC_RECONF_ADD6DLSCELL_ATT_SA}    M55118C00002
#This counter indicates the total number of RRC Reconfiguration attempts for 6 SCells Addition in DL for SA mode.
${RRC_RECONF_ADD6DLSCELL_SUCC_SA}    M55118C00005
#This counter indicates the total number of successful RRC Reconfiguration attempts for 6 SCells Addition in DL for SA mode.
${UE_PCELL_6_CONF_SCELL_DL_SA}    M55118C00014
#This counter provides the total number of CA UEs in the current cell configured as a PCell that have exactly 6 configured SCells in DL in SA mode.
${GNB_SCELL_6_ADMI_SUCC_SA}    M55138C03508
#This counter describes the number of successful radio admission requests for exactly 6 SCells before the CA configuration on RRC.
#It's measured in the PCell in SA mode only.
${MAX_UE_PCELL_6_CONF_SCEL_DL_SA}    M55156C00028
#This counter is updated with the maximum number of SCell UEs with 6 configured SCells in DL when the sample timer expires.
${UE_SCELL_6_CONF_SCELL_DL_SA}    M55118C00019
#This counter is updated with the current number of SCell UEs with 6 configured SCells in DL is calculated when the sample timer expires.
${UE_PCELL_2_CONF_SCELL_UL_SA}    M55118C00011
#This counter is updated with the current number of PCell UEs with 2 configured SCells in UL when the sample timer expires.
${MAX_UE_PCELL_2_CONF_SCEL_UL_SA}    M55156C00021
#This counter is updated with the maximum number of SCell UEs with 2 configured SCells in UL when the sample timer expires.
${UE_SCELL_2_CONF_SCELL_UL_SA}    M55118C00016
#This counter is updated with the current number of SCell UEs with 2 configured SCells in UL when the sample timer expires.
${GNB_SCELL_4_ADMI_SUCC_SA}    M55138C00049
#This counter describes the number of successful radio admission requests for exactly 4 SCells
#before the CA configuration on RRC
${UE_PCELL_4_CONF_SCELL_DL_SA}    M55118C02016
#The total number of CA UEs in the current cell configured as a PCell that have exactly 4
#configured SCells in DL in SA mode
${UE_SCELL_4_CONF_SCELL_DL_SA}    M55118C07510
#The sum of samples for the total number of CA UEs in the current cell configured as an
#SCell while pegged in the secondary cell that has four configured SCells in DL in SA mode.
${GNB_DU_SCELL_4_ADMI_REQ_SA}    M55139C00023
#This counter describes the number of radio admission requests for exactly 4 SCells before
#the CA configuration on RRC.
${GNB_DU_SCELL_4_ADMI_SUCC_SA}    M55139C00024
#This counter describes the number of successful radio admission requests for exactly 4
#SCells before the CA configuration on RRC
${RRC_RECONF_ADD4DLSCELL_ATT_SA}    M55118C02015
#This counter indicates the total number of RRC Reconfiguration attempts for 4 SCells
#Addition in DL for SA mode
${RRC_RECONF_ADD4DLSCELL_SUCC_SA}    M55118C02014
#This counter indicates the total number of successful RRC Reconfiguration attempts for
#4 SCells Addition in DL for SA mode.

*** Test Cases ***
CB008294-ET-A035-Mult_UE_intra-band_CA_in_mmW_band_with_different_UE_capability_Non-contiguous_component_carriers
    [Documentation]
    ...    1. This User Scenario shall validate asymmetric CA functionality with Analog Beamforming in mmW bands (FR2) for multi 5G-UE scenario
    ...       considering UE capabilities.the difference that here is applied to non-contiguous CCs.
    ...    2. Configuration
    ...         gNBs host following cells:
    ...                                 Cell-1    Cell-2    Cell-3    Cell-4    Cell-5    Cell-6    cell-7     cell-8
    ...    Technology                    TDD      TDD      TDD        TDD        TDD       TDD       TDD       TDD
    ...          Band                    n257     n257     n257       n257       n257      n257      n257      n257
    ...           Pci                     50       51       52         53         54       55         56       57
    ...     Bandwidth                    100      100      100        100        100       100       100       100
    ...            BF                    Yes      Yes      Yes        Yes        Yes       Yes       Yes       Yes
    ...         Arfcn                 2071591    2073257   2074923   2086631    2078255   2079921   2083253   2090647
    ...          gscn                  22446      22452     22458     22498      22470     22476     22488     22512
    ...    weightForSCellSelection    all cells are 50
    ...    Cell-1,Cell-2 and Cell-3 are contiguous, Cell-5 and Cell-6 are contiguous, other cells are not contiguous.
    ...    3. Test Case Steps:
    ...         a. attach UE1 to cell1
    ...         b. PDU setup and trigger scell addition
    ...         c. start DL,UL traffic and check traffic
    ...         d. attach UE2 to cell1 and repeat step b,c
    ...         e. attach UE3 to cell1 and repeat step b,c
    ...         f. Release all UEs
    ...    4. Expected Results:
    ...         a. UE1 is attch to pcell nrcell-1
    ...         b. UE1 is configured with 8CC(cell1+cell2,cell3,cell4,cell5,cell6,cell7,cell8) dl 4CC(cell1+cell2,cell3,cell4) ul
    ...         c. DL,UL traffic is ok
    ...         d. UE2 is configured with 7CC(cell1+cell2,cell3,cell4,cell5,cell6,cell7) dl, 4CC(cell1+cell2,cell3,cell4) ul,DL/UL traffic is ok
    ...         e. UE3 capability of supportedBandCombinationList is ca-BandwidthClassDL/UL-NR h and g means number of continuous carriers are 3
    ...            and 2, so UE3 is configured with 5CC(cell1+cell2,cell3,cell5,cell6) dl, 3CC(cell1+cell2,cell3) ul,DL/UL traffic is ok
    [Tags]    QC_321798    A035    CA_LABEL-8T(100Mhz_TDD_n257)    CA_LABEL-7T(100Mhz_TDD_n257)    CA_LABEL-5T(100Mhz_TDD_n257)
    UE1 register and blind 8CC CA successful
    UE2 register and blind 7CC CA successful
    UE3 register and blind 5CC CA successful
    Release UEs    ue_type=all
    Check WireShark Log    ${CURDIR}${/}A2A_A035${/}a2a.ini    wait_string=UEContextRelease::36
    Check Counters    ${PM_Counters_Check}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sa_mmwv/FS/8cells_8T_8DL_4UL_ecpri

Modify Cfg
    Update Cfg    ue_param id=1 ue_nr_capabilities=${Capa_Non-contiguous_8CC}
    Update Cfg    ue_param id=2 ue_nr_capabilities=${Capa_Non-contiguous_7CC}
    Update Cfg    ue_param id=3 ue_nr_capabilities=${Capa_Non-contiguous_5CC}

UE1 register and blind 8CC CA successful
    ${RAN_UE1_NGAP_ID}    Ue register and pdu session setup    ue_id=1    cell_id=1    pdu_regexp=${8CC_regexp}
    Set Test Variable    \${RAN_UE1_NGAP_ID}
    Run Traffic    ue_id=1
    Throughput Check    ue_id=1    Tput_dl=270    Tput_ul=90    DLCC_num=8    ULCC_num=4

UE2 register and blind 7CC CA successful
    ${RAN_UE2_NGAP_ID}    Ue register and pdu session setup    ue_id=2    cell_id=1    pdu_regexp=${7CC_regexp}
    Set Test Variable    \${RAN_UE2_NGAP_ID}
    Run Traffic    ue_id=2
    Throughput Check    ue_id=2    Tput_dl=270    Tput_ul=90    DLCC_num=7    ULCC_num=4

UE3 register and blind 5CC CA successful
    ${RAN_UE3_NGAP_ID}    Ue register and pdu session setup    ue_id=3    cell_id=1    pdu_regexp=${5CC_regexp}
    Set Test Variable    \${RAN_UE3_NGAP_ID}
    Run Traffic    ue_id=3
    Throughput Check    ue_id=3    Tput_dl=270    Tput_ul=90    DLCC_num=5     ULCC_num=3

Ue register and pdu session setup
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=1    ${cmd_regexp}=UE now in NG RM Registere
    ...    ${pdu_regexp}=QoS Routing Table
    [Return]    ${RAN_UE_NGAP_ID[0]}
    Execute Egate Command    ue_register id=${ue_id}    ${cmd_regexp}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    ${output}    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}    pass_regexp=${pdu_regexp}
    ${RAN_UE_NGAP_ID}    Get Regexp Matches    ${output}    RAN_UE_NGAP_ID\=(\\d+)    1

Run Traffic
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=2 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=8 mbps=100    UE ${ue_id}: UDP UL

Throughput Check
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1    ${Tput_dl}=945    ${Tput_ul}=225    ${sleep_time}=15s    ${DLCC_num}=4    ${ULCC_num}=2
    sleep    ${sleep_time}    sleep for Tput stable
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    pass_regexp=Average
    ${alldl_tput}    set variable    0
    FOR    ${id}    IN RANGE    0    ${DLCC_num}
        ${id}=    convert to string    ${id}
        ${cell_tput}    Scell DL Throughput Check    ${ue_id}    ${id}
        ${alldl_tput}    Evaluate    ${alldl_tput}+${cell_tput}
    END
    Should Be True    ${alldl_tput}/1000 > ${Tput_dl}
    Check UL CA Throughput    ue_id=${ue_id}    cc_num=${ULCC_num}    tput_ul=${Tput_ul}

Scell DL Throughput Check
    [Arguments]    ${ue_id}=1    ${scell_id}=0
    [Return]    ${scell_tput}
    ${scell_tput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput}/1000 > 0

Scell UL Throughput Check
    [Arguments]    ${ue_id}=1    ${scell_id}=0
    [Return]    ${scell_tput}
    ${scell_tput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=${scell_id}    type=pusch    rate_type=ave
    Should Be True    ${scell_tput}/1000 > 0

Check UL CA Throughput
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1    ${tput_ul}=90    ${sleep_time}=15s    ${cc_num}=2
    sleep    ${sleep_time}    sleep for Tput stable
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-4 type=pusch    pass_regexp=Average
    ${allul_tput}    set variable    0
    FOR    ${id}    IN RANGE    0    ${cc_num}
        ${id}=    convert to string    ${id}
        ${cell_tput}    Scell UL Throughput Check    ${ue_id}    ${id}
        ${allul_tput}    Evaluate    ${allul_tput}+${cell_tput}
    END
    Should Be True    ${allul_tput}/1000 > ${Tput_ul}

