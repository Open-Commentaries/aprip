JSON = require "pandoc_filters/json"

local function load_named_entities()
    local namedEntitiesFile = io.open(
        "static/named-entity-annotations/tlg0525.tlg001.perseus-grc2.named-entities.json",
        "r")

    if not namedEntitiesFile then return nil end

    local namedEntitiesRaw = namedEntitiesFile:read "*a"

    namedEntitiesFile:close()

    return JSON.decode(namedEntitiesRaw)
end

NAMED_ENTITIES = load_named_entities()

print(NAMED_ENTITIES[2]["entity_urn"])

local locationPattern = "{(%d+%.%d+%.%d+)}"
local authors = {}
local urn = "urn:cts:greekLit:tlg0525.tlg001.aprip-nagy"
local title = ""

function Meta(m)
    m.authors = authors
    m.base_urn = urn
    m.title = title

    return m
end

local currentUrn = ""
local tokens = {}

function Div(div)
    if div.attributes["custom-style"] == "chs_h1" then
        title = pandoc.utils.stringify(div.content)
        return pandoc.Str("")
    end

    if div.attributes["custom-style"] == "chs_h2" then
        return pandoc.Header(2, pandoc.utils.stringify(div.content), div.attr, div.classes)
    end

    if div.attributes["custom-style"] == "chs_essay_author" then
        table.insert(authors, pandoc.utils.stringify(div.content))
        return pandoc.Str("")
    end

    if div.attributes["custom-style"] == "chs_normal" then
        return div.content
    end

    return div
end

function Span(span)
    if span.attributes["custom-style"] == "chs_translit_Greek"
        or span.attributes["custom-style"] == "chs_emphasis" then
        return pandoc.Emph(span.content)
    end

    if span.attributes["custom-style"] == "chs_foreign" then
        return span.content
    end

    return span
end

function Str(str)
    local _, _, location = str.text:find(locationPattern)

    if location ~= nil then
        local citation = "@" .. urn .. ":" .. location
        currentUrn = citation
        tokens = {}

        return {
            pandoc.Str("---"),
            pandoc.Str("\n\n"),
            pandoc.Str(citation),
            pandoc.Str("\n\n")
        }
    end

    if not str.text:match("%w+") then
        return str
    end

    local tokenIndex = 0

    if tokens[str.text] == nil then
        tokenIndex = 1
        tokens[str.text] = tokenIndex
    else
        tokenIndex = tokens[str.text] + 1
        tokens[str.text] = tokenIndex
    end

    return pandoc.Span(str, { id = currentUrn .. "@" .. str.text:gsub("%W", "") .. "[" .. tokenIndex .. "]" })
end
