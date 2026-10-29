*** Settings ***
Documentation       An example about how to use the connect tool

Resource            ../Connect.robot
Resource            ../Setup.robot
Resource            ../SetConfig.robot
Resource            ../Scf.robot
Resource            ../Topology.robot

Library             ../../python/Airscales.py

Suite Setup         Suite setup         listBackupFiles=${FD_ALL}
Suite Teardown      Suite Teardown

*** Test Cases ***
Test ORAN
    Dated log                       isOran=[${isORAN}]

Test Dummy
    Dated Log                       Start

Test
    Dated log                       Start
    ${out}                          SSH Connect and Cmd
    ...                                 command=touch GNB_DU.bb.M       host=${GNB_DU.bb[0].M}
    Dated log                       RES TOUCH=${out}
    ${out}                          SSH Connect and Cmd
    ...                                 command=ls                      host=${GNB_DU.bb[0].M}
    Dated log                       RES LS=${out}


Test Node
    Dated log                       Start
    Find Node                       name=CPUE
    ...                             airscale=${TGNB_DU[0]}
    ...                             cardIndex=${0}
    ...                             capacityIndex=${0}
    Find Node                       name=CPUE
    ...                             airscale=${TGNB_DU[0]}
    ...                             cardIndex=${0}
    ...                             capacityIndex=${1}


Test SCF
    Dated Log Mono SCF
    Dated Log SCF                   index=0
    run keyword if                  ${nbGNB}>1
    ...                             Dated Log SCF                   index=1

Test Restore
    OAM Restore Files


*** Keywords ***
Dated Log Mono SCF
    Dated log                       SCF_SETUP_PATH=${SCF_SETUP_PATH}
    Dated log                       SCF_CU_SETUP_PATH=${SCF_CU_SETUP_PATH}

Dated Log SCF
    [Arguments]                     ${index}
    Dated log                       TSCF_SETUP_PATH[${index}]=${TSCF_SETUP_PATH[${index}]}
    Dated log                       TSCF_CU_SETUP_PATH[${index}]=${TSCF_CU_SETUP_PATH[${index}]}

Find Node
    [Arguments]                     ${name}                 # Name of the Node
    ...                             ${airscale}=${TGNB_DU[0]}
    ...                             ${cardIndex}=${0}       # Index in the list of cards supporting such node
    ...                             ${capacityIndex}=${0}   # index of the node in the list of Node for a card
    ${node}                         Get Node
    ...                                 name=${name}
    ...                                 airscale=${airscale}
    ...                                 cardIndex=${cardIndex}
    ...                                 capacityIndex=${capacityIndex}
    Dated Log                       NODE[${name}(${cardIndex},${capacityIndex})]=${node}
