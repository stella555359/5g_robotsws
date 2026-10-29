*** Settings ***

Resource    resources/CB008490-common_keywords.robot
Resource    resources/CB008490_setup_and_teardowns.robot
Resource    resources/CB008490-flows_with_sim_gNB.robot
Library     resources/CplaneOverloadSetter.py

Force Tags    CONFIGURED    CRT    PY39    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_LO_AP_LO
...    VARIANT_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup    Run setup    f1ap_gNBs=SN    sim_gNB=MN

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_3c_n257_simMN.lua
${SCF_gnb3_SN}=           Krakow/CB008490/scf_D_B301_SN_1xAWEUB.xml
${AP_XML}=                Krakow/CB008490/iphy_3cells_n257_1xAWEUB_simMN.xml
${SKIP_COUNTERS}=         ${TRUE}
${encryption}=            ${True}

*** Test Cases ***
CB008490-SR-MB-B501 SN gNB rejects SNodeAdditionRequest in overload state
    [Setup]    Prepare test environment CB008490-MB-501 on simMN

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm Before Test

    Perform CPLANE OVL activation via R&D mechanism    # on SN

    Attach UE1 and add initial PDU session to MN gNB NRCELL-1
    Set expected messages flows for SNodeAddition Reject for SN gNB3
    UE1 sends A4 measurement with target cells [2] for NR-DC PSCell addition with sim MN
    Verify expected messages flows for SNodeAddition Reject for SN gNB3
    Verify that SNodeAdditionRequestReject contains cause:misc:control-processing-overload for SN gNB3

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm After Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords
    ...  Check RTPM counter: NRCELL-1 IE_NRDC_MN_SNODE_REJ_OVL (M55116C00042) is equal 1

    [Teardown]    MB-401 cleanup


*** Keywords ***
Perform CPLANE OVL activation via R&D mechanism
    Set Overload High Threshold to 0
    Sleep  1

Perform CPLANE OVL deactivation via R&D mechanism
    Set Overload High Threshold to 40
    Sleep  1

Attach UE${ue_id:\d+} and add initial PDU session to MN gNB NRCELL-${cell_id:\d+}
    Attach UE${ue_id} without ICS to gNB2 cell${cell_id}
    Set expected messages flows for PDU session and A4 measurement configuration for UE${ue_id} and AMF1
    Add to UE${ue_id} initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE${ue_id} and AMF1
