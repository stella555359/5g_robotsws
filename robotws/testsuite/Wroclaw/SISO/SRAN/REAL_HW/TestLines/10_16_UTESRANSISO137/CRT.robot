
*** Settings ***
Documentation  Maintainers: @I_SRAN_PROD_SISO_WRO_CRTDEV_GMS

...  Test Suite Author: Boguslaw Trojnar
...  Test Suite Owner: Boguslaw Trojnar
...  Team: WRO3 7


Resource    ../../Resources/Setup/setup_and_teardown.robot
Resource    ../../robotlte_legacy/tc_scenarios.robot

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***
${CONFIGURATION_STARTUP_TIMEOUT}=    1000
${CUSTOM_LIVE_MODE_PRIMARY_NODE_IP}=    10.42.239.240

${CUSTOM_SWITCH_PERFORM_SNAPSHOT}=     Failed    # possible settings : Failed, Always, None
${CUSTOM_SWITCH_PERFORM_HW_SETUP}=     True     # to disable hardware reconfiguration ( PDU and Optical part ) set value False


#&{SM_VM_IP_ADDRESS_DICT}=
#...  L1230613867=10.42.239.240

${SKIP_TRUCK_ROLL}=   ${True}

# ${CELLS_YAML_PATH}=                 /home/ute/testline_configuration/10_16_UTESRANSISO137/cells.yaml
# ${UTE_UE_CONFIG}=                   /home/ute/testline_configuration/10_16_UTESRANSISO137/ute_ue_config.yml

# zmienna opcjonalna tworzona tylko je?li w ramach ca?ej TS pojawiaj? si? dodatkowe oczekiwane faulty na wszystkich BTSach
@{additional_common_fault_list}=
...  faultId=1911
...  faultId=4003
...  faultId=1300
...  faultId=4589

*** Test Cases ***

[AVQA][1.0] Automated__SiSo__FV_Testing_RF_Factory_SW_update
      [Setup]  Run Keywords
    ...  Configuration Precondition     CN=REF_10_16_UTESRANSISO137_HALFRACK     N=1
    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}    L1251403406  L1251403407
    ...  AND  Set Test Variable  ${FACTORYSW}  factory
    Execute Test In Loop  Incompatible Software Detection and Update
    [Teardown]  Configuration Postcondition
