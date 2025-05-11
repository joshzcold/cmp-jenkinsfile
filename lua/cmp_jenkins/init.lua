local source = {}

local defaults = {
  gdsl_file = os.getenv("HOME").."/.cache/nvim/cmp-jenkinsfile.gdsl",
  jenkins_url = "",
  http = {
      basic_auth_user = "",
      basic_auth_password = "",
      ca_cert = "",
      proxy = "",
  },
}

local function file_exists(name)
  local f=io.open(name,"r")
  if f~=nil then io.close(f) return true else return false end
end

local function file_is_empty(name)
  local file = io.open(name,"r")
  if not file then return true end
  local content = file:read "*a"
  local res = string.match(content,"(method)")
  return res == nil
end

local function build_curl(jenkins_url, opts)
    local cmd = "curl --silent -X GET "..jenkins_url.."/pipeline-syntax/gdsl"
    if opts.proxy ~= "" then
        cmd = cmd.." --proxy "..opts.proxy
    end
    if opts.ca_cert ~= "" then
        cmd = cmd.." --cacert "..opts.ca_cert
    end
    if opts.basic_auth_user ~= "" then
        cmd = cmd.."--basic -u "..opts.basic_auth_user..":"..opts.basic_auth_password
    end
    return cmd
end

function source.new()
  return setmetatable({}, { __index = source })
end

function source:complete(params, callback)
  params.option = vim.tbl_deep_extend('keep', params.option, defaults)
  vim.validate('gdsl_file', params.option.gdsl_file, 'string', false, '`opts.gdsl_file` must be `string`')
  vim.validate('jenkins_url', params.option.jenkins_url, 'string', false, '`opts.jenkins_url` must be `string`')
  vim.validate('http', params.option.http, 'table', false, '`opts.http` must be `table`')
  vim.validate('http.basic_auth_user', params.option.http.basic_auth_user, 'string', false, '`opts.http.basic_auth_user` must be `string`')
  vim.validate('http.basic_auth_password', params.option.http.basic_auth_password, 'string', false, '`opts.http.basic_auth_password` must be `string`')
  vim.validate('http.ca_cert', params.option.http.ca_cert, 'string', false, '`opts.http.ca_cert` must be `string`')
  vim.validate('http.proxy', params.option.http.proxy, 'string', false, '`opts.http.proxy` must be `string`')

  if params.option.jenkins_url ~= "" then
    if not file_exists(params.option.gdsl_file) or file_is_empty(params.option.gdsl_file) then
      local curl_cmd = build_curl(params.option.jenkins_url, params.option.http)
      local handle = io.popen(curl_cmd.." > "..params.option.gdsl_file)
     if handle ~= nil then
        local result = handle:read("*a")
        print(result)
        handle:close()
      end
    end
  end

  local _vals = {}
  local items = {}
  local file = io.open(params.option.gdsl_file)
  if file ~= nil then

    local lines = file:lines()
    for line in lines do
      local _name, _type, _params, _doc = line:match("name: '(.*)', type: '(.*)', namedParams: (%[.*%]), doc: '(.*)'")
      if _params == nil then
        _name, _type, _params, _doc = line:match("name: '(.*)', type: '(.*)', params: (%[.*%]), doc: '(.*)'")
      end

      if _name ~= nil and _type ~= nil and _params ~= nil and _doc ~= nil then
        -- print("name: "..name.." type: "..type.." params: "..params.." doc: "..doc)
        if _vals[_name] then
          _vals[_name].detail = _vals[_name].detail.."\n---------------\n".._params
        else
          _vals[_name] = {
            label = _name,
            detail = _doc.."\n\n".._params
          }
        end
      end
    end

    for _, v in pairs(_vals) do
      table.insert(items, {
          label = v.label,
          detail = v.detail,
          dup = 0
        })
    end

    io.close(file)
    callback({
        items = items,
        isIncomplete = false
      })
  end
end

return source

