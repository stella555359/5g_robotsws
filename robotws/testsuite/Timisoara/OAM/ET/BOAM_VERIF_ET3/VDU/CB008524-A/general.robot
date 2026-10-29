*** Settings ***
Documentation
...    Author: Oana Ciuculesc/Adrian Cretu
...    Maintainer: Oana Ciuculesc/Adrian Cretu  (oana.ciuculesc@nokia.com/adrian.1.cretu@nokia.com)
...    Group in charge: BTS_OAM_CU
...    References: doors
...    Feature Description: 5GCB008524-A
...    Sample execution:

Resource   ./resources/CB8524A.robot
Resource   ./resources/xPath_CB008524A.robot
*** Test Cases ***

[1]Test Case 59. Multiple process crashed during configuration to trigger 4649
    [Tags]     CRT   QC_    QCP_RAN_ET    QCD_MN_RAN
    Multiple process crashed during configuration to trigger 4649

[1]Test Case 24. gNB-vDU OAM supports active supervision for TRSCONFIG process
   [Tags]     CRT   QC_    QCP_RAN_ET    QCD_MN_RAN
   Check TRSConfig is restarted after killing process on VDU

[1]Test Case 41. eAxC critical process failure
   [Tags]     CRT   QC_    QCP_RAN_ET    QCD_MN_RAN
   Trigger a critical process failure

[1]Test Case 50. OAMASM non-critical multiple process failure
    [Tags]     CRT   QC_    QCP_RAN_ET    QCD_MN_RAN
    Trigger a non-critical process failure more than 5 times

[1]Test Case 56. Robustness- The OAM container won’t be restarted due to multiple process hang.
   [Tags]     CRT   QC_    QCP_RAN_ET    QCD_MN_RAN
  Multiple process hang situation for OAM container

[1]Test Case 3. FMMED service is resilient for its fault data
    [Tags]     CRT   QC_    QCP_RAN_ET    QCD_MN_RAN
    Check if FMMED service is resilient for its fault data

[1]Test Case 46. OAMCM critical process failure
    [Tags]     CRT   QC_    QCP_RAN_ET    QCD_MN_RAN
    OAMCM critical process failure

[1]Test Case 34. gNB-vDU OAM supports passive supervision for CTP process
   [Tags]     CRT   QC_    QCP_RAN_ET    QCD_MN_RAN
    gNB-vDU OAM supports passive supervision for CTP process

[1]Test Case 53. OAMConfig critical IMS service failure
    [Tags]     CRT   QC_    QCP_RAN_ET    QCD_MN_RAN
    OAMConfig critical IMS service failure

[1]Test Case 13. Resume communication between vDU OAM process running on OAMExt and OAMConfig pods
    [Tags]     CRT   QC_    QCP_RAN_ET    QCD_MN_RAN
    Resume communication between vDU OAM process running on OAMExt and OAMConfig pods
    Sleep    300s

