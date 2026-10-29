*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...      - Malgorzata Konior <malgorzata.konior@nokia.com>
...      - Konrad Krzyzak <konrad.krzyzak@nokia.com>
...      - Karolina Sroczyk <karolina.sroczyk@nokia.com>
...      - Michal Szymakowski <michal.szymakowski@nokia.com>
...      - Grzegorz Szymik <grzegorz.szymik@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

*** Variables ***


*** Keywords ***
Get occurence time of RRCReconfiguration after ICS for UE${ue_id:\d+}
    ${flow_alias_rrc}=     Get Flow Name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    ${start_a4retryTimer}=    get_message_occurence_time
    ...     flow_alias=${flow_alias_rrc}
    ...     message_alias=RRCReconfiguration
    ...     time_format=ntp_32bit
    ...     output_format=hex_uppercase

    Set Test Variable    ${start_a4retryTimer}

Get occurence time of NGAP InitialContextSetup for AMF${amf_id:\d+}
    ${flow_alias}=  get flow name
    ...     procedure=initialContextSetup
    ...     device=AMF${amf_id}

    ${start_a4retryTimer}=    get_message_occurence_time
    ...     flow_alias=${flow_alias}
    ...     message_alias=InitialContextSetupRequest
    ...     time_format=ntp_32bit
    ...     output_format=hex_uppercase

    Set Test Variable    ${start_a4retryTimer}

Get occurence time of RRCReestablishment for UE${ue_id:\d+}
    ${flow_alias_rrc}=     Get Flow Name
    ...     RRCReestablishmentRequest
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    ${start_a4retryTimer}=    get_message_occurence_time
    ...     flow_alias=${flow_alias_rrc}
    ...     message_alias=RRCReestablishmentRequest
    ...     time_format=ntp_32bit
    ...     output_format=hex_uppercase

    Set Test Variable    ${start_a4retryTimer}

Get occurence time of RRCReconfigurationComplete after Handover for UE${ue_id:\d+}
    ${flow_alias_rrc}=     Get Flow Name
    ...     RRCReconfigurationComplete
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    ${rrcreconfiguration after_ho}=    get_message_occurence_time
    ...     flow_alias=${flow_alias_rrc}
    ...     message_alias=RRCReconfigurationComplete
    ...     time_format=ntp_32bit
    ...     output_format=hex_uppercase

    Set Test Variable    ${rrcreconfiguration after_ho}

Get occurence time of ${msg:\d+} out of ${all:\d+} RRCReconfiguration with A4measurements installed for UE${ue:\d+} and verify if diff eq ${exp:\d+}s
    ${flow_alias_rrc}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue}
    ...     protocol=NR-RRC

    ${rrcreconfiguration_with_a4}=    get_message_occurence_time
    ...     flow_alias=${flow_alias_rrc}
    ...     message_alias=RRCReconfiguration_${msg}
    ...     time_format=ntp_32bit
    ...     output_format=hex_uppercase

    ${difference}=    Evaluate    ${rrcreconfiguration_with_a4} - ${start_a4retryTimer}
    ${lower_limit}=    Evaluate    ${exp} - ${a4retrytimer_toleration}
    ${upper_limit}=    Evaluate    ${exp} + ${a4retrytimer_toleration}

    Run Keyword If    ${difference} > ${upper_limit} or ${difference} < ${lower_limit}
    ...     Fail    Difference ${difference} [s] between RRCReconfiguration with A4 and start of a4retryTimer is wrong. Expected: ${exp}
    ...     ELSE    Log To Console
    ...     Difference ${difference} [s] between RRCReconfiguration with A4 and start of a4retryTimer is OK.

Get occurence time of RRCReconfiguration with A4measurements installed for UE${ue:\d+} and verify if diff eq ${exp:\d+}s
    ${flow_alias_rrc}=     Get Flow Name
    ...     RRCReconfiguration
    ...     device=UE_${ue}
    ...     protocol=NR-RRC

    ${rrcreconfiguration_with_a4}=    get_message_occurence_time
    ...     flow_alias=${flow_alias_rrc}
    ...     message_alias=RRCReconfiguration
    ...     time_format=ntp_32bit
    ...     output_format=hex_uppercase

    ${difference}=    Evaluate    ${rrcreconfiguration_with_a4} - ${start_a4retryTimer}
    ${lower_limit}=    Evaluate    ${exp} - ${a4retrytimer_toleration}
    ${upper_limit}=    Evaluate    ${exp} + ${a4retrytimer_toleration}

    Run Keyword If    ${difference} > ${upper_limit} or ${difference} < ${lower_limit}
    ...     Fail    Difference ${difference} [s] between RRCReconfiguration with A4 and start of a4retryTimer is wrong. Expected: ${exp}
    ...     ELSE    Log To Console
    ...     Difference ${difference} [s] between RRCReconfiguration with A4 and start of a4retryTimer is OK.

Get occurence time of RRCReconfiguration with A4 measurements installation for UE${ue_id:\d+} and verify if difference is equal ${expected:\d+}s
    ${flow_alias_rrc}=     Get Flow Name
    ...     2*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    ${rrcreconfiguration_with_a4}=    get_message_occurence_time
    ...     flow_alias=${flow_alias_rrc}
    ...     message_alias=RRCReconfiguration_2
    ...     time_format=ntp_32bit
    ...     output_format=hex_uppercase

    ${difference}=    Evaluate    ${rrcreconfiguration_with_a4} - ${start_a4retryTimer}
    ${lower_limit}=    Evaluate    ${expected} - ${a4retrytimer_toleration}
    ${upper_limit}=    Evaluate    ${expected} + ${a4retrytimer_toleration}

    Run Keyword If    ${difference} > ${upper_limit} or ${difference} < ${lower_limit}
    ...     Fail    Difference ${difference} [s] between RRCReconfiguration with A4 and start of a4retryTimer is wrong. Expected: ${expected}
    ...     ELSE    Log To Console
    ...     Difference ${difference} [s] between RRCReconfiguration with A4 and start of a4retryTimer is OK.

Get occurence time of RRCReconfiguration after RRCReestablishment procedure for UE${ue_id:\d+} and verify if difference is less than ${expected:\d+}s
    ${flow_alias_rrc}=     Get Flow Name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    ${rrcreconfiguration_with_a4}=    get_message_occurence_time
    ...     flow_alias=${flow_alias_rrc}
    ...     message_alias=RRCReconfiguration
    ...     time_format=ntp_32bit
    ...     output_format=hex_uppercase

    ${difference}=    Evaluate    ${rrcreconfiguration_with_a4} - ${start_a4retryTimer}

    Run Keyword If    ${difference} < ${expected}
    ...     Log To Console    Difference ${difference} [s] between RRCReconfiguration with A4 and the end of RRCReestablishment is OK.
    ...     ELSE
    ...     Fail    Difference ${difference} [s] between RRCReconfiguration with A4 and the end of RRCReestablishment is wrong. Expected: ${expected}

Get occurence time of RRCReconfiguration after RRCReestablishment procedure for UE${ue_id:\d+} and verify if difference is more than ${expected:\d+}s
    ${flow_alias_rrc}=     Get Flow Name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    ${rrcreconfiguration_with_a4}=    get_message_occurence_time
    ...     flow_alias=${flow_alias_rrc}
    ...     message_alias=RRCReconfiguration
    ...     time_format=ntp_32bit
    ...     output_format=hex_uppercase

    ${difference}=    Evaluate    ${rrcreconfiguration_with_a4} - ${start_a4retryTimer}

    Run Keyword If    ${difference} > ${expected}
    ...     Log To Console    Difference ${difference} [s] between RRCReconfiguration with A4 and the end of RRCReestablishment is OK.
    ...     ELSE
    ...     Fail    Difference ${difference} [s] between RRCReconfiguration with A4 and the end of RRCReestablishment is wrong. Expected: ${expected}

Get occurence time of RRCReconfiguration with A4 measurements after handover for UE${ue_id:\d+} and verify if difference is equal ${expected:\d+}s
    ${flow_alias_rrc}=     Get Flow Name
    ...     2*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    ${rrcreconfiguration_with_a4}=    get_message_occurence_time
    ...     flow_alias=${flow_alias_rrc}
    ...     message_alias=RRCReconfiguration_2
    ...     time_format=ntp_32bit
    ...     output_format=hex_uppercase

    ${difference}=    Evaluate    ${rrcreconfiguration_with_a4} - ${rrcreconfiguration after_ho}
    ${lower_limit}=    Evaluate    ${expected} - ${a4retrytimer_toleration}
    ${upper_limit}=    Evaluate    ${expected} + ${a4retrytimer_toleration}

    Run Keyword If    ${difference} > ${upper_limit} or ${difference} < ${lower_limit}
    ...     Fail    Difference ${difference} [s] between RRCReconfiguration with A4 and RRCReconfiguration after HO is wrong. Expected: ${expected}
    ...     ELSE    Log To Console
    ...     Difference ${difference} [s] between RRCReconfiguration with A4 and RRCReconfiguration after HO is OK.

Verify that RRCReconfiguration with A4 measurements is sent right after RRCReestablishment without starting a4RetryTimer for UE${ue_id:\d+}
    ${flow_alias_rrc}=     Get Flow Name
    ...     RRCReestablishmentRequest
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    ${rrceestablishment_request}=    get_message_occurence_time
    ...     flow_alias=${flow_alias_rrc}
    ...     message_alias=RRCReestablishmentRequest
    ...     time_format=ntp_32bit
    ...     output_format=hex_uppercase

    ${flow_alias_rrc}=     Get Flow Name
    ...     2*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    ${rrcreconfiguration_with_a4}=    get_message_occurence_time
    ...     flow_alias=${flow_alias_rrc}
    ...     message_alias=RRCReconfiguration_2
    ...     time_format=ntp_32bit
    ...     output_format=hex_uppercase

    ${difference}=    Evaluate    ${rrcreconfiguration_with_a4} - ${rrceestablishment_request}
    ${expected}=    Evaluate    2

    Run Keyword If    ${difference} > ${expected}
    ...     Fail    Difference ${difference} [s] between RRCReconfiguration with A4 and RRCReestablishmentRequest is wrong. Expected: < ${expected}
    ...     ELSE    Log To Console
    ...     Difference ${difference} [s] between RRCReconfiguration with A4 and RRCReestablishmentRequest is OK.
