*** Settings ***
Documentation
...      == COPYRIGHT ==
...          Nokia Networks
...      == AUTHORS ==
...        - Karol Rybak <karol.rybak@nokia.com>
...        - Lukasz Kordula <lukasz.kordula@nokia.com>
...      == MAINTAINER ==
...        - Lukasz Kordula <lukasz.kordula@nokia.com>

Library     OperatingSystem
Library     ute_wtssim
Library     ute_fsmaccess
Library     ta5g_pm_counters
Library     ta5g_egate
Library     ta5g_iphy
Library     ta5g_testline_management
Library     ta_emss
Library     ta_messaging
Library     ta_logcollector
Library     taf.sbts.oam.coam.admin    WITH NAME   coam
Library     ../../resources/former_l2_sw1/python/common_keywords.py
Resource    ../../resources/former_l2_sw1/robot/common_keywords.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    taf/rfrl/bts/robot/common/gnb_scf.robot

*** Variables ***
${CONF_DIR}=             /home/ute/test_repository/testsuite/Krakow/RRM/Airphone/CB013684/config
${ue_measurement_send_nr}=    ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=20 srsrq_nr=40
        ...    phycell_id=51 nrsrp_nr=100 nrsrq_nr=50 rs_type=ssb index=4 nrs_result=30:30:30

*** Keywords ***
Custom Suite Setup
    Setup Egate    egate_port=20000    alias=default

Custom Test Teardown
    [Arguments]    ${delta}=False
    IF    ${delta}    Perform Delta Commissioning On gNB    delta=${delta}
    Run Keyword And Ignore Error   setups_and_teardowns_keywords.Add Main BTS Metadata to Report

Attach UE SA
    [Arguments]  ${ue_id_first}  ${num_of_ues}=1
    ${last_ue_plus_one}    evaluate    ${ue_id_first} + ${num_of_ues}
    FOR    ${UE_ID}     IN RANGE    ${ue_id_first}       ${last_ue_plus_one}
        ${pdu}=    Set Variable    ${UE_ID}
        Execute egate command
        ...    cmd=set_pdu_param ue=${UE_ID} pdu=${pdu} trf_type=internal
        sleep    2s
        Execute egate command
        ...    cmd=ue_register id=${UE_ID}
        sleep    2s
        Execute egate command
        ...    cmd=ue_pdu_session_setup pdu=${pdu} ue=${UE_ID} nwslice=1 gw=1
        sleep    2s
    END

Fast Attach UE SA
    [Arguments]    ${ue_id_first}    ${num_of_ues}=1
    ${ue_id_last}    evaluate    ${ue_id_first} + ${num_of_ues} - ${1}
    Execute egate command    cmd=set_pdu_param ue=${ue_id_first}-${ue_id_last} pdu=1 trf_type=internal
    sleep    1s
    Execute egate command    cmd=ue_register id=${ue_id_first}-${ue_id_last}
    sleep    1s
    Execute egate command    cmd=ue_pdu_session_setup pdu=1 ue=${ue_id_first}-${ue_id_last} nwslice=1 gw=1
    sleep    1s

Show Active UEs
    execute_egate_command_and_wait_for_data    cmd=ue_disp state=ACTIVE

Detach UE SA
    [Arguments]  ${ue_id_first}  ${num_of_ues}=1
    ${last_ue_plus_one}    evaluate    ${ue_id_first} + ${num_of_ues}
    FOR    ${UE_ID}     IN RANGE    ${ue_id_first}       ${last_ue_plus_one}
        Execute egate command
        ...    cmd=ue_deregister id=${UE_ID} ue_deregister_type=switch_off
    END

Fast Deregister UE SA
    [Arguments]  ${ue_id_first}  ${num_of_ues}=1
    ${ue_id_last}    evaluate    ${ue_id_first} + ${num_of_ues} - ${1}
    Execute egate command    cmd=ue_deregister id=${ue_id_first}-${ue_id_last} ue_deregister_type=switch_off

Attach UE NSA
    [Arguments]  ${ue_id_first}  ${num_of_ues}=1
    ${last_ue_plus_one}    evaluate    ${ue_id_first} + ${num_of_ues}
    FOR    ${UE_ID}     IN RANGE    ${ue_id_first}       ${last_ue_plus_one}
        Execute egate command
        ...    cmd=ue_attach id=${UE_ID}
        sleep    2s
        Execute egate command
        ...    cmd=ue_dc_enb_start ue=${UE_ID} target_gnb=2 target_cells=1 bearer=2 type=split_scg
        sleep    2s
    END

Detach UE NSA
    [Arguments]  ${ue_id_first}  ${num_of_ues}=1
    ${last_ue_plus_one}    evaluate    ${ue_id_first} + ${num_of_ues}
    FOR    ${UE_ID}     IN RANGE    ${ue_id_first}       ${last_ue_plus_one}
        Execute egate command
        ...    cmd=ue_detach id=${UE_ID}
        sleep    5s
    END

Prepare test environment
    Configure  ${CONF_DIR}/enabling_miNrSSBPM.yaml

Activate missed rach testmodel
    [Arguments]  ${ue_id_first}  ${num_of_ues}=1
    ${last_ue_plus_one}    evaluate    ${ue_id_first} + ${num_of_ues}
    Execute egate command
    ...    cmd=cont_res_testmode_nr profile_id=4 missed_ra_resp=5
    FOR    ${UE_ID}     IN RANGE    ${ue_id_first}       ${last_ue_plus_one}
        Execute egate command
        ...    cmd=ue_testmode_set_nr id=${UE_ID} action=activate testmode=contention_resolution profile_id=4
        sleep    5s
    END

Activate msg3 retx testmodel
    [Arguments]  ${ue_id_first}  ${num_of_ues}=1
    ${last_ue_plus_one}    evaluate    ${ue_id_first} + ${num_of_ues}
    Execute egate command
    ...    cmd=cont_res_testmode_nr profile_id=4 msg3_retx=5
    FOR    ${UE_ID}     IN RANGE    ${ue_id_first}       ${last_ue_plus_one}
        Execute egate command
        ...    cmd=ue_testmode_set_nr id=${UE_ID} action=activate testmode=contention_resolution profile_id=4
        sleep    5s
    END

Send meas A3
    Execute egate command
    ...    cmd=${ue_measurement_send_nr}
    sleep    5s

Set SCellActivationMethod
    [Arguments]  ${param_value}=bufferBased
    Perform Configuration Parameter Recommissioning On gNB    dist_name=MRBTS-1/NRBTS-1    param_name=sCellActivationMethod
    ...                                                       param_value=${param_value}

Set actCarAgPmCount
    [Arguments]  ${param_value}=true
    Perform Configuration Parameter Recommissioning On gNB    dist_name=MRBTS-1/NRBTS-1    param_name=actCarAgPmCount
    ...                                                       param_value=${param_value}

Start data traffic for UE
    [Arguments]  ${ue_id}  ${pdu}  ${dir}  ${mbps}  ${trf_ids}
    FOR    ${trf_id}     IN    @{trf_ids}
        Execute egate command
        ...    cmd=trf_data_start ue=${ue_id} pdu=${pdu} dir=${dir} trf_id=${trf_id} mbps=${mbps}
    END

Generate data traffic
    [Arguments]  ${ue_id_first}  ${num_of_ues}  ${dir}  ${mbps}  ${trf_ids}
    ${last_ue_plus_one}    evaluate    ${ue_id_first} + ${num_of_ues}
    FOR    ${UE_ID}     IN RANGE    ${ue_id_first}    ${last_ue_plus_one}
#        ${pdu}=    Set Variable    ${UE_ID}
        Start data traffic for UE    ue_id=${UE_ID}    pdu=${1}    dir=${dir}    trf_ids=${trf_ids}    mbps=${mbps}
    END

Start different traffic for UEs
    [Arguments]    ${ue_id_first}  ${num_of_ues}=1    ${step}=1
    ${last_ue_plus_one}    evaluate    ${ue_id_first} + ${num_of_ues}
    FOR    ${ue_id}     IN RANGE    ${ue_id_first}    ${last_ue_plus_one}
        ${tput}=    Evaluate    ${ue_id} * ${step}
        Execute egate command    cmd=trf_data_start ue=${ue_id} pdu=1 dir=dl trf_id=1 mbps=${tput}
    END

Stop data traffic
    [Arguments]    ${ue_id_first}  ${num_of_ues}=1    ${trf_ids}=[1]
    ${last_ue_plus_one}    evaluate    ${ue_id_first} + ${num_of_ues}
    FOR    ${ue_id}     IN RANGE    ${ue_id_first}    ${last_ue_plus_one}
        FOR    ${trf_id}    IN    @{trf_ids}
            Execute egate command    cmd=trf_data_stop ue=${ue_id} pdu=1 dir=dl trf_id=${trf_id}
        END
    END

Set UE location
    [Arguments]  ${ue_id_first}  ${num_of_ues}=1  ${cell_id}=1
    ${last_ue_plus_one}    evaluate    ${ue_id_first} + ${num_of_ues}
    FOR    ${UE_ID}     IN RANGE    ${ue_id_first}    ${last_ue_plus_one}
        Execute egate command
        ...    cmd=ue_change_location id=${UE_ID} cell=${cell_id}
    END

Get sum of counters
    [Arguments]    ${pm_counters}   ${MO_ID}    @{counters}
    ${accl}    evaluate    0
    FOR    ${el}    IN    @{counters}
        ${el_val}   ta5g_pm_counters.get_pm_counter_value    counter=${el}    localmoid=${MO_ID}    filepath=${pm_counters}
        IF    ${el_val}[0] > 0
            ${accl}    evaluate    ${accl}+${el_val}[0]
            Log to Console    ${el} --> ${el_val}[0]
        END
    END
    log to console    SUM: ${accl}
    ${acct_str}    convert to string    ${accl}
    [Return]    ${acct_str}
