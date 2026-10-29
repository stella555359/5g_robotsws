-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

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
