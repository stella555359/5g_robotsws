*** Settings ***


Documentation
...   author: Marcin Wolczynski
...   contact: marcin.wolczynski@nokia.com
...   This is the fading simulator file


Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_5GC007322/manual/fading_simulator.py


*** Variables ***
${SN_1}                 R5CR418GVZN
${SN_2}                 R5CT62PZ25K


*** Test Cases ***

Battery Check For ViNR
    FOR     ${i}    IN RANGE    5
        ${temperature}  get_ue_battery_state    ${SN_1}
        check_temperature   ${temperature}
        ${temperature}  get_ue_battery_state    ${SN_2}
        check_temperature   ${temperature}
    END
