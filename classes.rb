class SearchList

  def initialize (*list)
    @list = *list
  end

  # def <<(elem)
  # @list << elem
  # self
  # end

  def to_s
    # print first n-1 elemnts with a comma
    list_without_last = @list.first @list.size - 1
    result_str = ""
    list_without_last.each { |x| result_str += "#{x}," }
    
    # print last element
    result_str += @list[-1].to_s
  end
  
  # def +(other)
  # ???
  # end

  # def each(∗args, &block)
  # @list.each(∗args, &block)
  # end

end

class Person
  def initialize(name, birthday, nationality)
    @name = name
    @birthday = birthday
    @nationality = nationality
  end
end

class Actor < Person
  def initialize(name, birthday, nationality)
    super(name, birthday, nationality)
    @starred_in = SearchList.new()
  end
end

class Director < Person
  def initialize(name, birthday, nationality)
    super(name, birthday, nationality)
    @directed = SearchList.new()
  end
end

class Movie
  def initialize(
    name,
    runtime,
    categories,
    release-date,
    directors,
    actors,
    price,
    rent_price,
    premiere,
    discount
  )

  end
end

sl = SearchList.new(1)
sl1 = SearchList.new(1,2,3)

puts sl.to_s
puts sl1.to_s
