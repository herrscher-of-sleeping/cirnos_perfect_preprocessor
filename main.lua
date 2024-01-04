#!/usr/bin/env lua
local context_lib = require "context"
local preprocess = require "preprocessor"

local function parse_arguments(args)
  local ret = {}
  for i, arg in ipairs(args) do
    local k, v = arg.match(arg, "([%w_]+)=([%w_]+)")
    if k and v then
      ret[k] = v
    end
  end
  return ret
end

local function main(args)
  local context = context_lib.make_context()
  context:set_values(parse_arguments(args))

  local processed_text = preprocess.process_input(context, io.lines())
  print(processed_text)
end

main(arg)
