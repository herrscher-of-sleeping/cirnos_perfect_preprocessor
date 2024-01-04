---@param context CIRPP.Context
---@param lines_iterator fun(): string?
local function process_input(context, lines_iterator)
  local ret = {}
  for line in lines_iterator do
    local command = context:parse_command(line)
    if command then
      command:execute(context)
    else
      local preprocessed_line = context:process_line(line)
      table.insert(ret, preprocessed_line)
    end
  end
  return table.concat(ret, "\n")
end

return {
  process_input = process_input
}
