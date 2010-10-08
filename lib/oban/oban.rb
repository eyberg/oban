require 'oban/colorify'

class Oban
  include Colorify

  attr_accessor :config
  attr_accessor :heroku_remote
  attr_accessor :submods  # TODO: should be a list eventually

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

    unless !current.empty? then
      puts colorRed("Not a git repository!")
      exit
    end

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

    set_submods

    puts colorBlue("using #{heroku_remote}")
  end

  # only supports one right now -- FIXME
  def set_submods
    submods = `git submodule status`

    if !submods.empty?
      self.submods = submods.split[1]
    
      puts colorBlue("found submodule: #{self.submods}")
    end

  end

  def rm_submods
    # rm git modules
    `rm -rf .gitmodules`

    puts colorBlue("removing submodule: #{self.submods}")
    `rm -rf #{self.submods}/.git`

    `git rm --cached #{self.submods}`
  end

  def add_submod_data
    `git add #{self.submods}`
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

    if !self.submods.nil? then
      rm_submods
      add_submod_data
    end

    # only add remotes if necessary
    remotes = `git remote`

    if remotes.match('heroku').nil? then
      `git remote add heroku #{self.heroku_remote}`
    end

    `git commit -a -m "deploying"`
    # btw --force should NEVER be used (except for this case) ;)
    `git push --force heroku HEAD:master`

    # add back in our submodules
    puts colorBlue('switching back to master')
    `git checkout master`
    `git submodule init`
    `git submodule update`

    # ensure we checkout master (cause it'll default to headless)
    `git --git-dir=#{self.submods}/.git checkout master`

  end

end
