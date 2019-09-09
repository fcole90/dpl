module Wrap
  extend self

  def wrap(str, width = 80)
    str.lines.map do |line|
      line.size > width ? line.gsub(/(.{1,#{width}})(\s+|$)/, "\\1\n").strip : line
    end.join("\n")
  end
end
