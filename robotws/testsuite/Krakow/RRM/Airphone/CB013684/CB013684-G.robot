*** Settings ***
Documentation
...        maintainer:   Lukasz Kordula
...        contact:      lukasz.kordula@nokia.com
...        author:       Lukasz Kordula
...        description:  Test Cases for CB013684-G

Resource    ./resources/CB013684_KW.robot
Resource    testsuite/Krakow/resources/former_l3_sw2/pm_counters.robot
Variables    ./resources/deltas.py
Library      ./resources/CB013684_resources.py         WITH NAME    local_resources

Suite Setup  Prepare suite environment  egate_config=${lua_cfg_file}  scfc=${scfc}  x2=True
#Suite Setup    Custom Suite Setup    # For manual run with already active egate
Suite Teardown  Clean suite environment

Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_TDD    SBTS00    CLOUD_5G_I_BOO_AP_LOO

*** Variables ***
${lua_cfg_file}  ${CONF_DIR}/basic_setup.cfg
${scfc}          ${CONF_DIR}/scfc_G.xml

${MO_ID}    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
&{CNT_1}     id=M55350C07001    name=DL_PDCP_VOL_UE_TPUT_TOT    mo_id=${MO_ID}    low=90000000    high=130000000
&{CNT_2}     id=M55350C08001    name=DL_PDCP_TIME_UE_TPUT       mo_id=${MO_ID}    low=1700000     high=2600000
&{CNT_3}     id=M55350C20002    name=DL_PDCP_UE_TPUT_BIN1       mo_id=${MO_ID}    low=0      high=10
&{CNT_4}     id=M55350C20003    name=DL_PDCP_UE_TPUT_BIN2       mo_id=${MO_ID}    low=20     high=350
&{CNT_5}     id=M55350C20004    name=DL_PDCP_UE_TPUT_BIN3       mo_id=${MO_ID}    low=0      high=10
&{CNT_6}     id=M55350C20005    name=DL_PDCP_UE_TPUT_BIN4       mo_id=${MO_ID}    low=75     high=350
&{CNT_7}     id=M55350C20006    name=DL_PDCP_UE_TPUT_BIN5       mo_id=${MO_ID}    low=0      high=10
&{CNT_8}     id=M55350C20007    name=DL_PDCP_UE_TPUT_BIN6       mo_id=${MO_ID}    low=100    high=350
&{CNT_9}     id=M55350C20008    name=DL_PDCP_UE_TPUT_BIN7       mo_id=${MO_ID}    low=0      high=10
&{CNT_10}    id=M55350C20009    name=DL_PDCP_UE_TPUT_BIN8       mo_id=${MO_ID}    low=150    high=350
&{CNT_11}    id=M55350C20010    name=DL_PDCP_UE_TPUT_BIN9       mo_id=${MO_ID}    low=0      high=10
&{CNT_12}    id=M55350C20011    name=DL_PDCP_UE_TPUT_BIN10      mo_id=${MO_ID}    low=220    high=350
&{CNT_13}    id=M55350C20012    name=DL_PDCP_UE_TPUT_BIN11      mo_id=${MO_ID}    low=220    high=350
&{CNT_14}    id=M55350C20013    name=DL_PDCP_UE_TPUT_BIN12      mo_id=${MO_ID}    low=0      high=10
&{CNT_15}    id=M55350C20014    name=DL_PDCP_UE_TPUT_BIN13      mo_id=${MO_ID}    low=220    high=350
&{CNT_16}    id=M55350C20015    name=DL_PDCP_UE_TPUT_BIN14      mo_id=${MO_ID}    low=0      high=10
&{CNT_17}    id=M55350C20016    name=DL_PDCP_UE_TPUT_BIN15      mo_id=${MO_ID}    low=220    high=370
&{CNT_18}    id=M55350C20017    name=DL_PDCP_UE_TPUT_BIN16      mo_id=${MO_ID}    low=0      high=10
&{CNT_19}    id=M55350C20018    name=DL_PDCP_UE_TPUT_BIN17      mo_id=${MO_ID}    low=220    high=350
&{CNT_20}    id=M55350C20019    name=DL_PDCP_UE_TPUT_BIN18      mo_id=${MO_ID}    low=0      high=10
&{CNT_21}    id=M55350C20020    name=DL_PDCP_UE_TPUT_BIN19      mo_id=${MO_ID}    low=0      high=10
&{CNT_22}    id=M55350C20021    name=DL_PDCP_UE_TPUT_BIN20      mo_id=${MO_ID}    low=0      high=10
@{COUNTERS_G1}    &{CNT_1}    &{CNT_2}   &{CNT_3}    &{CNT_4}    &{CNT_5}    &{CNT_6}    &{CNT_7}    &{CNT_8}    &{CNT_9}
...    &{CNT_10}    &{CNT_11}    &{CNT_12}    &{CNT_13}    &{CNT_14}    &{CNT_15}    &{CNT_16}    &{CNT_17}    &{CNT_18}
...    &{CNT_19}    &{CNT_20}    &{CNT_21}    &{CNT_22}
&{COUNTERS_G1_DIV_1}    num=&{CNT_1}    denom=&{CNT_2}    low=45    high=55
@{COUNTERS_G1_DIV}    &{COUNTERS_G1_DIV_1}

&{CNT_101}    id=M55309C00036    name=DL_RLC_PDU_VOL_UE_TPUT_FR2        mo_id=${MO_ID}    low=200000       high=400000000
&{CNT_102}    id=M55309C00037    name=DL_RLC_PDU_TIME_UE_TPUT_FR2       mo_id=${MO_ID}    low=700          high=1500000
&{CNT_103}    id=M55309C00002    name=DL_MAC_SDU_VOL_UE_TPUT            mo_id=${MO_ID}    low=200000       high=400000000
&{CNT_104}    id=M55309C00003    name=DL_MAC_SDU_TIME_UE_TPUT           mo_id=${MO_ID}    low=700          high=1500000
&{CNT_105}    id=M55373C00001    name=DL_RLC_VOL_UE_TPUT_PMQAP_FR2      mo_id=${MO_ID}    low=200000       high=400000000
&{CNT_106}    id=M55373C00002    name=DL_RLC_TIME_UE_TPUT_PMQAP_FR2     mo_id=${MO_ID}    low=700          high=1500000
&{CNT_107}    id=M55352C01002    name=DL_PDCP_VOL_UE_TPUT_5G_PMQAP      mo_id=${MO_ID}    low=60000000     high=300000000
&{CNT_108}    id=M55352C01003    name=DL_PDCP_TIME_UE_TPUT_5G_PMQAP     mo_id=${MO_ID}    low=200000       high=1250000
&{CNT_109}    id=M55352C01004    name=DL_PDCP_VOL_UE_TPUT_LTE_PMQAP     mo_id=${MO_ID}    low=0            high=0
&{CNT_110}    id=M55352C01005    name=DL_PDCP_TIME_UE_TPUT_LTE_PMQAP    mo_id=${MO_ID}    low=0            high=0
@{COUNTERS_G2}    &{CNT_101}    &{CNT_102}    &{CNT_103}    &{CNT_104}    &{CNT_105}    &{CNT_106}    &{CNT_107}
...    &{CNT_108}    &{CNT_109}    &{CNT_110}
&{COUNTERS_G2_DIV_1}    num=&{CNT_101}    denom=&{CNT_102}    low=270    high=300
&{COUNTERS_G2_DIV_2}    num=&{CNT_103}    denom=&{CNT_104}    low=270    high=300
&{COUNTERS_G2_DIV_3}    num=&{CNT_105}    denom=&{CNT_106}    low=270    high=300
&{COUNTERS_G2_DIV_4}    num=&{CNT_107}    denom=&{CNT_108}    low=270    high=300

@{COUNTERS_G2_1}    &{CNT_107}    &{CNT_108}
@{COUNTERS_G2_1_DIV}    &{COUNTERS_G2_DIV_4}
@{COUNTERS_G2_2}    &{CNT_101}    &{CNT_102}    &{CNT_103}    &{CNT_104}    &{CNT_105}    &{CNT_106}    &{CNT_107}
...    &{CNT_108}    &{CNT_109}    &{CNT_110}
@{COUNTERS_G2_2_DIV}    &{COUNTERS_G2_DIV_1}    &{COUNTERS_G2_DIV_2}    &{COUNTERS_G2_DIV_3}    &{COUNTERS_G2_DIV_4}

@{old_releases}           SBTS25R3    SBTS25R2

*** Test Cases ***
CB013684_G_DL_Throughput_Distribution_Non_PMQAP_Profile
    Perform Delta Commissioning On gNB    delta=${delta_G1}
    Wait For Next Full Pm Interval
    Fast Attach UE SA    ue_id_first=1    num_of_ues=9
    Start different traffic for UEs     ue_id_first=1    num_of_ues=9    step=9
    Show Active UEs
    Wait For Next Full Pm Interval
    ${pm_counters}=  Wait for next pm interval and get counters
    run keyword and continue on failure    local_resources.my_counters_validator    ${COUNTERS_G1}    ${pm_counters}
    run keyword and continue on failure    local_resources.verify_counters_division_list   ${COUNTERS_G1_DIV}    ${pm_counters}

    Fast Deregister UE SA    ue_id_first=1    num_of_ues=9
    [Teardown]    Custom Test Teardown    delta=${remove_delta_G1}

CB013684_G_Online_modification_of_discard_parameters
    set test variable    @{TRF_IDS}    1    2
    ${release}=    Get gNB Sw Release Name
    ${delta_G2_1}    Set Variable If    '${release}' not in ${old_releases}    ${delta_G2_1_from_26R1}    ${delta_G2_1_25R3}
    Perform Delta Commissioning On gNB    delta=${delta_G2_1}

    Wait For Next Full Pm Interval
    Fast Attach UE SA    ue_id_first=1    num_of_ues=2
    Generate data traffic    ue_id_first=1    num_of_ues=2    dir=dl    mbps=150    trf_ids=@{TRF_IDS}
    Show Active UEs

    ${pm_counters}=  Wait for next pm interval and get counters
    run keyword and continue on failure    local_resources.my_counters_validator    ${COUNTERS_G2_1}    ${pm_counters}
    run keyword and continue on failure    local_resources.verify_counters_division_list   ${COUNTERS_G2_1_DIV}    ${pm_counters}
    Perform Delta Commissioning On gNB    delta=${delta_G2_2}

    ${pm_counters}=  Wait for next pm interval and get counters
    run keyword and continue on failure    local_resources.my_counters_validator    ${COUNTERS_G2_1}    ${pm_counters}
    run keyword and continue on failure    local_resources.verify_counters_division_list   ${COUNTERS_G2_1_DIV}    ${pm_counters}
    Stop data traffic    ue_id_first=1    num_of_ues=2    trf_ids=@{TRF_IDS}
    BuiltIn.Sleep    10s
    Generate data traffic    ue_id_first=1    num_of_ues=2    dir=dl    mbps=150    trf_ids=@{TRF_IDS}
    ${pm_counters}=  Wait for next pm interval and get counters
    run keyword and continue on failure    local_resources.my_counters_validator    ${COUNTERS_G2_2}    ${pm_counters}
    run keyword and continue on failure    local_resources.verify_counters_division_list   ${COUNTERS_G2_2_DIV}    ${pm_counters}

    Fast Deregister UE SA    ue_id_first=1    num_of_ues=2
    Perform Delta Commissioning On gNB    delta=${remove_delta_G2_2}
    [Teardown]    Custom Test Teardown    delta=${remove_delta_G2_1}
