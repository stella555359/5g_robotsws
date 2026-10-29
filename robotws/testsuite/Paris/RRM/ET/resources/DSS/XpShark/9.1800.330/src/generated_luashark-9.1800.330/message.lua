local Proto = Proto
local pairs = pairs
local xpcall = xpcall
local debug = require("debug")
local print = print
local tostring = tostring
local config = require("config")
local structure = require("structure")
local arrays = require("arrays")
local fields = require("fields")
local unions = require("unions")
local bitset = require("bitset")
local ep = require("embeddedProtocols")
local tti = require("ttiStreamingType")
local enum = require("enumeration")
local ept = require("extensionPoint")
local str = require("stringType")

local function mprint(msg)
  if config.debug_prints then
    print("message.lua: "..msg)
  end
end

local m = {
  Structure = structure.StructureField,
  StaticUnion = unions.StaticUnionField,
  DynamicUnion = unions.DynamicUnionField,
  uint8 = fields.Uint8Field,
  uint16 = fields.Uint16Field,
  uint32 = fields.Uint32Field,
  uint64 = fields.Uint64Field,
  int8 = fields.Int8Field,
  int16 = fields.Int16Field,
  int32 = fields.Int32Field,
  int64 = fields.Int64Field,
  float32 = fields.Float32Field,
  boolean = fields.BooleanField,
  Padding = fields.PaddingField,
  byte = fields.ByteField,
  void = fields.VoidField,
  StaticFixedSizedArray = arrays.StaticFixedSizedArrayField,
  StaticVariableSizedArray = arrays.StaticVariableSizedArrayField,
  DynamicVariableSizedArray = arrays.DynamicVariableSizedArrayField,
  DynamicPackedArray = arrays.DynamicPackedArrayField,
  DynamicEmbeddedProtocol = ep.DynamicEmbeddedProtocol,
  StaticEmbeddedProtocol = ep.StaticEmbeddedProtocol,
  BitSet = bitset.BitSetField,
  String = str.StringField,
  TtiStreamingType = tti.TtiStreamingType,
  enumeration = enum.Field,
  ExtensionPoint = ept.ExtensionPointField,
  ArrayCompatibleDynamicEmbeddedProtocol = ep.ArrayCompatibleDynamicEmbeddedProtocol,
  ArrayCompatibleStaticEmbeddedProtocol = ep.ArrayCompatibleStaticEmbeddedProtocol
}

return m
