####ABOUT:

oban hopes to simplify the deploy process for apps on heroku that use
submodules

####INSTALL:
  sudo gem install oban --no-ri --no-rdoc

  # edit oban.yml.example
  cp oban.yml ~/.oban.yml

####Example Deploy:
  me@myhost:~/my_proj$ oban

####TODO:
  * right now if you have a fairly large repo it can take some time to
    upload -- I'd like to get rid of the push --force hack and do some
    intelligent diffing instead
  * testing!
  * support for multiple submodules (right now it only does one)
