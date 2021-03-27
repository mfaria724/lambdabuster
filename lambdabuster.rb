require_relative "classes"
require 'json'

persons = {}
actors = {}
directors = {}

def read_person(person_class, data)
  person_class.new(data["name"], Date.parse(data["birthday"]), data["nationality"])
end

def read_json(file)
  file = File.read('./file-name-to-be-read.json')
  data_hash = JSON.parse(file)
  for director in data_hash["directors"]
    if ! persons.keys.include? director["name"]
      persons[director["name"]] = read_person(Person, director)
      directors[director["name"]] = read_person(Director, director)
    else
      throw "El director #{director["name"]} aparece dos veces."
    end
  end

  for actor in data_hash["actors"]
    if ! actors.keys.include? actor["name"]
      actors[actor["name"]] = read_person(Actor, actor)
      if ! persons.keys.include? actor["name"]
        persons[actor["name"]] = read_person(Person, actor)
      end
    else 
      throw "El actor #{actor["name"]} aparece dos veces." 
    end
  end
end

