-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local xp_dss_CatmAllocInfo = require("xp/dss/CatmAllocInfo")
local xp_dss_DlPrbAllocationInfoExtension1Extensions = require("xp/dss/DlPrbAllocationInfoExtension1Extensions")


function DlPrbAllocationInfoExtension1 (fieldName, position)
    return
        fields.Structure({name="DlPrbAllocationInfoExtension1", fieldName=fieldName, position=position, size=68}, {
            xp_dss_CatmAllocInfo("catmAllocInfo", 0),
            xp_dss_DlPrbAllocationInfoExtension1Extensions("extensions", 60),
        })
end

return DlPrbAllocationInfoExtension1
