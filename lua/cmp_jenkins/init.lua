local source = {}

local defaults = {
  gdsl_file = "",
  jenkins_url = ""
}

function file_exists(name)
  local f=io.open(name,"r")
  if f~=nil then io.close(f) return true else return false end
end

function file_is_empty(name)
  local file = io.open(name,"r")
  if not file then return true end
  local content = file:read "*a"
  local res = string.match(content,"(method)")
  return res == nil
end


function source.new()
  return setmetatable({}, { __index = source })
end

function source:complete(params, callback)
  params.option = vim.tbl_deep_extend('keep', params.option, defaults)
  vim.validate({
      gdsl_file = { params.option.gdsl_file, 'string', '`opts.gdsl_file` must be `string`' },
      jenkins_url = { params.option.jenkins_url, 'string', '`opts.jenkins_url` must be `string`' },
    })
  local _gdsl_file_path = nil
  if params.option.gdsl_url ~= "" then
    if not file_exists("/tmp/jenkins.gdsl") or file_is_empty("/tmp/jenkins.gdsl") then
      local handle = io.popen("curl -s -X GET "..params.option.jenkins_url.."/pipeline-syntax/gdsl".." > /tmp/jenkins.gdsl")
      local result = handle:read("*a")
      print(result)
      handle:close()
    end
    _gdsl_file_path = "/tmp/jenkins.gdsl"
  elseif params.option.gdsl_file ~= "" then
    _gdsl_file_path = params.option.gdsl_file
  end

  if _gdsl_file_path ~= nil then
    local items = {}
    local file = io.open(_gdsl_file_path)
    local lines = file:lines()

    for line in lines do
      local _name, _type, _params, _doc = line:match("name: '(.*)', type: '(.*)', params: (%[.*%]), doc: '(.*)'")
      if params == nil then
        _name, _type, _params, _doc = line:match("name: '(.*)', type: '(.*)', namedParams: (%[.*%]), doc: '(.*)'")
      end

      if _name ~= nil and _type ~= nil and _params ~= nil and _doc ~= nil then
        -- print("name: "..name.." type: "..type.." params: "..params.." doc: "..doc)
        table.insert(items, {
            label = _name,
            detail = _doc.."\n".._params
          })
      end
    end
    io.close(file)
    callback({
        items = items,
        isIncomplete = false
      })
  end
end

return source

