require_relative "classes"
require 'json'
require 'set'

class Cliente
  def initialize
    @user = User.new
  end

  def read_person(person_class, data)
    person_class.new(data["name"], Date.parse(data["birthday"]), data["nationality"])
  end

  def read_movie(data)
    Movie.new(
      data["name"],
      data["runtime"],
      data["categories"],
      Date.parse(data["release_date"]),
      data["directors"],
      data["actors"],
      data["price"],
      data["rent_price"],
      data["premiere"],
      data["discount"]
    )
  end

  def prompt(msg)
    print msg
    text = gets
    text.chomp
  end

  def read_json
    @persons = {}
    @actors = {}
    @directors = {}
    @categories = Set.new

    file_name = self.prompt "Indique el archivo JSON: "
    file = File.read(file_name)
    data_hash = JSON.parse(file)
    for director in data_hash["directors"]
      if ! @persons.keys.include? director["name"]
        @persons[director["name"]] = self.read_person(Person, director)
        @directors[director["name"]] = self.read_person(Director, director)
      else
        throw "El director #{director["name"]} aparece dos veces."
      end
    end

    for actor in data_hash["actors"]
      if ! @actors.keys.include? actor["name"]
        @actors[actor["name"]] = self.read_person(Actor, actor)
        if ! @persons.keys.include? actor["name"]
          @persons[actor["name"]] = self.read_person(Person, actor)
        end
      else 
        throw "El actor #{actor["name"]} aparece dos veces." 
      end
    end

    movies = []
    for movie in data_hash["movies"]
      movies = movies.append(self.read_movie(movie))
      for catg in movie["categories"]
        @categories << catg
      end
    end
    @movies = SearchList.new(*movies)
  end

  def clear
    print "\033c"
  end

  def print_menu
    puts "Ingrese alguna de las siguientes acciones:"
    puts "\t [1] - Crear nueva orden de alquiler."
    puts "\t [2] - Crear nueva orden de compra."
    puts "\t [3] - Mi Usuario."
    puts "\t [4] - Consultar catálogo."
    puts "\t [5] - Salir."
  end

  def menu
    self.print_menu
    opcion = self.prompt "Opcion: "

    while ! ["1", "2", "3", "4", "5"].include? opcion
      self.clear
      puts "Opcion invalida! Debe estar estar entre 1 y 5"
      self.print_menu
      opcion = self.prompt "Opcion: "
    end

    return opcion
  end

  def buy 
    movie_name = prompt("Indique el nombre de la pelicula que desea alquilar: ")
    movie = @movies.scan(:name) { |name| name == movie_name }
    if ! movie.empty?
      movie = movie.first
      puts movie
      currency = prompt("Indique el tipo de moneda para el pago: ")
      while ! ["dolars", "euros", "bolivares", "bitcoins"].include? currency
        puts "Moneda invalida. Debe ser 'dolars', 'euros', 'bolivares' o 'bitcoins'."
        currency = prompt("Indique el tipo de moneda para el pago: ")
      end

      puts "El precio de la pelicula es " +
        movie.price.dolars.in(currency.to_sym).value.to_s +
        " " + currency
    end
  end

end

c = Cliente.new
c.read_json
c.clear
exit = false
while ! exit
  opcion = c.menu
  if opcion == "1"
    c.buy
  elsif opcion == "5"
    exit = true
  end
end
