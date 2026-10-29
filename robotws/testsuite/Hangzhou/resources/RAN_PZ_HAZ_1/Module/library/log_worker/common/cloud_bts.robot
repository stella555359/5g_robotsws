*** Settings ***
Documentation
...    Author: Liu, Renhui
...    Contact: renhui-david.liu@nokia-sbell.com






*** Keywords ***
cloud_bts.Connect To vCU By Rest
    [Arguments]   ${connection}    ${host}    ${username}    ${password}    ${port}    ${timeout}=${10}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to connect to vcu By Rest.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | product_type | Yes | vdu, vcu |
    ...    | bts_index | Yes | The list index from tl.cu[]  |
    ...    | cudu_index | Yes | the index of cu, du or classical bts  |
    ...    | connection | Yes | an alias for reusing an existing connection later  |
    ...    | timeout | No |   |
    ...    *Example:*
    ...        - cloud_bts.Connect To vCU By Rest
    ...
    run keyword and ignore error    cloud_bts.Disconnect From vCU    ${connection}
    cloud_vcu.connect to    host=${host}
    ...    port=${port}
    ...    username=${username}
    ...    password=${password}
    ...    alias=${connection}
    ...    secure=${True}
    ...    timeout=${timeout}

cloud_bts.Connect To vDU By Rest
    [Arguments]   ${connection}    ${host}    ${username}    ${password}    ${port}    ${timeout}=${10}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to connect to vDU By Rest.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | product_type | Yes | vdu, vcu |
    ...    | bts_index | Yes | The list index from tl.cu[]  |
    ...    | cudu_index | Yes | the index of cu, du or classical bts  |
    ...    | connection | Yes | an alias for reusing an existing connection later  |
    ...    | timeout | No |   |
    ...    *Example:*
    ...        - cloud_bts.Connect To vDU By Rest
    ...
    Run keyword and ignore error    cloud_bts.Disconnect From vDU    ${connection}
    cloud_vdu.connect to    host=${host}
    ...    port=${port}
    ...    username=${username}
    ...    password=${password}
    ...    secure=${True}
    ...    connection_name=${connection}
    ...    timeout=${timeout}

cloud_bts.Disconnect From vCU
    [Arguments]    ${connection}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to disconnect from vCU By Rest.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | product_type | Yes | vdu, vcu |
    ...    | bts_index | Yes | The list index from tl.cu[]  |
    ...    | cudu_index | Yes | the index of cu, du or classical bts  |
    ...    | connection | Yes | an alias for reusing an existing connection later  |
    ...    | timeout | No |   |
    ...    *Example:*
    ...        - cloud_worker.Start To Collect Snapshot Log
    ...
    cloud_vcu.disconnect    connection=${connection}

cloud_bts.Disconnect From vDU
    [Arguments]    ${connection}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to disconnect from vDU By Rest.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | product_type | Yes | vdu, vcu |
    ...    | bts_index | Yes | The list index from tl.cu[]  |
    ...    | cudu_index | Yes | the index of cu, du or classical bts  |
    ...    | connection | Yes | an alias for reusing an existing connection later  |
    ...    | timeout | No |   |
    ...    *Example:*
    ...        - cloud_worker.Start To Collect Snapshot Log
    ...
    cloud_vdu.disconnect    vdu_connection=${connection}
