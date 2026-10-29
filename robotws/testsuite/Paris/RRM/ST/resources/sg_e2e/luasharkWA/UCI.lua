total_info = {}
local UCI = Proto('UCI', 'UCI')
local uci = UCI.fields

local PUCCHRECEIVEREQ_LOCATION_PAYLOAD_OFFSET = 8
local PUCCHRECEIVEREQ_INFO_PAYLOAD_OFFSET = 36
local PUCCHRECEIVERESPPS_LOCATION_PAYLOAD_OFFSET = 0
local PUCCHRECEIVERESPPS_INFO_PAYLOAD_OFFSET = 52

uci.AN = ProtoField.string('uci.AN', 'AN', base.UNICODE)
uci.SR = ProtoField.uint8('uci.SR', 'SR', base.DEC)
uci.RI = ProtoField.uint8('uci.RI', 'RI', base.DEC)
uci.PMI = ProtoField.uint8('uci.PMI', 'PMI', base.DEC)
uci.CQI = ProtoField.uint8('uci.CQI', 'CQI', base.DEC)
uci.primaryBeamIdx = ProtoField.uint8('uci.primaryBeamIdx', 'primaryBeamIdx', base.DEC)
uci.seconderBeamIdx = ProtoField.uint8('uci.seconderBeamIdx', 'seconderBeamIdx', base.DEC)
uci.primaryBeamRSRP = ProtoField.uint8('uci.primaryBeamRSRP', 'primaryBeamRSRP', base.DEC)
uci.seconderBeamRSRP = ProtoField.uint8('uci.seconderBeamRSRP', 'seconderBeamRSRP', base.DEC)

local ssb_number_tab = {
     { 1, "SSB number: 2"           , 2 },
     { 2, "SSB number: 4"           , 4 },
     { 3, "SSB number: 8"           , 8 },
     { 4, "SSB number: 16"          , 16 },
     { 5, "SSB number: 32"          , 32 },
  }

local bit8table = {{uci.SR,1}, {uci.RI,1}, {uci.PMI,2}, {uci.CQI,4}}
local bit7table = {{uci.RI,1}, {uci.PMI,2}, {uci.CQI,4}}
local bit12table = {{uci.SR,1}, {uci.RI,2}, {uci.PMI,5}, {uci.CQI,4}}
local bit11table = {{uci.SR,1}, {uci.RI,1}, {uci.PMI,5}, {uci.CQI,4}}
local switch = {[7] = bit7table,[8] = bit8table,[11] = bit11table,[12] = bit12table}

UCI.prefs.ssb_number = Pref.enum("SSB number table:", 2, "SSB number table", ssb_number_tab, true)

get_position = function(offset_, size_)
  local start_byte_ = math.floor((offset_+1)/8)
  local start_offset_ = (offset_+1)%8
  local end_byte_ = math.floor((offset_+size_)/8)
  local end_offset_ = ((offset_+size_)%8)
  local len_bytes_ = end_byte_ - start_byte_ + 1
  return start_byte_, start_offset_, end_byte_, end_offset_, len_bytes_
end

local function get_common_intvalue(buffer, bit_offset, bit_len)
    start_byte, start_offset, end_byte, end_offset, len_bytes = get_position(bit_offset,bit_len)
    value = buffer(start_byte, len_bytes):le_uint()
    return value
end

function get_pucchreceivreq_info_dissector(buffer, offset)
  local pucchreceivreq_info = {}
  initial_offset = offset + PUCCHRECEIVEREQ_LOCATION_PAYLOAD_OFFSET
  initial_bit_offset = initial_offset*8-1

  offset = initial_offset
  bit_offset = initial_bit_offset
  local req_sfn_bit_len = 16
  req_sfn = get_common_intvalue(buffer, bit_offset, req_sfn_bit_len) --buffer(start_byte, len_bytes):bitfield(start_offset,bit_len)
  pucchreceivreq_info[1] = req_sfn

  bit_offset = bit_offset + req_sfn_bit_len
  local req_slot_bit_len = 8
  req_slot = get_common_intvalue(buffer, bit_offset, req_slot_bit_len)
  pucchreceivreq_info[2] = req_slot

  bit_offset = bit_offset + req_slot_bit_len + PUCCHRECEIVEREQ_INFO_PAYLOAD_OFFSET*8
  local nANPucch_bit_len = 8
  nANPucch = get_common_intvalue(buffer, bit_offset, nANPucch_bit_len)
  pucchreceivreq_info[3] = nANPucch

  bit_offset = bit_offset + nANPucch_bit_len
  local nOfBitOfUCI_bit_len = 8
  nOfBitOfUCI = get_common_intvalue(buffer, bit_offset, nOfBitOfUCI_bit_len)
  pucchreceivreq_info[4] = nOfBitOfUCI

  table.insert(total_info, pucchreceivreq_info)
end

function get_req_info(sfn, slot)
  local uci_length_in_bits = 0
  local nANPucch = 0
  if next(total_info) ~= nil then
    local start_check_sfn = total_info[#total_info][1]
    local check_threshold = 0
    for i=#total_info, 1, -1 do
      if start_check_sfn ~= total_info[i][1] then
        check_threshold = check_threshold + 1
        start_check_sfn = total_info[i][1]
      end
      if check_threshold < 2 then
        if sfn == total_info[i][1] and slot == total_info[i][2] then
            uci_length_in_bits = total_info[i][4] - total_info[i][3]
            nANPucch = total_info[i][3]
        end
      else
        table.remove(total_info, i)
      end
    end
  end
  return uci_length_in_bits, nANPucch
end


local function set_common_bitfield_with_table(buffer, uci_tree, bit_offset, field_object_table)
    for k,v in pairs(field_object_table) do
      local field_object = v[1]
      local bit_len = v[2]
      start_byte, start_offset, end_byte, end_offset, len_bytes = get_position(bit_offset,bit_len)
      uci_tree:add (field_object,buffer(start_byte,len_bytes),buffer(start_byte, len_bytes):bitfield(start_offset,bit_len))
      bit_offset = bit_offset + bit_len
    end
end

local function decode_uci(uci_length_in_bits, buffer, uciPayloadTree, bit_offset)
  if uci_length_in_bits > 12 then
    local bit_greater_than_12_table = {{uci.primaryBeamIdx,math.log10(UCI.prefs.ssb_number)/math.log10(2)},
        {uci.seconderBeamIdx,math.log10(UCI.prefs.ssb_number)/math.log10(2)}, {uci.primaryBeamRSRP,7}, {uci.seconderBeamRSRP,4}}
    set_common_bitfield_with_table(buffer, uciPayloadTree, bit_offset, bit_greater_than_12_table)
  else
    local bit_table = switch[uci_length_in_bits]
    if bit_table ~= nil then
      set_common_bitfield_with_table(buffer, uciPayloadTree, bit_offset, bit_table)
    end
  end
end 

local function set_common_bitfield(buffer, uci_tree, bit_offset, field_object, bit_len)
    start_byte, start_offset, end_byte, end_offset, len_bytes = get_position(bit_offset,bit_len)
    uci_tree:add (field_object,buffer(start_byte,len_bytes),buffer(start_byte, len_bytes):bitfield(start_offset,bit_len))
    bit_offset = bit_offset + bit_len
    return bit_offset
end


function get_pucchreceiverespps_decode_info_dissector(buffer, offset, tree)
  local uci_length_in_bits = 0
  local nANPucch = 0
  local pucchreceivreq_info = {}
  initial_offset = offset + PUCCHRECEIVERESPPS_LOCATION_PAYLOAD_OFFSET
  initial_bit_offset = initial_offset*8-1
  offset = initial_offset
  bit_offset = initial_bit_offset
  local respps_sfn_bit_len = 16
  respps_sfn = get_common_intvalue(buffer, bit_offset, respps_sfn_bit_len)
  pucchreceivreq_info[1] = respps_sfn
  bit_offset = bit_offset + respps_sfn_bit_len
  local respps_slot_bit_len = 8
  respps_slot = get_common_intvalue(buffer, bit_offset, respps_slot_bit_len)
  pucchreceivreq_info[2] = respps_slot

  uci_length_in_bits, nANPucch = get_req_info(respps_sfn, respps_slot)
  initial_offset = offset + PUCCHRECEIVERESPPS_INFO_PAYLOAD_OFFSET
  initial_bit_offset = initial_offset*8-1
  offset = initial_offset
  bit_offset = initial_bit_offset

  if uci_length_in_bits > 0 then
    if nANPucch > 0 then
      local uci_length = math.floor(((uci_length_in_bits + nANPucch)/8)+0.5)
      local uciPayloadTree = tree:add (UCI, buffer(offset, uci_length))
      bit_offset = set_common_bitfield(buffer, uciPayloadTree, bit_offset, uci.AN, nANPucch)
      decode_uci(uci_length_in_bits, buffer, uciPayloadTree, bit_offset)
    else
      local uci_length = math.floor(((uci_length_in_bits)/8)+0.5)
      local uciPayloadTree = tree:add (UCI, buffer(offset, uci_length))
      decode_uci(uci_length_in_bits, buffer, uciPayloadTree, bit_offset)
    end
    
  end
end