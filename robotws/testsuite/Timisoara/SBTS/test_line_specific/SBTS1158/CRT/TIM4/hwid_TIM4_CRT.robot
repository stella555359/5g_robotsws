*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SBTS00  SRAN  CLOUD_SRAN_LG_1FSMF_1FBBC_2FXDB_2FRMA_1FRHC  STATE_SKIP_AGENT
Library  XML  use_lxml=True
Library  taf.sw.scout
Library  String
Suite Setup      Set Library Search Order  coam   ute_admin   hran_frame_sbts_taf   hran_frame_sbts_siso   ca_CIT_general   ca_swm_general


*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara


*** Test Cases ***
[2]Automated__STATE__Site_reset
    [Tags]  QC_424983
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[2]Automated__STATE__Site_reset
    [Tags]  QC_18359  QC_424982
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
[2]Automated__STATE__Site_reset
    [Tags]  QC_18359  QC_424980
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
[2]Automated__STATE__Site_reset
    [Tags]  QC_18359  QC_424981
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
[2]Automated__STATE__Site_reset
    [Tags]  QC_18359  QC_424978
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[2]Automated__STATE__Site_reset
    [Tags]  QC_18359  QC_424976
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[2]Automated__STATE__Site_reset
    [Tags]  QC_18359  QC_424984
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
[2]Automated__STATE__Site_reset
    [Tags]  QC_18359  QC_424975
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
[2]Automated__STATE__Site_reset
    [Tags]  QC_18359  QC_416033
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
[2]Automated__STATE__Site_reset
    [Tags]  QC_18359  QC_413405
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[2]Automated__STATE__Site_reset
    [Tags]  QC_18359  QC_413403
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[2]Automated__STATE__Site_reset
    [Tags]  QC_18359  QC_413401
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
[2]Automated__STATE__Site_reset
    [Tags]  QC_18359  QC_413402
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
[2]Automated__STATE__Site_reset
    [Tags]  QC_18359  QC_409840
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
[2]Automated__STATE__Site_reset
    [Tags]  QC_18359  QC_409839
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[2]Automated__STATE__Site_reset
    [Tags]  QC_18359  QC_409838
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[2]Automated__STATE__Site_reset
    [Tags]  QC_18359  QC_386692
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
[2]Automated__STATE__Site_reset
    [Tags]  QC_18359  QC_384803
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
[2]Automated__STATE__Site_reset
    [Tags]  QC_18359  QC_384754
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
[2]Automated__STATE__Site_reset
    [Tags]  QC_18359  QC_384705
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[2]Automated__STATE__Site_reset
    [Tags]  QC_18359  QC_280436
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[2]Automated__STATE__Site_reset
    [Tags]  QC_18359  QC_280436
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
[2]Automated__STATE__Site_reset
    [Tags]  QC_18359  QC_280435
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
[2]Automated__STATE__Site_reset
    [Tags]  QC_18359  QC_261024
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
[2]Automated__STATE__Site_reset
    [Tags]  QC_18359  QC_260017
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[2]Automated__STATE__Site_reset
    [Tags]  QC_18359  QC_259446
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[2]Automated__STATE__Site_reset
    [Tags]  QC_18359  QC_259445
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
[2]Automated__STATE__Site_reset
    [Tags]  QC_18359  QC_259182
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
[2]Automated__STATE__Site_reset
    [Tags]  QC_18359  QC_259181
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
[2]Automated__STATE__Site_reset
    [Tags]  QC_18359  QC_259180
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[2]Automated__STATE__Site_reset
    [Tags]  QC_18359  QC_229395
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[2]Automated__STATE__Site_reset
    [Tags]  QC_18359  QC_229396
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
[2]Automated__STATE__Site_reset
    [Tags]  QC_18359  QC_229397
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
[2]Automated__STATE__Site_reset
    [Tags]  QC_18359  QC_229398
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
[2]Automated__STATE__Site_reset
    [Tags]  QC_18359  QC_229394
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[2]Automated__STATE__Site_reset
    [Tags]  QC_18359  QC_229393
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[2]Automated__STATE__Site_reset
    [Tags]  QC_18359  QC_226946
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
[2]Automated__STATE__Site_reset
    [Tags]  QC_18359  QC_226925
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
[2]Automated__STATE__Site_reset
    [Tags]  QC_18359  QC_172856
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
[2]Automated__STATE__Site_reset
    [Tags]  QC_18359  QC_170405
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API	
	
*** Keywords ***
