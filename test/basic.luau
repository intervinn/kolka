local lexer = require("../ast/lexer")
local stdio = require("@lune/stdio")

local toks = lexer.parse([[
    interface ISignal
        :Connect()
    end

    class Signal : ISignal
        [Operator("+=")]
        :Connect(func: () -> ())
            table.insert(self.items, func)
        end        
    end
]])

for _, t in toks do
    stdio.write(`{t.kind} `)
    if t.kind == "line" then
        stdio.write("\n")
    end
end