local encoder = {}

-- Encode a value into a n-bit big-endian value.
function encoder.encode_be(bits, v, trim)
    assert(bits % 8 == 0, "bits must be a multiple of 8")
    local bytes = bits // 8
    local res
    if type(v) == "string" and v:find("^0[xX][0-9a-fA-F]+$") then
        res = v:sub(3):gsub("%x%x", function(bytehex) return string.char(tonumber(bytehex, 16)) end)
    elseif math.type(v) == "integer" then
        res = string.pack(">I8", v):gsub("^\x00+", "")
    else
        error("cannot encode value '" .. tostring(v) .. "' to " .. bits .. " bit big endian")
    end
    if #res < bytes then -- add padding
        res = string.rep("\x00", bytes - #res) .. res
    elseif #res > bytes then
        error("value is too large to be encoded into " .. bits .. " bit big endian")
    end
    if trim then
        res = res:gsub("^\x00+", "")
        if res == "" then res = "\x00" end
    end
    return res
end

function encoder.encode_be256(v)
    if math.type(v) == "integer" then
        return string.pack(">I16I16", 0, v)
    elseif type(v) == "string" and #v == 32 then
        return v
    else
        return encoder.encode_be(256, v)
    end
end

function encoder.encode_erc20_address(v)
    if type(v) == "string" and #v == 20 then
        return v
    else -- numeric or hexadecimal encoding
        return encoder.encode_be(160, v)
    end
end

function encoder.encode_erc20_deposit(deposit)
    local payload = (deposit.successful ~= false and "\x01" or "\x00")
        .. encoder.encode_erc20_address(deposit.contract_address)
        .. encoder.encode_erc20_address(deposit.sender_address)
        .. encoder.encode_be256(deposit.amount)
    if deposit.extra_data then payload = payload .. deposit.extra_data end
    return payload
end

function encoder.encode_erc20_transfer_voucher(voucher)
    return "\169\5\156\187" -- First 4 bytes of "transfer(address,uint256)".
        .. "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00" -- 12 bytes of padding zeros
        .. encoder.encode_erc20_address(voucher.destination_address)
        .. encoder.encode_be256(voucher.amount)
end

function encoder.encode_ether_deposit(deposit)
    local payload = encoder.encode_erc20_address(deposit.sender_address)
        .. encoder.encode_be256(deposit.amount)
    if deposit.extra_data then payload = payload .. deposit.extra_data end
    return payload
end

function encoder.encode_ether_transfer_voucher(voucher)
    return "\x52\x2f\x68\x15" -- First 4 bytes of "withdrawEther(address,uint256)".
        .. "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00" -- 12 bytes of padding zeros
        .. encoder.encode_erc20_address(voucher.destination_address)
        .. encoder.encode_be256(voucher.amount)
end

function encoder.fromhex(s)
  local hexpart = assert(s:match'^0[xX]([0-9a-fA-F]+)$', 'malformed hexadecimal data')
  return hexpart:gsub('..', function(x) return string.char(tonumber(x, 16)) end)
end

function encoder.tohex(s)
    if math.type(s) == 'integer' then
        return '0x'..string.format('%x', s)
    else
        return '0x'..s:gsub('.', function(x) return ('%02x'):format(string.byte(x)) end)
    end
end

return encoder
