*** Settings ***

Library     testsuite.Krakow.SISO.regression.RAN_PZ_KRK4.CB008973.resources.DataTransferOperation.AttenuatorOperations
Library     testsuite/Krakow/resources/ue_proxy_wsl/ue_proxy_wsl.py

*** Variables ***

${NR_TDD_DL}                     811Mbits/sec
${NR_TDD_UL}                     70Mbits/sec
${NR_FDD_DL}                     200Mbits/sec
${NR_FDD_UL}                     85Mbits/sec
${NR_FDD_DL_4x4}                 370Mbits/sec
${NR_FDD_UL_4x4}                 85Mbits/sec
${LTE_DL_20MHz}                  200Mbits/sec
${LTE_UL_20MHz}                  80Mbits/sec

@{ATT_PORTS_CELL_35}=            ${11}  ${12}
@{ATT_VALUES_CELL_35}=           ${20}  ${20}
&{ATT_CONFIG_LTE_CELL_35}=       port_identifiers=@{ATT_PORTS_CELL_35}
...                              attenuation_values=@{ATT_VALUES_CELL_35}
@{ATT_PORTS_CELL_25}=            ${9}  ${10}
@{ATT_VALUES_CELL_25}=           ${30}  ${18}
&{ATT_CONFIG_LTE_CELL_25}=       port_identifiers=@{ATT_PORTS_CELL_25}
...                              attenuation_values=@{ATT_VALUES_CELL_25}
@{ATT_PORTS_CELL_11}=            ${1}  ${2}
@{ATT_VALUES_CELL_11}=           ${28}  ${32}
&{ATT_CONFIG_NR_TDD_CELL_11}=    port_identifiers=@{ATT_PORTS_CELL_11}
...                              attenuation_values=@{ATT_VALUES_CELL_11}
@{ATT_PORTS_CELL_22}=            ${9}  ${10}
@{ATT_VALUES_CELL_22}=           ${23}  ${25}
&{ATT_CONFIG_NR_FDD_CELL_22}=    port_identifiers=@{ATT_PORTS_CELL_22}
...                              attenuation_values=@{ATT_VALUES_CELL_22}
@{ATT_PORTS_CELL_41}=            ${13}  ${14}  ${3}  ${4}
@{ATT_VALUES_CELL_41}=           ${35}  ${35}  ${35}  ${35}
&{ATT_CONFIG_NR_FDD_CELL_41}=    port_identifiers=@{ATT_PORTS_CELL_41}
...                              attenuation_values=@{ATT_VALUES_CELL_41}

*** Keywords ***
Run TCP Data Transfer For Specific Cell
    [Arguments]    ${attenuation_configuration}    ${cell}
    ...            ${direction_first}=dl    ${direction_second}=ul    ${duration}=60s    ${tput_first}=${None}
    ...            ${tput_second}=${None}    ${protocol}=tcp    ${deviation}=5%
    ...            ${parallel_streams_first}=1      ${parallel_streams_second}=1

    Set Attenuation
    ...    configuration=${attenuation_configuration}

    Attach Ue    UE
    Sleep   60s
    Log Ue Info   UE    cell_id
    ${direction_upper}    Convert To Upper Case  ${direction_first}
    Log to console      ${direction_upper}

    Start Data Transfer   ue_alias=UE   direction=${direction_first}
    ...     dt_name=DT_${cell}_${direction_upper}
    ...     protocol=${protocol}    duration=${duration}   tput=${tput_first}
    ...     parallel_streams=${parallel_streams_first}

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

Run TCP Data Transfer For NR Cells
    [Arguments]    ${deviation}
    restart_proxy_on_ue_pc
    require UE  UE  capabilities=REAL_UE
    Run TCP Data Transfer For Specific Cell    attenuation_configuration=&{ATT_CONFIG_NR_FDD_CELL_41}    cell=41
    ...    duration=60s    tput_first=${NR_FDD_DL_4x4}    protocol=tcp    deviation=${deviation}  direction_first=dl
    ...    direction_second=ul    tput_second=${NR_FDD_UL_4x4}    parallel_streams_second=2    parallel_streams_first=1

    Run TCP Data Transfer For Specific Cell    attenuation_configuration=&{ATT_CONFIG_NR_FDD_CELL_22}    cell=22
    ...    duration=60s    tput_first=${NR_FDD_DL}    protocol=tcp    deviation=${deviation}  direction_first=dl
    ...    direction_second=ul    tput_second=${NR_FDD_UL}    parallel_streams_second=2    parallel_streams_first=1

    Run TCP Data Transfer For Specific Cell    attenuation_configuration=&{ATT_CONFIG_NR_TDD_CELL_11}    cell=11
    ...    duration=60s    tput_first=${NR_TDD_DL}    protocol=tcp    deviation=${deviation}  direction_first=dl
    ...    direction_second=ul    tput_second=${NR_TDD_UL}    parallel_streams_second=2    parallel_streams_first=1

Run TCP Data Transfer For LTE Cells
    [Arguments]    ${deviation}
    restart_proxy_on_ue_pc
    require UE  UE  capabilities=REAL_UE
    Run TCP Data Transfer For Specific Cell    attenuation_configuration=&{ATT_CONFIG_LTE_CELL_35}    cell=35
    ...    duration=60s    tput_first=${LTE_DL_20MHz}    protocol=tcp    deviation=${deviation}  direction_first=dl
    ...    direction_second=ul    tput_second=${LTE_UL_20MHz}    parallel_streams_second=2    parallel_streams_first=1

    Run TCP Data Transfer For Specific Cell    attenuation_configuration=&{ATT_CONFIG_LTE_CELL_25}    cell=25
    ...    duration=60s    tput_first=${LTE_DL_20MHz}   protocol=tcp    deviation=${deviation}  direction_first=dl
    ...    direction_second=ul    tput_second=${LTE_UL_20MHz}    parallel_streams_second=2    parallel_streams_first=1
