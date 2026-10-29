-- Copyright 2020 Nokia
-- Created with MuLTI version: v0.24.3 f49d755d2a606bfb2c44b20709ef7342a02f7078 EXPERIMENTAL!
-- Type repository checksum:   0a26cb0ac27ecf8a57b68bb0fb5af4f52b134846

local fields = require("message")
local xp_dss__ExtensionUnion_EutranFddCellFrequencyInfoExtensions = require("xp/dss/_ExtensionUnion_EutranFddCellFrequencyInfoExtensions")


function EutranFddCellFrequencyInfoExtensions (fieldName, position)
    return
        fields.ExtensionPoint({name="EutranFddCellFrequencyInfoExtensions", fieldName=fieldName, position=position, size=8}, {
            fields.DynamicVariableSizedArray({name="_ExtensionArray", position=0, size=8, numSizePaddingBytes=0, numItems=0, numPaddingBytes=0},
                fields.uint32, fields.uint32, xp_dss__ExtensionUnion_EutranFddCellFrequencyInfoExtensions("_ExtensionArray", 0)
            ),
        })
end

return EutranFddCellFrequencyInfoExtensions
