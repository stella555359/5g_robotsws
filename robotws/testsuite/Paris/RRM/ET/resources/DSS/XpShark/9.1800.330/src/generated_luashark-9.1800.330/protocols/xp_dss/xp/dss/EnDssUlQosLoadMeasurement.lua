-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local xp_dss_EnDssUlQosLoadMeasurementExtensions = require("xp/dss/EnDssUlQosLoadMeasurementExtensions")


-- In UL different QoS classes can be assigned to the same Logical Channel Group (LCG). In case a LCG contains a GBR and a non-GBR bearer the RBs granted to this LCG will count as used by GBR.
function EnDssUlQosLoadMeasurement (fieldName, position)
    return
        fields.Structure({name="EnDssUlQosLoadMeasurement", fieldName=fieldName, position=position, size=12}, {
            fields.uint8({name="measuredGbrLoad", position=0}),
            fields.uint8({name="measuredNbrLoad", position=1}),
            fields.uint8({name="MeasuredNgbrNnbrLoad", position=2}),
            fields.Padding({name="MeasuredNgbrNnbrLoad_extensions_padding", position=3, size=1}),
            xp_dss_EnDssUlQosLoadMeasurementExtensions("extensions", 4),
        })
end

return EnDssUlQosLoadMeasurement
