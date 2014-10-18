require 'rubygems'

require 'json'
require 'net/http'
require 'nokogiri'
require 'uri'

PaperArxivResult = Struct.new :title, :abstract, :url, :date_published, :authors, :links, :arxiv_id

class PaperArxiv

  # Base api query url
  API_PATH = 'http://export.arxiv.org/api/query?' 
  API_URI = URI.parse(API_PATH)

  attr_accessor :referer, :start_results, :num_results

  def initialize(referer='', num_results=50, start_results=0)
    @referer = referer
    @start_results = start_results
    @num_results = num_results
  end

  def search_query(query, field='all')
    api = API_URI
    api_call = Net::HTTP.new(api.host)
    
    params = "?search_query=#{field}:#{query}&start=#{@start_results}"
    params += "&max_results=#{@num_results}"

    response = api_call.get2(api.path + params, { 'Referer' => @referer })
    return nil if response.class.superclass == Net::HTTPServerError

    _generate_result(response.body)
  end

  def id_list(ids)
    api = API_URI
    api_call = Net::HTTP.new(api.host)
    
    params = "?id_list=#{ids}&start=#{@start_results}"
    params += "&max_results=#{@num_results}"

    response = api_call.get2(api.path + params, { 'Referer' => @referer })
    return nil if response.class.superclass == Net::HTTPServerError

    _generate_result(response.body)
  end

  private
    def _generate_result(body)
      doc = Nokogiri::HTML(body)
      doc.xpath('//feed/entry').map do |item|
        authors = item.xpath('author').map { |author| author.xpath('name').text }

        links = item.xpath('link').reject {|link| link.attribute("title").nil? }.map do |link|
          { link.attribute("title").value => link.attribute("href").value }
        end

        arxiv_id = item.xpath('id').text.gsub(/^http.*\//, '').gsub(/v\d+$/, '')

        PaperArxivResult.new(
          item.xpath('title').text,
          item.xpath('summary').text.gsub("\n", ' ').strip,
          item.xpath('id').text,
          item.xpath('published').text,
          authors,
          links,
          arxiv_id
        )
    end
  end
end
