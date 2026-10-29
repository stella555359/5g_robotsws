-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

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
