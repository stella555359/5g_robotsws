*** Settings ***
Documentation
...      == COPYRIGHT ==
...         Nokia Networks
...
...      == INTRODUCTION ==
...         This subfeature intruduces enhancement for measurement handling in MN
...
...      == TEST SET NAME ==
...      CB008490-D#B101 - Measurement handling in MN
...
...      == TESTING SPLIT ==
...      CB008490-D#B101 - Measurement handling in MN
...      CB008490-D#B201 - Interactions handling in MN
...      CB008490-D#B301 - Admission control in SN
...      CB008490-D#B401 - Security procedures in PSCell Addition (MN and SN)
...      CB008490-D#B501 - Data transmission
...
...      == TESTING SCOPE ==
...      CB008490-D#B101 - Measurement handling in MN
...      1. CB008490-SR-D-B101_1 SNode Addition after A4 measurement report with two PSCell candidate cells but only one is valid
...      2. CB008490-SR-D-B101_2 Deactivate A4 measurement upon supervisionTimer expiry with DRX enabled
...      3. CB008490-SR-D-B101_3 Modify RFSP via Downlink NAS Transport after A4 measurement installation
...
...      == CONTACTS ==
...         - Konrad Krzyzak        <konrad.krzyzak@nokia.com>
...         - Tomasz Pyrek          <tomasz.pyrek@nokia.com>
...         - Michal Szymakowski    <michal.szymakowski@nokia.com>
...         - Grzegorz Szymik       <grzegorz.szymik@nokia.com>
...         - Malgorzata Konior     <malgorzata.konior@nokia.com>
...
...      == MAINTAINER ==
...         - Malgorzata Konior     <malgorzata.konior@nokia.com>
...
...      == REFERENCES ==
...         CB008490 CFAM - https://gates.nsn-net.net/view/000271e7#o=868
...
...      == HISTORY ==
...      [26.02.2024] - Create Test Suite
...      [26.03.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=906091)
...      [17.06.2025] - add interaction with LBT28167
...      [20.07.2025] - remove LBT28167 RD flag - functionality merged to trunk

Resource    resources/CB008490-common_keywords.robot
Resource    resources/CB008490_setup_and_teardowns.robot

Force Tags    CONFIGURED    CRT    PY39    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_[LO][LO]_AP_[LOO]
...    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD

Suite Setup    Run setup    LBT28167=False

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_3c_n77_n261_n257_TDD_SA.cfg
${SCF_gnb2_MN}=           Krakow/CB008490/scf_D_B101_MN_GMC.xml
${SCF_gnb3_SN}=           Krakow/CB008490/scf_D_B101_SN.xml
${AP_XML}=                Krakow/CB008490/iphy_1cell_n78_3cells_n257_1xAWEUB.xml
&{NRCELL_ID_TO_PHYSCELL_ID}=  1=50  2=52  3=53  4=54

*** Test Cases ***
CB008490-SR-D-B101_1 SNode Addition after A4 measurement report with two PSCell candidate cells but only one is valid
    [Tags]
    [Documentation]
    ...  == DESCRIPTION ==
    ...  This user scenario describes:
    ...   - the gNB behavior for PSCell Addition upon receipt of one A4 measurement report with two NR-DC PSCell
    ...     candidate cells. In this case MN gNB ignores the reported cell which is NOT supported by UE for NR-DC setup;
    ...   - the gNB behavior for a UE when the A4 Supervision Timer expires. In this case MN DRX feature is enabled
    ...     on MN gNB (NRBTS.actCDRX is true) and UE supports DRX;
    ...   - how gNB identifies UEs as a FWA devices including dynamic reconfigurations. In this case UE RFSP index
    ...     is modified via Downlink NAS Transport message after UE attach to MN gNB and NR-DC A4 measurements
    ...     configuration. Modification do not impact UEs identification as FWA device and after A4 measurement
    ...     report PSCell Addition is successful.
    ...
    ...  == PRECONDITION ==
    ...  MN gNB and SN gNB configured according to CB008490-B common preconditions and CB008490-GA#B1, except:
    ...    MN configuration:
    ...     - NRBTS-2.actCDRX = true
    ...     - NRBTS-2.identifiedFwaUeList: 1
    ...     - NRCELL-1: band n77
    ...     - NRCELL-1.a4RetryTimer = 5
    ...    SN configuration:
    ...     - SN gNB hosts two NRDC Cells:
    ...          NRCELL-2: band n261, PCI = 52, nrCellIdentity = 49154
    ...          NRCELL-3: band n257, PCI = 53, nrCellIdentity = 49155
    ...     - NRCELL-2 and NRCELL-3 have overlapping coverage
    ...    UE1 configuration:
    ...     - UE supports DC-n77A-n261A and DC-n77A-n257A NR-DC band combinations;
    ...     - UE does not support NRCELL-2 as NR-DC PSCell candidate: cell bandwidth (100MHz) is not supported for
    ...         DC-n77A-n261A band combination;
    ...     - longDRX-Cycle: supported
    ...     - measAndMobParameters/measAndMobParameters-Common/independentGapConfig is not present
    ...     - set indexToRFSP to 1 via amf_ue_ics_param egate command
    ...
    ...  == POSTCONDITION ==
    ...    UE1 was successfully configured with NR-DC
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
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_23557; 5G_RAN_USR_RRM_23565; 5G_RAN_USR_RRM_23860
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC,NGAP,F1AP,E1AP
    ...
    ...  == CONTACTS ==
    ...  - Malgorzata Konior <malgorzata.konior@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...  - US CB008490-D#B3: Inter-gNB NR-DC PSCell Addition upon receipt of one A4 measurement report with NR-DC PSCell
    ...                     candidate cells of more than one adjacent gNBs - ALT3
    ...  - US CB008490-D#B6: Deactivate A4 upon supervisionTimer expiry - ALT1
    ...  - US CB008490-D#B21: FWA UEs identification in MN
    ...
    ...  == HISTORY ==
    ...      [26.02.2024] - Create Test Suite
    ...      [26.03.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=906091)
    ...      [17.06.2025] - add interaction with LBT28167

    [Setup]    Basic prepare

    Attach UE1 without ICS to gNB2 cell1
    Set expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1

    Set indexToRFSP for UE1 to 2 using DL NAS Transport message

    Set expected messages flows for A4 measurement release and DRX configuration for UE1, MN gNB2
    Verify expected messages flows for A4 measurement release and DRX configuration for UE1, MN gNB2

    Set expected messages flow for A4 measurements configuration after retryTimer expiry for UE1
    Verify expected messages flow for A4 measurements configuration after retryTimer expiry for UE1

    Set expected messages flows for SNodeAddition for SN gNB3
    Set expected messages flows for SNodeAddition for UE1, MN gNB2
    Set expected not failed messages flows for SNodeAddition for UE1, MN gNB2
    Set expected not failed messages flows for SNodeAddition for SN gNB3

    UE1 sends A4 measId=2 with CELL-2: rsrp1=85 rsrq1=31 and CELL-3: rsrp2=84 rsrq2=30

    Verify expected messages flows for SNodeAddition for SN gNB3
    Verify expected messages flows for SNodeAddition for UE1, MN gNB2
    Verify expected not failed messages flows for SNodeAddition for UE1, MN gNB2
    Verify expected not failed messages flows for SNodeAddition for SN gNB3
    Verify in SNodeAdditionRequest that candidateCellInfoListMN has 1 element, pci: 53 for SN gNB3
    Verify UEContextSetupResponse for SN gNB3 with CFRA

    [Teardown]    D-B101 cleanup

*** Keywords ***
Verify UEContextSetupResponse for SN gNB3 with CFRA
    Verify in UEContextSetupResponse that DUtoCURRCInformation contains CellGroupConfig with cellGroupId 1 for SN gNB3
    Verify in UEContextSetupResponse that cellGroupConfig contains rlc-BearerToAddModList and logicalChannelIdentity is 4 for SN gNB3
    Verify in UEContextSetupResponse that CellGroupConfig contains mac-CellGroupConfig and physicalCellGroupConfig SN gNB3
    Verify in UEContextSetupResponse that CellGroupConfig contains spCellConfig and servCellIndex is present for SN gNB3
    Verify in UEContextSetupResponse that CellGroupConfig contains spCellConfig contains spCellConfigCommon and physCellId is 53 for SN gNB3
    Verify in UEContextSetupResponse that iE-Extensions contains SelectedBandCombinationIndex and SelectedFeatureSetIndex is present for SN gNB3
    Verify in UEContextSetupResponse that DRBs-Setup-List has 1 element and dRBID is 4 for SN gNB3
    Verify in UEContextSetupResponse that DRBs-Setup-List contains dLUPTNL-Information-ToBeSetup-List dLUPTNLInformation is present for SN gNB3
    Verify that UEContextSetupResponse contains cellGroupConfig and cfra is present for SN gNB3
