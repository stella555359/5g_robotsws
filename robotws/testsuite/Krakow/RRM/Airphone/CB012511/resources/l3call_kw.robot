*** Settings ***
Documentation
...            author:       Hubert Chrzan, hubert.chrzan@nokia.com
...            maintainer:   Hubert Chrzan, hubert.chrzan@nokia.com

Library     String
Library     Collections
Resource    testsuite/Krakow/resources/former_l3_sw2/main_cls.robot

*** Keywords ***
UE Register 2AP
    [Documentation]    Example of use:
    ...                - use for the ue_id interval: ''UE Register 2AP    start_ue_id=${START_UE_ID}    end_ue_id=${END_UE_ID}''
    ...                - use for a single ue_id: ''UE Register 2AP    single_ue_id=${SINGLE_UE_ID}''
    [Arguments]    ${single_ue_id}=${None}   ${start_ue_id}=${None}    ${end_ue_id}=${None}
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    '${single_ue_id}' == '${None}' or type(${single_ue_id}) is int    msg=Invalid KW parameter: single_ue_id
    Should Be True    '${start_ue_id}' == '${None}' or type(${start_ue_id}) is int    msg=Invalid KW parameter: start_ue_id
    Should Be True    '${end_ue_id}' == '${None}' or type(${end_ue_id}) is int    msg=Invalid KW parameter: end_ue_id
    #---------------------------------------------------------------------------------------------------------------
    IF         ${single_ue_id} != ${None}
        SA UE Register       ue_id=${single_ue_id}    fail_regexp=NONE
        PDU Session Setup    ue_id=${single_ue_id}    pdu_id=1
    ELSE IF    ${single_ue_id} == ${None} and ${start_ue_id} != ${None} and ${end_ue_id} != ${None}
        Multi-UE Register 2AP    start_ue_id=${start_ue_id}    end_ue_id=${end_ue_id}
    END

Multi-UE Register 2AP
    [Arguments]    ${start_ue_id}    ${end_ue_id}
    ${end_ue}    Evaluate    ${end_ue_id} + 1
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${end_ue}
        SA UE Register    ue_id=${ue_id}
        PDU Session Setup    ue_id=${ue_id}
    END

Start Traffic For SA UEs
    [Documentation]    Example of use:
    ...    - UL traffic start for multiple UEs (range 200-205) with 1 Gbps throughput:
    ...    ''Start Traffic For SA UEs    start_ue_id=200    end_ue_id=205    dir=ul    mbps=1000mbps''
    ...    - DL traffic start for one UE with custom TRF-ID range and 150 Mbps throughput:
    ...    ''Start Traffic For SA UEs    single_ue_id=150    dir=dl    start_trf_id=5    end_trf_id=15    mbps=150mbps''
    ...    - Start of DL traffic for one UE with a bandwidth of 50 Mbps:
    ...    ''Start Traffic For SA UEs    single_ue_id=101    dir=dl    mbps=50mbps''
    [Arguments]    ${single_ue_id}=${None}    ${start_ue_id}=${None}    ${end_ue_id}=${None}    ${dir}=dl
    ...    ${start_trf_id}=1    ${end_trf_id}=10    ${mbps}=10mbps
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    '${single_ue_id}' == '${None}' or type(${single_ue_id}) is int    msg=Invalid KW parameter: single_ue_id
    Should Be True    '${start_ue_id}' == '${None}' or type(${start_ue_id}) is int    msg=Invalid KW parameter: start_ue_id
    Should Be True    '${end_ue_id}' == '${None}' or type(${end_ue_id}) is int    msg=Invalid KW parameter: end_ue_id
    Should Be True    '${dir}' in ['dl', 'ul', 'bidir']    msg=Invalid KW parameter: dir. Must be 'dl' or 'ul' or 'bidir'
    Should Be True    type(${start_trf_id}) is int and type(${end_trf_id}) is int    msg=Invalid TRF-ID range parameters
    Should Match Regexp    ${mbps}    ^[1-9][0-9]*[km]?bps$    msg=Invalid KW parameter: tput
    #---------------------------------------------------------------------------------------------------------------
    IF         ${single_ue_id} != ${None}
        Start Traffic For Single UE    ue_id=${single_ue_id}    dir=${dir}    start_trf_id=${start_trf_id}
        ...                            end_trf_id=${end_trf_id}    mbps=${mbps}
    ELSE IF    ${single_ue_id} == ${None} and ${start_ue_id} != ${None} and ${end_ue_id} != ${None}
        Start Traffic For Multi UEs    start_ue_id=${start_ue_id}    end_ue_id=${end_ue_id}    dir=${dir}
        ...                            start_trf_id=${start_trf_id}    end_trf_id=${end_trf_id}    mbps=${mbps}
    END

Start Traffic For Single UE
    [Arguments]    ${ue_id}    ${dir}    ${start_trf_id}    ${end_trf_id}    ${mbps}=10mbps
    Start Traffic For Multi UEs    start_ue_id=${ue_id}    end_ue_id=${ue_id}    dir=${dir}
    ...                            start_trf_id=${start_trf_id}    end_trf_id=${end_trf_id}    mbps=${mbps}

Start Traffic For Multi UEs
    [Arguments]    ${start_ue_id}    ${end_ue_id}    ${dir}    ${start_trf_id}    ${end_trf_id}    ${mbps}=10mbps
    ${end_ue}    Evaluate    ${end_ue_id} + 1
    ${end_trf}    Evaluate    ${end_trf_id} + 1
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${end_ue}
        FOR    ${id}    IN RANGE    ${start_trf_id}    ${end_trf}
            IF    '${dir}' == 'dl' or '${dir}' == 'bidir'
                Start Internal SA Downlink Traffic    ue_id=${ue_id}    pdu_id=1    tput=${mbps}
                ...                                   trf_id=${id}    protocol=tcp
            END
            IF    '${dir}' == 'ul' or '${dir}' == 'bidir'
                Start Internal SA Uplink Traffic    ue_id=${ue_id}    pdu_id=1    tput=${mbps}
                ...                                 trf_id=${id}    protocol=udp    size=1350
            END
            IF    '${dir}' != 'dl' and '${dir}' != 'ul' and '${dir}' != 'bidir'
                Fail    Invalid direction: ${dir}. Must be 'dl' or 'ul' or 'bidir'.
            END
            Sleep    1s
        END
    END

Stop Traffic For SA UEs
    [Arguments]    ${single_ue_id}=${None}    ${start_ue_id}=${None}    ${end_ue_id}=${None}
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    '${single_ue_id}' == '${None}' or type(${single_ue_id}) is int    msg=Invalid KW parameter: single_ue_id
    Should Be True    '${start_ue_id}' == '${None}' or type(${start_ue_id}) is int    msg=Invalid KW parameter: start_ue_id
    Should Be True    '${end_ue_id}' == '${None}' or type(${end_ue_id}) is int    msg=Invalid KW parameter: end_ue_id
    #---------------------------------------------------------------------------------------------------------------
    IF    ${single_ue_id} != ${None}
        Stop Internal SA Traffic    ue_id=${single_ue_id}
    ELSE IF    ${single_ue_id} == ${None} and ${start_ue_id} != ${None} and ${end_ue_id} != ${None}
        Stop Traffic For Multi UEs    start_ue_id=${start_ue_id}    end_ue_id=${end_ue_id}
    END

Stop Traffic For Multi UEs
    [Arguments]    ${start_ue_id}    ${end_ue_id}
    ${end_ue}    Evaluate    ${end_ue_id} + 1
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${end_ue}
        Stop Internal SA Traffic    ue_id=${ue_id}
    END
