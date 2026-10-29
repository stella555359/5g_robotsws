*** Settings ***
Documentation
...   Author: rong.nie@nokia-sbell.com
...   Contact: rong.nie@nokia-sbell.com
...   Description: The user scenario related to AirPhone operation.


Suite Setup       Common Suite Setup For RRM
Suite Teardown    Common Suite Teardown For RRM

Test Timeout    600 minutes

Resource          ../../../Resources/Classical/RRM_Common_Resource.robot
Resource          CNI118106_KeyWord.robot
Library       taf.ccs.aashell           WITH NAME    cli

*** Variables ***
@{delete useless cell}
...    delete:MRBTS-1/NRBTS-1/NRCELL-2
...    delete:MRBTS-1/NRBTS-1/NRCELLGRP-1
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-1
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-2
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-3
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-4
...    delete:MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1
...    NRDU-1:refNrCellGroup=0
...    NRCELL:allowUnsuppBcOrBcs=accept unknown band combinations,accept unknown BCSs

@{PARAMS_IN_SCF}
...    MRBTS-1/NRBTS-1:actInterMeNBMobility=true
...    MRBTS-1/NRBTS-1/NRCELL-1:cellDepType=NSA
...    delete:NRCELL-1:trackingAreaDN

${UE_ID}    11
${INTER_MENB_HO_RRC_RECONF_SUCC}    M55128C00504
@{counters_origin}    ${INTER_MENB_HO_RRC_RECONF_SUCC}=0
@{counters_success}    ${INTER_MENB_HO_RRC_RECONF_SUCC}=1
@{counters_fail}    ${INTER_MENB_HO_RRC_RECONF_SUCC}=0
${SA_NSA_MODEL}    NSA
*** Test Cases ***
CNI118106 Setup NSA call
    [Tags]    QC_68462       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Aashell outputs show those internal counters which impact the result of admission control in CP-RT.
    ...    Purpose of this CNI to add those internal counters to Aashell outputs.
    [Setup]    Case Precondition for NSA call
#    Kill agate and start egate
    Nsa Attach Ue ${UE_ID}
    Get aashell command output
    UE Deregister From gNB    ue_id=${ue_id}
    Get aashell command output
    ${scf_id}=    Get SCF Internal Id By Scout    no_ute=False

*** Keywords ***
Kill agate and start egate
    OperatingSystem.Run    sudo pkill edaemon
    OperatingSystem.Run    sudo pkill egate
    Airphone Edaemon Egate Setup
    Airphone Cfg Configuration    wts_cfg_name=${CURDIR}/config/basic_setup_NSA.cfg
    Sleep    5s




