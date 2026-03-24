# frozen_string_literal: true

require "fileutils"

module SchwabRb
  # Common path expansion and directory helpers for token and data files.
  module PathSupport
    module_function

    def expand_path(path)
      File.expand_path(path.to_s)
    end

    def ensure_parent_directory(path)
      directory = File.dirname(expand_path(path))
      FileUtils.mkdir_p(directory)
    end
  end
end
