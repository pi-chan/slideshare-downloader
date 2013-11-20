require 'open-uri'

module Helpers
  class Downloader
    def initialize(url)
      @url = url
    end

    def exec
      prepare()

      if !@slide_name or !@slide_count
        return nil
      end

      pdf_name = "#{@slide_name}.pdf"
      @pdf_file = Tempfile.new(pdf_name)

      Dir.mktmpdir do |dir|
        Dir.chdir(dir) do
          download_image()
          generate_pdf()
        end
      end

      new_name = @pdf_file.path.gsub(/\.pdf(.+)$/,'.pdf')
      FileUtils.copy(@pdf_file.path, new_name)
      @pdf_file.unlink

      return new_name
    end

    private

    def get_html()
      html = nil
      begin 
        html = open(@url) do |f|
          f.read
        end
      rescue
        # do nothing
      end

      return html
    end
    
    def prepare()
      html = get_html()
      return unless html
      doc = Nokogiri::HTML.parse(html)
      item = doc.xpath('/html/head/meta[@name="thumbnail"]').first
      return unless item
      thumbnail_url = item.attributes["content"].value

      xml_url = thumbnail_url.gsub(/phpapp(\d+)?(.+)$/,'phpapp\1').gsub(/ss_thumbnails\//,'') + ".xml"
      xml = open(xml_url) do |f|
        f.read
      end

      xml_doc = Nokogiri::XML(xml)
      @slide_count = xml_doc.xpath("/Show/Slide").count
      @slide_name = thumbnail_url.match(/ss_thumbnails\/(.+phpapp\d+)/)[1]
    end

    def download_image
      @slide_count.times do |i|
        path = "http://image.slidesharecdn.com/#{@slide_name}/95/slide-#{i+1}-1024.jpg"
        puts "downloading #{path} ..."
        filename = File.basename(path)
        open(filename, 'wb') do |out|
          open(path) do |data|
            out.write(data.read)
          end
        end
      end
    end

    def generate_pdf
      images = Dir.glob("slide-*.jpg")
      images = images.sort_by{|str| str[/\d+/].to_i}

      Prawn::Document.generate(
        @pdf_file.path,
        page_size:[1024,768],
        margin:0
      ) do
        images.each do |img|
          image(
            img,
            fit:[1024,768]
          )
          start_new_page
        end
      end
    end
    
  end
end

