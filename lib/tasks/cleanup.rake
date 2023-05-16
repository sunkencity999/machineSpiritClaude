# lib/tasks/cleanup.rake

namespace :cleanup do
  desc 'Remove generated images older than 24 hours'
  task remove_old_images: :environment do
    require 'fileutils'

    image_directory = Rails.root.join('public', 'generated_images')
    one_hour_ago = Time.now - 1.hours

    Dir.foreach(image_directory) do |file_name|
      next if ['.', '..'].include? file_name  # Skip current and parent directory
      file_path = File.join(image_directory, file_name)
      file_mtime = File.mtime(file_path)

      if File.file?(file_path) && file_mtime < one_hour_ago
        puts "Deleting #{file_path}"
        FileUtils.rm(file_path)
      end
    end
  end
end

