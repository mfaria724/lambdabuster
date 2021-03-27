require 'date'

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
    if ! @list.empty? then
      list_without_last = @list.first @list.size - 1
      result_str = ""
      list_without_last.each { |x| result_str += "#{x.to_s}, " }
      
      # print last element
      result_str += @list[-1].to_s
      return result_str
    else
      return ""
    end
  end
  
  # def +(other)
  # ???
  # end

  # def each(∗args, &block)
  # @list.each(∗args, &block)
  # end

  def scan(key)

    if @list.empty? then
      return SearchList.new()
    elsif @list.first.instance_variables.include?(("@" + key.to_s).to_sym)
      temp_list = @list.select { |elem| yield elem.send(key) }
      return SearchList.new(*temp_list)
    else
      throw "Los elementos de la lista no poseen el atributo #{key}."
    end 
    
  end

end

class Person

  attr_accessor :name
  attr_accessor :birthday
  attr_accessor :nationality

  def initialize(name, birthday, nationality)
    @name = name
    @birthday = birthday
    @nationality = nationality
  end

  def to_s
    @name
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

  attr_accessor :name
  attr_accessor :runtime
  attr_accessor :categories
  attr_accessor :release_date
  attr_accessor :directors
  attr_accessor :actors
  attr_accessor :price
  attr_accessor :rent_price
  attr_accessor :premiere
  attr_accessor :discount

  def initialize(
    name,
    runtime,
    categories,
    release_date,
    directors,
    actors,
    price,
    rent_price,
    premiere,
    discount
  )

    @name = name
    @runtime = runtime
    @categories = categories
    @release_date = release_date
    @directors = directors
    @actors = actors
    @price = price
    @rent_price = rent_price
    @premiere = premiere
    @discount = discount

  end

  def to_s
    # time in a humam redably format
    hours = @runtime / 60
    duration_human = "#{hours} h #{@runtime - (hours * 60)} min"

    # add title with date
    result_str = "#{@name} (#{@release_date.year}) - #{duration_human}\n"

    # genres
    result_str += "Genres: "
    list_without_last = @categories.first @categories.size - 1
    list_without_last.each { |cat| result_str += "#{cat}, " }    
    result_str += @categories[-1].to_s + "\n"

    # director
    result_str += "Directed by: "
    result_str += @directors.to_s + "\n"

    # cast
    result_str += "Cast: "
    result_str += @actors.to_s + "\n"

    result_str
  end
end

class Premiere 
  def initialize(movie)
    @movie = movie
  end

  # name setters and getters
  def name
    @movie.name
  end
  
  # TODO: remove if not neccesary setter
  def name=(name)
    @movie.name = name
  end

  # runtime setters and getters
  def runtime
    @movie.runtime
  end
  
  # TODO: remove if not neccesary setter
  def runtime=(runtime)
    @movie.runtime = runtime
  end

  # categories setters and getters
  def categories
    @movie.categories
  end
  
  # TODO: remove if not neccesary setter
  def categories=(categories)
    @movie.categories = categories
  end

  # release_date setters and getters
  def release_date
    @movie.release_date
  end
  
  # TODO: remove if not neccesary setter
  def release_date=(release_date)
    @movie.release_date = release_date
  end

  # directors setters and getters
  def directors
    @movie.directors
  end
  
  # TODO: remove if not neccesary setter
  def directors=(directors)
    @movie.directors = directors
  end

  # actors setters and getters
  def actors
    @movie.actors
  end
  
  # TODO: remove if not neccesary setter
  def actors=(actors)
    @movie.actors = actors
  end

  # premiere setters and getters
  def premiere
    @movie.premiere
  end
  
  # TODO: remove if not neccesary setter
  def premiere=(premiere)
    @movie.premiere = premiere
  end

  # discount setters and getters
  def discount
    @movie.discount
  end
  
  # TODO: remove if not neccesary setter
  def discount=(discount)
    @movie.discount = discount
  end

  def price
    @movie.price * 2
  end

  def rent_price
    @movie.rent_price * 2
  end
end

class Discount 
  def initialize(movie)
    @movie = movie
  end

  # name setters and getters
  def name
    @movie.name
  end
  
  # TODO: remove if not neccesary setter
  def name=(name)
    @movie.name = name
  end

  # runtime setters and getters
  def runtime
    @movie.runtime
  end
  
  # TODO: remove if not neccesary setter
  def runtime=(runtime)
    @movie.runtime = runtime
  end

  # categories setters and getters
  def categories
    @movie.categories
  end
  
  # TODO: remove if not neccesary setter
  def categories=(categories)
    @movie.categories = categories
  end

  # release_date setters and getters
  def release_date
    @movie.release_date
  end
  
  # TODO: remove if not neccesary setter
  def release_date=(release_date)
    @movie.release_date = release_date
  end

  # directors setters and getters
  def directors
    @movie.directors
  end
  
  # TODO: remove if not neccesary setter
  def directors=(directors)
    @movie.directors = directors
  end

  # actors setters and getters
  def actors
    @movie.actors
  end
  
  # TODO: remove if not neccesary setter
  def actors=(actors)
    @movie.actors = actors
  end

  # premiere setters and getters
  def premiere
    @movie.premiere
  end
  
  # TODO: remove if not neccesary setter
  def premiere=(premiere)
    @movie.premiere = premiere
  end

  # discount setters and getters
  def discount
    @movie.discount
  end
  
  # TODO: remove if not neccesary setter
  def discount=(discount)
    @movie.discount = discount
  end

  def price
    (1 - (@movie.discount / 100.0)) * @movie.price
  end

  def rent_price
    (1 - (@movie.discount / 100.0)) * @movie.rent_price
  end
end

class Float
  def dolars
    Dolar.new(self)
  end

  def euros
    Euro.new(self)
  end 

  def bolivares
    Bolivar.new(self)
  end 

  def bitcoins
    Bitcoin.new(self)
  end 
end

class Integer
  def dolars
    Dolar.new(self)
  end

  def euros
    Euro.new(self)
  end 

  def bolivares
    Bolivar.new(self)
  end 

  def bitcoins
    Bitcoin.new(self)
  end 
end

class Currency 
  attr_accessor :value
  attr_accessor :currency

  def initialize(value)
    @value = value
  end

  def in(currency)
    (@value * self.send(currency)).send(currency)
  end

  def compare(object)
    this_value = self.in(object.currency).value
    other_value = object.value
    if this_value < other_value then
      return :lesser
    elsif this_value == other_value then
      return :equal
    else 
      return :greater
    end
  end
    
end

class Dolar < Currency

  def initialize(value)
    super(value)
    @currency = :dolars
  end

  def dolars
    return 1
  end

  def euros 
    return 0.85
  end

  def bolivares
    return 1850000
  end

  def bitcoins
    return 0.000019
  end
end

class Euro < Currency

  def initialize(value)
    super(value)
    @currency = :euros
  end

  def dolars
    return 1.181
  end

  def euros 
    return 1
  end

  def bolivares
    return 2171000
  end
  
  def bitcoins
    return 0.0000223
  end
end

class Bolivar < Currency

  def initialize(value)
    super(value)
    @currency = :bolivares
  end
  
  def dolars
    return 0.000000545
  end

  def euros 
    return 0.00000046
  end

  def bolivares
    return 1
  end
  
  def bitcoins
    return 0.0000000000102
  end
end

class Bitcoin < Currency

  def initialize(value)
    super(value)
    @currency = :bitcoins
  end

  def dolars
    return 52000
  end

  def euros 
    return 44830
  end

  def bolivares
    return 98000000000
  end
  
  def bitcoins
    return 1
  end
end

module BuyOrder
  def buy_order(transaction)
    transaction.date = Date.today
    trasanction.total = trasanction.movie.rent_price
  end
end

module RentOrder
  def rent_order(transaction)
    transaction.date = Date.today
    trasanction.total = trasanction.movie.price
  end
end

class Transaction
  attr_accessor :movie
  attr_accessor :date
  attr_accessor :total

  def initialize(movie, type)
    @movie = movie
    @type = type
  end
end

class User
  def initialize
    @owned_movies = SearchList.new()
    @rented_movies = SearchList.new()
    @trasanctions = SearchList.new() 
  end
end

# TODO: delete all test code

=begin
c_nolan = Director.new('Christopher Nolan', 'X', 'English')
j_d_washington = Actor.new('John David Washington', 'X', 'American')
r_pattinson = Actor.new('Robert Pattinson', 'X', 'English')
e_debicki = Actor.new('Elizabeth Debicki', 'X', 'Australian')

tenet = Movie.new(
  'Tenet', 
  150, 
  ['Action', 'Sci-fi', 'Thriller'],
  Date.parse('2020-09-03'),
  SearchList.new(c_nolan),
  SearchList.new(j_d_washington, r_pattinson, e_debicki),
  100.0,
  10.0,
  true,
  20
)

puts tenet.to_s
puts tenet.price
puts tenet.rent_price

tenet_premier = Premiere.new(tenet)
puts tenet_premier.price
puts tenet_premier.rent_price

tenet_discount = Discount.new(tenet)
puts tenet_discount.price
puts tenet_discount.rent_price

var = 1850000.bolivares()
var2 = var.in(:dolars) 
puts var2.value
puts var2.class

puts 1.dolars.compare(1850000.bolivares) 

list = SearchList.new(c_nolan, j_d_washington, r_pattinson, e_debicki)
puts list.scan(:nationality) { |nationality| nationality == 'English' }
=end