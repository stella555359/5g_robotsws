-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6
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
