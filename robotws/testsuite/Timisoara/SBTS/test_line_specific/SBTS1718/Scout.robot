*** Settings ***
Force Tags  SBTS00  SRAN  CLOUD_SRAN_LWG_2ASIA_5ABIA_2FRGY_2FXDB_1AHEB  STATE_SKIP_AGENT
Library  taf.sw.scout
Library  String

*** Variables ***

*** Test Cases ***
Test
    ${tl_name}  Fetch From Right  ${CONFIGURATION}  .
    Setup Scout  ${tl_name}
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

Test 1
    ${tl_name}  Fetch From Right  ${CONFIGURATION}  .
    Setup Scout  ${tl_name}
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

Test 2
    ${tl_name}  Fetch From Right  ${CONFIGURATION}  .
    Setup Scout  ${tl_name}
    Request SCF  use_scout_internal_id=False
    Log Variables
    Teardown Scout API

*** Keywords ***
