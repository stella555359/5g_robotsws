*** Settings ***

Documentation     KWs which can be used for running tests on SA test line
...               The KWs being implemented in this file are the same as in SA_keywords.robot
...               The SA_keywords.robot Kws are based on lteemu services (V 3.21.0) which is obsoleted
...               so the SA_keywords_2.robot should be used instead of SA_keywords.robot
...               The KWs in this module are based on services provided in UteWts module,
...               most of them are "wrapper" KWs which simply call UteWts services to perform required
...               action. As consequence, UteWts KWs can be used directly without using below KWs

Library           BuiltIn
Library           OperatingSystem
Library           Collections
Library           String
Library           DateTime
Library           ArchiveLibrary
Library           logging


Resource          UteWts.robot


*** Keywords ***


Setup LTEemu environment sudo SA
    [Documentation]
    ...    (Re)start WTS service, load the basic.cfg file then wait for the TL to be ready
    ...        timeout : max time (in seconds) waiting for the TL to be ready (default value = 300)

    [Arguments]         ${timeout}=300

    Setup Wts Environment    timeout=${timeout}


Launch UE Attach SA
    [Documentation]
    ...    Register the UE with GNB
    ...        id : the UE identifier to be registered

    [Arguments]            ${id}=1

    UteWts.UE Register    ue=${id}


Verify AP Classical UE attach SA
    [Documentation]
    ...    Check that the UE was correctly attached to the GNB

    ${alias}    SSH Connect     ${HOST_EPCSIM}

    ${output}    SSH Exec    cd ${tl.core.dir_path}; grep crnti egate_console.log*    alias=${alias}

    #should contain	${output}	crnti


Verify UE RELEASED
    [Documentation]
    ...    Check that the UE was released

     ${alias}    SSH Connect     ${HOST_EPCSIM}

     ${output}    SSH Exec    cd ${tl.core.dir_path}; grep REGISTRATION_ACCEPT uec_1.log*    alias=${alias}

     should contain	${output}	RELEASED


# Set PDU Param
#     [Documentation]
#     ...    Set PDU param - to be done before "Launch PDU Session"
# 
#     [Arguments]    ${ue}=1    ${pdu}=1 
# 
#     ${ue_ip}    UteWts.UE PDU Set Param    ue=${ue}    pdu=${pdu}
# 
#     Dated Log    PDU Session setup OK (ue=${ue})


Launch PDU Session SA
    [Documentation]
    ...    Start PDU session
    ...    ue          : the UE identifier
    ...    pdu         : the PDU identifier
    ...    gw          : the gateway identifier
    ...    nwslice     : the network slice identifier


    [Arguments]    ${ue}=1    ${pdu}=1    ${gw}=1    ${nwslice}=1 

    ${ue_ip}    UteWts.UE PDU Set Param    ue=${ue}    pdu=${pdu}
    
    ${ue_ip}    UteWts.UE PDU Session Setup    ue=${ue}    pdu=${pdu}    gw=${gw}    nwslice=${nwslice}

    Dated Log    PDU Session setup OK (ue=${ue})


Traffic DL SA
    [Documentation]
    ...    Start downlink data traffic and display the average rate at the end of the specified traffic duration
    ...        ue          : the UE identifier (default value = 1)
    ...        pdu         : the PDU identifier (default value = 1)
    ...        qfi         : the Quality Flow Identifier (default value = 1)
    ...        rate        : the traffic rate per second, the rate unit is defined below (default value = 5)
    ...        rateUnit    : rate unit : mb for megabits, kb for for kilobits (default value = "mb")
    ...        time        : the traffic duration in seconds (default value = 10)

    [Arguments]    ${ue}=1    ${pdu}=1    ${qfi}=1    ${rate}=5    ${rateUnit}=mb    ${time}=10
    
    Dated Log    ADT - Start "Traffic DL SA" : ue=${ue}, pdu=${pdu}, qfi=${qfi}, rate=${rate}, rateUnit=${rateUnit}, time=${time}

    ${dir}    Set Variable    dl

    ${duration}    Set Variable    ${time}

    ${average_rate}=    Start Traffic And Return Average Throughput
    ...    ue=${ue}    pdu=${pdu}    qfi=${qfi}    dir=${dir}    duration=${duration}    rate=${rate}    rateUnit=${rateUnit}

    Dated Log    The DL average rate = ${average_rate}


Traffic UL SA
    [Documentation]
    ...    Start uplink data traffic
    ...        ue          : the UE identifier (default value = 1)
    ...        pdu         : the PDU identifier (default value = 1)
    ...        qfi         : the Quality Flow Identifier (default value = 1)
    ...        rate        : the traffic rate per second, the rate unit is defined below (default value = 5)
    ...        rateUnit    : rate unit : mb for megabits, kb for for kilobits (default value = "mb")
    ...        time        : the traffic duration in seconds (default value = 10)

    [Arguments]    ${ue}=1    ${pdu}=1    ${qfi}=1    ${rate}=5      ${rateUnit}=mb    ${time}=10

    Dated Log    ADT - Start "Traffic UL SA" : ue=${ue}, pdu=${pdu}, qfi=${qfi}, rate=${rate}, time=${time}

    ${dir}    Set Variable    ul

    ${duration}    Set Variable    ${time}

    ${average_rate}=    Start Traffic And Return Average Throughput
    ...    ue=${ue}    pdu=${pdu}    qfi=${qfi}    dir=${dir}    duration=${duration}    rate=${rate}    rateUnit=${rateUnit}

    Dated Log    The UL average rate = ${average_rate}


Start Traffic
    [Documentation]
    ...    Start data traffic using EGATE internal traffic simulator in the given direction
    ...    NOTE : no duration parameter is provided so it's needed to stop the traffic using "Stop Traffic" KW
    ...        ue          : the UE identifier (default value = 1)
    ...        pdu         : the PDU identifier (default value = 1)
    ...        qfi         : the Quality Flow Identifier (default value = 1)
    ...        dir         : traffic direction : ul for uplink, dl for downlink (default value = "dl")
    ...        rate        : the traffic rate per second, the rate unit is defined below (default value = 5)
    ...        rateUnit    : rate unit : mb for megabits, kb for for kilobits (default value = "mb")

    [Arguments]    ${ue}=1    ${pdu}=1    ${qfi}=1    ${trf_id}=1    ${dir}=dl    ${rate}=5    ${rateUnit}=mb    ${time}=10

    Dated Log    ADT - Start "Start Traffic" : ue=${ue}, pdu=${pdu}, qfi=${qfi}, rate=${rate}, rateUnit=${rateUnit}, dir=${dir}, time=${time}

    ${duration}    Set Variable    ${time}

    UteWts.Start Traffic
    ...    ue=${ue}    pdu=${pdu}    qfi=${qfi}    trf_id=${trf_id}    dir=${dir}    duration=${duration}    rate=${rate}   rateUnit=${rateUnit}


Stop Traffic
    [Documentation]
    ...    Stop data traffic generated by the EGATE internal traffic simulator
    ...        ue          : the UE identifier (default value = 1)
    ...        pdu         : the PDU identifier (default value = 1)
    ...        qfi         : the Quality Flow Identifier (default value = 1)
    ...        dir         : traffic direction : ul for uplink, dl for downlink (default value = "dl")

    [Arguments]    ${ue}=1    ${pdu}=1    ${qfi}=1    ${trf_id}=1    ${dir}=dl 

    Dated Log    ADT - Start "Stop Traffic" : ue=${ue}, pdu=${pdu}, qfi=${qfi}, dir=${dir}
    
    UteWts.Stop Traffic    ue=${ue}    pdu=${pdu}    qfi=${qfi}    trf_id=${trf_id}    dir=${dir}


Get Average Traffic Rate
    [Documentation]
    ...    Get average data traffic rate in the given direction
    ...        ue          : the UE identifier (default value = 1)
    ...        pdu         : the PDU identifier (default value = 1)
    ...        qfi         : the Quality Flow Identifier (default value = 1)
    ...        dir         : traffic direction : ul for uplink, dl for downlink (default value = "dl")

    [Arguments]    ${ue}=1    ${pdu}=1    ${qfi}=1    ${trf_id}=1    ${dir}=dl 
    
    ${average_rate}=    UteWts.Get Average Traffic Rate  ue=${ue}    pdu=${pdu}    qfi=${qfi}    trf_id=${trf_id}    dir=${dir}

    Dated Log    Average traffic rate = ${average_rate}

    [Return]    ${average_rate}


Start Traffic And Check Average Data Rate
    [Documentation]
    ...    Start data traffic, in the given direction, using EGATE internal traffic simulator then 
    ...    compare the expected data rate with the average data rate obtained during the traffic
    ...    Return these possible values : REACHED or NOT REACHED, EXCEEDED or Fail     
    ...        ue          : the UE identifier (default value = 1)
    ...        pdu         : the PDU identifier (default value = 1)
    ...        qfi         : the Quality Flow Identifier (default value = 1)
    ...        dir         : traffic direction : ul for uplink, dl for downlink (default value = "dl")
    ...        duration    : traffic duration in seconds (default value = 10)
    ...        rate        : required traffic rate in Megabits (default value = 5)
    ...        expected_data_rate    : expected traffic rate in Megabits (default value = 5)
    ...        deviation_in_percent  : acceptable deviation, in percent, applicable to the average traffic rate 

    [Arguments]    ${ue}=1    ${pdu}=1    ${qfi}=1    ${trf_id}=1    ${dir}=dl    ${duration}=10    ${rate}=5     
    ...            ${expected_data_rate}=5    ${deviation_in_percent}=5

    Dated Log    ue=${ue}, pdu=${pdu}, qfi=${qfi}, dir=${dir}, duration=${duration}, rate=${rate}
    Dated Log    expected_data_rate=${expected_data_rate}, deviation_in_percent=${deviation_in_percent}

    UteWts.Start Data Traffic In Egate    ue=${ue}    pdu=${pdu}    qfi=${qfi}    trf_id=${trf_id}    dir=${dir}
    ...                            duration=${duration}    rate=${rate}

    sleep  ${duration}s    reason=Waiting for ${duration} seconds before stopping data traffic ...

    # no neeed to stop as the "seconds" parameter in the above command should limit the traffic for this duration
    # Stop Data Traffic In Egate    ue=${ue}    pdu=${pdu}    qfi=${qfi}    trf_id=${trf_id}    dir=${dir}

    ${average_out}=    UteWts.Get Average Traffic Rate    ue=${ue}    pdu=${pdu}    qfi=${qfi}    trf_id=${trf_id}    dir=${dir}

    ${MEGA}=    Set Variable      1000000
    ${average_rate}=    Evaluate      ${average_out} / ${MEGA}

    Dated Log                       Data rate :  expected = ${expected_data_rate}, current = ${average_rate}

    # compare the average data rate with expected data rate

    ${min}=                         Evaluate                                ${expected_data_rate} * (100 - ${deviation_in_percent}) / 100

    ${max}=                         Evaluate                                ${expected_data_rate} * (100 + ${deviation_in_percent}) / 100

    Run Keyword If                  ${average_rate} < ${min}                Fail    Average rate is lower than minimum expected rate

    ${statusStr}                    Set variable if                         ${average_rate} > ${max}    EXCEEDED    REACHED

    [Return]    ${statusStr}   


Launch UE Detach SA
    [Documentation]
    ...    Detach an UE from GNB
    ...        id                 : UE ID (default value = 1)
    ...        ue_deregister_type : UE deregister type (default value = switch_off)
    ...        by                 : device initiating the deregister procedure (default value = ue)

    [Arguments]    ${id}=1    ${ue_deregister_type}=switch_off    ${by}=ue

    ${output}=     Send Egate Command and verify output
    ...    cmd=ue_deregister id=${id} ue_deregister_type=${ue_deregister_type} by=${by}
    ...    pass_regexp=UE Context Release Complete

