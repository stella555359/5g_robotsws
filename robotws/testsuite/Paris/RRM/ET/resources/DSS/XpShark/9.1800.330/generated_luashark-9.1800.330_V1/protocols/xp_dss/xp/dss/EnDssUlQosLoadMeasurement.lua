-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_dss_EnDssUlQosLoadMeasurementExtensions = require("xp/dss/EnDssUlQosLoadMeasurementExtensions"),
}

-- In UL different QoS classes can be assigned to the same Logical Channel Group (LCG). In case a LCG contains a GBR and a non-GBR bearer the RBs granted to this LCG will count as used by GBR.
function EnDssUlQosLoadMeasurement (fieldName, position)
    return
        fields.Structure({name="EnDssUlQosLoadMeasurement", fieldName=fieldName, position=position, size=12}, {
            fields.uint8({name="measuredGbrLoad", position=0}),
            fields.uint8({name="measuredNbrLoad", position=1}),
            fields.uint8({name="MeasuredNgbrNnbrLoad", position=2}),
            fields.Padding({name="MeasuredNgbrNnbrLoad_extensions_padding", position=3, size=1}),
            localVarTable.xp_dss_EnDssUlQosLoadMeasurementExtensions("extensions", 4),
        })
end

return EnDssUlQosLoadMeasurement
