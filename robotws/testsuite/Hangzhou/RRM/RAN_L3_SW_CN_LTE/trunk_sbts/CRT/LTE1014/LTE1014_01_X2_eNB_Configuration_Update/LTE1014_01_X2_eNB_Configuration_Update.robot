*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_TDD    CRT    CLOUD_R4LAPO_CUS
...               release-TL17    OAM2    owner-cathy.j.wang    owner-eric.jiang
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${AUTO_INITIAL_ENV_CONNECTION}    2b
@{PARAMS_IN_SCF}
...    delete:LNADJ.*
...    @{PARAMS_MME1}
...    @{X2_Link}
@{X2_Link}
...    LNADJ-1:cPlaneIpAddrCtrl=oamControlled
...    LNADJ-1:cPlaneIpAddr=10.0.1.31
...    LNADJ-1:adjEnbId=3
${phycellId_m}    13
@{PARAMS_MME1}
...    LNMME-0:administrativeState=unlocked
...    LNMME-0:ipAddrPrim=10.0.1.1

*** Test Cases ***
LTE1014_01_05 X2 eNB Configuration Update due to S1 Interface activation
    [Tags]    RAN_4G    RAN_4G_TDD    CDRT
    Online Commission ActS1Flex To Enabled
    Make One MME Support Two MME Pool Areas

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs    ue_count=1
    Create Enb Alias    alias=ENB_1    enb_id=1    id_type=wts
    Create Enb Alias    alias=ENB_2    enb_id=2    id_type=wts
    Create MME Alias    MME_1    mme_id=1    id_type=wts

Modify Yaml
    Add Yaml    EPC/MME_POOL_AREA
    ...    - id: 2
    ...      plmn: '262:04'
    ...      mmegi: 2
    ...      tac_list: 33
    Add Yaml    BASE_STATIONS
    ...    - id: 2
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1: 10.0.1.31
    ...      cells:
    ...      - {id: 21, technology: lte, tdd_cell: yes, duplex_mode: TDD, tac: 33, pci: '3:0', earfcn: '38000:38000', bw: 20}

Online Commission ActS1Flex To Enabled
    Delta Commission Parameters    LNBTS:actS1Flex=enabled

Make One MME Support Two MME Pool Areas
    # 262:03    262:Germany    03:E-Plus Mobilfunk GmbH & Co. KG
    Expect Message Flow
    ...    ENB_1:X2AP_ENBConfigurationUpdate (GUGroupIDList contains (pLMN-Identity eq "0x62F230" and mME-Group-ID eq "0x0002"))
    ...    ENB_2:X2AP_ENBConfigurationUpdateAcknowledge
    ...    alias=Flow   overall_timeout=20
    Execute Egate Command    mme_config_update pool=1:3 pool=2:4 relative_cap=2
    Flow Occurred As Expected    alias=Flow
