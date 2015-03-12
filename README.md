# Gondler

[![Build Status](https://travis-ci.org/rosylilly/gondler.png?branch=master)](https://travis-ci.org/rosylilly/gondler)

bundler for golang. inspired by [gom](https://github.com/mattn/gom).

## Installation

    $ gem install gondler

## Usage

1. Write your Gomfile

   ```
   gom 'github.com/golang/glog'
   ```
2. Install dependency packages: `gondler install`
3. Build your application: `gondler build`
4. Run tests: `gondler test`

## Gomfile

like gom's Gomfile

```ruby
itself 'github.com/rosylilly/test'

autodetect

gom 'github.com/golang/glog'
package 'github.com/golang/glog'

gom 'github.com/golang/glog', commit: 'c6f9652c7179652e2fd8ed7002330db089f4c9db'
gom 'github.com/golang/glog', branch: 'master'
gom 'github.com/golang/glog', tag: 'go1'

gom 'github.com/golang/glog', group: ['development', 'test']
group :development, :test do
  gom 'github.com/golang/glog'
end

gom 'github.com/golang/glog', os: ['linux', 'darwin']
os :linux, :darwin do
  gom 'github.com/golang/glog'
end
```

## Commands

    build           # Build with dependencies specified in your Gomfile
    exec            # Execute a command in the context of Gondler
    help [COMMAND]  # Describe available commands or one specific command
    install         # Install the dependecies specified in your Gomfile
    list            # Show all of the dependencies in the current bundle
    repl            # REPL in the context of Gondler
    test            # Test with dependencies specified in your Gomfile
    version         # Print Gondler version

## Custom commands

Gondler supports custom commands.

1. Create a executable script file somewhere in your executable paths. It must use the following naming schema `gondler-your-command`.
2. This file can be written in any scripting language or binaries.
3. Now your could use it as `gondler your-command`.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
