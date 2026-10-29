*** Settings ***
Documentation
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn
Library    Collections
Library    String
Library    json
Library    DateTime
Library    taf.hw.pdu
Library    taf.hw.optical_switch    WITH NAME    optical_switch
Library    taf.vran.vdu.enb.rest.interface.LTEvDU    WITH NAME    ltevdu

Resource    ../../../resources/Robot/common_kw.robot
Resource    ../../resources/variables.robot

*** Variables ***
${VDU_SCF_PATH}=    ${CURDIR}/SCF/SCFC_vDU.xml
${LTE_VDU_SCF_PATH}=    ${CURDIR}/SCF_8727/SCFC_vDU.xml
${DELTA_FILE_PATH}=    ${CURDIR}/SCF/SCFC_vDU_delta.json

#@{RMOD_SN_LIST}=  LR231902254  LR231902254
@{RMOD_SN_LIST}=  LR231902254  1M190413180  1M230816495


*** Test Cases ***
Test
    Set Message Colors
    Set Log Prefix  set_prefix=True
    ${log_to_console}=  Set Variable  True
    ${log_prefix}=  Set Variable  ${info_prefix}

    ${lte_vdu_connection}=  Set Variable  ${LTE_VDU_CONNECTION_DEFAULT}
    Log  \nLTE VDU ALLOWED ALARMS: ${LTE_VDU_ALLOWED_ALARMS}\n  console=True
