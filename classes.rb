require 'date'

# this expansion of class String is used to format the output
# increases redability for the user
class String
  def bold
    "\e[1m" + self + "\e[0m"
  end
end

# class to store all elements that will be defined in the following classes
# cotains utilities to look for elements in this lists
class SearchList

  def initialize (*list)
    @list = *list
  end

  def <<(elem)
    @list << elem
  end

  def empty?
    @list.empty?
  end

  def include?(element)
    @list.include? element
  end

  def first
    @list.first
  end

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

  # applies a block of code to each element of the list
  def each(&block)
    @list.each(&block)
  end

  # recieves a symbol and a block and verifies that an attribute of the elements
  # in the list meets a certain condition
  def scan(key)

    if @list.empty? then
      return SearchList.new()
    # as all elements on a SearchList are of the same type, just checking if the
    # first element contains the attribute is enough to verify that all of them
    # have it.
    elsif @list.first.instance_variables.include?(("@" + key.to_s).to_sym) ||
      @list.first.class.method_defined?(key)

      temp_list = @list.select { |elem| yield elem.send(key) }
      return SearchList.new(*temp_list)
    else
      throw "Los elementos de tipo '#{@list.first.class}'' no poseen el atributo '#{key}'."
    end 

  end

end

# identifies the basic data of a person. Parent class of Actor and Director
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
    "Nombre:".bold() + " #{@name}.\n" + "Cumpleaños:".bold() + " #{@birthday}.\n" + 
    "Nacionalidad:".bold() + " #{@nationality}.\n"
  end
end

# creates a kind of double linked list between movies and actors. Each actor
# contains a list of movies where he has acted and viceversa. 
class Actor < Person
  def initialize(name, birthday, nationality)
    super(name, birthday, nationality)
    @starred_in = SearchList.new()
  end
end

# creates a kind of double linked list between movies and actors. Each director
# contains a list of movies that he has directed and viceversa.
class Director < Person
  def initialize(name, birthday, nationality)
    super(name, birthday, nationality)
    @directed = SearchList.new()
  end
end

# stores the basic information for a movie. Parent class for Premiere and
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

# this class was made to proof our knowledge about the design pattern decorator
# heritance would have been a better choice. As we did this way, we needed to 
# define a single method for each of the variables in order to be able to get 
# them. This code is duplicated in class Discount as attributes need also to be
# "gettable"
class Premiere 
  def initialize(movie)
    @movie = movie
  end

  # name setters
  def name
    @movie.name
  end
  
  # runtime setters
  def runtime
    @movie.runtime
  end
  
  # categories setters
  def categories
    @movie.categories
  end
  
  # release_date setters
  def release_date
    @movie.release_date
  end
  
  # directors setters
  def directors
    @movie.directors
  end
  
  # actors setters
  def actors
    @movie.actors
  end
  
  # premiere setters
  def premiere
    @movie.premiere
  end
  
  # discount setters
  def discount
    @movie.discount
  end

  # to string extension
  def to_s
    @movie.to_s
  end
  
  # decorators applied related to the premiere extra charge
  def price
    @movie.price * 2
  end

  def rent_price
    @movie.rent_price * 2
  end
end

# this class was made to proof our knowledge about the design pattern decorator
# heritance would have been a better choice. As we did this way, we needed to 
# define a single method for each of the variables in order to be able to get 
# them. This code is duplicated in class Premiere as attributes need also to be
# "gettable"
class Discount 
  def initialize(movie)
    @movie = movie
  end

  # name setters
  def name
    @movie.name
  end
  
  # runtime setters
  def runtime
    @movie.runtime
  end
  
  # categories setters
  def categories
    @movie.categories
  end
  
  # release_date setters
  def release_date
    @movie.release_date
  end
  
  # directors setters
  def directors
    @movie.directors
  end
  
  # actors setters
  def actors
    @movie.actors
  end
  
  # premiere setters
  def premiere
    @movie.premiere
  end
  
  # discount setters
  def discount
    @movie.discount
  end
  
  # to string extension
  def to_s
    @movie.to_s
  end

  # decorators related to the discount applied to the movie
  def price
    (1 - (@movie.discount / 100.0)) * @movie.price
  end

  def rent_price
    (1 - (@movie.discount / 100.0)) * @movie.rent_price
  end
end

# extension of Integer and Float classes into our custom currency type classes.
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

# Parent class for every currency type class that provides utility methods for
# exchange between different currencies.
class Currency 
  attr_accessor :value
  attr_accessor :currency

  def initialize(value)
    @value = value
  end

  # transforms a currency to the especified symbol
  def in(currency)
    (@value * self.send(currency)).send(currency)
  end

  # compares an different element with the current one using the same currency.
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

# values to transforme the different currencies
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

# values to transforme the different currencies
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

# values to transforme the different currencies
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

# values to transforme the different currencies
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

# module to compute the price and date of a buy op
module BuyOrder
  def buy_order(transaction)
    transaction.date = Date.today
    transaction.total = transaction.movie.price
  end
end

# module to compute the price and date of a rent op
module RentOrder
  def rent_order(transaction)
    transaction.date = Date.today + 2
    transaction.total = transaction.movie.rent_price
  end
end

# class to start a transaction, no matter if it is a buy or rent operation
class Transaction
  include BuyOrder
  include RentOrder

  attr_accessor :movie
  attr_accessor :date
  attr_accessor :total

  def initialize(movie, type)
    @movie = movie
    @type = type

    # compute the date and the total price depending on the type of operation
    if @type == :buy
      buy_order(self)
    else
      rent_order(self)
    end
  end
end

# class to store the information of the user
class User
  attr_accessor :owned_movies
  attr_accessor :rented_movies
  attr_accessor :transactions

  def initialize
    @owned_movies = SearchList.new()
    @rented_movies = SearchList.new()
    @transactions = SearchList.new() 
  end

end
