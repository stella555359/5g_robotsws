from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
gNbId = tl.gnbs[0].instance_id

PARAMS_IN_SCF = [
  "NRCELL-1:dlMimoMode=8x4 Closed Loop Spatial Multiplexing",
  "NRCELL-1:nrCellType=8DL8UL",
  "NRCELL-1:actCsirsMultiplexing=true",
  "NRCELL-1:actCDrx=true",
  "NRCELL-3:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing",
  "NRCELL-3:nrCellType=4DL4UL",
  "NRCELL-3:actCsirsMultiplexing=false",
  "NRCELL-3:actCDrx=true",
  "NRDRX-1:drxInactivityTimer=80ms",
  "NRDRX-1:drxLongCycle=160ms",
  "NRDRX-1:drxOnDurationTimer=20ms",
  "NRDRX-1:userLabel=Default NonGbr",
  "NRBTS-1:actCarrierAggregation=true",
]
