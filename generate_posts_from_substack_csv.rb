require 'csv'
require 'date'
require 'fileutils'

class PostGenerator
  POSTS_DIR = '_posts'
  csv_path = 'posts.csv'

  def initialize(csv_path)
    @csv_path = csv_path
    FileUtils.mkdir_p(POSTS_DIR) unless Dir.exist?(POSTS_DIR)
  end

  def generate_posts
    CSV.foreach(@csv_path, headers: true) do |row|
      next unless row['is_published'] == 'true'
      create_post(row)
    end
  end

  private

  def create_post(row)
    date = DateTime.parse(row['post_date'])
    id = row['post_id'].split('.')[0]
    slug = row['post_id'].split('.')[1]
    filename = "#{date.strftime('%Y-%m-%d')}-#{slug}.md"
    filepath = File.join(POSTS_DIR, filename)

    post_url = "https://substack.com/home/post/p-#{id}" # Replace with your actual domain

    content = <<~FRONTMATTER
      ---
      layout: post
      title: #{row['title']}
      redirect_to:
        - #{post_url}
      categories: Newsletter
      description: #{row['subtitle']}
      date: #{date.strftime('%Y-%m-%d %H:%M:%S')}
      ---
    FRONTMATTER

    File.write(filepath, content)
    puts "Created #{filename}"
  rescue => e
    puts "Error creating #{filename}: #{e.message}"
  end
end

# Usage
generator = PostGenerator.new('posts.csv')
generator.generate_posts