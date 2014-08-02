require 'net/http'
require 'nokogiri'
require_relative 'yc_class_info'

class YcScheduleScraper
  def get_class_info(term_code, class_number)
    doc = fetch_info(term_code, class_number)
    results_row = doc.xpath("//table[tr/th/a[text()='CRN']]/tr")[1] # skip 0 because it's the header
    if results_row.nil?
      return nil
    end
    cells = results_row.xpath("td")
    if cells.length == 1
      return nil
    end
    name = cells[3].text
    schedule = cells[9].text
    if name != nil
      YcClassInfo.new(name, schedule)
    else
      nil
    end
  end

  def get_class_status(term_code, class_number)
    doc = fetch_info(term_code, class_number)
    results_row = doc.xpath("//table[tr/th/a[text()='CRN']]/tr")[1] # skip 0 because it's the header
    if results_row.nil?
      return nil
    end
    cells = results_row.xpath("td")
    if cells.length == 1
      return nil
    end
    span = cells[6].xpath("span")
    open_seats = span.text.to_i
    if open_seats == 0
      :closed
    else
      :open
    end
  end

private
  def string_value(node)
    if node == nil
      nil
    else
      node.to_s.strip
    end
  end

  def fetch_info(term_code, class_number)
    # TODO have this rotate between servers
    uri = URI('https://cleveland.yc.edu/MYSSB/pkgyc_csweb_external.P_ClassSearchResults')
    req = Net::HTTP::Post.new(uri.request_uri)
    req.set_form_data({'web_session' => '',
                              'term_code' => term_code,
                              'keyword' => '',
                              'kw_scope' => 'course',
                              'kw_opt' => 'all',
                              'sort_col' => '3',
                              'sort_dir' => 'A',
                              'online_flag' => '',
                              'avail_flag' => '',
                              'subj_code' => '*',
                              'instr_session' => '*',
                              'attr_type' => '*',
                              'instructor' => '*',
                              'weekday' => '*',
                              'crn' => class_number,
                        'campus' => '*'})
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    res = http.start do |http| 
      res = http.request(req)
    end
    doc = Nokogiri::HTML(res.body)
    # this somehow makes decoding of entities work (https://twitter.com/#!/tenderlove/status/11489447561)
    doc.encoding = "UTF-8"
    return doc
  end
end
