require 'net/http'
require 'json'
require 'set'

def get_recipes(type, instructions_lookup, ingredient_lookup)
  url = "https://www.thecocktaildb.com/api/json/v1/1/search.php?s=#{type}"
  url = URI(url)
  response = Net::HTTP.get(url)
  data = JSON.parse(response)
  
  data['drinks'].each do |drink|
    drink_name = drink['strDrink']
    instructions_lookup[drink_name] = drink['strInstructions']
    15.times do |index|
      ingredient = drink["strIngredient#{index+1}"]
      if ingredient.nil?
        break
      end
      if ingredient_lookup[ingredient].nil?
        ingredient_lookup[ingredient] = [drink_name]
      else 
        ingredient_lookup[ingredient] << drink_name
      end
    end
  end
  [instructions_lookup, ingredient_lookup]
end

def search_recipe(ingredients)
  recipes = {}
  ingredient_map = {}

  # Extract the recipes for six types of alcohol
  vodka_recipes = get_recipes('vodka', recipes, ingredient_map)
  whiskey_recipes = get_recipes('whiskey', recipes, ingredient_map)
  rum_recipes = get_recipes('rum', recipes, ingredient_map)
  tequila_recipes = get_recipes('tequila', recipes, ingredient_map)
  brandy_recipes = get_recipes('brandy', recipes, ingredient_map)
  gin_recipes = get_recipes('gin', recipes, ingredient_map)

  shared_recipes = Set.new
  ingredients.each do |ingredient|
    if ingredient_map[ingredient].nil?
      break
    end
    if shared_recipes.empty?
      shared_recipes = Set.new(ingredient_map[ingredient])
    else
      shared_recipes = shared_recipes.intersection(Set.new(ingredient_map[ingredient]))
    end
  end
  
  if shared_recipes.empty?
    puts "No recipe found with the given ingredients."
  else
    puts
    puts "Found #{shared_recipes.size} recipes!"
    shared_recipes.each do |drink_name|
      puts drink_name
      puts recipes[drink_name]
      puts
    end
  end
end


puts "Enter a list of ingredients (separated by comma):"
ingredients_string = gets.chomp
ingredients = ingredients_string.split(',').map(&:strip)

search_recipe(ingredients)
