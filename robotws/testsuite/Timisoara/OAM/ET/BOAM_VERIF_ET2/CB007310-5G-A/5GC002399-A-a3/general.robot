*** Settings ***
Documentation
...  Author: Coras Denisa-Maria (denisa.coras@nokia.com)
...  Maintainer: Coras Denisa-Maria (denisa.coras@nokia.com)
...  Test Description: BTS_commissioning_L2RT
...  Execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log -d results/
...  /home/ute/MN/UTE/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET2/CB007310-5G-A/5GC002399-A-a3/general.robot
...  Dryrun: /opt/ute/python/bin/robot -t "1.0 5GC002399-A-a3_BTS_commissioning_L2RT"
...  --dryrun --log NONE --report NONE --output NONE -v CONFIGURATION:dryrun -C off -d /home/ute/logs -L TRACE
...  testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET2/CB007310-5G-A/5GC002399-A-a3/general.robot

Resource    ${CURDIR}/resources/5GC002399-A-a3.robot
Resource    ../../resources/pretest_posttest.robot

Force Tags   STATE_SW_UPLOADED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN   #SBTS22R3
...   # Regression Optimisation - part 2- July 2022      SBTS00
...    CLOUD_5G_CLASSICAL_FULLRACK_ASILL_ABIOB1B3_AEQN_ECPRI_ASILR_ABIOB4B6_ENB
...    CA_BTS_OAM_VERIF    master_classicalbts_all  # SBTS22R1  SBTS22R2

Suite Setup       Run Keywords      UTE TL Preparation
...               AND               Suite Preconditions
Suite Teardown    Suite Postconditions
Test Setup        Test Preconditions
Test Teardown     Test Postconditions


*** Variables ***
${SW_DESTINATION}     /home/ute

*** Test Cases ***
[1.0] 5GC002399-A-a3_BTS_commissioning_L2RT
#    [Tags]    CRT    CA_MANO_SOAM3   QCP_MANO   QCP_BTS_OAM    QCD_MN_MANO   QCD_MN_BTS_OAM   QC_2719307   5G20A
    [Tags]    CRT
    [Documentation]
    ...
    5GC002399-A-a3_BTS_commissioning_L2RT
