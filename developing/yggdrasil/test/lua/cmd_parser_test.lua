﻿--test_parser_string.lua

--require "yggr_lua_base_type"
--require "system_gm_parser"

local cmd_name = "command"
local params_name = "params"

local function get_command_and_params(cmd)
	local mode = "([%a_]+)%s*([%w\128-\253%p]*)"
	local _, _, command, params = cmd:find(mode)
	return command, params
end

local function ip_addr_dot_str_to_u32(str)
	local mode = "%s*(%d+)%s*%.%s*(%d+)%s*%.%s*(%d+)%s*%.%s*(%d+)%s*"
	local _, _, _1, _2, _3, _4 = str:find(mode)
	return  tonumber(_1) * 16777216 + tonumber(_2) * 65536 + tonumber(_3) * 256 + tonumber(_4)
end

local function parser_ip_addresses(str)
	local mode = "%s*(%d+%s*%.%s*%d+%s*%.%s*%d+%s*%.%s*%d+)%s*"

	local i = 1
	local ip_arr = {}

	for s in str:gmatch(mode) do
		ip_arr[i] = ip_addr_dot_str_to_u32(s)
		i = i + 1
	end

	return ip_arr
end

local function parser_values(str)
	local mode = "%s*([%w%._]+)%s*"
	local i = 1
	local val_arr = {}

	for s in str:gmatch(mode) do
		val_arr[i] = s
		i = i + 1
	end

	return val_arr
end

local function parser_key_value(str)
	local mode = "%s*([%a_][%w_]*)%s*=%s*([%w%._]*)"
	local _, _, key, val = str:find(mode)
	return key, tonumber(val) or val
end

local function parser_key_values(value_str)
	local mode = "([%a_][%w_]*%s*=%s*[%w%._]*)"
	local values = {}
	for s in value_str:gmatch(mode) do
		local key, val = parser_key_value(s)
		values[key] = val
	end

	return values
end

local str_cmd = "adduser --name user1 --pwd -你好 --sys_lv log--in = 100 item = 2--00 --ip_limit 192.168.2.1 192.168.2.2   " --test data
--local str_cmd = "adduser --name user1" --test data

local function parser_params_of_name_value(params_str, parse_tab)

	--local mode = "%s*%-%-([%a_][%w_%.]*)%s+([%w%s=_%.]*)%s*"
	--local mode = "%s*--([%a_]+[%w%._]*)%s+([%w%_]+[%w_%p]*)%s*"
	local mode = "[%s]--([%a_]+[%w_]*)%s+([%w_%p]*[%w%s_=%.]*[%w_]+[%w%p_]*)"
	local params_obj = {}


	print("aaaaaa", params_str)
	for name, value in params_str:gmatch(mode) do
		print("bbbbbbbbbbbb", name, value)
		--params_obj[name] = (parse_tab[name] and parse_tab[name](value) or value)
		--print("bbbbbbbbbbbb", params_str, name, params_obj[name])
	end

	return params_obj
end

local function erase_bl_space(str)

	local mode = "%s*([%w_%.]+)%s*"
	local _, _, _1 = str:find(mode)
	return _1

end

local function ref_parse_test(str)

	print("cccccc", str)
	local mode = "%s*([%w_%p]+)%s*"
	local _, _, _1 = str:find(mode)
	print(_1)
	return _1

end

-- add_user_cmd_s
local function get_params_of_adduser(cmd_obj)

	local uid = yggr.lua.utf8_string(cmd_obj[params_name]["name"])
	local pwd = yggr.lua.utf8_string(cmd_obj[params_name]["pwd"])

	local sys_lv_list = game.game_mgr.sys_wrap.sys_lv_list()


	for k, v in pairs(cmd_obj[params_name]["sys_lv"]) do
		sys_lv_list:push_back(game.game_mgr.sys_wrap.sys_lv(yggr.lua.utf8_string(k), v))
	end

	local ip_list = yggr.lua.u32_list()

	for _, ip in ipairs(cmd_obj[params_name]["ip_limit"]) do
		ip_list:push_back(ip)
	end

	return uid, pwd, sys_lv_list, ip_list
	--return uid, pwd, sys_lv_list, yggr.lua.u32_list()
	--return uid, pwd, sys_lv_list
end


local function parser_adduser_cmd(cmd_str)

	local parse_tab = {
						["sys_lv"] = parser_key_values,
						["ip_limit"] = parser_ip_addresses,
						["name"] = erase_bl_space,
						["pwd"] = ref_parse_test
					}

	return parser_params_of_name_value(cmd_str, parse_tab)
end

-- add_user_cmd_e

-- get_user_list_s
-- empty params_parse
-- get_user_list_e

-- remove_user_s

local function parser_rmuser_cmd(cmd_str)

	local parse_tab = {
							["name"] = parser_values
						}

	return parser_params_of_name_value(cmd_str, parse_tab)

end

local function get_params_of_rmuser(cmd_obj)

	local user_id_list = yggr.lua.utf8_string_list()

	for _, uid in ipairs(cmd_obj[params_name]["name"]) do
		user_id_list:push_back(yggr.lua.utf8_string(uid))
	end

	return user_id_list
end

-- remove_user_e

--set_passwd_s

local function get_params_of_setpwd(cmd_obj)

	local uid = yggr.lua.utf8_string(cmd_obj[params_name]["name"])
	local pwd = yggr.lua.utf8_string(cmd_obj[params_name]["pwd"])

	return uid, pwd
end

local function parser_setpwd_cmd(cmd_str)
	local parse_tab = {
							["name"] = erase_bl_space,
							["pwd"] = earse_bl_space
						}

	return parser_params_of_name_value(cmd_str, parse_tab)
end

--set_passwd_e

--set_system_level_s

local function get_params_of_setsyslv(cmd_obj)

	local uid = yggr.lua.utf8_string(cmd_obj[params_name]["name"])

	local sys_lv_list = game.game_mgr.sys_wrap.sys_lv_list()


	for k, v in pairs(cmd_obj[params_name]["sys_lv"]) do
		sys_lv_list:push_back(game.game_mgr.sys_wrap.sys_lv(yggr.lua.utf8_string(k), v))
	end


	return uid, sys_lv_list
end


local function parse_setsyslv_cmd(cmd_str)
	local parse_tab = {
							["name"] = erase_bl_space,
							["sys_lv"] = parser_key_values
						}

	return parser_params_of_name_value(cmd_str, parse_tab)
end

--set_system_level_e

--get_system_level_list_s

local function get_params_of_getsyslist(cmd_obj)
	local uid = yggr.lua.utf8_string(cmd_obj[params_name]["name"])
	return uid
end

local function parse_getsyslist_cmd(cmd_str)
	local parse_tab = {
							["name"] = erase_bl_space
						}

	return parser_params_of_name_value(cmd_str, parse_tab)
end


--get_system_level_list_e

--get_system_level_s

local function get_params_of_getsyslv(cmd_obj)
	local uid = yggr.lua.utf8_string(cmd_obj[params_name]["name"])
	local sys = yggr.lua.utf8_string(cmd_obj[params_name]["sys"])

	return uid, sys
end

local function parse_getsyslv_cmd(cmd_str)
	local parse_tab = {
							["name"] = erase_bl_space,
							["sys"] = erase_bl_space
						}

	return parser_params_of_name_value(cmd_str, parse_tab)
end


--get_system_level_e

--remove_system_level_s

local function get_params_of_rmsyslv(cmd_obj)
	local uid = yggr.lua.utf8_string(cmd_obj[params_name]["name"])
	local sys = yggr.lua.utf8_string_list()

	for _, v in ipairs(cmd_obj[params_name]["sys"]) do
		sys:push_back(yggr.lua.utf8_string(v))
	end

	return uid, sys
end

local function parse_rmsyslv_cmd(cmd_str)
	local parse_tab = {
							["name"] = erase_bl_space,
							["sys"] = parser_values
						}

	return parser_params_of_name_value(cmd_str, parse_tab)
end


--remove_system_level_e

--insert_ip_limit_s

local function get_params_of_insiplim(cmd_obj)
	local uid = yggr.lua.utf8_string(cmd_obj[params_name]["name"])

	local ip_list = yggr.lua.u32_list()

	for _, ip in ipairs(cmd_obj[params_name]["ip_limit"]) do
		ip_list:push_back(ip)
	end

	return uid, ip_list
end

local function parse_insiplim_cmd(cmd_str)
	local parse_tab = {
							["name"] = erase_bl_space,
							["ip_limit"] = parser_ip_addresses
						}

	return parser_params_of_name_value(cmd_str, parse_tab)
end

--insert_ip_limit_e

--get_ip_limit_s

local function get_params_of_getiplim(cmd_obj)
	local uid = yggr.lua.utf8_string(cmd_obj[params_name]["name"])
	return uid
end

local function parse_getiplim_cmd(cmd_str)
	local parse_tab = {
							["name"] = erase_bl_space
						}

	return parser_params_of_name_value(cmd_str, parse_tab)
end

--get_ip_limit_e

--remove_ip_limit_s
--use inser_ip_limit parser
--remove_ip_limit_e


-- now_sys_exception s

local function get_exception(code)
	local code_tab = {
						["E_sys_ctrl_null"] = 0x00008800,
						["E_need_level"] = 0x00008801
					}

	local msg_tab = {
						["E_sys_ctrl_null"] = "system ctrler is null or command handler is null",
						["E_need_level"] = "need accesser level"
					}

	return code_tab[code], yggr.lua.utf8_string(msg_tab[code])
end

-- now_sys_exception e

-- commit_db_s
-- empty params_parse
-- commit_db_e


local function parser_command(params_in)

	--local uid = params_in:uid()
	--local lv = params_in:lv()
	local cmd_str = params_in
	--local sys_ctrl = game.game_mgr.sys_wrap.sys_gm_wrap(params_in:sys_wrap())

	--sys_ctrl:init_single()
	local cmd_parse_tab = {
							["adduser"] = parser_adduser_cmd,
							["userlist"] = nil,
							["rmuser"] = parser_rmuser_cmd,
							["setpwd"] = parser_setpwd_cmd,
							["setsyslv"] = parse_setsyslv_cmd,
							["getsyslist"] = parse_getsyslist_cmd,
							["getsyslv"] = parse_getsyslv_cmd,
							["rmsyslv"] = parse_rmsyslv_cmd,
							["insiplim"] = parse_insiplim_cmd,
							["getiplim"] = parse_getiplim_cmd,
							["rmiplim"] = parse_insiplim_cmd,
							["commit"] = nil
						}


	local lv_check_tab = {
							["adduser"] = 8000,
							["userlist"] = 5000,
							["rmuser"] = 8000,
							["setpwd"] = 8000,
							["setsyslv"] = 8000,
							["getsyslist"] = 5000,
							["getsyslv"] = 5000,
							["rmsyslv"] = 8000,
							["insiplim"] = 8000,
							["getiplim"] = 5000,
							["rmiplim"] = 8000,
							["commit"] = 8000
						}

	local cmd_obj = {}

	local cmd, params = get_command_and_params(cmd_str)

	print("xxxxxxxxxxxxx", params)
	--if params_in:lv() < lv_check_tab[cmd] then
	--	return game.game_mgr.sys_wrap.script_out_params(get_exception("E_need_level"))
	--end

	cmd_obj[cmd_name] = cmd
	cmd_obj[params_name] = cmd_parse_tab[cmd] and cmd_parse_tab[cmd](params)

	print("yyyyyyyyyyyyy", cmd_obj[params_name]["pwd"])

	--return call_gm_sys_ctrl(cmd_obj, sys_ctrl)


end

local function utf8_strlen(str)
	local _, len = str:gsub("[^\128-\193]", "")
	return len
end

--gm_sys_parser = parser_command

--local str_cmd = "adduser --name user1 --pwd \"123--456\" --sys_lv login = 100 item = 200 --ip_limit 192,168.2.1 192.168.2.2" --test data


--parser_command(str_cmd, str_cmd)

--local test_str = "fads发大水范德萨发fa878你fsdf好fdsf啊fsdfd"



--local test_str = "--aaa 图为让他网盘额题库 --bbb 历史考古 --ccc 可广泛历史考古法的客观"

local test_str = "aaab但是代数分式的 aaac反反倒是撒旦发大 "
print(test_str:gsub("[\1-\127]", ""))

local chs, _ test_str:gsub("[\1-\127]", "")
--local test_str = "aaabbbcccc aaac "
--local test_str = "aaabb啊 aaabb啊 "
--print(utf8_strlen(test_str))

--print(test_str:gsub("[\1-\127]", ""))

--local

--local mode = "[\194-\224][\128-\191]*"
local mode_1 = "([\1-\127\194-\224][\128-\191]*)"
--local mode_1 = "[\1-\127]"
--local mode_1 = "([a-z]*)"

--local mode = "[%s]--([%a_]+[%w_]*)%s+([%w_%p][\1-\127\194-\224][\128-\191]*[%w%s_=%.]*[%w_]+[%w%p_]*)"
--local mode = "aaa([\1-\127\194-\224][\1-\191\194-\224]*)%s+"
local mode = "aaa([%w但是代数分式的反反倒是撒旦发大]+)%s+"

for val in test_str:gmatch(mode) do
	print("match", val)
end
--print(test_str:gmatch(mode))

--local _, count = test_str:gsub("[^\128-\193]", "")
--print(count)

--test_str = "123456abcdef"

--for str in test_str:gmatch("[\97-z]*") do
	--print("aaa", str)
--end
--print(test_str:gmatch("([a-z]*)", ""))
