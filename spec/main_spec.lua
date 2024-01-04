local context_lib = require "context"
local preprocess = require "preprocessor"

local function line_iterator(text)
  return text:gmatch("[^\n]+")
end

describe("preprocessor", function()
  it("works", function()
    local context = context_lib.make_context()
    context:set_values({ ["FOO"] = "BAR" })

    assert.are.same(
      [[
        foo is bar
      ]],
      preprocess.process_input(context, line_iterator [[
        #ifeq FOO BAR
        foo is bar
        #endif
      ]])
    )

    assert.are.same(
      [[
      ]],
      preprocess.process_input(context, line_iterator [[
        #ifeq FOO BAZ
        foo is baz
        #endif
      ]])
    )

    assert.are.same(
      [[
        foo is bar
      ]],
      preprocess.process_input(context, line_iterator [[
        #ifeq FOO BAZ
        foo is baz
        #else
        foo is bar
        #endif
      ]])
    )

    assert.are.same(
      [[
        foo is bar
        this line should be included too
      ]],
      preprocess.process_input(context, line_iterator [[
        #ifeq FOO BAZ
        foo is baz
        #else
        foo is bar
        #ifeq something 1
        #else
        this line should be included too
        #endif
        #endif
      ]])
    )
  end)

  it("fails on unbalanced endif or else", function()
    local context = context_lib.make_context()

    assert.Error(
      function()
        preprocess.process_input(context, line_iterator [[
        #else
        ]])
      end,
      "else without ifeq/ifneq"
    )

    assert.Error(
      function()
        preprocess.process_input(context, line_iterator [[
        #endif
        ]])
      end,
      "endif without ifeq/ifneq"
    )
  end)
end)
