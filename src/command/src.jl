const sources_url = LittleDict([
    "HoJBot" => "https://github.com/Humans-of-Julia/HoJBot.jl",
])

"""
Returns the url of the source repo of HojBot.
"""
function commander(c::Client, m::Message, ::Val{:source})
    startswith(m.content, COMMAND_PREFIX * "source") ||  return
    regex = Regex(COMMAND_PREFIX * raw"source (repo|repository|help)$") # will add something soon to return specific code of commands
    matches = match(regex, m.content)
    if matches === nothing || matches.captures[1] == "repo" || matches.captures[1] == "repository"
        reply(c, m, sources_url["HoJBot"])
    elseif matches.captures[1] == "help"
        help_commander(c, m, :source)
    end
    return nothing
end

function help_commander(c::Client, m::Message, ::Val{:source})
    reply(c, m, """
        How to opt-in/out of the `reaction` bot:
        ```
        react help
        react in
        react out
        ```
        The commands `in` and `out` are to opt-in and opt-out of the reaction bot.
        """)
end
