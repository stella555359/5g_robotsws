*** Settings ***
Documentation
...    author: Ulm SQD 65
...    Team: 'MN RAN L3 SW ULM L3NRT SQD 65'
...    Email: 'I_MN_RAN_L3_SW_ULM_SQD_65@internal.nsn.com'
...    Description: Keywords for MaxTput test

Resource          ../resources/SQD65/sqd65_keywords.robot

*** Keywords ***

Determine Max Throughput all UEs DL
    [Arguments]  ${UEs}=${None}  ${tech}=${None}
    ${start}=  Set Variable if  '${tech}' == 'TDD'  ${tdd_start_dl_mue}  ${fdd_start_dl_mue}
    ${end}=  Set Variable if  '${tech}' == 'TDD'  ${tdd_end_dl_mue}  ${fdd_end_dl_mue}
    ${step}=  Set Variable if  '${tech}' == 'TDD'  ${tdd_step_dl_mue}  ${fdd_step_dl_mue}
    Log To Console  \nMulti UE DL test:
    FOR  ${tput}  IN RANGE  ${start}  ${end}  ${step}
      Start Traffic on all SA UEs  count=${UEs}  tput=${tput}  dir=dl
      Sleep  ${duration}
      ${loss}=  Check Traffic on all SA UEs  ${UEs}  ${tput}  dir=dl
      ${last}=  Evaluate  (${tput} - ${step}) * ${UEs}
      IF  ${loss} <= ${threshold}
        Log To Console  ${tput} mbps OK (${loss}% loss) ...
      ELSE
        Log To Console  ${tput} mbps has more than ${threshold}% (${loss}%) loss
        Log To Console  Last good gNB throughput was ${last} mbps
      END
      Sleep  5s  reason=To allow some time for screenshots
      Stop Traffic on all SA UEs  ${UEs}  ${tput}  dir=dl
      IF  ${loss} > ${threshold}   BREAK
      Sleep  2s
    END

Determine Max Throughput all UEs UL
    [Arguments]  ${UEs}=${None}  ${tech}=${None}
    ${start}=  Set Variable if  '${tech}' == 'TDD'  ${tdd_start_ul_mue}  ${fdd_start_ul_mue}
    ${end}=  Set Variable if  '${tech}' == 'TDD'  ${tdd_end_ul_mue}  ${fdd_end_ul_mue}
    ${step}=  Set Variable if  '${tech}' == 'TDD'  ${tdd_step_ul_mue}  ${fdd_step_ul_mue}
    Log To Console  \nMulti UE UL test:
    FOR  ${tput}  IN RANGE  ${start}  ${end}  ${step}
      Start Traffic on all SA UEs  count=${UEs}  tput=${tput}  dir=ul
      Sleep  ${duration}
      ${loss}=  Check Traffic on all SA UEs  ${UEs}  ${tput}  dir=ul
      ${last}=  Evaluate  (${tput} - ${step}) * ${UEs}
      IF  ${loss} <= ${threshold}
        Log To Console  ${tput} mbps OK (${loss}% loss) ...
      ELSE
        Log To Console  ${tput} mbps has more than ${threshold}% (${loss}%) loss
        Log To Console  Last good gNB throughput was ${last} mbps
      END
      Sleep  5s  reason=To allow some time for screenshots
      Stop Traffic on all SA UEs  ${UEs}  ${tput}  dir=ul
      IF  ${loss} > ${threshold}   BREAK
      Sleep  2s
    END

Determine Max Throughput single UE DL
    [Arguments]  ${tech}=${None}
    ${start}=  Set Variable if  '${tech}' == 'TDD'  ${tdd_start_dl_sue}  ${fdd_start_dl_sue}
    ${end}=  Set Variable if  '${tech}' == 'TDD'  ${tdd_end_dl_sue}  ${fdd_end_dl_sue}
    ${step}=  Set Variable if  '${tech}' == 'TDD'  ${tdd_step_dl_sue}  ${fdd_step_dl_sue}
    Log To Console  \nSinlge UE DL test:
    FOR  ${tput}  IN RANGE  ${start}  ${end}  ${step}
      Start Traffic on SA UE  ue=1  tput=${tput}  dir=dl
      Sleep  ${duration}
      ${loss}=  Check Traffic on SA UE  ue=1  tput=${tput}  dir=dl
      ${last}=  Evaluate  (${tput} - ${step})
      IF  ${loss} <= ${threshold}
        Log To Console  ${tput} mbps OK (${loss}% loss) ...
      ELSE
        Log To Console  ${tput} mbps has more than ${threshold}% (${loss}%) loss
        Log To Console  Last good single UE throughput was ${last} mbps
      END
      Sleep  5s  reason=To allow some time for screenshots
      Stop Traffic on SA UE  ue=1  tput=${tput}  dir=dl
      IF  ${loss} > ${threshold}   BREAK
      Sleep  2s
    END

Determine Max Throughput single UE UL
    [Arguments]  ${tech}=${None}
    ${start}=  Set Variable if  '${tech}' == 'TDD'  ${tdd_start_ul_sue}  ${fdd_start_ul_sue}
    ${end}=  Set Variable if  '${tech}' == 'TDD'  ${tdd_end_ul_sue}  ${fdd_end_ul_sue}
    ${step}=  Set Variable if  '${tech}' == 'TDD'  ${tdd_step_ul_sue}  ${fdd_step_ul_sue}
    Log To Console  \nSinlge UE UL test:
    FOR  ${tput}  IN RANGE  ${start}  ${end}  ${step}
      Start Traffic on SA UE  ue=1  tput=${tput}  dir=ul
      Sleep  ${duration}
      ${loss}=  Check Traffic on SA UE  ue=1  tput=${tput}  dir=ul
      ${last}=  Evaluate  (${tput} - ${step})
      IF  ${loss} <= ${threshold}
        Log To Console  ${tput} mbps OK (${loss}% loss) ...
      ELSE
        Log To Console  ${tput} mbps has more than ${threshold}% (${loss}%) loss
        Log To Console  Last good single UE throughput was ${last} mbps
      END
      Sleep  5s  reason=To allow some time for screenshots
      Stop Traffic on SA UE  ue=1  tput=${tput}  dir=ul
      IF  ${loss} > ${threshold}   BREAK
      Sleep  2s
    END

Start Traffic on all SA UEs
    [Arguments]  ${count}=${None}  ${tput}=${None}  ${dir}=${None}
    FOR    ${ue_id}    IN RANGE    1  ${${count}+1}
        Start Traffic on SA UE  ue=${ue_id}  tput=${tput}  dir=${dir}
    END

Start Traffic on SA UE
    [Arguments]  ${ue}=${None}  ${tput}=${None}  ${dir}=${None}
    ${trf_id}=  Set Variable  0
    FOR  ${trf_id}  IN RANGE  1  ${${tput}//100}+1
       Start data traffic in egate   ue_id=${ue}  direction=${dir}  protocol=udp  trf_id=${trf_id}  pdu=1  qfi=1  mbps=100
    END
    ${rest}=  Set Variable  ${${tput}%100}
    IF  ${rest} != 0
    ...  Start data traffic in egate   ue_id=${ue}  direction=${dir}  protocol=udp  trf_id=${${trf_id}+1}  pdu=1  qfi=1  mbps=${rest}
    sleep  2s  reason=Traffic generators don't start immediately
    Send Egate Command and verify output  cmd=bearer_stats_clear ue=${ue} pdu=1 qfi=1

Check Traffic on all SA UEs
    [Arguments]  ${count}=${None}  ${tput}=${None}  ${dir}=${None}
    ${sumloss}=  Set Variable  0
    FOR    ${ue_id}    IN RANGE    1  ${${count}+1}
       ${loss}=  Check Traffic on SA UE  ue=${ue_id}  tput=${tput}  dir=${dir}
       ${sumloss}=  Evaluate  ${sumloss} + ${loss}
    END
    ${loss}=  Evaluate  "%3.2f" % (${sumloss} / ${count})
    RETURN  ${loss}

Check Traffic on SA UE
    [Arguments]  ${ue}=${None}  ${tput}=${None}  ${dir}=${None}
    ${ue_tp}=  Get Average Data Rate via Egate  ue_id=${ue}  pdu=1  trf_id=1  qfi=1  dir=${dir}
    ${rate}=  Evaluate  ${ue_tp}/(${tput}*1000000)
    ${loss}=   Evaluate  "%3.2f" % ((1 - $rate) * 100)
    RETURN  ${loss}

Stop Traffic on all SA UEs
    [Arguments]  ${count}=${None}  ${tput}=${None}  ${dir}=${None}
    FOR    ${ue_id}    IN RANGE    1  ${${count}+1}
        Stop Traffic on SA UE  ue=${ue_id}  tput=${tput}  dir=${dir}
    END

Stop Traffic on SA UE
    [Arguments]  ${ue}=${None}  ${tput}=${None}  ${dir}=${None}
    ${trf_id}=  Set Variable  0
    FOR  ${trf_id}  IN RANGE  1  ${${tput}//100}+1
       Stop data traffic in egate   ue_id=${ue}  direction=${dir}  trf_id=${trf_id}  pdu=1  qfi=1
    END
    ${rest}=  Set Variable  ${${tput}%100}
    IF  ${rest} != 0  Stop data traffic in egate   ue_id=${ue}  direction=${dir}  trf_id=${${trf_id}+1}  pdu=1  qfi=1
