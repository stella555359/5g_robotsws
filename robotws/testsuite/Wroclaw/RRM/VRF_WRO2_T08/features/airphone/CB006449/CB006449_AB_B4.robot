*** Settings ***
Documentation
...    I. Cell configuration
...
...    No      PCI     LCR     chBW       Band     Technology    Mplane Only
...    ------------------------------------------------------------------------------
...    1        51      1        40        n41        TDD           NO
...    2        52      2        80        n41        TDD           NO
...    3        53      3        40        n77        TDD           NO
...    4        54      4        40        n77        TDD           NO
...    5        55      5       100        n41        TDD           YES
...    6        56      6        90        n41        TDD           YES
...    7        57      7     20/20        n25        FDD           NO
...    8        58      8     20/20        n25        FDD           NO
...    9        59      9     20/20        n25        FDD           YES
...    10       60      10    20/20        n66        FDD           NO
...    11       61      11    20/20        n71        FDD           NO
...    12       62      12    20/20        n71        FDD           UES
...
...
...    II. cells CA relations:
...
...    pcell/scell |  1  |  2  |  3  |  4  |  5  |  6  |  7  |  8  |  9  |  10 |  11 |  12  |          CA type
...    -----------------------------------------------------------------------------------------------------------
...    1           | --- |  x  |  x  |     |     |     |     |     |     |  x  |     |      |      TDD+TDD+TDD+FDD
...    2           |  x  | --- |  x  |     |     |     |     |     |     |  x  |     |      |      TDD+TDD+TDD+FDD
...    3           |  x  |  x  | --- |     |     |     |     |     |     |  x  |     |      |      TDD+TDD+TDD+FDD
...    10          |  x  |  X  |  x  |     |     |     |     |     |     | --- |     |      |      TFD+TDD+TDD+TDD


Force Tags    CLOUD_5G_I_LOO_AP_LOOO    SBTS00    CONFIGURED    CRT    NoResUsage

Resource     ../../../../resources/airphone/5G_SW_WRO_Keywords.robot
Resource     ./resources/CB006449_Keywords.robot
Resource     ./resources/CB006449_Variables.robot
Library      ./resources/CB006449_Keywords.py
Library      ta5g_pm_counters
Library      ta5g_ue_measurements
Library      ta5g_iphy
Library      ta5g_enb
Library      ta5g_testline_management
Library      ta5g_delta

Suite Setup    Run Keywords    Custom Setup Testline
...                                iphy=iphy_6449_AB.xml
...                                scfc=6449_AB_B4_scf.xml
...            AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/SetupLogs
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_CB006449_AA_B3.lua
...                                           mplane_cells=@{mplane_cells}
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/SetupLogs

Suite Teardown    Run Keywords    Stop Default Processes And Gather Logs And Compress Logs
...               AND             Roll Config Back


*** Variables ***
@{mplane_cells}=    5    6    9    12
@{swconfig_flags}=    0x9D0001=1    0x9D0002=1    0x9D0006=55139

*** Test Cases ***
CB006449_AB_B4_UL_Scheduling_Suspend_Resume_On_SCell_Due_To_Power_Limited_For_Multiple_UEs_Configured_With_TT_Intra_Band_Contiguous_UL_2CCs_CA
    [Documentation]    This user scenario describes the successful call setup for multiple UEs with T + T intra-band
    ...                contiguous UL 2CCs CA configured.
    ...                Firstly all UEs are in good radio condition and not power limited on PCell, UL data can be
    ...                scheduled for all UEs on both PCell and SCell. Then increase attenuation to increase downlink
    ...                pathloss on PCell for one UE denoted as UE1, UL scheduling is suspended for UE1 on SCell due
    ...                to power limited on PCell.


    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        AND             Set UL CA Capabilties For Multiple Ues
    ...                           ue_nr_capabilities=UE_UL_CA_CAPA_BC2_BC3_BC4_n41c_n66_BC18_n41_n66_n77_n71
    ...                           ues_amount=10

    Change Location of UEs
    Attach Multiple UEs With Throughput

    Start Traffic On Additional IDs And Await Throughput

    Verify Tcpdump Log    packet_filter=${RRC_RECONF_PCI_52_DL_UL_PCI_60_DL}
    ...                   number_of_messages=15    relation_symbol= >=

    Verify Tcpdump Log    packet_filter=${RRC_RECONF_PCI_51_DL_UL_PCI_60_DL}
    ...                   number_of_messages=15    relation_symbol= >=

    # Confirmation: scell t-put is OK before pathloss
    Assert Ul Traffic On Every Scell    ue_id=1    scells_amount=1    traffic=True
    Assert Dl Traffic On Every Scell    ue_id=1    scells_amount=2    traffic=True

    # Confirmation: scell t-put is OK before pathloss
    Assert Ul Traffic On Every Scell    ue_id=6    scells_amount=1    traffic=True
    Assert Dl Traffic On Every Scell    ue_id=6    scells_amount=2    traffic=True

    Execute Egate Command     cmd=ul_sinr_testmode_nr profile_id=2 pathloss=130
    Execute Egate Command     cmd=ue_testmode_set_nr scell=0 id=1 testmode=ul_sinr action=activate profile_id=2
    Execute Egate Command     cmd=ue_testmode_set_nr scell=0 id=6 testmode=ul_sinr action=activate profile_id=2

    Sleep    10s

    # Confirmation: there isn't scell t-put
    Assert Ul Traffic On Every Scell    ue_id=1    scells_amount=1    traffic=False
    Assert Ul Traffic On Every Scell    ue_id=6    scells_amount=1    traffic=False

    Execute Egate Command     cmd=ue_testmode_set_nr scell=0 id=1 testmode=ul_sinr action=deactivate profile_id=2
    Execute Egate Command     cmd=ue_testmode_set_nr scell=0 id=6 testmode=ul_sinr action=deactivate profile_id=2

    Sleep    10s

    # Confirmation: scell t-put is resumed
    Run Keyword And Continue On Failure    Assert Ul Traffic On Every Scell    ue_id=1    scells_amount=1    traffic=True
    Run Keyword And Continue On Failure    Assert Ul Traffic On Every Scell    ue_id=6    scells_amount=1    traffic=True

    Deregister Multiple Ues    ues_amount=10

    Wait For Next Full Pm Interval
    Verify Pcell Related Counters
    Verify Scell Related Counters
    Verify CB006449 AB B4 Cell_1 Counters
    Verify CB006449 AB B4 Cell_2 Counters

    [Teardown]    Run Keywords    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...           AND             Add Scout External Execution ID To Reporting Portal

*** Keywords ***
Start Traffic On Additional IDs And Await Throughput
    Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 dir=ul trf_id=2 mbps=100
    Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 dir=ul trf_id=3 mbps=100
    Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 dir=dl trf_id=4 mbps=100
    Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 dir=dl trf_id=5 mbps=100

    Execute Egate Command     cmd=trf_data_start ue=6 pdu=6 dir=ul trf_id=6 mbps=100
    Execute Egate Command     cmd=trf_data_start ue=6 pdu=6 dir=ul trf_id=7 mbps=100
    Execute Egate Command     cmd=trf_data_start ue=6 pdu=6 dir=dl trf_id=8 mbps=100
    Execute Egate Command     cmd=trf_data_start ue=6 pdu=6 dir=dl trf_id=9 mbps=100

    Sleep    10s

Change Location Of UEs
    Log To Console    Change UE Location UEs: 5-10
    FOR    ${i}    IN RANGE    6    11
        Change UE Location    ue_id=${i}   dst_enb=2    dst_cell=2
    END

Attach Multiple UEs With Throughput
    Log To Console    UE Attach: 1-10
    FOR    ${ue_id}    IN RANGE    1    11
        Wait Until Keyword Succeeds    2x    100ms    Attach Ue    ue_id=${ue_id}
        Establish Pdu Session With Traffic
        ...    ue_id=${ue_id}    pdu_id=${ue_id}    nwslice=1    gw_id=${ue_id}     direction=both    throughput=10mbps
    END
