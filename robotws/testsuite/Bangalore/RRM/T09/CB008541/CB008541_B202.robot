*** Settings ***
Documentation
...      == COPYRIGHT ==
...         Nokia Networks
...
...      == INTRODUCTION ==
...         CB008541: BWP Use Optimized for Feature Interworking and NR CA
...         The feature supports setting of SCell in NR CA when UE supports only the small BWP and not the
...         full carrier bandwidth of the SCell. It enables simultaneous support on one cell of Management
...         of UE Bandwidth Capabilities and of Dynamic BWP Adaptation for UE Power Saving.
...
...      == TEST SET NAME ==
...         CB008541 - BWP Use Optimized for Feature Interworking and NR CA
...
...      == TESTING SPLIT ==
...         CB008541-A-B001 SA Carrier Aggregation SCell selection for FDD PCell and FDD SCell
...         CB008541-A-B002 NSA Carrier Aggregation SCell selection for TDD PCell and TDD SCell
...         CB008541-A-B101 SA Carrier Aggregation SCell selection for FDD PCell and TDD SCell
...         CB008541-A-B102 NSA Carrier Aggregation SCell selection for FDD PCell and TDD SCell
...         CB008541-A-B201 SA Carrier Aggregation SCell selection for TDD PCell and FDD SCell
...         CB008541-A-B202 NSA Carrier Aggregation SCell selection for TDD PCell and FDD SCell
...         CB008541-A-B301 SA Carrier Aggregation SCell selection for TDD PCell and TDD SCell
...         CB008541-A-B401 Online feature activation and deactivation
...         CB008541-A-B501 SA Carrier Aggregation SCell Change
...
...      == CONTACTS ==
...       - Paulina Jedras <paulina.jedras@nokia.com>
...       - Malgorzata Konior <malgorzata.konior@nokia.com>
...       - Mateusz Matusik <mateusz.matusik@nokia.com>
...       - Maciej Madej <maciej.madej@nokia.com>
...
...      == MAINTAINER ==
...       - Maciej Madej <maciej.madej@nokia.com>
...
...      == REFERENCES ==
...         CB008541 CFAM
...
...      == HISTORY ==
...         [04.03.2022] - TC Create
...         [22.03.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=853917)
...         [13.02.2023] - CNI72007 AP_LO FDD - switch to CLOUD_5G_I_BOO_AP_LOO_SANSA_FS_ECPRI_CMWV_FDD+TDD
...         [24.02.2023] - TL type update to CLOUD_5G_I_BOO_AP_LOO
...         [27.02.2023] - revert to CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD due to unsupported custom-config in ca-agent
...         [22.06.2023] - Changing SAMPLES_BWP_UE_AMOUNTS counter range due to changes in PR703639
...         [05.07.2023] - TL type update to CLOUD_5G_I_BOO_AP_LOO

Resource    resources/CB008541_keywords_KRK.robot
#Library   taf.sbts.oam.coam.admin
#Library    taf.sw.scout    WITH NAME     scout
Resource        ../../../resources/robot/configuration_id.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_FDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_BOO_AP_LOO
    ...    CONFIGS_Krakow/CB008541/b202_FS_config.yml
    ...    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Suite Setup   Prepare test suite   ute_ca=True

*** Variables ***

${LUA_CFG}=               ${CURDIR}/config/egate_b202_FS.lua
${SCFC}=       ${CURDIR}/../../../../../custom-config/Bangalore/RRM/ET/CB008541/scfc_b202_FS.xml
${AP_XML}=     ${CURDIR}/../../../../../custom-config/Bangalore/RRM/ET/CB008541/iphy_b202_FS.xml

@{NRCELL_1_large_bwp}=  ${rb_scs30_bw60}  ${loc_and_bw_scs30_bw60}
@{NRCELL_1_small_bwp}=  ${rb_scs30_bw80}  ${loc_and_bw_scs30_bw80}

@{NRCELL_2_large_bwp}=  ${rb_scs30_bw60}  ${loc_and_bw_scs30_bw60}
@{NRCELL_2_small_bwp}=  ${rb_scs30_bw80}  ${loc_and_bw_scs30_bw80}

@{NRCELL_3_large_bwp}=  ${rb_scs15_bw30}  ${loc_and_bw_scs15_bw30}
@{NRCELL_3_small_bwp}=  ${rb_scs15_bw25}  ${loc_and_bw_scs15_bw25}

@{NRCELL_4_large_bwp}=  ${rb_scs15_bw30}  ${loc_and_bw_scs15_bw30}
@{NRCELL_4_small_bwp}=  ${rb_scs15_bw25}  ${loc_and_bw_scs15_bw25}

${bwp_config}=  ${CURDIR}/config/CB008541_B202_add_bwp_profile.yaml
${bwp_teardown}=  ${CURDIR}/config/CB008541_B202_teardown.yaml

*** Test Cases ***
[1][1.0] CB008541-B-B202 CA aware PSCell selection for FR1 cells
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...   This user story validates the successful SCell addition procedure for inter-band DL CA TDD FDD
    ...   band combination for single UE with 2 aggregated carriers in NSA mode when PSCell is chosen using
    ...   CA aware PSCell selection algorithm combined with CB008541 algorithm. PSCell is TDD carrier and single
    ...   SCell is FDD carrier. PSCell and SCell have two bandwidth parts configured - small and large. UE supports
    ...   large BWP on PSCell and small BWP on SCell.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIB + ABIO + ABIO
    ...  - NRCELL-1, NRCELL-2 - TDD -  simulated on AEHC radio module acts as PCell have the same config
    ...        NR_BAND: n41
    ...        SCS: 30kHz
    ...        large BWP: 80MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = allRb
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...        small BWP: 60MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = n162
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...
    ...   - NRCELL-3 - FDD -  simulated on AHFII radio module acts as SCell
    ...        NR_BAND: n66
    ...        SCS: 15kHz
    ...        large BWP: 40MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = allRb
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...
    ...  - NRCELL-4 - FDD -  simulated on AHFII radio module acts as SCell
    ...        NR_BAND: n66
    ...        SCS: 15kHz
    ...        large BWP: 40MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = allRb
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...        small BWP: 25MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = n133
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...  - AMF1 simulated
    ...  - UE1 - Airphone simulator
    ...        UE1 supports inter band TDD-FDD CA with up to 2CC n41A-n66A band combination.
    ...        In Feature Set Combination related to n41A-n66A CA band combination UE1 indicates:
    ...	            In  first FeatureSetDownlinkPerCC (FS#1) for B41 carrier:
    ...	                30kHz supportedSubcarrierSpacingDL
    ...	                supportedBandwidthDL = mhz80
    ...	            In first FeatureSetUplinkPerCC (FS#1) for B41 carrier:
    ...	                30kHz supportedSubcarrierSpacingUL
    ...	                supportedBandwidthUL = mhz80
    ...	            In  second FeatureSetDownlinkPerCC (FS#2) for B41 carrier:
    ...	                30kHz supportedSubcarrierSpacingDL
    ...	                supportedBandwidthDL = mhz60
    ...	            In second FeatureSetUplinkPerCC (FS#2) for B41 carrier:
    ...	                30kHz supportedSubcarrierSpacingUL
    ...	                supportedBandwidthUL = mhz60
    ...	            In second FeatureSetDownlinkPerCC (FS#3) for B66 carrier:
    ...	                15kHz supportedSubcarrierSpacingDL
    ...	                supportedBandwidthDL = mh25
    ...	            In second FeatureSetUplinkPerCC (FS#3) for B66 carrier:
    ...	                15kHz supportedSubcarrierSpacingUL
    ...	                supportedBandwidthUL = mhz25
    ...	            In second FeatureSetDownlinkPerCC (FS#4) for B66 carrier:
    ...	                15kHz supportedSubcarrierSpacingDL
    ...	                supportedBandwidthDL = mhz25
    ...	            In second FeatureSetUplinkPerCC (FS#4) for B66 carrier:
    ...	                15kHz supportedSubcarrierSpacingUL
    ...	                supportedBandwidthUL = mhz25
    ...
    ...	       channelBWs-DL = mhz60, 80 on fr1 scs-30kHz entry for B41
    ...	       channelBWs-UL = mhz60, 80 on fr1 scs-30kHz entry for B41
    ...	       channelBWs-DL = mhz25 on fr1 scs-15kHz entry for B66
    ...	       channelBWs-UL = mhz25 on fr1 scs-15kHz entry for B66
    ...
    ...        allowdBC-ListMRDC contains two band combinations
    ...         - band combination index = 1
    ...         - allowedFeatureSetList = { 1: (FS#1 + FS#3)}
    ...         - band combination index = 2
    ...         - allowedFeatureSetList = { 2: (FS#2 + FS#4)}
    ...  - UE2 - Airphone simulator
    ...        UE2 supports inter band TDD-FDD CA with up to 2CC n41A-n66A band combination.
    ...        In Feature Set Combination related to n41A-n66A CA band combination UE1 indicates:
    ...	            In  first FeatureSetDownlinkPerCC (FS#1) for B41 carrier:
    ...	                30kHz supportedSubcarrierSpacingDL
    ...	                supportedBandwidthDL = mhz80
    ...	            In first FeatureSetUplinkPerCC (FS#1) for B41 carrier:
    ...	                30kHz supportedSubcarrierSpacingUL
    ...	                supportedBandwidthUL = mhz80
    ...	            In first FeatureSetDownlinkPerCC (FS#2) for B66 carrier:
    ...	                15kHz supportedSubcarrierSpacingDL
    ...	                supportedBandwidthDL = mhz25
    ...	            In first FeatureSetUplinkPerCC (FS#2) for B66 carrier:
    ...	                15kHz supportedSubcarrierSpacingUL
    ...	                supportedBandwidthUL = mhz25
    ...
    ...	       channelBWs-DL = mhz60, 80 on fr1 scs-30kHz entry for B41
    ...	       channelBWs-UL = mhz60, 80 on fr1 scs-30kHz entry for B41
    ...	       channelBWs-DL = mhz25 on fr1 scs-15kHz entry for B66
    ...	       channelBWs-UL = mhz25 on fr1 scs-15kHz entry for B66
    ...
    ...  - gNB2 up and running with five SA cells OnAir (NRCELL-1,2 acts as PCells and NRCELL-3,4 acts as SCells)
    ...  - NRBTS/actMultipleDedicatedBWPs = true (CB007552 feature flag)
    ...  - NRBTS/NRCELL-1.actCaAwarePsCellSelectionFr1 = true
    ...  - NRBTS/NRCELL-2.actCaAwarePsCellSelectionFr1 = true
    ...  - NRBTS/NRCELL-1/actEnhMultipleDedicatedBWPs = true (CB008541-A feature flag)
    ...  - NRBTS/NRCELL-2/actEnhMultipleDedicatedBWPs = true (CB008541-A feature flag)
    ...  - NRBTS/NRCELL-1/allowUnsuppBcOrBcs = 0 "complete BCS check"
    ...  - NRBTS/NRDU/carrierAggregationSupportList =  {ca_Fr1Tdd_Sa, ca_Fr1Tdd_Fdd_Sa, ca_Fr1Tdd_Any_Sa}
    ...  - NRBTS/NRDU/actInterNumerologyCa = true
    ...  - NRCELL/NRREL-1/sCellAdditionMethod = blind in CA relation to F3
    ...  - NRCELL/NRREL-2/sCellAdditionMethod = blind in CA relation to F4
    ...
    ...  == Postconditions ==
    ...   - UE is configured with TDD cell (large BWP) as PSCell and FDD as Scell (small BWP)
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIB + ABIO + ABIO) with simulated AHFII, AEHC radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_14861
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC, NGAP pcap
    ...
    ...  == CONTACTS ==
    ...   - Maciej Madej <maciej.madej@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB008541-6219 User Scenario#1 CA aware PSCell selection for FR1 cells -  PSCell in
    ...        relation with SCell with small is taken into account due to UE supports small on SCell
    ...     -  CB008541-6686 User Scenario#2 NSA UE with 2CC carrier aggregation - SCell configured with small BWP
    ...        due to unsupported BW in gNB
    ...
    ...  == HISTORY ==
    ...     [04.03.2022] - TC Create
    ...     [22.03.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=853917)

    [Setup]  Prepare test environment B202
    [Tags]    QC_168044      QCD_MN_RAN    QCP_RAN_ET

    Attach UE1 to simulated eNB1 CELL-1
    Verify that blind SgNB Addition of gNB2 NRCELL-2 is successfully completed for UE1 to NRCELL-2
    Verify that allowedBC-ListMRDC contains two band combinations for UE1  # T2+F4, T3+F5
    Verify that UE1 connects to NRCELL-2 PSCell with small BWP profile
    Verify that NRCELL-4 SCell is configured with small BWP profile for UE1

    Wait until PM counters file is ready and saved
    Verify that M55167C00001 SAMPLES_BWP_UE_AMOUNTS counter is in range 250 - 300 in NRCELL-2 in gNB2
    Verify that M55167C00002 SUM_UE_SCELL_CONF_S_BWP counter is in range 1 - 300 in NRCELL-2 in gNB2
    Verify that M55167C00003 SUM_UE_SCELL_CONF_L_BWP counter is equal 0 in NRCELL-2 in gNB2
    Verify that M55115C03001 SGNB_DU_SCELL_ADM_S_BWP_SUCC counter is equal 1 in NRCELL-2 in gNB2
    Verify that M55115C03002 SGNB_DU_SCELL_ADM_L_BWP_SUCC counter is equal 0 in NRCELL-2 in gNB2

    #set actCaAwarePsCellSelectionFr1 to false for cells 1,2 and 3, add small BWP profile (25MHz) to NRCELL-4
    Setup enviroment for UE2

    Attach UE2 to simulated eNB1 CELL-1
    Verify that blind SgNB Addition of gNB2 NRCELL-1 is successfully completed for UE2
    Verify that UE2 connects to NRCELL-1 PSCell with small BWP profile
    Verify that NRCELL-3 SCell is configured with small BWP profile for UE2

    Wait until PM counters file is ready and saved
    Verify that M55167C00001 SAMPLES_BWP_UE_AMOUNTS counter is in range 150 - 300 in NRCELL-1 in gNB2
    Verify that M55167C00002 SUM_UE_SCELL_CONF_S_BWP counter is in range 1 - 300 in NRCELL-1 in gNB2
    Verify that M55167C00003 SUM_UE_SCELL_CONF_L_BWP counter is equal 0 in NRCELL-1 in gNB2
    Verify that M55115C03001 SGNB_DU_SCELL_ADM_S_BWP_SUCC counter is equal 1 in NRCELL-1 in gNB2
    Verify that M55115C03002 SGNB_DU_SCELL_ADM_L_BWP_SUCC counter is equal 0 in NRCELL-1 in gNB2

    [Teardown]     Run Keywords    Cleanup after test B202
    ...         AND        Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***
Prepare test environment B202
    Execute egate command  cmd=enb_endc_param id=1 serving_cell_index_range_scg=8:14
    Execute egate command  cmd=link_x2_up enb=1 target=2
    Execute egate command  cmd=enb_endc_param id=1 allowed_bc_list_mrdc=1:1|2:2|3:3
    Wait until PM counters file is ready and saved

Cleanup after test B202
    Detach and kill UEs from 1 to 2
    Configure    ${bwp_teardown}

Verify that blind SgNB Addition of gNB${gnb_id:\d+} NRCELL-${cell_id:\d+} is successfully completed for UE${ue_id:\d+} to NRCELL-2
    log to console      NRCELL-${cell_id}
    Expect ENDC flow for UE${ue_id} with gNB${gnb_id}
    Execute egate command  cmd=ue_dc_enb_start ue=${ue_id} target_gnb=${gnb_id} target_cells=1,2,3,4 bearer=2 type=split_scg
    Flow occurred as expected   alias=UE_${ue_id}_EN-DC
    verify that message fulfills query  (spCellConfigCommon contains (physCellId eq 52))
    ...    message_alias=SgnbAddAck
    ...    flow_alias=UE_${ue_id}_EN-DC

Verify that allowedBC-ListMRDC contains two band combinations for UE${ue_id}
    verify that message fulfills query  (
    ...       (
    ...            (allowedBC-ListMRDC contains
    ...                (bandCombinationIndex eq 1))
    ...	      and
    ...             (allowedBC-ListMRDC contains
    ...	             (allowedFeatureSetsList contains (1)))
    ...	      )
    ...	   and
    ...       (
    ...                (allowedBC-ListMRDC contains
    ...                (bandCombinationIndex eq 2 ))
    ...	      and
    ...             (allowedBC-ListMRDC contains
    ...	             (allowedFeatureSetsList contains (2)))
    ...	      )
    ...    )
    ...    message_alias=addReq
    ...    flow_alias=UE_${ue_id}_EN-DC

Setup enviroment for UE2
    Expect message flow
     ...    eNB1:X2AP_ENDCConfigurationUpdate
     ...    eNB1:X2AP_ENDCConfigurationUpdateAcknowledge
     ...    eNB1:X2AP_ENDCConfigurationUpdate
     ...    eNB1:X2AP_ENDCConfigurationUpdateAcknowledge
     ...    alias=Config_update   overall_timeout=120
    Configure    ${bwp_config}
    Flow occurred as expected  alias=Config_update


Outdated Request Scout SCF
    [Arguments]   ${scout_testline_name}
    [Documentation]    :Author: Michele
    ...    Request Scout SCF used inside Link SCOUT SCF to Configuration ID for Reporting KW.
    scout.setup_scout  scout_testline_name=${scout_testline_name}
    ${external_scf_id}=   scout.request_scf   use_scout_internal_id=False
    scout.teardown_scout_api
    [Return]   ${external_scf_id}

Outdated Link SCOUT SCF to Configuration ID for Reporting
    [Documentation]
    ...    Associate the SCF to the Configuration ID in Reporting Portal using SCOUT.
    ...
    ...    Example:
    ...     |  Link SCOUT SCF to Configuration ID for Reporting    node_id=${0}    node_type=enb
    ...
    ...     |param node_id | (default=0) Id/Number of Node (eNB or gNB) |
    ...     |param node_type | (default=gnb) Node type; possible values: gnb or enb |
    [Arguments]    ${node_id}=0    ${node_type}=gnb
    log to console     ${node_id}
    ${tl_name_only}      Get Hostname
    ${node_type_Name}        Run Keyword If  "${node_type}"=="gnb"   Set Variable  gNB
    ...     ELSE IF     "${node_type}"=="enb"                   Set Variable  eNB
    ...     ELSE        Fail    Wrong node_type '${node_type}'! allowed: enb|gnb
    Log To Console    ${\n}SCOUT Test Line Name: ${tl_name_only}
    ${scout_testline_name}=    Set Variable    ${tl_name_only}
    ${external_scf_id}=   Request Scout SCF   ${scout_testline_name}
    ${TC_ID}=    Set Variable    ute:id:${external_scf_id}
    Set Tags  ${TC_ID}

Outdated Get Hostname
    ${rc}  ${hostname_tmp}=  Run And Return Rc And Output  hostname
    ${hostname_tmp}=  Replace String  ${hostname_tmp}  -  _
    ${hostname_tmp}=  Convert To String  ${hostname_tmp}
    ${hostname_part}=  Split String  ${hostname_tmp}  _
    ${hostname_combined}=  Catenate  ${hostname_part[0]}_${hostname_part[1]}_${hostname_part[2]}
    Set Suite Variable  ${HOSTNAME}  ${hostname_combined}
    [Return]   ${HOSTNAME}
