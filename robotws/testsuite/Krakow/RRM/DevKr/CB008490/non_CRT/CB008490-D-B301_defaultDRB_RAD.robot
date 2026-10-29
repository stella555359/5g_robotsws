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
...         1.	CB008490-SR-D-B301_2 Successful RAC in PSCell without default DRB selected in MN
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

*** Test Cases ***
CB008490-SR-D-B301_1 Successful RAC in PSCell and selection of not fully loaded NRDC cell
    [Tags]
    [Documentation]
    ...  == DESCRIPTION ==
    ...    Purpose of this test case is to verify SNodeAddition procedure when no default DRB was selected by MN gNB.
    ...
    ...  == PRECONDITION ==
    ...    Same as CB008490-SR-D-B301_1 but with RD flag rdDisableSDAPheaderSa set to true:
    ...     - 0x660008=1 set in swconfig.txt in MN gNB
    ...     - rdDisableSDAPheaderSa=True set in cp_ue.enb_conf.ini in MN gNB
    ...
    ...  == POSTCONDITION ==
    ...    NR-DC is established for UE1
    ...    Default DRB is not selected by SN gNB
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

    [Setup]    Prepare test environment CB008490-D-B301 RAD

    Attach UE1 and add initial PDU session to MN gNB NRCELL-1
    Add to UE1 PDU1 session QoS flows with 5QI from list [9] and delete QoS flows with 5QI from list [] via amf
    Set expected flows for SNodeAddition for UE1, MN gNB2, SN gNB3
    UE1 sends A4 measurement with id=1 and PCIs [52]
    Verify expected flows for SNodeAddition for UE1, MN gNB2, SN gNB3
    Verify sdap-Config for all DRBs

    [Teardown]    Basic cleanup


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
    ...    Verify in SNodeAdditionRequest and SNodeAdditionRequestAcknowledge sdap-Config for all DRBs    gnb=3    rdDisableSDAPheaderSa=${True}
    Run Keyword And Continue On Failure
    ...    Verify in BearerContextSetupRequest sdap-Config for all DRBs    gnb=3    rdDisableSDAPheaderSa=${True}
