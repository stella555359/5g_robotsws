*** Settings ***
Documentation
...   author: Piotr Korczynski
...   contact: piotr.korczynski@nokia.com
...   developer version of testsuite


Resource    ../../Resources/Setup/setup_and_teardown.robot
#Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/robotlte_legacy/tc_scenarios.robot



Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition
*** Variables ***

#${CUSTOM_SWITCH_PERFORM_SNAPSHOT}=            Failed      # possible settings : Failed, Always, None
#${CUSTOM_SWITCH_PERFORM_HW_SETUP}=            True     # to disable hardware reconfiguration ( PDU and Optical part ) set value False

#${CUSTOM_LIVE_MODE_PRIMARY_NODE_IP}=    10.42.165.45
#@{CUSTOM_LIVE_MODE_AUXILLARY_NODES_IPS_LIST}=


#${CUSTOM_MPLANE_MODE_PRIMARY_NODE_IP}=    10.42.106.133
#@{CUSTOM_MPLANE_MODE_AUXILLARY_NODES_IPS_LIST}=
#
#${CUSTOM_FILE_MODE_MASTER_NODE_IP}
#@{CUSTOM_FILE_MODE_AUXILLARY_NODES_IPS_LIST}
#
#${CUSTOM_MANUAL_MODE_SCF_PATH}=   /home/ute/scf_files/

#
#&{SM_VM_IP_ADDRESS_DICT}=
#...  L1173212304=10.42.165.45
#...  L1173212320=10.42.164.97
#...  L9876456=10.44.55.88
#
#&{CUSTOM_PDU_CONFIG}=
#...  L1141527943=Aten,,10.42.51.180,4
#...  L123456=APC,default,10.44.11.11,1
#...  L123456=APC,default,10.44.11.11,1
#...  L123456=APC,default,10.44.11.11,1

#
#
#&{CLOUD_RF_AILR_B1-3_B4-5_UTE_SRAN_SISO_CRT_035}=
#...   OS=192.168.255.222:1-2,2-1,3-1,4-1,5-1|192.168.255.33:1-2,2-1,3-1,4-1,5-1

${ENABLE_TRUCK_ROLL_FLAG}    ${False}
@{additional_common_fault_list}=
...  faultId=2403
...  faultId=1898
...  faultId=4261
...  faultId=4003

&{CUSTOM_ADDITIONAL_ALLOWED_FAULTS}=   common=@{additional_common_fault_list}

&{10_16_UTESRANSISO115_DEFAULT}=       OS=192.168.255.555:1-1,2-1,3-1,4-1,5-1
&{CB007779_SYNC_DOWN}=              F7172128018=1:1-1,2-1,3-2,4-1,5-1
&{CB007779_DATA_DOWN}=              F7172128018=1:1-1,2-1,3-1,4-2,5-1
&{OPTICAL_SWITCH_ALT_CONF}=         6Q192920560=1:1-2,2-2,3-1,4-1,5-1
&{OS_ALT_CONF_FHS_SYNC_FH1}=        6Q192920560=1:1-2,2-1,3-1,4-1,5-1
&{OS_ALT_CONF_FHS_SYNC_FH2}=        6Q192920560=1:1-1,2-2,3-1,4-1,5-1

@{FHS_SNs}=    6Q202207370

*** Test Cases ***

Test Case 1
  test 1
#[1][1.0] Automated__SiSo__BTS_Block_Unblock_without_call
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}     600
#    ...  AND  Set Test Variable  ${CUSTOM_EXPECTED_SITE_RESET_TIME}     350
#    Execute Test In Loop  Execute Block BTS On Every Node
#    [Teardown]  Configuration Postcondition


*** Keywords ***
test 1
  Find Init Object Using Attribute Value  ${TL}  L6141629878
  Find Init Object Using Attribute Value  ${TL}  6Q191322004

