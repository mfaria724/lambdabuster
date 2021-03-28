require_relative "classes"
require 'json'
require 'set'
require 'date'

# class to manipulate all cliente logic
class Cliente
  attr_accessor :rented_movies

  def initialize
    # instanciates the initial user and adds some utilities for options
    @user = User.new
    @compare_options = {"1" => :< , "2" => :<= , "3" => :== , "4" => :>= , "5" => :>}
  end

  # creates an object with the provided class parsin the date
  def read_person(person_class, data)
    person_class.new(data["name"], Date.parse(data["birthday"]), data["nationality"])
  end

  # creates an object for a Movie, and wraps it into a Premier and/or Discount 
  # when it applies
  def read_movie(data)
    movie = Movie.new(
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

    # wraps it into Premier and/or Discount objects respectively
    if data["premiere"] == "True"
      movie = Premiere.new(movie)
    end

    if data["discount"] != 0
      movie = Discount.new(movie)
    end

    movie
  end

  # helper method to create a prompt
  def prompt(msg)
    print msg
    text = gets
    text.chomp
  end

  # read json initializer
  def read_json
    @persons = {}
    @actors = {}
    @directors = {}
    @categories = Set.new

    # ask for json location
    file_name = self.prompt "Indique el archivo JSON: "
    file = File.read(file_name)

    # uses json library to parse
    data_hash = JSON.parse(file)

    # checks if a person appears more than once as Director
    for director in data_hash["directors"]
      if ! @persons.keys.include? director["name"]
        @persons[director["name"]] = self.read_person(Person, director)
        @directors[director["name"]] = self.read_person(Director, director)
      else
        throw "El director #{director["name"]} aparece dos veces."
      end
    end

    # checks if an Actor appears more than once as an actor and if him appears
    # as a director avoid adding it again as a new Person
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

    # parse the movies 
    movies = []
    for movie in data_hash["movies"]
      movies = movies.append(self.read_movie(movie))
      for catg in movie["categories"]
        @categories << catg
      end
    end
    @movies = SearchList.new(*movies)
  end

  # helper method to clear the console
  def clear
    print "\033c"
  end

  # helper method to print the options of the main menu
  def print_menu
    puts "Ingrese alguna de las siguientes acciones:".bold()
    puts "\t [1] - Crear nueva orden de alquiler."
    puts "\t [2] - Crear nueva orden de compra."
    puts "\t [3] - Mi Usuario."
    puts "\t [4] - Consultar catálogo."
    puts "\t [5] - Salir."
  end

  # prompts any given menu and asks for a valid option
  def menu(opcion_list, print_menu)
    self.send(print_menu)
    opcion = self.prompt "Opcion: "

    while ! opcion_list.include? opcion
      self.clear
      puts "Opcion invalida! Debe estar estar entre #{opcion_list.first} y #{opcion_list.last}"
      self.send(print_menu)
      opcion = self.prompt "Opcion: "
    end

    return opcion
  end

  # starts the process of starting a new operation, even renting or
  # purchase
  def buy(transaction_type, user_list, action_str)

    # gets movie name
    movie_name = prompt("Indique el nombre de la pelicula que desea #{action_str}: ")
    salir = true
    while movie_name != "Salir"
      salir = false
      # checks if the movie is in the database
      movie = @movies.scan(:name) { |name| name == movie_name }

      if ! movie.empty?
        movie = movie.first
        puts "\n#{movie}\n"

        # asks for currency for the payment
        currency = prompt("Indique el tipo de moneda para el pago [dolars/euros/bolivares/bitcoins]: ")
        while ! ["dolars", "euros", "bolivares", "bitcoins"].include? currency
          puts "Moneda invalida.".bold() + 
            " Debe ser 'dolars', 'euros', 'bolivares' o 'bitcoins'."
          currency = prompt("Indique el tipo de moneda para el pago: ")
        end

        # prints the information about the total of the movie
        puts "\nEl precio de la pelicula es ".bold() +
          movie.send(transaction_type).dolars.in(currency.to_sym).value.to_s.bold() +
          " " + currency.bold()
        puts "\n"

        # confirmation message for the user
        confirmation = prompt "¿Desea continuar con esta transacción? [N/y]"
        if confirmation == "y"
          @user.send(user_list) << movie.name
          self.clear()
          puts "Su orden ha sido procesada con éxito.\n".bold()
        else
          self.clear()
          puts "La transacción ha sido cancelada.\n".bold()
        end
        movie_name = "Salir"

        # stores the successfull transation in the transactions lists
        if transaction_type == "price"
          @user.transactions << Transaction.new(movie, :buy)
        else
          @user.transactions << Transaction.new(movie, :rent)
        end 

      elsif
        movie_name = prompt(
          "La pelicula indicada no se encuentra en la base de datos.\n".bold() + 
          "Pruebe ingresando otro nombre. Tambien puede escribir " +
          "'Salir' para regresar al menu principal: "
        )
        salir = true
      end

    end
    if salir
      clear
    end
  end

  # function to start functionality my user
  def my_user 

    # checks if there's information to show
    if @user.owned_movies.empty? && @user.rented_movies.empty?
      self.clear()
      puts "No existe ninguna transacción aún.".bold()
      return
    end

    # prints the lists of rented and purchased movies
    puts "\nPelículas Compradas: ".bold()
    puts @user.owned_movies

    puts "\nPelículas Alquiladas: ".bold()
    puts @user.rented_movies

    # asks if user wants to consult the information of a movies
    puts "\n"
    response = prompt "¿Desea consultar la información de alguna de estas películas? [N/y] "
    
    while response == "y"
      puts "\n"
      # asks for movie name
      movie_name = prompt "Ingrese el nombre de la película que desea consultar: "

      # check if the movie is on the list
      while (! @user.owned_movies.include? movie_name) && 
        (! @user.rented_movies.include? movie_name) &&
        (movie_name != "Salir")
        puts "\nPelicula no encontrada. ".bold() + 
          "Debe ingresar alguna alquilada o comprada por usted."
        puts "Puede escribir 'Salir' para regresar al menu principal.\n"
        movie_name = prompt "Ingrese el nombre de la película que desea consultar: "
      end

      if movie_name != "Salir"
        # prints the movie information
        movie = (@movies.scan(:name) { |name| name == movie_name }).first
        puts "\n#{movie}\n"

        # asks if user wants information about a Person in the movie
        response2 = prompt "¿Desea consultar la información de algun actor o director " + 
          "de esta pelicula? [N/y] "
        
        while response2 == "y"
          # asks for the name of the person
          person_name = prompt "\nIngrese el nombre de la persona que desea consultar: "

          # checks that the person is valid
          while (! movie.actors.include? person_name) && 
            (! movie.directors.include? person_name) &&
            (person_name != "Salir")
            puts "Persona no encontrada. Debe ser un actor o director de #{movie.name}."
            puts "Puede escribir 'Salir' para seleccionar otra pelicula."
            person_name = prompt "Ingrese el nombre de la persona que desea consultar: "
          end

          # prints the information of the Person if required
          if person_name != "Salir"
            puts "\n#{@persons[person_name]}\n"
            response2 = prompt "¿Desea consultar la información de algun otro actor o " + 
              "director de esta pelicula? [N/y]"
          else
            response2 = "N"
          end
        end
        
        # checks if wants to keep consulting movies
        response = prompt "¿Desea consultar la información de alguna otra película? [N/y]"
      else
        response = "N"
      end
    end

    self.clear()
  end

  # helper for filtering main menu
  def print_query_menu
    puts "Ingrese alguna de las siguientes acciones:".bold()
    puts "\t [1] - Mostrar todas."
    puts "\t [2] - Filtrar."
    puts "\t [3] - Regresar al menu principal."
  end

  # helper for multiple filters on the menu
  def print_other_filter_menu
    puts "Ingrese alguna de las siguientes acciones:".bold()
    puts "\t [1] - Aplicar otro filtro."
    puts "\t [2] - Buscar."
  end

  # implements the catalog functionality
  def query

    # starts with the main menu 
    opcion = menu(["1", "2", "3"], :print_query_menu)
    if opcion == "1"
      # shows all movies 
      clear
      puts "Catálogo completo de películas:\n".bold()
      @movies.each {|x| puts x.to_s + "\n"}
    elsif opcion == "2"
      # keeps asking if user wants to add more filters to the query
      filter_list = @movies
      end_filter = "1"
      while end_filter == "1"
        filter_list = filter filter_list
        end_filter = menu(["1", "2"], :print_other_filter_menu)
      end

      self.clear()

      # prints the results of the query
      puts "Resultados de la búsqueda:\n".bold()
      filter_list.each {|x| puts x.to_s + "\n"}
    end
  end

  # helper menu for atributes which can be applied to the movies
  def print_query_filter_menu
    puts "Ingrese alguna de las siguientes acciones:".bold()
    puts "\t [1] - Nombre."
    puts "\t [2] - Año."
    puts "\t [3] - Nombre de director."
    puts "\t [4] - Nombre de actor."
    puts "\t [5] - Duracion."
    puts "\t [6] - Categorias."
    puts "\t [7] - Precio de compra."
    puts "\t [8] - Precio de alquiler."
  end

  # helper menu for the type of coincidence
  def print_match_menu
    puts "Ingrese alguna de las siguientes acciones:".bold()
    puts "\t [1] - Coincidencia exacta."
    puts "\t [2] - Coincidencia parcial."
  end

  # helper menu for the type of comparison
  def print_compare_menu
    puts "Ingrese alguna de las siguientes acciones:".bold()
    puts "\t [1] - Menor."
    puts "\t [2] - Menor o igual."
    puts "\t [3] - Igual."
    puts "\t [4] - Mayor o igual."
    puts "\t [5] - Mayor."
  end

  # starts the filtering functionality
  def filter(list)
    opcion = menu(["1", "2", "3", "4", "5", "6", "7", "8"], :print_query_filter_menu)
    
    # if clause for every type of filter that can be applied over the movies
    if opcion == "1"
      # search by name
      movie_name = prompt("Indique el nombre que desea buscar: ")
      opcion = menu(["1", "2"], :print_match_menu)
      if opcion == "1"
        list = list.scan(:name) { |name| name == movie_name }
      else
        list = list.scan(:name) { |name| name.include? movie_name }
      end

    elsif opcion == "2"
      # search by year
      year = prompt("Indique el año: ")
      opcion = menu(["1", "2", "3", "4", "5"], :print_compare_menu)
      list = list.scan(:release_date) { |date| date.year.send @compare_options[opcion], year.to_i }

    elsif opcion == "3"
      # search by director
      director_name = prompt("Indique el nombre del director que desea buscar: ")
      opcion = menu(["1", "2"], :print_match_menu)
      if opcion == "1"
        list = list.scan(:directors) { 
          |directors| directors.any? { |name| name == director_name } 
        }
      else
        list = list.scan(:directors) { 
          |directors| directors.any? { |name| name.include? director_name } 
        }
      end

    elsif opcion == "4"
      # search by actor
      actor_name = prompt("Indique el nombre del actor que desea buscar: ")
      opcion = menu(["1", "2"], :print_match_menu)
      if opcion == "1"
        list = list.scan(:actors) { 
          |actors| actors.any? { |name| name == actor_name } 
        }
      else
        list = list.scan(:actors) { 
          |actors| actors.any? { |name| name.include? actor_name } 
        }
      end

    elsif opcion == "5"
      # search by runtime
      runtime_filter = prompt("Indique la cantidad de minutos: ")
      opcion = menu(["1", "2", "3", "4", "5"], :print_compare_menu)
      list = list.scan(:runtime) { 
        |runtime| runtime.send @compare_options[opcion], runtime_filter.to_i 
      }

    elsif opcion == "6"
      # search by category
      catg_filter = []
      puts "Las categorias disponibles son: "
      @categories.each { |x| print x + ", "}
      puts ""

      opcion = "y"
      # asks for every category and checks if the category exists
      while opcion == "y"
        catg = prompt "Indique la categoria que desea buscar: "
        while ! @categories.include? catg
          puts "La categoria indicada no es ninguna de las disponibles"
          catg = prompt "Indique la categoria que desea buscar: "
        end
        catg_filter = catg_filter.append(catg)

        opcion = prompt "Desea agregar otra categoria? [N/y]"
      end

      # applies the filter
      list = list.scan(:categories) { 
        |categories| catg_filter.all? { |catgr| categories.include? catgr }
      }

    elsif opcion == "7"
      # search by purchase price
      price_filter = prompt("Indique el precio de compra: ")
      opcion = menu(["1", "2", "3", "4", "5"], :print_compare_menu)
      list = list.scan(:price) { 
        |price| price.send @compare_options[opcion], price_filter.to_i 
      }

    elsif opcion == "8"
      # search by renting price
      price_filter = prompt("Indique el precion de renta: ")
      opcion = menu(["1", "2", "3", "4", "5"], :print_compare_menu)
      list = list.scan(:rent_price) { 
        |price| price.send @compare_options[opcion], price_filter.to_i 
      }
    end

    return list
  end
end

# infinite loop to initialize the REPL 
c = Cliente.new

# loads database information
c.read_json

c.clear
exit = false
while ! exit
  opcion = c.menu(["1", "2", "3", "4", "5"], :print_menu)
  if opcion == "1"
    c.buy(:rent_price, :rented_movies, "alquilar")
  elsif opcion == "2"
    c.buy(:price, :owned_movies, "comprar")
  elsif opcion == "3"
    c.my_user
  elsif opcion == "4"
    c.query
  elsif opcion == "5"
    exit = true
  end
end
