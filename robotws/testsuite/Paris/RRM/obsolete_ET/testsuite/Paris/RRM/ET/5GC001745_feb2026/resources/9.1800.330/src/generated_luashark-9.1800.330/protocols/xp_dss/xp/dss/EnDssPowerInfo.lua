-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

local fields = require("message")
local xp_dss_GuardbandPosition = require("xp/dss/GuardbandPosition")
local xp_dss_EnDssPowerInfoExtensions = require("xp/dss/EnDssPowerInfoExtensions")


-- The IE defines the power and boosting related settings.
--      The CRM checks during the cell DL coordination procedure whether the powerInfos reported from the CRM clients are matching.
function EnDssPowerInfo (fieldName, position)
    return
        fields.Structure({name="EnDssPowerInfo", fieldName=fieldName, position=position, size=44}, {
            fields.uint16({name="pMax", position=0}),
            fields.Padding({name="pMax_nBIoTPower_padding", position=2, size=2}),
            fields.StaticVariableSizedArray({name="nBIoTPower", position=4, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=2},
                fields.uint32, fields.int16({name="item", position=4})
            ),
            fields.StaticVariableSizedArray({name="nBIoTPowerBoost", position=12, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=2},
                fields.uint32, fields.uint16({name="item", position=12})
            ),
            fields.StaticVariableSizedArray({name="commonBoost", position=20, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=3},
                fields.uint32, fields.uint8({name="item", position=20})
            ),
            fields.StaticVariableSizedArray({name="nBIoTGuardbandPosition", position=28, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=0},
                fields.uint32, fields.enumeration(
                    {name="item", position=28, enumTerm=xp_dss_GuardbandPosition},
                    ProtoField.int32, 4, "int32")
            ),
            xp_dss_EnDssPowerInfoExtensions("extensions", 36),
        })
end

return EnDssPowerInfo
