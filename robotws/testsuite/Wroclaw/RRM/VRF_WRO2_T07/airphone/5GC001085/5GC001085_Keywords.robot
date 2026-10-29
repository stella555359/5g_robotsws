*** Settings ***
Documentation
...  Author:   Marcin Plawny
...  Contact:  marcin.plawny@nokia.com

Resource    ../../../resources/airphone/5G_SW_WRO_Keywords.robot
Library    ta5g_testline_management
Library    ta5g_ue_measurements
Library    ta5g_enb
Library    ta5g_delta
Library    ta5g_iphy
Library    ta5g_throughput
Library    ta5g_commissioning
Library    ta5g_admin_operations
Library    ta5g_syslog

*** Variables ***
${NRREL_OBJECT_CREATION_TIME}    150
${NRREL_ID}    256
@{swconfig_rndFlag}    0x890062 = 5
@{swconfig_rndFlag_default}    0x890062 = 60

*** Keywords ***
Start Vm Ethernet Interfaces
    Start Vm Ethernet Interface    if_name=eth3:gNB2_XN    ip_with_mask=10.0.1.101/24
    Start Vm Ethernet Interface    if_name=eth3:gNB2_NG    ip_with_mask=10.0.1.102/24
    Start Vm Ethernet Interface    if_name=eth3:gNB4_XN    ip_with_mask=10.0.1.103/24
    Start Vm Ethernet Interface    if_name=eth3:gNB4_NG    ip_with_mask=10.0.1.104/24
    Start Vm Ethernet Interface    if_name=eth3:gNB2_X2    ip_with_mask=10.0.1.3/24
    Start Vm Ethernet Interface    if_name=eth3:eNB1_X2    ip_with_mask=10.0.1.138/24

Stop Vm Ethernet Interfaces
    Stop Vm Ethernet Interface    if_name=eth3:gNB2_XN    ip_with_mask=10.0.1.101/24
    Stop Vm Ethernet Interface    if_name=eth3:gNB2_NG    ip_with_mask=10.0.1.102/24
    Stop Vm Ethernet Interface    if_name=eth3:gNB4_XN    ip_with_mask=10.0.1.103/24
    Stop Vm Ethernet Interface    if_name=eth3:gNB4_NG    ip_with_mask=10.0.1.104/24
    Stop Vm Ethernet Interface    if_name=eth3:gNB2_X2    ip_with_mask=10.0.1.3/24
    Stop Vm Ethernet Interface    if_name=eth3:eNB1_X2    ip_with_mask=10.0.1.138/24

Attach Ue And Establish Pdu Session
    [Arguments]    ${ue_id}    ${pdu_id}=1    ${gw_id}=1
    Attach UE    ue_id=${ue_id}
    Establish PDU Session With Traffic    ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Sleep    2s    reason=Waiting for RRCReconfigurationComplete for A2 measurement report setup

Send A5 Measurement And Attempt Handover
    [Arguments]    ${ue_id}    ${meas_id}=3    ${target_phycell_id}=51    ${nrsrp_nr}=60    ${nrsrq_nr}=30
    Send Custom Ue Measurement Nr    pass_regexp=measResultListNR  get_ue_meas_cfg=1  id=${ue_id}  meas_id=${meas_id}  index=0
    ...                              nrs_result=${nrsrp_nr}:${nrsrq_nr}:0  event=A5  srsrp_nr=11  srsrq_nr=11  srs_result=0:11:11:0
    ...                              phycell_id=${target_phycell_id}  nrsrp_nr=${nrsrp_nr}  nrsrq_nr=${nrsrq_nr}  rs_type=ssb
    Sleep    3s  reason=Waiting for handover request to be processed

Attach And Establish Session For Multiple UEs
    [Arguments]    ${first_ue_id}    ${last_ue_id}
    FOR    ${i}    IN RANGE    ${first_ue_id}    ${last_ue_id}
        Attach Ue And Establish Pdu Session    ue_id=${i}
    END

Attempt Failed Intra Gnb Handover For Multiple UEs
    [Arguments]    ${first_ue_id}    ${last_ue_id}
    FOR    ${i}    IN RANGE    ${first_ue_id}    ${last_ue_id}
        Execute Egate Command    cmd=ue_nr_rrc_reconf_param id=${i} if_contains=reconfiguration_with_sync action=drop
        Send A5 Measurement And Attempt Handover    ue_id=${i}    meas_id=3    target_phycell_id=51
        Deregister UE Without Confirmation    ue_id=${i}
        Sleep    3s    reason=Waiting for previous UE release
    END

Attempt Failed Inter Gnb Handover For Multiple UEs
    [Arguments]    ${first_ue_id}    ${last_ue_id}    ${target_phycell_id}
    Execute Egate Command    cmd=gnb_xn_handover_preparation_param action=force_failure id=3
    FOR    ${i}    IN RANGE    ${first_ue_id}    ${last_ue_id}
        Send A5 Measurement And Attempt Handover    ue_id=${i}    meas_id=3    target_phycell_id=${target_phycell_id}
        Deregister UE Without Confirmation    ue_id=${i}
        Sleep    3s    reason=Waiting for previous UE release
    END

Wait And Verify Created NRREL Object
    [Arguments]    ${gnb_id}=3
    Wait For Object To Exist    object_name=NRCELL_A-1/NRREL_A-${NRREL_ID}  moc=NRREL_A  timeout=${NRREL_OBJECT_CREATION_TIME}
    &{NRREL}=    Get Managed Object    object_name=NRCELL_A-1/NRREL_A-${NRREL_ID}    moc=NRREL_A
    Verify Created NRREL Object    NRREL=&{NRREL}  mcc=${NRREL.gnbPlmn.mcc}  mnc=${NRREL.gnbPlmn.mnc}
    ...                            mncLength=${NRREL.gnbPlmn.mncLength}  gNbId=${gnb_id}  gNbIdLength=${NRREL.gNbIdLength}
    ...                            lcrId=${NRREL.lcrId}

Check Presence Of Three Initial NRREL And NRADJNRCELL
    Check If Object Exists    object_name=NRADJNRCELL_A-1    moc=NRADJNRCELL_A
    Check If Object Exists    object_name=NRADJNRCELL_A-2    moc=NRADJNRCELL_A
    Check If Object Exists    object_name=NRADJNRCELL_A-3    moc=NRADJNRCELL_A
    Check If Object Exists    object_name=NRCELL_A-1/NRREL_A-2    moc=NRREL_A
    Check If Object Exists    object_name=NRCELL_A-1/NRREL_A-3    moc=NRREL_A
    Check If Object Exists    object_name=NRCELL_A-1/NRREL_A-4    moc=NRREL_A

Remove NRBTS Objects
    [Arguments]    @{moc_list}    ${parameter}
    ${to_remove_list}    Create List
    ${object_type_list}    Create List
    FOR    ${moc_type}    IN    @{moc_list}
        ${modified_type}    Replace String    ${moc_type}    _A    ${EMPTY}
        Append To List    ${object_type_list}    ${modified_type}
    END
    ${objects_dictionary}    Get Parameter Values For Objects    object_types=${object_type_list}    mocs=${moc_list}    parameter=${parameter}
    ${objects}    Get Dictionary Keys    ${objects_dictionary}
    FOR    ${object}    IN    @{objects}
        @{split_object}    Split String    ${object}    /
        ${dist_name_a}    Create Distname A    @{split_object}
        ${dist_name}    Replace String    ${dist_name_a}    _A-    -
        Append To List    ${to_remove_list}    ${dist_name}
    END
    Delete Scf Objects    dist_names=${to_remove_list}

Create Distname A
    [Arguments]    @{split_object}
    ${dist_name_a}    Set Variable    MRBTS-1
    ${length}    Get Length    ${split_object}
    FOR    ${part}    IN RANGE    1    ${length-7}
        ${dist_name_a}    Catenate    SEPARATOR=/    ${dist_name_a}    ${split_object}[${part+7}]
    END
    [Return]    ${dist_name_a}

Verify Created NRADJGNB Object
    [Documentation]    Validate NRADJGNB object created in network plan by ANR feature.
    ...                Keyword compares requested parameters to values in SCF configuration.
    [Arguments]    ${NRADJGNB}    ${mcc}    ${mnc}    ${mncLength}    ${gNodeBIdCtrl}
    ...            ${gNbIdLength}    ${xnLinkRef}    ${administrativeState}
    Should Be Equal As Integers    ${NRADJGNB.gnbPlmn.mcc}    ${mcc}
    Should Be Equal As Integers    ${NRADJGNB.gnbPlmn.mnc}    ${mnc}
    Should Be Equal As Integers    ${NRADJGNB.gnbPlmn.mncLength}    ${mncLength}
    Should Be Equal    ${NRADJGNB.gNodeBIdCtrl}    ${gNodeBIdCtrl}
    Should Be Equal As Integers    ${NRADJGNB.gNbIdLength}    ${gNbIdLength}
    Should Be Equal As Integers    ${NRADJGNB.xnLinkRef}    ${xnLinkRef}
    Should Be Equal    ${NRADJGNB.administrativeState}    ${administrativeState}

Verify Created XNLINK Object
    [Documentation]    Validate XNLINK object created in network plan by ANR feature.
    ...                Keyword compares requested parameters to values in SCF configuration.
    [Arguments]    ${XNLINK}    ${cPlaneIpAddr}    ${cPlaneIpAddrCtrl}
    Should Be Equal    ${XNLINK.cPlaneIpAddr}    ${cPlaneIpAddr}
    Should Be Equal    ${XNLINK.cPlaneIpAddrCtrl}    ${cPlaneIpAddrCtrl}

Removal Restriction Modification Of MIB Cell Barred Status
    Execute Egate Command     cmd=uec_l2_testmode_params periodic_ssb_reading=true
    Sleep    1s    reason=waiting for cell started to be not barred

Send A3 Measurement Report With PCI And Check If Handover Is Not Performed
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=20 srsrq_nr=40 phycell_id=49 nrsrp_nr=90 nrsrq_nr=50
    ...    fail_regexp=eNB handover * performed

Start Additional Vm Ethernet Interfaces
    Start Vm Ethernet Interface    if_name=eth4:gNB10_XN1    ip_with_mask=10.0.2.20/24
    Start Vm Ethernet Interface    if_name=eth4:gNB10_XN2    ip_with_mask=10.0.2.1/24
    Start Vm Ethernet Interface    if_name=eth3:gNB10_XN3    ip_with_mask=10.0.3.1/24
    Start Vm Ethernet Interface    if_name=eth3:gNB10_XN4    ip_with_mask=10.0.1.1/24
    Start Vm Ethernet Interface    if_name=eth3:gNB10_XN5    ip_with_mask=10.0.3.151/32
    Start Vm Ethernet Interface    if_name=eth3:gNB10_XN6    ip_with_mask=10.0.3.153/32
    Start Vm Ethernet Interface    if_name=eth2:gNB10_XN7    ip_with_mask=192.168.6.252/24

Stop Additional Vm Ethernet Interfaces
    Stop Vm Ethernet Interface    if_name=eth4:gNB10_XN1    ip_with_mask=10.0.2.20/24
    Stop Vm Ethernet Interface    if_name=eth4:gNB10_XN2    ip_with_mask=10.0.2.1/24
    Stop Vm Ethernet Interface    if_name=eth3:gNB10_XN3    ip_with_mask=10.0.3.1/24
    Stop Vm Ethernet Interface    if_name=eth3:gNB10_XN4    ip_with_mask=10.0.1.1/24
    Stop Vm Ethernet Interface    if_name=eth3:gNB10_XN5    ip_with_mask=10.0.3.151/32
    Stop Vm Ethernet Interface    if_name=eth3:gNB10_XN6    ip_with_mask=10.0.3.153/32
    Stop Vm Ethernet Interface    if_name=eth2:gNB10_XN7    ip_with_mask=192.168.6.252/24

Waiting For OAM Config Update
    Sleep    60s    reason=Waiting For OAM Config Update
