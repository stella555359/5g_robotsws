*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SBTS00  SRAN  CLOUD_SRAN_LG_1FSMF_1FBBC_2FXDB_2FRMA_1FRHC  STATE_SKIP_AGENT
Library  XML  use_lxml=True
Library  taf.sw.scout
Library  String
Suite Setup      Set Library Search Order  coam   ute_admin   hran_frame_sbts_taf   hran_frame_sbts_siso   ca_CIT_general   ca_swm_general

Resource    ../../CIT/test_resources/STATE__Site_reset.robot

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara

*** Test Cases ***
[1]Airscale_STATE_Site Reset
    [Tags]  QC_18384
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#1a Site Reset Downtime
    [Tags]  QC_170157
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#54a_b Power-on Radio Unit startup availability
    [Tags]  QC_280435
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#51a_b Radio Unit Reset Downtime
    [Tags]  QC_280436
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#10 5G RAT Reset Downtime
    [Tags]  QC_409838
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#7 LTE RAT Reset Downtime
    [Tags]  QC_409839
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#16 - Manual cell lock unlock duration
    [Tags]  QC_409840
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#2a(b) Inter-Release SW Activition Downtime
    [Tags]  QC_413402
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#1a Site Reset Downtime
    [Tags]  QC_413401
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#3 Power-on Startup Availability
    [Tags]  QC_413403
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#4 Complete BTS SW Upgrade
    [Tags]  QC_413405
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#10 5G RAT Reset Downtime
    [Tags]  QC_424975
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#1a Site Reset Downtime
    [Tags]  QC_424984
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#8 WCDMA RAT Reset Downtime
    [Tags]  QC_424976
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#7 LTE RAT Reset Downtime
    [Tags]  QC_424977
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#51a_b Radio Unit Reset Downtime
    [Tags]  QC_424978
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#9 GSM RAT Reset Downtime
    [Tags]  QC_424979
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#4 Complete BTS SW Upgrade
    [Tags]  QC_424981
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#5 Capacity Module Reset Downtime
    [Tags]  QC_424980
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#2c(d) Intra-Release SW Activation Downtime
    [Tags]  QC_424982
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#3 Power-on Startup Availability
    [Tags]  QC_424983
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#51a_b Radio Unit Reset Downtime
    [Tags]  QC_164321
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#54a_b Power-on Radio Unit startup availability
    [Tags]  QC_164322
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#7 LTE RAT Reset Downtime
    [Tags]  QC_164323
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#8 WCDMA RAT Reset Downtime
    [Tags]  QC_164324
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#2c(d) Intra-Release SW Activation Downtime
    [Tags]  QC_164326
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#1 Site Reset Downtime
    [Tags]  QC_164327
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#3 Power-on Startup Availability
    [Tags]  QC_164328
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#4 Complete BTS SW Upgrade
    [Tags]  QC_164329
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#16 - Manual cell lock unlock duration
    [Tags]  QC_259180
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Airscale_OAM KPI_Local_Software_Rollback
    [Tags]  QC_259181
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Airscale_Local_Software_Download_and_Activation
    [Tags]  QC_259182
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#17a_b Cell Block-Unblock duration
    [Tags]  QC_384754
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Airscale_Local_Software_Download_and_Activation
    [Tags]  QC_18321
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Airscale_OAM KPI_Local_Software_Rollback
    [Tags]  QC_18322
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Airscale_Partial_Restart_of_LTE_RAT
    [Tags]  QC_18323
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Airscale_Partial_Restart_of_WCDMA_RAT
    [Tags]  QC_18324
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#2a SWR_First cell down-Last cell up
    [Tags]  QC_18326
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Airscale_STATE_SBTS Power reset
    [Tags]  QC_18325
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#3 Power Reset_BTS starts-First cell up
    [Tags]  QC_18327
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#4 SWR_SW download begins-First cell up
    [Tags]  QC_18328
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#7 LTE RAT reset_First cell down-Last cell up
    [Tags]  QC_18329
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#8 WCDMA RAT reset_First cell down-Last cell up
    [Tags]  QC_18330
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#9 GSM RAT Reset Downtime
    [Tags]  QC_165793
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Airscale_Partial_Restart_of_GSM_RAT
    [Tags]  QC_167210
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#1a Site Reset Downtime
    [Tags]  QC_170273
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Airscale_STATE_Site Reset
    [Tags]  QC_173403
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#16 - Manual cell lock unlock duration
    [Tags]  QC_259739
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#51a_b Radio Unit Reset Downtime
    [Tags]  QC_381674
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#54a_b Power-on Radio Unit startup availability
    [Tags]  QC_381675
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Airscale_Local_Software_Download_and_Activation
    [Tags]  QC_69344
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Airscale_Partial_Restart_of_LTE_RAT
    [Tags]  QC_69345
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Airscale_Partial_Restart_of_WCDMA_RAT
    [Tags]  QC_69346
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Airscale_STATE_SBTS Power reset
    [Tags]  QC_69347
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Airscale_STATE_Site Reset
    [Tags]  QC_69348
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#2c SWR_First cell down-Last cell up
    [Tags]  QC_69352
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#7 LTE RAT reset_First cell down-Last cell up
    [Tags]  QC_69354
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#8 WCDMA RAT reset_First cell down-Last cell up
    [Tags]  QC_69355
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#3 Power Reset_BTS starts-First cell up
    [Tags]  QC_69353
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Airscale_OAM KPI_Local_Software_Rollback
    [Tags]  QC_87240
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#9 GSM RAT Reset Downtime
    [Tags]  QC_166702
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#17a_b Cell Block-Unblock duration
    [Tags]  QC_166703
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#1a Site Reset Downtime
    [Tags]  QC_170158
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#5 Capacity Module Reset Downtime
    [Tags]  QC_226924
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#10 5G RAT Reset Downtime
    [Tags]  QC_226925
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#16 - Manual cell lock unlock duration
    [Tags]  QC_259445
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#51a_b Radio Unit Reset Downtime
    [Tags]  QC_384704
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#54a_b Power-on Radio Unit startup availability
    [Tags]  QC_384705
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#4 SWR_SW download begins-First cell up
    [Tags]  QC_456303
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#2a SWR_First cell down-Last cell up
    [Tags]  QC_18334
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#4 SWR_SW download begins-First cell up
    [Tags]  QC_18336
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#3 Power Reset_BTS starts-First cell up
    [Tags]  QC_18335
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#7 LTE RAT reset_First cell down-Last cell up
    [Tags]  QC_18337
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#8 WCDMA RAT reset_First cell down-Last cell up
    [Tags]  QC_18338
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Airscale_Local_Software_Download_and_Activation
    [Tags]  QC_18339
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Airscale_Partial_Restart_of_LTE_RAT
    [Tags]  QC_18341
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Airscale_OAM KPI_Local_Software_Rollback
    [Tags]  QC_18340
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Airscale_Partial_Restart_of_WCDMA_RAT
    [Tags]  QC_18342
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Airscale_STATE_SBTS Power reset
    [Tags]  QC_18343
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Airscale_STATE_Site Reset
    [Tags]  QC_18344
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#54a_b Power-on Radio Unit startup availability
    [Tags]  QC_165763
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#1a Site Reset Downtime
    [Tags]  QC_172856
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#10 5G RAT Reset Downtime
    [Tags]  QC_226946
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#5 Capacity Module Reset Downtime
    [Tags]  QC_229393
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#16 - Manual cell lock unlock duration
    [Tags]  QC_260017
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#51a_b Radio Unit Reset Downtime
    [Tags]  QC_386692
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#2a SWR_First cell down-Last cell up
    [Tags]  QC_18345
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#3 Power Reset_BTS starts-First cell up
    [Tags]  QC_18346
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#4 SWR_SW download begins-First cell up
    [Tags]  QC_18347
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#7 LTE RAT reset_First cell down-Last cell up
    [Tags]  QC_18348
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Airscale_FSMF_Partial_Restart_of_LTE_RAT
    [Tags]  QC_18350
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#8 WCDMA RAT reset_First cell down-Last cell up
    [Tags]  QC_18349
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Airscale_FSMF_Partial_Restart_of_WCDMA_RAT
    [Tags]  QC_18351
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Airscale_FSMF_SBTS Power reset
    [Tags]  QC_18352
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Airscale_FSMF_Site Reset
    [Tags]  QC_18353
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Airscale_FSMF_Software_Download_and_Activation
    [Tags]  QC_18354
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Airscale_FSMF_Software_Rollback
    [Tags]  QC_18355
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#1a Site Reset Downtime
    [Tags]  QC_170156
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#5 Capacity Module Reset Downtime
    [Tags]  QC_229394
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#54a_b Power-on Radio Unit startup availability
    [Tags]  QC_229398
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#51a_b Radio Unit Reset Downtime
    [Tags]  QC_229397
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#17a_b Cell Block-Unblock duration
    [Tags]  QC_229396
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#10 5G RAT Reset Downtime
    [Tags]  QC_229395
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#16 - Manual cell lock unlock duration
    [Tags]  QC_259446
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Airscale_STATE_SBTS Power reset
    [Tags]  QC_18360
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Airscale_Local_Software_Download_and_Activation
    [Tags]  QC_18361
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Airscale_OAM KPI_Local_Software_Rollback
    [Tags]  QC_18362
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Airscale_Partial_Restart_of_LTE_RAT
    [Tags]  QC_18363
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Airscale_STATE_Site Reset
    [Tags]  QC_18365
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Airscale_Partial_Restart_of_WCDMA_RAT
    [Tags]  QC_18364
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#3 Power Reset_BTS starts-First cell up
    [Tags]  QC_18369
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#7 LTE RAT reset_First cell down-Last cell up
    [Tags]  QC_18370
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#8 WCDMA RAT reset_First cell down-Last cell up
    [Tags]  QC_18371
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#2c SWR_First cell down-Last cell up
    [Tags]  QC_18372
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#17a_b Cell Block-Unblock duration
    [Tags]  QC_164304
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#10 5G RAT Reset Downtime
    [Tags]  QC_164303
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#1a Site Reset Downtime
    [Tags]  QC_170405
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#16 - Manual cell lock unlock duration
    [Tags]  QC_261024
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#2a(b) Inter-Release SW Activition Downtime - N-1 to N
    [Tags]  QC_384803
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]KPI#4 Complete BTS SW Upgrade
    [Tags]  QC_416033
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__KPI_triggered_fault_handling
    [Tags]  QC_18359
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]STATE__Downlink_(DL)_and_Uplink_(UL)_throughputs_for_LTE_BW_equal_to_20MHz
    [Tags]  QC_18377
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]SWM__SBTS_Local_SW_Download_and_Activation
    [Tags]  QC_18378
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]SWM__SBTS_Local_SW_Download_and_Activation
    [Tags]  QC_18379
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]CM_Manual establishment of the SBTS and basic calls on all cells
    [Tags]  QC_18380
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]CM_Manual reconfiguration of the SBTS - LTE replaced by SA NB-IoT
    [Tags]  QC_18385
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]SWM__SBTS_Local_SW_Download_and_Activation
    [Tags]  QC_18373
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]CM__SBTS_initial_setup
    [Tags]  QC_18374
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[2]CM__SBTS_initial_setup
    [Tags]  QC_18375
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[3]CM__SBTS_initial_setup
    [Tags]  QC_18376
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

*** Keywords ***