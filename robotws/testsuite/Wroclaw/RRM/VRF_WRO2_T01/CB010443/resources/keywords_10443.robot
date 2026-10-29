*** Settings ***
Documentation
...  Author:        Maciej Cupial, Adam Tokarski
...  Contact:       maciej.cupial@nokia.com, adam.tokarski@nokia.com
...  Feature owner: Karol Malutkiewicz, Witold Galka
...  Description:   Power Saving feature for 4G site, part 2
...                 Feature Corner:     https://feature-corner.nsn-net.net/materials/clchjwwcs374404xkzix2h4shg

Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common_kw.robot
Library         Collections
Library         String
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/AdminHelper.py    WITH NAME    ah
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/DeltaStore.py     WITH NAME    ds

Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/pcap_cplane.py
Library         pcap_cplane.pdml            WITH NAME   pdmlp
Library         taf.converters.pcaptopdml   WITH NAME   pcaptopdml
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/pcap_common.robot


*** Variables ***
${MRBTS_LTE_ID}          ${tl.enbs[0].instance_id}
${LTE_MPLANE}            ${tl.enbs[0].m.v4}
${MAIN_LTE_SCF_PATH}     MRBTS-${MRBTS_LTE_ID}/LNBTS-${MRBTS_LTE_ID}
${LTE_CONNECTION_ALIAS}  eNB


*** Keywords ***
Perform commissioning 10443 LTE
    [Documentation]
    ...    Performs delta commissioning for 10443 on LTE site

    [Arguments]
    ...    ${actLteNrDualConnectivity}=true
    ...    ${actLBPowerSaving}=true
    ...    ${actCoordinated4g5gPowerSaving}=disabled

    Log To Console  __Perform 10443 LTE commissioning

    ${lte_cells_ids}  Get LTE Cells Ids

    &{dict}    Create Dictionary    cellCapClass=100
    ...                             mlbEicicOperMode=allUes
    ...                             nomNumPrbNonGbr=1
    ...                             targetLoadGbrDl=50
    ...                             targetLoadNonGbrDl=75
    ...                             targetLoadPdcch=50
    ...                             ulCacIgnore=false
    ...                             ulCacSelection=ulReflectDlCac
    ...                             ulStaticCac=100

    ds.initialise_delta_store
    ds.add_param_to_delta   ${MAIN_LTE_SCF_PATH}   actLteNrDualConnectivity       value=${actLteNrDualConnectivity}
    ds.add_param_to_delta   ${MAIN_LTE_SCF_PATH}   actLBPowerSaving               value=${actLBPowerSaving}
    ds.add_param_to_delta   ${MAIN_LTE_SCF_PATH}   actCoordinated4g5gPowerSaving  value=${actCoordinated4g5gPowerSaving}

    FOR    ${cell_id}    IN    @{lte_cells_ids}
        ds.add_list_parameters_to_delta  ${MAIN_LTE_SCF_PATH}/LNCEL-${cell_id}   loadSettings    &{dict}
    END

    ${delta}       ds.collect_delta_store
    ah.recommission_with_delta_from_admin    ${delta}    connection=${LTE_CONNECTION_ALIAS}
    Verify If All Cells Are Onair


Activate 10443
    [Documentation]
    ...    Preforms delta commissioning with parameters which activates 10443 feature

    [Arguments]
    ...    ${actCoordinated4g5gPowerSaving}=cellDeactAndReact
    ...    ${tWaitNrAct}=500
    ...    ${actLBPowerSaving}=true
    ...    ${actLbpsCtrlLogicEnh}=true

    Log To Console    __Activate energy saving (CB010443)

    &{loadSettingsDict}  Create Dictionary  cellCapClass=100
    ...                                     mlbEicicOperMode=allUes
    ...                                     nomNumPrbNonGbr=5
    ...                                     targetLoadGbrDl=50
    ...                                     targetLoadNonGbrDl=75
    ...                                     targetLoadPdcch=50
    ...                                     ulCacIgnore=false
    ...                                     ulCacSelection=ulReflectDlCac
    ...                                     ulStaticCac=100

    ${lte_cells_ids}  Get LTE Cells Ids

    ds.initialise_delta_store

    FOR    ${cell_id}    IN    @{lte_cells_ids}
        ds.add_list_parameters_to_delta  ${MAIN_LTE_SCF_PATH}/LNCEL-${cell_id}   loadSettings    &{loadSettingsDict}
    END

    ds.add_param_to_delta   ${MAIN_LTE_SCF_PATH}   actCoordinated4g5gPowerSaving  value=${actCoordinated4g5gPowerSaving}
    ds.add_param_to_delta   ${MAIN_LTE_SCF_PATH}   tWaitNrAct                     value=${tWaitNrAct}
    ds.add_param_to_delta   ${MAIN_LTE_SCF_PATH}   actLBPowerSaving               value=${actLBPowerSaving}
    ds.add_param_to_delta   ${MAIN_LTE_SCF_PATH}   actLbpsCtrlLogicEnh            value=${actLbpsCtrlLogicEnh}
    ${delta}       ds.collect_delta_store
    ah.recommission_with_delta_from_admin    ${delta}    connection=${LTE_CONNECTION_ALIAS}
    Log To Console    __Wait for energy saving activation
    Verify If All Cells Are Onair


Deactivate 10443
    [Documentation]
    ...    Preforms delta commissioning with parameters which deactivates 10443 feature

    [Arguments]
    ...    ${actCoordinated4g5gPowerSaving}=disabled

    Log To Console    __Deactivate energy saving (CB010443)
    ds.initialise_delta_store
    ds.add_param_to_delta   ${MAIN_LTE_SCF_PATH}   actCoordinated4g5gPowerSaving  value=${actCoordinated4g5gPowerSaving}
    ${delta}       ds.collect_delta_store
    ah.recommission_with_delta_from_admin    ${delta}    connection=${LTE_CONNECTION_ALIAS}
    Log To Console    __Wait for energy saving deactivation
