*** Settings ***
Documentation   This is a keyword file for CB008146-E, part commissioning lists
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Keywords ***

Create a3MeasSsbRsrq
    [Documentation]    [PRIVATE]    create list a3MeasSsbRsrq and add it in NRCELL object
    ...       :Autor: Sylvia Schneider
    ${a3MeasSsbRsrq}    Set Variable    <list name="a3MeasSsbRsrq">
    FOR     ${line}   IN
           ...    <item>
           ...    <p name="a3HysteresisSsbRsrq">2</p>
           ...    <p name="a3OffsetSsbRsrq">10</p>
           ...    <p name="a3TimeToTriggerSsbRsrq">ms40</p>
           ...    </item>
           ...    </list>
           ${a3MeasSsbRsrq}    Catenate     SEPARATOR=\n   ${a3MeasSsbRsrq}   ${line}
    END
    Add Element     ${scf_xml}     ${a3MeasSsbRsrq}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-10"]


Update List Values
    [Documentation]    [PRIVATE]    Update List Values
    ...       :Autor: Sylvia Schneider
    ${xpath_cell}  Set Variable   managedObject[@distName="${bts_distName}/NRCELL-10"]
    FOR   ${list}                 ${param}                     ${value}   IN
    ...   a2MeasRedirectSsbRsrp   a2ThresholdRedirectSsbRsrp   24
    ...   a2MeasRedirectSsbRsrq   a2ThresholdRedirectSsbRsrq   21
    ...   a1MeashoSsbRsrpSA       a1ThresholdHoSsbRsrpVoNr     48
    ...   a2MeashoSsbRsrqSA       a2ThresholdhoSsbRsrqSA       31
       Set Element Text   ${scf_xml}    text=${value}    xpath=.//${xpath_cell}/list[@name="${list}"]/item/p[@name="${param}"]
    END
