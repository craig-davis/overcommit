module Overcommit::Hook::PreCommit
  # Runs `phpmd` against any modified PHP files.
  class PhpMd < Base
    # rubocop:disable Metrics/LineLength
    #
    # Text Output Format
    # https://github.com/phpmd/phpmd/blob/master/src/main/php/PHPMD/Renderer/TextRenderer.php#L37
    #
    # Sample String
    #   FileService.php:26  The class FileService has 14 public methods. Consider refactoring FileService to keep number of public methods under 10.
    #
    # rubocop:enable Metrics/LineLength
    MESSAGE_REGEX = /^(?<file>.+)\:(?<line>\d+)\t(?<message>.+)/

    def run
      # A list of error messages
      messages = []

      # Exit status for all of the runs. Should be zero!
      exit_status_sum = 0

      # Run for each of our applicable files
      applicable_files.each do |file|
        # Note that phpmd has a strange argument order
        result = execute(command, args: [file, 'text', @config['rules']])
        output = result.stdout.chomp
        exit_status_sum += result.status
        if result.status
          messages << output
        end
      end

      # If the sum of all lint status is zero, then none had exit status
      return :pass if exit_status_sum == 0

      # No messages is great news for us
      return :pass if messages.empty?

      # Return the list of message objects
      parse_messages(messages)
    end

    def parse_messages(messages)
      output = []

      messages.map do |message|
        message.scan(MESSAGE_REGEX).map do |file, line, msg|
          output << Overcommit::Hook::Message.new(:error, file, line.to_i, msg)
        end
      end

      output
    end
  end
end
