*** Settings ***
Documentation   This is a keyword file for 480-L, part commissioning, new objects
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Keywords ***

Create LCELNR CHANNELGROUP CHANNEL
    [Documentation]    [PRIVATE]    Create LCELNR  CHANNELGROUP CHANNEL objects in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${LCELNR}
    Log To Console    Building object MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${LCELNR}
    ${obj_LCELNR}    Set Variable  <managedObject class="LCELNR" distName="MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${LCELNR}"
    ${obj_LCELNR}   Catenate     SEPARATOR=${SPACE}   ${obj_LCELNR}    version="${SCF.MNL_version}" operation="create">
    FOR     ${line}   IN
           ...    <p name="actAsiDistMimoNr">false</p>
           ...    <p name="actSimplChConfMAA">false</p>
           ...    </managedObject>
           ${obj_LCELNR}   Catenate     SEPARATOR=\n         ${obj_LCELNR}   ${line}
    END
    Add Element     ${scf_xml}     ${obj_LCELNR}           xpath=.//cmData

    Log To Console    Building object MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${LCELNR}/CHANNELGROUP-1
    ${obj_CHANNELGROUP}    Set Variable
    ...  <managedObject class="CHANNELGROUP" distName="MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${LCELNR}/CHANNELGROUP-1"
    ${obj_CHANNELGROUP}   Catenate     SEPARATOR=${SPACE}   ${obj_CHANNELGROUP}    version="${SCF.MNL_version}" operation="create"/>
    Add Element     ${scf_xml}     ${obj_CHANNELGROUP}           xpath=.//cmData

    FOR   ${CHANNEL}   ${direction}   IN
    ...   1            TX
    ...   2            RX
    ...   3            TX
    ...   4            RX
       Log To Console    Building object MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${LCELNR}/CHANNELGROUP-1/CHANNEL-${CHANNEL}
       ${obj_CHANNEL}    Set Variable
       ...  <managedObject class="CHANNEL" distName="MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${LCELNR}/CHANNELGROUP-1/CHANNEL-${CHANNEL}"
       ${obj_CHANNEL}   Catenate     SEPARATOR=${SPACE}   ${obj_CHANNEL}    version="${SCF.MNL_version}" operation="create">
       ${obj_CHANNEL}   Catenate     SEPARATOR=\n         ${obj_CHANNEL}   <p name="direction">${direction}</p>
       ${obj_CHANNEL}   Catenate     SEPARATOR=\n         ${obj_CHANNEL}   <p name="resourceDN">MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1</p>
       ${obj_CHANNEL}   Catenate     SEPARATOR=\n         ${obj_CHANNEL}   </managedObject>
       Add Element     ${scf_xml}     ${obj_CHANNEL}           xpath=.//cmData
   END


Create nrcell-3 And nrcell-4
    [Documentation]    [PRIVATE]    create nrcell-3 and nrcell-4
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object MRBTS-1/NRBTS-1/NRCELL-3
    ${nrcell-2}    Element To String     ${scf_xml}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-2"]
    ${nrcell-3}    Replace String    ${nrcell-2}   distName="MRBTS-1/NRBTS-1/NRCELL-2"     distName="MRBTS-1/NRBTS-1/NRCELL-3"
    Add Element        ${scf_xml}     ${nrcell-3}      xpath=.//cmData
    Log To Console    Building object MRBTS-1/NRBTS-1/NRCELL-4
    ${nrcell-4}    Replace String    ${nrcell-2}   distName="MRBTS-1/NRBTS-1/NRCELL-2"     distName="MRBTS-1/NRBTS-1/NRCELL-4"
    Add Element        ${scf_xml}     ${nrcell-4}      xpath=.//cmData
    Log To Console    Building object MRBTS-1/NRBTS-1/NRCELL-3/NRPMCCP_CELL-1
    ${obj_cell3}    Set Variable   <managedObject class="NRPMCCP_CELL" distName="MRBTS-1/NRBTS-1/NRCELL-3/NRPMCCP_CELL-1"
    ${obj_cell3}   Catenate     SEPARATOR=${SPACE}   ${obj_cell3}    version="${SCF.version}" operation="create"/>
    Add Element     ${scf_xml}     ${obj_cell3}           xpath=.//cmData
    Log To Console    Building object MRBTS-1/NRBTS-1/NRCELL-4/NRPMCCP_CELL-1
    ${obj_cell4}    Set Variable   <managedObject class="NRPMCCP_CELL" distName="MRBTS-1/NRBTS-1/NRCELL-4/NRPMCCP_CELL-1"
    ${obj_cell4}   Catenate     SEPARATOR=${SPACE}   ${obj_cell4}    version="${SCF.version}" operation="create"/>
    Add Element     ${scf_xml}     ${obj_cell4}           xpath=.//cmData


Create NRX2LINK_TRUST
    [Documentation]    [PRIVATE]    create NRX2LINK_TRUST object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRX2LINK_TRUST-257
    ${new_MO}   Set Variable   <managedObject class="NRX2LINK_TRUST" distName="${bts_distName}/NRX2LINK_TRUST-257"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
           ...    <p name="ipV4Addr">10.0.1.137</p>
           ...    <p name="x2LinkTrustCtrl">gnbControlled</p>
           ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData

