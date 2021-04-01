# TODO make prev/next reaction buttons to flip through results

function commander(c::Client, m::Message, ::Val{:discourse})
    @info "discourse_commander called"
    startswith(m.content, COMMAND_PREFIX * "discourse") || return

    regex = Regex(COMMAND_PREFIX * raw"discourse( help| search| latest)? *(.*)$")

    matches = match(regex, m.content)

    if matches === nothing || matches.captures[1] ∈ (" help", nothing)
        help_commander(c, m, :discourse)
    elseif matches.captures[1] == " latest"
        discourse_latest(c, m)
    elseif matches.captures[1] == " search"
        discourse_search(c, m, matches.captures[2])
    else
        reply(c, m, "Sorry, are you playing me? Please check `discourse help`")
    end
    return nothing
end

function help_commander(c::Client, m::Message, ::Val{:discourse})
    reply(c, m, """
        How to use `discourse` bot:
        ```
        discourse latest             # random post from latest screen
        discourse search <query>     # search
        ```
        """)
end

function discourse_latest(c::Client, m::Message)

    response = HTTP.get("https://discourse.julialang.org/latest.json",
        headers = ["Accept" => "application/json"])
    json = JSON.parse(String(response.body))

    list = [(t["id"], t["slug"], t["posts_count"])
        for t in json["topic_list"]["topics"]]

    random_post = list[rand(1:length(list))]
    id, slug, posts_count = random_post

    message = """
        OK, here's a popular random post from latest:
        https://discourse.julialang.org/t/$slug/$id
        """
    reply(c, m, message)
end


function discourse_search(c::Client, m::Message, query::AbstractString)
    if length(query) == 0
        reply(c, m, "Please enter search term")
        return
    end

    # TODO sanitize query
    response = HTTP.get("https://discourse.julialang.org/search.json?q=$query",
        headers = ["Accept" => "application/json"])
    json = JSON.parse(String(response.body))

    list = [(t["id"], t["slug"], t["posts_count"])
        for t in json["topics"]]

    random_post = list[rand(1:length(list))]
    id, slug, posts_count = random_post

    message = """
        Search result for $query:
        https://discourse.julialang.org/t/$slug/$id
        """
    reply(c, m, message)
end
