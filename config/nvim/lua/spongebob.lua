local spongebob = function(str)
	local ret = ""
	for i = 1, #str do
		local char = str:sub(i, i)
		if i % 2 == 0 then
			ret = ret .. char:upper()
		else
			ret = ret .. char:lower()
		end
	end
	return ret
end

return spongebob
