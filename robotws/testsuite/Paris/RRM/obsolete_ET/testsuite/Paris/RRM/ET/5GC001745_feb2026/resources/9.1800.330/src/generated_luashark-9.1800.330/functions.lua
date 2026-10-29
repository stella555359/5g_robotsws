local config = require("config")
local luadbg = require("debug")
-------------------------------------------------------------------------------
-- local functions for helper functions
-------------------------------------------------------------------------------
local dissectorTable = {}
local id_location = {}

local function print_table(tbl)
    for k,v in pairs(tbl) do
      print("k="..k.." v="..tostring(v))
    end
end

local function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

local function get_dir_list(path, debug)
    local debug = debug or false
    local t = {}
    local cmd = nil
    if get_os() == "Linux" then
      cmd = 'find "'..path..'" -type d'
    elseif get_os() == "Windows" then
      cmd = 'dir "'..path..'" /b /ad /s'
    end
    local p = io.popen(cmd)
    for subDir in p:lines() do
      if subDir ~= path then
        table.insert(t, subDir)
      end
    end
    if debug then print_table(t) end
    return t
end

local function escape(str)
    return string.gsub(str, "[%(%)%.%+%-%*%?%[%]%^%$%%]", "%%%1") -- escape pattern
end

local function registerDissectorModule(dissectorModule, fileDir, dissectorFile)
  local diss = dissectorModule:generateProtoFields()
  if diss then
    dissectorTable[dissectorModule:protoName()] = dissectorModule
    id_location[dissectorModule:messageId()] = fileDir..dissectorFile
  else
    local file_one = GetFileContents(fileDir..dissectorFile)
    local file_two = GetFileContents(id_location[dissectorModule:messageId()])
    if file_one ~= file_two then
      error(("Different files with same message IDs: \n%s\n%s"):
      format(fileDir..dissectorFile, id_location[dissectorModule:messageId()]))
    else
      print(("Warning:Identical messages: \n%s\n%s"):
      format(fileDir..dissectorFile, id_location[dissectorModule:messageId()]))
    end
  end
end
-------------------------------------------------------------------------------
-- LUASHARK Helper functions
-------------------------------------------------------------------------------
function printn(print_string)
    if config.debug_prints then
        print(print_string)
    end
end

function split(str, pat, debug)
    local debug = debug or false
    local t = {}
    local fpat = "(.-)" .. pat
    local last_end = 1
    local s, e, cap = str:find(fpat, 1)
    while s do
      if s ~= 1 or cap ~= "" then
        table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
    end
    if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
    end
    if debug then print_table(t) end
    return t
end

function get_os()
    local cpathTable = split(package.cpath, "[;\\.]+")
    for k,v in pairs(cpathTable) do
      if v == "so" then
        return "Linux"
      elseif v == "dll" then
        return "Windows"
      end
    end
    return "UnknownOS"
end

function joinPath(first, second)
    local sep
    if get_os() == "Linux" then
      sep = "/"
    else
      sep = "\\"
    end
    return first..sep..second
end

function get_file_list(path, ftype, regex, mindepth, maxdepth, debug)
    local ftype = ftype or "f"
    local regex = regex or "*"
    local mindepth = mindepth or 1
    local maxdepth = maxdepth or 1
    local debug = debug or false
    local t = {}
    local cmd = nil
    if get_os() == "Linux" then
      cmd = 'find -L "'..path..'" '..' -mindepth '..mindepth..' -maxdepth '..maxdepth..' -name "'..tostring(regex)..'" -type '..ftype
    elseif get_os() == "Windows" then
      if ftype == "f" then
        cmd = 'dir "'..path..'\\'..tostring(regex)..'" /s/b'
      elseif ftype == "d" then
        cmd = 'echo off & for /d %a in ("'..path..'\\'..tostring(regex)..'") do echo %~fa'
      end
    end
    if debug then print("get_file_list cmd=\""..cmd.."\"") end
    local p = io.popen(cmd)
    for subDir in p:lines() do
      if subDir ~= path then
        table.insert(t, subDir)
      end
    end
    if debug then print_table(t) end
    return t
end

function script_path()
    local path = luadbg.getinfo(1).source
    local path_start = string.sub(path, 0, 1)
    if path_start == "@" then
       path = string.sub(path, 2)
    end
    return path
end

function get_dir_path(filepath)
    local dir_path = nil
    if get_os() == "Linux" then
      dir_path = filepath:match("(.*/)")
      if dir_path:sub(-1) == "/" then
        dir_path = dir_path:sub(1,-2)
      end
    elseif get_os() == "Windows" then
      dir_path = filepath:match("(.*\\)")
    end
    return dir_path
end

function get_last_path_item(filepath)
    local pathTable = {}
    if get_os() == "Linux" then
      pathTable = split(filepath, "[/]+")
    elseif get_os() == "Windows" then
      pathTable = split(filepath, "[\\]+")
    end
    return pathTable[#pathTable]
end

function has_value(tbl, value)
    if type(tbl) == "table" then
      for _, val in ipairs(tbl) do
          if val == value then
              return true
          end
      end
    else
      if tbl == value then
        return true
      end
    end
    return false
end

function getSep()
    if get_os() == "Linux" then
      return "/"
    else
      return "\\"
    end
end

function getRelativePath(fileDir, currentDir)
    local path_parts = split(fileDir, escape(currentDir), false)
    local table_length = tablelength(path_parts)
    return path_parts[table_length]
end

function GetFileContents(Filename)
    local File = io.open(Filename)
    if File then
      local Contents = File:read('*all')
      File:close()
      return Contents
    else
      print(('[%s]: Could not open file: %s'):format("luashark.lua", Filename))
      return
    end
end

function validLuaDir(interfaceDir)
  if get_last_path_item(interfaceDir) ~= config.embeddedProtocol.dir_name and
     get_last_path_item(interfaceDir) ~= config.embeddedProtocol.xp_dir_name and
     get_last_path_item(interfaceDir) ~= "luashark" then
    return true
  end
  return false
end

function matchNamespace(nameSpace, name)
  nameSpacelist = string.gmatch(nameSpace,"[%w%-_]*","")
  for nameSpace in nameSpacelist do
    if name == nameSpace then
      return name
    end
  end
  if string.match(nameSpace, name) then return name end
  return nil
end

function validInterface(nameSpace, dissectorFile, currentDir)
  local relativePath = string.gsub(nameSpace..getSep()..dissectorFile, currentDir, "")
  relativePath = string.gsub(relativePath, "%.lua", "")
  for _, name in pairs(config.interface_list) do
    if name == "all" or matchNamespace(nameSpace,name) then
      local dissectorModule = require(relativePath)
      if type(dissectorModule) == "table" then
        if dissectorModule.generateProtoFields then
          return dissectorModule
        end
      end
    end
  end
  return nil
end

function validLuaFile(dissectorFile)
  for _, name in pairs({"luashark.lua", "config.lua", "fields.lua", "xpshark.lua","functions.lua"}) do
    if dissectorFile ~= name then
      return true
    end
  end
  return false
end

function importLuaFile(filePath, currentDir)
  local fileDir = get_dir_path(filePath)
  local relative = getRelativePath(fileDir, currentDir)
  local nameSpace = string.gsub(relative, getSep(), ".")
  local dissectorFile = get_last_path_item(filePath)

  if validLuaFile(dissectorFile) then
    local dissectorModule =  validInterface(nameSpace, dissectorFile, currentDir)
    if dissectorModule ~= nil then
      registerDissectorModule(dissectorModule, fileDir, dissectorFile)
    end
  end
  return dissectorTable
end

function set_info_column(pinfo, newText)
  pinfo.cols.info:set(newText)
  pinfo.cols.info:fence()
end

-- TOBEUSE
function append_to_info_column(pinfo, newText)
  local currText = tostring(pinfo.cols.info)
  pinfo.cols.info:set(currText.."/"..newText)
  pinfo.cols.info:fence()
end

function fieldOutOfRange(offset, bufLen, fieldPosition, fieldSize)
  return (
    ((offset + fieldPosition) >= bufLen)
    or (fieldSize > bufLen)
    or ((offset + fieldPosition + fieldSize) > bufLen)
    )
end

function printMalformedWarn(tree, buffer, offset, field, fieldSize)
  if fieldSize == nil then
    fieldSize = field.size
  end
  tree:add_expert_info(PI_MALFORMED, PI_WARN,
      "Not enough bytes in buffer to read "..field.name.." field "..
      "(field.position="..field.position.." + field.size="..fieldSize..
      " + offset="..offset.." > buffer.size="..buffer:len()..")")
end
