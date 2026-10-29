*** Settings ***
Documentation
...      == COPYRIGHT ==
...         Nokia Networks
...
...      == INTRODUCTION ==
...      This sub-feature introduces additional scenarios during PSCell Addition.
...
...      == TEST SET NAME ==
...      CB008490-SR-D-B301 Admission Control (SN)
...
...      == TESTING SPLIT ==
...      CB008490-SR-D-B101 Measurement handling (MN)
...      CB008490-SR-D-B201 Interactions handling (MN)
...      CB008490-SR-D-B301 Admission Control (SN)
...      CB008490-SR-D-B401 Security procedures in PSCell Addition (MN and SN)
...      CB008490-SR-D-B501 Data Transmission
...
...      == TESTING SCOPE ==
...      CB008490-SR-D-B301 Admission Control (SN)
...         1.	CB008490-SR-D-B301_1 Successful RAC in PSCell and selection of not fully loaded NRDC cell
...         2.	CB008490-SR-D-B301_3 Unsuccessful PSCell Addition - RAC failed at gNB DU
...         3.	CB008490-SR-D-B301_4 PSCell Load Balancing - selected PSCell is not on A4 measurement list
...
...      == CONTACTS ==
...         - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...
...      == MAINTAINER ==
...         - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...
...      == REFERENCES ==
...         CB008490 CFAM - https://gates.nsn-net.net/view/00025ee1#o=8981&hlt
...
...      == HISTORY ==
...      [02.02.2024] - Create Test Suite
...      [12.03.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=905958)

Resource    ../resources/CB008490-common_keywords.robot
Resource    ../resources/CB008490_setup_and_teardowns.robot

Force Tags    CONFIGURED    CRT    PY39    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_[LO][LO]_AP_[LOO]
...    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD

Suite Setup    Run setup

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_4c_n78_n257_TDD_SA.cfg
${SCF_gnb2_MN}=           Krakow/CB008490/scf_D_B301_MN_1xAWEUB_GMC.xml
${SCF_gnb3_SN}=           Krakow/CB008490/scf_D_B301_SN_1xAWEUB.xml
${AP_XML}=                Krakow/CB008490/iphy_1cell_n78_3cells_n257_1xAWEUB.xml
&{USER_5QI_TO_EGATE_QOS_FLOW_ID}=  6=1  5=2  1=3  7=4  8=5  9=6  170=7
${yaml_B301_1}=           ${CURDIR}/config/yaml/B301_1.yaml
${yaml_B301_1_revert}=    ${CURDIR}/config/yaml/B301_1_default.yaml
${yaml_B301_4}=           ${CURDIR}/config/yaml/B301_4.yaml
${yaml_B301_4_revert}=    ${CURDIR}/config/yaml/B301_4_default.yaml

*** Test Cases ***
CB008490-SR-D-B301_1 Successful RAC in PSCell and selection of not fully loaded NRDC cell
    [Tags]
    [Documentation]
    ...  == DESCRIPTION ==
    ...    Purpose of this test case is to verify successful RAC in PSCell. When UE reports two NRDC Cells in A4 measurements and first one
    ...    is fully loaded (NRCELL.maxNumOfNrDcSnUsers or NRCELL.maxNumOfNrDcSnNonGBRBearers are at full capacity)
    ...    SN gNB select second one (if not fully loaded).
    ...
    ...  == PRECONDITION ==
    ...    MN gNB and SN gNB configured according to CB008490-B common preconditions and CB008490-GA#B1
    ...    SN gNB hosts three NRDC Cells (nrDcCell-1, nrDcCell-2, nrDcCell-3) on band n257 in the same cell group:
    ...     - nrDcCell-1 is NRCELL-2 with PCI = 52 and nrCellIdentity = 49154
    ...     - nrDcCell-2 is NRCELL-3 with PCI = 53 and nrCellIdentity = 49155
    ...     - nrDcCell-3 is NRCELL-4 with PCI = 54 and nrCellIdentity = 49156
    ...    RAC parameters are configured in SN gNB for:
    ...     - nrDcCell-1:
    ...      * NRCELL.maxNumOfNrDcSnUsers = default value
    ...      * NRCELL.maxNumOfNrDcSnNonGBRBearers = 2
    ...     - nrDcCell-2:
    ...      * NRCELL.maxNumOfNrDcSnUsers = 1
    ...      * NRCELL. maxNumOfSCellAlloc = 1
    ...      * NRCELL.maxNumOfNrDcSnNonGBRBearers = default value
    ...     - nrDcCell-3:
    ...      * NRCELL.maxNumOfNrDcSnUsers = default value
    ...      * NRCELL.maxNumOfNrDcSnNonGBRBearers = default value
    ...    RAC parameters are configured in SN gNB for cell group:
    ...     - NRCELLGRP.maxNumOfNrDcSnUsersCGRP = default value
    ...     - NRCELLGRP.maxNumOfNrDcSnNonGBRBearersCGRP = default value
    ...    Common RAC parameters are configured in SN gNB:
    ...     - NRCELL.maxNumOfUsersPerNRCell = default value
    ...     - NRDU.maxNumOfRrcConUEsPerDU = default value
    ...    PSCell load balancing is disabled in cells:
    ...     - NRCELL.ccLoadThreshold = 100 for all cells
    ...    UEs 1-3 are connected to MN gNB SA cell with A4 measurements for PSCell candidate NR frequency configured,
    ...    with PDU session eligible for NR-DC splitting with single splitable defaultDRB bearer
    ...
    ...  == POSTCONDITION ==
    ...    NR-DC is established for UEs 1-3
    ...    Same default DRB and  sdapHeader-UL are selected by SN gNB as was set earlier by MN gNB
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode as MN - gNB_MN
    ...  - gNB classical BTS in NR-DC-SN mode as SN - gNB_SN
    ...  - gNB module MN (ASIL + ABIO / ASIM + ABIP)
    ...  - gNB module SN (ASIL + ABIO / ASIM + ABIP)
    ...  - UE configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE:    5G_RAN_USR_RRM_23691
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC,NGAP,F1AP,E1AP
    ...
    ...  == CONTACTS ==
    ...  - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...  - US CB008490-D#B10: NR-DC PSCell RAC (successful admission)
    ...
    ...  == HISTORY ==
    ...    [02.02.2024] - Create Test Suite
    ...    [12.03.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=905958)

    [Setup]    Prepare test environment CB008490-D-B301_1

    Attach UE1 and add initial PDU session to MN gNB NRCELL-1
    Add to UE1 PDU1 session QoS flows with 5QI from list [8] and delete QoS flows with 5QI from list [] via amf
    Set expected flows for SNodeAddition for UE1, MN gNB2, SN gNB3
    UE1 sends A4 measurement with id=1 and PCIs [52]
    Verify expected flows for SNodeAddition for UE1, MN gNB2, SN gNB3
    Verify sdap-Config for all DRBs
    Verify that UEContextSetupRequest contains nRCellIdentity of PSCell NRCELL-2 for SN gNB3
    Verify in UEContextSetupRequest candidateCellInfoListMN for SN gNB3
    Verify in UEContextSetupResponse that CellGroupConfig contains spCellConfig contains spCellConfigCommon and physCellId is 52 for SN gNB3

    Attach UE2 and add initial PDU session to MN gNB NRCELL-1
    Set expected flows for SNodeAddition for UE2, MN gNB2, SN gNB3
    UE2 sends A4 measurement with id=1 and PCIs [52,53]
    Verify expected flows for SNodeAddition for UE2, MN gNB2, SN gNB3
    Verify that UEContextSetupRequest contains nRCellIdentity of PSCell NRCELL-3 for SN gNB3
    Verify in UEContextSetupRequest candidateCellInfoListMN for SN gNB3
    Verify in UEContextSetupResponse that CellGroupConfig contains spCellConfig contains spCellConfigCommon and physCellId is 53 for SN gNB3

    Attach UE3 and add initial PDU session to MN gNB NRCELL-1
    Set expected flows for SNodeAddition for UE3, MN gNB2, SN gNB3
    UE3 sends A4 measurement with id=1 and PCIs [52,53,54]
    Verify expected flows for SNodeAddition for UE3, MN gNB2, SN gNB3
    Verify that UEContextSetupRequest contains nRCellIdentity of PSCell NRCELL-4 for SN gNB3
    Verify in UEContextSetupRequest candidateCellInfoListMN for SN gNB3
    Verify in UEContextSetupResponse that CellGroupConfig contains spCellConfig contains spCellConfigCommon and physCellId is 54 for SN gNB3

    [Teardown]    Cleanup test environment CB008490-D-B301_1


CB008490-SR-D-B301_3 Unsuccessful PSCell Addition - RAC failed at gNB DU
    [Tags]
    [Documentation]
    ...  == DESCRIPTION ==
    ...    Purpose of this test case is to verify SN gNB behavior during SNodeAddition procedure after failed RAC at SN gNB DU.
    ...
    ...  == PRECONDITION ==
    ...    Same as CB008490-SR-D-B301_1 with following changes:
    ...     - All RAC parameters in SN gNB set do default values except NRBTS.NRDU.maxNumOfRrcConUEsPerDU = 1
    ...
    ...  == POSTCONDITION ==
    ...    NR-DC is not established for UE1
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode as MN - gNB_MN
    ...  - gNB classical BTS in NR-DC-SN mode as SN - gNB_SN
    ...  - gNB module MN (ASIL + ABIO / ASIM + ABIP)
    ...  - gNB module SN (ASIL + ABIO / ASIM + ABIP)
    ...  - UE configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE:    5G_RAN_USR_RRM_23695
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC,NGAP,F1AP,E1AP
    ...
    ...  == CONTACTS ==
    ...  - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...  - US CB008490-D#B10: NR-DC PSCell RAC (successful admission)
    ...
    ...  == HISTORY ==
    ...    [02.02.2024] - Create Test Suite
    ...    [12.03.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=905958)

    [Setup]    Prepare test environment CB008490-D-B301_3

    Attach UE2 and add initial PDU session to MN gNB NRCELL-1
    Set expected flows for SNodeAddition for UE2, MN gNB2, SN gNB3
    UE2 sends A4 measurement with id=1 and PCIs [53]
    Verify expected flows for SNodeAddition for UE2, MN gNB2, SN gNB3

    Attach UE1 and add initial PDU session to MN gNB NRCELL-1
    Set expected messages flows for SNodeAddition failed at DU for SN gNB3
    UE1 sends A4 measurement with id=1 and PCIs [52]
    Verify expected messages flows for SNodeAddition failed at DU for SN gNB3

    Verify that SNodeAdditionRequestReject contains cause:radioNetwork:no-radio-resources-available for SN gNB3
    Verify that UEContextSetupFailure contains cause:radioNetwork:no-radio-resources-available for SN gNB3
    Verify that E1AP:BearerContextReleaseCommand contains cause:radioNetwork:no-radio-resources-available for SN gNB3
    Verify that E1AP:BearerContextReleaseCommand has 3 IEs for SN gNB3
    Verify that E1AP:BearerContextReleaseComplete has 3 IEs for SN gNB3

    [Teardown]    Cleanup test environment CB008490-D-B301_3


CB008490-SR-D-B301_4 PSCell Load Balancing - selected PSCell is not on A4 measurement list
    [Tags]
    [Documentation]
    ...  == DESCRIPTION ==
    ...    Purpose of this test case is to verify SN gNB behavior during SNodeAddition procedure when
    ...    PSCell Load Balancing is enabled in concerned cell group
    ...
    ...  == PRECONDITION ==
    ...    Same as CB008490-SR-D-B301_1 with following changes:
    ...    - All RAC parameters in SN gNB set do default values except:
    ...     * NRCELL-2.maxNumOfNrDcSnUsers = 4
    ...     * NRCELL-3.maxNumOfNrDcSnUsers = 3
    ...     * NRCELL-4.maxNumOfNrDcSnUsers = 2
    ...    - PSCell load balancing is enabled in all cells in cell group by setting for all cells:
    ...     *NRCELL.ccLoadThreshold = 40
    ...    For each NRDC cell (nrDcCell-1, nrDcCell-2, nrDcCell-3) there is one UE with established NRDC
    ...    Load of nrDcCell-1 is below ccLoadThreshold (1/4 * 100% < 40%) and lower than nrDcCell-2
    ...    Load of nrDcCell-2 is below ccLoadThreshold (1/3 * 100% < 40%)
    ...    Load of nrDcCell-3 is above ccLoadThreshold (1/2 * 100% > 40%)
    ...
    ...  == POSTCONDITION ==
    ...    NR-DC is established for UE1
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode as MN - gNB_MN
    ...  - gNB classical BTS in NR-DC-SN mode as SN - gNB_SN
    ...  - gNB module MN (ASIL + ABIO / ASIM + ABIP)
    ...  - gNB module SN (ASIL + ABIO / ASIM + ABIP)
    ...  - UE configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE:    5G_RAN_USR_RRM_23696
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC,NGAP,F1AP,E1AP
    ...
    ...  == CONTACTS ==
    ...  - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...  - US CB008490-D#B10: NR-DC PSCell RAC (successful admission)
    ...
    ...  == HISTORY ==
    ...    [02.02.2024] - Create Test Suite
    ...    [12.03.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=905958)

    [Setup]    Prepare test environment CB008490-D-B301_4

    Attach UE2 and add initial PDU session to MN gNB NRCELL-1
    Set expected flows for SNodeAddition for UE2, MN gNB2, SN gNB3
    UE2 sends A4 measurement with id=1 and PCIs [52]
    Verify expected flows for SNodeAddition for UE2, MN gNB2, SN gNB3

    Attach UE3 and add initial PDU session to MN gNB NRCELL-1
    Set expected flows for SNodeAddition for UE3, MN gNB2, SN gNB3
    UE3 sends A4 measurement with id=1 and PCIs [53]
    Verify expected flows for SNodeAddition for UE3, MN gNB2, SN gNB3

    Attach UE4 and add initial PDU session to MN gNB NRCELL-1
    Set expected flows for SNodeAddition for UE4, MN gNB2, SN gNB3
    UE4 sends A4 measurement with id=1 and PCIs [54]
    Verify expected flows for SNodeAddition for UE4, MN gNB2, SN gNB3

    Attach UE1 and add initial PDU session to MN gNB NRCELL-1
    Set expected flows for SNodeAddition for UE1, MN gNB2, SN gNB3
    UE1 sends A4 measurement with id=1 and PCIs [54]
    Verify expected flows for SNodeAddition for UE1, MN gNB2, SN gNB3
    Verify that UEContextSetupRequest contains nRCellIdentity of PSCell NRCELL-2 for SN gNB3
    Verify in UEContextSetupRequest candidateCellInfoListMN for SN gNB3
    Verify in UEContextSetupResponse that CellGroupConfig contains spCellConfig contains spCellConfigCommon and physCellId is 52 for SN gNB3

    [Teardown]    Cleanup test environment CB008490-D-B301_4


*** Keywords ***
Attach UE${ue_id:\d+} and add initial PDU session to MN gNB NRCELL-${cell_id:\d+}
    Attach UE${ue_id} without ICS to gNB2 cell${cell_id}
    Set expected messages flows for PDU session and A4 measurement configuration for UE${ue_id} and AMF1
    Add to UE${ue_id} initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE${ue_id} and AMF1

Set expected flows for SNodeAddition for UE${ue_id:\d+}, MN gNB${mn_id:\d+}, SN gNB${sn_id:\d+}
    Set expected messages flows for SNodeAddition for SN gNB${sn_id}
    Set expected messages flows for SNodeAddition for UE${ue_id}, MN gNB${mn_id}
    Set expected not failed messages flows for SNodeAddition for UE${ue_id}, MN gNB${mn_id}
    Set expected not failed messages flows for SNodeAddition for SN gNB${sn_id}

Verify expected flows for SNodeAddition for UE${ue_id:\d+}, MN gNB${mn_id:\d+}, SN gNB${sn_id:\d+}
    Verify expected messages flows for SNodeAddition for SN gNB${sn_id}
    Verify expected messages flows for SNodeAddition for UE${ue_id}, MN gNB${mn_id}
    Verify expected not failed messages flows for SNodeAddition for UE${ue_id}, MN gNB${mn_id}
    Verify expected not failed messages flows for SNodeAddition for SN gNB${sn_id}

Verify sdap-Config for all DRBs
    Run Keyword And Continue On Failure
    ...    Verify in SNodeAdditionRequest and SNodeAdditionRequestAcknowledge sdap-Config for all DRBs    gnb=3    rdDisableSDAPheaderSa=${False}
    Run Keyword And Continue On Failure
    ...    Verify in BearerContextSetupRequest sdap-Config for all DRBs    gnb=3    rdDisableSDAPheaderSa=${False}
