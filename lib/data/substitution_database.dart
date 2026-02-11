/// Common ingredient substitutions for smart matching.
/// Key: The ingredient you NEED (normalized).
/// Value: List of ingredients you MIGHT HAVE that can work.
const Map<String, List<String>> commonSubstitutions = {
  // Dairy
  'heavy cream': ['greek yogurt', 'creme fraiche', 'coconut milk', 'evaporated milk', 'milk and butter'],
  'sour cream': ['greek yogurt', 'creme fraiche', 'cottage cheese'],
  'buttermilk': ['milk and vinegar', 'milk and lemon juice', 'yogurt'],
  'butter': ['margarine', 'oil', 'coconut oil', 'applesauce'],
  'milk': ['almond milk', 'soy milk', 'oat milk', 'coconut milk', 'water and cream'],
  'cheese': ['nutritional yeast'],
  'parmesan': ['pecorino', 'nutritional yeast'],
  'ricotta': ['cottage cheese'],
  
  // Acids
  'lemon juice': ['lime juice', 'vinegar', 'white wine'],
  'lime juice': ['lemon juice', 'vinegar'],
  'vinegar': ['lemon juice', 'lime juice', 'apple cider vinegar'],
  'balsamic vinegar': ['red wine vinegar', 'apple cider vinegar'],
  'white wine': ['chicken broth', 'vegetable broth', 'apple juice', 'white grape juice', 'ginger ale'],
  'red wine': ['beef broth', 'red grape juice', 'cranberry juice'],

  // Sweeteners
  'sugar': ['honey', 'maple syrup', 'agave nectar', 'brown sugar', 'stevia'],
  'brown sugar': ['white sugar and molasses', 'honey', 'maple syrup'],
  'honey': ['maple syrup', 'agave nectar', 'sugar'],
  'maple syrup': ['honey', 'agave nectar', 'sugar'],

  // Thickeners / Baking
  'cornstarch': ['flour', 'arrowroot powder', 'potato starch'],
  'baking soda': ['baking powder'], // carefully
  'baking powder': ['baking soda and cream of tartar'],
  'egg': ['flax egg', 'chia egg', 'applesauce', 'banana', 'yogurt'],
  'breadcrumbs': ['oats', 'crushed crackers', 'cornflakes'],

  // Sauces / Pastes
  'soy sauce': ['tamari', 'coconut aminos', 'liquid aminos', 'worcestershire sauce'],
  'tomato paste': ['tomato sauce', 'ketchup'],
  'tomato sauce': ['tomato paste and water', 'canned tomatoes'],
  'mayonnaise': ['greek yogurt', 'sour cream'],
  'sriracha': ['hot sauce', 'chili garlic sauce', 'tabasco'],
  'dijon mustard': ['yellow mustard', 'spicy brown mustard', 'dry mustard'],

  // Herbs / Spices
  'fresh basil': ['dried basil'],
  'fresh parsley': ['dried parsley'],
  'fresh cilantro': ['dried cilantro', 'parsley'],
  'fresh ginger': ['ground ginger'],
  'fresh garlic': ['garlic powder', 'minced garlic'],
  'onion': ['onion powder', 'shallot', 'leek'],
  'garlic': ['garlic powder', 'shallot'],
  'shallot': ['onion', 'garlic'],
};
