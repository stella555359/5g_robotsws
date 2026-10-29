-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local xp_dss_CatmInfoExtensions = require("xp/dss/CatmInfoExtensions")


-- The index reated parameters are pointing to a position in the generic DL PRB Reservation List (11.54).
--      The DL PRB Reservation List is segmented into different areas. Each area has a specific meaning (e.g. for CAT-M DL data, CAT-M paging, ...)
function CatmInfo (fieldName, position)
    return
        fields.Structure({name="CatmInfo", fieldName=fieldName, position=position, size=16}, {
            fields.boolean({name="repeatedMpbch", position=0}),
            fields.uint8({name="startSymbol", position=1}),
            fields.uint8({name="catmDlDataIndex", position=2}),
            fields.uint8({name="pagingStartingIndex", position=3}),
            fields.uint8({name="numberOfCatmPagingRecords", position=4}),
            fields.uint8({name="sib1BrStartingIndex", position=5}),
            fields.uint8({name="numberOfCatmSib1BrRecords", position=6}),
            fields.Padding({name="numberOfCatmSib1BrRecords_extensions_padding", position=7, size=1}),
            xp_dss_CatmInfoExtensions("extensions", 8),
        })
end

return CatmInfo
