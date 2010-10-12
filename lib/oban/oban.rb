require 'oban/colorify'

class Oban
  include Colorify

  attr_accessor :config
  attr_accessor :heroku_remote
  attr_accessor :submods  # TODO: should be a list eventually

  def initialize
    set_config
  end

  def real_init
    check_for_clean

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

    set_remotes

    set_submods

  end

  # show help message
  def show_help
    puts colorBlue("oban v??")
    puts colorBlue("homepage: http://github.com/feydr/oban")
    puts colorBlue("clone: git@github.com:feydr/oban.git")
    puts colorBlue("\r" + "-"*20)
    puts colorBlue("\tCommands:")
    puts colorBlue("\t--help\tthis listing")
    puts colorBlue("\tdeploy\tdeploy the local repository")
    puts colorBlue("\trollback\trollback the local repository")
    exit
  end

  # check for any uncommitted changes and bail if found
  def check_for_clean
    # can't believe there's not a simple yes/no here..
    out = `git status --porcelain`

    unless out.empty? then
      puts colorRed("you have uncommitted changes -- please commit and try again:\r\t#{out}")
      exit
    end

  end

  def set_remotes
    # only add remotes if necessary
    remotes = `git remote`

    if remotes.match('heroku').nil? then
      `git remote add heroku #{self.heroku_remote}`
    end
  end

  # checkout deploy - 1 branch from github and push to heroku
  def rollback
    puts colorBlue('rolling back to commit blah')
  end

  # ensure that our submodule is reset
  def reinit_submods
    # add back in our submodules
    `git submodule init`
    `git submodule update`

    # ensure we checkout master (cause it'll default to headless)
    `git --git-dir=#{self.submods}/.git checkout master`
  end

  def set_config
    home_conf_file = ENV['HOME'] + '/.oban.yml'
    cwd_conf_file = '.oban.yml'

    g2g = false

    if FileTest.exist?(home_conf_file) then
      self.config = YAML::load(File.open(home_conf_file) { |f| @stuff = f.read })
      g2g = true
    end

    if FileTest.exist?(cwd_conf_file) then
      self.config = YAML::load(File.open(cwd_conf_file) { |f| @stuff = f.read })
      g2g = true
    end

    unless g2g
      puts colorRed("Missing Conf File!")
      puts colorRed("\tPlease copy oban.yml.example to ~/.oban.yml or project_root and edit")
      exit
    end
  end

  # only supports one right now -- FIXME
  def set_submods
    submods = `git submodule status`

    if !submods.empty?
      self.submods = submods.split[1]
    end

  end

  # remove all mention of submodules but leave the data in
  def rm_submods
    # rm git modules
    `rm -rf .gitmodules`

    puts colorBlue("removing submodule: #{self.submods}")
    `rm -rf #{self.submods}/.git`

    `git rm --cached #{self.submods}`
  end

  # add in submod data
  def add_submod_data
    `git add #{self.submods}`
  end

  def deploy

    real_init

    # switch to master before anything else
    `git checkout master`

    puts colorBlue('deploying')

    # might need to change the logic on this to do reset --hard and
    # friends so we don't clobber the remote deploy branch

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

    `git commit -a -m "deploying"`

    # push to deploy branch first
    `git push origin +deploy`

    # btw --force should NEVER be used (except for this case) ;)
    `git push --force heroku HEAD:master`

    # add back in our submodules
    puts colorBlue('switching back to master')
    `git checkout master`

    reinit_submods

  end

end
