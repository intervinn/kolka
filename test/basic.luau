local lexer = require("../ast/lexer")
local stdio = require("@lune/stdio")

local toks = lexer.parse([[
    interface ISignal
        local function Connect()
    end

    class Signal : ISignal
        local some = 5 -- class field
        other = 10 -- static field

        @native
        @inline
        @operator("+=")
        local function Connect(func: () -> ())
            table.insert(self.items, func)
        end        
    end

    local thing = 5
    local isFive = match thing
        [x==1] = false,
        [x==2] = function() return false end,
        [x==5] = true,
        _ = false
    end
]])

for _, t in toks do
    stdio.write(`{t.kind} `)
    if t.kind == "line" then
        stdio.write("\n")
    end
end