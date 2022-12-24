require 'net/http'
require 'json'
require 'set'

def get_recipes(type, instructions_lookup, ingredient_lookup)
  url = "https://www.thecocktaildb.com/api/json/v1/1/search.php?s=#{type}"
  url = URI(url)
  response = Net::HTTP.get(url)
  data = JSON.parse(response)
  
  data['drinks'].each do |drink|
    drink_id = drink['idDrink'].to_i()
    instructions_lookup[drink_id] = drink['strInstructions']
    15.times do |index|
      ingredient = drink["strIngredient#{index+1}"]
      if ingredient.nil?
        break
      end
      if ingredient_lookup[ingredient].nil?
        ingredient_lookup[ingredient] = [drink_id]
      else 
        ingredient_lookup[ingredient] << drink_id
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

  shared_recipes = []
  ingredients.each do |ingredient|
    if ingredient_map[ingredient].nil?
      break
    end
    if shared_recipes.empty?
      shared_recipes = ingredient_map[ingredient]
    else
      shared_recipes = shared_recipes & ingredient_map[ingredient]
    end
  end
  
  if shared_recipes.empty?
    puts "No recipe found with the given ingredients."
  else
    shared_recipes.each do |recipe_id|
      puts recipes[recipe_id]
      puts
    end
  end
end


puts "Enter a list of ingredients (separated by comma):"
ingredients_string = gets.chomp
ingredients = ingredients_string.split(',').map(&:strip)

search_recipe(ingredients)
