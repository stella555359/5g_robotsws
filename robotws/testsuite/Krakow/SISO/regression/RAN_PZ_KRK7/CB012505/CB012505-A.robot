*** Settings ***
Documentation
...   author:
...    - Mateusz Matusik (mateusz.matusik@nokia.com)

Resource   ./resources/CB012505_keywords.robot


Suite Setup    Custom Suite Setup
Suite Teardown    Common Suite Teardown

*** Variables ***
${SOURCE_SW}           ${None}
${TARGET_SW}           ${None}
@{CUSTOMERS_LIST}      ${None}
@{CUSTOM_ALARMS}       61648    7115    4420    4123    4125    8150    4694    6450    4479

${MRBTS_ID1}           85033
&{NODE1}               testline_object=${tl.gnbs[0]}
...                    custom_allowed_alarms=${CUSTOM_ALARMS}

${MRBTS_ID2}           85034
&{NODE2}               testline_object=${tl.gnbs[1]}
...                    custom_allowed_alarms=${CUSTOM_ALARMS}

@{NODES}               ${NODE1}    ${NODE2}

${QC_DOMAIN}=          MN_RAN
${QC_PROJECT}=         RAN_VRF
${RP_CA}               VRF_SiSo
${RP_ORGANIZATION}     VRF_KRK_T07
${RP_LOCATION}         VRF_KRK

${bts_mplane_ip}=   ${tl.gnbs[0].dus[0].oam_ip.v4.split('/')[0]}
${bts_username}=    toor4nsn
${bts_password}=    oZPS0POrRieRtu

${VM_USERNAME}=     ute       # vm username used in syslog
${VM_PASSWORD}=     ute       # vm password used in syslog
${BTS_HOST_IP}=     192.168.255.129  #  IP used in admin setup
${GNB1_HOST_IP}=    10.89.3.34

${test_dir}=                          testsuite/Krakow/SISO/regression/RAN_PZ_KRK7/CB012505
${scfc_dir}=                          commissionings/Krakow/7_7_T01PY033/SBTS00
${base_scfc}=                         ${scfc_dir}/GNB0_SCF.xml
${gnb1_scfc}=                         ${scfc_dir}/GNB1_SCF.xml

*** Test Cases ***
CB012505-A_Robustness_I
    Verify that LNRELGNBCELL.nrStatus is set to available
    Verify that LNRELGNBCELL.sourceOfData is set to OM
    Lock X2 link from gNB nieghbor side
    Verify that LNRELGNBCELL.nrStatus is set to unavailable
    Verify that LNRELGNBCELL.sourceOfData is set to OM

    Unlock X2 link from gNB nieghbor side
    Verify that LNRELGNBCELL.nrStatus is set to available
    Verify that LNRELGNBCELL.sourceOfData is set to OM

    Activate CB012505 feature flag
    Verify that LNRELGNBCELL.nrStatus is set to available
    Verify that LNRELGNBCELL.sourceOfData is set to OM
    Lock X2 link from gNB nieghbor side
    Verify that LNRELGNBCELL.nrStatus is set to available
    Verify that LNRELGNBCELL.sourceOfData is set to OM

    Unlock X2 link from gNB nieghbor side
    Verify that LNRELGNBCELL.nrStatus is set to available
    Verify that LNRELGNBCELL.sourceOfData is set to OM

    Trigger neighbor gNB reboot via ssh
    Verify that LNRELGNBCELL.nrStatus is set to available
    Verify that LNRELGNBCELL.sourceOfData is set to OM
    Wait for x2link to became available

    Perform full commissioning for gNB
    Verify that LNRELGNBCELL.nrStatus is set to unavailable
    Verify that LNRELGNBCELL.sourceOfData is set to OM
    Wait for x2link to became available

    Trigger eNB reset
    Wait for x2link to became available
    Verify that LNRELGNBCELL.nrStatus is set to available
    Verify that LNRELGNBCELL.sourceOfData is set to OM

    Deactivate CB012505 feature flag
    Trigger eNB reset
    Wait for x2link to became available
    Verify that LNRELGNBCELL.nrStatus is set to available
    Verify that LNRELGNBCELL.sourceOfData is set to OM

    [Teardown]    Test cleanup
