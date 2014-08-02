require 'yc_schedule_scraper'

describe YcScheduleScraper do
  scraper = YcScheduleScraper.new
  it 'can determine the current term' do
    term = get_current_term
    expect(term).to match(/\d{6}/)
  end
  it 'can find closed class' do
    term = get_current_term
    closed = get_class(term, :closed)
    expect(closed).to match(/\d{5}/)
    expect(scraper.get_class_status(term, closed)).to eq(:closed)
  end
  it 'can find open class' do
    term = get_current_term
    open = get_class(term, :open)
    expect(open).to match(/\d{5}/)
    expect(scraper.get_class_status(term, open)).to eq(:open)
  end
  it 'can load class info' do
    info = scraper.get_class_info('201430', '37167')
    expect(info.name).to eq('Basic Tax Planning')
    expect(info.schedule).to eq('Online')
  end
  it 'returns nil for non-existent class' do
    expect(scraper.get_class_status('201430', '12345')).to be_nil
  end
end

def get_doc(url)
  uri = URI(url)
  req = Net::HTTP::Get.new(uri.request_uri)
  http = Net::HTTP.new(uri.host, uri.port)
  if uri.scheme == 'https'
    http.use_ssl = true
  end
  res = http.start do |http| 
    res = http.request(req)
  end
  Nokogiri::HTML(res.body)
end

def fetch_info(term_code)
  uri = URI("https://cleveland.yc.edu/MYSSB/pkgyc_csweb_external.P_ClassSearchResults")
  req = Net::HTTP::Post.new(uri.request_uri)
  req.set_form_data({"web_session" => "",
                            "term_code" => term_code,
                            "sort_col" => "3",
                            "sort_dir" => "A",
                            "kw_scope" => "course",
                            "keyword" => "",
                            "kw_opt" => "all",
                            "subj_code" => "*",
                      "campus" => "*"})
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  res = http.start do |http| 
    res = http.request(req)
  end
  Nokogiri::HTML(res.body)
end


def get_current_term
  doc = get_doc('https://cleveland.yc.edu/MYSSB/pkgyc_csweb_external.P_Term')
  doc.xpath("//select[@name='term_code']/option[@selected='selected']/@value").text
end

def get_class(term, status)
  doc = fetch_info(term)
  if status == :closed
    doc.xpath("//table[tr/th/a[text()='CRN']]//tr[td/span[text()='0']]/td[position()=1]/a")[0].text
  else
    doc.xpath("//table[tr/th/a[text()='CRN']]//tr[td/span[text()!='0']]/td[position()=1]/a")[0].text
  end
end

