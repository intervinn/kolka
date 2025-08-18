--!strict

export type Pos = {
    start: number,
    finish: number
}

export type Source = {
    text: string
}

export type Identifier = {kind: "identifier", text: string, pos: Pos}

export type Literal = 
{kind: "string", text: string, pos: Pos}
| {kind: "number", text: string, pos: Pos}

export type BinaryOperator =
{kind: "+", pos: Pos}
| {kind: "/", pos: Pos}
| {kind: "-", pos: Pos}
| {kind: "*", pos: Pos}
| {kind: "//", pos: Pos}
| {kind: "^", pos: Pos}
| {kind: "%", pos: Pos}
| {kind: "..", pos: Pos}
| {kind: "+=", pos: Pos}
| {kind: "-=", pos: Pos}
| {kind: "/=", pos: Pos}
| {kind: "*=", pos: Pos}
| {kind: "//=", pos: Pos}
| {kind: "^=", pos: Pos}
| {kind: "%=", pos: Pos}
| {kind: "..=", pos: Pos}
| {kind: ">", pos: Pos}
| {kind: "<", pos: Pos}
| {kind: ">=", pos: Pos}
| {kind: "<=", pos: Pos}
| {kind: "==", pos: Pos}
| {kind: "~=", pos: Pos}
| {kind: "and", pos: Pos}
| {kind: "or", pos: Pos}

export type UnaryOperator =
{kind: "#", pos: Pos}
| {kind: "not", pos: Pos}
| {kind: "-", pos: Pos}

export type Token =
Literal
| Identifier
| {kind: "fun", pos: Pos}
| {kind: "if", pos: Pos}
| {kind: "else", pos: Pos}
| {kind: "while", pos: Pos}
| {kind: "end", pos: Pos}
| {kind: "then", pos: Pos}
| {kind: "true", pos: Pos}
| {kind: "nil", pos: Pos}
| {kind: "false", pos: Pos}
| {kind: "type", pos: Pos}
| {kind: "interface", pos: Pos}
| {kind: "class", pos: Pos}
| {kind: "enum", pos: Pos}
| {kind: "pkg", pos: Pos}
| {kind: "local", pos: Pos}
| {kind: "line", pos: Pos}
| {kind: "=", pos: Pos}
| BinaryOperator

local reserved = table.freeze({
    "fun", "if", "else", "while",
    "end", "then", "true", "nil",
    "false", "type", "interface",
    "enum", "class", "pkg", "local",
    "in", "use", "and"
})

local singles = table.freeze({
    "[", "]", "{", "}",
    "(", ")", "=", "/",
    "+", "-", "*", ";",
    ",", ".", "$", ":",
    "#", "^"
})

local doubles = table.freeze({
    "==", "!=", "+=", "-=",
    "/=", "..", ">=", "<=",
    "^=", "->", "//"
})

local triples = table.freeze({
    "..=", "//="
})

local function strAt(str: string, at: number)
    return string.sub(str, at, at)
end

local function isIdent(char: string)
    return char:match("^%a+$") == char or char == "_"
end

local function parseIdentifier(source: string, start: number): (Token?, number)
    if not isIdent(strAt(source, start)) then return nil, 1 end

    local finish = -1
    for i = start+1,#source,1 do
        if not isIdent(strAt(source, i)) then
            finish = i-1
            break
        end
    end

    if finish == -1 then
        return nil, 1
    else
        return {
            kind = "identifier",
            pos = {start = start, finish = finish}
        } :: Token, finish - start + 1
    end
end

local function parseString(source: string, start: number): (Token?, number)
    if strAt(source, start) ~= "\"" then return nil, 1 end

    local finish = -1
    for i = start+1,#source,1 do
        if strAt(source, i) == "\"" then
            finish = i
            break
        end
    end

    if finish == -1 then return nil, 1 end
    return {
        kind = "string",
        text = string.sub(source, start, finish),
        pos = {
            start = start,
            finish = finish
        }
    } :: Token, finish - start + 1
end

local function parseSymbol(source: string, start: number): (Token?, number)
    if source:sub(start, start) == "\n" then
        return {
            kind = "line",
            pos = {start = start, finish = start}
        } :: Token, 1
    end

    for _, v in triples do
        if source:sub(start, start) == v then
            return {
                kind = v,
                pos = {start = start, finish = start+2}
            } :: Token, 3
        end
    end

    for _, v in doubles do
        if source:sub(start, start+1) == v then
            return {
                kind = v,
                pos = {start = start, finish = start+1}
            } :: Token, 2
        end
    end

    for _, v in singles do
        if source:sub(start, start) == v then
            return {
                kind = v,
                pos = {start = start, finish = start}
            } :: Token, 1
        end
    end

    return nil, 1
end

local function parseNumber(source: string, start: number): (Token?, number)
    if type(tonumber(strAt(source, start))) ~= "number" then return nil, 1 end
    local finish = -1

    for i = start+1, #source, 1 do
        if type(tonumber(source:sub(start, i))) ~= "number" then
            finish = i
        end
    end

    if finish == -1 then
        return nil, 1
    else
        return {
            kind = "number",
            pos = {start = start, finish = finish}
        } :: Token, finish - start + 1
    end
end

local function parseKeyword(source: string, start: number): (Token?, number)
    for _, r in reserved do
        if source:sub(start, start+(#r-1)) == r then
            return {
                kind = r,
                pos = {start = start, finish = start+(#r-1)}
            } :: Token, #r
        end
    end
    
    return nil, 1
end

-- TODO: put this in the end of parse chain to error the unknown things
local function parseBad(source: string, start: number): (Token?, number)
    return nil, 1
end

local function parse(source: string): {Token}
    local index = 1
    local eof = #source
    local result = {}
    local parsers = {parseSymbol, parseString, parseNumber, parseKeyword, parseIdentifier, parseBad}

    while true do
        if index == eof then
            break
        end

        local found = false
        for _, p in parsers do
            local token, shift = p(source, index)
            if token ~= nil then
                found = true
                index += shift
                table.insert(result, token)
                break
            end
        end

        if not found then
            index += 1
        end
    end

    return result
end

return {
    parse = parse
}