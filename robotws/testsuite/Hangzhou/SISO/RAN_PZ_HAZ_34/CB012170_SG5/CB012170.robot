*** Settings ***
Documentation
...    Author: Zhang Xuewen
...    Contact: xuewen.zhang@nokia-sbell.com
...    squad group:SG_05
...    Feature CB012170
Library     taf.transport.ssh    WITH NAME    ssh
Resource  ./Resources/CB012170_keyword.robot


Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown


*** Test Cases ***
[1]CB012170-SR-A_02_Online_feature_activation_validation_cMAAr7_1_64T64R
  [Setup]  SISO Coam Test Setup
  [Documentation]    Author: Zhang Xuewen
  [Tags]   CRT_TRUNK
#  Step 1 Active 5GC000430 on webEM
#  Step 2 Active CB008133 on webEM
#  Step 3 Active CB012170 on webEM
  Download MCShark To UTE
  Bip capture and Check PatternID
  Step 4 Check gnb status
  [Teardown]    SISO Coam Test Teardown

[1]CB012170-SR-B_06_IWK_CB002001_SSB_muting_when_enable_CB012170_cMAAr7_1_64T64R
  [Setup]  SISO Coam Test Setup
  [Documentation]    Author: Zhang Xuewen
  [Tags]   CRT_TRUNK
#  Step 1 UE run DL traffic and reduce the traffic load of power saving group
#  Step 3 Online change NRBTS.actSSBBoostInmMIMOMuting to true on WebEM
#  Step 4 Check service is not interrupted
#  Step 5 Check gnb status
  Download MCShark To UTE
  Bip capture and Check PatternID
  Step 5 Check gnb status
  [Teardown]    SISO Coam Test Teardown
