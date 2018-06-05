###
# Compass
###

# Change Compass configuration
# compass_config do |config|
#   config.output_style = :compact
# end

###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
# page "/path/to/file.html", :layout => false
#
# With alternative layout
# page "/path/to/file.html", :layout => :otherlayout
#
# A path which all have the same layout
# with_layout :admin do
#   page "/admin/*"
# end

with_layout "2018" do
  page "/2018/*"
end

# Proxy pages (https://middlemanapp.com/advanced/dynamic_pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", :locals => {
#  :which_fake_page => "Rendering a fake page with a local variable" }

# newsletter referenced /visiting; add a proxy so it doesn't 404
proxy "/visiting/index.html", "/about.html"

data.previous_speakers.each do |conference|
  conference.speakers.each do |speaker|
    slug = speaker.name.downcase.gsub(/\s+/, '-')

    proxy "/previous-speakers/#{conference.year}/#{slug}.html",
      "/individual_speaker.html",
      locals: { speaker: speaker },
      ignore: true
  end
end

data.speakers.each do |speaker|
  slug = speaker.name.downcase.gsub(/\s+/, '-')

  proxy "/speakers/#{slug}.html", "/individual_speaker.html",
    locals: { speaker: speaker },
    ignore: true
end
###
# Helpers
###

# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes

activate :directory_indexes

# Reload the browser automatically whenever files change
configure :development do
  activate :livereload
end

# Methods defined in the helpers block are available in templates
helpers do
  def get_schedule(schedule, speakers)
    # This is kludgy bs because I didn't want to actually implement an ORM.
    schedule.map do |day|
      events = day["events"].map do |event|
        if event["speaker_name"]
          speaker = speakers.select { |s| s["name"] == event["speaker_name"] }
                            .first
          if speaker
            event.merge speaker
          else
            event
          end
        else
          event
        end
      end
      events        = events.reject { |e| e["name"].nil? || e["name"] == "" }
      day["events"] = events.sort_by { |e| e["start_time"] }
      day
    end
  end

  def format_time(start)
    parsed_time = Time.strptime(start, "%H%M")
    parsed_time.strftime("%l:%M %p")
               .gsub(" ", "&nbsp;")
  end

  def generate_slug(name)
    name.downcase.gsub(/\s+/, '-')
  end

  def sort_by_name(items)
    items.sort_by { |item| item["name"] }
  end

  def sort_by_length(items = [])
    items.sort_by { |item| (item["abstract"] || []).length }
  end

  def titlelize(name = "")
    name
      .split("_")
      .map(&:capitalize)
      .join(" ")
  end
end

set :css_dir, 'stylesheets'

set :js_dir, 'javascripts'

set :images_dir, 'images'

# Build-specific configuration
configure :build do
  activate :minify_css
  activate :minify_javascript
  activate :asset_hash
  activate :relative_assets

  # Or use a different image path
  # set :http_prefix, "/Content/images/"
end

after_build do |builder|
  src = "./CNAME"
  dst = File.join(config[:build_dir],"CNAME")
  builder.source_paths << File.dirname(__FILE__)
  builder.copy_file(src,dst)
end

activate :deploy do |deploy|
  deploy.build_before = true
  deploy.method = :git
  deploy.remote = 'git@github.com:OSFeels/osfeels.github.io.git'
  deploy.branch = 'master'
end
