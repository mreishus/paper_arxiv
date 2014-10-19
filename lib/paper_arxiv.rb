require 'rubygems'

require 'json'
require 'net/http'
require 'nokogiri'
require 'uri'

class PaperArxiv

  # Base api query url
  API_PATH = 'http://export.arxiv.org/api/query?' 
  API_URI = URI.parse(API_PATH)

  attr_accessor :referer, :start_results, :num_results

  # Todo: Convert to named params
  def initialize(referer: '', num_results: 50, start_results: 0, cache_client: nil)
    @referer = referer
    @start_results = start_results
    @num_results = num_results

    if cache_client && cache_client.respond_to?(:get) && cache_client.respond_to?(:set)
      @cache_client = cache_client
    end
  end

  # Todo: DRY with repeated code in search_query() and id_list()
  def search_query(query, field='all')
    json_result = cache(query) do
      api = API_URI
      api_call = Net::HTTP.new(api.host)
      
      params = "?search_query=#{field}:#{query}&start=#{@start_results}"
      params += "&max_results=#{@num_results}"

      response = api_call.get2(api.path + params, { 'Referer' => @referer })
      return nil if response.class.superclass == Net::HTTPServerError

      _generate_result(response.body)
    end
    JSON.parse(json_result)
  end

  def id_list(ids)
    json_result = cache(ids) do
      api = API_URI
      api_call = Net::HTTP.new(api.host)
      
      params = "?id_list=#{ids}&start=#{@start_results}"
      params += "&max_results=#{@num_results}"

      response = api_call.get2(api.path + params, { 'Referer' => @referer })
      return nil if response.class.superclass == Net::HTTPServerError

      _generate_result(response.body)
    end
    JSON.parse(json_result)
  end

  # Use 'key' as a cache key, 
  # cache the results of whatever block we are given
  # Duration is default and may not be specified for now
  def cache(key)
    if !@cache_client
      # no cache client
      return yield self
    end

    if result = @cache_client.get(key)
      # cache hit
      result
    else
      #cache miss
      result = yield self
      @cache_client.set(key, result)
      result
    end
  end

  private
    def _generate_result(body)
      doc = Nokogiri::HTML(body)
      doc.xpath('//feed/entry').map do |item|
        authors = item.xpath('author').map { |author| author.xpath('name').text }

        links = item.xpath('link').reject {|link| link.attribute("title").nil? }.map do |link|
          { link.attribute("title").value => link.attribute("href").value }
        end.reduce Hash.new, :merge

        arxiv_id = item.xpath('id').text.gsub(/^http.*\//, '').gsub(/v\d+$/, '')

        {
          :title => item.xpath('title').text,
          :abstract => item.xpath('summary').text.gsub("\n", ' ').strip,
          :url => item.xpath('id').text,
          :date_published => item.xpath('published').text,
          :authors => authors,
          :links => links,
          :arxiv_id => arxiv_id
        }
    end.to_json
  end
end
