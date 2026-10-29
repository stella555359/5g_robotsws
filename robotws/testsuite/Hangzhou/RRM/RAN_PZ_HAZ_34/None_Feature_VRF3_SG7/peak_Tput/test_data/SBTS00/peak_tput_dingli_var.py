from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")
gNbId = tl.gnbs[0].instance_id

PARAMS_FOR_CELL_40M = [
  "NRCELL-1:chBw=40MHz",
  "NRCELL-1:reqMinNumPuschPrb=88",
  "NRCELL-1:msg1FrequencyStart=9",
  "BWP_PROFILE-50/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=96",
]

PARAMS_FOR_RECOVER = [
  "NRCELL-1:chBw=20MHz",
  "NRCELL-1:reqMinNumPuschPrb=39",
  "NRCELL-1:msg1FrequencyStart=6",
  "BWP_PROFILE-50/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=48",
]
