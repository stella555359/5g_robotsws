*** Settings ***
Documentation
...        maintainer:   Lukasz Kordula
...        contact:      lukasz.kordula@nokia.com
...        authors:      Pawel Grabania, Lukasz Kordula
...        description:  Test Cases for CB013684-A,B,C

Resource    ./resources/CB013684_KW.robot
Resource    testsuite/Krakow/resources/former_l3_sw2/pm_counters.robot
Variables    ./resources/deltas.py

Suite Setup  Prepare suite environment  egate_config=${lua_cfg_file}  x2=False
#Suite Setup    Custom Suite Setup    # For manual run with already active egate
Suite Teardown  Clean suite environment

Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_TDD    SBTS00    CLOUD_5G_I_BOO_AP_LOO

*** Variables ***
${lua_cfg_file}=  ${CONF_DIR}/basic_setup-A.cfg
${scfc}=  ${CONF_DIR}/scfc_A.xml

${MO_ID}    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
&{CNT_A1}    id=M55316C00036    name=MACCE_HARQ_ACK_SCELL_DEACT_SA    mo_id=${MO_ID}    low=5    high=40
&{CNT_A2}    id=M55316C00035    name=MACCE_SENT_SCELL_DEACT_SA        mo_id=${MO_ID}    low=5    high=40
&{CNT_A3}    id=M55316C00033    name=MACCE_SENT_SCELL_ACT_SA          mo_id=${MO_ID}    low=5    high=40
&{CNT_A4}    id=M55316C00034    name=MACCE_HARQ_ACK_SCELL_ACT_SA      mo_id=${MO_ID}    low=5    high=40
@{COUNTERS_A}    &{CNT_A1}    &{CNT_A2}    &{CNT_A3}    &{CNT_A4}

&{CNT_B1}    id=M55118C00097    name=SCELL_CONFIG_RRC_RECNFG_DUR_SA      mo_id=${MO_ID}    low=20    high=70
&{CNT_B2}    id=M55118C00098    name=SCELL_CONFIG_DUR_SA                 mo_id=${MO_ID}    low=30    high=80
@{COUNTERS_B}    &{CNT_B1}    &{CNT_B2}

&{CNT_C1_1}    id=M55203C00001    name=AVG_NUM_OF_CAP_UE_NOM_NRCABM      mo_id=${MO_ID}    low=600    high=600
&{CNT_C1_2}    id=M55203C00002    name=AVG_NUM_OF_CAP_UE_DENOM_NRCABM    mo_id=${MO_ID}    low=300    high=300
&{CNT_C1_3}    id=M55204C00001    name=PEAK_NUM_OF_CAP_UE_NRCABM         mo_id=${MO_ID}    low=2    high=2
@{COUNTERS_C1_part_PM}    &{CNT_C1_2}    &{CNT_C1_3}
@{COUNTERS_C1_full_PM}    &{CNT_C1_1}    &{CNT_C1_2}    &{CNT_C1_3}

&{CNT_C2_2}     id=M55203C00002    name=AVG_NUM_OF_CAP_UE_DENOM_NRCABM    mo_id=${MO_ID}    low=200    high=260
&{CNT_C2_3}     id=M55204C00001    name=PEAK_NUM_OF_CAP_UE_NRCABM         mo_id=${MO_ID}    low=2    high=2

${MO_ID_1}    PLMN-PLMN/CABMCCP-1
&{CNT_C3_1}    id=M55203C00001    name=AVG_NUM_OF_CAP_UE_NOM_NRCABM       mo_id=${MO_ID_1}    low=2400    high=2400
&{CNT_C3_2}    id=M55203C00002    name=AVG_NUM_OF_CAlP_UE_DENOM_NRCABM    mo_id=${MO_ID_1}    low=300    high=300
&{CNT_C3_3}    id=M55204C00001    name=PEAK_NUM_OF_CAP_UE_NRCABM          mo_id=${MO_ID_1}    low=8      high=8
${MO_ID_2}    PLMN-PLMN/CABMCCP-2
&{CNT_C3_4}    id=M55203C00001    name=AVG_NUM_OF_CAP_UE_NOM_NRCABM       mo_id=${MO_ID_2}    low=900    high=900
&{CNT_C3_5}    id=M55203C00002    name=AVG_NUM_OF_CAlP_UE_DENOM_NRCABM    mo_id=${MO_ID_2}    low=300    high=300
&{CNT_C3_6}    id=M55204C00001    name=PEAK_NUM_OF_CAP_UE_NRCABM          mo_id=${MO_ID_2}    low=3      high=3
${MO_ID_3}    PLMN-PLMN/CABMCCP-3
&{CNT_C3_7}    id=M55203C00001    name=AVG_NUM_OF_CAP_UE_NOM_NRCABM       mo_id=${MO_ID_3}    low=600    high=600
&{CNT_C3_8}    id=M55203C00002    name=AVG_NUM_OF_CAlP_UE_DENOM_NRCABM    mo_id=${MO_ID_3}    low=300    high=300
&{CNT_C3_9}    id=M55204C00001    name=PEAK_NUM_OF_CAP_UE_NRCABM          mo_id=${MO_ID_3}    low=2      high=2
@{COUNTERS_C3}    &{CNT_C3_1}    &{CNT_C3_2}    &{CNT_C3_3}    &{CNT_C3_4}    &{CNT_C3_5}    &{CNT_C3_6}
...    &{CNT_C3_7}    &{CNT_C3_8}    &{CNT_C3_9}

@{TRF_IDS}    1    2    3

*** Test Cases ***
CB013684_A_SCell_Activaton_Deactivation
    Set actCarAgPmCount
    Set SCellActivationMethod
    Wait For Next Full Pm Interval
    Attach UE SA    ue_id_first=1    num_of_ues=2
    Generate data traffic    ue_id_first=1    num_of_ues=1    dir=dl    mbps=150    trf_ids=@{TRF_IDS}
	BuiltIn.Sleep    180s
    Detach UE SA    ue_id_first=1    num_of_ues=2
    ${pm_counters}=    Wait for next pm interval and get counters
    Verify PM Counters Are In Range    filepath=${pm_counters}    counters=@{COUNTERS_A}
    [Teardown]    Custom Test Teardown    delta=${false}

CB013684_B_SA_CA_SCell_Addition_Delay_Intra_GNB
    Set actCarAgPmCount
    Set SCellActivationMethod
    Wait For Next Full Pm Interval
    Attach UE SA    ue_id_first=1    num_of_ues=1
    Generate data traffic    ue_id_first=1    num_of_ues=1    dir=dl    mbps=150    trf_ids=@{TRF_IDS}
	BuiltIn.Sleep    180s
    Detach UE SA    ue_id_first=1    num_of_ues=1
    ${pm_counters}=    Wait for next pm interval and get counters
    Verify PM Counters Are In Range    filepath=${pm_counters}    counters=@{COUNTERS_B}
    [Teardown]    Custom Test Teardown    delta=${false}

CB013684_C_CA_band_capability_counter_per_NRCABMCCP_Profile_configuration
    Perform Delta Commissioning On gNB    delta=${delta_C1}
    Attach UE SA    ue_id_first=1    num_of_ues=2
    Wait For Next Full Pm Interval
    ${pm_counters}=    Wait for next pm interval and get counters
    Verify PM Counters Are In Range    filepath=${pm_counters}    counters=@{COUNTERS_C1_full_PM}
    Fast Deregister UE SA    ue_id_first=2    num_of_ues=1
    Fast Attach UE SA   ue_id_first=3    num_of_ues=1
    ${pm_counters}=    Wait for next pm interval and get counters
    Verify PM Counters Are In Range    filepath=${pm_counters}    counters=@{COUNTERS_C1_part_PM}
    ${pm_counters}=    Wait for next pm interval and get counters
    Verify PM Counters Are In Range    filepath=${pm_counters}    counters=@{COUNTERS_C1_full_PM}
    Fast Deregister UE SA    ue_id_first=1    num_of_ues=3
    [Teardown]    Custom Test Teardown    delta=${remove_delta_C}

CB013684_C_CA_band_capability_counter_per_NRCABMCCP_Profile_configuration_online_modification_of_parameters
    Perform Delta Commissioning On gNB    delta=${delta_C2}
    Wait For Next Full Pm Interval
    Fast Attach UE SA    ue_id_first=1    num_of_ues=1
    BuiltIn.Sleep    30s
    Set actCarAgPmCount
    BuiltIn.Sleep    15s
    Fast Attach UE SA    ue_id_first=2    num_of_ues=1
    BuiltIn.Sleep    2s
    Fast Deregister UE SA    ue_id_first=1    num_of_ues=1
    BuiltIn.Sleep    15s
    Fast Attach UE SA    ue_id_first=1    num_of_ues=1

    ${pm_counters}    Wait for next pm interval and get counters
    ${denom_val}   Get PM Counter Values from XML File    filepath=${pm_counters}    counter_id=M55203C00002    mo_id=${MO_ID}
    ${exp_val_lo}    evaluate    ${denom_val}[0] * ${2} - ${150}
    ${exp_val_hi}    evaluate    ${denom_val}[0] * ${2} - ${40}
    set test variable    &{CNT_C2_1}     id=M55203C00001    name=AVG_NUM_OF_CAP_UE_NOM_NRCABM
    ...    mo_id=${MO_ID}    low=${exp_val_lo}   high=${exp_val_hi}
    set test variable    @{COUNTERS_C2}    &{CNT_C2_1}    &{CNT_C2_2}    &{CNT_C2_3}
    Verify PM Counters Are In Range    filepath=${pm_counters}    counters=@{COUNTERS_C2}

    Fast Deregister UE SA    ue_id_first=1    num_of_ues=2
    [Teardown]    Custom Test Teardown    delta=${remove_delta_C}

CB013684_C_CA_band_capability_counter_per_NRCABMCCP_Profile_configuration_gNB_updating_UE_capability
    Perform Delta Commissioning On gNB    delta=${delta_C3}
    BuiltIn.Sleep    2s
    Attach UE SA    ue_id_first=1    num_of_ues=8
    Wait For Next Full Pm Interval
    Wait For Next Full Pm Interval
    ${pm_counters}=    Wait for next pm interval and get counters
    Verify PM Counters Are In Range    filepath=${pm_counters}    counters=@{COUNTERS_C3}
    Fast Deregister UE SA    ue_id_first=1    num_of_ues=8
    [Teardown]    Custom Test Teardown    delta=${remove_delta_C3}
