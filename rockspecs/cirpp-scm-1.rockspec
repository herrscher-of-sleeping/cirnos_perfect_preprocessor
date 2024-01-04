package = "cirpp"
version = "scm-1"
source = {
  url = "git@github.com:herrscher-of-sleeping/cirnos_perfect_preprocessor.git",
}
description = {
  summary = "Cirno's perfect preprocessor that's dumb enough to be useful",
  license = "GNU GPLv3",
}
dependencies = {
  "lua >= 5.1, <= 5.4",
}
build = {
  type = "builtin",
  install = {
    bin = { cirpp = "main.lua" }
  },
  modules = {
    ["context"] = "context.lua",
    ["preprocessor"] = "preprocessor.lua",
  }
}
