*** Settings ***

Documentation     Keywords related to PM counters for CB013289
Library     ute_wtssim
Library     String
Library     OperatingSystem
Library     Collections
Library     ta5g_ue_measurements
Library     taf.config.wts        WITH NAME    wts_conf

Resource    ../../../../../resources/RAN_PZ_HAZ_1/Module/Module.robot

*** Variables ***
${nrcell_distname}=    MRBTS-1/NRBTS-1/NRCELL-1
${nrcell_distname_FDD}=    MRBTS-1/NRBTS-1/NRCELL-3
${nrbts_distname}=    MRBTS-1/NRBTS-1
${T22_counter}=     M55124C07001,M55124C07002,M55125C02001,M55125C02002,M55352C00007,M55352C00008,M55125C00048,M55125C00049
${T22_counter_rule}=    max(M55124C07001)>=1 and max(M55124C07002)>=1 and max(M55125C02001)>=1
...                    and max(M55125C02002)>=1 and max(M55352C00007)>=1 and max(M55352C00008)>=1
...                    and max(M55125C00048)>=1 and max(M55125C00049)>=1
#${T22_counter_rule}=    M55125C02001>0 and M55125C02002>0
${AB1_counter}=     M55125C02001,M55125C02002
${AB1_counter_rule}=    max(M55125C02001)>=1 and max(M55125C02002)>=1

${T44_counter}=     M55125C00048,M55125C00049,M55125C02001,M55125C02002,M55352C00007,M55352C00008
${T44_counter_rule}=    max(M55125C00048)>=1 and max(M55125C00049)>=1 and max(M55125C02001)>=1
...                    and max(M55125C02002)>=1 and max(M55352C00007)>=1 and max(M55352C00008)>=1

${direct_counter}=     M55125C00048,M55125C00049,M55125C02001,M55125C02002,M55352C00007,M55352C00008
${direct_counter_rule}=    max(M55125C00048)>=1 and max(M55125C00049)>=1 and max(M55125C02001)>=1
...                    and max(M55125C02002)>=1 and max(M55352C00007)>=1 and max(M55352C00008)>=1

${indirect_counter}=     M55125C00048,M55125C00049,M55125C02001,M55125C02002,M55352C00007,M55352C00008
${inidrect_counter_rule}=    max(M55125C00048)==0 and max(M55125C00049)==0 and max(M55125C02001)>=1
...                    and max(M55125C02002)>=1 and max(M55352C00007)==0 and max(M55352C00008)==0

${nodata_counter}=     M55125C00048,M55125C00049,M55125C02001,M55125C02002,M55352C00007,M55352C00008
${nodata_counter_rule}=    max(M55125C00048)>=1 and max(M55125C00049)==0 and max(M55125C02001)>=1
...                    and max(M55125C02002)>=1 and max(M55352C00007)==0 and max(M55352C00008)==0

${e1bear_counter}=     M55135C00505,M55133C01004,M55133C01005,M55113C00001
${e1bear_counter_rule}=    max(M55135C00505)>=1 and max(M55133C01004)>=1 and max(M55133C01005)>=1 and max(M55113C00001)>=1

${gtp_packet_counter}=     M55352C00007,M55352C00008
${gtp_packet_counter_rule}=    max(M55352C00007)==0 and max(M55352C00008)==0


*** Keywords ***
Start Collect Counter
    [Arguments]    ${distname}    ${counter}    ${counter_rule}
    ${rule1}    Catenate
    ...         Distname: ${distname};
    ...         Counter: ${counter};
    ...         Counter rule: ${counter_rule};
    ${rule_list}    Create List    ${rule1}
    Log To Console    \nThe rule list is: ${rule_list}
    Counter Operation    operation=start_collect_counter    product_type=gnb    bts_index=0    counter_rule=${rule_list}
    ...                  wait_for_next_counter_generate=${true}

Stop Collect Counter and verify PM counters
    ${result}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0    cudu_index=0
    Log To Console    \nCounter Rule Collect and Check Result is: ${result}


Start Collect Counter For Multi Rule
    [Arguments]    ${distname}    ${counter}    ${counter_rule}    ${second_distname}    ${second_counter}    ${second_counter_rule}
    ${rule1}    Catenate
    ...         Distname: ${distname};
    ...         Counter: ${counter};
    ...         Counter rule: ${counter_rule};
    ${rule2}    Catenate
    ...         Distname: ${second_distname};
    ...         Counter: ${second_counter};
    ...         Counter rule: ${second_counter_rule};
    ${rule_list}    Create List    ${rule1}    ${rule2}
    Log To Console    \nThe rule list is: ${rule_list}
    Counter Operation    operation=start_collect_counter    product_type=gnb    bts_index=0    counter_rule=${rule_list}
    ...                  wait_for_next_counter_generate=${true}

Start Collect Counter For T52
    ${rule1}    Catenate
    ...         Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...         Counter: M55352C00007;
    ...         Counter rule: max(M55352C00007);
    ${rule2}    Catenate
    ...         Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...         Counter: M55352C00008;
    ...         Counter rule: max(M55352C00008);
    ${rule_list}    Create List    ${rule1}    ${rule2}
    Log To Console    \nThe rule list is: ${rule_list}
    Counter Operation    operation=start_collect_counter    product_type=gnb    bts_index=0    counter_rule=${rule_list}
    ...                  wait_for_next_counter_generate=${true}

Stop Collect Counter and verify PM counters For T52
    ${result}    Counter Operation    operation=collect_counter_and_calculate   product_type=gnb    bts_index=0    cudu_index=0
    Log To Console    \nCounter Rule Collect and Check Result is: ${result}
    [Return]    ${result}