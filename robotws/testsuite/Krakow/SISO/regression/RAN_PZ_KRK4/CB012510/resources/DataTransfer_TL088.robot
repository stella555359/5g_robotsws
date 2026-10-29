*** Settings ***
Documentation
...    author: Weronika Wojcik
...    contact: weronika.wojcik@nokia.com
...    description: Test Suite for automates throughput testing scenarios with reusable KWs.

Library     testsuite.Krakow.SISO.regression.RAN_PZ_KRK4.CB012510.resources.DataTransferOperations_TL088.AttenuatorOperations
Library     testsuite.Krakow.SISO.regression.RAN_PZ_KRK4.CB012510.resources.DataTransferOperations_TL088.QualcommUeOperations

*** Variables ***

${NR_FDD_DL}                     1200Mbits/sec
${NR_FDD_UL}                     170Mbits/sec

${NR_DSS_DL}                     35Mbits/sec
${NR_DSS_UL}                     18500kbits/sec

${LTE_DSS_DL}                     48Mbits/sec
${LTE_DSS_UL}                     20Mbits/sec

${LTE_DL_20MHz}                  190Mbits/sec
${LTE_UL_20MHz}                  70Mbits/sec

@{ATT_PORTS_CELL_73}=            ${21}  ${22}
@{ATT_VALUES_CELL_73}=           ${30}  ${30}
&{ATT_CONFIG_LTE_CELL_73}=       port_identifiers=@{ATT_PORTS_CELL_73}
...                              attenuation_values=@{ATT_VALUES_CELL_73}
@{ATT_PORTS_CELL_71}=            ${17}  ${18}    ${19}  ${20}
@{ATT_VALUES_CELL_71}=           ${15}  ${15}    ${15}  ${15}
&{ATT_CONFIG_NR_FDD_CELL_71}=    port_identifiers=@{ATT_PORTS_CELL_71}
...                              attenuation_values=@{ATT_VALUES_CELL_71}

@{ATT_PORTS_CELL_16}=            ${25}  ${26}
@{ATT_VALUES_CELL_16}=           ${20}  ${20}
&{ATT_CONFIG_NR_FDD_CELL_16}=    port_identifiers=@{ATT_PORTS_CELL_16}
...                              attenuation_values=@{ATT_VALUES_CELL_16}


*** Keywords ***
Run TCP Data Transfer For Specific Cell
    [Arguments]    ${attenuation_configuration}    ${cell}
    ...            ${direction_first}=dl    ${direction_second}=ul    ${duration}=60s    ${tput_first}=${None}
    ...            ${tput_second}=${None}    ${protocol}=tcp    ${deviation}=5%
    ...            ${parallel_streams_first}=1      ${parallel_streams_second}=1    ${max_segment_size}=${None}

    Set Attenuation
    ...    configuration=${attenuation_configuration}
    Sleep   20s
    Attach Ue    UE
    Log Ue Info   UE    cell_id
    ${direction_upper}    Convert To Upper Case  ${direction_first}
    Log to console      ${direction_upper}

    Start Data Transfer   ue_alias=UE   direction=${direction_first}
    ...     dt_name=DT_${cell}_${direction_upper}
    ...     protocol=${protocol}    duration=${duration}   tput=${tput_first}
    ...     parallel_streams=${parallel_streams_first}    max_segment_size=${max_segment_size}

    Run Keyword and continue on failure     Await Data Transfer Finish       dt_name=DT_${cell}_${direction_upper}
    Run Keyword and continue on failure     Verify Average Throughput With Deviation
    ...     dt_name=DT_${cell}_${direction_upper}   tput=${tput_first}   deviation=${deviation}

    Sleep   60s

    ${direction_upper}    Convert To Upper Case  ${direction_second}
    Log to console      ${direction_upper}

    Start Data Transfer   ue_alias=UE   direction=${direction_second}
    ...     dt_name=DT_${cell}_${direction_upper}
    ...     protocol=${protocol}    duration=${duration}   tput=${tput_second}
    ...     parallel_streams=${parallel_streams_second}

    Run Keyword and continue on failure     Await Data Transfer Finish       dt_name=DT_${cell}_${direction_upper}
    Run Keyword and continue on failure     Verify Average Throughput With Deviation
    ...     dt_name=DT_${cell}_${direction_upper}   tput=${tput_second}   deviation=${deviation}
    Sleep   30s
    Detach Ue    UE

    Set Max Attenuation To All Ports
    Sleep   10s

Run TCP Data Transfer For NR Cells Qualcomm
    [Arguments]    ${deviation}
    set_ue_configuration    NR
    Run TCP Data Transfer For Specific Cell    attenuation_configuration=&{ATT_CONFIG_NR_FDD_CELL_71}    cell=71
    ...    duration=120s    tput_first=${NR_FDD_DL}    protocol=tcp    deviation=${deviation}  direction_first=dl
    ...    direction_second=ul    tput_second=${NR_FDD_UL}    parallel_streams_second=2    parallel_streams_first=8
    ...    max_segment_size=8600

        Run TCP Data Transfer For Specific Cell    attenuation_configuration=&{ATT_CONFIG_NR_FDD_CELL_16}    cell=16
    ...    duration=120s    tput_first=${NR_DSS_DL}    protocol=tcp    deviation=${deviation}  direction_first=dl
    ...    direction_second=ul    tput_second=${NR_DSS_UL}    parallel_streams_second=2    parallel_streams_first=8
    ...    max_segment_size=8600


Run TCP Data Transfer For LTE Cells Qualcomm
    [Arguments]    ${deviation}
    set_ue_configuration    LTE

    Run TCP Data Transfer For Specific Cell    attenuation_configuration=&{ATT_CONFIG_LTE_CELL_73}    cell=71
    ...    duration=120s    tput_first=${LTE_DL_20MHz}    protocol=tcp    deviation=${deviation}  direction_first=dl
    ...    direction_second=ul    tput_second=${LTE_UL_20MHz}    parallel_streams_second=1    parallel_streams_first=1


    Run TCP Data Transfer For Specific Cell    attenuation_configuration=&{ATT_CONFIG_NR_FDD_CELL_16}    cell=17
    ...    duration=120s    tput_first=${LTE_DSS_DL}   protocol=tcp    deviation=${deviation}  direction_first=dl
    ...    direction_second=ul    tput_second=${LTE_DSS_UL}    parallel_streams_second=2    parallel_streams_first=2

