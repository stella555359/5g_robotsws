*** Settings ***
Documentation  Support tshark operations
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    XML  use_LXML=true
Library    BuiltIn
Library    OperatingSystem
Library    Process
Library    ute_tshark

*** Keywords ***
Tshark Verify Handover To Cell
    [Arguments]  ${cell_under_test}  ${alias}=intraHO
    [Documentation]
    ...  Description:
    ...  Keyword checks whether the information related to the handover to the cell has been sent.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | cell_under_test        | Yes  | Tested cell number.                                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | alias                  | Yes  | Name of execution context.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

     Tshark Verify Message
     ...  packet_filter=iphy.ue_id==1&&lte-rrc.targetPhysCellId==${cell_under_test}&&lte-rrc.handoverType==0
     ...  alias=${alias}

Tshark Verify Message
    [Arguments]  ${packet_filter}  ${alias}=intraHO  ${messages_number}=1
    [Documentation]
    ...  Description:
    ...  Keyword checks whether the number of packets matching the packet filter.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | filter                 | Yes  | Packet filter definition.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | alias                  | Yes  | Name of execution context.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | messages_number        |  No  | Expected number of messages.                                               |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${messages_count}=  Get Packets Count  packet_filter=${packet_filter}  alias=${alias}
    ${result}=  Evaluate  ${messages_count}==${messages_number} or ${messages_count}>${messages_number}
    Should Be True  ${result}==True

Tshark Start Capturing On Interface
    [Arguments]  ${interface}  ${alias}  ${capture_filter}  ${log_dir}=${SUITE_LOGS_DIR_PATH}
    [Documentation]
    ...  Description:
    ...  Keyword start collecting logs with capture filter.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | interface              | Yes  | Host interface which is used to packects capture.                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | alias                  | Yes  | Name of execution context.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | capture_filter         | Yes  | Capture filter definition.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_dir                |  No  | Directory name where pcap file is stored.                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Setup Tshark  interface=${interface}  alias=${alias}  log_dir=${log_dir}  log_name=${alias}
    Start Capturing  capture_filter=${capture_filter}  alias=${alias}

Tshark Stop Capturing
    [Arguments]  ${alias}
    [Documentation]
    ...  Description:
    ...  Keyword stops collecting tshark logs.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | alias                  | Yes  | Name of execution context.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Stop Capturing  alias=${alias}

Tshark Teardown
    [Arguments]  ${alias}
    [Documentation]
    ...  Description:
    ...  Keyword removes tshark connection.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | alias                  | Yes  | Name of execution context.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ute_tshark.Teardown Tshark  alias=${alias}

Tshark Verify Packet Filter
    [Arguments]  ${packet_filter}  ${alias}=filter_alias  ${messages_number}=1
    [Documentation]
    ...  Description:
    ...  Keyword checks if relevant information appeared in packets and returns pass or failed status.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | packet_filter          | Yes  | Packet filter definition.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | alias                  | Yes  | Name of execution context.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | messages_number        |  No  | Expected number of messages.                                               |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${number_of_attach_messages}=  Get Packets Count  packet_filter=${packet_filter}  alias=${alias}
    ${number_of_messages}=  Convert To Integer  item=${messages_number}
    Run Keyword And Ignore Error  Should Be Equal  ${number_of_attach_messages}  ${number_of_messages}

