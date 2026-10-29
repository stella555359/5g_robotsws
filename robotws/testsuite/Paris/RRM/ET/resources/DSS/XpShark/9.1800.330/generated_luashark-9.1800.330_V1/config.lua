---- LuaShark Configuration File
return {
  debug_prints = false,       -- Print debug logs to console
  name_path_flag = false,
  interface_list = {          -- Interface list to be imported (e.g. "all", "DlData", "UlData", ...<namespace of interface>)
    "all",
  },
  fields = {
    display_func_name = true,      -- Display Field function/type name
  },
  arrays = {
    expand_item_field = true,     -- Expand array item Field.
    expand_item_structure = true,  -- Expand array item Structure
    expand_item_ep = true,         -- Expand array item Embedded Protocol
    expand_item_bitset = true,     -- Expand array item Bitset
    expand_item_union = true,      -- Expand array item Union
    expand_max_items = 1024,       -- Maximum number of items to be expanded
  },
  endpoint = {
    litte_endian = true,      -- Interface end-point endianess
  },
  embeddedProtocol = {
    dir_name = nil,   -- Embedded protocols lua files directory relative to luashark.lua path
    xp_dir_name = "protocols",    -- Embedded protocols lua files directory relative to xpshark.lua path
  },
  file_search_depth = 7,      -- the depth to find all lua files
  xpshark_port = {32742},    --list of ports {int,int...}; XPAP protocol interaction via these ports of sctp and udp
  xp_protocol_id = 0x761B,    --interger; the id of XPAP protocol which is defined in intertfaces files
}
