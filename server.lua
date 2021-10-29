file = io.open("jenkins.gdsl")lines = file:lines()
for line in lines do  
  name, type, params, doc = line:match("name: '(.*)', type: '(.*)', params: (%[.*%]), doc: '(.*)'")
  if params == nil then
  name, type, params, doc = line:match("name: '(.*)', type: '(.*)', namedParams: (%[.*%]), doc: '(.*)'")
  end

  if name ~= nil and type ~= nil and params ~= nil and doc ~= nil then
   print("name: "..name.." type: "..type.." params: "..params.." doc: "..doc) 
  end
end
