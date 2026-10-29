*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_ECPRI_CMWV_TDD_GMC

Documentation
...   author:
...    - Mateusz Matusik (mateusz.matusik@nokia.com)

Resource     ./resources/LBT28256_keywords.robot

Suite Setup    Run Setup

*** Variables ***
${LUA_CFG}=             ${CURDIR}/config/egate_n66_4T4R_AHFII_AEHC.lua
${SCFC}=                ${CURDIR}/config/scfc_n66_4T4R_AHFII_AEHC.xml
${AP_XML}=              ${CURDIR}/config/iphy_n66_4T4R_AHFII_AEHC.xml
${SKIP_COUNTERS}=       ${FALSE}

*** Test Cases ***
LBT28256-A_dualband_RU_check
    Verify that RU is in enabled state    1
    Trigger FID on AHFII RU    0
    Wait for RU to perform autonomus recovery    1
    Trigger FID on remaining AHFII RU antennas    0
    Verify that RU is in failed state    1
    Trigger additional FID 2922 on RU    0    antenna2a
    Trigger additional FID 2922 on RU    0    antenna3b
    Verify that RU is in failed state    1

    Cancel FID on AHFII RU    0
    Verify that RU is in degraded state    1
    Cancel additional FID 2922 on RU    0    antenna2a
    Cancel additional FID 2922 on RU    0    antenna3b
    Verify that RU is in enabled state    1

    [Teardown]    Test cleanup

LBT28256-A_mMIMO_RU_check
    Verify that RU is in enabled state    2
    Trigger FID on AEHC mMIMO RU    1
    Wait for RU to perform autonomus recovery    2
    Trigger FID on remaining AEHC mMIMO RU pipelines   1
    Verify that RU is in failed state    2
    Trigger additional FID 2922 on RU    1    txArray1:1
    Trigger additional FID 2922 on RU    1    txArray1:4
    Trigger additional FID 2922 on RU    1    txArray2:1
    Trigger additional FID 2922 on RU    1    txArray2:4
    Verify that RU is in failed state    2

    Cancel FID on AEHC mMIMO RU    1
    Verify that RU is in enabled state    2
    Cancel additional FID 2922 on RU    1    txArray1:1
    Cancel additional FID 2922 on RU    1    txArray1:4
    Cancel additional FID 2922 on RU    1    txArray2:1
    Cancel additional FID 2922 on RU    1    txArray2:4
    Verify that RU is in enabled state    2

    [Teardown]    Test cleanup
