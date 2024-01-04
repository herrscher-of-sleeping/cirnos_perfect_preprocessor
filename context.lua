---@class CIRPP.Context
local context_mt = {}
context_mt.__index = context_mt

---@class CIRPP.Instruction
---@field type string
---@field args table<string, string>
---@field execute fun(instruction: CIRPP.Instruction, context: CIRPP.Context)
---@field does_line_pass? fun(self: CIRPP.Instruction, line: string): boolean

---@alias CIRPP.Checker fun(context: CIRPP.Context): boolean

---@param context CIRPP.Context
---@param instruction CIRPP.Instruction
local function default_instruction_execute(instruction, context)
  context:push_if_stack(instruction)
end

local function register_instruction(context, name, keys, callbacks)
  ---@param args table
  ---@return CIRPP.Instruction
  context.instructions[name] = function(args)
    callbacks = callbacks or {}
    return {
      type = name,
      args = args,
      execute = callbacks.execute or default_instruction_execute,
      does_line_pass = callbacks.does_line_pass,
    }
  end

  ---@param line string
  ---@return CIRPP.Instruction
  context.parsers[name] = function(line)
    local match_str = "#%w+" .. ("%s+([%w_]+)"):rep(#keys)
    local matches = { line:match(match_str) }
    local args_map = {}
    for i = 1, #keys do
      args_map[keys[i]] = matches[i]
    end
    return context.instructions[name](args_map)
  end
end

---@return CIRPP.Instruction?
function context_mt:parse_command(line)
  local command = line:match("#(%w+)")
  if self.instructions[command] then
    return self.parsers[command](line)
  end
end

---@param line string
---@return string?
function context_mt:process_line(line)
  for _, instruction in pairs(self.if_stack) do
    if not instruction:does_line_pass(line) then
      return nil
    end
  end
  return line
end

---Print command (for debug purposes)
---@param command CIRPP.Instruction?
function context_mt:print_command(command, indent)
  if not command then
    return
  end
  print((" "):rep(indent or 0) .. command.type .. ": " .. table.concat(command.args, ", "))
end

function context_mt:dump()
  print("=============")
  print("Context dump:")
  for i, instruction in pairs(self.if_stack) do
    self:print_command(instruction, i - 1)
  end
  print("=============")
end

---@param values table<string, string>
function context_mt:set_values(values)
  self.values = values
end

function context_mt:push_if_stack(value)
  table.insert(self.if_stack, value)
end

local function make_context()
  ---@class CIRPP.Context
  local context = {
    ---@type table<integer, CIRPP.Instruction>
    if_stack = {},
    lines_array = {},

    checkers = {}, ---@type table<string, CIRPP.Checker>

    ---@type table<string, fun(args: table): CIRPP.Instruction>
    instructions = {},
    parsers = {},
    values = {},
  }

  setmetatable(context, context_mt)

  local checkers = {}

  checkers["ifeq"] = function(self, line)
    local key = self.args["key"]
    local value = self.args["value"]
    if context.values[key] == value then
      return true
    end
    return false
  end

  checkers["ifneq"] = function(self, line)
    local key = self.args["key"]
    local value = self.args["value"]
    if context.values[key] ~= value then
      return true
    end
    return false
  end

  register_instruction(context, "ifeq", { "key", "value" }, {
    does_line_pass = function(self, line)
      return checkers[self.type](self, line)
    end,
  })

  register_instruction(context, "ifneq", { "key", "value" }, {
    does_line_pass = function(self, line)
      return checkers[self.type](self, line)
    end,
  })

  register_instruction(context, "else", {}, {
    execute = function(command, ctx)
      local last_context_item = ctx.if_stack[#ctx.if_stack]
      assert(last_context_item, "else without ifeq/ifneq")
      if last_context_item.type == "ifeq" then
        last_context_item.type = "ifneq"
      elseif last_context_item.type == "ifneq" then
        last_context_item.type = "ifeq"
      end
    end,
  })

  register_instruction(context, "endif", {}, {
    execute = function(command, ctx)
      assert(#ctx.if_stack > 0, "endif without ifeq/ifneq")
      table.remove(ctx.if_stack)
    end,
  })
  register_instruction(context, "dump", {}, {
    execute = function(command, ctx)
      ctx:dump()
    end,
  })
  return context
end

return { make_context = make_context }
