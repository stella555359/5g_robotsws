*** Settings ***
Documentation
...  Author:        Pawel Wisniewski, Mikolaj Guszpit
...  Contact:       pawel.1.wisniewski@nokia.com, mikolaj.guszpit@nokia.com
...  Maintainer:    pawel.1.wisniewski@nokia.com, mikolaj.guszpit@nokia.com
...  Description:   To be done.

Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB008305/resources/keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/setup_teardown.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common_kw.robot
Library         testsuite.Wroclaw.RRM.VRF_WRO2_T01.resources.legacy.l2_trace                      WITH NAME    l2_trace
Library         testsuite.Wroclaw.RRM.VRF_WRO2_T01.resources.legacy.TTIDecoderInstaller           WITH NAME    tti
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/ps_csv_parser.py              WITH NAME   parser
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/topyoung_mcs.robot

Suite Setup       Run Keywords
...               Get UEs  ${MULTI_UE}                           AND
...               Set BTS and cell ids as suite variables        AND
...               Remove tmp btslog dir                          AND
...               Setup phaseshifter                             AND
...               Setup TTI Trace Collection                     AND
...               Setup tcpdump collector                        AND
...               tti.download and install

Test Setup        Run Keywords
...               Start syslog capture                           AND
...               Download SCF

Test Teardown     Run keywords
...               Set Scout Configuration ID                AND
...               taf.ue.Stop data transfers for all ues    AND
...               Disable TTI Trace                         AND
...               Collect Snapshot                          AND
...               Stop syslog capture                       AND
...               Recommission to default

*** Variables ***
@{MULTI_UE}   UE_1   UE_2

*** Test Cases ***
[1]CB008305-A_B4_Two_UEs_rank3_or_4_non-GBR_are_paired
    Perform commissioning 8305
    Enable TTI Trace
    Detach UEs from cell   ${MULTI_UE}
    Attach UEs to cell   ${MULTI_UE}
    Start DL for UEs   ue_aliases=${MULTI_UE}  duration=10m
    Start Tcpdump Collector
    sleep    30s
    Stop tcpdump collector  CB008305
    Parse and check tti PS CB008305    PAIR
    Perform delta 8305
    Start Tcpdump Collector
    sleep    30s
    Stop tcpdump collector  CB008305
    Parse and check tti PS CB008305    NONPAIR
