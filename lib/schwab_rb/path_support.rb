# frozen_string_literal: true

require "fileutils"

module SchwabRb
  module PathSupport
    module_function

    def expand_path(path)
      raise ArgumentError, "path is nil or empty" if path.nil? || path.to_s.strip.empty?

      File.expand_path(path.to_s)
    end

    def ensure_parent_directory(path)
      directory = File.dirname(expand_path(path))
      FileUtils.mkdir_p(directory)
    end
  end
end
