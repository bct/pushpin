require 'html5lib/constants'
require 'html5lib/filters/base'

module HTML5lib
  module Filters
    class WhitespaceFilter < Base

      SPACE_PRESERVE_ELEMENTS = %w[pre textarea] + RCDATA_ELEMENTS
      SPACES = /[#{SPACE_CHARACTERS.join('')}]+/m

      def each
        preserve = 0
        __getobj__.each do |token|
          case token[:type]
          when :StartTag
            if preserve > 0 or SPACE_PRESERVE_ELEMENTS.include?(token[:name])
              preserve += 1
            end

          when :EndTag
            preserve -= 1 if preserve > 0

          when :SpaceCharacters
            next if preserve == 0

          when :Characters
            token[:data] = token[:data].sub(SPACES,' ') if preserve == 0
          end

          yield token
        end
      end
    end
  end
end

