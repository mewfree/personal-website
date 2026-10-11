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
rm("build"; recursive=true, force=true)
if has_meworg
    println("Importing notes from $meworg_root ...")
    rm("src/notes"; recursive=true, force=true)
    write(
        "src/notes.org",
        replace(read(meworg_org, String), "university" => "notes", "University" => "Notes"),
    )
    cp(meworg_dir, "src/notes")
else
    println("No meworg at $meworg_root; using committed notes if present")
end

# Static assets first; generated files (note images, pages) are written over them.
cp("src/public", "build")

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
        "about_description" => "About Damien Gonot, software developer & marketer. Contact and résumé.",
        "citadel_title" => "Citadel - Damien Gonot",
        "citadel_heading" => "Citadel",
        "citadel_description" => "Damien Gonot's own citadel.",
        "now_title" => "Now - Damien Gonot",
        "now_heading" => "Now",
        "now_description" => "What Damien Gonot is currently using and writing.",
        "notes_title" => "Notes - Damien Gonot",
        "notes_heading" => "Notes",
        "notes_description" => "Damien Gonot's public notes.",
        "notes_suffix" => " - Damien Gonot",
        "not_found_title" => "404 - Page Not Found - Damien Gonot",
        "not_found_heading" => "Page Not Found",
        "not_found_description" => "Sorry, this page does not exist or has moved.",
        "not_found_message" => "Sorry, this page does not exist or has moved.",
        "not_found_home" => "Back to Home",
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
        "about_description" => "À propos de Damien Gonot, développeur et marketer. Contact et CV.",
        "citadel_title" => "Citadelle - Damien Gonot",
        "citadel_heading" => "Citadelle",
        "citadel_description" => "La citadelle de Damien Gonot.",
        "now_title" => "Maintenant - Damien Gonot",
        "now_heading" => "Maintenant",
        "now_description" => "Ce que Damien Gonot utilise et écrit en ce moment.",
        "notes_title" => "Notes - Damien Gonot",
        "notes_heading" => "Notes",
        "notes_description" => "Les notes publiques de Damien Gonot.",
        "notes_suffix" => " - Damien Gonot",
        "not_found_title" => "404 - Page non trouvée - Damien Gonot",
        "not_found_heading" => "Page non trouvée",
        "not_found_description" => "Désolé, cette page n'existe pas ou a été déplacée.",
        "not_found_message" => "Désolé, cette page n'existe pas ou a été déplacée.",
        "not_found_home" => "Retour à l'accueil",
    ),
)

const LANG_ACTIVE =
    "font-semibold text-indigo-600 dark:text-indigo-400"
const LANG_INACTIVE =
    "text-zinc-500 dark:text-zinc-400 hover:text-indigo-600 dark:hover:text-indigo-400"


const SITE_URL = "https://www.damiengonot.com"
const CONTENT_MARKER = "<!--CONTENT-->"
const NAV_LINK_CLASS = "hover:text-indigo-600 dark:hover:text-indigo-400"
const MAX_EXCERPT_CHARS = 297
const RECENT_POSTS = 5

read_template(name) = read(joinpath("src", "templates", "$name.html"), String)

# The shell is rendered once per page; content is spliced in afterwards so that
# placeholder-looking text inside posts (code samples) is never substituted.
const CHROME_TEMPLATE =
    read("src/header.html", String) * CONTENT_MARKER * read("src/footer.html", String)
const POST_LINK_TEMPLATE = read_template("post-link")
const POSTS_TEMPLATE = read_template("posts")
const POST_TEMPLATE = read_template("post")
const DAILY_DAY_TEMPLATE = read_template("daily-day")
const DAILY_ENTRY_TEMPLATE = read_template("daily-entry")
const DAILY_LIST_TEMPLATE = read_template("daily")
const DEFAULT_TEMPLATE = read_template("default")
const NOT_FOUND_TEMPLATE = read_template("404")

const SITEMAP = NamedTuple{(:loc, :lastmod, :changefreq, :priority),NTuple{4,String}}[]

# Concurrent subprocess helpers (pandoc dominates build time).
const PANDOC_TASKS = max(2, Sys.CPU_THREADS)
pmap_files(f, items) = asyncmap(f, items; ntasks=PANDOC_TASKS)

"""(en, fr) URL paths for a logical site path ("" is home)."""
locale_paths(logical_path::AbstractString) =
    isempty(logical_path) ? ("/", "/fr") : (logical_path, "/fr" * logical_path)

localized_path(locale::AbstractString, logical_path::AbstractString) =
    locale_paths(logical_path)[locale == "fr" ? 2 : 1]

format_daily_title(date::Date, locale::AbstractString) =
    locale == "fr" ? "$(day(date)) $(FR_MONTHS[month(date)]) $(year(date))" :
    Dates.format(date, dateformat"U d, Y")

format_daily_weekday(date::Date, locale::AbstractString) =
    locale == "fr" ? FR_WEEKDAYS[dayofweek(date)] : Dates.format(date, dateformat"EEEE")

"""Collapse whitespace and escape for double-quoted HTML attributes (e.g. meta description)."""
html_attr(s::AbstractString) = replace(
    strip(replace(s, r"\s+" => " ")),
    "&" => "&amp;",
    "\"" => "&quot;",
    "<" => "&lt;",
    ">" => "&gt;",
)

"""Plain-text excerpt → one-line meta description."""
function excerpt_description(excerpt::AbstractString; max_chars::Int=MAX_EXCERPT_CHARS)
    plain = strip(replace(excerpt, r"\s+" => " "))
    return first(plain, max_chars) * "..."
end

const LOCALIZED_HREF = r"href=\"(?=/(?:daily|blog|notes|about|citadel|now|resume|homepage))"

"""Rewrite absolute in-site links so FR pages stay under /fr/."""
localize_hrefs(html::AbstractString, locale::AbstractString) =
    locale == "fr" ? replace(html, LOCALIZED_HREF => s"href=\"/fr") : html

has_math_content(html::AbstractString) =
    occursin("class=\"math ", html) || occursin("<math", html)

function wrap_page(
    locale::AbstractString,
    logical_path::AbstractString,
    title::AbstractString,
    description::AbstractString,
    content::AbstractString,
)
    t = I18N[locale]
    en_path, fr_path = locale_paths(logical_path)
    canonical = locale == "fr" ? fr_path : en_path
    has_math = has_math_content(content)
    has_code = occursin("<pre", content)
    chrome = replace(
        CHROME_TEMPLATE,
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
        "{HIGHLIGHT_JS}" => has_code ? """<script defer src="/highlight.js"></script>""" : "",
        "{KATEX_CSS}" => has_math ? """<link rel="stylesheet" href="/katex.min.css">""" : "",
        "{KATEX_JS}" => has_math ?
                        """<script defer src="/katex.min.js"></script>\n      <script defer src="/katex-auto-render.min.js"></script>""" :
                        "",
    )
    head, tail = split(chrome, CONTENT_MARKER; limit=2)
    return head * content * tail
end

"""Render a page, write it under build/ and (optionally) register it in the sitemap."""
function emit!(
    locale::AbstractString,
    logical_path::AbstractString,
    title::AbstractString,
    description::AbstractString,
    content::AbstractString;
    sitemap::Bool=true,
    lastmod::AbstractString="",
    changefreq::AbstractString="monthly",
    priority::AbstractString="0.7",
)
    rel = isempty(logical_path) ? "index.html" : lstrip(logical_path, '/') * ".html"
    path = locale == "fr" ? joinpath("build", "fr", rel) : joinpath("build", rel)
    mkpath(dirname(path))
    write(path, wrap_page(locale, logical_path, title, description, content))
    sitemap && push!(
        SITEMAP,
        (
            loc=SITE_URL * localized_path(locale, logical_path),
            lastmod=String(lastmod),
            changefreq=String(changefreq),
            priority=String(priority),
        ),
    )
    return nothing
end

org_metadata(data::AbstractString) = Dict(
    m["key"] => m["value"] for m in eachmatch(r"#\+(?<key>.*): (?<value>.*)", data)
)

function frontmatter_metadata(data::AbstractString)
    yaml = match(r"---\n(.+?)---"s, data).captures[1]
    yaml = replace(yaml, "[" => "", "]" => "", "\"" => "")
    return Dict(
        (p = split(line, ": "; limit=2); p[1] => p[2]) for line in split(chomp(yaml), "\n")
    )
end

pandoc_html(path::AbstractString; from::AbstractString="") =
    read(`pandoc $path $(isempty(from) ? [] : ["--from=$from"]) --shift-heading-level-by=1`, String)
pandoc_plain(path::AbstractString; from::AbstractString="") =
    read(`pandoc $path $(isempty(from) ? [] : ["--from=$from"]) -t plain`, String)

# Blog posts (content shared; shell per locale)
println("Handling blog posts...")

struct Post
    slug::String
    title::String
    date::String
    content::String
    excerpt::String
end

function load_post(filename::AbstractString)
    path = joinpath("src", "posts", filename)
    slug, ext = splitext(filename)
    data = read(path, String)
    meta = ext == ".org" ? org_metadata(data) : frontmatter_metadata(data)
    return Post(slug, meta["title"], meta["date"], pandoc_html(path), pandoc_plain(path))
end

post_files = filter(f -> splitext(f)[2] in (".md", ".org"), readdir("src/posts"))
posts = sort!(pmap_files(load_post, post_files); by=p -> Date(p.date), rev=true)

post_links = Dict{String,Vector{String}}()

for locale in LOCALES
    t = I18N[locale]

    for post in posts
        content = replace(
            POST_TEMPLATE,
            "{TITLE}" => post.title,
            "{DATE}" => post.date,
            "{CONTENT}" => localize_hrefs(post.content, locale),
            "{CONTENT_LANG_NOTE}" => t["content_lang_note"],
        )
        emit!(
            locale,
            "/blog/" * post.slug,
            post.title * " - Damien Gonot",
            excerpt_description(post.excerpt),
            content;
            lastmod=post.date,
            priority="0.8",
        )
    end

    post_links[locale] = [
        replace(
            POST_LINK_TEMPLATE,
            "{TITLE}" => post.title,
            "{SLUG}" => post.slug,
            "{DATE}" => post.date,
            "{PREFIX}" => t["prefix"],
        ) for post in posts
    ]
    content = replace(
        POSTS_TEMPLATE,
        "{CONTENT}" => join(post_links[locale]),
        "{BLOG_TITLE}" => t["blog_title"],
        "{BLOG_INTRO}" => t["blog_intro"],
    )
    emit!(
        locale,
        "/blog",
        t["blog_page_title"],
        t["blog_page_description"],
        content;
        changefreq="weekly",
        priority="0.9",
    )
end

# Daily
println("Handling daily...")

struct Daily
    slug::String
    date::Date
    content::String
    excerpt::String
end

function load_daily(filename::AbstractString)
    path = joinpath("src", "daily", filename)
    slug = first(splitext(filename))
    return Daily(
        slug,
        Date(slug),
        pandoc_html(path; from="org"),
        pandoc_plain(path; from="org"),
    )
end

daily_files =
    isdir("src/daily") ? filter(endswith(".org"), readdir("src/daily")) : String[]
dailies = sort!(pmap_files(load_daily, daily_files); by=d -> d.date, rev=true)

nav_link(prefix, slug, label) =
    """<a href="$prefix/daily/$slug" class="$NAV_LINK_CLASS">$label</a>"""

latest_daily = Dict{String,String}()

for locale in LOCALES
    t = I18N[locale]
    prefix = t["prefix"]
    titles = [format_daily_title(d.date, locale) for d in dailies]
    weekdays = [format_daily_weekday(d.date, locale) for d in dailies]
    contents = [localize_hrefs(d.content, locale) for d in dailies]

    for (i, day) in enumerate(dailies)
        content = replace(
            DAILY_DAY_TEMPLATE,
            "{TITLE}" => titles[i],
            "{SLUG}" => day.slug,
            "{WEEKDAY}" => weekdays[i],
            "{CONTENT}" => contents[i],
            "{PREV}" =>
                i < length(dailies) ?
                nav_link(prefix, dailies[i+1].slug, "← " * titles[i+1]) : "",
            "{NEXT}" => i > 1 ? nav_link(prefix, dailies[i-1].slug, titles[i-1] * " →") : "",
            "{PREFIX}" => prefix,
            "{DAILY_TITLE}" => t["daily_title"],
            "{CONTENT_LANG_NOTE}" => t["content_lang_note"],
        )
        emit!(
            locale,
            "/daily/" * day.slug,
            titles[i] * t["daily_suffix"],
            excerpt_description(day.excerpt),
            content;
            lastmod=day.slug,
            changefreq="never",
            priority="0.6",
        )
    end

    entries = [
        replace(
            DAILY_ENTRY_TEMPLATE,
            "{TITLE}" => titles[i],
            "{SLUG}" => day.slug,
            "{WEEKDAY}" => weekdays[i],
            "{CONTENT}" => contents[i],
            "{PREFIX}" => prefix,
        ) for (i, day) in enumerate(dailies)
    ]
    content = replace(
        DAILY_LIST_TEMPLATE,
        "{CONTENT}" => join(entries),
        "{DAILY_TITLE}" => t["daily_title"],
        "{DAILY_INTRO}" => t["daily_intro"],
    )
    emit!(
        locale,
        "/daily",
        t["daily_page_title"],
        t["daily_page_description"],
        content;
        changefreq="daily",
        priority="0.9",
    )
    latest_daily[locale] = isempty(entries) ? t["no_daily"] : first(entries)
end

# Notes (shared content; shell per locale)
println("Handling notes...")
has_notes = isfile("src/notes.org") && isdir("src/notes")

struct Note
    slug::String
    title::String
    content::String
    excerpt::String
end

pandoc_math_flag =
    occursin("--math-method", read(`pandoc --help`, String)) ? "--math-method=mathjax" :
    "--mathjax"

function load_note(path::AbstractString)
    slug = first(splitext(relpath(path, "src/notes")))
    data = replace(read(path, String), "university.org][University]" => "notes.org][Notes]")
    lines = map(split(data, "\n")) do line
        startswith(line, "#+begin_src") && !contains(line, ":exports") ?
        line * " :exports both" : line
    end
    joined = join(["#+options: H:6"; lines], "\n")
    content = replace(
        read(
            pipeline(
                `pandoc --quiet --from=org --shift-heading-level-by=1 $pandoc_math_flag`;
                stdin=IOBuffer(joined),
            ),
            String,
        ),
        "./images/" => "/images/",
        ".org\">" => "\">",
    )
    excerpt = replace(
        read(pipeline(`pandoc --quiet --from=org -t plain`; stdin=IOBuffer(joined)), String),
        r"[^a-zA-Z0-9_\s]" => "",
    )
    return Note(slug, org_metadata(data)["title"], content, excerpt)
end

if has_notes
    org_paths = String[]
    mkpath("build/images")
    for (root, _, files) in walkdir("src/notes"), file in files
        path = joinpath(root, file)
        ext = splitext(file)[2]
        if ext == ".org"
            push!(org_paths, path)
        elseif ext == ".png"
            cp(path, joinpath("build", "images", file); force=true)
        end
    end
    notes = pmap_files(load_note, org_paths)

    for locale in LOCALES
        t = I18N[locale]
        for note in notes
            content = replace(
                DEFAULT_TEMPLATE,
                "{TITLE}" => note.title,
                "{CONTENT}" => localize_hrefs(note.content, locale),
                "{CONTENT_LANG_NOTE}" => t["content_lang_note"],
            )
            emit!(
                locale,
                "/notes/" * note.slug,
                note.title * t["notes_suffix"],
                excerpt_description(note.excerpt),
                content,
            )
        end
    end
else
    println("  Skipping notes (src/notes not found)")
end

# Other routes (home, about, citadel, now, notes index, 404)
println("Handling other routes...")

"""Pandoc-render an org source once; per-locale localization happens later."""
function render_org(source_path::AbstractString)
    return replace(
        pandoc_html(source_path),
        ".org\">" => "\">",
        "href=\"file:///now\"" => "href=\"/now\"",
        "href=\"file:///damiengonot_resume.pdf\"" => "href=\"/damiengonot_resume.pdf\"",
        "href=\"damiengonot_resume.pdf\"" => "href=\"/damiengonot_resume.pdf\"",
        "href=\"./images/" => "href=\"/images/",
        "src=\"./images/" => "src=\"/images/",
    )
end

route_content(html::AbstractString, heading::AbstractString, locale::AbstractString) =
    replace(
        DEFAULT_TEMPLATE,
        "{TITLE}" => heading,
        "{CONTENT}" => localize_hrefs(html, locale),
        "{CONTENT_LANG_NOTE}" => "",
    )

# (logical path, i18n key stem, source basename, priority)
const ORG_ROUTES = (
    ("/about", "about", "about.org", "0.7"),
    ("/citadel", "citadel", "citadel.org", "0.5"),
    ("/now", "now", "now.org", "0.7"),
)

org_sources = Dict(
    (locale, route[1]) =>
        render_org(joinpath("src", locale == "fr" ? "fr" : "", route[3])) for
    locale in LOCALES for route in ORG_ROUTES
)
notes_index_html = has_notes ? render_org("src/notes.org") : ""

for locale in LOCALES
    t = I18N[locale]
    println("  Locale: $locale")

    home_source = joinpath("src", locale == "fr" ? "fr" : "", "index.html")
    home_content = replace(
        read(home_source, String),
        "{RECENT_BLOG_POSTS}" => join(first(post_links[locale], RECENT_POSTS)),
        "{LATEST_DAILY}" => latest_daily[locale],
    )
    emit!(
        locale,
        "",
        t["home_title"],
        t["home_description"],
        home_content;
        changefreq="daily",
        priority="1.0",
    )

    for (path, key, _, priority) in ORG_ROUTES
        emit!(
            locale,
            path,
            t["$(key)_title"],
            t["$(key)_description"],
            route_content(org_sources[(locale, path)], t["$(key)_heading"], locale);
            priority=priority,
        )
    end

    if has_notes
        html = notes_index_html
        # pandoc may emit relative notes links; keep FR ones under /fr/
        locale == "fr" && (html = replace(html, "href=\"notes/" => "href=\"/fr/notes/"))
        emit!(
            locale,
            "/notes",
            t["notes_title"],
            t["notes_description"],
            route_content(html, t["notes_heading"], locale);
            changefreq="weekly",
            priority="0.8",
        )
    end

    not_found_content = replace(
        NOT_FOUND_TEMPLATE,
        "{NOT_FOUND_HEADING}" => t["not_found_heading"],
        "{NOT_FOUND_MESSAGE}" => t["not_found_message"],
        "{NOT_FOUND_HOME}" => t["not_found_home"],
        "{HOME_HREF}" => t["home_href"],
        "{PREFIX}" => t["prefix"],
        "{NAV_DAILY}" => t["nav_daily"],
        "{NAV_BLOG}" => t["nav_blog"],
        "{NAV_NOTES}" => t["nav_notes"],
    )
    emit!(
        locale,
        "/404",
        t["not_found_title"],
        t["not_found_description"],
        not_found_content;
        sitemap=false,
    )
end

# Sitemap
println("Generating sitemap.xml...")
open("build/sitemap.xml", "w") do io
    println(io, """<?xml version="1.0" encoding="UTF-8"?>""")
    println(io, """<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">""")
    for item in SITEMAP
        println(io, "  <url>")
        println(io, "    <loc>$(item.loc)</loc>")
        isempty(item.lastmod) || println(io, "    <lastmod>$(item.lastmod)</lastmod>")
        println(io, "    <changefreq>$(item.changefreq)</changefreq>")
        println(io, "    <priority>$(item.priority)</priority>")
        println(io, "  </url>")
    end
    println(io, "</urlset>")
end

# Wrap it up
println("Wrapping it up...")
run(`npx @tailwindcss/cli -i ./src/input.css -o ./build/main.css --minify`)
run(
    `npx html-minifier-terser --input-dir ./build --output-dir ./build --collapse-whitespace --minify-js true --file-ext html`,
)

println("Website has been generated!")
