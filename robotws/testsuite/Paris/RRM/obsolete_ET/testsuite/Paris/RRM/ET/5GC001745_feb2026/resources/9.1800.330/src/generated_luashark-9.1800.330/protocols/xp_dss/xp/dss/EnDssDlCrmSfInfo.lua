-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

local fields = require("message")
local xp_dss_EnDssDlCrmSfInfoExtensions = require("xp/dss/EnDssDlCrmSfInfoExtensions")


-- This IE defines parameters that are used for the Common Resource Management algorithm for Downlink in the CRM.
function EnDssDlCrmSfInfo (fieldName, position)
    return
        fields.Structure({name="EnDssDlCrmSfInfo", fieldName=fieldName, position=position, size=132}, {
            fields.uint8({name="enDssKeepAliveDlRepetitionTimer", position=0}),
            fields.Padding({name="enDssKeepAliveDlRepetitionTimer_thresholdForIncreasingDlSharingRatio_padding", position=1, size=3}),
            fields.StaticVariableSizedArray({name="thresholdForIncreasingDlSharingRatio", position=4, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=3},
                fields.uint32, fields.uint8({name="item", position=4})
            ),
            fields.StaticVariableSizedArray({name="thresholdForDecreasingDlSharingRatio", position=12, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=3},
                fields.uint32, fields.uint8({name="item", position=12})
            ),
            fields.StaticVariableSizedArray({name="hysteresisForDlSharingRatioChanging", position=20, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=3},
                fields.uint32, fields.uint8({name="item", position=20})
            ),
            fields.StaticVariableSizedArray({name="dlSchedulingWeightForNr", position=28, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=3},
                fields.uint32, fields.uint8({name="item", position=28})
            ),
            fields.StaticVariableSizedArray({name="dlSchedulingWeightForLte", position=36, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=3},
                fields.uint32, fields.uint8({name="item", position=36})
            ),
            fields.StaticVariableSizedArray({name="enDssDlQoSLoadMeasurementTimer", position=44, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=2},
                fields.uint32, fields.uint16({name="item", position=44})
            ),
            fields.StaticVariableSizedArray({name="enDssDlResourceAllocationTimer", position=52, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=2},
                fields.uint32, fields.uint16({name="item", position=52})
            ),
            fields.StaticVariableSizedArray({name="enDssDlRemovalTimer", position=60, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=2},
                fields.uint32, fields.uint16({name="item", position=60})
            ),
            fields.StaticVariableSizedArray({name="enDssDlMinSfSharingRatioUpdateTimer", position=68, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=3},
                fields.uint32, fields.uint8({name="item", position=68})
            ),
            fields.StaticVariableSizedArray({name="lteNrDssDlNonGbrStepSize", position=76, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=3},
                fields.uint32, fields.uint8({name="item", position=76})
            ),
            fields.StaticVariableSizedArray({name="lteNrDssDlGbrStepSize", position=84, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=3},
                fields.uint32, fields.uint8({name="item", position=84})
            ),
            fields.StaticVariableSizedArray({name="lteNrDssDlLteGbrUpThresh", position=92, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=3},
                fields.uint32, fields.uint8({name="item", position=92})
            ),
            fields.StaticVariableSizedArray({name="lteNrDssDlNrPdcchUpThresh", position=100, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=3},
                fields.uint32, fields.uint8({name="item", position=100})
            ),
            fields.StaticVariableSizedArray({name="asgnDlMinValue", position=108, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=3},
                fields.uint32, fields.uint8({name="item", position=108})
            ),
            fields.StaticVariableSizedArray({name="asgnDlMaxValue", position=116, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=3},
                fields.uint32, fields.uint8({name="item", position=116})
            ),
            xp_dss_EnDssDlCrmSfInfoExtensions("extensions", 124),
        })
end

return EnDssDlCrmSfInfo
