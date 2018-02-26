namespace :github do
  task register_hook: :environment do
    client = Octokit::Client.new(:login => ENV.fetch("GITHUB_LOGIN_ACCOUNT_NAME", ""), :password => ENV.fetch("GITHUB_LOGIN_PASSWORD", ""))
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