AddCSLuaFile()

function UTILS_AddClass(sfile,cfunc,cname)
	local oldc = _G[cname]
	_G[cname] = {} 
	include(sfile)
	/*
	local fndata = file.Read( sfile, "LUA" )
	if not fndata then
		Error("File not found: "..sfile)
	end
	//PrintTable(_G[cname])
	RunString(fndata, "UTILS_AddClass."..cname, true )
	 
	//PrintTable(_G[cname])
	*/
	local result = _G[cname]
	if result.base then
		local base = cfunc(result.base) or {}
		local newbase = table.Copy( base)
		table.Merge(base,result) 
		result = base 
		result._base = newbase 
	end
	_G[cname] = oldc or {}
	return result
end 