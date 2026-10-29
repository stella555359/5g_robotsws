*** Settings ***
Documentation
...      == COPYRIGHT ==
...          Nokia Networks
...      == AUTHORS ==
...        - Arkadiusz Sobejko <arkadiusz.sobejko@nokia.com>
...      == MAINTAINER ==
...        - Arkadiusz Sobejko <arkadiusz.sobejko@nokia.com>

Library    OperatingSystem
Library    ute_fsmaccess
Library    ute_wtssim
Library    taf.sbts.oam.coam.admin    WITH NAME   coam
Library    taf.ul.ue.sim.env_setup
Library    ta5g_egate
Library    ta5g_iphy
Library    ta5g_pm_counters
Library    ta5g_testline_management
Library    ta_emss
Library    ta_messaging
Library    ../../resources/former_l2_sw1/python/traffic_handling.py
Library    ../../resources/former_l2_sw1/python/ue_handling.py
Library    ../../resources/former_l2_sw1/python/common_keywords.py
Library    CB009211_resources.py

Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    ../../resources/former_l2_sw1/robot/common_keywords.robot
Resource    ../../resources/former_l2_sw1/robot/collectors.robot

*** Keywords ***
Prepare NR-DC suite environment Setup
    Log To Console    Setup started
    Logcollector start

    ${CONFIGURE_ENV}    get variable value    ${configure}    "True"
    Run keyword if  ${CONFIGURE_ENV}=="True"
    ...    Configure suite environment

    Setup egate  egate_port=20000  alias=default
    Copy iphy packet lua
    Setup devices aliases

    Enable internal mirroring for alias  gNB2
    Enable internal mirroring for alias  gNB3
    Setup emss in test

Configure suite environment
    Add gnb configuration    host_id=1    scfc=${SCF_gnb2_MN}
    Add gnb configuration    host_id=2    scfc=${SCF_gnb3_SN}
    Add simulator  sim_type=airphone  config=${AP_XML}
    Add 5gc  config=${egate_config}  edaemon_ports=22222
    Configure environment       rmod_detection_timeout=420s    validate_gnb=False

Setup devices aliases
    Create UEs alias    alias=UE   id_type=wts_5g
    Create GNB device with alias 'gNB2' identified by ip=10.0.1.2
    Create GNB device with alias 'gNB3' identified by ip=10.0.1.4
    Create AMF device with alias 'AMF1' identified by ip=10.0.1.1

CB009211 feature enable
    Configure    ${CURDIR}/../config/CB009211_feature_enable.yaml

CB009211 feature enable NR-DC configuration
    Configure    ${CURDIR}/../config/CB009211_feature_enable_NR-DC.yaml

Set feature flag ${MOC}-${ID}/${parameter} to ${value}
    Log to console    Set feature flag ${MOC}-${ID}/${parameter} to ${value}
    Configure    {'MOC': '${MOC}', 'ID': '${ID}', '${parameter}': '${value}'}

Configure intrafreq A3 RSRP HO
    Configure    ${CURDIR}/../config/intra_gNB_intra_freq_A3_RSRP_based_HO.yaml

Configure intrafreq A3 RSRP HO NR-DC configuration
    Configure    ${CURDIR}/../config/intra_gNB_intra_freq_A3_RSRP_based_HO_NR-DC.yaml

Configure interfreq A3 RSRP HO NR-DC configuration
    Configure    ${CURDIR}/../config/intra_gNB_inter_freq_A3_RSRP_based_HO_NR-DC.yaml

Configure intrafreq A3 RSRP HO B_B1
    Configure    ${CURDIR}/../config/B_B1_intra_gNB_intra_freq_A3_RSRP_based_HO.yaml

Configure intrafreq A5 RSRQ HO
    Configure    ${CURDIR}/../config/intra_gNB_intra_freq_A5_RSRQ_based_HO.yaml

Configure intrafreq A5 RSRQ HO B_B2
    Configure    ${CURDIR}/../config/B_B2_intra_gNB_intra_freq_A5_RSRQ_based_HO.yaml

Configure intrafreq A5 RSRQ HO NR-DC configuration
    Configure    ${CURDIR}/../config/intra_gNB_intra_freq_A5_RSRQ_based_HO_NR-DC.yaml

Start observer for RRCReestablishment message
    Expect message flow
    ...    UE_1:NR-RRC_RRCReestablishmentRequest as RRCReestablishmentRequest
    ...    UE_1:NR-RRC_RRCReconfiguration as RRCReconfiguration
    ...    UE_1:NR-RRC_RRCReconfigurationComplete
    ...    alias=RRCReestablishment_procedure    overall_timeout=10

Verify RRCReestablishment message
    [Arguments]    ${physcell_id}    ${reestablishment_cause}
    Flow occurred as expected    alias=RRCReestablishment_procedure
    Verify That Message Has Fields    c-RNTI eq ${crnti_UE}
    ...                               physCellId eq ${physcell_id}
    ...                               reestablishmentCause eq '${reestablishment_cause}'
    ...                               message_alias=RRCReestablishmentRequest
    ...                               flow_alias=RRCReestablishment_procedure

Get UE RNTI
    [Arguments]    ${UE_ID}
    ${crnti_UE} =    ue_handling.Get Ue CRNTI    ue_id=${UE_ID}
    Set Test Variable    ${crnti_UE}
