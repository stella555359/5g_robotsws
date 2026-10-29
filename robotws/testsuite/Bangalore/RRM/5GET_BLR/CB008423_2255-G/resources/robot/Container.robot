*** Settings ***
Documentation
...             == Purpose ==
...             Library to manage dynamic discovery of Containers and associated logs
...
...             == Description ==
...             *Concepts:*.
...
...             a container is an encapsulation of a mini virtual machine with its own ecosystem.
...             GNB architecture is designed to put main components (CPRT, L2RT, CPNRT, CPIF, ...)
...             in a container.
...             This module aims at dynamically discover these containers, and retrieve associated logs files.
...             in order to propose to testers a simplified interface where it is only required to specify the component
...             to retrieve the associated log files.
...
...             A Node is defined with :
...             | name      | Name of GNB 5G component                  | CPRT, L2RT, ...  |
...             | host      | reference to host that embeds the node    | GNB_DU.sys[0].M  |
...             | id        | Unique identifier of the node             | CPUE20           |
...             | nodeId    | Internal identifier at system level       | 0x2513           |
...             | log       | reference to associated log file          |                  |
...
...             A NodeLog is defined with :
...             | id              | unique identifier of the log file         | CPRT00                                     |
...             | node            | reference to node embedding this log file | CPRT00                                     |
...             | dir             | root path to reach the file               | /tmp/node_CPRT00/tmp/                      |
...             | rootName        | Name without extension of the log file    | startup_cp_rt                              |
...             | ext             | Current extension                         | log.xz                                     |
...             | name            | current name with extention               | startup_cp_rt.log                          |
...             | path            | current final path                        | /tmp/node_CPRT00/tmp/startup_cp_rt.log.xz  |
...             Name, extension and path can be updated at any moment thanks to "Node Log Update Name" Keyword
...             For instance, at suite setup, the extension can be log, then at one moement the file is zipped and extension
...             becomes .zip or .log.xz, requiring to perform an unzip of the file
...
...             *Services:*.
...
...             Main services are :
...             | Get Node             | to get a reference on a node knowing its name, its card index and its capactity index |
...             | Get Log              | to get a reference on a log knowing its name, its card index and its capactity index  |
...             | Node Log Update Name | To update name, extension and path of a log                                           |
...
...             The card index is the index in the list of cards supporting such Node.
...             The capacity index is the index of the node in the list of Node for a card.
...             For instance, for a GNB BOO, let say we have 4 CPUE nodes :
...                CPUE20 and CPUE21 on first ABIL card, CPUE30 and CPUE31 on second ABIL card.
...             Get Node(CPUE,0,0) will return CPUE20 (0 for first card, 0 for first node).
...             Get Node(CPUE,0,1) will return CPUE21 (0 for first card, 1 for second node).
...             Get Node(CPUE,1,0) will return CPUE30 (1 for second card, 0 for first node).
...             Get Node(CPUE,1,1) will return CPUE31 (1 for second card, 1 for second node).


Library                             taf.transport.ssh                 WITH NAME    csn

Variables                           ../../../resources/NPS/SWENG/python/ReadConfig.py
Resource                            Connect.robot
Library                             ../../../resources/NPS/SWENG/python/Container.py
Library                             ../../../resources/NPS/SWENG/python/StringTool.py

*** Variables ***
*** Keywords ***
WA Update Nodes and Logs Def
    [Documentation]                 INTERNAL USAGE
    ...                             Loop until discovery of nodes is OK
    Wait until keyword succeeds     4min    30s
    ...                             NodesAndLogDiscovery

Get Node
    [Documentation]                 Retrieve an instance of node, knowing its card index and its capacity index.
    ...                             The card index is the index in the list of cards supporting such Node.
    ...                             The capacity index is the index of the node in the list of Node for a card.
    ...                             For instance, for a GNB BOO, let say we have 4 CPUE nodes :
    ...                                 CPUE20 and CPUE21 on first ABIL card, CPUE30 and CPUE31 on second ABIL card
    ...                             Get Node(CPUE,0,0) will return CPUE20 (0 for first card, 0 for first node)
    ...                             Get Node(CPUE,0,1) will return CPUE21 (0 for first card, 1 for second node)
    ...                             Get Node(CPUE,1,0) will return CPUE30 (1 for second card, 0 for first node)
    ...                             Get Node(CPUE,1,1) will return CPUE31 (1 for second card, 1 for second node)
    [Arguments]                     ${name}                 # Name of the Node
    ...                             ${cardIndex}=${0}       # Index in the list of cards supporting such node
    ...                             ${capacityIndex}=${0}   # index of the node in the list of Node for a card
    ${node}                         getNodeMatching
    ...                                 name=${name}
    ...                                 cardIndex=${cardIndex}
    ...                                 capacityIndex=${capacityIndex}
    [Return]                        ${node}

Get Log
    [Documentation]                 Retrieve an instance of log, knowing its card index and its capacity index.
    ...                             The card index is the index in the list of cards supporting such Node.
    ...                             The capacity index is the index of the node in the list of Node for a card.
    ...                             For instance, for a GNB BOO, let say we have 4 CPUE nodes :
    ...                                 CPUE20 and CPUE21 on first ABIL card, CPUE30 and CPUE31 on second ABIL card
    ...                             Get Log(CPUE,0,0) will return log for CPUE20 (0 for first card, 0 for first node)
    ...                             Get Log(CPUE,0,1) will return log for CPUE21 (0 for first card, 1 for second node)
    ...                             Get Log(CPUE,1,0) will return log for CPUE30 (1 for second card, 0 for first node)
    ...                             Get Log(CPUE,1,1) will return log for CPUE31 (1 for second card, 1 for second node)
    [Arguments]                     ${name}                 # Name of the Node
    ...                             ${cardIndex}=${0}       # Index in the list of cards supporting such node
    ...                             ${capacityIndex}=${0}   # index of the node in the list of Node for a card
    ${log}                          getLogMatching
    ...                                 name=${name}
    ...                                 cardIndex=${cardIndex}
    ...                                 capacityIndex=${capacityIndex}
    [Return]                        ${log}

Node Log Update Name
    [Documentation]                 Update name, extension and path of a log file, in case it has changed between suite setup and now
    [Arguments]                     ${log}
    call method                     ${log}                                  updateName

