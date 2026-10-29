*** Settings ***
Documentation
...    author: Marcin Szlapa
...    contact: marcin.szlapa@nokia.com
...    Description: CB012614 keywords

Library     BuiltIn
Library     taf.hw.rf_attenuator
Library     ./ue_proxy.py
Resource    taf/rfrl/ue/robot/REAL_UE.robot


*** Keywords ***
Perform Bidirectional Data Transfer With Throughput Verification on all cells
    [Arguments]    ${data_transfer_configuration}
    log to console   \nRequire Smawave UE
    ue.Require UE  UE  capabilities=Smawave
    FOR    ${cell}    IN    @{data_transfer_configuration}
        log to console   \nStart Cell ${cell['cell_id']} Throughput Verification
        IF    ${cell['delta']}
            log to console   \nPerform Delta Commissioning With qrxlevmin
            Perform Delta Commissioning On gNB     delta=${cell['delta']}
        END
        ue.Detach UE    UE
        log to console   \nAttenuator Setup:
        Set attenuation    attenuators=${cell['attenuators']}
        Prepare UE
        # ...    apn=${cell['apn']}
        ...    cell_id=${cell['cell_id']}
        Perform Bidirectional Data Transfer With Throughput Verification
        ...    duration=${cell['duration']}
        ...    dl_throughput=${cell['dl_throughput']}
        ...    ul_throughput=${cell['ul_throughput']}
        ...    max_deviation=${cell['max_deviation']}
        log to console   \nUE Detach
        ue.Detach UE    UE
    END
    ue.Stop Using Ue  UE

Set attenuation
    [Arguments]    ${attenuators}
    FOR  ${i}  ${att}    IN ENUMERATE   @{attenuators}
        log to console    \nAttenuator ${i}:\n ${att['attenuator_values']}
        setup_attenuator    attenuator=${att['attenuator']}  alias=att
        set_ports_attenuation    ports=${att['attenuator_ports']}  values=${att['attenuator_values']}  attenuator_device=att
    END

Prepare UE
    [Arguments]    ${cell_id}
    #    Set APN
    #    ...    ue_index=${ue_index}
    #    ...    apn_name=${apn}
    #    Reboot UEs    ${ue_index}
    run keyword and ignore error    ue.Stop Using Ue  UE
    stop_ue_proxy_on_ue_pc
    start_ue_proxy_on_ue_pc
    log to console   \nRequire Smawave UE
    ue.Require UE  UE  capabilities=Smawave
    log to console   \nUE Attach (cell ${cell_id})
    ue.Attach UE    UE
    #    Wait until keyword succeeds  3x    15 sec
    #    ...    Check attached cell ID    cell_id=${cell_id}


Check attached cell ID
    [Arguments]    ${cell_id}
    ${ue_info}    ue.Get Ue Info    UE    cell_id
    Should Be Equal  ${ue_info}   ${cell_id}

Perform Bidirectional Data Transfer With Throughput Verification
    [Arguments]    ${duration}    ${dl_throughput}    ${ul_throughput}    ${max_deviation}
    log to console   \nStart UL Data Transfer
    ue.Start Data Transfer    dt_name=DT_UL    ue_alias=UE    direction=ul    protocol=tcp    duration=${duration}
    ...  tput=${ul_throughput}
    ...  size_packet=1400B
    ...  parallel_streams=4
    ...  max_segment_size=1408
    ...  linux_congestion=cubic
    log to console   \nStart DL Data Transfer
    ue.Start Data Transfer    dt_name=DT_DL    ue_alias=UE    direction=dl    protocol=tcp    duration=${duration}
    ...  tput=${dl_throughput}
    ...  size_packet=1400B
    ...  parallel_streams=4
    ...  max_segment_size=1408
    ...  linux_congestion=cubic
#    REAL_UE.Wait for truput stabilization
    log to console   \nAwait Data Transfer Finish
    ue.Await Data Transfer Finish       dt_name=DT_UL
    ue.Await Data Transfer Finish       dt_name=DT_DL
    log to console   \nAverage Throughput Verification
    ue.Verify Average Throughput With Deviation   dt_name=DT_DL   tput=${dl_throughput}  deviation=${max_deviation}
    log to console   \nDL Throughput OK
    ue.Verify Average Throughput With Deviation   dt_name=DT_UL   tput=${ul_throughput}   deviation=${max_deviation}
    log to console   \nUL Throughput OK
