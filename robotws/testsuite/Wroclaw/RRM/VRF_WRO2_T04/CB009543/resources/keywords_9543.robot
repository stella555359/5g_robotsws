*** Settings ***
Documentation
...   feature keywords

Library    ute_ue
Library    testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod.TcpdumpSmod     WITH NAME    Tcpdump
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ue_keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/5GC001167/resources/keywords.robot

*** Keywords ***
Clear Attenuation On All Subcells
    attenuator_keywords.Initialise Attenuator
    Clear Attenuaton On Subcell    1
    Clear Attenuaton On Subcell    2    attenuation=10
    Clear Attenuaton On Subcell    3

Clear Attenuaton On Subcell
    [Arguments]    ${subcell_id}    ${attenuation}=0
    attenuator_keywords.Initialise Attenuator
    attenuator_keywords.Set Attenuation  ${attenuation}  ${ATTENUATOR['NRCELL_6']['ports']['S${subcell_id}']}  confirm=${TRUE}
    ...    attenuator_id=${ATTENUATOR['NRCELL_6']['att_id']}

Attenuate Subcell
    [Arguments]    ${subcell_id}
    attenuator_keywords.Initialise Attenuator
    Log To Console    Attenuating Subcell ${subcell_id}
    attenuator_keywords.Set Attenuation  90  ${ATTENUATOR['NRCELL_6']['ports']['S${subcell_id}']}  confirm=${TRUE}
    ...    attenuator_id=${ATTENUATOR['NRCELL_6']['att_id']}

Attenuate All Subcells
    attenuator_keywords.Initialise Attenuator
    Attenuate Subcell    1
    Attenuate Subcell    2
    Attenuate Subcell    3

Set Initial Attenuation For FDD Supercell Test
    keywords.Attenuate All Cells    ${1}
    keywords.Attenuate All Cells    ${2}
    Clear Attenuation On All Subcells

