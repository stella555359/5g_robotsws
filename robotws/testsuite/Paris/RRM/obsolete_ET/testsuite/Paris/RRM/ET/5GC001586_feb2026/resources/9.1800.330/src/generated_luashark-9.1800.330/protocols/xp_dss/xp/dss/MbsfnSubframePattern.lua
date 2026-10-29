-- Copyright 2020 Nokia
-- Created with MuLTI version: v0.24.3 f49d755d2a606bfb2c44b20709ef7342a02f7078 EXPERIMENTAL!
-- Type repository checksum:   0a26cb0ac27ecf8a57b68bb0fb5af4f52b134846
local fields = require("message")


-- This IE defines an MBSFN Subframe pattern for 4 consecutive radio frames.
--      The allocation of the MBSFN subframes happens for 4 radio frames. In each radio frame up to 6 subframes can be MBSFN subframes (position 2,3,4,6,7,8). To express the positions of the MBSFN subframes within the 4 radio frames 4*6 bits are needed. The pattern repeats after the 4 radio frames. See also in the annex (12.5).
--      The positive integer value for capacity describes the number of bits in the set
function MbsfnSubframePattern (fieldName, position)
    return
        fields.BitSet({name="MbsfnSubframePattern", fieldName=fieldName, position=position, size=3},
            fields.byte({name="byte", position=position}))
end

return MbsfnSubframePattern
