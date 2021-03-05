# frozen_string_literal: true

module Squelch
  # @private
  module Patterns
    ORACLE_QUOTED = Regexp.union(
      /q'\<.*?\>'/m, # q'<text>'
      /q'\[.*?\]'/m, # q'[text]'
      /q'\{.*?\}'/m, # q'{text}'
      /q'\(.*?\)'/m, # q'(text)'
    ).freeze

    SINGLE_QUOTED = %r{
      '             # a single quote
      (?:           # followed by zero or more
        [^']        #   non-quote characters
        |           #   or
        ''          #   escaped quotes
      )*?           #
      (?:           # and closed by either
        \\'.*       #   a literal backslash at the end of the string
        |           #   or
        '(?!')      #   one non-escaped quote
      )             #
    }mx.freeze

    DOUBLE_QUOTED = %r{
      "             # a double quote
      (?:           # followed by zero or more
        [^"]        #   non-quote characters
        |           #   or
        ""          #   escaped quotes
      )*?           #
      (?:           # and closed by either
        \\".*       #   a literal backslash at the end of the string
        |           #   or
        "(?!")      #   one non-escaped quote
      )             #
    }mx.freeze

    DOLLAR_QUOTED = %r{
      (             # a dollar quote is defined dynamically
        \$          # the quote mark begins with a dollar sign
        (?!\d)      #   unless followed by a digit, which denotes a variable
        [^$]*?      #   otherwise it can can optionally contain any characters
        \$          # up until another dollar sign
      )             #
      .*?           # there's some amount of intervening text being quoted
      \1            # until the dollar quote mark is repeated
    }mx.freeze

    LINE_COMMENT = %r{
      (?:\#|--)     # single-line comments start with a hash or double hyphen
      .*?           # they contain arbitrary text
      (?=\r|\n|$)   # up until, but not including, the newline/carriage-return
    }x.freeze

    BLOCK_COMMENT = %r{
      /\*           # block comments open with a slash-star
        (?>         #   they contain zero or more
          [^/*]     #   non-star or -slash characters
          |         #   or
          /(?!\*)   #   a slash as long as it's not followed by a star
          |         #   or
          \*(?!/)   #   a star as long as it's not followed by a slash
          |         #   or
          \g<0>     #   recursively, a nested block comment
        )*          #
        /?          #   slash followed by star is ok if star is part of close
      \*/           # block comments close with a star-slash
    }mx.freeze

    UUID = /\{?\h{8}\-\h{4}\-\h{4}\-\h{4}\-\h{12}\}?/.freeze

    NUMBER = /-?\b(?:[0-9]+\.)?[0-9]+([eE][+-]?[0-9]+)?\b/.freeze

    BOOLEAN = /\b(?:true|false|null)\b/i.freeze

    HEXADECIMAL = /0x\h+/.freeze
  end
end
