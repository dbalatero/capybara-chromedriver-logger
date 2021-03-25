module Capybara
  module Chromedriver
    module Logger
      class Message
        attr_reader :level, :message, :file, :location, :timestamp

        def initialize(log)
          @message = log.message.strip.gsub(/%c/, '')
          @level = log.level
          @file = nil
          @location = nil

          extract_file_and_location!
        end

        def to_s
          first_line = [
            "\u{1F4DC} ",
            log_level,
            file_and_location
          ].compact.join(' ')

          second_line = formatted_message

          [first_line, second_line].join("\n")
        end

        def error?
          level == 'SEVERE'
        end

        private

        COLOR_CODES = {
          default: 49,
          light_red: 101,
          light_green: 102,
          light_blue: 103,
          light_magenta: 105,
          light_cyan: 106,
        }.freeze

        COLORS = {
          'SEVERE' => :light_red,
          'INFO' => :light_green,
          'WARNING' => :light_cyan,
          'DEBUG' => :light_blue
        }.freeze

        COLOR_MODES = {
          default: 0,
          bold: 1,
        }.freeze

        LEADING_SPACES = ' ' * 5

        def formatted_message
          message
            .gsub('\n', "\n")
            .gsub('\u003C', "\u003C")
            .split("\n")
            .map { |line| "#{LEADING_SPACES}#{line}" }
            .join("\n")
        end

        def level_color
          COLORS[level] || :light_blue
        end

        def log_level
          colorize(
            " #{level.downcase} ",
            mode: :bold,
            background: level_color,
          )
        end

        def file_and_location
          return unless file && location

          colorize(
            "#{file} #{location}",
            background: :light_magenta
          )
        end

        def extract_file_and_location!
          match = message.match(/^(.+)\s+?(\d+:\d+)\s+?(.+)$/)

          return unless match

          _, @file, @location, message = match.to_a
          @message = message.gsub(/^"(.+?)"$/, '\1')
        end

        def colorize(msg, background: :default, mode: :default)
          mode_code = COLOR_MODES.fetch(mode)
          color_code = 97 # white
          background_code = COLOR_CODES.fetch(background)

          str = "\033[#{mode_code};#{color_code};#{background_code}m"
          str += msg
          str + "\033[0m"
        end
      end
    end
  end
end
