require "tilt/erubis"
require "sinatra"
require "sinatra/reloader" if development?

helpers do
  def in_paragraphs(chapter)
    chapter.split("\n\n").map.with_index do |paragraph, idx|
      "<p id=pgraph#{idx}>#{paragraph}</p>"
    end.join
  end

  # reads the contents and its chapter and yields its name, number and chapter to the block in chapters_matching

  def each_chapter
    @contents.each_with_index do |name, idx|
      number = idx + 1
      chapter = File.read("data/chp#{number}.txt").split("\n\n")
      yield(number, name, chapter)
    end
  end

  # checks to see if the yielded name, number and chapter include the query name. returns an array of number and name of book hashes that do include the query

  def chapters_matching(query)
    results = []
    return results if !query || query.empty?

    each_chapter do |number, name, chapter|
      matching_para = {}
      chapter.each_with_index {|para, idx| matching_para[idx] = para if para.include?(query)}
        results << {number: number, name: name, chapter:matching_para} unless matching_para.empty?
    end

    results
  end

  def strengthen(text, term)
    plain_text = text.split(term)
    strong_term = "<strong>#{term}</strong>"
    plain_text.join(strong_term)
  end
end



before do
  @contents = File.readlines("data/toc.txt")
end

get "/" do
  @title = 'The Adventures of Sherlock Holmes'
  erb :home
end

get "/chapters/:number" do
  @contents = File.readlines("data/toc.txt")
  number = params[:number].to_i
  chapter_name = @contents[number - 1]

  redirect("/") if @contents.length < number

  @title = "Chapter #{number}: #{chapter_name}"
  @chapter = File.read("data/chp#{number}.txt")
  erb :chapter
end

get "/search" do
  @results = chapters_matching(params[:query])
  erb :search
end

not_found do
  redirect("/")
end
