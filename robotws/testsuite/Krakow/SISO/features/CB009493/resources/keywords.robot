*** Settings ***
Documentation
...    Test suite for regression testing for feature CB009493
...    authors: Wioleta Swies
...    maintainer: wioleta.swies@nokia.com
...    group: RAN_PZ_KRK_SG_7
...    contact: wioleta.swies@nokia.com


Library      taf.sbts.oam.coam.admin  WITH NAME  SbtsAdmin
Library      taf.rfrl.bts.devices.asir.asir_operations.GnbAsirHubOperations  WITH NAME  GnbAsir
Library      ./tools.py
Library      taf.transport.ssh  WITH NAME  SSH

Resource     taf/rfrl/bts/robot/enb.robot
Resource     taf/rfrl/bts/robot/gnb.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Library      taf.rfrl.csv4all.CSV4AllTestCases
Resource     testsuite/Krakow/resources/RAN_PZ_KRK7/Quectel_L3_Call/keywords.robot
Resource     taf/rfrl/procedures/resources/robot/SwconfigOperations.robot

Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py

*** Variables ***
${UE_CAPABILITIES}                   QUECTEL_UE
${UE_DEFAULT_ALIAS_NAME}             UE
${DATA_TRANSFER_DEFAULT_DURATION}    120s
${DEFAULT_PACKET_SIZE}               1320
${DEFAULT_PROTOCOL}                  tcp
${DEFAULT_DEVIATION}                 20%


*** Keywords ***
Check data transfer via Quectel with APHG Reset
    [Documentation]    Keyword used to verify throughput (both DL and UL) using Quectel UE.
    ...                Requires useage `Require UE` with same ue_alias before call this KW.
    ...                Intended to be used multiple times within single test case.
    ...                Please define variables such as:
    ...                 - UE_DEFAULT_ALIAS_NAME
    ...                 - DATA_TRANSFER_DEFAULT_DURATION
    ...                 - DEFAULT_PACKET_SIZE
    ...                 - DEFAULT_PROTOCOL
    ...                 - DEFAULT_DEVIATION
    ...                on your Suite/Test level once as this Keyword will automatically loads these as defaults arguments.
    ...                Otherwise pass it normally - expicitly giving each argument desired value.

    [Arguments]    ${throughput_DL}
    ...            ${throughput_UL}
    ...            ${parallel_streams_DL}=1
    ...            ${parallel_streams_UL}=1
    ...            ${ue_alias}=${UE_DEFAULT_ALIAS_NAME}
    ...            ${ue_capabilities}=QUECTEL_UE
    ...            ${duration}=${DATA_TRANSFER_DEFAULT_DURATION}
    ...            ${packet}=${DEFAULT_PACKET_SIZE}
    ...            ${protocol}=${DEFAULT_PROTOCOL}
    ...            ${deviation}=${DEFAULT_DEVIATION}
    ...            ${linux_congestion}=reno
    ...            ${log_throughput}=${False}

    ute_ue.Require UE    ${ue_alias}    capabilities=${ue_capabilities}
    ute_ue.Attach UE    ${ue_alias}
    Sleep    10sec

    ute_ue.Get UE Info    ${ue_alias}    ALL

    Lock ASIR

    Check DL and UL data transfer with Quectel    throughput_DL=${throughput_DL}
    ...                                           throughput_UL=${throughput_UL}
    ...                                           parallel_streams_DL=${parallel_streams_DL}
    ...                                           parallel_streams_UL=${parallel_streams_UL}
    ...                                           ue_alias=${ue_alias}
    ...                                           duration=${duration}
    ...                                           packet=${packet}
    ...                                           protocol=${protocol}
    ...                                           deviation=${deviation}
    ...                                           linux_congestion=${linux_congestion}
    ...                                           log_throughput=${log_throughput}

    [Teardown]    Run keywords    ute_ue.Detach UE    ${ue_alias}    AND
    ...           Run Keyword And Ignore Error    ute_ue.Stop Using UE    ${ue_alias}    AND
    ...           Unlock ASIR

Lock ASIR
    SbtsAdmin.Connect to      name=coam
    SbtsAdmin.lock
    ...        dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/ASIRMOD-1
    ...        connection=coam
    ...        timeout=60
    SbtsAdmin.teardown          connection=coam

Unlock ASIR
    SbtsAdmin.Connect to      name=coam
    SbtsAdmin.unlock
    ...        dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/ASIRMOD-1
    ...        connection=coam
    ...        timeout=60
    SbtsAdmin.teardown          connection=coam
