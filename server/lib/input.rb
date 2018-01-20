# This needs to be changed out to a Javascript implementation for the browser.
module Input
  # √
  def get_input(opts={})
    opts.values.each.with_index |prompt, idx|
      print "#{idx + 1}: "
      puts prompt
    end
    choice = gets.chomp.to_i - 1
    result = opts[opts.keys[choice]]
    return result if result
    puts "\n#{"invalid option".red}\n"
    get_input opts
  end
end
