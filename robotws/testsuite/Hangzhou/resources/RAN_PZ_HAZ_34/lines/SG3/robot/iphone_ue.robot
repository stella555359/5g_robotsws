*** Settings ***
Documentation
...    author: Ming Shi
...    contact: ming.shi@nokia.com

Library   taf.ue


*** Keywords ***
iphone_prepare_ue
    [Arguments]    ${ue_index}    ${ue_aliases}
    FOR    ${i}    ${ue_alias}    IN ZIP   ${ue_index}    ${ue_aliases}
        require_ue    ue_alias=${ue_alias}    capabilities=iphone_${i}
    END

iphone_attach_ue
    [Arguments]    ${ue_aliases}
    FOR    ${ue_alias}    IN   @{ue_aliases}
        ${status}=    Run Keyword And Return Status    attach_ue    ue_alias=${ue_alias}
        IF   not ${status}
            reboot_ue    ue_alias=${ue_alias}
            detach_ue    ue_alias=${ue_alias}
            attach_ue    ue_alias=${ue_alias}
        END
    END

iphone_detach_ue
    [Arguments]    ${ue_aliases}
    FOR    ${ue_alias}    IN   @{ue_aliases}
        detach_ue    ue_alias=${ue_alias}
    END

iphone_make_voice_call
    [Arguments]    ${ue_aliases}    ${phone_numbers}    ${durations}
    FOR    ${ue_alias}    ${phone_number}    ${duration}    IN ZIP   ${ue_aliases}    ${phone_numbers}    ${durations}
        start_voice_call
        ...    ue_alias=${ue_alias}
        ...    vc_alias=${ue_alias}_${phone_number}
        ...    to=${phone_number}
        ...    duration=${duration}
        await_voice_call_finish
        ...    vc_alias=${ue_alias}_${phone_number}
    END

iphone_stop_voice_call
    [Arguments]    ${ue_aliases}    ${phone_numbers}
    FOR    ${ue_alias}    ${phone_number}    IN ZIP   ${ue_aliases}    ${phone_numbers}
        stop_voice_call
        ...    vc_alias=${ue_alias}_${phone_number}
    END

iphone_make_traffic
    [Arguments]    ${ue_aliases}    ${directions}    ${durations}    ${throughputs}    ${protocols}
    FOR    ${ue_alias}    ${direction}    ${duration}    ${throughput}    ${protocol}    IN ZIP
    ...    ${ue_aliases}    ${directions}    ${durations}    ${throughputs}    ${protocols}
        start_data_transfer
        ...    dt_name=dt_${ue_alias}
        ...    ue_alias=${ue_alias}
        ...    direction=${direction}
        ...    duration=${duration}
        ...    throughput=${throughput}
        ...    protocol=${protocol}
    END

iphone_stop_traffic
    [Arguments]    ${ue_aliases}
    FOR    ${ue_alias}    IN   @{ue_aliases}
        stop_data_transfer    dt_name=dt_${ue_alias}
    END
