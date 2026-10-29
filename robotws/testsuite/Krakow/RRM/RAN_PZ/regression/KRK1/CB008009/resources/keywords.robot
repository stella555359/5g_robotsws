*** Settings ***
Documentation
...    Keywords for CB008009 test suite - throughput distribution counters.
...    author:  Szymon Skorupski
...    contact: szymon.skorupski@nokia.com

Library     ta5g_pm_counters
Library     ute_fsmaccess
Library     ta_emss
Resource    taf/rfrl/bts/robot/common/gnb_scf.robot
Resource    taf/rfrl/ue/robot/REAL_UE.robot
Variables   variables.py

*** Keywords ***
Activate CB008009 feature parameters
    Perform Delta Commissioning On gNB    delta=${delta_dict}

Prepare UE
    [Arguments]         ${ue_alias}     ${capabilities}
    ue.Require Ue       ${ue_alias}     capabilities=${capabilities}
    ue.Detach Ue        ${ue_alias}
    ue.Attach Ue        ${ue_alias}

Start Data Traffic on Real UE
    [Arguments]    ${ue_alias}    ${direction}    ${tput_duration}    ${tput_val}    ${dt_name}
    Start Data Transfer on Real UE      ue_alias=${ue_alias}        direction=${direction}      protocol=udp
    ...                                 duration=${tput_duration}   tput=${tput_val}            size_packet=1400B
    ...                                 buffer_client=4M            buffer_server=4M            parallel_streams=1
    ...                                 dt_name=${dt_name}
    Wait for truput stabilization

Run single UE tput with verification for multi intervals within PM period
    [Arguments]     ${ue_alias}     ${direction}    ${tput_duration}    ${deviation}
    ...             ${tput_val_1}   ${tput_val_2}   ${tput_val_3}
    [Documentation]
    ...     Keyword was designed to perform three intevals of real UE UDP tput with its verification.
    ...     User can define parameters:
    ...     param: direction - tput direction ul/dl,
    ...     param: tput_duration - tput duration within single interval (in seconds),
    ...     param: devation - acceptable tput deviation for verification purposes,
    ...     param: tput_val_1, tput_val_2, tput_val_3 - tput values in each interval

    Log to console  Single UE tput distribution counters verification scenario
    Wait for next full pm interval
    # 1st interval:
    Log to console      First interval: ${tput_val_1} for ${tput_duration}
    Start Data Traffic on Real UE    ue_alias=${ue_alias}    direction=${direction}      tput_duration=${tput_duration}
    ...                              tput_val=${tput_val_1}    dt_name=DT_DL_UE_1
    ue.Verify Average Throughput With Deviation    dt_name=DT_DL_UE_1    tput=${tput_val_1}    deviation=${deviation}
    # 2nd interval:
    Log to console      Second interval: ${tput_val_2} for ${tput_duration}
    Start Data Traffic on Real UE    ue_alias=${ue_alias}    direction=${direction}      tput_duration=${tput_duration}
    ...                                 tput_val=${tput_val_2}    dt_name=DT_DL_UE_1
    ue.Verify Average Throughput With Deviation    dt_name=DT_DL_UE_1    tput=${tput_val_2}    deviation=${deviation}
    # 3rd interval:
    Log to console      Third interval: ${tput_val_3} for ${tput_duration}
    Start Data Traffic on Real UE    ue_alias=${ue_alias}    direction=${direction}      tput_duration=${tput_duration}
    ...                                 tput_val=${tput_val_3}    dt_name=DT_DL_UE_1
    ue.Verify Average Throughput With Deviation    dt_name=DT_DL_UE_1    tput=${tput_val_3}    deviation=${deviation}

DL nonPMQAP tput distribution BIN counters verification for single UE scenario
    [Arguments]     ${ue_alias}    ${direction}    ${tput_duration}    ${deviation}
    [Documentation]
    ...             Keyword was written to test CB008009 DL throughput distribution counters for single UE.
    ...             First it runs three DL UDP tput intervals which duration is defined by tput_duration parameter.
    ...             Then it verifies if counters were collected on gNB.
    ...             Counters values gathered into BINS are compared to tput_duration and tput_values.

    Run single UE tput with verification for multi intervals within PM period    ue_alias=${ue_alias}
    ...             direction=${direction}      tput_duration=${tput_duration}      deviation=${deviation}
    ...             tput_val_1=40000 Kbits/sec  tput_val_2=225000 Kbits/sec         tput_val_3=475000 Kbits/sec
    # DL non_PMQAP Counter verification
    Wait for next full pm interval
    ${pm_counters}=  Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...    M55350C20002    8-11      DL_PDCP_UE_TPUT_BIN1
    ...    M55350C20003    0-2       DL_PDCP_UE_TPUT_BIN2
    ...    M55350C20004    0-2       DL_PDCP_UE_TPUT_BIN3
    ...    M55350C20005    0-2       DL_PDCP_UE_TPUT_BIN4
    ...    M55350C20006    8-11      DL_PDCP_UE_TPUT_BIN5
    ...    M55350C20007    0-2       DL_PDCP_UE_TPUT_BIN6
    ...    M55350C20008    0-2       DL_PDCP_UE_TPUT_BIN7
    ...    M55350C20009    0-2       DL_PDCP_UE_TPUT_BIN8
    ...    M55350C20010    0-2       DL_PDCP_UE_TPUT_BIN9
    ...    M55350C20011    8-11      DL_PDCP_UE_TPUT_BIN10
    ...    M55350C20012    0-2       DL_PDCP_UE_TPUT_BIN11
    ...    M55350C20013    0-2       DL_PDCP_UE_TPUT_BIN12
    ...    M55350C20014    0-2       DL_PDCP_UE_TPUT_BIN13
    ...    M55350C20015    0-2       DL_PDCP_UE_TPUT_BIN14
    ...    M55350C20016    0-2       DL_PDCP_UE_TPUT_BIN15
    ...    M55350C20017    0-2       DL_PDCP_UE_TPUT_BIN16
    ...    M55350C20018    0-2       DL_PDCP_UE_TPUT_BIN17
    ...    M55350C20019    0-2       DL_PDCP_UE_TPUT_BIN18
    ...    M55350C20020    0-2       DL_PDCP_UE_TPUT_BIN19
    ...    M55350C20021    0-2       DL_PDCP_UE_TPUT_BIN20
    ...    local_moid=PLMN-PLMN/MRBTS-76008/NRBTS-76008/NRCELL-1
    ...    file_path=${pm_counters}
    ue.Detach Ue    ue_alias=${ue_alias}

DL PMQAP tput distribution BIN counters verification for single UE scenario
    [Arguments]     ${ue_alias}    ${direction}    ${tput_duration}    ${deviation}
    [Documentation]
    ...             Keyword was written to test CB008009 DL throughput distribution counters for single UE.
    ...             First it runs three DL UDP tput intervals which duration is defined by tput_duration parameter.
    ...             Then it verifies if counters were collected on gNB.
    ...             Counters values gathered into BINS are compared to tput_duration and tput_values.

    Run single UE tput with verification for multi intervals within PM period    ue_alias=${ue_alias}
    ...             direction=${direction}      tput_duration=${tput_duration}      deviation=${deviation}
    ...             tput_val_1=40000 Kbits/sec  tput_val_2=225000 Kbits/sec         tput_val_3=475000 Kbits/sec
    # Counter verification
    Wait for next full pm interval
    ${pm_counters}=  Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...    M55352C03001    8-11      DL_PDCP_UE_TPUT_BIN1_PMQAP
    ...    M55352C03002    0-2       DL_PDCP_UE_TPUT_BIN2_PMQAP
    ...    M55352C03003    0-2       DL_PDCP_UE_TPUT_BIN3_PMQAP
    ...    M55352C03004    0-2       DL_PDCP_UE_TPUT_BIN4_PMQAP
    ...    M55352C03005    8-11      DL_PDCP_UE_TPUT_BIN5_PMQAP
    ...    M55352C03006    0-2       DL_PDCP_UE_TPUT_BIN6_PMQAP
    ...    M55352C03007    0-2       DL_PDCP_UE_TPUT_BIN7_PMQAP
    ...    M55352C03008    0-2       DL_PDCP_UE_TPUT_BIN8_PMQAP
    ...    M55352C03009    0-2       DL_PDCP_UE_TPUT_BIN9_PMQAP
    ...    M55352C03010    8-11      DL_PDCP_UE_TPUT_BIN10_PMQAP
    ...    M55352C03011    0-2       DL_PDCP_UE_TPUT_BIN11_PMQAP
    ...    M55352C03012    0-2       DL_PDCP_UE_TPUT_BIN12_PMQAP
    ...    M55352C03013    0-2       DL_PDCP_UE_TPUT_BIN13_PMQAP
    ...    M55352C03014    0-2       DL_PDCP_UE_TPUT_BIN14_PMQAP
    ...    M55352C03015    0-2       DL_PDCP_UE_TPUT_BIN15_PMQAP
    ...    M55352C03016    0-2       DL_PDCP_UE_TPUT_BIN16_PMQAP
    ...    M55352C03017    0-2       DL_PDCP_UE_TPUT_BIN17_PMQAP
    ...    M55352C03018    0-2       DL_PDCP_UE_TPUT_BIN18_PMQAP
    ...    M55352C03019    0-2       DL_PDCP_UE_TPUT_BIN19_PMQAP
    ...    M55352C03020    0-2       DL_PDCP_UE_TPUT_BIN20_PMQAP
    ...    local_moid=PLMN-PLMN/MRBTS-76008/NRBTS-76008/NRCELL-1
    ...    file_path=${pm_counters}
    ue.Detach Ue    ue_alias=${ue_alias}

UL nonPMQAP tput distribution BIN counters verification for single UE scenario
    [Arguments]     ${ue_alias}    ${direction}    ${tput_duration}    ${deviation}
    [Documentation]
    ...             Keyword was written to test CB008009 UL throughput distribution counters for single UE - non PMQAP.
    ...             First it runs three UL UDP tput intervals which duration is defined by tput_duration parameter.
    ...             Then it verifies if counters were collected on gNB.
    ...             Counters values gathered into BINS are compared to tput_duration and tput_values.

    Run single UE tput with verification for multi intervals within PM period    ue_alias=${ue_alias}
    ...             direction=${direction}      tput_duration=${tput_duration}      deviation=${deviation}
    ...             tput_val_1=26000 Kbits/sec  tput_val_2=46000 Kbits/sec         tput_val_3=56000 Kbits/sec
    # UL non_PMQAP Counter verification
    Wait for next full pm interval
    ${pm_counters}=  Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...    M55349C06000    0-2          UL_RLC_UE_TPUT_BIN1
    ...    M55349C06001    0-2          UL_RLC_UE_TPUT_BIN2
    ...    M55349C06002    0-2          UL_RLC_UE_TPUT_BIN3
    ...    M55349C06003    0-2          UL_RLC_UE_TPUT_BIN4
    ...    M55349C06004    0-2          UL_RLC_UE_TPUT_BIN5
    ...    M55349C06005    7-11         UL_RLC_UE_TPUT_BIN6
    ...    M55349C06006    0-2          UL_RLC_UE_TPUT_BIN7
    ...    M55349C06007    0-2          UL_RLC_UE_TPUT_BIN8
    ...    M55349C06008    0-2          UL_RLC_UE_TPUT_BIN9
    ...    M55349C06009    7-11         UL_RLC_UE_TPUT_BIN10
    ...    M55349C06010    0-2          UL_RLC_UE_TPUT_BIN11
    ...    M55349C06011    7-11         UL_RLC_UE_TPUT_BIN12
    ...    M55349C06012    0-2          UL_RLC_UE_TPUT_BIN13
    ...    M55349C06013    0-2          UL_RLC_UE_TPUT_BIN14
    ...    M55349C06014    0-2          UL_RLC_UE_TPUT_BIN15
    ...    M55349C06015    0-2          UL_RLC_UE_TPUT_BIN16
    ...    M55349C06016    0-2          UL_RLC_UE_TPUT_BIN17
    ...    M55349C06017    0-2          UL_RLC_UE_TPUT_BIN18
    ...    M55349C06018    0-2          UL_RLC_UE_TPUT_BIN19
    ...    M55349C06019    0-2          UL_RLC_UE_TPUT_BIN20
    ...    local_moid=PLMN-PLMN/MRBTS-76008/NRBTS-76008/NRCELL-1
    ...    file_path=${pm_counters}
    ue.Detach Ue    ue_alias=${ue_alias}

UL PMQAP tput distribution BIN counters verification for single UE scenario
    [Arguments]     ${ue_alias}    ${direction}    ${tput_duration}    ${deviation}
    [Documentation]
    ...             Keyword was written to test CB008009 UL throughput distribution counters for single UE - PMQAP.
    ...             First it runs three UL UDP tput intervals which duration is defined by tput_duration parameter.
    ...             Then it verifies if counters were collected on gNB.
    ...             Counters values gathered into BINS are compared to tput_duration and tput_values.

    Run single UE tput with verification for multi intervals within PM period    ue_alias=${ue_alias}
    ...             direction=${direction}      tput_duration=${tput_duration}      deviation=${deviation}
    ...             tput_val_1=26000 Kbits/sec  tput_val_2=46000 Kbits/sec         tput_val_3=56000 Kbits/sec
    # UL PMQAP Counter verification
    Wait for next full pm interval
    ${pm_counters}=  Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...    M55353C01002    0-2          UL_RLC_UE_TPUT_BIN1_PMQAP
    ...    M55353C01003    0-2          UL_RLC_UE_TPUT_BIN2_PMQAP
    ...    M55353C01004    0-2          UL_RLC_UE_TPUT_BIN3_PMQAP
    ...    M55353C01005    0-2          UL_RLC_UE_TPUT_BIN4_PMQAP
    ...    M55353C01006    0-2          UL_RLC_UE_TPUT_BIN5_PMQAP
    ...    M55353C01007    7-11         UL_RLC_UE_TPUT_BIN6_PMQAP
    ...    M55353C01008    0-2          UL_RLC_UE_TPUT_BIN7_PMQAP
    ...    M55353C01009    0-2          UL_RLC_UE_TPUT_BIN8_PMQAP
    ...    M55353C01010    0-2          UL_RLC_UE_TPUT_BIN9_PMQAP
    ...    M55353C01011    7-11         UL_RLC_UE_TPUT_BIN10_PMQAP
    ...    M55353C01012    0-2          UL_RLC_UE_TPUT_BIN11_PMQAP
    ...    M55353C01013    7-11         UL_RLC_UE_TPUT_BIN12_PMQAP
    ...    M55353C01014    0-2          UL_RLC_UE_TPUT_BIN13_PMQAP
    ...    M55353C01015    0-2          UL_RLC_UE_TPUT_BIN14_PMQAP
    ...    M55353C01016    0-2          UL_RLC_UE_TPUT_BIN15_PMQAP
    ...    M55353C01017    0-2          UL_RLC_UE_TPUT_BIN16_PMQAP
    ...    M55353C01018    0-2          UL_RLC_UE_TPUT_BIN17_PMQAP
    ...    M55353C01019    0-2          UL_RLC_UE_TPUT_BIN18_PMQAP
    ...    M55353C01020    0-2          UL_RLC_UE_TPUT_BIN19_PMQAP
    ...    M55353C01021    0-2          UL_RLC_UE_TPUT_BIN20_PMQAP
    ...    local_moid=PLMN-PLMN/MRBTS-76008/NRBTS-76008/NRCELL-1
    ...    file_path=${pm_counters}
    ue.Detach Ue    ue_alias=${ue_alias}
