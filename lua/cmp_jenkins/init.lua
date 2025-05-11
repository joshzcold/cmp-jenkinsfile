local source = {}

local defaults = {
  gdsl_file = os.getenv("HOME").."/.cache/nvim/cmp-jenkinsfile.gdsl",
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
  vim.validate('gdsl_file', params.option.gdsl_file, 'string', false, '`opts.gdsl_file` must be `string`')
  vim.validate('jenkins_url', params.option.jenkins_url, 'string', false, '`opts.jenkins_url` must be `string`')
  if params.option.jenkins_url ~= "" then
    if not file_exists(params.option.gdsl_file) or file_is_empty(params.option.gdsl_file) then
      local handle = io.popen("curl -s -X GET "..params.option.jenkins_url.."/pipeline-syntax/gdsl".." > "..params.option.gdsl_file)
      local result = handle:read("*a")
      print(result)
      handle:close()
    end
  end

  local _vals = {}
  local items = {}
  local last_item
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

