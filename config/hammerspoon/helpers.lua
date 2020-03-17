local M = {}
M.getTableKeys = function(tab)
    local keyset = {}
    for k, _ in pairs(tab) do
        keyset[#keyset + 1] = k
    end
    return keyset
end

threshold = .01
M.approxEqualTables = function(left, right)
    isApproxEqual = true
    for key, _ in pairs(left) do
        if math.abs(left[key] - right[key]) > threshold then
            isApproxEqual = false
        end
    end
    return isApproxEqual
end

return M
