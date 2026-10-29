-- Copyright 2020 Nokia
-- Created with MuLTI version: v0.24.3 f49d755d2a606bfb2c44b20709ef7342a02f7078 EXPERIMENTAL!
-- Type repository checksum:   0a26cb0ac27ecf8a57b68bb0fb5af4f52b134846

local fields = require("message")
local xp_dss_EnDssUlCrmScInfoExtensions = require("xp/dss/EnDssUlCrmScInfoExtensions")


-- This IE defines parameters that are used for the Common Resource Management algorithm in the CRM.
function EnDssUlCrmScInfo (fieldName, position)
    return
        fields.Structure({name="EnDssUlCrmScInfo", fieldName=fieldName, position=position, size=120}, {
            fields.StaticVariableSizedArray({name="thresholdForIncreasingUlSharingRatio", position=0, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=3},
                fields.uint32, fields.uint8({name="item", position=0})
            ),
            fields.StaticVariableSizedArray({name="thresholdForDecreasingUlSharingRatio", position=8, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=3},
                fields.uint32, fields.uint8({name="item", position=8})
            ),
            fields.StaticVariableSizedArray({name="hysteresisForUlSharingRatioChanging", position=16, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=3},
                fields.uint32, fields.uint8({name="item", position=16})
            ),
            fields.StaticVariableSizedArray({name="maximumUlGbrSharingAdaptationStepSize", position=24, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=3},
                fields.uint32, fields.uint8({name="item", position=24})
            ),
            fields.StaticVariableSizedArray({name="maximumUlNonGbrSharingAdaptationStepSize", position=32, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=3},
                fields.uint32, fields.uint8({name="item", position=32})
            ),
            fields.StaticVariableSizedArray({name="ulSchedulingWeightForNr", position=40, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=3},
                fields.uint32, fields.uint8({name="item", position=40})
            ),
            fields.StaticVariableSizedArray({name="ulSchedulingWeightForLte", position=48, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=3},
                fields.uint32, fields.uint8({name="item", position=48})
            ),
            fields.StaticVariableSizedArray({name="enDssUlQoSLoadMeasurementTimer", position=56, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=2},
                fields.uint32, fields.uint16({name="item", position=56})
            ),
            fields.StaticVariableSizedArray({name="enDssUlResourceAllocationTimer", position=64, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=2},
                fields.uint32, fields.uint16({name="item", position=64})
            ),
            fields.StaticVariableSizedArray({name="enDssUlMinScSharingRatioUpdateTimer", position=72, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=3},
                fields.uint32, fields.uint8({name="item", position=72})
            ),
            fields.StaticVariableSizedArray({name="lteNrDssUlLteGbrUpThresh", position=80, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=3},
                fields.uint32, fields.uint8({name="item", position=80})
            ),
            fields.StaticVariableSizedArray({name="lteNrDssUlNrPdcchUpThresh", position=88, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=3},
                fields.uint32, fields.uint8({name="item", position=88})
            ),
            fields.StaticVariableSizedArray({name="asgnUlMinValue", position=96, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=3},
                fields.uint32, fields.uint8({name="item", position=96})
            ),
            fields.StaticVariableSizedArray({name="asgnUlMaxValue", position=104, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=3},
                fields.uint32, fields.uint8({name="item", position=104})
            ),
            xp_dss_EnDssUlCrmScInfoExtensions("extensions", 112),
        })
end

return EnDssUlCrmScInfo
