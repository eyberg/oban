require 'oban/colorify'

class Oban
  include Colorify

  attr_accessor :config
  attr_accessor :heroku_remote

  def initialize
    conf_file = ENV['HOME'] + '/.oban.yml'

    unless FileTest.exist?(conf_file)
      puts colorRed('Missing Conf File!')
      puts colorRed('\tPlease copy oban.yml.example to ~/.oban.yml and edit')
      exit
    end

    self.config = YAML::load(File.open(conf_file) { |f| @stuff = f.read })
    
    # grab config for current repository (based on github)
    current = `git remote show origin | grep Fetch`

    current = current.split("URL:").last.strip
    remote = ""

    config.each do |e|
      if !e["github"].match(current).nil? then
        remote = e["heroku"]
      end
    end

    unless !remote.empty?
      puts colorRed("Could not Find Remote! Sorry")
      puts colorRed("please ensure your ~/.oban.yml has a remote listed for this repo")
      exit
    end

    self.heroku_remote = remote

    puts colorBlue("using #{heroku_remote}")
  end

  def push
    # switch to master before anything else
    `git checkout master`

    puts colorBlue('deploying')

    # make sure we have config/s3.yml
    # make sure we have config/mongo.yml
    # make sure we have config/database.yml

    # test to see if deploy exists.. wipe it if it does..
    branches = `git branch`

    if !branches.match('deploy').nil? then
      `git branch -D deploy`
    end

    # create new branch then checkout
    `git branch deploy`
    `git checkout deploy`

    # rm git modules
    # needs to be refactored a bit better
    `rm -rf .gitmodules`

    #`rm -rf app/models/shared/.git`
    `rm -rf app/models/.git`

    `git rm --cached app/models`

    #`git rm --cached app/models`
    #`git rm --cached app/models/shared`

    # Time.now.to_i hack?

    `git add app/models`

    #`rm -rf \`find . -mindepth 2 -name .git\``
    #`git add .`

    # only add remotes if necessary
    remotes = `git remote`

    if remotes.match('heroku').nil? then
      heroku_remote = ""
      `git remote add heroku #{heroku_remote}`
    end

    `git commit -a -m "deploying"`
    # btw --force should NEVER be used (except for this case) ;)
    `git push --force heroku HEAD:master`

    # add back in our submodules
    puts colorBlue('switching back to master')
    `git checkout master`
    `git submodule init`
    `git submodule update`
  end

end
