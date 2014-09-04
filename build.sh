#!/bin/bash

if [[ -s "$HOME/.rvm/scripts/rvm" ]]
  then
    source "$HOME/.rvm/scripts/rvm"
    export RVM_RUBY=$(cat .ruby-version)
    export RVM_GEMSET=$(cat .ruby-gemset)
    rvm use $RVM_RUBY@$RVM_GEMSET --create
fi

bundle install
bundle exec rake test
