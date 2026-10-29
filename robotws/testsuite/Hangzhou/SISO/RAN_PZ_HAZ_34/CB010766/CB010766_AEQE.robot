*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
#Test Setup           #SISO Coam Test Setup
#Test Teardown        #SISO Coam Test Teardown
Test Timeout         2h

Resource    Resource/CB010766_Common_KW.robot

Documentation
...    Author: Zhang Xuewen
...    Contact: xuewen.zhang@nokia-sbell.com
...    squad group:SG_05
...    Feature 'CB010766 RU Deep Sleep mode for mMIMO products' in SBTS24R1 program

Force Tags    RAN_5G_TDD    RAN_5G    SBTS00    STATE_SW_UPLOADED    PY310

*** Test Cases ***
[1]CB010766-SR-A_11 Configure time window for RU deep sleep (AEQE)
    [Tags]    1S-2CC-4D-4U   CRT_TRUNK    CLOUD_5G_CLASSICAL_SA_ASILL_ABIOB1_AEQE
    [Setup]    SISO Coam Test Setup
    Configure time window for RU deep sleep
    [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ...    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    ...    AND    SISO Coam Test Teardown

[1]CB010766-SR-A_17 Activate RU Deep Sleep Mode when the time window starts (AEQE)
    [Tags]    1S-2CC-4D-4U    CRT_TRUNK    CLOUD_5G_CLASSICAL_SA_ASILL_ABIOB1_AEQE
    [Setup]    SISO Coam Test Setup
    Activate RU Deep Sleep Mode when the time window starts
    [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ...    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    ...    AND    SISO Coam Test Teardown

[1]CB010766-SR-A_18 Awake RU from deep sleep when the time window ends (AEQE)
    [Tags]    1S-2CC-4D-4U    CRT_TRUNK    CLOUD_5G_CLASSICAL_SA_ASILL_ABIOB1_AEQE
    [Setup]    SISO Coam Test Setup
    Awake RU from deep sleep when the time window ends
    [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ...    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    ...    AND    SISO Coam Test Teardown

[1]CB010766-SR-A_16 Change RU deep sleep mode when time window is re-configured (AEQE)
    [Tags]    1S-2CC-4D-4U    CRT_TRUNK    CLOUD_5G_CLASSICAL_SA_ASILL_ABIOB1_AEQE
    [Setup]    SISO Coam Test Setup
    Change RU deep sleep mode when time window is re-configured
    [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ...    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    ...    AND    SISO Coam Test Teardown
