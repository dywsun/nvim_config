local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local events = require("luasnip.util.events")
local ai = require("luasnip.nodes.absolute_indexer")
local extras = require("luasnip.extras")
local fmt = require("luasnip.extras.fmt").fmt
local m = extras.m
local l = extras.l
local rep = extras.rep
local postfix = require("luasnip.extras.postfix").postfix

ls.add_snippets("lua", {
  -- for lua snippet s
  s(
    "snip",
    fmt(
      [[
  -- {}
  s("{}", {{
    {}
  }}),{}
  ]],
      {
        i(1, "comment for record"),
        i(2, "trigger"),
        i(3),
        i(0),
      }
    )
  ),
})

ls.add_snippets("all", {
  s("ternary", {
    -- equivalent to "${1:cond} ? ${2:then} : ${3:else}"
    i(1, "cond"),
    t(" ? "),
    i(2, "then"),
    t(" : "),
    i(3, "else"),
  }),

  s("testline", {
    t({ "test line=>" }),
    i(1),
    t({ "", "test line=>" }),
    i(2),
    t({ "", "test line=>" }),
    i(0),
  }),
})

-- for cocos create
ls.add_snippets("typescript", {
  s(
    "cocos363",
    fmt(
      [[
  import {{ _decorator, Component, Node }} from 'cc';
  const {{ ccclass, property }} = _decorator;

  @ccclass('{}')
  export class {} extends Component {{
    protected onLoad(): void {{
    }}

    protected onDestroy(): void {{

    }}
  }}{}
  ]],
      {
        i(1, "NewCompenent"),
        rep(1),
        i(0),
      }
    )
  ),

  s(
    "pnode",
    fmt(
      [[
    @property(Node)
    {}: Node = null
    {}
  ]],
      { i(1, "testNode"), i(0) }
    )
  ),
  s(
    "pnodes",
    fmt(
      [[
    @property(Node)
    {}: Node[] = []
    {}
  ]],
      { i(1, "testNodes"), i(0) }
    )
  ),
  s(
    "plabel",
    fmt(
      [[
    @property(Label)
    {}: Label = null
    {}
  ]],
      { i(1, "testLabel"), i(0) }
    )
  ),

  s("width", { t([[getComponent(UITransform).width]]) }),
  s("height", { t([[getComponent(UITransform).height]]) }),
})
