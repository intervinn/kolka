--!strict
local lexer = require("./lexer")

export type Expression =
{kind: "binary", op: lexer.BinaryOperator, left: Expression, right: Expression, pos: lexer.Pos}
| {kind: "call", fun: Expression, args: {Expression}, lparent: lexer.Pos, rparen: lexer.Pos}
| {kind: "index", subj: Expression, index: Expression, lbrack: lexer.Pos, rbrack: lexer.Pos}
| {kind: "selector", subj: Expression, select: lexer.Identifier}
| {kind: "method", subj: Expression, call: Expression}
| lexer.Literal

local function parseBinaryExpr(source: {lexer.Token}, start: number): (Expression?, number)
    return nil, 1
end

local function parseCallExpr(source: {lexer.Token}, start: number): (Expression?, number)
    return nil, 1
end

local function parseIndexExpr(source: {lexer.Token}, start: number): (Expression?, number)
    return nil, 1
end

local function parseSelectorExpr(source: {lexer.Token}, start: number): (Expression?, number)
    return nil, 1
end

local function parseMethodExpr(source: {lexer.Token}, start: number): (Expression?, number)
    return nil, 1
end

-- TODO: finish the parsers

local function parse(source: {lexer.Token})
    
end