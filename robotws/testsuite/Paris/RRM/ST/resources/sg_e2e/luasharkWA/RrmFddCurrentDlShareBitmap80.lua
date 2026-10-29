-- Copyright 2020 Nokia
-- Created with MuLTI version: v0.25.3 8f3f26b652c19bd64290922f1096d976ec333e58
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b
local fields = require("message")


function RrmFddCurrentDlShareBitmap80 (fieldName, position)
    return
        fields.BitSet({name="RrmFddCurrentDlShareBitmap80", fieldName=fieldName, position=position, size=10, padding=0},
            fields.byte({name="byte", position=position}))
end

return RrmFddCurrentDlShareBitmap80
