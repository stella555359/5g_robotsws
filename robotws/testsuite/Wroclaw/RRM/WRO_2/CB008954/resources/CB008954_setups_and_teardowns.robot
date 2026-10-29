*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...       - Paulina Jedras <paulina.jedras@nokia.com>
...       - Malgorzata Konior <malgorzata.konior@nokia.com>
...       - Mateusz Matusik <mateusz.matusik@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Resource    CB008954_common_keywords.robot

*** Variables ***
${H_IWK103_setup}=   ${CURDIR}/../config/yaml/H_IWK103.yaml

*** Keywords ***
Prepare test environment C_B105
    Set UE capabilities    ue_id=1    ue_nr_capabilities=nr_n41_20_30_n78_20_30
    Set UE capabilities    ue_id=2    ue_nr_capabilities=nr_n41_20_40_n78_20_40

Prepare test environment D_B101
    Configure  [{'MOC':'NRREL', 'sCellAdditionMethod':'covBasedA1'}]
    Set UE capabilities    ue_id=71    ue_nr_capabilities=nr_n78_10
    ...                                ue_eutra_nr_capabilities=mrdc_n78_10
    Set UE capabilities    ue_id=72    ue_nr_capabilities=nr_n41_20_30_n78_20_30
    ...                                ue_eutra_nr_capabilities=mrdc_n41_30_n78_30
    Set UE capabilities    ue_id=73    ue_nr_capabilities=nr_n41_20_40_n78_20_40
    ...                                ue_eutra_nr_capabilities=mrdc_n41_40_n78_40
    Set UE capabilities    ue_id=74    ue_nr_capabilities=nr_n41_20_40_100_n78_20_40_100
    ...                                ue_eutra_nr_capabilities=mrdc_n41_100_n78_100
    Set UE capabilities    ue_id=75    ue_nr_capabilities=nr_n25_10_n66_10
    ...                                ue_eutra_nr_capabilities=mrdc_n25_10_n66_10
    Set UE capabilities    ue_id=76    ue_nr_capabilities=nr_n25_10_20_n66_10_20
    ...                                ue_eutra_nr_capabilities=mrdc_n25_20_n66_20
    Set UE capabilities    ue_id=77    ue_nr_capabilities=nr_n25_10_20_30_n66_10_20_30
    ...                                ue_eutra_nr_capabilities=mrdc_n25_30_n66_30

Prepare test environment E_B101_1
    Configure  [{'MOC':'NRREL', 'sCellAdditionMethod':'covBasedA1'}, {'MOC':'NRCELL', 'actEnhMultipleDedicatedBWPs': 'False'}]
    Set UE capabilities    ue_id=1    ue_nr_capabilities=nr_n41_20_40_100_n78_20
    Set UE capabilities    ue_id=2    ue_nr_capabilities=nr_n41_20_40_100_n78_20_40
    Set UE capabilities    ue_id=3    ue_nr_capabilities=nr_n41_20_40_100_n78_20_40_100

Cleanup after test E_B101_1
    Basic cleanup
    Configure  [{'MOC':'NRCELL', 'actEnhMultipleDedicatedBWPs': 'true'}]

Prepare test environment E_B101_2
    Configure  [{'MOC':'NRREL', 'sCellAdditionMethod':'covBasedA1'}, {'MOC':'NRCELL', 'ID': '4', 'actEnhMultipleDedicatedBWPs': 'False'}]
    Set UE capabilities    ue_id=1    ue_nr_capabilities=nr_n25_10_n66_10
    Set UE capabilities    ue_id=2    ue_nr_capabilities=nr_n25_10_20_n66_10_20
    Set UE capabilities    ue_id=3    ue_nr_capabilities=nr_n25_10_20_30_n66_10

Cleanup after test E_B101_2
    Basic cleanup
    Configure  [{'MOC':'NRCELL', 'ID': '4', 'actEnhMultipleDedicatedBWPs': 'true'}]

Prepare test environment E_B102_1
    Configure  [{'MOC':'NRREL', 'sCellAdditionMethod':'blind'}, {'MOC':'NRCELL', 'actEnhMultipleDedicatedBWPs': 'False'}]
    Set UE capabilities    ue_id=71    ue_nr_capabilities=nr_n41_20_40_100_n78_20
    ...                                ue_eutra_nr_capabilities=mrdc_n41_100_n78_20
    Set UE capabilities    ue_id=72    ue_nr_capabilities=nr_n41_20_40_100_n78_20_40
    ...                                ue_eutra_nr_capabilities=mrdc_n41_100_n78_40
    Set UE capabilities    ue_id=73    ue_nr_capabilities=nr_n41_20_40_100_n78_20_40_100
    ...                                ue_eutra_nr_capabilities=mrdc_n41_100_n78_100

Cleanup after test E_B102_1
    Basic cleanup
    Configure  [{'MOC':'NRCELL', 'actEnhMultipleDedicatedBWPs': 'true'}]

Prepare test environment E_B102_2
    Configure  [{'MOC':'NRREL', 'sCellAdditionMethod':'blind'}]
    Set UE capabilities    ue_id=71    ue_nr_capabilities=nr_n25_10_n78_20_40
    ...                                ue_eutra_nr_capabilities=mrdc_n25_10_n78_20_40
    Set UE capabilities    ue_id=72    ue_nr_capabilities=nr_n25_10_20_n78_20
    ...                                ue_eutra_nr_capabilities=mrdc_n25_20_n78_20
    Set UE capabilities    ue_id=73    ue_nr_capabilities=nr_n25_10_20_n78_20_40_100
    ...                                ue_eutra_nr_capabilities=mrdc_n25_20_n78_100

Prepare test environment E_B103
    Configure  [{'MOC':'NRREL', 'sCellAdditionMethod':'blind'}]
    Set UE capabilities    ue_id=1    ue_nr_capabilities=nr_n66_10_20_30_n78_20_40_100_bcs0
    Set UE capabilities    ue_id=2    ue_nr_capabilities=nr_n66_10_20_30_n78_20_40_100_bcs0


Prepare test environment CB008954-B-C-E_1
    Configure  [{'MOC':'NRREL', 'sCellAdditionMethod':'covBasedA1'}]
    Set UE capabilities    ue_id=1    ue_nr_capabilities=nr_n25_10_n41_40_n78_20
    Set UE capabilities    ue_id=2    ue_nr_capabilities=nr_n25_20_n41_40_n78_40
    Set UE capabilities    ue_id=3    ue_nr_capabilities=nr_n25_30_n41_40_n78_100
    Set UE capabilities    ue_id=4    ue_nr_capabilities=r_n25_10_n66_20_n78_20
    Set UE capabilities    ue_id=5    ue_nr_capabilities=nr_n25_20_n66_20_n78_40
    Set UE capabilities    ue_id=6    ue_nr_capabilities=nr_n25_30_n66_20_n78_100
    Set UE capabilities    ue_id=7    ue_nr_capabilities=nr_n25_30_n66_20_n78_100

Prepare test environment CB008954-D-E_1
    Configure  [{'MOC':'NRREL', 'sCellAdditionMethod':'blind'}]
    Set UE capabilities    ue_id=71    ue_nr_capabilities=nr_n41_20_30_n78_20_30
    ...                                ue_eutra_nr_capabilities=mrdc_n41_30_n78_30
    Set UE capabilities    ue_id=72    ue_nr_capabilities=nr_n41_20_40_n78_20
    ...                                ue_eutra_nr_capabilities=mrdc_n41_40_n78_20
    Set UE capabilities    ue_id=73    ue_nr_capabilities=nr_n25_10_20_30_n41_20
    ...                                ue_eutra_nr_capabilities=mrdc_n25_30_n41_20
    Set UE capabilities    ue_id=74    ue_nr_capabilities=nr_n25_10_20_30_n41_100
    ...                                ue_eutra_nr_capabilities=mrdc_n25_30_n41_100
    Set UE capabilities    ue_id=75    ue_nr_capabilities=nr_n25_10_20_n78_20_40
    ...                                ue_eutra_nr_capabilities=mrdc_n25_20_n78_40
    Set UE capabilities    ue_id=76    ue_nr_capabilities=nr_n25_10_20_30_n41_20
    ...                                ue_eutra_nr_capabilities=mrdc_n25_30_n41_20

Prepare test environment H-IWK101
    Set UE capabilities    ue_id=1    ue_nr_capabilities=nr_n78_40
    Set UE capabilities    ue_id=2    ue_nr_capabilities=nr_n78_60
    Set UE capabilities    ue_id=3    ue_nr_capabilities=nr_n78_100
    Set UE capabilities    ue_id=4    ue_nr_capabilities=nr_n41_40
    Set UE capabilities    ue_id=5    ue_nr_capabilities=nr_n41_60
    Set UE capabilities    ue_id=6    ue_nr_capabilities=nr_n41_100

Cleanup after test H-IWK101
    Basic cleanup
    Restore PS-BWP on NRCELL-1 to 20Mhz, on NRCELL-2 to 50Mhz

Prepare test environment H-IWK102
    Set UEs capabilities   first_ue_id=1     last_ue_id=20    ue_nr_capabilities=nr_n78_100
    Set UEs capabilities   first_ue_id=21    last_ue_id=30    ue_nr_capabilities=nr_n78_60
    Set UEs capabilities   first_ue_id=31    last_ue_id=40    ue_nr_capabilities=nr_n78_40
    Set UEs capabilities   first_ue_id=41    last_ue_id=50    ue_nr_capabilities=nr_n78_100
    Set UEs capabilities   first_ue_id=51    last_ue_id=60    ue_nr_capabilities=nr_n78_60
    Set UEs capabilities   first_ue_id=61    last_ue_id=70    ue_nr_capabilities=nr_n78_40

Cleanup after test H-IWK102
    Execute egate command  cmd=smf_param id=1 reset
    Execute egate command    cmd=trf_data_stop ue=1-40 dir=bi pdu=1 qfi=2
    Basic cleanup

Prepare test environment H-IWK104
    Set UEs capabilities    first_ue_id=1    last_ue_id=3    ue_nr_capabilities=nr_n25_10_n66_10
    Set UEs capabilities    first_ue_id=4    last_ue_id=6    ue_nr_capabilities=nr_n25_10_20_n66_10_20
    Set UEs capabilities    first_ue_id=7    last_ue_id=9    ue_nr_capabilities=nr_n25_10_20_30_n66_10_20_30

Prepare test environment H-IWK105
    Set UEs capabilities    first_ue_id=1    last_ue_id=2    ue_nr_capabilities=nr_n25_10_n66_10
    Set UEs capabilities    first_ue_id=3    last_ue_id=4    ue_nr_capabilities=nr_n25_10_20_n66_10_20
    Set UEs capabilities    first_ue_id=5    last_ue_id=6    ue_nr_capabilities=nr_n25_10_20_30_n66_10_20_30

Cleanup after test H-IWK104
    Basic cleanup
    Configure  [{'MOC':'NRCELL', 'ID': '3', 'actSmallestRRCSetup': 'false'}]

Prepare test environment H-IWK103
    Configure    ${H_IWK103_setup}    alias=H-IWK103
    Set UEs capabilities   first_ue_id=1    last_ue_id=20    ue_nr_capabilities=nr_n41_100_ulcg2
    Set UEs capabilities   first_ue_id=21    last_ue_id=40    ue_nr_capabilities=nr_n41_60_no_ulcg2
    Set UEs capabilities   first_ue_id=41    last_ue_id=50    ue_nr_capabilities=nr_n41_40_no_ulcg2

Cleanup after test H-IWK103
    Deconfigure    alias=H-IWK103
    Basic cleanup
    Execute egate command  cmd=smf_param id=1 reset

Prepare test environment Robust-TC1
    Configure    [{'MOC':'NRHOIF', 'ID': '1-2', 'a5MeasEnabled': 'rsrp'}]
    Set UE capabilities    ue_id=1    ue_nr_capabilities=nr_n78_60_Robust
    Set UE capabilities    ue_id=2    ue_nr_capabilities=nr_n78_60_Robust
    Set UE capabilities    ue_id=3    ue_nr_capabilities=nr_n25_20_n78_60_Robust
    start_observing_measurements    UE_3    technology=5G

Cleanup after test Robust-TC1
    Execute egate command    cmd=ue_nr_rrc_reconf_param id=1 reset
    Execute egate command    cmd=ue_nr_rrc_reconf_param id=2 reset
    stop_observing_measurements     UE_3
    Basic cleanup

Prepare test environment Robust-TC2
    Set UE capabilities    ue_id=1    ue_nr_capabilities=nr_n25_10_n41_60_n78_60_2CC
    Configure    [{'MOC': 'NRCELL', 'ID': '1', 'a2MeashoEnabledSA': 'none'}]
    start_observing_measurements    UE_1    technology=5G

Cleanup after test Robust-TC2
    stop_observing_measurements     UE_1
    Basic cleanup

Set UE capabilities
    [Arguments]         ${ue_id}    ${ue_nr_capabilities}    ${ue_eutra_nr_capabilities}=${None}
    Execute egate command
    ...    cmd=ue_param id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities} capability_file=${CURDIR}/capabilities.cfg
    Run Keyword if  '${ue_eutra_nr_capabilities}' != '${None}'
    ...    Execute egate command
    ...    cmd=ue_param id=${ue_id} ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities} capability_file=${CURDIR}/capabilities.cfg

Set UEs capabilities
    [Arguments]         ${first_ue_id}    ${last_ue_id}    ${ue_nr_capabilities}    ${ue_eutra_nr_capabilities}=${None}
    FOR    ${ue}    IN RANGE    ${first_ue_id}    ${last_ue_id}+1
        Set UE capabilities    ue_id=${ue}    ue_nr_capabilities=${ue_nr_capabilities}    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    END

Basic cleanup
    Execute egate command    cmd=trf_data_stop ue=1-50 dir=bi pdu=1 qfi=1
    Execute egate command    cmd=trf_data_stop ue=51-100 dir=bi id=2
    CB008954_setups_and_teardowns.Detach and kill UEs from 1 to 100
    Stop collecting syslog
    BuiltIn.Sleep    10s    To be sure, that all resources are released (to pass hanging resources verification)

Detach and kill UEs from ${first_ue:\d+} to ${last_ue:\d+}
    Execute egate command  cmd=ue_kill id=${first_ue}-${last_ue}
    Log to console      UEs killed, but AP cleaning may be still in progress, do not re-attach immediately
    BuiltIn.Sleep    3s

