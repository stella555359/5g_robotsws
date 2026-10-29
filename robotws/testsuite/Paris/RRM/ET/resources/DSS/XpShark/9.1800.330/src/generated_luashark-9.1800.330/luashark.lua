--[[
  Copyright 2019 Nokia

  XP protocols Wireshark Lua Dissector Script

  Wireshark Lua API:
    https://wiki.wireshark.org/Lua
    https://wiki.wireshark.org/LuaAPI

  Wireshark Developer’s Guide:
    https://www.wireshark.org/docs/wsdg_html_chunked/PartDevelopment.html
    https://www.wireshark.org/docs/wsdg_html_chunked/wsluarm_modules.html

  XP protocols introduction:
    https://confluence.int.net.nokia.com/pages/viewpage.action?pageId=911374906
--]]

-------------------------------------------------------------------------------
-- LuaShark local modules and packages
-------------------------------------------------------------------------------

-- From standard LUA
local package = require("package")
local io = require("io")
local tostring = tostring
local tonumber = tonumber
local pairs = pairs
local ipairs = ipairs
local type = type
local table = table
local pcall = pcall
local format = string.format
local string = string
local PI_PROTOCOL = PI_PROTOCOL
local PI_WARN = PI_WARN

-- Set LuaShark Plugin Information
local luashark_info = {
  version = "0.2.19",
  requires = "WiresharkLTE_v2.4.5.lte.1803.01 (or newer)",
  author = "MuLTI",
  description = "This plugin dissects payloads contained in SICP (syscom) and BIP messages",
  repository = "https://gerrit.ext.net.nokia.com/gerrit/#/admin/projects/MN/5G/COMMON/multi",
}
set_plugin_info(luashark_info)

-------------------------------------------------------------------------------
-- Check Wireshark Version
-------------------------------------------------------------------------------
-- Get Wireshark version
local wireshark_version = get_version()

v1, v2, v3, v4, v5, v6 = string.match(wireshark_version, "(%d+).(%d+).(%d+).(%w+).(%w+).(%w+)")
r1, r2, r3, r4, r5, r6 = string.match(luashark_info.requires, "(%d+).(%d+).(%d+).(%w+).(%w+).(%w+)")

-- combine v1/v2/v3 and r1/r2/r3
v1_2_3 = tonumber(v1) * 10000 + tonumber(v2) * 100 + tonumber(v3)
r1_2_3 = tonumber(r1) * 10000 + tonumber(r2) * 100 + tonumber(r3)

-- combine v5/v6 and r5/r6
v5_6 = tonumber(v5) * 100 + tonumber(v6)
r5_6 = tonumber(r5) * 100 + tonumber(r6)

if not (v1 and v2 and v3 and v4 and v5 and v6) then
  error("Wireshark version '"..wireshark_version.."' is not supported. "..
        "Please use "..luashark_info.requires..".")
else
  if not (tonumber(v1_2_3) >= tonumber(r1_2_3) and
          tostring(v4) == tostring(r4) and
          tonumber(v5_6) >= tonumber(r5_6)) then
    error("WiresharkLTE  version '"..wireshark_version.."' is not supported. "..
          "Please use "..luashark_info.requires..".")
  end
end

-------------------------------------------------------------------------------
-- Add path in script argument to package.path
-------------------------------------------------------------------------------
for i, path in ipairs({...}) do
  package.path = package.path .. ';'..path.."/?.lua"
end

-------------------------------------------------------------------------------
-- LuaShark local variables and import common functions
-------------------------------------------------------------------------------
require("functions")
local config = require("config")
local dissectorTable = {}
local print = printn

-------------------------------------------------------------------------------
-- Wireshark Dissector Tables
-------------------------------------------------------------------------------
print("Dissector:")
for v,k in pairs(Dissector.list()) do
  print("  Dissector["..v.."]="..k)
end

print("DissectorTable:")
for v,k in pairs(DissectorTable.list()) do
  print("  DissectorTable["..v.."]="..k)
end

-------------------------------------------------------------------------------
-- Get Wireshark Dissectors
-------------------------------------------------------------------------------
local udp_table    = DissectorTable.get("udp.port")
local sctp_table   = DissectorTable.get("sctp.port")
local sic_table    = DissectorTable.get("sic.msgid")
local bip_ec_table = DissectorTable.get("bip_ec.messageid")

-------------------------------------------------------------------------------
-- Field Extractors from transport layer (e.g. sic and bip)
-------------------------------------------------------------------------------
local f_sic_msgid            = Field.new("sic.msgid")
local f_sic_length           = Field.new("sic.length")
local f_bip_ec_msgid         = Field.new("bip_ec.Sw_Event.MessageID")
local f_bip_ec_eventSize     = Field.new("bip_ec.eventSize")
local f_bip_ec_fragmentIndex = Field.new("bip_ec.fragmentIndex")

local function extract_transport_layer_fields(buffer, pinfo)
  local msgId
  local msgLen
  local offset = 0
  local f_sic_msgid_field = f_sic_msgid()
  local f_sic_length_field = f_sic_length()
  local f_bip_ec_msgid_field = f_bip_ec_msgid()
  local f_bip_ec_eventSize_field = f_bip_ec_eventSize()

  if f_sic_msgid_field and f_sic_length_field then
    msgId = f_sic_msgid_field()
    msgLen = f_sic_length_field()
  elseif f_bip_ec_msgid_field and f_bip_ec_eventSize_field then
    msgId = f_bip_ec_msgid_field()
    msgLen = f_bip_ec_eventSize_field()
  else
    error("could not find Message ID and Length fields from SICP or BIP EC")
  end
  return msgId, msgLen, offset
end

-------------------------------------------------------------------------------
-- interfaces dissector over syscom/bip
-------------------------------------------------------------------------------
local sicBipInterface = Proto("sic_bip_interface", "syscom bip interface")
sicBipInterface.fields.payload = ProtoField.bytes("sicBipInterface.payload", "payload", base.NONE)

function sicBipInterface.dissector(buffer, pinfo, tree)
  --TODO: support for bip fragments in DL and UL user plane messages
  local msgId, msgLen, offset = extract_transport_layer_fields(buffer, pinfo)
  local subtree = tree

  local dissectorFound = false
  local colinfo = ""
  for dissectorName,dissectorObj in pairs(dissectorTable) do
    if has_value(dissectorObj:messageId(), msgId) then
      set_info_column(pinfo, dissectorName)
      dissectorObj:dissector(buffer, offset, pinfo, subtree, msgLen)
      dissectorFound = true
      break
    end
  end
  if not dissectorFound then
    local msgIdStr = "msgId="..tostring(msgId)
    if msgId ~= nil then msgIdStr = format("msgId=0x%04x", msgId) end
    set_info_column(pinfo, msgIdStr)
    subtree:add (sicBipInterface.fields.payload, buffer(offset))
    subtree:add_expert_info(PI_PROTOCOL, PI_WARN, "could not find dissector for "..msgIdStr)
  end
end
-------------------------------------------------------------------------------
-- Import Dissectors from all Interfaces Sub-Directories
-------------------------------------------------------------------------------
local luasharkScriptPath = script_path()
local luasharkDirPath = get_dir_path(luasharkScriptPath)
print("--------------------------------------------------")
print("Wireshark Version: "..wireshark_version)
print("Operating System: "..get_os())
print("LuaShark Script path: "..luasharkScriptPath)
print("LuaShark Directory path: "..luasharkDirPath)
print("--------------------------------------------------")
for _, interfaceDir in pairs(get_file_list(luasharkDirPath, "d", "*", 1, 1)) do
  package.path = package.path .. ';'..interfaceDir..'/?.lua'
  if validLuaDir(interfaceDir) then
    if get_last_path_item(interfaceDir) ~= nil then
      print("Import Protocol Dissectors from "..get_last_path_item(interfaceDir))
      for _, filePath in pairs(get_file_list(interfaceDir, "f", "*.lua", 1,
        config.file_search_depth)) do
        dissectorTable = importLuaFile(filePath, luasharkDirPath)
      end
    end
  end
end

-------------------------------------------------------------------------------
-- Subscribe interfaces Stacks
-------------------------------------------------------------------------------
-- register interfaces for SCTP and UDP Ports used for sic
for _, port in pairs({29210, 29211, 4127}) do
  udp_table:add(tonumber(port), Dissector.get("syscom"))
  sctp_table:add(tonumber(port), Dissector.get("syscom"))
end

-- register interfaces's msgIds for sic and bip_ec
for _, sysMsg in pairs(dissectorTable) do
    sic_table:add(tonumber(sysMsg:messageId()), sicBipInterface)
    bip_ec_table:add(tonumber(sysMsg:messageId()), sicBipInterface)
end

-------------------------------------------------------------------------------
-- XPAP dissectors and embedded Protocols
-------------------------------------------------------------------------------
local xpap = nil
-------------------------------------------------------------------------------
-- interfaces for Import Embedded Protocols for XPAP
-------------------------------------------------------------------------------
local function embedded_protocol_dissector_add_into_xpap (protoFile, ep_table)
  local protoObj = require(protoFile)
  if type(protoObj) == "table" then
    if protoObj.generateProtoFields then
      protoObj:generateProtoFields()
      local fileProto = protoObj:getProto()
      function fileProto.dissector(buffer, pinfo, tree)
        set_info_column(pinfo, xpap.name .. "/" .. fileProto.name)
        protoObj:dissector(buffer, 0, pinfo, tree)
      end
      ep_table:add(tonumber(protoObj:messageId()), fileProto)
      if config.xp_protocol_id ~= nil then
        sic_table:add(tonumber(protoObj:messageId()), xpap)
      end
    end
  end
end
local function import_embedded_protocol_dissector (interfaceDir, ep_table)
  for _, filePath in pairs(get_file_list(interfaceDir, "f", "*.lua", 1, 3)) do
    package.path = package.path .. ';'..joinPath(get_dir_path(filePath), '/?.lua')
    local protoFile = split(get_last_path_item(filePath), "[\\.]+")[1]
    print("Import Embedded Protocol Dissector "..protoFile)
    embedded_protocol_dissector_add_into_xpap (protoFile, ep_table)
  end
end
-------------------------------------------------------------------------------
-- XPAP Dissectors over SCTP/UDP
-------------------------------------------------------------------------------
if config.xp_protocol_id ~= nil then
  print("Import XPAP Dissectors")
  local XPAPid = config.xp_protocol_id
  local xpapObj = nil

  for dissectorName, dissectorObj in pairs(dissectorTable) do
    if has_value(dissectorObj:messageId(), XPAPid) then
      xpapObj = dissectorObj
      break
    end
  end
  if xpapObj ~=nil then
    xpap = xpapObj:getProto()
    xpap.fields.payload = ProtoField.bytes("XPAP.payload", "payload", base.NONE)

    function xpap.dissector(buffer, pinfo, subtree)
      xpapObj:dissector(buffer, 0, pinfo, subtree)
    end
    -------------------------------------------------------------------------------
    -- Subscribe XPAP Protocol Stacks over SCTP/UDP
    -------------------------------------------------------------------------------
    -- register XPAP for SCTP and UDP Ports config.xpshark_port
    for _, port in pairs(config.xpshark_port) do
      udp_table:add(tonumber(port), xpap)
      sctp_table:add(tonumber(port), xpap)
    end
    -------------------------------------------------------------------------------
    -- Import Embedded Protocols for XPAP
    -------------------------------------------------------------------------------
    if config.embeddedProtocol.xp_dir_name ~= nil then
      for _, interfaceDir in pairs(get_file_list(joinPath(luasharkDirPath, config.embeddedProtocol.xp_dir_name), "d", "*", 1, 1)) do
        package.path = package.path .. ';'..joinPath(interfaceDir, '/?.lua')
        local protoObj = get_last_path_item(interfaceDir)
        local ep_table = DissectorTable.new(tostring(protoObj))
        import_embedded_protocol_dissector (interfaceDir, ep_table)
      end
    end
  end
end
