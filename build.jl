using Dates

println("Generating website...")

# Notes source: local meworg vault (optional). Override with MEWORG_ROOT.
# On CI / machines without meworg, committed src/notes is used as-is.
meworg_root = get(ENV, "MEWORG_ROOT", joinpath(homedir(), "meworg"))
meworg_org = joinpath(meworg_root, "university.org")
meworg_dir = joinpath(meworg_root, "university")
has_meworg = isfile(meworg_org) && isdir(meworg_dir)

# Clean up first
println("Cleaning up...")
isdir("build") && rm("build", recursive=true)
if has_meworg
    println("Importing notes from $meworg_root ...")
    isfile("src/notes.org") && rm("src/notes.org")
    isdir("src/notes") && rm("src/notes", recursive=true)
    cp(meworg_org, "src/notes.org")
    if Sys.isapple()
        run(`sed -i '' -e 's/university/notes/g' -e 's/University/Notes/g' src/notes.org`)
    else
        run(`sed -i -e 's/university/notes/g' -e 's/University/Notes/g' src/notes.org`)
    end
    cp(meworg_dir, "src/notes")
else
    println("No meworg at $meworg_root; using committed notes if present")
end

header = read("src/header.html", String)
footer = read("src/footer.html", String)

# Handling blog posts
println("Handling blog posts...")
mkpath("build/blog")
posts = []
for filename in readdir("src/posts")
    println("  Handling post: $filename")
    slug, type = split(filename, ".")
    if type == "org"
        data = read("src/posts/$filename", String)
        matches = collect(eachmatch(r"#\+(?<key>.*): (?<value>.*)", data))
        metadata = Dict(match["key"] => match["value"] for match in matches)
        title = metadata["title"]
        date = metadata["date"]
        tags = split(metadata["tags"], ",")
        tags = strip.(tags)
    elseif type == "md"
        data = read("src/posts/$filename", String)
        yaml = match(r"---\n((.|\n)+?)---", data).captures[1]
        yaml = replace(yaml, "[" => "", "]" => "", "\"" => "")
        metas = split(chomp(yaml), "\n")
        metas = split.(metas, ": ", limit=2)
        metadata = Dict(meta[1] => meta[2] for meta in metas)
        title = metadata["title"]
        date = metadata["date"]
        tags = split(metadata["tags"], ",")
        tags = strip.(tags)
    else
    end
    content = read(`pandoc src/posts/$filename --shift-heading-level-by=1`, String)
    excerpt = read(`pandoc src/posts/$filename -t plain`, String)

    post = Dict("slug" => slug, "title" => title, "date" => date, "tags" => tags)
    push!(posts, post)

    template = read("src/templates/post.html", String)
    templated_string =
        replace(template, "{TITLE}" => title, "{DATE}" => date, "{CONTENT}" => content)
    output =
        replace(
            header,
            "{SLUG}" => "/blog/" * slug,
            "{TITLE}" => title * " - Damien Gonot",
            "{DESCRIPTION}" => "$(first(excerpt, 297))...",
        ) *
        templated_string *
        footer
    open("build/blog/$slug.html", "w") do io
        write(io, output)
    end
end

# List of blog posts
println("Generating list of blog posts...")
posts = sort(posts, by=p -> Date(p["date"]), rev=true)
post_link_template = read("src/templates/post-link.html", String)
posts_template = read("src/templates/posts.html", String)
posts_list = [
    replace(
        post_link_template,
        "{TITLE}" => post["title"],
        "{SLUG}" => post["slug"],
        "{DATE}" => post["date"],
    ) for post in posts
]
content = replace(posts_template, "{CONTENT}" => join(posts_list))
output =
    replace(
        header,
        "{SLUG}" => "/blog",
        "{TITLE}" => "Blog Posts - Damien Gonot",
        "{DESCRIPTION}" => "List of blog posts by Damien Gonot.",
    ) *
    content *
    footer
open("build/blog.html", "w") do io
    write(io, output)
end

# Daily (append-only curated days from src/daily/YYYY-MM-DD.org)
println("Handling daily...")
mkpath("build/daily")
dailies = []
daily_dir = "src/daily"
if isdir(daily_dir)
    for filename in readdir(daily_dir)
        endswith(filename, ".org") || continue
        println("  Handling daily: $filename")
        local slug = replace(filename, ".org" => "")
        local date = Date(slug)
        local title = Dates.format(date, dateformat"U d, Y")
        local weekday = Dates.format(date, dateformat"EEEE")
        local content = read(
            `pandoc $daily_dir/$filename --from=org --shift-heading-level-by=1`,
            String,
        )
        local excerpt = read(
            `pandoc $daily_dir/$filename --from=org -t plain`,
            String,
        )
        push!(
            dailies,
            Dict(
                "slug" => slug,
                "date" => date,
                "title" => title,
                "weekday" => weekday,
                "content" => content,
                "excerpt" => excerpt,
            ),
        )
    end
end

dailies = sort(dailies, by=d -> d["date"], rev=true)
daily_day_template = read("src/templates/daily-day.html", String)
for (i, day) in enumerate(dailies)
    # Chronological neighbors: newer = previous index, older = next index
    local prev_html = if i < length(dailies)
        older = dailies[i + 1]
        """<a href="/daily/$(older["slug"])" class="hover:text-indigo-600 dark:hover:text-indigo-400">← $(older["title"])</a>"""
    else
        ""
    end
    local next_html = if i > 1
        newer = dailies[i - 1]
        """<a href="/daily/$(newer["slug"])" class="hover:text-indigo-600 dark:hover:text-indigo-400">$(newer["title"]) →</a>"""
    else
        ""
    end

    local templated_string = replace(
        daily_day_template,
        "{TITLE}" => day["title"],
        "{SLUG}" => day["slug"],
        "{WEEKDAY}" => day["weekday"],
        "{CONTENT}" => day["content"],
        "{PREV}" => prev_html,
        "{NEXT}" => next_html,
    )
    local output =
        replace(
            header,
            "{SLUG}" => "/daily/" * day["slug"],
            "{TITLE}" => day["title"] * " - Daily - Damien Gonot",
            "{DESCRIPTION}" => "$(first(day["excerpt"], 297))...",
        ) *
        templated_string *
        footer
    open("build/daily/$(day["slug"]).html", "w") do io
        write(io, output)
    end
end

println("Generating daily index...")
daily_entry_template = read("src/templates/daily-entry.html", String)
daily_list_template = read("src/templates/daily.html", String)
# Full reverse-chronological stream of every available day
daily_entries = [
    replace(
        daily_entry_template,
        "{TITLE}" => day["title"],
        "{SLUG}" => day["slug"],
        "{WEEKDAY}" => day["weekday"],
        "{CONTENT}" => day["content"],
    ) for day in dailies
]
daily_content = replace(daily_list_template, "{CONTENT}" => join(daily_entries))
daily_output =
    replace(
        header,
        "{SLUG}" => "/daily",
        "{TITLE}" => "Daily - Damien Gonot",
        "{DESCRIPTION}" => "Curated daily links and notes by Damien Gonot.",
    ) *
    daily_content *
    footer
open("build/daily.html", "w") do io
    write(io, daily_output)
end

# Homepage teaser: latest day (if any)
latest_daily = if isempty(dailies)
    """<p class="text-sm text-zinc-500 dark:text-zinc-400">No entries yet.</p>"""
else
    day = dailies[1]
    replace(
        daily_entry_template,
        "{TITLE}" => day["title"],
        "{SLUG}" => day["slug"],
        "{WEEKDAY}" => day["weekday"],
        "{CONTENT}" => day["content"],
    )
end

# Notes
println("Handling notes...")
has_notes = isfile("src/notes.org") && isdir("src/notes")
if has_notes
    mkpath("build/notes")
    for (root, dirs, files) in walkdir("src/notes")
        for dir in dirs
            path = replace(joinpath(root, dir), "src/" => "build/")
            mkpath(path)
        end
        for file in files
            filename = joinpath(root, file)
            println("  Handling file: $filename")
            slug, type = split(filename, ".")
            slug = replace(slug, "src/notes/" => "")
            if type == "org"
                if Sys.isapple()
                    run(`sed -i '' 's/university.org\]\[University\]/notes.org\]\[Notes\]/g' $filename`)
                else
                    run(`sed -i 's/university.org\]\[University\]/notes.org\]\[Notes\]/g' $filename`)
                end
                local data = read(filename, String)
                local exports_both = map(
                    line ->
                        if startswith(line, "#+begin_src") && !contains(line, ":exports")
                            return line * " :exports both"
                        else
                            return line
                        end,
                    split(data, "\n"),
                )
                local joined = join(["#+options: H:6"; exports_both], "\n")
                local matches = collect(eachmatch(r"#\+(?<key>.*): (?<value>.*)", data))
                local metadata = Dict(match["key"] => match["value"] for match in matches)
                local title = metadata["title"]
                local content = replace(
                    read(
                        pipeline(
                            `echo $joined`,
                            `pandoc --quiet --from=org --shift-heading-level-by=1 --mathjax`,
                        ),
                        String,
                    ),
                    "./images/" => "/images/",
                    ".org\">" => "\">",
                )
                local excerpt = replace(
                    read(
                        pipeline(`echo $joined`, `pandoc --quiet --from=org -t plain`),
                        String,
                    ),
                    r"[^a-zA-Z0-9_\s]" => "",
                )

                local template = read("src/templates/default.html", String)
                local templated_string =
                    replace(template, "{TITLE}" => title, "{CONTENT}" => content)
                local output =
                    replace(
                        header,
                        "{SLUG}" => "/notes/" * slug,
                        "{TITLE}" => title * " - Damien Gonot",
                        "{DESCRIPTION}" => "$(first(excerpt, 297))...",
                    ) *
                    templated_string *
                    footer
                open("build/notes/$slug.html", "w") do io
                    write(io, output)
                end
            elseif type == "png"
                run(`cp $filename src/public/images/$file`)
            else
            end
        end
    end
else
    println("  Skipping notes (src/notes not found)")
end

# Other routes
println("Handling other routes...")
routes = [
    (
        destination="index.html",
        source="index.html",
        title="Damien Gonot",
        heading="",
        description="Homepage of Damien Gonot's personal website.",
    ),
    (
        destination="about.html",
        source="about.org",
        title="About - Damien Gonot",
        heading="About me",
        description="Learn more about Damien Gonot.",
    ),
    (
        destination="citadel.html",
        source="citadel.org",
        title="Citadel - Damien Gonot",
        heading="Citadel",
        description="Damien Gonot's own citadel.",
    ),
]
if has_notes
    push!(
        routes,
        (
            destination="notes.html",
            source="notes.org",
            title="Notes - Damien Gonot",
            heading="Notes",
            description="Damien Gonot's public notes.",
        ),
    )
end

for route in routes
    (; destination, source, title, heading, description) = route
    println("  Handling route: $destination")

    if endswith(source, ".org")
        local template = read("src/templates/default.html", String)
        local html = replace(
            read(`pandoc src/$source --shift-heading-level-by=1`, String),
            ".org\">" => "\">",
        )
        local content = replace(template, "{TITLE}" => heading, "{CONTENT}" => html)
    elseif endswith(source, ".html")
        local content = read("src/$source", String)
    else
    end

    local slug = "/" * replace(destination, ".html" => "")

    if destination == "index.html"
        local content = replace(
            content,
            "{RECENT_BLOG_POSTS}" => join(posts_list[1:5]),
            "{LATEST_DAILY}" => latest_daily,
        )
        local slug = ""
    end

    local output =
        replace(header, "{SLUG}" => slug, "{TITLE}" => title, "{DESCRIPTION}" => description) *
        content *
        footer
    open("build/$destination", "w") do io
        write(io, output)
    end
end

# Wrap it up
println("Wrapping it up...")
run(`cp -a src/public/. build/`)
run(`npx @tailwindcss/cli -i ./src/input.css -o ./build/main.css --minify`)
run(
    `npx html-minifier --input-dir ./build --output-dir ./build --collapse-whitespace --minify-js true --file-ext html`,
)

println("Website has been generated!")
