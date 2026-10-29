*** Settings ***
Documentation


Suite Setup  Clean And Prepare UTE VM 4G


Resource       taf/rfrl/uuf4all/uuf4all_test_cases.robot
Resource       ${CURDIR}/../resources/other/install_vm_ute_4G.robot
Library        taf.transport.ssh   WITH NAME   ssh


*** Variables ***


*** Test Cases ***
5GC000937_01_Cloudification_test
   Log               ****** TL dummy Cloudification ******************************************
   Log               ****** including VM UTE 5G and VM UTE 4G reinstallation *****************

    



*** Keywords ***
Install VM UTE 4G
   Clean And Prepare UTE VM 4G
