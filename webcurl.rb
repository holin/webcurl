require 'rubygems'
require 'sinatra'
require 'haml'

template :layout do
  %{
%html
 %head
  %style
   input.title {width: 800px}
   div.content textarea {width: 800px; height: 100px}
   div.header textarea {width: 800px; height: 100px}
 =yield 
  }
end

template :index do
  %{
%h2.title Web Curl
%form(action="/" method="post")
 .title 
  %span Url:
  %br 
  %input(type="text" name="url" class="title"){:value => @url}
 .header 
  %span Request Header: 
  %br
  %textarea(name="rq_header")= params[:rq_header]
 .header 
  %span Response Header: 
  %br
  %textarea(name="rsp_header")= @header
 .content 
  %span Content:  
  %br
  %textarea= @content
 .title
 .header 
  %span Curl cmd: 
  %br
  %textarea= @cmd
  %br
  %input(type="submit" value="submit")
  }
end

def parse_header(s)
  h = {}
  s.split(/\n/).each do |line|
    arr = line.gsub(/\:\s/, " ").split(/\s/)
    h[arr.first] = arr.last
  end
  str = ""
  h.each do |k, v|
    str << " -H '#{k}: #{v}'"
  end
  str
end

def get_url
  header = parse_header(params[:rq_header])
  cmd = "curl #{header} -i '#{@url}'"
  @cmd = cmd
  html = `#{cmd}`
  arr = html.split(/\r\n\r\n/m)
  @header = arr.first
  arr.delete_at(0)
  @content = arr.join
end


get '/' do
  @url = params[:url]
  @header = nil
  @content = nil
  get_url unless @url.nil?
  haml :index
end

post '/' do
  @url = params[:url]
  @header = nil
  @content = nil
  get_url unless @url.nil?
  haml :index
end

get '/header' do
  s = ""
  request.env.each do |k, v|
    s << "#{k}: #{v}\n"
  end
  s
end

