*** Settings ***
Documentation       This is for ASIB + ABIL in Trunk ssh to ABIL master / ABIL loner / ABIL slave with hostname.
...                 author: Liu Jia
...                 contact: jia-rebecca.liu@nokia-sbell.com
...                 Do not modify without permission of the owner!

Library    String
Library    Collections
Library    taf.transport.ssh    WITH NAME    ssh
Library    taf.config.testline.info.testline_info.TestlineInfo    WITH NAME    testline_info
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot

*** Keywords ***
