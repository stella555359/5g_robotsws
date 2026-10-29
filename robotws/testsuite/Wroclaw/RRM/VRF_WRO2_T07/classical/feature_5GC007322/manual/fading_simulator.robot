*** Settings ***
Documentation
...   author: Marcin Wolczynski
...   contact: marcin.wolczynski@nokia.com
...   This is the fading simulator file

Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_5GC007322/manual/fading_simulator.py


*** Variables ***
${HOST_IP}=             10.42.221.77
${start_value_A}=       ${73}
${end_value_A}=         ${95}
${start_value_B}=       ${73}
${end_value_B}=         ${95}
${step}=                ${1}
${time_interval}=       ${200}


*** Test Cases ***


FADING_SIMULATOR_LOGS_COLLECTION
    [Documentation]     This case is to simulate the attenuation on fading simulator
    start_simulation   host=${HOST_IP}    start_value_A=${start_value_A}    end_value_A=${end_value_A}    step=${step}
    ...                start_value_B=${start_value_B}    end_value_B=${end_value_B}    time_interval=${time_interval}
