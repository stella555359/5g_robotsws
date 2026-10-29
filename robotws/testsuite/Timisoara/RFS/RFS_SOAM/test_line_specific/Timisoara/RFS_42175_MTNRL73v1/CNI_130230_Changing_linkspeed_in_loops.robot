*** Settings ***
Documentation  Test Suite

Resource
...  taf/rfrl/procedures/SISO/CNI130230/CNI_130230_Changing_linkspeed_in_loops.robot

*** Variables ***

&{LINKSPEED_DICT_2}    dist_name=MRBTS-623073/EQM-1/HWTOP-1/CABLINK-1
    ...                parameter=linkSpeed
    ...                planned_value=Auto
    ...                origin_value=cpri7
&{LINKSPEED_DICT_4}    dist_name=MRBTS-623073/EQM-1/HWTOP-1/CABLINK-3
    ...                parameter=linkSpeed
    ...                planned_value=Auto
    ...                origin_value=Cpri7
&{LINKSPEED_DICT_5}    dist_name=MRBTS-623073/EQM-1/HWTOP-1/CABLINK-4
    ...                parameter=linkSpeed
    ...                planned_value=Auto
    ...                origin_value=Cpri7
@{LINKSPEED}   ${LINKSPEED_DICT_2}  ${LINKSPEED_DICT_4}  ${LINKSPEED_DICT_5}

&{LINKSPEED_MAX_2}     dist_name=MRBTS-623073/EQM_R-4/HWTOP_R-1/CABLINK_R-1001
    ...                parameter=linkMaxPhysicalCapacity
    ...                planned_value=Auto
    ...                origin_value=9830
&{LINKSPEED_MAX_4}     dist_name=RBTS-623073/EQM_R-4/HWTOP_R-1/CABLINK_R-1002
    ...                parameter=linkMaxPhysicalCapacity
    ...                planned_value=Auto
    ...                origin_value=9830
&{LINKSPEED_MAX_5}     dist_name=MRBTS-623073/EQM_R-4/HWTOP_R-1/CABLINK_R-1003
    ...                parameter=linkMaxPhysicalCapacity
    ...                planned_value=Auto
    ...                origin_value=9830
@{LINKSPEED_MAX}    ${LINKSPEED_MAX_2}  ${LINKSPEED_MAX_4}  ${LINKSPEED_MAX_5}


*** Test Cases ***
CNI_130230_Changing_linkspeed_in_loops
    [Timeout]    14400
    Run Keywords
    ...  Set Test Variable  ${LINKSPEED_PARAMETERS}  ${LINKSPEED}
    ...  AND  Set Test Variable  ${MAX_LINKSPEED_PARAMETERS}  ${LINKSPEED_MAX}
    ...  AND  Set Test Variable  ${REPEAT_COUNTER}  1
    CNI_130230_Changing_linkspeed_in_loops
    ...    linkspeed_parameters=${LINKSPEED_PARAMETERS}
    ...    max_linkspeed_parameters=${MAX_LINKSPEED_PARAMETERS}
    ...    iterations=${REPEAT_COUNTER}
    ...    bts_id=${0}
    ...    bts_type=enb
