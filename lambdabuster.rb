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


end

