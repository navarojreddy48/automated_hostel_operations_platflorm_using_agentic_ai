-- Seed the mess_menu table with the initial weekly menu
-- This will populate the database with the default menu items

USE hostelconnect_db;

-- Clear existing data
TRUNCATE TABLE mess_menu;

-- Monday
INSERT INTO mess_menu (day_of_week, meal_type, menu_items) VALUES
('monday', 'breakfast', 'Idli\nSambar\nPalli Chutney\nGinger Chutney\nTea & Milk (Common)'),
('monday', 'lunch', 'Plain Rice\nCabbage Fry\nTomato Dal\nDrumstick Sambar\nCurd, Papad & Chutneys (Common)'),
('monday', 'snacks', 'Veg & Egg Noodles / Onion Samosa\nTea & Milk (Common)'),
('monday', 'dinner', 'Plain Rice\nBobbatlu\nBrinjal Curry\nKandagadala Curry\nMethi Dal\nEgg Fry\nTomato Rasam\nCurd, Papad & Chutneys (Common)');

-- Tuesday
INSERT INTO mess_menu (day_of_week, meal_type, menu_items) VALUES
('tuesday', 'breakfast', 'Uthappam / Pesarattu\nPalli Chutney\nGinger Chutney\nTea & Milk (Common)'),
('tuesday', 'lunch', 'Plain Rice\nBendi Fry/Curry\nThotakura Dal\nMiriyalu Rasam\nCurd, Papad & Chutneys (Common)'),
('tuesday', 'snacks', 'Veg Puff & Egg Puff\nTea & Milk (Common)'),
('tuesday', 'dinner', 'Plain Rice\nMixed Vegetable Curry\nEgg Curry\nDal Tadka\nChapathi\nCarrot Sambar\nCurd, Papad & Chutneys (Common)');

-- Wednesday
INSERT INTO mess_menu (day_of_week, meal_type, menu_items) VALUES
('wednesday', 'breakfast', 'Wada\nSambar\nPalli Chutney\nGinger Chutney\nTea & Milk (Common)'),
('wednesday', 'lunch', 'Plain Rice\nChikkudukaya Tomato Curry\nPumpkin Sambar\nDosakaya Dal\nCurd, Papad & Chutneys (Common)'),
('wednesday', 'snacks', 'Mixed Fruits (Separate) / Sweet Corn / Banana\nTea & Milk (Common)'),
('wednesday', 'dinner', 'Plain Rice\nBagara Rice\nChicken Curry\nPaneer Butter Masala\nPumpkin Sambar\nRaita\nCurd, Papad & Chutneys (Common)');

-- Thursday
INSERT INTO mess_menu (day_of_week, meal_type, menu_items) VALUES
('thursday', 'breakfast', 'Dosa\nAloo Masala Curry\nPalli Chutney\nGinger Chutney\nTea & Milk (Common)'),
('thursday', 'lunch', 'Plain Rice\nMethi Dal\nDonda Fry/Curry\nTomato Rasam\nCurd, Papad & Chutneys (Common)'),
('thursday', 'snacks', 'Cool Cake / Pineapple Cake / Butterscotch Cake / Plum Cake\nTea & Milk (Common)'),
('thursday', 'dinner', 'Plain Rice\nChapathi\nDal Fry\nMeal Maker / Rajma\nEgg Burji / Egg Masala\nMajjiga Charu\nCurd, Papad & Chutneys (Common)');

-- Friday
INSERT INTO mess_menu (day_of_week, meal_type, menu_items) VALUES
('friday', 'breakfast', 'Lemon Rice / Tamarind Rice\nUpma\nBread Jam\nTomato Chutney\nPalli Chutney\nTea & Milk (Common)'),
('friday', 'lunch', 'Plain Rice\nAahu Curry/Fry\nChukkakura Dal\nSorakaya Sambar\nCurd, Papad & Chutneys (Common)'),
('friday', 'snacks', 'Punugulu / Mirchi Bajji\nTea & Milk (Common)'),
('friday', 'dinner', 'Plain Rice\nEgg/Veg Fried Rice OR Veg Pulav\nTomato Egg Curry\nAahu Curry\nCarrot Sambar\nCurd, Papad & Chutneys (Common)');

-- Saturday
INSERT INTO mess_menu (day_of_week, meal_type, menu_items) VALUES
('saturday', 'breakfast', 'Mysore Bonda\nTomato Chutney\nPalli Chutney\nTea & Milk (Common)'),
('saturday', 'lunch', 'Plain Rice\nMixed Veg Curry\nBachalakara Dal\nRasam/Sambar\nCurd, Papad & Chutneys (Common)'),
('saturday', 'snacks', 'Dil Pasand / Donuts / Burger / Dil Kush\nTea & Milk (Common)'),
('saturday', 'dinner', 'Plain Rice\nSambar Rice\nThotakura Dal\nGobi Manchuria / Veg Manchuria\nMiriyalu Rasam\nBoiled Egg\nCurd, Papad & Chutneys (Common)');

-- Sunday
INSERT INTO mess_menu (day_of_week, meal_type, menu_items) VALUES
('sunday', 'breakfast', 'Chapathi\nChole Curry\nTea & Milk (Common)'),
('sunday', 'lunch', 'Plain Rice\nBrinjal Curry\nMoong Dal\nCarrot Sambar\nCurd, Papad & Chutneys (Common)'),
('sunday', 'snacks', 'Cashew / Moon Fruit / Osmania Biscuits\nTea & Milk (Common)'),
('sunday', 'dinner', 'Plain Rice\nBagara Rice\nChicken Curry / Chicken Biryani\nPaneer Butter Masala / Paneer Biryani\nCarrot Sambar\nRaita\nDouble Ka Meetha (2 times) / Semiya Payasam / Kadduka Kheer\nCurd, Papad & Chutneys (Common)');

-- Verify the data
SELECT day_of_week, meal_type, COUNT(*) as item_count 
FROM mess_menu 
GROUP BY day_of_week, meal_type 
ORDER BY 
    FIELD(day_of_week, 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'),
    FIELD(meal_type, 'breakfast', 'lunch', 'snacks', 'dinner');
