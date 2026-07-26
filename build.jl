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

# i18n
const LOCALES = ["en", "fr"]

const FR_MONTHS = [
    "janvier",
    "février",
    "mars",
    "avril",
    "mai",
    "juin",
    "juillet",
    "août",
    "septembre",
    "octobre",
    "novembre",
    "décembre",
]
const FR_WEEKDAYS = [
    "lundi",
    "mardi",
    "mercredi",
    "jeudi",
    "vendredi",
    "samedi",
    "dimanche",
]

const I18N = Dict(
    "en" => Dict(
        "lang" => "en",
        "prefix" => "",
        "home_href" => "/",
        "nav_daily" => "Daily",
        "nav_blog" => "Blog",
        "nav_notes" => "Notes",
        "nav_about" => "About",
        "lang_switcher_label" => "Language",
        "theme_aria" => "Toggle color theme",
        "blog_title" => "Blog",
        "blog_intro" => """Longer posts. Much of the archive is ads and marketing automation
    (Google Ads, Facebook Marketing API, spreadsheets). Newer writing wanders further afield.
    For day-to-day AI links, see
    <a href="/daily" class="underline decoration-indigo-400/50 underline-offset-4 hover:decoration-indigo-400">Daily</a>.""",
        "blog_page_title" => "Blog Posts - Damien Gonot",
        "blog_page_description" => "Blog posts by Damien Gonot: ads and marketing automation, plus occasional longer essays.",
        "daily_title" => "Daily",
        "daily_intro" => """Day-to-day links and short notes, mostly AI. For longer posts, see the
    <a href="/blog" class="underline decoration-indigo-400/50 underline-offset-4 hover:decoration-indigo-400">blog</a>.""",
        "daily_page_title" => "Daily - Damien Gonot",
        "daily_page_description" => "Daily AI links and short notes by Damien Gonot.",
        "daily_suffix" => " - Daily - Damien Gonot",
        "content_lang_note" => "",
        "no_daily" => """<p class="text-sm text-zinc-500 dark:text-zinc-400">No entries yet.</p>""",
        "home_title" => "Damien Gonot",
        "home_description" => "Software developer & marketer. Daily AI notes, a blog on ads automation, and public notes by Damien Gonot.",
        "about_title" => "About - Damien Gonot",
        "about_heading" => "About me",
        "about_description" => "About Damien Gonot, software developer & marketer. Contact, résumé, and personal stack.",
        "citadel_title" => "Citadel - Damien Gonot",
        "citadel_heading" => "Citadel",
        "citadel_description" => "Damien Gonot's own citadel.",
        "notes_title" => "Notes - Damien Gonot",
        "notes_heading" => "Notes",
        "notes_description" => "Damien Gonot's public notes.",
        "notes_suffix" => " - Damien Gonot",
    ),
    "fr" => Dict(
        "lang" => "fr",
        "prefix" => "/fr",
        "home_href" => "/fr",
        "nav_daily" => "Journal",
        "nav_blog" => "Blog",
        "nav_notes" => "Notes",
        "nav_about" => "À propos",
        "lang_switcher_label" => "Langue",
        "theme_aria" => "Changer le thème de couleur",
        "blog_title" => "Blog",
        "blog_intro" => """Des articles plus longs. Une grande partie des archives porte sur les ads et l'automatisation marketing
    (Google Ads, Facebook Marketing API, tableurs). Les textes plus récents s'éloignent un peu.
    Pour les liens IA au jour le jour, voir le
    <a href="/fr/daily" class="underline decoration-indigo-400/50 underline-offset-4 hover:decoration-indigo-400">Journal</a>.
    <span class="block mt-2 text-sm">Les articles sont pour l'instant en anglais.</span>""",
        "blog_page_title" => "Articles de blog - Damien Gonot",
        "blog_page_description" => "Articles de Damien Gonot : ads et automatisation marketing, et parfois des essais plus longs.",
        "daily_title" => "Journal",
        "daily_intro" => """Liens et notes au fil des jours, surtout de l'IA. Pour les textes plus longs, voir le
    <a href="/fr/blog" class="underline decoration-indigo-400/50 underline-offset-4 hover:decoration-indigo-400">blog</a>.
    <span class="block mt-2 text-sm">Le contenu est souvent en anglais.</span>""",
        "daily_page_title" => "Journal - Damien Gonot",
        "daily_page_description" => "Liens IA et notes quotidiennes de Damien Gonot.",
        "daily_suffix" => " - Journal - Damien Gonot",
        "content_lang_note" => """<p class="mt-3 text-sm text-zinc-500 dark:text-zinc-400">Ce contenu est en anglais.</p>""",
        "no_daily" => """<p class="text-sm text-zinc-500 dark:text-zinc-400">Pas encore d'entrées.</p>""",
        "home_title" => "Damien Gonot",
        "home_description" => "Développeur et marketer. Journal IA quotidien, blog sur l'automatisation des ads, et notes publiques de Damien Gonot.",
        "about_title" => "À propos - Damien Gonot",
        "about_heading" => "À propos de moi",
        "about_description" => "À propos de Damien Gonot, développeur et marketer. Contact, CV et stack personnelle.",
        "citadel_title" => "Citadelle - Damien Gonot",
        "citadel_heading" => "Citadelle",
        "citadel_description" => "La citadelle de Damien Gonot.",
        "notes_title" => "Notes - Damien Gonot",
        "notes_heading" => "Notes",
        "notes_description" => "Les notes publiques de Damien Gonot.",
        "notes_suffix" => " - Damien Gonot",
    ),
)

const LANG_ACTIVE =
    "font-semibold text-indigo-600 dark:text-indigo-400"
const LANG_INACTIVE =
    "text-zinc-500 dark:text-zinc-400 hover:text-indigo-600 dark:hover:text-indigo-400"

header_template = read("src/header.html", String)
footer_template = read("src/footer.html", String)

"""Logical site path without locale prefix. Empty string for home."""
function locale_paths(logical_path::AbstractString)
    en = logical_path == "" ? "/" : logical_path
    fr = logical_path == "" ? "/fr" : "/fr" * logical_path
    return (en, fr)
end

function format_daily_title(date::Date, locale::AbstractString)
    if locale == "fr"
        return "$(day(date)) $(FR_MONTHS[month(date)]) $(year(date))"
    end
    return Dates.format(date, dateformat"U d, Y")
end

function format_daily_weekday(date::Date, locale::AbstractString)
    if locale == "fr"
        return FR_WEEKDAYS[dayofweek(date)]
    end
    return Dates.format(date, dateformat"EEEE")
end

"""Collapse whitespace and escape for double-quoted HTML attributes (e.g. meta description)."""
function html_attr(s::AbstractString)
    s = strip(replace(String(s), r"\s+" => " "))
    s = replace(s, "&" => "&amp;")
    s = replace(s, "\"" => "&quot;")
    s = replace(s, "<" => "&lt;")
    s = replace(s, ">" => "&gt;")
    return s
end

"""Plain-text excerpt → one-line meta description (escaped later via wrap_page)."""
function excerpt_description(excerpt::AbstractString; max_chars::Int=297)
    plain = strip(replace(String(excerpt), r"\s+" => " "))
    if length(plain) > max_chars
        return first(plain, max_chars) * "..."
    end
    return plain * "..."
end

"""Rewrite absolute in-site links so FR pages stay under /fr/."""
function localize_hrefs(html::AbstractString, locale::AbstractString)
    locale == "fr" || return html
    # Longer prefixes first so /notes is not half-matched oddly
    for path in
        ("/daily", "/blog", "/notes", "/about", "/citadel", "/resume", "/homepage")
        html = replace(html, "href=\"$path" => "href=\"/fr$path")
    end
    return html
end

function apply_chrome(
    chrome::AbstractString,
    locale::AbstractString,
    logical_path::AbstractString;
    title::AbstractString,
    description::AbstractString,
)
    t = I18N[locale]
    en_path, fr_path = locale_paths(logical_path)
    canonical = locale == "fr" ? fr_path : en_path
    # Avoid bare "/" becoming empty in some contexts; keep as-is
    return replace(
        chrome,
        "{LANG}" => t["lang"],
        "{TITLE}" => title,
        "{DESCRIPTION}" => html_attr(description),
        "{CANONICAL}" => canonical == "/" ? "" : canonical,
        "{EN_PATH}" => en_path,
        "{FR_PATH}" => fr_path,
        "{EN_CLASS}" => locale == "en" ? LANG_ACTIVE : LANG_INACTIVE,
        "{FR_CLASS}" => locale == "fr" ? LANG_ACTIVE : LANG_INACTIVE,
        "{PREFIX}" => t["prefix"],
        "{HOME_HREF}" => t["home_href"],
        "{NAV_DAILY}" => t["nav_daily"],
        "{NAV_BLOG}" => t["nav_blog"],
        "{NAV_NOTES}" => t["nav_notes"],
        "{NAV_ABOUT}" => t["nav_about"],
        "{LANG_SWITCHER_LABEL}" => t["lang_switcher_label"],
        "{THEME_ARIA}" => t["theme_aria"],
    )
end

function wrap_page(
    locale::AbstractString,
    logical_path::AbstractString,
    title::AbstractString,
    description::AbstractString,
    content::AbstractString,
)
    header = apply_chrome(
        header_template,
        locale,
        logical_path;
        title=title,
        description=description,
    )
    footer = apply_chrome(
        footer_template,
        locale,
        logical_path;
        title=title,
        description=description,
    )
    return header * content * footer
end

function build_out_path(locale::AbstractString, rel::AbstractString)
    if locale == "fr"
        return joinpath("build", "fr", rel)
    end
    return joinpath("build", rel)
end

function write_page(locale::AbstractString, rel::AbstractString, html::AbstractString)
    path = build_out_path(locale, rel)
    mkpath(dirname(path))
    open(path, "w") do io
        write(io, html)
    end
end

# Handling blog posts (content shared; shell per locale)
println("Handling blog posts...")
mkpath("build/blog")
mkpath("build/fr/blog")
posts = []
post_bodies = Dict{String,Dict{String,String}}()
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
        continue
    end
    content = read(`pandoc src/posts/$filename --shift-heading-level-by=1`, String)
    excerpt = read(`pandoc src/posts/$filename -t plain`, String)

    post = Dict("slug" => slug, "title" => title, "date" => date, "tags" => tags)
    push!(posts, post)
    post_bodies[slug] = Dict(
        "title" => title,
        "date" => date,
        "content" => content,
        "excerpt" => excerpt,
    )
end

posts = sort(posts, by=p -> Date(p["date"]), rev=true)
post_link_template = read("src/templates/post-link.html", String)
posts_template = read("src/templates/posts.html", String)
post_template = read("src/templates/post.html", String)

for locale in LOCALES
    t = I18N[locale]
    for (slug, body) in post_bodies
        content = localize_hrefs(body["content"], locale)
        templated = replace(
            post_template,
            "{TITLE}" => body["title"],
            "{DATE}" => body["date"],
            "{CONTENT}" => content,
            "{CONTENT_LANG_NOTE}" => t["content_lang_note"],
        )
        output = wrap_page(
            locale,
            "/blog/" * slug,
            body["title"] * " - Damien Gonot",
            excerpt_description(body["excerpt"]),
            templated,
        )
        write_page(locale, "blog/$slug.html", output)
    end

    posts_list = [
        replace(
            post_link_template,
            "{TITLE}" => post["title"],
            "{SLUG}" => post["slug"],
            "{DATE}" => post["date"],
            "{PREFIX}" => t["prefix"],
        ) for post in posts
    ]
    content = replace(
        posts_template,
        "{CONTENT}" => join(posts_list),
        "{BLOG_TITLE}" => t["blog_title"],
        "{BLOG_INTRO}" => t["blog_intro"],
    )
    output = wrap_page(
        locale,
        "/blog",
        t["blog_page_title"],
        t["blog_page_description"],
        content,
    )
    write_page(locale, "blog.html", output)
end

# Handling daily
println("Handling daily...")
mkpath("build/daily")
mkpath("build/fr/daily")
dailies_raw = []
daily_dir = "src/daily"
if isdir(daily_dir)
    for filename in readdir(daily_dir)
        endswith(filename, ".org") || continue
        println("  Handling daily: $filename")
        local slug = replace(filename, ".org" => "")
        local date = Date(slug)
        local content = read(
            `pandoc $daily_dir/$filename --from=org --shift-heading-level-by=1`,
            String,
        )
        local excerpt = read(
            `pandoc $daily_dir/$filename --from=org -t plain`,
            String,
        )
        push!(
            dailies_raw,
            Dict(
                "slug" => slug,
                "date" => date,
                "content" => content,
                "excerpt" => excerpt,
            ),
        )
    end
end

dailies_raw = sort(dailies_raw, by=d -> d["date"], rev=true)
daily_day_template = read("src/templates/daily-day.html", String)
daily_entry_template = read("src/templates/daily-entry.html", String)
daily_list_template = read("src/templates/daily.html", String)

latest_daily_by_locale = Dict{String,String}()
posts_list_by_locale = Dict{String,Vector{String}}()

for locale in LOCALES
    t = I18N[locale]
    posts_list_by_locale[locale] = [
        replace(
            post_link_template,
            "{TITLE}" => post["title"],
            "{SLUG}" => post["slug"],
            "{DATE}" => post["date"],
            "{PREFIX}" => t["prefix"],
        ) for post in posts
    ]

    dailies = [
        Dict(
            "slug" => d["slug"],
            "date" => d["date"],
            "title" => format_daily_title(d["date"], locale),
            "weekday" => format_daily_weekday(d["date"], locale),
            "content" => localize_hrefs(d["content"], locale),
            "excerpt" => d["excerpt"],
        ) for d in dailies_raw
    ]

    for (i, day) in enumerate(dailies)
        prev_html = if i < length(dailies)
            older = dailies[i + 1]
            """<a href="$(t["prefix"])/daily/$(older["slug"])" class="hover:text-indigo-600 dark:hover:text-indigo-400">← $(older["title"])</a>"""
        else
            ""
        end
        next_html = if i > 1
            newer = dailies[i - 1]
            """<a href="$(t["prefix"])/daily/$(newer["slug"])" class="hover:text-indigo-600 dark:hover:text-indigo-400">$(newer["title"]) →</a>"""
        else
            ""
        end

        templated_string = replace(
            daily_day_template,
            "{TITLE}" => day["title"],
            "{SLUG}" => day["slug"],
            "{WEEKDAY}" => day["weekday"],
            "{CONTENT}" => day["content"],
            "{PREV}" => prev_html,
            "{NEXT}" => next_html,
            "{PREFIX}" => t["prefix"],
            "{DAILY_TITLE}" => t["daily_title"],
            "{CONTENT_LANG_NOTE}" => t["content_lang_note"],
        )
        output = wrap_page(
            locale,
            "/daily/" * day["slug"],
            day["title"] * t["daily_suffix"],
            excerpt_description(day["excerpt"]),
            templated_string,
        )
        write_page(locale, "daily/$(day["slug"]).html", output)
    end

    daily_entries = [
        replace(
            daily_entry_template,
            "{TITLE}" => day["title"],
            "{SLUG}" => day["slug"],
            "{WEEKDAY}" => day["weekday"],
            "{CONTENT}" => day["content"],
            "{PREFIX}" => t["prefix"],
        ) for day in dailies
    ]
    daily_content = replace(
        daily_list_template,
        "{CONTENT}" => join(daily_entries),
        "{DAILY_TITLE}" => t["daily_title"],
        "{DAILY_INTRO}" => t["daily_intro"],
    )
    daily_output = wrap_page(
        locale,
        "/daily",
        t["daily_page_title"],
        t["daily_page_description"],
        daily_content,
    )
    write_page(locale, "daily.html", daily_output)

    latest_daily_by_locale[locale] = if isempty(dailies)
        t["no_daily"]
    else
        day = dailies[1]
        replace(
            daily_entry_template,
            "{TITLE}" => day["title"],
            "{SLUG}" => day["slug"],
            "{WEEKDAY}" => day["weekday"],
            "{CONTENT}" => day["content"],
            "{PREFIX}" => t["prefix"],
        )
    end
end

# Handling notes (shared content; shell per locale)
println("Handling notes...")
has_notes = isfile("src/notes.org") && isdir("src/notes")
note_pages = Dict{String,Dict{String,String}}()  # slug => title/content/excerpt

if has_notes
    mkpath("build/notes")
    mkpath("build/fr/notes")
    for (root, dirs, files) in walkdir("src/notes")
        for dir in dirs
            # Directories created per-locale when writing
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
                note_pages[slug] = Dict(
                    "title" => title,
                    "content" => content,
                    "excerpt" => excerpt,
                )
            elseif type == "png"
                run(`cp $filename src/public/images/$file`)
            end
        end
    end

    default_template = read("src/templates/default.html", String)
    for locale in LOCALES
        t = I18N[locale]
        for (slug, body) in note_pages
            content = localize_hrefs(body["content"], locale)
            templated = replace(
                default_template,
                "{TITLE}" => body["title"],
                "{CONTENT}" => content,
                "{CONTENT_LANG_NOTE}" => t["content_lang_note"],
            )
            output = wrap_page(
                locale,
                "/notes/" * slug,
                body["title"] * t["notes_suffix"],
                excerpt_description(body["excerpt"]),
                templated,
            )
            write_page(locale, "notes/$slug.html", output)
        end
    end
else
    println("  Skipping notes (src/notes not found)")
end

# Other routes (home, about, citadel, notes index)
println("Handling other routes...")

# Pre-render org/html sources once where possible
function render_org_route(source_path::AbstractString, heading::AbstractString, locale::AbstractString)
    template = read("src/templates/default.html", String)
    html = replace(
        read(`pandoc $source_path --shift-heading-level-by=1`, String),
        ".org\">" => "\">",
    )
    html = localize_hrefs(html, locale)
    return replace(
        template,
        "{TITLE}" => heading,
        "{CONTENT}" => html,
        "{CONTENT_LANG_NOTE}" => "",
    )
end

for locale in LOCALES
    t = I18N[locale]
    println("  Locale: $locale")

    # Homepage
    home_source = locale == "fr" ? "src/fr/index.html" : "src/index.html"
    home_content = read(home_source, String)
    home_content = replace(
        home_content,
        "{RECENT_BLOG_POSTS}" => join(posts_list_by_locale[locale][1:min(5, length(posts))]),
        "{LATEST_DAILY}" => latest_daily_by_locale[locale],
    )
    home_output = wrap_page(
        locale,
        "",
        t["home_title"],
        t["home_description"],
        home_content,
    )
    write_page(locale, "index.html", home_output)

    # About
    about_source = locale == "fr" ? "src/fr/about.org" : "src/about.org"
    about_content = render_org_route(about_source, t["about_heading"], locale)
    # Ensure résumé link is root-absolute from any locale path
    about_content = replace(
        about_content,
        "href=\"file:///damiengonot_resume.pdf\"" => "href=\"/damiengonot_resume.pdf\"",
        "href=\"damiengonot_resume.pdf\"" => "href=\"/damiengonot_resume.pdf\"",
    )
    about_output = wrap_page(
        locale,
        "/about",
        t["about_title"],
        t["about_description"],
        about_content,
    )
    write_page(locale, "about.html", about_output)

    # Citadel
    citadel_source = locale == "fr" ? "src/fr/citadel.org" : "src/citadel.org"
    citadel_content = render_org_route(citadel_source, t["citadel_heading"], locale)
    # Image path in org is relative; force absolute public path
    citadel_content = replace(citadel_content, "href=\"./images/" => "href=\"/images/")
    citadel_content = replace(citadel_content, "src=\"./images/" => "src=\"/images/")
    citadel_output = wrap_page(
        locale,
        "/citadel",
        t["citadel_title"],
        t["citadel_description"],
        citadel_content,
    )
    write_page(locale, "citadel.html", citadel_output)

    # Notes index
    if has_notes
        notes_content = render_org_route("src/notes.org", t["notes_heading"], locale)
        # For FR, also prefix relative notes links that pandoc may emit without leading slash
        if locale == "fr"
            notes_content = replace(notes_content, "href=\"notes/" => "href=\"/fr/notes/")
        end
        notes_output = wrap_page(
            locale,
            "/notes",
            t["notes_title"],
            t["notes_description"],
            notes_content,
        )
        write_page(locale, "notes.html", notes_output)
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
