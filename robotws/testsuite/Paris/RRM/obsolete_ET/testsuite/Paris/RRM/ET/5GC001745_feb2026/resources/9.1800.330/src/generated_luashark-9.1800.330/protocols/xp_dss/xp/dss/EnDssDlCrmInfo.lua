-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

local fields = require("message")
local xp_dss_EnDssDlCrmInfoExtensions = require("xp/dss/EnDssDlCrmInfoExtensions")


-- This IE defines parameters that are used for the Common Resource Management algorithm in the CRM.
function EnDssDlCrmInfo (fieldName, position)
    return
        fields.Structure({name="EnDssDlCrmInfo", fieldName=fieldName, position=position, size=84}, {
            fields.uint8({name="enDssKeepAliveRepetitionTimer", position=0}),
            fields.Padding({name="enDssKeepAliveRepetitionTimer_enDssMinMbsfnSharingRatioUpdateTimer_padding", position=1, size=3}),
            fields.StaticVariableSizedArray({name="enDssMinMbsfnSharingRatioUpdateTimer", position=4, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=3},
                fields.uint32, fields.uint8({name="item", position=4})
            ),
            fields.StaticVariableSizedArray({name="thresholdForIncreasingTheSharingRatio", position=12, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=3},
                fields.uint32, fields.uint8({name="item", position=12})
            ),
            fields.StaticVariableSizedArray({name="thresholdForDecreasingTheSharingRatio", position=20, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=3},
                fields.uint32, fields.uint8({name="item", position=20})
            ),
            fields.StaticVariableSizedArray({name="hysteresisForSharingRatioChanging", position=28, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=3},
                fields.uint32, fields.uint8({name="item", position=28})
            ),
            fields.StaticVariableSizedArray({name="schedulingWeightForNr", position=36, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=3},
                fields.uint32, fields.uint8({name="item", position=36})
            ),
            fields.StaticVariableSizedArray({name="schedulingWeightForLte", position=44, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=3},
                fields.uint32, fields.uint8({name="item", position=44})
            ),
            fields.StaticVariableSizedArray({name="enDssDlLoadMeasurementTimer", position=52, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=2},
                fields.uint32, fields.uint16({name="item", position=52})
            ),
            fields.StaticVariableSizedArray({name="enDssResourceAllocationTimer", position=60, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=2},
                fields.uint32, fields.uint16({name="item", position=60})
            ),
            fields.StaticVariableSizedArray({name="enDssRemovalTimer", position=68, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=2},
                fields.uint32, fields.uint16({name="item", position=68})
            ),
            xp_dss_EnDssDlCrmInfoExtensions("extensions", 76),
        })
end

return EnDssDlCrmInfo
