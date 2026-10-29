-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b
local fields = require("message")


-- This IE defines an MBSFN Subframe pattern for 4 consecutive radio frames.
--      The allocation of the MBSFN subframes happens for 4 radio frames. In each radio frame up to 6 subframes can be MBSFN subframes (position 2,3,4,6,7,8). To express the positions of the MBSFN subframes within the 4 radio frames 4*6 bits are needed. The pattern repeats after the 4 radio frames. See also in the annex (12.5).
--      The positive integer value for capacity describes the number of bits in the set
function MbsfnSubframePattern (fieldName, position)
    return
        fields.BitSet({name="MbsfnSubframePattern", fieldName=fieldName, position=position, size=4, padding=1},
            fields.byte({name="byte", position=position}))
end

return MbsfnSubframePattern
