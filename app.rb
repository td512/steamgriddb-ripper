require 'rest-client'
require 'json'
require 'nice_hash'
require 'fileutils'
require 'open-uri'

api_key = '' # API Key from https://www.steamgriddb.com/profile/preferences

steam_applist = RestClient.get('https://api.steampowered.com/ISteamApps/GetAppList/v2/')
decoded_applist = steam_applist.json
total_apps = decoded_applist.applist.apps.count
counter = 1
decoded_applist.applist.apps.each do |app|
  grid_id = 0
  puts "Processing #{app.name}, AppID: #{app.appid}"
  begin
    res = RestClient.get("https://www.steamgriddb.com/api/v2/games/steam/#{app.appid}",
                         {authorization: "Bearer #{api_key}"})
    grid_id = res.body.json.data.id
  rescue RestClient::NotFound
    puts "No games found for #{app.name}, skipping"
    puts "Processed #{counter}/#{total_apps}, #{total_apps - counter} to go"
    counter += 1
    puts ""
    next
  rescue RestClient::Unauthorized
    puts "Unauthorized, fill in your API key for Steam Grid DB on line 6"
    exit 1
  end

  begin
    res = RestClient.get("https://www.steamgriddb.com/api/v2/grids/game/#{grid_id}",
                         {authorization: "Bearer #{api_key}"})
    puts "No grids found for #{app.name}" if res.body.json.data.empty?
    res.body.json.data.each do |grid|
      begin
        open(grid.url) do |image|
          FileUtils.mkdir_p("output/#{app.name.gsub(/[^0-9A-Za-z.\-\ \(\)\,\.\'\_\[\]\;\'\!\@\#\$\%\^\&\+\=\-]/, '-')} (#{app.appid})/grids")
          File.open("output/#{app.name.gsub(/[^0-9A-Za-z.\-\ \(\)\,\.\'\_\[\]\;\'\!\@\#\$\%\^\&\+\=\-]/, '-')} (#{app.appid})/grids/#{grid.url.split('/').last}", 'wb') { |f| f.write(image.read) }
          puts "Saved grid #{grid.id} to output/#{app.name.gsub(/[^0-9A-Za-z.\-\ \(\)\,\.\'\_\[\]\;\'\!\@\#\$\%\^\&\+\=\-]/, '-')} (#{app.appid})/grids/#{grid.url.split('/').last}"
        end
      rescue OpenURI::HTTPError => e
        puts "Unable to save image #{grid.url}, error: #{e}"
      end
    end
  rescue RestClient::NotFound
    puts "No grids found for #{app.name}"
  end

  begin
    res = RestClient.get("https://www.steamgriddb.com/api/v2/heroes/game/#{grid_id}",
                         {authorization: "Bearer #{api_key}"})
    puts "No heroes found for #{app.name}" if res.body.json.data.empty?
    res.body.json.data.each do |grid|
      begin
        open(grid.url) do |image|
          FileUtils.mkdir_p("output/#{app.name.gsub(/[^0-9A-Za-z.\-\ \(\)\,\.\'\_\[\]\;\'\!\@\#\$\%\^\&\+\=\-]/, '-')} (#{app.appid})/heroes")
          File.open("output/#{app.name.gsub(/[^0-9A-Za-z.\-\ \(\)\,\.\'\_\[\]\;\'\!\@\#\$\%\^\&\+\=\-]/, '-')} (#{app.appid})/heroes/#{grid.url.split('/').last}", 'wb') { |f| f.write(image.read) }
          puts "Saved hero #{grid.id} to output/#{app.name.gsub(/[^0-9A-Za-z.\-\ \(\)\,\.\'\_\[\]\;\'\!\@\#\$\%\^\&\+\=\-]/, '-')} (#{app.appid})/grids/#{grid.url.split('/').last}"
        end
      rescue OpenURI::HTTPError => e
        puts "Unable to save image #{grid.url}, error: #{e}"
      end
    end
  rescue RestClient::NotFound
    puts "No heroes found for #{app.name}"
  end

  begin
    res = RestClient.get("https://www.steamgriddb.com/api/v2/logos/game/#{grid_id}",
                         {authorization: "Bearer #{api_key}"})
    puts "No logos found for #{app.name}" if res.body.json.data.empty?
    res.body.json.data.each do |grid|
      begin
        open(grid.url) do |image|
          FileUtils.mkdir_p("output/#{app.name.gsub(/[^0-9A-Za-z.\-\ \(\)\,\.\'\_\[\]\;\'\!\@\#\$\%\^\&\+\=\-]/, '-')} (#{app.appid})/logos")
          File.open("output/#{app.name.gsub(/[^0-9A-Za-z.\-\ \(\)\,\.\'\_\[\]\;\'\!\@\#\$\%\^\&\+\=\-]/, '-')} (#{app.appid})/logos/#{grid.url.split('/').last}", 'wb') { |f| f.write(image.read) }
          puts "Saved logo #{grid.id} to output/#{app.name.gsub(/[^0-9A-Za-z.\-\ \(\)\,\.\'\_\[\]\;\'\!\@\#\$\%\^\&\+\=\-]/, '-')} (#{app.appid})/grids/#{grid.url.split('/').last}"
        end
      rescue OpenURI::HTTPError => e
        puts "Unable to save image #{grid.url}, error: #{e}"
      end
    end
  rescue RestClient::NotFound
    puts "No logos found for #{app.name}"
    puts ""
  end
  puts "Processed #{counter}/#{total_apps}, #{total_apps - counter} to go"
  counter += 1
  puts ""
end