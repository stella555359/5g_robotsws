-- Copyright 2020 Nokia
-- Created with MuLTI version: v0.24.3 f49d755d2a606bfb2c44b20709ef7342a02f7078 EXPERIMENTAL!
-- Type repository checksum:   0a26cb0ac27ecf8a57b68bb0fb5af4f52b134846

local fields = require("message")
local xp_dss_PrbArea = require("xp/dss/PrbArea")
local xp_dss_PrbAreasExtensions = require("xp/dss/PrbAreasExtensions")


function PrbAreas (fieldName, position)
    return
        fields.Structure({name="PrbAreas", fieldName=fieldName, position=position, size=52}, {
            fields.StaticVariableSizedArray({name="prbArea", position=0, size=44, numSizePaddingBytes=0, numItems=10, numPaddingBytes=0},
                fields.uint32, xp_dss_PrbArea("prbArea", 0)
            ),
            xp_dss_PrbAreasExtensions("extensions", 44),
        })
end

return PrbAreas
