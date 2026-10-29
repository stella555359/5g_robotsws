*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Library    ../../Python/traffic_verify.py

*** Variables ***
${SPLIT_BEARER_ID}    2

*** Keywords ***
Run ${traffic_rate:\d+}Mbps UL and DL traffic on UE${ue_id:\d+} PDU${pdu_id:\d+} QFI${qfi_id:\d+} and wait ${seconds:\d+} seconds
    Execute egate command
    ...  cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=ul mbps=${traffic_rate}
    ...  pass_regexp=Started Uplink Internal traffic
    Execute egate command
    ...  cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl mbps=${traffic_rate}
    ...  pass_regexp=Started Downlink Internal traffic
    Sleep  ${seconds}

Run ${ul_trf_rate:\d+}Mbps UL and ${dl_trf_rate:\d+}Mbps DL traffic on UE${ue_id:\d+} PDU${pdu_id:\d+} QFI${qfi_id:\d+} and wait ${secs:\d+} seconds
    Execute egate command
    ...  cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=ul mbps=${ul_trf_rate}
    ...  pass_regexp=Started Uplink Internal traffic
    Execute egate command
    ...  cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl mbps=${dl_trf_rate}
    ...  pass_regexp=Started Downlink Internal traffic
    Sleep  ${secs}

Run ${traffic_rate:\d+}Mbps ${direction:(UL|DL)} traffic on UE${ue_id:\d+} PDU${pdu_id:\d+} QFI${qfi_id:\d+} and wait ${seconds:\d+} seconds
    ${dir_param}    Convert To Lowercase    ${direction}
    Execute egate command
    ...  cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=${dir_param} mbps=${traffic_rate}
    ...  pass_regexp=Started .* Internal traffic
    Sleep  ${seconds}

Run ${traffic_rate:\d+}Mbps UL and DL traffic on split bearer for UE${ue_id:\d+} and wait ${seconds:\d+} seconds
    Execute egate command
    ...  cmd=trf_data_start ue=${ue_id} id=${SPLIT_BEARER_ID} dir=ul mbps=${traffic_rate}
    ...  pass_regexp=UE ${ue_id}: UDP UL TRF
    Execute egate command
    ...  cmd=trf_data_start ue=${ue_id} id=${SPLIT_BEARER_ID} dir=dl mbps=${traffic_rate}
    ...  pass_regexp=UE ${ue_id}: UDP DL TRF
    Sleep  ${seconds}

Run ${traffic_rate:\d+}Mbps ${direction:(UL|DL)} traffic on split bearer for UE${ue_id:\d+} and wait ${seconds:\d+} seconds
    ${dir_param}    Convert To Lowercase    ${direction}
    Execute egate command
    ...  cmd=trf_data_start ue=${ue_id} id=${SPLIT_BEARER_ID} dir=${dir_param} mbps=${traffic_rate}
    ...  pass_regexp=UE ${ue_id}: UDP ${direction} TRF
    Sleep  ${seconds}

Run ${rate:\d+}Mbps ${direction:(UL|DL)} traffic-${trf_id:\d+} on UE${ue_id:\d+} PDU${pdu_id:\d+} QFI${qfi_id:\d+} and wait ${seconds:\d+} seconds
    ${dir_param}    Convert To Lowercase    ${direction}
    Execute egate command
    ...  cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=${dir_param} mbps=${rate} trf_id=${trf_id}
    ...  pass_regexp=Started.*Internal traffic.*TrfId:${trf_id}
    Sleep  ${seconds}

Stop and verify ${traffic_rate:\d+}Mbps UL and DL traffic on split bearer for UE${ue_id:\d+}
    Verify ${traffic_rate}MBps UL and DL traffic on SCG split bearer for UE${ue_id}
    Stop ${traffic_rate}Mbps UL and DL traffic on split bearer for UE${ue_id}

Stop and verify ${traffic_rate:\d+}Mbps UL and DL traffic on UE${ue_id:\d+} PDU${pdu_id:\d+} QFI${qfi_id:\d+}
    Verify ${traffic_rate}Mbps UL and DL traffic on PDU-${pdu_id} QFI-${qfi_id} for UE${ue_id}
    Execute egate command
    ...  cmd=trf_data_stop ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id}
    ...  pass_regexp=UPF-1: Stop.* Downlink Internal traffic on Ue

Stop and verify ${traffic_rate:\d+}Mbps ${direction:(UL|DL)} traffic on UE${ue_id:\d+} PDU${pdu_id:\d+} QFI${qfi_id:\d+}
    ${dir_param}    Convert To Lowercase    ${direction}
    Verify ${traffic_rate}Mbps ${direction} traffic on PDU-${pdu_id} QFI-${qfi_id} for UE${ue_id}
    Execute egate command
    ...  cmd=trf_data_stop ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=${dir_param}
    ...  pass_regexp=Stop.* Internal traffic on Ue

Stop ${traffic_rate:\d+}Mbps UL and DL traffic on UE${ue_id:\d+} PDU${pdu_id:\d+} QFI${qfi_id:\d+}
    Execute egate command
    ...  cmd=trf_data_stop ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id}
    ...  pass_regexp=UPF-1: Stop.* Downlink Internal traffic on Ue
    Builtin.Log     ${traffic_rate}

Stop ${traffic_rate:\d+}Mbps ${direction:(UL|DL)} traffic on UE${ue_id:\d+} PDU${pdu_id:\d+} QFI${qfi_id:\d+}
    ${dir_param}    Convert To Lowercase    ${direction}
    Execute egate command
    ...  cmd=trf_data_stop ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=${dir_param}
    ...  pass_regexp=Stop.* Internal traffic on Ue
    Builtin.Log     ${traffic_rate}

Stop ${traffic_rate:\d+}Mbps UL and DL traffic on split bearer for UE${ue_id:\d+}
    Execute egate command
    ...  cmd=trf_data_stop ue=${ue_id} id=${SPLIT_BEARER_ID}
    ...  pass_regexp=.*
    Builtin.Log     ${traffic_rate}

Stop ${traffic_rate:\d+}Mbps ${direction:(UL|DL)} traffic on split bearer for UE${ue_id:\d+}
    ${dir_param}    Convert To Lowercase    ${direction}
    Execute egate command
    ...  cmd=trf_data_stop ue=${ue_id} id=${SPLIT_BEARER_ID} dir=${dir_param}
    ...  pass_regexp=.*
    Builtin.Log     ${traffic_rate}

Verify ${traffic_rate:\d+}Mbps UL and DL traffic on UE${ue_id:\d+} PDU${pdu_id:\d+} QFI${qfi_id:\d+}
    Verify ${traffic_rate}Mbps UL and DL traffic on PDU-${pdu_id} QFI-${qfi_id} for UE${ue_id}

Verify ${traffic_rate:\d+}Mbps ${direction:(UL|DL)} traffic on UE${ue_id:\d+} PDU${pdu_id:\d+} QFI${qfi_id:\d+}
    Verify ${traffic_rate}Mbps ${direction} traffic on PDU-${pdu_id} QFI-${qfi_id} for UE${ue_id}
