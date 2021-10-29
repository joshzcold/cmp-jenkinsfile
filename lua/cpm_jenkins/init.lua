local cmp = require'cmp'

local source = {}

local defaults = {
  gdsl_file = "./groovy.gdsl",
  gdsl_url = ""
}

source.complete = function(self, params, callback)
  local items
  local file = io.open(defaults.gdsl_file)lines = file:lines()
  local processing = false

  for line in lines do
    name, type, params, doc = line:match("name: '(.*)', type: '(.*)', params: (%[.*%]), doc: '(.*)'")
    if params == nil then
      name, type, params, doc = line:match("name: '(.*)', type: '(.*)', namedParams: (%[.*%]), doc: '(.*)'")
    end

    if name ~= nil and type ~= nil and params ~= nil and doc ~= nil then
      print("name: "..name.." type: "..type.." params: "..params.." doc: "..doc) 
      table.insert(items, {
          label = name,
          dup = 0
      })
    end
  end
  callback({ items = items })
end

return source

