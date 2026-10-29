*** Settings ***
Documentation
...      == COPYRIGHT ==
...          Nokia Networks
...      == AUTHORS ==
...        - Karol Rybak <karol.rybak@nokia.com>
...      == MAINTAINER ==
...        - Karol Rybak <karol.rybak@nokia.com>

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

*** Variables ***
${CONF_DIR}=             /home/ute/test_repository/testsuite/Krakow/RRM/Airphone/CB009267/config

*** Keywords ***
Attach UE SA
    [Arguments]  ${ue_id_first}  ${ue_id_last}  ${pdu}
    FOR    ${UE_ID}     IN RANGE    ${ue_id_first}       ${ue_id_last}
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

Detach UE SA
	[Arguments]  ${ue_id_first}  ${ue_id_last}
	FOR    ${UE_ID}     IN RANGE    ${ue_id_first}       ${ue_id_last}
        Execute egate command
        ...    cmd=ue_deregister id=${UE_ID} ue_deregister_type=switch_off
    END

Attach UE NSA
    [Arguments]  ${ue_id_first}  ${ue_id_last}
    FOR    ${UE_ID}     IN RANGE    ${ue_id_first}       ${ue_id_last}
        Execute egate command
        ...    cmd=ue_attach id=${UE_ID}
        sleep    2s
        Execute egate command
        ...    cmd=ue_dc_enb_start ue=${UE_ID} target_gnb=2 target_cells=1 bearer=2 type=split_scg
        sleep    2s
    END

Detach UE NSA
	[Arguments]  ${ue_id_first}  ${ue_id_last}  ${step}=1
	FOR    ${UE_ID}     IN RANGE    ${ue_id_first}       ${ue_id_last}       ${step}
        Execute egate command
        ...    cmd=ue_detach id=${UE_ID}
        sleep    5s
    END

Trigger PSCell change
    Execute egate command
    ...    cmd=ue_enb_param id=1 measurement_gap=gp0:20 mgta=ms0dot50 gap_purpose=perUE gap_trigger=gnb_triggered drx_config=off
    sleep     2s
    Execute egate command
    ...    cmd=ue_measurement_send_nr id=1 meas_id=2 event=A2
    sleep     2s
    Execute egate command
    ...    cmd=ue_measurement_send_nr id=1 meas_id=4 event=A3 srsrp_nr=19 srsrq_nr=19 phycell_id=52 nrsrp_nr=30 nrsrq_nr=30

Set maxNumScellsDlFr2SA to ${maxNumScellsDlFr2SA} and maxNumScellsUlFr2SA to ${maxNumScellsUlFr2SA}
    Log to console    Change maxNumScellsDlFr2SA to ${maxNumScellsDlFr2SA}
    ...    and to maxNumScellsUlFr2SA to ${maxNumScellsUlFr2SA}
    Set enb parameter value    param_path=NRBTS.maxNumScellsDlFr2SA    value=${maxNumScellsDlFr2SA}    bts_id=1
    Set enb parameter value    param_path=NRBTS.maxNumScellsUlFr2SA    value=${maxNumScellsUlFr2SA}    bts_id=1
    Configure  ${CONF_DIR}/changing_maxNumScellsDlFr2SA_and_maxNumScellsUlFr2SA.yaml    node_id=1

Set maxNumScellsUl to ${maxNumScellsUl} and maxNumScellsDl to ${maxNumScellsDl}
    Log to console    Change maxNumScellsUl to ${maxNumScellsUl}
    ...    and to maxNumScellsDl to ${maxNumScellsDl}
    Set enb parameter value    param_path=NRBTS.maxNumScellsDl    value=${maxNumScellsDl}    bts_id=1
    Set enb parameter value    param_path=NRBTS.maxNumScellsUl    value=${maxNumScellsUl}    bts_id=1
    Configure  ${CONF_DIR}/changing_maxNumScellsDl_and_maxNumScellsUl.yaml    node_id=1

Prepare test environment
    Configure  ${CONF_DIR}/enabling_actCarAgPmCount.yaml
