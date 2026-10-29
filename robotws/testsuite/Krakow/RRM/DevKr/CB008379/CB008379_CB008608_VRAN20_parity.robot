*** Settings ***
Documentation
...      == COPYRIGHT ==
...         Nokia Networks
...
...      == INTRODUCTION ==
...         CB008379: GBR Services for SA
...
...      == TEST SET NAME ==
...         CB008379
...
...      == AUTHORS ==
...       - Dawid Krawczuk <dawid.krawczuk@nokia.com>
...       - Marek Kieltyka <marek.kieltyka@nokia.com>
...       - Michal Szymakowski <michal.szymakowski@nokia.com>
...
...      == MAINTAINER ==
...       - I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
...
...      == REFERENCES ==
...         CB008379 CFAM
...
...      == HISTORY ==
...         [23.06.2022] - Create VRAN2.0 parity test suite
...         [13.02.2023] - Switch to VRAN4.0 RANNIC
...         [23.11.2023] - Switch to VRAN4.0 Rinline2 Thor

Resource    ./resources/CB008379-common_keywords.robot
Resource    ./resources/CB008379-verify_imports.robot

Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_TDD    vDUCNF00    DISABLE_GENERATION
    ...    CLOUD_5GC_dRNIC_1vDU_P_AP_LO_SWFH
    ...    VARIANT_SANSA_FS_ECPRI_CMWV_TDD
    ...    PY39
#    ...    CONFIGS_Krakow/CB008379/VRAN20.yaml

Suite Setup    Run VRAN Setup
Suite Teardown  Run keywords
...             vcu_emss_teardown    AND
...             vdu_emss_teardown


#Suite Setup       Run Setup
#...  admission_control=${True}
#...  gbr_mixed_mode=${False}
#Suite Teardown    Run Keyword When Not In UTE    Restore maxGbrTrafficLimit=90%, maxNumOfGBRBearersSA=10, GFBR=6Mbps and MFBR=9Mbps for all 5QIs

*** Variables ***
${LUA_CFG}=                  ${CURDIR}/config/VRAN/SA_TDD_2c_1gNBSim_inter_freq.lua
${cu_suite_setup_delta}=     ${CURDIR}/config/VRAN/CU_NRADJGNB_NRDRB_NRPMQAP.json
${du_suite_setup_delta}=     ${CURDIR}/config/VRAN/DU_NRDRB_NRPMQAP.json



@{cu_yaml_paths_to_configure}=      ${disable_ciphering_yaml_path}
...                                 ${CURDIR}/config/yaml_config/NRPQMAP_CU.yaml
...                                 ${CURDIR}/config/yaml_config/GBR_CU.yaml
...                                 ${CURDIR}/config/yaml_config/NRCELL_CU.yaml
#...                                 ${CURDIR}/config/yaml_config/HO_CU.yaml

@{du_yaml_paths_to_configure}=      ${CURDIR}/config/yaml_config/NRPQMAP_DU.yaml
...                                 ${CURDIR}/config/yaml_config/GBR_DU.yaml
...                                 ${CURDIR}/config/yaml_config/NRCELL_DU.yaml


${SKIP_COUNTERS}=                   ${FALSE}
${wait_until_kw_succ_rep}           3x
${wait_until_kw_succ_time}          3s
${wait_until_resources_allocated}   20
${wait_until_resources_released}    40

&{maxGBRTrafficLimit_per_test}      E_a-4=10  # TDD UL
&{gfbr_per_test}                    E_a-4=6
${traffic_rate}                     5

*** Test Cases ***
CB008379-A-c_2_TDD ICS without PDU session then PDU sesssion setup and release - no SRB2 release
    [Tags]    A_c_2    GQC_PLAN:FEATURE:CB008608
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  ICS without session, Setup PDU session with nongbr, add gbr, then release session, SRB2 is not released,
    ...  PDU session setup with nongbr + GBR (SRB already present and not set-up)
    ...
    ...  == Precondition: ==
    ...  - gNB2 up and running with SA cell OnAir
    ...  - NRCELL-1.actNonVoNRGbrService = true
    ...  - NRCELL-1.maxNumOfGBRBearersSA = 10
    ...  - NRCELL-1.actCDrx = false
    ...  - NRCELL-1.actGBRAdmissionControl = 'GBRService'
    ...  - NRCELL-1.maxGBRTrafficLimit = 90%
    ...  == TESTING TOOLS ==
    ...  - AirPhone, 5GCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB VRAN4.0 BTS in SA mode
    ...  - HARDWARE ID: gNB(vCU OE22 + vDU RANNIC) with simulated AEQP radio module - NR_BAND: n78
    ...  == REQUIREMENTS COVERAGE ==
    ...  - 5G_L2_IF_560
    ...  == REQUIRED LOGS ==
    ...  NGAP, NR-RRC
    ...  == CONTACTS ==
    ...  Marek Kieltyka <marek.kieltyka@nokia.com>
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...  - USCB008379-A/B#B1: Successful setup of GBR Bearer with PDU Session Setup Request - Basic scenario
    ...  HISTORY:
    ...  [29.06.2022] - VRAN2.0 passed CB008608 - SW build: vCUCNF_0.250.5740;vDUCNF_0.300.6618
    ...  [08.02.2023] - VRAN4.0 passed CB009881 - SW build: vCUCNF23R2_0.250.10218;vDUCNF23R2_0.300.10914

    Omit when SKIP_COUNTERS present
    ...     Wait until CU PM counters file is ready and saved

    Run Keyword And Continue On Failure
    ...  Repeat ICS without PDU session then PDU sesssion setup and release - no SRB2 release for UE1 and 5QI2
    Run Keyword And Continue On Failure
    ...  Repeat ICS without PDU session then PDU sesssion setup and release - no SRB2 release for UE2 and 5QI3
    Run Keyword And Continue On Failure
    ...  Repeat ICS without PDU session then PDU sesssion setup and release - no SRB2 release for UE3 and 5QI4

    Run Keyword And Continue On Failure
    ...  Repeat ICS without PDU session then PDU sesssion setup and release - no SRB2 release for UE4 and 5QI71
    Run Keyword And Continue On Failure
    ...  Repeat ICS without PDU session then PDU sesssion setup and release - no SRB2 release for UE5 and 5QI72
    Run Keyword And Continue On Failure
    ...  Repeat ICS without PDU session then PDU sesssion setup and release - no SRB2 release for UE6 and 5QI76

    Omit when SKIP_COUNTERS present
    ...     Wait until CU PM counters file is ready and saved
    Omit when SKIP_COUNTERS present
    ...     Check VRAN counters NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0,QFI_SETUP_ATT 6,QFI_SETUP_SUCC 6,QFI_REL 6,QFI_REL_NORMAL 3
    Omit when SKIP_COUNTERS present
    ...     Check VRAN counters NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0,QFI_SETUP_ATT 6,QFI_SETUP_SUCC 6,QFI_REL 6,QFI_REL_NORMAL 3

    Run Keyword And Continue On Failure
    ...  Repeat ICS without PDU session then PDU sesssion setup and release - no SRB2 release for UE7 and 5QI128
    Run Keyword And Continue On Failure
    ...  Repeat ICS without PDU session then PDU sesssion setup and release - no SRB2 release for UE8 and 5QI212
    Run Keyword And Continue On Failure
    ...  Repeat ICS without PDU session then PDU sesssion setup and release - no SRB2 release for UE9 and 5QI254

    Omit when SKIP_COUNTERS present
    ...     Wait until CU PM counters file is ready and saved
    Omit when SKIP_COUNTERS present
    ...     Check VRAN counters NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0,QFI_SETUP_ATT 6,QFI_SETUP_SUCC 6,QFI_REL 6,QFI_REL_NORMAL 3
    Omit when SKIP_COUNTERS present
    ...     Check VRAN counters NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0,QFI_SETUP_ATT 6,QFI_SETUP_SUCC 6,QFI_REL 6,QFI_REL_NORMAL 3

#    TODO: verify NRPMQAP-1 QFI_SETUP_ATT [ 'No counter value right now for MRBTS-1/NRBTS-1/NRCELL-1/NRPMQAP-1' ]
#    Check VRAN counters NRPMQAP-1: AVE_NUMBER_OF_SA_RRC 0,QFI_SETUP_ATT 0,QFI_SETUP_SUCC 0,QFI_REL 0,QFI_REL_NORMAL 0
#    Check VRAN counters NRPMQAP-6: AVE_NUMBER_OF_SA_RRC 0,QFI_SETUP_ATT 0,QFI_SETUP_SUCC 0,QFI_REL 0,QFI_REL_NORMAL 0

    [Teardown]  Cleanup after test A_b-2

*** Keywords ***
Cleanup after test A_b-2
    Detach and kill UE1
    Detach and kill UE2
    Detach and kill UE3
    Detach and kill UE4
    Detach and kill UE5
    Detach and kill UE6
    Detach and kill UE7
    Detach and kill UE8
    Detach and kill UE9


Run VRAN Setup
    Log To Console    Setup started
    Setup VRAN devices aliases
    Run keyword and ignore error
    ...     vcu.Connect to  host=${vCU_admin}  port=443  username=Nemuadmin  password=Nokia@123  secure=True
    Run keyword and ignore error
    ...     vdu.Connect to  host=${vDU_admin}  port=443  username=Nemuadmin  password=Nokia@123  secure=True
    setup_vcu_emss
    setup_vdu_emss
    vcu_configure       ${cu_yaml_paths_to_configure}
    vdu_configure       ${du_yaml_paths_to_configure}
#    Send CU delta commissioning   input_filepath=${cu_suite_setup_delta}
#    Send DU delta commissioning   input_filepath=${du_suite_setup_delta}
    ${run_update}    get variable value      ${configure}    True     # do not ever change that line!
    Run Keyword if  "${run_update}" == "True"
    ...         Reach OnAir in VRAN with retries   lua_cfg=${LUA_CFG}
    Run Keyword if  "${run_update}" != "True"
    ...         Setup egate  egate_port=20000  alias=default
