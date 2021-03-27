require_relative "classes"
require 'json'
require 'set'

class Cliente
  def initialize
    @user = User.new
    @compare_options = {"1" => :< , "2" => :<= , "3" => :== , "4" => :>= , "5" => :>}
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

  def buy(transaction_type, user_list, action_str)
    movie_name = prompt("Indique el nombre de la pelicula que desea #{action_str}: ")
    while movie_name != "Salir"
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
          movie.send(transaction_type).dolars.in(currency.to_sym).value.to_s +
          " " + currency

        confirmation = prompt "¿Desea continuar con esta transacción? [N/y]"
        if confirmation == "y"
          @user.send(user_list) << movie.name
          puts "Su orden ha sido procesada con éxito."
        end
        movie_name = "Salir"


      elsif
        movie_name = prompt(
          "La pelicula indicada no se encuentra en la base de datos.\n" + 
          "Pruebe ingresando otro nombre. Tambien puede escribir " +
          "'Salir' para regresar al menu principal: "
        )
      end
    end
  end

  def my_user 
    puts "Películas Compradas: "
    puts @user.owned_movies

    puts "Películas Alquiladas: "
    puts @user.rented_movies

    response = prompt "¿Desea consultar la información de alguna de estas películas? [N/y] "
    while response == "y"
      movie_name = prompt "Ingrese el nombre de la película que desea consultar: "

      while (! @user.owned_movies.include? movie_name) && 
        (! @user.rented_movies.include? movie_name) &&
        (movie_name != "Salir")
        puts "Pelicula no encontrada. Debe ingresar una alguna alquilada o comprada."
        puts "Puede escribir 'Salir' para regresar al menu principal"
        movie_name = prompt "Ingrese el nombre de la película que desea consultar: "
      end

      if movie_name != "Salir"
        movie = (@movies.scan(:name) { |name| name == movie_name }).first
        puts movie
        response2 = prompt "¿Desea consultar la información de algun actor o director " + 
          "de esta pelicula? [N/y] "
        
        while response2 == "y"
          person_name = prompt "Ingrese el nombre de la persona que desea consultar: "

          while (! movie.actors.include? person_name) && 
            (! movie.directors.include? person_name) &&
            (person_name != "Salir")
            puts "Persona no encontrada. Debe ser un actor o director de #{movie.name}."
            puts "Puede escribir 'Salir' para seleccionar otra pelicula."
            person_name = prompt "Ingrese el nombre de la persona que desea consultar: "
          end

          if person_name != "Salir"
            puts @persons[person_name]
            response2 = prompt "¿Desea consultar la información de algun otro actor o " + 
              "director de esta pelicula? [N/y]"
          else
            response2 = "N"
          end
        end
        
        response = prompt "¿Desea consultar la información de alguna otra película? [N/y]"
      else
        response = "N"
      end
    end
  end

  def print_query_menu
    puts "Ingrese alguna de las siguientes acciones:"
    puts "\t [1] - Mostrar todas."
    puts "\t [2] - Filtrar."
    puts "\t [3] - Regresar al menu principal."
  end

  def print_other_filter_menu
    puts "Ingrese alguna de las siguientes acciones:"
    puts "\t [1] - Aplicar otro filtro."
    puts "\t [2] - Buscar."
  end

  def query
    opcion = menu(["1", "2", "3"], :print_query_menu)
    if opcion == "1"
      @movies.each {|x| puts x.to_s + "\n"}
    elsif opcion == "2"
      filter_list = @movies
      end_filter = "1"
      while end_filter == "1"
        filter_list = filter filter_list
        end_filter = menu(["1", "2"], :print_other_filter_menu)
      end
      filter_list.each {|x| puts x.to_s + "\n"}
    end
  end

  def print_query_filter_menu
    puts "Ingrese alguna de las siguientes acciones:"
    puts "\t [1] - Nombre."
    puts "\t [2] - A;o."
    puts "\t [3] - Nombre de director."
    puts "\t [4] - Nombre de actor."
    puts "\t [5] - Duracion."
    puts "\t [6] - Categorias."
    puts "\t [7] - Precio de compra."
    puts "\t [8] - Precio de alquiler."
  end

  def print_match_menu
    puts "Ingrese alguna de las siguientes acciones:"
    puts "\t [1] - Coincidencia exacta."
    puts "\t [2] - Coincidencia parcial."
  end

  def print_compare_menu
    puts "Ingrese alguna de las siguientes acciones:"
    puts "\t [1] - Menor."
    puts "\t [2] - Menor o igual."
    puts "\t [3] - Igual."
    puts "\t [4] - Mayor o igual."
    puts "\t [5] - Mayor."
  end

  def filter(list)
    opcion = menu(["1", "2", "3", "4", "5", "6", "7", "8"], :print_query_filter_menu)
    
    if opcion == "1"
      movie_name = prompt("Indique el nombre que desea buscar: ")
      opcion = menu(["1", "2"], :print_match_menu)
      if opcion == "1"
        list = list.scan(:name) { |name| name == movie_name }
      else
        list = list.scan(:name) { |name| name.include? movie_name }
      end

    elsif opcion == "2"
      year = prompt("Indique el a;o: ")
      opcion = menu(["1", "2", "3", "4", "5"], :print_compare_menu)
      list = list.scan(:release_date) { |date| date.year.send @compare_options[opcion], year.to_i }

    elsif opcion == "3"
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
      runtime_filter = prompt("Indique la cantidad de minutos: ")
      opcion = menu(["1", "2", "3", "4", "5"], :print_compare_menu)
      list = list.scan(:runtime) { 
        |runtime| runtime.send @compare_options[opcion], runtime_filter.to_i 
      }

    elsif opcion == "6"
      catg_filter = []
      puts "Las categorias disponibles son: "
      @categories.each { |x| print x + ", "}
      puts ""

      opcion = "y"
      while opcion == "y"
        catg = prompt "Indique la categoria que desea buscar: "
        while ! @categories.include? catg
          puts "La categoria indicada no es ninguna de las disponibles"
          catg = prompt "Indique la categoria que desea buscar: "
        end
        catg_filter = catg_filter.append(catg)

        opcion = prompt "Desea agregar otra categoria? [N/y]"
      end

      list = list.scan(:categories) { 
        |categories| catg_filter.all? { |catgr| categories.include? catgr }
      }

    elsif opcion == "7"
      price_filter = prompt("Indique el precio de compra: ")
      opcion = menu(["1", "2", "3", "4", "5"], :print_compare_menu)
      list = list.scan(:price) { 
        |price| price.send @compare_options[opcion], price_filter.to_i 
      }

    elsif opcion == "8"
      price_filter = prompt("Indique el precion de renta: ")
      opcion = menu(["1", "2", "3", "4", "5"], :print_compare_menu)
      list = list.scan(:rent_price) { 
        |price| price.send @compare_options[opcion], price_filter.to_i 
      }
    end

    return list
  end
end

c = Cliente.new
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
