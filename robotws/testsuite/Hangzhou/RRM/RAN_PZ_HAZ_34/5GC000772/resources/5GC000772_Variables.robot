
*** Variables ***

###
### These variables contain the default values.
### If you have to use other values, please set them directly in the test case
###

# GNB Variables:
${GN_OAM_ADDR}=                    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${SA_OR_NSA_MODE}=                 NSA

# Test Variables:
${CAMPAIGN_NAME}=                  5GC000772_NSA
${IS_FIRST_CALL}=                  True
${CELL_NUMBER}=                    1
${CELL_FOR_HO}=                    2
${CALL_DURATION}=                  120
${X2traces}=                       True
${F1traces}=                       True

# Qualcomm Variables:
${QCT_UE_ID_1}=                    0
${QCT_UE_ID_2}=                    1

# Defaults Values for cDRX parameters:
${defDrxInactivityTimer}=          4ms
${defDrxLongCycle}=                40ms
${defDrxOnDurationTimer}=          10ms
${defDrxRetransTimerDl}=           0slot
${defDrxRetransTimerUl}=           0slot
${defDrxHarqRttTimerDl}=           0symbols
${defDrxHarqRttTimerUl}=           0symbols

# Online Feature Modification parameters:
${longCycleStartValue}=            40ms
${longCycleSecondValue}=           80ms
${TimerBeforeDrxModification}=     60s
${TimerAfterDrxModification}=      60s

# Counters Variables:
${SLOTS_SEC}=                      2000
${PM_INTERVAL}=                    5
${PRECISION_SUM}=                  10
${THRESHOLD_MIN}=                  1
${THRESHOLD_MAX}=                  99

# DRX Counters Name:
${SLOTS_UE_DRX_ACTIVE}=            M55308C11001
${SLOTS_UE_DRX_SLEEP}=             M55308C11002
${HO_ATT_UE_IN_DRX}=               M55128C01001
${HO_SUCC_UE_IN_DRX}=              M55128C01002

# By default, no StateMachine Is Run:
@{SM_TO_BE_RUN}=                   Stub.sm
@{SM_TO_BE_RUN_20A}=               Stub20A.sm

# Some commands to be executed on ASIK
${rmPMFiles}=                      rm /tmp/PM.*
${rmRDFiles}=                      rm /tmp/RD.*


