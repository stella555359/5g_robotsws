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

@{C004_Shutting_Down_Pcell}
...    NRBTS:actGrflShdn=true
...    NRCELL-1:administrativeState=Shutting Down

@{C004_unlock_Pcell}
...    NRBTS:actGrflShdn=false
...    NRCELL-1:administrativeState=Unlocked

@{8DL4UL_expect_regexp}
...    pcid:51, scellIdx:1] configure_0_1
...    pcid:53, scellIdx:3] configure_0_1
...    pcid:50, scellIdx:0] configure_0_1
...    pcid:52, scellIdx:2] configure_0_1
...    pcid:51, scellIdx:1] configure_1_1
...    pcid:53, scellIdx:3] configure_1_1
...    pcid:55, scellIdx:5] configure_1_1
...    pcid:57, scellIdx:7] configure_1_1
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

@{PM_Counters_Check}
...    NRDU-1:NF1CD:${F1_DU_P_RESET_RCV}=1
...    NRDU-1:NF1CD:${F1_DU_P_RESET_ACK_SENT}=1
...    NRBTS-1:NE1CB:${E1_RESET_SENT_CUCP}=1
...    NRBTS-1:NE1CB:${E1_RESET_ACK_RECD_CUCP}=1
...    NRBTS-1:NNGCB:${NG_CU_RESET_REQ_SENT}=1
...    NRBTS-1:NNGCB:${NG_CU_RESET_ACK_RCV}=1

${F1_DU_P_RESET_RCV}           M55117C01512
#F1_DU_P_RESET_RCV (M55117C01512) shall be increased by gNB-DU when a RESET message for Partial Reset is received on F1.
${F1_DU_P_RESET_ACK_SENT}      M55117C01513
#F1_DU_P_RESET_ACK_SENT (M55117C01513) shall be increased by gNB-DU when a RESET ACKNOWLEDGE for Partial Reset is sent out on F1.
${E1_RESET_SENT_CUCP}       M55121C00501
#E1_RESET_SENT_CUCP (M55121C00501) shall be increased by gNB-CU-CP when a RESET message for is sent out on E1.
${E1_RESET_ACK_RECD_CUCP}      M55121C00502
#E1_RESET_ACK_RECD_CUCP (M55121C00502) shall be increased by gNB-CU-CP when a RESET ACKNOWLEDGE message is received on E1.
${NG_CU_RESET_REQ_SENT}           M55119C00011
#NG_CU_RESET_REQ_SENT (M55119C00011) shall be incremented every time an NGAP : NG Reset message is sent by the gNB-CU.
${NG_CU_RESET_ACK_RCV}      M55119C00014
#NG_CU_RESET_ACK_RCV (M55119C00014) shall be incremented every time an NGAP : NG Reset Acknowledge message is received by the gNB-CU.


*** Test Cases ***
CB008294-ET-C001_Pcell_Lock_And_Unlock
    [Documentation]
    ...    1. This User Scenario shall validate asymmetric CA functionality with Analog Beamforming in mmW bands (FR2)
    ...       for multi 5G-UE scenario considering UE capabilities. when Pcell lock will trigger E1AP/F1AP/NGAP reset
    ...       after Pcell unlock 8CC will be blind added successfully.
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
    ...           a. UE1 attach to cell-1, setup PDU session and then start traffic.
    ...           b. Lock Pcell.
    ...           c. Unlock Pcell.
    ...           d. UE1 attach to cell-1, setup PDU session, Start traffic.
    ...           e. UE2 attach to cell-1, setup PDU session, Start traffic.
    ...           f. Release all UEs.
    ...    4. Expected Results:
    ...           a. Setup PDU session successfully and no CA scell added, traffic is on going as expect.
    ...           b. Pcell locked successfully, E1AP/F1AP/NGAP reset, UE release.
    ...           c. Unlock Pcell successfully.
    ...           d. UE1 8CC CA setup successfully, traffic is ok as expect.
    ...           e. UE2 8CC CA setup successfully, traffic is ok as expect.
    ...           f. Release all UEs successfully.
    [Tags]    QC_323930    C001    CA_LABEL-8T(100Mhz_TDD_n257)
    Clear Counter files    False
    UE with 8DL4UL capability Scelladd     ue_id=1    dl_cc_num=8    ul_cc_num=4    expect_regexp=${8DL4UL_expect_regexp}
    ...    min_dltput=410    min_ultput=160
    Lock Cell1
    Unlock Cell1
    UE with 8DL4UL capability Scelladd     ue_id=1    dl_cc_num=8    ul_cc_num=4    expect_regexp=${8DL4UL_expect_regexp}
    ...    min_dltput=410    min_ultput=160
    UE with 8DL4UL capability Scelladd     ue_id=2    dl_cc_num=8    ul_cc_num=4    expect_regexp=${8DL4UL_expect_regexp}
    ...    min_dltput=410    min_ultput=160
    Check WireShark Log    ${CURDIR}${/}A2A_C001${/}a2a.ini    wait_string=UEContextModificationResponse::30
    Check Counters    ${PM_Counters_Check}

CB008294-ET-C004_Pcell_Shutting_Down_And_Unlock
    [Documentation]
    ...    1. This User Scenario shall validate asymmetric CA functionality with Analog Beamforming in mmW bands (FR2)
    ...       for multi 5G-UE scenario considering UE capabilities. when Pcell shutting down UE will trigger
    ...       E1AP/F1AP/NGAP reset after Pcell, unlock 8CC will be blind added successfully.
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
    ...           a. UE1 attach to cell-1, setup PDU session and then start traffic.
    ...           b. Shut down Pcell.
    ...           c. Unlock Pcell.
    ...           d. UE1 attach to cell-1, setup PDU session, Start traffic.
    ...           e. UE2 attach to cell-1, setup PDU session, Start traffic.
    ...           f. Release all UEs.
    ...    4. Expected Results:
    ...           a. Setup PDU session successfully and no CA scell added, traffic is on going as expect.
    ...           b. Pcell shutting down successfully, E1AP/F1AP/NGAP reset, UE release.
    ...           c. Unlock Pcell successfully.
    ...           d. UE1 8CC CA setup successfully, traffic is ok as expect.
    ...           e. UE2 8CC CA setup successfully, traffic is ok as expect.
    ...           f. Release all UEs successfully.
    [Tags]    QC_323927    C004    CA_LABEL-8T(100Mhz_TDD_n257)
    Clear Counter files    True
    UE with 8DL4UL capability Scelladd     ue_id=1    dl_cc_num=8    ul_cc_num=4    expect_regexp=${8DL4UL_expect_regexp}
    ...    min_dltput=410    min_ultput=160
    OnlineParamChange Shutting Down Pcell    ${C004_Shutting_Down_Pcell}
    OnlineParamChange    ${C004_unlock_Pcell}
    UE with 8DL4UL capability Scelladd     ue_id=1    dl_cc_num=8    ul_cc_num=4    expect_regexp=${8DL4UL_expect_regexp}
    ...    min_dltput=410    min_ultput=160
    UE with 8DL4UL capability Scelladd     ue_id=2    dl_cc_num=8    ul_cc_num=4    expect_regexp=${8DL4UL_expect_regexp}
    ...    min_dltput=410    min_ultput=160
    Check WireShark Log    ${CURDIR}${/}A2A_C004${/}a2a.ini    wait_string=UEContextModificationResponse::30
    Check Counters    ${PM_Counters_Check}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sa_mmwv/FS/8cells_8T_8DL_4UL_ecpri

Set UE Capability
    [Arguments]    ${ue_id}=1    ${UE_Capabilities}=${SA_Capa_perUE_Full}
    Execute Egate Command    ue_param id=${ue_id} ue_nr_capabilities=${UE_Capabilities}

UE with 8DL4UL capability Scelladd
    [Arguments]    ${ue_id}=1    ${dl_cc_num}=2    ${ul_cc_num}=2    ${expect_regexp}=${EMPTY}    ${min_dltput}=410    ${min_ultput}=160
    Set UE Capability    ue_id=${ue_id}    UE_Capabilities=${CAPA_CB008294_A_8CC_n257}
    SA CA UE Setup PDU Session And Check CA Addition Successfully    ue_id=${ue_id}    expect_regexp=${expect_regexp}
    Traffic Send    ue_id=${ue_id}
    Throughput Check    ue_id=${ue_id}

Sa CA UE Register
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${gnb_id}=2
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=${gnb_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered

SA CA UE Setup PDU Session And Check CA Addition Successfully
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${gnb_id}=2    ${expect_regexp}=${EMPTY}
    Sa CA UE Register    ue_id=${ue_id}    gnb_id=2    cell_id=1
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    sim_debug_log level=4
    Execute Egate Command    uec_l2_testmode_params fixed_csi_report=true
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    pass_regexp=${expect_regexp}

Traffic Send
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=2 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=3 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=8 mbps=175    UE ${ue_id}: UDP UL

Throughput Check
    [Arguments]    ${ue_id}=1    ${Tput_dl}=410    ${Tput_ul}=160    ${sleep_time}=15s    ${CC_num}=8
    sleep    ${sleep_time}    sleep for Tput stable
    ${ret0}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-3 type=pusch    pass_regexp=Average
    ${allul_tput}    set variable    0
    FOR    ${id}    IN RANGE    0    4
        ${id}=    convert to string    ${id}
        ${cell_tput}    Scell Throughput Check UL    ${ue_id}    ${id}
        ${allul_tput}    Evaluate    ${allul_tput}+${cell_tput}
    END
    Should Be True    ${allul_tput}/1000 > ${Tput_ul}
    ${ret0}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    pass_regexp=Average
    ${alldl_tput}    set variable    0
    FOR    ${id}    IN RANGE    0    ${CC_num}
        ${id}=    convert to string    ${id}
        ${cell_tput}    Scell Throughput Check    ${ue_id}    ${id}
        ${alldl_tput}    Evaluate    ${alldl_tput}+${cell_tput}
    END
    Should Be True    ${alldl_tput}/1000 > ${Tput_dl}

OnlineParamChange Shutting Down Pcell
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cell Should Be Locked    1

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${False}

Scell Throughput Check
    [Arguments]    ${ue_id}=1    ${scell_id}=0
    [Return]    ${scell_tput}
    ${scell_tput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput}/1000 > 0

Scell Throughput Check UL
    [Arguments]    ${ue_id}=1    ${scell_id}=0
    [Return]    ${scell_tput}
    ${scell_tput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=${scell_id}    type=pusch    rate_type=ave
    Should Be True    ${scell_tput}/1000 > 0

