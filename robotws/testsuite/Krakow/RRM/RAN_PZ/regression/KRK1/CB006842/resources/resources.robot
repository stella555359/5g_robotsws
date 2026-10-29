*** Settings ***
Documentation
...   author: Julia Luszcz, Agnieszka Bylica
...   contact: julia.luszcz@nokia.com, agnieszka.bylica@nokia.com
...   maintainer/contact: Agnieszka Bylica / agnieszka.bylica@nokia.com, Damian Silkowski / damian.silkowski@nokia.com
...   Keywords for test cases automation of feature CB006842/CB009055 - the energy saving mode for ASiR

*** Keywords ***
Verify ASIR counters are set
    [Arguments]    ${interval}    ${start_timestamp}    ${stop_timestamp}    ${allowed_diff}=${30000}    ${asirmods}=${None}
    ${values}    verify_counters_have_values              counters=M40020C0,M40020C1,M40020C2,M40020C3,M40020C4,M40020C5
    ...                                                                             interval=${interval}
    ...                                                                             start_timestamp=${start_timestamp}
    ...                                                                             stop_timestamp=${stop_timestamp}
    verify_counter_values_difference_between_asirmods     counters_values=${values}
    ...                                                                             counter_name=M40020C4
    ...                                                                             allowed_diff=${allowed_diff}
    ...                                                                             asirmods=${asirmods}

Verify summary counters are set
    [Arguments]    ${interval}    ${start_timestamp}    ${stop_timestamp}
    ${values}    verify_counters_have_values     counters=M40002C1,M40002C2
    ...                                                             interval=${interval}
    ...                                                             start_timestamp=${start_timestamp}
    ...                                                             stop_timestamp=${stop_timestamp}
