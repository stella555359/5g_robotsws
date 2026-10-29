*** Settings ***
Resource     keywords_CB008490.robot
Variables    keywords_CB008490.py

Documentation
...    author: Marcin Kotula
...    maintainer: Marcin Kotula (marcin.kotula@nokia.com)
...    testline: CLOUD_5G_I_[MP][MP]_AP_[LOOO]
...    release: 25R2

*** Variables ***
${TRAFFIC_DURATION_SEC_B101}=   20s

*** Keywords ***
CB008490-L-B101_SRS_port_updated
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...    This case will verify information on the new SRS ports and the UL MIMO layer is modified
    ...    based on the number of SRS ports with actCoverageNonCoherentUes = TRUE
    ...    2.Test Case Steps:
    ...         a. SA UE3 attach to CELL, setup and modify PDU session.
    ...         b. Send A4 measurement to trigger PSCell Addition.
    ...         c. Trigger change to RANK1 with activating AP ul_mimo_switch_nr and ul_sinr_testmode_nr testmode.
    ...         d. Trigger change to RANK2 with deactivating AP ul_mimo_switch_nr and ul_sinr_testmode_nr testmode.
    ...    3. Expected Results:
    ...         Step a: UE3 PDU session is successfully established.
    ...         Step b: PSCell is successfuly added.
    ...         Step c: RANK is changed to 1 with information nrofSRS-Ports port1 and maxMIMO-Layers 1.
    ...         Step d: RANK is changed to 2 with information nrofSRS-Ports port2 and maxMIMO-Layers 2.

    Register Nrdc Ue With Default Pdu Session    ue_id=3
    Sleep    5s    Wait Measurement To Configure
    Set expected message flow for A4 meas inter-gNB PSCell Addition For UE3 GNB3 during SN-initiated SNodeMod procedure
    Send A4 Measurement And Trigger Pscell Addition    ue_id=3
    Verify expected message flow for A4 meas inter-gNB PSCell Addition For UE3 GNB3 during SN-initiated SNodeMod procedure
    Change RANK to 1
    Change RANK to 2

Enable actCoverageNonCoherentUes on gNB3
    Send Delta Commissioning
    ...    input_filepath=${DELTA_FILES_PATH}/CB008490/delta_GNB-3_enable_actCoverageNonCoherentUes.json
    ...    remote_host=${REMOTE_HOST_1_IP}

Set rdRsrpCellCenteredThreshold To -128 on gNB3
    &{hop}=     Create Dictionary    host=${REMOTE_HOST_1_IP}    user=ute
    &{hops}=    Create Dictionary    proxy=${hop}

    cli.create_aashell_cli    name=ash_gnb3    hops=${hops}
    cli.setup    ash_gnb3
    cli.execute_aashell_command    name=ash_gnb3    command=rad -mpw 0x580216 0xFFFFFF64
    cli.Teardown   ash_gnb3

Change RANK to 1
    Execute Egate Command    cmd=ul_mimo_switch_nr profile_id=1 pusch_tx_mix_ratio=100 srs_tx_mix_ratio=100
    Execute Egate Command    cmd=ul_sinr_testmode_nr profile_id=2 sinr_target_pusch=-600
    execute egate command    cmd=ue_testmode_set_nr id=3 testmode=ul_mimo_switch_nr action=activate profile_id=1 cell_group=SCG
    Execute Egate Command    cmd=ue_testmode_set_nr id=3 testmode=ul_sinr action=activate profile_id=2 cell_group=SCG scell=secondary
    ...    pass_regexp=nrofSRS-Ports port1
    ...    pass_regexp=maxMIMO-Layers 1
    ...    timeout=10
    Sleep    ${TRAFFIC_DURATION_SEC_B101}

Change RANK to 2
    Execute Egate Command    cmd=ue_testmode_set_nr id=3 testmode=ul_mimo_switch_nr action=deactivate profile_id=1 cell_group=SCG
    Execute Egate Command    cmd=ue_testmode_set_nr id=3 testmode=ul_sinr action=deactivate profile_id=2 cell_group=SCG scell=secondary
    ...    pass_regexp=nrofSRS-Ports port2
    ...    pass_regexp=maxMIMO-Layers 2
    ...    timeout=10
    Sleep    ${TRAFFIC_DURATION_SEC_B101}
