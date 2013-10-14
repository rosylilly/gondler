require 'readline'
require 'gondler'

class Gondler::REPL
  def self.run
    new.run
  end

  def initialize
  end

  def run
    while (buf = Readline.readline("> ", true))
      execute(buf)
    end
  end

  def execute(line)
    cmd = line.match(/\A\w+/).to_s

    if builtin.include?(cmd)
      Gondler::CLI.start(line.split(/\s+/))
    else
      system(line)
    end
  end

  def builtin
    @builtin ||= builtin_commands.keys + ['help']
  end

  def builtin_commands
    @builtin_commands ||= Gondler::CLI.commands
  end
end
