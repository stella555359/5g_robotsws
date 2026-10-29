*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CLOUD_5G_I_BOO_AP_LOO    team-CN1ET
...    owner-jean.jing    release-SBTS24R2    CRT
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
...    NRBTS:actCarrierAggregationFr2SA=true
...    NRBTS:maxNumScellsDlFr2SA=7
...    NRBTS:maxNumScellsUlFr2SA=3
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRCELL-1:sCellOnlyFr2Sa=false
...    NRCELL:actProactUlScheduling=true
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

@{A013_parameter_update}
...    NRBTS:caConfigurationSupportFr2SA=4CCDL_2CCUL

@{A013_parameter_recover}
...    NRBTS:caConfigurationSupportFr2SA=8CCDL_4CCUL

#only support CB008294 6cc CA
${SA_Capa_6T}    SEPARATOR=
...    E1A25000574F7603564803C4280058084400090020C008120C7A023D801E099321CF916BD055EC12F40CFB027C0F1E238F20020301262C011
...    306E41280634DA0004040140601CCE00F42B4070378E3087000A8F3F1436011FB660AA40078F0021C4106115028FDFC8106400340C0058038
...    FC71689003000804020068029150AD00DE38C21C002A3CFC50D8047ED982A9001E3C008710418414123F7F20419000D03001600E3F1C5A240
...    0C0020100801A00A401081D001430000A81D002870021004004101170001501403678F2E01B3C78A1FB410000BD00F8009000C00268101682
...    40500603009401800180F80324A00C0000000000392500A0080200802008021802DE2B74A00820080000000008201002008020000200ABD51
...    5DA816807C00D028000A10014C008800800022400001000000120000080000000004002004008004010020A852882C31B9D06CC0120

#256 for CSIRS for tracking.
${CAPA_CB008294_A_8CC_n257_maxconfigureResourceallcc_256}    SEPARATOR=
...    E1A25000574F7603564803C4280058084400090020C008120C7A023D801E099321CF916BD055EC12F40CFB027C0F1E238F20020301262C011
...    306E41280634DA0004040140601CCE00F42B4070378E3087000A8F3F1436011FB660AA40078F0021C4106115028FDFC8106400340C0058038
...    FC71689003000804020068029150AD00DE38C21C002A3CFC50D8047ED982A9001E3C0087104184540A3FFF20419000D03001600E3F1C5A240
...    0C0020100801A00A401081D001430000A81D003080021004004101170001501403678F2E01B3C7961FB410000BD00F8009000C00268101682
...    40500603009401800180F80324A00C0000000000392500E008020080200802008021802DE2B74A00820080000000008201802008020080000
...    802AF54576A05A01F00340A00028400530022002000089000004000000480000200000000010008010020010040082A14A20B0C6E741B3004
...    80

@{A015_expect_regexp}
...    pcid:51, scellIdx:1] configure_0_1
...    pcid:52, scellIdx:2] configure_0_1
...    pcid:51, scellIdx:1] configure_1_1
...    pcid:52, scellIdx:2] configure_1_1
...    pcid:53, scellIdx:3] configure_1_1
...    pcid:54, scellIdx:4] configure_1_1
...    pcid:55, scellIdx:5] configure_1_1
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 3 activated successfully at airphone
...    SCellIndex 4 activated successfully at airphone
...    SCellIndex 5 activated successfully at airphone

@{A013_expect_regexp}
...    pcid:51, scellIdx:1] configure_0_1
...    pcid:51, scellIdx:1] configure_1_1
...    pcid:52, scellIdx:2] configure_1_1
...    pcid:53, scellIdx:3] configure_1_1
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 3 activated successfully at airphone

@{A044_expect_regexp}
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

@{A013_PM_Counters_Check}
...    NRCELL-1:NCAC:${RRC_RECONF_ADD3DLSCELL_ATT_SA}=1
...    NRCELL-1:NCAC:${RRC_RECONF_ADD3DLSCELL_SUCC_SA}=1
...    NRCELL-1:NCAC:${RRC_RECONF_ADD1ULSCELL_ATT_SA}=1
...    NRCELL-1:NCAC:${RRC_RECONF_ADD1ULSCELL_SUCC_SA}=1
...    NRCELL-1:RSACU:${GNB_SCELL_3_ADMI_REQ_SA}=1
...    NRCELL-1:RSACU:${GNB_SCELL_3_ADMI_SUCC_SA}=1
...    NRCELL-1:NCAC:${UE_PCELL_3_CONF_SCELL_DL_SA}>0
...    NRCELL-1:NCAC:${UE_PCELL_1_CONF_SCELL_UL_SA}>0
...    NRCELL-1:RSADU:${GNB_DU_SCELL_3_ADMI_REQ_SA}=1
...    NRCELL-1:RSADU:${GNB_DU_SCELL_3_ADMI_SUCC_SA}=1

${RRC_RECONF_ADD3DLSCELL_ATT_SA}    M55118C09503
#This counter is updated when an RRC reconfiguration message configuring exactly 3 SCells in DL is triggered in SA mode.
${RRC_RECONF_ADD3DLSCELL_SUCC_SA}    M55118C09502
#This counter is updated when an RRC reconfiguration complete message following RRC reconfiguration configuring exactly 3
#SCells in DL is received in SA mode.
${RRC_RECONF_ADD1ULSCELL_ATT_SA}    M55118C10001
#TThis counter indicates the total number of RRC Reconfiguration attempts for 1 SCell Addition in UL for SA mode.
${RRC_RECONF_ADD1ULSCELL_SUCC_SA}    M55118C10002
#This counter indicates the total number of successful RRC Reconfiguration attempts for 1 SCell Addition in UL for SA mode.
${GNB_SCELL_3_ADMI_REQ_SA}    M55138C03001
#This counter indicates the number of radio admission requests for exactly 3 SCells before the CA configuration on RRC.
${GNB_SCELL_3_ADMI_SUCC_SA}    M55138C03002
#This counter indicates the number of successful radio admission requests for exactly 3 SCells before the CA configuration on RRC..
${UE_PCELL_3_CONF_SCELL_DL_SA}    M55118C09501
#The total number of successful RRC reconfiguration procedures in SA mode configuring UE with 3 SCells in DL.
${UE_PCELL_1_CONF_SCELL_UL_SA}    M55118C10005
#This counter shows the sum of samples for total number of CA UEs in the current cell configured as a PCell, which have 1 configured SCell in UL.
${GNB_DU_SCELL_3_ADMI_REQ_SA}    M55139C03001
#This counter describes the number of radio admission requests for exactly 3 SCells before
#the CA configuration on RRC.
${GNB_DU_SCELL_3_ADMI_SUCC_SA}    M55139C03002
#This counter describes the number of successful radio admission requests for exactly 3
#SCells before the CA configuration on RRC

@{PM_Counters_Check_A015}
...    NRCELL-1:NCAC:${RRC_RECONF_ADD5DLSCELL_ATT_SA}=1
...    NRCELL-1:NCAC:${RRC_RECONF_ADD5DLSCELL_SUCC_SA}=1
...    NRCELL-1:NCAC:${RRC_RECONF_ADD2ULSCELL_ATT_SA}=1
...    NRCELL-1:NCAC:${RRC_RECONF_ADD2ULSCELL_SUCC_SA}=1
...    NRCELL-1:NCAC:${UE_PCELL_2_CONF_SCELL_UL_SA}>0
...    NRCELL-1:NCAC:${UE_PCELL_5_CONF_SCELL_DL_SA}>0
...    NRCELL-1:RSADU:${GNB_DU_SCELL_5_ADMI_REQ_SA}=1
...    NRCELL-1:RSADU:${GNB_DU_SCELL_5_ADMI_SUCC_SA}=1
...    NRCELL-1:RSACU:${GNB_SCELL_5_ADMI_REQ_SA}=1
...    NRCELL-1:RSACU:${GNB_SCELL_5_ADMI_SUCC_SA}=1
...    NRCELL-1:CUCM:${MAX_UE_PCELL_2_CONF_SCEL_UL_SA}=1
...    NRCELL-1:CUCM:${MAX_UE_PCELL_5_CONF_SCEL_DL_SA}=1
...    NRCELL-2:NCAC:${UE_SCELL_2_CONF_SCELL_UL_SA}>0
...    NRCELL-2:NCAC:${UE_SCELL_5_CONF_SCELL_DL_SA}>0
...    NRCELL-3:NCAC:${UE_SCELL_2_CONF_SCELL_UL_SA}>0
...    NRCELL-3:NCAC:${UE_SCELL_5_CONF_SCELL_DL_SA}>0
...    NRCELL-4:NCAC:${UE_SCELL_5_CONF_SCELL_DL_SA}>0
...    NRCELL-5:NCAC:${UE_SCELL_5_CONF_SCELL_DL_SA}>0
...    NRCELL-6:NCAC:${UE_SCELL_5_CONF_SCELL_DL_SA}>0


${RRC_RECONF_ADD5DLSCELL_ATT_SA}    M55118C00001
#This counter indicates the total number of RRC Reconfiguration attempts for 5 SCells Addition in DL for SA mode.
${RRC_RECONF_ADD5DLSCELL_SUCC_SA}    M55118C00004
#This counter indicates the total number of successful RRC Reconfiguration attempts for 5 SCells Addition in DL for SA mode.
${RRC_RECONF_ADD2ULSCELL_ATT_SA}    M55118C00007
#This counter indicates the total number of RRC Reconfiguration attempts for 2 SCells Addition in UL for SA mode..
${RRC_RECONF_ADD2ULSCELL_SUCC_SA}    M55118C00009
#This counter indicates the total number of successful RRC Reconfiguration attempts for 2 SCells Addition in UL for SA mode.
${UE_PCELL_2_CONF_SCELL_UL_SA}    M55118C00011
#This counter shows the sum of samples for total number of CA UEs in the current cell configured as a PCell, which have 2 configured SCells in UL..
${UE_PCELL_5_CONF_SCELL_DL_SA}    M55118C00013
#The current number of PCell UEs with exactly 5 configured SCells in DL in SA mode is calculated when the sample timer expires.
${GNB_DU_SCELL_5_ADMI_REQ_SA}    M55139C03003
#This counter describes the number of radio admission requests for exactly 5 SCells before the CA configuration on RRC.
#It's measured in PCell in SA mode in DU only.
${GNB_DU_SCELL_5_ADMI_SUCC_SA}    M55139C03006
#This counter describes the number of successful radio admission requests for exactly 5 SCells before the CA configuration on RRC.
#It's measured in PCell in SA mode in DU only.
${GNB_SCELL_5_ADMI_REQ_SA}    M55138C03504
#This counter describes the number of radio admission requests for exactly 5 SCells before the CA configuration on RRC.
#It's measured in PCell in SA mode only.
${UE_SCELL_5_CONF_SCELL_DL_SA}    M55118C00018
#Sum of CA UEs in the current cell configured as an SCell that have 5 configured SCells in DL.
${GNB_SCELL_5_ADMI_SUCC_SA}    M55138C03507
#This counter describes the number of successful radio admission requests for exactly 5 SCells before
#the CA configuration on RRC. It's measured in the PCell in SA mode only.
${MAX_UE_PCELL_2_CONF_SCEL_UL_SA}    M55156C00021
#This counter shows the maximum of samples for the total number of CA UEs in the current cell configured as a PCell,
#which have 2 configured SCells in UL.
${MAX_UE_PCELL_5_CONF_SCEL_DL_SA}    M55156C00027
#This counter shows the maximum of samples for the total number of CA UEs in the current cell configured as a
#PCell with 5 configured SCells in DL.
${UE_SCELL_2_CONF_SCELL_UL_SA}    M55118C00016
#This counter shows the sum of samples for the total number of CA UEs in the current cell configured as a
#UL SCell while pegged in the secondary cell, which have 2 configured SCells in UL.



*** Test Cases ***
CB008294-ET-A013_UE_intra-band_CA_in_mmW_band_with_up_to_4CCs_in_DL_and_2CCs_in_UL_contiguous_component_carriers
    [Documentation]
    ...    1. This User Scenario shall validate asymmetric CA functionality with Analog Beamforming in mmW bands (FR2)
    ...       for multi 5G-UE scenario considering UE capabilities. when Pcell use frequency in lowest 4CCs in_DL and 2CCs
    ...       in UL will be blind added successfully.
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
    ...           a. UE attach to cell-1.
    ...           b. Setup PDU session.
    ...           c. Start traffic.
    ...           d. UE release.
    ...    4. Expected Results:
    ...           a. UE1 is attch to cell-1 as PScell successfully.
    ...           b. Setup PDU session and then scell blind add (CA_pcell cell-1; DL_CA cell-2, cell-3 and cell-4; ul_CA cell-2) successfully.
    ...           c. Traffic is ok as expect on PScell and Scell.
    ...           d. UE1 release successfully.
    [Tags]    QC_321762    013    CA_LABEL-TTTT(100Mhz_TDD_n257_n257_n257_n257)
    Clear Counter files    ${False}
    OnlineParamChange    ${A013_parameter_update}
    UE 4CC DL 2CC UL CA Check     ue_id=1
    Release UE    ue_id=1
    Check WireShark Log    ${CURDIR}${/}A2A_A013${/}a2a.ini    wait_string=UEContextReleaseComplete::4
    Check Counters    ${A013_PM_Counters_Check}
    [Teardown]    Teardown for A013

CB008294-ET-A015_UE_intra-band_CA_in_mmW_band_ICS_without_PDU_session_6CCDL_3CCUL
    [Documentation]
    ...    1. This User Scenario shall validate asymmetric CA functionality with Analog Beamforming in mmW bands (FR2)
    ...       for multi 5G-UE scenario considering UE capabilities. Specifies that ICS is always sent in response to
    ...       registration request in initial UE messagewhen Pcell use frequency in lowest 6CCs in_DL and 3CCs
    ...       in UL will be blind added successfully.
    ...    2. Configuration
    ...         gNBs host following cells:
    ...                                 Cell-1    Cell-2    Cell-3    Cell-4    Cell-5    Cell-6    cell-7     cell-8
    ...    Technology                    TDD      TDD      TDD        TDD        TDD       TDD       TDD       TDD
    ...          Band                    n257     n257     n257       n257       n257      n257      n257      n257
    ...           Pci                     50       51       52         53         54       55         56       57
    ...     Bandwidth                    100      100      100        100        100       100       100       100
    ...            BF                    Yes      Yes      Yes        Yes        Yes       Yes       Yes       Yes
    ...         Arfcn                2071591    2073257    2074923    2076589    2078255    2079921    2081587    2083253
    ...    maxNumOfUsersPerNRCell        275      275      275        275        275       275       275       275
    ...    maxNumOfSCellAlloc            250      250      250        250        250       250       250       250
    ...        LCELNR                   DL/UL    DL/UL    DL/UL      DL/UL      DL/UL     DL/UL     DL/UL     DL/UL
    ...    weightForSCellSelection    all cells are 50
    ...    2. Test Case Steps:
    ...           a. caConfigurationSupportFr2Sa set to none.
    ...           b. Specifies that ICS is always sent in response to registration request in initial UE message
    ...           c. UE attach to cell-1.
    ...           d. Setup PDU session.
    ...           e. Start traffic.
    ...           f. UE release.
    ...    4. Expected Results:
    ...           b. PDU session will setup after ueContextModification.
    ...           c. UE is attch to cell-1 as PScell successfully.
    ...           d. Setup PDU session and then scell blind add (CA_pcell_cell-1, DL_cell-2, cell-3 cell-4, cell-5 and
    ...              cell-6; ul_CA cell-2) successfully.
    ...           e. Traffic is ok as expect on PScell and Scell.
    ...           f. UE1 release successfully.
    [Tags]    QC_321773    015    CA_LABEL-TTTTTT(100Mhz_TDD_n257_n257_n257_n257_n257_n257)
    Clear Counter files    True
    UE 6CC DL 3CC UL CA Check
    Release UE
    Check WireShark Log    ${CURDIR}${/}A2A_A015${/}a2a.ini    wait_string=UEContextReleaseComplete::4
    Check Counters    ${PM_Counters_Check_A015}

CB008294-ET-A044_UE_intra-band_CA_in_mmW_band_to_8DL_4UL_contiguous_component_carriers_and_Pcell_frequency_in_lowest
    [Documentation]
    ...    1. This user scenario describes when how to configure Beam Group to UE and how Beam Group change works in FR2 SA Cell.
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
    ...        LCELNR                   DL/UL    DL/UL    DL/UL      DL/UL      DL         DL        DL        DL
    ...    weightForSCellSelection    all cells are 50
    ...    2.Test Case Steps:
    ...          a. UE1 attach to cell-1, Setup PDU session.
    ...          b. Trigger beamgroup change from beamGroupId#0(beamid 0) to beamGroupId#2(beamid 12) to beamGroupId#1(beamid 23)
    ...          c. UE1 release.
    ...          d. UE2 attach to cell-1 with UE capabilities maxconfigureResourceallcc set to 256, Setup PDU session.
    ...          e. Trigger beamgroup change from beamGroupId#0(beamid 0) to beamGroupId#2(beamid 12) to beamGroupId#1(beamid 23)
    ...    3. Expected Results:
    ...          a: UE1 L3 CALL setup and 8DL/4UL CA blind successfully.
    ...          b. Trigger beamgroup change successfully.
    ...          c. UE1 release successfully.
    ...          d: UE2 L3 CALL setup and 8DL/4UL CA blind successfully.
    ...          e. Trigger beamgroup change successfully.
    [Tags]     QC_325468    044    CA_LABEL-8T(100Mhz_TDD_n257)
    UE 8CC DL 4CC UL CA Check    ue_id=1
    UE Beamgroup Change    ue_id=1
    Release UE
    UE 8CC DL 4CC UL CA Check    ue_id=2    UE_Capabilities=${CAPA_CB008294_A_8CC_n257_maxconfigureResourceallcc_256}
    UE Beamgroup Change UE2    ue_id=2
    Check WireShark Log    ${CURDIR}${/}A2A_A044${/}a2a.ini    wait_string=UEContextReleaseComplete::4

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sa_mmwv/FS/8cells_8T_8DL_4UL_ecpri

UE 6CC DL 3CC UL CA Check
    [Arguments]    ${ue_id}=1    ${CC_num}=6
    Execute Egate Command    amf_param id=1 send_ics_registration=on
    Set UE Capability    ue_id=${ue_id}    UE_Capabilities=${SA_Capa_6T}
    SA CA UE Setup PDU Session And Check CA Addition Successfully    ue_id=${ue_id}    expect_regexp=${A015_expect_regexp}
    Traffic Send For A15    ue_id=${ue_id}
    Throughput Check    ue_id=${ue_id}    Tput=810    CC_num=6    type=pdsch
    Throughput Check    ue_id=${ue_id}    Tput=315    CC_num=3    type=pusch

UE 4CC DL 2CC UL CA Check
    [Arguments]    ${ue_id}=1
    Set UE Capability    ue_id=${ue_id}    UE_Capabilities=${CAPA_CB008294_A_8CC_n257}
    SA CA UE Setup PDU Session And Check CA Addition Successfully    ue_id=${ue_id}    expect_regexp=${A013_expect_regexp}
    Traffic Send For A13    ue_id=${ue_id}
    Throughput Check    ue_id=${ue_id}    Tput=810    CC_num=4    type=pdsch
    Throughput Check    ue_id=${ue_id}    Tput=180    CC_num=2    type=pusch

UE 8CC DL 4CC UL CA Check
    [Arguments]    ${ue_id}=1    ${UE_Capabilities}=${CAPA_CB008294_A_8CC_n257}
    Set UE Capability    ue_id=${ue_id}    UE_Capabilities=${UE_Capabilities}
    SA CA UE Setup PDU Session And Check CA Addition Successfully    ue_id=${ue_id}    expect_regexp=${A044_expect_regexp}
    Traffic Send For A13    ue_id=${ue_id}
    Throughput Check    ue_id=${ue_id}    Tput=810    CC_num=8    type=pdsch
    Throughput Check    ue_id=${ue_id}    Tput=180    CC_num=4    type=pusch

Release UE
    [Arguments]    ${ue_id}=1
    Release Ues    ue_type=sa    ue_id=${ue_id}

Sa CA UE Register
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${gnb_id}=2
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=${gnb_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered

SA CA UE Setup PDU Session And Check CA Addition Successfully
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${gnb_id}=2    ${expect_regexp}=${EMPTY}
    Sa CA UE Register    ue_id=${ue_id}    gnb_id=${gnb_id}    cell_id=${cell_id}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    pass_regexp=${expect_regexp}

Traffic Send For A15
    [Arguments]    ${ue_id}=1    ${sleep_time}=15s
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=2 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=3 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=4 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=5 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=6 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=8 mbps=150    UE ${ue_id}: UDP UL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=9 mbps=150    UE ${ue_id}: UDP UL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=10 mbps=50    UE ${ue_id}: UDP UL
    sleep    ${sleep_time}    sleep for Tput stable

Traffic Send For A13
    [Arguments]    ${ue_id}=1    ${sleep_time}=15s
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=2 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=3 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=4 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=5 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=6 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=8 mbps=150    UE ${ue_id}: UDP UL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=9 mbps=50    UE ${ue_id}: UDP UL
    sleep    ${sleep_time}    sleep for Tput stable

Throughput Check
    [Arguments]    ${ue_id}=1    ${Tput}=540    ${CC_num}=4    ${type}=pdsch
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=${type}    pass_regexp=Average
    ${all_tput}    set variable    0
    FOR    ${id}    IN RANGE    0    ${CC_num}
        ${id}=    convert to string    ${id}
        ${cell_tput}    Scell Throughput Check    ${ue_id}    ${id}    type=${type}
        ${all_tput}    Evaluate    ${all_tput}+${cell_tput}
    END
    Should Be True    ${all_tput}/1000 > ${Tput}

Scell Throughput Check
    [Arguments]    ${ue_id}=1    ${scell_id}=0    ${type}=pdsch
    [Return]    ${scell_tput}
    ${scell_tput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=${scell_id}    type=${type}    rate_type=ave
    Should Be True    ${scell_tput}/1000 > 0

Set UE Capability
    [Arguments]    ${ue_id}=1    ${UE_Capabilities}=${SA_Capa_perUE_Full}
    Execute Egate Command    ue_param id=${ue_id} ue_nr_capabilities=${UE_Capabilities}

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${False}

Teardown for A013
    OnlineParamChange    ${A013_parameter_recover}
    Common Test Teardown And Stop Capture Logs

UE Beamgroup Change
    [Arguments]    ${ue_id}=1
    Execute Egate Command    csi_override_testmode_nr profile_id=1 cqi_mode=fixed cqi=15 ri_mode=fixed ri=1 pmi_mode=fixed pmi=1
    Execute Egate Command    ue_testmode_set_nr id=1 testmode=csi_override action=activate profile_id=1 scell=0-7
    Beamgroup Change Trigger Active    ue_id=${ue_id}
    sleep    5s    sleep for Tput stable
    Throughput Check    ue_id=${ue_id}    Tput=810    CC_num=8    type=pdsch
    Throughput Check    ue_id=${ue_id}    Tput=180    CC_num=4    type=pusch
    Beamgroup Change Trigger Deactive    ue_id=${ue_id}
    sleep    5s    sleep for Tput stable
    Throughput Check    ue_id=${ue_id}    Tput=810    CC_num=8    type=pdsch
    Throughput Check    ue_id=${ue_id}    Tput=180    CC_num=4    type=pusch

Beamgroup Change Trigger Active
    [Arguments]    ${ue_id}=1
    Beam Testmod Set    ue_id=${ue_id}    profile_id=2    Initial=0,1,2,3,7,8,9,10    bestbeam=0    beamaction=attach
    Beam Testmod Set    ue_id=${ue_id}    profile_id=3    Initial=0    bestbeam=12    beamaction=switch    expect_regexp=${Beamswitch_expect_regexp}
    Beam Testmod Set    ue_id=${ue_id}    profile_id=4    Initial=10    bestbeam=23    beamaction=switch    expect_regexp=${Beamswitch_expect_regexp}

UE Beamgroup Change UE2
    [Arguments]    ${ue_id}=1
    Execute Egate Command    csi_override_testmode_nr profile_id=1 cqi_mode=fixed cqi=15 ri_mode=fixed ri=1 pmi_mode=fixed pmi=1
    Execute Egate Command    ue_testmode_set_nr id=1 testmode=csi_override action=activate profile_id=1 scell=0-7
    Beamgroup Change Trigger Active UE2    ue_id=${ue_id}
    sleep    5s    sleep for Tput stable
    Throughput Check    ue_id=${ue_id}    Tput=810    CC_num=8    type=pdsch
    Throughput Check    ue_id=${ue_id}    Tput=180    CC_num=4    type=pusch
    Beamgroup Change Trigger Deactive    ue_id=${ue_id}
    sleep    5s    sleep for Tput stable
    Throughput Check    ue_id=${ue_id}    Tput=810    CC_num=8    type=pdsch
    Throughput Check    ue_id=${ue_id}    Tput=180    CC_num=4    type=pusch

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
