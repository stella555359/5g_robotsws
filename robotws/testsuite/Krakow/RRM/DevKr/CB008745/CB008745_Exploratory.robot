*** Settings ***
Documentation
...      == COPYRIGHT ==
...         Nokia Networks
...
...      == INTRODUCTION ==
...         CB008745 is impacting both 4G and 5G
...         In 5G CB008745 introduces new parameters for configuring the monitoring window of 5G Cell switching
...         CB008745 introduces PSG control logic improvement, so that cells are switch on/off in more flexible and accurate way
...         - Extend and support new method of load quantity calculation
...         - Extend and support new triggering rule of Cell switch on/off
...
...      == TEST SET NAME ==
...         4G/5G Cell Switch OFF & 4G MIMO Muting Responsiveness Improvements
...
...      == TESTING SPLIT ==
...         CB008745-B PSG control logic improvement in 5G for Cell Swtich off/on
...
...      == CONTACTS ==
...       - Maciej Madej <maciej.madej@nokia.com>
...       - Paulina Jedras <paulina.jedras@nokia.com>
...
...      == MAINTAINER ==
...       - I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
...
...      == REFERENCES ==
...         CB008745 CFAM
...
...      == HISTORY ==
...         [13.02.2023] - TC Create

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4    SKIPRUN
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Resource    ./resources/CB008745-common_keywords.robot
Library     ute_syslog
Library     ./resources/verify_syslog.py

Suite Setup  Run Keywords
...  Run Setup
...  AND  Create default NRPGRP-1 with cell1 and cell2


Suite Teardown  Teardown connection to admin  ${ADMIN_CONNECTION}

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_2c_TDD_SANSA.lua
${SKIP_COUNTERS}=         ${TRUE}
&{5QI_TO_EGATE_QOS_FLOW_ID}=  1=1  2=2  3=3  4=4  71=5  72=6  76=7  128=8  212=9  254=10  5=11  6=12  7=13  8=14  9=15  170=16
@{GBR_5QI}=  1  2  3  4  71  72  76  128  212
${GBR_traffic_rate}  100
${nGBR_traffic_rate}  50
${GNB_ip}             192.168.255.126

*** Test Cases ***
Exploratory_1 Check GBR and nGBR load reported for energy saving purpose - AdmissionControll off
    [Tags]    E_1
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...  Test verifies that GBR and nGBR traffic load for energy saving purpose is correctly distinguished
    ...   and reported from L2 to L3. In test case average load from latest 10s in syslog is verified.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - UE_1 - Airphone simulator configured for SA mode
    ...  - gNB2 up and running with 2 SA cells
    ...  - NRCELL-1, NRCELL-2 are up
    ...  - NRPGRP-1 is created
    ...  - NRPGRP-1.lbpsSOMethod = cell switch off
    ...  - NRPGRP-1.lbpsCellList = {
    ...       {
    ...       - lbpsCellSOOrder = 1
    ...       - nrCellId = 1
    ...       }
    ...       {
    ...       - lbpsCellSOOrder = 2
    ...       - nrCellId = 2
    ...       }
    ...    }
    ...  - NRBTS.actNrLBPowerSaving = True (5GC000431)
    ...  - NRBTS.actLbpsCtrlLogicEnh = True (CB008745)
    ...  - NRCELL-2.actGBRAdmissionControl = off
    ...  - NRCELL-2.actEnhancedVoNR = False
    ...  - NRCELL-2.actNonVonrGBRService = True
    ...
    ...  == Postconditions ==
    ...  With each set of attached UEs with traffic, reported load is distincted as GBR or nGBR
    ...  It can be manually checked, that for each 5QI it is +/- on the the same level
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with two simulated AEQE radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE:
    ...
    ...  == REQUIRED LOGS ==
    ...    gNB Syslog
    ...
    ...  == CONTACTS ==
    ...   - Paulina Jedras <paulina.jedras@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     CB008745 CFAM
    ...
    ...  == HISTORY ==
    ...     [13.02.2023] - TC Create

    [Setup]  Prepare test environment Exploratory_1

    Set test variable  ${CB008745}  True

    Log  ${\n} *** CB008745 ON, Traffic on each 5QI + always nGBR on 5QI5 ***  console=True
    Verify traffic for 5QI5 and each of 5QIs[1,2,3,4,71,72,76,128,170,212] separately - use UEs[1,2,3] on cell2

    Log  ${\n} *** CB008745 ON, Traffic on each 5QI separately ***  console=True
    Verify traffic for each of 5QIs[1,2,3,4,5,71,72,76,128,170,212] separately - use UEs[1,2,3] on cell2

    Deactivate CB008745 feature flag
    Set test variable  ${CB008745}  False

    Log  ${\n} *** CB008745 OFF, Traffic on each 5QI separately ***  console=True
    Verify traffic for each of 5QIs[1,2,3,4,5,71,72,76,128,170,212] separately - use UEs[1,2,3] on cell2

    [Teardown]  Detach and kill UEs from 1 to 20

Exploratory_2 Check GBR and nGBR load reported for energy saving purpose - AdmissionControll EnhancedVoNR
    [Tags]    E_2
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...  Test verifies that GBR and nGBR traffic load for energy saving purpose is correctly distinguished
    ...   and reported from L2 to L3. In test case average load from latest 10s in syslog is verified.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - UE_1 - Airphone simulator configured for SA mode
    ...  - gNB2 up and running with 2 SA cells
    ...  - NRCELL-1, NRCELL-2 are up
    ...  - NRPGRP-1 is created
    ...  - NRPGRP-1.lbpsSOMethod = cell switch off
    ...  - NRPGRP-1.lbpsCellList = {
    ...       {
    ...       - lbpsCellSOOrder = 1
    ...       - nrCellId = 1
    ...       }
    ...       {
    ...       - lbpsCellSOOrder = 2
    ...       - nrCellId = 2
    ...       }
    ...    }
    ...  - NRBTS.actNrLBPowerSaving = True (5GC000431)
    ...  - NRBTS.actLbpsCtrlLogicEnh = True (CB008745)
    ...  - NRCELL-2.actGBRAdmissionControl = EnhancedVoNR
    ...  - NRCELL-2.actEnhancedVoNR = True
    ...  - NRCELL-2.actNonVonrGBRService = False
    ...
    ...  == Postconditions ==
    ...  With each set of attached UEs with traffic, reported load is distincted as GBR or nGBR
    ...  It can be manually checked, that for each 5QI it is +/- on the the same level
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with two simulated AEQE radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE:
    ...
    ...  == REQUIRED LOGS ==
    ...    gNB Syslog
    ...
    ...  == CONTACTS ==
    ...   - Paulina Jedras <paulina.jedras@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     CB008745 CFAM
    ...
    ...  == HISTORY ==
    ...     [13.02.2023] - TC Create

    [Setup]  Prepare test environment Exploratory_2

    Set test variable  ${CB008745}  True

    Log  ${\n} *** CB008745 ON, Traffic on 5QI1 + nGBR on 5QI5 ***  console=True
#    Log to console  ${\n} *** CB008745 ON, Traffic on each 5QI + always nGBR on 5QI5 ***
    Verify traffic for 5QI5 and each of 5QIs[1] separately - use UEs[1,2,3] on cell2

    Log  ${\n} *** CB008745 ON, Traffic on 5QI1 ***  console=True
    Verify traffic for each of 5QIs[1] separately - use UEs[1,2,3] on cell2

    Deactivate CB008745 feature flag
    Set test variable  ${CB008745}  False

    Log  ${\n} *** CB008745 OFF, Traffic on 5QI1 ***  console=True
    Verify traffic for each of 5QIs[1] separately - use UEs[1,2,3] on cell2

    [Teardown]  Detach and kill UEs from 1 to 20

Exploratory_3 Check GBR and nGBR load reported for energy saving purpose - AdmissionControll GBRService
    [Tags]    E_3
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...  Test verifies that GBR and nGBR traffic load for energy saving purpose is correctly distinguished
    ...   and reported from L2 to L3. In test case average load from latest 10s in syslog is verified.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - UE_1 - Airphone simulator configured for SA mode
    ...  - gNB2 up and running with 2 SA cells
    ...  - NRCELL-1, NRCELL-2 are up
    ...  - NRPGRP-1 is created
    ...  - NRPGRP-1.lbpsSOMethod = cell switch off
    ...  - NRPGRP-1.lbpsCellList = {
    ...       {
    ...       - lbpsCellSOOrder = 1
    ...       - nrCellId = 1
    ...       }
    ...       {
    ...       - lbpsCellSOOrder = 2
    ...       - nrCellId = 2
    ...       }
    ...    }
    ...  - NRBTS.actNrLBPowerSaving = True (5GC000431)
    ...  - NRBTS.actLbpsCtrlLogicEnh = True (CB008745)
    ...  - NRCELL-2.actGBRAdmissionControl = GBRService
    ...  - NRCELL-2.actEnhancedVoNR = False
    ...  - NRCELL-2.actNonVonrGBRService = True
    ...
    ...  == Postconditions ==
    ...  With each set of attached UEs with traffic, reported load is distincted as GBR or nGBR
    ...  It can be manually checked, that for each 5QI it is +/- on the the same level
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with two simulated AEQE radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE:
    ...
    ...  == REQUIRED LOGS ==
    ...    gNB Syslog
    ...
    ...  == CONTACTS ==
    ...   - Paulina Jedras <paulina.jedras@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     CB008745 CFAM
    ...
    ...  == HISTORY ==
    ...     [13.02.2023] - TC Create

    [Setup]  Prepare test environment Exploratory_3

    Set test variable  ${CB008745}  True

    Log  ${\n} *** CB008745 ON, Traffic on each 5QI + always nGBR on 5QI5 ***  console=True
    Verify traffic for 5QI5 and each of 5QIs[1,2,3,4,71,72,76,128,170,212] separately - use UEs[1,2,3] on cell2

    Log  ${\n} *** CB008745 ON, Traffic on each 5QI separately ***  console=True
    Verify traffic for each of 5QIs[1,2,3,4,5,71,72,76,128,170,212] separately - use UEs[1,2,3] on cell2

    Deactivate CB008745 feature flag
    Set test variable  ${CB008745}  False

    Log  ${\n} *** CB008745 OFF, Traffic on each 5QI separately ***  console=True
    Verify traffic for each of 5QIs[1,2,3,4,5,71,72,76,128,170,212] separately - use UEs[1,2,3] on cell2

    [Teardown]  Detach and kill UEs from 1 to 20

*** Keywords ***
Create default NRPGRP-1 with cell1 and cell2
    Set NRPGRP-1 parameters
    Configure  ${1_NRPGRP_2_cells}  node_id=1

Prepare test environment Exploratory_1
    Set test variable  ${AdmCon}  off
    Set test variable  ${EnhVoNR}  False
    Set test variable  ${CB008379}  True
    Basic setup for exploratory TC

Prepare test environment Exploratory_2
    Set test variable  ${AdmCon}  EnhancedVoNR
    Set test variable  ${EnhVoNR}  True
    Set test variable  ${CB008379}  False
    Basic setup for exploratory TC

Prepare test environment Exploratory_3
    Set test variable  ${AdmCon}  GBRService
    Set test variable  ${EnhVoNR}  False
    Set test variable  ${CB008379}  True
    Basic setup for exploratory TC

Basic setup for exploratory TC
    ${GBR_related_features}  catenate    {'MOC': 'NRCELL', 'actGBRAdmissionControl': '${AdmCon}', 'actEnhancedVoNR': '${EnhVoNR}',
    ...                                                    'actNonVonrGBRService': '${CB008379}'}
    Configure  [${GBR_related_features}]
    Activate 5GC000431 and CB008745 feature flags

Verify traffic for each of 5QIs[${5QIs}] separately - use UEs[${UEs}] on cell${cell_id:\d+}
    Set test variable  ${additional_5QI5_traffic}  False
    @{5QI_list}=   Split To List   ${5QIs}
    FOR   ${5qi_id}  IN  @{5QI_list}
#        start collecting syslog  prefix=5QI${5qi_id}
        Run Keyword And Continue On Failure
        ...     Attach UEs[${UEs}] to gNB2 cell${cell_id} with 1 non-GBR and 1 GBR 5QI${5qi_id} bearer
        Run Keyword And Continue On Failure
        ...     Run ${GBR_traffic_rate}Mbps DL traffic on UEs[${UEs}] GBR bearer
        Sleep  30s  Wait for high traffic stabilization
#        stop collecting syslog

        Run Keyword And Continue On Failure
        ...     Collect syslog and print current load on cell${cell_id} for 5QI${5qi_id}

        Detach UEs[${UEs}]
    END

Verify traffic for 5QI5 and each of 5QIs[${5QIs}] separately - use UEs[${UEs}] on cell${cell_id:\d+}
    Set test variable  ${additional_5QI5_traffic}  True
    @{5QI_list}=   Split To List   ${5QIs}
    FOR   ${5qi_id}  IN  @{5QI_list}
        # In case of issues uncomment below KWs to collect additional syslog and observe how load measurements are
        # increasing from the moment of syslog start to the moment of traffic stabilization
#        start collecting syslog  prefix=5QI${5qi_id}
        Run Keyword And Continue On Failure
        ...     Attach UEs[${UEs}] to gNB2 cell${cell_id} with 1 non-GBR and 1 GBR 5QI${5qi_id} bearer
        Run Keyword And Continue On Failure
        ...     Run ${GBR_traffic_rate}Mbps DL traffic on UEs[${UEs}] GBR bearer
        Run Keyword And Continue On Failure
        ...     Run ${GBR_traffic_rate}Mbps DL traffic on UEs[${UEs}] non-GBR bearer
        Sleep  30s  Wait for high traffic stabilization
#        stop collecting syslog

        Run Keyword And Continue On Failure
        ...     Collect syslog and print current load on cell${cell_id} for 5QI${5qi_id}

        Detach UEs[${UEs}]
    END

Collect syslog and print current load on cell${cell_id:\d+} for 5QI${5qi_id:\d+}
    Run Keyword if    '${5qi_id}' in ${GBR_5QI} and ${CB008745}==True and ${additional_5QI5_traffic}==False
    ...               Set test variable  ${traffic_type}  GBR
    ...    ELSE IF    '${5qi_id}' in ${GBR_5QI} and ${CB008745}==True and ${additional_5QI5_traffic}==True
    ...               Set test variable  ${traffic_type}  GBR+nGBR
    ...    ELSE IF    '${5qi_id}' not in ${GBR_5QI} and ${CB008745}==True
    ...               Set test variable  ${traffic_type}  nGBR
    ...    ELSE IF    ${CB008745} == False
    ...               Set test variable  ${traffic_type}  CB008745_OFF

    Set test variable  ${cell_config}   AdmCon_${AdmCon}_EnhVoNR_${EnhVoNR}_CB008379_${CB008379}_${traffic_type}
    ute_syslog.Start Syslog
    ...    log_dir=${OUTPUT_DIR}
    ...    log_name=${cell_config}
    ...    ip=${GNB_ip}
    ...    alias=${cell_config}
    Sleep  12s  Wait for at least one print with current cell load for energy saving purpose in syslog
    ute_syslog.Stop Syslog  alias=${cell_config}

    ${nrCellIdentity}=  Evaluate  16384 + ${cell_id}
    Log to console  ${\n}Load measurement for 5QI${5qi_id}
    verify_energy_saving_measurement  ${nrCellIdentity}  ${traffic_type}  gnb_syslog=${OUTPUT_DIR}/${cell_config}
