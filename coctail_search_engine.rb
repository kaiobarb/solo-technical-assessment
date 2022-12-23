require 'net/http'
require 'json'

def get_recipes(type)
    url = "https://www.thecocktaildb.com/api/json/v1/1/search.php?s=#{type}"
    url = URI(url)
    response = Net::HTTP.get(url)
    data = JSON.parse(response)

    instructions = []
    data['drinks'].each do |drink|
      instructions << drink['strInstructions']
    end

    instructions
  end

def search_recipe(ingredients)
  # Extract the recipes for six types of alcohol
  vodka_recipes = get_recipes('vodka')
  whiskey_recipes = get_recipes('whiskey')
  rum_recipes = get_recipes('rum')
  tequila_recipes = get_recipes('tequila')
  brandy_recipes = get_recipes('brandy')
  gin_recipes = get_recipes('gin')

  found = false
  all_recipes = [vodka_recipes, whiskey_recipes, rum_recipes, tequila_recipes, brandy_recipes, gin_recipes]
  all_recipes.each do |recipes|
    recipes.each do |recipe|
      # Check if all the ingredients are present in the recipe
      all_ingredients_present = true
      ingredients.each do |ingredient|
        unless recipe.include?(ingredient)
          all_ingredients_present = false
          break
        end
      end

      # If all the ingredients are present, print the recipe and set found to true
      if all_ingredients_present
        puts recipe
        found = true
      end
    end
  end

  # If no recipe was found, print a message indicating that no recipe could be found with the given ingredients
  unless found
    puts "No recipe found with the given ingredients."
  end
end

puts "Enter a list of ingredients (separated by comma):"
ingredients_string = gets.chomp
ingredients = ingredients_string.split(',').map(&:strip)

search_recipe(ingredients)
