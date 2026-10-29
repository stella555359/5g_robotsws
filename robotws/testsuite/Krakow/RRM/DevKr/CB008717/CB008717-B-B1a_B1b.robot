*** Settings ***
Documentation
...      == COPYRIGHT ==
...         Nokia Networks
...
...      == INTRODUCTION ==
...         This subfeature introduces successful establishment of MN terminated split bearer. One NR-DC-SN cell, that can
...         act as PSCell in NR-DC, is successfully activated. After Initial Context Setup/PDU Session Resource Setup, NR DC
...         establishment is attempted for NR DC eligible UEs, MN terminated Split Bearer Addition procedure is successfully
...         completed and Successful bearer type is changed from MCG to MN terminated split bearer.
...
...      == TEST SET NAME ==
...         CB008717-B Successful Blind PSCell Addition for a single UE after ICS having only non-GBR bearer with TDD PCell
...
...      == TESTING SPLIT==
...         CB008717-A NR-DC Cell Activation for a Secondary Node
...         CB008717-B Successful Blind PSCell Addition for UEs after ICS having only non-GBR bearers
...         CB008717-C UE Release due to AMF Context Release
...         CB008717-D Successful Blind PSCell Addition for UEs after ICS having only non-GBR bearers, additional content
...         CB008717-E UE Release without bearer takeback
...         CB008717-G Cell Management for Secondary Node
...         CB008717-H Configuration and Reception of A4 measurements
...         CB008717-I Successful Measurement based PSCell Addition
...         CB008717-J Interaction with event A4
...         CB008717-M Mobilty on PCell
...
...      == AUTHORS ==
...       - Konrad Krzyzak <konrad.krzyzak@nokia.com>
...       - Agnieszka Wlodarczyk <agnieszka.wlodarczyk@nokia.com>
...       - Karolina Sroczyk <karolina.sroczyk@nokia.com>
...
...      == MAINTAINER ==
...       - I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
...
...      == REFERENCES ==
...       - CB008717 CFAM
...
...      == HISTORY ==
...         [28.06.2022] - Create Test Suite
...         [29.06.2022] - Review by EFS
...         [28.04.2023] - Migration to new AP_LO

Resource    ./resources/CB008717-common_keywords.robot

Force Tags    CRT    RAN_5G    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_BOO_AP_LOO
    ...    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Suite Setup  Run Setup  ute-ca=True

*** Variables ***
${LUA_CFG}=                ${CURDIR}/config/common/2c_TDD_n78_FR2_n257_NRDC.lua
${SCFC}=                   ${CURDIR}/../../../../../custom-config/Krakow/CB008717/common/SCFC_FS_n78_n257.xml
${AP_XML}=                 ${CURDIR}/../../../../../custom-config/Krakow/CB008717/common/iphy_FS_2c_n78_n257.xml

*** Test Cases ***
CB008717-B-B1a-Successful_Blind_PSCell_Addition_for_UE_after_ICS_having_only_non-GBR_bearers_TDD
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  This test scenario describes establishment of MN terminated split bearer while UE-NR-Capability have only:
    ...     - one matching band combination,
    ...     - does not contain featureSetCombinationDC IEs
    ...     - is not stored in AMF.
    ...  In ICS, there is one PDU Session with one non-GBR QoS Flow and there is no mimo change in PCell.
    ...  == Precondition: ==
    ...     - rdNrDcDefaultPSCellLcrId is set to NRBTS/NRCELL-2.lcrId
    ...     - One FR1 cell (NRBTS/NRCELL-1) is active in pure SA mode of operation with enabled NR-DC
    ...     - One FR2 cell (NRBTS/NRCELL-2) is active in pure NR-DC-SN mode of operation
    ...  == TESTING TOOLS ==
    ...     - AirPhone, 5GCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...     - gNB classicBTS in SA mode
    ...     - HARDWARE ID:  gNB(ASIB + ABIO + ABIO)
    ...     - UE: Airphone AP_LO (ASIL + 2xABIO)
    ...  == REQUIREMENTS COVERAGE ==
    ...     5G_RAN_USR_RRM_15391
    ...  == REQUIRED LOGS ==
    ...     NGAP, F1AP, E1AP, RRC
    ...  == CONTACTS ==
    ...     Adrianna Zenczak <adrianna.zenczak@nokia.com>
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...         CB008717-5G-B1a Successful Blind PSCell Addition for a UE after ICS havig only non-GBR bearers
    ...  HISTORY:
    ...     [28.06.2022] - Create Test Case
    ...     [03.10.2022] - Test Case added to CRT after review
    ...     [28.04.2023] - Porting to AP_LO

    [Tags]   B_B1a-TDD

    [Setup]  Prepare test environment B_B1a

    Attach UE1 without ICS to gNB2 cell1

    Set expected messages flows for A4 measurement configuration for UE1, gNB2 and AMF1
#    Add to UE1 initial PDU session with ICS
    Exclude UECaps from ICS for UE1 and include indexToRFSP eq 87
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE1, gNB2 and AMF1

    Verify that AMF1 NGAP InitialContextSetup does not contain UERadioCapability
    Verify that UECapabilityEnquiry was completed successfully for UE1 and band:n78, band:n257
    Verify that AMF1 NGAP InitialContextSetup contains 1 PDU sessions
    Verify that in 2 out of 2 RRCReconfiguration measConfig relate to NRHOIF-1, band:257 and ssb:2071387 for UE1

    Set expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1
    UE1 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1
    Verify that in 1 out of 2 BearerCtxModReq PDUSessionID-1 with 1 DRB was success for gNB2 for SN context
    Verify that in 1 out of 2 BearerCtxModResp PDUSessionID-1 with 1 DRB was success for gNB2 for SN context
    Verify that UECtxSetupReq PDUSessionID-1 with 1 DRB was success for gNB2
    Verify that UECtxSetupResp PDUSessionID-1 with 1 DRB was success for gNB2

    Verify that in 2 out of 2 BearerCtxModReq PDUSessionID-1 with 1 DRB was success for gNB2 for MN context
    Verify that in 2 out of 2 BearerCtxModResp PDUSessionID-1 with 1 DRB was success for gNB2 for MN context
    Verify that in 1 out of 2 UECtxModReq was success for gNB2
    Verify that in 1 out of 2 UECtxModResp 2 MIMO in UL and 2 MIMO in DL for gNB2

    Verify that RRCReconfiguration was completed successfully for gNB2 and for UE1

    [Teardown]  Detach and kill UE1

CB008717-B-B1b_Blind_PSCell_Addition_multiple_BandCombination_MIMO_downgrade_and_upgrade
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  This test scenario describes establishment of MN terminated split bearer while UE-NR-Capability have only:
    ...     - one matching band combination,
    ...     - does not contain featureSetCombinationDC IEs
    ...     - is not stored in AMF.
    ...  In ICS, there is one PDU Session with one non-GBR QoS Flow and there is mimo change in PCell (downgrade - UE5, upgrade - UE6).
    ...  == Precondition: ==
    ...     - Same as CB008717-B-B1a
    ...     - UE5-NR-Capabilities along with MIMO layers couse MIMO upgrade
    ...     - UE6-NR-Capabilities along with MIMO layers couse MIMO upgrade
    ...  == TESTING TOOLS ==
    ...     - AirPhone, 5GCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...     - gNB classicBTS in SA mode
    ...     - HARDWARE ID:  gNB(ASIB + ABIO + ABIO)
    ...     - UE: Airphone AP_LO (ASIL + 2xABIO)
    ...  == REQUIREMENTS COVERAGE ==
    ...     5G_RAN_USR_RRM_15391
    ...  == REQUIRED LOGS ==
    ...     NGAP, F1AP, E1AP, RRC
    ...  == CONTACTS ==
    ...     Karolina Sroczyk <karolina.sroczyk@nokia.com>
    ...  == REFERENCES ==
    ...     CB008717 CFAM:
    ...         CB008717-5G-B1b Successful Blind PSCell Addition for a UE after ICS havig only non-GBR bearers
    ...  HISTORY:
    ...     [28.06.2022] - Create Test Case
    ...     [03.10.2022] - Test Case added to CRT after review
    ...     [28.04.2023] - Porting to AP_LO

    [Tags]  B_B1b

    [Setup]  Prepare test environment B_B1a

    Attach UE5 without ICS to gNB2 cell1
    Set expected messages flows for A4 measurement configuration for UE5, gNB2 and AMF1
#    Add to UE5 initial PDU session with ICS
    Add to UE5 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE5, gNB2 and AMF1
    Verify in 1 out of 2 RRCReconfiguration for UE5 that 2 MIMO in UL and 4 MIMO in DL
    Set expected messages flows for A4 measurement based PSCell addition for UE5, gNB2 and AMF1
    UE5 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition for UE5, gNB2 and AMF1
    Verify in UECtxSetupResp that servCellIndex 1, 2 MIMO in UL and 2 MIMO in DL for gNB2
    Verify in RRCReconfiguration that csi-ReportConfigToAddModList is present for UE5

    Attach UE6 without ICS to gNB2 cell1
    Set expected messages flows for A4 measurement configuration for UE6, gNB2 and AMF1
#    Add to UE6 initial PDU session with ICS
    Add to UE6 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE6, gNB2 and AMF1
#    Verify in 1 out of 2 RRCReconfiguration for UE6 that 2 MIMO in UL and 2 MIMO in DL
    Set expected messages flows for A4 measurement based PSCell addition for UE6, gNB2 and AMF1
    UE6 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition for UE6, gNB2 and AMF1
    Verify in UECtxSetupResp that servCellIndex 1, 2 MIMO in UL and 4 MIMO in DL for gNB2
    Verify in RRCReconfiguration that csi-ReportConfigToAddModList is present for UE6

    [Teardown]  Cleanup after test B-B1b
