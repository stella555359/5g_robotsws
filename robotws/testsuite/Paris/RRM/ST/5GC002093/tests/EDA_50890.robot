#(py27) localuser@iv-ps328:~/TafProject/robotws/testsuite/Paris/RRM/ST/5GC002093/tests$
# /home/localuser/TafProject/robotws/testsuite/Paris/RRM/ST/5GC002093/tests/
# robot --dryr -V CV328/ -b debug.log -d ./logs/ EDA_50890.robot
# OR ~/TafProject/robotws/testsuite/Paris/RRM/ST/resources/sg_radio_perf/sh
# ./to_be_run_cv328.sh
# robot --exitonfailure -V CV328/ -b debug.log -d ./logs/ EDA_50890.robot

*** Settings ***
Documentation
...           AUTHOR (I&V):   Nathalie Caudy       nathalie.caudy@nokia.com
...           creation : 07/07/2022
...
...         TL tested :
...         gNB Classical 1 x ASIB, 1 x ASIK, 3 RU cmW (AEHC) eCPRI
...         UE Qualcomm
...         5G Real
...         CN Real


Variables         ../../../../resources/ST/python/custom.py
Resource          ../resources/robot/EDA_50890_resources.robot


Force Tags        5G_RAN     CLASSICAL    STATE_ON_AIR

Suite Setup       EDA_Suite_Setup
Suite Teardown    EDA_Suite_Teardown

*** Variables ***
${gNB_id}=              0

*** Test Cases **
TC_EDA_50890
    [Tags]          EDA_50890
    EDA_50890





