*** Settings ***
Documentation
...    author:  Justyna Klinger-Obszarny
...    contact: justyna.klinger-obszarny@nokia.com


Library     ta5g_pm_counters
Library     ute_fsmaccess
Library     ta_emss
Library     taf.rfrl.bts.devices.du.commissioning
Library     taf.rfrl.bts.devices.du.commissioning.GnbCommissioning    WITH NAME      gnbscf
Resource    taf/rfrl/ue/robot/REAL_UE.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables   resources/variables.py

*** Variables ***
${TRAFFIC_DURATION_SEC}    10s
${protocol}                udp
${deviation}               10%
${UE_1_alias}              UE_1
${UE_2_alias}              UE_2
${capabilities_ue}         REAL_UE

*** Test Cases ***
CB008009-A_7_DL_Throughput_Distribution_counters_linear_for_NON_PMQAP_profile_NSA
    [Documentation]
    ...  Set parameters for feature activation:
    ...    * actThpDist=1
    ...    * actIpThpt=1
    ...    * thpTimeCalc=enabled
    ...    * reportingIntervalPm=5
    ...
    ...  Feature configuration parameters:
    ...    * durationThresDiscardDL set to default value (40ms) for each NRDRB object (MRBTS-76008/NRBTS-76008/NRDRB-X)
    ...    * volThresDiscardDl set to default value (8000 kBs) ) for each NRDRB object (MRBTS-76008/NRBTS-76008/NRDRB-X)
    ...  Defining distribution BINs:
    ...    * thpHistScale set to Linear
    ...    * histDownlinkMaxRange set to default 1000000 kbit/s (1Gbit/s)
    ...    * histDownlinkMinRange set to default 100 kbit/s (0.1Mbit/s)

    [Setup]    gnbscf.Perform Bts Delta Commissioning    delta=${delta_dict}    bts_id=0

    Log to console  One UE scenario...
    Wait for next full pm interval

    ue.Require Ue    ${UE_1_alias}
    ...  capabilities=${capabilities_ue}
    ue.Detach Ue     ${UE_1_alias}
    ue.Attach Ue     ${UE_1_alias}
    Sleep  3s

    Start DL Data Traffic on Real UE    ue_alias=${UE_1_alias}    protocol=${protocol}
    ...    time=${TRAFFIC_DURATION_SEC}    tput_val=40000 Kbits/sec    dt_name=DT_DL_UE_1
    ue.Verify Average Throughput With Deviation    dt_name=DT_DL_UE_1    tput=40000 Kbits/sec    deviation=${deviation}
    Sleep  10s

    Start DL Data Traffic on Real UE    ue_alias=${UE_1_alias}    protocol=${protocol}
    ...    time=${TRAFFIC_DURATION_SEC}    tput_val=225000 Kbits/sec    dt_name=DT_DL_UE_1
    ue.Verify Average Throughput With Deviation    dt_name=DT_DL_UE_1    tput=225000 Kbits/sec    deviation=${deviation}
    Sleep  10s

    Start DL Data Traffic on Real UE    ue_alias=${UE_1_alias}    protocol=${protocol}
    ...    time=${TRAFFIC_DURATION_SEC}    tput_val=475000 Kbits/sec    dt_name=DT_DL_UE_1
    ue.Verify Average Throughput With Deviation    dt_name=DT_DL_UE_1    tput=475000 Kbits/sec    deviation=${deviation}
    Sleep  10s

    Wait for next full pm interval
    ${pm_counters}=  Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...    M55350C20002    8-12      DL_PDCP_UE_TPUT_BIN1
    ...    M55350C20003    0         DL_PDCP_UE_TPUT_BIN2
    ...    M55350C20004    0         DL_PDCP_UE_TPUT_BIN3
    ...    M55350C20005    0         DL_PDCP_UE_TPUT_BIN4
    ...    M55350C20006    8-12      DL_PDCP_UE_TPUT_BIN5
    ...    M55350C20007    0         DL_PDCP_UE_TPUT_BIN6
    ...    M55350C20008    0         DL_PDCP_UE_TPUT_BIN7
    ...    M55350C20009    0         DL_PDCP_UE_TPUT_BIN8
    ...    M55350C20010    0         DL_PDCP_UE_TPUT_BIN9
    ...    M55350C20011    8-12      DL_PDCP_UE_TPUT_BIN10
    ...    M55350C20012    0         DL_PDCP_UE_TPUT_BIN11
    ...    M55350C20013    0         DL_PDCP_UE_TPUT_BIN12
    ...    M55350C20014    0         DL_PDCP_UE_TPUT_BIN13
    ...    M55350C20015    0         DL_PDCP_UE_TPUT_BIN14
    ...    M55350C20016    0         DL_PDCP_UE_TPUT_BIN15
    ...    M55350C20017    0         DL_PDCP_UE_TPUT_BIN16
    ...    M55350C20018    0         DL_PDCP_UE_TPUT_BIN17
    ...    M55350C20019    0         DL_PDCP_UE_TPUT_BIN18
    ...    M55350C20020    0         DL_PDCP_UE_TPUT_BIN19
    ...    M55350C20021    0         DL_PDCP_UE_TPUT_BIN20
    ...    local_moid=PLMN-PLMN/MRBTS-76021/NRBTS-76021/NRCELL-2
    ...    file_path=${pm_counters}

    ue.Detach Ue     ${UE_1_alias}
    Sleep  10s

    Log to console  Multi UEs scenario...
    Wait for next full pm interval

	ue.Attach Ue     ${UE_1_alias}
	ue.Require Ue    ${UE_2_alias}
	...  capabilities=${capabilities_ue}
	ue.Attach Ue     ${UE_2_alias}

    Start DL Data Traffic on Real UE    ue_alias=${UE_1_alias}    protocol=${protocol}
    ...    time=${TRAFFIC_DURATION_SEC}    tput_val= 40000 Kbits/sec    dt_name=DT_DL_UE_1
    Start DL Data Traffic on Real UE    ue_alias=${UE_2_alias}    protocol=${protocol}
    ...    time=${TRAFFIC_DURATION_SEC}    tput_val=40000 Kbits/sec    dt_name=DT_DL_UE_2
    ue.Verify Average Throughput With Deviation    dt_name=DT_DL_UE_1    tput=40000 Kbits/sec    deviation=${deviation}
    ue.Verify Average Throughput With Deviation    dt_name=DT_DL_UE_2    tput=40000 Kbits/sec    deviation=${deviation}
    Sleep  10s

    Start DL Data Traffic on Real UE    ue_alias=${UE_1_alias}    protocol=${protocol}
    ...    time=${TRAFFIC_DURATION_SEC}    tput_val=225000 Kbits/sec    dt_name=DT_DL_UE_1
    Start DL Data Traffic on Real UE    ue_alias=${UE_2_alias}    protocol=${protocol}
    ...    time=${TRAFFIC_DURATION_SEC}    tput_val=225000 Kbits/sec    dt_name=DT_DL_UE_2
    ue.Verify Average Throughput With Deviation    dt_name=DT_DL_UE_1    tput=225000 Kbits/sec    deviation=${deviation}
    ue.Verify Average Throughput With Deviation    dt_name=DT_DL_UE_2    tput=225000 Kbits/sec    deviation=${deviation}
    Sleep  10s

    Start DL Data Traffic on Real UE    ue_alias=${UE_1_alias}    protocol=${protocol}
    ...    time=${TRAFFIC_DURATION_SEC}    tput_val=475000 Kbits/sec    dt_name=DT_DL_UE_1
    Start DL Data Traffic on Real UE    ue_alias=${UE_2_alias}    protocol=${protocol}
    ...    time=${TRAFFIC_DURATION_SEC}    tput_val=475000 Kbits/sec    dt_name=DT_DL_UE_2
    ue.Verify Average Throughput With Deviation    dt_name=DT_DL_UE_1    tput=475000 Kbits/sec    deviation=${deviation}
    ue.Verify Average Throughput With Deviation    dt_name=DT_DL_UE_2    tput=475000 Kbits/sec    deviation=${deviation}
    Sleep  10s

    Wait for next full pm interval
    ${pm_counters2}=  Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...    M55350C20002    8-12      DL_PDCP_UE_TPUT_BIN1
    ...    M55350C20003    0-1000    DL_PDCP_UE_TPUT_BIN2
    ...    M55350C20004    0-1000    DL_PDCP_UE_TPUT_BIN3
    ...    M55350C20005    0-1000    DL_PDCP_UE_TPUT_BIN4
    ...    M55350C20006    8-12      DL_PDCP_UE_TPUT_BIN5
    ...    M55350C20007    0-1000    DL_PDCP_UE_TPUT_BIN6
    ...    M55350C20008    0-1000    DL_PDCP_UE_TPUT_BIN7
    ...    M55350C20009    0-1000    DL_PDCP_UE_TPUT_BIN8
    ...    M55350C20010    0-1000    DL_PDCP_UE_TPUT_BIN9
    ...    M55350C20011    0-1000    DL_PDCP_UE_TPUT_BIN10
    ...    M55350C20012    8-12      DL_PDCP_UE_TPUT_BIN11
    ...    M55350C20013    0-1000    DL_PDCP_UE_TPUT_BIN12
    ...    M55350C20014    0-1000    DL_PDCP_UE_TPUT_BIN13
    ...    M55350C20015    0-1000    DL_PDCP_UE_TPUT_BIN14
    ...    M55350C20016    0-1000    DL_PDCP_UE_TPUT_BIN15
    ...    M55350C20017    0-1000    DL_PDCP_UE_TPUT_BIN16
    ...    M55350C20018    0-1000    DL_PDCP_UE_TPUT_BIN17
    ...    M55350C20019    0-1000    DL_PDCP_UE_TPUT_BIN18
    ...    M55350C20020    0-1000    DL_PDCP_UE_TPUT_BIN19
    ...    M55350C20021    0-1000    DL_PDCP_UE_TPUT_BIN20
    ...    local_moid=PLMN-PLMN/MRBTS-76021/NRBTS-76021/NRCELL-2
    ...    file_path=${pm_counters2}

	[Teardown]    Run keywords    ue.Detach Ue    ${UE_1_alias}
    ...                    AND    ue.Detach Ue    ${UE_2_alias}

CB008009-A_8_DL_Throughput_Distribution_counters_linear_for_PMQAP_profile_NSA
    [Documentation]
    ...  Set parameters for feature activation:
    ...    * actThpDist=1
    ...    * actIpThpt=1
    ...    * thpTimeCalc=enabled
    ...    * reportingIntervalPm=5
    ...
    ...  Configure NRPMQAP functionality:
    ...    * different PLMNs (mmc, mnc) - (1:1 now and 244:8) are configured
    ...    * QOS profile (PLMN, QCI/5QI) are configured - step 4
    ...
    ...  Feature configuration parameters:
    ...    * urationThresDiscardDL set to default value (40ms) for each NRDRB object (MRBTS-76008/NRBTS-76008/NRDRB-X)
    ...    * volThresDiscardDl set to default value (8000 kBs) ) for each NRDRB object (MRBTS-76008/NRBTS-76008/NRDRB-X)
    ...
    ...  Defining distribution BINs:
    ...    * thpHistScale set to Linear
    ...    * histDownlinkMaxRange set to default 1000000 kbit/s (1Gbit/s)
    ...    * histDownlinkMinRange set to default 100 kbit/s (0.1Mbit/s)

    [Setup]    gnbscf.Perform Bts Delta Commissioning    delta=${delta_dict}    bts_id=0

    Log to console  One UE scenario...
    Wait for next full pm interval

    ue.Require Ue    ${UE_1_alias}
    ...  capabilities=${capabilities_ue}
    ue.Detach Ue     ${UE_1_alias}
    ue.Attach Ue     ${UE_1_alias}
    Sleep  3s

    Start DL Data Traffic on Real UE    ue_alias=${UE_1_alias}    protocol=${protocol}
    ...    time=${TRAFFIC_DURATION_SEC}    tput_val=80 Kbits/sec    dt_name=DT_DL_UE_1
    ue.Verify Average Throughput With Deviation    dt_name=DT_DL_UE_1    tput=80 Kbits/sec    deviation=${deviation}
    Sleep  10s

    Start DL Data Traffic on Real UE    ue_alias=${UE_1_alias}    protocol=${protocol}
    ...    time=${TRAFFIC_DURATION_SEC}    tput_val=500000 Kbits/sec    dt_name=DT_DL_UE_1
    ue.Verify Average Throughput With Deviation    dt_name=DT_DL_UE_1    tput=500000 Kbits/sec    deviation=${deviation}
    Sleep  10s

    Start DL Data Traffic on Real UE    ue_alias=${UE_1_alias}    protocol=${protocol}
    ...    time=${TRAFFIC_DURATION_SEC}    tput_val=1500000 Kbits/sec    dt_name=DT_DL_UE_1
    ue.Verify Average Throughput With Deviation    dt_name=DT_DL_UE_1    tput=1500000 Kbits/sec    deviation=${deviation}
    Sleep  10s

	Wait for next full pm interval
	${pm_counters}=  Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...    M55350C20002    8-12      DL_PDCP_UE_TPUT_BIN1
    ...    M55350C20003    0-1000    DL_PDCP_UE_TPUT_BIN2
    ...    M55350C20004    0-1000    DL_PDCP_UE_TPUT_BIN3
    ...    M55350C20005    0-1000    DL_PDCP_UE_TPUT_BIN4
    ...    M55350C20006    8-12      DL_PDCP_UE_TPUT_BIN5
    ...    M55350C20007    0-1000    DL_PDCP_UE_TPUT_BIN6
    ...    M55350C20008    0-1000    DL_PDCP_UE_TPUT_BIN7
    ...    M55350C20009    0-1000    DL_PDCP_UE_TPUT_BIN8
    ...    M55350C20010    0-1000    DL_PDCP_UE_TPUT_BIN9
    ...    M55350C20011    8-12      DL_PDCP_UE_TPUT_BIN10
    ...    M55350C20012    0-1000    DL_PDCP_UE_TPUT_BIN11
    ...    M55350C20013    0-1000    DL_PDCP_UE_TPUT_BIN12
    ...    M55350C20014    0-1000    DL_PDCP_UE_TPUT_BIN13
    ...    M55350C20015    0-1000    DL_PDCP_UE_TPUT_BIN14
    ...    M55350C20016    0-1000    DL_PDCP_UE_TPUT_BIN15
    ...    M55350C20017    0-1000    DL_PDCP_UE_TPUT_BIN16
    ...    M55350C20018    0-1000    DL_PDCP_UE_TPUT_BIN17
    ...    M55350C20019    0-1000    DL_PDCP_UE_TPUT_BIN18
    ...    M55350C20020    0-1000    DL_PDCP_UE_TPUT_BIN19
    ...    M55350C20021    0-1000    DL_PDCP_UE_TPUT_BIN20
    ...    local_moid=PLMN-PLMN/MRBTS-76021/NRBTS-76021/NRCELL-2
    ...    file_path=${pm_counters}

    ue.Detach Ue     ${UE_1_alias}

    Log to console  Multi UEs scenario...
    Wait for next full pm interval

	ue.Attach Ue     ${UE_1_alias}
	ue.Require Ue    ${UE_2_alias}
	...  capabilities=${capabilities_ue}
	ue.Attach Ue     ${UE_2_alias}

    Start DL Data Traffic on Real UE    ue_alias=${UE_1_alias}    protocol=${protocol}
    ...    time=${TRAFFIC_DURATION_SEC}    tput_val=80 Kbits/sec    dt_name=DT_DL_UE_1
    Start DL Data Traffic on Real UE    ue_alias=${UE_2_alias}    protocol=${protocol}
    ...    time=${TRAFFIC_DURATION_SEC}    tput_val=80 Kbits/sec    dt_name=DT_DL_UE_2
    ue.Verify Average Throughput With Deviation    dt_name=DT_DL_UE_1    tput=80 Kbits/sec    deviation=${deviation}
    ue.Verify Average Throughput With Deviation    dt_name=DT_DL_UE_2    tput=80 Kbits/sec    deviation=${deviation}
    Sleep  10s

    Start DL Data Traffic on Real UE    ue_alias=${UE_1_alias}    protocol=${protocol}
    ...    time=${TRAFFIC_DURATION_SEC}    tput_val=500000 Kbits/sec    dt_name=DT_DL_UE_1
    Start DL Data Traffic on Real UE    ue_alias=${UE_2_alias}    protocol=${protocol}
    ...    time=${TRAFFIC_DURATION_SEC}    tput_val=500000 Kbits/sec    dt_name=DT_DL_UE_2
    ue.Verify Average Throughput With Deviation    dt_name=DT_DL_UE_1    tput=500000 Kbits/sec    deviation=${deviation}
    ue.Verify Average Throughput With Deviation    dt_name=DT_DL_UE_2    tput=500000 Kbits/sec    deviation=${deviation}
    Sleep  10s

    Start DL Data Traffic on Real UE    ue_alias=${UE_1_alias}    protocol=${protocol}
    ...    time=${TRAFFIC_DURATION_SEC}    tput_val=1500000 Kbits/sec    dt_name=DT_DL_UE_1
    Start DL Data Traffic on Real UE    ue_alias=${UE_2_alias}    protocol=${protocol}
    ...    time=${TRAFFIC_DURATION_SEC}    tput_val=1500000 Kbits/sec    dt_name=DT_DL_UE_2
    ue.Verify Average Throughput With Deviation    dt_name=DT_DL_UE_1    tput=1500000 Kbits/sec    deviation=${deviation}
    ue.Verify Average Throughput With Deviation    dt_name=DT_DL_UE_2    tput=1500000 Kbits/sec    deviation=${deviation}
    Sleep  10s

    Wait for next full pm interval
    ${pm_counters2}=  Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...    M55350C20002    8-12      DL_PDCP_UE_TPUT_BIN1
    ...    M55350C20003    0-1000    DL_PDCP_UE_TPUT_BIN2
    ...    M55350C20004    0-1000    DL_PDCP_UE_TPUT_BIN3
    ...    M55350C20005    0-1000    DL_PDCP_UE_TPUT_BIN4
    ...    M55350C20006    8-12      DL_PDCP_UE_TPUT_BIN5
    ...    M55350C20007    0-1000    DL_PDCP_UE_TPUT_BIN6
    ...    M55350C20008    0-1000    DL_PDCP_UE_TPUT_BIN7
    ...    M55350C20009    0-1000    DL_PDCP_UE_TPUT_BIN8
    ...    M55350C20010    0-1000    DL_PDCP_UE_TPUT_BIN9
    ...    M55350C20011    8-12      DL_PDCP_UE_TPUT_BIN10
    ...    M55350C20012    0-1000    DL_PDCP_UE_TPUT_BIN11
    ...    M55350C20013    0-1000    DL_PDCP_UE_TPUT_BIN12
    ...    M55350C20014    0-1000    DL_PDCP_UE_TPUT_BIN13
    ...    M55350C20015    0-1000    DL_PDCP_UE_TPUT_BIN14
    ...    M55350C20016    0-1000    DL_PDCP_UE_TPUT_BIN15
    ...    M55350C20017    0-1000    DL_PDCP_UE_TPUT_BIN16
    ...    M55350C20018    0-1000    DL_PDCP_UE_TPUT_BIN17
    ...    M55350C20019    0-1000    DL_PDCP_UE_TPUT_BIN18
    ...    M55350C20020    0-1000    DL_PDCP_UE_TPUT_BIN19
    ...    M55350C20021    0-1000    DL_PDCP_UE_TPUT_BIN20
    ...    local_moid=PLMN-PLMN/MRBTS-76021/NRBTS-76021/NRCELL-2
    ...    file_path=${pm_counters2}


	[Teardown]    Run keywords    ue.Detach Ue    ${UE_1_alias}
    ...                    AND    ue.Detach Ue    ${UE_2_alias}


*** Keywords ***
Start DL Data Traffic on Real UE
    [Arguments]    ${ue_alias}    ${protocol}    ${time}    ${tput_val}   ${dt_name}
    Start Data Transfer on Real UE    dt_name=${dt_name}    ue_alias=${ue_alias}   direction=dl    protocol=${protocol}     duration=${time}
    ...  tput=${tput_val}
    ...  size_packet=1400B
    ...  buffer_client=4M
    ...  buffer_server=4M
    ...  parallel_streams=1
    Wait for truput stabilization
