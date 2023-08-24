# frozen_string_literal: true

require 'date'
require 'faraday'
require 'fileutils'
require 'marc'
require 'nokogiri'
require 'thor'
require 'uri'
require 'optparse'

require 'pry'

def fetch_arks(host, ark, class_year)
  ark = ark.delete_prefix('ark:/')
  additional_params = class_year == '' ? '' : "?type=graduation&order=DESC&rpp=20&value=#{class_year}"
  host = "#{host}/handle/#{ark}/browse"

  offset = 0
  response = paginate_response(host, additional_params, offset)

  while response != '' 
    html_table_css_selector = 'html > body > main > div:nth-of-type(2) > div > table'
    td_id = class_year == '' ? 't2' : 't3'
    response_document = Nokogiri::HTML.parse(response.body)
    search_table = response_document.at_css(html_table_css_selector)
    search_table_rows = search_table.css('tr')
    search_result_rows = search_table_rows[1..]
    search_result_rows.each do |tr|
      td_element = tr.at_css("td[headers='#{td_id}']")
      handle_element = td_element.at_css('a')
      handle = handle_element['href'].gsub('/handle/', '')
      puts handle
    end
    offset += 20
    response = paginate_response(host, additional_params, offset)
  end 
end

def paginate_response(url, additional_params, offset) 
  stop_phrase = "No Entries in Index"
  url = additional_params == '' ? "#{url}?offset=#{offset}" : "#{url}#{additional_params}&offset=#{offset}"
  response = Faraday.get(url.to_s)
  raise(ArgumentError, "Failed to receive a response from the DSpace URI: #{url}") unless response.success?
  response.body.to_s.include?(stop_phrase) ? '' : response
end

options = {}
OptionParser.new do |opts|
  opts.banner = 'Usage: list_arks.rb [options]'
  opts.on('-h', '--host', 'Host URL') do |h|
    options[:host] = h
  end
  opts.on('-c', '--classyear', 'Class year') do |c|
    options[:classyear] = c
  end
  opts.on('-h', '--host HOST', String, 'Host URL') { |h| options[:host] = h }
  opts.on('-a', '--ark ARK', String, 'Collection ark') { |a| options[:ark] = a }
  opts.on('-c', '--classyear YEAR', Integer, 'Class year') { |c| options[:classyear] = c }
end.parse!

host = options[:host] || 'https://dataspace-staging.princeton.edu'
ark = options[:ark] || 'ark:/88435/dsp01zw12z7787'
class_year = options[:classyear] || ''
fetch_arks(host, ark, class_year)
