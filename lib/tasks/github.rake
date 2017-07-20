namespace :github do
  task register_hook: :environment do
    apiconfig = YAML.load(File.open(Rails.root.to_s + "/config/apiconfig.yml"))
    client = Octokit::Client.new(:login => apiconfig["github"]["login"], :password => apiconfig["github"]["password"])
    res = client.create_hook(
      'TakuKobayashi/board_game_mania',
      'board_game_mania',
      {
        :url => 'https://www.boardgame-mania.click/',
        :content_type => 'json'
      },
      {
        :events => ['push'],
        :active => true
      }
    )
    p res
  end
end