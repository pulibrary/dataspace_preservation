# frozen_string_literal: true

require 'faraday'
require 'fileutils'
require 'marc'
require 'nokogiri'
require 'thor'
require 'uri'

require 'pry-byebug'

HOST = 'https://dataspace-staging.princeton.edu/handle/88435/dsp019c67wm88m/browse?type=graduation&order=DESC&rpp=20&value=2015'
HTML_TABLE_CSS_SELECTOR = 'html > body > main > div:nth-of-type(2) > div:nth-of-type(3) > table'

def fetch_arks
    response = Faraday.get(HOST.to_s)
    unless response.success?
        raise(ArgumentError,
              "Failed to receive a response from the DSpace URI: #{query_uri}")
    end
    response_document = Nokogiri::HTML.parse(response.body)
    search_table = response_document.at_css(HTML_TABLE_CSS_SELECTOR)

    search_table_rows = search_table.css('tr')
    search_result_rows = search_table_rows[1..]

    search_result_rows.each do |tr|
        td_element = tr.at_css("td[headers='t3']")

        handle_element = td_element.at_css('a')
        handle = handle_element['href'].gsub('/handle/', '')

        puts handle
    end 
end 

fetch_arks