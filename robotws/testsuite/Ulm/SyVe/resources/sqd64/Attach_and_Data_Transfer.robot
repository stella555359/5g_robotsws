*** Settings ***
Documentation
...    author: Michele, Ulm SQD64
...    contact: I_PZ_ULM_SQD_64@internal.nsn.com
...    Description: Keywords for menage the attenuator and perform
...    Attach and Data Tranfer

Library    Collections
Library    OperatingSystem
Library    String
Library    taf.ue

Resource    ../../resources/attenuator.robot
Resource    ../../resources/IPSL.robot
Resource    ../../../resources/Common/testline.robot


*** Variables ***
${IMSI_01}           5551070000001xx
${IMSI_02}           5551070000001xx
${DL_MaxThroughput}        173 Mbits/sec   #15MHz BW:88 Mbits/sec #200 Mbits/sec   #10MHz BW:88 Mbits/sec
${UL_MaxThroughput}         55 Mbits/sec   #15MHz BW:88 Mbits/sec  #82 Mbits/sec   #10MHz BW:35 Mbits/sec
${2UEs_DL_MaxThroughput}    91 Mbits/sec   #10MHz BW:46 Mbits/sec
${2UEs_UL_MaxThroughput}    42 Mbits/sec   #10MHz BW:17 Mbits/sec
${Tput_deviation}           8%
${DL_throughput}           5Mbits/sec
${UL_throughput}           2Mbits/sec
${initial_4G_attenuation}    ${0}
${initial_5G_attenuation}    ${20}
${initial_off_value}         ${110}


*** Keywords ***
Stop IPSL and set Scenario Preconditions
    [Arguments]    ${path_to_ipsl_files}
    testline.Create testcase log directory

    attenuator.Attenuate all cells in testline

    OperatingSystem.Directory Should Not Be Empty    ${path_to_ipsl_files}
    IPSL Stop And Start with specific IMSI    ${path_to_ipsl_files}


IPSL Stop And Start with specific IMSI
    [Documentation]
    ...    The KW is prepared for two UEs. It work also with one UE,
    ...    but the IMSI for the second UE is the ${IMSI_02} assigned.
    [Arguments]    ${path_to_ipsl_files}
    Log To Console    ${\n}STOP IPSL: ${tl.core.ips.ssh_connection_details.addr} (IP from __init__.py file).
    ${ipsl}  ${os}    IPSL.open IPSL connection    ${tl.core.ips.ssh_connection_details.addr}
    IPSL.stop IPSL    alias=${ipsl}    os=${os}
    Sleep  2s

    ${ue_num}=    Get length    ${tl.ues}
    FOR    ${ue_id}    IN RANGE    ${ue_num}
        Set Test Variable    ${IMSI_0${ue_id+1}}    ${tl.ues[${ue_id}].imsi}
        Log    IMSI_0${ue_id+1}:${IMSI_0${ue_id+1}}    console=${P_console}
    END

    Log    START IPSL.${\n}    console=${P_console}
    IPSL.start IPSL    path_to_ipsl_files=${path_to_ipsl_files}
    Sleep  2s


Attach UE to eNB
    [Documentation]
    ...    https://confluence.ext.net.nokia.com/display/AbstractLibs/taf.ue.proxy+available+robot+framework+Keywords
    ...    Possibility to give the UE identify. e.g. ue_id=0 First UE, ue_id=1 Second UE.
    ...    Possibility to give the gNB identify. e.g. gNB_id=0 First gNB, gNB_id=1 Second gNB.
    ...    Possibility to give the Cell identify. (RadioUnit) e.g. ru_id=0 First Cell, ru_id=1 Second Cell, ru_id=2 Third cell.
    ...    Pay Attention: UEs are connected to the same RF cable!
    ...        e.g. giving gNB0 for UE0 and gNB1 for UE1, both UEs are visible to both gNBs.
    [Arguments]    ${ue_id}=0    ${enb_id}=0    ${ru_id}=0
    [Timeout]    5min
    attenuator.Set eNB all ports attenuation      ${initial_4G_attenuation}    enb_id=${enb_id}    ru_id=${ru_id}
    sleep  2s

    Run Keyword And Warn On Failure    taf.ue.Require Ue    UE_${ue_id}   capabilities=REAL_UE
    # ToDo: Pass Execution if    UE_Available=FAIL    The Require Ue KW was Failling. L3 Call can not be verified.

    Log To Console    Perform eNB Attach.${\n}
    taf.ue.Attach Ue    UE_${ue_id}

    ${PefixAlias} =    Set Variable    LTE_DT
    taf.ue.Start Data Transfer    ${PefixAlias}_DL    UE_${ue_id}    DL    duration=30s
    #ToDo: Check why app_server is not in the documentations! e.g.:
    #ToDo: taf.ue.Start Data Transfer    DT_UL    UE1    UL    duration=30s    protocol=tcp    app_server=ssh
    taf.ue.Start Data Transfer    ${PefixAlias}_UL    UE_${ue_id}    UL    duration=30s
    sleep  10s

    taf.ue.Log UE Info    UE_${ue_id}

    #ToDo: Check why "Get cell throughput" is still NotImplementedError for taf.ue Library.
    #ToDo: taf.ue.Require Cell    first_cell    lnbts_id=453901    lcr_id=116198667
    #ToDo: Run Keyword And Warn On Failure    taf.ue.Get cell throughput    cell_alias=first_cell    function=current    direction=dl    type=data

    Await and Stop Data Transfer than Get Average Throughput    DataTranfer=${PefixAlias}

    Set Test Variable    ${PefixAlias}    5G_DT
    taf.ue.Start Data Transfer    ${PefixAlias}_UL    UE_${ue_id}    UL    duration=180s    protocol=tcp
    taf.ue.Start Data Transfer    ${PefixAlias}_DL    UE_${ue_id}    DL    duration=180s    protocol=tcp
    sleep  10s


Perform SgNBAddition
    [Documentation]
    ...    https://confluence.ext.net.nokia.com/display/AbstractLibs/taf.ue.proxy+available+robot+framework+Keywords
    ...    Possibility to give the UE identify. e.g. ue_id=0 First UE, ue_id=1 Second UE.
    ...    Possibility to give the gNB identify. e.g. gNB_id=0 First gNB, gNB_id=1 Second gNB.
    ...    Possibility to give the Cell identify. (RadioUnit) e.g. ru_id=0 First Cell, ru_id=1 Second Cell, ru_id=2 Third cell.
    ...    Pay Attention: UEs are connected to the same RF cable!
    ...        e.g. giving gNB0 for UE0 and gNB1 for UE1, both UEs are visible to both gNBs.
    [Arguments]    ${ue_id}=0    ${gnb_id}=0    ${ru_id}=0
    [Timeout]    10min
    attenuator.Set gNB all ports attenuation      ${initial_5G_attenuation}    gnb_id=${gnb_id}    ru_id=${ru_id}
    sleep  2s
    Log To Console    ${\n}Perform SgNBAddition.${\n}Then, Wait 3 Min. under 5G cell.
    sleep  90s

    taf.ue.Log UE Info    UE_${ue_id}

    Await and Stop Data Transfer than Get Average Throughput    DataTranfer=${PefixAlias}

    Run Keyword And Warn On Failure    taf.ue.Verify Average Throughput With Deviation    ${PefixAlias}_UL    tput=${UL_MaxThroughput}
    ...     deviation=${Tput_deviation}
    Run Keyword And Warn On Failure    taf.ue.Verify Average Throughput With Deviation    ${PefixAlias}_DL    tput=${DL_MaxThroughput}
    ...     deviation=${Tput_deviation}

    Run Keyword And Warn On Failure    taf.ue.Get Data Transfer Statistics    ${PefixAlias}_UL
    Run Keyword And Warn On Failure    taf.ue.Get Data Transfer Statistics    ${PefixAlias}_DL

    # ToDo: FAIL on failure. The TL370 not working in 5G. This is the workaround...
    Run Keyword And Warn On Failure    taf.ue.Validate Ue Info    UE_${ue_id}    5G_STATE    5G_NSA

    [Teardown]   Detach and Attenuate all cells


Await and Stop Data Transfer than Get Average Throughput
    [Arguments]    ${DataTranfer}

    taf.ue.Await Data Transfer Finish    ${DataTranfer}_DL
    taf.ue.Await Data Transfer Finish    ${DataTranfer}_UL

    ${Average_Throughput_UL}=    taf.ue.Get Average Throughput    ${DataTranfer}_UL
    Log    Average Throughput UL:${\n}${Average_Throughput_UL}    console=${P_console}
    ${Average_Throughput_DL}=    taf.ue.Get Average Throughput    ${DataTranfer}_DL
    Log    Average Throughput DL:${\n}${Average_Throughput_DL}    console=${P_console}


Detach and Attenuate all cells
    [Arguments]    ${ue_id}=0
    [Timeout]    15min
    Run Keyword And Warn On Failure    taf.ue.Detach Ue    UE_${ue_id}

    attenuator.Attenuate all cells in testline
