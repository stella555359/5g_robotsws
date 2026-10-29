*** Settings ***

Documentation    :copyright: Nokia

Resource     ../resources/5G_SW_WRO_Keywords.robot

Library      ta5g_file_system
Library      ta5g_testline_management
Library      ta5g_iphy
Library      ta5g_enb
Library      ta5g_ue_measurements
Library      ta5g_delta
Library      taf.ul.ettf.setups
Library      ta5g_egate
Library      ute_reporting_portal
Library      ta5g_pm_counters

*** Variables ***
#${TRF_DURATION}=        900

*** Keywords ***
Get Pm Counter Value As Integer
    [Arguments]    ${counter_name}  ${counter_file}
    ${pm_counter_value}=    Get Pm Counter Value
       ...    ${counter_name}    PLMN-PLMN/MRBTS-1/NRBTS-1   ${counter_file}
    ${pm_value_integer}    Evaluate    int(${pm_counter_value}[0])
    [Return]    ${pm_value_integer}


Perform NSA call
    [Arguments]    ${ue_id}  ${target_cell}  ${target_gnb}
    Attach Ue To Enb    ue_id=${ue_id}  optional_parameters=profile=1
    Start Gnb Addition Procedure
    ...    ue=${ue_id}
    ...    target_cells=${target_cell}
    ...    target_gnb=${target_gnb}
    ...    bearer=2
    ...    dc_type=split_scg
    Start Data Traffic
    ...     ues=${ue_id}
    ...     bearer_id=2
    ...     direction=dl
    ...     throughput=65mbps
    ...     traffic_id=1

Perform Multiple NSA UEs call
    [Arguments]    ${ue_id}  ${target_cell}  ${target_gnb}
    Attach Ue To Enb    ue_id=${ue_id}  optional_parameters=profile=1
    Start Gnb Addition Procedure
    ...    ue=${ue_id}
    ...    target_cells=${target_cell}
    ...    target_gnb=${target_gnb}
    ...    bearer=2
    ...    dc_type=split_scg
    Start Data Traffic
    ...     ues=${ue_id}
    ...     bearer_id=2
    ...     direction=dl
    ...     throughput=6mbps
    ...     traffic_id=1

Perform NSA call for UEs ID11-20
    FOR    ${index}    IN RANGE    11    21
        Perform Multiple NSA UEs call    ue_id=${index}  target_cell=1   target_gnb=2
    END
    
Dual Connectivity Release
    [Documentation]
    ...    command to trigger LTE-NR dual connectivity release
    ...
    ...    | ue_id      | Specified UE ID                               |
    ...    | bearer     | Bearer ID List                                |
    ...    | by         | Determines the initiator of the DC procedure  |
    ...    | cause      | Cause for the DC procedure                    |
    ...
    [Arguments]   ${ue_id}   ${bearer}   ${by}   ${cause}
    Execute Egate Command    cmd=enb_ue_dc_release ue=${ue_id} bearer=${bearer} by=${by} cause=${cause}
    ...   pass_regexp=Bearer-type change from SCG-split to MCG is successful
    Log to console   Dual Connectivity Released

Perform Dual Connectivity Release for UEs ID11-20
    FOR    ${index}    IN RANGE    11    21
        Dual Connectivity Release    ue_id=${index}   bearer=2   by=enb   cause=off
    END

Perform Detach UEs
    [Arguments]    ${ue_id}
    Detach Ue    ue_id=${ue_id}

Perform Detach for UEs ID11-20
    FOR    ${index}    IN RANGE    11    21
        Perform Detach UEs    ue_id=${index}
    END

#Attach 4 Sa Ues And Start Traffic
#    [Arguments]    ${num_of_sa_ues}=${4}
#    FOR    ${ue_id}    IN RANGE    ${1}    ${num_of_sa_ues}+${1}
#    \    Set Internal Traffic Type To UEs    ue_id=${ue_id}    pdu_id=${ue_id}
#    \    Register Ue With Default Pdu Session    ue_id=${ue_id}    pdu_id=${ue_id}     gw=${ue_id}
#    \    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${ue_id} qfi=1 dir=dl mbps=10 protocol=udp

Set udp buffer size
    Run    sudo sysctl -w net.core.wmem_max=20971520
    Run    sudo sysctl -w net.core.wmem_default=20971520
    Run    sudo sysctl -w net.core.rmem_max=20971520
    Run    sudo sysctl -w net.core.rmem_default=20971520
