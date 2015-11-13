require 'pp'

class String
  # http://stackoverflow.com/a/11006397
  def balanced_parentheses?
    valid = true
    self.gsub(/[^\(\)]/, '').split('').inject(0) do |counter, parenthesis|
      counter += (parenthesis == '(' ? 1 : -1)
      valid = false if counter < 0
      counter
    end.zero? && valid
  end
end

def main
  patterns = find_patterns(10)

  combinators = Hash[patterns.map {|k,v| [k, v.flat_map {|p| combinators_by_pattern(p)}.sort]}.sort]

  puts "Counts:"
  pp Hash[combinators.map {|k,v| [k,v.size] }] 
  puts "Terms:"
  pp combinators
end

def find_patterns(max_n)
  patterns = Hash.new { |h, k| h[k] = [] }
  patterns[1] = ["X"] # in "patterns", X is a placeholder for variables

  # Alternate between search and simplify steps many times to build up the set of candidate patterns
  (max_n / 2 + 1).times do
    # Search
    (2..(max_n + 2)).each do |n|  # we need to go up to max_n + 2 to get accurate patterns up to max_n
      if n > 3
        # Building up new terms through abstraction
        patterns[n] += patterns[n-3].map {|p| "λX.#{p}"}

        # Building up new terms through application
        (1...(n-2)).each {|j|
          k = n - j - 2
          patterns[j].each {|p1|
            patterns[k].each {|p2|
              patterns[n] << "(#{p1}#{p2})"
              patterns[n] << "(#{p2}#{p1})"
            }
          }
        }
      end

      patterns[n].uniq!
    end

    # Simplify (https://en.wikipedia.org/wiki/Lambda_calculus#Notation)
    # Note: the (M N) P => M N P rule is harder to encode, but fortunately doesn't come up in N<=10 at all!
    simplified_patterns = patterns.values.reduce(&:+)
    5.times do
      simplified_patterns.map! {|p|
        p.gsub!(/λ(X+)\.λ(X+)\./, 'λ\1\2.')
        p.gsub!(/^\((.*)\)$/, '\1') if p.gsub(/^\((.*)\)$/, '\1').balanced_parentheses?
        p.gsub!(/\.\((.*)\)/, '.\1') if p.gsub(/\.\((.*)\)/, '.\1').balanced_parentheses?
        p
      }.uniq!
    end

    # Reassign to buckets by length
    patterns = Hash.new { |h, k| h[k] = [] }
    simplified_patterns.each {|p|
      patterns[p.size] << p
    }
  end

  patterns.keep_if {|k, v| k <= max_n }

  # Filter out patterns that cannot be combinators (don't start with λ)
  patterns = Hash[patterns.map {|k, v| [k, v.keep_if {|p| p.start_with? "λ"}]}]
end

def combinators_by_pattern(pattern)
  # First fill in variable bounds
  bound_variables = []
  next_bound_variable = "`"  # a - 1

  5.times do
    pattern.match(/λ(X+)\./) {|m| 
      vars = ""
      m[1].chars.each {|c| vars << next_bound_variable.next! }
      bound_variables += vars.chars

      pattern.sub!(/λ(X+)\./, "λ#{vars}.")
    }
  end

  # Then fill in the slots
  # NOTE: λ expressions inside parentheses pose a challenge for this naive
  #       implementation of "bounded variables". But fortunately it's not an issue in N<=10!
  combinators = [pattern]
  10.times do
    combinators.each do |c|
      if c.include? "X"
        idx = c.index("X")
        combinators.delete(c)
        combinators += bound_variables.select {|v| c.slice(0, idx).include? v} # has this variable appeared yet?
                                      .map {|v| c.sub("X", v)}
      end
    end
  end
  combinators
end

main()