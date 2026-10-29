-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_dss_PrbArea = require("xp/dss/PrbArea"),
      xp_dss_PrbAreasExtensions = require("xp/dss/PrbAreasExtensions"),
}

function PrbAreas (fieldName, position)
    return
        fields.Structure({name="PrbAreas", fieldName=fieldName, position=position, size=52}, {
            fields.StaticVariableSizedArray({name="prbArea", position=0, size=44, numSizePaddingBytes=0, numItems=10, numPaddingBytes=0},
                fields.uint32, localVarTable.xp_dss_PrbArea("prbArea", 0)
            ),
            localVarTable.xp_dss_PrbAreasExtensions("extensions", 44),
        })
end

return PrbAreas
