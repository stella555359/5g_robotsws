-- Copyright 2020 Nokia
-- Created with MuLTI version: v0.24.3 f49d755d2a606bfb2c44b20709ef7342a02f7078 EXPERIMENTAL!
-- Type repository checksum:   0a26cb0ac27ecf8a57b68bb0fb5af4f52b134846

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
