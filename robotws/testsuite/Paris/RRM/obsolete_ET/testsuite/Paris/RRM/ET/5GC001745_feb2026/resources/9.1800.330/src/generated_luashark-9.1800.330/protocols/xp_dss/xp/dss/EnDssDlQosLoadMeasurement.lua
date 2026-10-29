-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

local fields = require("message")
local xp_dss_EnDssDlQosLoadMeasurementExtensions = require("xp/dss/EnDssDlQosLoadMeasurementExtensions")


function EnDssDlQosLoadMeasurement (fieldName, position)
    return
        fields.Structure({name="EnDssDlQosLoadMeasurement", fieldName=fieldName, position=position, size=40}, {
            fields.uint8({name="measuredGbrLoad", position=0}),
            fields.uint8({name="measuredNbrLoad", position=1}),
            fields.uint8({name="measuredNgbrNnbrLoad", position=2}),
            fields.Padding({name="measuredNgbrNnbrLoad_measuredGbrBuffer_padding", position=3, size=1}),
            fields.uint16({name="measuredGbrBuffer", position=4}),
            fields.int16({name="measuredGbrBufferChange", position=6}),
            fields.uint16({name="measuredNbrBuffer", position=8}),
            fields.int16({name="measuredNbrBufferChange", position=10}),
            fields.uint16({name="measuredNgbrNnbrBuffer", position=12}),
            fields.int16({name="measuredNgbrNnbrBufferChange", position=14}),
            fields.StaticVariableSizedArray({name="measuredPdcchLoad", position=16, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=3},
                fields.uint32, fields.uint8({name="item", position=16})
            ),
            fields.StaticVariableSizedArray({name="numberOfRrcConnectedUes", position=24, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=2},
                fields.uint32, fields.uint16({name="item", position=24})
            ),
            xp_dss_EnDssDlQosLoadMeasurementExtensions("extensions", 32),
        })
end

return EnDssDlQosLoadMeasurement
