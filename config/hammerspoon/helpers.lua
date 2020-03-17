local M = {}
M.getTableKeys = function(tab)
    local keyset = {}
    for k, _ in pairs(tab) do
        keyset[#keyset + 1] = k
    end
    return keyset
end

threshold = .01
M.approxEqualRects = function(left, right)
    isApproxEqual = true
    for _, key in ipairs({'x', 'y', 'w', 'h'}) do
        if math.abs(left[key] - right[key]) > threshold then
            isApproxEqual = false
        end
    end
    return isApproxEqual
end

return M
